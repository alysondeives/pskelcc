; ModuleID = 'atax.c'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, i8*, i8*, i8*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type { %struct._IO_marker*, %struct._IO_FILE*, i32 }
%struct.timezone = type { i32, i32 }
%struct.timeval = type { i64, i64 }

@.str = private unnamed_addr constant [35 x i8] c"Error return from gettimeofday: %d\00", align 1
@.str.1 = private unnamed_addr constant [74 x i8] c"Non-Matching CPU-GPU Outputs Beyond Error Threshold of %4.2f Percent: %d\0A\00", align 1
@stdout = external global %struct._IO_FILE*, align 8
@.str.2 = private unnamed_addr constant [50 x i8] c"<< Matrix Transpose and Vector Multiplication >>\0A\00", align 1
@.str.3 = private unnamed_addr constant [22 x i8] c"GPU Runtime: %0.6lfs\0A\00", align 1
@.str.4 = private unnamed_addr constant [22 x i8] c"CPU Runtime: %0.6lfs\0A\00", align 1

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
define void @init_array(float* %x, float* %A) #0 {
entry:
  %x.addr = alloca float*, align 8
  %A.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  store float* %x, float** %x.addr, align 8
  store float* %A, float** %A.addr, align 8
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.12, %entry
  %0 = load i32, i32* %i, align 4
  %cmp = icmp slt i32 %0, 8192
  br i1 %cmp, label %for.body, label %for.end.14

for.body:                                         ; preds = %for.cond
  %1 = load i32, i32* %i, align 4
  %conv = sitofp i32 %1 to double
  %mul = fmul double %conv, 0x400921FB54442D18
  %conv1 = fptrunc double %mul to float
  %2 = load i32, i32* %i, align 4
  %idxprom = sext i32 %2 to i64
  %3 = load float*, float** %x.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %3, i64 %idxprom
  store float %conv1, float* %arrayidx, align 4
  store i32 0, i32* %j, align 4
  br label %for.cond.2

for.cond.2:                                       ; preds = %for.inc, %for.body
  %4 = load i32, i32* %j, align 4
  %cmp3 = icmp slt i32 %4, 8192
  br i1 %cmp3, label %for.body.5, label %for.end

for.body.5:                                       ; preds = %for.cond.2
  %5 = load i32, i32* %i, align 4
  %conv6 = sitofp i32 %5 to float
  %6 = load i32, i32* %j, align 4
  %conv7 = sitofp i32 %6 to float
  %mul8 = fmul float %conv6, %conv7
  %div = fdiv float %mul8, 8.192000e+03
  %7 = load i32, i32* %i, align 4
  %mul9 = mul nsw i32 %7, 8192
  %8 = load i32, i32* %j, align 4
  %add = add nsw i32 %mul9, %8
  %idxprom10 = sext i32 %add to i64
  %9 = load float*, float** %A.addr, align 8
  %arrayidx11 = getelementptr inbounds float, float* %9, i64 %idxprom10
  store float %div, float* %arrayidx11, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.5
  %10 = load i32, i32* %j, align 4
  %inc = add nsw i32 %10, 1
  store i32 %inc, i32* %j, align 4
  br label %for.cond.2

for.end:                                          ; preds = %for.cond.2
  br label %for.inc.12

for.inc.12:                                       ; preds = %for.end
  %11 = load i32, i32* %i, align 4
  %inc13 = add nsw i32 %11, 1
  store i32 %inc13, i32* %i, align 4
  br label %for.cond

for.end.14:                                       ; preds = %for.cond
  ret void
}

; Function Attrs: nounwind uwtable
define void @compareResults(float* %z, float* %z_outputFromGpu) #0 {
entry:
  %z.addr = alloca float*, align 8
  %z_outputFromGpu.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %fail = alloca i32, align 4
  store float* %z, float** %z.addr, align 8
  store float* %z_outputFromGpu, float** %z_outputFromGpu.addr, align 8
  store i32 0, i32* %fail, align 4
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %0 = load i32, i32* %i, align 4
  %cmp = icmp slt i32 %0, 8192
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %1 = load i32, i32* %i, align 4
  %idxprom = sext i32 %1 to i64
  %2 = load float*, float** %z.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %2, i64 %idxprom
  %3 = load float, float* %arrayidx, align 4
  %conv = fpext float %3 to double
  %4 = load i32, i32* %i, align 4
  %idxprom1 = sext i32 %4 to i64
  %5 = load float*, float** %z_outputFromGpu.addr, align 8
  %arrayidx2 = getelementptr inbounds float, float* %5, i64 %idxprom1
  %6 = load float, float* %arrayidx2, align 4
  %conv3 = fpext float %6 to double
  %call = call float @percentDiff(double %conv, double %conv3)
  %conv4 = fpext float %call to double
  %cmp5 = fcmp ogt double %conv4, 5.000000e-01
  br i1 %cmp5, label %if.then, label %if.end

