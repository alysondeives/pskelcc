; ModuleID = 'fur-base.ll'
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
define void @init_array(i32 %ni, i32 %nj, i32* %A, i32* %B) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.15, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc16, %for.inc.15 ]
  %cmp = icmp slt i32 %i.0, %ni
  br i1 %cmp, label %for.body, label %for.end.17

for.body:                                         ; preds = %for.cond
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %j.0 = phi i32 [ 0, %for.body ], [ %inc, %for.inc ]
  %cmp2 = icmp slt i32 %j.0, %nj
  br i1 %cmp2, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.cond.1
  %add = add nsw i32 %j.0, 2
  %mul = mul nsw i32 %i.0, %add
  %add4 = add nsw i32 %mul, 3
  %rem = srem i32 %add4, 2
  %mul5 = mul nsw i32 %i.0, %nj
  %add6 = add nsw i32 %mul5, %j.0
  %idxprom = sext i32 %add6 to i64
  %arrayidx = getelementptr inbounds i32, i32* %A, i64 %idxprom
  store i32 %rem, i32* %arrayidx, align 4
  %add7 = add nsw i32 %j.0, 2
  %mul8 = mul nsw i32 %i.0, %add7
  %add9 = add nsw i32 %mul8, 3
  %rem10 = srem i32 %add9, 2
  %mul11 = mul nsw i32 %i.0, %nj
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
define void @fur(i32 %tsteps, i32 %ni, i32 %nj, i32* %A, i32* %B) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.119, %entry
  %t.0 = phi i32 [ 0, %entry ], [ %inc120, %for.inc.119 ]
  %numberA.0 = phi i32 [ undef, %entry ], [ %numberA.1, %for.inc.119 ]
  %numberI.0 = phi i32 [ undef, %entry ], [ %numberI.1, %for.inc.119 ]
  %cmp = icmp slt i32 %t.0, %tsteps
  br i1 %cmp, label %for.body, label %for.end.121

for.body:                                         ; preds = %for.cond
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc.92, %for.body
  %i.0 = phi i32 [ 1, %for.body ], [ %inc93, %for.inc.92 ]
  %numberA.1 = phi i32 [ %numberA.0, %for.body ], [ %numberA.2, %for.inc.92 ]
  %numberI.1 = phi i32 [ %numberI.0, %for.body ], [ %numberI.2, %for.inc.92 ]
  %sub = sub nsw i32 %ni, 1
  %cmp2 = icmp slt i32 %i.0, %sub
  br i1 %cmp2, label %for.body.3, label %for.end.94

for.body.3:                                       ; preds = %for.cond.1
  br label %for.cond.4

for.cond.4:                                       ; preds = %for.inc.89, %for.body.3
  %j.0 = phi i32 [ 1, %for.body.3 ], [ %inc90, %for.inc.89 ]
  %numberA.2 = phi i32 [ %numberA.1, %for.body.3 ], [ %numberA.3, %for.inc.89 ]
  %numberI.2 = phi i32 [ %numberI.1, %for.body.3 ], [ %numberI.3, %for.inc.89 ]
  %sub5 = sub nsw i32 %nj, 1
  %cmp6 = icmp slt i32 %j.0, %sub5
  br i1 %cmp6, label %for.body.7, label %for.end.91

for.body.7:                                       ; preds = %for.cond.4
  %mul = mul nsw i32 2, 1
  %sub8 = sub nsw i32 1, %mul
  br label %for.cond.9

for.cond.9:                                       ; preds = %for.inc.23, %for.body.7
  %y.0 = phi i32 [ %sub8, %for.body.7 ], [ %inc24, %for.inc.23 ]
  %numberA.3 = phi i32 [ %numberA.2, %for.body.7 ], [ %numberA.4, %for.inc.23 ]
  %cmp10 = icmp sle i32 %y.0, 1
  br i1 %cmp10, label %for.body.11, label %for.end.25

