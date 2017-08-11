; ModuleID = 'correlation-base.ll'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, i8*, i8*, i8*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type { %struct._IO_marker*, %struct._IO_FILE*, i32 }
%struct.timezone = type { i32, i32 }
%struct.timeval = type { i64, i64 }

@.str = private unnamed_addr constant [35 x i8] c"Error return from gettimeofday: %d\00", align 1
@.str.1 = private unnamed_addr constant [74 x i8] c"Non-Matching CPU-GPU Outputs Beyond Error Threshold of %4.2f Percent: %d\0A\00", align 1
@stdout = external global %struct._IO_FILE*, align 8
@.str.2 = private unnamed_addr constant [31 x i8] c"<< Correlation Computation >>\0A\00", align 1
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
define void @init_arrays(float* %data) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.6, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc7, %for.inc.6 ]
  %cmp = icmp slt i32 %i.0, 2049
  br i1 %cmp, label %for.body, label %for.end.8

for.body:                                         ; preds = %for.cond
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %j.0 = phi i32 [ 0, %for.body ], [ %inc, %for.inc ]
  %cmp2 = icmp slt i32 %j.0, 2049
  br i1 %cmp2, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.cond.1
  %conv = sitofp i32 %i.0 to float
  %conv4 = sitofp i32 %j.0 to float
  %mul = fmul float %conv, %conv4
  %div = fdiv float %mul, 2.049000e+03
  %mul5 = mul nsw i32 %i.0, 2049
  %add = add nsw i32 %mul5, %j.0
  %idxprom = sext i32 %add to i64
  %arrayidx = getelementptr inbounds float, float* %data, i64 %idxprom
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
  ret void
}

; Function Attrs: nounwind uwtable
define void @correlation(i32 %m, i32 %n, float* %data, float* %mean, float* %stddev, float* %symmat) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.11, %entry
  %j.0 = phi i32 [ 0, %entry ], [ %inc12, %for.inc.11 ]
  %cmp = icmp slt i32 %j.0, %m
  br i1 %cmp, label %for.body, label %for.end.13

for.body:                                         ; preds = %for.cond
  %idxprom = sext i32 %j.0 to i64
  %arrayidx = getelementptr inbounds float, float* %mean, i64 %idxprom
  store float 0.000000e+00, float* %arrayidx, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %i.0 = phi i32 [ 0, %for.body ], [ %inc, %for.inc ]
  %cmp2 = icmp slt i32 %i.0, %n
  br i1 %cmp2, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.cond.1
  %mul = mul nsw i32 %i.0, %m
  %add = add nsw i32 %mul, %j.0
  %idxprom4 = sext i32 %add to i64
  %arrayidx5 = getelementptr inbounds float, float* %data, i64 %idxprom4
  %tmp = load float, float* %arrayidx5, align 4
  %idxprom6 = sext i32 %j.0 to i64
  %arrayidx7 = getelementptr inbounds float, float* %mean, i64 %idxprom6
  %tmp1 = load float, float* %arrayidx7, align 4
  %add8 = fadd float %tmp1, %tmp
  store float %add8, float* %arrayidx7, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.3
  %inc = add nsw i32 %i.0, 1
  br label %for.cond.1

for.end:                                          ; preds = %for.cond.1
  %idxprom9 = sext i32 %j.0 to i64
  %arrayidx10 = getelementptr inbounds float, float* %mean, i64 %idxprom9
  %tmp2 = load float, float* %arrayidx10, align 4
  %div = fdiv float %tmp2, 3.214212e+06
  store float %div, float* %arrayidx10, align 4
  br label %for.inc.11

for.inc.11:                                       ; preds = %for.end
  %inc12 = add nsw i32 %j.0, 1
  br label %for.cond

for.end.13:                                       ; preds = %for.cond
  br label %for.cond.14

for.cond.14:                                      ; preds = %for.inc.60, %for.end.13
  %j.1 = phi i32 [ 0, %for.end.13 ], [ %inc61, %for.inc.60 ]
  %cmp15 = icmp slt i32 %j.1, %m
  br i1 %cmp15, label %for.body.16, label %for.end.62

