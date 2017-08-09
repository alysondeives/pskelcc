; ModuleID = 'mvt-base.ll'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, i8*, i8*, i8*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type { %struct._IO_marker*, %struct._IO_FILE*, i32 }
%struct.timezone = type { i32, i32 }
%struct.timeval = type { i64, i64 }

@.str = private unnamed_addr constant [35 x i8] c"Error return from gettimeofday: %d\00", align 1
@.str.1 = private unnamed_addr constant [74 x i8] c"Non-Matching CPU-GPU Outputs Beyond Error Threshold of %4.2f Percent: %d\0A\00", align 1
@stdout = external global %struct._IO_FILE*, align 8
@.str.2 = private unnamed_addr constant [43 x i8] c"<< Matrix Vector Product and Transpose >>\0A\00", align 1
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
define void @init_array(float* %A, float* %x1, float* %x2, float* %y1, float* %y2, float* %x1_gpu, float* %x2_gpu) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.34, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc35, %for.inc.34 ]
  %cmp = icmp slt i32 %i.0, 4096
  br i1 %cmp, label %for.body, label %for.end.36

for.body:                                         ; preds = %for.cond
  %conv = sitofp i32 %i.0 to float
  %div = fdiv float %conv, 4.096000e+03
  %idxprom = sext i32 %i.0 to i64
  %arrayidx = getelementptr inbounds float, float* %x1, i64 %idxprom
  store float %div, float* %arrayidx, align 4
  %conv1 = sitofp i32 %i.0 to float
  %add = fadd float %conv1, 1.000000e+00
  %div2 = fdiv float %add, 4.096000e+03
  %idxprom3 = sext i32 %i.0 to i64
  %arrayidx4 = getelementptr inbounds float, float* %x2, i64 %idxprom3
  store float %div2, float* %arrayidx4, align 4
  %idxprom5 = sext i32 %i.0 to i64
  %arrayidx6 = getelementptr inbounds float, float* %x1, i64 %idxprom5
  %tmp = load float, float* %arrayidx6, align 4
  %idxprom7 = sext i32 %i.0 to i64
  %arrayidx8 = getelementptr inbounds float, float* %x1_gpu, i64 %idxprom7
  store float %tmp, float* %arrayidx8, align 4
  %idxprom9 = sext i32 %i.0 to i64
  %arrayidx10 = getelementptr inbounds float, float* %x2, i64 %idxprom9
  %tmp1 = load float, float* %arrayidx10, align 4
  %idxprom11 = sext i32 %i.0 to i64
  %arrayidx12 = getelementptr inbounds float, float* %x2_gpu, i64 %idxprom11
  store float %tmp1, float* %arrayidx12, align 4
  %conv13 = sitofp i32 %i.0 to float
  %add14 = fadd float %conv13, 3.000000e+00
  %div15 = fdiv float %add14, 4.096000e+03
  %idxprom16 = sext i32 %i.0 to i64
  %arrayidx17 = getelementptr inbounds float, float* %y1, i64 %idxprom16
  store float %div15, float* %arrayidx17, align 4
  %conv18 = sitofp i32 %i.0 to float
  %add19 = fadd float %conv18, 4.000000e+00
  %div20 = fdiv float %add19, 4.096000e+03
  %idxprom21 = sext i32 %i.0 to i64
  %arrayidx22 = getelementptr inbounds float, float* %y2, i64 %idxprom21
  store float %div20, float* %arrayidx22, align 4
  br label %for.cond.23

for.cond.23:                                      ; preds = %for.inc, %for.body
  %j.0 = phi i32 [ 0, %for.body ], [ %inc, %for.inc ]
  %cmp24 = icmp slt i32 %j.0, 4096
  br i1 %cmp24, label %for.body.26, label %for.end

for.body.26:                                      ; preds = %for.cond.23
  %conv27 = sitofp i32 %i.0 to float
  %conv28 = sitofp i32 %j.0 to float
  %mul = fmul float %conv27, %conv28
  %div29 = fdiv float %mul, 4.096000e+03
  %mul30 = mul nsw i32 %i.0, 4096
  %add31 = add nsw i32 %mul30, %j.0
  %idxprom32 = sext i32 %add31 to i64
  %arrayidx33 = getelementptr inbounds float, float* %A, i64 %idxprom32
  store float %div29, float* %arrayidx33, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.26
  %inc = add nsw i32 %j.0, 1
  br label %for.cond.23

for.end:                                          ; preds = %for.cond.23
  br label %for.inc.34

for.inc.34:                                       ; preds = %for.end
  %inc35 = add nsw i32 %i.0, 1
  br label %for.cond

for.end.36:                                       ; preds = %for.cond
  ret void
}

