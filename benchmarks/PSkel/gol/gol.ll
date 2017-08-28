; ModuleID = 'gol-base.ll'
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
define void @init_array(i32 %n, i32* %A, i32* %B) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.15, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc16, %for.inc.15 ]
  %cmp = icmp slt i32 %i.0, %n
  br i1 %cmp, label %for.body, label %for.end.17

for.body:                                         ; preds = %for.cond
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %j.0 = phi i32 [ 0, %for.body ], [ %inc, %for.inc ]
  %cmp2 = icmp slt i32 %j.0, %n
  br i1 %cmp2, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.cond.1
  %add = add nsw i32 %j.0, 2
  %mul = mul nsw i32 %i.0, %add
  %add4 = add nsw i32 %mul, 3
  %rem = srem i32 %add4, 2
  %mul5 = mul nsw i32 %i.0, %n
  %add6 = add nsw i32 %mul5, %j.0
  %idxprom = sext i32 %add6 to i64
  %arrayidx = getelementptr inbounds i32, i32* %A, i64 %idxprom
  store i32 %rem, i32* %arrayidx, align 4
  %add7 = add nsw i32 %j.0, 2
  %mul8 = mul nsw i32 %i.0, %add7
  %add9 = add nsw i32 %mul8, 3
  %rem10 = srem i32 %add9, 2
  %mul11 = mul nsw i32 %i.0, %n
  %add12 = add nsw i32 %mul11, %j.0
  %idxprom13 = sext i32 %add12 to i64
  %arrayidx14 = getelementptr inbounds i32, i32* %B, i64 %idxprom13
  store i32 %rem10, i32* %arrayidx14, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.3
  %inc = add nsw i32 %j.0, 1
  br label %for.cond.1

for.end:                                          ; preds = %for.cond.1
  br label %for.inc.15

for.inc.15:                                       ; preds = %for.end
  %inc16 = add nsw i32 %i.0, 1
  br label %for.cond

for.end.17:                                       ; preds = %for.cond
  ret void
}

; Function Attrs: nounwind uwtable
define i32 @main(i32 %argc, i8** %argv) #0 {
entry:
  %mul = mul nsw i32 1024, 1024
  %conv = sext i32 %mul to i64
  %mul1 = mul i64 %conv, 4
  %call = call noalias i8* @malloc(i64 %mul1) #3
  %tmp = bitcast i8* %call to i32*
  %mul2 = mul nsw i32 1024, 1024
  %conv3 = sext i32 %mul2 to i64
  %mul4 = mul i64 %conv3, 4
  %call5 = call noalias i8* @malloc(i64 %mul4) #3
  %tmp1 = bitcast i8* %call5 to i32*
  call void @init_array(i32 1024, i32* %tmp, i32* %tmp1)
  %call6 = call double @rtclock()
  call void @gol(i32 10, i32 1024, i32* %tmp, i32* %tmp1)
  %call7 = call double @rtclock()
  %tmp2 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %sub = fsub double %call7, %call6
  %call8 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %tmp2, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.1, i32 0, i32 0), double %sub)
  %tmp3 = bitcast i32* %tmp to i8*
  call void @free(i8* %tmp3) #3
  %tmp4 = bitcast i32* %tmp1 to i8*
  call void @free(i8* %tmp4) #3
  ret i32 0
}

; Function Attrs: nounwind
declare noalias i8* @malloc(i64) #1

; Function Attrs: nounwind uwtable
define internal void @gol(i32 %tsteps, i32 %n, i32* %A, i32* %B) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.90, %entry
  %t.0 = phi i32 [ 0, %entry ], [ %inc91, %for.inc.90 ]
  %cmp = icmp slt i32 %t.0, %tsteps
  br i1 %cmp, label %for.body, label %for.end.92

for.body:                                         ; preds = %for.cond
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc.65, %for.body
  %i.0 = phi i32 [ 1, %for.body ], [ %inc66, %for.inc.65 ]
  %sub = sub nsw i32 %n, 1
  %cmp2 = icmp slt i32 %i.0, %sub
  br i1 %cmp2, label %for.body.3, label %for.end.67

