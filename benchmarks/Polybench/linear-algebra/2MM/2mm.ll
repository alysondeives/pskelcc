; ModuleID = '2mm-base.ll'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, i8*, i8*, i8*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type { %struct._IO_marker*, %struct._IO_FILE*, i32 }
%struct.timezone = type { i32, i32 }
%struct.timeval = type { i64, i64 }

@.str = private unnamed_addr constant [35 x i8] c"Error return from gettimeofday: %d\00", align 1
@.str.1 = private unnamed_addr constant [74 x i8] c"Non-Matching CPU-GPU Outputs Beyond Error Threshold of %4.2f Percent: %d\0A\00", align 1
@stdout = external global %struct._IO_FILE*, align 8
@.str.2 = private unnamed_addr constant [63 x i8] c"<< Linear Algebra: 2 Matrix Multiplications (D=A.B; E=C.D) >>\0A\00", align 1
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
define void @init_array(i32 %ni, i32 %nj, i32 %nk, i32 %nl, float* %A, float* %B, float* %C, float* %D) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.7, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc8, %for.inc.7 ]
  %cmp = icmp slt i32 %i.0, %ni
  br i1 %cmp, label %for.body, label %for.end.9

for.body:                                         ; preds = %for.cond
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %j.0 = phi i32 [ 0, %for.body ], [ %inc, %for.inc ]
  %cmp2 = icmp slt i32 %j.0, %nk
  br i1 %cmp2, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.cond.1
  %conv = sitofp i32 %i.0 to float
  %conv4 = sitofp i32 %j.0 to float
  %mul = fmul float %conv, %conv4
  %conv5 = sitofp i32 %ni to float
  %div = fdiv float %mul, %conv5
  %mul6 = mul nsw i32 %i.0, %ni
  %add = add nsw i32 %mul6, %j.0
  %idxprom = sext i32 %add to i64
  %arrayidx = getelementptr inbounds float, float* %A, i64 %idxprom
  store float %div, float* %arrayidx, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.3
  %inc = add nsw i32 %j.0, 1
  br label %for.cond.1

for.end:                                          ; preds = %for.cond.1
  br label %for.inc.7

for.inc.7:                                        ; preds = %for.end
  %inc8 = add nsw i32 %i.0, 1
  br label %for.cond

for.end.9:                                        ; preds = %for.cond
  br label %for.cond.10

for.cond.10:                                      ; preds = %for.inc.31, %for.end.9
  %i.1 = phi i32 [ 0, %for.end.9 ], [ %inc32, %for.inc.31 ]
  %cmp11 = icmp slt i32 %i.1, %nk
  br i1 %cmp11, label %for.body.13, label %for.end.33

for.body.13:                                      ; preds = %for.cond.10
  br label %for.cond.14

for.cond.14:                                      ; preds = %for.inc.28, %for.body.13
  %j.1 = phi i32 [ 0, %for.body.13 ], [ %inc29, %for.inc.28 ]
  %cmp15 = icmp slt i32 %j.1, %nj
  br i1 %cmp15, label %for.body.17, label %for.end.30

for.body.17:                                      ; preds = %for.cond.14
  %conv18 = sitofp i32 %i.1 to float
  %add19 = add nsw i32 %j.1, 1
  %conv20 = sitofp i32 %add19 to float
  %mul21 = fmul float %conv18, %conv20
  %conv22 = sitofp i32 %nj to float
  %div23 = fdiv float %mul21, %conv22
  %mul24 = mul nsw i32 %i.1, %nk
  %add25 = add nsw i32 %mul24, %j.1
  %idxprom26 = sext i32 %add25 to i64
  %arrayidx27 = getelementptr inbounds float, float* %B, i64 %idxprom26
  store float %div23, float* %arrayidx27, align 4
  br label %for.inc.28

for.inc.28:                                       ; preds = %for.body.17
  %inc29 = add nsw i32 %j.1, 1
  br label %for.cond.14

for.end.30:                                       ; preds = %for.cond.14
  br label %for.inc.31

for.inc.31:                                       ; preds = %for.end.30
  %inc32 = add nsw i32 %i.1, 1
  br label %for.cond.10

for.end.33:                                       ; preds = %for.cond.10
  br label %for.cond.34

for.cond.34:                                      ; preds = %for.inc.55, %for.end.33
  %i.2 = phi i32 [ 0, %for.end.33 ], [ %inc56, %for.inc.55 ]
  %cmp35 = icmp slt i32 %i.2, %nl
  br i1 %cmp35, label %for.body.37, label %for.end.57

for.body.37:                                      ; preds = %for.cond.34
  br label %for.cond.38

