; ModuleID = 'gemm.c'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, i8*, i8*, i8*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type { %struct._IO_marker*, %struct._IO_FILE*, i32 }
%struct.timezone = type { i32, i32 }
%struct.timeval = type { i64, i64 }

@.str = private unnamed_addr constant [35 x i8] c"Error return from gettimeofday: %d\00", align 1
@.str.1 = private unnamed_addr constant [74 x i8] c"Non-Matching CPU-GPU Outputs Beyond Error Threshold of %4.2f Percent: %d\0A\00", align 1
@stdout = external global %struct._IO_FILE*, align 8
@.str.2 = private unnamed_addr constant [42 x i8] c"<< Matrix-multiply C=alpha.A.B+beta.C >>\0A\00", align 1
@.str.3 = private unnamed_addr constant [22 x i8] c"CPU Runtime: %0.6lfs\0A\00", align 1

; Function Attrs: nounwind uwtable
define double @rtclock() #0 {
entry:
  %Tzp = alloca %struct.timezone, align 4
  %Tp = alloca %struct.timeval, align 8
  %stat = alloca i32, align 4
  %call = call i32 @gettimeofday(%struct.timeval* %Tp, %struct.timezone* %Tzp) #3
  store i32 %call, i32* %stat, align 4
  %0 = load i32, i32* %stat, align 4
  %cmp = icmp ne i32 %0, 0
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %1 = load i32, i32* %stat, align 4
  %call1 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([35 x i8], [35 x i8]* @.str, i32 0, i32 0), i32 %1)
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  %tv_sec = getelementptr inbounds %struct.timeval, %struct.timeval* %Tp, i32 0, i32 0
  %2 = load i64, i64* %tv_sec, align 8
  %conv = sitofp i64 %2 to double
  %tv_usec = getelementptr inbounds %struct.timeval, %struct.timeval* %Tp, i32 0, i32 1
  %3 = load i64, i64* %tv_usec, align 8
  %conv2 = sitofp i64 %3 to double
  %mul = fmul double %conv2, 1.000000e-06
  %add = fadd double %conv, %mul
  ret double %add
}

; Function Attrs: nounwind
declare i32 @gettimeofday(%struct.timeval*, %struct.timezone*) #1

declare i32 @printf(i8*, ...) #2

; Function Attrs: nounwind uwtable
define float @absVal(float %a) #0 {
entry:
  %retval = alloca float, align 4
  %a.addr = alloca float, align 4
  store float %a, float* %a.addr, align 4
  %0 = load float, float* %a.addr, align 4
  %cmp = fcmp olt float %0, 0.000000e+00
  br i1 %cmp, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  %1 = load float, float* %a.addr, align 4
  %mul = fmul float %1, -1.000000e+00
  store float %mul, float* %retval
  br label %return

if.else:                                          ; preds = %entry
  %2 = load float, float* %a.addr, align 4
  store float %2, float* %retval
  br label %return

return:                                           ; preds = %if.else, %if.then
  %3 = load float, float* %retval
  ret float %3
}

; Function Attrs: nounwind uwtable
define float @percentDiff(double %val1, double %val2) #0 {
entry:
  %retval = alloca float, align 4
  %val1.addr = alloca double, align 8
  %val2.addr = alloca double, align 8
  store double %val1, double* %val1.addr, align 8
  store double %val2, double* %val2.addr, align 8
  %0 = load double, double* %val1.addr, align 8
  %conv = fptrunc double %0 to float
  %call = call float @absVal(float %conv)
  %conv1 = fpext float %call to double
  %cmp = fcmp olt double %conv1, 1.000000e-02
  br i1 %cmp, label %land.lhs.true, label %if.else

land.lhs.true:                                    ; preds = %entry
  %1 = load double, double* %val2.addr, align 8
  %conv3 = fptrunc double %1 to float
  %call4 = call float @absVal(float %conv3)
  %conv5 = fpext float %call4 to double
  %cmp6 = fcmp olt double %conv5, 1.000000e-02
  br i1 %cmp6, label %if.then, label %if.else

