; ModuleID = 'jacobi3d.c'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, i8*, i8*, i8*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type { %struct._IO_marker*, %struct._IO_FILE*, i32 }
%struct.timezone = type { i32, i32 }
%struct.timeval = type { i64, i64 }

@.str = private unnamed_addr constant [35 x i8] c"Error return from gettimeofday: %d\00", align 1
<<<<<<< HEAD
@.str.1 = private unnamed_addr constant [74 x i8] c"Non-Matching CPU-GPU Outputs Beyond Error Threshold of %4.2f Percent: %d\0A\00", align 1
@stdout = external global %struct._IO_FILE*, align 8
@.str.2 = private unnamed_addr constant [29 x i8] c">> 3D 7PT Jacobi Stencil <<\0A\00", align 1
@.str.3 = private unnamed_addr constant [22 x i8] c"CPU Runtime: %0.6lfs\0A\00", align 1
=======
@.str.1 = private unnamed_addr constant [51 x i8] c"Expected: %f, received: %f at position [%d,%d,%d]\0A\00", align 1
@.str.2 = private unnamed_addr constant [74 x i8] c"Non-Matching CPU-GPU Outputs Beyond Error Threshold of %4.2f Percent: %d\0A\00", align 1
@stdout = external global %struct._IO_FILE*, align 8
@.str.3 = private unnamed_addr constant [29 x i8] c">> 3D 7PT Jacobi Stencil <<\0A\00", align 1
@.str.4 = private unnamed_addr constant [22 x i8] c"CPU Runtime: %0.6lfs\0A\00", align 1
>>>>>>> a3e0d4f4e8669d5cf2aae8a9b08d26ab6c4a5279

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
define void @jacobi3d(i32 %tsteps, i32 %x, i32 %y, i32 %z, float* %A, float* %B) #0 {
entry:
  %tsteps.addr = alloca i32, align 4
  %x.addr = alloca i32, align 4
  %y.addr = alloca i32, align 4
  %z.addr = alloca i32, align 4
  %A.addr = alloca float*, align 8
  %B.addr = alloca float*, align 8
  %t = alloca i32, align 4
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %k = alloca i32, align 4
  %c0 = alloca float, align 4
  %c1 = alloca float, align 4
  %c2 = alloca float, align 4
  %c3 = alloca float, align 4
  %c4 = alloca float, align 4
  %c5 = alloca float, align 4
  %c6 = alloca float, align 4
  store i32 %tsteps, i32* %tsteps.addr, align 4
  store i32 %x, i32* %x.addr, align 4
  store i32 %y, i32* %y.addr, align 4
  store i32 %z, i32* %z.addr, align 4
  store float* %A, float** %A.addr, align 8
  store float* %B, float** %B.addr, align 8
<<<<<<< HEAD
  store float 2.000000e+00, float* %c0, align 4
  store float 5.000000e+00, float* %c1, align 4
  store float -8.000000e+00, float* %c2, align 4
  store float -3.000000e+00, float* %c3, align 4
  store float 6.000000e+00, float* %c4, align 4
  store float -9.000000e+00, float* %c5, align 4
  store float 4.000000e+00, float* %c6, align 4
  store i32 0, i32* %t, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.130, %entry
  %0 = load i32, i32* %t, align 4
  %1 = load i32, i32* %tsteps.addr, align 4
  %cmp = icmp slt i32 %0, %1
  br i1 %cmp, label %for.body, label %for.end.132

for.body:                                         ; preds = %for.cond
  store i32 2, i32* %i, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc.89, %for.body
  %2 = load i32, i32* %i, align 4
  %3 = load i32, i32* %z.addr, align 4
  %sub = sub nsw i32 %3, 1
  %sub2 = sub nsw i32 %sub, 1
  %cmp3 = icmp slt i32 %2, %sub2
  br i1 %cmp3, label %for.body.4, label %for.end.91

for.body.4:                                       ; preds = %for.cond.1
  store i32 2, i32* %j, align 4
  br label %for.cond.5

for.cond.5:                                       ; preds = %for.inc.86, %for.body.4
  %4 = load i32, i32* %j, align 4
  %5 = load i32, i32* %y.addr, align 4
  %sub6 = sub nsw i32 %5, 1
  %sub7 = sub nsw i32 %sub6, 1
  %cmp8 = icmp slt i32 %4, %sub7
  br i1 %cmp8, label %for.body.9, label %for.end.88

for.body.9:                                       ; preds = %for.cond.5
  store i32 2, i32* %k, align 4
  br label %for.cond.10

for.cond.10:                                      ; preds = %for.inc, %for.body.9
  %6 = load i32, i32* %k, align 4
  %7 = load i32, i32* %x.addr, align 4
  %sub11 = sub nsw i32 %7, 1
  %sub12 = sub nsw i32 %sub11, 1
  %cmp13 = icmp slt i32 %6, %sub12
  br i1 %cmp13, label %for.body.14, label %for.end

for.body.14:                                      ; preds = %for.cond.10
=======
  store float 1.000000e+00, float* %c0, align 4
  store float 1.000000e+00, float* %c1, align 4
  store float 1.000000e+00, float* %c2, align 4
  store float 1.000000e+00, float* %c3, align 4
  store float 1.000000e+00, float* %c4, align 4
  store float 1.000000e+00, float* %c5, align 4
  store float 1.000000e+00, float* %c6, align 4
  store i32 0, i32* %t, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.124, %entry
  %0 = load i32, i32* %t, align 4
  %1 = load i32, i32* %tsteps.addr, align 4
  %cmp = icmp slt i32 %0, %1
  br i1 %cmp, label %for.body, label %for.end.126

for.body:                                         ; preds = %for.cond
  store i32 1, i32* %i, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc.86, %for.body
  %2 = load i32, i32* %i, align 4
  %3 = load i32, i32* %z.addr, align 4
  %sub = sub nsw i32 %3, 1
  %cmp2 = icmp slt i32 %2, %sub
  br i1 %cmp2, label %for.body.3, label %for.end.88

for.body.3:                                       ; preds = %for.cond.1
  store i32 1, i32* %j, align 4
  br label %for.cond.4

for.cond.4:                                       ; preds = %for.inc.83, %for.body.3
  %4 = load i32, i32* %j, align 4
  %5 = load i32, i32* %y.addr, align 4
  %sub5 = sub nsw i32 %5, 1
  %cmp6 = icmp slt i32 %4, %sub5
  br i1 %cmp6, label %for.body.7, label %for.end.85

for.body.7:                                       ; preds = %for.cond.4
  store i32 1, i32* %k, align 4
  br label %for.cond.8

for.cond.8:                                       ; preds = %for.inc, %for.body.7
  %6 = load i32, i32* %k, align 4
  %7 = load i32, i32* %x.addr, align 4
  %sub9 = sub nsw i32 %7, 1
  %cmp10 = icmp slt i32 %6, %sub9
  br i1 %cmp10, label %for.body.11, label %for.end

for.body.11:                                      ; preds = %for.cond.8
>>>>>>> a3e0d4f4e8669d5cf2aae8a9b08d26ab6c4a5279
  %8 = load float, float* %c0, align 4
  %9 = load i32, i32* %i, align 4
  %10 = load i32, i32* %x.addr, align 4
  %11 = load i32, i32* %y.addr, align 4
  %mul = mul nsw i32 %10, %11
<<<<<<< HEAD
  %mul15 = mul nsw i32 %9, %mul
  %12 = load i32, i32* %j, align 4
  %13 = load i32, i32* %x.addr, align 4
  %mul16 = mul nsw i32 %12, %13
  %add = add nsw i32 %mul15, %mul16
  %14 = load i32, i32* %k, align 4
  %sub17 = sub nsw i32 %14, 1
  %add18 = add nsw i32 %add, %sub17
  %idxprom = sext i32 %add18 to i64
  %15 = load float*, float** %A.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %15, i64 %idxprom
  %16 = load float, float* %arrayidx, align 4
  %mul19 = fmul float %8, %16
