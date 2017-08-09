; ModuleID = 'syr2k.c'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, i8*, i8*, i8*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type { %struct._IO_marker*, %struct._IO_FILE*, i32 }
%struct.timezone = type { i32, i32 }
%struct.timeval = type { i64, i64 }

@.str = private unnamed_addr constant [35 x i8] c"Error return from gettimeofday: %d\00", align 1
@.str.1 = private unnamed_addr constant [74 x i8] c"Non-Matching CPU-GPU Outputs Beyond Error Threshold of %4.2f Percent: %d\0A\00", align 1
@stdout = external global %struct._IO_FILE*, align 8
@.str.2 = private unnamed_addr constant [36 x i8] c"<< Symmetric rank-2k operations >>\0A\00", align 1
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
define void @init_arrays(float* %A, float* %B, float* %C) #0 {
entry:
  %A.addr = alloca float*, align 8
  %B.addr = alloca float*, align 8
  %C.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  store float* %A, float** %A.addr, align 8
  store float* %B, float** %B.addr, align 8
  store float* %C, float** %C.addr, align 8
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.31, %entry
  %0 = load i32, i32* %i, align 4
  %cmp = icmp slt i32 %0, 2048
  br i1 %cmp, label %for.body, label %for.end.33

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
  %add = fadd float %mul, 2.000000e+00
  %div = fdiv float %add, 2.048000e+03
  %4 = load i32, i32* %i, align 4
  %mul5 = mul nsw i32 %4, 2048
  %5 = load i32, i32* %j, align 4
  %add6 = add nsw i32 %mul5, %5
  %idxprom = sext i32 %add6 to i64
  %6 = load float*, float** %C.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %6, i64 %idxprom
  store float %div, float* %arrayidx, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.3
  %7 = load i32, i32* %j, align 4
  %inc = add nsw i32 %7, 1
  store i32 %inc, i32* %j, align 4
  br label %for.cond.1

for.end:                                          ; preds = %for.cond.1
  store i32 0, i32* %j, align 4
  br label %for.cond.7

for.cond.7:                                       ; preds = %for.inc.28, %for.end
  %8 = load i32, i32* %j, align 4
  %cmp8 = icmp slt i32 %8, 2048
  br i1 %cmp8, label %for.body.10, label %for.end.30

for.body.10:                                      ; preds = %for.cond.7
  %9 = load i32, i32* %i, align 4
  %conv11 = sitofp i32 %9 to float
  %10 = load i32, i32* %j, align 4
  %conv12 = sitofp i32 %10 to float
  %mul13 = fmul float %conv11, %conv12
  %div14 = fdiv float %mul13, 2.048000e+03
  %11 = load i32, i32* %i, align 4
  %mul15 = mul nsw i32 %11, 2048
  %12 = load i32, i32* %j, align 4
  %add16 = add nsw i32 %mul15, %12
  %idxprom17 = sext i32 %add16 to i64
  %13 = load float*, float** %A.addr, align 8
  %arrayidx18 = getelementptr inbounds float, float* %13, i64 %idxprom17
  store float %div14, float* %arrayidx18, align 4
  %14 = load i32, i32* %i, align 4
  %conv19 = sitofp i32 %14 to float
  %15 = load i32, i32* %j, align 4
  %conv20 = sitofp i32 %15 to float
  %mul21 = fmul float %conv19, %conv20
  %add22 = fadd float %mul21, 1.000000e+00
  %div23 = fdiv float %add22, 2.048000e+03
  %16 = load i32, i32* %i, align 4
  %mul24 = mul nsw i32 %16, 2048
  %17 = load i32, i32* %j, align 4
  %add25 = add nsw i32 %mul24, %17
  %idxprom26 = sext i32 %add25 to i64
  %18 = load float*, float** %B.addr, align 8
  %arrayidx27 = getelementptr inbounds float, float* %18, i64 %idxprom26
  store float %div23, float* %arrayidx27, align 4
  br label %for.inc.28

for.inc.28:                                       ; preds = %for.body.10
  %19 = load i32, i32* %j, align 4
  %inc29 = add nsw i32 %19, 1
  store i32 %inc29, i32* %j, align 4
  br label %for.cond.7

for.end.30:                                       ; preds = %for.cond.7
  br label %for.inc.31

