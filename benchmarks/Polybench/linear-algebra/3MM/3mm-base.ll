; ModuleID = '3mm.c'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, i8*, i8*, i8*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type { %struct._IO_marker*, %struct._IO_FILE*, i32 }
%struct.timezone = type { i32, i32 }
%struct.timeval = type { i64, i64 }

@.str = private unnamed_addr constant [35 x i8] c"Error return from gettimeofday: %d\00", align 1
@.str.1 = private unnamed_addr constant [74 x i8] c"Non-Matching CPU-GPU Outputs Beyond Error Threshold of %4.2f Percent: %d\0A\00", align 1
@stdout = external global %struct._IO_FILE*, align 8
@.str.2 = private unnamed_addr constant [70 x i8] c"<< Linear Algebra: 3 Matrix Multiplications (E=A.B; F=C.D; G=E.F) >>\0A\00", align 1
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
define void @init_array(double* %A, double* %B, double* %C, double* %D) #0 {
entry:
  %A.addr = alloca double*, align 8
  %B.addr = alloca double*, align 8
  %C.addr = alloca double*, align 8
  %D.addr = alloca double*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  store double* %A, double** %A.addr, align 8
  store double* %B, double** %B.addr, align 8
  store double* %C, double** %C.addr, align 8
  store double* %D, double** %D.addr, align 8
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.6, %entry
  %0 = load i32, i32* %i, align 4
  %cmp = icmp slt i32 %0, 800
  br i1 %cmp, label %for.body, label %for.end.8

for.body:                                         ; preds = %for.cond
  store i32 0, i32* %j, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %1 = load i32, i32* %j, align 4
  %cmp2 = icmp slt i32 %1, 1000
  br i1 %cmp2, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.cond.1
  %2 = load i32, i32* %i, align 4
  %conv = sitofp i32 %2 to double
  %3 = load i32, i32* %j, align 4
  %conv4 = sitofp i32 %3 to double
  %mul = fmul double %conv, %conv4
  %div = fdiv double %mul, 8.000000e+02
  %4 = load i32, i32* %i, align 4
  %mul5 = mul nsw i32 %4, 1000
  %5 = load i32, i32* %j, align 4
  %add = add nsw i32 %mul5, %5
  %idxprom = sext i32 %add to i64
  %6 = load double*, double** %A.addr, align 8
  %arrayidx = getelementptr inbounds double, double* %6, i64 %idxprom
  store double %div, double* %arrayidx, align 8
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
  %cmp10 = icmp slt i32 %9, 1000
  br i1 %cmp10, label %for.body.12, label %for.end.31

for.body.12:                                      ; preds = %for.cond.9
  store i32 0, i32* %j, align 4
  br label %for.cond.13

for.cond.13:                                      ; preds = %for.inc.26, %for.body.12
  %10 = load i32, i32* %j, align 4
  %cmp14 = icmp slt i32 %10, 900
  br i1 %cmp14, label %for.body.16, label %for.end.28

for.body.16:                                      ; preds = %for.cond.13
  %11 = load i32, i32* %i, align 4
  %conv17 = sitofp i32 %11 to double
  %12 = load i32, i32* %j, align 4
  %add18 = add nsw i32 %12, 1
  %conv19 = sitofp i32 %add18 to double
  %mul20 = fmul double %conv17, %conv19
  %div21 = fdiv double %mul20, 9.000000e+02
  %13 = load i32, i32* %i, align 4
  %mul22 = mul nsw i32 %13, 900
  %14 = load i32, i32* %j, align 4
  %add23 = add nsw i32 %mul22, %14
  %idxprom24 = sext i32 %add23 to i64
  %15 = load double*, double** %B.addr, align 8
  %arrayidx25 = getelementptr inbounds double, double* %15, i64 %idxprom24
  store double %div21, double* %arrayidx25, align 8
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
  %cmp33 = icmp slt i32 %18, 900
  br i1 %cmp33, label %for.body.35, label %for.end.54

for.body.35:                                      ; preds = %for.cond.32
  store i32 0, i32* %j, align 4
  br label %for.cond.36

