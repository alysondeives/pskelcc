; ModuleID = 'conv-2d.c'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, i8*, i8*, i8*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type { %struct._IO_marker*, %struct._IO_FILE*, i32 }
%struct.timezone = type { i32, i32 }
%struct.timeval = type { i64, i64 }

@.str = private unnamed_addr constant [35 x i8] c"Error return from gettimeofday: %d\00", align 1
@.str.1 = private unnamed_addr constant [74 x i8] c"Non-Matching CPU-GPU Outputs Beyond Error Threshold of %4.2f Percent: %d\0A\00", align 1
@stdout = external global %struct._IO_FILE*, align 8
@.str.2 = private unnamed_addr constant [40 x i8] c">> Two dimensional (2D) convolution <<\0A\00", align 1
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
define void @conv2D(i32 %ni, i32 %nj, float* %A, float* %B) #0 {
entry:
  %ni.addr = alloca i32, align 4
  %nj.addr = alloca i32, align 4
  %A.addr = alloca float*, align 8
  %B.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %c11 = alloca float, align 4
  %c12 = alloca float, align 4
  %c13 = alloca float, align 4
  %c21 = alloca float, align 4
  %c22 = alloca float, align 4
  %c23 = alloca float, align 4
  %c31 = alloca float, align 4
  %c32 = alloca float, align 4
  %c33 = alloca float, align 4
  store i32 %ni, i32* %ni.addr, align 4
  store i32 %nj, i32* %nj.addr, align 4
  store float* %A, float** %A.addr, align 8
  store float* %B, float** %B.addr, align 8
  store float 0x3FC99999A0000000, float* %c11, align 4
  store float 5.000000e-01, float* %c21, align 4
  store float 0xBFE99999A0000000, float* %c31, align 4
  store float 0xBFD3333340000000, float* %c12, align 4
  store float 0x3FE3333340000000, float* %c22, align 4
  store float 0xBFECCCCCC0000000, float* %c32, align 4
  store float 0x3FD99999A0000000, float* %c13, align 4
  store float 0x3FE6666660000000, float* %c23, align 4
  store float 0x3FB99999A0000000, float* %c33, align 4
  store i32 1, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.70, %entry
  %0 = load i32, i32* %i, align 4
  %1 = load i32, i32* %ni.addr, align 4
  %sub = sub nsw i32 %1, 1
  %cmp = icmp slt i32 %0, %sub
  br i1 %cmp, label %for.body, label %for.end.72

for.body:                                         ; preds = %for.cond
  store i32 1, i32* %j, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %2 = load i32, i32* %j, align 4
  %3 = load i32, i32* %nj.addr, align 4
  %sub2 = sub nsw i32 %3, 1
  %cmp3 = icmp slt i32 %2, %sub2
  br i1 %cmp3, label %for.body.4, label %for.end