for.body.16:                                      ; preds = %for.cond.14
  %idxprom17 = sext i32 %j.1 to i64
  %arrayidx18 = getelementptr inbounds float, float* %stddev, i64 %idxprom17
  store float 0.000000e+00, float* %arrayidx18, align 4
  br label %for.cond.19

for.cond.19:                                      ; preds = %for.inc.39, %for.body.16
  %i.1 = phi i32 [ 0, %for.body.16 ], [ %inc40, %for.inc.39 ]
  %cmp20 = icmp slt i32 %i.1, %n
  br i1 %cmp20, label %for.body.21, label %for.end.41

for.body.21:                                      ; preds = %for.cond.19
  %mul22 = mul nsw i32 %i.1, %m
  %add23 = add nsw i32 %mul22, %j.1
  %idxprom24 = sext i32 %add23 to i64
  %arrayidx25 = getelementptr inbounds float, float* %data, i64 %idxprom24
  %tmp3 = load float, float* %arrayidx25, align 4
  %idxprom26 = sext i32 %j.1 to i64
  %arrayidx27 = getelementptr inbounds float, float* %mean, i64 %idxprom26
  %tmp4 = load float, float* %arrayidx27, align 4
  %sub = fsub float %tmp3, %tmp4
  %mul28 = mul nsw i32 %i.1, %m
  %add29 = add nsw i32 %mul28, %j.1
  %idxprom30 = sext i32 %add29 to i64
  %arrayidx31 = getelementptr inbounds float, float* %data, i64 %idxprom30
  %tmp5 = load float, float* %arrayidx31, align 4
  %idxprom32 = sext i32 %j.1 to i64
  %arrayidx33 = getelementptr inbounds float, float* %mean, i64 %idxprom32
  %tmp6 = load float, float* %arrayidx33, align 4
  %sub34 = fsub float %tmp5, %tmp6
  %mul35 = fmul float %sub, %sub34
  %idxprom36 = sext i32 %j.1 to i64
  %arrayidx37 = getelementptr inbounds float, float* %stddev, i64 %idxprom36
  %tmp7 = load float, float* %arrayidx37, align 4
  %add38 = fadd float %tmp7, %mul35
  store float %add38, float* %arrayidx37, align 4
  br label %for.inc.39

for.inc.39:                                       ; preds = %for.body.21
  %inc40 = add nsw i32 %i.1, 1
  br label %for.cond.19

for.end.41:                                       ; preds = %for.cond.19
  %idxprom42 = sext i32 %j.1 to i64
  %arrayidx43 = getelementptr inbounds float, float* %stddev, i64 %idxprom42
  %tmp8 = load float, float* %arrayidx43, align 4
  %div44 = fdiv float %tmp8, 3.214212e+06
  store float %div44, float* %arrayidx43, align 4
  %idxprom45 = sext i32 %j.1 to i64
  %arrayidx46 = getelementptr inbounds float, float* %stddev, i64 %idxprom45
  %tmp9 = load float, float* %arrayidx46, align 4
  %conv = fpext float %tmp9 to double
  %call = call double @sqrt(double %conv) #3
  %conv47 = fptrunc double %call to float
  %idxprom48 = sext i32 %j.1 to i64
  %arrayidx49 = getelementptr inbounds float, float* %stddev, i64 %idxprom48
  store float %conv47, float* %arrayidx49, align 4
  %idxprom50 = sext i32 %j.1 to i64
  %arrayidx51 = getelementptr inbounds float, float* %stddev, i64 %idxprom50
  %tmp10 = load float, float* %arrayidx51, align 4
  %cmp52 = fcmp ole float %tmp10, 0x3F747AE140000000
  br i1 %cmp52, label %cond.true, label %cond.false

cond.true:                                        ; preds = %for.end.41
  br label %cond.end

