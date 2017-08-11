; ModuleID = 'atax-base.ll'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, i8*, i8*, i8*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type { %struct._IO_marker*, %struct._IO_FILE*, i32 }
%struct.timezone = type { i32, i32 }
%struct.timeval = type { i64, i64 }

@.str = private unnamed_addr constant [35 x i8] c"Error return from gettimeofday: %d\00", align 1
@.str.1 = private unnamed_addr constant [74 x i8] c"Non-Matching CPU-GPU Outputs Beyond Error Threshold of %4.2f Percent: %d\0A\00", align 1
@stdout = external global %struct._IO_FILE*, align 8
@.str.2 = private unnamed_addr constant [50 x i8] c"<< Matrix Transpose and Vector Multiplication >>\0A\00", align 1
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
define void @init_array(float* %x, float* %A) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.12, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc13, %for.inc.12 ]
  %cmp = icmp slt i32 %i.0, 4096
  br i1 %cmp, label %for.body, label %for.end.14

for.body:                                         ; preds = %for.cond
  %conv = sitofp i32 %i.0 to double
  %mul = fmul double %conv, 0x400921FB54442D18
  %conv1 = fptrunc double %mul to float
  %idxprom = sext i32 %i.0 to i64
  %arrayidx = getelementptr inbounds float, float* %x, i64 %idxprom
  store float %conv1, float* %arrayidx, align 4
  br label %for.cond.2

for.cond.2:                                       ; preds = %for.inc, %for.body
  %j.0 = phi i32 [ 0, %for.body ], [ %inc, %for.inc ]
  %cmp3 = icmp slt i32 %j.0, 4096
  br i1 %cmp3, label %for.body.5, label %for.end

for.body.5:                                       ; preds = %for.cond.2
  %conv6 = sitofp i32 %i.0 to float
  %conv7 = sitofp i32 %j.0 to float
  %mul8 = fmul float %conv6, %conv7
  %div = fdiv float %mul8, 4.096000e+03
  %mul9 = mul nsw i32 %i.0, 4096
  %add = add nsw i32 %mul9, %j.0
  %idxprom10 = sext i32 %add to i64
  %arrayidx11 = getelementptr inbounds float, float* %A, i64 %idxprom10
  store float %div, float* %arrayidx11, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.5
  %inc = add nsw i32 %j.0, 1
  br label %for.cond.2

for.end:                                          ; preds = %for.cond.2
  br label %for.inc.12

for.inc.12:                                       ; preds = %for.end
  %inc13 = add nsw i32 %i.0, 1
  br label %for.cond

for.end.14:                                       ; preds = %for.cond
  ret void
}

; Function Attrs: nounwind uwtable
define void @compareResults(float* %z, float* %z_outputFromGpu) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc7, %for.inc ]
  %fail.0 = phi i32 [ 0, %entry ], [ %fail.1, %for.inc ]
  %cmp = icmp slt i32 %i.0, 4096
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %idxprom = sext i32 %i.0 to i64
  %arrayidx = getelementptr inbounds float, float* %z, i64 %idxprom
  %tmp = load float, float* %arrayidx, align 4
  %conv = fpext float %tmp to double
  %idxprom1 = sext i32 %i.0 to i64
  %arrayidx2 = getelementptr inbounds float, float* %z_outputFromGpu, i64 %idxprom1
  %tmp1 = load float, float* %arrayidx2, align 4
  %conv3 = fpext float %tmp1 to double
  %call = call float @percentDiff(double %conv, double %conv3)
  %conv4 = fpext float %call to double
  %cmp5 = fcmp ogt double %conv4, 5.000000e-01
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
  %call8 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([74 x i8], [74 x i8]* @.str.1, i32 0, i32 0), double 5.000000e-01, i32 %fail.0)
  ret void
}

; Function Attrs: nounwind uwtable
define void @atax_cpu(i32 %nx, i32 %ny, float* %A, float* %x, float* %y, float* %tmp) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc, %for.inc ]
  %cmp = icmp slt i32 %i.0, %ny
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %idxprom = sext i32 %i.0 to i64
  %arrayidx = getelementptr inbounds float, float* %y, i64 %idxprom
  store float 0.000000e+00, float* %arrayidx, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %inc = add nsw i32 %i.0, 1
  br label %for.cond

for.end:                                          ; preds = %for.cond
  br label %for.cond.3

for.cond.3:                                       ; preds = %for.inc.42, %for.end
  %i.1 = phi i32 [ 0, %for.end ], [ %inc43, %for.inc.42 ]
  %cmp4 = icmp slt i32 %i.1, %nx
  br i1 %cmp4, label %for.body.5, label %for.end.44

for.body.5:                                       ; preds = %for.cond.3
  %idxprom6 = sext i32 %i.1 to i64
  %arrayidx7 = getelementptr inbounds float, float* %tmp, i64 %idxprom6
  store float 0.000000e+00, float* %arrayidx7, align 4
  br label %for.cond.8

