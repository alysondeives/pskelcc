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
define void @init_array(i32 %ni, i32 %nj, i32 %nk, i32 %nl, float* %A, float* %B, float* %C, float* %D) #0 {
entry:
  %ni.addr = alloca i32, align 4
  %nj.addr = alloca i32, align 4
  %nk.addr = alloca i32, align 4
  %nl.addr = alloca i32, align 4
  %A.addr = alloca float*, align 8
  %B.addr = alloca float*, align 8
  %C.addr = alloca float*, align 8
  %D.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  store i32 %ni, i32* %ni.addr, align 4
  store i32 %nj, i32* %nj.addr, align 4
  store i32 %nk, i32* %nk.addr, align 4
  store i32 %nl, i32* %nl.addr, align 4
  store float* %A, float** %A.addr, align 8
  store float* %B, float** %B.addr, align 8
  store float* %C, float** %C.addr, align 8
  store float* %D, float** %D.addr, align 8
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.7, %entry
  %0 = load i32, i32* %i, align 4
  %1 = load i32, i32* %ni.addr, align 4
  %cmp = icmp slt i32 %0, %1
  br i1 %cmp, label %for.body, label %for.end.9

for.body:                                         ; preds = %for.cond
  store i32 0, i32* %j, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %2 = load i32, i32* %j, align 4
  %3 = load i32, i32* %nk.addr, align 4
  %cmp2 = icmp slt i32 %2, %3
  br i1 %cmp2, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.cond.1
  %4 = load i32, i32* %i, align 4
  %conv = sitofp i32 %4 to float
  %5 = load i32, i32* %j, align 4
  %conv4 = sitofp i32 %5 to float
  %mul = fmul float %conv, %conv4
  %6 = load i32, i32* %ni.addr, align 4
  %conv5 = sitofp i32 %6 to float
  %div = fdiv float %mul, %conv5
  %7 = load i32, i32* %i, align 4
  %8 = load i32, i32* %ni.addr, align 4
  %mul6 = mul nsw i32 %7, %8
  %9 = load i32, i32* %j, align 4
  %add = add nsw i32 %mul6, %9
  %idxprom = sext i32 %add to i64
  %10 = load float*, float** %A.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %10, i64 %idxprom
  store float %div, float* %arrayidx, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.3
  %11 = load i32, i32* %j, align 4
  %inc = add nsw i32 %11, 1
  store i32 %inc, i32* %j, align 4
  br label %for.cond.1

for.end:                                          ; preds = %for.cond.1
  br label %for.inc.7

for.inc.7:                                        ; preds = %for.end
  %12 = load i32, i32* %i, align 4
  %inc8 = add nsw i32 %12, 1
  store i32 %inc8, i32* %i, align 4
  br label %for.cond

for.end.9:                                        ; preds = %for.cond
  store i32 0, i32* %i, align 4
  br label %for.cond.10

for.cond.10:                                      ; preds = %for.inc.31, %for.end.9
  %13 = load i32, i32* %i, align 4
  %14 = load i32, i32* %nk.addr, align 4
  %cmp11 = icmp slt i32 %13, %14
  br i1 %cmp11, label %for.body.13, label %for.end.33

for.body.13:                                      ; preds = %for.cond.10
  store i32 0, i32* %j, align 4
  br label %for.cond.14

for.cond.14:                                      ; preds = %for.inc.28, %for.body.13
  %15 = load i32, i32* %j, align 4
  %16 = load i32, i32* %nj.addr, align 4
  %cmp15 = icmp slt i32 %15, %16
  br i1 %cmp15, label %for.body.17, label %for.end.30