for.cond.36:                                      ; preds = %for.inc.49, %for.body.35
  %19 = load i32, i32* %j, align 4
  %cmp37 = icmp slt i32 %19, 1200
  br i1 %cmp37, label %for.body.39, label %for.end.51

for.body.39:                                      ; preds = %for.cond.36
  %20 = load i32, i32* %i, align 4
  %conv40 = sitofp i32 %20 to double
  %21 = load i32, i32* %j, align 4
  %add41 = add nsw i32 %21, 3
  %conv42 = sitofp i32 %add41 to double
  %mul43 = fmul double %conv40, %conv42
  %div44 = fdiv double %mul43, 1.100000e+03
  %22 = load i32, i32* %i, align 4
  %mul45 = mul nsw i32 %22, 1200
  %23 = load i32, i32* %j, align 4
  %add46 = add nsw i32 %mul45, %23
  %idxprom47 = sext i32 %add46 to i64
  %24 = load double*, double** %C.addr, align 8
  %arrayidx48 = getelementptr inbounds double, double* %24, i64 %idxprom47
  store double %div44, double* %arrayidx48, align 8
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
  %cmp56 = icmp slt i32 %27, 1200
  br i1 %cmp56, label %for.body.58, label %for.end.77

for.body.58:                                      ; preds = %for.cond.55
  store i32 0, i32* %j, align 4
  br label %for.cond.59

for.cond.59:                                      ; preds = %for.inc.72, %for.body.58
  %28 = load i32, i32* %j, align 4
  %cmp60 = icmp slt i32 %28, 1100
  br i1 %cmp60, label %for.body.62, label %for.end.74

for.body.62:                                      ; preds = %for.cond.59
  %29 = load i32, i32* %i, align 4
  %conv63 = sitofp i32 %29 to double
  %30 = load i32, i32* %j, align 4
  %add64 = add nsw i32 %30, 2
  %conv65 = sitofp i32 %add64 to double
  %mul66 = fmul double %conv63, %conv65
  %div67 = fdiv double %mul66, 1.000000e+03
  %31 = load i32, i32* %i, align 4
  %mul68 = mul nsw i32 %31, 1100
  %32 = load i32, i32* %j, align 4
  %add69 = add nsw i32 %mul68, %32
  %idxprom70 = sext i32 %add69 to i64
  %33 = load double*, double** %D.addr, align 8
  %arrayidx71 = getelementptr inbounds double, double* %33, i64 %idxprom70
  store double %div67, double* %arrayidx71, align 8
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
define void @compareResults(double* %G, double* %G_outputFromGpu) #0 {
entry:
  %G.addr = alloca double*, align 8
  %G_outputFromGpu.addr = alloca double*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %fail = alloca i32, align 4
  store double* %G, double** %G.addr, align 8
  store double* %G_outputFromGpu, double** %G_outputFromGpu.addr, align 8
  store i32 0, i32* %fail, align 4
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.11, %entry
  %0 = load i32, i32* %i, align 4
  %cmp = icmp slt i32 %0, 800
  br i1 %cmp, label %for.body, label %for.end.13

for.body:                                         ; preds = %for.cond
  store i32 0, i32* %j, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %1 = load i32, i32* %j, align 4
  %cmp2 = icmp slt i32 %1, 1100
  br i1 %cmp2, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.cond.1
  %2 = load i32, i32* %i, align 4
  %mul = mul nsw i32 %2, 1100
  %3 = load i32, i32* %j, align 4
  %add = add nsw i32 %mul, %3
  %idxprom = sext i32 %add to i64
  %4 = load double*, double** %G.addr, align 8
  %arrayidx = getelementptr inbounds double, double* %4, i64 %idxprom
  %5 = load double, double* %arrayidx, align 8
  %6 = load i32, i32* %i, align 4
  %mul4 = mul nsw i32 %6, 1100
  %7 = load i32, i32* %j, align 4
  %add5 = add nsw i32 %mul4, %7
  %idxprom6 = sext i32 %add5 to i64
  %8 = load double*, double** %G_outputFromGpu.addr, align 8
  %arrayidx7 = getelementptr inbounds double, double* %8, i64 %idxprom6
  %9 = load double, double* %arrayidx7, align 8
  %call = call float @percentDiff(double %5, double %9)
  %conv = fpext float %call to double
  %cmp8 = fcmp ogt double %conv, 5.000000e-02
  br i1 %cmp8, label %if.then, label %if.end

