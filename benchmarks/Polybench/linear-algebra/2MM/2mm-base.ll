; ModuleID = '2mm.c'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, i8*, i8*, i8*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type { %struct._IO_marker*, %struct._IO_FILE*, i32 }
%struct.timezone = type { i32, i32 }
%struct.timeval = type { i64, i64 }

@.str = private unnamed_addr constant [35 x i8] c"Error return from gettimeofday: %d\00", align 1
@.str.1 = private unnamed_addr constant [74 x i8] c"Non-Matching CPU-GPU Outputs Beyond Error Threshold of %4.2f Percent: %d\0A\00", align 1
@stdout = external global %struct._IO_FILE*, align 8
@.str.2 = private unnamed_addr constant [63 x i8] c"<< Linear Algebra: 2 Matrix Multiplications (D=A.B; E=C.D) >>\0A\00", align 1
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
define void @init_array(float* %A, float* %B, float* %C, float* %D) #0 {
entry:
  %A.addr = alloca float*, align 8
  %B.addr = alloca float*, align 8
  %C.addr = alloca float*, align 8
  %D.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  store float* %A, float** %A.addr, align 8
  store float* %B, float** %B.addr, align 8
  store float* %C, float** %C.addr, align 8
  store float* %D, float** %D.addr, align 8
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.6, %entry
  %0 = load i32, i32* %i, align 4
  %cmp = icmp slt i32 %0, 1500
  br i1 %cmp, label %for.body, label %for.end.8

for.body:                                         ; preds = %for.cond
  store i32 0, i32* %j, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %1 = load i32, i32* %j, align 4
  %cmp2 = icmp slt i32 %1, 1500
  br i1 %cmp2, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.cond.1
  %2 = load i32, i32* %i, align 4
  %conv = sitofp i32 %2 to float
  %3 = load i32, i32* %j, align 4
  %conv4 = sitofp i32 %3 to float
  %mul = fmul float %conv, %conv4
  %div = fdiv float %mul, 1.500000e+03
  %4 = load i32, i32* %i, align 4
  %mul5 = mul nsw i32 %4, 1500
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
  %cmp10 = icmp slt i32 %9, 1500
  br i1 %cmp10, label %for.body.12, label %for.end.31

for.body.12:                                      ; preds = %for.cond.9
  store i32 0, i32* %j, align 4
  br label %for.cond.13

for.cond.13:                                      ; preds = %for.inc.26, %for.body.12
  %10 = load i32, i32* %j, align 4
  %cmp14 = icmp slt i32 %10, 1500
  br i1 %cmp14, label %for.body.16, label %for.end.28

for.body.16:                                      ; preds = %for.cond.13
  %11 = load i32, i32* %i, align 4
  %conv17 = sitofp i32 %11 to float
  %12 = load i32, i32* %j, align 4
  %add18 = add nsw i32 %12, 1
  %conv19 = sitofp i32 %add18 to float
  %mul20 = fmul float %conv17, %conv19
  %div21 = fdiv float %mul20, 1.500000e+03
  %13 = load i32, i32* %i, align 4
  %mul22 = mul nsw i32 %13, 1500
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

for.cond.32:                                      ; preds = %for.inc.52, %for.end.31
  %18 = load i32, i32* %i, align 4
  %cmp33 = icmp slt i32 %18, 1500
  br i1 %cmp33, label %for.body.35, label %for.end.54

for.body.35:                                      ; preds = %for.cond.32
  store i32 0, i32* %j, align 4
  br label %for.cond.36

for.cond.36:                                      ; preds = %for.inc.49, %for.body.35
  %19 = load i32, i32* %j, align 4
  %cmp37 = icmp slt i32 %19, 1500
  br i1 %cmp37, label %for.body.39, label %for.end.51