for.body.17:                                      ; preds = %for.cond.14
  %17 = load i32, i32* %i, align 4
  %conv18 = sitofp i32 %17 to float
  %18 = load i32, i32* %j, align 4
  %add19 = add nsw i32 %18, 1
  %conv20 = sitofp i32 %add19 to float
  %mul21 = fmul float %conv18, %conv20
  %19 = load i32, i32* %nj.addr, align 4
  %conv22 = sitofp i32 %19 to float
  %div23 = fdiv float %mul21, %conv22
  %20 = load i32, i32* %i, align 4
  %21 = load i32, i32* %nk.addr, align 4
  %mul24 = mul nsw i32 %20, %21
  %22 = load i32, i32* %j, align 4
  %add25 = add nsw i32 %mul24, %22
  %idxprom26 = sext i32 %add25 to i64
  %23 = load float*, float** %B.addr, align 8
  %arrayidx27 = getelementptr inbounds float, float* %23, i64 %idxprom26
  store float %div23, float* %arrayidx27, align 4
  br label %for.inc.28

for.inc.28:                                       ; preds = %for.body.17
  %24 = load i32, i32* %j, align 4
  %inc29 = add nsw i32 %24, 1
  store i32 %inc29, i32* %j, align 4
  br label %for.cond.14

for.end.30:                                       ; preds = %for.cond.14
  br label %for.inc.31

for.inc.31:                                       ; preds = %for.end.30
  %25 = load i32, i32* %i, align 4
  %inc32 = add nsw i32 %25, 1
  store i32 %inc32, i32* %i, align 4
  br label %for.cond.10

for.end.33:                                       ; preds = %for.cond.10
  store i32 0, i32* %i, align 4
  br label %for.cond.34

for.cond.34:                                      ; preds = %for.inc.55, %for.end.33
  %26 = load i32, i32* %i, align 4
  %27 = load i32, i32* %nl.addr, align 4
  %cmp35 = icmp slt i32 %26, %27
  br i1 %cmp35, label %for.body.37, label %for.end.57

for.body.37:                                      ; preds = %for.cond.34
  store i32 0, i32* %j, align 4
  br label %for.cond.38

for.cond.38:                                      ; preds = %for.inc.52, %for.body.37
  %28 = load i32, i32* %j, align 4
  %29 = load i32, i32* %nj.addr, align 4
  %cmp39 = icmp slt i32 %28, %29
  br i1 %cmp39, label %for.body.41, label %for.end.54

for.body.41:                                      ; preds = %for.cond.38
  %30 = load i32, i32* %i, align 4
  %conv42 = sitofp i32 %30 to float
  %31 = load i32, i32* %j, align 4
  %add43 = add nsw i32 %31, 3
  %conv44 = sitofp i32 %add43 to float
  %mul45 = fmul float %conv42, %conv44
  %32 = load i32, i32* %nl.addr, align 4
  %conv46 = sitofp i32 %32 to float
  %div47 = fdiv float %mul45, %conv46
  %33 = load i32, i32* %i, align 4
  %34 = load i32, i32* %nl.addr, align 4
  %mul48 = mul nsw i32 %33, %34
  %35 = load i32, i32* %j, align 4
  %add49 = add nsw i32 %mul48, %35
  %idxprom50 = sext i32 %add49 to i64
  %36 = load float*, float** %C.addr, align 8
  %arrayidx51 = getelementptr inbounds float, float* %36, i64 %idxprom50
  store float %div47, float* %arrayidx51, align 4
  br label %for.inc.52

for.inc.52:                                       ; preds = %for.body.41
  %37 = load i32, i32* %j, align 4
  %inc53 = add nsw i32 %37, 1
  store i32 %inc53, i32* %j, align 4
  br label %for.cond.38

for.end.54:                                       ; preds = %for.cond.38
  br label %for.inc.55

for.inc.55:                                       ; preds = %for.end.54
  %38 = load i32, i32* %i, align 4
  %inc56 = add nsw i32 %38, 1
  store i32 %inc56, i32* %i, align 4
  br label %for.cond.34

for.end.57:                                       ; preds = %for.cond.34
  store i32 0, i32* %i, align 4
  br label %for.cond.58

