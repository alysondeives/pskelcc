; ModuleID = 'bicg.c'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, i8*, i8*, i8*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type { %struct._IO_marker*, %struct._IO_FILE*, i32 }
%struct.timezone = type { i32, i32 }
%struct.timeval = type { i64, i64 }

@.str = private unnamed_addr constant [35 x i8] c"Error return from gettimeofday: %d\00", align 1
@.str.1 = private unnamed_addr constant [74 x i8] c"Non-Matching CPU-GPU Outputs Beyond Error Threshold of %4.2f Percent: %d\0A\00", align 1
@stdout = external global %struct._IO_FILE*, align 8
@.str.2 = private unnamed_addr constant [49 x i8] c"<< BiCG Sub Kernel of BiCGStab Linear Solver >>\0A\00", align 1
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
define void @init_array(float* %A, float* %p, float* %r) #0 {
entry:
  %A.addr = alloca float*, align 8
  %p.addr = alloca float*, align 8
  %r.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  store float* %A, float** %A.addr, align 8
  store float* %p, float** %p.addr, align 8
  store float* %r, float** %r.addr, align 8
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.12, %entry
  %0 = load i32, i32* %i, align 4
  %cmp = icmp slt i32 %0, 4096
  br i1 %cmp, label %for.body, label %for.end.14

for.body:                                         ; preds = %for.cond
  %1 = load i32, i32* %i, align 4
  %conv = sitofp i32 %1 to double
  %mul = fmul double %conv, 0x400921FB54442D18
  %conv1 = fptrunc double %mul to float
  %2 = load i32, i32* %i, align 4
  %idxprom = sext i32 %2 to i64
  %3 = load float*, float** %r.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %3, i64 %idxprom
  store float %conv1, float* %arrayidx, align 4
  store i32 0, i32* %j, align 4
  br label %for.cond.2

for.cond.2:                                       ; preds = %for.inc, %for.body
  %4 = load i32, i32* %j, align 4
  %cmp3 = icmp slt i32 %4, 4096
  br i1 %cmp3, label %for.body.5, label %for.end

for.body.5:                                       ; preds = %for.cond.2
  %5 = load i32, i32* %i, align 4
  %conv6 = sitofp i32 %5 to float
  %6 = load i32, i32* %j, align 4
  %conv7 = sitofp i32 %6 to float
  %mul8 = fmul float %conv6, %conv7
  %div = fdiv float %mul8, 4.096000e+03
  %7 = load i32, i32* %i, align 4
  %mul9 = mul nsw i32 %7, 4096
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
  store i32 0, i32* %i, align 4
  br label %for.cond.15

for.cond.15:                                      ; preds = %for.inc.24, %for.end.14
  %12 = load i32, i32* %i, align 4
  %cmp16 = icmp slt i32 %12, 4096
  br i1 %cmp16, label %for.body.18, label %for.end.26

for.body.18:                                      ; preds = %for.cond.15
  %13 = load i32, i32* %i, align 4
  %conv19 = sitofp i32 %13 to double
  %mul20 = fmul double %conv19, 0x400921FB54442D18
  %conv21 = fptrunc double %mul20 to float
  %14 = load i32, i32* %i, align 4
  %idxprom22 = sext i32 %14 to i64
  %15 = load float*, float** %p.addr, align 8
  %arrayidx23 = getelementptr inbounds float, float* %15, i64 %idxprom22
  store float %conv21, float* %arrayidx23, align 4
  br label %for.inc.24

for.inc.24:                                       ; preds = %for.body.18
  %16 = load i32, i32* %i, align 4
  %inc25 = add nsw i32 %16, 1
  store i32 %inc25, i32* %i, align 4
  br label %for.cond.15

for.end.26:                                       ; preds = %for.cond.15
  ret void
}

