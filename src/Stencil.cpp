//===--------------------------------- Stencil.cpp ------------------------===//
//
// This file is distributed under the XXX license.
// See LICENSE.TXT for details.
//
// Copyright (C) 2017   Alyson Deives Pereira
//
//===----------------------------------------------------------------------===//
//
// Stencil is an optimization to identify stencil computation loops
//
//===----------------------------------------------------------------------===//

#include <fstream>
#include <queue>


#include "llvm/Analysis/RegionInfo.h"  
#include "llvm/Analysis/AliasAnalysis.h"
#include "llvm/Analysis/ScalarEvolutionExpressions.h"
#include "llvm/Analysis/ScalarEvolution.h"
#include "llvm/Analysis/LoopInfo.h"

#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/DIBuilder.h" 
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Value.h"

#include "llvm/Support/CommandLine.h"
#include "llvm/Support/DataTypes.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Analysis/ValueTracking.h"
#include "llvm/ADT/Statistic.h"


//#include "../../dawncc/ArrayInference/PtrRangeAnalysis.h"
//#include "../../dawncc/ArrayInference/regionReconstructor.h"

#include "Stencil.h"

using namespace llvm;
using namespace std;
using namespace lge;

Value* Stencil::getPointerOperand(Instruction *Inst) {
  if (LoadInst *Load = dyn_cast<LoadInst>(Inst))
    return Load->getPointerOperand();
  else if (StoreInst *Store = dyn_cast<StoreInst>(Inst))
    return Store->getPointerOperand();
  else if (GetElementPtrInst *GEP = dyn_cast<GetElementPtrInst>(Inst))
    return GEP->getPointerOperand();

  return 0;
}

void Stencil::populateArrayExpression (ArrayExpression *arr, Value *Val) {
    Instruction *Ins;
    int numOperands = 0;
    if ((Ins = dyn_cast<Instruction>(Val))){
		//errs()<<"Populating "<<*Ins<<"\n";
		if (!(isa<PHINode>(*Ins))) {
            numOperands = Ins->getNumOperands();
            //errs()<<"Check :"<<*Val<<" has "<<numOperands<<" operands"<<"\n";
            if(isa<GetElementPtrInst>(*Ins)){
				arr->insert(std::pair<Value*,Value*>(Val,Ins->getOperand(1))); 
				//errs()<<"Inserted "<<*Ins->getOperand(1)<<"\n";
				populateArrayExpression(arr,Ins->getOperand(1));
			}
			else{
				for (int i=0; i<numOperands;i++) {
					arr->insert(std::pair<Value*,Value*>(Val,Ins->getOperand(i))); 
					//errs()<<"Inserted "<<*Ins->getOperand(i)<<"\n";
					populateArrayExpression(arr,Ins->getOperand(i));
				}
			}
        }
    }
}

bool Stencil::populateArrayAccess (Value *Val, ArrayAccess *acc){
    Instruction *Ins;
    int numOperands = 0;
    if ((Ins = dyn_cast<Instruction>(Val))){
        numOperands = Ins->getNumOperands();
        //errs()<<"Val :"<<*Val<<" has "<<numOperands<<" operands"<<"\n";
        if(LoadInst *LD = dyn_cast<LoadInst>(Ins)){
            // Print SCEV
            BasicBlock *bb = LD->getParent();
            Loop *L = LI->getLoopFor(bb);
            //errs()<<"Val: "<<*Val<<"\n";
            //const SCEV* scev_exp = SE->getSCEVAtScope(LD->getPointerOperand(), L);
            const SCEV* scev_exp = SE->getSCEV(LD->getPointerOperand());
            errs()<<"-----------------------------------------------------------\n";
            //errs()<<"SCEV Access: "<<*scev_exp<<"\n";
            //printSCEV(scev_exp, SE->getElementSize(dyn_cast<Instruction>(LD->getPointerOperand())));
			//errs()<<"ElementSize: "<<*SE->getElementSize(LD)<<"\n";
			Neighbor2D neighbor;
            delinearize(scev_exp, neighbor);
			ArrayExpression arr;
			//errs()<<"PointerOperand: "<<*(dyn_cast<LoadInst>(Ins))->getPointerOperand()<<"\n";
			populateArrayExpression(&arr, Ins->getOperand(0));
			//for(int i=0; i<numOperands;i++){
            //    populateArrayExpression(&arr, Ins->getOperand(i));
            //}
            acc->insert( std::pair<Value*,ArrayExpression>(Ins,arr));
		}
        /*
        if(isa<GetElementPtrInst>(*Ins)){
            ArrayExpression arr;
            for(int i=0; i<numOperands;i++){
                populateArrayExpression(&arr, Ins->getOperand(i));
            }
            this->arrayAcc.insert( std::pair<Value*,ArrayExpression>(Ins,arr));
            //errs()<<"GEP inserted with Array Expression"<<*Ins<<"\n"; 
        }
        */
        else{
            for(int i=0; i<numOperands;i++){
                if(!(isa<PHINode>(*Ins))){ 
					//errs()<<"Populating: "<<*Ins<<"\n";
                    populateArrayAccess(Ins->getOperand(i),acc);
                }
            }
        }
    }
    else {
        //errs()<<"Val is not a Instruction: "<<*Val<<"\n";
    }

    return (acc->size() != 0);
}
/*
void Stencil::populateArrayAccess (Value *Val) {
    Instruction *Ins;
    int numOperands = 0;
    if (Ins = dyn_cast<Instruction>(Val)){
        numOperands = Ins->getNumOperands();
        errs()<<"Val :"<<*Val<<" has "<<numOperands<<" operands"<<"\n";
        for(int i=0; i<numOperands;i++){
            if(!(isa<PHINode>(*Ins))){
                populateTree(Ins->getOperand(i));
            }
        }
    }
    else {
        errs()<<"Val is not a Instruction: "<<*Val<<"\n";
    }
    //for(int i=0; i<numOperands;i++){
        //if(!(isa<PHINode>(*Val)) && !(isa<Constant>(*Val))){
        //    populateTree(Val->getOperand(i));
        //}
    //}
}
*/

void Stencil::delinearize(const SCEV *S, Neighbor2D &str_neighbor){
	errs()<<"SCEV Function: "<<*S<<"\n";
	const SCEVUnknown *BasePointer = dyn_cast<SCEVUnknown>(SE->getPointerBase(S));
	
	// Do not delinearize if we cannot find the base pointer.
    if (!BasePointer) {
		errs()<<"Could not find base pointer in SCEV : "<<*S<<"\n";  
	}
	
	Value *BasePtr = BasePointer->getValue();
	S = SE->getMinusSCEV(S, BasePointer);
	
	//errs()<<"Minus SCEV Function: "<<*S<<"\n";
	
	const SCEVMulExpr *M1 = dyn_cast<SCEVMulExpr>(S);
	if(!M1) {
		errs()<<"Expected Mul Expression: "<<*S<<"\n";
	}
	
	if(M1->getNumOperands() != 2){
		errs()<<"Expected 2 Operands in MulExpr: "<<*M1<<"\n";
	}
	
	const SCEV *ElementSize = M1->getOperand(0);
	
	const SCEVSignExtendExpr *Sign = dyn_cast<SCEVSignExtendExpr>(M1->getOperand(1));
	
	if(!Sign){
		errs()<<"Expected SExt expression: "<<*M1<<"\n";
	}
	
	Type *SignType = Sign->getType();
	
	const SCEV *S1 = Sign->getOperand();
	
	if(!isa<SCEVAddRecExpr>(S1)){
		errs()<<"Expected SCEV AddRec expression: "<<*Sign<<"\n";
	}
	
	errs()<<"Base Pointer: "<<*BasePtr<<"\n";
	errs()<<"Access SCEV: "<<*S1<<"\n";
	
	//Now we have a AddRec SCEV. We need to traverse it! 
	//std::map<const Loop*,const SCEV*> Loops;
    SmallVector<const Loop*, 3> SCEVLoops;
    SmallVector<const SCEV*, 3> SCEVSteps;
	
	while(isa<SCEVAddRecExpr>(S1)){
		const Loop *L = dyn_cast<SCEVAddRecExpr>(S1)->getLoop();
		const SCEV *Step = dyn_cast<SCEVAddRecExpr>(S1)->getStepRecurrence(*SE);

        SCEVLoops.push_back(L);
        SCEVSteps.push_back(Step);

        //errs()<<"SCEV Step: "<<*Step<<"\n";
        //errs()<<"SCEV Loop: "<<*L<<"\n";
        
		//Loops.insert(std::pair<const Loop*,const SCEV*>(L,Step));
		S1 = (dyn_cast<SCEVAddRecExpr>(S1))->getStart();
	}
	
	switch (SCEVLoops.size()){
		case 1:
			//TODO parse1D
			//parseSCEV(S1,Loops);
			break;
		case 2:
			parse2DSCEV(S1,SCEVLoops, SCEVSteps);
			break;
		case 3:
			//TODO parse3D
			//parse3DSCEV(S1,Loops);
			break;
	}
	
	
	
	//printSCEV(S1, ElementSize);
    
}

