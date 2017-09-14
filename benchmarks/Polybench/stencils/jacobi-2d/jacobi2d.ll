; ModuleID = 'jacobi2d-base.ll'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, i8*, i8*, i8*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type { %struct._IO_marker*, %struct._IO_FILE*, i32 }
%struct.timezone = type { i32, i32 }
%struct.timeval = type { i64, i64 }

@.str = private unnamed_addr constant [35 x i8] c"Error return from gettimeofday: %d\00", align 1
@stdout = external global %struct._IO_FILE*, align 8
@.str.1 = private unnamed_addr constant [22 x i8] c"CPU Runtime: %0.6lfs\0A\00", align 1
@D = common global float* null, align 8
@G = common global float* null, align 8

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
define void @init_array(i32 %n, float* %A, float* %B) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.20, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc21, %for.inc.20 ]
  %cmp = icmp slt i32 %i.0, %n
  br i1 %cmp, label %for.body, label %for.end.22

for.body:                                         ; preds = %for.cond
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %j.0 = phi i32 [ 0, %for.body ], [ %inc, %for.inc ]
  %cmp2 = icmp slt i32 %j.0, %n
  br i1 %cmp2, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.cond.1
  %conv = sitofp i32 %i.0 to float
  %add = add nsw i32 %j.0, 2
  %conv4 = sitofp i32 %add to float
  %mul = fmul float %conv, %conv4
  %add5 = fadd float %mul, 2.000000e+00
  %conv6 = sitofp i32 %n to float
  %div = fdiv float %add5, %conv6
  %mul7 = mul nsw i32 %i.0, %n
  %add8 = add nsw i32 %mul7, %j.0
  %idxprom = sext i32 %add8 to i64
  %arrayidx = getelementptr inbounds float, float* %A, i64 %idxprom
  store float %div, float* %arrayidx, align 4
  %conv9 = sitofp i32 %i.0 to float
  %add10 = add nsw i32 %j.0, 3
  %conv11 = sitofp i32 %add10 to float
  %mul12 = fmul float %conv9, %conv11
  %add13 = fadd float %mul12, 3.000000e+00
  %conv14 = sitofp i32 %n to float
  %div15 = fdiv float %add13, %conv14
  %mul16 = mul nsw i32 %i.0, %n
  %add17 = add nsw i32 %mul16, %j.0
  %idxprom18 = sext i32 %add17 to i64
  %arrayidx19 = getelementptr inbounds float, float* %B, i64 %idxprom18
  store float %div15, float* %arrayidx19, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.3
  %inc = add nsw i32 %j.0, 1
  br label %for.cond.1

for.end:                                          ; preds = %for.cond.1
  br label %for.inc.20

for.inc.20:                                       ; preds = %for.end
  %inc21 = add nsw i32 %i.0, 1
  br label %for.cond

for.end.22:                                       ; preds = %for.cond
  ret void
}

; Function Attrs: nounwind uwtable
define i32 @main(i32 %argc, i8** %argv) #0 {
entry:
  %mul = mul nsw i32 1024, 1024
  %conv = sext i32 %mul to i64
  %mul1 = mul i64 %conv, 4
  %call = call noalias i8* @malloc(i64 %mul1) #3
  %tmp = bitcast i8* %call to float*
  %mul2 = mul nsw i32 1024, 1024
  %conv3 = sext i32 %mul2 to i64
  %mul4 = mul i64 %conv3, 4
  %call5 = call noalias i8* @malloc(i64 %mul4) #3
  %tmp1 = bitcast i8* %call5 to float*
  call void @init_array(i32 1024, float* %tmp, float* %tmp1)
  %call6 = call double @rtclock()
  call void @jacobi2d(i32 10, i32 1024, float* %tmp, float* %tmp1)
  %call7 = call double @rtclock()
  %tmp2 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %sub = fsub double %call7, %call6
  %call8 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %tmp2, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.1, i32 0, i32 0), double %sub)
  %tmp3 = bitcast float* %tmp to i8*
  call void @free(i8* %tmp3) #3
  %tmp4 = bitcast float* %tmp1 to i8*
  call void @free(i8* %tmp4) #3
  ret i32 0
}

; Function Attrs: nounwind
declare noalias i8* @malloc(i64) #1

; Function Attrs: nounwind uwtable
define internal void @jacobi2d(i32 %tsteps, i32 %n, float* %A, float* %B) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.62, %entry
  %t.0 = phi i32 [ 0, %entry ], [ %inc63, %for.inc.62 ]
  %cmp = icmp slt i32 %t.0, %tsteps
  br i1 %cmp, label %for.body, label %for.end.64

for.body:                                         ; preds = %for.cond
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc.37, %for.body
  %i.0 = phi i32 [ 1, %for.body ], [ %inc38, %for.inc.37 ]
  %sub = sub nsw i32 %n, 1
  %cmp2 = icmp slt i32 %i.0, %sub
  br i1 %cmp2, label %for.body.3, label %for.end.39

for.body.3:                                       ; preds = %for.cond.1
  br label %for.cond.4