; Function Attrs: nounwind uwtable
define void @compareResults(float* %s, float* %s_outputFromGpu, float* %q, float* %q_outputFromGpu) #0 {
entry:
  %s.addr = alloca float*, align 8
  %s_outputFromGpu.addr = alloca float*, align 8
  %q.addr = alloca float*, align 8
  %q_outputFromGpu.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %fail = alloca i32, align 4
  store float* %s, float** %s.addr, align 8
  store float* %s_outputFromGpu, float** %s_outputFromGpu.addr, align 8
  store float* %q, float** %q.addr, align 8
  store float* %q_outputFromGpu, float** %q_outputFromGpu.addr, align 8
  store i32 0, i32* %fail, align 4
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %0 = load i32, i32* %i, align 4
  %cmp = icmp slt i32 %0, 4096
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %1 = load i32, i32* %i, align 4
  %idxprom = sext i32 %1 to i64
  %2 = load float*, float** %q.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %2, i64 %idxprom
  %3 = load float, float* %arrayidx, align 4
  %conv = fpext float %3 to double
  %4 = load i32, i32* %i, align 4
  %idxprom1 = sext i32 %4 to i64
  %5 = load float*, float** %q_outputFromGpu.addr, align 8
  %arrayidx2 = getelementptr inbounds float, float* %5, i64 %idxprom1
  %6 = load float, float* %arrayidx2, align 4
  %conv3 = fpext float %6 to double
  %call = call float @percentDiff(double %conv, double %conv3)
  %conv4 = fpext float %call to double
  %cmp5 = fcmp ogt double %conv4, 7.000000e-01
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
  store i32 0, i32* %i, align 4
  br label %for.cond.8

for.cond.8:                                       ; preds = %for.inc.25, %for.end
  %9 = load i32, i32* %i, align 4
  %cmp9 = icmp slt i32 %9, 4096
  br i1 %cmp9, label %for.body.11, label %for.end.27

for.body.11:                                      ; preds = %for.cond.8
  %10 = load i32, i32* %i, align 4
  %idxprom12 = sext i32 %10 to i64
  %11 = load float*, float** %s.addr, align 8
  %arrayidx13 = getelementptr inbounds float, float* %11, i64 %idxprom12
  %12 = load float, float* %arrayidx13, align 4
  %conv14 = fpext float %12 to double
  %13 = load i32, i32* %i, align 4
  %idxprom15 = sext i32 %13 to i64
  %14 = load float*, float** %s_outputFromGpu.addr, align 8
  %arrayidx16 = getelementptr inbounds float, float* %14, i64 %idxprom15
  %15 = load float, float* %arrayidx16, align 4
  %conv17 = fpext float %15 to double
  %call18 = call float @percentDiff(double %conv14, double %conv17)
  %conv19 = fpext float %call18 to double
  %cmp20 = fcmp ogt double %conv19, 7.000000e-01
  br i1 %cmp20, label %if.then.22, label %if.end.24

if.then.22:                                       ; preds = %for.body.11
  %16 = load i32, i32* %fail, align 4
  %inc23 = add nsw i32 %16, 1
  store i32 %inc23, i32* %fail, align 4
  br label %if.end.24

if.end.24:                                        ; preds = %if.then.22, %for.body.11
  br label %for.inc.25

for.inc.25:                                       ; preds = %if.end.24
  %17 = load i32, i32* %i, align 4
  %inc26 = add nsw i32 %17, 1
  store i32 %inc26, i32* %i, align 4
  br label %for.cond.8

for.end.27:                                       ; preds = %for.cond.8
  %18 = load i32, i32* %fail, align 4
  %call28 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([74 x i8], [74 x i8]* @.str.1, i32 0, i32 0), double 7.000000e-01, i32 %18)
  ret void
}

; Function Attrs: nounwind uwtable
define void @bicg_cpu(i32 %nx, i32 %ny, float* %A, float* %r, float* %s, float* %p, float* %q) #0 {
entry:
  %nx.addr = alloca i32, align 4
  %ny.addr = alloca i32, align 4
  %A.addr = alloca float*, align 8
  %r.addr = alloca float*, align 8
  %s.addr = alloca float*, align 8
  %p.addr = alloca float*, align 8
  %q.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  store i32 %nx, i32* %nx.addr, align 4
  store i32 %ny, i32* %ny.addr, align 4
  store float* %A, float** %A.addr, align 8
  store float* %r, float** %r.addr, align 8
  store float* %s, float** %s.addr, align 8
  store float* %p, float** %p.addr, align 8
  store float* %q, float** %q.addr, align 8
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %0 = load i32, i32* %i, align 4
  %1 = load i32, i32* %ny.addr, align 4
  %cmp = icmp slt i32 %0, %1
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %2 = load i32, i32* %i, align 4
  %idxprom = sext i32 %2 to i64
  %3 = load float*, float** %s.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %3, i64 %idxprom
  store float 0.000000e+00, float* %arrayidx, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %4 = load i32, i32* %i, align 4
  %inc = add nsw i32 %4, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  store i32 0, i32* %i, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc.34, %for.end
  %5 = load i32, i32* %i, align 4
  %6 = load i32, i32* %nx.addr, align 4
  %cmp2 = icmp slt i32 %5, %6
  br i1 %cmp2, label %for.body.3, label %for.end.36

