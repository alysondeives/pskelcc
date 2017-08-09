; ModuleID = 'gesummv-base.ll'
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
@.str.3 = private unnamed_addr constant [22 x i8] c"GPU Runtime: %0.6lfs\0A\00", align 1
@.str.4 = private unnamed_addr constant [22 x i8] c"CPU Runtime: %0.6lfs\0A\00", align 1

; Function Attrs: nounwind uwtable
define double @rtclock() #0 {
entry:
  %Tzp = alloca %struct.timezone, align 4
  %Tp = alloca %struct.timeval, align 8
  %call = call i32 @gettimeofday(%struct.timeval* %Tp, %struct.timezone* %Tzp) #3
  %cmp = icmp ne i32 %call, 0
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %call1 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([35 x i8], [35 x i8]* @.str, i32 0, i32 0), i32 %call)
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  %tv_sec = getelementptr inbounds %struct.timeval, %struct.timeval* %Tp, i32 0, i32 0
  %tmp = load i64, i64* %tv_sec, align 8
  %conv = sitofp i64 %tmp to double
  %tv_usec = getelementptr inbounds %struct.timeval, %struct.timeval* %Tp, i32 0, i32 1
  %tmp1 = load i64, i64* %tv_usec, align 8
  %conv2 = sitofp i64 %tmp1 to double
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
  %cmp = fcmp olt float %a, 0.000000e+00
  br i1 %cmp, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  %mul = fmul float %a, -1.000000e+00
  br label %return

if.else:                                          ; preds = %entry
  br label %return

return:                                           ; preds = %if.else, %if.then
  %retval.0 = phi float [ %mul, %if.then ], [ %a, %if.else ]
  ret float %retval.0
}

; Function Attrs: nounwind uwtable
define float @percentDiff(double %val1, double %val2) #0 {
entry:
  %conv = fptrunc double %val1 to float
  %call = call float @absVal(float %conv)
  %conv1 = fpext float %call to double
  %cmp = fcmp olt double %conv1, 1.000000e-02
  br i1 %cmp, label %land.lhs.true, label %if.else

land.lhs.true:                                    ; preds = %entry
  %conv3 = fptrunc double %val2 to float
  %call4 = call float @absVal(float %conv3)
  %conv5 = fpext float %call4 to double
  %cmp6 = fcmp olt double %conv5, 1.000000e-02
  br i1 %cmp6, label %if.then, label %if.else

if.then:                                          ; preds = %land.lhs.true
  br label %return

if.else:                                          ; preds = %land.lhs.true, %entry
  %sub = fsub double %val1, %val2
  %conv8 = fptrunc double %sub to float
  %call9 = call float @absVal(float %conv8)
  %add = fadd double %val1, 0x3E45798EE0000000
  %conv10 = fptrunc double %add to float
  %call11 = call float @absVal(float %conv10)
  %div = fdiv float %call9, %call11
  %call12 = call float @absVal(float %div)
  %mul = fmul float 1.000000e+02, %call12
  br label %return

return:                                           ; preds = %if.else, %if.then
  %retval.0 = phi float [ 0.000000e+00, %if.then ], [ %mul, %if.else ]
  ret float %retval.0
}

; Function Attrs: nounwind uwtable
define void @gesummv(float* %A, float* %B, float* %x, float* %y, float* %tmp) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.39, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc40, %for.inc.39 ]
  %cmp = icmp slt i32 %i.0, 8192
  br i1 %cmp, label %for.body, label %for.end.41

for.body:                                         ; preds = %for.cond
  %idxprom = sext i32 %i.0 to i64
  %arrayidx = getelementptr inbounds float, float* %tmp, i64 %idxprom
  store float 0.000000e+00, float* %arrayidx, align 4
  %idxprom3 = sext i32 %i.0 to i64
  %arrayidx4 = getelementptr inbounds float, float* %y, i64 %idxprom3
  store float 0.000000e+00, float* %arrayidx4, align 4
  br label %for.cond.5

for.cond.5:                                       ; preds = %for.inc, %for.body
  %j.0 = phi i32 [ 0, %for.body ], [ %inc, %for.inc ]
  %cmp6 = icmp slt i32 %j.0, 8192
  br i1 %cmp6, label %for.body.7, label %for.end