; Function Attrs: nounwind uwtable
define void @runMvt(float* %a, float* %x1, float* %x2, float* %y1, float* %y2) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.12, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc13, %for.inc.12 ]
  %cmp = icmp slt i32 %i.0, 4096
  br i1 %cmp, label %for.body, label %for.end.14

for.body:                                         ; preds = %for.cond
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %j.0 = phi i32 [ 0, %for.body ], [ %inc, %for.inc ]
  %cmp2 = icmp slt i32 %j.0, 4096
  br i1 %cmp2, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.cond.1
  %idxprom = sext i32 %i.0 to i64
  %arrayidx = getelementptr inbounds float, float* %x1, i64 %idxprom
  %tmp = load float, float* %arrayidx, align 4
  %mul = mul nsw i32 %i.0, 4096
  %add = add nsw i32 %mul, %j.0
  %idxprom4 = sext i32 %add to i64
  %arrayidx5 = getelementptr inbounds float, float* %a, i64 %idxprom4
  %tmp1 = load float, float* %arrayidx5, align 4
  %idxprom6 = sext i32 %j.0 to i64
  %arrayidx7 = getelementptr inbounds float, float* %y1, i64 %idxprom6
  %tmp2 = load float, float* %arrayidx7, align 4
  %mul8 = fmul float %tmp1, %tmp2
  %add9 = fadd float %tmp, %mul8
  %idxprom10 = sext i32 %i.0 to i64
  %arrayidx11 = getelementptr inbounds float, float* %x1, i64 %idxprom10
  store float %add9, float* %arrayidx11, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.3
  %inc = add nsw i32 %j.0, 1
  br label %for.cond.1

for.end:                                          ; preds = %for.cond.1
  br label %for.inc.12

for.inc.12:                                       ; preds = %for.end
  %inc13 = add nsw i32 %i.0, 1
  br label %for.cond

for.end.14:                                       ; preds = %for.cond
  br label %for.cond.15

for.cond.15:                                      ; preds = %for.inc.36, %for.end.14
  %i.1 = phi i32 [ 0, %for.end.14 ], [ %inc37, %for.inc.36 ]
  %cmp16 = icmp slt i32 %i.1, 4096
  br i1 %cmp16, label %for.body.17, label %for.end.38

for.body.17:                                      ; preds = %for.cond.15
  br label %for.cond.18

for.cond.18:                                      ; preds = %for.inc.33, %for.body.17
  %j.1 = phi i32 [ 0, %for.body.17 ], [ %inc34, %for.inc.33 ]
  %cmp19 = icmp slt i32 %j.1, 4096
  br i1 %cmp19, label %for.body.20, label %for.end.35

for.body.20:                                      ; preds = %for.cond.18
  %idxprom21 = sext i32 %i.1 to i64
  %arrayidx22 = getelementptr inbounds float, float* %x2, i64 %idxprom21
  %tmp3 = load float, float* %arrayidx22, align 4
  %mul23 = mul nsw i32 %j.1, 4096
  %add24 = add nsw i32 %mul23, %i.1
  %idxprom25 = sext i32 %add24 to i64
  %arrayidx26 = getelementptr inbounds float, float* %a, i64 %idxprom25
  %tmp4 = load float, float* %arrayidx26, align 4
  %idxprom27 = sext i32 %j.1 to i64
  %arrayidx28 = getelementptr inbounds float, float* %y2, i64 %idxprom27
  %tmp5 = load float, float* %arrayidx28, align 4
  %mul29 = fmul float %tmp4, %tmp5
  %add30 = fadd float %tmp3, %mul29
  %idxprom31 = sext i32 %i.1 to i64
  %arrayidx32 = getelementptr inbounds float, float* %x2, i64 %idxprom31
  store float %add30, float* %arrayidx32, align 4
  br label %for.inc.33

for.inc.33:                                       ; preds = %for.body.20
  %inc34 = add nsw i32 %j.1, 1
  br label %for.cond.18

for.end.35:                                       ; preds = %for.cond.18
  br label %for.inc.36

for.inc.36:                                       ; preds = %for.end.35
  %inc37 = add nsw i32 %i.1, 1
  br label %for.cond.15

for.end.38:                                       ; preds = %for.cond.15
  ret void
}

; Function Attrs: nounwind uwtable
define void @GPU__runMvt(float* %a, float* %x1, float* %x2, float* %y1, float* %y2) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.12, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc13, %for.inc.12 ]
  %cmp = icmp slt i32 %i.0, 4096
  br i1 %cmp, label %for.body, label %for.end.14

