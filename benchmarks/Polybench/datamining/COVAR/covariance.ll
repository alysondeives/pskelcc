; ModuleID = 'covariance-base.ll'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, i8*, i8*, i8*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type { %struct._IO_marker*, %struct._IO_FILE*, i32 }
%struct.timezone = type { i32, i32 }
%struct.timeval = type { i64, i64 }

@.str = private unnamed_addr constant [35 x i8] c"Error return from gettimeofday: %d\00", align 1
@.str.1 = private unnamed_addr constant [74 x i8] c"Non-Matching CPU-GPU Outputs Beyond Error Threshold of %4.2f Percent: %d\0A\00", align 1
@stdout = external global %struct._IO_FILE*, align 8
@.str.2 = private unnamed_addr constant [30 x i8] c"<< Covariance Computation >>\0A\00", align 1
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
define void @init_arrays(float* %data) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.6, %entry
  %i.0 = phi i32 [ 1, %entry ], [ %inc7, %for.inc.6 ]
  %cmp = icmp slt i32 %i.0, 2049
  br i1 %cmp, label %for.body, label %for.end.8

for.body:                                         ; preds = %for.cond
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %j.0 = phi i32 [ 1, %for.body ], [ %inc, %for.inc ]
  %cmp2 = icmp slt i32 %j.0, 2049
  br i1 %cmp2, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.cond.1
  %conv = sitofp i32 %i.0 to float
  %conv4 = sitofp i32 %j.0 to float
  %mul = fmul float %conv, %conv4
  %div = fdiv float %mul, 2.048000e+03
  %mul5 = mul nsw i32 %i.0, 2049
  %add = add nsw i32 %mul5, %j.0
  %idxprom = sext i32 %add to i64
  %arrayidx = getelementptr inbounds float, float* %data, i64 %idxprom
  store float %div, float* %arrayidx, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.3
  %inc = add nsw i32 %j.0, 1
  br label %for.cond.1

for.end:                                          ; preds = %for.cond.1
  br label %for.inc.6

for.inc.6:                                        ; preds = %for.end
  %inc7 = add nsw i32 %i.0, 1
  br label %for.cond

for.end.8:                                        ; preds = %for.cond
  ret void
}

; Function Attrs: nounwind uwtable
define void @compareResults(float* %symmat, float* %symmat_outputFromGpu) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.13, %entry
  %i.0 = phi i32 [ 1, %entry ], [ %inc14, %for.inc.13 ]
  %fail.0 = phi i32 [ 0, %entry ], [ %fail.1, %for.inc.13 ]
  %cmp = icmp slt i32 %i.0, 2049
  br i1 %cmp, label %for.body, label %for.end.15

for.body:                                         ; preds = %for.cond
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %j.0 = phi i32 [ 1, %for.body ], [ %inc12, %for.inc ]
  %fail.1 = phi i32 [ %fail.0, %for.body ], [ %fail.2, %for.inc ]
  %cmp2 = icmp slt i32 %j.0, 2049
  br i1 %cmp2, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.cond.1
  %mul = mul nsw i32 %i.0, 2049
  %add = add nsw i32 %mul, %j.0
  %idxprom = sext i32 %add to i64
  %arrayidx = getelementptr inbounds float, float* %symmat, i64 %idxprom
  %tmp = load float, float* %arrayidx, align 4
  %conv = fpext float %tmp to double
  %mul4 = mul nsw i32 %i.0, 2049
  %add5 = add nsw i32 %mul4, %j.0
  %idxprom6 = sext i32 %add5 to i64
  %arrayidx7 = getelementptr inbounds float, float* %symmat_outputFromGpu, i64 %idxprom6
  %tmp1 = load float, float* %arrayidx7, align 4
  %conv8 = fpext float %tmp1 to double
  %call = call float @percentDiff(double %conv, double %conv8)
  %conv9 = fpext float %call to double
  %cmp10 = fcmp ogt double %conv9, 1.050000e+00
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
  %call16 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([74 x i8], [74 x i8]* @.str.1, i32 0, i32 0), double 1.050000e+00, i32 %fail.0)
  ret void
}

; Function Attrs: nounwind uwtable
define void @covariance(i32 %m, i32 %n, float* %data, float* %symmat, float* %mean) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.12, %entry
  %j.0 = phi i32 [ 0, %entry ], [ %inc13, %for.inc.12 ]
  %cmp = icmp slt i32 %j.0, %m
  br i1 %cmp, label %for.body, label %for.end.14

