; ModuleID = 'jacobi3d-base.ll'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, i8*, i8*, i8*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type { %struct._IO_marker*, %struct._IO_FILE*, i32 }
%struct.timezone = type { i32, i32 }
%struct.timeval = type { i64, i64 }

@.str = private unnamed_addr constant [35 x i8] c"Error return from gettimeofday: %d\00", align 1
@.str.1 = private unnamed_addr constant [74 x i8] c"Non-Matching CPU-GPU Outputs Beyond Error Threshold of %4.2f Percent: %d\0A\00", align 1
@stdout = external global %struct._IO_FILE*, align 8
@.str.2 = private unnamed_addr constant [29 x i8] c">> 3D 7PT Jacobi Stencil <<\0A\00", align 1
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
define void @jacobi3d(i32 %tsteps, i32 %x, i32 %y, i32 %z, float* %A, float* %B) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.130, %entry
  %t.0 = phi i32 [ 0, %entry ], [ %inc131, %for.inc.130 ]
  %cmp = icmp slt i32 %t.0, %tsteps
  br i1 %cmp, label %for.body, label %for.end.132

for.body:                                         ; preds = %for.cond
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc.89, %for.body
  %i.0 = phi i32 [ 2, %for.body ], [ %inc90, %for.inc.89 ]
  %sub = sub nsw i32 %z, 1
  %sub2 = sub nsw i32 %sub, 1
  %cmp3 = icmp slt i32 %i.0, %sub2
  br i1 %cmp3, label %for.body.4, label %for.end.91

for.body.4:                                       ; preds = %for.cond.1
  br label %for.cond.5

for.cond.5:                                       ; preds = %for.inc.86, %for.body.4
  %j.0 = phi i32 [ 2, %for.body.4 ], [ %inc87, %for.inc.86 ]
  %sub6 = sub nsw i32 %y, 1
  %sub7 = sub nsw i32 %sub6, 1
  %cmp8 = icmp slt i32 %j.0, %sub7
  br i1 %cmp8, label %for.body.9, label %for.end.88

for.body.9:                                       ; preds = %for.cond.5
  br label %for.cond.10

for.cond.10:                                      ; preds = %for.inc, %for.body.9
  %k.0 = phi i32 [ 2, %for.body.9 ], [ %inc, %for.inc ]
  %sub11 = sub nsw i32 %x, 1
  %sub12 = sub nsw i32 %sub11, 1
  %cmp13 = icmp slt i32 %k.0, %sub12
  br i1 %cmp13, label %for.body.14, label %for.end

