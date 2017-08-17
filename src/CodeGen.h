#include "Stencil.h"

using namespace llvm;
using namespace lge;



class CodeGen : public FunctionPass {
private:
	Stencil *SA;
	Function *CurrentFn;
	
    int block_dim_x, block_dim_y, block_dim_z;

	std::string idx_x, idx_y, idx_z; //Data element dimension indexes
	std::string dim_x, dim_y, dim_z; //Data dimensions
	void writeHeader(raw_fd_ostream &OS, Stencil::StencilInfo &Stencil);
	void writeType(llvm::Type *T, raw_fd_ostream &OS);
	void writeKernelBaseline(llvm::raw_fd_ostream &OS, Stencil::StencilInfo &Stencil);
    void writeKernelCall(llvm::raw_fd_ostream &OS, Stencil::StencilInfo &Stencil);
	void writeGlobalKernelParams(llvm::raw_fd_ostream &OS, Stencil::StencilInfo &Stencil);
	void writeExpression(raw_fd_ostream &OS, Value *Val, Stencil::StencilInfo &Stencil);
	void writeComputation(llvm::raw_fd_ostream &OS, Stencil::StencilInfo &Stencil);
	void writeMemAccess(llvm::raw_fd_ostream &OS, Stencil::StencilInfo &Stencil);
	void writeThreadIndex(llvm::raw_fd_ostream &OS, Stencil::StencilInfo &Stencil);
	
	void writeKernelOptimized(llvm::raw_fd_ostream &OS, Stencil::StencilInfo &Stencil);
	void writeKernelCallOptimized(llvm::raw_fd_ostream &OS, Stencil::StencilInfo &Stencil);
	void writeThreadIndexOptimized(llvm::raw_fd_ostream &OS, Stencil::StencilInfo &Stencil);
	void writeLoadHaloOptimized(llvm::raw_fd_ostream &OS, Stencil::StencilInfo &Stencil);
	void writeExpressionOptimized(llvm::raw_fd_ostream &OS, Value *Val, Stencil::StencilInfo &Stencil, int timestep);
	void writeComputeOptimized(llvm::raw_fd_ostream &OS, Stencil::StencilInfo &Stencil);
	
	Value *getPointerOperand(Value *V);
	
public:
	
	static char ID;
	CodeGen() : FunctionPass(ID), block_dim_x(32),block_dim_y(16),block_dim_z(1) {};
  
	virtual bool runOnFunction(Function &F) override;

	virtual void getAnalysisUsage(AnalysisUsage &AU) const {
	  AU.addRequired<Stencil>();
	  AU.setPreservesAll();
	}  
};