for.body.4:                                       ; preds = %for.cond.1
  %4 = load float, float* %c11, align 4
  %5 = load i32, i32* %i, align 4
  %sub5 = sub nsw i32 %5, 1
  %6 = load i32, i32* %nj.addr, align 4
  %mul = mul nsw i32 %sub5, %6
  %7 = load i32, i32* %j, align 4
  %sub6 = sub nsw i32 %7, 1
  %add = add nsw i32 %mul, %sub6
  %idxprom = sext i32 %add to i64
  %8 = load float*, float** %A.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %8, i64 %idxprom
  %9 = load float, float* %arrayidx, align 4
  %mul7 = fmul float %4, %9
  %10 = load float, float* %c12, align 4
  %11 = load i32, i32* %i, align 4
  %12 = load i32, i32* %nj.addr, align 4
  %mul8 = mul nsw i32 %11, %12
  %13 = load i32, i32* %j, align 4
  %sub9 = sub nsw i32 %13, 1
  %add10 = add nsw i32 %mul8, %sub9
  %idxprom11 = sext i32 %add10 to i64
  %14 = load float*, float** %A.addr, align 8
  %arrayidx12 = getelementptr inbounds float, float* %14, i64 %idxprom11
  %15 = load float, float* %arrayidx12, align 4
  %mul13 = fmul float %10, %15
  %add14 = fadd float %mul7, %mul13
  %16 = load float, float* %c13, align 4
  %17 = load i32, i32* %i, align 4
  %add15 = add nsw i32 %17, 1
  %18 = load i32, i32* %nj.addr, align 4
  %mul16 = mul nsw i32 %add15, %18
  %19 = load i32, i32* %j, align 4
  %sub17 = sub nsw i32 %19, 1
  %add18 = add nsw i32 %mul16, %sub17
  %idxprom19 = sext i32 %add18 to i64
  %20 = load float*, float** %A.addr, align 8
  %arrayidx20 = getelementptr inbounds float, float* %20, i64 %idxprom19
  %21 = load float, float* %arrayidx20, align 4
  %mul21 = fmul float %16, %21
  %add22 = fadd float %add14, %mul21
  %22 = load float, float* %c21, align 4
  %23 = load i32, i32* %i, align 4
  %sub23 = sub nsw i32 %23, 1
  %24 = load i32, i32* %nj.addr, align 4
  %mul24 = mul nsw i32 %sub23, %24
  %25 = load i32, i32* %j, align 4
  %add25 = add nsw i32 %mul24, %25
  %idxprom26 = sext i32 %add25 to i64
  %26 = load float*, float** %A.addr, align 8
  %arrayidx27 = getelementptr inbounds float, float* %26, i64 %idxprom26
  %27 = load float, float* %arrayidx27, align 4
  %mul28 = fmul float %22, %27
  %add29 = fadd float %add22, %mul28
  %28 = load float, float* %c22, align 4
  %29 = load i32, i32* %i, align 4
  %30 = load i32, i32* %nj.addr, align 4
  %mul30 = mul nsw i32 %29, %30
  %31 = load i32, i32* %j, align 4
  %add31 = add nsw i32 %mul30, %31
  %idxprom32 = sext i32 %add31 to i64
  %32 = load float*, float** %A.addr, align 8
  %arrayidx33 = getelementptr inbounds float, float* %32, i64 %idxprom32
  %33 = load float, float* %arrayidx33, align 4
  %mul34 = fmul float %28, %33
  %add35 = fadd float %add29, %mul34
  %34 = load float, float* %c23, align 4
  %35 = load i32, i32* %i, align 4
  %add36 = add nsw i32 %35, 1
  %36 = load i32, i32* %nj.addr, align 4
  %mul37 = mul nsw i32 %add36, %36
  %37 = load i32, i32* %j, align 4
  %add38 = add nsw i32 %mul37, %37
  %idxprom39 = sext i32 %add38 to i64
  %38 = load float*, float** %A.addr, align 8
  %arrayidx40 = getelementptr inbounds float, float* %38, i64 %idxprom39
  %39 = load float, float* %arrayidx40, align 4
  %mul41 = fmul float %34, %39
  %add42 = fadd float %add35, %mul41
  %40 = load float, float* %c31, align 4
  %41 = load i32, i32* %i, align 4
  %sub43 = sub nsw i32 %41, 1
  %42 = load i32, i32* %nj.addr, align 4
  %mul44 = mul nsw i32 %sub43, %42
  %43 = load i32, i32* %j, align 4
  %add45 = add nsw i32 %43, 1
  %add46 = add nsw i32 %mul44, %add45
  %idxprom47 = sext i32 %add46 to i64
  %44 = load float*, float** %A.addr, align 8
  %arrayidx48 = getelementptr inbounds float, float* %44, i64 %idxprom47
  %45 = load float, float* %arrayidx48, align 4
  %mul49 = fmul float %40, %45
  %add50 = fadd float %add42, %mul49
  %46 = load float, float* %c32, align 4
  %47 = load i32, i32* %i, align 4
  %48 = load i32, i32* %nj.addr, align 4
  %mul51 = mul nsw i32 %47, %48
  %49 = load i32, i32* %j, align 4
  %add52 = add nsw i32 %49, 1
  %add53 = add nsw i32 %mul51, %add52
  %idxprom54 = sext i32 %add53 to i64
  %50 = load float*, float** %A.addr, align 8
  %arrayidx55 = getelementptr inbounds float, float* %50, i64 %idxprom54
  %51 = load float, float* %arrayidx55, align 4
  %mul56 = fmul float %46, %51
  %add57 = fadd float %add50, %mul56
  %52 = load float, float* %c33, align 4
  %53 = load i32, i32* %i, align 4
  %add58 = add nsw i32 %53, 1
  %54 = load i32, i32* %nj.addr, align 4
  %mul59 = mul nsw i32 %add58, %54
  %55 = load i32, i32* %j, align 4
  %add60 = add nsw i32 %55, 1
  %add61 = add nsw i32 %mul59, %add60
  %idxprom62 = sext i32 %add61 to i64
  %56 = load float*, float** %A.addr, align 8
  %arrayidx63 = getelementptr inbounds float, float* %56, i64 %idxprom62
  %57 = load float, float* %arrayidx63, align 4
  %mul64 = fmul float %52, %57
  %add65 = fadd float %add57, %mul64
  %58 = load i32, i32* %i, align 4
  %59 = load i32, i32* %nj.addr, align 4
  %mul66 = mul nsw i32 %58, %59
  %60 = load i32, i32* %j, align 4
  %add67 = add nsw i32 %mul66, %60
  %idxprom68 = sext i32 %add67 to i64
  %61 = load float*, float** %B.addr, align 8
  %arrayidx69 = getelementptr inbounds float, float* %61, i64 %idxprom68
  store float %add65, float* %arrayidx69, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.4
  %62 = load i32, i32* %j, align 4
  %inc = add nsw i32 %62, 1
  store i32 %inc, i32* %j, align 4
  br label %for.cond.1