for.body.14:                                      ; preds = %for.cond.10
  %mul = mul nsw i32 %x, %y
  %mul15 = mul nsw i32 %i.0, %mul
  %mul16 = mul nsw i32 %j.0, %x
  %add = add nsw i32 %mul15, %mul16
  %sub17 = sub nsw i32 %k.0, 1
  %add18 = add nsw i32 %add, %sub17
  %idxprom = sext i32 %add18 to i64
  %arrayidx = getelementptr inbounds float, float* %A, i64 %idxprom
  %tmp = load float, float* %arrayidx, align 4
  %mul19 = fmul float 2.000000e+00, %tmp
  %mul20 = mul nsw i32 %x, %y
  %mul21 = mul nsw i32 %i.0, %mul20
  %mul22 = mul nsw i32 %j.0, %x
  %add23 = add nsw i32 %mul21, %mul22
  %add24 = add nsw i32 %add23, %k.0
  %idxprom25 = sext i32 %add24 to i64
  %arrayidx26 = getelementptr inbounds float, float* %A, i64 %idxprom25
  %tmp1 = load float, float* %arrayidx26, align 4
  %mul27 = fmul float 5.000000e+00, %tmp1
  %add28 = fadd float %mul19, %mul27
  %mul29 = mul nsw i32 %x, %y
  %mul30 = mul nsw i32 %i.0, %mul29
  %mul31 = mul nsw i32 %j.0, %x
  %add32 = add nsw i32 %mul30, %mul31
  %add33 = add nsw i32 %k.0, 1
  %add34 = add nsw i32 %add32, %add33
  %idxprom35 = sext i32 %add34 to i64
  %arrayidx36 = getelementptr inbounds float, float* %A, i64 %idxprom35
  %tmp2 = load float, float* %arrayidx36, align 4
  %mul37 = fmul float -8.000000e+00, %tmp2
  %add38 = fadd float %add28, %mul37
  %sub39 = sub nsw i32 %i.0, 1
  %mul40 = mul nsw i32 %x, %y
  %mul41 = mul nsw i32 %sub39, %mul40
  %mul42 = mul nsw i32 %j.0, %x
  %add43 = add nsw i32 %mul41, %mul42
  %add44 = add nsw i32 %add43, %k.0
  %idxprom45 = sext i32 %add44 to i64
  %arrayidx46 = getelementptr inbounds float, float* %A, i64 %idxprom45
  %tmp3 = load float, float* %arrayidx46, align 4
  %mul47 = fmul float -3.000000e+00, %tmp3
  %add48 = fadd float %add38, %mul47
  %add49 = add nsw i32 %i.0, 1
  %mul50 = mul nsw i32 %x, %y
  %mul51 = mul nsw i32 %add49, %mul50
  %mul52 = mul nsw i32 %j.0, %x
  %add53 = add nsw i32 %mul51, %mul52
  %add54 = add nsw i32 %add53, %k.0
  %idxprom55 = sext i32 %add54 to i64
  %arrayidx56 = getelementptr inbounds float, float* %A, i64 %idxprom55
  %tmp4 = load float, float* %arrayidx56, align 4
  %mul57 = fmul float 6.000000e+00, %tmp4
  %add58 = fadd float %add48, %mul57
  %mul59 = mul nsw i32 %x, %y
  %mul60 = mul nsw i32 %i.0, %mul59
  %sub61 = sub nsw i32 %j.0, 1
  %mul62 = mul nsw i32 %sub61, %x
  %add63 = add nsw i32 %mul60, %mul62
  %add64 = add nsw i32 %add63, %k.0
  %idxprom65 = sext i32 %add64 to i64
  %arrayidx66 = getelementptr inbounds float, float* %A, i64 %idxprom65
  %tmp5 = load float, float* %arrayidx66, align 4
  %mul67 = fmul float -9.000000e+00, %tmp5
  %add68 = fadd float %add58, %mul67
  %mul69 = mul nsw i32 %x, %y
  %mul70 = mul nsw i32 %i.0, %mul69
  %add71 = add nsw i32 %j.0, 1
  %mul72 = mul nsw i32 %add71, %x
  %add73 = add nsw i32 %mul70, %mul72
  %add74 = add nsw i32 %add73, %k.0
  %idxprom75 = sext i32 %add74 to i64
  %arrayidx76 = getelementptr inbounds float, float* %A, i64 %idxprom75
  %tmp6 = load float, float* %arrayidx76, align 4
  %mul77 = fmul float 4.000000e+00, %tmp6
  %add78 = fadd float %add68, %mul77
  %mul79 = mul nsw i32 %x, %y
  %mul80 = mul nsw i32 %i.0, %mul79
  %mul81 = mul nsw i32 %j.0, %x
  %add82 = add nsw i32 %mul80, %mul81
  %add83 = add nsw i32 %add82, %k.0
  %idxprom84 = sext i32 %add83 to i64
  %arrayidx85 = getelementptr inbounds float, float* %B, i64 %idxprom84
  store float %add78, float* %arrayidx85, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.14
  %inc = add nsw i32 %k.0, 1
  br label %for.cond.10

for.end:                                          ; preds = %for.cond.10
  br label %for.inc.86

for.inc.86:                                       ; preds = %for.end
  %inc87 = add nsw i32 %j.0, 1
  br label %for.cond.5

for.end.88:                                       ; preds = %for.cond.5
  br label %for.inc.89

for.inc.89:                                       ; preds = %for.end.88
  %inc90 = add nsw i32 %i.0, 1
  br label %for.cond.1

for.end.91:                                       ; preds = %for.cond.1
  br label %for.cond.92

for.cond.92:                                      ; preds = %for.inc.127, %for.end.91
  %i.1 = phi i32 [ 2, %for.end.91 ], [ %inc128, %for.inc.127 ]
  %sub93 = sub nsw i32 %z, 1
  %sub94 = sub nsw i32 %sub93, 1
  %cmp95 = icmp slt i32 %i.1, %sub94
  br i1 %cmp95, label %for.body.96, label %for.end.129

for.body.96:                                      ; preds = %for.cond.92
  br label %for.cond.97