cond.false:                                       ; preds = %for.end.41
  %idxprom54 = sext i32 %j.1 to i64
  %arrayidx55 = getelementptr inbounds float, float* %stddev, i64 %idxprom54
  %tmp11 = load float, float* %arrayidx55, align 4
  %conv56 = fpext float %tmp11 to double
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi double [ 1.000000e+00, %cond.true ], [ %conv56, %cond.false ]
  %conv57 = fptrunc double %cond to float
  %idxprom58 = sext i32 %j.1 to i64
  %arrayidx59 = getelementptr inbounds float, float* %stddev, i64 %idxprom58
  store float %conv57, float* %arrayidx59, align 4
  br label %for.inc.60

for.inc.60:                                       ; preds = %cond.end
  %inc61 = add nsw i32 %j.1, 1
  br label %for.cond.14

for.end.62:                                       ; preds = %for.cond.14
  br label %for.cond.63

for.cond.63:                                      ; preds = %for.inc.93, %for.end.62
  %i.2 = phi i32 [ 0, %for.end.62 ], [ %inc94, %for.inc.93 ]
  %cmp64 = icmp slt i32 %i.2, %n
  br i1 %cmp64, label %for.body.66, label %for.end.95

for.body.66:                                      ; preds = %for.cond.63
  br label %for.cond.67

for.cond.67:                                      ; preds = %for.inc.90, %for.body.66
  %j.2 = phi i32 [ 0, %for.body.66 ], [ %inc91, %for.inc.90 ]
  %cmp68 = icmp slt i32 %j.2, %m
  br i1 %cmp68, label %for.body.70, label %for.end.92

for.body.70:                                      ; preds = %for.cond.67
  %idxprom71 = sext i32 %j.2 to i64
  %arrayidx72 = getelementptr inbounds float, float* %mean, i64 %idxprom71
  %tmp12 = load float, float* %arrayidx72, align 4
  %mul73 = mul nsw i32 %i.2, %m
  %add74 = add nsw i32 %mul73, %j.2
  %idxprom75 = sext i32 %add74 to i64
  %arrayidx76 = getelementptr inbounds float, float* %data, i64 %idxprom75
  %tmp13 = load float, float* %arrayidx76, align 4
  %sub77 = fsub float %tmp13, %tmp12
  store float %sub77, float* %arrayidx76, align 4
  %call78 = call double @sqrt(double 3.214212e+06) #3
  %idxprom79 = sext i32 %j.2 to i64
  %arrayidx80 = getelementptr inbounds float, float* %stddev, i64 %idxprom79
  %tmp14 = load float, float* %arrayidx80, align 4
  %conv81 = fpext float %tmp14 to double
  %mul82 = fmul double %call78, %conv81
  %mul83 = mul nsw i32 %i.2, %m
  %add84 = add nsw i32 %mul83, %j.2
  %idxprom85 = sext i32 %add84 to i64
  %arrayidx86 = getelementptr inbounds float, float* %data, i64 %idxprom85
  %tmp15 = load float, float* %arrayidx86, align 4
  %conv87 = fpext float %tmp15 to double
  %div88 = fdiv double %conv87, %mul82
  %conv89 = fptrunc double %div88 to float
  store float %conv89, float* %arrayidx86, align 4
  br label %for.inc.90

for.inc.90:                                       ; preds = %for.body.70
  %inc91 = add nsw i32 %j.2, 1
  br label %for.cond.67

for.end.92:                                       ; preds = %for.cond.67
  br label %for.inc.93

for.inc.93:                                       ; preds = %for.end.92
  %inc94 = add nsw i32 %i.2, 1
  br label %for.cond.63

for.end.95:                                       ; preds = %for.cond.63
  br label %for.cond.96

for.cond.96:                                      ; preds = %for.inc.146, %for.end.95
  %j1.0 = phi i32 [ 0, %for.end.95 ], [ %inc147, %for.inc.146 ]
  %sub97 = sub nsw i32 %m, 1
  %cmp98 = icmp slt i32 %j1.0, %sub97
  br i1 %cmp98, label %for.body.100, label %for.end.148