void Stencil::parse2DSCEV(const SCEV *S, SmallVector<const Loop*,3> &L, SmallVector<const SCEV*,3> &Steps){
    PHINode *Outer = getPHINode(L[1]);
    PHINode *Inner = getPHINode(L[0]);

    //errs()<<"PHINode Inner: "<<*Inner<<"\n";
    //errs()<<"PHINode Outer: "<<*Outer<<"\n";

    ConstantInt *InnerValue = dyn_cast<ConstantInt>(Inner->getIncomingValue(0));
    ConstantInt *OuterValue = dyn_cast<ConstantInt>(Outer->getIncomingValue(0));

    int innerVal = InnerValue->getSExtValue();
    int outerVal = OuterValue->getSExtValue();

    int offsetOuter = 0;
    int offsetInner = 0;


    const SCEVAddExpr *AddExpr;
    const SCEVConstant *Const;
    const SCEVMulExpr *MulExpr;
    
    switch(S->getSCEVType()){
	case scConstant:
		// 2D Case
		// InnerLoop - offset = -1*PHINODE-initial-value
		// OuterLoop - offset = Constant - PHINODE-initial-value
        offsetInner = -1 * innerVal;
        offsetOuter = (dyn_cast<SCEVConstant>(S))->getValue()->getSExtValue() - outerVal;
		break;
	case scUnknown:
		//2D Case
		// InnerLoop = offset = PHINODE-initial-value - 1
		// OuterLoop = offset = -1*PHINODE-initial-value
        offsetInner = innerVal - 1;
        offsetOuter = -1 * outerVal;
		break;
	case scAddExpr:
		// 2D Case: Constant + MulExpr | Unknown
		// InnerLoop = if unknown = (PHINODE-initial-value - 1) else (MUlOperand(0) - PHINODE-initial-value)
		// OuterLoop = Constant - PHINODE-initial-value
        AddExpr = dyn_cast<SCEVAddExpr>(S);
        if(MulExpr = dyn_cast<SCEVMulExpr>(AddExpr->getOperand(1))){
            Const = dyn_cast<SCEVConstant>(MulExpr->getOperand(0));
            offsetInner = Const->getValue()->getSExtValue()-innerVal;
        }
        else if(isa<SCEVUnknown>(AddExpr->getOperand(1))) {
            offsetInner = innerVal - 1;
        }
        else {
            errs()<<"ERROR! Expected (Constant + MulExpr | Unknown) SCEV: "<<*S<<"\n";
        }

        Const = dyn_cast<SCEVConstant>(AddExpr->getOperand(0));
        offsetOuter = Const->getValue()->getSExtValue() - outerVal;

        //if(isa<SCEVUnknown>(dyn_cast<SCEVAddExpr>(S)->getOperand(1)))
        
        //else if (isa<SCEVMulExpr>((dyn_cast<SCEVAddExpr>(S))->getOperand(1)))
        //    offsetInner = dyn_cast<SCEVConstant>((dyn_cast<SCEVMulExpr>(S))->getOperand(1))->getValue()->getSExtValue() - innerVal;
		break;
	case scMulExpr:
		//2D Case
		// InnerLoop - offset = MUlOperand(0) - PHINODE-initial-value
		// OuterLoop = offset = -1 * PHINODE-initial-value
        MulExpr = dyn_cast<SCEVMulExpr>(S);
        Const = dyn_cast<SCEVConstant>(MulExpr->getOperand(0));
        offsetInner = Const->getValue()->getSExtValue() - innerVal;

        offsetOuter = -1 * outerVal;
		break;
	default:
		llvm_unreachable("Unknown SCEV kind!");
	}

    errs()<<"Offset Inner: "<<offsetInner<<"\n";
    errs()<<"Offset Outer: "<<offsetOuter<<"\n";
        
}

void Stencil::printSCEV(const SCEV *S, const SCEV *E){
    switch (S->getSCEVType()) {
    case scConstant:
      //return visitConstant((const SCEVConstant *)S);
      errs()<<"Constant: ";
      S->dump();
      break;
    case scTruncate:
      errs()<<"TruncateExpr: ";
      S->dump();
      printCastExpr((const SCEVTruncateExpr *)S,E);
      break;
    case scZeroExtend:
      errs()<<"ZeroExtendExpr: ";
      S->dump();
      printCastExpr((const SCEVZeroExtendExpr *)S, E);
      //return visitZeroExtendExpr((const SCEVZeroExtendExpr *)S);
      break;
    case scSignExtend:
      errs()<<"SignExtendExpr: ";
      S->dump();
      printCastExpr((const SCEVSignExtendExpr *)S, E);
      //return visitSignExtendExpr((const SCEVSignExtendExpr *)S);
      break;
    case scAddExpr:
	  errs()<<"AddExpr: ";
	  S->dump();
      printNAryExpr((const SCEVAddExpr *)S, E);
      break;
    case scMulExpr:
      errs()<<"MulExpr: ";
      S->dump();
      printNAryExpr((const SCEVMulExpr *)S, E);
      break;
    case scUDivExpr:
      //return visitUDivExpr((const SCEVUDivExpr *)S);
      errs()<<"ZeroUDivExpr: ";
      S->dump();
      break;
    case scAddRecExpr:
      errs()<<"AddRecExpr: ";
      S->dump();
      printAddRecExpr((const SCEVAddRecExpr *)S, E);
      break;
    case scSMaxExpr:
      errs()<<"SMaxExpr: ";
      S->dump();
      printNAryExpr((const SCEVSMaxExpr *)S, E);
      break;
    case scUMaxExpr:
      errs()<<"UMaxExpr: ";
      S->dump();
      printNAryExpr((const SCEVUMaxExpr *)S, E);
      break;
    case scUnknown:
	  errs()<<"Unknown: ";
	  S->dump();
      break;
      //return visitUnknown((const SCEVUnknown *)S);
    case scCouldNotCompute:
      errs()<<"CouldNotCompute: "<<"\n";
      S->dump();
      break;
      //return nullptr;
    default:
      llvm_unreachable("Unknown SCEV type!");
      break;
    }
}

template<typename T>
void Stencil::printNAryExpr(T *S, const SCEV *E){
    errs()<<"Num Operands: "<<S->getNumOperands()<<"\n";
    for (unsigned I = 0, J = S->getNumOperands(); I < J; ++I) {
        printSCEV(S->getOperand(I), E);
	}
}

template<typename T>
void Stencil::printCastExpr(T *S, const SCEV *E){
    printSCEV(S->getOperand(), E);
}

void Stencil::printAddRecExpr(const SCEVAddRecExpr *S, const SCEV *E){
    const SCEV *Start = S->getStart();
    const SCEV *Step = S->getStepRecurrence(*SE);
    const Loop *L = S->getLoop();
	const SCEV *Post = S->getPostIncExpr(*SE);
	const SCEV *Minus = SE->getMinusSCEV(Post,S);

    errs()<<"Start: "<<*Start<<"\n";
    errs()<<"Step: "<<*Step<<"\n";
    errs()<<"Post: "<<*Post<<"\n";
    errs()<<"Minus: "<<*Minus<<"\n";
    errs()<<"Loop: ";
    L->print(errs());
    errs()<<"Backedge: "<<*SE->getBackedgeTakenCount(L)<<"\n";

	/*
	SmallVector<const SCEV*,3> Subscripts;
	SmallVector<const SCEV*,3> Sizes;
	//const SCEV *ElementSize;
	
	SE->delinearize(S,Subscripts,Sizes,E);
	
	if (Subscripts.size() == 0 || Sizes.size() == 0 ||
          Subscripts.size() != Sizes.size()) {
        errs() << "Failed to delinearize\n";
	}
	*/

    for (unsigned I = 0, J = S->getNumOperands(); I < J; ++I) {
        //errs()<<"AddRecExpr Operand "<<I<<": "<<*S->getOperand(I)<<"\n";
		printSCEV(S->getOperand(I), E);
	}

}