for.cond.97:                                      ; preds = %for.inc.124, %for.body.96
  %j.1 = phi i32 [ 2, %for.body.96 ], [ %inc125, %for.inc.124 ]
  %sub98 = sub nsw i32 %y, 1
  %sub99 = sub nsw i32 %sub98, 1
  %cmp100 = icmp slt i32 %j.1, %sub99
  br i1 %cmp100, label %for.body.101, label %for.end.126

for.body.101:                                     ; preds = %for.cond.97
  br label %for.cond.102

for.cond.102:                                     ; preds = %for.inc.121, %for.body.101
  %k.1 = phi i32 [ 2, %for.body.101 ], [ %inc122, %for.inc.121 ]
  %sub103 = sub nsw i32 %x, 1
  %sub104 = sub nsw i32 %sub103, 1
  %cmp105 = icmp slt i32 %k.1, %sub104
  br i1 %cmp105, label %for.body.106, label %for.end.123

for.body.106:                                     ; preds = %for.cond.102
  %mul107 = mul nsw i32 %x, %y
  %mul108 = mul nsw i32 %i.1, %mul107
  %mul109 = mul nsw i32 %j.1, %x
  %add110 = add nsw i32 %mul108, %mul109
  %add111 = add nsw i32 %add110, %k.1
  %idxprom112 = sext i32 %add111 to i64
  %arrayidx113 = getelementptr inbounds float, float* %B, i64 %idxprom112
  %tmp7 = load float, float* %arrayidx113, align 4
  %mul114 = mul nsw i32 %x, %y
  %mul115 = mul nsw i32 %i.1, %mul114
  %mul116 = mul nsw i32 %j.1, %z
  %add117 = add nsw i32 %mul115, %mul116
  %add118 = add nsw i32 %add117, %k.1
  %idxprom119 = sext i32 %add118 to i64
  %arrayidx120 = getelementptr inbounds float, float* %A, i64 %idxprom119
  store float %tmp7, float* %arrayidx120, align 4
  br label %for.inc.121

for.inc.121:                                      ; preds = %for.body.106
  %inc122 = add nsw i32 %k.1, 1
  br label %for.cond.102

for.end.123:                                      ; preds = %for.cond.102
  br label %for.inc.124

for.inc.124:                                      ; preds = %for.end.123
  %inc125 = add nsw i32 %j.1, 1
  br label %for.cond.97

for.end.126:                                      ; preds = %for.cond.97
  br label %for.inc.127

for.inc.127:                                      ; preds = %for.end.126
  %inc128 = add nsw i32 %i.1, 1
  br label %for.cond.92

for.end.129:                                      ; preds = %for.cond.92
  br label %for.inc.130

for.inc.130:                                      ; preds = %for.end.129
  %inc131 = add nsw i32 %t.0, 1
  br label %for.cond

for.end.132:                                      ; preds = %for.cond
  ret void
}

; Function Attrs: nounwind uwtable
define void @init(float* %A) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.34, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc35, %for.inc.34 ]
  %cmp = icmp slt i32 %i.0, 192
  br i1 %cmp, label %for.body, label %for.end.36

for.body:                                         ; preds = %for.cond
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc.31, %for.body
  %j.0 = phi i32 [ 0, %for.body ], [ %inc32, %for.inc.31 ]
  %cmp2 = icmp slt i32 %j.0, 192
  br i1 %cmp2, label %for.body.3, label %for.end.33

for.body.3:                                       ; preds = %for.cond.1
  br label %for.cond.4

for.cond.4:                                       ; preds = %for.inc, %for.body.3
  %k.0 = phi i32 [ 0, %for.body.3 ], [ %inc, %for.inc ]
  %cmp5 = icmp slt i32 %k.0, 192
  br i1 %cmp5, label %for.body.6, label %for.end

for.body.6:                                       ; preds = %for.cond.4
  %cmp7 = icmp slt i32 %i.0, 2
  br i1 %cmp7, label %if.then, label %lor.lhs.false

lor.lhs.false:                                    ; preds = %for.body.6
  %cmp8 = icmp slt i32 %j.0, 2
  br i1 %cmp8, label %if.then, label %lor.lhs.false.9

lor.lhs.false.9:                                  ; preds = %lor.lhs.false
  %cmp10 = icmp sge i32 %i.0, 190
  br i1 %cmp10, label %if.then, label %lor.lhs.false.11