if.then:                                          ; preds = %land.lhs.true
  store float 0.000000e+00, float* %retval
  br label %return

if.else:                                          ; preds = %land.lhs.true, %entry
  %2 = load double, double* %val1.addr, align 8
  %3 = load double, double* %val2.addr, align 8
  %sub = fsub double %2, %3
  %conv8 = fptrunc double %sub to float
  %call9 = call float @absVal(float %conv8)
  %4 = load double, double* %val1.addr, align 8
  %add = fadd double %4, 0x3E45798EE0000000
  %conv10 = fptrunc double %add to float
  %call11 = call float @absVal(float %conv10)
  %div = fdiv float %call9, %call11
  %call12 = call float @absVal(float %div)
  %mul = fmul float 1.000000e+02, %call12
  store float %mul, float* %retval
  br label %return

return:                                           ; preds = %if.else, %if.then
  %5 = load float, float* %retval
  ret float %5
}

; Function Attrs: nounwind uwtable
define void @gemm(i32 %ni, i32 %nj, i32 %nk, float* %A, float* %B, float* %C) #0 {
entry:
  %ni.addr = alloca i32, align 4
  %nj.addr = alloca i32, align 4
  %nk.addr = alloca i32, align 4
  %A.addr = alloca float*, align 8
  %B.addr = alloca float*, align 8
  %C.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %k = alloca i32, align 4
  store i32 %ni, i32* %ni.addr, align 4
  store i32 %nj, i32* %nj.addr, align 4
  store i32 %nk, i32* %nk.addr, align 4
  store float* %A, float** %A.addr, align 8
  store float* %B, float** %B.addr, align 8
  store float* %C, float** %C.addr, align 8
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.26, %entry
  %0 = load i32, i32* %i, align 4
  %1 = load i32, i32* %ni.addr, align 4
  %cmp = icmp slt i32 %0, %1
  br i1 %cmp, label %for.body, label %for.end.28

for.body:                                         ; preds = %for.cond
  store i32 0, i32* %j, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc.23, %for.body
  %2 = load i32, i32* %j, align 4
  %3 = load i32, i32* %nj.addr, align 4
  %cmp2 = icmp slt i32 %2, %3
  br i1 %cmp2, label %for.body.3, label %for.end.25

for.body.3:                                       ; preds = %for.cond.1
  %4 = load i32, i32* %i, align 4
  %mul = mul nsw i32 %4, 2048
  %5 = load i32, i32* %j, align 4
  %add = add nsw i32 %mul, %5
  %idxprom = sext i32 %add to i64
  %6 = load float*, float** %C.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %6, i64 %idxprom
  %7 = load float, float* %arrayidx, align 4
  %mul4 = fmul float %7, 2.123000e+03
  store float %mul4, float* %arrayidx, align 4
  store i32 0, i32* %k, align 4
  br label %for.cond.5

for.cond.5:                                       ; preds = %for.inc, %for.body.3
  %8 = load i32, i32* %k, align 4
  %9 = load i32, i32* %nk.addr, align 4
  %cmp6 = icmp slt i32 %8, %9
  br i1 %cmp6, label %for.body.7, label %for.end

