; ModuleID = 'mvt.c'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, i8*, i8*, i8*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type { %struct._IO_marker*, %struct._IO_FILE*, i32 }
%struct.timezone = type { i32, i32 }
%struct.timeval = type { i64, i64 }

@.str = private unnamed_addr constant [35 x i8] c"Error return from gettimeofday: %d\00", align 1
@.str.1 = private unnamed_addr constant [74 x i8] c"Non-Matching CPU-GPU Outputs Beyond Error Threshold of %4.2f Percent: %d\0A\00", align 1
@stdout = external global %struct._IO_FILE*, align 8
@.str.2 = private unnamed_addr constant [43 x i8] c"<< Matrix Vector Product and Transpose >>\0A\00", align 1
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
define void @init_array(float* %A, float* %x1, float* %x2, float* %y1, float* %y2, float* %x1_gpu, float* %x2_gpu) #0 {
entry:
  %A.addr = alloca float*, align 8
  %x1.addr = alloca float*, align 8
  %x2.addr = alloca float*, align 8
  %y1.addr = alloca float*, align 8
  %y2.addr = alloca float*, align 8
  %x1_gpu.addr = alloca float*, align 8
  %x2_gpu.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  store float* %A, float** %A.addr, align 8
  store float* %x1, float** %x1.addr, align 8
  store float* %x2, float** %x2.addr, align 8
  store float* %y1, float** %y1.addr, align 8
  store float* %y2, float** %y2.addr, align 8
  store float* %x1_gpu, float** %x1_gpu.addr, align 8
  store float* %x2_gpu, float** %x2_gpu.addr, align 8
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.34, %entry
  %0 = load i32, i32* %i, align 4
  %cmp = icmp slt i32 %0, 4096
  br i1 %cmp, label %for.body, label %for.end.36

for.body:                                         ; preds = %for.cond
  %1 = load i32, i32* %i, align 4
  %conv = sitofp i32 %1 to float
  %div = fdiv float %conv, 4.096000e+03
  %2 = load i32, i32* %i, align 4
  %idxprom = sext i32 %2 to i64
  %3 = load float*, float** %x1.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %3, i64 %idxprom
  store float %div, float* %arrayidx, align 4
  %4 = load i32, i32* %i, align 4
  %conv1 = sitofp i32 %4 to float
  %add = fadd float %conv1, 1.000000e+00
  %div2 = fdiv float %add, 4.096000e+03
  %5 = load i32, i32* %i, align 4
  %idxprom3 = sext i32 %5 to i64
  %6 = load float*, float** %x2.addr, align 8
  %arrayidx4 = getelementptr inbounds float, float* %6, i64 %idxprom3
  store float %div2, float* %arrayidx4, align 4
  %7 = load i32, i32* %i, align 4
  %idxprom5 = sext i32 %7 to i64
  %8 = load float*, float** %x1.addr, align 8
  %arrayidx6 = getelementptr inbounds float, float* %8, i64 %idxprom5
  %9 = load float, float* %arrayidx6, align 4
  %10 = load i32, i32* %i, align 4
  %idxprom7 = sext i32 %10 to i64
  %11 = load float*, float** %x1_gpu.addr, align 8
  %arrayidx8 = getelementptr inbounds float, float* %11, i64 %idxprom7
  store float %9, float* %arrayidx8, align 4
  %12 = load i32, i32* %i, align 4
  %idxprom9 = sext i32 %12 to i64
  %13 = load float*, float** %x2.addr, align 8
  %arrayidx10 = getelementptr inbounds float, float* %13, i64 %idxprom9
  %14 = load float, float* %arrayidx10, align 4
  %15 = load i32, i32* %i, align 4
  %idxprom11 = sext i32 %15 to i64
  %16 = load float*, float** %x2_gpu.addr, align 8
  %arrayidx12 = getelementptr inbounds float, float* %16, i64 %idxprom11
  store float %14, float* %arrayidx12, align 4
  %17 = load i32, i32* %i, align 4
  %conv13 = sitofp i32 %17 to float
  %add14 = fadd float %conv13, 3.000000e+00
  %div15 = fdiv float %add14, 4.096000e+03
  %18 = load i32, i32* %i, align 4
  %idxprom16 = sext i32 %18 to i64
  %19 = load float*, float** %y1.addr, align 8
  %arrayidx17 = getelementptr inbounds float, float* %19, i64 %idxprom16
  store float %div15, float* %arrayidx17, align 4
  %20 = load i32, i32* %i, align 4
  %conv18 = sitofp i32 %20 to float
  %add19 = fadd float %conv18, 4.000000e+00
  %div20 = fdiv float %add19, 4.096000e+03
  %21 = load i32, i32* %i, align 4
  %idxprom21 = sext i32 %21 to i64
  %22 = load float*, float** %y2.addr, align 8
  %arrayidx22 = getelementptr inbounds float, float* %22, i64 %idxprom21
  store float %div20, float* %arrayidx22, align 4
  store i32 0, i32* %j, align 4
  br label %for.cond.23

