#include "Stencil.h"

using namespace llvm;
using namespace lge;



class CodeGen : public FunctionPass {
private:
	Stencil *SA;
	
	std::string idx_x, idx_y, idx_z;
	std::string dim_x, dim_y, dim_z;
	
	void writeType(llvm::Type *T, raw_fd_ostream &OS);
	void writeKernel(llvm::raw_fd_ostream &OS, Stencil::StencilInfo &Stencil);
	void writeExpression(raw_fd_ostream &OS, Value *Val);
	void writeComputation(llvm::raw_fd_ostream &OS, Stencil::StencilInfo &Stencil);
	void writeMemAccess(llvm::raw_fd_ostream &OS, Stencil::StencilInfo &Stencil);
	void writeThreadIndex(llvm::raw_fd_ostream &OS, Stencil::StencilInfo &Stencil);
	
public:
	
	static char ID;
	CodeGen() : FunctionPass(ID) {};
  
	virtual bool runOnFunction(Function &F) override;

	virtual void getAnalysisUsage(AnalysisUsage &AU) const {
	  AU.addRequired<Stencil>();
	  AU.setPreservesAll();
	}  
};