for.cond.58:                                      ; preds = %for.inc.79, %for.end.57
  %39 = load i32, i32* %i, align 4
  %40 = load i32, i32* %ni.addr, align 4
  %cmp59 = icmp slt i32 %39, %40
  br i1 %cmp59, label %for.body.61, label %for.end.81

for.body.61:                                      ; preds = %for.cond.58
  store i32 0, i32* %j, align 4
  br label %for.cond.62

for.cond.62:                                      ; preds = %for.inc.76, %for.body.61
  %41 = load i32, i32* %j, align 4
  %42 = load i32, i32* %nl.addr, align 4
  %cmp63 = icmp slt i32 %41, %42
  br i1 %cmp63, label %for.body.65, label %for.end.78

for.body.65:                                      ; preds = %for.cond.62
  %43 = load i32, i32* %i, align 4
  %conv66 = sitofp i32 %43 to float
  %44 = load i32, i32* %j, align 4
  %add67 = add nsw i32 %44, 2
  %conv68 = sitofp i32 %add67 to float
  %mul69 = fmul float %conv66, %conv68
  %45 = load i32, i32* %nk.addr, align 4
  %conv70 = sitofp i32 %45 to float
  %div71 = fdiv float %mul69, %conv70
  %46 = load i32, i32* %i, align 4
  %47 = load i32, i32* %nl.addr, align 4
  %mul72 = mul nsw i32 %46, %47
  %48 = load i32, i32* %j, align 4
  %add73 = add nsw i32 %mul72, %48
  %idxprom74 = sext i32 %add73 to i64
  %49 = load float*, float** %D.addr, align 8
  %arrayidx75 = getelementptr inbounds float, float* %49, i64 %idxprom74
  store float %div71, float* %arrayidx75, align 4
  br label %for.inc.76

for.inc.76:                                       ; preds = %for.body.65
  %50 = load i32, i32* %j, align 4
  %inc77 = add nsw i32 %50, 1
  store i32 %inc77, i32* %j, align 4
  br label %for.cond.62

for.end.78:                                       ; preds = %for.cond.62
  br label %for.inc.79

for.inc.79:                                       ; preds = %for.end.78
  %51 = load i32, i32* %i, align 4
  %inc80 = add nsw i32 %51, 1
  store i32 %inc80, i32* %i, align 4
  br label %for.cond.58

for.end.81:                                       ; preds = %for.cond.58
  ret void
}

; Function Attrs: nounwind uwtable
define void @compareResults(i32 %ni, i32 %nl, float* %E, float* %E_GPU) #0 {
entry:
  %ni.addr = alloca i32, align 4
  %nl.addr = alloca i32, align 4
  %E.addr = alloca float*, align 8
  %E_GPU.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %fail = alloca i32, align 4
  store i32 %ni, i32* %ni.addr, align 4
  store i32 %nl, i32* %nl.addr, align 4
  store float* %E, float** %E.addr, align 8
  store float* %E_GPU, float** %E_GPU.addr, align 8
  store i32 0, i32* %fail, align 4
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.13, %entry
  %0 = load i32, i32* %i, align 4
  %1 = load i32, i32* %nl.addr, align 4
  %cmp = icmp slt i32 %0, %1
  br i1 %cmp, label %for.body, label %for.end.15

