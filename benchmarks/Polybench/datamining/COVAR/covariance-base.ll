; ModuleID = 'covariance.c'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, i8*, i8*, i8*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type { %struct._IO_marker*, %struct._IO_FILE*, i32 }
%struct.timezone = type { i32, i32 }
%struct.timeval = type { i64, i64 }

@.str = private unnamed_addr constant [35 x i8] c"Error return from gettimeofday: %d\00", align 1
@.str.1 = private unnamed_addr constant [74 x i8] c"Non-Matching CPU-GPU Outputs Beyond Error Threshold of %4.2f Percent: %d\0A\00", align 1
@stdout = external global %struct._IO_FILE*, align 8
@.str.2 = private unnamed_addr constant [30 x i8] c"<< Covariance Computation >>\0A\00", align 1
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
define void @init_arrays(float* %data) #0 {
entry:
  %data.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  store float* %data, float** %data.addr, align 8
  store i32 1, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.6, %entry
  %0 = load i32, i32* %i, align 4
  %cmp = icmp slt i32 %0, 2049
  br i1 %cmp, label %for.body, label %for.end.8

for.body:                                         ; preds = %for.cond
  store i32 1, i32* %j, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %1 = load i32, i32* %j, align 4
  %cmp2 = icmp slt i32 %1, 2049
  br i1 %cmp2, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.cond.1
  %2 = load i32, i32* %i, align 4
  %conv = sitofp i32 %2 to float
  %3 = load i32, i32* %j, align 4
  %conv4 = sitofp i32 %3 to float
  %mul = fmul float %conv, %conv4
  %div = fdiv float %mul, 2.048000e+03
  %4 = load i32, i32* %i, align 4
  %mul5 = mul nsw i32 %4, 2049
  %5 = load i32, i32* %j, align 4
  %add = add nsw i32 %mul5, %5
  %idxprom = sext i32 %add to i64
  %6 = load float*, float** %data.addr, align 8
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
  ret void
}

; Function Attrs: nounwind uwtable
define void @compareResults(float* %symmat, float* %symmat_outputFromGpu) #0 {
entry:
  %symmat.addr = alloca float*, align 8
  %symmat_outputFromGpu.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %fail = alloca i32, align 4
  store float* %symmat, float** %symmat.addr, align 8
  store float* %symmat_outputFromGpu, float** %symmat_outputFromGpu.addr, align 8
  store i32 0, i32* %fail, align 4
  store i32 1, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.13, %entry
  %0 = load i32, i32* %i, align 4
  %cmp = icmp slt i32 %0, 2049
  br i1 %cmp, label %for.body, label %for.end.15

for.body:                                         ; preds = %for.cond
  store i32 1, i32* %j, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %1 = load i32, i32* %j, align 4
  %cmp2 = icmp slt i32 %1, 2049
  br i1 %cmp2, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.cond.1
  %2 = load i32, i32* %i, align 4
  %mul = mul nsw i32 %2, 2049
  %3 = load i32, i32* %j, align 4
  %add = add nsw i32 %mul, %3
  %idxprom = sext i32 %add to i64
  %4 = load float*, float** %symmat.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %4, i64 %idxprom
  %5 = load float, float* %arrayidx, align 4
  %conv = fpext float %5 to double
  %6 = load i32, i32* %i, align 4
  %mul4 = mul nsw i32 %6, 2049
  %7 = load i32, i32* %j, align 4
  %add5 = add nsw i32 %mul4, %7
  %idxprom6 = sext i32 %add5 to i64
  %8 = load float*, float** %symmat_outputFromGpu.addr, align 8
  %arrayidx7 = getelementptr inbounds float, float* %8, i64 %idxprom6
  %9 = load float, float* %arrayidx7, align 4
  %conv8 = fpext float %9 to double
  %call = call float @percentDiff(double %conv, double %conv8)
  %conv9 = fpext float %call to double
  %cmp10 = fcmp ogt double %conv9, 1.050000e+00
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
  %call16 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([74 x i8], [74 x i8]* @.str.1, i32 0, i32 0), double 1.050000e+00, i32 %13)
  ret void
}

