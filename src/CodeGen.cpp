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

#include "llvm/ADT/SmallVector.h"

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

Value *CodeGen::getPointerOperand(Value *Val){
	Value *V = Val;
	while(isa<LoadInst>(V) && isa <StoreInst>(V) && isa<GetElementPtrInst>(V)){
		if (LoadInst *Load = dyn_cast<LoadInst>(Val))
			V =  Load->getPointerOperand();
		else if (StoreInst *Store = dyn_cast<StoreInst>(V))
			V =  Store->getPointerOperand();
		else if (GetElementPtrInst *GEP = dyn_cast<GetElementPtrInst>(V))
			V = GEP->getPointerOperand();
	}
	return V;
}


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
		CurrentFn = &F;
	
		std::error_code EC;
		std::unique_ptr<llvm::tool_output_file> Out;

        std::string Filename = F.getName();
        Filename.append(".cuh");
        
		Out = llvm::make_unique<llvm::tool_output_file>(Filename, EC, sys::fs::F_None);

		writeHeader(Out->os(), Stencil);
		writeKernelBaseline(Out->os(),Stencil);
		writeKernelOptimized(Out->os(),Stencil);
		Out->keep();
	}
	return false;
}

void CodeGen::writeHeader(raw_fd_ostream &OS, Stencil::StencilInfo &Stencil){
	OS << "#define BLOCK_DIMX " << this->block_dim_x << "\n";
    OS << "#define BLOCK_DIMY " << this->block_dim_y << "\n";
    OS << "#define BLOCK_DIMZ " << this->block_dim_z << "\n";
    OS << "#define RADIUS " << Stencil.radius << "\n\n";
    
    OS << "// Error checking function\n";
	OS << "#define wbCheck(stmt) do {                                                    \\"<<"\n";
    OS << "cudaError_t err = stmt;                                               \\"<<"\n";
    OS << "if (err != cudaSuccess) {                                             \\"<<"\n";
    OS << "        printf(\"ERROR: Failed to run stmt %s\\n\", #stmt);                       \\"<<"\n";
    OS << "        printf(\"ERROR: Got CUDA error ...  %s\\n\", cudaGetErrorString(err));    \\"<<"\n";
    OS << "        return -1;                                                        \\"<<"\n";
    OS << "    }                                                                     \\"<<"\n";
    OS << "} while(0)\n\n";
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
  
void CodeGen::writeThreadIndexOptimized(raw_fd_ostream &OS, Stencil::StencilInfo &Stencil){
	size_t lastindex;
	
	OS << "__shared__ ";
	writeType(Stencil.outputStr->getValueOperand()->getType(), OS);
	OS << " ds_a[BLOCK_DIMY][BLOCK_DIMX];\n";
	
	// The optimized version has z-blocking
	//lastindex = Stencil.dimension_phinode[0]->getName().str().find_last_of(".");
	//idx_z = Stencil.dimension_phinode[0]->getName().str().substr(0,lastindex);
	//OS <<"int "<<idx_z<<" = blockIdx.z * blockDim.z + threadIdx.z;\n";
	
	lastindex = Stencil.dimension_phinode[1]->getName().str().find_last_of(".");
	idx_y  = Stencil.dimension_phinode[1]->getName().str().substr(0,lastindex);
	OS <<"int "<<idx_y<<" = blockIdx.y * (blockDim.y-2*RADIUS) + threadIdx.y + RADIUS;\n";
	
	lastindex = Stencil.dimension_phinode[2]->getName().str().find_last_of(".");
	idx_x = Stencil.dimension_phinode[2]->getName().str().substr(0,lastindex);
	OS <<"int "<<idx_x<<" = blockIdx.x * (blockDim.x-2*RADIUS) + threadIdx.x + RADIUS;\n";
	
	dim_z = Stencil.dimension_value[0]->getName();
	dim_y = Stencil.dimension_value[1]->getName();
	dim_x = Stencil.dimension_value[2]->getName();
	
	OS << "int in_index = " << idx_y << " * " << dim_x << " + " << idx_x << ";\n";
	OS << "int out_index = 0;\n";
	OS << "int next_index = 0;\n";
	
	OS << "int stride = " << dim_x << " * " << dim_y << ";\n";
}
    
void CodeGen::writeThreadIndex(raw_fd_ostream &OS, Stencil::StencilInfo &Stencil){
	//Offsets
	size_t lastindex;
	
	lastindex = Stencil.dimension_phinode[0]->getName().str().find_last_of(".");
	idx_z = Stencil.dimension_phinode[0]->getName().str().substr(0,lastindex);
	OS <<"int "<<idx_z<<" = blockIdx.z * blockDim.z + threadIdx.z;\n";
	
	lastindex = Stencil.dimension_phinode[1]->getName().str().find_last_of(".");
	idx_y  = Stencil.dimension_phinode[1]->getName().str().substr(0,lastindex);
	OS <<"int "<<idx_y<<" = blockIdx.y * blockDim.y + threadIdx.y;\n";
	
	lastindex = Stencil.dimension_phinode[2]->getName().str().find_last_of(".");
	idx_x = Stencil.dimension_phinode[2]->getName().str().substr(0,lastindex);
	OS <<"int "<<idx_x<<" = blockIdx.x * blockDim.x + threadIdx.x;\n";
	
	dim_z = Stencil.dimension_value[0]->getName();
	dim_y = Stencil.dimension_value[1]->getName();
	dim_x = Stencil.dimension_value[2]->getName();
}

void CodeGen::writeLoadHaloOptimized(raw_fd_ostream &OS, Stencil::StencilInfo &Stencil){
	// We perform two inner timesteps. We consider the radius is equals to the z_range;
	// t0 = t + 0
	// t1 = t + 1
	for(int i = Stencil.radius; i > 0; i--){
		OS << "register float t0_infront" << i <<";\n";
		OS << "register float t1_infront" << i <<";\n";
		OS << "register float t0_behind" << i <<";\n";
		OS << "register float t1_behind" << i <<";\n";
	}
	
	OS << "register float t0_current;\n";
	OS << "register float t1_current;\n";
	
	//Load Ghost Zones
	OS << "in_index += RADIUS*stride;\n";
	
	for(int i = Stencil.radius; i > 0; i--){
		OS << "t0_behind" << i << " = __ldg(&" << Stencil.input->getName() << "[in_index]);\n";
		OS << "in_index += stride;\n";
	}
	
	OS << "out_index = in_index;\n";
	//TODO Why this condition exist?
	if(Stencil.radius == 1)
		OS << "next_index = in_index;\n";
	
	OS << "t0_current = __ldg(&" << Stencil.input->getName() <<"[in_index]);\n";
	OS << "in_index += stride;\n";
	if(Stencil.radius > 1)
		OS << "next_index = in_index;\n";
	
	for(int i = 1; i <= Stencil.radius; i++){
		OS << "t0_infront" << i << " = __ldg(&" << Stencil.input->getName() << "[in_index]);\n";
		OS << "in_index += stride;\n";
	}
}

void CodeGen::writeComputeOptimized(raw_fd_ostream &OS, Stencil::StencilInfo &Stencil){
	// Compute t1_current
	// Compute stencil for Z = 0 (t + 1) but exclude ghost zones
	OS << "if (";
	OS << "(" << idx_y << " >= 2*RADIUS) && ";
	OS << "(" << idx_y << " < (" << dim_y << "-2*RADIUS)) && ";
	OS << "(" << idx_x << " >= 2*RADIUS) && ";
	OS << "(" << idx_x << " < (" << dim_x << "-2*RADIUS)) ";
	OS << ") {\n";
	OS << "t1_current = (";
	writeExpressionOptimized(OS,Stencil.outputStr->getValueOperand(), Stencil, 0); 
	OS << ");\n";
	
	OS << "} else {\n";
    OS << "t1_current = t0_current;\n";
    OS << "}\n";
	
	// Copy planes Z = -1 to -R to registers in t+1 (ghost zones, keep values in 0.0)
	for (int i = Stencil.radius; i > 0; i--){
		OS << "t1_behind" << i <<" = t0_behind" << i <<";\n";
	}
	
	
	//Compute each t1_infront
	for(int i = 1; i < Stencil.radius; i++){
		for (int i = Stencil.radius; i > 1; i--){
		OS << "t0_behind" << i <<" = t0_behind" << i-1 <<";\n";
		}
		OS << "t0_behind1 = t0_current;\n";
		OS << "t0_current = t0_infront1;\n";
		
		for (int i = 1; i < Stencil.radius; i++){
			OS << "t0_infront" << i <<" = t0_infront" << i+1 <<";\n";
		}
		OS << "t0_infront" << Stencil.radius << " = __ldg(&" << Stencil.input->getName() <<"[in_index]);\n";
		OS << "in_index += stride;\n";
		if(i>1){
			OS << "next_index += stride;\n";
		}
		
		OS << "if (";
		OS << "(" << idx_y << " >= 2*RADIUS) && ";
		OS << "(" << idx_y << " < (" << dim_y << "-2*RADIUS)) && ";
		OS << "(" << idx_x << " >= 2*RADIUS) && ";
		OS << "(" << idx_x << " < (" << dim_x << "-2*RADIUS)) &&";
		OS << "(" << dim_z << " > (4*RADIUS+1)) &&";
		OS << ") {\n";
		OS << "t1_infront" << i << " = (";
		writeExpressionOptimized(OS,Stencil.outputStr->getValueOperand(), Stencil, 0); 
		OS << ");\n";
		
		OS << "} else {\n";
		OS << "t1_infront" << i <<" = t0_current;\n";
		OS << "}\n\n";
	}
	
	//Iterate over Z
	OS << "for (int i = 0; i < " << dim_z << "-(4*RADIUS); i++) {\n";
	// Load Z = (2R+i) to registers
	for (int i = Stencil.radius; i > 1; i--){
		OS << "t0_behind" << i <<" = t0_behind" << i-1 <<";\n";
	}
	OS << "t0_behind1 = t0_current;\n";
	OS << "t0_current = t0_infront1\n;";
	for (int i = 1; i < Stencil.radius; i++){
		OS << "t0_infront" << i <<" = t0_infront" << i+1 <<";\n";
	}
	OS << "t0_infront" << Stencil.radius << " = __ldg(&" << Stencil.input->getName() <<"[in_index]);\n";
	OS << "in_index += stride;\n";
	OS << "next_index += stride;\n";
	
	// Compute stencil for Z = R+i (t + 1) but exclude ghost zones
	OS << "if (";
	OS << "(" << idx_y << " >= 2*RADIUS) && ";
	OS << "(" << idx_y << " < (" << dim_y << "-2*RADIUS)) && ";
	OS << "(" << idx_x << " >= 2*RADIUS) && ";
	OS << "(" << idx_x << " < (" << dim_x << "-2*RADIUS)) && ";
	OS << "(i < ("<< dim_z << "-5*RADIUS))";
	OS << ") {\n";
	OS << "t1_infront" << Stencil.radius <<" = (";
	writeExpressionOptimized(OS,Stencil.outputStr->getValueOperand(), Stencil, 0); 
	OS << ");\n";
    OS << "} else {\n";
    OS << "t1_infront" << Stencil.radius << " = t0_current;\n";
    OS << "}\n";
    
    // Load Z = k (t + 1) to shared memory
    OS << "__syncthreads();\n";
    OS << "ds_a[threadIdx.y][threadIdx.x] = t1_current;\n";
    OS << "__syncthreads();\n";
    
    // Compute stencil for Z = k (t + 2) but exclude halo zones
    OS << "if (";
    OS << "(threadIdx.y >= RADIUS) && ";
    OS << "(threadIdx.y < (BLOCK_DIMY-RADIUS)) && ";
    OS << "(threadIdx.x >= RADIUS) && ";
    OS << "(threadIdx.x < (BLOCK_DIMX-RADIUS)) ";
    OS << ") {";
    
    OS << Stencil.output->getName() << "[out_index] = (";
    writeExpressionOptimized(OS,Stencil.outputStr->getValueOperand(), Stencil, 1); 
    OS << ");\n";
    
    OS << "}\n";
    
    OS << "}\n";	
}

// TODO deal with arguments in LD inst
void CodeGen::writeExpressionOptimized(raw_fd_ostream &OS, Value *Val, Stencil::StencilInfo &Stencil, int timestep){	
	if((isa<LoadInst>(Val))){
		LoadInst *LD = dyn_cast<LoadInst>(Val);
		errs() << "Current: "<<*LD<<"\n";
		//Value *Ptr = getPointerOperand(Val);
		//get the neighbor with this LD
		Stencil::Neighbor N;
		for(auto i : Stencil.neighbors){
			errs() << "Checking: "<<*(i.LoadAccess)<<"\n";
			if (i.LoadAccess == LD){
				N = i;
				errs()<<*LD<<"\n";
				break;
			}
		}
		if (N.offset_z == 0){
			if(N.offset_x == 0 && N.offset_y == 0){
				OS << "t" << timestep <<"_current";
			}
			else{
				if(timestep == 0){
					OS << "__ldg(&" << N.BasePtr->getName();
					OS << "[out_index + ("<< N.offset_x << ") + (" << dim_y << " * ("<< N.offset_y <<"))])";
				}
				else if(timestep == 1){
					OS << "ds_a[threadIdx.y+(" << N.offset_y << ")][threadIdx.x+(" << N.offset_x << ")]";
				}
				else {
					OS << "ERROR";
					errs() <<"ERROR! Unexpected timestep value: "<< timestep <<"\n";
				}
			}
		}
		else if (N.offset_z < 0){
			OS << "t" << timestep << "_behind" << abs(N.offset_z);
		}
		else {
			OS << "t" << timestep << "_infront" << abs(N.offset_z);
		}
	}
	else if(isa<ConstantInt>(Val)){
        errs() << "CONSTANTINT";
        OS << (dyn_cast<ConstantInt>(Val))->getSExtValue();
        errs()<<"\n";
	}
	else if(isa<ConstantFP>(Val)){
		errs() << "CONSTANTFP";
        const APFloat FP = (dyn_cast<ConstantFP>(Val))->getValueAPF();
        SmallVector<char,256> Str;
        FP.toString(Str);
        errs()<<"FP: ";
        for(auto c : Str){
            errs()<<c;
            OS << c;
        }
        errs()<<"\n";
	}
	else if((isa<Instruction>(Val))){
		Instruction *Ins = dyn_cast<Instruction>(Val);
		OS << "(";
		writeExpressionOptimized(OS, Ins->getOperand(0),Stencil,timestep);
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
		writeExpressionOptimized(OS, Ins->getOperand(1),Stencil,timestep);
		OS << ")";
	}
	else{
		OS <<"UNKNOWN OPERATOR";
	}
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
        errs() << "CONSTANTINT";
        OS << (dyn_cast<ConstantInt>(Val))->getSExtValue();
        errs()<<"\n";
	}
	else if(isa<ConstantFP>(Val)){
		errs() << "CONSTANTFP";
        const APFloat FP = (dyn_cast<ConstantFP>(Val))->getValueAPF();
        SmallVector<char,256> Str;
        FP.toString(Str);
        errs()<<"FP: ";
        for(auto c : Str){
            errs()<<c;
            OS << c;
        }
        errs()<<"\n";
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
	OS << "(" << idx_z << " * "<< dim_x <<" * " << dim_y << ") + ";
	OS << "(" << idx_y << " * "<< dim_x <<") + ";
	OS << "(" << idx_x << ") ] = ( ";
	
	writeExpression(OS, Stencil.outputStr->getValueOperand());
	
	OS <<" );\n";
}

void CodeGen::writeGlobalKernelParams(raw_fd_ostream &OS, Stencil::StencilInfo &Stencil){
    if(!(isa<ConstantInt>(Stencil.iteration_value))){
        writeType(Stencil.iteration_value->getType(), OS);
        OS << " " << Stencil.iteration_value->getName() << ", ";
    }
	
	for(auto i : Stencil.dimension_value){
		errs()<<"Dimension: "<<*i<<"\n";
		writeType(i->getType(), OS);
		OS <<  " " << i->getName() << ", ";
	}

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
}

void CodeGen::writeKernelCall(raw_fd_ostream &OS, Stencil::StencilInfo &Stencil){
	OS << "\nint " << CurrentFn->getName() <<"_GPU_baseline (";
	
	if(!(isa<ConstantInt>(Stencil.iteration_value))){
        writeType(Stencil.iteration_value->getType(), OS);
        OS << " " << Stencil.iteration_value->getName() << ", ";
    }
	
	for(auto i : Stencil.dimension_value){
		writeType(i->getType(), OS);
		OS <<  " " << i->getName() << ", ";
	}

	writeType(Stencil.input->getType(), OS);
	OS <<  " " << Stencil.input->getName() <<", ";
	
	writeType(Stencil.output->getType(), OS);
	OS <<  " " << Stencil.output->getName();

	for(auto i : Stencil.arguments){
		OS << ", ";
		writeType(i->getType(), OS);
		OS <<  " " << i->getName();
	}
	
	OS << "){";

    //GPU Array Declaration
    writeType(Stencil.input->getType(), OS);
	OS <<  " " << Stencil.input->getName() <<"_GPU;\n";

    writeType(Stencil.output->getType(), OS);
	OS <<  " " << Stencil.output->getName()<<"_GPU;\n";

    for(auto i : Stencil.arguments){
		writeType(i->getType(), OS);
		OS <<  " " << i->getName()<<"_GPU;\n";
	}

    //Input Size
    OS << "size_t input_size = ";
    for(auto i : Stencil.dimension_value){
		OS << i->getName() << "*";
	}
    OS << "sizeof(";
    writeType(Stencil.outputStr->getValueOperand()->getType(), OS);
    OS << ");\n";

    //CUDA Malloc
    OS << "wbCheck( cudaMalloc((void**) &" << Stencil.input->getName() << "_GPU" << ", input_size) );\n";
    OS << "wbCheck( cudaMalloc((void**) &" << Stencil.output->getName() << "_GPU" << ", input_size) );\n";

    //TODO Arguments Malloc

    //CUDA MemCopy
    OS << "wbCheck( cudaMemcpy(" << Stencil.input->getName() << "_GPU," << Stencil.input->getName() << ", input_size, cudaMemcpyHostToDevice) );\n";
    OS << "wbCheck( cudaMemcpy(" << Stencil.output->getName() << "_GPU," << Stencil.output->getName() << ", input_size, cudaMemcpyHostToDevice) );\n";

    //DimBlock
    OS << "dim3 dimBlock;\n";
    OS << "dim3 dimGrid;\n";
    OS << "dimBlock.x = BLOCK_DIMX;\n";
    OS << "dimBlock.y = BLOCK_DIMY;\n";
    OS << "dimBlock.z = BLOCK_DIMZ;\n";
    OS << "dimGrid.x = (int)ceil("<< dim_x << "/BLOCK_DIMX);\n";
    OS << "dimGrid.y = (int)ceil("<< dim_y << "/BLOCK_DIMY);\n";
    OS << "dimGrid.z = (int)ceil("<< dim_z << "/BLOCK_DIMZ);\n";


    //TODO Iteration Value for single stencil
    OS << "for (int i = 0; i < ";
    if(isa<ConstantInt>(Stencil.iteration_value)){
        OS << dyn_cast<ConstantInt>(Stencil.iteration_value)->getSExtValue();
    }
    else {
        OS << Stencil.iteration_value->getName();
    }
    OS << "; i++) {\n";
    OS << "if (i%2) {\n";
    OS << CurrentFn->getName() << "_kernel_baseline <<< dimGrid,dimBlock >>> (";
    if(!(isa<ConstantInt>(Stencil.iteration_value))){
		OS << Stencil.iteration_value->getName();
	}
    
    for(auto i : Stencil.dimension_value){
		OS << ", " << i->getName();
	}
	
	OS << ", " << Stencil.output->getName() << "_GPU, ";
    OS << Stencil.input->getName() << "_GPU";

    for(auto i : Stencil.arguments){
		OS << ", "<< i->getName();
	}
	
	OS << ");\n";
    OS <<"}\nelse{\n";
    OS << CurrentFn->getName() << "_kernel_baseline <<< dimGrid,dimBlock >>> (";
    if(!(isa<ConstantInt>(Stencil.iteration_value))){
		OS << Stencil.iteration_value->getName();
	}
	
	for(auto i : Stencil.dimension_value){
		OS << ", " << i->getName();
	}
	
	OS << ", " << Stencil.input->getName() << "_GPU, ";
    OS << Stencil.output->getName() << "_GPU";
	
	for(auto i : Stencil.arguments){
		OS << ", "<< i->getName();
	}
	
	OS << ");\n";
    OS << "}\n";
    OS << "wbCheck(cudaGetLastError())\n;";
    OS << "}\n";

    //CUDA MemCopy
    OS << "wbCheck( cudaMemcpy(" << Stencil.output->getName() << "," << Stencil.output->getName() << "_GPU, input_size, cudaMemcpyDeviceToHost) );\n";

    //CUDA Free
    OS << "wbCheck( cudaFree(" << Stencil.input->getName() << "_GPU) );";
    OS << "wbCheck( cudaFree(" << Stencil.output->getName() << "_GPU) );";

    for(auto i : Stencil.arguments){
		OS <<  "wbCheck( cudaFree(" << i->getName()<<"_GPU) );\n";
	}
    
    OS << "return 0;\n}\n";
}

void CodeGen::writeKernelBaseline(raw_fd_ostream &OS, Stencil::StencilInfo &Stencil){
    // Write Kernel
    OS << "__global__\n";
	OS << "void " << CurrentFn->getName() <<"_kernel_baseline (";
	writeGlobalKernelParams(OS, Stencil);
	OS << ")";
    OS << "{\n";
	writeThreadIndex(OS, Stencil);
	OS << "if( ";
	OS << "(" << idx_x << " > " << Stencil.radius <<") && ";
	OS << "(" << idx_y << " > " << Stencil.radius <<") && ";
	OS << "(" << idx_z << " > " << Stencil.radius <<") && ";
	OS << "(" << idx_x << " < " << "(" << dim_x << " - " << Stencil.radius <<")) && ";
	OS << "(" << idx_y << " < " << "(" << dim_y << " - " << Stencil.radius <<")) && ";
	OS << "(" << idx_z << " < " << "(" << dim_z << " - " << Stencil.radius <<")) ";
	OS << "){\n";
	writeMemAccess(OS, Stencil);
	writeComputation(OS, Stencil);
	OS << "}\n";
	OS << "}\n";

    //Write Kernel Function Call
    writeKernelCall(OS, Stencil);
}

void CodeGen::writeKernelOptimized(raw_fd_ostream &OS, Stencil::StencilInfo &Stencil){
	 OS << "__global__\n";
	OS << "void " << CurrentFn->getName() <<"_kernel_opt (";
	writeGlobalKernelParams(OS, Stencil);
	OS << ")";
    OS << "{\n";
	writeThreadIndexOptimized(OS, Stencil);
	writeLoadHaloOptimized(OS, Stencil);
	writeComputeOptimized(OS, Stencil);
	OS << "}\n";
	
	writeKernelCallOptimized(OS, Stencil);
}

void CodeGen::writeKernelCallOptimized(raw_fd_ostream &OS, Stencil::StencilInfo &Stencil){
	OS << "\nint " << CurrentFn->getName() <<"_GPU_opt (";
	
	if(!(isa<ConstantInt>(Stencil.iteration_value))){
        writeType(Stencil.iteration_value->getType(), OS);
        OS << " " << Stencil.iteration_value->getName() << ", ";
    }
	
	for(auto i : Stencil.dimension_value){
		writeType(i->getType(), OS);
		OS <<  " " << i->getName() << ", ";
	}

	writeType(Stencil.input->getType(), OS);
	OS <<  " " << Stencil.input->getName() <<", ";
	
	writeType(Stencil.output->getType(), OS);
	OS <<  " " << Stencil.output->getName();

	for(auto i : Stencil.arguments){
		OS << ", ";
		writeType(i->getType(), OS);
		OS <<  " " << i->getName();
	}
	
	OS << "){";

    //GPU Array Declaration
    writeType(Stencil.input->getType(), OS);
	OS <<  " " << Stencil.input->getName() <<"_GPU;\n";

    writeType(Stencil.output->getType(), OS);
	OS <<  " " << Stencil.output->getName()<<"_GPU;\n";

    for(auto i : Stencil.arguments){
		writeType(i->getType(), OS);
		OS <<  " " << i->getName()<<"_GPU;\n";
	}

    //Input Size
    OS << "size_t input_size = ";
    for(auto i : Stencil.dimension_value){
		OS << "(" << i->getName() << "+4*RADIUS)  *";
	}
    OS << "sizeof(";
    writeType(Stencil.outputStr->getValueOperand()->getType(), OS);
    OS << ");\n";

    //CUDA Malloc
    OS << "wbCheck( cudaMalloc((void**) &" << Stencil.input->getName() << "_GPU" << ", input_size) );\n";
    OS << "wbCheck( cudaMalloc((void**) &" << Stencil.output->getName() << "_GPU" << ", input_size) );\n";

    //TODO Arguments Malloc

	//TODO Input has no stride, how to deal with it?
    //CUDA MemCopy
    OS << "wbCheck( cudaMemcpy(" << Stencil.input->getName() << "_GPU," << Stencil.input->getName() << ", input_size, cudaMemcpyHostToDevice) );\n";
    OS << "wbCheck( cudaMemcpy(" << Stencil.output->getName() << "_GPU," << Stencil.output->getName() << ", input_size, cudaMemcpyHostToDevice) );\n";

    //DimBlock
    OS << "dim3 dimBlock;\n";
    OS << "dim3 dimGrid;\n";
    OS << "dimBlock.x = BLOCK_DIMX;\n";
    OS << "dimBlock.y = BLOCK_DIMY;\n";
    OS << "dimBlock.z = 1;\n";
    OS << "dimGrid.x = (int)ceil("<< dim_x << "/(BLOCK_DIMX-2*RADIUS));\n";
    OS << "dimGrid.y = (int)ceil("<< dim_y << "/(BLOCK_DIMY-2*RADIUS));\n";
    OS << "dimGrid.z = 1;\n";


    //TODO Iteration Value for single stencil
    OS << "for (int i = 0; i < (";
    if(isa<ConstantInt>(Stencil.iteration_value)){
        OS << dyn_cast<ConstantInt>(Stencil.iteration_value)->getSExtValue();
    }
    else {
        OS << Stencil.iteration_value->getName();
    }
    OS << "/2); i++) {\n";
    OS << "if (i%2) {\n";
    OS << CurrentFn->getName() << "_kernel_opt <<< dimGrid,dimBlock >>> (";
    if(!(isa<ConstantInt>(Stencil.iteration_value))){
		OS << Stencil.iteration_value->getName();
	}
    
    for(auto i : Stencil.dimension_value){
		OS << ", " << i->getName() << "+ 4*RADIUS";
	}
	
	OS << ", " << Stencil.output->getName() << "_GPU, ";
    OS << Stencil.input->getName() << "_GPU";

    for(auto i : Stencil.arguments){
		OS << ", "<< i->getName() << "+ 4*RADIUS";
	}
	
	OS << ");\n";
    OS <<"}\nelse{\n";
    OS << CurrentFn->getName() << "_kernel_opt <<< dimGrid,dimBlock >>> (";
    if(!(isa<ConstantInt>(Stencil.iteration_value))){
		OS << Stencil.iteration_value->getName();
	}
	
	for(auto i : Stencil.dimension_value){
		OS << ", " << i->getName() << "+ 4*RADIUS";
	}
	
	OS << ", " << Stencil.input->getName() << "_GPU, ";
    OS << Stencil.output->getName() << "_GPU";
	
	for(auto i : Stencil.arguments){
		OS << ", "<< i->getName();
	}
	
	OS << ");\n";
    OS << "}\n";
    OS << "wbCheck(cudaGetLastError())\n;";
    OS << "}\n";

    //CUDA MemCopy
    OS << "wbCheck( cudaMemcpy(" << Stencil.output->getName() << "," << Stencil.output->getName() << "_GPU, input_size, cudaMemcpyDeviceToHost) );\n";

    //CUDA Free
    OS << "wbCheck( cudaFree(" << Stencil.input->getName() << "_GPU) );";
    OS << "wbCheck( cudaFree(" << Stencil.output->getName() << "_GPU) );";

    for(auto i : Stencil.arguments){
		OS <<  "wbCheck( cudaFree(" << i->getName()<<"_GPU) );\n";
	}
    
    OS << "return 0;\n}\n";
}

char CodeGen::ID = 0;
static RegisterPass<CodeGen> Z("cuda", "Write cuda stencil code");