for.end:                                          ; preds = %for.cond.1
  br label %for.inc.70

for.inc.70:                                       ; preds = %for.end
  %63 = load i32, i32* %i, align 4
  %inc71 = add nsw i32 %63, 1
  store i32 %inc71, i32* %i, align 4
  br label %for.cond

for.end.72:                                       ; preds = %for.cond
  ret void
}

; Function Attrs: nounwind uwtable
define void @init(i32 %ni, i32 %nj, float* %A) #0 {
entry:
  %ni.addr = alloca i32, align 4
  %nj.addr = alloca i32, align 4
  %A.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  store i32 %ni, i32* %ni.addr, align 4
  store i32 %nj, i32* %nj.addr, align 4
  store float* %A, float** %A.addr, align 8
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.4, %entry
  %0 = load i32, i32* %i, align 4
  %1 = load i32, i32* %ni.addr, align 4
  %cmp = icmp slt i32 %0, %1
  br i1 %cmp, label %for.body, label %for.end.6

for.body:                                         ; preds = %for.cond
  store i32 0, i32* %j, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %2 = load i32, i32* %j, align 4
  %3 = load i32, i32* %nj.addr, align 4
  %cmp2 = icmp slt i32 %2, %3
  br i1 %cmp2, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.cond.1
  %call = call i32 @rand() #3
  %conv = sitofp i32 %call to float
  %div = fdiv float %conv, 0x41E0000000000000
  %4 = load i32, i32* %i, align 4
  %5 = load i32, i32* %nj.addr, align 4
  %mul = mul nsw i32 %4, %5
  %6 = load i32, i32* %j, align 4
  %add = add nsw i32 %mul, %6
  %idxprom = sext i32 %add to i64
  %7 = load float*, float** %A.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %7, i64 %idxprom
  store float %div, float* %arrayidx, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.3
  %8 = load i32, i32* %j, align 4
  %inc = add nsw i32 %8, 1
  store i32 %inc, i32* %j, align 4
  br label %for.cond.1

for.end:                                          ; preds = %for.cond.1
  br label %for.inc.4

for.inc.4:                                        ; preds = %for.end
  %9 = load i32, i32* %i, align 4
  %inc5 = add nsw i32 %9, 1
  store i32 %inc5, i32* %i, align 4
  br label %for.cond

