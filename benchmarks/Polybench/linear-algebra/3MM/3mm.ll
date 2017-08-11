; ModuleID = '3mm-base.ll'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, i8*, i8*, i8*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type { %struct._IO_marker*, %struct._IO_FILE*, i32 }
%struct.timezone = type { i32, i32 }
%struct.timeval = type { i64, i64 }

@.str = private unnamed_addr constant [35 x i8] c"Error return from gettimeofday: %d\00", align 1
@.str.1 = private unnamed_addr constant [74 x i8] c"Non-Matching CPU-GPU Outputs Beyond Error Threshold of %4.2f Percent: %d\0A\00", align 1
@stdout = external global %struct._IO_FILE*, align 8
@.str.2 = private unnamed_addr constant [70 x i8] c"<< Linear Algebra: 3 Matrix Multiplications (E=A.B; F=C.D; G=E.F) >>\0A\00", align 1
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
define void @init_array(float* %A, float* %B, float* %C, float* %D) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.6, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc7, %for.inc.6 ]
  %cmp = icmp slt i32 %i.0, 2048
  br i1 %cmp, label %for.body, label %for.end.8

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
  br label %for.inc.6

for.inc.6:                                        ; preds = %for.end
  %inc7 = add nsw i32 %i.0, 1
  br label %for.cond

for.end.8:                                        ; preds = %for.cond
  br label %for.cond.9

for.cond.9:                                       ; preds = %for.inc.29, %for.end.8
  %i.1 = phi i32 [ 0, %for.end.8 ], [ %inc30, %for.inc.29 ]
  %cmp10 = icmp slt i32 %i.1, 2048
  br i1 %cmp10, label %for.body.12, label %for.end.31

for.body.12:                                      ; preds = %for.cond.9
  br label %for.cond.13

for.cond.13:                                      ; preds = %for.inc.26, %for.body.12
  %j.1 = phi i32 [ 0, %for.body.12 ], [ %inc27, %for.inc.26 ]
  %cmp14 = icmp slt i32 %j.1, 2048
  br i1 %cmp14, label %for.body.16, label %for.end.28

for.body.16:                                      ; preds = %for.cond.13
  %conv17 = sitofp i32 %i.1 to float
  %add18 = add nsw i32 %j.1, 1
  %conv19 = sitofp i32 %add18 to float
  %mul20 = fmul float %conv17, %conv19
  %div21 = fdiv float %mul20, 2.048000e+03
  %mul22 = mul nsw i32 %i.1, 2048
  %add23 = add nsw i32 %mul22, %j.1
  %idxprom24 = sext i32 %add23 to i64
  %arrayidx25 = getelementptr inbounds float, float* %B, i64 %idxprom24
  store float %div21, float* %arrayidx25, align 4
  br label %for.inc.26

for.inc.26:                                       ; preds = %for.body.16
  %inc27 = add nsw i32 %j.1, 1
  br label %for.cond.13

for.end.28:                                       ; preds = %for.cond.13
  br label %for.inc.29

for.inc.29:                                       ; preds = %for.end.28
  %inc30 = add nsw i32 %i.1, 1
  br label %for.cond.9

for.end.31:                                       ; preds = %for.cond.9
  br label %for.cond.32

for.cond.32:                                      ; preds = %for.inc.52, %for.end.31
  %i.2 = phi i32 [ 0, %for.end.31 ], [ %inc53, %for.inc.52 ]
  %cmp33 = icmp slt i32 %i.2, 2048
  br i1 %cmp33, label %for.body.35, label %for.end.54

for.body.35:                                      ; preds = %for.cond.32
  br label %for.cond.36

for.cond.36:                                      ; preds = %for.inc.49, %for.body.35
  %j.2 = phi i32 [ 0, %for.body.35 ], [ %inc50, %for.inc.49 ]
  %cmp37 = icmp slt i32 %j.2, 2048
  br i1 %cmp37, label %for.body.39, label %for.end.51

for.body.39:                                      ; preds = %for.cond.36
  %conv40 = sitofp i32 %i.2 to float
  %add41 = add nsw i32 %j.2, 3
  %conv42 = sitofp i32 %add41 to float
  %mul43 = fmul float %conv40, %conv42
  %div44 = fdiv float %mul43, 2.048000e+03
  %mul45 = mul nsw i32 %i.2, 2048
  %add46 = add nsw i32 %mul45, %j.2
  %idxprom47 = sext i32 %add46 to i64
  %arrayidx48 = getelementptr inbounds float, float* %C, i64 %idxprom47
  store float %div44, float* %arrayidx48, align 4
  br label %for.inc.49

for.inc.49:                                       ; preds = %for.body.39
  %inc50 = add nsw i32 %j.2, 1
  br label %for.cond.36

for.end.51:                                       ; preds = %for.cond.36
  br label %for.inc.52