for.inc.31:                                       ; preds = %for.end.30
  %20 = load i32, i32* %i, align 4
  %inc32 = add nsw i32 %20, 1
  store i32 %inc32, i32* %i, align 4
  br label %for.cond

for.end.33:                                       ; preds = %for.cond
  ret void
}

; Function Attrs: nounwind uwtable
define void @syr2k(float* %A, float* %B, float* %C) #0 {
entry:
  %A.addr = alloca float*, align 8
  %B.addr = alloca float*, align 8
  %C.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %k = alloca i32, align 4
  store float* %A, float** %A.addr, align 8
  store float* %B, float** %B.addr, align 8
  store float* %C, float** %C.addr, align 8
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.5, %entry
  %0 = load i32, i32* %i, align 4
  %cmp = icmp slt i32 %0, 2048
  br i1 %cmp, label %for.body, label %for.end.7

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
  %mul4 = fmul float %5, 4.546000e+03
  store float %mul4, float* %arrayidx, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.3
  %6 = load i32, i32* %j, align 4
  %inc = add nsw i32 %6, 1
  store i32 %inc, i32* %j, align 4
  br label %for.cond.1

for.end:                                          ; preds = %for.cond.1
  br label %for.inc.5

for.inc.5:                                        ; preds = %for.end
  %7 = load i32, i32* %i, align 4
  %inc6 = add nsw i32 %7, 1
  store i32 %inc6, i32* %i, align 4
  br label %for.cond

for.end.7:                                        ; preds = %for.cond
  store i32 0, i32* %i, align 4
  br label %for.cond.8

for.cond.8:                                       ; preds = %for.inc.53, %for.end.7
  %8 = load i32, i32* %i, align 4
  %cmp9 = icmp slt i32 %8, 2048
  br i1 %cmp9, label %for.body.10, label %for.end.55

for.body.10:                                      ; preds = %for.cond.8
  store i32 0, i32* %j, align 4
  br label %for.cond.11

for.cond.11:                                      ; preds = %for.inc.50, %for.body.10
  %9 = load i32, i32* %j, align 4
  %cmp12 = icmp slt i32 %9, 2048
  br i1 %cmp12, label %for.body.13, label %for.end.52

for.body.13:                                      ; preds = %for.cond.11
  store i32 0, i32* %k, align 4
  br label %for.cond.14

for.cond.14:                                      ; preds = %for.inc.47, %for.body.13
  %10 = load i32, i32* %k, align 4
  %cmp15 = icmp slt i32 %10, 2048
  br i1 %cmp15, label %for.body.16, label %for.end.49

for.body.16:                                      ; preds = %for.cond.14
  %11 = load i32, i32* %i, align 4
  %mul17 = mul nsw i32 %11, 2048
  %12 = load i32, i32* %k, align 4
  %add18 = add nsw i32 %mul17, %12
  %idxprom19 = sext i32 %add18 to i64
  %13 = load float*, float** %A.addr, align 8
  %arrayidx20 = getelementptr inbounds float, float* %13, i64 %idxprom19
  %14 = load float, float* %arrayidx20, align 4
  %mul21 = fmul float 1.243500e+04, %14
  %15 = load i32, i32* %j, align 4
  %mul22 = mul nsw i32 %15, 2048
  %16 = load i32, i32* %k, align 4
  %add23 = add nsw i32 %mul22, %16
  %idxprom24 = sext i32 %add23 to i64
  %17 = load float*, float** %B.addr, align 8
  %arrayidx25 = getelementptr inbounds float, float* %17, i64 %idxprom24
  %18 = load float, float* %arrayidx25, align 4
  %mul26 = fmul float %mul21, %18
  %19 = load i32, i32* %i, align 4
  %mul27 = mul nsw i32 %19, 2048
  %20 = load i32, i32* %j, align 4
  %add28 = add nsw i32 %mul27, %20
  %idxprom29 = sext i32 %add28 to i64
  %21 = load float*, float** %C.addr, align 8
  %arrayidx30 = getelementptr inbounds float, float* %21, i64 %idxprom29
  %22 = load float, float* %arrayidx30, align 4
  %add31 = fadd float %22, %mul26
  store float %add31, float* %arrayidx30, align 4
  %23 = load i32, i32* %i, align 4
  %mul32 = mul nsw i32 %23, 2048
  %24 = load i32, i32* %k, align 4
  %add33 = add nsw i32 %mul32, %24
  %idxprom34 = sext i32 %add33 to i64
  %25 = load float*, float** %B.addr, align 8
  %arrayidx35 = getelementptr inbounds float, float* %25, i64 %idxprom34
  %26 = load float, float* %arrayidx35, align 4
  %mul36 = fmul float 1.243500e+04, %26
  %27 = load i32, i32* %j, align 4
  %mul37 = mul nsw i32 %27, 2048
  %28 = load i32, i32* %k, align 4
  %add38 = add nsw i32 %mul37, %28
  %idxprom39 = sext i32 %add38 to i64
  %29 = load float*, float** %A.addr, align 8
  %arrayidx40 = getelementptr inbounds float, float* %29, i64 %idxprom39
  %30 = load float, float* %arrayidx40, align 4
  %mul41 = fmul float %mul36, %30
  %31 = load i32, i32* %i, align 4
  %mul42 = mul nsw i32 %31, 2048
  %32 = load i32, i32* %j, align 4
  %add43 = add nsw i32 %mul42, %32
  %idxprom44 = sext i32 %add43 to i64
  %33 = load float*, float** %C.addr, align 8
  %arrayidx45 = getelementptr inbounds float, float* %33, i64 %idxprom44
  %34 = load float, float* %arrayidx45, align 4
  %add46 = fadd float %34, %mul41
  store float %add46, float* %arrayidx45, align 4
  br label %for.inc.47

