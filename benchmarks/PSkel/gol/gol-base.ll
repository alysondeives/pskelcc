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
define void @init_array(i32 %n, i32* %A, i32* %B) #0 {
entry:
  %n.addr = alloca i32, align 4
  %A.addr = alloca i32*, align 8
  %B.addr = alloca i32*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  store i32 %n, i32* %n.addr, align 4
  store i32* %A, i32** %A.addr, align 8
  store i32* %B, i32** %B.addr, align 8
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.15, %entry
  %0 = load i32, i32* %i, align 4
  %1 = load i32, i32* %n.addr, align 4
  %cmp = icmp slt i32 %0, %1
  br i1 %cmp, label %for.body, label %for.end.17

for.body:                                         ; preds = %for.cond
  store i32 0, i32* %j, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %2 = load i32, i32* %j, align 4
  %3 = load i32, i32* %n.addr, align 4
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
  %7 = load i32, i32* %n.addr, align 4
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
  %13 = load i32, i32* %n.addr, align 4
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
  %n = alloca i32, align 4
  %tsteps = alloca i32, align 4
  %t_start = alloca double, align 8
  %t_end = alloca double, align 8
  %A = alloca i32*, align 8
  %B = alloca i32*, align 8
  store i32 0, i32* %retval
  store i32 %argc, i32* %argc.addr, align 4
  store i8** %argv, i8*** %argv.addr, align 8
  store i32 1024, i32* %n, align 4
  store i32 10, i32* %tsteps, align 4
  %0 = load i32, i32* %n, align 4
  %1 = load i32, i32* %n, align 4
  %mul = mul nsw i32 %0, %1
  %conv = sext i32 %mul to i64
  %mul1 = mul i64 %conv, 4
  %call = call noalias i8* @malloc(i64 %mul1) #3
  %2 = bitcast i8* %call to i32*
  store i32* %2, i32** %A, align 8
  %3 = load i32, i32* %n, align 4
  %4 = load i32, i32* %n, align 4
  %mul2 = mul nsw i32 %3, %4
  %conv3 = sext i32 %mul2 to i64
  %mul4 = mul i64 %conv3, 4
  %call5 = call noalias i8* @malloc(i64 %mul4) #3
  %5 = bitcast i8* %call5 to i32*
  store i32* %5, i32** %B, align 8
  %6 = load i32, i32* %n, align 4
  %7 = load i32*, i32** %A, align 8
  %8 = load i32*, i32** %B, align 8
  call void @init_array(i32 %6, i32* %7, i32* %8)
  %call6 = call double @rtclock()
  store double %call6, double* %t_start, align 8
  %9 = load i32, i32* %tsteps, align 4
  %10 = load i32, i32* %n, align 4
  %11 = load i32*, i32** %A, align 8
  %12 = load i32*, i32** %B, align 8
  call void @gol(i32 %9, i32 %10, i32* %11, i32* %12)
  %call7 = call double @rtclock()
  store double %call7, double* %t_end, align 8
  %13 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %14 = load double, double* %t_end, align 8
  %15 = load double, double* %t_start, align 8
  %sub = fsub double %14, %15
  %call8 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %13, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.1, i32 0, i32 0), double %sub)
  %16 = load i32*, i32** %A, align 8
  %17 = bitcast i32* %16 to i8*
  call void @free(i8* %17) #3
  %18 = load i32*, i32** %B, align 8
  %19 = bitcast i32* %18 to i8*
  call void @free(i8* %19) #3
  ret i32 0
}

; Function Attrs: nounwind
declare noalias i8* @malloc(i64) #1

; Function Attrs: nounwind uwtable
define internal void @gol(i32 %tsteps, i32 %n, i32* %A, i32* %B) #0 {
entry:
  %tsteps.addr = alloca i32, align 4
  %n.addr = alloca i32, align 4
  %A.addr = alloca i32*, align 8
  %B.addr = alloca i32*, align 8
  %t = alloca i32, align 4
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %neighbors = alloca i32, align 4
  store i32 %tsteps, i32* %tsteps.addr, align 4
  store i32 %n, i32* %n.addr, align 4
  store i32* %A, i32** %A.addr, align 8
  store i32* %B, i32** %B.addr, align 8
  store i32 0, i32* %t, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.90, %entry
  %0 = load i32, i32* %t, align 4
  %1 = load i32, i32* %tsteps.addr, align 4
  %cmp = icmp slt i32 %0, %1
  br i1 %cmp, label %for.body, label %for.end.92