for.cond.23:                                      ; preds = %for.inc, %for.body
  %23 = load i32, i32* %j, align 4
  %cmp24 = icmp slt i32 %23, 4096
  br i1 %cmp24, label %for.body.26, label %for.end

for.body.26:                                      ; preds = %for.cond.23
  %24 = load i32, i32* %i, align 4
  %conv27 = sitofp i32 %24 to float
  %25 = load i32, i32* %j, align 4
  %conv28 = sitofp i32 %25 to float
  %mul = fmul float %conv27, %conv28
  %div29 = fdiv float %mul, 4.096000e+03
  %26 = load i32, i32* %i, align 4
  %mul30 = mul nsw i32 %26, 4096
  %27 = load i32, i32* %j, align 4
  %add31 = add nsw i32 %mul30, %27
  %idxprom32 = sext i32 %add31 to i64
  %28 = load float*, float** %A.addr, align 8
  %arrayidx33 = getelementptr inbounds float, float* %28, i64 %idxprom32
  store float %div29, float* %arrayidx33, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.26
  %29 = load i32, i32* %j, align 4
  %inc = add nsw i32 %29, 1
  store i32 %inc, i32* %j, align 4
  br label %for.cond.23

for.end:                                          ; preds = %for.cond.23
  br label %for.inc.34

for.inc.34:                                       ; preds = %for.end
  %30 = load i32, i32* %i, align 4
  %inc35 = add nsw i32 %30, 1
  store i32 %inc35, i32* %i, align 4
  br label %for.cond

for.end.36:                                       ; preds = %for.cond
  ret void
}

; Function Attrs: nounwind uwtable
define void @runMvt(float* %a, float* %x1, float* %x2, float* %y1, float* %y2) #0 {
entry:
  %a.addr = alloca float*, align 8
  %x1.addr = alloca float*, align 8
  %x2.addr = alloca float*, align 8
  %y1.addr = alloca float*, align 8
  %y2.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  store float* %a, float** %a.addr, align 8
  store float* %x1, float** %x1.addr, align 8
  store float* %x2, float** %x2.addr, align 8
  store float* %y1, float** %y1.addr, align 8
  store float* %y2, float** %y2.addr, align 8
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.12, %entry
  %0 = load i32, i32* %i, align 4
  %cmp = icmp slt i32 %0, 4096
  br i1 %cmp, label %for.body, label %for.end.14

for.body:                                         ; preds = %for.cond
  store i32 0, i32* %j, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %1 = load i32, i32* %j, align 4
  %cmp2 = icmp slt i32 %1, 4096
  br i1 %cmp2, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.cond.1
  %2 = load i32, i32* %i, align 4
  %idxprom = sext i32 %2 to i64
  %3 = load float*, float** %x1.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %3, i64 %idxprom
  %4 = load float, float* %arrayidx, align 4
  %5 = load i32, i32* %i, align 4
  %mul = mul nsw i32 %5, 4096
  %6 = load i32, i32* %j, align 4
  %add = add nsw i32 %mul, %6
  %idxprom4 = sext i32 %add to i64
  %7 = load float*, float** %a.addr, align 8
  %arrayidx5 = getelementptr inbounds float, float* %7, i64 %idxprom4
  %8 = load float, float* %arrayidx5, align 4
  %9 = load i32, i32* %j, align 4
  %idxprom6 = sext i32 %9 to i64
  %10 = load float*, float** %y1.addr, align 8
  %arrayidx7 = getelementptr inbounds float, float* %10, i64 %idxprom6
  %11 = load float, float* %arrayidx7, align 4
  %mul8 = fmul float %8, %11
  %add9 = fadd float %4, %mul8
  %12 = load i32, i32* %i, align 4
  %idxprom10 = sext i32 %12 to i64
  %13 = load float*, float** %x1.addr, align 8
  %arrayidx11 = getelementptr inbounds float, float* %13, i64 %idxprom10
  store float %add9, float* %arrayidx11, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.3
  %14 = load i32, i32* %j, align 4
  %inc = add nsw i32 %14, 1
  store i32 %inc, i32* %j, align 4
  br label %for.cond.1

