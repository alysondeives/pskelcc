; ModuleID = 'fur.c'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, i8*, i8*, i8*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type { %struct._IO_marker*, %struct._IO_FILE*, i32 }
%struct.timezone = type { i32, i32 }
%struct.timeval = type { i64, i64 }

@.str = private unnamed_addr constant [35 x i8] c"Error return from gettimeofday: %d\00", align 1
@stdout = external global %struct._IO_FILE*, align 8
@.str.1 = private unnamed_addr constant [22 x i8] c"CPU Runtime: %0.6lfs\0A\00", align 1

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
define void @init_array(i32 %ni, i32 %nj, i32* %A, i32* %B) #0 {
entry:
  %ni.addr = alloca i32, align 4
  %nj.addr = alloca i32, align 4
  %A.addr = alloca i32*, align 8
  %B.addr = alloca i32*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  store i32 %ni, i32* %ni.addr, align 4
  store i32 %nj, i32* %nj.addr, align 4
  store i32* %A, i32** %A.addr, align 8
  store i32* %B, i32** %B.addr, align 8
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.15, %entry
  %0 = load i32, i32* %i, align 4
  %1 = load i32, i32* %ni.addr, align 4
  %cmp = icmp slt i32 %0, %1
  br i1 %cmp, label %for.body, label %for.end.17

for.body:                                         ; preds = %for.cond
  store i32 0, i32* %j, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %2 = load i32, i32* %j, align 4
  %3 = load i32, i32* %nj.addr, align 4
  %cmp2 = icmp slt i32 %2, %3
  br i1 %cmp2, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.cond.1
  %4 = load i32, i32* %i, align 4
  %5 = load i32, i32* %j, align 4
  %add = add nsw i32 %5, 2
  %mul = mul nsw i32 %4, %add
  %add4 = add nsw i32 %mul, 3
  %rem = srem i32 %add4, 2
  %6 = load i32, i32* %i, align 4
  %7 = load i32, i32* %nj.addr, align 4
  %mul5 = mul nsw i32 %6, %7
  %8 = load i32, i32* %j, align 4
  %add6 = add nsw i32 %mul5, %8
  %idxprom = sext i32 %add6 to i64
  %9 = load i32*, i32** %A.addr, align 8
  %arrayidx = getelementptr inbounds i32, i32* %9, i64 %idxprom
  store i32 %rem, i32* %arrayidx, align 4
  %10 = load i32, i32* %i, align 4
  %11 = load i32, i32* %j, align 4
  %add7 = add nsw i32 %11, 2
  %mul8 = mul nsw i32 %10, %add7
  %add9 = add nsw i32 %mul8, 3
  %rem10 = srem i32 %add9, 2
  %12 = load i32, i32* %i, align 4
  %13 = load i32, i32* %nj.addr, align 4
  %mul11 = mul nsw i32 %12, %13
  %14 = load i32, i32* %j, align 4
  %add12 = add nsw i32 %mul11, %14
  %idxprom13 = sext i32 %add12 to i64
  %15 = load i32*, i32** %B.addr, align 8
  %arrayidx14 = getelementptr inbounds i32, i32* %15, i64 %idxprom13
  store i32 %rem10, i32* %arrayidx14, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.3
  %16 = load i32, i32* %j, align 4
  %inc = add nsw i32 %16, 1
  store i32 %inc, i32* %j, align 4
  br label %for.cond.1

for.end:                                          ; preds = %for.cond.1
  br label %for.inc.15

for.inc.15:                                       ; preds = %for.end
  %17 = load i32, i32* %i, align 4
  %inc16 = add nsw i32 %17, 1
  store i32 %inc16, i32* %i, align 4
  br label %for.cond

for.end.17:                                       ; preds = %for.cond
  ret void
}

; Function Attrs: nounwind uwtable
define void @fur(i32 %tsteps, i32 %ni, i32 %nj, i32* %A, i32* %B) #0 {
entry:
  %tsteps.addr = alloca i32, align 4
  %ni.addr = alloca i32, align 4
  %nj.addr = alloca i32, align 4
  %A.addr = alloca i32*, align 8
  %B.addr = alloca i32*, align 8
  %t = alloca i32, align 4
  %x = alloca i32, align 4
  %y = alloca i32, align 4
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %numberA = alloca i32, align 4
  %numberI = alloca i32, align 4
  %power = alloca float, align 4
  %totalPowerI = alloca float, align 4
  %level = alloca i32, align 4
  store i32 %tsteps, i32* %tsteps.addr, align 4
  store i32 %ni, i32* %ni.addr, align 4
  store i32 %nj, i32* %nj.addr, align 4
  store i32* %A, i32** %A.addr, align 8
  store i32* %B, i32** %B.addr, align 8
  store i32 0, i32* %t, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.119, %entry
  %0 = load i32, i32* %t, align 4
  %1 = load i32, i32* %tsteps.addr, align 4
  %cmp = icmp slt i32 %0, %1
  br i1 %cmp, label %for.body, label %for.end.121