if.then:                                          ; preds = %for.body.3
  %10 = load i32, i32* %fail, align 4
  %inc = add nsw i32 %10, 1
  store i32 %inc, i32* %fail, align 4
  br label %if.end

if.end:                                           ; preds = %if.then, %for.body.3
  br label %for.inc

for.inc:                                          ; preds = %if.end
  %11 = load i32, i32* %j, align 4
  %inc10 = add nsw i32 %11, 1
  store i32 %inc10, i32* %j, align 4
  br label %for.cond.1

for.end:                                          ; preds = %for.cond.1
  br label %for.inc.11

for.inc.11:                                       ; preds = %for.end
  %12 = load i32, i32* %i, align 4
  %inc12 = add nsw i32 %12, 1
  store i32 %inc12, i32* %i, align 4
  br label %for.cond

for.end.13:                                       ; preds = %for.cond
  %13 = load i32, i32* %fail, align 4
  %call14 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([74 x i8], [74 x i8]* @.str.1, i32 0, i32 0), double 5.000000e-02, i32 %13)
  ret void
}

; Function Attrs: nounwind uwtable
define void @mm3(i32 %ni, i32 %nj, i32 %nk, i32 %nl, i32 %nm, double* %A, double* %B, double* %C, double* %D, double* %E, double* %F, double* %G) #0 {
entry:
  %ni.addr = alloca i32, align 4
  %nj.addr = alloca i32, align 4
  %nk.addr = alloca i32, align 4
  %nl.addr = alloca i32, align 4
  %nm.addr = alloca i32, align 4
  %A.addr = alloca double*, align 8
  %B.addr = alloca double*, align 8
  %C.addr = alloca double*, align 8
  %D.addr = alloca double*, align 8
  %E.addr = alloca double*, align 8
  %F.addr = alloca double*, align 8
  %G.addr = alloca double*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %k = alloca i32, align 4
  store i32 %ni, i32* %ni.addr, align 4
  store i32 %nj, i32* %nj.addr, align 4
  store i32 %nk, i32* %nk.addr, align 4
  store i32 %nl, i32* %nl.addr, align 4
  store i32 %nm, i32* %nm.addr, align 4
  store double* %A, double** %A.addr, align 8
  store double* %B, double** %B.addr, align 8
  store double* %C, double** %C.addr, align 8
  store double* %D, double** %D.addr, align 8
  store double* %E, double** %E.addr, align 8
  store double* %F, double** %F.addr, align 8
  store double* %G, double** %G.addr, align 8
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.24, %entry
  %0 = load i32, i32* %i, align 4
  %1 = load i32, i32* %ni.addr, align 4
  %cmp = icmp slt i32 %0, %1
  br i1 %cmp, label %for.body, label %for.end.26

for.body:                                         ; preds = %for.cond
  store i32 0, i32* %j, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc.21, %for.body
  %2 = load i32, i32* %j, align 4
  %3 = load i32, i32* %nj.addr, align 4
  %cmp2 = icmp slt i32 %2, %3
  br i1 %cmp2, label %for.body.3, label %for.end.23

for.body.3:                                       ; preds = %for.cond.1
  %4 = load i32, i32* %i, align 4
  %mul = mul nsw i32 %4, 900
  %5 = load i32, i32* %j, align 4
  %add = add nsw i32 %mul, %5
  %idxprom = sext i32 %add to i64
  %6 = load double*, double** %E.addr, align 8
  %arrayidx = getelementptr inbounds double, double* %6, i64 %idxprom
  store double 0.000000e+00, double* %arrayidx, align 8
  store i32 0, i32* %k, align 4
  br label %for.cond.4