for.body.7:                                       ; preds = %for.cond.5
  %10 = load i32, i32* %i, align 4
  %11 = load i32, i32* %nk.addr, align 4
  %mul8 = mul nsw i32 %10, %11
  %12 = load i32, i32* %k, align 4
  %add9 = add nsw i32 %mul8, %12
  %idxprom10 = sext i32 %add9 to i64
  %13 = load float*, float** %A.addr, align 8
  %arrayidx11 = getelementptr inbounds float, float* %13, i64 %idxprom10
  %14 = load float, float* %arrayidx11, align 4
  %mul12 = fmul float 3.241200e+04, %14
  %15 = load i32, i32* %k, align 4
  %16 = load i32, i32* %nj.addr, align 4
  %mul13 = mul nsw i32 %15, %16
  %17 = load i32, i32* %j, align 4
  %add14 = add nsw i32 %mul13, %17
  %idxprom15 = sext i32 %add14 to i64
  %18 = load float*, float** %B.addr, align 8
  %arrayidx16 = getelementptr inbounds float, float* %18, i64 %idxprom15
  %19 = load float, float* %arrayidx16, align 4
  %mul17 = fmul float %mul12, %19
  %20 = load i32, i32* %i, align 4
  %21 = load i32, i32* %nj.addr, align 4
  %mul18 = mul nsw i32 %20, %21
  %22 = load i32, i32* %j, align 4
  %add19 = add nsw i32 %mul18, %22
  %idxprom20 = sext i32 %add19 to i64
  %23 = load float*, float** %C.addr, align 8
  %arrayidx21 = getelementptr inbounds float, float* %23, i64 %idxprom20
  %24 = load float, float* %arrayidx21, align 4
  %add22 = fadd float %24, %mul17
  store float %add22, float* %arrayidx21, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.7
  %25 = load i32, i32* %k, align 4
  %inc = add nsw i32 %25, 1
  store i32 %inc, i32* %k, align 4
  br label %for.cond.5

for.end:                                          ; preds = %for.cond.5
  br label %for.inc.23

for.inc.23:                                       ; preds = %for.end
  %26 = load i32, i32* %j, align 4
  %inc24 = add nsw i32 %26, 1
  store i32 %inc24, i32* %j, align 4
  br label %for.cond.1

for.end.25:                                       ; preds = %for.cond.1
  br label %for.inc.26

for.inc.26:                                       ; preds = %for.end.25
  %27 = load i32, i32* %i, align 4
  %inc27 = add nsw i32 %27, 1
  store i32 %inc27, i32* %i, align 4
  br label %for.cond

for.end.28:                                       ; preds = %for.cond
  ret void
}

; Function Attrs: nounwind uwtable
define void @init(float* %A, float* %B, float* %C, float* %C_OMP) #0 {
entry:
  %A.addr = alloca float*, align 8
  %B.addr = alloca float*, align 8
  %C.addr = alloca float*, align 8
  %C_OMP.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  store float* %A, float** %A.addr, align 8
  store float* %B, float** %B.addr, align 8
  store float* %C, float** %C.addr, align 8
  store float* %C_OMP, float** %C_OMP.addr, align 8
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.6, %entry
  %0 = load i32, i32* %i, align 4
  %cmp = icmp slt i32 %0, 2048
  br i1 %cmp, label %for.body, label %for.end.8

for.body:                                         ; preds = %for.cond
  store i32 0, i32* %j, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %1 = load i32, i32* %j, align 4
  %cmp2 = icmp slt i32 %1, 2048
  br i1 %cmp2, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.cond.1
  %2 = load i32, i32* %i, align 4
  %conv = sitofp i32 %2 to float
  %3 = load i32, i32* %j, align 4
  %conv4 = sitofp i32 %3 to float
  %mul = fmul float %conv, %conv4
  %div = fdiv float %mul, 2.048000e+03
  %4 = load i32, i32* %i, align 4
  %mul5 = mul nsw i32 %4, 2048
  %5 = load i32, i32* %j, align 4
  %add = add nsw i32 %mul5, %5
  %idxprom = sext i32 %add to i64
  %6 = load float*, float** %A.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %6, i64 %idxprom
  store float %div, float* %arrayidx, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.3
  %7 = load i32, i32* %j, align 4
  %inc = add nsw i32 %7, 1
  store i32 %inc, i32* %j, align 4
  br label %for.cond.1

for.end:                                          ; preds = %for.cond.1
  br label %for.inc.6

for.inc.6:                                        ; preds = %for.end
  %8 = load i32, i32* %i, align 4
  %inc7 = add nsw i32 %8, 1
  store i32 %inc7, i32* %i, align 4
  br label %for.cond

for.end.8:                                        ; preds = %for.cond
  store i32 0, i32* %i, align 4
  br label %for.cond.9