for.inc.47:                                       ; preds = %for.body.16
  %35 = load i32, i32* %k, align 4
  %inc48 = add nsw i32 %35, 1
  store i32 %inc48, i32* %k, align 4
  br label %for.cond.14

for.end.49:                                       ; preds = %for.cond.14
  br label %for.inc.50

for.inc.50:                                       ; preds = %for.end.49
  %36 = load i32, i32* %j, align 4
  %inc51 = add nsw i32 %36, 1
  store i32 %inc51, i32* %j, align 4
  br label %for.cond.11

for.end.52:                                       ; preds = %for.cond.11
  br label %for.inc.53

for.inc.53:                                       ; preds = %for.end.52
  %37 = load i32, i32* %i, align 4
  %inc54 = add nsw i32 %37, 1
  store i32 %inc54, i32* %i, align 4
  br label %for.cond.8

for.end.55:                                       ; preds = %for.cond.8
  ret void
}

; Function Attrs: nounwind uwtable
define void @GPU__syr2k(float* %A, float* %B, float* %C) #0 {
entry:
  %A.addr = alloca float*, align 8
  %B.addr = alloca float*, align 8
  %C.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %k = alloca i32, align 4
  store float* %A, float** %A.addr, align 8
  store float* %B, float** %B.addr, align 8
  store float* %C, float** %C.addr, align 8
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.5, %entry
  %0 = load i32, i32* %i, align 4
  %cmp = icmp slt i32 %0, 2048
  br i1 %cmp, label %for.body, label %for.end.7

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
  %mul4 = fmul float %5, 4.546000e+03
  store float %mul4, float* %arrayidx, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.3
  %6 = load i32, i32* %j, align 4
  %inc = add nsw i32 %6, 1
  store i32 %inc, i32* %j, align 4
  br label %for.cond.1

for.end:                                          ; preds = %for.cond.1
  br label %for.inc.5

for.inc.5:                                        ; preds = %for.end
  %7 = load i32, i32* %i, align 4
  %inc6 = add nsw i32 %7, 1
  store i32 %inc6, i32* %i, align 4
  br label %for.cond

for.end.7:                                        ; preds = %for.cond
  store i32 0, i32* %i, align 4
  br label %for.cond.8

for.cond.8:                                       ; preds = %for.inc.53, %for.end.7
  %8 = load i32, i32* %i, align 4
  %cmp9 = icmp slt i32 %8, 2048
  br i1 %cmp9, label %for.body.10, label %for.end.55

for.body.10:                                      ; preds = %for.cond.8
  store i32 0, i32* %j, align 4
  br label %for.cond.11

