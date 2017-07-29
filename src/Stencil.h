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

  //The key value is the load instruction
  //The map value is the arrayExpression map
  typedef std::map<Value*,ArrayExpression> ArrayAccess;
 
  //The key value is the array base pointer
  //The mapped values are each arrayAccess from this base pointer
  typedef std::multimap<Value*, ArrayAccess> BasePointers;
  
  struct Neighbor2D {
	  const SCEV* scev_exp;
	  Value*   basePtr;
	  PHINode* phinode_x;
	  PHINode* phinode_y;
	  int offset_x;
	  int offset_y;
	  Value* stride_x;
	  
	  Neighbor2D() {
		basePtr = nullptr;
		phinode_x = nullptr;
		phinode_y = nullptr;
		stride_x = nullptr;
		offset_x = 0;
		offset_y = 0;
		scev_exp = nullptr;
	  }
	  
	  void dump() {
		errs()<<"Base pointer: "<< *basePtr <<"\n";
		errs()<<"SCEV: "<< *scev_exp <<"\n";
		errs()<<"PHINode X: "<<*phinode_x<<"\n";
		errs()<<"X Offset: "<<offset_x<<"\n";
		errs()<<"PHINode Y: "<<*phinode_y<<"\n";
		errs()<<"Y Offset: "<<offset_y<<"\n";
		errs()<<"Stride X: "<<*stride_x<<"\n";
	  }
  };
  
  struct StencilData {
	int 		dimension;
	Value* 		iteration_value;
	PHINode* 	iteration_phinode;
	Loop*		iteration_loop;
	SmallVector<Value*,3> 		dimension_value;
	SmallVector<PHINode*,3> 	dimension_phinode;
	SmallVector<Loop*,3>		dimension_loops;
	int 		num_neighbors;
	Value*		input;
	Value*		output;
	std::vector<Neighbor2D> neighbors;
	std::vector<Value*> arguments;
	
	StencilData() {
		dimension = 0;
	}
  };
  //===---------------------------------------------------------------------===

  Value* getPointerOperand (Instruction *Ins);
  void populateArrayExpression (ArrayExpression *ArrayExp, Value *Val);
  void populateArrayAccess (Value *Val, ArrayAccess *acc);
  void traverseArrayExpression( ArrayExpression *ArrayExp, Value *Val);
  void showArrayExpression (ArrayExpression *ArrayExp, Value *Val);
  void showArrayAccess();
  bool containsOpCode (Value *Val, unsigned opCode);

  bool matchInstruction (Value *Val, unsigned opCode);
  bool parse_load (Value *Val, Neighbor2D *neighbor);
  bool parse_gep (Value *Val, Neighbor2D *neighbor);
  bool parse_idxprom (Value *Val, Neighbor2D *neighbor);
  bool parse_start (Value *Val, Neighbor2D *neighbor);
  bool parse_xoffset (Value *Val, Neighbor2D *neighbor);
  bool parse_xoffset_add (Value *Val, int sign, Neighbor2D *neighbor);
  bool parse_yoffset (Value *Val, Neighbor2D *neighbor);
  bool parse_yoffset_add (Value *Val, int sign, Neighbor2D *neighbor);
  bool parse_yoffset_mul (Value *Val, Neighbor2D *neighbor);
  bool parse_yoffset_stride (Value *Val, Neighbor2D *neighbor);
  
  void buildRange (Loop *loop);
  void printLoopDetails (Loop *loop);
  void printNeighbors ();
  
  bool verifyIterationLoop (Loop *loop);
  bool verifyComputationLoops (Loop *loop, unsigned int dimension);
  bool verifySwapLoops (Loop *loop, unsigned int dimension);
  bool verifyStore (Loop* loop);
  bool verifySwap (Loop* loop);
  PHINode* getPHINode (Loop *loop);
  bool matchStencilNeighborhood(Neighbor2D *str_neighbor);
  
  Value* visit(const SCEV *S);
  Value* visitAddExpr(const SCEVAddExpr *S);
  Value* visitSMaxExpr(const SCEVSMaxExpr *S);
  Value* visitUMaxExpr(const SCEVUMaxExpr *S);
  Value* visitUnknown(const SCEVUnknown *S);
  
  void showRange();
  
 
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