for.body:                                         ; preds = %for.cond
  store i32 1, i32* %i, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc.65, %for.body
  %2 = load i32, i32* %i, align 4
  %3 = load i32, i32* %n.addr, align 4
  %sub = sub nsw i32 %3, 1
  %cmp2 = icmp slt i32 %2, %sub
  br i1 %cmp2, label %for.body.3, label %for.end.67

for.body.3:                                       ; preds = %for.cond.1
  store i32 1, i32* %j, align 4
  br label %for.cond.4

for.cond.4:                                       ; preds = %for.inc, %for.body.3
  %4 = load i32, i32* %j, align 4
  %5 = load i32, i32* %n.addr, align 4
  %sub5 = sub nsw i32 %5, 1
  %cmp6 = icmp slt i32 %4, %sub5
  br i1 %cmp6, label %for.body.7, label %for.end

for.body.7:                                       ; preds = %for.cond.4
  %6 = load i32, i32* %i, align 4
  %sub8 = sub nsw i32 %6, 1
  %7 = load i32, i32* %n.addr, align 4
  %mul = mul nsw i32 %sub8, %7
  %8 = load i32, i32* %j, align 4
  %sub9 = sub nsw i32 %8, 1
  %add = add nsw i32 %mul, %sub9
  %idxprom = sext i32 %add to i64
  %9 = load i32*, i32** %A.addr, align 8
  %arrayidx = getelementptr inbounds i32, i32* %9, i64 %idxprom
  %10 = load i32, i32* %arrayidx, align 4
  %11 = load i32, i32* %i, align 4
  %sub10 = sub nsw i32 %11, 1
  %12 = load i32, i32* %n.addr, align 4
  %mul11 = mul nsw i32 %sub10, %12
  %13 = load i32, i32* %j, align 4
  %add12 = add nsw i32 %mul11, %13
  %idxprom13 = sext i32 %add12 to i64
  %14 = load i32*, i32** %A.addr, align 8
  %arrayidx14 = getelementptr inbounds i32, i32* %14, i64 %idxprom13
  %15 = load i32, i32* %arrayidx14, align 4
  %add15 = add nsw i32 %10, %15
  %16 = load i32, i32* %i, align 4
  %sub16 = sub nsw i32 %16, 1
  %17 = load i32, i32* %n.addr, align 4
  %mul17 = mul nsw i32 %sub16, %17
  %18 = load i32, i32* %j, align 4
  %add18 = add nsw i32 %18, 1
  %add19 = add nsw i32 %mul17, %add18
  %idxprom20 = sext i32 %add19 to i64
  %19 = load i32*, i32** %A.addr, align 8
  %arrayidx21 = getelementptr inbounds i32, i32* %19, i64 %idxprom20
  %20 = load i32, i32* %arrayidx21, align 4
  %add22 = add nsw i32 %add15, %20
  %21 = load i32, i32* %i, align 4
  %22 = load i32, i32* %n.addr, align 4
  %mul23 = mul nsw i32 %21, %22
  %23 = load i32, i32* %j, align 4
  %sub24 = sub nsw i32 %23, 1
  %add25 = add nsw i32 %mul23, %sub24
  %idxprom26 = sext i32 %add25 to i64
  %24 = load i32*, i32** %A.addr, align 8
  %arrayidx27 = getelementptr inbounds i32, i32* %24, i64 %idxprom26
  %25 = load i32, i32* %arrayidx27, align 4
  %add28 = add nsw i32 %add22, %25
  %26 = load i32, i32* %i, align 4
  %27 = load i32, i32* %n.addr, align 4
  %mul29 = mul nsw i32 %26, %27
  %28 = load i32, i32* %j, align 4
  %add30 = add nsw i32 %28, 1
  %add31 = add nsw i32 %mul29, %add30
  %idxprom32 = sext i32 %add31 to i64
  %29 = load i32*, i32** %A.addr, align 8
  %arrayidx33 = getelementptr inbounds i32, i32* %29, i64 %idxprom32
  %30 = load i32, i32* %arrayidx33, align 4
  %add34 = add nsw i32 %add28, %30
  %31 = load i32, i32* %i, align 4
  %add35 = add nsw i32 %31, 1
  %32 = load i32, i32* %n.addr, align 4
  %mul36 = mul nsw i32 %add35, %32
  %33 = load i32, i32* %j, align 4
  %sub37 = sub nsw i32 %33, 1
  %add38 = add nsw i32 %mul36, %sub37
  %idxprom39 = sext i32 %add38 to i64
  %34 = load i32*, i32** %A.addr, align 8
  %arrayidx40 = getelementptr inbounds i32, i32* %34, i64 %idxprom39
  %35 = load i32, i32* %arrayidx40, align 4
  %add41 = add nsw i32 %add34, %35
  %36 = load i32, i32* %i, align 4
  %add42 = add nsw i32 %36, 1
  %37 = load i32, i32* %n.addr, align 4
  %mul43 = mul nsw i32 %add42, %37
  %38 = load i32, i32* %j, align 4
  %add44 = add nsw i32 %mul43, %38
  %idxprom45 = sext i32 %add44 to i64
  %39 = load i32*, i32** %A.addr, align 8
  %arrayidx46 = getelementptr inbounds i32, i32* %39, i64 %idxprom45
  %40 = load i32, i32* %arrayidx46, align 4
  %add47 = add nsw i32 %add41, %40
  %41 = load i32, i32* %i, align 4
  %sub48 = sub nsw i32 %41, 1
  %42 = load i32, i32* %n.addr, align 4
  %mul49 = mul nsw i32 %sub48, %42
  %43 = load i32, i32* %j, align 4
  %add50 = add nsw i32 %43, 1
  %add51 = add nsw i32 %mul49, %add50
  %idxprom52 = sext i32 %add51 to i64
  %44 = load i32*, i32** %A.addr, align 8
  %arrayidx53 = getelementptr inbounds i32, i32* %44, i64 %idxprom52
  %45 = load i32, i32* %arrayidx53, align 4
  %add54 = add nsw i32 %add47, %45
  store i32 %add54, i32* %neighbors, align 4
  %46 = load i32, i32* %neighbors, align 4
  %cmp55 = icmp eq i32 %46, 3
  br i1 %cmp55, label %lor.end, label %lor.rhs