=======
  %mul12 = mul nsw i32 %9, %mul
  %12 = load i32, i32* %j, align 4
  %13 = load i32, i32* %x.addr, align 4
  %mul13 = mul nsw i32 %12, %13
  %add = add nsw i32 %mul12, %mul13
  %14 = load i32, i32* %k, align 4
  %sub14 = sub nsw i32 %14, 1
  %add15 = add nsw i32 %add, %sub14
  %idxprom = sext i32 %add15 to i64
  %15 = load float*, float** %A.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %15, i64 %idxprom
  %16 = load float, float* %arrayidx, align 4
  %mul16 = fmul float %8, %16
>>>>>>> a3e0d4f4e8669d5cf2aae8a9b08d26ab6c4a5279
  %17 = load float, float* %c1, align 4
  %18 = load i32, i32* %i, align 4
  %19 = load i32, i32* %x.addr, align 4
  %20 = load i32, i32* %y.addr, align 4
<<<<<<< HEAD
  %mul20 = mul nsw i32 %19, %20
  %mul21 = mul nsw i32 %18, %mul20
  %21 = load i32, i32* %j, align 4
  %22 = load i32, i32* %x.addr, align 4
  %mul22 = mul nsw i32 %21, %22
  %add23 = add nsw i32 %mul21, %mul22
  %23 = load i32, i32* %k, align 4
  %add24 = add nsw i32 %add23, %23
  %idxprom25 = sext i32 %add24 to i64
  %24 = load float*, float** %A.addr, align 8
  %arrayidx26 = getelementptr inbounds float, float* %24, i64 %idxprom25
  %25 = load float, float* %arrayidx26, align 4
  %mul27 = fmul float %17, %25
  %add28 = fadd float %mul19, %mul27
=======
  %mul17 = mul nsw i32 %19, %20
  %mul18 = mul nsw i32 %18, %mul17
  %21 = load i32, i32* %j, align 4
  %22 = load i32, i32* %x.addr, align 4
  %mul19 = mul nsw i32 %21, %22
  %add20 = add nsw i32 %mul18, %mul19
  %23 = load i32, i32* %k, align 4
  %add21 = add nsw i32 %add20, %23
  %idxprom22 = sext i32 %add21 to i64
  %24 = load float*, float** %A.addr, align 8
  %arrayidx23 = getelementptr inbounds float, float* %24, i64 %idxprom22
  %25 = load float, float* %arrayidx23, align 4
  %mul24 = fmul float %17, %25
  %add25 = fadd float %mul16, %mul24
>>>>>>> a3e0d4f4e8669d5cf2aae8a9b08d26ab6c4a5279
  %26 = load float, float* %c2, align 4
  %27 = load i32, i32* %i, align 4
  %28 = load i32, i32* %x.addr, align 4
  %29 = load i32, i32* %y.addr, align 4
<<<<<<< HEAD
  %mul29 = mul nsw i32 %28, %29
  %mul30 = mul nsw i32 %27, %mul29
  %30 = load i32, i32* %j, align 4
  %31 = load i32, i32* %x.addr, align 4
  %mul31 = mul nsw i32 %30, %31
  %add32 = add nsw i32 %mul30, %mul31
  %32 = load i32, i32* %k, align 4
  %add33 = add nsw i32 %32, 1
  %add34 = add nsw i32 %add32, %add33
  %idxprom35 = sext i32 %add34 to i64
  %33 = load float*, float** %A.addr, align 8
  %arrayidx36 = getelementptr inbounds float, float* %33, i64 %idxprom35
  %34 = load float, float* %arrayidx36, align 4
  %mul37 = fmul float %26, %34
  %add38 = fadd float %add28, %mul37
  %35 = load float, float* %c3, align 4
  %36 = load i32, i32* %i, align 4
  %sub39 = sub nsw i32 %36, 1
  %37 = load i32, i32* %x.addr, align 4
  %38 = load i32, i32* %y.addr, align 4
  %mul40 = mul nsw i32 %37, %38
  %mul41 = mul nsw i32 %sub39, %mul40
  %39 = load i32, i32* %j, align 4
  %40 = load i32, i32* %x.addr, align 4
  %mul42 = mul nsw i32 %39, %40
  %add43 = add nsw i32 %mul41, %mul42
  %41 = load i32, i32* %k, align 4
  %add44 = add nsw i32 %add43, %41
  %idxprom45 = sext i32 %add44 to i64
  %42 = load float*, float** %A.addr, align 8
  %arrayidx46 = getelementptr inbounds float, float* %42, i64 %idxprom45
  %43 = load float, float* %arrayidx46, align 4
  %mul47 = fmul float %35, %43
  %add48 = fadd float %add38, %mul47
  %44 = load float, float* %c4, align 4
  %45 = load i32, i32* %i, align 4
  %add49 = add nsw i32 %45, 1
  %46 = load i32, i32* %x.addr, align 4
  %47 = load i32, i32* %y.addr, align 4
  %mul50 = mul nsw i32 %46, %47
  %mul51 = mul nsw i32 %add49, %mul50
  %48 = load i32, i32* %j, align 4
  %49 = load i32, i32* %x.addr, align 4
  %mul52 = mul nsw i32 %48, %49
  %add53 = add nsw i32 %mul51, %mul52
  %50 = load i32, i32* %k, align 4
  %add54 = add nsw i32 %add53, %50
  %idxprom55 = sext i32 %add54 to i64
  %51 = load float*, float** %A.addr, align 8
  %arrayidx56 = getelementptr inbounds float, float* %51, i64 %idxprom55
  %52 = load float, float* %arrayidx56, align 4
  %mul57 = fmul float %44, %52
  %add58 = fadd float %add48, %mul57
=======
  %mul26 = mul nsw i32 %28, %29
  %mul27 = mul nsw i32 %27, %mul26
  %30 = load i32, i32* %j, align 4
  %31 = load i32, i32* %x.addr, align 4
  %mul28 = mul nsw i32 %30, %31
  %add29 = add nsw i32 %mul27, %mul28
  %32 = load i32, i32* %k, align 4
  %add30 = add nsw i32 %32, 1
  %add31 = add nsw i32 %add29, %add30
  %idxprom32 = sext i32 %add31 to i64
  %33 = load float*, float** %A.addr, align 8
  %arrayidx33 = getelementptr inbounds float, float* %33, i64 %idxprom32
  %34 = load float, float* %arrayidx33, align 4
  %mul34 = fmul float %26, %34
  %add35 = fadd float %add25, %mul34
  %35 = load float, float* %c3, align 4
  %36 = load i32, i32* %i, align 4
  %sub36 = sub nsw i32 %36, 1
  %37 = load i32, i32* %x.addr, align 4
  %38 = load i32, i32* %y.addr, align 4
  %mul37 = mul nsw i32 %37, %38
  %mul38 = mul nsw i32 %sub36, %mul37
  %39 = load i32, i32* %j, align 4
  %40 = load i32, i32* %x.addr, align 4
  %mul39 = mul nsw i32 %39, %40
  %add40 = add nsw i32 %mul38, %mul39
  %41 = load i32, i32* %k, align 4
  %add41 = add nsw i32 %add40, %41
  %idxprom42 = sext i32 %add41 to i64
  %42 = load float*, float** %A.addr, align 8
  %arrayidx43 = getelementptr inbounds float, float* %42, i64 %idxprom42
  %43 = load float, float* %arrayidx43, align 4
  %mul44 = fmul float %35, %43
  %add45 = fadd float %add35, %mul44
  %44 = load float, float* %c4, align 4
  %45 = load i32, i32* %i, align 4
  %add46 = add nsw i32 %45, 1
  %46 = load i32, i32* %x.addr, align 4
  %47 = load i32, i32* %y.addr, align 4
  %mul47 = mul nsw i32 %46, %47
  %mul48 = mul nsw i32 %add46, %mul47
  %48 = load i32, i32* %j, align 4
  %49 = load i32, i32* %x.addr, align 4
  %mul49 = mul nsw i32 %48, %49
  %add50 = add nsw i32 %mul48, %mul49
  %50 = load i32, i32* %k, align 4
  %add51 = add nsw i32 %add50, %50
  %idxprom52 = sext i32 %add51 to i64
  %51 = load float*, float** %A.addr, align 8
  %arrayidx53 = getelementptr inbounds float, float* %51, i64 %idxprom52
  %52 = load float, float* %arrayidx53, align 4
  %mul54 = fmul float %44, %52
  %add55 = fadd float %add45, %mul54