for.cond.4:                                       ; preds = %for.inc, %for.body.3
  %7 = load i32, i32* %k, align 4
  %8 = load i32, i32* %nk.addr, align 4
  %cmp5 = icmp slt i32 %7, %8
  br i1 %cmp5, label %for.body.6, label %for.end

for.body.6:                                       ; preds = %for.cond.4
  %9 = load i32, i32* %i, align 4
  %10 = load i32, i32* %nk.addr, align 4
  %mul7 = mul nsw i32 %9, %10
  %11 = load i32, i32* %k, align 4
  %add8 = add nsw i32 %mul7, %11
  %idxprom9 = sext i32 %add8 to i64
  %12 = load double*, double** %A.addr, align 8
  %arrayidx10 = getelementptr inbounds double, double* %12, i64 %idxprom9
  %13 = load double, double* %arrayidx10, align 8
  %14 = load i32, i32* %k, align 4
  %15 = load i32, i32* %nj.addr, align 4
  %mul11 = mul nsw i32 %14, %15
  %16 = load i32, i32* %j, align 4
  %add12 = add nsw i32 %mul11, %16
  %idxprom13 = sext i32 %add12 to i64
  %17 = load double*, double** %B.addr, align 8
  %arrayidx14 = getelementptr inbounds double, double* %17, i64 %idxprom13
  %18 = load double, double* %arrayidx14, align 8
  %mul15 = fmul double %13, %18
  %19 = load i32, i32* %i, align 4
  %20 = load i32, i32* %nj.addr, align 4
  %mul16 = mul nsw i32 %19, %20
  %21 = load i32, i32* %j, align 4
  %add17 = add nsw i32 %mul16, %21
  %idxprom18 = sext i32 %add17 to i64
  %22 = load double*, double** %E.addr, align 8
  %arrayidx19 = getelementptr inbounds double, double* %22, i64 %idxprom18
  %23 = load double, double* %arrayidx19, align 8
  %add20 = fadd double %23, %mul15
  store double %add20, double* %arrayidx19, align 8
  br label %for.inc

for.inc:                                          ; preds = %for.body.6
  %24 = load i32, i32* %k, align 4
  %inc = add nsw i32 %24, 1
  store i32 %inc, i32* %k, align 4
  br label %for.cond.4

for.end:                                          ; preds = %for.cond.4
  br label %for.inc.21

for.inc.21:                                       ; preds = %for.end
  %25 = load i32, i32* %j, align 4
  %inc22 = add nsw i32 %25, 1
  store i32 %inc22, i32* %j, align 4
  br label %for.cond.1

for.end.23:                                       ; preds = %for.cond.1
  br label %for.inc.24

for.inc.24:                                       ; preds = %for.end.23
  %26 = load i32, i32* %i, align 4
  %inc25 = add nsw i32 %26, 1
  store i32 %inc25, i32* %i, align 4
  br label %for.cond

for.end.26:                                       ; preds = %for.cond
  store i32 0, i32* %i, align 4
  br label %for.cond.27

for.cond.27:                                      ; preds = %for.inc.60, %for.end.26
  %27 = load i32, i32* %i, align 4
  %28 = load i32, i32* %nj.addr, align 4
  %cmp28 = icmp slt i32 %27, %28
  br i1 %cmp28, label %for.body.29, label %for.end.62

for.body.29:                                      ; preds = %for.cond.27
  store i32 0, i32* %j, align 4
  br label %for.cond.30

for.cond.30:                                      ; preds = %for.inc.57, %for.body.29
  %29 = load i32, i32* %j, align 4
  %30 = load i32, i32* %nl.addr, align 4
  %cmp31 = icmp slt i32 %29, %30
  br i1 %cmp31, label %for.body.32, label %for.end.59