for.cond.11:                                      ; preds = %for.inc.50, %for.body.10
  %9 = load i32, i32* %j, align 4
  %cmp12 = icmp slt i32 %9, 2048
  br i1 %cmp12, label %for.body.13, label %for.end.52

for.body.13:                                      ; preds = %for.cond.11
  store i32 0, i32* %k, align 4
  br label %for.cond.14

for.cond.14:                                      ; preds = %for.inc.47, %for.body.13
  %10 = load i32, i32* %k, align 4
  %cmp15 = icmp slt i32 %10, 2048
  br i1 %cmp15, label %for.body.16, label %for.end.49

for.body.16:                                      ; preds = %for.cond.14
  %11 = load i32, i32* %i, align 4
  %mul17 = mul nsw i32 %11, 2048
  %12 = load i32, i32* %k, align 4
  %add18 = add nsw i32 %mul17, %12
  %idxprom19 = sext i32 %add18 to i64
  %13 = load float*, float** %A.addr, align 8
  %arrayidx20 = getelementptr inbounds float, float* %13, i64 %idxprom19
  %14 = load float, float* %arrayidx20, align 4
  %mul21 = fmul float 1.243500e+04, %14
  %15 = load i32, i32* %j, align 4
  %mul22 = mul nsw i32 %15, 2048
  %16 = load i32, i32* %k, align 4
  %add23 = add nsw i32 %mul22, %16
  %idxprom24 = sext i32 %add23 to i64
  %17 = load float*, float** %B.addr, align 8
  %arrayidx25 = getelementptr inbounds float, float* %17, i64 %idxprom24
  %18 = load float, float* %arrayidx25, align 4
  %mul26 = fmul float %mul21, %18
  %19 = load i32, i32* %i, align 4
  %mul27 = mul nsw i32 %19, 2048
  %20 = load i32, i32* %j, align 4
  %add28 = add nsw i32 %mul27, %20
  %idxprom29 = sext i32 %add28 to i64
  %21 = load float*, float** %C.addr, align 8
  %arrayidx30 = getelementptr inbounds float, float* %21, i64 %idxprom29
  %22 = load float, float* %arrayidx30, align 4
  %add31 = fadd float %22, %mul26
  store float %add31, float* %arrayidx30, align 4
  %23 = load i32, i32* %i, align 4
  %mul32 = mul nsw i32 %23, 2048
  %24 = load i32, i32* %k, align 4
  %add33 = add nsw i32 %mul32, %24
  %idxprom34 = sext i32 %add33 to i64
  %25 = load float*, float** %B.addr, align 8
  %arrayidx35 = getelementptr inbounds float, float* %25, i64 %idxprom34
  %26 = load float, float* %arrayidx35, align 4
  %mul36 = fmul float 1.243500e+04, %26
  %27 = load i32, i32* %j, align 4
  %mul37 = mul nsw i32 %27, 2048
  %28 = load i32, i32* %k, align 4
  %add38 = add nsw i32 %mul37, %28
  %idxprom39 = sext i32 %add38 to i64
  %29 = load float*, float** %A.addr, align 8
  %arrayidx40 = getelementptr inbounds float, float* %29, i64 %idxprom39
  %30 = load float, float* %arrayidx40, align 4
  %mul41 = fmul float %mul36, %30
  %31 = load i32, i32* %i, align 4
  %mul42 = mul nsw i32 %31, 2048
  %32 = load i32, i32* %j, align 4
  %add43 = add nsw i32 %mul42, %32
  %idxprom44 = sext i32 %add43 to i64
  %33 = load float*, float** %C.addr, align 8
  %arrayidx45 = getelementptr inbounds float, float* %33, i64 %idxprom44
  %34 = load float, float* %arrayidx45, align 4
  %add46 = fadd float %34, %mul41
  store float %add46, float* %arrayidx45, align 4
  br label %for.inc.47

for.inc.47:                                       ; preds = %for.body.16
  %35 = load i32, i32* %k, align 4
  %inc48 = add nsw i32 %35, 1
  store i32 %inc48, i32* %k, align 4
  br label %for.cond.14

for.end.49:                                       ; preds = %for.cond.14
  br label %for.inc.50