for.body:                                         ; preds = %for.cond
  store i32 1, i32* %i, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc.92, %for.body
  %2 = load i32, i32* %i, align 4
  %3 = load i32, i32* %ni.addr, align 4
  %sub = sub nsw i32 %3, 1
  %cmp2 = icmp slt i32 %2, %sub
  br i1 %cmp2, label %for.body.3, label %for.end.94

for.body.3:                                       ; preds = %for.cond.1
  store i32 1, i32* %j, align 4
  br label %for.cond.4

for.cond.4:                                       ; preds = %for.inc.89, %for.body.3
  %4 = load i32, i32* %j, align 4
  %5 = load i32, i32* %nj.addr, align 4
  %sub5 = sub nsw i32 %5, 1
  %cmp6 = icmp slt i32 %4, %sub5
  br i1 %cmp6, label %for.body.7, label %for.end.91

for.body.7:                                       ; preds = %for.cond.4
  %6 = load i32, i32* %level, align 4
  %7 = load i32, i32* %level, align 4
  %mul = mul nsw i32 2, %7
  %sub8 = sub nsw i32 %6, %mul
  store i32 %sub8, i32* %y, align 4
  br label %for.cond.9

for.cond.9:                                       ; preds = %for.inc.23, %for.body.7
  %8 = load i32, i32* %y, align 4
  %9 = load i32, i32* %level, align 4
  %cmp10 = icmp sle i32 %8, %9
  br i1 %cmp10, label %for.body.11, label %for.end.25

for.body.11:                                      ; preds = %for.cond.9
  %10 = load i32, i32* %level, align 4
  %11 = load i32, i32* %level, align 4
  %mul12 = mul nsw i32 2, %11
  %sub13 = sub nsw i32 %10, %mul12
  store i32 %sub13, i32* %x, align 4
  br label %for.cond.14

for.cond.14:                                      ; preds = %for.inc, %for.body.11
  %12 = load i32, i32* %x, align 4
  %13 = load i32, i32* %level, align 4
  %cmp15 = icmp sle i32 %12, %13
  br i1 %cmp15, label %for.body.16, label %for.end

for.body.16:                                      ; preds = %for.cond.14
  %14 = load i32, i32* %x, align 4
  %cmp17 = icmp ne i32 %14, 0
  br i1 %cmp17, label %if.then, label %lor.lhs.false

lor.lhs.false:                                    ; preds = %for.body.16
  %15 = load i32, i32* %y, align 4
  %cmp18 = icmp ne i32 %15, 0
  br i1 %cmp18, label %if.then, label %if.end

if.then:                                          ; preds = %lor.lhs.false, %for.body.16
  %16 = load i32, i32* %i, align 4
  %17 = load i32, i32* %y, align 4
  %add = add nsw i32 %16, %17
  %18 = load i32, i32* %nj.addr, align 4
  %mul19 = mul nsw i32 %add, %18
  %19 = load i32, i32* %j, align 4
  %20 = load i32, i32* %x, align 4
  %add20 = add nsw i32 %19, %20
  %add21 = add nsw i32 %mul19, %add20
  %idxprom = sext i32 %add21 to i64
  %21 = load i32*, i32** %A.addr, align 8
  %arrayidx = getelementptr inbounds i32, i32* %21, i64 %idxprom
  %22 = load i32, i32* %arrayidx, align 4
  %23 = load i32, i32* %numberA, align 4
  %add22 = add nsw i32 %23, %22
  store i32 %add22, i32* %numberA, align 4
  br label %if.end

if.end:                                           ; preds = %if.then, %lor.lhs.false
  br label %for.inc

for.inc:                                          ; preds = %if.end
  %24 = load i32, i32* %x, align 4
  %inc = add nsw i32 %24, 1
  store i32 %inc, i32* %x, align 4
  br label %for.cond.14

for.end:                                          ; preds = %for.cond.14
  br label %for.inc.23

for.inc.23:                                       ; preds = %for.end
  %25 = load i32, i32* %y, align 4
  %inc24 = add nsw i32 %25, 1
  store i32 %inc24, i32* %y, align 4
  br label %for.cond.9