; Function Attrs: nounwind uwtable
define void @covariance(i32 %m, i32 %n, float* %data, float* %symmat, float* %mean) #0 {
entry:
  %m.addr = alloca i32, align 4
  %n.addr = alloca i32, align 4
  %data.addr = alloca float*, align 8
  %symmat.addr = alloca float*, align 8
  %mean.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %j1 = alloca i32, align 4
  %j2 = alloca i32, align 4
  store i32 %m, i32* %m.addr, align 4
  store i32 %n, i32* %n.addr, align 4
  store float* %data, float** %data.addr, align 8
  store float* %symmat, float** %symmat.addr, align 8
  store float* %mean, float** %mean.addr, align 8
  store i32 0, i32* %j, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.12, %entry
  %0 = load i32, i32* %j, align 4
  %1 = load i32, i32* %m.addr, align 4
  %cmp = icmp slt i32 %0, %1
  br i1 %cmp, label %for.body, label %for.end.14

for.body:                                         ; preds = %for.cond
  %2 = load i32, i32* %j, align 4
  %idxprom = sext i32 %2 to i64
  %3 = load float*, float** %mean.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %3, i64 %idxprom
  store float 0.000000e+00, float* %arrayidx, align 4
  store i32 0, i32* %i, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %4 = load i32, i32* %i, align 4
  %5 = load i32, i32* %n.addr, align 4
  %cmp2 = icmp slt i32 %4, %5
  br i1 %cmp2, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.cond.1
  %6 = load i32, i32* %i, align 4
  %7 = load i32, i32* %m.addr, align 4
  %mul = mul nsw i32 %6, %7
  %8 = load i32, i32* %j, align 4
  %add = add nsw i32 %mul, %8
  %idxprom4 = sext i32 %add to i64
  %9 = load float*, float** %data.addr, align 8
  %arrayidx5 = getelementptr inbounds float, float* %9, i64 %idxprom4
  %10 = load float, float* %arrayidx5, align 4
  %11 = load i32, i32* %j, align 4
  %idxprom6 = sext i32 %11 to i64
  %12 = load float*, float** %mean.addr, align 8
  %arrayidx7 = getelementptr inbounds float, float* %12, i64 %idxprom6
  %13 = load float, float* %arrayidx7, align 4
  %add8 = fadd float %13, %10
  store float %add8, float* %arrayidx7, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.3
  %14 = load i32, i32* %i, align 4
  %inc = add nsw i32 %14, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond.1

for.end:                                          ; preds = %for.cond.1
  %15 = load i32, i32* %j, align 4
  %idxprom9 = sext i32 %15 to i64
  %16 = load float*, float** %mean.addr, align 8
  %arrayidx10 = getelementptr inbounds float, float* %16, i64 %idxprom9
  %17 = load float, float* %arrayidx10, align 4
  %conv = fpext float %17 to double
  %div = fdiv double %conv, 0x414885C20147AE14
  %conv11 = fptrunc double %div to float
  store float %conv11, float* %arrayidx10, align 4
  br label %for.inc.12

for.inc.12:                                       ; preds = %for.end
  %18 = load i32, i32* %j, align 4
  %inc13 = add nsw i32 %18, 1
  store i32 %inc13, i32* %j, align 4
  br label %for.cond

for.end.14:                                       ; preds = %for.cond
  store i32 0, i32* %i, align 4
  br label %for.cond.15

for.cond.15:                                      ; preds = %for.inc.32, %for.end.14
  %19 = load i32, i32* %i, align 4
  %20 = load i32, i32* %n.addr, align 4
  %cmp16 = icmp slt i32 %19, %20
  br i1 %cmp16, label %for.body.18, label %for.end.34

for.body.18:                                      ; preds = %for.cond.15
  store i32 0, i32* %j, align 4
  br label %for.cond.19

for.cond.19:                                      ; preds = %for.inc.29, %for.body.18
  %21 = load i32, i32* %j, align 4
  %22 = load i32, i32* %m.addr, align 4
  %cmp20 = icmp slt i32 %21, %22
  br i1 %cmp20, label %for.body.22, label %for.end.31

for.body.22:                                      ; preds = %for.cond.19
  %23 = load i32, i32* %j, align 4
  %idxprom23 = sext i32 %23 to i64
  %24 = load float*, float** %mean.addr, align 8
  %arrayidx24 = getelementptr inbounds float, float* %24, i64 %idxprom23
  %25 = load float, float* %arrayidx24, align 4
  %26 = load i32, i32* %i, align 4
  %27 = load i32, i32* %m.addr, align 4
  %mul25 = mul nsw i32 %26, %27
  %28 = load i32, i32* %j, align 4
  %add26 = add nsw i32 %mul25, %28
  %idxprom27 = sext i32 %add26 to i64
  %29 = load float*, float** %data.addr, align 8
  %arrayidx28 = getelementptr inbounds float, float* %29, i64 %idxprom27
  %30 = load float, float* %arrayidx28, align 4
  %sub = fsub float %30, %25
  store float %sub, float* %arrayidx28, align 4
  br label %for.inc.29

