//===--------------------------------- CodeGen.cpp ------------------------===//
//
// This file is distributed under the XXX license.
// See LICENSE.TXT for details.
//
// Copyright (C) 2017   Alyson Deives Pereira
//
//===----------------------------------------------------------------------===//
//
// CodeGen is an optimization that generates CUDA code based on stencil information
// from the Stencil function pass
//
//===----------------------------------------------------------------------===//

#include "llvm/IR/Instruction.h"
#include "llvm/IR/Value.h"

#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/ToolOutputFile.h"

#include "CodeGen.h"
#include <map>

using namespace llvm;
using namespace std;
using namespace lge;


bool CodeGen::runOnFunction(Function &F) {
	this->SA = &getAnalysis<Stencil>();
	
	std::pair <std::multimap<Function*,Stencil::StencilInfo>::iterator, std::multimap<Function*,Stencil::StencilInfo>::iterator> ret;
	
	/* Navigate through all stencils
	ret = SA->StencilData.equal_range(&F);
	
	for (auto it=ret.first; it!=ret.second; ++it){
		errs()<<"Input: "<<*it->second.input<<"\n";
		errs()<<"Output: "<<*it->second.output<<"\n";
		write(it->second);
	}
	*/
	
	auto it = SA->StencilData.find(&F);
	if(it != SA->StencilData.end()){
		Stencil::StencilInfo Stencil = it->second;
	
	
		std::error_code EC;
		std::unique_ptr<llvm::tool_output_file> Out;
	
		Out = llvm::make_unique<llvm::tool_output_file>(F.getName(), EC, sys::fs::F_None);
	
		
		writeKernel(Out->os(),Stencil);
		
	
		Out->keep();
	}
	return false;
}

void CodeGen::writeType(Type *T, raw_fd_ostream &OS){
	 errs()<<"TypeID: "<<T->getTypeID()<<"\n";
	 switch (T->getTypeID()) {
     case Type::FloatTyID:  
		OS << "float"; 
		return;
     case Type::DoubleTyID: 
		OS << "double"; 
		return;
     case Type::IntegerTyID: 	   
		OS << "int"; 
		return;
     case Type::PointerTyID:
		writeType(T->getPointerElementType(), OS);
		OS << "* ";
		return;
     default: 
		OS << "void"; 
		return;
 }
}	
    
void CodeGen::writeThreadIndex(raw_fd_ostream &OS, Stencil::StencilInfo &Stencil){
	//Thread Idx
	/*OS <<"int tx = threadIdx.x;\n";
	OS <<"int ty = threadIdx.y;\n";
	OS <<"int tz = threadIdx.z;\n";
	
	//Block idx
	OS <<"int bx = BlockIdx.x;\n";
	OS <<"int by = BlockIdx.y;\n";
	OS <<"int bz = BlockIdx.z;\n";
	
	//Grid Dim
	OS <<"int GridDim_x = GridDim.x;\n";
	OS <<"int GridDim_y = GridDim.y;\n";
	OS <<"int GridDim_z = GridDim.z;\n";
	
	//Block Dim
	OS <<"int BlockDim_x = BlockDim.x;\n";
	OS <<"int BlockDim_y = BlockDim.y;\n";
	OS <<"int BlockDim_z = BlockDim.z;\n";
	*/
	//Offsets
	size_t lastindex;
	
	lastindex = Stencil.dimension_phinode[0]->getName().str().find_last_of(".");
	idx_z = Stencil.dimension_phinode[0]->getName().str().substr(0,lastindex);
	OS <<"int "<<idx_z<<" = BlockIdx.z * BlockDim.z + threadIdx.z;\n";
	
	lastindex = Stencil.dimension_phinode[1]->getName().str().find_last_of(".");
	idx_x = Stencil.dimension_phinode[1]->getName().str().substr(0,lastindex);
	OS <<"int "<<idx_x<<" = BlockIdx.x * BlockDim.x + threadIdx.x;\n";
	
	lastindex = Stencil.dimension_phinode[2]->getName().str().find_last_of(".");
	idx_y  = Stencil.dimension_phinode[2]->getName().str().substr(0,lastindex);
	OS <<"int "<<idx_y<<" = BlockIdx.y * BlockDim.y + threadIdx.y;\n";
	
	dim_z = Stencil.dimension_value[0]->getName();
	dim_x = Stencil.dimension_value[1]->getName();
	dim_y = Stencil.dimension_value[2]->getName();
	
}