for.body:                                         ; preds = %for.cond
  store i32 0, i32* %j, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %2 = load i32, i32* %j, align 4
  %3 = load i32, i32* %ni.addr, align 4
  %cmp2 = icmp slt i32 %2, %3
  br i1 %cmp2, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.cond.1
  %4 = load i32, i32* %i, align 4
  %5 = load i32, i32* %ni.addr, align 4
  %mul = mul nsw i32 %4, %5
  %6 = load i32, i32* %j, align 4
  %add = add nsw i32 %mul, %6
  %idxprom = sext i32 %add to i64
  %7 = load float*, float** %E.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %7, i64 %idxprom
  %8 = load float, float* %arrayidx, align 4
  %conv = fpext float %8 to double
  %9 = load i32, i32* %i, align 4
  %10 = load i32, i32* %ni.addr, align 4
  %mul4 = mul nsw i32 %9, %10
  %11 = load i32, i32* %j, align 4
  %add5 = add nsw i32 %mul4, %11
  %idxprom6 = sext i32 %add5 to i64
  %12 = load float*, float** %E_GPU.addr, align 8
  %arrayidx7 = getelementptr inbounds float, float* %12, i64 %idxprom6
  %13 = load float, float* %arrayidx7, align 4
  %conv8 = fpext float %13 to double
  %call = call float @percentDiff(double %conv, double %conv8)
  %conv9 = fpext float %call to double
  %cmp10 = fcmp ogt double %conv9, 5.000000e-02
  br i1 %cmp10, label %if.then, label %if.end

if.then:                                          ; preds = %for.body.3
  %14 = load i32, i32* %fail, align 4
  %inc = add nsw i32 %14, 1
  store i32 %inc, i32* %fail, align 4
  br label %if.end

if.end:                                           ; preds = %if.then, %for.body.3
  br label %for.inc

for.inc:                                          ; preds = %if.end
  %15 = load i32, i32* %j, align 4
  %inc12 = add nsw i32 %15, 1
  store i32 %inc12, i32* %j, align 4
  br label %for.cond.1

for.end:                                          ; preds = %for.cond.1
  br label %for.inc.13

for.inc.13:                                       ; preds = %for.end
  %16 = load i32, i32* %i, align 4
  %inc14 = add nsw i32 %16, 1
  store i32 %inc14, i32* %i, align 4
  br label %for.cond

for.end.15:                                       ; preds = %for.cond
  %17 = load i32, i32* %fail, align 4
  %call16 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([74 x i8], [74 x i8]* @.str.1, i32 0, i32 0), double 5.000000e-02, i32 %17)
  ret void
}

; Function Attrs: nounwind uwtable
define void @mm2(i32 %ni, i32 %nj, i32 %nk, i32 %nl, float* %A, float* %B, float* %C, float* %D, float* %E) #0 {
entry:
  %ni.addr = alloca i32, align 4
  %nj.addr = alloca i32, align 4
  %nk.addr = alloca i32, align 4
  %nl.addr = alloca i32, align 4
  %A.addr = alloca float*, align 8
  %B.addr = alloca float*, align 8
  %C.addr = alloca float*, align 8
  %D.addr = alloca float*, align 8
  %E.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %k = alloca i32, align 4
  store i32 %ni, i32* %ni.addr, align 4
  store i32 %nj, i32* %nj.addr, align 4
  store i32 %nk, i32* %nk.addr, align 4
  store i32 %nl, i32* %nl.addr, align 4
  store float* %A, float** %A.addr, align 8
  store float* %B, float** %B.addr, align 8
  store float* %C, float** %C.addr, align 8
  store float* %D, float** %D.addr, align 8
  store float* %E, float** %E.addr, align 8
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
  %5 = load i32, i32* %nj.addr, align 4
  %mul = mul nsw i32 %4, %5
  %6 = load i32, i32* %j, align 4
  %add = add nsw i32 %mul, %6
  %idxprom = sext i32 %add to i64
  %7 = load float*, float** %C.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %7, i64 %idxprom
  store float 0.000000e+00, float* %arrayidx, align 4
  store i32 0, i32* %k, align 4
  br label %for.cond.4

for.cond.4:                                       ; preds = %for.inc, %for.body.3
  %8 = load i32, i32* %k, align 4
  %9 = load i32, i32* %nk.addr, align 4
  %cmp5 = icmp slt i32 %8, %9
  br i1 %cmp5, label %for.body.6, label %for.end