for.inc.52:                                       ; preds = %for.end.51
  %inc53 = add nsw i32 %i.2, 1
  br label %for.cond.32

for.end.54:                                       ; preds = %for.cond.32
  br label %for.cond.55

for.cond.55:                                      ; preds = %for.inc.75, %for.end.54
  %i.3 = phi i32 [ 0, %for.end.54 ], [ %inc76, %for.inc.75 ]
  %cmp56 = icmp slt i32 %i.3, 2048
  br i1 %cmp56, label %for.body.58, label %for.end.77

for.body.58:                                      ; preds = %for.cond.55
  br label %for.cond.59

for.cond.59:                                      ; preds = %for.inc.72, %for.body.58
  %j.3 = phi i32 [ 0, %for.body.58 ], [ %inc73, %for.inc.72 ]
  %cmp60 = icmp slt i32 %j.3, 2048
  br i1 %cmp60, label %for.body.62, label %for.end.74

for.body.62:                                      ; preds = %for.cond.59
  %conv63 = sitofp i32 %i.3 to float
  %add64 = add nsw i32 %j.3, 2
  %conv65 = sitofp i32 %add64 to float
  %mul66 = fmul float %conv63, %conv65
  %div67 = fdiv float %mul66, 2.048000e+03
  %mul68 = mul nsw i32 %i.3, 2048
  %add69 = add nsw i32 %mul68, %j.3
  %idxprom70 = sext i32 %add69 to i64
  %arrayidx71 = getelementptr inbounds float, float* %D, i64 %idxprom70
  store float %div67, float* %arrayidx71, align 4
  br label %for.inc.72

for.inc.72:                                       ; preds = %for.body.62
  %inc73 = add nsw i32 %j.3, 1
  br label %for.cond.59

for.end.74:                                       ; preds = %for.cond.59
  br label %for.inc.75

for.inc.75:                                       ; preds = %for.end.74
  %inc76 = add nsw i32 %i.3, 1
  br label %for.cond.55

for.end.77:                                       ; preds = %for.cond.55
  ret void
}

; Function Attrs: nounwind uwtable
define void @compareResults(float* %G, float* %G_outputFromGpu) #0 {
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
  %arrayidx = getelementptr inbounds float, float* %G, i64 %idxprom
  %tmp = load float, float* %arrayidx, align 4
  %conv = fpext float %tmp to double
  %mul4 = mul nsw i32 %i.0, 2048
  %add5 = add nsw i32 %mul4, %j.0
  %idxprom6 = sext i32 %add5 to i64
  %arrayidx7 = getelementptr inbounds float, float* %G_outputFromGpu, i64 %idxprom6
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
define void @mm3(i32 %ni, i32 %nj, i32 %nk, i32 %nl, i32 %nm, float* %A, float* %B, float* %C, float* %D, float* %E, float* %F, float* %G) #0 {
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
  %mul = mul nsw i32 %i.0, 2048
  %add = add nsw i32 %mul, %j.0
  %idxprom = sext i32 %add to i64
  %arrayidx = getelementptr inbounds float, float* %E, i64 %idxprom
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
  %arrayidx19 = getelementptr inbounds float, float* %E, i64 %idxprom18
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
  %cmp28 = icmp slt i32 %i.1, %nj
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
  %arrayidx36 = getelementptr inbounds float, float* %F, i64 %idxprom35
  store float 0.000000e+00, float* %arrayidx36, align 4
  br label %for.cond.37

for.cond.37:                                      ; preds = %for.inc.54, %for.body.32
  %k.1 = phi i32 [ 0, %for.body.32 ], [ %inc55, %for.inc.54 ]
  %cmp38 = icmp slt i32 %k.1, %nm
  br i1 %cmp38, label %for.body.39, label %for.end.56

for.body.39:                                      ; preds = %for.cond.37
  %mul40 = mul nsw i32 %i.1, %nm
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
  %arrayidx52 = getelementptr inbounds float, float* %F, i64 %idxprom51
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
  br label %for.cond.63

for.cond.63:                                      ; preds = %for.inc.96, %for.end.62
  %i.2 = phi i32 [ 0, %for.end.62 ], [ %inc97, %for.inc.96 ]
  %cmp64 = icmp slt i32 %i.2, %ni
  br i1 %cmp64, label %for.body.65, label %for.end.98

for.body.65:                                      ; preds = %for.cond.63
  br label %for.cond.66

for.cond.66:                                      ; preds = %for.inc.93, %for.body.65
  %j.2 = phi i32 [ 0, %for.body.65 ], [ %inc94, %for.inc.93 ]
  %cmp67 = icmp slt i32 %j.2, %nl
  br i1 %cmp67, label %for.body.68, label %for.end.95

for.body.68:                                      ; preds = %for.cond.66
  %mul69 = mul nsw i32 %i.2, %nl
  %add70 = add nsw i32 %mul69, %j.2
  %idxprom71 = sext i32 %add70 to i64
  %arrayidx72 = getelementptr inbounds float, float* %G, i64 %idxprom71
  store float 0.000000e+00, float* %arrayidx72, align 4
  br label %for.cond.73