void CodeGen::writeMemAccess(raw_fd_ostream &OS, Stencil::StencilInfo &Stencil){
	for(auto i : Stencil.neighbors){
		//GetElementPtrInst *GEP = dyn_cast<GetElementPtrInst>(i->LoadAccess->getPointerOperand());
		//Value *Val = dyn_cast<Value>(i.LoadAccess);
		//Val->getType()->dump();
		writeType(i.LoadAccess->getType(), OS);
		OS << " " << i.LoadAccess->getName() <<" = ";
		OS << i.BasePtr->getName() << "[ ";
		OS << "(" << idx_z << " + ("<< i.offset_z <<"))" << " * "<< dim_x <<" * " << dim_y << " + ";
		OS << "(" << idx_y << " + ("<< i.offset_y <<"))" << " * "<< dim_x <<" + ";
		OS << "(" << idx_x << " + ("<< i.offset_x <<"))" << " ];\n";
	}
	//OS << "[k * ni * nj + j * dimx + i;
}

void CodeGen::writeExpression(raw_fd_ostream &OS, Value *Val){
	
	if((isa<LoadInst>(Val))){
		LoadInst *LD = dyn_cast<LoadInst>(Val);
		OS << LD->getName();
	}
	else if(isa<ConstantInt>(Val)){
		OS << "CONSTANTINT";
	}
	else if(isa<ConstantFP>(Val)){
		OS << "CONSTANTFP";
	}
	else if((isa<Instruction>(Val))){
		Instruction *Ins = dyn_cast<Instruction>(Val);
		OS << "(";
		writeExpression(OS, Ins->getOperand(0));
		switch (Ins->getOpcode()){
			case Instruction::Add: 
			case Instruction::FAdd: OS << " + "; break;
			case Instruction::Sub:
			case Instruction::FSub: OS << " - "; break;
			case Instruction::Mul:
			case Instruction::FMul: OS << " * "; break;
			case Instruction::UDiv:
			case Instruction::FDiv:
			case Instruction::SDiv: OS << " / "; break;
			default: OS << "Opcode:"<<Ins->getOpcodeName(); break;
		}
		writeExpression(OS, Ins->getOperand(1));
		OS << ")";
	}
	else{
		OS <<"UNKNOWN OPERATOR";
	}
}

void CodeGen::writeComputation(raw_fd_ostream &OS, Stencil::StencilInfo &Stencil){
	OS << Stencil.output->getName() << "[ ";
	OS << "(" << idx_z << " * "<< dim_x <<" * " << dim_y << " + ";
	OS << "(" << idx_y << " * "<< dim_x <<" + ";
	OS << "(" << idx_x << ") ] = ( ";
	
	writeExpression(OS, Stencil.outputStr->getValueOperand());
	
	OS <<" );\n";
}

void CodeGen::writeKernel(raw_fd_ostream &OS, Stencil::StencilInfo &Stencil){
	OS << "__global__\n";
	OS << "void kernel (";
	
	errs()<<"Input: "<<Stencil.input->getName()<<"\n";
	writeType(Stencil.input->getType(), OS);
	OS <<  " " << Stencil.input->getName() <<", ";
	
	writeType(Stencil.output->getType(), OS);
	OS <<  " " << Stencil.output->getName();

	for(auto i : Stencil.arguments){
		OS << ", ";
		errs()<<"Argument: "<<*i<<"\n";
		writeType(i->getType(), OS);
		OS <<  " " << i->getName();
	}
	
	for(auto i : Stencil.dimension_value){
		errs()<<"Dimension: "<<*i<<"\n";
		OS << ", ";
		writeType(i->getType(), OS);
		OS <<  " " << i->getName();
	}
	
	OS << ") {\n";
	
	writeThreadIndex(OS, Stencil);
	
	writeMemAccess(OS, Stencil);
	
	writeComputation(OS, Stencil);
	
	OS << "}\n";
}

char CodeGen::ID = 0;
static RegisterPass<CodeGen> Z("cuda", "Write cuda stencil code");