for.body.6:                                       ; preds = %for.cond.4
  %10 = load i32, i32* %i, align 4
  %11 = load i32, i32* %nk.addr, align 4
  %mul7 = mul nsw i32 %10, %11
  %12 = load i32, i32* %k, align 4
  %add8 = add nsw i32 %mul7, %12
  %idxprom9 = sext i32 %add8 to i64
  %13 = load float*, float** %A.addr, align 8
  %arrayidx10 = getelementptr inbounds float, float* %13, i64 %idxprom9
  %14 = load float, float* %arrayidx10, align 4
  %15 = load i32, i32* %k, align 4
  %16 = load i32, i32* %nj.addr, align 4
  %mul11 = mul nsw i32 %15, %16
  %17 = load i32, i32* %j, align 4
  %add12 = add nsw i32 %mul11, %17
  %idxprom13 = sext i32 %add12 to i64
  %18 = load float*, float** %B.addr, align 8
  %arrayidx14 = getelementptr inbounds float, float* %18, i64 %idxprom13
  %19 = load float, float* %arrayidx14, align 4
  %mul15 = fmul float %14, %19
  %20 = load i32, i32* %i, align 4
  %21 = load i32, i32* %nj.addr, align 4
  %mul16 = mul nsw i32 %20, %21
  %22 = load i32, i32* %j, align 4
  %add17 = add nsw i32 %mul16, %22
  %idxprom18 = sext i32 %add17 to i64
  %23 = load float*, float** %C.addr, align 8
  %arrayidx19 = getelementptr inbounds float, float* %23, i64 %idxprom18
  %24 = load float, float* %arrayidx19, align 4
  %add20 = fadd float %24, %mul15
  store float %add20, float* %arrayidx19, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.6
  %25 = load i32, i32* %k, align 4
  %inc = add nsw i32 %25, 1
  store i32 %inc, i32* %k, align 4
  br label %for.cond.4

for.end:                                          ; preds = %for.cond.4
  br label %for.inc.21

for.inc.21:                                       ; preds = %for.end
  %26 = load i32, i32* %j, align 4
  %inc22 = add nsw i32 %26, 1
  store i32 %inc22, i32* %j, align 4
  br label %for.cond.1

for.end.23:                                       ; preds = %for.cond.1
  br label %for.inc.24

for.inc.24:                                       ; preds = %for.end.23
  %27 = load i32, i32* %i, align 4
  %inc25 = add nsw i32 %27, 1
  store i32 %inc25, i32* %i, align 4
  br label %for.cond

for.end.26:                                       ; preds = %for.cond
  store i32 0, i32* %i, align 4
  br label %for.cond.27

for.cond.27:                                      ; preds = %for.inc.60, %for.end.26
  %28 = load i32, i32* %i, align 4
  %29 = load i32, i32* %ni.addr, align 4
  %cmp28 = icmp slt i32 %28, %29
  br i1 %cmp28, label %for.body.29, label %for.end.62

for.body.29:                                      ; preds = %for.cond.27
  store i32 0, i32* %j, align 4
  br label %for.cond.30

for.cond.30:                                      ; preds = %for.inc.57, %for.body.29
  %30 = load i32, i32* %j, align 4
  %31 = load i32, i32* %nl.addr, align 4
  %cmp31 = icmp slt i32 %30, %31
  br i1 %cmp31, label %for.body.32, label %for.end.59

for.body.32:                                      ; preds = %for.cond.30
  %32 = load i32, i32* %i, align 4
  %33 = load i32, i32* %nl.addr, align 4
  %mul33 = mul nsw i32 %32, %33
  %34 = load i32, i32* %j, align 4
  %add34 = add nsw i32 %mul33, %34
  %idxprom35 = sext i32 %add34 to i64
  %35 = load float*, float** %E.addr, align 8
  %arrayidx36 = getelementptr inbounds float, float* %35, i64 %idxprom35
  store float 0.000000e+00, float* %arrayidx36, align 4
  store i32 0, i32* %k, align 4
  br label %for.cond.37

for.cond.37:                                      ; preds = %for.inc.54, %for.body.32
  %36 = load i32, i32* %k, align 4
  %37 = load i32, i32* %nj.addr, align 4
  %cmp38 = icmp slt i32 %36, %37
  br i1 %cmp38, label %for.body.39, label %for.end.56