>>>>>>> a3e0d4f4e8669d5cf2aae8a9b08d26ab6c4a5279
  %53 = load float, float* %c5, align 4
  %54 = load i32, i32* %i, align 4
  %55 = load i32, i32* %x.addr, align 4
  %56 = load i32, i32* %y.addr, align 4
<<<<<<< HEAD
  %mul59 = mul nsw i32 %55, %56
  %mul60 = mul nsw i32 %54, %mul59
  %57 = load i32, i32* %j, align 4
  %sub61 = sub nsw i32 %57, 1
  %58 = load i32, i32* %x.addr, align 4
  %mul62 = mul nsw i32 %sub61, %58
  %add63 = add nsw i32 %mul60, %mul62
  %59 = load i32, i32* %k, align 4
  %add64 = add nsw i32 %add63, %59
  %idxprom65 = sext i32 %add64 to i64
  %60 = load float*, float** %A.addr, align 8
  %arrayidx66 = getelementptr inbounds float, float* %60, i64 %idxprom65
  %61 = load float, float* %arrayidx66, align 4
  %mul67 = fmul float %53, %61
  %add68 = fadd float %add58, %mul67
=======
  %mul56 = mul nsw i32 %55, %56
  %mul57 = mul nsw i32 %54, %mul56
  %57 = load i32, i32* %j, align 4
  %sub58 = sub nsw i32 %57, 1
  %58 = load i32, i32* %x.addr, align 4
  %mul59 = mul nsw i32 %sub58, %58
  %add60 = add nsw i32 %mul57, %mul59
  %59 = load i32, i32* %k, align 4
  %add61 = add nsw i32 %add60, %59
  %idxprom62 = sext i32 %add61 to i64
  %60 = load float*, float** %A.addr, align 8
  %arrayidx63 = getelementptr inbounds float, float* %60, i64 %idxprom62
  %61 = load float, float* %arrayidx63, align 4
  %mul64 = fmul float %53, %61
  %add65 = fadd float %add55, %mul64
>>>>>>> a3e0d4f4e8669d5cf2aae8a9b08d26ab6c4a5279
  %62 = load float, float* %c6, align 4
  %63 = load i32, i32* %i, align 4
  %64 = load i32, i32* %x.addr, align 4
  %65 = load i32, i32* %y.addr, align 4
<<<<<<< HEAD
  %mul69 = mul nsw i32 %64, %65
  %mul70 = mul nsw i32 %63, %mul69
  %66 = load i32, i32* %j, align 4
  %add71 = add nsw i32 %66, 1
  %67 = load i32, i32* %x.addr, align 4
  %mul72 = mul nsw i32 %add71, %67
  %add73 = add nsw i32 %mul70, %mul72
  %68 = load i32, i32* %k, align 4
  %add74 = add nsw i32 %add73, %68
  %idxprom75 = sext i32 %add74 to i64
  %69 = load float*, float** %A.addr, align 8
  %arrayidx76 = getelementptr inbounds float, float* %69, i64 %idxprom75
  %70 = load float, float* %arrayidx76, align 4
  %mul77 = fmul float %62, %70
  %add78 = fadd float %add68, %mul77
  %71 = load i32, i32* %i, align 4
  %72 = load i32, i32* %x.addr, align 4
  %73 = load i32, i32* %y.addr, align 4
  %mul79 = mul nsw i32 %72, %73
  %mul80 = mul nsw i32 %71, %mul79
  %74 = load i32, i32* %j, align 4
  %75 = load i32, i32* %x.addr, align 4
  %mul81 = mul nsw i32 %74, %75
  %add82 = add nsw i32 %mul80, %mul81
  %76 = load i32, i32* %k, align 4
  %add83 = add nsw i32 %add82, %76
  %idxprom84 = sext i32 %add83 to i64
  %77 = load float*, float** %B.addr, align 8
  %arrayidx85 = getelementptr inbounds float, float* %77, i64 %idxprom84
  store float %add78, float* %arrayidx85, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.14
  %78 = load i32, i32* %k, align 4
  %inc = add nsw i32 %78, 1
  store i32 %inc, i32* %k, align 4
  br label %for.cond.10

for.end:                                          ; preds = %for.cond.10
  br label %for.inc.86

for.inc.86:                                       ; preds = %for.end
  %79 = load i32, i32* %j, align 4
  %inc87 = add nsw i32 %79, 1
  store i32 %inc87, i32* %j, align 4
  br label %for.cond.5

for.end.88:                                       ; preds = %for.cond.5
  br label %for.inc.89

for.inc.89:                                       ; preds = %for.end.88
  %80 = load i32, i32* %i, align 4
  %inc90 = add nsw i32 %80, 1
  store i32 %inc90, i32* %i, align 4
  br label %for.cond.1

for.end.91:                                       ; preds = %for.cond.1
  store i32 2, i32* %i, align 4
  br label %for.cond.92

for.cond.92:                                      ; preds = %for.inc.127, %for.end.91
  %81 = load i32, i32* %i, align 4
  %82 = load i32, i32* %z.addr, align 4
  %sub93 = sub nsw i32 %82, 1
  %sub94 = sub nsw i32 %sub93, 1
  %cmp95 = icmp slt i32 %81, %sub94
  br i1 %cmp95, label %for.body.96, label %for.end.129

for.body.96:                                      ; preds = %for.cond.92
  store i32 2, i32* %j, align 4
  br label %for.cond.97

for.cond.97:                                      ; preds = %for.inc.124, %for.body.96
  %83 = load i32, i32* %j, align 4
  %84 = load i32, i32* %y.addr, align 4
  %sub98 = sub nsw i32 %84, 1
  %sub99 = sub nsw i32 %sub98, 1
  %cmp100 = icmp slt i32 %83, %sub99
  br i1 %cmp100, label %for.body.101, label %for.end.126

for.body.101:                                     ; preds = %for.cond.97
  store i32 2, i32* %k, align 4
  br label %for.cond.102

for.cond.102:                                     ; preds = %for.inc.121, %for.body.101
  %85 = load i32, i32* %k, align 4
  %86 = load i32, i32* %x.addr, align 4
  %sub103 = sub nsw i32 %86, 1
  %sub104 = sub nsw i32 %sub103, 1
  %cmp105 = icmp slt i32 %85, %sub104
  br i1 %cmp105, label %for.body.106, label %for.end.123

for.body.106:                                     ; preds = %for.cond.102
  %87 = load i32, i32* %i, align 4
  %88 = load i32, i32* %x.addr, align 4
  %89 = load i32, i32* %y.addr, align 4
  %mul107 = mul nsw i32 %88, %89
  %mul108 = mul nsw i32 %87, %mul107
  %90 = load i32, i32* %j, align 4
  %91 = load i32, i32* %x.addr, align 4
  %mul109 = mul nsw i32 %90, %91
  %add110 = add nsw i32 %mul108, %mul109
  %92 = load i32, i32* %k, align 4
  %add111 = add nsw i32 %add110, %92
  %idxprom112 = sext i32 %add111 to i64
  %93 = load float*, float** %B.addr, align 8
  %arrayidx113 = getelementptr inbounds float, float* %93, i64 %idxprom112
  %94 = load float, float* %arrayidx113, align 4
  %95 = load i32, i32* %i, align 4
  %96 = load i32, i32* %x.addr, align 4
  %97 = load i32, i32* %y.addr, align 4
  %mul114 = mul nsw i32 %96, %97
  %mul115 = mul nsw i32 %95, %mul114
  %98 = load i32, i32* %j, align 4
  %99 = load i32, i32* %z.addr, align 4
  %mul116 = mul nsw i32 %98, %99
  %add117 = add nsw i32 %mul115, %mul116
  %100 = load i32, i32* %k, align 4
  %add118 = add nsw i32 %add117, %100
  %idxprom119 = sext i32 %add118 to i64
  %101 = load float*, float** %A.addr, align 8
  %arrayidx120 = getelementptr inbounds float, float* %101, i64 %idxprom119
  store float %94, float* %arrayidx120, align 4
  br label %for.inc.121