if.then:                                          ; preds = %for.body
  %7 = load i32, i32* %fail, align 4
  %inc = add nsw i32 %7, 1
  store i32 %inc, i32* %fail, align 4
  br label %if.end

if.end:                                           ; preds = %if.then, %for.body
  br label %for.inc

for.inc:                                          ; preds = %if.end
  %8 = load i32, i32* %i, align 4
  %inc7 = add nsw i32 %8, 1
  store i32 %inc7, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  %9 = load i32, i32* %fail, align 4
  %call8 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([74 x i8], [74 x i8]* @.str.1, i32 0, i32 0), double 5.000000e-01, i32 %9)
  ret void
}

; Function Attrs: nounwind uwtable
define void @atax_cpu(float* %A, float* %x, float* %y, float* %tmp) #0 {
entry:
  %A.addr = alloca float*, align 8
  %x.addr = alloca float*, align 8
  %y.addr = alloca float*, align 8
  %tmp.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  store float* %A, float** %A.addr, align 8
  store float* %x, float** %x.addr, align 8
  store float* %y, float** %y.addr, align 8
  store float* %tmp, float** %tmp.addr, align 8
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %0 = load i32, i32* %i, align 4
  %cmp = icmp slt i32 %0, 8192
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %1 = load i32, i32* %i, align 4
  %idxprom = sext i32 %1 to i64
  %2 = load float*, float** %y.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %2, i64 %idxprom
  store float 0.000000e+00, float* %arrayidx, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %3 = load i32, i32* %i, align 4
  %inc = add nsw i32 %3, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  store i32 0, i32* %i, align 4
  br label %for.cond.3

for.cond.3:                                       ; preds = %for.inc.42, %for.end
  %4 = load i32, i32* %i, align 4
  %cmp4 = icmp slt i32 %4, 8192
  br i1 %cmp4, label %for.body.5, label %for.end.44

for.body.5:                                       ; preds = %for.cond.3
  %5 = load i32, i32* %i, align 4
  %idxprom6 = sext i32 %5 to i64
  %6 = load float*, float** %tmp.addr, align 8
  %arrayidx7 = getelementptr inbounds float, float* %6, i64 %idxprom6
  store float 0.000000e+00, float* %arrayidx7, align 4
  store i32 0, i32* %j, align 4
  br label %for.cond.8

for.cond.8:                                       ; preds = %for.inc.21, %for.body.5
  %7 = load i32, i32* %j, align 4
  %cmp9 = icmp slt i32 %7, 8192
  br i1 %cmp9, label %for.body.10, label %for.end.23

for.body.10:                                      ; preds = %for.cond.8
  %8 = load i32, i32* %i, align 4
  %idxprom11 = sext i32 %8 to i64
  %9 = load float*, float** %tmp.addr, align 8
  %arrayidx12 = getelementptr inbounds float, float* %9, i64 %idxprom11
  %10 = load float, float* %arrayidx12, align 4
  %11 = load i32, i32* %i, align 4
  %mul = mul nsw i32 %11, 8192
  %12 = load i32, i32* %j, align 4
  %add = add nsw i32 %mul, %12
  %idxprom13 = sext i32 %add to i64
  %13 = load float*, float** %A.addr, align 8
  %arrayidx14 = getelementptr inbounds float, float* %13, i64 %idxprom13
  %14 = load float, float* %arrayidx14, align 4
  %15 = load i32, i32* %j, align 4
  %idxprom15 = sext i32 %15 to i64
  %16 = load float*, float** %x.addr, align 8
  %arrayidx16 = getelementptr inbounds float, float* %16, i64 %idxprom15
  %17 = load float, float* %arrayidx16, align 4
  %mul17 = fmul float %14, %17
  %add18 = fadd float %10, %mul17
  %18 = load i32, i32* %i, align 4
  %idxprom19 = sext i32 %18 to i64
  %19 = load float*, float** %tmp.addr, align 8
  %arrayidx20 = getelementptr inbounds float, float* %19, i64 %idxprom19
  store float %add18, float* %arrayidx20, align 4
  br label %for.inc.21