// We need to overwrite this method so the most specialized visit methods are
// called before the visitors on SCEVExpander.
Value* Stencil::visit(const SCEV *S) {
    switch (S->getSCEVType()) {
    case scConstant:
      //return visitConstant((const SCEVConstant *)S);
      errs()<<"Constant: ";
      S->dump();
    case scTruncate:
      //return visitTruncateExpr((const SCEVTruncateExpr *)S);
      //errs()<<"TruncateExpr: "<<"\n";
      //S->dump();
    case scZeroExtend:
      //return visitZeroExtendExpr((const SCEVZeroExtendExpr *)S);
      //errs()<<"ZeroExtendExpr: "<<"\n";
      //S->dump();
    case scSignExtend:
      //return visitSignExtendExpr((const SCEVSignExtendExpr *)S);
      //errs()<<"SignExtendExpr"<<"\n";
      //S->dump();
    case scAddExpr:
	  //errs()<<"AddExpr: ";
	  //S->dump();
      return visitAddExpr((const SCEVAddExpr *)S);
    case scMulExpr:
      //return visitMulExpr((const SCEVMulExpr *)S);
      //errs()<<"MulExpr: ";
      //S->dump();
    case scUDivExpr:
      //return visitUDivExpr((const SCEVUDivExpr *)S);
      //errs()<<"ZeroUDivExpr: ";
      //S->dump();
    case scAddRecExpr:
      //errs()<<"AddRecExpr: ";
      //S->dump();
      //return visitAddRecExpr((const SCEVAddRecExpr *));
    case scSMaxExpr:
      //errs()<<"SMaxExpr: ";
      //S->dump();
      return visitSMaxExpr((const SCEVSMaxExpr *)S);
    case scUMaxExpr:
      //errs()<<"UMaxExpr: ";
      //S->dump();
      return visitUMaxExpr((const SCEVUMaxExpr *)S);
    case scUnknown:
	  //errs()<<"Unknown: ";
	  //S->dump();
      return visitUnknown((const SCEVUnknown *)S);
    case scCouldNotCompute:
      //errs()<<"CouldNotCompute: "<<"\n";
      //S->dump();
      //return nullptr;
    default:
      llvm_unreachable("Unknown SCEV type!");
    }
    //S->dump();
}

Value* Stencil::visitUnknown(const SCEVUnknown *S){
	//errs()<<"Unknown: "<<S->getValue()<<"\n";
	return S->getValue();
}

Value* Stencil::visitAddExpr(const SCEVAddExpr *S){
	//errs()<<"AddExpr:"<<"\n";
	//S->dump();
	//const SCEVAddExpr *S1;
	//errs()<<"Operands: "<<S->getNumOperands()<<"\n";
	for (unsigned I = 0, E = S->getNumOperands(); I < E; ++I) {
		//errs()<<"Operand "<<I<<": ";
		//S->getOperand(I)->dump();
		if(!(isa<SCEVConstant>(S->getOperand(I))))
			return visit(S->getOperand(I));
	}
}

Value* Stencil::visitUMaxExpr(const SCEVUMaxExpr *S){
	//errs()<<"Operands: "<<S->getNumOperands()<<"\n";
	for (unsigned I = 0, E = S->getNumOperands(); I < E; ++I) {
		//errs()<<"Operand "<<I<<": ";
		//S->getOperand(I)->dump();
		if(!(isa<SCEVConstant>(S->getOperand(I))))
			return visit(S->getOperand(I));
	}
}

Value* Stencil::visitSMaxExpr(const SCEVSMaxExpr *S){
	//errs()<<"Operands: "<<S->getNumOperands()<<"\n";
	for (unsigned I = 0, E = S->getNumOperands(); I < E; ++I) {
		//errs()<<"Operand "<<I<<": ";
		//S->getOperand(I)->dump();
		if(!(isa<SCEVConstant>(S->getOperand(I))))
			return visit(S->getOperand(I));
	}
}

void Stencil::showRange(Loop *loop){
	Region *r = RP->getRegionInfo().getRegionFor(loop->getLoopPreheader()); 
	Module *M = loop->getLoopPredecessor()->getParent()->getParent();
	const DataLayout DL = DataLayout(M);
	
	for (auto& ranges : ptrRA->RegionsRangeData[r].BasePtrsData) {
		errs()<<"Key: "<<*ranges.first<<"\n";
		errs()<<"Base Pointer: "<<*ranges.second.BasePtr<<"\n";
		std::vector<const SCEV*> access = ranges.second.AccessFunctions;
		std::vector<Instruction*> instructions = ranges.second.AccessInstructions;
		
		for(auto acc : access){
			errs()<<*acc<<"\n";
		}
		
		for(auto ins : instructions){
			errs()<<*ins<<"\n";
		}
	}
}

void Stencil::buildRange(Loop *loop){
	Region *r = RP->getRegionInfo().getRegionFor(loop->getLoopPreheader());        
	Module *M = loop->getLoopPredecessor()->getParent()->getParent();
	const DataLayout DL = DataLayout(M);
	if (!ptrRA->RegionsRangeData[r].HasFullSideEffectInfo){
		errs()<<"Region has unkown side effect"<<"\n";
	}
	else{
		//Instruction *insertPt = r->getEntry()->getFirstNonPHI();
		//errs()<<"Region Non Phi Ins:" <<*insertPt<<"\n";
		Instruction *insertPt = r->getEntry()->getTerminator();
		errs()<<"Region Terminator Ins:" <<*insertPt<<"\n";
		SCEVRangeBuilder rangeBuilder(SE, DL, AA, LI, DT, r, insertPt);
		std::map<Value *, std::pair<Value *, Value *> > pointerBounds;
		
		//ptrRA->RegionsRangeData[r] returns a RegionRangeInfo struct of region r
		//BasePtrsData is a map<Value*,PtrRangeInfo> 
		//
		for (auto& pair : ptrRA->RegionsRangeData[r].BasePtrsData) {
			std::vector<const SCEV*> access = pair.second.AccessFunctions;
			
			errs()<<"Base Pointer: "<<*pair.first<<"\n";
			for(auto i : access){
				i->dump();
			}
			
			Value *low = rangeBuilder.getULowerBound(pair.second.AccessFunctions);
			Value *up = rangeBuilder.getUUpperBound(pair.second.AccessFunctions);

			errs()<<"Low: "<<*low<<"\n";
			errs()<<"Up: "<<*up<<"\n";
			errs()<<"Pair first: "<<*pair.first<<"\n";
			
			// Adds "sizeof(element)" to the upper bound of a pointer, so it gives  
			// us the address of the first byte after the memory region.
			up = rangeBuilder.stretchPtrUpperBound(pair.first, up);
			pointerBounds.insert(std::make_pair(pair.first, std::make_pair(low, up)));
			errs()<<"Up Stretch: "<<*up<<"\n";
		}
	}
}

void Stencil::printLoopDetails(Loop *loop){
	errs()<<"\nLOOP\n";
    loop->print(errs());
     
    errs()<<"PreHeader: \n";
	loop->getLoopPreheader()->dump();
	
	errs()<<"Header: \n";
	loop->getHeader()->dump();
	
	errs()<<"Latch: \n";
	loop->getLoopLatch()->dump();
	
	
	/// getSmallConstantTripCount - Returns the maximum trip count of this loop as a
	/// normal unsigned value. Returns 0 if the trip count is unknown or not
	/// constant. Will also return 0 if the maximum trip count is very large (>=
	/// 2^32).
	///
	/// This "trip count" assumes that control exits via ExitingBlock. More
	/// precisely, it is the number of times that control may reach ExitingBlock
	/// before taking the branch. For loops with multiple exits, it may not be the
	/// number times that the loop header executes because the loop may exit
	/// prematurely via another branch.
	
	errs() << "Trip Count: " << SE->getSmallConstantTripCount(loop) << "\n";
	 
	errs() << "BackedgeTakenCount: "; 
            
    const SCEV* backedge = SE->getBackedgeTakenCount(loop);
    backedge->dump();
    errs()<<"Type: "<<backedge->getSCEVType()<<"\n"; 
    
    
	/// getMaxBackedgeTakenCount - Similar to getBackedgeTakenCount, except
	/// return the least SCEV value that is known never to be less than the
	/// actual backedge taken count.
             
	errs() << "MaxBackedgeTakenCount: ";
    SE->getMaxBackedgeTakenCount(loop)->dump();
    
	/// getExitCount - Get the expression for the number of loop iterations for which
	/// this loop is guaranteed not to exit via ExitingBlock. Otherwise return
	/// SCEVCouldNotCompute.
     
    errs() << "Exit count: ";
    SE->getExitCount(loop,loop->getUniqueExitBlock())->dump();
    
    Value *bound;
    if(!(backedge->getSCEVType() == scConstant)) {
		bound = visit(backedge);
	}
	else{
		const SCEVConstant* scev_const = dyn_cast<SCEVConstant>(backedge);
		bound = dyn_cast<Value>(scev_const->getValue());
	}
	errs()<<"Bound: "<<*bound<<"\n";
	
	
	
	/// Check to see if the loop has a canonical induction variable: an integer
	/// recurrence that starts at 0 and increments by one each time through the
	/// loop. If so, return the phi node that corresponds to it.
	///
	/// The IndVarSimplify pass transforms loops to have a canonical induction
	/// variable.
            
	
	auto *phiNode = loop->getCanonicalInductionVariable();       
    errs() << "Ind-var: ";
    if(phiNode) {
		phiNode->dump();
		//buildRange(loop);
	}
    else errs() << "Could not find canonical ind-var\n";
}