for.inc.121:                                      ; preds = %for.body.106
  %102 = load i32, i32* %k, align 4
  %inc122 = add nsw i32 %102, 1
  store i32 %inc122, i32* %k, align 4
  br label %for.cond.102

for.end.123:                                      ; preds = %for.cond.102
  br label %for.inc.124

for.inc.124:                                      ; preds = %for.end.123
  %103 = load i32, i32* %j, align 4
  %inc125 = add nsw i32 %103, 1
  store i32 %inc125, i32* %j, align 4
  br label %for.cond.97

for.end.126:                                      ; preds = %for.cond.97
  br label %for.inc.127

for.inc.127:                                      ; preds = %for.end.126
  %104 = load i32, i32* %i, align 4
  %inc128 = add nsw i32 %104, 1
  store i32 %inc128, i32* %i, align 4
  br label %for.cond.92

for.end.129:                                      ; preds = %for.cond.92
  br label %for.inc.130

for.inc.130:                                      ; preds = %for.end.129
  %105 = load i32, i32* %t, align 4
  %inc131 = add nsw i32 %105, 1
  store i32 %inc131, i32* %t, align 4
  br label %for.cond

for.end.132:                                      ; preds = %for.cond
=======
  %mul66 = mul nsw i32 %64, %65
  %mul67 = mul nsw i32 %63, %mul66
  %66 = load i32, i32* %j, align 4
  %add68 = add nsw i32 %66, 1
  %67 = load i32, i32* %x.addr, align 4
  %mul69 = mul nsw i32 %add68, %67
  %add70 = add nsw i32 %mul67, %mul69
  %68 = load i32, i32* %k, align 4
  %add71 = add nsw i32 %add70, %68
  %idxprom72 = sext i32 %add71 to i64
  %69 = load float*, float** %A.addr, align 8
  %arrayidx73 = getelementptr inbounds float, float* %69, i64 %idxprom72
  %70 = load float, float* %arrayidx73, align 4
  %mul74 = fmul float %62, %70
  %add75 = fadd float %add65, %mul74
  %71 = load i32, i32* %i, align 4
  %72 = load i32, i32* %x.addr, align 4
  %73 = load i32, i32* %y.addr, align 4
  %mul76 = mul nsw i32 %72, %73
  %mul77 = mul nsw i32 %71, %mul76
  %74 = load i32, i32* %j, align 4
  %75 = load i32, i32* %x.addr, align 4
  %mul78 = mul nsw i32 %74, %75
  %add79 = add nsw i32 %mul77, %mul78
  %76 = load i32, i32* %k, align 4
  %add80 = add nsw i32 %add79, %76
  %idxprom81 = sext i32 %add80 to i64
  %77 = load float*, float** %B.addr, align 8
  %arrayidx82 = getelementptr inbounds float, float* %77, i64 %idxprom81
  store float %add75, float* %arrayidx82, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.11
  %78 = load i32, i32* %k, align 4
  %inc = add nsw i32 %78, 1
  store i32 %inc, i32* %k, align 4
  br label %for.cond.8

for.end:                                          ; preds = %for.cond.8
  br label %for.inc.83

for.inc.83:                                       ; preds = %for.end
  %79 = load i32, i32* %j, align 4
  %inc84 = add nsw i32 %79, 1
  store i32 %inc84, i32* %j, align 4
  br label %for.cond.4

for.end.85:                                       ; preds = %for.cond.4
  br label %for.inc.86

for.inc.86:                                       ; preds = %for.end.85
  %80 = load i32, i32* %i, align 4
  %inc87 = add nsw i32 %80, 1
  store i32 %inc87, i32* %i, align 4
  br label %for.cond.1

for.end.88:                                       ; preds = %for.cond.1
  store i32 1, i32* %i, align 4
  br label %for.cond.89

for.cond.89:                                      ; preds = %for.inc.121, %for.end.88
  %81 = load i32, i32* %i, align 4
  %82 = load i32, i32* %z.addr, align 4
  %sub90 = sub nsw i32 %82, 1
  %cmp91 = icmp slt i32 %81, %sub90
  br i1 %cmp91, label %for.body.92, label %for.end.123

for.body.92:                                      ; preds = %for.cond.89
  store i32 1, i32* %j, align 4
  br label %for.cond.93

for.cond.93:                                      ; preds = %for.inc.118, %for.body.92
  %83 = load i32, i32* %j, align 4
  %84 = load i32, i32* %y.addr, align 4
  %sub94 = sub nsw i32 %84, 1
  %cmp95 = icmp slt i32 %83, %sub94
  br i1 %cmp95, label %for.body.96, label %for.end.120

for.body.96:                                      ; preds = %for.cond.93
  store i32 1, i32* %k, align 4
  br label %for.cond.97

for.cond.97:                                      ; preds = %for.inc.115, %for.body.96
  %85 = load i32, i32* %k, align 4
  %86 = load i32, i32* %x.addr, align 4
  %sub98 = sub nsw i32 %86, 1
  %cmp99 = icmp slt i32 %85, %sub98
  br i1 %cmp99, label %for.body.100, label %for.end.117

for.body.100:                                     ; preds = %for.cond.97
  %87 = load i32, i32* %i, align 4
  %88 = load i32, i32* %x.addr, align 4
  %89 = load i32, i32* %y.addr, align 4
  %mul101 = mul nsw i32 %88, %89
  %mul102 = mul nsw i32 %87, %mul101
  %90 = load i32, i32* %j, align 4
  %91 = load i32, i32* %x.addr, align 4
  %mul103 = mul nsw i32 %90, %91
  %add104 = add nsw i32 %mul102, %mul103
  %92 = load i32, i32* %k, align 4
  %add105 = add nsw i32 %add104, %92
  %idxprom106 = sext i32 %add105 to i64
  %93 = load float*, float** %B.addr, align 8
  %arrayidx107 = getelementptr inbounds float, float* %93, i64 %idxprom106
  %94 = load float, float* %arrayidx107, align 4
  %95 = load i32, i32* %i, align 4
  %96 = load i32, i32* %x.addr, align 4
  %97 = load i32, i32* %y.addr, align 4
  %mul108 = mul nsw i32 %96, %97
  %mul109 = mul nsw i32 %95, %mul108
  %98 = load i32, i32* %j, align 4
  %99 = load i32, i32* %z.addr, align 4
  %mul110 = mul nsw i32 %98, %99
  %add111 = add nsw i32 %mul109, %mul110
  %100 = load i32, i32* %k, align 4
  %add112 = add nsw i32 %add111, %100
  %idxprom113 = sext i32 %add112 to i64
  %101 = load float*, float** %A.addr, align 8
  %arrayidx114 = getelementptr inbounds float, float* %101, i64 %idxprom113
  store float %94, float* %arrayidx114, align 4
  br label %for.inc.115

for.inc.115:                                      ; preds = %for.body.100
  %102 = load i32, i32* %k, align 4
  %inc116 = add nsw i32 %102, 1
  store i32 %inc116, i32* %k, align 4
  br label %for.cond.97

for.end.117:                                      ; preds = %for.cond.97
  br label %for.inc.118

for.inc.118:                                      ; preds = %for.end.117
  %103 = load i32, i32* %j, align 4
  %inc119 = add nsw i32 %103, 1
  store i32 %inc119, i32* %j, align 4
  br label %for.cond.93