for.cond.9:                                       ; preds = %for.inc.29, %for.end.8
  %9 = load i32, i32* %i, align 4
  %cmp10 = icmp slt i32 %9, 2048
  br i1 %cmp10, label %for.body.12, label %for.end.31

for.body.12:                                      ; preds = %for.cond.9
  store i32 0, i32* %j, align 4
  br label %for.cond.13

for.cond.13:                                      ; preds = %for.inc.26, %for.body.12
  %10 = load i32, i32* %j, align 4
  %cmp14 = icmp slt i32 %10, 2048
  br i1 %cmp14, label %for.body.16, label %for.end.28

for.body.16:                                      ; preds = %for.cond.13
  %11 = load i32, i32* %i, align 4
  %conv17 = sitofp i32 %11 to float
  %12 = load i32, i32* %j, align 4
  %conv18 = sitofp i32 %12 to float
  %mul19 = fmul float %conv17, %conv18
  %add20 = fadd float %mul19, 1.000000e+00
  %div21 = fdiv float %add20, 2.048000e+03
  %13 = load i32, i32* %i, align 4
  %mul22 = mul nsw i32 %13, 2048
  %14 = load i32, i32* %j, align 4
  %add23 = add nsw i32 %mul22, %14
  %idxprom24 = sext i32 %add23 to i64
  %15 = load float*, float** %B.addr, align 8
  %arrayidx25 = getelementptr inbounds float, float* %15, i64 %idxprom24
  store float %div21, float* %arrayidx25, align 4
  br label %for.inc.26

for.inc.26:                                       ; preds = %for.body.16
  %16 = load i32, i32* %j, align 4
  %inc27 = add nsw i32 %16, 1
  store i32 %inc27, i32* %j, align 4
  br label %for.cond.13

for.end.28:                                       ; preds = %for.cond.13
  br label %for.inc.29

for.inc.29:                                       ; preds = %for.end.28
  %17 = load i32, i32* %i, align 4
  %inc30 = add nsw i32 %17, 1
  store i32 %inc30, i32* %i, align 4
  br label %for.cond.9

for.end.31:                                       ; preds = %for.cond.9
  store i32 0, i32* %i, align 4
  br label %for.cond.32

for.cond.32:                                      ; preds = %for.inc.61, %for.end.31
  %18 = load i32, i32* %i, align 4
  %cmp33 = icmp slt i32 %18, 2048
  br i1 %cmp33, label %for.body.35, label %for.end.63

for.body.35:                                      ; preds = %for.cond.32
  store i32 0, i32* %j, align 4
  br label %for.cond.36

for.cond.36:                                      ; preds = %for.inc.58, %for.body.35
  %19 = load i32, i32* %j, align 4
  %cmp37 = icmp slt i32 %19, 2048
  br i1 %cmp37, label %for.body.39, label %for.end.60

for.body.39:                                      ; preds = %for.cond.36
  %20 = load i32, i32* %i, align 4
  %conv40 = sitofp i32 %20 to float
  %21 = load i32, i32* %j, align 4
  %conv41 = sitofp i32 %21 to float
  %mul42 = fmul float %conv40, %conv41
  %add43 = fadd float %mul42, 2.000000e+00
  %div44 = fdiv float %add43, 2.048000e+03
  %22 = load i32, i32* %i, align 4
  %mul45 = mul nsw i32 %22, 2048
  %23 = load i32, i32* %j, align 4
  %add46 = add nsw i32 %mul45, %23
  %idxprom47 = sext i32 %add46 to i64
  %24 = load float*, float** %C.addr, align 8
  %arrayidx48 = getelementptr inbounds float, float* %24, i64 %idxprom47
  store float %div44, float* %arrayidx48, align 4
  %25 = load i32, i32* %i, align 4
  %conv49 = sitofp i32 %25 to float
  %26 = load i32, i32* %j, align 4
  %conv50 = sitofp i32 %26 to float
  %mul51 = fmul float %conv49, %conv50
  %add52 = fadd float %mul51, 2.000000e+00
  %div53 = fdiv float %add52, 2.048000e+03
  %27 = load i32, i32* %i, align 4
  %mul54 = mul nsw i32 %27, 2048
  %28 = load i32, i32* %j, align 4
  %add55 = add nsw i32 %mul54, %28
  %idxprom56 = sext i32 %add55 to i64
  %29 = load float*, float** %C_OMP.addr, align 8
  %arrayidx57 = getelementptr inbounds float, float* %29, i64 %idxprom56
  store float %div53, float* %arrayidx57, align 4
  br label %for.inc.58