for.cond.8:                                       ; preds = %for.inc.21, %for.body.5
  %j.0 = phi i32 [ 0, %for.body.5 ], [ %inc22, %for.inc.21 ]
  %cmp9 = icmp slt i32 %j.0, %ny
  br i1 %cmp9, label %for.body.10, label %for.end.23

for.body.10:                                      ; preds = %for.cond.8
  %idxprom11 = sext i32 %i.1 to i64
  %arrayidx12 = getelementptr inbounds float, float* %tmp, i64 %idxprom11
  %tmp1 = load float, float* %arrayidx12, align 4
  %mul = mul nsw i32 %i.1, %ny
  %add = add nsw i32 %mul, %j.0
  %idxprom13 = sext i32 %add to i64
  %arrayidx14 = getelementptr inbounds float, float* %A, i64 %idxprom13
  %tmp2 = load float, float* %arrayidx14, align 4
  %idxprom15 = sext i32 %j.0 to i64
  %arrayidx16 = getelementptr inbounds float, float* %x, i64 %idxprom15
  %tmp3 = load float, float* %arrayidx16, align 4
  %mul17 = fmul float %tmp2, %tmp3
  %add18 = fadd float %tmp1, %mul17
  %idxprom19 = sext i32 %i.1 to i64
  %arrayidx20 = getelementptr inbounds float, float* %tmp, i64 %idxprom19
  store float %add18, float* %arrayidx20, align 4
  br label %for.inc.21

for.inc.21:                                       ; preds = %for.body.10
  %inc22 = add nsw i32 %j.0, 1
  br label %for.cond.8

for.end.23:                                       ; preds = %for.cond.8
  br label %for.cond.24

for.cond.24:                                      ; preds = %for.inc.39, %for.end.23
  %j.1 = phi i32 [ 0, %for.end.23 ], [ %inc40, %for.inc.39 ]
  %cmp25 = icmp slt i32 %j.1, %ny
  br i1 %cmp25, label %for.body.26, label %for.end.41

for.body.26:                                      ; preds = %for.cond.24
  %idxprom27 = sext i32 %j.1 to i64
  %arrayidx28 = getelementptr inbounds float, float* %y, i64 %idxprom27
  %tmp4 = load float, float* %arrayidx28, align 4
  %mul29 = mul nsw i32 %i.1, %ny
  %add30 = add nsw i32 %mul29, %j.1
  %idxprom31 = sext i32 %add30 to i64
  %arrayidx32 = getelementptr inbounds float, float* %A, i64 %idxprom31
  %tmp5 = load float, float* %arrayidx32, align 4
  %idxprom33 = sext i32 %i.1 to i64
  %arrayidx34 = getelementptr inbounds float, float* %tmp, i64 %idxprom33
  %tmp6 = load float, float* %arrayidx34, align 4
  %mul35 = fmul float %tmp5, %tmp6
  %add36 = fadd float %tmp4, %mul35
  %idxprom37 = sext i32 %j.1 to i64
  %arrayidx38 = getelementptr inbounds float, float* %y, i64 %idxprom37
  store float %add36, float* %arrayidx38, align 4
  br label %for.inc.39

for.inc.39:                                       ; preds = %for.body.26
  %inc40 = add nsw i32 %j.1, 1
  br label %for.cond.24

for.end.41:                                       ; preds = %for.cond.24
  br label %for.inc.42

for.inc.42:                                       ; preds = %for.end.41
  %inc43 = add nsw i32 %i.1, 1
  br label %for.cond.3

for.end.44:                                       ; preds = %for.cond.3
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
  %conv2 = sext i32 4096 to i64
  %mul3 = mul i64 %conv2, 4
  %call4 = call noalias i8* @malloc(i64 %mul3) #3
  %tmp1 = bitcast i8* %call4 to float*
  %conv5 = sext i32 4096 to i64
  %mul6 = mul i64 %conv5, 4
  %call7 = call noalias i8* @malloc(i64 %mul6) #3
  %tmp2 = bitcast i8* %call7 to float*
  %conv8 = sext i32 4096 to i64
  %mul9 = mul i64 %conv8, 4
  %call10 = call noalias i8* @malloc(i64 %mul9) #3
  %tmp3 = bitcast i8* %call10 to float*
  %tmp4 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %call11 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %tmp4, i8* getelementptr inbounds ([50 x i8], [50 x i8]* @.str.2, i32 0, i32 0))
  call void @init_array(float* %tmp1, float* %tmp)
  %call12 = call double @rtclock()
  call void @atax_cpu(i32 4096, i32 4096, float* %tmp, float* %tmp1, float* %tmp2, float* %tmp3)
  %call13 = call double @rtclock()
  %tmp5 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %sub = fsub double %call13, %call12
  %call14 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %tmp5, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.3, i32 0, i32 0), double %sub)
  %tmp6 = bitcast float* %tmp to i8*
  call void @free(i8* %tmp6) #3
  %tmp7 = bitcast float* %tmp1 to i8*
  call void @free(i8* %tmp7) #3
  %tmp8 = bitcast float* %tmp2 to i8*
  call void @free(i8* %tmp8) #3
  %tmp9 = bitcast float* %tmp3 to i8*
  call void @free(i8* %tmp9) #3
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