for.body.39:                                      ; preds = %for.cond.36
  %20 = load i32, i32* %i, align 4
  %conv40 = sitofp i32 %20 to float
  %21 = load i32, i32* %j, align 4
  %add41 = add nsw i32 %21, 3
  %conv42 = sitofp i32 %add41 to float
  %mul43 = fmul float %conv40, %conv42
  %div44 = fdiv float %mul43, 1.500000e+03
  %22 = load i32, i32* %i, align 4
  %mul45 = mul nsw i32 %22, 1500
  %23 = load i32, i32* %j, align 4
  %add46 = add nsw i32 %mul45, %23
  %idxprom47 = sext i32 %add46 to i64
  %24 = load float*, float** %C.addr, align 8
  %arrayidx48 = getelementptr inbounds float, float* %24, i64 %idxprom47
  store float %div44, float* %arrayidx48, align 4
  br label %for.inc.49

for.inc.49:                                       ; preds = %for.body.39
  %25 = load i32, i32* %j, align 4
  %inc50 = add nsw i32 %25, 1
  store i32 %inc50, i32* %j, align 4
  br label %for.cond.36

for.end.51:                                       ; preds = %for.cond.36
  br label %for.inc.52

for.inc.52:                                       ; preds = %for.end.51
  %26 = load i32, i32* %i, align 4
  %inc53 = add nsw i32 %26, 1
  store i32 %inc53, i32* %i, align 4
  br label %for.cond.32

for.end.54:                                       ; preds = %for.cond.32
  store i32 0, i32* %i, align 4
  br label %for.cond.55

for.cond.55:                                      ; preds = %for.inc.75, %for.end.54
  %27 = load i32, i32* %i, align 4
  %cmp56 = icmp slt i32 %27, 1500
  br i1 %cmp56, label %for.body.58, label %for.end.77

for.body.58:                                      ; preds = %for.cond.55
  store i32 0, i32* %j, align 4
  br label %for.cond.59

for.cond.59:                                      ; preds = %for.inc.72, %for.body.58
  %28 = load i32, i32* %j, align 4
  %cmp60 = icmp slt i32 %28, 1500
  br i1 %cmp60, label %for.body.62, label %for.end.74

for.body.62:                                      ; preds = %for.cond.59
  %29 = load i32, i32* %i, align 4
  %conv63 = sitofp i32 %29 to float
  %30 = load i32, i32* %j, align 4
  %add64 = add nsw i32 %30, 2
  %conv65 = sitofp i32 %add64 to float
  %mul66 = fmul float %conv63, %conv65
  %div67 = fdiv float %mul66, 1.500000e+03
  %31 = load i32, i32* %i, align 4
  %mul68 = mul nsw i32 %31, 1500
  %32 = load i32, i32* %j, align 4
  %add69 = add nsw i32 %mul68, %32
  %idxprom70 = sext i32 %add69 to i64
  %33 = load float*, float** %D.addr, align 8
  %arrayidx71 = getelementptr inbounds float, float* %33, i64 %idxprom70
  store float %div67, float* %arrayidx71, align 4
  br label %for.inc.72

for.inc.72:                                       ; preds = %for.body.62
  %34 = load i32, i32* %j, align 4
  %inc73 = add nsw i32 %34, 1
  store i32 %inc73, i32* %j, align 4
  br label %for.cond.59

for.end.74:                                       ; preds = %for.cond.59
  br label %for.inc.75

for.inc.75:                                       ; preds = %for.end.74
  %35 = load i32, i32* %i, align 4
  %inc76 = add nsw i32 %35, 1
  store i32 %inc76, i32* %i, align 4
  br label %for.cond.55

for.end.77:                                       ; preds = %for.cond.55
  ret void
}

; Function Attrs: nounwind uwtable
define void @compareResults(float* %E, float* %E_GPU) #0 {
entry:
  %E.addr = alloca float*, align 8
  %E_GPU.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %fail = alloca i32, align 4
  store float* %E, float** %E.addr, align 8
  store float* %E_GPU, float** %E_GPU.addr, align 8
  store i32 0, i32* %fail, align 4
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.13, %entry
  %0 = load i32, i32* %i, align 4
  %cmp = icmp slt i32 %0, 1500
  br i1 %cmp, label %for.body, label %for.end.15