for.inc.29:                                       ; preds = %for.body.22
  %31 = load i32, i32* %j, align 4
  %inc30 = add nsw i32 %31, 1
  store i32 %inc30, i32* %j, align 4
  br label %for.cond.19

for.end.31:                                       ; preds = %for.cond.19
  br label %for.inc.32

for.inc.32:                                       ; preds = %for.end.31
  %32 = load i32, i32* %i, align 4
  %inc33 = add nsw i32 %32, 1
  store i32 %inc33, i32* %i, align 4
  br label %for.cond.15

for.end.34:                                       ; preds = %for.cond.15
  store i32 0, i32* %j1, align 4
  br label %for.cond.35

for.cond.35:                                      ; preds = %for.inc.79, %for.end.34
  %33 = load i32, i32* %j1, align 4
  %34 = load i32, i32* %m.addr, align 4
  %cmp36 = icmp slt i32 %33, %34
  br i1 %cmp36, label %for.body.38, label %for.end.81

for.body.38:                                      ; preds = %for.cond.35
  %35 = load i32, i32* %j1, align 4
  store i32 %35, i32* %j2, align 4
  br label %for.cond.39

for.cond.39:                                      ; preds = %for.inc.76, %for.body.38
  %36 = load i32, i32* %j2, align 4
  %37 = load i32, i32* %m.addr, align 4
  %cmp40 = icmp slt i32 %36, %37
  br i1 %cmp40, label %for.body.42, label %for.end.78

for.body.42:                                      ; preds = %for.cond.39
  %38 = load i32, i32* %j1, align 4
  %39 = load i32, i32* %m.addr, align 4
  %mul43 = mul nsw i32 %38, %39
  %40 = load i32, i32* %j2, align 4
  %add44 = add nsw i32 %mul43, %40
  %idxprom45 = sext i32 %add44 to i64
  %41 = load float*, float** %symmat.addr, align 8
  %arrayidx46 = getelementptr inbounds float, float* %41, i64 %idxprom45
  store float 0.000000e+00, float* %arrayidx46, align 4
  store i32 1, i32* %i, align 4
  br label %for.cond.47

for.cond.47:                                      ; preds = %for.inc.65, %for.body.42
  %42 = load i32, i32* %i, align 4
  %43 = load i32, i32* %n.addr, align 4
  %cmp48 = icmp slt i32 %42, %43
  br i1 %cmp48, label %for.body.50, label %for.end.67

for.body.50:                                      ; preds = %for.cond.47
  %44 = load i32, i32* %i, align 4
  %45 = load i32, i32* %m.addr, align 4
  %mul51 = mul nsw i32 %44, %45
  %46 = load i32, i32* %j1, align 4
  %add52 = add nsw i32 %mul51, %46
  %idxprom53 = sext i32 %add52 to i64
  %47 = load float*, float** %data.addr, align 8
  %arrayidx54 = getelementptr inbounds float, float* %47, i64 %idxprom53
  %48 = load float, float* %arrayidx54, align 4
  %49 = load i32, i32* %i, align 4
  %50 = load i32, i32* %m.addr, align 4
  %mul55 = mul nsw i32 %49, %50
  %51 = load i32, i32* %j2, align 4
  %add56 = add nsw i32 %mul55, %51
  %idxprom57 = sext i32 %add56 to i64
  %52 = load float*, float** %data.addr, align 8
  %arrayidx58 = getelementptr inbounds float, float* %52, i64 %idxprom57
  %53 = load float, float* %arrayidx58, align 4
  %mul59 = fmul float %48, %53
  %54 = load i32, i32* %j1, align 4
  %55 = load i32, i32* %m.addr, align 4
  %mul60 = mul nsw i32 %54, %55
  %56 = load i32, i32* %j2, align 4
  %add61 = add nsw i32 %mul60, %56
  %idxprom62 = sext i32 %add61 to i64
  %57 = load float*, float** %symmat.addr, align 8
  %arrayidx63 = getelementptr inbounds float, float* %57, i64 %idxprom62
  %58 = load float, float* %arrayidx63, align 4
  %add64 = fadd float %58, %mul59
  store float %add64, float* %arrayidx63, align 4
  br label %for.inc.65

for.inc.65:                                       ; preds = %for.body.50
  %59 = load i32, i32* %i, align 4
  %inc66 = add nsw i32 %59, 1
  store i32 %inc66, i32* %i, align 4
  br label %for.cond.47