for.body.11:                                      ; preds = %for.cond.9
  %mul12 = mul nsw i32 2, 1
  %sub13 = sub nsw i32 1, %mul12
  br label %for.cond.14

for.cond.14:                                      ; preds = %for.inc, %for.body.11
  %x.0 = phi i32 [ %sub13, %for.body.11 ], [ %inc, %for.inc ]
  %numberA.4 = phi i32 [ %numberA.3, %for.body.11 ], [ %numberA.5, %for.inc ]
  %cmp15 = icmp sle i32 %x.0, 1
  br i1 %cmp15, label %for.body.16, label %for.end

for.body.16:                                      ; preds = %for.cond.14
  %cmp17 = icmp ne i32 %x.0, 0
  br i1 %cmp17, label %if.then, label %lor.lhs.false

lor.lhs.false:                                    ; preds = %for.body.16
  %cmp18 = icmp ne i32 %y.0, 0
  br i1 %cmp18, label %if.then, label %if.end

if.then:                                          ; preds = %lor.lhs.false, %for.body.16
  %add = add nsw i32 %i.0, %y.0
  %mul19 = mul nsw i32 %add, %nj
  %add20 = add nsw i32 %j.0, %x.0
  %add21 = add nsw i32 %mul19, %add20
  %idxprom = sext i32 %add21 to i64
  %arrayidx = getelementptr inbounds i32, i32* %A, i64 %idxprom
  %tmp = load i32, i32* %arrayidx, align 4
  %add22 = add nsw i32 %numberA.4, %tmp
  br label %if.end

if.end:                                           ; preds = %if.then, %lor.lhs.false
  %numberA.5 = phi i32 [ %add22, %if.then ], [ %numberA.4, %lor.lhs.false ]
  br label %for.inc

for.inc:                                          ; preds = %if.end
  %inc = add nsw i32 %x.0, 1
  br label %for.cond.14

for.end:                                          ; preds = %for.cond.14
  br label %for.inc.23

for.inc.23:                                       ; preds = %for.end
  %inc24 = add nsw i32 %y.0, 1
  br label %for.cond.9

for.end.25:                                       ; preds = %for.cond.9
  %mul26 = mul nsw i32 2, 1
  %mul27 = mul nsw i32 4, 1
  %sub28 = sub nsw i32 %mul26, %mul27
  br label %for.cond.29

for.cond.29:                                      ; preds = %for.inc.65, %for.end.25
  %y.1 = phi i32 [ %sub28, %for.end.25 ], [ %inc66, %for.inc.65 ]
  %numberI.3 = phi i32 [ %numberI.2, %for.end.25 ], [ %numberI.4, %for.inc.65 ]
  %mul30 = mul nsw i32 2, 1
  %cmp31 = icmp sle i32 %y.1, %mul30
  br i1 %cmp31, label %for.body.32, label %for.end.67

for.body.32:                                      ; preds = %for.cond.29
  %mul33 = mul nsw i32 2, 1
  %mul34 = mul nsw i32 4, 1
  %sub35 = sub nsw i32 %mul33, %mul34
  br label %for.cond.36

for.cond.36:                                      ; preds = %for.inc.62, %for.body.32
  %x.1 = phi i32 [ %sub35, %for.body.32 ], [ %inc63, %for.inc.62 ]
  %numberI.4 = phi i32 [ %numberI.3, %for.body.32 ], [ %numberI.6, %for.inc.62 ]
  %mul37 = mul nsw i32 2, 1
  %cmp38 = icmp sle i32 %x.1, %mul37
  br i1 %cmp38, label %for.body.39, label %for.end.64

for.body.39:                                      ; preds = %for.cond.36
  %cmp40 = icmp ne i32 %x.1, 0
  br i1 %cmp40, label %if.then.43, label %lor.lhs.false.41

lor.lhs.false.41:                                 ; preds = %for.body.39
  %cmp42 = icmp ne i32 %y.1, 0
  br i1 %cmp42, label %if.then.43, label %if.end.61