for.end.120:                                      ; preds = %for.cond.93
  br label %for.inc.121

for.inc.121:                                      ; preds = %for.end.120
  %104 = load i32, i32* %i, align 4
  %inc122 = add nsw i32 %104, 1
  store i32 %inc122, i32* %i, align 4
  br label %for.cond.89

for.end.123:                                      ; preds = %for.cond.89
  br label %for.inc.124

for.inc.124:                                      ; preds = %for.end.123
  %105 = load i32, i32* %t, align 4
  %inc125 = add nsw i32 %105, 1
  store i32 %inc125, i32* %t, align 4
  br label %for.cond

for.end.126:                                      ; preds = %for.cond
>>>>>>> a3e0d4f4e8669d5cf2aae8a9b08d26ab6c4a5279
  ret void
}

; Function Attrs: nounwind uwtable
<<<<<<< HEAD
define void @init(float* %A) #0 {
entry:
  %A.addr = alloca float*, align 8
=======
define void @init(float* %A, i32 %x, i32 %y, i32 %z, i32 %offset_x, i32 %offset_y, i32 %offset_z) #0 {
entry:
  %A.addr = alloca float*, align 8
  %x.addr = alloca i32, align 4
  %y.addr = alloca i32, align 4
  %z.addr = alloca i32, align 4
  %offset_x.addr = alloca i32, align 4
  %offset_y.addr = alloca i32, align 4
  %offset_z.addr = alloca i32, align 4
>>>>>>> a3e0d4f4e8669d5cf2aae8a9b08d26ab6c4a5279
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %k = alloca i32, align 4
  store float* %A, float** %A.addr, align 8
<<<<<<< HEAD
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.34, %entry
  %0 = load i32, i32* %i, align 4
  %cmp = icmp slt i32 %0, 192
  br i1 %cmp, label %for.body, label %for.end.36
=======
  store i32 %x, i32* %x.addr, align 4
  store i32 %y, i32* %y.addr, align 4
  store i32 %z, i32* %z.addr, align 4
  store i32 %offset_x, i32* %offset_x.addr, align 4
  store i32 %offset_y, i32* %offset_y.addr, align 4
  store i32 %offset_z, i32* %offset_z.addr, align 4
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.32, %entry
  %0 = load i32, i32* %i, align 4
  %1 = load i32, i32* %z.addr, align 4
  %cmp = icmp slt i32 %0, %1
  br i1 %cmp, label %for.body, label %for.end.34
>>>>>>> a3e0d4f4e8669d5cf2aae8a9b08d26ab6c4a5279

for.body:                                         ; preds = %for.cond
  store i32 0, i32* %j, align 4
  br label %for.cond.1

<<<<<<< HEAD
for.cond.1:                                       ; preds = %for.inc.31, %for.body
  %1 = load i32, i32* %j, align 4
  %cmp2 = icmp slt i32 %1, 192
  br i1 %cmp2, label %for.body.3, label %for.end.33
=======
for.cond.1:                                       ; preds = %for.inc.29, %for.body
  %2 = load i32, i32* %j, align 4
  %3 = load i32, i32* %y.addr, align 4
  %cmp2 = icmp slt i32 %2, %3
  br i1 %cmp2, label %for.body.3, label %for.end.31
>>>>>>> a3e0d4f4e8669d5cf2aae8a9b08d26ab6c4a5279

for.body.3:                                       ; preds = %for.cond.1
  store i32 0, i32* %k, align 4
  br label %for.cond.4

for.cond.4:                                       ; preds = %for.inc, %for.body.3
<<<<<<< HEAD
  %2 = load i32, i32* %k, align 4
  %cmp5 = icmp slt i32 %2, 192
  br i1 %cmp5, label %for.body.6, label %for.end

for.body.6:                                       ; preds = %for.cond.4
  %3 = load i32, i32* %i, align 4
  %cmp7 = icmp slt i32 %3, 2
  br i1 %cmp7, label %if.then, label %lor.lhs.false

lor.lhs.false:                                    ; preds = %for.body.6
  %4 = load i32, i32* %j, align 4
  %cmp8 = icmp slt i32 %4, 2
  br i1 %cmp8, label %if.then, label %lor.lhs.false.9

lor.lhs.false.9:                                  ; preds = %lor.lhs.false
  %5 = load i32, i32* %i, align 4
  %cmp10 = icmp sge i32 %5, 190
  br i1 %cmp10, label %if.then, label %lor.lhs.false.11

lor.lhs.false.11:                                 ; preds = %lor.lhs.false.9
  %6 = load i32, i32* %j, align 4
  %cmp12 = icmp sge i32 %6, 190
  br i1 %cmp12, label %if.then, label %lor.lhs.false.13

lor.lhs.false.13:                                 ; preds = %lor.lhs.false.11
  %7 = load i32, i32* %k, align 4
  %cmp14 = icmp slt i32 %7, 2
  br i1 %cmp14, label %if.then, label %lor.lhs.false.15

lor.lhs.false.15:                                 ; preds = %lor.lhs.false.13
  %8 = load i32, i32* %k, align 4
  %cmp16 = icmp sge i32 %8, 190
  br i1 %cmp16, label %if.then, label %if.else

if.then:                                          ; preds = %lor.lhs.false.15, %lor.lhs.false.13, %lor.lhs.false.11, %lor.lhs.false.9, %lor.lhs.false, %for.body.6
  %9 = load i32, i32* %i, align 4
  %mul = mul nsw i32 %9, 36864
  %10 = load i32, i32* %j, align 4
  %mul17 = mul nsw i32 %10, 192
  %add = add nsw i32 %mul, %mul17
  %11 = load i32, i32* %k, align 4
  %add18 = add nsw i32 %add, %11
  %idxprom = sext i32 %add18 to i64
  %12 = load float*, float** %A.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %12, i64 %idxprom
  store float 0.000000e+00, float* %arrayidx, align 4
  br label %if.end

if.else:                                          ; preds = %lor.lhs.false.15
  %13 = load i32, i32* %i, align 4
  %rem = srem i32 %13, 12
  %14 = load i32, i32* %j, align 4
  %rem19 = srem i32 %14, 7
  %mul20 = mul nsw i32 2, %rem19
  %add21 = add nsw i32 %rem, %mul20
  %15 = load i32, i32* %k, align 4
  %rem22 = srem i32 %15, 13
  %mul23 = mul nsw i32 3, %rem22
  %add24 = add nsw i32 %add21, %mul23
  %conv = sitofp i32 %add24 to float
  %16 = load i32, i32* %i, align 4
  %mul25 = mul nsw i32 %16, 36864
  %17 = load i32, i32* %j, align 4
  %mul26 = mul nsw i32 %17, 192
  %add27 = add nsw i32 %mul25, %mul26
  %18 = load i32, i32* %k, align 4
  %add28 = add nsw i32 %add27, %18
  %idxprom29 = sext i32 %add28 to i64
  %19 = load float*, float** %A.addr, align 8
  %arrayidx30 = getelementptr inbounds float, float* %19, i64 %idxprom29
  store float %conv, float* %arrayidx30, align 4
=======
  %4 = load i32, i32* %k, align 4
  %5 = load i32, i32* %x.addr, align 4
  %cmp5 = icmp slt i32 %4, %5
  br i1 %cmp5, label %for.body.6, label %for.end

for.body.6:                                       ; preds = %for.cond.4
  %6 = load i32, i32* %i, align 4
  %7 = load i32, i32* %offset_z.addr, align 4
  %cmp7 = icmp slt i32 %6, %7
  br i1 %cmp7, label %if.then, label %lor.lhs.false

lor.lhs.false:                                    ; preds = %for.body.6
  %8 = load i32, i32* %j, align 4
  %9 = load i32, i32* %offset_y.addr, align 4
  %cmp8 = icmp slt i32 %8, %9
  br i1 %cmp8, label %if.then, label %lor.lhs.false.9

