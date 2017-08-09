; ModuleID = 'conv-2d-base.ll'
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
define void @conv2D(i32 %ni, i32 %nj, float* %A, float* %B) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.70, %entry
  %i.0 = phi i32 [ 1, %entry ], [ %inc71, %for.inc.70 ]
  %sub = sub nsw i32 %ni, 1
  %cmp = icmp slt i32 %i.0, %sub
  br i1 %cmp, label %for.body, label %for.end.72

for.body:                                         ; preds = %for.cond
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %j.0 = phi i32 [ 1, %for.body ], [ %inc, %for.inc ]
  %sub2 = sub nsw i32 %nj, 1
  %cmp3 = icmp slt i32 %j.0, %sub2
  br i1 %cmp3, label %for.body.4, label %for.end

for.body.4:                                       ; preds = %for.cond.1
  %sub5 = sub nsw i32 %i.0, 1
  %mul = mul nsw i32 %sub5, %nj
  %sub6 = sub nsw i32 %j.0, 1
  %add = add nsw i32 %mul, %sub6
  %idxprom = sext i32 %add to i64
  %arrayidx = getelementptr inbounds float, float* %A, i64 %idxprom
  %tmp = load float, float* %arrayidx, align 4
  %mul7 = fmul float 0x3FC99999A0000000, %tmp
  %mul8 = mul nsw i32 %i.0, %nj
  %sub9 = sub nsw i32 %j.0, 1
  %add10 = add nsw i32 %mul8, %sub9
  %idxprom11 = sext i32 %add10 to i64
  %arrayidx12 = getelementptr inbounds float, float* %A, i64 %idxprom11
  %tmp1 = load float, float* %arrayidx12, align 4
  %mul13 = fmul float 0xBFD3333340000000, %tmp1
  %add14 = fadd float %mul7, %mul13
  %add15 = add nsw i32 %i.0, 1
  %mul16 = mul nsw i32 %add15, %nj
  %sub17 = sub nsw i32 %j.0, 1
  %add18 = add nsw i32 %mul16, %sub17
  %idxprom19 = sext i32 %add18 to i64
  %arrayidx20 = getelementptr inbounds float, float* %A, i64 %idxprom19
  %tmp2 = load float, float* %arrayidx20, align 4
  %mul21 = fmul float 0x3FD99999A0000000, %tmp2
  %add22 = fadd float %add14, %mul21
  %sub23 = sub nsw i32 %i.0, 1
  %mul24 = mul nsw i32 %sub23, %nj
  %add25 = add nsw i32 %mul24, %j.0
  %idxprom26 = sext i32 %add25 to i64
  %arrayidx27 = getelementptr inbounds float, float* %A, i64 %idxprom26
  %tmp3 = load float, float* %arrayidx27, align 4
  %mul28 = fmul float 5.000000e-01, %tmp3
  %add29 = fadd float %add22, %mul28
  %mul30 = mul nsw i32 %i.0, %nj
  %add31 = add nsw i32 %mul30, %j.0
  %idxprom32 = sext i32 %add31 to i64
  %arrayidx33 = getelementptr inbounds float, float* %A, i64 %idxprom32
  %tmp4 = load float, float* %arrayidx33, align 4
  %mul34 = fmul float 0x3FE3333340000000, %tmp4
  %add35 = fadd float %add29, %mul34
  %add36 = add nsw i32 %i.0, 1
  %mul37 = mul nsw i32 %add36, %nj
  %add38 = add nsw i32 %mul37, %j.0
  %idxprom39 = sext i32 %add38 to i64
  %arrayidx40 = getelementptr inbounds float, float* %A, i64 %idxprom39
  %tmp5 = load float, float* %arrayidx40, align 4
  %mul41 = fmul float 0x3FE6666660000000, %tmp5
  %add42 = fadd float %add35, %mul41
  %sub43 = sub nsw i32 %i.0, 1
  %mul44 = mul nsw i32 %sub43, %nj
  %add45 = add nsw i32 %j.0, 1
  %add46 = add nsw i32 %mul44, %add45
  %idxprom47 = sext i32 %add46 to i64
  %arrayidx48 = getelementptr inbounds float, float* %A, i64 %idxprom47
  %tmp6 = load float, float* %arrayidx48, align 4
  %mul49 = fmul float 0xBFE99999A0000000, %tmp6
  %add50 = fadd float %add42, %mul49
  %mul51 = mul nsw i32 %i.0, %nj
  %add52 = add nsw i32 %j.0, 1
  %add53 = add nsw i32 %mul51, %add52
  %idxprom54 = sext i32 %add53 to i64
  %arrayidx55 = getelementptr inbounds float, float* %A, i64 %idxprom54
  %tmp7 = load float, float* %arrayidx55, align 4
  %mul56 = fmul float 0xBFECCCCCC0000000, %tmp7
  %add57 = fadd float %add50, %mul56
  %add58 = add nsw i32 %i.0, 1
  %mul59 = mul nsw i32 %add58, %nj
  %add60 = add nsw i32 %j.0, 1
  %add61 = add nsw i32 %mul59, %add60
  %idxprom62 = sext i32 %add61 to i64
  %arrayidx63 = getelementptr inbounds float, float* %A, i64 %idxprom62
  %tmp8 = load float, float* %arrayidx63, align 4
  %mul64 = fmul float 0x3FB99999A0000000, %tmp8
  %add65 = fadd float %add57, %mul64
  %mul66 = mul nsw i32 %i.0, %nj
  %add67 = add nsw i32 %mul66, %j.0
  %idxprom68 = sext i32 %add67 to i64
  %arrayidx69 = getelementptr inbounds float, float* %B, i64 %idxprom68
  store float %add65, float* %arrayidx69, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.4
  %inc = add nsw i32 %j.0, 1
  br label %for.cond.1