for.body:                                         ; preds = %for.cond
  %idxprom = sext i32 %j.0 to i64
  %arrayidx = getelementptr inbounds float, float* %mean, i64 %idxprom
  store float 0.000000e+00, float* %arrayidx, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %i.0 = phi i32 [ 0, %for.body ], [ %inc, %for.inc ]
  %cmp2 = icmp slt i32 %i.0, %n
  br i1 %cmp2, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.cond.1
  %mul = mul nsw i32 %i.0, %m
  %add = add nsw i32 %mul, %j.0
  %idxprom4 = sext i32 %add to i64
  %arrayidx5 = getelementptr inbounds float, float* %data, i64 %idxprom4
  %tmp = load float, float* %arrayidx5, align 4
  %idxprom6 = sext i32 %j.0 to i64
  %arrayidx7 = getelementptr inbounds float, float* %mean, i64 %idxprom6
  %tmp1 = load float, float* %arrayidx7, align 4
  %add8 = fadd float %tmp1, %tmp
  store float %add8, float* %arrayidx7, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.3
  %inc = add nsw i32 %i.0, 1
  br label %for.cond.1

for.end:                                          ; preds = %for.cond.1
  %idxprom9 = sext i32 %j.0 to i64
  %arrayidx10 = getelementptr inbounds float, float* %mean, i64 %idxprom9
  %tmp2 = load float, float* %arrayidx10, align 4
  %conv = fpext float %tmp2 to double
  %div = fdiv double %conv, 0x414885C20147AE14
  %conv11 = fptrunc double %div to float
  store float %conv11, float* %arrayidx10, align 4
  br label %for.inc.12

for.inc.12:                                       ; preds = %for.end
  %inc13 = add nsw i32 %j.0, 1
  br label %for.cond

for.end.14:                                       ; preds = %for.cond
  br label %for.cond.15

for.cond.15:                                      ; preds = %for.inc.32, %for.end.14
  %i.1 = phi i32 [ 0, %for.end.14 ], [ %inc33, %for.inc.32 ]
  %cmp16 = icmp slt i32 %i.1, %n
  br i1 %cmp16, label %for.body.18, label %for.end.34

for.body.18:                                      ; preds = %for.cond.15
  br label %for.cond.19

for.cond.19:                                      ; preds = %for.inc.29, %for.body.18
  %j.1 = phi i32 [ 0, %for.body.18 ], [ %inc30, %for.inc.29 ]
  %cmp20 = icmp slt i32 %j.1, %m
  br i1 %cmp20, label %for.body.22, label %for.end.31

for.body.22:                                      ; preds = %for.cond.19
  %idxprom23 = sext i32 %j.1 to i64
  %arrayidx24 = getelementptr inbounds float, float* %mean, i64 %idxprom23
  %tmp3 = load float, float* %arrayidx24, align 4
  %mul25 = mul nsw i32 %i.1, %m
  %add26 = add nsw i32 %mul25, %j.1
  %idxprom27 = sext i32 %add26 to i64
  %arrayidx28 = getelementptr inbounds float, float* %data, i64 %idxprom27
  %tmp4 = load float, float* %arrayidx28, align 4
  %sub = fsub float %tmp4, %tmp3
  store float %sub, float* %arrayidx28, align 4
  br label %for.inc.29

for.inc.29:                                       ; preds = %for.body.22
  %inc30 = add nsw i32 %j.1, 1
  br label %for.cond.19

for.end.31:                                       ; preds = %for.cond.19
  br label %for.inc.32

for.inc.32:                                       ; preds = %for.end.31
  %inc33 = add nsw i32 %i.1, 1
  br label %for.cond.15

for.end.34:                                       ; preds = %for.cond.15
  br label %for.cond.35

for.cond.35:                                      ; preds = %for.inc.79, %for.end.34
  %j1.0 = phi i32 [ 0, %for.end.34 ], [ %inc80, %for.inc.79 ]
  %cmp36 = icmp slt i32 %j1.0, %m
  br i1 %cmp36, label %for.body.38, label %for.end.81

for.body.38:                                      ; preds = %for.cond.35
  br label %for.cond.39

for.cond.39:                                      ; preds = %for.inc.76, %for.body.38
  %j2.0 = phi i32 [ %j1.0, %for.body.38 ], [ %inc77, %for.inc.76 ]
  %cmp40 = icmp slt i32 %j2.0, %m
  br i1 %cmp40, label %for.body.42, label %for.end.78