for.body.7:                                       ; preds = %for.cond.5
  %mul = mul nsw i32 %i.0, 8192
  %add = add nsw i32 %mul, %j.0
  %idxprom8 = sext i32 %add to i64
  %arrayidx9 = getelementptr inbounds float, float* %A, i64 %idxprom8
  %tmp1 = load float, float* %arrayidx9, align 4
  %idxprom10 = sext i32 %j.0 to i64
  %arrayidx11 = getelementptr inbounds float, float* %x, i64 %idxprom10
  %tmp2 = load float, float* %arrayidx11, align 4
  %mul12 = fmul float %tmp1, %tmp2
  %idxprom13 = sext i32 %i.0 to i64
  %arrayidx14 = getelementptr inbounds float, float* %tmp, i64 %idxprom13
  %tmp3 = load float, float* %arrayidx14, align 4
  %add15 = fadd float %mul12, %tmp3
  %idxprom16 = sext i32 %i.0 to i64
  %arrayidx17 = getelementptr inbounds float, float* %tmp, i64 %idxprom16
  store float %add15, float* %arrayidx17, align 4
  %mul18 = mul nsw i32 %i.0, 8192
  %add19 = add nsw i32 %mul18, %j.0
  %idxprom20 = sext i32 %add19 to i64
  %arrayidx21 = getelementptr inbounds float, float* %B, i64 %idxprom20
  %tmp4 = load float, float* %arrayidx21, align 4
  %idxprom22 = sext i32 %j.0 to i64
  %arrayidx23 = getelementptr inbounds float, float* %x, i64 %idxprom22
  %tmp5 = load float, float* %arrayidx23, align 4
  %mul24 = fmul float %tmp4, %tmp5
  %idxprom25 = sext i32 %i.0 to i64
  %arrayidx26 = getelementptr inbounds float, float* %y, i64 %idxprom25
  %tmp6 = load float, float* %arrayidx26, align 4
  %add27 = fadd float %mul24, %tmp6
  %idxprom28 = sext i32 %i.0 to i64
  %arrayidx29 = getelementptr inbounds float, float* %y, i64 %idxprom28
  store float %add27, float* %arrayidx29, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.7
  %inc = add nsw i32 %j.0, 1
  br label %for.cond.5

for.end:                                          ; preds = %for.cond.5
  %idxprom30 = sext i32 %i.0 to i64
  %arrayidx31 = getelementptr inbounds float, float* %tmp, i64 %idxprom30
  %tmp7 = load float, float* %arrayidx31, align 4
  %mul32 = fmul float 4.353200e+04, %tmp7
  %idxprom33 = sext i32 %i.0 to i64
  %arrayidx34 = getelementptr inbounds float, float* %y, i64 %idxprom33
  %tmp8 = load float, float* %arrayidx34, align 4
  %mul35 = fmul float 1.231300e+04, %tmp8
  %add36 = fadd float %mul32, %mul35
  %idxprom37 = sext i32 %i.0 to i64
  %arrayidx38 = getelementptr inbounds float, float* %y, i64 %idxprom37
  store float %add36, float* %arrayidx38, align 4
  br label %for.inc.39

for.inc.39:                                       ; preds = %for.end
  %inc40 = add nsw i32 %i.0, 1
  br label %for.cond

for.end.41:                                       ; preds = %for.cond
  ret void
}

; Function Attrs: nounwind uwtable
define void @GPU__gesummv(float* %A, float* %B, float* %x, float* %y, float* %tmp) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.39, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc40, %for.inc.39 ]
  %cmp = icmp slt i32 %i.0, 8192
  br i1 %cmp, label %for.body, label %for.end.41

for.body:                                         ; preds = %for.cond
  %idxprom = sext i32 %i.0 to i64
  %arrayidx = getelementptr inbounds float, float* %tmp, i64 %idxprom
  store float 0.000000e+00, float* %arrayidx, align 4
  %idxprom3 = sext i32 %i.0 to i64
  %arrayidx4 = getelementptr inbounds float, float* %y, i64 %idxprom3
  store float 0.000000e+00, float* %arrayidx4, align 4
  br label %for.cond.5

for.cond.5:                                       ; preds = %for.inc, %for.body
  %j.0 = phi i32 [ 0, %for.body ], [ %inc, %for.inc ]
  %cmp6 = icmp slt i32 %j.0, 8192
  br i1 %cmp6, label %for.body.7, label %for.end

