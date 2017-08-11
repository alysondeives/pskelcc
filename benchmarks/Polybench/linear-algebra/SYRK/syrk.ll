; ModuleID = 'syrk-base.ll'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, i8*, i8*, i8*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type { %struct._IO_marker*, %struct._IO_FILE*, i32 }
%struct.timezone = type { i32, i32 }
%struct.timeval = type { i64, i64 }

@.str = private unnamed_addr constant [35 x i8] c"Error return from gettimeofday: %d\00", align 1
@.str.1 = private unnamed_addr constant [74 x i8] c"Non-Matching CPU-GPU Outputs Beyond Error Threshold of %4.2f Percent: %d\0A\00", align 1
@stdout = external global %struct._IO_FILE*, align 8
@.str.2 = private unnamed_addr constant [35 x i8] c"<< Symmetric rank-k operations >>\0A\00", align 1
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
define void @init_arrays(float* %A, float* %C, float* %D) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.31, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc32, %for.inc.31 ]
  %cmp = icmp slt i32 %i.0, 2048
  br i1 %cmp, label %for.body, label %for.end.33

for.body:                                         ; preds = %for.cond
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %j.0 = phi i32 [ 0, %for.body ], [ %inc, %for.inc ]
  %cmp2 = icmp slt i32 %j.0, 2048
  br i1 %cmp2, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.cond.1
  %conv = sitofp i32 %i.0 to float
  %conv4 = sitofp i32 %j.0 to float
  %mul = fmul float %conv, %conv4
  %div = fdiv float %mul, 2.048000e+03
  %mul5 = mul nsw i32 %i.0, 2048
  %add = add nsw i32 %mul5, %j.0
  %idxprom = sext i32 %add to i64
  %arrayidx = getelementptr inbounds float, float* %A, i64 %idxprom
  store float %div, float* %arrayidx, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.3
  %inc = add nsw i32 %j.0, 1
  br label %for.cond.1

for.end:                                          ; preds = %for.cond.1
  br label %for.cond.6

for.cond.6:                                       ; preds = %for.inc.28, %for.end
  %j.1 = phi i32 [ 0, %for.end ], [ %inc29, %for.inc.28 ]
  %cmp7 = icmp slt i32 %j.1, 2048
  br i1 %cmp7, label %for.body.9, label %for.end.30

for.body.9:                                       ; preds = %for.cond.6
  %conv10 = sitofp i32 %i.0 to float
  %conv11 = sitofp i32 %j.1 to float
  %mul12 = fmul float %conv10, %conv11
  %add13 = fadd float %mul12, 2.000000e+00
  %div14 = fdiv float %add13, 2.048000e+03
  %mul15 = mul nsw i32 %i.0, 2048
  %add16 = add nsw i32 %mul15, %j.1
  %idxprom17 = sext i32 %add16 to i64
  %arrayidx18 = getelementptr inbounds float, float* %C, i64 %idxprom17
  store float %div14, float* %arrayidx18, align 4
  %conv19 = sitofp i32 %i.0 to float
  %conv20 = sitofp i32 %j.1 to float
  %mul21 = fmul float %conv19, %conv20
  %add22 = fadd float %mul21, 2.000000e+00
  %div23 = fdiv float %add22, 2.048000e+03
  %mul24 = mul nsw i32 %i.0, 2048
  %add25 = add nsw i32 %mul24, %j.1
  %idxprom26 = sext i32 %add25 to i64
  %arrayidx27 = getelementptr inbounds float, float* %D, i64 %idxprom26
  store float %div23, float* %arrayidx27, align 4
  br label %for.inc.28

for.inc.28:                                       ; preds = %for.body.9
  %inc29 = add nsw i32 %j.1, 1
  br label %for.cond.6

for.end.30:                                       ; preds = %for.cond.6
  br label %for.inc.31

for.inc.31:                                       ; preds = %for.end.30
  %inc32 = add nsw i32 %i.0, 1
  br label %for.cond

for.end.33:                                       ; preds = %for.cond
  ret void
}

; Function Attrs: nounwind uwtable
define void @compareResults(float* %C, float* %D) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.13, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc14, %for.inc.13 ]
  %fail.0 = phi i32 [ 0, %entry ], [ %fail.1, %for.inc.13 ]
  %cmp = icmp slt i32 %i.0, 2048
  br i1 %cmp, label %for.body, label %for.end.15

for.body:                                         ; preds = %for.cond
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %j.0 = phi i32 [ 0, %for.body ], [ %inc12, %for.inc ]
  %fail.1 = phi i32 [ %fail.0, %for.body ], [ %fail.2, %for.inc ]
  %cmp2 = icmp slt i32 %j.0, 2048
  br i1 %cmp2, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.cond.1
  %mul = mul nsw i32 %i.0, 2048
  %add = add nsw i32 %mul, %j.0
  %idxprom = sext i32 %add to i64
  %arrayidx = getelementptr inbounds float, float* %C, i64 %idxprom
  %tmp = load float, float* %arrayidx, align 4
  %conv = fpext float %tmp to double
  %mul4 = mul nsw i32 %i.0, 2048
  %add5 = add nsw i32 %mul4, %j.0
  %idxprom6 = sext i32 %add5 to i64
  %arrayidx7 = getelementptr inbounds float, float* %D, i64 %idxprom6
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
define void @syrk(i32 %ni, i32 %nj, float* %A, float* %C) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.5, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc6, %for.inc.5 ]
  %cmp = icmp slt i32 %i.0, %ni
  br i1 %cmp, label %for.body, label %for.end.7