for.end:                                          ; preds = %for.cond.1
  br label %for.inc.12

for.inc.12:                                       ; preds = %for.end
  %15 = load i32, i32* %i, align 4
  %inc13 = add nsw i32 %15, 1
  store i32 %inc13, i32* %i, align 4
  br label %for.cond

for.end.14:                                       ; preds = %for.cond
  store i32 0, i32* %i, align 4
  br label %for.cond.15

for.cond.15:                                      ; preds = %for.inc.36, %for.end.14
  %16 = load i32, i32* %i, align 4
  %cmp16 = icmp slt i32 %16, 4096
  br i1 %cmp16, label %for.body.17, label %for.end.38

for.body.17:                                      ; preds = %for.cond.15
  store i32 0, i32* %j, align 4
  br label %for.cond.18

for.cond.18:                                      ; preds = %for.inc.33, %for.body.17
  %17 = load i32, i32* %j, align 4
  %cmp19 = icmp slt i32 %17, 4096
  br i1 %cmp19, label %for.body.20, label %for.end.35

for.body.20:                                      ; preds = %for.cond.18
  %18 = load i32, i32* %i, align 4
  %idxprom21 = sext i32 %18 to i64
  %19 = load float*, float** %x2.addr, align 8
  %arrayidx22 = getelementptr inbounds float, float* %19, i64 %idxprom21
  %20 = load float, float* %arrayidx22, align 4
  %21 = load i32, i32* %j, align 4
  %mul23 = mul nsw i32 %21, 4096
  %22 = load i32, i32* %i, align 4
  %add24 = add nsw i32 %mul23, %22
  %idxprom25 = sext i32 %add24 to i64
  %23 = load float*, float** %a.addr, align 8
  %arrayidx26 = getelementptr inbounds float, float* %23, i64 %idxprom25
  %24 = load float, float* %arrayidx26, align 4
  %25 = load i32, i32* %j, align 4
  %idxprom27 = sext i32 %25 to i64
  %26 = load float*, float** %y2.addr, align 8
  %arrayidx28 = getelementptr inbounds float, float* %26, i64 %idxprom27
  %27 = load float, float* %arrayidx28, align 4
  %mul29 = fmul float %24, %27
  %add30 = fadd float %20, %mul29
  %28 = load i32, i32* %i, align 4
  %idxprom31 = sext i32 %28 to i64
  %29 = load float*, float** %x2.addr, align 8
  %arrayidx32 = getelementptr inbounds float, float* %29, i64 %idxprom31
  store float %add30, float* %arrayidx32, align 4
  br label %for.inc.33

for.inc.33:                                       ; preds = %for.body.20
  %30 = load i32, i32* %j, align 4
  %inc34 = add nsw i32 %30, 1
  store i32 %inc34, i32* %j, align 4
  br label %for.cond.18

for.end.35:                                       ; preds = %for.cond.18
  br label %for.inc.36

for.inc.36:                                       ; preds = %for.end.35
  %31 = load i32, i32* %i, align 4
  %inc37 = add nsw i32 %31, 1
  store i32 %inc37, i32* %i, align 4
  br label %for.cond.15

for.end.38:                                       ; preds = %for.cond.15
  ret void
}

; Function Attrs: nounwind uwtable
define void @GPU__runMvt(float* %a, float* %x1, float* %x2, float* %y1, float* %y2) #0 {
entry:
  %a.addr = alloca float*, align 8
  %x1.addr = alloca float*, align 8
  %x2.addr = alloca float*, align 8
  %y1.addr = alloca float*, align 8
  %y2.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %j18 = alloca i32, align 4
  store float* %a, float** %a.addr, align 8
  store float* %x1, float** %x1.addr, align 8
  store float* %x2, float** %x2.addr, align 8
  store float* %y1, float** %y1.addr, align 8
  store float* %y2, float** %y2.addr, align 8
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.12, %entry
  %0 = load i32, i32* %i, align 4
  %cmp = icmp slt i32 %0, 4096
  br i1 %cmp, label %for.body, label %for.end.14