for.cond.38:                                      ; preds = %for.inc.52, %for.body.37
  %j.2 = phi i32 [ 0, %for.body.37 ], [ %inc53, %for.inc.52 ]
  %cmp39 = icmp slt i32 %j.2, %nj
  br i1 %cmp39, label %for.body.41, label %for.end.54

for.body.41:                                      ; preds = %for.cond.38
  %conv42 = sitofp i32 %i.2 to float
  %add43 = add nsw i32 %j.2, 3
  %conv44 = sitofp i32 %add43 to float
  %mul45 = fmul float %conv42, %conv44
  %conv46 = sitofp i32 %nl to float
  %div47 = fdiv float %mul45, %conv46
  %mul48 = mul nsw i32 %i.2, %nl
  %add49 = add nsw i32 %mul48, %j.2
  %idxprom50 = sext i32 %add49 to i64
  %arrayidx51 = getelementptr inbounds float, float* %C, i64 %idxprom50
  store float %div47, float* %arrayidx51, align 4
  br label %for.inc.52

for.inc.52:                                       ; preds = %for.body.41
  %inc53 = add nsw i32 %j.2, 1
  br label %for.cond.38

for.end.54:                                       ; preds = %for.cond.38
  br label %for.inc.55

for.inc.55:                                       ; preds = %for.end.54
  %inc56 = add nsw i32 %i.2, 1
  br label %for.cond.34

for.end.57:                                       ; preds = %for.cond.34
  br label %for.cond.58

for.cond.58:                                      ; preds = %for.inc.79, %for.end.57
  %i.3 = phi i32 [ 0, %for.end.57 ], [ %inc80, %for.inc.79 ]
  %cmp59 = icmp slt i32 %i.3, %ni
  br i1 %cmp59, label %for.body.61, label %for.end.81

for.body.61:                                      ; preds = %for.cond.58
  br label %for.cond.62

for.cond.62:                                      ; preds = %for.inc.76, %for.body.61
  %j.3 = phi i32 [ 0, %for.body.61 ], [ %inc77, %for.inc.76 ]
  %cmp63 = icmp slt i32 %j.3, %nl
  br i1 %cmp63, label %for.body.65, label %for.end.78

for.body.65:                                      ; preds = %for.cond.62
  %conv66 = sitofp i32 %i.3 to float
  %add67 = add nsw i32 %j.3, 2
  %conv68 = sitofp i32 %add67 to float
  %mul69 = fmul float %conv66, %conv68
  %conv70 = sitofp i32 %nk to float
  %div71 = fdiv float %mul69, %conv70
  %mul72 = mul nsw i32 %i.3, %nl
  %add73 = add nsw i32 %mul72, %j.3
  %idxprom74 = sext i32 %add73 to i64
  %arrayidx75 = getelementptr inbounds float, float* %D, i64 %idxprom74
  store float %div71, float* %arrayidx75, align 4
  br label %for.inc.76

for.inc.76:                                       ; preds = %for.body.65
  %inc77 = add nsw i32 %j.3, 1
  br label %for.cond.62

for.end.78:                                       ; preds = %for.cond.62
  br label %for.inc.79

for.inc.79:                                       ; preds = %for.end.78
  %inc80 = add nsw i32 %i.3, 1
  br label %for.cond.58

for.end.81:                                       ; preds = %for.cond.58
  ret void
}

; Function Attrs: nounwind uwtable
define void @compareResults(i32 %ni, i32 %nl, float* %E, float* %E_GPU) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.13, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc14, %for.inc.13 ]
  %fail.0 = phi i32 [ 0, %entry ], [ %fail.1, %for.inc.13 ]
  %cmp = icmp slt i32 %i.0, %nl
  br i1 %cmp, label %for.body, label %for.end.15

for.body:                                         ; preds = %for.cond
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %j.0 = phi i32 [ 0, %for.body ], [ %inc12, %for.inc ]
  %fail.1 = phi i32 [ %fail.0, %for.body ], [ %fail.2, %for.inc ]
  %cmp2 = icmp slt i32 %j.0, %ni
  br i1 %cmp2, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.cond.1
  %mul = mul nsw i32 %i.0, %ni
  %add = add nsw i32 %mul, %j.0
  %idxprom = sext i32 %add to i64
  %arrayidx = getelementptr inbounds float, float* %E, i64 %idxprom
  %tmp = load float, float* %arrayidx, align 4
  %conv = fpext float %tmp to double
  %mul4 = mul nsw i32 %i.0, %ni
  %add5 = add nsw i32 %mul4, %j.0
  %idxprom6 = sext i32 %add5 to i64
  %arrayidx7 = getelementptr inbounds float, float* %E_GPU, i64 %idxprom6
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
define void @mm2(i32 %ni, i32 %nj, i32 %nk, i32 %nl, float* %A, float* %B, float* %C, float* %D, float* %E) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.24, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc25, %for.inc.24 ]
  %cmp = icmp slt i32 %i.0, %ni
  br i1 %cmp, label %for.body, label %for.end.26