lor.lhs.false.9:                                  ; preds = %lor.lhs.false
  %10 = load i32, i32* %i, align 4
  %11 = load i32, i32* %z.addr, align 4
  %12 = load i32, i32* %offset_z.addr, align 4
  %sub = sub nsw i32 %11, %12
  %cmp10 = icmp sge i32 %10, %sub
  br i1 %cmp10, label %if.then, label %lor.lhs.false.11

lor.lhs.false.11:                                 ; preds = %lor.lhs.false.9
  %13 = load i32, i32* %j, align 4
  %14 = load i32, i32* %y.addr, align 4
  %15 = load i32, i32* %offset_y.addr, align 4
  %sub12 = sub nsw i32 %14, %15
  %cmp13 = icmp sge i32 %13, %sub12
  br i1 %cmp13, label %if.then, label %lor.lhs.false.14

lor.lhs.false.14:                                 ; preds = %lor.lhs.false.11
  %16 = load i32, i32* %k, align 4
  %17 = load i32, i32* %offset_x.addr, align 4
  %cmp15 = icmp slt i32 %16, %17
  br i1 %cmp15, label %if.then, label %lor.lhs.false.16

lor.lhs.false.16:                                 ; preds = %lor.lhs.false.14
  %18 = load i32, i32* %k, align 4
  %19 = load i32, i32* %x.addr, align 4
  %20 = load i32, i32* %offset_x.addr, align 4
  %sub17 = sub nsw i32 %19, %20
  %cmp18 = icmp sge i32 %18, %sub17
  br i1 %cmp18, label %if.then, label %if.else

if.then:                                          ; preds = %lor.lhs.false.16, %lor.lhs.false.14, %lor.lhs.false.11, %lor.lhs.false.9, %lor.lhs.false, %for.body.6
  %21 = load i32, i32* %i, align 4
  %22 = load i32, i32* %x.addr, align 4
  %23 = load i32, i32* %y.addr, align 4
  %mul = mul nsw i32 %22, %23
  %mul19 = mul nsw i32 %21, %mul
  %24 = load i32, i32* %j, align 4
  %25 = load i32, i32* %x.addr, align 4
  %mul20 = mul nsw i32 %24, %25
  %add = add nsw i32 %mul19, %mul20
  %26 = load i32, i32* %k, align 4
  %add21 = add nsw i32 %add, %26
  %idxprom = sext i32 %add21 to i64
  %27 = load float*, float** %A.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %27, i64 %idxprom
  store float 0.000000e+00, float* %arrayidx, align 4
  br label %if.end

if.else:                                          ; preds = %lor.lhs.false.16
  %28 = load i32, i32* %i, align 4
  %29 = load i32, i32* %x.addr, align 4
  %30 = load i32, i32* %y.addr, align 4
  %mul22 = mul nsw i32 %29, %30
  %mul23 = mul nsw i32 %28, %mul22
  %31 = load i32, i32* %j, align 4
  %32 = load i32, i32* %x.addr, align 4
  %mul24 = mul nsw i32 %31, %32
  %add25 = add nsw i32 %mul23, %mul24
  %33 = load i32, i32* %k, align 4
  %add26 = add nsw i32 %add25, %33
  %idxprom27 = sext i32 %add26 to i64
  %34 = load float*, float** %A.addr, align 8
  %arrayidx28 = getelementptr inbounds float, float* %34, i64 %idxprom27
  store float 1.000000e+00, float* %arrayidx28, align 4
>>>>>>> a3e0d4f4e8669d5cf2aae8a9b08d26ab6c4a5279
  br label %if.end

if.end:                                           ; preds = %if.else, %if.then
  br label %for.inc

for.inc:                                          ; preds = %if.end
<<<<<<< HEAD
  %20 = load i32, i32* %k, align 4
  %inc = add nsw i32 %20, 1
=======
  %35 = load i32, i32* %k, align 4
  %inc = add nsw i32 %35, 1
>>>>>>> a3e0d4f4e8669d5cf2aae8a9b08d26ab6c4a5279
  store i32 %inc, i32* %k, align 4
  br label %for.cond.4

for.end:                                          ; preds = %for.cond.4
<<<<<<< HEAD
  br label %for.inc.31

for.inc.31:                                       ; preds = %for.end
  %21 = load i32, i32* %j, align 4
  %inc32 = add nsw i32 %21, 1
  store i32 %inc32, i32* %j, align 4
  br label %for.cond.1

for.end.33:                                       ; preds = %for.cond.1
  br label %for.inc.34

for.inc.34:                                       ; preds = %for.end.33
  %22 = load i32, i32* %i, align 4
  %inc35 = add nsw i32 %22, 1
  store i32 %inc35, i32* %i, align 4
  br label %for.cond

for.end.36:                                       ; preds = %for.cond
=======
  br label %for.inc.29

for.inc.29:                                       ; preds = %for.end
  %36 = load i32, i32* %j, align 4
  %inc30 = add nsw i32 %36, 1
  store i32 %inc30, i32* %j, align 4
  br label %for.cond.1

for.end.31:                                       ; preds = %for.cond.1
  br label %for.inc.32

for.inc.32:                                       ; preds = %for.end.31
  %37 = load i32, i32* %i, align 4
  %inc33 = add nsw i32 %37, 1
  store i32 %inc33, i32* %i, align 4
  br label %for.cond

for.end.34:                                       ; preds = %for.cond
>>>>>>> a3e0d4f4e8669d5cf2aae8a9b08d26ab6c4a5279
  ret void
}

; Function Attrs: nounwind uwtable
<<<<<<< HEAD
=======
define i32 @checkResult(float* %a, float* %ref, i32 %dimx, i32 %dimy, i32 %dimz) #0 {
entry:
  %a.addr = alloca float*, align 8
  %ref.addr = alloca float*, align 8
  %dimx.addr = alloca i32, align 4
  %dimy.addr = alloca i32, align 4
  %dimz.addr = alloca i32, align 4
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %k = alloca i32, align 4
  store float* %a, float** %a.addr, align 8
  store float* %ref, float** %ref.addr, align 8
  store i32 %dimx, i32* %dimx.addr, align 4
  store i32 %dimy, i32* %dimy.addr, align 4
  store i32 %dimz, i32* %dimz.addr, align 4
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.36, %entry
  %0 = load i32, i32* %i, align 4
  %1 = load i32, i32* %dimz.addr, align 4
  %cmp = icmp slt i32 %0, %1
  br i1 %cmp, label %for.body, label %for.end.38

for.body:                                         ; preds = %for.cond
  store i32 0, i32* %j, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc.33, %for.body
  %2 = load i32, i32* %j, align 4
  %3 = load i32, i32* %dimy.addr, align 4
  %cmp2 = icmp slt i32 %2, %3
  br i1 %cmp2, label %for.body.3, label %for.end.35

for.body.3:                                       ; preds = %for.cond.1
  store i32 0, i32* %k, align 4
  br label %for.cond.4

for.cond.4:                                       ; preds = %for.inc, %for.body.3
  %4 = load i32, i32* %k, align 4
  %5 = load i32, i32* %dimx.addr, align 4
  %cmp5 = icmp slt i32 %4, %5
  br i1 %cmp5, label %for.body.6, label %for.end