lor.rhs:                                          ; preds = %for.body.7
  %47 = load i32, i32* %neighbors, align 4
  %cmp56 = icmp eq i32 %47, 2
  br i1 %cmp56, label %land.rhs, label %land.end

land.rhs:                                         ; preds = %lor.rhs
  %48 = load i32, i32* %i, align 4
  %49 = load i32, i32* %n.addr, align 4
  %mul57 = mul nsw i32 %48, %49
  %50 = load i32, i32* %j, align 4
  %add58 = add nsw i32 %mul57, %50
  %idxprom59 = sext i32 %add58 to i64
  %51 = load i32*, i32** %A.addr, align 8
  %arrayidx60 = getelementptr inbounds i32, i32* %51, i64 %idxprom59
  %52 = load i32, i32* %arrayidx60, align 4
  %tobool = icmp ne i32 %52, 0
  br label %land.end

land.end:                                         ; preds = %land.rhs, %lor.rhs
  %53 = phi i1 [ false, %lor.rhs ], [ %tobool, %land.rhs ]
  br label %lor.end

lor.end:                                          ; preds = %land.end, %for.body.7
  %54 = phi i1 [ true, %for.body.7 ], [ %53, %land.end ]
  %cond = select i1 %54, i32 1, i32 0
  %55 = load i32, i32* %i, align 4
  %56 = load i32, i32* %n.addr, align 4
  %mul61 = mul nsw i32 %55, %56
  %57 = load i32, i32* %j, align 4
  %add62 = add nsw i32 %mul61, %57
  %idxprom63 = sext i32 %add62 to i64
  %58 = load i32*, i32** %B.addr, align 8
  %arrayidx64 = getelementptr inbounds i32, i32* %58, i64 %idxprom63
  store i32 %cond, i32* %arrayidx64, align 4
  br label %for.inc