bool Stencil::verifyIterationLoop(Loop *loop, StencilInfo *Stencil){
	auto *phiNode = loop->getCanonicalInductionVariable();
	const SCEV* backedge;
	Value *bound;
	    
    if(phiNode) {
		backedge = SE->getBackedgeTakenCount(loop);
		if(!(backedge->getSCEVType() == scConstant)) {
			bound = visit(backedge);
		}
		else{
			const SCEVConstant* scev_const = dyn_cast<SCEVConstant>(backedge);
			bound = dyn_cast<Value>(scev_const->getValue());
		}
		
		 Stencil->iteration_phinode = phiNode;
		 Stencil->iteration_value = bound;
		 Stencil->iteration_loop = loop;

        Stencil->iteration = std::make_tuple(loop,phiNode, bound);
		 
        errs() << "Iteration loop PHINode: "<<*phiNode<<"\n";
		errs() << "Iteration loop Bound: "<<*Stencil->iteration_value<<"\n";
		return true;
	}
    else {
		errs() << "Could not find canonical ind-var\n";
		return false;
	}
	return false;
}

bool Stencil::verifyComputationLoops(Loop *loop, unsigned int dimension, StencilInfo *Stencil){
	const SCEV* backedge = SE->getBackedgeTakenCount(loop);
	Value *bound;
	
	if(!(backedge->getSCEVType() == scConstant)) {
		bound = visit(backedge);
	}
	else{
		const SCEVConstant* scev_const = dyn_cast<SCEVConstant>(backedge);
		bound = dyn_cast<Value>(scev_const->getValue());
	}
	
	Stencil->dimension++;
	Stencil->dimension_value.push_back(bound);
	PHINode* phi = getPHINode(loop);
	
	errs()<<"Computation Loop "<<Stencil->dimension<<" Phinode: "<<*phi<<"\n";
	errs()<<"Computation Loop "<<Stencil->dimension<<" Bound: "<<*bound<<"\n";
	 
	vector<Loop*> subLoops = loop->getSubLoops();
	
	if(subLoops.empty()) {
		//errs()<<"Subloop is empty\n";
		if(!verifyStore(loop, Stencil))
			return false;
	}
	else {
		Loop::iterator j, f;
		for (j = subLoops.begin(), f = subLoops.end(); j != f; ++j) {
			if(!verifyComputationLoops(*j, dimension + 1, Stencil))
				return false;
		}
	}
	return true;
}

bool Stencil::verifyStore(Loop *loop, StencilInfo *Stencil){
	Value *PtrOp;
	//Value *ValOp;
	//Instruction *Ins;
	GetElementPtrInst *GEP;
	LoadInst *LD;
	Neighbor2D store_neighbor;
	ArrayAccess arrayAcc;
	
	std::vector<Instruction*> StrIns;
	
	for(Loop::block_iterator bb = loop->block_begin();bb!=loop->block_end(); ++bb){
		for(BasicBlock::iterator I = (*bb)->begin(), E = (*bb)->end(); I != E; ++I){
			if(isa<StoreInst>(I))
				StrIns.push_back(I);
		}
	}
	
	if(StrIns.empty()) {
		errs()<<"ERROR! Inner computation loop has no store instruction\n";
		return false;
	}
	
	for(auto Ins : StrIns){
		errs()<<"Store: "<<*Ins<<"\n";	
        //errs() << "Store Instruction: "<< *Ins << "\n";
        
        // Get base pointer of store instruction operand
        PtrOp = getPointerOperand(Ins);

        const SCEV *ElementSize = SE->getElementSize(Ins);

        //errs()<<"Str PtrOp: "<<*PtrOp<<"\n";
        if(!parse_gep(PtrOp, ElementSize, &store_neighbor))
            //return false;
        
        while (isa<LoadInst>(PtrOp) || isa<GetElementPtrInst>(PtrOp)){
            if((LD = dyn_cast<LoadInst>(PtrOp)))
                PtrOp = LD->getPointerOperand();
            if((GEP = dyn_cast<GetElementPtrInst>(PtrOp)))
                PtrOp = GEP->getPointerOperand();
            //errs()<<"Passou "<<"\n";
        }
        
        //errs() << "Store Base pointer: "<<*PtrOp << "\n"; 
        Stencil->output = PtrOp;
        
        //errs() << "GEP: "<<*GEP<<"\n";
        
        StoreInst *Str = dyn_cast<StoreInst>(Ins);
        //Output Computation Value
        errs()<<"Store Value Operand: "<<*Str->getValueOperand()<<"\n";
        //Output GEP
        //errs()<<"Store Pointer Operand: "<<*Str->getPointerOperand()<<"\n";
       
        // Populate map with memory access of the store
        // Return false if no load is found
        if(!populateArrayAccess(Str->getValueOperand(), &arrayAcc)){
            errs()<<"ERROR! Store Instruction has no memory access!"<<"\n";
            return false;
        }

        errs()<<"ArrayAccess Size: "<<arrayAcc.size()<<"\n";
        for(auto i : arrayAcc){
            Neighbor2D neighbor;
            //errs()<<"Parsing: "<<*i.first<<"\n";
            if(parse_load(i.first, &neighbor)){
                //errs()<<"Neighbor scev: "<<*neighbor.scev_exp<<"\n";
                Stencil->neighbors.push_back(neighbor);

                // initially considers all pointers as arguments
                // the input pointer will be in the swap loop
                if(std::find(Stencil->arguments.begin(),Stencil->arguments.end(),neighbor.basePtr) == Stencil->arguments.end()){
                    //errs()<<"Inserted: "<<neighbor.basePtr<<"\n";
                    Value *Val = neighbor.basePtr;
                    Stencil->arguments.push_back(Val);
                }
            }
            else {
                errs()<<"Error parsing: "<<i.first<<"\n";
                return false;
            }
        }		
        
        //printNeighbors(Stencil);	
			
        /* Match access */
        if(!matchStencilNeighborhood(&store_neighbor, Stencil))
            return false;
        }

    errs()<<"Stencil Output: "<<*Stencil->output<<"\n";
	return true;
}

bool Stencil::matchStencilNeighborhood(Neighbor2D *str_neighbor, StencilInfo *Stencil){
	for(auto neighbor : Stencil->neighbors){
		//errs()<<"Position "<<*str_neighbor->scev_exp<<"\n";
		if( neighbor.phinode_x != str_neighbor->phinode_x ||
			neighbor.phinode_y != str_neighbor->phinode_y ||
			neighbor.stride_x != str_neighbor->stride_x ) {
				errs()<<"Does not match stencil computation\n";
                errs()<<"Neighbor\t\t\t\t\t\t\t\tOutput\n";
                errs()<<"BasePtr:   "<<*neighbor.basePtr<<"\t\t\t\t\t\t\t"<<*str_neighbor->basePtr<<"\n";
				errs()<<"Phinode X: "<<*neighbor.phinode_x<<"\t"<<*str_neighbor->phinode_x<<"\n";
				errs()<<"Phinode Y: "<<*neighbor.phinode_y<<"\t"<<*str_neighbor->phinode_y<<"\n";
				errs()<<"Stride X:  "<<*neighbor.stride_x<<"\t\t\t\t\t\t\t"<<*str_neighbor->stride_x<<"\n";
				return false;
		}
	}
	return true;
}