for.inc.58:                                       ; preds = %for.body.39
  %30 = load i32, i32* %j, align 4
  %inc59 = add nsw i32 %30, 1
  store i32 %inc59, i32* %j, align 4
  br label %for.cond.36

for.end.60:                                       ; preds = %for.cond.36
  br label %for.inc.61

for.inc.61:                                       ; preds = %for.end.60
  %31 = load i32, i32* %i, align 4
  %inc62 = add nsw i32 %31, 1
  store i32 %inc62, i32* %i, align 4
  br label %for.cond.32

for.end.63:                                       ; preds = %for.cond.32
  ret void
}

; Function Attrs: nounwind uwtable
define void @compareResults(float* %C, float* %C_outputFromGpu) #0 {
entry:
  %C.addr = alloca float*, align 8
  %C_outputFromGpu.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %fail = alloca i32, align 4
  store float* %C, float** %C.addr, align 8
  store float* %C_outputFromGpu, float** %C_outputFromGpu.addr, align 8
  store i32 0, i32* %fail, align 4
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.13, %entry
  %0 = load i32, i32* %i, align 4
  %cmp = icmp slt i32 %0, 2048
  br i1 %cmp, label %for.body, label %for.end.15

for.body:                                         ; preds = %for.cond
  store i32 0, i32* %j, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %1 = load i32, i32* %j, align 4
  %cmp2 = icmp slt i32 %1, 2048
  br i1 %cmp2, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.cond.1
  %2 = load i32, i32* %i, align 4
  %mul = mul nsw i32 %2, 2048
  %3 = load i32, i32* %j, align 4
  %add = add nsw i32 %mul, %3
  %idxprom = sext i32 %add to i64
  %4 = load float*, float** %C.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %4, i64 %idxprom
  %5 = load float, float* %arrayidx, align 4
  %conv = fpext float %5 to double
  %6 = load i32, i32* %i, align 4
  %mul4 = mul nsw i32 %6, 2048
  %7 = load i32, i32* %j, align 4
  %add5 = add nsw i32 %mul4, %7
  %idxprom6 = sext i32 %add5 to i64
  %8 = load float*, float** %C_outputFromGpu.addr, align 8
  %arrayidx7 = getelementptr inbounds float, float* %8, i64 %idxprom6
  %9 = load float, float* %arrayidx7, align 4
  %conv8 = fpext float %9 to double
  %call = call float @percentDiff(double %conv, double %conv8)
  %conv9 = fpext float %call to double
  %cmp10 = fcmp ogt double %conv9, 5.000000e-02
  br i1 %cmp10, label %if.then, label %if.end

if.then:                                          ; preds = %for.body.3
  %10 = load i32, i32* %fail, align 4
  %inc = add nsw i32 %10, 1
  store i32 %inc, i32* %fail, align 4
  br label %if.end

if.end:                                           ; preds = %if.then, %for.body.3
  br label %for.inc

for.inc:                                          ; preds = %if.end
  %11 = load i32, i32* %j, align 4
  %inc12 = add nsw i32 %11, 1
  store i32 %inc12, i32* %j, align 4
  br label %for.cond.1

for.end:                                          ; preds = %for.cond.1
  br label %for.inc.13

for.inc.13:                                       ; preds = %for.end
  %12 = load i32, i32* %i, align 4
  %inc14 = add nsw i32 %12, 1
  store i32 %inc14, i32* %i, align 4
  br label %for.cond