for.body.100:                                     ; preds = %for.cond.96
  %mul101 = mul nsw i32 %j1.0, %m
  %add102 = add nsw i32 %mul101, %j1.0
  %idxprom103 = sext i32 %add102 to i64
  %arrayidx104 = getelementptr inbounds float, float* %symmat, i64 %idxprom103
  store float 1.000000e+00, float* %arrayidx104, align 4
  %add105 = add nsw i32 %j1.0, 1
  br label %for.cond.106

for.cond.106:                                     ; preds = %for.inc.143, %for.body.100
  %j2.0 = phi i32 [ %add105, %for.body.100 ], [ %inc144, %for.inc.143 ]
  %cmp107 = icmp slt i32 %j2.0, %m
  br i1 %cmp107, label %for.body.109, label %for.end.145

for.body.109:                                     ; preds = %for.cond.106
  %mul110 = mul nsw i32 %j1.0, %m
  %add111 = add nsw i32 %mul110, %j2.0
  %idxprom112 = sext i32 %add111 to i64
  %arrayidx113 = getelementptr inbounds float, float* %symmat, i64 %idxprom112
  store float 0.000000e+00, float* %arrayidx113, align 4
  br label %for.cond.114

for.cond.114:                                     ; preds = %for.inc.132, %for.body.109
  %i.3 = phi i32 [ 0, %for.body.109 ], [ %inc133, %for.inc.132 ]
  %cmp115 = icmp slt i32 %i.3, %n
  br i1 %cmp115, label %for.body.117, label %for.end.134

for.body.117:                                     ; preds = %for.cond.114
  %mul118 = mul nsw i32 %i.3, %m
  %add119 = add nsw i32 %mul118, %j1.0
  %idxprom120 = sext i32 %add119 to i64
  %arrayidx121 = getelementptr inbounds float, float* %data, i64 %idxprom120
  %tmp16 = load float, float* %arrayidx121, align 4
  %mul122 = mul nsw i32 %i.3, %m
  %add123 = add nsw i32 %mul122, %j2.0
  %idxprom124 = sext i32 %add123 to i64
  %arrayidx125 = getelementptr inbounds float, float* %data, i64 %idxprom124
  %tmp17 = load float, float* %arrayidx125, align 4
  %mul126 = fmul float %tmp16, %tmp17
  %mul127 = mul nsw i32 %j1.0, %m
  %add128 = add nsw i32 %mul127, %j2.0
  %idxprom129 = sext i32 %add128 to i64
  %arrayidx130 = getelementptr inbounds float, float* %symmat, i64 %idxprom129
  %tmp18 = load float, float* %arrayidx130, align 4
  %add131 = fadd float %tmp18, %mul126
  store float %add131, float* %arrayidx130, align 4
  br label %for.inc.132

for.inc.132:                                      ; preds = %for.body.117
  %inc133 = add nsw i32 %i.3, 1
  br label %for.cond.114

for.end.134:                                      ; preds = %for.cond.114
  %mul135 = mul nsw i32 %j1.0, %m
  %add136 = add nsw i32 %mul135, %j2.0
  %idxprom137 = sext i32 %add136 to i64
  %arrayidx138 = getelementptr inbounds float, float* %symmat, i64 %idxprom137
  %tmp19 = load float, float* %arrayidx138, align 4
  %mul139 = mul nsw i32 %j2.0, %m
  %add140 = add nsw i32 %mul139, %j1.0
  %idxprom141 = sext i32 %add140 to i64
  %arrayidx142 = getelementptr inbounds float, float* %symmat, i64 %idxprom141
  store float %tmp19, float* %arrayidx142, align 4
  br label %for.inc.143

for.inc.143:                                      ; preds = %for.end.134
  %inc144 = add nsw i32 %j2.0, 1
  br label %for.cond.106

for.end.145:                                      ; preds = %for.cond.106
  br label %for.inc.146

for.inc.146:                                      ; preds = %for.end.145
  %inc147 = add nsw i32 %j1.0, 1
  br label %for.cond.96