for.body:                                         ; preds = %for.cond
  store i32 0, i32* %j, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %1 = load i32, i32* %j, align 4
  %cmp2 = icmp slt i32 %1, 1500
  br i1 %cmp2, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.cond.1
  %2 = load i32, i32* %i, align 4
  %mul = mul nsw i32 %2, 1500
  %3 = load i32, i32* %j, align 4
  %add = add nsw i32 %mul, %3
  %idxprom = sext i32 %add to i64
  %4 = load float*, float** %E.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %4, i64 %idxprom
  %5 = load float, float* %arrayidx, align 4
  %conv = fpext float %5 to double
  %6 = load i32, i32* %i, align 4
  %mul4 = mul nsw i32 %6, 1500
  %7 = load i32, i32* %j, align 4
  %add5 = add nsw i32 %mul4, %7
  %idxprom6 = sext i32 %add5 to i64
  %8 = load float*, float** %E_GPU.addr, align 8
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
define void @mm2(float* %A, float* %B, float* %C, float* %D, float* %E) #0 {
entry:
  %A.addr = alloca float*, align 8
  %B.addr = alloca float*, align 8
  %C.addr = alloca float*, align 8
  %D.addr = alloca float*, align 8
  %E.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %k = alloca i32, align 4
  store float* %A, float** %A.addr, align 8
  store float* %B, float** %B.addr, align 8
  store float* %C, float** %C.addr, align 8
  store float* %D, float** %D.addr, align 8
  store float* %E, float** %E.addr, align 8
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.24, %entry
  %0 = load i32, i32* %i, align 4
  %cmp = icmp slt i32 %0, 1500
  br i1 %cmp, label %for.body, label %for.end.26

for.body:                                         ; preds = %for.cond
  store i32 0, i32* %j, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc.21, %for.body
  %1 = load i32, i32* %j, align 4
  %cmp2 = icmp slt i32 %1, 1500
  br i1 %cmp2, label %for.body.3, label %for.end.23

for.body.3:                                       ; preds = %for.cond.1
  %2 = load i32, i32* %i, align 4
  %mul = mul nsw i32 %2, 1500
  %3 = load i32, i32* %j, align 4
  %add = add nsw i32 %mul, %3
  %idxprom = sext i32 %add to i64
  %4 = load float*, float** %C.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %4, i64 %idxprom
  store float 0.000000e+00, float* %arrayidx, align 4
  store i32 0, i32* %k, align 4
  br label %for.cond.4

for.cond.4:                                       ; preds = %for.inc, %for.body.3
  %5 = load i32, i32* %k, align 4
  %cmp5 = icmp slt i32 %5, 1500
  br i1 %cmp5, label %for.body.6, label %for.end

for.body.6:                                       ; preds = %for.cond.4
  %6 = load i32, i32* %i, align 4
  %mul7 = mul nsw i32 %6, 1500
  %7 = load i32, i32* %k, align 4
  %add8 = add nsw i32 %mul7, %7
  %idxprom9 = sext i32 %add8 to i64
  %8 = load float*, float** %A.addr, align 8
  %arrayidx10 = getelementptr inbounds float, float* %8, i64 %idxprom9
  %9 = load float, float* %arrayidx10, align 4
  %10 = load i32, i32* %k, align 4
  %mul11 = mul nsw i32 %10, 1500
  %11 = load i32, i32* %j, align 4
  %add12 = add nsw i32 %mul11, %11
  %idxprom13 = sext i32 %add12 to i64
  %12 = load float*, float** %B.addr, align 8
  %arrayidx14 = getelementptr inbounds float, float* %12, i64 %idxprom13
  %13 = load float, float* %arrayidx14, align 4
  %mul15 = fmul float %9, %13
  %14 = load i32, i32* %i, align 4
  %mul16 = mul nsw i32 %14, 1500
  %15 = load i32, i32* %j, align 4
  %add17 = add nsw i32 %mul16, %15
  %idxprom18 = sext i32 %add17 to i64
  %16 = load float*, float** %C.addr, align 8
  %arrayidx19 = getelementptr inbounds float, float* %16, i64 %idxprom18
  %17 = load float, float* %arrayidx19, align 4
  %add20 = fadd float %17, %mul15
  store float %add20, float* %arrayidx19, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.6
  %18 = load i32, i32* %k, align 4
  %inc = add nsw i32 %18, 1
  store i32 %inc, i32* %k, align 4
  br label %for.cond.4