for.cond.4:                                       ; preds = %for.inc, %for.body.3
  %j.0 = phi i32 [ 1, %for.body.3 ], [ %inc, %for.inc ]
  %sub5 = sub nsw i32 %n, 1
  %cmp6 = icmp slt i32 %j.0, %sub5
  br i1 %cmp6, label %for.body.7, label %for.end

for.body.7:                                       ; preds = %for.cond.4
  %mul = mul nsw i32 %i.0, %n
  %add = add nsw i32 %mul, %j.0
  %idxprom = sext i32 %add to i64
  %arrayidx = getelementptr inbounds float, float* %A, i64 %idxprom
  %tmp = load float, float* %arrayidx, align 4
  %mul8 = mul nsw i32 %i.0, %n
  %sub9 = sub nsw i32 %j.0, 1
  %add10 = add nsw i32 %mul8, %sub9
  %idxprom11 = sext i32 %add10 to i64
  %arrayidx12 = getelementptr inbounds float, float* %A, i64 %idxprom11
  %tmp1 = load float, float* %arrayidx12, align 4
  %add13 = fadd float %tmp, %tmp1
  %mul14 = mul nsw i32 %i.0, %n
  %add15 = add nsw i32 %j.0, 1
  %add16 = add nsw i32 %mul14, %add15
  %idxprom17 = sext i32 %add16 to i64
  %arrayidx18 = getelementptr inbounds float, float* %A, i64 %idxprom17
  %tmp2 = load float, float* %arrayidx18, align 4
  %add19 = fadd float %add13, %tmp2
  %add20 = add nsw i32 %i.0, 1
  %mul21 = mul nsw i32 %add20, %n
  %add22 = add nsw i32 %mul21, %j.0
  %idxprom23 = sext i32 %add22 to i64
  %arrayidx24 = getelementptr inbounds float, float* %A, i64 %idxprom23
  %tmp3 = load float, float* %arrayidx24, align 4
  %add25 = fadd float %add19, %tmp3
  %sub26 = sub nsw i32 %i.0, 1
  %mul27 = mul nsw i32 %sub26, %n
  %add28 = add nsw i32 %mul27, %j.0
  %idxprom29 = sext i32 %add28 to i64
  %arrayidx30 = getelementptr inbounds float, float* %A, i64 %idxprom29
  %tmp4 = load float, float* %arrayidx30, align 4
  %add31 = fadd float %add25, %tmp4
  %mul32 = fmul float 0x3FC99999A0000000, %add31
  %mul33 = mul nsw i32 %i.0, %n
  %add34 = add nsw i32 %mul33, %j.0
  %idxprom35 = sext i32 %add34 to i64
  %arrayidx36 = getelementptr inbounds float, float* %B, i64 %idxprom35
  store float %mul32, float* %arrayidx36, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.7
  %inc = add nsw i32 %j.0, 1
  br label %for.cond.4

for.end:                                          ; preds = %for.cond.4
  br label %for.inc.37

for.inc.37:                                       ; preds = %for.end
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
  %arrayidx51 = getelementptr inbounds float, float* %B, i64 %idxprom50
  %tmp5 = load float, float* %arrayidx51, align 4
  %mul52 = mul nsw i32 %i.1, %n
  %add53 = add nsw i32 %mul52, %j.1
  %idxprom54 = sext i32 %add53 to i64
  %arrayidx55 = getelementptr inbounds float, float* %A, i64 %idxprom54
  store float %tmp5, float* %arrayidx55, align 4
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
  br label %for.cond.65

for.cond.65:                                      ; preds = %for.inc.137, %for.end.64
  %t.1 = phi i32 [ 0, %for.end.64 ], [ %inc138, %for.inc.137 ]
  %cmp66 = icmp slt i32 %t.1, %tsteps
  br i1 %cmp66, label %for.body.67, label %for.end.139

for.body.67:                                      ; preds = %for.cond.65
  br label %for.cond.68

for.cond.68:                                      ; preds = %for.inc.112, %for.body.67
  %i.2 = phi i32 [ 1, %for.body.67 ], [ %inc113, %for.inc.112 ]
  %sub69 = sub nsw i32 %n, 1
  %cmp70 = icmp slt i32 %i.2, %sub69
  br i1 %cmp70, label %for.body.71, label %for.end.114

for.body.71:                                      ; preds = %for.cond.68
  br label %for.cond.72

for.cond.72:                                      ; preds = %for.inc.109, %for.body.71
  %j.2 = phi i32 [ 1, %for.body.71 ], [ %inc110, %for.inc.109 ]
  %sub73 = sub nsw i32 %n, 1
  %cmp74 = icmp slt i32 %j.2, %sub73
  br i1 %cmp74, label %for.body.75, label %for.end.111