for.body.6:                                       ; preds = %for.cond.4
  %6 = load i32, i32* %i, align 4
  %7 = load i32, i32* %dimx.addr, align 4
  %mul = mul nsw i32 %6, %7
  %8 = load i32, i32* %dimy.addr, align 4
  %mul7 = mul nsw i32 %mul, %8
  %9 = load i32, i32* %j, align 4
  %10 = load i32, i32* %dimx.addr, align 4
  %mul8 = mul nsw i32 %9, %10
  %add = add nsw i32 %mul7, %mul8
  %11 = load i32, i32* %k, align 4
  %add9 = add nsw i32 %add, %11
  %idxprom = sext i32 %add9 to i64
  %12 = load float*, float** %a.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %12, i64 %idxprom
  %13 = load float, float* %arrayidx, align 4
  %14 = load i32, i32* %i, align 4
  %15 = load i32, i32* %dimx.addr, align 4
  %mul10 = mul nsw i32 %14, %15
  %16 = load i32, i32* %dimy.addr, align 4
  %mul11 = mul nsw i32 %mul10, %16
  %17 = load i32, i32* %j, align 4
  %18 = load i32, i32* %dimx.addr, align 4
  %mul12 = mul nsw i32 %17, %18
  %add13 = add nsw i32 %mul11, %mul12
  %19 = load i32, i32* %k, align 4
  %add14 = add nsw i32 %add13, %19
  %idxprom15 = sext i32 %add14 to i64
  %20 = load float*, float** %ref.addr, align 8
  %arrayidx16 = getelementptr inbounds float, float* %20, i64 %idxprom15
  %21 = load float, float* %arrayidx16, align 4
  %cmp17 = fcmp une float %13, %21
  br i1 %cmp17, label %if.then, label %if.end

if.then:                                          ; preds = %for.body.6
  %22 = load i32, i32* %i, align 4
  %23 = load i32, i32* %dimx.addr, align 4
  %mul18 = mul nsw i32 %22, %23
  %24 = load i32, i32* %dimy.addr, align 4
  %mul19 = mul nsw i32 %mul18, %24
  %25 = load i32, i32* %j, align 4
  %26 = load i32, i32* %dimx.addr, align 4
  %mul20 = mul nsw i32 %25, %26
  %add21 = add nsw i32 %mul19, %mul20
  %27 = load i32, i32* %k, align 4
  %add22 = add nsw i32 %add21, %27
  %idxprom23 = sext i32 %add22 to i64
  %28 = load float*, float** %ref.addr, align 8
  %arrayidx24 = getelementptr inbounds float, float* %28, i64 %idxprom23
  %29 = load float, float* %arrayidx24, align 4
  %conv = fpext float %29 to double
  %30 = load i32, i32* %i, align 4
  %31 = load i32, i32* %dimx.addr, align 4
  %mul25 = mul nsw i32 %30, %31
  %32 = load i32, i32* %dimy.addr, align 4
  %mul26 = mul nsw i32 %mul25, %32
  %33 = load i32, i32* %j, align 4
  %34 = load i32, i32* %dimx.addr, align 4
  %mul27 = mul nsw i32 %33, %34
  %add28 = add nsw i32 %mul26, %mul27
  %35 = load i32, i32* %k, align 4
  %add29 = add nsw i32 %add28, %35
  %idxprom30 = sext i32 %add29 to i64
  %36 = load float*, float** %a.addr, align 8
  %arrayidx31 = getelementptr inbounds float, float* %36, i64 %idxprom30
  %37 = load float, float* %arrayidx31, align 4
  %conv32 = fpext float %37 to double
  %38 = load i32, i32* %i, align 4
  %39 = load i32, i32* %j, align 4
  %40 = load i32, i32* %k, align 4
  %call = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([51 x i8], [51 x i8]* @.str.1, i32 0, i32 0), double %conv, double %conv32, i32 %38, i32 %39, i32 %40)
  br label %if.end

if.end:                                           ; preds = %if.then, %for.body.6
  br label %for.inc

for.inc:                                          ; preds = %if.end
  %41 = load i32, i32* %k, align 4
  %inc = add nsw i32 %41, 1
  store i32 %inc, i32* %k, align 4
  br label %for.cond.4

for.end:                                          ; preds = %for.cond.4
  br label %for.inc.33

for.inc.33:                                       ; preds = %for.end
  %42 = load i32, i32* %j, align 4
  %inc34 = add nsw i32 %42, 1
  store i32 %inc34, i32* %j, align 4
  br label %for.cond.1

for.end.35:                                       ; preds = %for.cond.1
  br label %for.inc.36

for.inc.36:                                       ; preds = %for.end.35
  %43 = load i32, i32* %i, align 4
  %inc37 = add nsw i32 %43, 1
  store i32 %inc37, i32* %i, align 4
  br label %for.cond

for.end.38:                                       ; preds = %for.cond
  ret i32 1
}

; Function Attrs: nounwind uwtable
>>>>>>> a3e0d4f4e8669d5cf2aae8a9b08d26ab6c4a5279
define void @compareResults(float* %B, float* %B_GPU) #0 {
entry:
  %B.addr = alloca float*, align 8
  %B_GPU.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %k = alloca i32, align 4
  %fail = alloca i32, align 4
  store float* %B, float** %B.addr, align 8
  store float* %B_GPU, float** %B_GPU.addr, align 8
  store i32 0, i32* %fail, align 4
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.23, %entry
  %0 = load i32, i32* %i, align 4
<<<<<<< HEAD
  %cmp = icmp slt i32 %0, 192
=======
  %cmp = icmp slt i32 %0, 128
>>>>>>> a3e0d4f4e8669d5cf2aae8a9b08d26ab6c4a5279
  br i1 %cmp, label %for.body, label %for.end.25

for.body:                                         ; preds = %for.cond
  store i32 0, i32* %j, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc.20, %for.body
  %1 = load i32, i32* %j, align 4
<<<<<<< HEAD
  %cmp2 = icmp slt i32 %1, 192
=======
  %cmp2 = icmp slt i32 %1, 128
>>>>>>> a3e0d4f4e8669d5cf2aae8a9b08d26ab6c4a5279
  br i1 %cmp2, label %for.body.3, label %for.end.22

for.body.3:                                       ; preds = %for.cond.1
  store i32 0, i32* %k, align 4
  br label %for.cond.4

for.cond.4:                                       ; preds = %for.inc, %for.body.3
  %2 = load i32, i32* %k, align 4
<<<<<<< HEAD
  %cmp5 = icmp slt i32 %2, 192
=======
  %cmp5 = icmp slt i32 %2, 128
>>>>>>> a3e0d4f4e8669d5cf2aae8a9b08d26ab6c4a5279
  br i1 %cmp5, label %for.body.6, label %for.end

for.body.6:                                       ; preds = %for.cond.4
  %3 = load i32, i32* %i, align 4
<<<<<<< HEAD
  %mul = mul nsw i32 %3, 36864
  %4 = load i32, i32* %j, align 4
  %mul7 = mul nsw i32 %4, 192
=======
  %mul = mul nsw i32 %3, 16384
  %4 = load i32, i32* %j, align 4
  %mul7 = mul nsw i32 %4, 128
>>>>>>> a3e0d4f4e8669d5cf2aae8a9b08d26ab6c4a5279
  %add = add nsw i32 %mul, %mul7
  %5 = load i32, i32* %k, align 4
  %add8 = add nsw i32 %add, %5
  %idxprom = sext i32 %add8 to i64
  %6 = load float*, float** %B.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %6, i64 %idxprom
  %7 = load float, float* %arrayidx, align 4
  %conv = fpext float %7 to double
  %8 = load i32, i32* %i, align 4
<<<<<<< HEAD
  %mul9 = mul nsw i32 %8, 36864
  %9 = load i32, i32* %j, align 4
  %mul10 = mul nsw i32 %9, 192
=======
  %mul9 = mul nsw i32 %8, 16384
  %9 = load i32, i32* %j, align 4
  %mul10 = mul nsw i32 %9, 128
>>>>>>> a3e0d4f4e8669d5cf2aae8a9b08d26ab6c4a5279
  %add11 = add nsw i32 %mul9, %mul10
  %10 = load i32, i32* %k, align 4
  %add12 = add nsw i32 %add11, %10
  %idxprom13 = sext i32 %add12 to i64
  %11 = load float*, float** %B_GPU.addr, align 8
  %arrayidx14 = getelementptr inbounds float, float* %11, i64 %idxprom13
  %12 = load float, float* %arrayidx14, align 4
  %conv15 = fpext float %12 to double
  %call = call float @percentDiff(double %conv, double %conv15)
  %conv16 = fpext float %call to double
  %cmp17 = fcmp ogt double %conv16, 5.000000e-01
  br i1 %cmp17, label %if.then, label %if.end

