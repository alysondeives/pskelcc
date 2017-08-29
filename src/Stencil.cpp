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

bool Stencil::setRadius(StencilInfo *Stencil){
	if(Stencil->neighbors.empty())
		return false;
	
	int max_x, max_y, max_z;
	int range = 0;
	int value = 0;
	
	max_x = abs(Stencil->neighbors[0].offset_x);
	max_y = abs(Stencil->neighbors[0].offset_y);
	max_z = abs(Stencil->neighbors[0].offset_z);
	
	range = ((max_y > max_x) ? max_y : max_x );
	range = ((range > max_z) ? range : max_z );
	
	for(unsigned int i = 1; i < Stencil->neighbors.size(); i++){
		max_x = abs(Stencil->neighbors[i].offset_x);
		max_y = abs(Stencil->neighbors[i].offset_y);
		max_z = abs(Stencil->neighbors[i].offset_z);
		
		value = ((max_y > max_x) ? max_y : max_x );
		value = ((value > max_z) ? value : max_z );
	
		if(value > range){
			range = value;
		}
	}
	
	Stencil->radius = range;
	return true;
}

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
        if(isa<LoadInst>(Ins)){
            
            /* Delinearization moved to verifyStore
            // Print SCEV
            BasicBlock *bb = LD->getParent();
            Loop *L = LI->getLoopFor(bb);
            //errs()<<"Val: "<<*Val<<"\n";
            const SCEV* scev_exp = SE->getSCEVAtScope(LD->getPointerOperand(), L);
            //const SCEV* scev_exp = SE->getSCEV(LD->getPointerOperand());
            errs()<<"-----------------------------------------------------------\n";
            //errs()<<"SCEV Access: "<<*scev_exp<<"\n";
            //printSCEV(scev_exp, SE->getElementSize(dyn_cast<Instruction>(LD->getPointerOperand())));
            const SCEV *ElementSize = SE->getElementSize(LD);
			//errs()<<"ElementSize: "<<ElementSize<<"\n";
			Neighbor neighbor;

            //TODO Move to verifyStore
            delinearize(scev_exp, ElementSize, neighbor);
			*/
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
        if(isa<PHINode>(*Ins)){
            PHINode *PHI = dyn_cast<PHINode>(Ins);
            errs()<<"PHINode: "<<*PHI<<"\n";
            for(int i=0; i<PHI->getNumIncomingValues(); i++){
                errs()<<"Incoming:"<<*PHI->getIncomingValue(i)<<"\n";
                //errs()<<"Incoming:"<<PHI->getIncomingValue(i)<<"\n";
            }  
        }
        else{
            for(int i=0; i<numOperands;i++){
                //if(!(isa<PHINode>(*Ins))){ 
					//errs()<<"Populating: "<<*Ins<<"\n";
                    populateArrayAccess(Ins->getOperand(i),acc);
                //}
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

bool Stencil::delinearize(const SCEV *S, const SCEV *ElementSize, Neighbor &N){
	errs()<<"SCEV Function: "<<*S<<"\n";
    const SCEVUnknown *BasePointer;
	Value *BasePtr;
	
	N.SCEVAccess = S;
	
    // Analyzes 3D and 2D SCEVs in the form
    // 3D: ((TYPE_SIZE * (sext i32 {{{((ConstantExpr | AddExpr | MulExpr | Unknown) * %NK),+,%NK}<%for.cond>,+,(%NJ * %NK)}<%for.cond.1>,+,1}<nw><%for.cond.5> to i64))<nsw> + %BASE_POINTER)<nsw>
    //
    // 2D: ((TYPE_SIZE * (sext i32 {{(ConstantExpr | AddExpr | MulExpr | Unknown),+,%NJ}<%for.cond.1>,+,1}<nw><%for.cond.4> to i64))<nsw> + %POINTER_BASE)<nsw>
    if(isa<SCEVAddExpr>(S)){
        BasePointer = dyn_cast<SCEVUnknown>(SE->getPointerBase(S));
        
        // Do not delinearize if we cannot find the base pointer.
        if (!BasePointer) {
            errs()<<"Could not find base pointer in SCEV : "<<*S<<"\n";  
            return false;
        }
        
        BasePtr = BasePointer->getValue();
        S = SE->getMinusSCEV(S, BasePointer);
        
        //errs()<<"Minus SCEV Function: "<<*S<<"\n";
        
        const SCEVMulExpr *M1 = dyn_cast<SCEVMulExpr>(S);
        if(!M1) {
            errs()<<"Expected Mul Expression: "<<*S<<"\n";
            return false;
        }
        
        if(M1->getNumOperands() != 2){
            errs()<<"Expected 2 Operands in MulExpr: "<<*M1<<"\n";
            return false;
        }
        
        //const SCEV *ElementSize = M1->getOperand(0);
        
        const SCEVSignExtendExpr *Sign = dyn_cast<SCEVSignExtendExpr>(M1->getOperand(1));
        
        if(!Sign){
            errs()<<"Expected SExt expression: "<<*M1<<"\n";
            return false;
        }
        
        Type *SignType = Sign->getType();
        
        const SCEV *S1 = Sign->getOperand();
        
        if(!isa<SCEVAddRecExpr>(S1)){
            errs()<<"Expected SCEV AddRec expression: "<<*Sign<<"\n";
            return false;
        }
        
        errs()<<"Base Pointer: "<<*BasePtr<<"\n";
        errs()<<"Access SCEV: "<<*S1<<"\n";
        // Save Values to Neighbor data
        N.BasePtr = BasePtr;
        //N.SCEVAccess = S1;
			
        //Now we have a AddRec SCEV. We need to traverse it! 
        //SmallVector<const Loop*, 3> SCEVLoops;
        //SmallVector<const SCEV*, 3> SCEVSteps;
        
        while(isa<SCEVAddRecExpr>(S1)){
            const Loop *L = dyn_cast<SCEVAddRecExpr>(S1)->getLoop();
            const SCEV *Step = dyn_cast<SCEVAddRecExpr>(S1)->getStepRecurrence(*SE);

            //SCEVLoops.push_back(L);
            //SCEVSteps.push_back(Step);
            
            N.SCEVLoops.push_back(L);
            N.SCEVSteps.push_back(Step);

            errs()<<"SCEV Step: "<<*Step<<"\n";
            //errs()<<"SCEV Loop: "<<*L<<"\n";
            
            //Loops.insert(std::pair<const Loop*,const SCEV*>(L,Step));
            S1 = (dyn_cast<SCEVAddRecExpr>(S1))->getStart();
        }
        
        errs()<<"SCEVLoops Size: "<<N.SCEVLoops.size()<<"\n";
        switch (N.SCEVLoops.size()){
            case 1:
                errs()<<"ERROR! Unexpected 1D SCEV: "<<*S1<<"\n";
                return false;
                break;
            case 2:
                return parse2DSCEV(S1,N);
                break;
            case 3:
                return parse3DSCEV(S1,N);
                break;
            default:
                errs()<<"ERROR! Unexpected Multidimensional SCEV: "<<*S1<<"\n";
                return false;
                break;
        }
	}
    // Analyzes 1D SCEV in the form  {%BASE_POINTER,+,TYPE_SIZE}<nw><%for.cond.1>
    else if(isa<SCEVAddRecExpr>(S)) {
        return parse1DSCEV(dyn_cast<SCEVAddRecExpr>(S), ElementSize, N);
    }
	else {
        errs()<<"Unexpected SCEV: "<<*S<<"\n";
        return false;
    }
    
	return true;
}

bool Stencil::parse1DSCEV(const SCEVAddRecExpr *S, const SCEV *ElementSize, Neighbor &N){
    errs()<<"1D SCEV: "<<*S<<"\n";
    const SCEVAddExpr *AddExpr;
    const SCEVUnknown *BasePtr;
    const SCEVConstant *Const;
    
    const SCEV *Start = S->getStart();
    const SCEV *Step = S->getStepRecurrence(*SE);

    PHINode *Inner = getPHINode(S->getLoop());
    ConstantInt *InnerValue = dyn_cast<ConstantInt>(Inner->getIncomingValue(0));
    int innerVal = InnerValue->getSExtValue();

    int offsetInner = 0;

    if((AddExpr = dyn_cast<SCEVAddExpr>(Start))){
        Const = dyn_cast<SCEVConstant>(AddExpr->getOperand(0));
        int constVal = Const->getValue()->getSExtValue();
        int sizeVal = (dyn_cast<SCEVConstant>(ElementSize))->getValue()->getSExtValue();

        if(constVal % sizeVal != 0){
            errs()<<"ERROR! Constant "<<*Const<<" should de divided by Element Size "<<*ElementSize<<"\n";
            return false;
        }

        constVal = constVal/sizeVal;

        offsetInner = constVal - innerVal;
        BasePtr = dyn_cast<SCEVUnknown>(AddExpr->getOperand(1));
    }
    else if((BasePtr = dyn_cast<SCEVUnknown>(Start))){
        offsetInner = -1 * innerVal;
    }
    else{
        errs()<<"ERROR! Unexpected SCEV Start: "<<*Start<<"\n";
        return false;
    }

    errs()<<"Offset Inner: "<<offsetInner<<"\n";
    N.BasePtr = BasePtr->getValue();
    N.phinode_x = Inner;
    N.offset_x = offsetInner;
    N.dimension = 1;
    return true;
}

bool Stencil::parse2DSCEV(const SCEV *S, Neighbor &N){
    errs()<<"2D SCEV: "<<*S<<"\n";
    //errs()<<"Constant Range: "<<SE->getUnsignedRange(S)<<"\n";
    PHINode *Outer = getPHINode(N.SCEVLoops[1]);
    PHINode *Inner = getPHINode(N.SCEVLoops[0]);

    //errs()<<"PHINode Inner: "<<*Inner<<"\n";
    //errs()<<"PHINode Outer: "<<*Outer<<"\n";
    
    ConstantInt *InnerValue = dyn_cast<ConstantInt>(Inner->getIncomingValue(0));
    ConstantInt *OuterValue = dyn_cast<ConstantInt>(Outer->getIncomingValue(0));

    int innerVal = InnerValue->getSExtValue();
    int outerVal = OuterValue->getSExtValue();

    //errs()<<"innerVal: "<<innerVal<<"\n";
    //errs()<<"outerVal: "<<outerVal<<"\n";

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
		// InnerLoop  offset = PHINODE-initial-value - 1
		// OuterLoop  offset = -1*PHINODE-initial-value
        offsetInner = 1 - innerVal;  //innerVal - 1;
        offsetOuter = -1 * outerVal;
		break;
	case scAddExpr:
		// 2D Case: Constant + MulExpr | Unknown
		// InnerLoop = if unknown = (1 - PHINODE-initial-value) else (MUlOperand(0) - PHINODE-initial-value)
		// OuterLoop = Constant - PHINODE-initial-value
        AddExpr = dyn_cast<SCEVAddExpr>(S);
        if((MulExpr = dyn_cast<SCEVMulExpr>(AddExpr->getOperand(1)))){
            Const = dyn_cast<SCEVConstant>(MulExpr->getOperand(0));
            offsetInner = Const->getValue()->getSExtValue()-innerVal;
        }
        else if(isa<SCEVUnknown>(AddExpr->getOperand(1))) {
            offsetInner = 1 - innerVal;
        }
        else {
            errs()<<"ERROR! Expected (Constant + MulExpr | Unknown) SCEV: "<<*S<<"\n";
            return false;
        }

        Const = dyn_cast<SCEVConstant>(AddExpr->getOperand(0));
        offsetOuter = Const->getValue()->getSExtValue() - outerVal;
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
		return false;
	}

    errs()<<"Offset Inner: "<<offsetInner<<"\n";
    errs()<<"Offset Outer: "<<offsetOuter<<"\n";
    
    N.phinode_x = Inner;
    N.phinode_y = Outer;
    N.offset_x = offsetInner;
    N.offset_y = offsetOuter;
     N.dimension = 2;
    
    return true;
}

bool Stencil::parse3DSCEV(const SCEV *S, Neighbor &N){
    errs()<<"3D SCEV: "<<*S<<"\n";

    PHINode *Outer = getPHINode(N.SCEVLoops[2]);   //for j
    PHINode *Mid   = getPHINode(N.SCEVLoops[1]);   //for i
    PHINode *Inner = getPHINode(N.SCEVLoops[0]);   //for k

    //errs()<<"PHINode Inner: "<<*Inner<<"\n";
    //errs()<<"PHINode Outer: "<<*Outer<<"\n";

    ConstantInt *InnerValue = dyn_cast<ConstantInt>(Inner->getIncomingValue(0));
    ConstantInt *MidValue = dyn_cast<ConstantInt>(Mid->getIncomingValue(0));
    ConstantInt *OuterValue = dyn_cast<ConstantInt>(Outer->getIncomingValue(0));
    
    int innerVal = InnerValue->getSExtValue();
    int midVal = MidValue->getSExtValue();
    int outerVal = OuterValue->getSExtValue();
    
    //errs()<<"innerVal: "<<innerVal<<"\n";
    //errs()<<"midVal: "<<midVal<<"\n";
    //errs()<<"outerVal: "<<outerVal<<"\n";

    int offsetOuter = 0; // J
    int offsetInner = 0; // K
    int offsetMid = 0;  // I

    const SCEVAddExpr *AddExpr;
    const SCEVConstant *Const;
    const SCEVMulExpr *MulExpr;

    switch(S->getSCEVType()){
    case scConstant:
		// InnerLoop offset = -1*PHINODE-initial-value
        // MidLoop offset = 
		// OuterLoop offset = Constant - PHINODE-initial-value
        Const = dyn_cast<SCEVConstant>(S);
        offsetInner = Const->getValue()->getSExtValue() - innerVal;
        offsetMid = -1 * midVal;
        offsetOuter = -1 * outerVal;
		break;
	case scUnknown:
		// InnerLoop  offset = PHINODE-initial-value - 1
		// OuterLoop  offset = -1*PHINODE-initial-value
        //offsetInner = 1 - innerVal;  //innerVal - 1;
        //offsetOuter = -1 * outerVal;
        offsetInner = -1 * innerVal;
        offsetMid = -1 * midVal;
        offsetOuter = 1 - outerVal;
		break;
	case scAddExpr:
        //3D Case:
        // Constant + NK
        // Constant + (NJ * NK) or
        // Constant + (Constant * NJ * NK)
        // Constant + ((Constant + (Constant * NJ)) * NK)
		// Constant + ((Constant + NJ) * NK)
        AddExpr = dyn_cast<SCEVAddExpr>(S);
        

        Const = dyn_cast<SCEVConstant>(AddExpr->getOperand(0));
        offsetInner = Const->getValue()->getSExtValue()-innerVal;
        
        if((MulExpr = dyn_cast<SCEVMulExpr>(AddExpr->getOperand(1)))){
			if(MulExpr->getNumOperands() == 2){
				// Constant + (NJ * NK)
				if(isa<SCEVUnknown>(MulExpr->getOperand(0)) && isa<SCEVUnknown>(MulExpr->getOperand(1))) {
					offsetMid = 1 - midVal;
					offsetOuter = -1 * outerVal;
				}
				// Constant + ((Constant + NJ) * NK) or
				// Constant + ((Constant + (Constant * NJ)) * NK)
				else if(isa<SCEVAddExpr>(MulExpr->getOperand(0)) && isa<SCEVUnknown>(MulExpr->getOperand(1))) {
					AddExpr = dyn_cast<SCEVAddExpr>(MulExpr->getOperand(0));
					Const = dyn_cast<SCEVConstant>(AddExpr->getOperand(0));
					offsetOuter = Const->getValue()->getSExtValue() - outerVal;
					
					if((MulExpr = dyn_cast<SCEVMulExpr>(AddExpr->getOperand(1)))) {
						Const = dyn_cast<SCEVConstant>(MulExpr->getOperand(0));
						offsetMid = Const->getValue()->getSExtValue() - midVal;
					}
					else if(isa<SCEVUnknown>(AddExpr->getOperand(1))){
						offsetMid = 1 - midVal;
					}
				}
				else if(isa<SCEVConstant>(MulExpr->getOperand(0)) && isa<SCEVUnknown>(MulExpr->getOperand(1))) {
					Const = dyn_cast<SCEVConstant>(MulExpr->getOperand(0));
					offsetOuter = Const->getValue()->getSExtValue() - outerVal;
					
					offsetMid = -1 * midVal;
				}
				else{
					errs()<<"ERROR! Expected (Unknown * Unknown) SCEV: "<<*MulExpr<<"\n";
					 return false;
				}
			}
			else if(MulExpr->getNumOperands() == 3) {
				Const = dyn_cast<SCEVConstant>(MulExpr->getOperand(0));
				if(isa<SCEVUnknown>(MulExpr->getOperand(1)) && isa<SCEVUnknown>(MulExpr->getOperand(2))) {
					offsetMid = Const->getValue()->getSExtValue() - midVal;
					offsetOuter = -1 * outerVal;
				}
				else{
					errs()<<"ERROR! Expected (Constant * Unknow * Unknown) SCEV: "<<*MulExpr<<"\n";
					 return false;
				}
			}
			else {
				errs()<<"ERROR! Expected (Unknown * Unknown) or (Constant * Unknown * Unknown) SCEV : "<<*MulExpr<<"\n";
				return false;
			}
		}
		else {
			if(isa<SCEVUnknown>(AddExpr->getOperand(1))){
				offsetMid = -1 * midVal;
				offsetOuter = 1 - outerVal;
			}
			else{
				errs()<<"ERROR! Expected (Constant + Unknown) SCEV: "<<*S<<"\n";
				 return false;
			}
		}
		break;
	case scMulExpr:
		//3D Case
        //  NJ * NK
        //  Constant * NJ
		//  Constant * NJ * NK or
        // (Constant + NJ) * NK or
        // (Constant + (Constant * NJ)) * NK
        MulExpr = dyn_cast<SCEVMulExpr>(S);
        
        if(MulExpr->getNumOperands() == 3){
            Const = dyn_cast<SCEVConstant>(MulExpr->getOperand(0));
            offsetMid = Const->getValue()->getSExtValue() - midVal;
            offsetInner = -1 * innerVal;
            offsetOuter = -1 * outerVal;
        }
        else if(MulExpr->getNumOperands() == 2){
            if(isa<SCEVUnknown>(MulExpr->getOperand(0))){
                offsetInner = -1 * innerVal;
                offsetOuter = -1 * outerVal;
                offsetMid = 1 - outerVal;
            }
            else if((Const = dyn_cast<SCEVConstant>(MulExpr->getOperand(0)))){
                offsetOuter = Const->getValue()->getSExtValue() - outerVal;
                offsetInner = -1 * innerVal;
                offsetMid = -1 * midVal;
            }
            else if((AddExpr = dyn_cast<SCEVAddExpr>(MulExpr->getOperand(0)))){
                if(isa<SCEVUnknown>(AddExpr->getOperand(1))){
                    offsetInner = -1 * innerVal;

                    Const = dyn_cast<SCEVConstant>(AddExpr->getOperand(0));
                    offsetOuter = Const->getValue()->getSExtValue() - outerVal;

                    offsetMid = 1 - midVal;
                }
                else if(isa<SCEVMulExpr>(AddExpr->getOperand(1))){
                    offsetInner = -1 * innerVal;

                    Const = dyn_cast<SCEVConstant>(AddExpr->getOperand(0));
                    offsetOuter = Const->getValue()->getSExtValue() - outerVal;

                    MulExpr = dyn_cast<SCEVMulExpr>(AddExpr->getOperand(1));
                    Const = dyn_cast<SCEVConstant>(MulExpr->getOperand(0));
                    offsetMid = Const->getValue()->getSExtValue() - midVal;
                }
                else{
                    errs()<<"ERROR! Expected Unknown or MulExpr: "<<*AddExpr->getOperand(1)<<"\n";
                     return false;
                }
            }
            else {
                errs()<<"ERROR! Expected (Constant * Unknown) or (AddExpr * Unknown) :"<<*MulExpr<<"\n";
                return false;
            }
        }
        else{
            errs()<<"ERROR! Expected 2 or 3 operands in MulExpr: "<<*MulExpr<<"\n";
            return false;
        } 
        
		break;
	default:
		llvm_unreachable("Unknown SCEV kind!");
		return false;
	}

    errs()<<"Offset Mid: "<<offsetMid<<"\n";
    errs()<<"Offset Outer: "<<offsetOuter<<"\n";
    errs()<<"Offset Inner: "<<offsetInner<<"\n";
    
    N.phinode_x = Inner; //Mid
    N.phinode_y = Mid; //Outer
    N.phinode_z = Outer; //Inner
    
    N.offset_x = offsetInner; //offsetMid
    N.offset_y = offsetMid; //offsetOuter
    N.offset_z = offsetOuter; //offsetInner
    N.dimension = 3;
    
    return true;
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
	  errs() << *S << "\n";
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

void Stencil::printPtrRangeAnalysis(Loop *loop){
    Region *r = RP->getRegionInfo().getRegionFor(loop->getLoopPreheader());        
	Module *M = loop->getLoopPredecessor()->getParent()->getParent();
	const DataLayout DL = DataLayout(M);

    //std::map<Value *, PtrRangeInfo> BasePtrsData;
    for (auto& pair : ptrRA->RegionsRangeData[r].BasePtrsData) {
        std::vector<const SCEV*> access = pair.second.AccessFunctions;

        for(auto s : access){
            errs()<<*s<<"\n";
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
    
    //Value *bound;
    //if(!(backedge->getSCEVType() == scConstant)) {
	//	bound = visit(backedge);
	//}
	//else{
	//	const SCEVConstant* scev_const = dyn_cast<SCEVConstant>(backedge);
	//	bound = dyn_cast<Value>(scev_const->getValue());
	//}
	//errs()<<"Bound: "<<*bound<<"\n";
	
	
	
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

bool Stencil::isLoopLatch(Loop *L, BasicBlock* BB){
	SmallVector<BasicBlock*,1>  Latches;
	L->getLoopLatches(Latches);
	for(auto latch : Latches){
		if(latch == BB)
			return true;
	}
	return false;	
}

bool Stencil::hasCanonicalUses(PHINode *PHI){
	bool use = true;
	Loop *L = LI->getLoopFor(PHI->getParent());
	for (Value::user_iterator UI = PHI->user_begin(), UE = PHI->user_end();
                     UI != UE; ++UI) {
		User *U = *UI;
        errs() << "  - " << *U << "\n";
        BasicBlock* BB = dyn_cast<Instruction>(U)->getParent();
        if( !(LI->isLoopHeader(BB) || isLoopLatch(L, BB))){
			use = false;
			break;
		}
    }
	return use;
}

bool Stencil::verifyIterationLoop(Loop *loop, StencilInfo *Stencil){
	auto *phiNode = loop->getCanonicalInductionVariable();
	const SCEV* backedge;
	Value *bound;
	    
    if(phiNode) {
		//TODO Backedge SCEV parse
		backedge = SE->getBackedgeTakenCount(loop);
		errs() << "Iteration loop backedge: "<<*backedge<<"\n";
		if(!(backedge->getSCEVType() == scConstant)) {
			bound = visit(backedge);
		}
		else{
			const SCEVConstant* scev_const = dyn_cast<SCEVConstant>(backedge);
			bound = dyn_cast<Value>(scev_const->getValue());
		}
		
		if(!(hasCanonicalUses(phiNode))){
			errs()<<"Iteration loop phinodes are used in loop body\n";
			return false;
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
    auto *phiNode = loop->getCanonicalInductionVariable();
    if(phiNode)
		errs()<< "Induction variable: "<<*phiNode<<"\n";
	else
		errs()<< "Computation Loop has no Induction Variable\n";
	
    Value *bound;

    auto phinode = loop->getCanonicalInductionVariable();
    if(phinode) {
        errs()<<"Computation Loop Canonical Ind-var: "<<*phinode<<"\n";
    }
    
    Stencil->dimension++;
    
	PHINode* phi = getPHINode(loop);
	Stencil->dimension_phinode.push_back(phi);
    errs()<<"Computation Loop "<<Stencil->dimension<<" Phinode: "<<*phi<<"\n";

    const SCEV* backedge = SE->getBackedgeTakenCount(loop);
    errs()<<"Computation Loop "<<Stencil->dimension<<" Backedge SCEV: "<<*backedge<<"\n";

    const SCEVConstant *Const;
    const SCEVSMaxExpr *SMax;
    const SCEVUnknown *Unknown;
    const SCEVAddExpr *AddExpr;
    if((Const = dyn_cast<SCEVConstant>(backedge))){
		bound = Const->getValue();
    }
    else if((SMax = dyn_cast<SCEVSMaxExpr>(backedge))){
        if(!(isa<SCEVConstant>(SMax->getOperand(0)))){
            errs()<<"ERROR! Expected SCEVConstant for Operand 0 of SMaxExprSCEV: "<<*SMax<<"\n";
            return false;
        }
        
        if((Unknown = dyn_cast<SCEVUnknown>(SMax->getOperand(1)))){
            bound = Unknown->getValue();
        }
        else if((AddExpr = dyn_cast<SCEVAddExpr>(SMax->getOperand(1)))){
            if((Unknown = dyn_cast<SCEVUnknown>(AddExpr->getOperand(1)))){
                bound = Unknown->getValue();
            }
            else{
                errs()<<"ERROR! Expected Unknow SCEV in AddExpr SCEV: "<<*AddExpr<<"\n";
                return false;
            }
        }
        else{
            errs()<<"ERROR! Expected Unknown or AddExpr SCEV for Operand 1 of SMaxExpr SCEV: "<<*SMax<<"\n";
            return false;
        }
    }
    else if((Unknown = dyn_cast<SCEVUnknown>(backedge))){
		bound = Unknown->getValue();
	}
    else if((AddExpr = dyn_cast<SCEVAddExpr>(backedge))){
        if((SMax = dyn_cast<SCEVSMaxExpr>(AddExpr->getOperand(1)))){
            if(!(isa<SCEVConstant>(SMax->getOperand(0)))){
                errs()<<"ERROR! Expected SCEVConstant for Operand 0 of SMaxExprSCEV: "<<*SMax<<"\n";
                return false;
            }
            
            if((Unknown = dyn_cast<SCEVUnknown>(SMax->getOperand(1)))){
                bound = Unknown->getValue();
            }
            else if((AddExpr = dyn_cast<SCEVAddExpr>(SMax->getOperand(1)))){
                if((Unknown = dyn_cast<SCEVUnknown>(AddExpr->getOperand(1)))){
                    bound = Unknown->getValue();
                }
                else{
                    errs()<<"ERROR! Expected Unknow SCEV in AddExpr SCEV: "<<*AddExpr<<"\n";
                    return false;
                }
            }
            else{
                errs()<<"ERROR! Expected Unknown or AddExpr SCEV for Operand 1 of SMaxExpr SCEV: "<<*SMax<<"\n";
                return false;
            }
        }
        else if((Unknown = dyn_cast<SCEVUnknown>(AddExpr->getOperand(1)))){
            bound = Unknown->getValue();
        }
        else{
            errs()<<"ERROR! Expected SMaxExpr SCEV for Operand 1 of AddExpr SCEV: "<<*AddExpr<<"\n";
            return false;
        }
    }
    else{
        errs()<<"ERROR! Loop has unexpected SCEV backedge type: "<<*backedge<<"\n";
        return false;
    }
    /*
	if(!(backedge->getSCEVType() == scConstant)) {
		bound = visit(backedge);
	}
	else{
		const SCEVConstant* scev_const = dyn_cast<SCEVConstant>(backedge);
		bound = dyn_cast<Value>(scev_const->getValue());
	}
    */
	Stencil->dimension_value.push_back(bound);
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

//TODO Verify if the only computation neighbor is the same store base pointer

bool Stencil::verifyStore(Loop *loop, StencilInfo *Stencil){
	Value *PtrOp;
	//Value *ValOp;
	//Instruction *Ins;
	GetElementPtrInst *GEP;
	LoadInst *LD;
	
	
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
	
	//TODO Analyze more than one store
	if(StrIns.size()> 1){
		errs()<<"ERROR! Inner computation loop has more than 1 store instruction\n";
		return false;
	}
	
	for(auto Ins : StrIns){
		ArrayAccess arrayAcc;
		Neighbor store_neighbor;
		errs()<<"Store: "<<*Ins<<"\n";	
        //errs() << "Store Instruction: "<< *Ins << "\n";
        
        // Get base pointer of store instruction operand
        PtrOp = getPointerOperand(Ins);

        const SCEV *ElementSize = SE->getElementSize(Ins);

        errs()<<"Str PtrOp: "<<*PtrOp<<"\n";
        
        while (isa<LoadInst>(PtrOp) || isa<GetElementPtrInst>(PtrOp)){
            if((LD = dyn_cast<LoadInst>(PtrOp)))
                PtrOp = LD->getPointerOperand();
            if((GEP = dyn_cast<GetElementPtrInst>(PtrOp)))
                PtrOp = GEP->getPointerOperand();
            //errs()<<"Passou "<<"\n";
        }
        
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

        const SCEV *StrSCEV = SE->getSCEV(Str->getPointerOperand());
        if(!delinearize(StrSCEV, ElementSize, store_neighbor)){
			errs()<<"Error delinearizing: "<<*Str<<" with SCEV "<<*StrSCEV<<"\n";
            return false;
        }
        
        /* The Store Pointer must have the same dimension as the number of loops */
        if(store_neighbor.dimension != Stencil->dimension){
			errs()<<"ERROR! Store Pointer has dimension "<< store_neighbor.dimension  <<" expected "<<Stencil->dimension <<"\n";
			return false;
		}
        
        
        errs()<<"-----------------------------------------------------------\n";
        errs()<<"Str SCEV Access: "<<*StrSCEV<<"\n";

        //parseSCEVs

        
        errs()<<"ArrayAccess Size: "<<arrayAcc.size()<<"\n";
        /* Get all Neighbors */
        for(auto i : arrayAcc){
            Neighbor N;
            LoadInst *LD = dyn_cast<LoadInst>(i.first);
            BasicBlock *bb = LD->getParent();
            Loop *L = LI->getLoopFor(bb);
            
            const SCEV* SCEVExpr = SE->getSCEVAtScope(LD->getPointerOperand(), L);
            const SCEV *ElementSize = SE->getElementSize(LD);
            N.LoadAccess = LD;
            errs()<<"-----------------------------------------------------------\n";
   
            if(!delinearize(SCEVExpr, ElementSize, N)){
				errs()<<"Error delinearizing: "<<*i.first<<" with SCEV "<<*SCEVExpr<<"\n";
                return false;
			}
			
			/* Match access */
			if(!(matchStencilNeighborhood(store_neighbor, N))){
				errs()<<"ERROR! Str and Neighbor access does not match\n";
				errs()<<"\tStr: "<<*(store_neighbor.SCEVAccess)<<"\n";
				errs()<<"\tNeighbor: "<<*(N.SCEVAccess)<<"\n";
				return false;
			}	
			
			Stencil->neighbors.push_back(N);
			
			// initially considers all pointers as arguments
            // the input pointer will be in the swap loop
			if(std::find(Stencil->arguments.begin(),Stencil->arguments.end(),N.BasePtr) == Stencil->arguments.end()){
				//errs()<<"Inserted: "<<neighbor.basePtr<<"\n";
                Value *Val = N.BasePtr;
                Stencil->arguments.push_back(Val);
			}
        }
        
        
        //TODO For at least one Argument Pointer, we need to find at least two references with different offsets
        bool neighborhood = false;
        for(auto arg: Stencil->arguments){
			int count = 0;
            std::vector<Neighbor> NeighborSet;
			for(auto neighbor : Stencil->neighbors){
				if(neighbor.BasePtr == arg){
					count++;
                    NeighborSet.push_back(neighbor);
				}
			}

            if(count == 1){
                continue;
            }

            Neighbor neighbor = NeighborSet[0];
            for(unsigned int i=1; i < NeighborSet.size(); i++){
                if(neighbor.offset_x != NeighborSet[i].offset_x ||
                   neighbor.offset_y != NeighborSet[i].offset_y ||
                   neighbor.offset_z != NeighborSet[i].offset_z){
                    neighborhood = true;
                }
            }
		}
		
		if(!neighborhood){
			errs()<<"ERROR! Computation does not have stencil neighborhood\n";
			return false;
		}
		
		//Set Neighborhood radius
		if(!setRadius(Stencil)){
			errs()<<"ERROR! Could not set stencil radius!\n";
		}
        
        //errs() << "Store Base pointer: "<<*PtrOp << "\n"; 
        Stencil->output = PtrOp;
        Stencil->outputStr = Str;
	}
	errs()<<"Stencil Output: "<<*Stencil->output<<"\n";
    //printNeighbors(Stencil);		
	return true;
}

/*
bool Stencil::matchStencilSwap(Neighbor &Str, Neighbor &N){
    if(Str.SCEVLoops.size() != Str.SCEVLoops.size())
		return false;
	
    for (int i=0; i<Str.SCEVLoops.size(); i++){
		if(Str.SCEVLoops[i] != N.SCEVLoops[i])
			return false;
			
		if(Str.SCEVSteps[i] != N.SCEVSteps[i])
			return false;
		}
	}
}
*/

bool Stencil::matchStencilNeighborhood(Neighbor &Str, Neighbor &N){
	/* Match SCEV Loops */
	if(Str.SCEVLoops.size() != N.SCEVLoops.size()){
		/* They have different sizes, but can be a neighbor argument */
		return true;
	}
	else {
		for (unsigned int i=0; i<Str.SCEVLoops.size(); i++){
            //const SCEV *StrSCEV = Str.SCEVSteps[i];
            //const SCEV *NSCEV = N.SCEVSteps[i];

            /*if(StrSCEV != NSCEV){
                errs()<<"ERROR! Store and Neighbor SCEV Steps differs\n";
                errs()<<"\t Store: "<<*StrSCEV<<"\n";
                errs()<<"\t Neighbor: "<<*NSCEV<<"\n";
				return false;
            }*/
            
			if(Str.SCEVLoops[i] != N.SCEVLoops[i]){
                errs()<<"ERROR! Store and Neighbor SCEV Loops differs\n";
                errs()<<"\t Store: "<<*(Str.SCEVLoops[i])<<"\n";
                errs()<<"\t Neighbor: "<<*(N.SCEVLoops[i])<<"\n";
				return false;
            }
			
			if(Str.SCEVSteps[i] != N.SCEVSteps[i]){
				errs()<<"ERROR! Store and Neighbor SCEV Steps differs\n";
                errs()<<"\t Store: "<<*(Str.SCEVSteps[i])<<"\n";
                errs()<<"\t Neighbor: "<<*(N.SCEVSteps[i])<<"\n";
				return false;
            }
            
		}
	}
	//for(auto neighbor : Stencil->neighbors){
		//errs()<<"Position "<<*str_neighbor->scev_exp<<"\n";
		// TODO Match
		/*if( neighbor.phinode_x != str_neighbor->phinode_x ||
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
		*/
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
	
	errs()<<"Swap Look Backedge: " << *backedge << "\n";
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

bool Stencil::verifySwap(Loop *L, StencilInfo *Stencil){
	//ArrayAccess arr;
	//Neighbor str_neighbor;
	//Neighbor neighbor;
	//Value* OutputVal; // Base Pointer of the value stored
	//Value* InputVal;  // Base Pointer of the store
	LoadInst *LD;
	GetElementPtrInst *GEP;

    //TODO Store all the Store Inst first and then loop through them
	for(Loop::block_iterator bb = L->block_begin();bb!=L->block_end(); ++bb){
		for(BasicBlock::iterator I = (*bb)->begin(), E = (*bb)->end(); I != E; ++I){
			if(isa<StoreInst>(I)){
                StoreInst *Str = dyn_cast<StoreInst>(I);
                
                Value *StrPointer = Str->getPointerOperand();
                Value *StrValue = Str->getValueOperand();

                if(!(GEP = dyn_cast<GetElementPtrInst>(StrPointer))){
                    errs()<<"ERROR! Expected GEP as Store Pointer Operand: "<<*StrPointer<<"\n";
                    return false;
                }

                if(!(LD = dyn_cast<LoadInst>(StrValue))){
                    errs()<<"ERROR! Expected LoadInst as Store Value Operand: "<<*StrValue<<"\n";
                    return false;
                }

                const SCEV* SCEVStrPointer = SE->getSCEVAtScope(GEP, L);
                const SCEV* SCEVStrValue = SE->getSCEVAtScope(LD->getPointerOperand(), L);
                const SCEV* SCEVMinus = SE->getMinusSCEV(SCEVStrPointer,SCEVStrValue);
                
                //errs()<<"SCEV StrPointer: "<<*SCEVStrPointer<<"\n";
                //errs()<<"SCEV StrValue: "<<*SCEVStrValue<<"\n";
                //errs()<<"SCEV StrMinus: "<<*SCEVMinus<<"\n";

                /* We expect the SCEVMinus to be on the form ((-1 * %INPUT) + %OUTPUT) */
                const SCEVAddExpr *AddExpr;
                const SCEVUnknown *SCEVOutput;
                const SCEVMulExpr *SCEVInput;
                
                if(!(AddExpr = dyn_cast<SCEVAddExpr>(SCEVMinus)))
                    return false;
                
                if(!(SCEVInput = dyn_cast<SCEVMulExpr>(AddExpr->getOperand(0))))
                    return false;

                if(!(SCEVOutput = dyn_cast<SCEVUnknown>(AddExpr->getOperand(1))))
                    return false;

                Value *Input = dyn_cast<SCEVUnknown>(SCEVInput->getOperand(1))->getValue();
                Value *Output = SCEVOutput->getValue();

                /* Match Output Value */
                if(Stencil->output != Output){
                    errs()<<"ERROR! Output Pointer Values does not match";
                    errs()<<"\tSwap Loop Output: "<<*Output<<"\n";
                    errs()<<"\tComputation Loop Output: "<<*Stencil->output<<"\n";
                    return false;
                }

                /* Match Input Value and remove it from arguments list */
                for(unsigned int i = 0; i < Stencil->arguments.size(); ++i){
                    //errs()<<"Swap: "<<&(*it)<<"\n";
                    if(Stencil->arguments[i] == Input){
                        errs()<<"Stencil Input: "<<*Input<<"\n";
                        Stencil->input = Input;
                        Stencil->arguments.erase(Stencil->arguments.begin() + i);
                    }
                }

                if(!Stencil->input){
                    errs()<<"ERROR! Input Pointer value does not match\n";
                    errs()<<"\tSwap Loop Input: "<<*Input<<"\n";
                    errs()<<"\tComputation Loop Inputs: \n";
                    for(auto i : Stencil->arguments){
                        errs()<<"\t"<<*i<<"\n";
                    }
                    return false;
                }
                
                //Instruction *Ins = dyn_cast<Instruction>(&*I);
				//errs() << "Store Instruction: "<< *Ins << "\n";

                /*
				// Get base pointer of store instruction operand
                InputVal = getPointerOperand(Ins);
                GEP = dyn_cast<GetElementPtrInst>(InputVal);
                
                const SCEV *ElementSize = SE->getElementSize(I);
				//errs()<<"PtrOp: "<<*InputVal<<"\n";

                const SCEV* SCEVExpr = SE->getSCEVAtScope(GEP->getPointerOperand(), L);
                */
                

                /*
				parse_gep(InputVal, ElementSize, &str_neighbor);
				
				while (isa<LoadInst>(InputVal) || isa<GetElementPtrInst>(InputVal)){
					if((LD = dyn_cast<LoadInst>(InputVal)))
						InputVal = LD->getPointerOperand();
					if((GEP = dyn_cast<GetElementPtrInst>(InputVal)))
						InputVal = GEP->getPointerOperand();
					//errs()<<"Passou "<<"\n";
				}
				*/
				//errs() << "Swap Store Base pointer: "<<*InputVal << "\n"; 
				//errs() << "Swap GEP: "<<*GEP<<"\n";
				
				
			
				//Output Computation Value
				//errs()<<"Swap Store Value Operand: "<<*Str->getValueOperand()<<"\n";
				
				//Output GEP
				//errs()<<"Swap Store Pointer Operand: "<<*Str->getPointerOperand()<<"\n";
			   
				//Populate map with memory access of the store
				/*populateArrayAccess(Str->getValueOperand(),&arr);   //Saved values
				//populateArrayAccess(Str->getPointerOperand());
				
				if(arr.size() > 1){
					errs()<<"ERROR! Expected only one load value on the Store\n";
					return false;
				}
				
				Neighbor neighbor;
				if(parse_load(arr.begin()->first, &neighbor)){
					//errs()<<"Load scev: "<<*neighbor.scev_exp<<"\n";
					OutputVal = neighbor.BasePtr;
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
						if(Stencil->arguments[i] == str_neighbor.BasePtr){
							Stencil->input = str_neighbor.BasePtr;
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
                */
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
    errs() << "Dumping SCEVs:\n";
    LoadInst *LD;
    StoreInst *Str;
    for(inst_iterator i = inst_begin(F); i != inst_end(F);++i){
        if((LD = dyn_cast<LoadInst>(&(*i)))){
            const SCEV* scev_exp = SE->getSCEV(LD->getPointerOperand());
            errs()<<"Load SCEV: " << *scev_exp << "\n";
        }
        if((Str = dyn_cast<StoreInst>(&(*i)))){
            const SCEV* scev_exp = SE->getSCEV(Str->getPointerOperand());
            errs()<<"Store SCEV: " << *scev_exp << "\n";
        }
    }
    
    if(verifyStencil()){
		errs()<<"FUNCTION "<< F.getName()<<" CONTAINS STENCIL!\n";
	}
    else{
        errs()<<"Function "<< F.getName()<<" does not constain Stencil\n";
    }
	return false;
}

// TODO Generate Stencil Computation tree for future Code Generation
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
		//printLoopDetails(it_loop);
		//outermost loop
		//Loop *it_loop = LI->begin()[0];
		vector<Loop*> subLoops = it_loop->getSubLoops();
		
		if(it_loop->isAnnotatedParallel()){
			errs()<<"Outermost loop is Annotated Parallel\n";
		}
		
		if(subLoops.size() == 1) { //!verifyIterationLoop(it_loop)
			/* Considers it is a single iteration stencil */
			errs()<<"-----------------------------------------------------------\n";
			errs()<<"Considering a single iteration stencil\n";
			
			if(!verifyComputationLoops(it_loop,1, &Stencil)){
				errs()<<"ERROR! Computation loop does not match stencil\n";
				//return false;
                if(loopCount == 1)
                    return false;
                else
                    continue;
			}
			
			// Set the number of iteration to 1
			llvm::Type *i64_type = llvm::IntegerType::getInt64Ty(llvm::getGlobalContext());
			llvm::Constant *i64_val = llvm::ConstantInt::get(i64_type, 1, false);
			Stencil.iteration_value = dyn_cast<Value>(i64_val);
			
			//Set the input
			//TODO In case of many arguments, define wich one is the input (largest number of references?)
			Stencil.input = Stencil.arguments.back();
			Stencil.arguments.pop_back();
		}
		else {
			errs()<<"-----------------------------------------------------------\n";
			errs()<<"Considering a iterative stencil\n";
			// iteration loop
			if(!verifyIterationLoop(it_loop, &Stencil)){
                if(loopCount == 1)
                    return false;
                else
                    continue;
			}
			// computation loops
			if(subLoops.size() != 2){
				errs()<<"ERROR! Expected 2 subloops for outermost loop\n";
                //return false;
                 if(loopCount == 1)
                    return false;
                else
                    continue;
			}
			else{
				if(!verifyComputationLoops(subLoops[0],1, &Stencil)){
					errs()<<"Computation loop does not match stencil\n";
					//return false;
                    if(loopCount == 1)
                        return false;
                    else
                        continue;
				}
				if(!verifySwapLoops(subLoops[1],1, &Stencil)) {
					errs()<<"Swap loop does not match stencil\n";
					//return false;
                    if(loopCount == 1)
                        return false;
                    else
                        continue;
				}
			}
			
			//Set the input
			//TODO In case of many arguments, define wich one is the input (largest number of references?)
			Stencil.input = Stencil.arguments.back();
			Stencil.arguments.pop_back();
			
		}
        errs()<<"INSERTING!\n";
        StencilData.insert(std::pair<Function*, StencilInfo>(CurrentFn,Stencil));
        loopCount--;
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

/*
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

bool Stencil::parse_load(Value *Val, Neighbor *neighbor) {
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


bool Stencil::parse_gep(Value *Val, const SCEV *ElementSize, Neighbor *neighbor) {
	//errs()<<"Parse gep: "<<*Val<<"\n";
	if(GetElementPtrInst *GEP = dyn_cast<GetElementPtrInst>(Val)) {
		//errs()<<"GEP: "<<*GEP<<"\n";
		BasicBlock *bb = GEP->getParent();
		Loop *L = LI->getLoopFor(bb);
		//errs()<<"Val: "<<*Val<<"\n";
		const SCEV* scev_exp = SE->getSCEVAtScope(Val, L);
        errs()<<"SCEV: "<<*scev_exp<<"\n";
        
		neighbor->SCEVAccess = scev_exp;
		neighbor->BasePtr = GEP->getOperand(0);
		if(!parse_idxprom(GEP->getOperand(1), neighbor))
			return false;
	}
	else {
		errs()<<"ERROR! Expected GEP Instruction: "<<*Val<<"\n";
		return false;
	}
	return true;
}

bool Stencil::parse_idxprom(Value *Val, Neighbor *neighbor) {
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

bool Stencil::parse_start(Value *Val, Neighbor *neighbor) {
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


bool Stencil::parse_xoffset(Value *Val, Neighbor *neighbor) {
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

bool Stencil::parse_xoffset_add(Value *Val, int sign, Neighbor *neighbor) {
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

bool Stencil::parse_yoffset_mul(Value *Val, Neighbor *neighbor) {
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

bool Stencil::parse_yoffset_stride(Value *Val, Neighbor *neighbor) {
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

bool Stencil::parse_yoffset(Value *Val, Neighbor *neighbor) {
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

bool Stencil::parse_yoffset_add(Value *Val, int sign, Neighbor *neighbor) {
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
*/
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
static RegisterPass<Stencil> Z("stencil", "Detect stencil computation", false, true);

//===----------------------- Stencil.cpp ------------------------===//