for.body.3:                                       ; preds = %for.cond.1
  %7 = load i32, i32* %i, align 4
  %idxprom4 = sext i32 %7 to i64
  %8 = load float*, float** %q.addr, align 8
  %arrayidx5 = getelementptr inbounds float, float* %8, i64 %idxprom4
  store float 0.000000e+00, float* %arrayidx5, align 4
  store i32 0, i32* %j, align 4
  br label %for.cond.6

for.cond.6:                                       ; preds = %for.inc.31, %for.body.3
  %9 = load i32, i32* %j, align 4
  %10 = load i32, i32* %ny.addr, align 4
  %cmp7 = icmp slt i32 %9, %10
  br i1 %cmp7, label %for.body.8, label %for.end.33

for.body.8:                                       ; preds = %for.cond.6
  %11 = load i32, i32* %j, align 4
  %idxprom9 = sext i32 %11 to i64
  %12 = load float*, float** %s.addr, align 8
  %arrayidx10 = getelementptr inbounds float, float* %12, i64 %idxprom9
  %13 = load float, float* %arrayidx10, align 4
  %14 = load i32, i32* %i, align 4
  %idxprom11 = sext i32 %14 to i64
  %15 = load float*, float** %r.addr, align 8
  %arrayidx12 = getelementptr inbounds float, float* %15, i64 %idxprom11
  %16 = load float, float* %arrayidx12, align 4
  %17 = load i32, i32* %i, align 4
  %18 = load i32, i32* %ny.addr, align 4
  %mul = mul nsw i32 %17, %18
  %19 = load i32, i32* %j, align 4
  %add = add nsw i32 %mul, %19
  %idxprom13 = sext i32 %add to i64
  %20 = load float*, float** %A.addr, align 8
  %arrayidx14 = getelementptr inbounds float, float* %20, i64 %idxprom13
  %21 = load float, float* %arrayidx14, align 4
  %mul15 = fmul float %16, %21
  %add16 = fadd float %13, %mul15
  %22 = load i32, i32* %j, align 4
  %idxprom17 = sext i32 %22 to i64
  %23 = load float*, float** %s.addr, align 8
  %arrayidx18 = getelementptr inbounds float, float* %23, i64 %idxprom17
  store float %add16, float* %arrayidx18, align 4
  %24 = load i32, i32* %i, align 4
  %idxprom19 = sext i32 %24 to i64
  %25 = load float*, float** %q.addr, align 8
  %arrayidx20 = getelementptr inbounds float, float* %25, i64 %idxprom19
  %26 = load float, float* %arrayidx20, align 4
  %27 = load i32, i32* %j, align 4
  %idxprom21 = sext i32 %27 to i64
  %28 = load float*, float** %p.addr, align 8
  %arrayidx22 = getelementptr inbounds float, float* %28, i64 %idxprom21
  %29 = load float, float* %arrayidx22, align 4
  %30 = load i32, i32* %i, align 4
  %31 = load i32, i32* %ny.addr, align 4
  %mul23 = mul nsw i32 %30, %31
  %32 = load i32, i32* %j, align 4
  %add24 = add nsw i32 %mul23, %32
  %idxprom25 = sext i32 %add24 to i64
  %33 = load float*, float** %A.addr, align 8
  %arrayidx26 = getelementptr inbounds float, float* %33, i64 %idxprom25
  %34 = load float, float* %arrayidx26, align 4
  %mul27 = fmul float %29, %34
  %add28 = fadd float %26, %mul27
  %35 = load i32, i32* %i, align 4
  %idxprom29 = sext i32 %35 to i64
  %36 = load float*, float** %q.addr, align 8
  %arrayidx30 = getelementptr inbounds float, float* %36, i64 %idxprom29
  store float %add28, float* %arrayidx30, align 4
  br label %for.inc.31