for.body:                                         ; preds = %for.cond
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %j.0 = phi i32 [ 0, %for.body ], [ %inc, %for.inc ]
  %cmp2 = icmp slt i32 %j.0, 4096
  br i1 %cmp2, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.cond.1
  %idxprom = sext i32 %i.0 to i64
  %arrayidx = getelementptr inbounds float, float* %x1, i64 %idxprom
  %tmp = load float, float* %arrayidx, align 4
  %mul = mul nsw i32 %i.0, 4096
  %add = add nsw i32 %mul, %j.0
  %idxprom4 = sext i32 %add to i64
  %arrayidx5 = getelementptr inbounds float, float* %a, i64 %idxprom4
  %tmp1 = load float, float* %arrayidx5, align 4
  %idxprom6 = sext i32 %j.0 to i64
  %arrayidx7 = getelementptr inbounds float, float* %y1, i64 %idxprom6
  %tmp2 = load float, float* %arrayidx7, align 4
  %mul8 = fmul float %tmp1, %tmp2
  %add9 = fadd float %tmp, %mul8
  %idxprom10 = sext i32 %i.0 to i64
  %arrayidx11 = getelementptr inbounds float, float* %x1, i64 %idxprom10
  store float %add9, float* %arrayidx11, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.3
  %inc = add nsw i32 %j.0, 1
  br label %for.cond.1

for.end:                                          ; preds = %for.cond.1
  br label %for.inc.12

for.inc.12:                                       ; preds = %for.end
  %inc13 = add nsw i32 %i.0, 1
  br label %for.cond

for.end.14:                                       ; preds = %for.cond
  br label %for.cond.15

for.cond.15:                                      ; preds = %for.inc.37, %for.end.14
  %i.1 = phi i32 [ 0, %for.end.14 ], [ %inc38, %for.inc.37 ]
  %cmp16 = icmp slt i32 %i.1, 4096
  br i1 %cmp16, label %for.body.17, label %for.end.39

for.body.17:                                      ; preds = %for.cond.15
  br label %for.cond.19

for.cond.19:                                      ; preds = %for.inc.34, %for.body.17
  %j18.0 = phi i32 [ 0, %for.body.17 ], [ %inc35, %for.inc.34 ]
  %cmp20 = icmp slt i32 %j18.0, 4096
  br i1 %cmp20, label %for.body.21, label %for.end.36

for.body.21:                                      ; preds = %for.cond.19
  %idxprom22 = sext i32 %i.1 to i64
  %arrayidx23 = getelementptr inbounds float, float* %x2, i64 %idxprom22
  %tmp3 = load float, float* %arrayidx23, align 4
  %mul24 = mul nsw i32 %j18.0, 4096
  %add25 = add nsw i32 %mul24, %i.1
  %idxprom26 = sext i32 %add25 to i64
  %arrayidx27 = getelementptr inbounds float, float* %a, i64 %idxprom26
  %tmp4 = load float, float* %arrayidx27, align 4
  %idxprom28 = sext i32 %j18.0 to i64
  %arrayidx29 = getelementptr inbounds float, float* %y2, i64 %idxprom28
  %tmp5 = load float, float* %arrayidx29, align 4
  %mul30 = fmul float %tmp4, %tmp5
  %add31 = fadd float %tmp3, %mul30
  %idxprom32 = sext i32 %i.1 to i64
  %arrayidx33 = getelementptr inbounds float, float* %x2, i64 %idxprom32
  store float %add31, float* %arrayidx33, align 4
  br label %for.inc.34

for.inc.34:                                       ; preds = %for.body.21
  %inc35 = add nsw i32 %j18.0, 1
  br label %for.cond.19

for.end.36:                                       ; preds = %for.cond.19
  br label %for.inc.37

for.inc.37:                                       ; preds = %for.end.36
  %inc38 = add nsw i32 %i.1, 1
  br label %for.cond.15

for.end.39:                                       ; preds = %for.cond.15
  ret void
}

; Function Attrs: nounwind uwtable
define void @compareResults(float* %x1, float* %x1_outputFromGpu, float* %x2, float* %x2_outputFromGpu) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc20, %for.inc ]
  %fail.0 = phi i32 [ 0, %entry ], [ %fail.2, %for.inc ]
  %cmp = icmp slt i32 %i.0, 4096
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %idxprom = sext i32 %i.0 to i64
  %arrayidx = getelementptr inbounds float, float* %x1, i64 %idxprom
  %tmp = load float, float* %arrayidx, align 4
  %conv = fpext float %tmp to double
  %idxprom1 = sext i32 %i.0 to i64
  %arrayidx2 = getelementptr inbounds float, float* %x1_outputFromGpu, i64 %idxprom1
  %tmp1 = load float, float* %arrayidx2, align 4
  %conv3 = fpext float %tmp1 to double
  %call = call float @percentDiff(double %conv, double %conv3)
  %conv4 = fpext float %call to double
  %cmp5 = fcmp ogt double %conv4, 5.000000e-02
  br i1 %cmp5, label %if.then, label %if.end