if.then:                                          ; preds = %for.body.6
  %13 = load i32, i32* %fail, align 4
  %inc = add nsw i32 %13, 1
  store i32 %inc, i32* %fail, align 4
  br label %if.end

if.end:                                           ; preds = %if.then, %for.body.6
  br label %for.inc

for.inc:                                          ; preds = %if.end
  %14 = load i32, i32* %k, align 4
  %inc19 = add nsw i32 %14, 1
  store i32 %inc19, i32* %k, align 4
  br label %for.cond.4

for.end:                                          ; preds = %for.cond.4
  br label %for.inc.20

for.inc.20:                                       ; preds = %for.end
  %15 = load i32, i32* %j, align 4
  %inc21 = add nsw i32 %15, 1
  store i32 %inc21, i32* %j, align 4
  br label %for.cond.1

for.end.22:                                       ; preds = %for.cond.1
  br label %for.inc.23

for.inc.23:                                       ; preds = %for.end.22
  %16 = load i32, i32* %i, align 4
  %inc24 = add nsw i32 %16, 1
  store i32 %inc24, i32* %i, align 4
  br label %for.cond

for.end.25:                                       ; preds = %for.cond
  %17 = load i32, i32* %fail, align 4
<<<<<<< HEAD
  %call26 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([74 x i8], [74 x i8]* @.str.1, i32 0, i32 0), double 5.000000e-01, i32 %17)
=======
  %call26 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([74 x i8], [74 x i8]* @.str.2, i32 0, i32 0), double 5.000000e-01, i32 %17)
>>>>>>> a3e0d4f4e8669d5cf2aae8a9b08d26ab6c4a5279
  ret void
}

; Function Attrs: nounwind uwtable
define i32 @main(i32 %argc, i8** %argv) #0 {
entry:
  %retval = alloca i32, align 4
  %argc.addr = alloca i32, align 4
  %argv.addr = alloca i8**, align 8
  %tsteps = alloca i32, align 4
  %x = alloca i32, align 4
  %y = alloca i32, align 4
  %z = alloca i32, align 4
  %t_start = alloca double, align 8
  %t_end = alloca double, align 8
  %A = alloca float*, align 8
  %B = alloca float*, align 8
<<<<<<< HEAD
  %B_GPU = alloca float*, align 8
  %B_GPU_OPT = alloca float*, align 8
  store i32 0, i32* %retval
  store i32 %argc, i32* %argc.addr, align 4
  store i8** %argv, i8*** %argv.addr, align 8
  store i32 2, i32* %tsteps, align 4
  store i32 192, i32* %x, align 4
  store i32 192, i32* %y, align 4
  store i32 192, i32* %z, align 4
  %call = call noalias i8* @malloc(i64 30118144) #3
  %0 = bitcast i8* %call to float*
  store float* %0, float** %A, align 8
  %call1 = call noalias i8* @calloc(i64 7529536, i64 4) #3
  %1 = bitcast i8* %call1 to float*
  store float* %1, float** %B, align 8
  %call2 = call noalias i8* @calloc(i64 7529536, i64 4) #3
  %2 = bitcast i8* %call2 to float*
  store float* %2, float** %B_GPU, align 8
  %call3 = call noalias i8* @calloc(i64 7529536, i64 4) #3
  %3 = bitcast i8* %call3 to float*
  store float* %3, float** %B_GPU_OPT, align 8
  %4 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %call4 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %4, i8* getelementptr inbounds ([29 x i8], [29 x i8]* @.str.2, i32 0, i32 0))
  %5 = load float*, float** %A, align 8
  call void @init(float* %5)
  %call5 = call double @rtclock()
  store double %call5, double* %t_start, align 8
  %6 = load i32, i32* %tsteps, align 4
  %7 = load i32, i32* %x, align 4
  %8 = load i32, i32* %y, align 4
  %9 = load i32, i32* %z, align 4
  %10 = load float*, float** %A, align 8
  %11 = load float*, float** %B, align 8
  call void @jacobi3d(i32 %6, i32 %7, i32 %8, i32 %9, float* %10, float* %11)
  %call6 = call double @rtclock()
  store double %call6, double* %t_end, align 8
  %12 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %13 = load double, double* %t_end, align 8
  %14 = load double, double* %t_start, align 8
  %sub = fsub double %13, %14
  %call7 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %12, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.3, i32 0, i32 0), double %sub)
  %15 = load float*, float** %A, align 8
  %16 = bitcast float* %15 to i8*
  call void @free(i8* %16) #3
  %17 = load float*, float** %B, align 8
  %18 = bitcast float* %17 to i8*
  call void @free(i8* %18) #3
=======
  store i32 0, i32* %retval
  store i32 %argc, i32* %argc.addr, align 4
  store i8** %argv, i8*** %argv.addr, align 8
  store i32 10, i32* %tsteps, align 4
  store i32 128, i32* %x, align 4
  store i32 128, i32* %y, align 4
  store i32 128, i32* %z, align 4
  %call = call noalias i8* @calloc(i64 2197000, i64 4) #3
  %0 = bitcast i8* %call to float*
  store float* %0, float** %A, align 8
  %call1 = call noalias i8* @calloc(i64 2197000, i64 4) #3
  %1 = bitcast i8* %call1 to float*
  store float* %1, float** %B, align 8
  %2 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %call2 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %2, i8* getelementptr inbounds ([29 x i8], [29 x i8]* @.str.3, i32 0, i32 0))
  %3 = load float*, float** %A, align 8
  call void @init(float* %3, i32 130, i32 130, i32 130, i32 1, i32 1, i32 1)
  %call3 = call double @rtclock()
  store double %call3, double* %t_start, align 8
  %4 = load i32, i32* %tsteps, align 4
  %5 = load i32, i32* %x, align 4
  %add = add nsw i32 %5, 2
  %6 = load i32, i32* %y, align 4
  %add4 = add nsw i32 %6, 2
  %7 = load i32, i32* %z, align 4
  %add5 = add nsw i32 %7, 2
  %8 = load float*, float** %A, align 8
  %9 = load float*, float** %B, align 8
  call void @jacobi3d(i32 %4, i32 %add, i32 %add4, i32 %add5, float* %8, float* %9)
  %call6 = call double @rtclock()
  store double %call6, double* %t_end, align 8
  %10 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %11 = load double, double* %t_end, align 8
  %12 = load double, double* %t_start, align 8
  %sub = fsub double %11, %12
  %call7 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %10, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.4, i32 0, i32 0), double %sub)
  %13 = load float*, float** %A, align 8
  %14 = bitcast float* %13 to i8*
  call void @free(i8* %14) #3
  %15 = load float*, float** %B, align 8
  %16 = bitcast float* %15 to i8*
  call void @free(i8* %16) #3
>>>>>>> a3e0d4f4e8669d5cf2aae8a9b08d26ab6c4a5279
  ret i32 0
}

; Function Attrs: nounwind
<<<<<<< HEAD
declare noalias i8* @malloc(i64) #1

; Function Attrs: nounwind
=======
>>>>>>> a3e0d4f4e8669d5cf2aae8a9b08d26ab6c4a5279
declare noalias i8* @calloc(i64, i64) #1

declare i32 @fprintf(%struct._IO_FILE*, i8*, ...) #2

; Function Attrs: nounwind
declare void @free(i8*) #1

attributes #0 = { nounwind uwtable "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nounwind }

!llvm.ident = !{!0}

!0 = !{!"clang version 3.7.1 (https://github.com/llvm-mirror/clang.git 0dbefa1b83eb90f7a06b5df5df254ce32be3db4b) (https://github.com/llvm-mirror/llvm.git 33c352b3eda89abc24e7511d9045fa2e499a42e3)"}
