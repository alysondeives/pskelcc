; ModuleID = 'jacobi2d.c'
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
define void @init_array(i32 %n, float* %A, float* %B) #0 {
entry:
  %n.addr = alloca i32, align 4
  %A.addr = alloca float*, align 8
  %B.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  store i32 %n, i32* %n.addr, align 4
  store float* %A, float** %A.addr, align 8
  store float* %B, float** %B.addr, align 8
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.20, %entry
  %0 = load i32, i32* %i, align 4
  %1 = load i32, i32* %n.addr, align 4
  %cmp = icmp slt i32 %0, %1
  br i1 %cmp, label %for.body, label %for.end.22

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
  %conv = sitofp i32 %4 to float
  %5 = load i32, i32* %j, align 4
  %add = add nsw i32 %5, 2
  %conv4 = sitofp i32 %add to float
  %mul = fmul float %conv, %conv4
  %add5 = fadd float %mul, 2.000000e+00
  %6 = load i32, i32* %n.addr, align 4
  %conv6 = sitofp i32 %6 to float
  %div = fdiv float %add5, %conv6
  %7 = load i32, i32* %i, align 4
  %8 = load i32, i32* %n.addr, align 4
  %mul7 = mul nsw i32 %7, %8
  %9 = load i32, i32* %j, align 4
  %add8 = add nsw i32 %mul7, %9
  %idxprom = sext i32 %add8 to i64
  %10 = load float*, float** %A.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %10, i64 %idxprom
  store float %div, float* %arrayidx, align 4
  %11 = load i32, i32* %i, align 4
  %conv9 = sitofp i32 %11 to float
  %12 = load i32, i32* %j, align 4
  %add10 = add nsw i32 %12, 3
  %conv11 = sitofp i32 %add10 to float
  %mul12 = fmul float %conv9, %conv11
  %add13 = fadd float %mul12, 3.000000e+00
  %13 = load i32, i32* %n.addr, align 4
  %conv14 = sitofp i32 %13 to float
  %div15 = fdiv float %add13, %conv14
  %14 = load i32, i32* %i, align 4
  %15 = load i32, i32* %n.addr, align 4
  %mul16 = mul nsw i32 %14, %15
  %16 = load i32, i32* %j, align 4
  %add17 = add nsw i32 %mul16, %16
  %idxprom18 = sext i32 %add17 to i64
  %17 = load float*, float** %B.addr, align 8
  %arrayidx19 = getelementptr inbounds float, float* %17, i64 %idxprom18
  store float %div15, float* %arrayidx19, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.3
  %18 = load i32, i32* %j, align 4
  %inc = add nsw i32 %18, 1
  store i32 %inc, i32* %j, align 4
  br label %for.cond.1

for.end:                                          ; preds = %for.cond.1
  br label %for.inc.20

for.inc.20:                                       ; preds = %for.end
  %19 = load i32, i32* %i, align 4
  %inc21 = add nsw i32 %19, 1
  store i32 %inc21, i32* %i, align 4
  br label %for.cond

for.end.22:                                       ; preds = %for.cond
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
  %A = alloca float*, align 8
  %B = alloca float*, align 8
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
  %2 = bitcast i8* %call to float*
  store float* %2, float** %A, align 8
  %3 = load i32, i32* %n, align 4
  %4 = load i32, i32* %n, align 4
  %mul2 = mul nsw i32 %3, %4
  %conv3 = sext i32 %mul2 to i64
  %mul4 = mul i64 %conv3, 4
  %call5 = call noalias i8* @malloc(i64 %mul4) #3
  %5 = bitcast i8* %call5 to float*
  store float* %5, float** %B, align 8
  %6 = load i32, i32* %n, align 4
  %7 = load float*, float** %A, align 8
  %8 = load float*, float** %B, align 8
  call void @init_array(i32 %6, float* %7, float* %8)
  %call6 = call double @rtclock()
  store double %call6, double* %t_start, align 8
  %9 = load i32, i32* %tsteps, align 4
  %10 = load i32, i32* %n, align 4
  %11 = load float*, float** %A, align 8
  %12 = load float*, float** %B, align 8
  call void @jacobi2d(i32 %9, i32 %10, float* %11, float* %12)
  %call7 = call double @rtclock()
  store double %call7, double* %t_end, align 8
  %13 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %14 = load double, double* %t_end, align 8
  %15 = load double, double* %t_start, align 8
  %sub = fsub double %14, %15
  %call8 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %13, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.1, i32 0, i32 0), double %sub)
  %16 = load float*, float** %A, align 8
  %17 = bitcast float* %16 to i8*
  call void @free(i8* %17) #3
  %18 = load float*, float** %B, align 8
  %19 = bitcast float* %18 to i8*
  call void @free(i8* %19) #3
  ret i32 0
}

