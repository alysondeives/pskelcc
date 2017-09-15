; ModuleID = 'gol.c'
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
  call void @gol(i32 %10, i32 %11, i32 %12, i32* %13, i32* %14)
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

; Function Attrs: nounwind uwtable
define internal void @gol(i32 %tsteps, i32 %ni, i32 %nj, i32* %A, i32* %B) #0 {
entry:
  %tsteps.addr = alloca i32, align 4
  %ni.addr = alloca i32, align 4
  %nj.addr = alloca i32, align 4
  %A.addr = alloca i32*, align 8
  %B.addr = alloca i32*, align 8
  %t = alloca i32, align 4
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %neighbors = alloca i32, align 4
  %y = alloca i32, align 4
  %x = alloca i32, align 4
  store i32 %tsteps, i32* %tsteps.addr, align 4
  store i32 %ni, i32* %ni.addr, align 4
  store i32 %nj, i32* %nj.addr, align 4
  store i32* %A, i32** %A.addr, align 8
  store i32* %B, i32** %B.addr, align 8
  store i32 0, i32* %neighbors, align 4
  store i32 0, i32* %t, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.60, %entry
  %0 = load i32, i32* %t, align 4
  %1 = load i32, i32* %tsteps.addr, align 4
  %cmp = icmp slt i32 %0, %1
  br i1 %cmp, label %for.body, label %for.end.62

for.body:                                         ; preds = %for.cond
  store i32 1, i32* %i, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc.35, %for.body
  %2 = load i32, i32* %i, align 4
  %3 = load i32, i32* %ni.addr, align 4
  %sub = sub nsw i32 %3, 1
  %cmp2 = icmp slt i32 %2, %sub
  br i1 %cmp2, label %for.body.3, label %for.end.37

for.body.3:                                       ; preds = %for.cond.1
  store i32 1, i32* %j, align 4
  br label %for.cond.4

for.cond.4:                                       ; preds = %for.inc.32, %for.body.3
  %4 = load i32, i32* %j, align 4
  %5 = load i32, i32* %nj.addr, align 4
  %sub5 = sub nsw i32 %5, 1
  %cmp6 = icmp slt i32 %4, %sub5
  br i1 %cmp6, label %for.body.7, label %for.end.34

for.body.7:                                       ; preds = %for.cond.4
  store i32 -1, i32* %y, align 4
  br label %for.cond.8

for.cond.8:                                       ; preds = %for.inc.19, %for.body.7
  %6 = load i32, i32* %y, align 4
  %cmp9 = icmp sle i32 %6, 1
  br i1 %cmp9, label %for.body.10, label %for.end.21

for.body.10:                                      ; preds = %for.cond.8
  store i32 -1, i32* %x, align 4
  br label %for.cond.11

for.cond.11:                                      ; preds = %for.inc, %for.body.10
  %7 = load i32, i32* %x, align 4
  %cmp12 = icmp sle i32 %7, 1
  br i1 %cmp12, label %for.body.13, label %for.end

for.body.13:                                      ; preds = %for.cond.11
  %8 = load i32, i32* %x, align 4
  %cmp14 = icmp ne i32 %8, 0
  br i1 %cmp14, label %land.lhs.true, label %if.end

land.lhs.true:                                    ; preds = %for.body.13
  %9 = load i32, i32* %y, align 4
  %cmp15 = icmp ne i32 %9, 0
  br i1 %cmp15, label %if.then, label %if.end

if.then:                                          ; preds = %land.lhs.true
  %10 = load i32, i32* %i, align 4
  %11 = load i32, i32* %y, align 4
  %add = add nsw i32 %10, %11
  %12 = load i32, i32* %nj.addr, align 4
  %mul = mul nsw i32 %add, %12
  %13 = load i32, i32* %j, align 4
  %14 = load i32, i32* %x, align 4
  %add16 = add nsw i32 %13, %14
  %add17 = add nsw i32 %mul, %add16
  %idxprom = sext i32 %add17 to i64
  %15 = load i32*, i32** %A.addr, align 8
  %arrayidx = getelementptr inbounds i32, i32* %15, i64 %idxprom
  %16 = load i32, i32* %arrayidx, align 4
  %17 = load i32, i32* %neighbors, align 4
  %add18 = add nsw i32 %17, %16
  store i32 %add18, i32* %neighbors, align 4
  br label %if.end

if.end:                                           ; preds = %if.then, %land.lhs.true, %for.body.13
  br label %for.inc

for.inc:                                          ; preds = %if.end
  %18 = load i32, i32* %x, align 4
  %inc = add nsw i32 %18, 1
  store i32 %inc, i32* %x, align 4
  br label %for.cond.11

for.end:                                          ; preds = %for.cond.11
  br label %for.inc.19

for.inc.19:                                       ; preds = %for.end
  %19 = load i32, i32* %y, align 4
  %inc20 = add nsw i32 %19, 1
  store i32 %inc20, i32* %y, align 4
  br label %for.cond.8

for.end.21:                                       ; preds = %for.cond.8
  %20 = load i32, i32* %neighbors, align 4
  %cmp22 = icmp eq i32 %20, 3
  br i1 %cmp22, label %lor.end, label %lor.rhs

lor.rhs:                                          ; preds = %for.end.21
  %21 = load i32, i32* %neighbors, align 4
  %cmp23 = icmp eq i32 %21, 2
  br i1 %cmp23, label %land.rhs, label %land.end