for.body.32:                                      ; preds = %for.cond.30
  %31 = load i32, i32* %i, align 4
  %32 = load i32, i32* %nl.addr, align 4
  %mul33 = mul nsw i32 %31, %32
  %33 = load i32, i32* %j, align 4
  %add34 = add nsw i32 %mul33, %33
  %idxprom35 = sext i32 %add34 to i64
  %34 = load double*, double** %F.addr, align 8
  %arrayidx36 = getelementptr inbounds double, double* %34, i64 %idxprom35
  store double 0.000000e+00, double* %arrayidx36, align 8
  store i32 0, i32* %k, align 4
  br label %for.cond.37

for.cond.37:                                      ; preds = %for.inc.54, %for.body.32
  %35 = load i32, i32* %k, align 4
  %36 = load i32, i32* %nm.addr, align 4
  %cmp38 = icmp slt i32 %35, %36
  br i1 %cmp38, label %for.body.39, label %for.end.56

for.body.39:                                      ; preds = %for.cond.37
  %37 = load i32, i32* %i, align 4
  %38 = load i32, i32* %nm.addr, align 4
  %mul40 = mul nsw i32 %37, %38
  %39 = load i32, i32* %k, align 4
  %add41 = add nsw i32 %mul40, %39
  %idxprom42 = sext i32 %add41 to i64
  %40 = load double*, double** %C.addr, align 8
  %arrayidx43 = getelementptr inbounds double, double* %40, i64 %idxprom42
  %41 = load double, double* %arrayidx43, align 8
  %42 = load i32, i32* %k, align 4
  %43 = load i32, i32* %nl.addr, align 4
  %mul44 = mul nsw i32 %42, %43
  %44 = load i32, i32* %j, align 4
  %add45 = add nsw i32 %mul44, %44
  %idxprom46 = sext i32 %add45 to i64
  %45 = load double*, double** %D.addr, align 8
  %arrayidx47 = getelementptr inbounds double, double* %45, i64 %idxprom46
  %46 = load double, double* %arrayidx47, align 8
  %mul48 = fmul double %41, %46
  %47 = load i32, i32* %i, align 4
  %48 = load i32, i32* %nl.addr, align 4
  %mul49 = mul nsw i32 %47, %48
  %49 = load i32, i32* %j, align 4
  %add50 = add nsw i32 %mul49, %49
  %idxprom51 = sext i32 %add50 to i64
  %50 = load double*, double** %F.addr, align 8
  %arrayidx52 = getelementptr inbounds double, double* %50, i64 %idxprom51
  %51 = load double, double* %arrayidx52, align 8
  %add53 = fadd double %51, %mul48
  store double %add53, double* %arrayidx52, align 8
  br label %for.inc.54

for.inc.54:                                       ; preds = %for.body.39
  %52 = load i32, i32* %k, align 4
  %inc55 = add nsw i32 %52, 1
  store i32 %inc55, i32* %k, align 4
  br label %for.cond.37

for.end.56:                                       ; preds = %for.cond.37
  br label %for.inc.57

for.inc.57:                                       ; preds = %for.end.56
  %53 = load i32, i32* %j, align 4
  %inc58 = add nsw i32 %53, 1
  store i32 %inc58, i32* %j, align 4
  br label %for.cond.30

for.end.59:                                       ; preds = %for.cond.30
  br label %for.inc.60

for.inc.60:                                       ; preds = %for.end.59
  %54 = load i32, i32* %i, align 4
  %inc61 = add nsw i32 %54, 1
  store i32 %inc61, i32* %i, align 4
  br label %for.cond.27

for.end.62:                                       ; preds = %for.cond.27
  store i32 0, i32* %i, align 4
  br label %for.cond.63

for.cond.63:                                      ; preds = %for.inc.96, %for.end.62
  %55 = load i32, i32* %i, align 4
  %56 = load i32, i32* %ni.addr, align 4
  %cmp64 = icmp slt i32 %55, %56
  br i1 %cmp64, label %for.body.65, label %for.end.98

for.body.65:                                      ; preds = %for.cond.63
  store i32 0, i32* %j, align 4
  br label %for.cond.66

for.cond.66:                                      ; preds = %for.inc.93, %for.body.65
  %57 = load i32, i32* %j, align 4
  %58 = load i32, i32* %nl.addr, align 4
  %cmp67 = icmp slt i32 %57, %58
  br i1 %cmp67, label %for.body.68, label %for.end.95