; Function Attrs: nounwind
declare noalias i8* @malloc(i64) #1

; Function Attrs: nounwind uwtable
define internal void @jacobi2d(i32 %tsteps, i32 %n, float* %A, float* %B) #0 {
entry:
  %tsteps.addr = alloca i32, align 4
  %n.addr = alloca i32, align 4
  %A.addr = alloca float*, align 8
  %B.addr = alloca float*, align 8
  %t = alloca i32, align 4
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %c1 = alloca float, align 4
  store i32 %tsteps, i32* %tsteps.addr, align 4
  store i32 %n, i32* %n.addr, align 4
  store float* %A, float** %A.addr, align 8
  store float* %B, float** %B.addr, align 8
  store float 0x3FC99999A0000000, float* %c1, align 4
  store i32 0, i32* %t, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.62, %entry
  %0 = load i32, i32* %t, align 4
  %1 = load i32, i32* %tsteps.addr, align 4
  %cmp = icmp slt i32 %0, %1
  br i1 %cmp, label %for.body, label %for.end.64

for.body:                                         ; preds = %for.cond
  store i32 1, i32* %i, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc.37, %for.body
  %2 = load i32, i32* %i, align 4
  %3 = load i32, i32* %n.addr, align 4
  %sub = sub nsw i32 %3, 1
  %cmp2 = icmp slt i32 %2, %sub
  br i1 %cmp2, label %for.body.3, label %for.end.39

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
  %6 = load float, float* %c1, align 4
  %7 = load i32, i32* %i, align 4
  %8 = load i32, i32* %n.addr, align 4
  %mul = mul nsw i32 %7, %8
  %9 = load i32, i32* %j, align 4
  %add = add nsw i32 %mul, %9
  %idxprom = sext i32 %add to i64
  %10 = load float*, float** %A.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %10, i64 %idxprom
  %11 = load float, float* %arrayidx, align 4
  %12 = load i32, i32* %i, align 4
  %13 = load i32, i32* %n.addr, align 4
  %mul8 = mul nsw i32 %12, %13
  %14 = load i32, i32* %j, align 4
  %sub9 = sub nsw i32 %14, 1
  %add10 = add nsw i32 %mul8, %sub9
  %idxprom11 = sext i32 %add10 to i64
  %15 = load float*, float** %A.addr, align 8
  %arrayidx12 = getelementptr inbounds float, float* %15, i64 %idxprom11
  %16 = load float, float* %arrayidx12, align 4
  %add13 = fadd float %11, %16
  %17 = load i32, i32* %i, align 4
  %18 = load i32, i32* %n.addr, align 4
  %mul14 = mul nsw i32 %17, %18
  %19 = load i32, i32* %j, align 4
  %add15 = add nsw i32 %19, 1
  %add16 = add nsw i32 %mul14, %add15
  %idxprom17 = sext i32 %add16 to i64
  %20 = load float*, float** %A.addr, align 8
  %arrayidx18 = getelementptr inbounds float, float* %20, i64 %idxprom17
  %21 = load float, float* %arrayidx18, align 4
  %add19 = fadd float %add13, %21
  %22 = load i32, i32* %i, align 4
  %add20 = add nsw i32 %22, 1
  %23 = load i32, i32* %n.addr, align 4
  %mul21 = mul nsw i32 %add20, %23
  %24 = load i32, i32* %j, align 4
  %add22 = add nsw i32 %mul21, %24
  %idxprom23 = sext i32 %add22 to i64
  %25 = load float*, float** %A.addr, align 8
  %arrayidx24 = getelementptr inbounds float, float* %25, i64 %idxprom23
  %26 = load float, float* %arrayidx24, align 4
  %add25 = fadd float %add19, %26
  %27 = load i32, i32* %i, align 4
  %sub26 = sub nsw i32 %27, 1
  %28 = load i32, i32* %n.addr, align 4
  %mul27 = mul nsw i32 %sub26, %28
  %29 = load i32, i32* %j, align 4
  %add28 = add nsw i32 %mul27, %29
  %idxprom29 = sext i32 %add28 to i64
  %30 = load float*, float** %A.addr, align 8
  %arrayidx30 = getelementptr inbounds float, float* %30, i64 %idxprom29
  %31 = load float, float* %arrayidx30, align 4
  %add31 = fadd float %add25, %31
  %mul32 = fmul float %6, %add31
  %32 = load i32, i32* %i, align 4
  %33 = load i32, i32* %n.addr, align 4
  %mul33 = mul nsw i32 %32, %33
  %34 = load i32, i32* %j, align 4
  %add34 = add nsw i32 %mul33, %34
  %idxprom35 = sext i32 %add34 to i64
  %35 = load float*, float** %B.addr, align 8
  %arrayidx36 = getelementptr inbounds float, float* %35, i64 %idxprom35
  store float %mul32, float* %arrayidx36, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.7
  %36 = load i32, i32* %j, align 4
  %inc = add nsw i32 %36, 1
  store i32 %inc, i32* %j, align 4
  br label %for.cond.4