if.then.43:                                       ; preds = %lor.lhs.false.41, %for.body.39
  %cmp44 = icmp sle i32 %x.1, 1
  br i1 %cmp44, label %land.lhs.true, label %if.then.52

land.lhs.true:                                    ; preds = %if.then.43
  %mul45 = mul nsw i32 -1, 1
  %cmp46 = icmp sge i32 %x.1, %mul45
  br i1 %cmp46, label %land.lhs.true.47, label %if.then.52

land.lhs.true.47:                                 ; preds = %land.lhs.true
  %cmp48 = icmp sle i32 %y.1, 1
  br i1 %cmp48, label %land.lhs.true.49, label %if.then.52

land.lhs.true.49:                                 ; preds = %land.lhs.true.47
  %mul50 = mul nsw i32 -1, 1
  %cmp51 = icmp sge i32 %y.1, %mul50
  br i1 %cmp51, label %if.end.60, label %if.then.52

if.then.52:                                       ; preds = %land.lhs.true.49, %land.lhs.true.47, %land.lhs.true, %if.then.43
  %add53 = add nsw i32 %i.0, %y.1
  %mul54 = mul nsw i32 %add53, %nj
  %add55 = add nsw i32 %j.0, %x.1
  %add56 = add nsw i32 %mul54, %add55
  %idxprom57 = sext i32 %add56 to i64
  %arrayidx58 = getelementptr inbounds i32, i32* %A, i64 %idxprom57
  %tmp1 = load i32, i32* %arrayidx58, align 4
  %add59 = add nsw i32 %numberI.4, %tmp1
  br label %if.end.60

if.end.60:                                        ; preds = %if.then.52, %land.lhs.true.49
  %numberI.5 = phi i32 [ %numberI.4, %land.lhs.true.49 ], [ %add59, %if.then.52 ]
  br label %if.end.61

if.end.61:                                        ; preds = %if.end.60, %lor.lhs.false.41
  %numberI.6 = phi i32 [ %numberI.5, %if.end.60 ], [ %numberI.4, %lor.lhs.false.41 ]
  br label %for.inc.62

for.inc.62:                                       ; preds = %if.end.61
  %inc63 = add nsw i32 %x.1, 1
  br label %for.cond.36

for.end.64:                                       ; preds = %for.cond.36
  br label %for.inc.65

for.inc.65:                                       ; preds = %for.end.64
  %inc66 = add nsw i32 %y.1, 1
  br label %for.cond.29

for.end.67:                                       ; preds = %for.cond.29
  %conv = sitofp i32 %numberI.3 to float
  %mul68 = fmul float %conv, 2.000000e+00
  %conv69 = sitofp i32 %numberA.3 to float
  %sub70 = fsub float %conv69, %mul68
  %cmp71 = fcmp olt float %sub70, 0.000000e+00
  br i1 %cmp71, label %cond.true, label %cond.false

cond.true:                                        ; preds = %for.end.67
  br label %cond.end.83

cond.false:                                       ; preds = %for.end.67
  %conv73 = sitofp i32 %numberA.3 to float
  %sub74 = fsub float %conv73, %mul68
  %cmp75 = fcmp ogt float %sub74, 0.000000e+00
  br i1 %cmp75, label %cond.true.77, label %cond.false.78

cond.true.77:                                     ; preds = %cond.false
  br label %cond.end

cond.false.78:                                    ; preds = %cond.false
  %mul79 = mul nsw i32 %i.0, %nj
  %add80 = add nsw i32 %mul79, %j.0
  %idxprom81 = sext i32 %add80 to i64
  %arrayidx82 = getelementptr inbounds i32, i32* %A, i64 %idxprom81
  %tmp2 = load i32, i32* %arrayidx82, align 4
  br label %cond.end

cond.end:                                         ; preds = %cond.false.78, %cond.true.77
  %cond = phi i32 [ 1, %cond.true.77 ], [ %tmp2, %cond.false.78 ]
  br label %cond.end.83