for.inc.50:                                       ; preds = %for.end.49
  %36 = load i32, i32* %j, align 4
  %inc51 = add nsw i32 %36, 1
  store i32 %inc51, i32* %j, align 4
  br label %for.cond.11

for.end.52:                                       ; preds = %for.cond.11
  br label %for.inc.53

for.inc.53:                                       ; preds = %for.end.52
  %37 = load i32, i32* %i, align 4
  %inc54 = add nsw i32 %37, 1
  store i32 %inc54, i32* %i, align 4
  br label %for.cond.8

for.end.55:                                       ; preds = %for.cond.8
  ret void
}

; Function Attrs: nounwind uwtable
define void @compareResults(float* %C, float* %C_Gpu) #0 {
entry:
  %C.addr = alloca float*, align 8
  %C_Gpu.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %fail = alloca i32, align 4
  store float* %C, float** %C.addr, align 8
  store float* %C_Gpu, float** %C_Gpu.addr, align 8
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
  %8 = load float*, float** %C_Gpu.addr, align 8
  %arrayidx7 = getelementptr inbounds float, float* %8, i64 %idxprom6
  %9 = load float, float* %arrayidx7, align 4
  %conv8 = fpext float %9 to double
  %call = call float @percentDiff(double %conv, double %conv8)
  %conv9 = fpext float %call to double
  %cmp10 = fcmp ogt double %conv9, 1.000000e-01
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
  %call16 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([74 x i8], [74 x i8]* @.str.1, i32 0, i32 0), double 1.000000e-01, i32 %13)
  ret void
}

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
entry:
  %retval = alloca i32, align 4
  %t_start = alloca double, align 8
  %t_end = alloca double, align 8
  %A = alloca float*, align 8
  %B = alloca float*, align 8
  %C = alloca float*, align 8
  %C_Gpu = alloca float*, align 8
  store i32 0, i32* %retval
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
  store float* %3, float** %C_Gpu, align 8
  %4 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %call4 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %4, i8* getelementptr inbounds ([36 x i8], [36 x i8]* @.str.2, i32 0, i32 0))
  %5 = load float*, float** %A, align 8
  %6 = load float*, float** %B, align 8
  %7 = load float*, float** %C_Gpu, align 8
  call void @init_arrays(float* %5, float* %6, float* %7)
  %call5 = call double @rtclock()
  store double %call5, double* %t_start, align 8
  %8 = load float*, float** %A, align 8
  %9 = load float*, float** %B, align 8
  %10 = load float*, float** %C_Gpu, align 8
  call void @GPU__syr2k(float* %8, float* %9, float* %10)
  %call6 = call double @rtclock()
  store double %call6, double* %t_end, align 8
  %11 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %12 = load double, double* %t_end, align 8
  %13 = load double, double* %t_start, align 8
  %sub = fsub double %12, %13
  %call7 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %11, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.3, i32 0, i32 0), double %sub)
  %14 = load float*, float** %A, align 8
  %15 = load float*, float** %B, align 8
  %16 = load float*, float** %C, align 8
  call void @init_arrays(float* %14, float* %15, float* %16)
  %call8 = call double @rtclock()
  store double %call8, double* %t_start, align 8
  %17 = load float*, float** %A, align 8
  %18 = load float*, float** %B, align 8
  %19 = load float*, float** %C, align 8
  call void @syr2k(float* %17, float* %18, float* %19)
  %call9 = call double @rtclock()
  store double %call9, double* %t_end, align 8
  %20 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %21 = load double, double* %t_end, align 8
  %22 = load double, double* %t_start, align 8
  %sub10 = fsub double %21, %22
  %call11 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %20, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.4, i32 0, i32 0), double %sub10)
  %23 = load float*, float** %C, align 8
  %24 = load float*, float** %C_Gpu, align 8
  call void @compareResults(float* %23, float* %24)
  %25 = load float*, float** %A, align 8
  %26 = bitcast float* %25 to i8*
  call void @free(i8* %26) #3
  %27 = load float*, float** %B, align 8
  %28 = bitcast float* %27 to i8*
  call void @free(i8* %28) #3
  %29 = load float*, float** %C, align 8
  %30 = bitcast float* %29 to i8*
  call void @free(i8* %30) #3
  %31 = load float*, float** %C_Gpu, align 8
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