for.body.3:                                       ; preds = %for.cond.1
  br label %for.cond.4

for.cond.4:                                       ; preds = %for.inc, %for.body.3
  %j.0 = phi i32 [ 1, %for.body.3 ], [ %inc, %for.inc ]
  %sub5 = sub nsw i32 %n, 1
  %cmp6 = icmp slt i32 %j.0, %sub5
  br i1 %cmp6, label %for.body.7, label %for.end

for.body.7:                                       ; preds = %for.cond.4
  %sub8 = sub nsw i32 %i.0, 1
  %mul = mul nsw i32 %sub8, %n
  %sub9 = sub nsw i32 %j.0, 1
  %add = add nsw i32 %mul, %sub9
  %idxprom = sext i32 %add to i64
  %arrayidx = getelementptr inbounds i32, i32* %A, i64 %idxprom
  %tmp = load i32, i32* %arrayidx, align 4
  %sub10 = sub nsw i32 %i.0, 1
  %mul11 = mul nsw i32 %sub10, %n
  %add12 = add nsw i32 %mul11, %j.0
  %idxprom13 = sext i32 %add12 to i64
  %arrayidx14 = getelementptr inbounds i32, i32* %A, i64 %idxprom13
  %tmp1 = load i32, i32* %arrayidx14, align 4
  %add15 = add nsw i32 %tmp, %tmp1
  %sub16 = sub nsw i32 %i.0, 1
  %mul17 = mul nsw i32 %sub16, %n
  %add18 = add nsw i32 %j.0, 1
  %add19 = add nsw i32 %mul17, %add18
  %idxprom20 = sext i32 %add19 to i64
  %arrayidx21 = getelementptr inbounds i32, i32* %A, i64 %idxprom20
  %tmp2 = load i32, i32* %arrayidx21, align 4
  %add22 = add nsw i32 %add15, %tmp2
  %mul23 = mul nsw i32 %i.0, %n
  %sub24 = sub nsw i32 %j.0, 1
  %add25 = add nsw i32 %mul23, %sub24
  %idxprom26 = sext i32 %add25 to i64
  %arrayidx27 = getelementptr inbounds i32, i32* %A, i64 %idxprom26
  %tmp3 = load i32, i32* %arrayidx27, align 4
  %add28 = add nsw i32 %add22, %tmp3
  %mul29 = mul nsw i32 %i.0, %n
  %add30 = add nsw i32 %j.0, 1
  %add31 = add nsw i32 %mul29, %add30
  %idxprom32 = sext i32 %add31 to i64
  %arrayidx33 = getelementptr inbounds i32, i32* %A, i64 %idxprom32
  %tmp4 = load i32, i32* %arrayidx33, align 4
  %add34 = add nsw i32 %add28, %tmp4
  %add35 = add nsw i32 %i.0, 1
  %mul36 = mul nsw i32 %add35, %n
  %sub37 = sub nsw i32 %j.0, 1
  %add38 = add nsw i32 %mul36, %sub37
  %idxprom39 = sext i32 %add38 to i64
  %arrayidx40 = getelementptr inbounds i32, i32* %A, i64 %idxprom39
  %tmp5 = load i32, i32* %arrayidx40, align 4
  %add41 = add nsw i32 %add34, %tmp5
  %add42 = add nsw i32 %i.0, 1
  %mul43 = mul nsw i32 %add42, %n
  %add44 = add nsw i32 %mul43, %j.0
  %idxprom45 = sext i32 %add44 to i64
  %arrayidx46 = getelementptr inbounds i32, i32* %A, i64 %idxprom45
  %tmp6 = load i32, i32* %arrayidx46, align 4
  %add47 = add nsw i32 %add41, %tmp6
  %sub48 = sub nsw i32 %i.0, 1
  %mul49 = mul nsw i32 %sub48, %n
  %add50 = add nsw i32 %j.0, 1
  %add51 = add nsw i32 %mul49, %add50
  %idxprom52 = sext i32 %add51 to i64
  %arrayidx53 = getelementptr inbounds i32, i32* %A, i64 %idxprom52
  %tmp7 = load i32, i32* %arrayidx53, align 4
  %add54 = add nsw i32 %add47, %tmp7
  %cmp55 = icmp eq i32 %add54, 3
  br i1 %cmp55, label %lor.end, label %lor.rhs