for.end.25:                                       ; preds = %for.cond.9
  %26 = load i32, i32* %level, align 4
  %mul26 = mul nsw i32 2, %26
  %27 = load i32, i32* %level, align 4
  %mul27 = mul nsw i32 4, %27
  %sub28 = sub nsw i32 %mul26, %mul27
  store i32 %sub28, i32* %y, align 4
  br label %for.cond.29

for.cond.29:                                      ; preds = %for.inc.65, %for.end.25
  %28 = load i32, i32* %y, align 4
  %29 = load i32, i32* %level, align 4
  %mul30 = mul nsw i32 2, %29
  %cmp31 = icmp sle i32 %28, %mul30
  br i1 %cmp31, label %for.body.32, label %for.end.67

for.body.32:                                      ; preds = %for.cond.29
  %30 = load i32, i32* %level, align 4
  %mul33 = mul nsw i32 2, %30
  %31 = load i32, i32* %level, align 4
  %mul34 = mul nsw i32 4, %31
  %sub35 = sub nsw i32 %mul33, %mul34
  store i32 %sub35, i32* %x, align 4
  br label %for.cond.36

for.cond.36:                                      ; preds = %for.inc.62, %for.body.32
  %32 = load i32, i32* %x, align 4
  %33 = load i32, i32* %level, align 4
  %mul37 = mul nsw i32 2, %33
  %cmp38 = icmp sle i32 %32, %mul37
  br i1 %cmp38, label %for.body.39, label %for.end.64

for.body.39:                                      ; preds = %for.cond.36
  %34 = load i32, i32* %x, align 4
  %cmp40 = icmp ne i32 %34, 0
  br i1 %cmp40, label %if.then.43, label %lor.lhs.false.41

lor.lhs.false.41:                                 ; preds = %for.body.39
  %35 = load i32, i32* %y, align 4
  %cmp42 = icmp ne i32 %35, 0
  br i1 %cmp42, label %if.then.43, label %if.end.61

if.then.43:                                       ; preds = %lor.lhs.false.41, %for.body.39
  %36 = load i32, i32* %x, align 4
  %37 = load i32, i32* %level, align 4
  %cmp44 = icmp sle i32 %36, %37
  br i1 %cmp44, label %land.lhs.true, label %if.then.52

land.lhs.true:                                    ; preds = %if.then.43
  %38 = load i32, i32* %x, align 4
  %39 = load i32, i32* %level, align 4
  %mul45 = mul nsw i32 -1, %39
  %cmp46 = icmp sge i32 %38, %mul45
  br i1 %cmp46, label %land.lhs.true.47, label %if.then.52

land.lhs.true.47:                                 ; preds = %land.lhs.true
  %40 = load i32, i32* %y, align 4
  %41 = load i32, i32* %level, align 4
  %cmp48 = icmp sle i32 %40, %41
  br i1 %cmp48, label %land.lhs.true.49, label %if.then.52

land.lhs.true.49:                                 ; preds = %land.lhs.true.47
  %42 = load i32, i32* %y, align 4
  %43 = load i32, i32* %level, align 4
  %mul50 = mul nsw i32 -1, %43
  %cmp51 = icmp sge i32 %42, %mul50
  br i1 %cmp51, label %if.end.60, label %if.then.52

if.then.52:                                       ; preds = %land.lhs.true.49, %land.lhs.true.47, %land.lhs.true, %if.then.43
  %44 = load i32, i32* %i, align 4
  %45 = load i32, i32* %y, align 4
  %add53 = add nsw i32 %44, %45
  %46 = load i32, i32* %nj.addr, align 4
  %mul54 = mul nsw i32 %add53, %46
  %47 = load i32, i32* %j, align 4
  %48 = load i32, i32* %x, align 4
  %add55 = add nsw i32 %47, %48
  %add56 = add nsw i32 %mul54, %add55
  %idxprom57 = sext i32 %add56 to i64
  %49 = load i32*, i32** %A.addr, align 8
  %arrayidx58 = getelementptr inbounds i32, i32* %49, i64 %idxprom57
  %50 = load i32, i32* %arrayidx58, align 4
  %51 = load i32, i32* %numberI, align 4
  %add59 = add nsw i32 %51, %50
  store i32 %add59, i32* %numberI, align 4
  br label %if.end.60

if.end.60:                                        ; preds = %if.then.52, %land.lhs.true.49
  br label %if.end.61

if.end.61:                                        ; preds = %if.end.60, %lor.lhs.false.41
  br label %for.inc.62

for.inc.62:                                       ; preds = %if.end.61
  %52 = load i32, i32* %x, align 4
  %inc63 = add nsw i32 %52, 1
  store i32 %inc63, i32* %x, align 4
  br label %for.cond.36

