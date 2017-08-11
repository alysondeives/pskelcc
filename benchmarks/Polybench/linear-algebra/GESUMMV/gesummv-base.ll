; ModuleID = 'gesummv.c'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, i8*, i8*, i8*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type { %struct._IO_marker*, %struct._IO_FILE*, i32 }
%struct.timezone = type { i32, i32 }
%struct.timeval = type { i64, i64 }

@.str = private unnamed_addr constant [35 x i8] c"Error return from gettimeofday: %d\00", align 1
@.str.1 = private unnamed_addr constant [74 x i8] c"Non-Matching CPU-GPU Outputs Beyond Error Threshold of %4.2f Percent: %d\0A\00", align 1
@stdout = external global %struct._IO_FILE*, align 8
@.str.2 = private unnamed_addr constant [48 x i8] c"<< Scalar, Vector and Matrix Multiplication >>\0A\00", align 1
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
define void @gesummv(i32 %n, float* %A, float* %B, float* %x, float* %y, float* %tmp) #0 {
entry:
  %n.addr = alloca i32, align 4
  %A.addr = alloca float*, align 8
  %B.addr = alloca float*, align 8
  %x.addr = alloca float*, align 8
  %y.addr = alloca float*, align 8
  %tmp.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  store i32 %n, i32* %n.addr, align 4
  store float* %A, float** %A.addr, align 8
  store float* %B, float** %B.addr, align 8
  store float* %x, float** %x.addr, align 8
  store float* %y, float** %y.addr, align 8
  store float* %tmp, float** %tmp.addr, align 8
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.39, %entry
  %0 = load i32, i32* %i, align 4
  %1 = load i32, i32* %n.addr, align 4
  %cmp = icmp slt i32 %0, %1
  br i1 %cmp, label %for.body, label %for.end.41

for.body:                                         ; preds = %for.cond
  %2 = load i32, i32* %i, align 4
  %idxprom = sext i32 %2 to i64
  %3 = load float*, float** %tmp.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %3, i64 %idxprom
  store float 0.000000e+00, float* %arrayidx, align 4
  %4 = load i32, i32* %i, align 4
  %idxprom3 = sext i32 %4 to i64
  %5 = load float*, float** %y.addr, align 8
  %arrayidx4 = getelementptr inbounds float, float* %5, i64 %idxprom3
  store float 0.000000e+00, float* %arrayidx4, align 4
  store i32 0, i32* %j, align 4
  br label %for.cond.5

for.cond.5:                                       ; preds = %for.inc, %for.body
  %6 = load i32, i32* %j, align 4
  %7 = load i32, i32* %n.addr, align 4
  %cmp6 = icmp slt i32 %6, %7
  br i1 %cmp6, label %for.body.7, label %for.end

for.body.7:                                       ; preds = %for.cond.5
  %8 = load i32, i32* %i, align 4
  %9 = load i32, i32* %n.addr, align 4
  %mul = mul nsw i32 %8, %9
  %10 = load i32, i32* %j, align 4
  %add = add nsw i32 %mul, %10
  %idxprom8 = sext i32 %add to i64
  %11 = load float*, float** %A.addr, align 8
  %arrayidx9 = getelementptr inbounds float, float* %11, i64 %idxprom8
  %12 = load float, float* %arrayidx9, align 4
  %13 = load i32, i32* %j, align 4
  %idxprom10 = sext i32 %13 to i64
  %14 = load float*, float** %x.addr, align 8
  %arrayidx11 = getelementptr inbounds float, float* %14, i64 %idxprom10
  %15 = load float, float* %arrayidx11, align 4
  %mul12 = fmul float %12, %15
  %16 = load i32, i32* %i, align 4
  %idxprom13 = sext i32 %16 to i64
  %17 = load float*, float** %tmp.addr, align 8
  %arrayidx14 = getelementptr inbounds float, float* %17, i64 %idxprom13
  %18 = load float, float* %arrayidx14, align 4
  %add15 = fadd float %mul12, %18
  %19 = load i32, i32* %i, align 4
  %idxprom16 = sext i32 %19 to i64
  %20 = load float*, float** %tmp.addr, align 8
  %arrayidx17 = getelementptr inbounds float, float* %20, i64 %idxprom16
  store float %add15, float* %arrayidx17, align 4
  %21 = load i32, i32* %i, align 4
  %22 = load i32, i32* %n.addr, align 4
  %mul18 = mul nsw i32 %21, %22
  %23 = load i32, i32* %j, align 4
  %add19 = add nsw i32 %mul18, %23
  %idxprom20 = sext i32 %add19 to i64
  %24 = load float*, float** %B.addr, align 8
  %arrayidx21 = getelementptr inbounds float, float* %24, i64 %idxprom20
  %25 = load float, float* %arrayidx21, align 4
  %26 = load i32, i32* %j, align 4
  %idxprom22 = sext i32 %26 to i64
  %27 = load float*, float** %x.addr, align 8
  %arrayidx23 = getelementptr inbounds float, float* %27, i64 %idxprom22
  %28 = load float, float* %arrayidx23, align 4
  %mul24 = fmul float %25, %28
  %29 = load i32, i32* %i, align 4
  %idxprom25 = sext i32 %29 to i64
  %30 = load float*, float** %y.addr, align 8
  %arrayidx26 = getelementptr inbounds float, float* %30, i64 %idxprom25
  %31 = load float, float* %arrayidx26, align 4
  %add27 = fadd float %mul24, %31
  %32 = load i32, i32* %i, align 4
  %idxprom28 = sext i32 %32 to i64
  %33 = load float*, float** %y.addr, align 8
  %arrayidx29 = getelementptr inbounds float, float* %33, i64 %idxprom28
  store float %add27, float* %arrayidx29, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.7
  %34 = load i32, i32* %j, align 4
  %inc = add nsw i32 %34, 1
  store i32 %inc, i32* %j, align 4
  br label %for.cond.5