for.body:                                         ; preds = %for.cond
  store i32 0, i32* %j, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %1 = load i32, i32* %j, align 4
  %cmp2 = icmp slt i32 %1, 4096
  br i1 %cmp2, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.cond.1
  %2 = load i32, i32* %i, align 4
  %idxprom = sext i32 %2 to i64
  %3 = load float*, float** %x1.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %3, i64 %idxprom
  %4 = load float, float* %arrayidx, align 4
  %5 = load i32, i32* %i, align 4
  %mul = mul nsw i32 %5, 4096
  %6 = load i32, i32* %j, align 4
  %add = add nsw i32 %mul, %6
  %idxprom4 = sext i32 %add to i64
  %7 = load float*, float** %a.addr, align 8
  %arrayidx5 = getelementptr inbounds float, float* %7, i64 %idxprom4
  %8 = load float, float* %arrayidx5, align 4
  %9 = load i32, i32* %j, align 4
  %idxprom6 = sext i32 %9 to i64
  %10 = load float*, float** %y1.addr, align 8
  %arrayidx7 = getelementptr inbounds float, float* %10, i64 %idxprom6
  %11 = load float, float* %arrayidx7, align 4
  %mul8 = fmul float %8, %11
  %add9 = fadd float %4, %mul8
  %12 = load i32, i32* %i, align 4
  %idxprom10 = sext i32 %12 to i64
  %13 = load float*, float** %x1.addr, align 8
  %arrayidx11 = getelementptr inbounds float, float* %13, i64 %idxprom10
  store float %add9, float* %arrayidx11, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.3
  %14 = load i32, i32* %j, align 4
  %inc = add nsw i32 %14, 1
  store i32 %inc, i32* %j, align 4
  br label %for.cond.1

for.end:                                          ; preds = %for.cond.1
  br label %for.inc.12

for.inc.12:                                       ; preds = %for.end
  %15 = load i32, i32* %i, align 4
  %inc13 = add nsw i32 %15, 1
  store i32 %inc13, i32* %i, align 4
  br label %for.cond

for.end.14:                                       ; preds = %for.cond
  store i32 0, i32* %i, align 4
  br label %for.cond.15

for.cond.15:                                      ; preds = %for.inc.37, %for.end.14
  %16 = load i32, i32* %i, align 4
  %cmp16 = icmp slt i32 %16, 4096
  br i1 %cmp16, label %for.body.17, label %for.end.39

for.body.17:                                      ; preds = %for.cond.15
  store i32 0, i32* %j18, align 4
  br label %for.cond.19

for.cond.19:                                      ; preds = %for.inc.34, %for.body.17
  %17 = load i32, i32* %j18, align 4
  %cmp20 = icmp slt i32 %17, 4096
  br i1 %cmp20, label %for.body.21, label %for.end.36

for.body.21:                                      ; preds = %for.cond.19
  %18 = load i32, i32* %i, align 4
  %idxprom22 = sext i32 %18 to i64
  %19 = load float*, float** %x2.addr, align 8
  %arrayidx23 = getelementptr inbounds float, float* %19, i64 %idxprom22
  %20 = load float, float* %arrayidx23, align 4
  %21 = load i32, i32* %j18, align 4
  %mul24 = mul nsw i32 %21, 4096
  %22 = load i32, i32* %i, align 4
  %add25 = add nsw i32 %mul24, %22
  %idxprom26 = sext i32 %add25 to i64
  %23 = load float*, float** %a.addr, align 8
  %arrayidx27 = getelementptr inbounds float, float* %23, i64 %idxprom26
  %24 = load float, float* %arrayidx27, align 4
  %25 = load i32, i32* %j18, align 4
  %idxprom28 = sext i32 %25 to i64
  %26 = load float*, float** %y2.addr, align 8
  %arrayidx29 = getelementptr inbounds float, float* %26, i64 %idxprom28
  %27 = load float, float* %arrayidx29, align 4
  %mul30 = fmul float %24, %27
  %add31 = fadd float %20, %mul30
  %28 = load i32, i32* %i, align 4
  %idxprom32 = sext i32 %28 to i64
  %29 = load float*, float** %x2.addr, align 8
  %arrayidx33 = getelementptr inbounds float, float* %29, i64 %idxprom32
  store float %add31, float* %arrayidx33, align 4
  br label %for.inc.34

for.inc.34:                                       ; preds = %for.body.21
  %30 = load i32, i32* %j18, align 4
  %inc35 = add nsw i32 %30, 1
  store i32 %inc35, i32* %j18, align 4
  br label %for.cond.19