for.inc.21:                                       ; preds = %for.body.10
  %20 = load i32, i32* %j, align 4
  %inc22 = add nsw i32 %20, 1
  store i32 %inc22, i32* %j, align 4
  br label %for.cond.8

for.end.23:                                       ; preds = %for.cond.8
  store i32 0, i32* %j, align 4
  br label %for.cond.24

for.cond.24:                                      ; preds = %for.inc.39, %for.end.23
  %21 = load i32, i32* %j, align 4
  %cmp25 = icmp slt i32 %21, 8192
  br i1 %cmp25, label %for.body.26, label %for.end.41

for.body.26:                                      ; preds = %for.cond.24
  %22 = load i32, i32* %j, align 4
  %idxprom27 = sext i32 %22 to i64
  %23 = load float*, float** %y.addr, align 8
  %arrayidx28 = getelementptr inbounds float, float* %23, i64 %idxprom27
  %24 = load float, float* %arrayidx28, align 4
  %25 = load i32, i32* %i, align 4
  %mul29 = mul nsw i32 %25, 8192
  %26 = load i32, i32* %j, align 4
  %add30 = add nsw i32 %mul29, %26
  %idxprom31 = sext i32 %add30 to i64
  %27 = load float*, float** %A.addr, align 8
  %arrayidx32 = getelementptr inbounds float, float* %27, i64 %idxprom31
  %28 = load float, float* %arrayidx32, align 4
  %29 = load i32, i32* %i, align 4
  %idxprom33 = sext i32 %29 to i64
  %30 = load float*, float** %tmp.addr, align 8
  %arrayidx34 = getelementptr inbounds float, float* %30, i64 %idxprom33
  %31 = load float, float* %arrayidx34, align 4
  %mul35 = fmul float %28, %31
  %add36 = fadd float %24, %mul35
  %32 = load i32, i32* %j, align 4
  %idxprom37 = sext i32 %32 to i64
  %33 = load float*, float** %y.addr, align 8
  %arrayidx38 = getelementptr inbounds float, float* %33, i64 %idxprom37
  store float %add36, float* %arrayidx38, align 4
  br label %for.inc.39

for.inc.39:                                       ; preds = %for.body.26
  %34 = load i32, i32* %j, align 4
  %inc40 = add nsw i32 %34, 1
  store i32 %inc40, i32* %j, align 4
  br label %for.cond.24

for.end.41:                                       ; preds = %for.cond.24
  br label %for.inc.42

for.inc.42:                                       ; preds = %for.end.41
  %35 = load i32, i32* %i, align 4
  %inc43 = add nsw i32 %35, 1
  store i32 %inc43, i32* %i, align 4
  br label %for.cond.3

for.end.44:                                       ; preds = %for.cond.3
  ret void
}

; Function Attrs: nounwind uwtable
define void @GPU__atax(float* %A, float* %x, float* %y, float* %tmp) #0 {
entry:
  %A.addr = alloca float*, align 8
  %x.addr = alloca float*, align 8
  %y.addr = alloca float*, align 8
  %tmp.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  store float* %A, float** %A.addr, align 8
  store float* %x, float** %x.addr, align 8
  store float* %y, float** %y.addr, align 8
  store float* %tmp, float** %tmp.addr, align 8
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %0 = load i32, i32* %i, align 4
  %cmp = icmp slt i32 %0, 8192
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %1 = load i32, i32* %i, align 4
  %idxprom = sext i32 %1 to i64
  %2 = load float*, float** %y.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %2, i64 %idxprom
  store float 0.000000e+00, float* %arrayidx, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %3 = load i32, i32* %i, align 4
  %inc = add nsw i32 %3, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  store i32 0, i32* %i, align 4
  br label %for.cond.3

for.cond.3:                                       ; preds = %for.inc.24, %for.end
  %4 = load i32, i32* %i, align 4
  %cmp4 = icmp slt i32 %4, 8192
  br i1 %cmp4, label %for.body.5, label %for.end.26

for.body.5:                                       ; preds = %for.cond.3
  %5 = load i32, i32* %i, align 4
  %idxprom6 = sext i32 %5 to i64
  %6 = load float*, float** %tmp.addr, align 8
  %arrayidx7 = getelementptr inbounds float, float* %6, i64 %idxprom6
  store float 0.000000e+00, float* %arrayidx7, align 4
  store i32 0, i32* %j, align 4
  br label %for.cond.8