for.end:                                          ; preds = %for.cond.5
  %35 = load i32, i32* %i, align 4
  %idxprom30 = sext i32 %35 to i64
  %36 = load float*, float** %tmp.addr, align 8
  %arrayidx31 = getelementptr inbounds float, float* %36, i64 %idxprom30
  %37 = load float, float* %arrayidx31, align 4
  %mul32 = fmul float 4.353200e+04, %37
  %38 = load i32, i32* %i, align 4
  %idxprom33 = sext i32 %38 to i64
  %39 = load float*, float** %y.addr, align 8
  %arrayidx34 = getelementptr inbounds float, float* %39, i64 %idxprom33
  %40 = load float, float* %arrayidx34, align 4
  %mul35 = fmul float 1.231300e+04, %40
  %add36 = fadd float %mul32, %mul35
  %41 = load i32, i32* %i, align 4
  %idxprom37 = sext i32 %41 to i64
  %42 = load float*, float** %y.addr, align 8
  %arrayidx38 = getelementptr inbounds float, float* %42, i64 %idxprom37
  store float %add36, float* %arrayidx38, align 4
  br label %for.inc.39

for.inc.39:                                       ; preds = %for.end
  %43 = load i32, i32* %i, align 4
  %inc40 = add nsw i32 %43, 1
  store i32 %inc40, i32* %i, align 4
  br label %for.cond

for.end.41:                                       ; preds = %for.cond
  ret void
}

; Function Attrs: nounwind uwtable
define void @init(float* %A, float* %x) #0 {
entry:
  %A.addr = alloca float*, align 8
  %x.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  store float* %A, float** %A.addr, align 8
  store float* %x, float** %x.addr, align 8
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.11, %entry
  %0 = load i32, i32* %i, align 4
  %cmp = icmp slt i32 %0, 2048
  br i1 %cmp, label %for.body, label %for.end.13

for.body:                                         ; preds = %for.cond
  %1 = load i32, i32* %i, align 4
  %conv = sitofp i32 %1 to float
  %div = fdiv float %conv, 2.048000e+03
  %2 = load i32, i32* %i, align 4
  %idxprom = sext i32 %2 to i64
  %3 = load float*, float** %x.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %3, i64 %idxprom
  store float %div, float* %arrayidx, align 4
  store i32 0, i32* %j, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %4 = load i32, i32* %j, align 4
  %cmp2 = icmp slt i32 %4, 2048
  br i1 %cmp2, label %for.body.4, label %for.end

for.body.4:                                       ; preds = %for.cond.1
  %5 = load i32, i32* %i, align 4
  %conv5 = sitofp i32 %5 to float
  %6 = load i32, i32* %j, align 4
  %conv6 = sitofp i32 %6 to float
  %mul = fmul float %conv5, %conv6
  %div7 = fdiv float %mul, 2.048000e+03
  %7 = load i32, i32* %i, align 4
  %mul8 = mul nsw i32 %7, 2048
  %8 = load i32, i32* %j, align 4
  %add = add nsw i32 %mul8, %8
  %idxprom9 = sext i32 %add to i64
  %9 = load float*, float** %A.addr, align 8
  %arrayidx10 = getelementptr inbounds float, float* %9, i64 %idxprom9
  store float %div7, float* %arrayidx10, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.4
  %10 = load i32, i32* %j, align 4
  %inc = add nsw i32 %10, 1
  store i32 %inc, i32* %j, align 4
  br label %for.cond.1

for.end:                                          ; preds = %for.cond.1
  br label %for.inc.11

for.inc.11:                                       ; preds = %for.end
  %11 = load i32, i32* %i, align 4
  %inc12 = add nsw i32 %11, 1
  store i32 %inc12, i32* %i, align 4
  br label %for.cond

for.end.13:                                       ; preds = %for.cond
  ret void
}