for.end.15:                                       ; preds = %for.cond
  %13 = load i32, i32* %fail, align 4
  %call16 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([74 x i8], [74 x i8]* @.str.1, i32 0, i32 0), double 5.000000e-02, i32 %13)
  ret void
}

; Function Attrs: nounwind uwtable
define i32 @main(i32 %argc, i8** %argv) #0 {
entry:
  %retval = alloca i32, align 4
  %argc.addr = alloca i32, align 4
  %argv.addr = alloca i8**, align 8
  %t_start = alloca double, align 8
  %t_end = alloca double, align 8
  %ni = alloca i32, align 4
  %nj = alloca i32, align 4
  %nk = alloca i32, align 4
  %A = alloca float*, align 8
  %B = alloca float*, align 8
  %C = alloca float*, align 8
  %C_outputFromGpu = alloca float*, align 8
  store i32 0, i32* %retval
  store i32 %argc, i32* %argc.addr, align 4
  store i8** %argv, i8*** %argv.addr, align 8
  store i32 2048, i32* %ni, align 4
  store i32 2048, i32* %nj, align 4
  store i32 2048, i32* %nk, align 4
  %call = call noalias i8* @malloc(i64 16777216) #3
  %0 = bitcast i8* %call to float*
  store float* %0, float** %A, align 8
  %call1 = call noalias i8* @malloc(i64 16777216) #3
  %1 = bitcast i8* %call1 to float*
  store float* %1, float** %B, align 8
  %call2 = call noalias i8* @malloc(i64 16777216) #3
  %2 = bitcast i8* %call2 to float*
  store float* %2, float** %C, align 8
  %call3 = call noalias i8* @malloc(i64 16777216) #3
  %3 = bitcast i8* %call3 to float*
  store float* %3, float** %C_outputFromGpu, align 8
  %4 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %call4 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %4, i8* getelementptr inbounds ([42 x i8], [42 x i8]* @.str.2, i32 0, i32 0))
  %5 = load float*, float** %A, align 8
  %6 = load float*, float** %B, align 8
  %7 = load float*, float** %C, align 8
  %8 = load float*, float** %C_outputFromGpu, align 8
  call void @init(float* %5, float* %6, float* %7, float* %8)
  %call5 = call double @rtclock()
  store double %call5, double* %t_start, align 8
  %9 = load i32, i32* %ni, align 4
  %10 = load i32, i32* %nk, align 4
  %11 = load i32, i32* %nk, align 4
  %12 = load float*, float** %A, align 8
  %13 = load float*, float** %B, align 8
  %14 = load float*, float** %C, align 8
  call void @gemm(i32 %9, i32 %10, i32 %11, float* %12, float* %13, float* %14)
  %call6 = call double @rtclock()
  store double %call6, double* %t_end, align 8
  %15 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %16 = load double, double* %t_end, align 8
  %17 = load double, double* %t_start, align 8
  %sub = fsub double %16, %17
  %call7 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %15, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.3, i32 0, i32 0), double %sub)
  %18 = load float*, float** %A, align 8
  %19 = bitcast float* %18 to i8*
  call void @free(i8* %19) #3
  %20 = load float*, float** %B, align 8
  %21 = bitcast float* %20 to i8*
  call void @free(i8* %21) #3
  %22 = load float*, float** %C, align 8
  %23 = bitcast float* %22 to i8*
  call void @free(i8* %23) #3
  ret i32 0
}

; Function Attrs: nounwind
declare noalias i8* @malloc(i64) #1

declare i32 @fprintf(%struct._IO_FILE*, i8*, ...) #2

; Function Attrs: nounwind
declare void @free(i8*) #1

attributes #0 = { nounwind uwtable "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nounwind }

!llvm.ident = !{!0}

!0 = !{!"clang version 3.7.1 (https://github.com/llvm-mirror/clang.git 0dbefa1b83eb90f7a06b5df5df254ce32be3db4b) (https://github.com/llvm-mirror/llvm.git 33c352b3eda89abc24e7511d9045fa2e499a42e3)"}