for.cond.8:                                       ; preds = %for.inc.21, %for.body.5
  %7 = load i32, i32* %j, align 4
  %cmp9 = icmp slt i32 %7, 8192
  br i1 %cmp9, label %for.body.10, label %for.end.23

for.body.10:                                      ; preds = %for.cond.8
  %8 = load i32, i32* %i, align 4
  %idxprom11 = sext i32 %8 to i64
  %9 = load float*, float** %tmp.addr, align 8
  %arrayidx12 = getelementptr inbounds float, float* %9, i64 %idxprom11
  %10 = load float, float* %arrayidx12, align 4
  %11 = load i32, i32* %i, align 4
  %mul = mul nsw i32 %11, 8192
  %12 = load i32, i32* %j, align 4
  %add = add nsw i32 %mul, %12
  %idxprom13 = sext i32 %add to i64
  %13 = load float*, float** %A.addr, align 8
  %arrayidx14 = getelementptr inbounds float, float* %13, i64 %idxprom13
  %14 = load float, float* %arrayidx14, align 4
  %15 = load i32, i32* %j, align 4
  %idxprom15 = sext i32 %15 to i64
  %16 = load float*, float** %x.addr, align 8
  %arrayidx16 = getelementptr inbounds float, float* %16, i64 %idxprom15
  %17 = load float, float* %arrayidx16, align 4
  %mul17 = fmul float %14, %17
  %add18 = fadd float %10, %mul17
  %18 = load i32, i32* %i, align 4
  %idxprom19 = sext i32 %18 to i64
  %19 = load float*, float** %tmp.addr, align 8
  %arrayidx20 = getelementptr inbounds float, float* %19, i64 %idxprom19
  store float %add18, float* %arrayidx20, align 4
  br label %for.inc.21

for.inc.21:                                       ; preds = %for.body.10
  %20 = load i32, i32* %j, align 4
  %inc22 = add nsw i32 %20, 1
  store i32 %inc22, i32* %j, align 4
  br label %for.cond.8

for.end.23:                                       ; preds = %for.cond.8
  br label %for.inc.24

for.inc.24:                                       ; preds = %for.end.23
  %21 = load i32, i32* %i, align 4
  %inc25 = add nsw i32 %21, 1
  store i32 %inc25, i32* %i, align 4
  br label %for.cond.3

for.end.26:                                       ; preds = %for.cond.3
  store i32 0, i32* %j, align 4
  br label %for.cond.27

for.cond.27:                                      ; preds = %for.inc.48, %for.end.26
  %22 = load i32, i32* %j, align 4
  %cmp28 = icmp slt i32 %22, 8192
  br i1 %cmp28, label %for.body.29, label %for.end.50

for.body.29:                                      ; preds = %for.cond.27
  store i32 0, i32* %i, align 4
  br label %for.cond.30

for.cond.30:                                      ; preds = %for.inc.45, %for.body.29
  %23 = load i32, i32* %i, align 4
  %cmp31 = icmp slt i32 %23, 8192
  br i1 %cmp31, label %for.body.32, label %for.end.47

for.body.32:                                      ; preds = %for.cond.30
  %24 = load i32, i32* %j, align 4
  %idxprom33 = sext i32 %24 to i64
  %25 = load float*, float** %y.addr, align 8
  %arrayidx34 = getelementptr inbounds float, float* %25, i64 %idxprom33
  %26 = load float, float* %arrayidx34, align 4
  %27 = load i32, i32* %i, align 4
  %mul35 = mul nsw i32 %27, 8192
  %28 = load i32, i32* %j, align 4
  %add36 = add nsw i32 %mul35, %28
  %idxprom37 = sext i32 %add36 to i64
  %29 = load float*, float** %A.addr, align 8
  %arrayidx38 = getelementptr inbounds float, float* %29, i64 %idxprom37
  %30 = load float, float* %arrayidx38, align 4
  %31 = load i32, i32* %i, align 4
  %idxprom39 = sext i32 %31 to i64
  %32 = load float*, float** %tmp.addr, align 8
  %arrayidx40 = getelementptr inbounds float, float* %32, i64 %idxprom39
  %33 = load float, float* %arrayidx40, align 4
  %mul41 = fmul float %30, %33
  %add42 = fadd float %26, %mul41
  %34 = load i32, i32* %j, align 4
  %idxprom43 = sext i32 %34 to i64
  %35 = load float*, float** %y.addr, align 8
  %arrayidx44 = getelementptr inbounds float, float* %35, i64 %idxprom43
  store float %add42, float* %arrayidx44, align 4
  br label %for.inc.45