lor.lhs.false.11:                                 ; preds = %lor.lhs.false.9
  %cmp12 = icmp sge i32 %j.0, 190
  br i1 %cmp12, label %if.then, label %lor.lhs.false.13

lor.lhs.false.13:                                 ; preds = %lor.lhs.false.11
  %cmp14 = icmp slt i32 %k.0, 2
  br i1 %cmp14, label %if.then, label %lor.lhs.false.15

lor.lhs.false.15:                                 ; preds = %lor.lhs.false.13
  %cmp16 = icmp sge i32 %k.0, 190
  br i1 %cmp16, label %if.then, label %if.else

if.then:                                          ; preds = %lor.lhs.false.15, %lor.lhs.false.13, %lor.lhs.false.11, %lor.lhs.false.9, %lor.lhs.false, %for.body.6
  %mul = mul nsw i32 %i.0, 36864
  %mul17 = mul nsw i32 %j.0, 192
  %add = add nsw i32 %mul, %mul17
  %add18 = add nsw i32 %add, %k.0
  %idxprom = sext i32 %add18 to i64
  %arrayidx = getelementptr inbounds float, float* %A, i64 %idxprom
  store float 0.000000e+00, float* %arrayidx, align 4
  br label %if.end

if.else:                                          ; preds = %lor.lhs.false.15
  %rem = srem i32 %i.0, 12
  %rem19 = srem i32 %j.0, 7
  %mul20 = mul nsw i32 2, %rem19
  %add21 = add nsw i32 %rem, %mul20
  %rem22 = srem i32 %k.0, 13
  %mul23 = mul nsw i32 3, %rem22
  %add24 = add nsw i32 %add21, %mul23
  %conv = sitofp i32 %add24 to float
  %mul25 = mul nsw i32 %i.0, 36864
  %mul26 = mul nsw i32 %j.0, 192
  %add27 = add nsw i32 %mul25, %mul26
  %add28 = add nsw i32 %add27, %k.0
  %idxprom29 = sext i32 %add28 to i64
  %arrayidx30 = getelementptr inbounds float, float* %A, i64 %idxprom29
  store float %conv, float* %arrayidx30, align 4
  br label %if.end

if.end:                                           ; preds = %if.else, %if.then
  br label %for.inc

for.inc:                                          ; preds = %if.end
  %inc = add nsw i32 %k.0, 1
  br label %for.cond.4

for.end:                                          ; preds = %for.cond.4
  br label %for.inc.31

for.inc.31:                                       ; preds = %for.end
  %inc32 = add nsw i32 %j.0, 1
  br label %for.cond.1

for.end.33:                                       ; preds = %for.cond.1
  br label %for.inc.34

for.inc.34:                                       ; preds = %for.end.33
  %inc35 = add nsw i32 %i.0, 1
  br label %for.cond

for.end.36:                                       ; preds = %for.cond
  ret void
}

; Function Attrs: nounwind uwtable
define void @compareResults(float* %B, float* %B_GPU) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.23, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc24, %for.inc.23 ]
  %fail.0 = phi i32 [ 0, %entry ], [ %fail.1, %for.inc.23 ]
  %cmp = icmp slt i32 %i.0, 192
  br i1 %cmp, label %for.body, label %for.end.25

for.body:                                         ; preds = %for.cond
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc.20, %for.body
  %j.0 = phi i32 [ 0, %for.body ], [ %inc21, %for.inc.20 ]
  %fail.1 = phi i32 [ %fail.0, %for.body ], [ %fail.2, %for.inc.20 ]
  %cmp2 = icmp slt i32 %j.0, 192
  br i1 %cmp2, label %for.body.3, label %for.end.22

for.body.3:                                       ; preds = %for.cond.1
  br label %for.cond.4

for.cond.4:                                       ; preds = %for.inc, %for.body.3
  %k.0 = phi i32 [ 0, %for.body.3 ], [ %inc19, %for.inc ]
  %fail.2 = phi i32 [ %fail.1, %for.body.3 ], [ %fail.3, %for.inc ]
  %cmp5 = icmp slt i32 %k.0, 192
  br i1 %cmp5, label %for.body.6, label %for.end