for.body.39:                                      ; preds = %for.cond.37
  %38 = load i32, i32* %i, align 4
  %39 = load i32, i32* %nj.addr, align 4
  %mul40 = mul nsw i32 %38, %39
  %40 = load i32, i32* %k, align 4
  %add41 = add nsw i32 %mul40, %40
  %idxprom42 = sext i32 %add41 to i64
  %41 = load float*, float** %C.addr, align 8
  %arrayidx43 = getelementptr inbounds float, float* %41, i64 %idxprom42
  %42 = load float, float* %arrayidx43, align 4
  %43 = load i32, i32* %k, align 4
  %44 = load i32, i32* %nl.addr, align 4
  %mul44 = mul nsw i32 %43, %44
  %45 = load i32, i32* %j, align 4
  %add45 = add nsw i32 %mul44, %45
  %idxprom46 = sext i32 %add45 to i64
  %46 = load float*, float** %D.addr, align 8
  %arrayidx47 = getelementptr inbounds float, float* %46, i64 %idxprom46
  %47 = load float, float* %arrayidx47, align 4
  %mul48 = fmul float %42, %47
  %48 = load i32, i32* %i, align 4
  %49 = load i32, i32* %nl.addr, align 4
  %mul49 = mul nsw i32 %48, %49
  %50 = load i32, i32* %j, align 4
  %add50 = add nsw i32 %mul49, %50
  %idxprom51 = sext i32 %add50 to i64
  %51 = load float*, float** %E.addr, align 8
  %arrayidx52 = getelementptr inbounds float, float* %51, i64 %idxprom51
  %52 = load float, float* %arrayidx52, align 4
  %add53 = fadd float %52, %mul48
  store float %add53, float* %arrayidx52, align 4
  br label %for.inc.54

for.inc.54:                                       ; preds = %for.body.39
  %53 = load i32, i32* %k, align 4
  %inc55 = add nsw i32 %53, 1
  store i32 %inc55, i32* %k, align 4
  br label %for.cond.37

for.end.56:                                       ; preds = %for.cond.37
  br label %for.inc.57

for.inc.57:                                       ; preds = %for.end.56
  %54 = load i32, i32* %j, align 4
  %inc58 = add nsw i32 %54, 1
  store i32 %inc58, i32* %j, align 4
  br label %for.cond.30

for.end.59:                                       ; preds = %for.cond.30
  br label %for.inc.60

