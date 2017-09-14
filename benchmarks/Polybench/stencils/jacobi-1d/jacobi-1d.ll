; ModuleID = 'jacobi-1d-base.ll'
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
define i32 @main(i32 %argc, i8** %argv) #0 {
entry:
  %conv = sext i32 1024 to i64
  %mul = mul i64 %conv, 4
  %call = call noalias i8* @malloc(i64 %mul) #3
  %tmp = bitcast i8* %call to float*
  %conv1 = sext i32 1024 to i64
  %mul2 = mul i64 %conv1, 4
  %call3 = call noalias i8* @malloc(i64 %mul2) #3
  %tmp1 = bitcast i8* %call3 to float*
  call void @init_array(i32 1024, float* %tmp, float* %tmp1)
  %call4 = call double @rtclock()
  call void @jacobi(i32 10, i32 1024, float* %tmp, float* %tmp1)
  %call5 = call double @rtclock()
  %tmp2 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %sub = fsub double %call5, %call4
  %call6 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %tmp2, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.1, i32 0, i32 0), double %sub)
  %tmp3 = bitcast float* %tmp to i8*
  call void @free(i8* %tmp3) #3
  %tmp4 = bitcast float* %tmp1 to i8*
  call void @free(i8* %tmp4) #3
  ret i32 0
}

; Function Attrs: nounwind
declare noalias i8* @malloc(i64) #1

; Function Attrs: nounwind uwtable
define internal void @init_array(i32 %n, float* %A, float* %B) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc, %for.inc ]
  %cmp = icmp slt i32 %i.0, %n
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %conv = sitofp i32 %i.0 to float
  %add = fadd float %conv, 2.000000e+00
  %conv1 = sitofp i32 %n to float
  %div = fdiv float %add, %conv1
  %idxprom = sext i32 %i.0 to i64
  %arrayidx = getelementptr inbounds float, float* %A, i64 %idxprom
  store float %div, float* %arrayidx, align 4
  %conv2 = sitofp i32 %i.0 to float
  %add3 = fadd float %conv2, 3.000000e+00
  %conv4 = sitofp i32 %n to float
  %div5 = fdiv float %add3, %conv4
  %idxprom6 = sext i32 %i.0 to i64
  %arrayidx7 = getelementptr inbounds float, float* %B, i64 %idxprom6
  store float %div5, float* %arrayidx7, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %inc = add nsw i32 %i.0, 1
  br label %for.cond

for.end:                                          ; preds = %for.cond
  ret void
}

; Function Attrs: nounwind uwtable
define internal void @jacobi(i32 %tsteps, i32 %n, float* %A, float* %B) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.24, %entry
  %t.0 = phi i32 [ 0, %entry ], [ %inc25, %for.inc.24 ]
  %cmp = icmp slt i32 %t.0, %tsteps
  br i1 %cmp, label %for.body, label %for.end.26

for.body:                                         ; preds = %for.cond
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %i.0 = phi i32 [ 1, %for.body ], [ %inc, %for.inc ]
  %sub = sub nsw i32 %n, 1
  %cmp2 = icmp slt i32 %i.0, %sub
  br i1 %cmp2, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.cond.1
  %sub4 = sub nsw i32 %i.0, 1
  %idxprom = sext i32 %sub4 to i64
  %arrayidx = getelementptr inbounds float, float* %A, i64 %idxprom
  %tmp = load float, float* %arrayidx, align 4
  %idxprom5 = sext i32 %i.0 to i64
  %arrayidx6 = getelementptr inbounds float, float* %A, i64 %idxprom5
  %tmp1 = load float, float* %arrayidx6, align 4
  %add = fadd float %tmp, %tmp1
  %add7 = add nsw i32 %i.0, 1
  %idxprom8 = sext i32 %add7 to i64
  %arrayidx9 = getelementptr inbounds float, float* %A, i64 %idxprom8
  %tmp2 = load float, float* %arrayidx9, align 4
  %add10 = fadd float %add, %tmp2
  %mul = fmul float 0x3FD5554760000000, %add10
  %idxprom11 = sext i32 %i.0 to i64
  %arrayidx12 = getelementptr inbounds float, float* %B, i64 %idxprom11
  store float %mul, float* %arrayidx12, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.3
  %inc = add nsw i32 %i.0, 1
  br label %for.cond.1

for.end:                                          ; preds = %for.cond.1
  br label %for.cond.13

for.cond.13:                                      ; preds = %for.inc.21, %for.end
  %j.0 = phi i32 [ 0, %for.end ], [ %inc22, %for.inc.21 ]
  %sub14 = sub nsw i32 %n, 1
  %cmp15 = icmp slt i32 %j.0, %sub14
  br i1 %cmp15, label %for.body.16, label %for.end.23

for.body.16:                                      ; preds = %for.cond.13
  %idxprom17 = sext i32 %j.0 to i64
  %arrayidx18 = getelementptr inbounds float, float* %B, i64 %idxprom17
  %tmp3 = load float, float* %arrayidx18, align 4
  %idxprom19 = sext i32 %j.0 to i64
  %arrayidx20 = getelementptr inbounds float, float* %A, i64 %idxprom19
  store float %tmp3, float* %arrayidx20, align 4
  br label %for.inc.21

for.inc.21:                                       ; preds = %for.body.16
  %inc22 = add nsw i32 %j.0, 1
  br label %for.cond.13

for.end.23:                                       ; preds = %for.cond.13
  br label %for.inc.24

for.inc.24:                                       ; preds = %for.end.23
  %inc25 = add nsw i32 %t.0, 1
  br label %for.cond

for.end.26:                                       ; preds = %for.cond
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