for.end.64:                                       ; preds = %for.cond.36
  br label %for.inc.65

for.inc.65:                                       ; preds = %for.end.64
  %53 = load i32, i32* %y, align 4
  %inc66 = add nsw i32 %53, 1
  store i32 %inc66, i32* %y, align 4
  br label %for.cond.29

for.end.67:                                       ; preds = %for.cond.29
  %54 = load i32, i32* %numberI, align 4
  %conv = sitofp i32 %54 to float
  %55 = load float, float* %power, align 4
  %mul68 = fmul float %conv, %55
  store float %mul68, float* %totalPowerI, align 4
  %56 = load i32, i32* %numberA, align 4
  %conv69 = sitofp i32 %56 to float
  %57 = load float, float* %totalPowerI, align 4
  %sub70 = fsub float %conv69, %57
  %cmp71 = fcmp olt float %sub70, 0.000000e+00
  br i1 %cmp71, label %cond.true, label %cond.false

cond.true:                                        ; preds = %for.end.67
  br label %cond.end.83

cond.false:                                       ; preds = %for.end.67
  %58 = load i32, i32* %numberA, align 4
  %conv73 = sitofp i32 %58 to float
  %59 = load float, float* %totalPowerI, align 4
  %sub74 = fsub float %conv73, %59
  %cmp75 = fcmp ogt float %sub74, 0.000000e+00
  br i1 %cmp75, label %cond.true.77, label %cond.false.78

cond.true.77:                                     ; preds = %cond.false
  br label %cond.end

cond.false.78:                                    ; preds = %cond.false
  %60 = load i32, i32* %i, align 4
  %61 = load i32, i32* %nj.addr, align 4
  %mul79 = mul nsw i32 %60, %61
  %62 = load i32, i32* %j, align 4
  %add80 = add nsw i32 %mul79, %62
  %idxprom81 = sext i32 %add80 to i64
  %63 = load i32*, i32** %A.addr, align 8
  %arrayidx82 = getelementptr inbounds i32, i32* %63, i64 %idxprom81
  %64 = load i32, i32* %arrayidx82, align 4
  br label %cond.end

cond.end:                                         ; preds = %cond.false.78, %cond.true.77
  %cond = phi i32 [ 1, %cond.true.77 ], [ %64, %cond.false.78 ]
  br label %cond.end.83

cond.end.83:                                      ; preds = %cond.end, %cond.true
  %cond84 = phi i32 [ 0, %cond.true ], [ %cond, %cond.end ]
  %65 = load i32, i32* %i, align 4
  %66 = load i32, i32* %nj.addr, align 4
  %mul85 = mul nsw i32 %65, %66
  %67 = load i32, i32* %j, align 4
  %add86 = add nsw i32 %mul85, %67
  %idxprom87 = sext i32 %add86 to i64
  %68 = load i32*, i32** %B.addr, align 8
  %arrayidx88 = getelementptr inbounds i32, i32* %68, i64 %idxprom87
  store i32 %cond84, i32* %arrayidx88, align 4
  br label %for.inc.89

for.inc.89:                                       ; preds = %cond.end.83
  %69 = load i32, i32* %j, align 4
  %inc90 = add nsw i32 %69, 1
  store i32 %inc90, i32* %j, align 4
  br label %for.cond.4

for.end.91:                                       ; preds = %for.cond.4
  br label %for.inc.92

for.inc.92:                                       ; preds = %for.end.91
  %70 = load i32, i32* %i, align 4
  %inc93 = add nsw i32 %70, 1
  store i32 %inc93, i32* %i, align 4
  br label %for.cond.1

for.end.94:                                       ; preds = %for.cond.1
  store i32 1, i32* %i, align 4
  br label %for.cond.95

for.cond.95:                                      ; preds = %for.inc.116, %for.end.94
  %71 = load i32, i32* %i, align 4
  %72 = load i32, i32* %ni.addr, align 4
  %sub96 = sub nsw i32 %72, 1
  %cmp97 = icmp slt i32 %71, %sub96
  br i1 %cmp97, label %for.body.99, label %for.end.118

for.body.99:                                      ; preds = %for.cond.95
  store i32 1, i32* %j, align 4
  br label %for.cond.100

for.cond.100:                                     ; preds = %for.inc.113, %for.body.99
  %73 = load i32, i32* %j, align 4
  %74 = load i32, i32* %nj.addr, align 4
  %sub101 = sub nsw i32 %74, 1
  %cmp102 = icmp slt i32 %73, %sub101
  br i1 %cmp102, label %for.body.104, label %for.end.115