for.inc:                                          ; preds = %lor.end
  %59 = load i32, i32* %j, align 4
  %inc = add nsw i32 %59, 1
  store i32 %inc, i32* %j, align 4
  br label %for.cond.4

for.end:                                          ; preds = %for.cond.4
  br label %for.inc.65

for.inc.65:                                       ; preds = %for.end
  %60 = load i32, i32* %i, align 4
  %inc66 = add nsw i32 %60, 1
  store i32 %inc66, i32* %i, align 4
  br label %for.cond.1

for.end.67:                                       ; preds = %for.cond.1
  store i32 1, i32* %i, align 4
  br label %for.cond.68

for.cond.68:                                      ; preds = %for.inc.87, %for.end.67
  %61 = load i32, i32* %i, align 4
  %62 = load i32, i32* %n.addr, align 4
  %sub69 = sub nsw i32 %62, 1
  %cmp70 = icmp slt i32 %61, %sub69
  br i1 %cmp70, label %for.body.71, label %for.end.89

for.body.71:                                      ; preds = %for.cond.68
  store i32 1, i32* %j, align 4
  br label %for.cond.72

for.cond.72:                                      ; preds = %for.inc.84, %for.body.71
  %63 = load i32, i32* %j, align 4
  %64 = load i32, i32* %n.addr, align 4
  %sub73 = sub nsw i32 %64, 1
  %cmp74 = icmp slt i32 %63, %sub73
  br i1 %cmp74, label %for.body.75, label %for.end.86

for.body.75:                                      ; preds = %for.cond.72
  %65 = load i32, i32* %i, align 4
  %66 = load i32, i32* %n.addr, align 4
  %mul76 = mul nsw i32 %65, %66
  %67 = load i32, i32* %j, align 4
  %add77 = add nsw i32 %mul76, %67
  %idxprom78 = sext i32 %add77 to i64
  %68 = load i32*, i32** %B.addr, align 8
  %arrayidx79 = getelementptr inbounds i32, i32* %68, i64 %idxprom78
  %69 = load i32, i32* %arrayidx79, align 4
  %70 = load i32, i32* %i, align 4
  %71 = load i32, i32* %n.addr, align 4
  %mul80 = mul nsw i32 %70, %71
  %72 = load i32, i32* %j, align 4
  %add81 = add nsw i32 %mul80, %72
  %idxprom82 = sext i32 %add81 to i64
  %73 = load i32*, i32** %A.addr, align 8
  %arrayidx83 = getelementptr inbounds i32, i32* %73, i64 %idxprom82
  store i32 %69, i32* %arrayidx83, align 4
  br label %for.inc.84

for.inc.84:                                       ; preds = %for.body.75
  %74 = load i32, i32* %j, align 4
  %inc85 = add nsw i32 %74, 1
  store i32 %inc85, i32* %j, align 4
  br label %for.cond.72

for.end.86:                                       ; preds = %for.cond.72
  br label %for.inc.87

for.inc.87:                                       ; preds = %for.end.86
  %75 = load i32, i32* %i, align 4
  %inc88 = add nsw i32 %75, 1
  store i32 %inc88, i32* %i, align 4
  br label %for.cond.68

for.end.89:                                       ; preds = %for.cond.68
  br label %for.inc.90

for.inc.90:                                       ; preds = %for.end.89
  %76 = load i32, i32* %t, align 4
  %inc91 = add nsw i32 %76, 1
  store i32 %inc91, i32* %t, align 4
  br label %for.cond

for.end.92:                                       ; preds = %for.cond
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