for.cond.73:                                      ; preds = %for.inc.90, %for.body.68
  %k.2 = phi i32 [ 0, %for.body.68 ], [ %inc91, %for.inc.90 ]
  %cmp74 = icmp slt i32 %k.2, %nj
  br i1 %cmp74, label %for.body.75, label %for.end.92

for.body.75:                                      ; preds = %for.cond.73
  %mul76 = mul nsw i32 %i.2, %nj
  %add77 = add nsw i32 %mul76, %k.2
  %idxprom78 = sext i32 %add77 to i64
  %arrayidx79 = getelementptr inbounds float, float* %E, i64 %idxprom78
  %tmp6 = load float, float* %arrayidx79, align 4
  %mul80 = mul nsw i32 %k.2, %nl
  %add81 = add nsw i32 %mul80, %j.2
  %idxprom82 = sext i32 %add81 to i64
  %arrayidx83 = getelementptr inbounds float, float* %F, i64 %idxprom82
  %tmp7 = load float, float* %arrayidx83, align 4
  %mul84 = fmul float %tmp6, %tmp7
  %mul85 = mul nsw i32 %i.2, %nl
  %add86 = add nsw i32 %mul85, %j.2
  %idxprom87 = sext i32 %add86 to i64
  %arrayidx88 = getelementptr inbounds float, float* %G, i64 %idxprom87
  %tmp8 = load float, float* %arrayidx88, align 4
  %add89 = fadd float %tmp8, %mul84
  store float %add89, float* %arrayidx88, align 4
  br label %for.inc.90

for.inc.90:                                       ; preds = %for.body.75
  %inc91 = add nsw i32 %k.2, 1
  br label %for.cond.73

for.end.92:                                       ; preds = %for.cond.73
  br label %for.inc.93

for.inc.93:                                       ; preds = %for.end.92
  %inc94 = add nsw i32 %j.2, 1
  br label %for.cond.66

for.end.95:                                       ; preds = %for.cond.66
  br label %for.inc.96

for.inc.96:                                       ; preds = %for.end.95
  %inc97 = add nsw i32 %i.2, 1
  br label %for.cond.63

for.end.98:                                       ; preds = %for.cond.63
  ret void
}

; Function Attrs: nounwind uwtable
define i32 @main(i32 %argc, i8** %argv) #0 {
entry:
  %call = call noalias i8* @malloc(i64 16777216) #3
  %tmp = bitcast i8* %call to float*
  %call1 = call noalias i8* @malloc(i64 16777216) #3
  %tmp1 = bitcast i8* %call1 to float*
  %call2 = call noalias i8* @malloc(i64 16777216) #3
  %tmp2 = bitcast i8* %call2 to float*
  %call3 = call noalias i8* @malloc(i64 16777216) #3
  %tmp3 = bitcast i8* %call3 to float*
  %call4 = call noalias i8* @malloc(i64 16777216) #3
  %tmp4 = bitcast i8* %call4 to float*
  %call5 = call noalias i8* @malloc(i64 16777216) #3
  %tmp5 = bitcast i8* %call5 to float*
  %call6 = call noalias i8* @malloc(i64 16777216) #3
  %tmp6 = bitcast i8* %call6 to float*
  %tmp7 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %call7 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %tmp7, i8* getelementptr inbounds ([70 x i8], [70 x i8]* @.str.2, i32 0, i32 0))
  call void @init_array(float* %tmp, float* %tmp1, float* %tmp2, float* %tmp3)
  %call8 = call double @rtclock()
  call void @mm3(i32 2048, i32 2048, i32 2048, i32 2048, i32 2048, float* %tmp, float* %tmp1, float* %tmp2, float* %tmp3, float* %tmp4, float* %tmp5, float* %tmp6)
  %call9 = call double @rtclock()
  %tmp8 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %sub = fsub double %call9, %call8
  %call10 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %tmp8, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.3, i32 0, i32 0), double %sub)
  %tmp9 = bitcast float* %tmp to i8*
  call void @free(i8* %tmp9) #3
  %tmp10 = bitcast float* %tmp1 to i8*
  call void @free(i8* %tmp10) #3
  %tmp11 = bitcast float* %tmp2 to i8*
  call void @free(i8* %tmp11) #3
  %tmp12 = bitcast float* %tmp3 to i8*
  call void @free(i8* %tmp12) #3
  %tmp13 = bitcast float* %tmp4 to i8*
  call void @free(i8* %tmp13) #3
  %tmp14 = bitcast float* %tmp5 to i8*
  call void @free(i8* %tmp14) #3
  %tmp15 = bitcast float* %tmp6 to i8*
  call void @free(i8* %tmp15) #3
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