for.end:                                          ; preds = %for.cond.4
  br label %for.inc.21

for.inc.21:                                       ; preds = %for.end
  %19 = load i32, i32* %j, align 4
  %inc22 = add nsw i32 %19, 1
  store i32 %inc22, i32* %j, align 4
  br label %for.cond.1

for.end.23:                                       ; preds = %for.cond.1
  br label %for.inc.24

for.inc.24:                                       ; preds = %for.end.23
  %20 = load i32, i32* %i, align 4
  %inc25 = add nsw i32 %20, 1
  store i32 %inc25, i32* %i, align 4
  br label %for.cond

for.end.26:                                       ; preds = %for.cond
  store i32 0, i32* %i, align 4
  br label %for.cond.27

for.cond.27:                                      ; preds = %for.inc.60, %for.end.26
  %21 = load i32, i32* %i, align 4
  %cmp28 = icmp slt i32 %21, 1500
  br i1 %cmp28, label %for.body.29, label %for.end.62

for.body.29:                                      ; preds = %for.cond.27
  store i32 0, i32* %j, align 4
  br label %for.cond.30

for.cond.30:                                      ; preds = %for.inc.57, %for.body.29
  %22 = load i32, i32* %j, align 4
  %cmp31 = icmp slt i32 %22, 1500
  br i1 %cmp31, label %for.body.32, label %for.end.59

for.body.32:                                      ; preds = %for.cond.30
  %23 = load i32, i32* %i, align 4
  %mul33 = mul nsw i32 %23, 1500
  %24 = load i32, i32* %j, align 4
  %add34 = add nsw i32 %mul33, %24
  %idxprom35 = sext i32 %add34 to i64
  %25 = load float*, float** %E.addr, align 8
  %arrayidx36 = getelementptr inbounds float, float* %25, i64 %idxprom35
  store float 0.000000e+00, float* %arrayidx36, align 4
  store i32 0, i32* %k, align 4
  br label %for.cond.37

for.cond.37:                                      ; preds = %for.inc.54, %for.body.32
  %26 = load i32, i32* %k, align 4
  %cmp38 = icmp slt i32 %26, 1500
  br i1 %cmp38, label %for.body.39, label %for.end.56

for.body.39:                                      ; preds = %for.cond.37
  %27 = load i32, i32* %i, align 4
  %mul40 = mul nsw i32 %27, 1500
  %28 = load i32, i32* %k, align 4
  %add41 = add nsw i32 %mul40, %28
  %idxprom42 = sext i32 %add41 to i64
  %29 = load float*, float** %C.addr, align 8
  %arrayidx43 = getelementptr inbounds float, float* %29, i64 %idxprom42
  %30 = load float, float* %arrayidx43, align 4
  %31 = load i32, i32* %k, align 4
  %mul44 = mul nsw i32 %31, 1500
  %32 = load i32, i32* %j, align 4
  %add45 = add nsw i32 %mul44, %32
  %idxprom46 = sext i32 %add45 to i64
  %33 = load float*, float** %D.addr, align 8
  %arrayidx47 = getelementptr inbounds float, float* %33, i64 %idxprom46
  %34 = load float, float* %arrayidx47, align 4
  %mul48 = fmul float %30, %34
  %35 = load i32, i32* %i, align 4
  %mul49 = mul nsw i32 %35, 1500
  %36 = load i32, i32* %j, align 4
  %add50 = add nsw i32 %mul49, %36
  %idxprom51 = sext i32 %add50 to i64
  %37 = load float*, float** %E.addr, align 8
  %arrayidx52 = getelementptr inbounds float, float* %37, i64 %idxprom51
  %38 = load float, float* %arrayidx52, align 4
  %add53 = fadd float %38, %mul48
  store float %add53, float* %arrayidx52, align 4
  br label %for.inc.54

for.inc.54:                                       ; preds = %for.body.39
  %39 = load i32, i32* %k, align 4
  %inc55 = add nsw i32 %39, 1
  store i32 %inc55, i32* %k, align 4
  br label %for.cond.37