for.body.42:                                      ; preds = %for.cond.39
  %mul43 = mul nsw i32 %j1.0, %m
  %add44 = add nsw i32 %mul43, %j2.0
  %idxprom45 = sext i32 %add44 to i64
  %arrayidx46 = getelementptr inbounds float, float* %symmat, i64 %idxprom45
  store float 0.000000e+00, float* %arrayidx46, align 4
  br label %for.cond.47

for.cond.47:                                      ; preds = %for.inc.65, %for.body.42
  %i.2 = phi i32 [ 1, %for.body.42 ], [ %inc66, %for.inc.65 ]
  %cmp48 = icmp slt i32 %i.2, %n
  br i1 %cmp48, label %for.body.50, label %for.end.67

for.body.50:                                      ; preds = %for.cond.47
  %mul51 = mul nsw i32 %i.2, %m
  %add52 = add nsw i32 %mul51, %j1.0
  %idxprom53 = sext i32 %add52 to i64
  %arrayidx54 = getelementptr inbounds float, float* %data, i64 %idxprom53
  %tmp5 = load float, float* %arrayidx54, align 4
  %mul55 = mul nsw i32 %i.2, %m
  %add56 = add nsw i32 %mul55, %j2.0
  %idxprom57 = sext i32 %add56 to i64
  %arrayidx58 = getelementptr inbounds float, float* %data, i64 %idxprom57
  %tmp6 = load float, float* %arrayidx58, align 4
  %mul59 = fmul float %tmp5, %tmp6
  %mul60 = mul nsw i32 %j1.0, %m
  %add61 = add nsw i32 %mul60, %j2.0
  %idxprom62 = sext i32 %add61 to i64
  %arrayidx63 = getelementptr inbounds float, float* %symmat, i64 %idxprom62
  %tmp7 = load float, float* %arrayidx63, align 4
  %add64 = fadd float %tmp7, %mul59
  store float %add64, float* %arrayidx63, align 4
  br label %for.inc.65

for.inc.65:                                       ; preds = %for.body.50
  %inc66 = add nsw i32 %i.2, 1
  br label %for.cond.47

for.end.67:                                       ; preds = %for.cond.47
  %mul68 = mul nsw i32 %j1.0, %m
  %add69 = add nsw i32 %mul68, %j2.0
  %idxprom70 = sext i32 %add69 to i64
  %arrayidx71 = getelementptr inbounds float, float* %symmat, i64 %idxprom70
  %tmp8 = load float, float* %arrayidx71, align 4
  %mul72 = mul nsw i32 %j2.0, %m
  %add73 = add nsw i32 %mul72, %j1.0
  %idxprom74 = sext i32 %add73 to i64
  %arrayidx75 = getelementptr inbounds float, float* %symmat, i64 %idxprom74
  store float %tmp8, float* %arrayidx75, align 4
  br label %for.inc.76

for.inc.76:                                       ; preds = %for.end.67
  %inc77 = add nsw i32 %j2.0, 1
  br label %for.cond.39

for.end.78:                                       ; preds = %for.cond.39
  br label %for.inc.79

for.inc.79:                                       ; preds = %for.end.78
  %inc80 = add nsw i32 %j1.0, 1
  br label %for.cond.35

for.end.81:                                       ; preds = %for.cond.35
  ret void
}

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
entry:
  %call = call noalias i8* @malloc(i64 16793604) #3
  %tmp = bitcast i8* %call to float*
  %call1 = call noalias i8* @malloc(i64 16793604) #3
  %tmp1 = bitcast i8* %call1 to float*
  %call2 = call noalias i8* @malloc(i64 8196) #3
  %tmp2 = bitcast i8* %call2 to float*
  %call3 = call noalias i8* @malloc(i64 16793604) #3
  %tmp3 = bitcast i8* %call3 to float*
  %tmp4 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %call4 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %tmp4, i8* getelementptr inbounds ([30 x i8], [30 x i8]* @.str.2, i32 0, i32 0))
  call void @init_arrays(float* %tmp)
  %call5 = call double @rtclock()
  call void @covariance(i32 2048, i32 2048, float* %tmp, float* %tmp1, float* %tmp2)
  %call6 = call double @rtclock()
  %tmp5 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %sub = fsub double %call6, %call5
  %call7 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %tmp5, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.3, i32 0, i32 0), double %sub)
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