for.inc.31:                                       ; preds = %for.body.8
  %37 = load i32, i32* %j, align 4
  %inc32 = add nsw i32 %37, 1
  store i32 %inc32, i32* %j, align 4
  br label %for.cond.6

for.end.33:                                       ; preds = %for.cond.6
  br label %for.inc.34

for.inc.34:                                       ; preds = %for.end.33
  %38 = load i32, i32* %i, align 4
  %inc35 = add nsw i32 %38, 1
  store i32 %inc35, i32* %i, align 4
  br label %for.cond.1

for.end.36:                                       ; preds = %for.cond.1
  ret void
}

; Function Attrs: nounwind uwtable
define i32 @main(i32 %argc, i8** %argv) #0 {
entry:
  %retval = alloca i32, align 4
  %argc.addr = alloca i32, align 4
  %argv.addr = alloca i8**, align 8
  %nx = alloca i32, align 4
  %ny = alloca i32, align 4
  %t_start = alloca double, align 8
  %t_end = alloca double, align 8
  %A = alloca float*, align 8
  %r = alloca float*, align 8
  %s = alloca float*, align 8
  %p = alloca float*, align 8
  %q = alloca float*, align 8
  store i32 0, i32* %retval
  store i32 %argc, i32* %argc.addr, align 4
  store i8** %argv, i8*** %argv.addr, align 8
  store i32 4096, i32* %nx, align 4
  store i32 4096, i32* %ny, align 4
  %call = call noalias i8* @malloc(i64 67108864) #3
  %0 = bitcast i8* %call to float*
  store float* %0, float** %A, align 8
  %call1 = call noalias i8* @malloc(i64 16384) #3
  %1 = bitcast i8* %call1 to float*
  store float* %1, float** %r, align 8
  %call2 = call noalias i8* @malloc(i64 16384) #3
  %2 = bitcast i8* %call2 to float*
  store float* %2, float** %s, align 8
  %call3 = call noalias i8* @malloc(i64 16384) #3
  %3 = bitcast i8* %call3 to float*
  store float* %3, float** %p, align 8
  %call4 = call noalias i8* @malloc(i64 16384) #3
  %4 = bitcast i8* %call4 to float*
  store float* %4, float** %q, align 8
  %5 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %call5 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %5, i8* getelementptr inbounds ([49 x i8], [49 x i8]* @.str.2, i32 0, i32 0))
  %6 = load float*, float** %A, align 8
  %7 = load float*, float** %p, align 8
  %8 = load float*, float** %r, align 8
  call void @init_array(float* %6, float* %7, float* %8)
  %call6 = call double @rtclock()
  store double %call6, double* %t_start, align 8
  %9 = load i32, i32* %nx, align 4
  %10 = load i32, i32* %ny, align 4
  %11 = load float*, float** %A, align 8
  %12 = load float*, float** %r, align 8
  %13 = load float*, float** %s, align 8
  %14 = load float*, float** %p, align 8
  %15 = load float*, float** %q, align 8
  call void @bicg_cpu(i32 %9, i32 %10, float* %11, float* %12, float* %13, float* %14, float* %15)
  %call7 = call double @rtclock()
  store double %call7, double* %t_end, align 8
  %16 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %17 = load double, double* %t_end, align 8
  %18 = load double, double* %t_start, align 8
  %sub = fsub double %17, %18
  %call8 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %16, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.3, i32 0, i32 0), double %sub)
  %19 = load float*, float** %A, align 8
  %20 = bitcast float* %19 to i8*
  call void @free(i8* %20) #3
  %21 = load float*, float** %r, align 8
  %22 = bitcast float* %21 to i8*
  call void @free(i8* %22) #3
  %23 = load float*, float** %s, align 8
  %24 = bitcast float* %23 to i8*
  call void @free(i8* %24) #3
  %25 = load float*, float** %p, align 8
  %26 = bitcast float* %25 to i8*
  call void @free(i8* %26) #3
  %27 = load float*, float** %q, align 8
  %28 = bitcast float* %27 to i8*
  call void @free(i8* %28) #3
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