void Stencil::printNeighbors(StencilInfo *Stencil){
	errs()<<"# of Neighbors of base pointer "<<*Stencil->output;
    errs()<<" : "<<Stencil->neighbors.size()<<"\n";

    errs()<<"-----------------------------------------------------------------\n";
	for(auto i : Stencil->neighbors){
		i.dump();
	}
    errs()<<"-----------------------------------------------------------------\n";
}

bool Stencil::verifySwapLoops(Loop *loop, unsigned int dimension, StencilInfo *Stencil){
	const SCEV* backedge = SE->getBackedgeTakenCount(loop);
	Value* bound;
	PHINode* phi = getPHINode(loop);
	
	if(!(backedge->getSCEVType() == scConstant)) {
		bound = visit(backedge);
	}
	else{
		const SCEVConstant* scev_const = dyn_cast<SCEVConstant>(backedge);
		bound = dyn_cast<Value>(scev_const->getValue());
	}
	
	errs()<<"Swap Loop "<<dimension<<" Phinode: "<<*phi<<"\n";
	errs()<<"Swap Loop "<<dimension<<" Bound: "<<*bound<<"\n";
	
	//TODO Match bounds with computation loop bounds?
	
	vector<Loop*> subLoops = loop->getSubLoops();
	if(subLoops.empty()) {
		//errs()<<"Subloop is empty\n";
		if(!verifySwap(loop, Stencil))
			return false;
	}
	else{
		Loop::iterator j, f;
		for (j = subLoops.begin(), f = subLoops.end(); j != f; ++j) {
			verifySwapLoops(*j, dimension + 1, Stencil);
		}
	}
	return true;
}

bool Stencil::verifySwap(Loop *loop, StencilInfo *Stencil){
	ArrayAccess arr;
	Neighbor2D str_neighbor;
	Neighbor2D neighbor;
	Value* OutputVal; // Base Pointer of the value stored
	Value* InputVal;  // Base Pointer of the store
	LoadInst *LD;
	GetElementPtrInst *GEP;
	
	for(Loop::block_iterator bb = loop->block_begin();bb!=loop->block_end(); ++bb){
		for(BasicBlock::iterator I = (*bb)->begin(), E = (*bb)->end(); I != E; ++I){
			if(isa<StoreInst>(I)){
				Instruction *Ins = dyn_cast<Instruction>(&*I);
				//errs() << "Store Instruction: "<< *Ins << "\n";
				
				// Get base pointer of store instruction operand
				InputVal = getPointerOperand(Ins);
                const SCEV *ElementSize = SE->getElementSize(I);
				//errs()<<"PtrOp: "<<*InputVal<<"\n";
				parse_gep(InputVal, ElementSize, &str_neighbor);
				
				while (isa<LoadInst>(InputVal) || isa<GetElementPtrInst>(InputVal)){
					if((LD = dyn_cast<LoadInst>(InputVal)))
						InputVal = LD->getPointerOperand();
					if((GEP = dyn_cast<GetElementPtrInst>(InputVal)))
						InputVal = GEP->getPointerOperand();
					//errs()<<"Passou "<<"\n";
				}
				
				//errs() << "Swap Store Base pointer: "<<*InputVal << "\n"; 
				//errs() << "Swap GEP: "<<*GEP<<"\n";
				
				StoreInst *Str = dyn_cast<StoreInst>(Ins);
			
				//Output Computation Value
				//errs()<<"Swap Store Value Operand: "<<*Str->getValueOperand()<<"\n";
				
				//Output GEP
				//errs()<<"Swap Store Pointer Operand: "<<*Str->getPointerOperand()<<"\n";
			   
				//Populate map with memory access of the store
				populateArrayAccess(Str->getValueOperand(),&arr);   //Saved values
				//populateArrayAccess(Str->getPointerOperand());
				
				if(arr.size() > 1){
					errs()<<"ERROR! Expected only one load value on the Store\n";
					return false;
				}
				
				Neighbor2D neighbor;
				if(parse_load(arr.begin()->first, &neighbor)){
					//errs()<<"Load scev: "<<*neighbor.scev_exp<<"\n";
					OutputVal = neighbor.basePtr;
				}
				else {
					errs()<<"Error parsing: "<<arr.begin()->first<<"\n";
					return false;
				}			
				
				if( neighbor.phinode_x != str_neighbor.phinode_x ||
					neighbor.phinode_y != str_neighbor.phinode_y ||
					neighbor.stride_x != str_neighbor.stride_x ||
					neighbor.offset_x != str_neighbor.offset_x ||
					neighbor.offset_y != str_neighbor.offset_y) {
						errs()<<"ERROR! Swap loop does not match a pointer swap\n";
						errs()<<"Phinode X: "<<*neighbor.phinode_x<<"\t"<<*str_neighbor.phinode_x<<"\n";
						errs()<<"Phinode Y: "<<*neighbor.phinode_y<<"\t"<<*str_neighbor.phinode_y<<"\n";
						errs()<<"Stride X: "<<*neighbor.stride_x<<"\t"<<*str_neighbor.stride_x<<"\n";
						errs()<<"Phinode XOffset: "<<neighbor.offset_x<<"\t"<<str_neighbor.offset_x<<"\n";
						errs()<<"Phinode YOffset: "<<neighbor.offset_y<<"\t"<<str_neighbor.offset_y<<"\n";
						return false;
				}
				else {
					//Set the load value of the store as input
					//errs()<<"Arguments Size: "<<Stencil->arguments.size()<<"\n";
					
					//for(std::vector<Value*>::const_iterator it = Stencil->arguments.begin(); it != Stencil->arguments.end(); ++it) {
					for(unsigned int i = 0; i < Stencil->arguments.size(); ++i){
						//errs()<<"Swap: "<<&(*it)<<"\n";
						if(Stencil->arguments[i] == str_neighbor.basePtr){
							Stencil->input = str_neighbor.basePtr;
							Stencil->arguments.erase(Stencil->arguments.begin() + i);
							//errs()<<"Remove"<<"\n";
						}
					}
					if(!Stencil->input){
						errs()<<"ERROR! Pointer swap does not match computation loop pointer\n";
						return false;
					}
				}
				
				errs()<<"Stencil Input: "<<*Stencil->input<<"\n";
				errs()<<"Stencil Arguments: "<<Stencil->arguments.size()<<"\n";
				
				for (auto i : Stencil->arguments){
					errs()<<"\t"<<*i<<"\n";
				}
			}
		}
	}
	return true;
}

PHINode* Stencil::getPHINode(const Loop* loop){
	BasicBlock* bb = loop->getHeader();
	for(auto i = bb->begin(), e = bb->end(); i!=e;++i){
		if(isa<PHINode>(*i)){
			PHINode* phi = dyn_cast<PHINode>(&(*i));
			return phi;
		}
	} 
}

bool Stencil::runOnFunction(Function &F) {
	this->LI = &getAnalysis<LoopInfoWrapperPass>().getLoopInfo();
    this->DT = &getAnalysis<DominatorTreeWrapperPass>().getDomTree();
	this->SE = &getAnalysis<ScalarEvolution>();
	//this->SE = getAnalysis<ScalarEvolutionWrapperPass>(F).getSE();
    this->RP = &getAnalysis<RegionInfoPass>();
    this->AA = &getAnalysis<AliasAnalysis>();
    this->ptrRA = &getAnalysis<PtrRangeAnalysis>();

    //this->rn = &getAnalysis<RecoverNames>();
    //this->rr = &getAnalysis<RegionReconstructor>();
    //this->st = &getAnalysis<ScopeTree>();
	
	errs() << "\nFunction: " << F.getName() + "\n";
    errs() << "Arguments: ";
    for (auto& A : F.getArgumentList()) {
        errs() << A << "\t";
    }
    errs() << "\n";
    
    CurrentFn = &F;

    /*errs() << "Dumping loops:\n";
	for(auto bb = F.begin(); bb!=F.end(); bb++){
        if(LI->isLoopHeader(&(*bb))){
            Loop *loop = LI->getLoopFor(&(*bb));
            printLoopDetails(loop);
		}
	}
	*/
    
    if(verifyStencil()){
		errs()<<"Function "<< F.getName()<<" constains Stencil Computation\n";
	}
	return false;
}

