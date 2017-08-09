; ModuleID = 'gemm-base.ll'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, i8*, i8*, i8*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type { %struct._IO_marker*, %struct._IO_FILE*, i32 }
%struct.timezone = type { i32, i32 }
%struct.timeval = type { i64, i64 }

@.str = private unnamed_addr constant [35 x i8] c"Error return from gettimeofday: %d\00", align 1
@.str.1 = private unnamed_addr constant [74 x i8] c"Non-Matching CPU-GPU Outputs Beyond Error Threshold of %4.2f Percent: %d\0A\00", align 1
@stdout = external global %struct._IO_FILE*, align 8
@.str.2 = private unnamed_addr constant [42 x i8] c"<< Matrix-multiply C=alpha.A.B+beta.C >>\0A\00", align 1
@.str.3 = private unnamed_addr constant [22 x i8] c"GPU Runtime: %0.6lfs\0A\00", align 1
@.str.4 = private unnamed_addr constant [22 x i8] c"CPU Runtime: %0.6lfs\0A\00", align 1

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
define void @gemm(float* %A, float* %B, float* %C) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.26, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc27, %for.inc.26 ]
  %cmp = icmp slt i32 %i.0, 2048
  br i1 %cmp, label %for.body, label %for.end.28

for.body:                                         ; preds = %for.cond
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc.23, %for.body
  %j.0 = phi i32 [ 0, %for.body ], [ %inc24, %for.inc.23 ]
  %cmp2 = icmp slt i32 %j.0, 2048
  br i1 %cmp2, label %for.body.3, label %for.end.25

for.body.3:                                       ; preds = %for.cond.1
  %mul = mul nsw i32 %i.0, 2048
  %add = add nsw i32 %mul, %j.0
  %idxprom = sext i32 %add to i64
  %arrayidx = getelementptr inbounds float, float* %C, i64 %idxprom
  %tmp = load float, float* %arrayidx, align 4
  %mul4 = fmul float %tmp, 2.123000e+03
  store float %mul4, float* %arrayidx, align 4
  br label %for.cond.5

for.cond.5:                                       ; preds = %for.inc, %for.body.3
  %k.0 = phi i32 [ 0, %for.body.3 ], [ %inc, %for.inc ]
  %cmp6 = icmp slt i32 %k.0, 2048
  br i1 %cmp6, label %for.body.7, label %for.end

for.body.7:                                       ; preds = %for.cond.5
  %mul8 = mul nsw i32 %i.0, 2048
  %add9 = add nsw i32 %mul8, %k.0
  %idxprom10 = sext i32 %add9 to i64
  %arrayidx11 = getelementptr inbounds float, float* %A, i64 %idxprom10
  %tmp1 = load float, float* %arrayidx11, align 4
  %mul12 = fmul float 3.241200e+04, %tmp1
  %mul13 = mul nsw i32 %k.0, 2048
  %add14 = add nsw i32 %mul13, %j.0
  %idxprom15 = sext i32 %add14 to i64
  %arrayidx16 = getelementptr inbounds float, float* %B, i64 %idxprom15
  %tmp2 = load float, float* %arrayidx16, align 4
  %mul17 = fmul float %mul12, %tmp2
  %mul18 = mul nsw i32 %i.0, 2048
  %add19 = add nsw i32 %mul18, %j.0
  %idxprom20 = sext i32 %add19 to i64
  %arrayidx21 = getelementptr inbounds float, float* %C, i64 %idxprom20
  %tmp3 = load float, float* %arrayidx21, align 4
  %add22 = fadd float %tmp3, %mul17
  store float %add22, float* %arrayidx21, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.7
  %inc = add nsw i32 %k.0, 1
  br label %for.cond.5

for.end:                                          ; preds = %for.cond.5
  br label %for.inc.23

for.inc.23:                                       ; preds = %for.end
  %inc24 = add nsw i32 %j.0, 1
  br label %for.cond.1