for.body.7:                                       ; preds = %for.cond.5
  %mul = mul nsw i32 %i.0, 8192
  %add = add nsw i32 %mul, %j.0
  %idxprom8 = sext i32 %add to i64
  %arrayidx9 = getelementptr inbounds float, float* %A, i64 %idxprom8
  %tmp1 = load float, float* %arrayidx9, align 4
  %idxprom10 = sext i32 %j.0 to i64
  %arrayidx11 = getelementptr inbounds float, float* %x, i64 %idxprom10
  %tmp2 = load float, float* %arrayidx11, align 4
  %mul12 = fmul float %tmp1, %tmp2
  %idxprom13 = sext i32 %i.0 to i64
  %arrayidx14 = getelementptr inbounds float, float* %tmp, i64 %idxprom13
  %tmp3 = load float, float* %arrayidx14, align 4
  %add15 = fadd float %mul12, %tmp3
  %idxprom16 = sext i32 %i.0 to i64
  %arrayidx17 = getelementptr inbounds float, float* %tmp, i64 %idxprom16
  store float %add15, float* %arrayidx17, align 4
  %mul18 = mul nsw i32 %i.0, 8192
  %add19 = add nsw i32 %mul18, %j.0
  %idxprom20 = sext i32 %add19 to i64
  %arrayidx21 = getelementptr inbounds float, float* %B, i64 %idxprom20
  %tmp4 = load float, float* %arrayidx21, align 4
  %idxprom22 = sext i32 %j.0 to i64
  %arrayidx23 = getelementptr inbounds float, float* %x, i64 %idxprom22
  %tmp5 = load float, float* %arrayidx23, align 4
  %mul24 = fmul float %tmp4, %tmp5
  %idxprom25 = sext i32 %i.0 to i64
  %arrayidx26 = getelementptr inbounds float, float* %y, i64 %idxprom25
  %tmp6 = load float, float* %arrayidx26, align 4
  %add27 = fadd float %mul24, %tmp6
  %idxprom28 = sext i32 %i.0 to i64
  %arrayidx29 = getelementptr inbounds float, float* %y, i64 %idxprom28
  store float %add27, float* %arrayidx29, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.7
  %inc = add nsw i32 %j.0, 1
  br label %for.cond.5

for.end:                                          ; preds = %for.cond.5
  %idxprom30 = sext i32 %i.0 to i64
  %arrayidx31 = getelementptr inbounds float, float* %tmp, i64 %idxprom30
  %tmp7 = load float, float* %arrayidx31, align 4
  %mul32 = fmul float 4.353200e+04, %tmp7
  %idxprom33 = sext i32 %i.0 to i64
  %arrayidx34 = getelementptr inbounds float, float* %y, i64 %idxprom33
  %tmp8 = load float, float* %arrayidx34, align 4
  %mul35 = fmul float 1.231300e+04, %tmp8
  %add36 = fadd float %mul32, %mul35
  %idxprom37 = sext i32 %i.0 to i64
  %arrayidx38 = getelementptr inbounds float, float* %y, i64 %idxprom37
  store float %add36, float* %arrayidx38, align 4
  br label %for.inc.39

for.inc.39:                                       ; preds = %for.end
  %inc40 = add nsw i32 %i.0, 1
  br label %for.cond

for.end.41:                                       ; preds = %for.cond
  ret void
}

; Function Attrs: nounwind uwtable
define void @init(float* %A, float* %x) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.11, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc12, %for.inc.11 ]
  %cmp = icmp slt i32 %i.0, 8192
  br i1 %cmp, label %for.body, label %for.end.13

for.body:                                         ; preds = %for.cond
  %conv = sitofp i32 %i.0 to float
  %div = fdiv float %conv, 8.192000e+03
  %idxprom = sext i32 %i.0 to i64
  %arrayidx = getelementptr inbounds float, float* %x, i64 %idxprom
  store float %div, float* %arrayidx, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %j.0 = phi i32 [ 0, %for.body ], [ %inc, %for.inc ]
  %cmp2 = icmp slt i32 %j.0, 8192
  br i1 %cmp2, label %for.body.4, label %for.end

for.body.4:                                       ; preds = %for.cond.1
  %conv5 = sitofp i32 %i.0 to float
  %conv6 = sitofp i32 %j.0 to float
  %mul = fmul float %conv5, %conv6
  %div7 = fdiv float %mul, 8.192000e+03
  %mul8 = mul nsw i32 %i.0, 8192
  %add = add nsw i32 %mul8, %j.0
  %idxprom9 = sext i32 %add to i64
  %arrayidx10 = getelementptr inbounds float, float* %A, i64 %idxprom9
  store float %div7, float* %arrayidx10, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.4
  %inc = add nsw i32 %j.0, 1
  br label %for.cond.1