bool Stencil::verifyStencil() {	 
     int loopCount = 0;
     for (LoopInfo::iterator i = LI->begin(), e = LI->end(); i != e; ++i) {
		 loopCount++;
	 }
	 errs()<<"Function  has "<<loopCount<<" outermost loops\n";
	 
	if(LI->empty()){
		 errs()<<"ERROR! Function has no loops\n";
		 return (false);
	}

    //if(loopCount > 1){
	//	 errs()<<"ERROR! Expected only 1 outermost loop\n";
		 //return (false);
    //}
	 //else{
         
    for (LoopInfo::iterator it = LI->begin(), e = LI->end(); it != e; ++it) {
        Loop *it_loop = *it;
        StencilInfo Stencil;
             
		//outermost loop
		//Loop *it_loop = LI->begin()[0];
		vector<Loop*> subLoops = it_loop->getSubLoops();
		
		if(it_loop->isAnnotatedParallel()){
			errs()<<"Outermost loop is Annotated Parallel\n";
		}
		
		if(subLoops.size() == 1) { //!verifyIterationLoop(it_loop)
			/* Considers it is a single iteration stencil */
			errs()<<"Considering a single iteration stencil\n";
			
			if(!verifyComputationLoops(it_loop,1, &Stencil)){
				errs()<<"ERROR! Computation loop does not match stencil\n";
				//return false;
                continue;
			}
			
			llvm::Type *i64_type = llvm::IntegerType::getInt64Ty(llvm::getGlobalContext());
			llvm::Constant *i64_val = llvm::ConstantInt::get(i64_type, 1, false);
			Stencil.iteration_value = dyn_cast<Value>(i64_val);
		}
		else {
			// iteration loop
			if(!verifyIterationLoop(it_loop, &Stencil)){
				//return false;
                continue;
			}
			// computation loops
			if(subLoops.size() != 2){
				errs()<<"ERROR! Expected 2 subloops for outermost loop\n";
                //return false;
                continue;
			}
			else{
				if(!verifyComputationLoops(subLoops[0],1, &Stencil)){
					errs()<<"Computation loop does not match stencil\n";
					//return false;
                    continue;
				}
				if(!verifySwapLoops(subLoops[1],1, &Stencil)) {
					errs()<<"Swap loop does not match stencil\n";
					//return false;
                    continue;
				}
			}
		}
        errs()<<"INSERTING!\n";
        StencilData.insert(std::pair<Function*, StencilInfo>(CurrentFn,Stencil));
	}
	
	return (!StencilData.empty());
}


bool Stencil::containsOpCode(Value *Val, unsigned opCode){
    if(!isa<Instruction>(Val)) {
        return false;
    }
    else {
        Instruction *Ins = dyn_cast<Instruction>(Val);
   	    int numOperands = Ins->getNumOperands();
        for(int i=0;i<numOperands;++i){
            if(isa<Instruction>(Ins->getOperand(i))){
                Instruction *op = dyn_cast<Instruction>(Ins->getOperand(i));
                if(op->getOpcode() == opCode){
                    return true;
                }            
            }
        }
    }
    return false;      
}


void Stencil::showArrayAccess(ArrayAccess arrayAcc){
	errs()<<"ArrayAccess"<<"\n";
	for(auto it : arrayAcc){
		errs()<<*it.first<<"\n";
		for(auto it2 : it.second){
			errs()<<"\t"<<*it2.first<<"\n";
		}
	}
}

void Stencil::showArrayExpression(ArrayExpression *exp, Value *Val){
    std::pair <ArrayExpression::iterator, ArrayExpression::iterator> ret;
    ret = exp->equal_range(Val); 
    
    for(ArrayExpression::iterator it = ret.first; it != ret.second; it++){
	    errs()<<"Value: "<<*it->second<<"\n";
        showArrayExpression(exp,it->second);
    }
}

bool Stencil::matchInstruction(Value *Val, unsigned opcode){
    if(isa<Instruction>(Val)){
       Instruction *Ins = dyn_cast<Instruction>(Val); 
       if(Ins->getOpcode() == opcode){
            return true;
        }
        else {
            return false;
        }
    }
    else {
        return false;
    }
}

bool Stencil::parse_load(Value *Val, Neighbor2D *neighbor) {
	//errs()<<"Parse load: "<<*Val<<"\n";
    const SCEV* ElementSize = SE->getElementSize(dyn_cast<Instruction>(Val));
    //errs()<<"Element Size: "<<*ElementSize<<"\n";
	if(isa<LoadInst>(Val)){
		if(!parse_gep((dyn_cast<LoadInst>(Val))->getPointerOperand(), ElementSize, neighbor)){
			errs()<<"ERROR parsing gep"<<"\n";
			return false;
		}
	}
	else {
		errs()<<"ERROR! Expected Load Instruction: "<<*Val<<"\n";
		return false;
	}
	return true;
}

bool Stencil::parse_gep(Value *Val, const SCEV *ElementSize, Neighbor2D *neighbor) {
	//errs()<<"Parse gep: "<<*Val<<"\n";
	if(GetElementPtrInst *GEP = dyn_cast<GetElementPtrInst>(Val)) {
		//errs()<<"GEP: "<<*GEP<<"\n";
		BasicBlock *bb = GEP->getParent();
		Loop *L = LI->getLoopFor(bb);
		//errs()<<"Val: "<<*Val<<"\n";
		const SCEV* scev_exp = SE->getSCEVAtScope(Val, L);
        errs()<<"SCEV: "<<*scev_exp<<"\n";
        /* TODO try to delinearize
        const SCEV *AccessFn = SE->getSCEVAtScope(Val, L);
        errs()<<"AccessFn: "<<*AccessFn<<"\n";

        const SCEVUnknown *BasePointer = dyn_cast<SCEVUnknown>(SE->getPointerBase(AccessFn));
        errs()<<"BasePtr: "<<*BasePointer<<"\n";

        AccessFn = SE->getMinusSCEV(AccessFn, BasePointer);
        errs()<<"AccessFn: "<<*AccessFn<<"\n";
        
        const SCEVAddRecExpr *AR = dyn_cast<SCEVAddRecExpr>(AccessFn);

        errs()<<"AR: "<<*AR<<"\n";
      
        SmallVector<const SCEV*, 3> Subscripts;
        SmallVector<const SCEV*, 3> Sizes;
        SE->delinearize(AR, Subscripts, Sizes, ElementSize);

       
        int Size = Subscripts.size();
         errs() << "Size: "<<Size<<"\n";
        for (int i = 0; i < Size - 1; i++)
            errs() << "[" << *Sizes[i] << "]";
        errs() << " with elements of " << *Sizes[Size - 1] << " bytes.\n";

        errs() << "ArrayRef";
        for (int i = 0; i < Size; i++)
            errs() << "[" << *Subscripts[i] << "]";
        errs() << "\n";
        */
        
		neighbor->scev_exp = scev_exp;
		neighbor->basePtr = GEP->getOperand(0);
		if(!parse_idxprom(GEP->getOperand(1), neighbor))
			return false;
	}
	else {
		errs()<<"ERROR! Expected GEP Instruction: "<<*Val<<"\n";
		return false;
	}
	return true;
}

bool Stencil::parse_idxprom(Value *Val, Neighbor2D *neighbor) {
	if(isa<SExtInst>(Val)){
		if(!parse_start(dyn_cast<Instruction>(Val)->getOperand(0), neighbor))
			return false;
	}
	else {
		errs()<<"ERROR! Expected SExt Instruction: "<<*Val<<"\n";
		return false;
	}
	return true;
}

bool Stencil::parse_start(Value *Val, Neighbor2D *neighbor) {
    if(matchInstruction(Val, Instruction::Add)){
        Instruction *Ins = dyn_cast<Instruction>(Val);
        if(matchInstruction(Ins->getOperand(0),Instruction::Mul)){
            if(!parse_yoffset_mul(Ins->getOperand(0), neighbor))
				return false;
            if(!parse_xoffset(Ins->getOperand(1), neighbor))
				return false;
        } 
        else if (matchInstruction(Ins->getOperand(1),Instruction::Mul)){
            if(!parse_yoffset_mul(Ins->getOperand(1), neighbor))
				return false;
            if(!parse_xoffset(Ins->getOperand(0), neighbor))
				return false;
        }
        else{
            errs()<<"ERROR! Expected Mul Operand: "<<*Ins<<"\n";
            return false;
        }
    }
    else{
        errs()<<"ERROR! Expected ADD Instruction: "<<*Val<<"\n";
        return false;
    }
    return true;
}


