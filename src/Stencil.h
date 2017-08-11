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
  
  struct Neighbor{
	  const SCEV* SCEVAccess;
	  SmallVector<const Loop*,3> SCEVLoops;
	  SmallVector<const SCEV*,3> SCEVSteps;
	  Value*   BasePtr;
	  LoadInst *LoadAccess;
	  
	  PHINode* phinode_x;
	  PHINode* phinode_y;
	  PHINode* phinode_z;
	  
	  int dimension;
	  int offset_x;
	  int offset_y;
	  int offset_z;
	  Value* stride_x;
	  
	  
	  Neighbor() {
		BasePtr = nullptr;
		phinode_x = nullptr;
		phinode_y = nullptr;
		phinode_z = nullptr;
		stride_x = nullptr;
		offset_x = 0;
		offset_y = 0;
		offset_z = 0;
		dimension = 1;
		//SCEVAccess = nullptr;
	  }
	  
	  void dump() {
		if(BasePtr)
			errs()<<"Base pointer: "<< *BasePtr <<"\n";
		if(SCEVAccess)
			errs()<<"SCEV: "<< *SCEVAccess<<"\n";
		if(phinode_x){
			errs()<<"PHINode X: "<<*phinode_x<<"\n";
			errs()<<"X Offset: "<<offset_x<<"\n";
		}
		if(phinode_y){
			errs()<<"PHINode Y: "<<*phinode_y<<"\n";
			errs()<<"Y Offset: "<<offset_y<<"\n";
		}
		if(phinode_z){
			errs()<<"PHINode Z: "<<*phinode_z<<"\n";
			errs()<<"Z Offset: "<<offset_z<<"\n";
		}
		if(stride_x)
			errs()<<"Stride X: "<<*stride_x<<"\n";
	  }
  };
  
  struct StencilInfo {
	int 		dimension;
    std::tuple<Loop*, PHINode*, Value*> dimensions;
    std::tuple<Loop*, PHINode*, Value*> iteration;
	Value* 		iteration_value;
	PHINode* 	iteration_phinode;
	Loop*		iteration_loop;
    Loop*       outer_loop;
	SmallVector<Value*,3> 		dimension_value;
	SmallVector<PHINode*,3> 	dimension_phinode;
	SmallVector<Loop*,3>		dimension_loops;
	int 		num_neighbors;
	Value*		input;
	Value*		output;
	std::vector<Neighbor> neighbors;
	std::vector<Value*> arguments;
	
	StencilInfo() {
		dimension = 0;
		num_neighbors = 0;
	}
  };
  //===---------------------------------------------------------------------===

  // Function being analysed.
  Function *CurrentFn;
  
  
  std::multimap<Function*, StencilInfo> StencilData;


  Value* getPointerOperand (Instruction *Ins);
  void populateArrayExpression (ArrayExpression *ArrayExp, Value *Val);
  bool populateArrayAccess (Value *Val, ArrayAccess *acc);
  void traverseArrayExpression( ArrayExpression *ArrayExp, Value *Val);
  void showArrayExpression (ArrayExpression *ArrayExp, Value *Val);
  void showArrayAccess(ArrayAccess arrayAcc);
  bool containsOpCode (Value *Val, unsigned opCode);

/*
  bool matchInstruction (Value *Val, unsigned opCode);
  bool parse_load (Value *Val, Neighbor *neighbor);
  bool parse_gep (Value *Val, const SCEV *ElementSize, Neighbor *neighbor);
  bool parse_idxprom (Value *Val, Neighbor *neighbor);
  bool parse_start (Value *Val, Neighbor *neighbor);
  bool parse_xoffset (Value *Val, Neighbor *neighbor);
  bool parse_xoffset_add (Value *Val, int sign, Neighbor *neighbor);
  bool parse_yoffset (Value *Val, Neighbor *neighbor);
  bool parse_yoffset_add (Value *Val, int sign, Neighbor *neighbor);
  bool parse_yoffset_mul (Value *Val, Neighbor *neighbor);
  bool parse_yoffset_stride (Value *Val, Neighbor *neighbor);
*/  
  void buildRange (Loop *loop);
  void printLoopDetails (Loop *loop);
  void printNeighbors (StencilInfo *Stencil);
  void printPtrRangeAnalysis(Loop *loop);
  
  bool verifyStencil();
  bool verifyIterationLoop (Loop *loop, StencilInfo *Stencil);
  bool verifyComputationLoops (Loop *loop, unsigned int dimension, StencilInfo *Stencil);
  bool verifySwapLoops (Loop *loop, unsigned int dimension, StencilInfo *Stencil);
  bool verifyStore (Loop* loop, StencilInfo *Stencil);
  bool verifySwap (Loop* loop, StencilInfo *Stencil);
  PHINode* getPHINode (const Loop *loop);
  bool matchStencilNeighborhood(Neighbor &Str, Neighbor &N);
  
  Value* visit(const SCEV *S);
  Value* visitAddExpr(const SCEVAddExpr *S);
  Value* visitSMaxExpr(const SCEVSMaxExpr *S);
  Value* visitUMaxExpr(const SCEVUMaxExpr *S);
  Value* visitUnknown(const SCEVUnknown *S);
  
  void showRange(Loop *loop);

  void printSCEV(const SCEV *S, const SCEV *E);

  template<typename T>
  void printNAryExpr(T *S, const SCEV *E);

  template<typename T>
  void printCastExpr(T *S, const SCEV *E);

  void printAddRecExpr(const SCEVAddRecExpr *S, const SCEV *E);
  bool delinearize(const SCEV *S, const SCEV *E, Neighbor &N);
  bool parse1DSCEV(const SCEVAddRecExpr *S, const SCEV *E, Neighbor &N);
  bool parse2DSCEV(const SCEV *S, Neighbor &N);
  bool parse3DSCEV(const SCEV *S, Neighbor &N);
  
  ScalarEvolution *SE;
  LoopInfo *LI;
  PtrRangeAnalysis *ptrRA;
  RegionInfoPass *RP;
  AliasAnalysis *AA;
  DominatorTree *DT;
  
  //RecoverNames *rn;
  //RegionReconstructor *rr;
  //ScopeTree *st;
 
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
};

//===------------------------ Stencil.h --------------------------===//