; Function Attrs: nounwind uwtable
define void @compareResults(float* %y, float* %y_outputFromGpu) #0 {
entry:
  %y.addr = alloca float*, align 8
  %y_outputFromGpu.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %fail = alloca i32, align 4
  store float* %y, float** %y.addr, align 8
  store float* %y_outputFromGpu, float** %y_outputFromGpu.addr, align 8
  store i32 0, i32* %fail, align 4
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %0 = load i32, i32* %i, align 4
  %cmp = icmp slt i32 %0, 2048
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %1 = load i32, i32* %i, align 4
  %idxprom = sext i32 %1 to i64
  %2 = load float*, float** %y.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %2, i64 %idxprom
  %3 = load float, float* %arrayidx, align 4
  %conv = fpext float %3 to double
  %4 = load i32, i32* %i, align 4
  %idxprom1 = sext i32 %4 to i64
  %5 = load float*, float** %y_outputFromGpu.addr, align 8
  %arrayidx2 = getelementptr inbounds float, float* %5, i64 %idxprom1
  %6 = load float, float* %arrayidx2, align 4
  %conv3 = fpext float %6 to double
  %call = call float @percentDiff(double %conv, double %conv3)
  %conv4 = fpext float %call to double
  %cmp5 = fcmp ogt double %conv4, 5.000000e-02
  br i1 %cmp5, label %if.then, label %if.end

if.then:                                          ; preds = %for.body
  %7 = load i32, i32* %fail, align 4
  %inc = add nsw i32 %7, 1
  store i32 %inc, i32* %fail, align 4
  br label %if.end

if.end:                                           ; preds = %if.then, %for.body
  br label %for.inc

for.inc:                                          ; preds = %if.end
  %8 = load i32, i32* %i, align 4
  %inc7 = add nsw i32 %8, 1
  store i32 %inc7, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  %9 = load i32, i32* %fail, align 4
  %call8 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([74 x i8], [74 x i8]* @.str.1, i32 0, i32 0), double 5.000000e-02, i32 %9)
  ret void
}

; Function Attrs: nounwind uwtable
define i32 @main(i32 %argc, i8** %argv) #0 {
entry:
  %retval = alloca i32, align 4
  %argc.addr = alloca i32, align 4
  %argv.addr = alloca i8**, align 8
  %n = alloca i32, align 4
  %t_start = alloca double, align 8
  %t_end = alloca double, align 8
  %A = alloca float*, align 8
  %B = alloca float*, align 8
  %x = alloca float*, align 8
  %y = alloca float*, align 8
  %tmp = alloca float*, align 8
  store i32 0, i32* %retval
  store i32 %argc, i32* %argc.addr, align 4
  store i8** %argv, i8*** %argv.addr, align 8
  store i32 2048, i32* %n, align 4
  %call = call noalias i8* @malloc(i64 16777216) #3
  %0 = bitcast i8* %call to float*
  store float* %0, float** %A, align 8
  %call1 = call noalias i8* @malloc(i64 16777216) #3
  %1 = bitcast i8* %call1 to float*
  store float* %1, float** %B, align 8
  %call2 = call noalias i8* @malloc(i64 8192) #3
  %2 = bitcast i8* %call2 to float*
  store float* %2, float** %x, align 8
  %call3 = call noalias i8* @malloc(i64 8192) #3
  %3 = bitcast i8* %call3 to float*
  store float* %3, float** %y, align 8
  %call4 = call noalias i8* @malloc(i64 8192) #3
  %4 = bitcast i8* %call4 to float*
  store float* %4, float** %tmp, align 8
  %5 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %call5 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %5, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @.str.2, i32 0, i32 0))
  %6 = load float*, float** %A, align 8
  %7 = load float*, float** %x, align 8
  call void @init(float* %6, float* %7)
  %call6 = call double @rtclock()
  store double %call6, double* %t_start, align 8
  %8 = load i32, i32* %n, align 4
  %9 = load float*, float** %A, align 8
  %10 = load float*, float** %B, align 8
  %11 = load float*, float** %x, align 8
  %12 = load float*, float** %y, align 8
  %13 = load float*, float** %tmp, align 8
  call void @gesummv(i32 %8, float* %9, float* %10, float* %11, float* %12, float* %13)
  %call7 = call double @rtclock()
  store double %call7, double* %t_end, align 8
  %14 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %15 = load double, double* %t_end, align 8
  %16 = load double, double* %t_start, align 8
  %sub = fsub double %15, %16
  %call8 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %14, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.3, i32 0, i32 0), double %sub)
  %17 = load float*, float** %A, align 8
  %18 = bitcast float* %17 to i8*
  call void @free(i8* %18) #3
  %19 = load float*, float** %B, align 8
  %20 = bitcast float* %19 to i8*
  call void @free(i8* %20) #3
  %21 = load float*, float** %x, align 8
  %22 = bitcast float* %21 to i8*
  call void @free(i8* %22) #3
  %23 = load float*, float** %y, align 8
  %24 = bitcast float* %23 to i8*
  call void @free(i8* %24) #3
  %25 = load float*, float** %tmp, align 8
  %26 = bitcast float* %25 to i8*
  call void @free(i8* %26) #3
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