bool Stencil::parse_xoffset(Value *Val, Neighbor2D *neighbor) {
    if(matchInstruction(Val, Instruction::PHI)){
		neighbor->phinode_x = (PHINode*) Val;
		neighbor->offset_x = 0;
        //errs()<<"PHI Node: "<<*Val<<"\n";
        //errs()<<"X offset: 0"<<"\n";
    } 
    else if(matchInstruction(Val, Instruction::Add)){
        if(!parse_xoffset_add(Val, 1, neighbor))
			return false;
    }
    else if(matchInstruction(Val, Instruction::Sub)){
        if(!parse_xoffset_add(Val, -1, neighbor))
			return false;
    }else {
        errs()<<"ERROR! Expected PHI or ADD Instruction: "<<*Val<<"\n";
        return false;
    }
    return true;
}

bool Stencil::parse_xoffset_add(Value *Val, int sign, Neighbor2D *neighbor) {
    Instruction *Ins = dyn_cast<Instruction>(Val);
    PHINode *Phi;
    ConstantInt *Const;
    if(matchInstruction(Ins->getOperand(0),Instruction::PHI)) {
        Phi = dyn_cast<PHINode>(Ins->getOperand(0));
        neighbor->phinode_x = Phi;
        if(isa<ConstantInt>(Ins->getOperand(1))){
            Const = dyn_cast<ConstantInt>(Ins->getOperand(1));
            neighbor->offset_x = sign * Const->getSExtValue();
        }   
        else {
            errs()<<"ERROR! Expected Constant: "<<*Ins->getOperand(1)<<"\n"; 
            return false;
        }
    }
    else if(matchInstruction(Ins->getOperand(1),Instruction::PHI)) {
        Phi = dyn_cast<PHINode>(Ins->getOperand(0));
        neighbor->phinode_x = Phi;
        if(isa<ConstantInt>(Ins->getOperand(1))){
            Const = dyn_cast<ConstantInt>(Ins->getOperand(1));
            neighbor->offset_x = sign * Const->getSExtValue();
        }
        else{
           errs()<<"ERROR! Expected Constant: "<<*Ins->getOperand(1)<<"\n"; 
           return false;
        } 
    }
    else{
        errs()<<"ERROR! Expected PHI Instruction: "<<*Ins<<"\n";
        return false;
    }
    //errs()<<"PHI Node: "<<*Phi<<"\n";
    //errs()<<"X offset: "<<sign * Const->getSExtValue()<<"\n";
    return true;
}

bool Stencil::parse_yoffset_mul(Value *Val, Neighbor2D *neighbor) {
    Instruction *Ins = dyn_cast<Instruction>(Val);
	if(matchInstruction(Ins->getOperand(0),Instruction::PHI) || 
	   matchInstruction(Ins->getOperand(0),Instruction::Add) || 
	   matchInstruction(Ins->getOperand(0),Instruction::Sub) ){
		if(!parse_yoffset(Ins->getOperand(0),neighbor))
			return false;
		if(!parse_yoffset_stride(Ins->getOperand(1), neighbor))
			return false;
	} 
	else if (matchInstruction(Ins->getOperand(1),Instruction::PHI) || 
			 matchInstruction(Ins->getOperand(1),Instruction::Add) || 
			 matchInstruction(Ins->getOperand(1),Instruction::Sub) ){
		if(!parse_yoffset(Ins->getOperand(1), neighbor))
			return false;
		if(!parse_yoffset_stride(Ins->getOperand(0), neighbor))
			return false;
	}
	else{
		errs()<<"ERROR! Expected PHINode, Add, or Sub Operand: "<<*Ins<<"\n";
		return false;
	}
	return true;
}

bool Stencil::parse_yoffset_stride(Value *Val, Neighbor2D *neighbor) {
    if(isa<Constant>(Val)){
        //errs()<<"CONSTANT: "<<*Val<<"\n";
        neighbor->stride_x = Val;
    }
    else if(isa<Argument>(Val)){
        //errs()<<"ARGUMENT: "<<*Val<<"\n";
        neighbor->stride_x = Val;
    }
    else if(isa<LoadInst>(Val)){
        LoadInst *Load = dyn_cast<LoadInst>(Val);
        Value *LoadVal = Load->getPointerOperand();
        //errs()<<"LOAD: "<<*LoadVal<<"\n";
        neighbor->stride_x = LoadVal;
    }
    else {
        errs()<<"ERROR! Expected Constant, Argument or LoadInst: "<<*Val<<"\n";
        return false;
    }
    return true;
}

bool Stencil::parse_yoffset(Value *Val, Neighbor2D *neighbor) {
    if(matchInstruction(Val, Instruction::PHI)){
		neighbor->phinode_y = (PHINode*) Val;
		neighbor->offset_y = 0;
        //errs()<<"PHI Node: "<<*Val<<"\n";
        //errs()<<"Y offset: 0"<<"\n";
    } 
    else if(matchInstruction(Val, Instruction::Add)){
        if(!parse_yoffset_add(Val, 1, neighbor))
			return false;
    }
    else if(matchInstruction(Val, Instruction::Sub)){
        if(!parse_yoffset_add(Val, -1, neighbor))
			return false;
    }
    else {
        errs()<<"ERROR! Expected PHI, Add or Sub Instruction: "<<*Val<<"\n";
        return false;
    }
    return true;
}

bool Stencil::parse_yoffset_add(Value *Val, int sign, Neighbor2D *neighbor) {
    Instruction *Ins = dyn_cast<Instruction>(Val);
    PHINode *Phi;
    ConstantInt *Const;
    if(matchInstruction(Ins->getOperand(0),Instruction::PHI)) {
        Phi = dyn_cast<PHINode>(Ins->getOperand(0));
        neighbor->phinode_y = Phi;
        if(isa<ConstantInt>(Ins->getOperand(1))){
            Const = dyn_cast<ConstantInt>(Ins->getOperand(1));
            neighbor->offset_y = sign * Const->getSExtValue();
        }   
        else {
            errs()<<"ERROR! Expected Constant: "<<*Ins->getOperand(1)<<"\n"; 
            return false;
        }
    }
    else if(matchInstruction(Ins->getOperand(1),Instruction::PHI)) {
        Phi = dyn_cast<PHINode>(Ins->getOperand(1));
        neighbor->phinode_y = Phi;
        if(isa<ConstantInt>(Ins->getOperand(0))){
            Const = dyn_cast<ConstantInt>(Ins->getOperand(0));
            neighbor->offset_y = sign * Const->getSExtValue();
        }
        else{
           errs()<<"ERROR! Expected Constant: "<<*Ins->getOperand(0)<<"\n"; 
           return false;
        } 
    }
    else{
        errs()<<"ERROR! Expected PHI Instruction: "<<*Ins<<"\n";
        return false;
    }
    //errs()<<"PHI Node: "<<*Phi<<"\n";
    //errs()<<"Y offset: "<<sign * Const->getSExtValue()<<"\n";
    return true;
}