for.end.25:                                       ; preds = %for.cond.1
  br label %for.inc.26

for.inc.26:                                       ; preds = %for.end.25
  %inc27 = add nsw i32 %i.0, 1
  br label %for.cond

for.end.28:                                       ; preds = %for.cond
  ret void
}

; Function Attrs: nounwind uwtable
define void @GPU__gemm(float* %A, float* %B, float* %C) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.26, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc27, %for.inc.26 ]
  %cmp = icmp slt i32 %i.0, 2048
  br i1 %cmp, label %for.body, label %for.end.28

for.body:                                         ; preds = %for.cond
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc.23, %for.body
  %j.0 = phi i32 [ 0, %for.body ], [ %inc24, %for.inc.23 ]
  %cmp2 = icmp slt i32 %j.0, 2048
  br i1 %cmp2, label %for.body.3, label %for.end.25

for.body.3:                                       ; preds = %for.cond.1
  %mul = mul nsw i32 %i.0, 2048
  %add = add nsw i32 %mul, %j.0
  %idxprom = sext i32 %add to i64
  %arrayidx = getelementptr inbounds float, float* %C, i64 %idxprom
  %tmp = load float, float* %arrayidx, align 4
  %mul4 = fmul float %tmp, 2.123000e+03
  store float %mul4, float* %arrayidx, align 4
  br label %for.cond.5

for.cond.5:                                       ; preds = %for.inc, %for.body.3
  %k.0 = phi i32 [ 0, %for.body.3 ], [ %inc, %for.inc ]
  %cmp6 = icmp slt i32 %k.0, 2048
  br i1 %cmp6, label %for.body.7, label %for.end

for.body.7:                                       ; preds = %for.cond.5
  %mul8 = mul nsw i32 %i.0, 2048
  %add9 = add nsw i32 %mul8, %k.0
  %idxprom10 = sext i32 %add9 to i64
  %arrayidx11 = getelementptr inbounds float, float* %A, i64 %idxprom10
  %tmp1 = load float, float* %arrayidx11, align 4
  %mul12 = fmul float 3.241200e+04, %tmp1
  %mul13 = mul nsw i32 %k.0, 2048
  %add14 = add nsw i32 %mul13, %j.0
  %idxprom15 = sext i32 %add14 to i64
  %arrayidx16 = getelementptr inbounds float, float* %B, i64 %idxprom15
  %tmp2 = load float, float* %arrayidx16, align 4
  %mul17 = fmul float %mul12, %tmp2
  %mul18 = mul nsw i32 %i.0, 2048
  %add19 = add nsw i32 %mul18, %j.0
  %idxprom20 = sext i32 %add19 to i64
  %arrayidx21 = getelementptr inbounds float, float* %C, i64 %idxprom20
  %tmp3 = load float, float* %arrayidx21, align 4
  %add22 = fadd float %tmp3, %mul17
  store float %add22, float* %arrayidx21, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.7
  %inc = add nsw i32 %k.0, 1
  br label %for.cond.5

for.end:                                          ; preds = %for.cond.5
  br label %for.inc.23

for.inc.23:                                       ; preds = %for.end
  %inc24 = add nsw i32 %j.0, 1
  br label %for.cond.1

for.end.25:                                       ; preds = %for.cond.1
  br label %for.inc.26

for.inc.26:                                       ; preds = %for.end.25
  %inc27 = add nsw i32 %i.0, 1
  br label %for.cond

for.end.28:                                       ; preds = %for.cond
  ret void
}

; Function Attrs: nounwind uwtable
define void @init(float* %A, float* %B, float* %C, float* %C_OMP) #0 {
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
  %conv18 = sitofp i32 %j.1 to float
  %mul19 = fmul float %conv17, %conv18
  %add20 = fadd float %mul19, 1.000000e+00
  %div21 = fdiv float %add20, 2.048000e+03
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

