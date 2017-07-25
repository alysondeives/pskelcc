#include "llvm/Analysis/RegionInfo.h"
#include "llvm/Analysis/AliasAnalysis.h"
#include "llvm/Analysis/ScalarEvolutionExpressions.h"
#include "llvm/Analysis/ScalarEvolution.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/LoopPass.h"

#include "llvm/ADT/SmallVector.h"

//#ifndef myutils
//#define myutils
#include "../../dawncc/PtrRangeAnalysis/PtrRangeAnalysis.h"

//#include "../../dawncc/ArrayInference/recoverCode.h"
//#include "../../dawncc/ScopeTree/ScopeTree.h"
//#endif

#include <vector>
#include <map>

using namespace llvm;
using namespace lge;


class Stencil : public FunctionPass {

  private:

  //===---------------------------------------------------------------------===
  //                              Data Structs
  //===---------------------------------------------------------------------===
  //The key value is the root instruction of a array access Expression  (Value*)
  //The map value is a vector of the X key operands ( Value->getOperand(X) )
  typedef std::multimap<Value*, Value*> ArrayExpression; 

  //The key value is the pointer Operand of a GEP ( GEP->getOperandPointer() )
  //The map value is the arrayExpression map
  typedef std::map<Value*,ArrayExpression> ArrayAccess;
 
 
  struct StencilData {
	int 		dimension_size;
	Value* 		iteration_value;
	PHINode* 	iteration_phinode;
	Loop*		iteration_loop;
	SmallVector<Value*,3> 		dimension_value;
	SmallVector<PHINode*,3> 	dimension_phinode;
	SmallVector<Loop*,3>		dimension_loops;
	int 		num_neighbors;
	Value*		input;
	Value*		output;
	
	StencilData() {}
  };
  //===---------------------------------------------------------------------===

  Value* getPointerOperand (Instruction *Ins);
  void populateArrayExpression (ArrayExpression *ArrayExp, Value *Val);
  void populateArrayAccess (Value *Val);
  void traverseArrayExpression( ArrayExpression *ArrayExp, Value *Val);
  void showArrayExpression (ArrayExpression *ArrayExp, Value *Val);
  bool containsOpCode (Value *Val, unsigned opCode);

  bool matchInstruction (Value *Val, unsigned opCode);
  void parse_start (Value *Val);
  void parse_xoffset (Value *Val);
  void parse_xoffset_add (Value *Val, int sign);
  void parse_yoffset (Value *Val);
  void parse_yoffset_add (Value *Val, int sign);
  void parse_yoffset_mul (Value *Val);
  void parse_yoffset_stride (Value *Val);
  
  void buildRange (Loop *loop);
  void getLoopDetails (Loop *loop);
  bool verifyIterationLoop (Loop *loop);
  void verifyStore (BasicBlock* bb);
  
  Value* visit(const SCEV *S);
  Value* visitAddExpr(const SCEVAddExpr *S);
  Value* visitSMaxExpr(const SCEVSMaxExpr *S);
  Value* visitUMaxExpr(const SCEVUMaxExpr *S);
  Value* visitUnknown(const SCEVUnknown *S);
  
  
  
 
  public:

  //===---------------------------------------------------------------------===
  //                              Data Structs
  //===---------------------------------------------------------------------===

  //The key value is the root instruction of the array access Expression  (Value*)
  //The mapped values are the X key operands ( Value->getOperand(X) )
  //typedef std::map<Value*,vector<Value*>> arrayExpression; 
  //arrayExpression ArrayExp;

  //The key value is the pointer Operand of a GEP ( GEP->getOperandPointer() )
  //The 
  //typedef std::multimap<Value*,arrayExpression> arrayAccess;
  ArrayAccess arrayAcc;
  StencilData StencilInfo;

  //===---------------------------------------------------------------------===

  static char ID;

  Stencil() : FunctionPass(ID) {};
  
  // We need to insert the Instructions for each source file.
  virtual bool runOnFunction(Function &F) override;

  virtual void getAnalysisUsage(AnalysisUsage &AU) const {
      
      AU.addRequired<RegionInfoPass>();
      AU.addRequired<AliasAnalysis>();
      
      //AU.addRequiredTransitive<LoopInfoWrapperPass>();
      AU.addRequired<PtrRangeAnalysis>();
      AU.addRequired<DominatorTreeWrapperPass>();
      //AU.addRequired<RecoverNames>();
      
      //AU.addRequired<RegionReconstructor>(); 
      //AU.addRequired<ScopeTree>();
      
      AU.addRequired<LoopInfoWrapperPass>();
      AU.addRequired<ScalarEvolution>();
      AU.setPreservesAll();
  }

  ScalarEvolution *SE;
  LoopInfo *LI;
  PtrRangeAnalysis *ptrRA;
  RegionInfoPass *RP;
  AliasAnalysis *AA;
  DominatorTree *DT;
  
  //RecoverNames *rn;
  //RegionReconstructor *rr;
  //ScopeTree *st;
  
};

//===------------------------ Stencil.h --------------------------===//