/*
void Stencil::traverseArrayExpression(ArrayExpression *exp, Value *Val){
    Instruction *Ins;
    errs()<<"Key: "<<*Val<<"\n";
    //errs()<<"Count: "<<exp->count(Val)<<"\n";
    
    // Get range of mapped values
    std::pair <ArrayExpression::iterator, ArrayExpression::iterator> ret;
    ret = exp->equal_range(Val); 
    
    for(ArrayExpression::iterator it = ret.first; it != ret.second; it++){
		errs()<<"Value: "<<*it->second<<"\n";
		if(Ins = dyn_cast<Instruction>(it->second)){
            errs()<<"Instruction: "<<*Ins<<"\n";
			int numOperands = Ins->getNumOperands();
            unsigned opCode = Ins->getOpcode();
            if(opCode == Instruction::Add){
                // We assume the access as (phinode_y [+/- offset_y])*width + phinode_x [+/- offset_x]
                Instruction *Mul;       //corresponds to (phinode_y +/- offset)*width
                Instruction *Offset;    //corresponds to phinode_x +/- offset_x
                Instruction *MulOperand; 
                Value *Width;           //corresponds to width
                Constant *Const;
                Argument *Arg;
                LoadInst *Load;
                // If 1st operand is Mul
                if(dyn_cast<Instruction>(Ins->getOperand(0))->getOpcode() == Instruction::Mul){
                    Mul = dyn_cast<Instruction>(Ins->getOperand(0));
                }
                else if (dyn_cast<Instruction>(Ins->getOperand(1))->getOpcode() == Instruction::Mul){ 
                    Mul = dyn_cast<Instruction>(Ins->getOperand(1));
                }
                else {
                    errs()<<"ERROR! Expected Mul Operand in "<<*Ins<<"\n";
                }
                errs()<<"Mul: "<<*Mul<<"\n";
                // get phinode_y from Mul (no offset)
                if(containsOpCode(Mul,Instruction::PHI)){
                    errs()<<"Mul: "<<*Mul<<" uses PHI with no offset\n";
                    if(isa<PHINode>(Mul->getOperand(0))){
                        errs()<<"Mul Operand 0 is PHI"<<"\n";
                        if(isa<Constant>(Mul->getOperand(1))){
                            errs()<<"Mul Operand 1 is CONSTANT\n";
                        }
                        else if(isa<Argument>(Mul->getOperand(1))){
                            errs()<<"Mul Operand 1 is ARGUMENT\n";
                        }
                        else if(isa<LoadInst>(Mul->getOperand(1))){
                            LoadInst *Load = dyn_cast<LoadInst>(Mul->getOperand(1));
                            Value *LoadVal = Load->getPointerOperand();
                            errs()<<"Mul Operand 0 is LOAD "<<*LoadVal<<"\n";
                        }
                           else {
                            errs()<<"ERROR! Expected Constant or Argument for Operand 1\n";
                        }
                    }
                    else {
                        errs()<<"Mul Operand 1 is PHI"<<"\n";
                         if(isa<Constant>(Mul->getOperand(0))){
                            errs()<<"Mul Operand 0 is CONSTANT\n";
                        }
                        else if(isa<Argument>(Mul->getOperand(0))){
                            errs()<<"Mul Operand 0 is ARGUMENT\n";
                        }
                        else if(isa<LoadInst>(Mul->getOperand(0))){
                            LoadInst *Load = dyn_cast<LoadInst>(Mul->getOperand(0));
                            Value *LoadVal = Load->getPointerOperand();
                            errs()<<"Mul Operand 0 is LOAD "<<*LoadVal<<"\n";
                        }
                        else {
                            errs()<<"ERROR! Expected Constant or Argument for Operand 0\n";
                        }
                    }
                }
                // get phinode_y from Mul with offset
                else {   
                    if(containsOpCode(Mul->getOperand(0),Instruction::PHI)){
                        MulOperand = dyn_cast<Instruction>(Mul->getOperand(0));
                        errs()<<"Mul Operand 0 contains PHI: "<<*MulOperand<<"\n";
                        if(isa<Constant>(Mul->getOperand(1)) || isa<Argument>(Mul->getOperand(1)) || isa<LoadInst>(Mul->getOperand(1))){
                            Width = Mul->getOperand(1);
                            errs()<<"Mul Operand 1 is WIDTH: "<<*Width<<"\n";
                        }
                        else {
                            errs()<<"ERROR! Expected Constant, Argument or LoadInst for Operand 1: "<<*Mul->getOperand(1)<<"\n";
                        }
                    }    
                    else if(containsOpCode(Mul->getOperand(1),Instruction::PHI)){
                        MulOperand = dyn_cast<Instruction>(Mul->getOperand(1));
                        errs()<<"Mul Operand 1 contains PHI: "<<*MulOperand<<"\n";
                        if(isa<Constant>(Mul->getOperand(0)) || isa<Argument>(Mul->getOperand(0)) || isa<LoadInst>(Mul->getOperand(0))) {
                            Width = Mul->getOperand(1);
                            errs()<<"Mul Operand 1 is WIDTH: "<<*Width<<"\n";
                        }
                        else {
                            errs()<<"ERROR! Expected Constant, Argument or LoadInst for Operand 1: "<<*Mul->getOperand(1)<<"\n";
                        }
                    }
                                              
                }        
                        if(isa<Constant>(Mul->getOperand(1)))
                            Const = dyn_cast<Constant>(Mul->getOperand(1));
                        else if (isa<Argument>(Mul->getOperand(1)))
                            Arg = dyn_cast<Argument>(Mul->getOperand(1));
                        else if (isa<LoadInst>(Mul->getOperand(1)))
                            Load = dyn_cast<LoadInst>(Mul->getOperand(1));
                        else 
                            errs()<<"ERROR! Expected Constant or Argument in "<<*Mul->getOperand(1);
                    }
                    else if(isa<Instruction>(Mul->getOperand(1))){
                        MulOperand = dyn_cast<Instruction>(Mul->getOperand(1));
                        if(isa<Constant>(Mul->getOperand(0)))
                            Const = dyn_cast<Constant>(Mul->getOperand(0));
                        else if (isa<Argument>(Mul->getOperand(0)))
                            Arg = dyn_cast<Argument>(Mul->getOperand(0));
                         else if (isa<LoadInst>(Mul->getOperand(0)))
                            Load = dyn_cast<LoadInst>(Mul->getOperand(0));
                        else 
                            errs()<<"ERROR! Expected Constant or Argument in "<<*Mul->getOperand(0);
                    }                    
                    else
                        errs()<<"ERROR! Expected Instruction in "<<*MulOperand<<"\n";
                         
                    if(containsOpCode(MulOperand,Instruction::PHI)){
                            errs()<<"Mul Operand: "<<*MulOperand<<" uses PHI with offset\n";
                    }
                    else{
                        errs()<<"ERROR! Expected a Instruction with PHI offset\n";
                    }    

                }                   
                //else{
                //    errs()<<"ERROR! Expected Mul Operand in "<<*Ins<<"\n";
                //}
                */
                /* get width offset from Mul */
             /*
            }
            else if(opCode == Instruction::Mul){ 
                errs()<<"opCode: "<<opCode<<" is Mul\n";
            }
            else if(opCode == Instruction::Sub){  
                errs()<<"opCode: "<<opCode<<" is Sub\n";
            }
            else if(opCode == Instruction::Load){  
                 errs()<<"opCode: "<<opCode<<" is Load\n";
            }
            else if(opCode == Instruction::PHI){  
                 errs()<<"opCode: "<<opCode<<" is PHI\n";
            }
            else {
                errs()<<"UNEXPECTED OPCODE "<<Ins->getOpcodeName()<<" in "<<*Ins<<"\n";
            }  
            */         
            /* 
			for(int i=0;i<numOperands;++i){
				if(isa<PHINode>(Ins->getOperand(i))){
					errs()<<"Operand "<<i<<" of "<<*it->second<<" is a PHINode\n";
					for(int j=0;j<numOperands;++j){
						if(isa<ConstantInt>(Ins->getOperand(j))){
							int offset = dyn_cast<ConstantInt>(Ins->getOperand(j))->getSExtValue(); 
                            unsigned opCode = Ins->getOpcode();
                            const char * opCodeName = Ins->getOpcodeName();
                            errs()<<"Operand "<<j<<" of "<<*it->second<<" is a ConstantInt with offset of "<<offset<<" and opCodeName "<<opCodeName<<"\n";
						}
					}
				}
			}
            
		}
		else if(Constant *Cons = dyn_cast<Constant>(it->second)){
			errs()<<*it->second<<" is constant\n";
		}
		else if(Argument *Arg = dyn_cast<Argument>(it->second)){
			errs()<<*it->second<<" is argument\n";
		}
        else {
            errs()<<*it->second<<" is something else. Traversing again.<<\n";
            //if(exp->count(it->second)>0){ 
    		//    traverseArrayExpression(exp,it->second);
            // }
        }
    }//end for     

}
*/	
	//for(ArrayExpression::iterator it = ret.first; it != ret.second; it++){
        /* traverse if the mapped value exist as a key */
        //if(exp->count(it->second)>0){ 
    	//	traverseArrayExpression(exp,it->second);
        //}
	//}
    
    /*
    if(exp->find(Val) != exp->end()){
        Instruction *Ins = dyn_cast<Instruction>(exp->find(Val)->second);
        errs()<<"Checked: "<<*Ins<<"\n";
        errs()<<"OpCode Name: "<<Ins->getOpcodeName()<<"\n";
        if(isa<PHINode>(Ins->getOperand(0)) || isa<PHINode>(Ins->getOperand(1))){
            errs()<<"Phi: "<<*Ins<<"\n";     
        }
        else if (isa<Constant>(Ins->getOperand(0)) || isa<Constant>(Ins->getOperand(1))){
           errs()<<"Constant: "<<*Ins<<"\n"; 
        }
        else{
            traverseArrayExpression(exp,Ins->getOperand(0));
            traverseArrayExpression(exp,Ins->getOperand(1));
        
        }
    }
    else{
       errs()<<"Not found: "<<*Val<<"\n";
    }
    */
//}

char Stencil::ID = 0;
static RegisterPass<Stencil> Z("stencil", "Detect stencil computation");

//===----------------------- Stencil.cpp ------------------------===//