for.cond.32:                                      ; preds = %for.inc.61, %for.end.31
  %i.2 = phi i32 [ 0, %for.end.31 ], [ %inc62, %for.inc.61 ]
  %cmp33 = icmp slt i32 %i.2, 2048
  br i1 %cmp33, label %for.body.35, label %for.end.63

for.body.35:                                      ; preds = %for.cond.32
  br label %for.cond.36

for.cond.36:                                      ; preds = %for.inc.58, %for.body.35
  %j.2 = phi i32 [ 0, %for.body.35 ], [ %inc59, %for.inc.58 ]
  %cmp37 = icmp slt i32 %j.2, 2048
  br i1 %cmp37, label %for.body.39, label %for.end.60

for.body.39:                                      ; preds = %for.cond.36
  %conv40 = sitofp i32 %i.2 to float
  %conv41 = sitofp i32 %j.2 to float
  %mul42 = fmul float %conv40, %conv41
  %add43 = fadd float %mul42, 2.000000e+00
  %div44 = fdiv float %add43, 2.048000e+03
  %mul45 = mul nsw i32 %i.2, 2048
  %add46 = add nsw i32 %mul45, %j.2
  %idxprom47 = sext i32 %add46 to i64
  %arrayidx48 = getelementptr inbounds float, float* %C, i64 %idxprom47
  store float %div44, float* %arrayidx48, align 4
  %conv49 = sitofp i32 %i.2 to float
  %conv50 = sitofp i32 %j.2 to float
  %mul51 = fmul float %conv49, %conv50
  %add52 = fadd float %mul51, 2.000000e+00
  %div53 = fdiv float %add52, 2.048000e+03
  %mul54 = mul nsw i32 %i.2, 2048
  %add55 = add nsw i32 %mul54, %j.2
  %idxprom56 = sext i32 %add55 to i64
  %arrayidx57 = getelementptr inbounds float, float* %C_OMP, i64 %idxprom56
  store float %div53, float* %arrayidx57, align 4
  br label %for.inc.58

for.inc.58:                                       ; preds = %for.body.39
  %inc59 = add nsw i32 %j.2, 1
  br label %for.cond.36

for.end.60:                                       ; preds = %for.cond.36
  br label %for.inc.61

for.inc.61:                                       ; preds = %for.end.60
  %inc62 = add nsw i32 %i.2, 1
  br label %for.cond.32

for.end.63:                                       ; preds = %for.cond.32
  ret void
}

; Function Attrs: nounwind uwtable
define void @compareResults(float* %C, float* %C_outputFromGpu) #0 {
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
  %arrayidx7 = getelementptr inbounds float, float* %C_outputFromGpu, i64 %idxprom6
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
  %tmp4 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %call4 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %tmp4, i8* getelementptr inbounds ([42 x i8], [42 x i8]* @.str.2, i32 0, i32 0))
  call void @init(float* %tmp, float* %tmp1, float* %tmp2, float* %tmp3)
  %call5 = call double @rtclock()
  call void @GPU__gemm(float* %tmp, float* %tmp1, float* %tmp3)
  %call6 = call double @rtclock()
  %tmp5 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %sub = fsub double %call6, %call5
  %call7 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %tmp5, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.3, i32 0, i32 0), double %sub)
  %call8 = call double @rtclock()
  call void @gemm(float* %tmp, float* %tmp1, float* %tmp2)
  %call9 = call double @rtclock()
  %tmp6 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %sub10 = fsub double %call9, %call8
  %call11 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %tmp6, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.4, i32 0, i32 0), double %sub10)
  call void @compareResults(float* %tmp2, float* %tmp3)
  %tmp7 = bitcast float* %tmp to i8*
  call void @free(i8* %tmp7) #3
  %tmp8 = bitcast float* %tmp1 to i8*
  call void @free(i8* %tmp8) #3
  %tmp9 = bitcast float* %tmp2 to i8*
  call void @free(i8* %tmp9) #3
  %tmp10 = bitcast float* %tmp3 to i8*
  call void @free(i8* %tmp10) #3
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