lor.rhs:                                          ; preds = %for.body.7
  %cmp56 = icmp eq i32 %add54, 2
  br i1 %cmp56, label %land.rhs, label %land.end

land.rhs:                                         ; preds = %lor.rhs
  %mul57 = mul nsw i32 %i.0, %n
  %add58 = add nsw i32 %mul57, %j.0
  %idxprom59 = sext i32 %add58 to i64
  %arrayidx60 = getelementptr inbounds i32, i32* %A, i64 %idxprom59
  %tmp8 = load i32, i32* %arrayidx60, align 4
  %tobool = icmp ne i32 %tmp8, 0
  br label %land.end

land.end:                                         ; preds = %land.rhs, %lor.rhs
  %tmp9 = phi i1 [ false, %lor.rhs ], [ %tobool, %land.rhs ]
  br label %lor.end

lor.end:                                          ; preds = %land.end, %for.body.7
  %tmp10 = phi i1 [ true, %for.body.7 ], [ %tmp9, %land.end ]
  %cond = select i1 %tmp10, i32 1, i32 0
  %mul61 = mul nsw i32 %i.0, %n
  %add62 = add nsw i32 %mul61, %j.0
  %idxprom63 = sext i32 %add62 to i64
  %arrayidx64 = getelementptr inbounds i32, i32* %B, i64 %idxprom63
  store i32 %cond, i32* %arrayidx64, align 4
  br label %for.inc

for.inc:                                          ; preds = %lor.end
  %inc = add nsw i32 %j.0, 1
  br label %for.cond.4

for.end:                                          ; preds = %for.cond.4
  br label %for.inc.65

for.inc.65:                                       ; preds = %for.end
  %inc66 = add nsw i32 %i.0, 1
  br label %for.cond.1

for.end.67:                                       ; preds = %for.cond.1
  br label %for.cond.68

for.cond.68:                                      ; preds = %for.inc.87, %for.end.67
  %i.1 = phi i32 [ 1, %for.end.67 ], [ %inc88, %for.inc.87 ]
  %sub69 = sub nsw i32 %n, 1
  %cmp70 = icmp slt i32 %i.1, %sub69
  br i1 %cmp70, label %for.body.71, label %for.end.89

for.body.71:                                      ; preds = %for.cond.68
  br label %for.cond.72

for.cond.72:                                      ; preds = %for.inc.84, %for.body.71
  %j.1 = phi i32 [ 1, %for.body.71 ], [ %inc85, %for.inc.84 ]
  %sub73 = sub nsw i32 %n, 1
  %cmp74 = icmp slt i32 %j.1, %sub73
  br i1 %cmp74, label %for.body.75, label %for.end.86

for.body.75:                                      ; preds = %for.cond.72
  %mul76 = mul nsw i32 %i.1, %n
  %add77 = add nsw i32 %mul76, %j.1
  %idxprom78 = sext i32 %add77 to i64
  %arrayidx79 = getelementptr inbounds i32, i32* %B, i64 %idxprom78
  %tmp11 = load i32, i32* %arrayidx79, align 4
  %mul80 = mul nsw i32 %i.1, %n
  %add81 = add nsw i32 %mul80, %j.1
  %idxprom82 = sext i32 %add81 to i64
  %arrayidx83 = getelementptr inbounds i32, i32* %A, i64 %idxprom82
  store i32 %tmp11, i32* %arrayidx83, align 4
  br label %for.inc.84

for.inc.84:                                       ; preds = %for.body.75
  %inc85 = add nsw i32 %j.1, 1
  br label %for.cond.72

for.end.86:                                       ; preds = %for.cond.72
  br label %for.inc.87

for.inc.87:                                       ; preds = %for.end.86
  %inc88 = add nsw i32 %i.1, 1
  br label %for.cond.68

for.end.89:                                       ; preds = %for.cond.68
  br label %for.inc.90

for.inc.90:                                       ; preds = %for.end.89
  %inc91 = add nsw i32 %t.0, 1
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