for.inc.60:                                       ; preds = %for.end.59
  %55 = load i32, i32* %i, align 4
  %inc61 = add nsw i32 %55, 1
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
  %ni = alloca i32, align 4
  %nj = alloca i32, align 4
  %nk = alloca i32, align 4
  %nl = alloca i32, align 4
  %t_start = alloca double, align 8
  %t_end = alloca double, align 8
  %t_start_GPU = alloca double, align 8
  %t_end_GPU = alloca double, align 8
  %C = alloca float*, align 8
  %A = alloca float*, align 8
  %B = alloca float*, align 8
  %D = alloca float*, align 8
  %E = alloca float*, align 8
  store i32 0, i32* %retval
  store i32 %argc, i32* %argc.addr, align 4
  store i8** %argv, i8*** %argv.addr, align 8
  store i32 2048, i32* %ni, align 4
  store i32 2048, i32* %nj, align 4
  store i32 2048, i32* %nk, align 4
  store i32 2048, i32* %nl, align 4
  %0 = load i32, i32* %ni, align 4
  %1 = load i32, i32* %nj, align 4
  %mul = mul nsw i32 %0, %1
  %conv = sext i32 %mul to i64
  %mul1 = mul i64 %conv, 4
  %call = call noalias i8* @malloc(i64 %mul1) #3
  %2 = bitcast i8* %call to float*
  store float* %2, float** %C, align 8
  %3 = load i32, i32* %ni, align 4
  %4 = load i32, i32* %nk, align 4
  %mul2 = mul nsw i32 %3, %4
  %conv3 = sext i32 %mul2 to i64
  %mul4 = mul i64 %conv3, 4
  %call5 = call noalias i8* @malloc(i64 %mul4) #3
  %5 = bitcast i8* %call5 to float*
  store float* %5, float** %A, align 8
  %6 = load i32, i32* %nk, align 4
  %7 = load i32, i32* %nj, align 4
  %mul6 = mul nsw i32 %6, %7
  %conv7 = sext i32 %mul6 to i64
  %mul8 = mul i64 %conv7, 4
  %call9 = call noalias i8* @malloc(i64 %mul8) #3
  %8 = bitcast i8* %call9 to float*
  store float* %8, float** %B, align 8
  %9 = load i32, i32* %nj, align 4
  %10 = load i32, i32* %nl, align 4
  %mul10 = mul nsw i32 %9, %10
  %conv11 = sext i32 %mul10 to i64
  %mul12 = mul i64 %conv11, 4
  %call13 = call noalias i8* @malloc(i64 %mul12) #3
  %11 = bitcast i8* %call13 to float*
  store float* %11, float** %D, align 8
  %12 = load i32, i32* %ni, align 4
  %13 = load i32, i32* %nl, align 4
  %mul14 = mul nsw i32 %12, %13
  %conv15 = sext i32 %mul14 to i64
  %mul16 = mul i64 %conv15, 4
  %call17 = call noalias i8* @malloc(i64 %mul16) #3
  %14 = bitcast i8* %call17 to float*
  store float* %14, float** %E, align 8
  %15 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %call18 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %15, i8* getelementptr inbounds ([63 x i8], [63 x i8]* @.str.2, i32 0, i32 0))
  %16 = load i32, i32* %ni, align 4
  %17 = load i32, i32* %nj, align 4
  %18 = load i32, i32* %nk, align 4
  %19 = load i32, i32* %nl, align 4
  %20 = load float*, float** %A, align 8
  %21 = load float*, float** %B, align 8
  %22 = load float*, float** %C, align 8
  %23 = load float*, float** %D, align 8
  call void @init_array(i32 %16, i32 %17, i32 %18, i32 %19, float* %20, float* %21, float* %22, float* %23)
  %call19 = call double @rtclock()
  store double %call19, double* %t_start, align 8
  %24 = load i32, i32* %ni, align 4
  %25 = load i32, i32* %nj, align 4
  %26 = load i32, i32* %nk, align 4
  %27 = load i32, i32* %nl, align 4
  %28 = load float*, float** %A, align 8
  %29 = load float*, float** %B, align 8
  %30 = load float*, float** %C, align 8
  %31 = load float*, float** %D, align 8
  %32 = load float*, float** %E, align 8
  call void @mm2(i32 %24, i32 %25, i32 %26, i32 %27, float* %28, float* %29, float* %30, float* %31, float* %32)
  %call20 = call double @rtclock()
  store double %call20, double* %t_end, align 8
  %33 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %34 = load double, double* %t_end, align 8
  %35 = load double, double* %t_start, align 8
  %sub = fsub double %34, %35
  %call21 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %33, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.3, i32 0, i32 0), double %sub)
  %36 = load float*, float** %C, align 8
  %37 = bitcast float* %36 to i8*
  call void @free(i8* %37) #3
  %38 = load float*, float** %A, align 8
  %39 = bitcast float* %38 to i8*
  call void @free(i8* %39) #3
  %40 = load float*, float** %B, align 8
  %41 = bitcast float* %40 to i8*
  call void @free(i8* %41) #3
  %42 = load float*, float** %D, align 8
  %43 = bitcast float* %42 to i8*
  call void @free(i8* %43) #3
  %44 = load float*, float** %E, align 8
  %45 = bitcast float* %44 to i8*
  call void @free(i8* %45) #3
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