for.inc.45:                                       ; preds = %for.body.32
  %36 = load i32, i32* %i, align 4
  %inc46 = add nsw i32 %36, 1
  store i32 %inc46, i32* %i, align 4
  br label %for.cond.30

for.end.47:                                       ; preds = %for.cond.30
  br label %for.inc.48

for.inc.48:                                       ; preds = %for.end.47
  %37 = load i32, i32* %j, align 4
  %inc49 = add nsw i32 %37, 1
  store i32 %inc49, i32* %j, align 4
  br label %for.cond.27

for.end.50:                                       ; preds = %for.cond.27
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
  %A = alloca float*, align 8
  %x = alloca float*, align 8
  %y = alloca float*, align 8
  %y_outputFromGpu = alloca float*, align 8
  %tmp = alloca float*, align 8
  store i32 0, i32* %retval
  store i32 %argc, i32* %argc.addr, align 4
  store i8** %argv, i8*** %argv.addr, align 8
  %call = call noalias i8* @malloc(i64 268435456) #3
  %0 = bitcast i8* %call to float*
  store float* %0, float** %A, align 8
  %call1 = call noalias i8* @malloc(i64 32768) #3
  %1 = bitcast i8* %call1 to float*
  store float* %1, float** %x, align 8
  %call2 = call noalias i8* @malloc(i64 32768) #3
  %2 = bitcast i8* %call2 to float*
  store float* %2, float** %y, align 8
  %call3 = call noalias i8* @malloc(i64 32768) #3
  %3 = bitcast i8* %call3 to float*
  store float* %3, float** %y_outputFromGpu, align 8
  %call4 = call noalias i8* @malloc(i64 32768) #3
  %4 = bitcast i8* %call4 to float*
  store float* %4, float** %tmp, align 8
  %5 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %call5 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %5, i8* getelementptr inbounds ([50 x i8], [50 x i8]* @.str.2, i32 0, i32 0))
  %6 = load float*, float** %x, align 8
  %7 = load float*, float** %A, align 8
  call void @init_array(float* %6, float* %7)
  %call6 = call double @rtclock()
  store double %call6, double* %t_start, align 8
  %8 = load float*, float** %A, align 8
  %9 = load float*, float** %x, align 8
  %10 = load float*, float** %y_outputFromGpu, align 8
  %11 = load float*, float** %tmp, align 8
  call void @GPU__atax(float* %8, float* %9, float* %10, float* %11)
  %call7 = call double @rtclock()
  store double %call7, double* %t_end, align 8
  %12 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %13 = load double, double* %t_end, align 8
  %14 = load double, double* %t_start, align 8
  %sub = fsub double %13, %14
  %call8 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %12, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.3, i32 0, i32 0), double %sub)
  %call9 = call double @rtclock()
  store double %call9, double* %t_start, align 8
  %15 = load float*, float** %A, align 8
  %16 = load float*, float** %x, align 8
  %17 = load float*, float** %y, align 8
  %18 = load float*, float** %tmp, align 8
  call void @atax_cpu(float* %15, float* %16, float* %17, float* %18)
  %call10 = call double @rtclock()
  store double %call10, double* %t_end, align 8
  %19 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %20 = load double, double* %t_end, align 8
  %21 = load double, double* %t_start, align 8
  %sub11 = fsub double %20, %21
  %call12 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %19, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.4, i32 0, i32 0), double %sub11)
  %22 = load float*, float** %y, align 8
  %23 = load float*, float** %y_outputFromGpu, align 8
  call void @compareResults(float* %22, float* %23)
  %24 = load float*, float** %A, align 8
  %25 = bitcast float* %24 to i8*
  call void @free(i8* %25) #3
  %26 = load float*, float** %x, align 8
  %27 = bitcast float* %26 to i8*
  call void @free(i8* %27) #3
  %28 = load float*, float** %y, align 8
  %29 = bitcast float* %28 to i8*
  call void @free(i8* %29) #3
  %30 = load float*, float** %y_outputFromGpu, align 8
  %31 = bitcast float* %30 to i8*
  call void @free(i8* %31) #3
  %32 = load float*, float** %tmp, align 8
  %33 = bitcast float* %32 to i8*
  call void @free(i8* %33) #3
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