for.end.148:                                      ; preds = %for.cond.96
  %sub149 = sub nsw i32 %m, 1
  %mul150 = mul nsw i32 %sub149, %m
  %sub151 = sub nsw i32 %m, 1
  %add152 = add nsw i32 %mul150, %sub151
  %idxprom153 = sext i32 %add152 to i64
  %arrayidx154 = getelementptr inbounds float, float* %symmat, i64 %idxprom153
  store float 1.000000e+00, float* %arrayidx154, align 4
  ret void
}

; Function Attrs: nounwind
declare double @sqrt(double) #1

; Function Attrs: nounwind uwtable
define void @compareResults(float* %symmat, float* %symmat_outputFromGpu) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.13, %entry
  %i.0 = phi i32 [ 1, %entry ], [ %inc14, %for.inc.13 ]
  %fail.0 = phi i32 [ 0, %entry ], [ %fail.1, %for.inc.13 ]
  %cmp = icmp slt i32 %i.0, 2049
  br i1 %cmp, label %for.body, label %for.end.15

for.body:                                         ; preds = %for.cond
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %j.0 = phi i32 [ 1, %for.body ], [ %inc12, %for.inc ]
  %fail.1 = phi i32 [ %fail.0, %for.body ], [ %fail.2, %for.inc ]
  %cmp2 = icmp slt i32 %j.0, 2049
  br i1 %cmp2, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.cond.1
  %mul = mul nsw i32 %i.0, 2049
  %add = add nsw i32 %mul, %j.0
  %idxprom = sext i32 %add to i64
  %arrayidx = getelementptr inbounds float, float* %symmat, i64 %idxprom
  %tmp = load float, float* %arrayidx, align 4
  %conv = fpext float %tmp to double
  %mul4 = mul nsw i32 %i.0, 2049
  %add5 = add nsw i32 %mul4, %j.0
  %idxprom6 = sext i32 %add5 to i64
  %arrayidx7 = getelementptr inbounds float, float* %symmat_outputFromGpu, i64 %idxprom6
  %tmp1 = load float, float* %arrayidx7, align 4
  %conv8 = fpext float %tmp1 to double
  %call = call float @percentDiff(double %conv, double %conv8)
  %conv9 = fpext float %call to double
  %cmp10 = fcmp ogt double %conv9, 1.050000e+00
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
  %call16 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([74 x i8], [74 x i8]* @.str.1, i32 0, i32 0), double 1.050000e+00, i32 %fail.0)
  ret void
}

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
entry:
  %call = call noalias i8* @malloc(i64 16777216) #3
  %tmp = bitcast i8* %call to float*
  %call1 = call noalias i8* @malloc(i64 8192) #3
  %tmp1 = bitcast i8* %call1 to float*
  %call2 = call noalias i8* @malloc(i64 8192) #3
  %tmp2 = bitcast i8* %call2 to float*
  %call3 = call noalias i8* @malloc(i64 16777216) #3
  %tmp3 = bitcast i8* %call3 to float*
  %tmp4 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %call4 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %tmp4, i8* getelementptr inbounds ([31 x i8], [31 x i8]* @.str.2, i32 0, i32 0))
  call void @init_arrays(float* %tmp)
  %call5 = call double @rtclock()
  call void @correlation(i32 2048, i32 2048, float* %tmp, float* %tmp1, float* %tmp2, float* %tmp3)
  %call6 = call double @rtclock()
  %tmp5 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %sub = fsub double %call6, %call5
  %call7 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %tmp5, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.3, i32 0, i32 0), double %sub)
  %tmp6 = bitcast float* %tmp to i8*
  call void @free(i8* %tmp6) #3
  %tmp7 = bitcast float* %tmp1 to i8*
  call void @free(i8* %tmp7) #3
  %tmp8 = bitcast float* %tmp2 to i8*
  call void @free(i8* %tmp8) #3
  %tmp9 = bitcast float* %tmp3 to i8*
  call void @free(i8* %tmp9) #3
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
