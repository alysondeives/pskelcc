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
  call void @gol(i32 10, i32 1024, i32* %tmp, i32* %tmp1, i32 1)
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
define internal void @gol(i32 %tsteps, i32 %n, i32* %A, i32* %B, i32 %radius) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.62, %entry
  %t.0 = phi i32 [ 0, %entry ], [ %inc63, %for.inc.62 ]
  %neighbors.0 = phi i32 [ 0, %entry ], [ %neighbors.1, %for.inc.62 ]
  %cmp = icmp slt i32 %t.0, %tsteps
  br i1 %cmp, label %for.body, label %for.end.64

for.body:                                         ; preds = %for.cond
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc.37, %for.body
  %i.0 = phi i32 [ 1, %for.body ], [ %inc38, %for.inc.37 ]
  %neighbors.1 = phi i32 [ %neighbors.0, %for.body ], [ %neighbors.2, %for.inc.37 ]
  %sub = sub nsw i32 %n, 1
  %cmp2 = icmp slt i32 %i.0, %sub
  br i1 %cmp2, label %for.body.3, label %for.end.39

for.body.3:                                       ; preds = %for.cond.1
  br label %for.cond.4

for.cond.4:                                       ; preds = %for.inc.34, %for.body.3
  %j.0 = phi i32 [ 1, %for.body.3 ], [ %inc35, %for.inc.34 ]
  %neighbors.2 = phi i32 [ %neighbors.1, %for.body.3 ], [ %neighbors.3, %for.inc.34 ]
  %sub5 = sub nsw i32 %n, 1
  %cmp6 = icmp slt i32 %j.0, %sub5
  br i1 %cmp6, label %for.body.7, label %for.end.36

for.body.7:                                       ; preds = %for.cond.4
  %sub8 = sub nsw i32 0, 1
  br label %for.cond.9

for.cond.9:                                       ; preds = %for.inc.21, %for.body.7
  %neighbors.3 = phi i32 [ %neighbors.2, %for.body.7 ], [ %neighbors.4, %for.inc.21 ]
  %y.0 = phi i32 [ %sub8, %for.body.7 ], [ %inc22, %for.inc.21 ]
  %cmp10 = icmp sle i32 %y.0, 1
  br i1 %cmp10, label %for.body.11, label %for.end.23

for.body.11:                                      ; preds = %for.cond.9
  %sub12 = sub nsw i32 0, 1
  br label %for.cond.13

for.cond.13:                                      ; preds = %for.inc, %for.body.11
  %neighbors.4 = phi i32 [ %neighbors.3, %for.body.11 ], [ %neighbors.5, %for.inc ]
  %x.0 = phi i32 [ %sub12, %for.body.11 ], [ %inc, %for.inc ]
  %cmp14 = icmp sle i32 %x.0, 1
  br i1 %cmp14, label %for.body.15, label %for.end

for.body.15:                                      ; preds = %for.cond.13
  %cmp16 = icmp ne i32 %x.0, 0
  br i1 %cmp16, label %land.lhs.true, label %if.end

land.lhs.true:                                    ; preds = %for.body.15
  %cmp17 = icmp ne i32 %y.0, 0
  br i1 %cmp17, label %if.then, label %if.end

if.then:                                          ; preds = %land.lhs.true
  %add = add nsw i32 %i.0, %y.0
  %mul = mul nsw i32 %add, %n
  %add18 = add nsw i32 %j.0, %x.0
  %add19 = add nsw i32 %mul, %add18
  %idxprom = sext i32 %add19 to i64
  %arrayidx = getelementptr inbounds i32, i32* %A, i64 %idxprom
  %tmp = load i32, i32* %arrayidx, align 4
  %add20 = add nsw i32 %neighbors.4, %tmp
  br label %if.end

if.end:                                           ; preds = %if.then, %land.lhs.true, %for.body.15
  %neighbors.5 = phi i32 [ %add20, %if.then ], [ %neighbors.4, %land.lhs.true ], [ %neighbors.4, %for.body.15 ]
  br label %for.inc

for.inc:                                          ; preds = %if.end
  %inc = add nsw i32 %x.0, 1
  br label %for.cond.13

for.end:                                          ; preds = %for.cond.13
  br label %for.inc.21