for.body.104:                                     ; preds = %for.cond.100
  %75 = load i32, i32* %i, align 4
  %76 = load i32, i32* %nj.addr, align 4
  %mul105 = mul nsw i32 %75, %76
  %77 = load i32, i32* %j, align 4
  %add106 = add nsw i32 %mul105, %77
  %idxprom107 = sext i32 %add106 to i64
  %78 = load i32*, i32** %B.addr, align 8
  %arrayidx108 = getelementptr inbounds i32, i32* %78, i64 %idxprom107
  %79 = load i32, i32* %arrayidx108, align 4
  %80 = load i32, i32* %i, align 4
  %81 = load i32, i32* %nj.addr, align 4
  %mul109 = mul nsw i32 %80, %81
  %82 = load i32, i32* %j, align 4
  %add110 = add nsw i32 %mul109, %82
  %idxprom111 = sext i32 %add110 to i64
  %83 = load i32*, i32** %A.addr, align 8
  %arrayidx112 = getelementptr inbounds i32, i32* %83, i64 %idxprom111
  store i32 %79, i32* %arrayidx112, align 4
  br label %for.inc.113

for.inc.113:                                      ; preds = %for.body.104
  %84 = load i32, i32* %j, align 4
  %inc114 = add nsw i32 %84, 1
  store i32 %inc114, i32* %j, align 4
  br label %for.cond.100

for.end.115:                                      ; preds = %for.cond.100
  br label %for.inc.116

for.inc.116:                                      ; preds = %for.end.115
  %85 = load i32, i32* %i, align 4
  %inc117 = add nsw i32 %85, 1
  store i32 %inc117, i32* %i, align 4
  br label %for.cond.95

for.end.118:                                      ; preds = %for.cond.95
  br label %for.inc.119

for.inc.119:                                      ; preds = %for.end.118
  %86 = load i32, i32* %t, align 4
  %inc120 = add nsw i32 %86, 1
  store i32 %inc120, i32* %t, align 4
  br label %for.cond

for.end.121:                                      ; preds = %for.cond
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
  %tsteps = alloca i32, align 4
  %t_start = alloca double, align 8
  %t_end = alloca double, align 8
  %A = alloca i32*, align 8
  %B = alloca i32*, align 8
  store i32 0, i32* %retval
  store i32 %argc, i32* %argc.addr, align 4
  store i8** %argv, i8*** %argv.addr, align 8
  store i32 1024, i32* %ni, align 4
  store i32 1024, i32* %nj, align 4
  store i32 10, i32* %tsteps, align 4
  %0 = load i32, i32* %ni, align 4
  %1 = load i32, i32* %nj, align 4
  %mul = mul nsw i32 %0, %1
  %conv = sext i32 %mul to i64
  %mul1 = mul i64 %conv, 4
  %call = call noalias i8* @malloc(i64 %mul1) #3
  %2 = bitcast i8* %call to i32*
  store i32* %2, i32** %A, align 8
  %3 = load i32, i32* %ni, align 4
  %4 = load i32, i32* %nj, align 4
  %mul2 = mul nsw i32 %3, %4
  %conv3 = sext i32 %mul2 to i64
  %mul4 = mul i64 %conv3, 4
  %call5 = call noalias i8* @malloc(i64 %mul4) #3
  %5 = bitcast i8* %call5 to i32*
  store i32* %5, i32** %B, align 8
  %6 = load i32, i32* %ni, align 4
  %7 = load i32, i32* %nj, align 4
  %8 = load i32*, i32** %A, align 8
  %9 = load i32*, i32** %B, align 8
  call void @init_array(i32 %6, i32 %7, i32* %8, i32* %9)
  %call6 = call double @rtclock()
  store double %call6, double* %t_start, align 8
  %10 = load i32, i32* %tsteps, align 4
  %11 = load i32, i32* %ni, align 4
  %12 = load i32, i32* %nj, align 4
  %13 = load i32*, i32** %A, align 8
  %14 = load i32*, i32** %B, align 8
  call void @fur(i32 %10, i32 %11, i32 %12, i32* %13, i32* %14)
  %call7 = call double @rtclock()
  store double %call7, double* %t_end, align 8
  %15 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %16 = load double, double* %t_end, align 8
  %17 = load double, double* %t_start, align 8
  %sub = fsub double %16, %17
  %call8 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %15, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.1, i32 0, i32 0), double %sub)
  %18 = load i32*, i32** %A, align 8
  %19 = bitcast i32* %18 to i8*
  call void @free(i8* %19) #3
  %20 = load i32*, i32** %B, align 8
  %21 = bitcast i32* %20 to i8*
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