for.end.56:                                       ; preds = %for.cond.37
  br label %for.inc.57

for.inc.57:                                       ; preds = %for.end.56
  %40 = load i32, i32* %j, align 4
  %inc58 = add nsw i32 %40, 1
  store i32 %inc58, i32* %j, align 4
  br label %for.cond.30

for.end.59:                                       ; preds = %for.cond.30
  br label %for.inc.60

for.inc.60:                                       ; preds = %for.end.59
  %41 = load i32, i32* %i, align 4
  %inc61 = add nsw i32 %41, 1
  store i32 %inc61, i32* %i, align 4
  br label %for.cond.27

for.end.62:                                       ; preds = %for.cond.27
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
  %t_start_GPU = alloca double, align 8
  %t_end_GPU = alloca double, align 8
  %C = alloca float*, align 8
  %A = alloca float*, align 8
  %B = alloca float*, align 8
  %D = alloca float*, align 8
  %E = alloca float*, align 8
  %E_GPU = alloca float*, align 8
  store i32 0, i32* %retval
  store i32 %argc, i32* %argc.addr, align 4
  store i8** %argv, i8*** %argv.addr, align 8
  %call = call noalias i8* @malloc(i64 9000000) #3
  %0 = bitcast i8* %call to float*
  store float* %0, float** %C, align 8
  %call1 = call noalias i8* @malloc(i64 9000000) #3
  %1 = bitcast i8* %call1 to float*
  store float* %1, float** %A, align 8
  %call2 = call noalias i8* @malloc(i64 9000000) #3
  %2 = bitcast i8* %call2 to float*
  store float* %2, float** %B, align 8
  %call3 = call noalias i8* @malloc(i64 9000000) #3
  %3 = bitcast i8* %call3 to float*
  store float* %3, float** %D, align 8
  %call4 = call noalias i8* @malloc(i64 9000000) #3
  %4 = bitcast i8* %call4 to float*
  store float* %4, float** %E, align 8
  %call5 = call noalias i8* @malloc(i64 9000000) #3
  %5 = bitcast i8* %call5 to float*
  store float* %5, float** %E_GPU, align 8
  %6 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %call6 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %6, i8* getelementptr inbounds ([63 x i8], [63 x i8]* @.str.2, i32 0, i32 0))
  %7 = load float*, float** %A, align 8
  %8 = load float*, float** %B, align 8
  %9 = load float*, float** %C, align 8
  %10 = load float*, float** %D, align 8
  call void @init_array(float* %7, float* %8, float* %9, float* %10)
  %call7 = call double @rtclock()
  store double %call7, double* %t_start, align 8
  %11 = load float*, float** %A, align 8
  %12 = load float*, float** %B, align 8
  %13 = load float*, float** %C, align 8
  %14 = load float*, float** %D, align 8
  %15 = load float*, float** %E, align 8
  call void @mm2(float* %11, float* %12, float* %13, float* %14, float* %15)
  %call8 = call double @rtclock()
  store double %call8, double* %t_end, align 8
  %16 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %17 = load double, double* %t_end, align 8
  %18 = load double, double* %t_start, align 8
  %sub = fsub double %17, %18
  %call9 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %16, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.3, i32 0, i32 0), double %sub)
  %19 = load float*, float** %E, align 8
  %20 = load float*, float** %E_GPU, align 8
  call void @compareResults(float* %19, float* %20)
  %21 = load float*, float** %C, align 8
  %22 = bitcast float* %21 to i8*
  call void @free(i8* %22) #3
  %23 = load float*, float** %A, align 8
  %24 = bitcast float* %23 to i8*
  call void @free(i8* %24) #3
  %25 = load float*, float** %B, align 8
  %26 = bitcast float* %25 to i8*
  call void @free(i8* %26) #3
  %27 = load float*, float** %D, align 8
  %28 = bitcast float* %27 to i8*
  call void @free(i8* %28) #3
  %29 = load float*, float** %E, align 8
  %30 = bitcast float* %29 to i8*
  call void @free(i8* %30) #3
  %31 = load float*, float** %E_GPU, align 8
  %32 = bitcast float* %31 to i8*
  call void @free(i8* %32) #3
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