for.inc.21:                                       ; preds = %for.end
  %inc22 = add nsw i32 %y.0, 1
  br label %for.cond.9

for.end.23:                                       ; preds = %for.cond.9
  %cmp24 = icmp eq i32 %neighbors.3, 3
  br i1 %cmp24, label %lor.end, label %lor.rhs

lor.rhs:                                          ; preds = %for.end.23
  %cmp25 = icmp eq i32 %neighbors.3, 2
  br i1 %cmp25, label %land.rhs, label %land.end

land.rhs:                                         ; preds = %lor.rhs
  %mul26 = mul nsw i32 %i.0, %n
  %add27 = add nsw i32 %mul26, %j.0
  %idxprom28 = sext i32 %add27 to i64
  %arrayidx29 = getelementptr inbounds i32, i32* %A, i64 %idxprom28
  %tmp1 = load i32, i32* %arrayidx29, align 4
  %tobool = icmp ne i32 %tmp1, 0
  br label %land.end

land.end:                                         ; preds = %land.rhs, %lor.rhs
  %tmp2 = phi i1 [ false, %lor.rhs ], [ %tobool, %land.rhs ]
  br label %lor.end

lor.end:                                          ; preds = %land.end, %for.end.23
  %tmp3 = phi i1 [ true, %for.end.23 ], [ %tmp2, %land.end ]
  %cond = select i1 %tmp3, i32 1, i32 0
  %mul30 = mul nsw i32 %i.0, %n
  %add31 = add nsw i32 %mul30, %j.0
  %idxprom32 = sext i32 %add31 to i64
  %arrayidx33 = getelementptr inbounds i32, i32* %B, i64 %idxprom32
  store i32 %cond, i32* %arrayidx33, align 4
  br label %for.inc.34

for.inc.34:                                       ; preds = %lor.end
  %inc35 = add nsw i32 %j.0, 1
  br label %for.cond.4

for.end.36:                                       ; preds = %for.cond.4
  br label %for.inc.37

for.inc.37:                                       ; preds = %for.end.36
  %inc38 = add nsw i32 %i.0, 1
  br label %for.cond.1

for.end.39:                                       ; preds = %for.cond.1
  br label %for.cond.40

for.cond.40:                                      ; preds = %for.inc.59, %for.end.39
  %i.1 = phi i32 [ 1, %for.end.39 ], [ %inc60, %for.inc.59 ]
  %sub41 = sub nsw i32 %n, 1
  %cmp42 = icmp slt i32 %i.1, %sub41
  br i1 %cmp42, label %for.body.43, label %for.end.61

for.body.43:                                      ; preds = %for.cond.40
  br label %for.cond.44

for.cond.44:                                      ; preds = %for.inc.56, %for.body.43
  %j.1 = phi i32 [ 1, %for.body.43 ], [ %inc57, %for.inc.56 ]
  %sub45 = sub nsw i32 %n, 1
  %cmp46 = icmp slt i32 %j.1, %sub45
  br i1 %cmp46, label %for.body.47, label %for.end.58

for.body.47:                                      ; preds = %for.cond.44
  %mul48 = mul nsw i32 %i.1, %n
  %add49 = add nsw i32 %mul48, %j.1
  %idxprom50 = sext i32 %add49 to i64
  %arrayidx51 = getelementptr inbounds i32, i32* %B, i64 %idxprom50
  %tmp4 = load i32, i32* %arrayidx51, align 4
  %mul52 = mul nsw i32 %i.1, %n
  %add53 = add nsw i32 %mul52, %j.1
  %idxprom54 = sext i32 %add53 to i64
  %arrayidx55 = getelementptr inbounds i32, i32* %A, i64 %idxprom54
  store i32 %tmp4, i32* %arrayidx55, align 4
  br label %for.inc.56

for.inc.56:                                       ; preds = %for.body.47
  %inc57 = add nsw i32 %j.1, 1
  br label %for.cond.44

for.end.58:                                       ; preds = %for.cond.44
  br label %for.inc.59

for.inc.59:                                       ; preds = %for.end.58
  %inc60 = add nsw i32 %i.1, 1
  br label %for.cond.40

for.end.61:                                       ; preds = %for.cond.40
  br label %for.inc.62

for.inc.62:                                       ; preds = %for.end.61
  %inc63 = add nsw i32 %t.0, 1
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