for.body.68:                                      ; preds = %for.cond.66
  %59 = load i32, i32* %i, align 4
  %60 = load i32, i32* %nl.addr, align 4
  %mul69 = mul nsw i32 %59, %60
  %61 = load i32, i32* %j, align 4
  %add70 = add nsw i32 %mul69, %61
  %idxprom71 = sext i32 %add70 to i64
  %62 = load double*, double** %G.addr, align 8
  %arrayidx72 = getelementptr inbounds double, double* %62, i64 %idxprom71
  store double 0.000000e+00, double* %arrayidx72, align 8
  store i32 0, i32* %k, align 4
  br label %for.cond.73

for.cond.73:                                      ; preds = %for.inc.90, %for.body.68
  %63 = load i32, i32* %k, align 4
  %64 = load i32, i32* %nj.addr, align 4
  %cmp74 = icmp slt i32 %63, %64
  br i1 %cmp74, label %for.body.75, label %for.end.92

for.body.75:                                      ; preds = %for.cond.73
  %65 = load i32, i32* %i, align 4
  %66 = load i32, i32* %nj.addr, align 4
  %mul76 = mul nsw i32 %65, %66
  %67 = load i32, i32* %k, align 4
  %add77 = add nsw i32 %mul76, %67
  %idxprom78 = sext i32 %add77 to i64
  %68 = load double*, double** %E.addr, align 8
  %arrayidx79 = getelementptr inbounds double, double* %68, i64 %idxprom78
  %69 = load double, double* %arrayidx79, align 8
  %70 = load i32, i32* %k, align 4
  %71 = load i32, i32* %nl.addr, align 4
  %mul80 = mul nsw i32 %70, %71
  %72 = load i32, i32* %j, align 4
  %add81 = add nsw i32 %mul80, %72
  %idxprom82 = sext i32 %add81 to i64
  %73 = load double*, double** %F.addr, align 8
  %arrayidx83 = getelementptr inbounds double, double* %73, i64 %idxprom82
  %74 = load double, double* %arrayidx83, align 8
  %mul84 = fmul double %69, %74
  %75 = load i32, i32* %i, align 4
  %76 = load i32, i32* %nl.addr, align 4
  %mul85 = mul nsw i32 %75, %76
  %77 = load i32, i32* %j, align 4
  %add86 = add nsw i32 %mul85, %77
  %idxprom87 = sext i32 %add86 to i64
  %78 = load double*, double** %G.addr, align 8
  %arrayidx88 = getelementptr inbounds double, double* %78, i64 %idxprom87
  %79 = load double, double* %arrayidx88, align 8
  %add89 = fadd double %79, %mul84
  store double %add89, double* %arrayidx88, align 8
  br label %for.inc.90

for.inc.90:                                       ; preds = %for.body.75
  %80 = load i32, i32* %k, align 4
  %inc91 = add nsw i32 %80, 1
  store i32 %inc91, i32* %k, align 4
  br label %for.cond.73

for.end.92:                                       ; preds = %for.cond.73
  br label %for.inc.93

for.inc.93:                                       ; preds = %for.end.92
  %81 = load i32, i32* %j, align 4
  %inc94 = add nsw i32 %81, 1
  store i32 %inc94, i32* %j, align 4
  br label %for.cond.66

for.end.95:                                       ; preds = %for.cond.66
  br label %for.inc.96

for.inc.96:                                       ; preds = %for.end.95
  %82 = load i32, i32* %i, align 4
  %inc97 = add nsw i32 %82, 1
  store i32 %inc97, i32* %i, align 4
  br label %for.cond.63