for.body.75:                                      ; preds = %for.cond.72
  %mul76 = mul nsw i32 %i.2, %n
  %add77 = add nsw i32 %mul76, %j.2
  %idxprom78 = sext i32 %add77 to i64
  %tmp6 = load float*, float** @D, align 8
  %arrayidx79 = getelementptr inbounds float, float* %tmp6, i64 %idxprom78
  %tmp7 = load float, float* %arrayidx79, align 4
  %mul80 = mul nsw i32 %i.2, %n
  %sub81 = sub nsw i32 %j.2, 1
  %add82 = add nsw i32 %mul80, %sub81
  %idxprom83 = sext i32 %add82 to i64
  %tmp8 = load float*, float** @D, align 8
  %arrayidx84 = getelementptr inbounds float, float* %tmp8, i64 %idxprom83
  %tmp9 = load float, float* %arrayidx84, align 4
  %add85 = fadd float %tmp7, %tmp9
  %mul86 = mul nsw i32 %i.2, %n
  %add87 = add nsw i32 %j.2, 1
  %add88 = add nsw i32 %mul86, %add87
  %idxprom89 = sext i32 %add88 to i64
  %tmp10 = load float*, float** @D, align 8
  %arrayidx90 = getelementptr inbounds float, float* %tmp10, i64 %idxprom89
  %tmp11 = load float, float* %arrayidx90, align 4
  %add91 = fadd float %add85, %tmp11
  %add92 = add nsw i32 %i.2, 1
  %mul93 = mul nsw i32 %add92, %n
  %add94 = add nsw i32 %mul93, %j.2
  %idxprom95 = sext i32 %add94 to i64
  %tmp12 = load float*, float** @D, align 8
  %arrayidx96 = getelementptr inbounds float, float* %tmp12, i64 %idxprom95
  %tmp13 = load float, float* %arrayidx96, align 4
  %add97 = fadd float %add91, %tmp13
  %sub98 = sub nsw i32 %i.2, 1
  %mul99 = mul nsw i32 %sub98, %n
  %add100 = add nsw i32 %mul99, %j.2
  %idxprom101 = sext i32 %add100 to i64
  %tmp14 = load float*, float** @D, align 8
  %arrayidx102 = getelementptr inbounds float, float* %tmp14, i64 %idxprom101
  %tmp15 = load float, float* %arrayidx102, align 4
  %add103 = fadd float %add97, %tmp15
  %mul104 = fmul float 0x3FC99999A0000000, %add103
  %mul105 = mul nsw i32 %i.2, %n
  %add106 = add nsw i32 %mul105, %j.2
  %idxprom107 = sext i32 %add106 to i64
  %tmp16 = load float*, float** @G, align 8
  %arrayidx108 = getelementptr inbounds float, float* %tmp16, i64 %idxprom107
  store float %mul104, float* %arrayidx108, align 4
  br label %for.inc.109

for.inc.109:                                      ; preds = %for.body.75
  %inc110 = add nsw i32 %j.2, 1
  br label %for.cond.72

for.end.111:                                      ; preds = %for.cond.72
  br label %for.inc.112

for.inc.112:                                      ; preds = %for.end.111
  %inc113 = add nsw i32 %i.2, 1
  br label %for.cond.68

for.end.114:                                      ; preds = %for.cond.68
  br label %for.cond.115

for.cond.115:                                     ; preds = %for.inc.134, %for.end.114
  %i.3 = phi i32 [ 1, %for.end.114 ], [ %inc135, %for.inc.134 ]
  %sub116 = sub nsw i32 %n, 1
  %cmp117 = icmp slt i32 %i.3, %sub116
  br i1 %cmp117, label %for.body.118, label %for.end.136

for.body.118:                                     ; preds = %for.cond.115
  br label %for.cond.119

for.cond.119:                                     ; preds = %for.inc.131, %for.body.118
  %j.3 = phi i32 [ 1, %for.body.118 ], [ %inc132, %for.inc.131 ]
  %sub120 = sub nsw i32 %n, 1
  %cmp121 = icmp slt i32 %j.3, %sub120
  br i1 %cmp121, label %for.body.122, label %for.end.133

for.body.122:                                     ; preds = %for.cond.119
  %mul123 = mul nsw i32 %i.3, %n
  %add124 = add nsw i32 %mul123, %j.3
  %idxprom125 = sext i32 %add124 to i64
  %tmp17 = load float*, float** @G, align 8
  %arrayidx126 = getelementptr inbounds float, float* %tmp17, i64 %idxprom125
  %tmp18 = load float, float* %arrayidx126, align 4
  %mul127 = mul nsw i32 %i.3, %n
  %add128 = add nsw i32 %mul127, %j.3
  %idxprom129 = sext i32 %add128 to i64
  %tmp19 = load float*, float** @D, align 8
  %arrayidx130 = getelementptr inbounds float, float* %tmp19, i64 %idxprom129
  store float %tmp18, float* %arrayidx130, align 4
  br label %for.inc.131

for.inc.131:                                      ; preds = %for.body.122
  %inc132 = add nsw i32 %j.3, 1
  br label %for.cond.119

for.end.133:                                      ; preds = %for.cond.119
  br label %for.inc.134

for.inc.134:                                      ; preds = %for.end.133
  %inc135 = add nsw i32 %i.3, 1
  br label %for.cond.115

for.end.136:                                      ; preds = %for.cond.115
  br label %for.inc.137

for.inc.137:                                      ; preds = %for.end.136
  %inc138 = add nsw i32 %t.1, 1
  br label %for.cond.65

for.end.139:                                      ; preds = %for.cond.65
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