if.then:                                          ; preds = %for.body
  %inc = add nsw i32 %fail.0, 1
  br label %if.end

if.end:                                           ; preds = %if.then, %for.body
  %fail.1 = phi i32 [ %inc, %if.then ], [ %fail.0, %for.body ]
  %idxprom7 = sext i32 %i.0 to i64
  %arrayidx8 = getelementptr inbounds float, float* %x2, i64 %idxprom7
  %tmp2 = load float, float* %arrayidx8, align 4
  %conv9 = fpext float %tmp2 to double
  %idxprom10 = sext i32 %i.0 to i64
  %arrayidx11 = getelementptr inbounds float, float* %x2_outputFromGpu, i64 %idxprom10
  %tmp3 = load float, float* %arrayidx11, align 4
  %conv12 = fpext float %tmp3 to double
  %call13 = call float @percentDiff(double %conv9, double %conv12)
  %conv14 = fpext float %call13 to double
  %cmp15 = fcmp ogt double %conv14, 5.000000e-02
  br i1 %cmp15, label %if.then.17, label %if.end.19

if.then.17:                                       ; preds = %if.end
  %inc18 = add nsw i32 %fail.1, 1
  br label %if.end.19

if.end.19:                                        ; preds = %if.then.17, %if.end
  %fail.2 = phi i32 [ %inc18, %if.then.17 ], [ %fail.1, %if.end ]
  br label %for.inc

for.inc:                                          ; preds = %if.end.19
  %inc20 = add nsw i32 %i.0, 1
  br label %for.cond

for.end:                                          ; preds = %for.cond
  %call21 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([74 x i8], [74 x i8]* @.str.1, i32 0, i32 0), double 5.000000e-02, i32 %fail.0)
  ret void
}

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
entry:
  %call = call noalias i8* @malloc(i64 67108864) #3
  %tmp = bitcast i8* %call to float*
  %call1 = call noalias i8* @malloc(i64 16384) #3
  %tmp1 = bitcast i8* %call1 to float*
  %call2 = call noalias i8* @malloc(i64 16384) #3
  %tmp2 = bitcast i8* %call2 to float*
  %call3 = call noalias i8* @malloc(i64 16384) #3
  %tmp3 = bitcast i8* %call3 to float*
  %call4 = call noalias i8* @malloc(i64 16384) #3
  %tmp4 = bitcast i8* %call4 to float*
  %call5 = call noalias i8* @malloc(i64 16384) #3
  %tmp5 = bitcast i8* %call5 to float*
  %call6 = call noalias i8* @malloc(i64 16384) #3
  %tmp6 = bitcast i8* %call6 to float*
  %tmp7 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %call7 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %tmp7, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @.str.2, i32 0, i32 0))
  call void @init_array(float* %tmp, float* %tmp1, float* %tmp2, float* %tmp5, float* %tmp6, float* %tmp3, float* %tmp4)
  %call8 = call double @rtclock()
  call void @GPU__runMvt(float* %tmp, float* %tmp3, float* %tmp4, float* %tmp5, float* %tmp6)
  %call9 = call double @rtclock()
  %tmp8 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %sub = fsub double %call9, %call8
  %call10 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %tmp8, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.3, i32 0, i32 0), double %sub)
  %call11 = call double @rtclock()
  call void @runMvt(float* %tmp, float* %tmp1, float* %tmp2, float* %tmp5, float* %tmp6)
  %call12 = call double @rtclock()
  %tmp9 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %sub13 = fsub double %call12, %call11
  %call14 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %tmp9, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.4, i32 0, i32 0), double %sub13)
  call void @compareResults(float* %tmp1, float* %tmp3, float* %tmp2, float* %tmp4)
  %tmp10 = bitcast float* %tmp to i8*
  call void @free(i8* %tmp10) #3
  %tmp11 = bitcast float* %tmp1 to i8*
  call void @free(i8* %tmp11) #3
  %tmp12 = bitcast float* %tmp2 to i8*
  call void @free(i8* %tmp12) #3
  %tmp13 = bitcast float* %tmp3 to i8*
  call void @free(i8* %tmp13) #3
  %tmp14 = bitcast float* %tmp4 to i8*
  call void @free(i8* %tmp14) #3
  %tmp15 = bitcast float* %tmp5 to i8*
  call void @free(i8* %tmp15) #3
  %tmp16 = bitcast float* %tmp6 to i8*
  call void @free(i8* %tmp16) #3
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