land.rhs:                                         ; preds = %lor.rhs
  %22 = load i32, i32* %i, align 4
  %23 = load i32, i32* %nj.addr, align 4
  %mul24 = mul nsw i32 %22, %23
  %24 = load i32, i32* %j, align 4
  %add25 = add nsw i32 %mul24, %24
  %idxprom26 = sext i32 %add25 to i64
  %25 = load i32*, i32** %A.addr, align 8
  %arrayidx27 = getelementptr inbounds i32, i32* %25, i64 %idxprom26
  %26 = load i32, i32* %arrayidx27, align 4
  %tobool = icmp ne i32 %26, 0
  br label %land.end

land.end:                                         ; preds = %land.rhs, %lor.rhs
  %27 = phi i1 [ false, %lor.rhs ], [ %tobool, %land.rhs ]
  br label %lor.end

lor.end:                                          ; preds = %land.end, %for.end.21
  %28 = phi i1 [ true, %for.end.21 ], [ %27, %land.end ]
  %cond = select i1 %28, i32 1, i32 0
  %29 = load i32, i32* %i, align 4
  %30 = load i32, i32* %nj.addr, align 4
  %mul28 = mul nsw i32 %29, %30
  %31 = load i32, i32* %j, align 4
  %add29 = add nsw i32 %mul28, %31
  %idxprom30 = sext i32 %add29 to i64
  %32 = load i32*, i32** %B.addr, align 8
  %arrayidx31 = getelementptr inbounds i32, i32* %32, i64 %idxprom30
  store i32 %cond, i32* %arrayidx31, align 4
  br label %for.inc.32

for.inc.32:                                       ; preds = %lor.end
  %33 = load i32, i32* %j, align 4
  %inc33 = add nsw i32 %33, 1
  store i32 %inc33, i32* %j, align 4
  br label %for.cond.4

for.end.34:                                       ; preds = %for.cond.4
  br label %for.inc.35

for.inc.35:                                       ; preds = %for.end.34
  %34 = load i32, i32* %i, align 4
  %inc36 = add nsw i32 %34, 1
  store i32 %inc36, i32* %i, align 4
  br label %for.cond.1

for.end.37:                                       ; preds = %for.cond.1
  store i32 1, i32* %i, align 4
  br label %for.cond.38

for.cond.38:                                      ; preds = %for.inc.57, %for.end.37
  %35 = load i32, i32* %i, align 4
  %36 = load i32, i32* %ni.addr, align 4
  %sub39 = sub nsw i32 %36, 1
  %cmp40 = icmp slt i32 %35, %sub39
  br i1 %cmp40, label %for.body.41, label %for.end.59

for.body.41:                                      ; preds = %for.cond.38
  store i32 1, i32* %j, align 4
  br label %for.cond.42

for.cond.42:                                      ; preds = %for.inc.54, %for.body.41
  %37 = load i32, i32* %j, align 4
  %38 = load i32, i32* %nj.addr, align 4
  %sub43 = sub nsw i32 %38, 1
  %cmp44 = icmp slt i32 %37, %sub43
  br i1 %cmp44, label %for.body.45, label %for.end.56

for.body.45:                                      ; preds = %for.cond.42
  %39 = load i32, i32* %i, align 4
  %40 = load i32, i32* %nj.addr, align 4
  %mul46 = mul nsw i32 %39, %40
  %41 = load i32, i32* %j, align 4
  %add47 = add nsw i32 %mul46, %41
  %idxprom48 = sext i32 %add47 to i64
  %42 = load i32*, i32** %B.addr, align 8
  %arrayidx49 = getelementptr inbounds i32, i32* %42, i64 %idxprom48
  %43 = load i32, i32* %arrayidx49, align 4
  %44 = load i32, i32* %i, align 4
  %45 = load i32, i32* %nj.addr, align 4
  %mul50 = mul nsw i32 %44, %45
  %46 = load i32, i32* %j, align 4
  %add51 = add nsw i32 %mul50, %46
  %idxprom52 = sext i32 %add51 to i64
  %47 = load i32*, i32** %A.addr, align 8
  %arrayidx53 = getelementptr inbounds i32, i32* %47, i64 %idxprom52
  store i32 %43, i32* %arrayidx53, align 4
  br label %for.inc.54

for.inc.54:                                       ; preds = %for.body.45
  %48 = load i32, i32* %j, align 4
  %inc55 = add nsw i32 %48, 1
  store i32 %inc55, i32* %j, align 4
  br label %for.cond.42

for.end.56:                                       ; preds = %for.cond.42
  br label %for.inc.57

for.inc.57:                                       ; preds = %for.end.56
  %49 = load i32, i32* %i, align 4
  %inc58 = add nsw i32 %49, 1
  store i32 %inc58, i32* %i, align 4
  br label %for.cond.38

for.end.59:                                       ; preds = %for.cond.38
  br label %for.inc.60

for.inc.60:                                       ; preds = %for.end.59
  %50 = load i32, i32* %t, align 4
  %inc61 = add nsw i32 %50, 1
  store i32 %inc61, i32* %t, align 4
  br label %for.cond

for.end.62:                                       ; preds = %for.cond
  ret void
}

declare i32 @fprintf(%struct._IO_FILE*, i8*, ...) #2

; Function Attrs: nounwind
declare void @free(i8*) #1

attributes #0 = { nounwind uwtable "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nounwind }

!llvm.ident = !{!0}

!0 = !{!"clang version 3.7.1 (https://github.com/llvm-mirror/clang.git 0dbefa1b83eb90f7a06b5df5df254ce32be3db4b) (https://github.com/llvm-mirror/llvm.git 33c352b3eda89abc24e7511d9045fa2e499a42e3)"}