for.body:                                         ; preds = %for.cond
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc.21, %for.body
  %j.0 = phi i32 [ 0, %for.body ], [ %inc22, %for.inc.21 ]
  %cmp2 = icmp slt i32 %j.0, %nj
  br i1 %cmp2, label %for.body.3, label %for.end.23

for.body.3:                                       ; preds = %for.cond.1
  %mul = mul nsw i32 %i.0, %nj
  %add = add nsw i32 %mul, %j.0
  %idxprom = sext i32 %add to i64
  %arrayidx = getelementptr inbounds float, float* %C, i64 %idxprom
  store float 0.000000e+00, float* %arrayidx, align 4
  br label %for.cond.4

for.cond.4:                                       ; preds = %for.inc, %for.body.3
  %k.0 = phi i32 [ 0, %for.body.3 ], [ %inc, %for.inc ]
  %cmp5 = icmp slt i32 %k.0, %nk
  br i1 %cmp5, label %for.body.6, label %for.end

for.body.6:                                       ; preds = %for.cond.4
  %mul7 = mul nsw i32 %i.0, %nk
  %add8 = add nsw i32 %mul7, %k.0
  %idxprom9 = sext i32 %add8 to i64
  %arrayidx10 = getelementptr inbounds float, float* %A, i64 %idxprom9
  %tmp = load float, float* %arrayidx10, align 4
  %mul11 = mul nsw i32 %k.0, %nj
  %add12 = add nsw i32 %mul11, %j.0
  %idxprom13 = sext i32 %add12 to i64
  %arrayidx14 = getelementptr inbounds float, float* %B, i64 %idxprom13
  %tmp1 = load float, float* %arrayidx14, align 4
  %mul15 = fmul float %tmp, %tmp1
  %mul16 = mul nsw i32 %i.0, %nj
  %add17 = add nsw i32 %mul16, %j.0
  %idxprom18 = sext i32 %add17 to i64
  %arrayidx19 = getelementptr inbounds float, float* %C, i64 %idxprom18
  %tmp2 = load float, float* %arrayidx19, align 4
  %add20 = fadd float %tmp2, %mul15
  store float %add20, float* %arrayidx19, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.6
  %inc = add nsw i32 %k.0, 1
  br label %for.cond.4

for.end:                                          ; preds = %for.cond.4
  br label %for.inc.21

for.inc.21:                                       ; preds = %for.end
  %inc22 = add nsw i32 %j.0, 1
  br label %for.cond.1

for.end.23:                                       ; preds = %for.cond.1
  br label %for.inc.24

for.inc.24:                                       ; preds = %for.end.23
  %inc25 = add nsw i32 %i.0, 1
  br label %for.cond

for.end.26:                                       ; preds = %for.cond
  br label %for.cond.27

for.cond.27:                                      ; preds = %for.inc.60, %for.end.26
  %i.1 = phi i32 [ 0, %for.end.26 ], [ %inc61, %for.inc.60 ]
  %cmp28 = icmp slt i32 %i.1, %ni
  br i1 %cmp28, label %for.body.29, label %for.end.62

for.body.29:                                      ; preds = %for.cond.27
  br label %for.cond.30

for.cond.30:                                      ; preds = %for.inc.57, %for.body.29
  %j.1 = phi i32 [ 0, %for.body.29 ], [ %inc58, %for.inc.57 ]
  %cmp31 = icmp slt i32 %j.1, %nl
  br i1 %cmp31, label %for.body.32, label %for.end.59

for.body.32:                                      ; preds = %for.cond.30
  %mul33 = mul nsw i32 %i.1, %nl
  %add34 = add nsw i32 %mul33, %j.1
  %idxprom35 = sext i32 %add34 to i64
  %arrayidx36 = getelementptr inbounds float, float* %E, i64 %idxprom35
  store float 0.000000e+00, float* %arrayidx36, align 4
  br label %for.cond.37

for.cond.37:                                      ; preds = %for.inc.54, %for.body.32
  %k.1 = phi i32 [ 0, %for.body.32 ], [ %inc55, %for.inc.54 ]
  %cmp38 = icmp slt i32 %k.1, %nj
  br i1 %cmp38, label %for.body.39, label %for.end.56