cond.end.83:                                      ; preds = %cond.end, %cond.true
  %cond84 = phi i32 [ 0, %cond.true ], [ %cond, %cond.end ]
  %mul85 = mul nsw i32 %i.0, %nj
  %add86 = add nsw i32 %mul85, %j.0
  %idxprom87 = sext i32 %add86 to i64
  %arrayidx88 = getelementptr inbounds i32, i32* %B, i64 %idxprom87
  store i32 %cond84, i32* %arrayidx88, align 4
  br label %for.inc.89

for.inc.89:                                       ; preds = %cond.end.83
  %inc90 = add nsw i32 %j.0, 1
  br label %for.cond.4

for.end.91:                                       ; preds = %for.cond.4
  br label %for.inc.92

for.inc.92:                                       ; preds = %for.end.91
  %inc93 = add nsw i32 %i.0, 1
  br label %for.cond.1

for.end.94:                                       ; preds = %for.cond.1
  br label %for.cond.95

for.cond.95:                                      ; preds = %for.inc.116, %for.end.94
  %i.1 = phi i32 [ 1, %for.end.94 ], [ %inc117, %for.inc.116 ]
  %sub96 = sub nsw i32 %ni, 1
  %cmp97 = icmp slt i32 %i.1, %sub96
  br i1 %cmp97, label %for.body.99, label %for.end.118

for.body.99:                                      ; preds = %for.cond.95
  br label %for.cond.100

for.cond.100:                                     ; preds = %for.inc.113, %for.body.99
  %j.1 = phi i32 [ 1, %for.body.99 ], [ %inc114, %for.inc.113 ]
  %sub101 = sub nsw i32 %nj, 1
  %cmp102 = icmp slt i32 %j.1, %sub101
  br i1 %cmp102, label %for.body.104, label %for.end.115

for.body.104:                                     ; preds = %for.cond.100
  %mul105 = mul nsw i32 %i.1, %nj
  %add106 = add nsw i32 %mul105, %j.1
  %idxprom107 = sext i32 %add106 to i64
  %arrayidx108 = getelementptr inbounds i32, i32* %B, i64 %idxprom107
  %tmp3 = load i32, i32* %arrayidx108, align 4
  %mul109 = mul nsw i32 %i.1, %nj
  %add110 = add nsw i32 %mul109, %j.1
  %idxprom111 = sext i32 %add110 to i64
  %arrayidx112 = getelementptr inbounds i32, i32* %A, i64 %idxprom111
  store i32 %tmp3, i32* %arrayidx112, align 4
  br label %for.inc.113

for.inc.113:                                      ; preds = %for.body.104
  %inc114 = add nsw i32 %j.1, 1
  br label %for.cond.100

for.end.115:                                      ; preds = %for.cond.100
  br label %for.inc.116

for.inc.116:                                      ; preds = %for.end.115
  %inc117 = add nsw i32 %i.1, 1
  br label %for.cond.95

for.end.118:                                      ; preds = %for.cond.95
  br label %for.inc.119

for.inc.119:                                      ; preds = %for.end.118
  %inc120 = add nsw i32 %t.0, 1
  br label %for.cond

for.end.121:                                      ; preds = %for.cond
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
  call void @init_array(i32 1024, i32 1024, i32* %tmp, i32* %tmp1)
  %call6 = call double @rtclock()
  call void @fur(i32 10, i32 1024, i32 1024, i32* %tmp, i32* %tmp1)
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

declare i32 @fprintf(%struct._IO_FILE*, i8*, ...) #2

; Function Attrs: nounwind
declare void @free(i8*) #1

attributes #0 = { nounwind uwtable "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nounwind }

!llvm.ident = !{!0}

!0 = !{!"clang version 3.7.1 (https://github.com/llvm-mirror/clang.git 0dbefa1b83eb90f7a06b5df5df254ce32be3db4b) (https://github.com/llvm-mirror/llvm.git 33c352b3eda89abc24e7511d9045fa2e499a42e3)"}