for.end.98:                                       ; preds = %for.cond.63
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
  %nl = alloca i32, align 4
  %nm = alloca i32, align 4
  %A = alloca double*, align 8
  %B = alloca double*, align 8
  %C = alloca double*, align 8
  %D = alloca double*, align 8
  %E = alloca double*, align 8
  %F = alloca double*, align 8
  %G = alloca double*, align 8
  store i32 0, i32* %retval
  store i32 %argc, i32* %argc.addr, align 4
  store i8** %argv, i8*** %argv.addr, align 8
  store i32 800, i32* %ni, align 4
  store i32 900, i32* %nj, align 4
  store i32 1000, i32* %nk, align 4
  store i32 1100, i32* %nl, align 4
  store i32 1200, i32* %nm, align 4
  %call = call noalias i8* @malloc(i64 6400000) #3
  %0 = bitcast i8* %call to double*
  store double* %0, double** %A, align 8
  %call1 = call noalias i8* @malloc(i64 7200000) #3
  %1 = bitcast i8* %call1 to double*
  store double* %1, double** %B, align 8
  %call2 = call noalias i8* @malloc(i64 8640000) #3
  %2 = bitcast i8* %call2 to double*
  store double* %2, double** %C, align 8
  %call3 = call noalias i8* @malloc(i64 10560000) #3
  %3 = bitcast i8* %call3 to double*
  store double* %3, double** %D, align 8
  %call4 = call noalias i8* @malloc(i64 5760000) #3
  %4 = bitcast i8* %call4 to double*
  store double* %4, double** %E, align 8
  %call5 = call noalias i8* @malloc(i64 7920000) #3
  %5 = bitcast i8* %call5 to double*
  store double* %5, double** %F, align 8
  %call6 = call noalias i8* @malloc(i64 7040000) #3
  %6 = bitcast i8* %call6 to double*
  store double* %6, double** %G, align 8
  %7 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %call7 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %7, i8* getelementptr inbounds ([70 x i8], [70 x i8]* @.str.2, i32 0, i32 0))
  %8 = load double*, double** %A, align 8
  %9 = load double*, double** %B, align 8
  %10 = load double*, double** %C, align 8
  %11 = load double*, double** %D, align 8
  call void @init_array(double* %8, double* %9, double* %10, double* %11)
  %call8 = call double @rtclock()
  store double %call8, double* %t_start, align 8
  %12 = load i32, i32* %ni, align 4
  %13 = load i32, i32* %nj, align 4
  %14 = load i32, i32* %nk, align 4
  %15 = load i32, i32* %nl, align 4
  %16 = load i32, i32* %nm, align 4
  %17 = load double*, double** %A, align 8
  %18 = load double*, double** %B, align 8
  %19 = load double*, double** %C, align 8
  %20 = load double*, double** %D, align 8
  %21 = load double*, double** %E, align 8
  %22 = load double*, double** %F, align 8
  %23 = load double*, double** %G, align 8
  call void @mm3(i32 %12, i32 %13, i32 %14, i32 %15, i32 %16, double* %17, double* %18, double* %19, double* %20, double* %21, double* %22, double* %23)
  %call9 = call double @rtclock()
  store double %call9, double* %t_end, align 8
  %24 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %25 = load double, double* %t_end, align 8
  %26 = load double, double* %t_start, align 8
  %sub = fsub double %25, %26
  %call10 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %24, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.3, i32 0, i32 0), double %sub)
  %27 = load double*, double** %A, align 8
  %28 = bitcast double* %27 to i8*
  call void @free(i8* %28) #3
  %29 = load double*, double** %B, align 8
  %30 = bitcast double* %29 to i8*
  call void @free(i8* %30) #3
  %31 = load double*, double** %C, align 8
  %32 = bitcast double* %31 to i8*
  call void @free(i8* %32) #3
  %33 = load double*, double** %D, align 8
  %34 = bitcast double* %33 to i8*
  call void @free(i8* %34) #3
  %35 = load double*, double** %E, align 8
  %36 = bitcast double* %35 to i8*
  call void @free(i8* %36) #3
  %37 = load double*, double** %F, align 8
  %38 = bitcast double* %37 to i8*
  call void @free(i8* %38) #3
  %39 = load double*, double** %G, align 8
  %40 = bitcast double* %39 to i8*
  call void @free(i8* %40) #3
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