for.body.39:                                      ; preds = %for.cond.37
  %mul40 = mul nsw i32 %i.1, %nj
  %add41 = add nsw i32 %mul40, %k.1
  %idxprom42 = sext i32 %add41 to i64
  %arrayidx43 = getelementptr inbounds float, float* %C, i64 %idxprom42
  %tmp3 = load float, float* %arrayidx43, align 4
  %mul44 = mul nsw i32 %k.1, %nl
  %add45 = add nsw i32 %mul44, %j.1
  %idxprom46 = sext i32 %add45 to i64
  %arrayidx47 = getelementptr inbounds float, float* %D, i64 %idxprom46
  %tmp4 = load float, float* %arrayidx47, align 4
  %mul48 = fmul float %tmp3, %tmp4
  %mul49 = mul nsw i32 %i.1, %nl
  %add50 = add nsw i32 %mul49, %j.1
  %idxprom51 = sext i32 %add50 to i64
  %arrayidx52 = getelementptr inbounds float, float* %E, i64 %idxprom51
  %tmp5 = load float, float* %arrayidx52, align 4
  %add53 = fadd float %tmp5, %mul48
  store float %add53, float* %arrayidx52, align 4
  br label %for.inc.54

for.inc.54:                                       ; preds = %for.body.39
  %inc55 = add nsw i32 %k.1, 1
  br label %for.cond.37

for.end.56:                                       ; preds = %for.cond.37
  br label %for.inc.57

for.inc.57:                                       ; preds = %for.end.56
  %inc58 = add nsw i32 %j.1, 1
  br label %for.cond.30

for.end.59:                                       ; preds = %for.cond.30
  br label %for.inc.60

for.inc.60:                                       ; preds = %for.end.59
  %inc61 = add nsw i32 %i.1, 1
  br label %for.cond.27

for.end.62:                                       ; preds = %for.cond.27
  ret void
}

; Function Attrs: nounwind uwtable
define i32 @main(i32 %argc, i8** %argv) #0 {
entry:
  %mul = mul nsw i32 2048, 2048
  %conv = sext i32 %mul to i64
  %mul1 = mul i64 %conv, 4
  %call = call noalias i8* @malloc(i64 %mul1) #3
  %tmp = bitcast i8* %call to float*
  %mul2 = mul nsw i32 2048, 2048
  %conv3 = sext i32 %mul2 to i64
  %mul4 = mul i64 %conv3, 4
  %call5 = call noalias i8* @malloc(i64 %mul4) #3
  %tmp1 = bitcast i8* %call5 to float*
  %mul6 = mul nsw i32 2048, 2048
  %conv7 = sext i32 %mul6 to i64
  %mul8 = mul i64 %conv7, 4
  %call9 = call noalias i8* @malloc(i64 %mul8) #3
  %tmp2 = bitcast i8* %call9 to float*
  %mul10 = mul nsw i32 2048, 2048
  %conv11 = sext i32 %mul10 to i64
  %mul12 = mul i64 %conv11, 4
  %call13 = call noalias i8* @malloc(i64 %mul12) #3
  %tmp3 = bitcast i8* %call13 to float*
  %mul14 = mul nsw i32 2048, 2048
  %conv15 = sext i32 %mul14 to i64
  %mul16 = mul i64 %conv15, 4
  %call17 = call noalias i8* @malloc(i64 %mul16) #3
  %tmp4 = bitcast i8* %call17 to float*
  %tmp5 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %call18 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %tmp5, i8* getelementptr inbounds ([63 x i8], [63 x i8]* @.str.2, i32 0, i32 0))
  call void @init_array(i32 2048, i32 2048, i32 2048, i32 2048, float* %tmp1, float* %tmp2, float* %tmp, float* %tmp3)
  %call19 = call double @rtclock()
  call void @mm2(i32 2048, i32 2048, i32 2048, i32 2048, float* %tmp1, float* %tmp2, float* %tmp, float* %tmp3, float* %tmp4)
  %call20 = call double @rtclock()
  %tmp6 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %sub = fsub double %call20, %call19
  %call21 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %tmp6, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.3, i32 0, i32 0), double %sub)
  %tmp7 = bitcast float* %tmp to i8*
  call void @free(i8* %tmp7) #3
  %tmp8 = bitcast float* %tmp1 to i8*
  call void @free(i8* %tmp8) #3
  %tmp9 = bitcast float* %tmp2 to i8*
  call void @free(i8* %tmp9) #3
  %tmp10 = bitcast float* %tmp3 to i8*
  call void @free(i8* %tmp10) #3
  %tmp11 = bitcast float* %tmp4 to i8*
  call void @free(i8* %tmp11) #3
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