for.end:                                          ; preds = %for.cond.1
  br label %for.inc.11

for.inc.11:                                       ; preds = %for.end
  %inc12 = add nsw i32 %i.0, 1
  br label %for.cond

for.end.13:                                       ; preds = %for.cond
  ret void
}

; Function Attrs: nounwind uwtable
define void @compareResults(float* %y, float* %y_outputFromGpu) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc7, %for.inc ]
  %fail.0 = phi i32 [ 0, %entry ], [ %fail.1, %for.inc ]
  %cmp = icmp slt i32 %i.0, 8192
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %idxprom = sext i32 %i.0 to i64
  %arrayidx = getelementptr inbounds float, float* %y, i64 %idxprom
  %tmp = load float, float* %arrayidx, align 4
  %conv = fpext float %tmp to double
  %idxprom1 = sext i32 %i.0 to i64
  %arrayidx2 = getelementptr inbounds float, float* %y_outputFromGpu, i64 %idxprom1
  %tmp1 = load float, float* %arrayidx2, align 4
  %conv3 = fpext float %tmp1 to double
  %call = call float @percentDiff(double %conv, double %conv3)
  %conv4 = fpext float %call to double
  %cmp5 = fcmp ogt double %conv4, 5.000000e-02
  br i1 %cmp5, label %if.then, label %if.end

if.then:                                          ; preds = %for.body
  %inc = add nsw i32 %fail.0, 1
  br label %if.end

if.end:                                           ; preds = %if.then, %for.body
  %fail.1 = phi i32 [ %inc, %if.then ], [ %fail.0, %for.body ]
  br label %for.inc

for.inc:                                          ; preds = %if.end
  %inc7 = add nsw i32 %i.0, 1
  br label %for.cond

for.end:                                          ; preds = %for.cond
  %call8 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([74 x i8], [74 x i8]* @.str.1, i32 0, i32 0), double 5.000000e-02, i32 %fail.0)
  ret void
}

; Function Attrs: nounwind uwtable
define i32 @main(i32 %argc, i8** %argv) #0 {
entry:
  %call = call noalias i8* @malloc(i64 268435456) #3
  %tmp = bitcast i8* %call to float*
  %call1 = call noalias i8* @malloc(i64 268435456) #3
  %tmp1 = bitcast i8* %call1 to float*
  %call2 = call noalias i8* @malloc(i64 32768) #3
  %tmp2 = bitcast i8* %call2 to float*
  %call3 = call noalias i8* @malloc(i64 32768) #3
  %tmp3 = bitcast i8* %call3 to float*
  %call4 = call noalias i8* @malloc(i64 32768) #3
  %tmp4 = bitcast i8* %call4 to float*
  %call5 = call noalias i8* @malloc(i64 32768) #3
  %tmp5 = bitcast i8* %call5 to float*
  %tmp6 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %call6 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %tmp6, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @.str.2, i32 0, i32 0))
  call void @init(float* %tmp, float* %tmp2)
  %call7 = call double @rtclock()
  call void @GPU__gesummv(float* %tmp, float* %tmp1, float* %tmp2, float* %tmp4, float* %tmp5)
  %call8 = call double @rtclock()
  %tmp7 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %sub = fsub double %call8, %call7
  %call9 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %tmp7, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.3, i32 0, i32 0), double %sub)
  %call10 = call double @rtclock()
  call void @gesummv(float* %tmp, float* %tmp1, float* %tmp2, float* %tmp3, float* %tmp5)
  %call11 = call double @rtclock()
  %tmp8 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %sub12 = fsub double %call11, %call10
  %call13 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %tmp8, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.4, i32 0, i32 0), double %sub12)
  call void @compareResults(float* %tmp3, float* %tmp4)
  %tmp9 = bitcast float* %tmp to i8*
  call void @free(i8* %tmp9) #3
  %tmp10 = bitcast float* %tmp1 to i8*
  call void @free(i8* %tmp10) #3
  %tmp11 = bitcast float* %tmp2 to i8*
  call void @free(i8* %tmp11) #3
  %tmp12 = bitcast float* %tmp3 to i8*
  call void @free(i8* %tmp12) #3
  %tmp13 = bitcast float* %tmp4 to i8*
  call void @free(i8* %tmp13) #3
  %tmp14 = bitcast float* %tmp5 to i8*
  call void @free(i8* %tmp14) #3
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