for.end:                                          ; preds = %for.cond.1
  br label %for.inc.70

for.inc.70:                                       ; preds = %for.end
  %inc71 = add nsw i32 %i.0, 1
  br label %for.cond

for.end.72:                                       ; preds = %for.cond
  ret void
}

; Function Attrs: nounwind uwtable
define void @init(i32 %ni, i32 %nj, float* %A) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.4, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc5, %for.inc.4 ]
  %cmp = icmp slt i32 %i.0, %ni
  br i1 %cmp, label %for.body, label %for.end.6

for.body:                                         ; preds = %for.cond
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %j.0 = phi i32 [ 0, %for.body ], [ %inc, %for.inc ]
  %cmp2 = icmp slt i32 %j.0, %nj
  br i1 %cmp2, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.cond.1
  %call = call i32 @rand() #3
  %conv = sitofp i32 %call to float
  %div = fdiv float %conv, 0x41E0000000000000
  %mul = mul nsw i32 %i.0, %nj
  %add = add nsw i32 %mul, %j.0
  %idxprom = sext i32 %add to i64
  %arrayidx = getelementptr inbounds float, float* %A, i64 %idxprom
  store float %div, float* %arrayidx, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.3
  %inc = add nsw i32 %j.0, 1
  br label %for.cond.1

for.end:                                          ; preds = %for.cond.1
  br label %for.inc.4

for.inc.4:                                        ; preds = %for.end
  %inc5 = add nsw i32 %i.0, 1
  br label %for.cond

for.end.6:                                        ; preds = %for.cond
  ret void
}

; Function Attrs: nounwind
declare i32 @rand() #1

; Function Attrs: nounwind uwtable
define void @compareResults(float* %B, float* %B_GPU) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.13, %entry
  %i.0 = phi i32 [ 1, %entry ], [ %inc14, %for.inc.13 ]
  %fail.0 = phi i32 [ 0, %entry ], [ %fail.1, %for.inc.13 ]
  %cmp = icmp slt i32 %i.0, 4095
  br i1 %cmp, label %for.body, label %for.end.15

for.body:                                         ; preds = %for.cond
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %j.0 = phi i32 [ 1, %for.body ], [ %inc12, %for.inc ]
  %fail.1 = phi i32 [ %fail.0, %for.body ], [ %fail.2, %for.inc ]
  %cmp2 = icmp slt i32 %j.0, 4095
  br i1 %cmp2, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.cond.1
  %mul = mul nsw i32 %i.0, 4096
  %add = add nsw i32 %mul, %j.0
  %idxprom = sext i32 %add to i64
  %arrayidx = getelementptr inbounds float, float* %B, i64 %idxprom
  %tmp = load float, float* %arrayidx, align 4
  %conv = fpext float %tmp to double
  %mul4 = mul nsw i32 %i.0, 4096
  %add5 = add nsw i32 %mul4, %j.0
  %idxprom6 = sext i32 %add5 to i64
  %arrayidx7 = getelementptr inbounds float, float* %B_GPU, i64 %idxprom6
  %tmp1 = load float, float* %arrayidx7, align 4
  %conv8 = fpext float %tmp1 to double
  %call = call float @percentDiff(double %conv, double %conv8)
  %conv9 = fpext float %call to double
  %cmp10 = fcmp ogt double %conv9, 5.000000e-02
  br i1 %cmp10, label %if.then, label %if.end

if.then:                                          ; preds = %for.body.3
  %inc = add nsw i32 %fail.1, 1
  br label %if.end

if.end:                                           ; preds = %if.then, %for.body.3
  %fail.2 = phi i32 [ %inc, %if.then ], [ %fail.1, %for.body.3 ]
  br label %for.inc

for.inc:                                          ; preds = %if.end
  %inc12 = add nsw i32 %j.0, 1
  br label %for.cond.1

for.end:                                          ; preds = %for.cond.1
  br label %for.inc.13

for.inc.13:                                       ; preds = %for.end
  %inc14 = add nsw i32 %i.0, 1
  br label %for.cond

for.end.15:                                       ; preds = %for.cond
  %call16 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([74 x i8], [74 x i8]* @.str.1, i32 0, i32 0), double 5.000000e-02, i32 %fail.0)
  ret void
}

; Function Attrs: nounwind uwtable
define i32 @main(i32 %argc, i8** %argv) #0 {
entry:
  %mul = mul nsw i32 4096, 4096
  %conv = sext i32 %mul to i64
  %mul1 = mul i64 %conv, 4
  %call = call noalias i8* @malloc(i64 %mul1) #3
  %tmp = bitcast i8* %call to float*
  %mul2 = mul nsw i32 4096, 4096
  %conv3 = sext i32 %mul2 to i64
  %mul4 = mul i64 %conv3, 4
  %call5 = call noalias i8* @malloc(i64 %mul4) #3
  %tmp1 = bitcast i8* %call5 to float*
  %tmp2 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %call6 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %tmp2, i8* getelementptr inbounds ([40 x i8], [40 x i8]* @.str.2, i32 0, i32 0))
  call void @init(i32 4096, i32 4096, float* %tmp)
  %call7 = call double @rtclock()
  call void @conv2D(i32 4096, i32 4096, float* %tmp, float* %tmp1)
  %call8 = call double @rtclock()
  %tmp3 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %sub = fsub double %call8, %call7
  %call9 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %tmp3, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.3, i32 0, i32 0), double %sub)
  %tmp4 = bitcast float* %tmp to i8*
  call void @free(i8* %tmp4) #3
  %tmp5 = bitcast float* %tmp1 to i8*
  call void @free(i8* %tmp5) #3
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