for.end.36:                                       ; preds = %for.cond.19
  br label %for.inc.37

for.inc.37:                                       ; preds = %for.end.36
  %31 = load i32, i32* %i, align 4
  %inc38 = add nsw i32 %31, 1
  store i32 %inc38, i32* %i, align 4
  br label %for.cond.15

for.end.39:                                       ; preds = %for.cond.15
  ret void
}

; Function Attrs: nounwind uwtable
define void @compareResults(float* %x1, float* %x1_outputFromGpu, float* %x2, float* %x2_outputFromGpu) #0 {
entry:
  %x1.addr = alloca float*, align 8
  %x1_outputFromGpu.addr = alloca float*, align 8
  %x2.addr = alloca float*, align 8
  %x2_outputFromGpu.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %fail = alloca i32, align 4
  store float* %x1, float** %x1.addr, align 8
  store float* %x1_outputFromGpu, float** %x1_outputFromGpu.addr, align 8
  store float* %x2, float** %x2.addr, align 8
  store float* %x2_outputFromGpu, float** %x2_outputFromGpu.addr, align 8
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
  %2 = load float*, float** %x1.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %2, i64 %idxprom
  %3 = load float, float* %arrayidx, align 4
  %conv = fpext float %3 to double
  %4 = load i32, i32* %i, align 4
  %idxprom1 = sext i32 %4 to i64
  %5 = load float*, float** %x1_outputFromGpu.addr, align 8
  %arrayidx2 = getelementptr inbounds float, float* %5, i64 %idxprom1
  %6 = load float, float* %arrayidx2, align 4
  %conv3 = fpext float %6 to double
  %call = call float @percentDiff(double %conv, double %conv3)
  %conv4 = fpext float %call to double
  %cmp5 = fcmp ogt double %conv4, 5.000000e-02
  br i1 %cmp5, label %if.then, label %if.end

if.then:                                          ; preds = %for.body
  %7 = load i32, i32* %fail, align 4
  %inc = add nsw i32 %7, 1
  store i32 %inc, i32* %fail, align 4
  br label %if.end

if.end:                                           ; preds = %if.then, %for.body
  %8 = load i32, i32* %i, align 4
  %idxprom7 = sext i32 %8 to i64
  %9 = load float*, float** %x2.addr, align 8
  %arrayidx8 = getelementptr inbounds float, float* %9, i64 %idxprom7
  %10 = load float, float* %arrayidx8, align 4
  %conv9 = fpext float %10 to double
  %11 = load i32, i32* %i, align 4
  %idxprom10 = sext i32 %11 to i64
  %12 = load float*, float** %x2_outputFromGpu.addr, align 8
  %arrayidx11 = getelementptr inbounds float, float* %12, i64 %idxprom10
  %13 = load float, float* %arrayidx11, align 4
  %conv12 = fpext float %13 to double
  %call13 = call float @percentDiff(double %conv9, double %conv12)
  %conv14 = fpext float %call13 to double
  %cmp15 = fcmp ogt double %conv14, 5.000000e-02
  br i1 %cmp15, label %if.then.17, label %if.end.19

if.then.17:                                       ; preds = %if.end
  %14 = load i32, i32* %fail, align 4
  %inc18 = add nsw i32 %14, 1
  store i32 %inc18, i32* %fail, align 4
  br label %if.end.19

if.end.19:                                        ; preds = %if.then.17, %if.end
  br label %for.inc