for.end:                                          ; preds = %for.cond.4
  br label %for.inc.37

for.inc.37:                                       ; preds = %for.end
  %37 = load i32, i32* %i, align 4
  %inc38 = add nsw i32 %37, 1
  store i32 %inc38, i32* %i, align 4
  br label %for.cond.1

for.end.39:                                       ; preds = %for.cond.1
  store i32 1, i32* %i, align 4
  br label %for.cond.40

for.cond.40:                                      ; preds = %for.inc.59, %for.end.39
  %38 = load i32, i32* %i, align 4
  %39 = load i32, i32* %n.addr, align 4
  %sub41 = sub nsw i32 %39, 1
  %cmp42 = icmp slt i32 %38, %sub41
  br i1 %cmp42, label %for.body.43, label %for.end.61

for.body.43:                                      ; preds = %for.cond.40
  store i32 1, i32* %j, align 4
  br label %for.cond.44

for.cond.44:                                      ; preds = %for.inc.56, %for.body.43
  %40 = load i32, i32* %j, align 4
  %41 = load i32, i32* %n.addr, align 4
  %sub45 = sub nsw i32 %41, 1
  %cmp46 = icmp slt i32 %40, %sub45
  br i1 %cmp46, label %for.body.47, label %for.end.58

for.body.47:                                      ; preds = %for.cond.44
  %42 = load i32, i32* %i, align 4
  %43 = load i32, i32* %n.addr, align 4
  %mul48 = mul nsw i32 %42, %43
  %44 = load i32, i32* %j, align 4
  %add49 = add nsw i32 %mul48, %44
  %idxprom50 = sext i32 %add49 to i64
  %45 = load float*, float** %B.addr, align 8
  %arrayidx51 = getelementptr inbounds float, float* %45, i64 %idxprom50
  %46 = load float, float* %arrayidx51, align 4
  %47 = load i32, i32* %i, align 4
  %48 = load i32, i32* %n.addr, align 4
  %mul52 = mul nsw i32 %47, %48
  %49 = load i32, i32* %j, align 4
  %add53 = add nsw i32 %mul52, %49
  %idxprom54 = sext i32 %add53 to i64
  %50 = load float*, float** %A.addr, align 8
  %arrayidx55 = getelementptr inbounds float, float* %50, i64 %idxprom54
  store float %46, float* %arrayidx55, align 4
  br label %for.inc.56

for.inc.56:                                       ; preds = %for.body.47
  %51 = load i32, i32* %j, align 4
  %inc57 = add nsw i32 %51, 1
  store i32 %inc57, i32* %j, align 4
  br label %for.cond.44

for.end.58:                                       ; preds = %for.cond.44
  br label %for.inc.59

for.inc.59:                                       ; preds = %for.end.58
  %52 = load i32, i32* %i, align 4
  %inc60 = add nsw i32 %52, 1
  store i32 %inc60, i32* %i, align 4
  br label %for.cond.40

for.end.61:                                       ; preds = %for.cond.40
  br label %for.inc.62

for.inc.62:                                       ; preds = %for.end.61
  %53 = load i32, i32* %t, align 4
  %inc63 = add nsw i32 %53, 1
  store i32 %inc63, i32* %t, align 4
  br label %for.cond

for.end.64:                                       ; preds = %for.cond
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