for.body.6:                                       ; preds = %for.cond.4
  %mul = mul nsw i32 %i.0, 36864
  %mul7 = mul nsw i32 %j.0, 192
  %add = add nsw i32 %mul, %mul7
  %add8 = add nsw i32 %add, %k.0
  %idxprom = sext i32 %add8 to i64
  %arrayidx = getelementptr inbounds float, float* %B, i64 %idxprom
  %tmp = load float, float* %arrayidx, align 4
  %conv = fpext float %tmp to double
  %mul9 = mul nsw i32 %i.0, 36864
  %mul10 = mul nsw i32 %j.0, 192
  %add11 = add nsw i32 %mul9, %mul10
  %add12 = add nsw i32 %add11, %k.0
  %idxprom13 = sext i32 %add12 to i64
  %arrayidx14 = getelementptr inbounds float, float* %B_GPU, i64 %idxprom13
  %tmp1 = load float, float* %arrayidx14, align 4
  %conv15 = fpext float %tmp1 to double
  %call = call float @percentDiff(double %conv, double %conv15)
  %conv16 = fpext float %call to double
  %cmp17 = fcmp ogt double %conv16, 5.000000e-01
  br i1 %cmp17, label %if.then, label %if.end

if.then:                                          ; preds = %for.body.6
  %inc = add nsw i32 %fail.2, 1
  br label %if.end

if.end:                                           ; preds = %if.then, %for.body.6
  %fail.3 = phi i32 [ %inc, %if.then ], [ %fail.2, %for.body.6 ]
  br label %for.inc

for.inc:                                          ; preds = %if.end
  %inc19 = add nsw i32 %k.0, 1
  br label %for.cond.4

for.end:                                          ; preds = %for.cond.4
  br label %for.inc.20

for.inc.20:                                       ; preds = %for.end
  %inc21 = add nsw i32 %j.0, 1
  br label %for.cond.1

for.end.22:                                       ; preds = %for.cond.1
  br label %for.inc.23

for.inc.23:                                       ; preds = %for.end.22
  %inc24 = add nsw i32 %i.0, 1
  br label %for.cond

for.end.25:                                       ; preds = %for.cond
  %call26 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([74 x i8], [74 x i8]* @.str.1, i32 0, i32 0), double 5.000000e-01, i32 %fail.0)
  ret void
}

; Function Attrs: nounwind uwtable
define i32 @main(i32 %argc, i8** %argv) #0 {
entry:
  %call = call noalias i8* @malloc(i64 30118144) #3
  %tmp = bitcast i8* %call to float*
  %call1 = call noalias i8* @calloc(i64 7529536, i64 4) #3
  %tmp1 = bitcast i8* %call1 to float*
  %call2 = call noalias i8* @calloc(i64 7529536, i64 4) #3
  %tmp2 = bitcast i8* %call2 to float*
  %call3 = call noalias i8* @calloc(i64 7529536, i64 4) #3
  %tmp3 = bitcast i8* %call3 to float*
  %tmp4 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %call4 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %tmp4, i8* getelementptr inbounds ([29 x i8], [29 x i8]* @.str.2, i32 0, i32 0))
  call void @init(float* %tmp)
  %call5 = call double @rtclock()
  call void @jacobi3d(i32 2, i32 192, i32 192, i32 192, float* %tmp, float* %tmp1)
  %call6 = call double @rtclock()
  %tmp5 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %sub = fsub double %call6, %call5
  %call7 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %tmp5, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.3, i32 0, i32 0), double %sub)
  %tmp6 = bitcast float* %tmp to i8*
  call void @free(i8* %tmp6) #3
  %tmp7 = bitcast float* %tmp1 to i8*
  call void @free(i8* %tmp7) #3
  ret i32 0
}

; Function Attrs: nounwind
declare noalias i8* @malloc(i64) #1

; Function Attrs: nounwind
declare noalias i8* @calloc(i64, i64) #1

declare i32 @fprintf(%struct._IO_FILE*, i8*, ...) #2

; Function Attrs: nounwind
declare void @free(i8*) #1

attributes #0 = { nounwind uwtable "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nounwind }

!llvm.ident = !{!0}

!0 = !{!"clang version 3.7.1 (https://github.com/llvm-mirror/clang.git 0dbefa1b83eb90f7a06b5df5df254ce32be3db4b) (https://github.com/llvm-mirror/llvm.git 33c352b3eda89abc24e7511d9045fa2e499a42e3)"}
