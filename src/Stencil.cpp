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
       if (!(isa<PHINode>(*Ins))) {
            numOperands = Ins->getNumOperands();
            //errs()<<"Val :"<<*Val<<" has "<<numOperands<<" operands"<<"\n";
            for (int i=0; i<numOperands;i++) {
                arr->insert(std::pair<Value*,Value*>(Val,Ins->getOperand(i))); 
                //errs()<<"Inserted "<<*Ins->getOperand(i)<<"\n";
                populateArrayExpression(arr,Ins->getOperand(i));
            }
        }
    }
}

void Stencil::populateArrayAccess (Value *Val){
    Instruction *Ins;
    int numOperands = 0;
    if ((Ins = dyn_cast<Instruction>(Val))){
        numOperands = Ins->getNumOperands();
        //errs()<<"Val :"<<*Val<<" has "<<numOperands<<" operands"<<"\n";
        if(isa<GetElementPtrInst>(*Ins)){
            ArrayExpression arr;
            for(int i=0; i<numOperands;i++){
                populateArrayExpression(&arr, Ins->getOperand(i));
            }
            this->arrayAcc.insert( std::pair<Value*,ArrayExpression>(Ins,arr));
            //errs()<<"GEP inserted with Array Expression"<<*Ins<<"\n"; 
        }
        else{ 
            for(int i=0; i<numOperands;i++){
                if(!(isa<PHINode>(*Ins))){ 
                    populateArrayAccess(Ins->getOperand(i));
                }
            }
        }
    }
    else {
        //errs()<<"Val is not a Instruction: "<<*Val<<"\n";
    }
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

// We need to overwrite this method so the most specialized visit methods are
// called before the visitors on SCEVExpander.
Value* Stencil::visit(const SCEV *S) {
    switch (S->getSCEVType()) {
    case scConstant:
      //return visitConstant((const SCEVConstant *)S);
      //errs()<<"Constant: ";
      //S->dump();
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
      //return visitAddRecExpr((const SCEVAddRecExpr *));
      //errs()<<"AddRecExpr: ";
      //S->dump();
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

void Stencil::getLoopDetails(Loop *loop){
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
    
    Value* bound = visit(backedge);
	errs()<<"Bound: "<<*bound<<"\n";
	
	/// Check to see if the loop has a canonical induction variable: an integer
	/// recurrence that starts at 0 and increments by one each time through the
	/// loop. If so, return the phi node that corresponds to it.
	///
	/// The IndVarSimplify pass transforms loops to have a canonical induction
	/// variable.
            
	
	auto *phiNode = loop->getCanonicalInductionVariable();       
    errs() << "Ind-var: ";
    phiNode->dump();
    if(phiNode) {
		//phiNode->dump();
		//buildRange(loop);
	}
    else errs() << "Could not find canonical ind-var\n";
}

bool Stencil::verifyIterationLoop(Loop *loop){
	auto *phiNode = loop->getCanonicalInductionVariable();       
    if(phiNode) {
		 StencilInfo.iteration_phinode = phiNode;
		 StencilInfo.iteration_value = visit(SE->getBackedgeTakenCount(loop));
		 StencilInfo.iteration_loop = loop;
		 
		 errs() << "Iteration loop PHINode: "<<*phiNode<<"\n";
		 errs() << "Iteration loop Bound: "<<*StencilInfo.iteration_value<<"\n";
		 return true;
	}
    else {
		errs() << "Could not find canonical ind-var\n";
		return false;
	}
	return false;
}

bool Stencil::verifyComputationLoops(Loop *loop, unsigned int dimension){
	const SCEV* backedge = SE->getBackedgeTakenCount(loop);
	Value* dimension_value = visit(backedge);
	StencilInfo.dimension++;
	StencilInfo.dimension_value.push_back(dimension_value);
	PHINode* phi = getPHINode(loop);
	
	errs()<<"Computation Loop "<<StencilInfo.dimension<<" Phinode: "<<*phi<<"\n";
	errs()<<"Computation Loop "<<StencilInfo.dimension<<" Bound: "<<*dimension_value<<"\n";
	
	vector<Loop*> subLoops = loop->getSubLoops();
	
	if(subLoops.empty()) {
		errs()<<"Subloop is empty\n";
		verifyStore(loop);
	}
	else {
		Loop::iterator j, f;
		for (j = subLoops.begin(), f = subLoops.end(); j != f; ++j) {
			verifyComputationLoops(*j, dimension + 1);
		}
	}
	return true;
}

void Stencil::verifyStore(Loop *loop){
   Value *PtrOp;
   //Value *ValOp;
   Instruction *Ins;
   GetElementPtrInst *GEP;
   LoadInst *LD;
	
   for(Loop::block_iterator bb = loop->block_begin();bb!=loop->block_end(); ++bb){
	   for(BasicBlock::iterator I = (*bb)->begin(), E = (*bb)->end(); I != E; ++I){
			if(isa<StoreInst>(*I)){
				Ins = dyn_cast<Instruction>(&*I);
				errs() << "Store Instruction: "<< *Ins << "\n";
				
				// Get base pointer of store instruction operand
				PtrOp = getPointerOperand(Ins);
				while (isa<LoadInst>(PtrOp) || isa<GetElementPtrInst>(PtrOp)){
					if((LD = dyn_cast<LoadInst>(PtrOp)))
						PtrOp = LD->getPointerOperand();
					if((GEP = dyn_cast<GetElementPtrInst>(PtrOp)))
						PtrOp = GEP->getPointerOperand();
					//errs()<<"Passou "<<"\n";
				}
				errs() << "Store Base pointer: "<<*PtrOp << "\n"; //O que fazer com esse PtrOp?
				errs() << "GEP: "<<*GEP<<"\n";
				// Navigate through store instruction val
				StoreInst *Str = dyn_cast<StoreInst>(Ins);
				//ValOp = Str->getValueOperand();
				//errs() << "Store Val: "<< *ValOp << "\n";
				//errs() << "Num Operands: "<< dyn_cast<Instruction>(*ValOp)->getNumOperands()<<"\n";
				//Ins = dyn_cast<Instruction>(ValOp);
				//errs() << "Store Ins: "<< *Ins << "\n";
			   
				//Populate map with memory access of the store
				populateArrayAccess(Str->getValueOperand());   //Saved values
				populateArrayAccess(Str->getPointerOperand()); 
			   

	 
				//errs() << "Store Ins Operand: "<< *Ins->getOperand(1)<<"\n";
				//for(use_iterator op = ValOp->use_begin(), e = ValOp->use_end(); op != e; ++op){
				//    errs() <<"Use it: "<<*op<<"\n";
				//}
				
				//
				//int op1;
				//std::string str1,str2;
				//str1 = RC.getAccessString(PtrOp,"", &op1, &DT);

				//errs() << "name: "<<str1<<" int: "<<op1<< "\n";
				 
				//str2 = RC.getAccessString(GEP->getOperand(1),str1, &op1, &DT);
				//errs() << "name: "<<str2<<" int: "<<op1<< "\n";
				

				//while(!(isa<PHINode>(*Ins))){
					////errs() <<"ins: "<<*ValOp<<"\n";
					////ValOp = ValOp->getOperand(0);
					//Ins = dyn_cast<Instruction>(ValOp);
					//errs()<<"Ins: "<<*Ins<<"\n";
					//ValOp = Ins->getOperand(0);
				//}
			   
					
			}
		}

		 //Traverse map
		 for(ArrayAccess::iterator it = this->arrayAcc.begin();it!=this->arrayAcc.end();++it){
			GetElementPtrInst *GEP = dyn_cast<GetElementPtrInst>(it->first);
			//errs()<<"\nGEP node: "<<*it->first<<"\n";
			Value *root = dyn_cast<Value>(GEP->getOperand(1));
			//errs()<<"Root Expression: "<<*root<<"\n";
			ArrayExpression exp = it->second;
			auto it2 = exp.find(root);
			if(it2 != exp.end()){
				//traverseArrayExpression(&exp,root);
				//showArrayExpression(&exp,root);
				//TODO include idxprom to parsing
				//parse_start(it2->second);
			}

			//errs()<<"Key "<<*(exp.begin()->first)<<" has "<<exp.count(root)<<"\n";

			
			
			//for(ArrayExpression::iterator it2 = exp.begin(); it2 != exp.end();++it2){
				
				//errs()<<"Key: "<<*it2->first<<"\t\t"<<"Map: "<<*it2->second<<"\n";
				////if(it2->first->getName().equals(root->getName())){
				////    errs()<<"equals "<<i<<"\n";
				////    traverseArrayExpression(&exp,it2->first);
					////errs()<<"Find: "<<*(exp.find(it2->second)->first)<<"\n";
				////} 
				////i++;
			 //}
			
		}
		
	}
	
}

bool Stencil::verifySwapLoops(Loop *loop, unsigned int dimension){
	StencilInfo.dimension_value.push_back(visit(SE->getBackedgeTakenCount(loop)));
	
	vector<Loop*> subLoops = loop->getSubLoops();
    Loop::iterator j, f;
    for (j = subLoops.begin(), f = subLoops.end(); j != f; ++j) {
        verifySwapLoops(*j, dimension + 1);
    }
	return true;
}

PHINode* Stencil::getPHINode(Loop* loop){
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
	
    this->RP = &getAnalysis<RegionInfoPass>();
    this->AA = &getAnalysis<AliasAnalysis>();
    this->ptrRA = &getAnalysis<PtrRangeAnalysis>();

    //this->rn = &getAnalysis<RecoverNames>();
    //this->rr = &getAnalysis<RegionReconstructor>();
    //this->st = &getAnalysis<ScopeTree>();
	
    
	//ScalarEvolution &SE = getAnalysis<ScalarEvolutionWrapperPass>(F).getSE();
	//int loopCounter = 0;
	
    errs() << "\nFunction: " << F.getName() + "\n";
    errs() << "Arguments: ";
    for (auto& A : F.getArgumentList()) {
        errs() << A << "\t";
    }
    errs() << "\n";
    
    /*
    errs() << "Dumping loops:\n";
	for(auto bb = F.begin(); bb!=F.end(); bb++){
        if(LI->isLoopHeader(&(*bb))){
            Loop *loop = LI->getLoopFor(&(*bb));
            errs()<<"\nLOOP:\n";
            loop->print(errs());
            getLoopDetails(loop);
		}
	}
	*/
	
     int loopCount = 0;
     for (LoopInfo::iterator i = LI->begin(), e = LI->end(); i != e; ++i) {
		 loopCount++;
	 }
	 errs()<<"Function "<< F.getName()<<" has "<<loopCount<<" outermost loops\n";
	 if(loopCount > 1){
		 errs()<<"ERROR! Expected only 1 outermost loop\n";
		 return (false);
	 }
	 else{
		//outermost loop
		Loop *it_loop = LI->begin()[0];
		if(it_loop->isAnnotatedParallel()){
			errs()<<"Outermost loop is Annotated Parallel\n";
		}
		if(!verifyIterationLoop(it_loop))
			return false;
		
		//computation loops
		vector<Loop*> subLoops = it_loop->getSubLoops();
		
		if(subLoops.size() != 2){
			errs()<<"ERROR! Expected 2 subloops for outermost loop\n";
			return false;
		}
		else{
			if(!verifyComputationLoops(subLoops[0],1))
				return false;
			
			if(!verifySwapLoops(subLoops[1],1))
				return false;
		}
		
			
	}
    return(true);
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

void Stencil::showArrayExpression(ArrayExpression *exp, Value *Val){
    std::pair <ArrayExpression::iterator, ArrayExpression::iterator> ret;
    ret = exp->equal_range(Val); 
    
    for(ArrayExpression::iterator it = ret.first; it != ret.second; it++){
	    errs()<<"Value: "<<*it->second<<"\n";
        showArrayExpression(exp,it->second);
    }
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

void Stencil::parse_start(Value *Val) {
    if(matchInstruction(Val, Instruction::Add)){
        Instruction *Ins = dyn_cast<Instruction>(Val);
        if(matchInstruction(Ins->getOperand(0),Instruction::Mul)){
            parse_yoffset_mul(Ins->getOperand(0));
            parse_xoffset(Ins->getOperand(1));
        } 
        else if (matchInstruction(Ins->getOperand(1),Instruction::Mul)){
            parse_yoffset_mul(Ins->getOperand(1));
            parse_xoffset(Ins->getOperand(0)); 
        }
        else{
            errs()<<"ERROR! Expected Mul Operand: "<<*Ins<<"\n";
        }
    }
    else{
        errs()<<"ERROR! Expected ADD Instruction: "<<*Val<<"\n";
    }
}


void Stencil::parse_xoffset(Value *Val) {
    if(matchInstruction(Val, Instruction::PHI)){
        errs()<<"PHI Node: "<<*Val<<"\n";
        errs()<<"X offset: 0"<<"\n";
    } 
    else if(matchInstruction(Val, Instruction::Add)){
        parse_xoffset_add(Val, 1);
    }
    else if(matchInstruction(Val, Instruction::Sub)){
        parse_xoffset_add(Val, -1);
    }else {
        errs()<<"ERROR! Expected PHI or ADD Instruction: "<<*Val<<"\n";
    }
}

void Stencil::parse_xoffset_add(Value *Val, int sign) {
    Instruction *Ins = dyn_cast<Instruction>(Val);
    PHINode *Phi;
    ConstantInt *Const;
    if(matchInstruction(Ins->getOperand(0),Instruction::PHI)) {
        Phi = dyn_cast<PHINode>(Ins->getOperand(0));
        if(isa<ConstantInt>(Ins->getOperand(1))){
            Const = dyn_cast<ConstantInt>(Ins->getOperand(1));
        }   
        else {
            errs()<<"ERROR! Expected Constant: "<<*Ins->getOperand(1)<<"\n"; 
        }
    }
    else if(matchInstruction(Ins->getOperand(1),Instruction::PHI)) {
        Phi = dyn_cast<PHINode>(Ins->getOperand(0));
        if(isa<ConstantInt>(Ins->getOperand(1))){
            Const = dyn_cast<ConstantInt>(Ins->getOperand(1));
        }
        else{
           errs()<<"ERROR! Expected Constant: "<<*Ins->getOperand(1)<<"\n"; 
        } 
    }
    else{
        errs()<<"ERROR! Expected PHI Instruction: "<<*Ins<<"\n";
    }
    errs()<<"PHI Node: "<<*Phi<<"\n";
    errs()<<"X offset: "<<sign * Const->getSExtValue()<<"\n";
}

void Stencil::parse_yoffset_mul(Value *Val) {
    Instruction *Ins = dyn_cast<Instruction>(Val);
        if(matchInstruction(Ins->getOperand(0),Instruction::PHI) || 
           matchInstruction(Ins->getOperand(0),Instruction::Add) || 
           matchInstruction(Ins->getOperand(0),Instruction::Sub) ){
            parse_yoffset(Ins->getOperand(0));
            parse_yoffset_stride(Ins->getOperand(1));
        } 
        else if (matchInstruction(Ins->getOperand(1),Instruction::PHI) || 
                 matchInstruction(Ins->getOperand(1),Instruction::Add) || 
                 matchInstruction(Ins->getOperand(1),Instruction::Sub) ){
            parse_yoffset(Ins->getOperand(1));
            parse_yoffset_stride(Ins->getOperand(0)); 
        }
        else{
            errs()<<"ERROR! Expected PHINode, Add, or Sub Operand: "<<*Ins<<"\n";
        }
}

void Stencil::parse_yoffset_stride(Value *Val) {
    if(isa<Constant>(Val)){
        errs()<<"CONSTANT: "<<*Val<<"\n";
    }
    else if(isa<Argument>(Val)){
        errs()<<"ARGUMENT: "<<*Val<<"\n";
    }
    else if(isa<LoadInst>(Val)){
        LoadInst *Load = dyn_cast<LoadInst>(Val);
        Value *LoadVal = Load->getPointerOperand();
        errs()<<"LOAD: "<<*LoadVal<<"\n";
    }
    else {
        errs()<<"ERROR! Expected Constant, Argument or LoadInst: "<<*Val<<"\n";
    }
}

void Stencil::parse_yoffset(Value *Val) {
    if(matchInstruction(Val, Instruction::PHI)){
        errs()<<"PHI Node: "<<*Val<<"\n";
        errs()<<"Y offset: 0"<<"\n";
    } 
    else if(matchInstruction(Val, Instruction::Add)){
        parse_yoffset_add(Val, 1);
    }
    else if(matchInstruction(Val, Instruction::Sub)){
        parse_yoffset_add(Val, -1);
    }
    else {
        errs()<<"ERROR! Expected PHI, Add or Sub Instruction: "<<*Val<<"\n";
    }
}

void Stencil::parse_yoffset_add(Value *Val, int sign) {
    Instruction *Ins = dyn_cast<Instruction>(Val);
    PHINode *Phi;
    ConstantInt *Const;
    if(matchInstruction(Ins->getOperand(0),Instruction::PHI)) {
        Phi = dyn_cast<PHINode>(Ins->getOperand(0));
        if(isa<ConstantInt>(Ins->getOperand(1))){
            Const = dyn_cast<ConstantInt>(Ins->getOperand(1));
        }   
        else {
            errs()<<"ERROR! Expected Constant: "<<*Ins->getOperand(1)<<"\n"; 
        }
    }
    else if(matchInstruction(Ins->getOperand(1),Instruction::PHI)) {
        Phi = dyn_cast<PHINode>(Ins->getOperand(1));
        if(isa<ConstantInt>(Ins->getOperand(0))){
            Const = dyn_cast<ConstantInt>(Ins->getOperand(0));
        }
        else{
           errs()<<"ERROR! Expected Constant: "<<*Ins->getOperand(0)<<"\n"; 
        } 
    }
    else{
        errs()<<"ERROR! Expected PHI Instruction: "<<*Ins<<"\n";
    }
    errs()<<"PHI Node: "<<*Phi<<"\n";
    errs()<<"Y offset: "<<sign * Const->getSExtValue()<<"\n";
}


char Stencil::ID = 0;
static RegisterPass<Stencil> Z("stencil", "Detect stencil computation");

//===----------------------- Stencil.cpp ------------------------===//