for.body:                                         ; preds = %for.cond
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %j.0 = phi i32 [ 0, %for.body ], [ %inc, %for.inc ]
  %cmp2 = icmp slt i32 %j.0, %ni
  br i1 %cmp2, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.cond.1
  %mul = mul nsw i32 %i.0, %ni
  %add = add nsw i32 %mul, %j.0
  %idxprom = sext i32 %add to i64
  %arrayidx = getelementptr inbounds float, float* %C, i64 %idxprom
  %tmp = load float, float* %arrayidx, align 4
  %mul4 = fmul float %tmp, 4.546000e+03
  store float %mul4, float* %arrayidx, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.3
  %inc = add nsw i32 %j.0, 1
  br label %for.cond.1

for.end:                                          ; preds = %for.cond.1
  br label %for.inc.5

for.inc.5:                                        ; preds = %for.end
  %inc6 = add nsw i32 %i.0, 1
  br label %for.cond

for.end.7:                                        ; preds = %for.cond
  br label %for.cond.8

for.cond.8:                                       ; preds = %for.inc.38, %for.end.7
  %i.1 = phi i32 [ 0, %for.end.7 ], [ %inc39, %for.inc.38 ]
  %cmp9 = icmp slt i32 %i.1, %ni
  br i1 %cmp9, label %for.body.10, label %for.end.40

for.body.10:                                      ; preds = %for.cond.8
  br label %for.cond.11

for.cond.11:                                      ; preds = %for.inc.35, %for.body.10
  %j.1 = phi i32 [ 0, %for.body.10 ], [ %inc36, %for.inc.35 ]
  %cmp12 = icmp slt i32 %j.1, %ni
  br i1 %cmp12, label %for.body.13, label %for.end.37

for.body.13:                                      ; preds = %for.cond.11
  br label %for.cond.14

for.cond.14:                                      ; preds = %for.inc.32, %for.body.13
  %k.0 = phi i32 [ 0, %for.body.13 ], [ %inc33, %for.inc.32 ]
  %cmp15 = icmp slt i32 %k.0, %nj
  br i1 %cmp15, label %for.body.16, label %for.end.34

for.body.16:                                      ; preds = %for.cond.14
  %mul17 = mul nsw i32 %i.1, %ni
  %add18 = add nsw i32 %mul17, %k.0
  %idxprom19 = sext i32 %add18 to i64
  %arrayidx20 = getelementptr inbounds float, float* %A, i64 %idxprom19
  %tmp1 = load float, float* %arrayidx20, align 4
  %mul21 = fmul float 1.243500e+04, %tmp1
  %mul22 = mul nsw i32 %j.1, %ni
  %add23 = add nsw i32 %mul22, %k.0
  %idxprom24 = sext i32 %add23 to i64
  %arrayidx25 = getelementptr inbounds float, float* %A, i64 %idxprom24
  %tmp2 = load float, float* %arrayidx25, align 4
  %mul26 = fmul float %mul21, %tmp2
  %mul27 = mul nsw i32 %i.1, %ni
  %add28 = add nsw i32 %mul27, %j.1
  %idxprom29 = sext i32 %add28 to i64
  %arrayidx30 = getelementptr inbounds float, float* %C, i64 %idxprom29
  %tmp3 = load float, float* %arrayidx30, align 4
  %add31 = fadd float %tmp3, %mul26
  store float %add31, float* %arrayidx30, align 4
  br label %for.inc.32

for.inc.32:                                       ; preds = %for.body.16
  %inc33 = add nsw i32 %k.0, 1
  br label %for.cond.14

for.end.34:                                       ; preds = %for.cond.14
  br label %for.inc.35

for.inc.35:                                       ; preds = %for.end.34
  %inc36 = add nsw i32 %j.1, 1
  br label %for.cond.11

for.end.37:                                       ; preds = %for.cond.11
  br label %for.inc.38

for.inc.38:                                       ; preds = %for.end.37
  %inc39 = add nsw i32 %i.1, 1
  br label %for.cond.8

for.end.40:                                       ; preds = %for.cond.8
  ret void
}

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
entry:
  %call = call noalias i8* @malloc(i64 16777216) #3
  %tmp = bitcast i8* %call to float*
  %call1 = call noalias i8* @malloc(i64 16777216) #3
  %tmp1 = bitcast i8* %call1 to float*
  %call2 = call noalias i8* @malloc(i64 16777216) #3
  %tmp2 = bitcast i8* %call2 to float*
  %tmp3 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %call3 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %tmp3, i8* getelementptr inbounds ([35 x i8], [35 x i8]* @.str.2, i32 0, i32 0))
  call void @init_arrays(float* %tmp, float* %tmp1, float* %tmp2)
  %call4 = call double @rtclock()
  call void @syrk(i32 2048, i32 2048, float* %tmp, float* %tmp1)
  %call5 = call double @rtclock()
  %tmp4 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %sub = fsub double %call5, %call4
  %call6 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %tmp4, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.3, i32 0, i32 0), double %sub)
  %tmp5 = bitcast float* %tmp to i8*
  call void @free(i8* %tmp5) #3
  %tmp6 = bitcast float* %tmp1 to i8*
  call void @free(i8* %tmp6) #3
  %tmp7 = bitcast float* %tmp2 to i8*
  call void @free(i8* %tmp7) #3
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