for.inc:                                          ; preds = %if.end.19
  %15 = load i32, i32* %i, align 4
  %inc20 = add nsw i32 %15, 1
  store i32 %inc20, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  %16 = load i32, i32* %fail, align 4
  %call21 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([74 x i8], [74 x i8]* @.str.1, i32 0, i32 0), double 5.000000e-02, i32 %16)
  ret void
}

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
entry:
  %retval = alloca i32, align 4
  %t_start = alloca double, align 8
  %t_end = alloca double, align 8
  %a = alloca float*, align 8
  %x1 = alloca float*, align 8
  %x2 = alloca float*, align 8
  %x1_outputFromGpu = alloca float*, align 8
  %x2_outputFromGpu = alloca float*, align 8
  %y_1 = alloca float*, align 8
  %y_2 = alloca float*, align 8
  store i32 0, i32* %retval
  %call = call noalias i8* @malloc(i64 67108864) #3
  %0 = bitcast i8* %call to float*
  store float* %0, float** %a, align 8
  %call1 = call noalias i8* @malloc(i64 16384) #3
  %1 = bitcast i8* %call1 to float*
  store float* %1, float** %x1, align 8
  %call2 = call noalias i8* @malloc(i64 16384) #3
  %2 = bitcast i8* %call2 to float*
  store float* %2, float** %x2, align 8
  %call3 = call noalias i8* @malloc(i64 16384) #3
  %3 = bitcast i8* %call3 to float*
  store float* %3, float** %x1_outputFromGpu, align 8
  %call4 = call noalias i8* @malloc(i64 16384) #3
  %4 = bitcast i8* %call4 to float*
  store float* %4, float** %x2_outputFromGpu, align 8
  %call5 = call noalias i8* @malloc(i64 16384) #3
  %5 = bitcast i8* %call5 to float*
  store float* %5, float** %y_1, align 8
  %call6 = call noalias i8* @malloc(i64 16384) #3
  %6 = bitcast i8* %call6 to float*
  store float* %6, float** %y_2, align 8
  %7 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %call7 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %7, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @.str.2, i32 0, i32 0))
  %8 = load float*, float** %a, align 8
  %9 = load float*, float** %x1, align 8
  %10 = load float*, float** %x2, align 8
  %11 = load float*, float** %y_1, align 8
  %12 = load float*, float** %y_2, align 8
  %13 = load float*, float** %x1_outputFromGpu, align 8
  %14 = load float*, float** %x2_outputFromGpu, align 8
  call void @init_array(float* %8, float* %9, float* %10, float* %11, float* %12, float* %13, float* %14)
  %call8 = call double @rtclock()
  store double %call8, double* %t_start, align 8
  %15 = load float*, float** %a, align 8
  %16 = load float*, float** %x1_outputFromGpu, align 8
  %17 = load float*, float** %x2_outputFromGpu, align 8
  %18 = load float*, float** %y_1, align 8
  %19 = load float*, float** %y_2, align 8
  call void @GPU__runMvt(float* %15, float* %16, float* %17, float* %18, float* %19)
  %call9 = call double @rtclock()
  store double %call9, double* %t_end, align 8
  %20 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %21 = load double, double* %t_end, align 8
  %22 = load double, double* %t_start, align 8
  %sub = fsub double %21, %22
  %call10 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %20, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.3, i32 0, i32 0), double %sub)
  %call11 = call double @rtclock()
  store double %call11, double* %t_start, align 8
  %23 = load float*, float** %a, align 8
  %24 = load float*, float** %x1, align 8
  %25 = load float*, float** %x2, align 8
  %26 = load float*, float** %y_1, align 8
  %27 = load float*, float** %y_2, align 8
  call void @runMvt(float* %23, float* %24, float* %25, float* %26, float* %27)
  %call12 = call double @rtclock()
  store double %call12, double* %t_end, align 8
  %28 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %29 = load double, double* %t_end, align 8
  %30 = load double, double* %t_start, align 8
  %sub13 = fsub double %29, %30
  %call14 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %28, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.4, i32 0, i32 0), double %sub13)
  %31 = load float*, float** %x1, align 8
  %32 = load float*, float** %x1_outputFromGpu, align 8
  %33 = load float*, float** %x2, align 8
  %34 = load float*, float** %x2_outputFromGpu, align 8
  call void @compareResults(float* %31, float* %32, float* %33, float* %34)
  %35 = load float*, float** %a, align 8
  %36 = bitcast float* %35 to i8*
  call void @free(i8* %36) #3
  %37 = load float*, float** %x1, align 8
  %38 = bitcast float* %37 to i8*
  call void @free(i8* %38) #3
  %39 = load float*, float** %x2, align 8
  %40 = bitcast float* %39 to i8*
  call void @free(i8* %40) #3
  %41 = load float*, float** %x1_outputFromGpu, align 8
  %42 = bitcast float* %41 to i8*
  call void @free(i8* %42) #3
  %43 = load float*, float** %x2_outputFromGpu, align 8
  %44 = bitcast float* %43 to i8*
  call void @free(i8* %44) #3
  %45 = load float*, float** %y_1, align 8
  %46 = bitcast float* %45 to i8*
  call void @free(i8* %46) #3
  %47 = load float*, float** %y_2, align 8
  %48 = bitcast float* %47 to i8*
  call void @free(i8* %48) #3
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
