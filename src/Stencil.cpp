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
//using namespace lge;

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

bool Stencil::runOnFunction(Function &F) {
	this->LI = &getAnalysis<LoopInfoWrapperPass>().getLoopInfo();
	this->SE = &getAnalysis<ScalarEvolution>();
	
    /*this->li = &getAnalysis<LoopInfoWrapperPass>().getLoopInfo();
    this->rp = &getAnalysis<RegionInfoPass>();
    this->aa = &getAnalysis<AliasAnalysis>();
    this->se = &getAnalysis<ScalarEvolution>();
    this->dt = &getAnalysis<DominatorTreeWrapperPass>().getDomTree();
    this->ptrRA = &getAnalysis<PtrRangeAnalysis>();
    this->rn = &getAnalysis<RecoverNames>();
    this->rr = &getAnalysis<RegionReconstructor>();
    this->st = &getAnalysis<ScopeTree>();
	*/
	//ScalarEvolution &SE = getAnalysis<ScalarEvolutionWrapperPass>(F).getSE();
	//int loopCounter = 0;
	
    errs() << "\nFunction: " << F.getName() + "\n";
    errs() << "Arguments: ";
    for (auto& A : F.getArgumentList()) {
        errs() << A << "\t";
    }
    errs() << "\n";
    
    //for (LoopInfo::iterator i = LI.begin(); i != LI.end(); ++i){	
	//	Loop *L = *i;
	//	loopCounter++;
	//	L->print(errs());
	//}
	
	
	errs() << "Dumping loops:\n";
	for(auto bb = F.begin(); bb!=F.end(); bb++){
      if(LI->isLoopHeader(&(*bb))){
         Loop *loop = LI->getLoopFor(&(*bb));
         loop->print(errs());
         
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
         
        /// getBackedgeTakenCount - If the specified loop has a predictable
		/// backedge-taken count, return it, otherwise return a SCEVCouldNotCompute
		/// object. The backedge-taken count is the number of times the loop header
		/// will be branched to from within the loop. This is one less than the
		/// trip count of the loop, since it doesn't count the first iteration,
		/// when the header is branched to from outside the loop.
		///
		/// Note that it is not valid to call this method on a loop without a
		/// loop-invariant backedge-taken count (see
		/// hasLoopInvariantBackedgeTakenCount)t.
        errs() << "BackedgeTakenCount: "; 
         
        const SCEV* backedge = SE->getBackedgeTakenCount(loop);
        backedge->dump();;
         
        SE->getRange(backedge, ScalarEvolution::HINT_RANGE_SIGNED ).dump();
         //SE->getUnsignedRange(SE->getBackedgeTakenCount(loop)).dump();
         
         
         /// getMaxBackedgeTakenCount - Similar to getBackedgeTakenCount, except
		 /// return the least SCEV value that is known never to be less than the
		 /// actual backedge taken count.
         errs() << "MaxBackedgeTakenCount: ";
         SE->getMaxBackedgeTakenCount(loop)->dump();
         //SE->getUnsignedRange(SE->getMaxBackedgeTakenCount(loop)).dump();
         
         
		/// Check to see if the loop has a canonical induction variable: an integer
		/// recurrence that starts at 0 and increments by one each time through the
		/// loop. If so, return the phi node that corresponds to it.
		///
		/// The IndVarSimplify pass transforms loops to have a canonical induction
		/// variable.
		///
  
         auto *phiNode = loop->getCanonicalInductionVariable();       
         errs() << "Ind-var: ";
         if(phiNode) phiNode->dump();
         else errs() << "Could not find canonical ind-var\n";
         
         //errs() << "Relaxing loop:\n";
         //performRelaxationInLoop(loop,bbCosts,instrBBs,instrBBSets,loopInfo,BFI);
         
         errs() << "Exit count: ";
         SE->getExitCount(loop,loop->getUniqueExitBlock())->dump();
      }
   }
       
   
   
   // Searches for a Store instruction
   // TODO move to inner loop verificaton
   Value *PtrOp;
   //Value *ValOp;
   Instruction *Ins;
   GetElementPtrInst *GEP;
   LoadInst *LD;
	
    for(inst_iterator I = inst_begin(F),E=inst_end(F); I!=E; ++I){
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
    
    return(false);
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