for.end.67:                                       ; preds = %for.cond.47
  %60 = load i32, i32* %j1, align 4
  %61 = load i32, i32* %m.addr, align 4
  %mul68 = mul nsw i32 %60, %61
  %62 = load i32, i32* %j2, align 4
  %add69 = add nsw i32 %mul68, %62
  %idxprom70 = sext i32 %add69 to i64
  %63 = load float*, float** %symmat.addr, align 8
  %arrayidx71 = getelementptr inbounds float, float* %63, i64 %idxprom70
  %64 = load float, float* %arrayidx71, align 4
  %65 = load i32, i32* %j2, align 4
  %66 = load i32, i32* %m.addr, align 4
  %mul72 = mul nsw i32 %65, %66
  %67 = load i32, i32* %j1, align 4
  %add73 = add nsw i32 %mul72, %67
  %idxprom74 = sext i32 %add73 to i64
  %68 = load float*, float** %symmat.addr, align 8
  %arrayidx75 = getelementptr inbounds float, float* %68, i64 %idxprom74
  store float %64, float* %arrayidx75, align 4
  br label %for.inc.76

for.inc.76:                                       ; preds = %for.end.67
  %69 = load i32, i32* %j2, align 4
  %inc77 = add nsw i32 %69, 1
  store i32 %inc77, i32* %j2, align 4
  br label %for.cond.39

for.end.78:                                       ; preds = %for.cond.39
  br label %for.inc.79

for.inc.79:                                       ; preds = %for.end.78
  %70 = load i32, i32* %j1, align 4
  %inc80 = add nsw i32 %70, 1
  store i32 %inc80, i32* %j1, align 4
  br label %for.cond.35

for.end.81:                                       ; preds = %for.cond.35
  ret void
}

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
entry:
  %retval = alloca i32, align 4
  %n = alloca i32, align 4
  %m = alloca i32, align 4
  %t_start = alloca double, align 8
  %t_end = alloca double, align 8
  %data = alloca float*, align 8
  %symmat = alloca float*, align 8
  %mean = alloca float*, align 8
  %symmat_outputFromGpu = alloca float*, align 8
  store i32 0, i32* %retval
  store i32 2048, i32* %n, align 4
  store i32 2048, i32* %m, align 4
  %call = call noalias i8* @malloc(i64 16793604) #3
  %0 = bitcast i8* %call to float*
  store float* %0, float** %data, align 8
  %call1 = call noalias i8* @malloc(i64 16793604) #3
  %1 = bitcast i8* %call1 to float*
  store float* %1, float** %symmat, align 8
  %call2 = call noalias i8* @malloc(i64 8196) #3
  %2 = bitcast i8* %call2 to float*
  store float* %2, float** %mean, align 8
  %call3 = call noalias i8* @malloc(i64 16793604) #3
  %3 = bitcast i8* %call3 to float*
  store float* %3, float** %symmat_outputFromGpu, align 8
  %4 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %call4 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %4, i8* getelementptr inbounds ([30 x i8], [30 x i8]* @.str.2, i32 0, i32 0))
  %5 = load float*, float** %data, align 8
  call void @init_arrays(float* %5)
  %call5 = call double @rtclock()
  store double %call5, double* %t_start, align 8
  %6 = load i32, i32* %m, align 4
  %7 = load i32, i32* %n, align 4
  %8 = load float*, float** %data, align 8
  %9 = load float*, float** %symmat, align 8
  %10 = load float*, float** %mean, align 8
  call void @covariance(i32 %6, i32 %7, float* %8, float* %9, float* %10)
  %call6 = call double @rtclock()
  store double %call6, double* %t_end, align 8
  %11 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %12 = load double, double* %t_end, align 8
  %13 = load double, double* %t_start, align 8
  %sub = fsub double %12, %13
  %call7 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %11, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.3, i32 0, i32 0), double %sub)
  %14 = load float*, float** %data, align 8
  %15 = bitcast float* %14 to i8*
  call void @free(i8* %15) #3
  %16 = load float*, float** %symmat, align 8
  %17 = bitcast float* %16 to i8*
  call void @free(i8* %17) #3
  %18 = load float*, float** %mean, align 8
  %19 = bitcast float* %18 to i8*
  call void @free(i8* %19) #3
  %20 = load float*, float** %symmat_outputFromGpu, align 8
  %21 = bitcast float* %20 to i8*
  call void @free(i8* %21) #3
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