for.end.6:                                        ; preds = %for.cond
  ret void
}

; Function Attrs: nounwind
declare i32 @rand() #1

; Function Attrs: nounwind uwtable
define void @compareResults(float* %B, float* %B_GPU) #0 {
entry:
  %B.addr = alloca float*, align 8
  %B_GPU.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %fail = alloca i32, align 4
  store float* %B, float** %B.addr, align 8
  store float* %B_GPU, float** %B_GPU.addr, align 8
  store i32 0, i32* %fail, align 4
  store i32 1, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.13, %entry
  %0 = load i32, i32* %i, align 4
  %cmp = icmp slt i32 %0, 4095
  br i1 %cmp, label %for.body, label %for.end.15

for.body:                                         ; preds = %for.cond
  store i32 1, i32* %j, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %1 = load i32, i32* %j, align 4
  %cmp2 = icmp slt i32 %1, 4095
  br i1 %cmp2, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.cond.1
  %2 = load i32, i32* %i, align 4
  %mul = mul nsw i32 %2, 4096
  %3 = load i32, i32* %j, align 4
  %add = add nsw i32 %mul, %3
  %idxprom = sext i32 %add to i64
  %4 = load float*, float** %B.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %4, i64 %idxprom
  %5 = load float, float* %arrayidx, align 4
  %conv = fpext float %5 to double
  %6 = load i32, i32* %i, align 4
  %mul4 = mul nsw i32 %6, 4096
  %7 = load i32, i32* %j, align 4
  %add5 = add nsw i32 %mul4, %7
  %idxprom6 = sext i32 %add5 to i64
  %8 = load float*, float** %B_GPU.addr, align 8
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
  %A = alloca float*, align 8
  %B = alloca float*, align 8
  store i32 0, i32* %retval
  store i32 %argc, i32* %argc.addr, align 4
  store i8** %argv, i8*** %argv.addr, align 8
  store i32 4096, i32* %ni, align 4
  store i32 4096, i32* %nj, align 4
  %0 = load i32, i32* %ni, align 4
  %1 = load i32, i32* %nj, align 4
  %mul = mul nsw i32 %0, %1
  %conv = sext i32 %mul to i64
  %mul1 = mul i64 %conv, 4
  %call = call noalias i8* @malloc(i64 %mul1) #3
  %2 = bitcast i8* %call to float*
  store float* %2, float** %A, align 8
  %3 = load i32, i32* %ni, align 4
  %4 = load i32, i32* %nj, align 4
  %mul2 = mul nsw i32 %3, %4
  %conv3 = sext i32 %mul2 to i64
  %mul4 = mul i64 %conv3, 4
  %call5 = call noalias i8* @malloc(i64 %mul4) #3
  %5 = bitcast i8* %call5 to float*
  store float* %5, float** %B, align 8
  %6 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %call6 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %6, i8* getelementptr inbounds ([40 x i8], [40 x i8]* @.str.2, i32 0, i32 0))
  %7 = load i32, i32* %ni, align 4
  %8 = load i32, i32* %nj, align 4
  %9 = load float*, float** %A, align 8
  call void @init(i32 %7, i32 %8, float* %9)
  %call7 = call double @rtclock()
  store double %call7, double* %t_start, align 8
  %10 = load i32, i32* %ni, align 4
  %11 = load i32, i32* %nj, align 4
  %12 = load float*, float** %A, align 8
  %13 = load float*, float** %B, align 8
  call void @conv2D(i32 %10, i32 %11, float* %12, float* %13)
  %call8 = call double @rtclock()
  store double %call8, double* %t_end, align 8
  %14 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %15 = load double, double* %t_end, align 8
  %16 = load double, double* %t_start, align 8
  %sub = fsub double %15, %16
  %call9 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %14, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.3, i32 0, i32 0), double %sub)
  %17 = load float*, float** %A, align 8
  %18 = bitcast float* %17 to i8*
  call void @free(i8* %18) #3
  %19 = load float*, float** %B, align 8
  %20 = bitcast float* %19 to i8*
  call void @free(i8* %20) #3
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
