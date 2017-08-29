; ModuleID = 'cloudsim-base.ll'
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
  %call = call i32 @gettimeofday(%struct.timeval* %Tp, %struct.timezone* %Tzp) #4
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
define float @Convert_Celsius_To_Kelvin(float %number_celsius) #0 {
entry:
  %add = fadd float %number_celsius, 0x4071126660000000
  ret float %add
}

; Function Attrs: nounwind uwtable
define float @Convert_hPa_To_mmHg(float %number_hpa) #0 {
entry:
  %mul = fmul float %number_hpa, 0x3FE8008200000000
  ret float %mul
}

; Function Attrs: nounwind uwtable
define float @Convert_milibars_To_mmHg(float %number_milibars) #0 {
entry:
  %mul = fmul float %number_milibars, 0x3FE8008200000000
  ret float %mul
}

; Function Attrs: nounwind uwtable
define float @CalculateRPV(float %temperature_Kelvin, float %pressure_mmHg) #0 {
entry:
  %call = call float @powf(float 1.000000e+01, float -4.000000e+00) #4
  %mul = fmul float 0x401ACCCCC0000000, %call
  %div = fdiv float 0xC0A6F2CCC0000000, %temperature_Kelvin
  %conv = fpext float %div to double
  %conv1 = fpext float %temperature_Kelvin to double
  %call2 = call double @log10(double %conv1) #4
  %mul3 = fmul double 0x4013B69440000000, %call2
  %sub = fsub double %conv, %mul3
  %add = fadd double %sub, 0x40378C0840000000
  %call4 = call double @pow(double 1.000000e+01, double %add) #4
  %conv5 = fptrunc double %call4 to float
  %call6 = call float @Convert_milibars_To_mmHg(float %conv5)
  %mul7 = fmul float %mul, %pressure_mmHg
  %mul8 = fmul float %mul7, 0x3FF3333340000000
  %sub9 = fsub float %call6, %mul8
  ret float %sub9
}

; Function Attrs: nounwind
declare float @powf(float, float) #1

; Function Attrs: nounwind
declare double @pow(double, double) #1

; Function Attrs: nounwind
declare double @log10(double) #1

; Function Attrs: nounwind uwtable
define float @CalculateDewPoint(float %temperature_Kelvin, float %pressure_mmHg) #0 {
entry:
  %call = call float @CalculateRPV(float %temperature_Kelvin, float %pressure_mmHg)
  %conv = fpext float %call to double
  %call1 = call double @log10(double %conv) #4
  %mul = fmul double 0x406DA999A0000000, %call1
  %sub = fsub double 0x40674FB220000000, %mul
  %conv2 = fpext float %call to double
  %call3 = call double @log10(double %conv2) #4
  %sub4 = fsub double %call3, 0x4020926180000000
  %div = fdiv double %sub, %sub4
  %conv5 = fptrunc double %div to float
  ret float %conv5
}

; Function Attrs: nounwind uwtable
define void @init_wind(i32 %ni, i32 %nj, float* %A, float* %B) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.17, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc18, %for.inc.17 ]
  %cmp = icmp slt i32 %i.0, %ni
  br i1 %cmp, label %for.body, label %for.end.19

for.body:                                         ; preds = %for.cond
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %j.0 = phi i32 [ 0, %for.body ], [ %inc, %for.inc ]
  %cmp2 = icmp slt i32 %j.0, %nj
  br i1 %cmp2, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.cond.1
  %call = call i32 @rand() #4
  %conv = sitofp i32 %call to float
  %div = fdiv float %conv, 0x41E0000000000000
  %mul = fmul float %div, 2.000000e+00
  %mul4 = fmul float %mul, 0x3FB99999A0000000
  %add = fadd float 0x402DCCCCC0000000, %mul4
  %mul5 = mul nsw i32 %i.0, %nj
  %add6 = add nsw i32 %mul5, %j.0
  %idxprom = sext i32 %add6 to i64
  %arrayidx = getelementptr inbounds float, float* %A, i64 %idxprom
  store float %add, float* %arrayidx, align 4
  %call7 = call i32 @rand() #4
  %conv8 = sitofp i32 %call7 to float
  %div9 = fdiv float %conv8, 0x41E0000000000000
  %mul10 = fmul float %div9, 2.000000e+00
  %mul11 = fmul float %mul10, 0x3FB99999A0000000
  %add12 = fadd float 0x4027CCCCC0000000, %mul11
  %mul13 = mul nsw i32 %i.0, %nj
  %add14 = add nsw i32 %mul13, %j.0
  %idxprom15 = sext i32 %add14 to i64
  %arrayidx16 = getelementptr inbounds float, float* %B, i64 %idxprom15
  store float %add12, float* %arrayidx16, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.3
  %inc = add nsw i32 %j.0, 1
  br label %for.cond.1

for.end:                                          ; preds = %for.cond.1
  br label %for.inc.17

for.inc.17:                                       ; preds = %for.end
  %inc18 = add nsw i32 %i.0, 1
  br label %for.cond

for.end.19:                                       ; preds = %for.cond
  ret void
}

; Function Attrs: nounwind
declare i32 @rand() #1

; Function Attrs: nounwind uwtable
define void @init_array(i32 %ni, i32 %nj, float* %A, float* %B) #0 {
entry:
  %div = sdiv i32 %nj, 2
  %div1 = sdiv i32 %ni, 2
  %call = call float @Convert_Celsius_To_Kelvin(float -3.000000e+00)
  %call2 = call float @Convert_hPa_To_mmHg(float 7.000000e+02)
  %call3 = call float @CalculateDewPoint(float %call, float %call2)
  %sub = fsub float %call3, 5.000000e-01
  %add = fadd float %call3, 5.000000e-01
  call void @srand(i32 1) #4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.12, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc13, %for.inc.12 ]
  %cmp = icmp slt i32 %i.0, %ni
  br i1 %cmp, label %for.body, label %for.end.14

for.body:                                         ; preds = %for.cond
  br label %for.cond.4

for.cond.4:                                       ; preds = %for.inc, %for.body
  %j.0 = phi i32 [ 0, %for.body ], [ %inc, %for.inc ]
  %cmp5 = icmp slt i32 %j.0, %nj
  br i1 %cmp5, label %for.body.6, label %for.end

for.body.6:                                       ; preds = %for.cond.4
  %mul = mul nsw i32 %i.0, %nj
  %add7 = add nsw i32 %mul, %j.0
  %idxprom = sext i32 %add7 to i64
  %arrayidx = getelementptr inbounds float, float* %A, i64 %idxprom
  store float -3.000000e+00, float* %arrayidx, align 4
  %mul8 = mul nsw i32 %i.0, %nj
  %add9 = add nsw i32 %mul8, %j.0
  %idxprom10 = sext i32 %add9 to i64
  %arrayidx11 = getelementptr inbounds float, float* %B, i64 %idxprom10
  store float -3.000000e+00, float* %arrayidx11, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.6
  %inc = add nsw i32 %j.0, 1
  br label %for.cond.4

for.end:                                          ; preds = %for.cond.4
  br label %for.inc.12

for.inc.12:                                       ; preds = %for.end
  %inc13 = add nsw i32 %i.0, 1
  br label %for.cond

for.end.14:                                       ; preds = %for.cond
  %sub15 = sub nsw i32 %div, 20
  br label %for.cond.16

for.cond.16:                                      ; preds = %for.inc.52, %for.end.14
  %i.1 = phi i32 [ %sub15, %for.end.14 ], [ %inc53, %for.inc.52 ]
  %add17 = add nsw i32 %div, 20
  %cmp18 = icmp slt i32 %i.1, %add17
  br i1 %cmp18, label %for.body.19, label %for.end.54

for.body.19:                                      ; preds = %for.cond.16
  %conv = sitofp i32 20 to float
  %conv20 = fpext float %conv to double
  %call21 = call double @pow(double %conv20, double 2.000000e+00) #4
  %conv22 = sitofp i32 %div to float
  %conv23 = sitofp i32 %i.1 to float
  %sub24 = fsub float %conv22, %conv23
  %conv25 = fpext float %sub24 to double
  %call26 = call double @pow(double %conv25, double 2.000000e+00) #4
  %sub27 = fsub double %call21, %call26
  %call28 = call double @sqrt(double %sub27) #4
  %conv29 = sitofp i32 %div1 to double
  %sub30 = fsub double %call28, %conv29
  %call31 = call double @floor(double %sub30) #5
  %mul32 = fmul double %call31, -1.000000e+00
  %conv33 = fptosi double %mul32 to i32
  %sub34 = sub nsw i32 %div1, %conv33
  %add35 = add nsw i32 %div1, %sub34
  br label %for.cond.36

for.cond.36:                                      ; preds = %for.inc.50, %for.body.19
  %j.1 = phi i32 [ %add35, %for.body.19 ], [ %dec, %for.inc.50 ]
  %cmp37 = icmp sge i32 %j.1, %conv33
  br i1 %cmp37, label %for.body.39, label %for.end.51

for.body.39:                                      ; preds = %for.cond.36
  %call40 = call i32 @rand() #4
  %conv41 = sitofp i32 %call40 to float
  %div42 = fdiv float %conv41, 0x41E0000000000000
  %sub43 = fsub float %add, %sub
  %mul44 = fmul float %div42, %sub43
  %add45 = fadd float %sub, %mul44
  %mul46 = mul nsw i32 %i.1, %nj
  %add47 = add nsw i32 %mul46, %j.1
  %idxprom48 = sext i32 %add47 to i64
  %arrayidx49 = getelementptr inbounds float, float* %A, i64 %idxprom48
  store float %add45, float* %arrayidx49, align 4
  br label %for.inc.50

for.inc.50:                                       ; preds = %for.body.39
  %dec = add nsw i32 %j.1, -1
  br label %for.cond.36

for.end.51:                                       ; preds = %for.cond.36
  br label %for.inc.52

for.inc.52:                                       ; preds = %for.end.51
  %inc53 = add nsw i32 %i.1, 1
  br label %for.cond.16

for.end.54:                                       ; preds = %for.cond.16
  ret void
}

; Function Attrs: nounwind
declare void @srand(i32) #1

; Function Attrs: nounwind readnone
declare double @floor(double) #3

; Function Attrs: nounwind
declare double @sqrt(double) #1

; Function Attrs: nounwind uwtable
define void @cloudsim(i32 %tsteps, i32 %ni, i32 %nj, float* %A, float* %B, float* %WIND_X, float* %WIND_Y) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.159, %entry
  %t.0 = phi i32 [ 0, %entry ], [ %inc160, %for.inc.159 ]
  %n.0 = phi i32 [ undef, %entry ], [ %n.1, %for.inc.159 ]
  %numNeighbor.0 = phi i32 [ 4, %entry ], [ %numNeighbor.1, %for.inc.159 ]
  %cmp = icmp slt i32 %t.0, %tsteps
  br i1 %cmp, label %for.body, label %for.end.161

for.body:                                         ; preds = %for.cond
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc.134, %for.body
  %i.0 = phi i32 [ 0, %for.body ], [ %inc135, %for.inc.134 ]
  %n.1 = phi i32 [ %n.0, %for.body ], [ %n.2, %for.inc.134 ]
  %numNeighbor.1 = phi i32 [ %numNeighbor.0, %for.body ], [ %numNeighbor.2, %for.inc.134 ]
  %cmp2 = icmp slt i32 %i.0, %ni
  br i1 %cmp2, label %for.body.3, label %for.end.136

for.body.3:                                       ; preds = %for.cond.1
  br label %for.cond.4

for.cond.4:                                       ; preds = %for.inc, %for.body.3
  %j.0 = phi i32 [ 0, %for.body.3 ], [ %inc, %for.inc ]
  %n.2 = phi i32 [ %n.1, %for.body.3 ], [ %cond46, %for.inc ]
  %numNeighbor.2 = phi i32 [ %numNeighbor.1, %for.body.3 ], [ %cond27, %for.inc ]
  %cmp5 = icmp slt i32 %j.0, %nj
  br i1 %cmp5, label %for.body.6, label %for.end

for.body.6:                                       ; preds = %for.cond.4
  %cmp7 = icmp eq i32 %j.0, 0
  br i1 %cmp7, label %cond.true, label %cond.false

cond.true:                                        ; preds = %for.body.6
  %sub = sub nsw i32 %numNeighbor.2, 1
  br label %cond.end

cond.false:                                       ; preds = %for.body.6
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi i32 [ %sub, %cond.true ], [ %numNeighbor.2, %cond.false ]
  %cmp8 = icmp eq i32 %i.0, 0
  br i1 %cmp8, label %cond.true.9, label %cond.false.11

cond.true.9:                                      ; preds = %cond.end
  %sub10 = sub nsw i32 %cond, 1
  br label %cond.end.12

cond.false.11:                                    ; preds = %cond.end
  br label %cond.end.12

cond.end.12:                                      ; preds = %cond.false.11, %cond.true.9
  %cond13 = phi i32 [ %sub10, %cond.true.9 ], [ %cond, %cond.false.11 ]
  %sub14 = sub nsw i32 %nj, 1
  %cmp15 = icmp eq i32 %j.0, %sub14
  br i1 %cmp15, label %cond.true.16, label %cond.false.18

cond.true.16:                                     ; preds = %cond.end.12
  %sub17 = sub nsw i32 %cond13, 1
  br label %cond.end.19

cond.false.18:                                    ; preds = %cond.end.12
  br label %cond.end.19

cond.end.19:                                      ; preds = %cond.false.18, %cond.true.16
  %cond20 = phi i32 [ %sub17, %cond.true.16 ], [ %cond13, %cond.false.18 ]
  %sub21 = sub nsw i32 %ni, 1
  %cmp22 = icmp eq i32 %i.0, %sub21
  br i1 %cmp22, label %cond.true.23, label %cond.false.25

cond.true.23:                                     ; preds = %cond.end.19
  %sub24 = sub nsw i32 %cond20, 1
  br label %cond.end.26

cond.false.25:                                    ; preds = %cond.end.19
  br label %cond.end.26

cond.end.26:                                      ; preds = %cond.false.25, %cond.true.23
  %cond27 = phi i32 [ %sub24, %cond.true.23 ], [ %cond20, %cond.false.25 ]
  %mul = mul nsw i32 %i.0, %nj
  %add = add nsw i32 %mul, %j.0
  %cmp28 = icmp eq i32 %j.0, 0
  br i1 %cmp28, label %cond.true.29, label %cond.false.30

cond.true.29:                                     ; preds = %cond.end.26
  br label %cond.end.32

cond.false.30:                                    ; preds = %cond.end.26
  %sub31 = sub nsw i32 %add, 1
  br label %cond.end.32

cond.end.32:                                      ; preds = %cond.false.30, %cond.true.29
  %cond33 = phi i32 [ %add, %cond.true.29 ], [ %sub31, %cond.false.30 ]
  %sub34 = sub nsw i32 %nj, 1
  %cmp35 = icmp eq i32 %j.0, %sub34
  br i1 %cmp35, label %cond.true.36, label %cond.false.37

cond.true.36:                                     ; preds = %cond.end.32
  br label %cond.end.39

cond.false.37:                                    ; preds = %cond.end.32
  %add38 = add nsw i32 %add, 1
  br label %cond.end.39

cond.end.39:                                      ; preds = %cond.false.37, %cond.true.36
  %cond40 = phi i32 [ %add, %cond.true.36 ], [ %add38, %cond.false.37 ]
  %cmp41 = icmp eq i32 %i.0, 0
  br i1 %cmp41, label %cond.true.42, label %cond.false.43

cond.true.42:                                     ; preds = %cond.end.39
  br label %cond.end.45

cond.false.43:                                    ; preds = %cond.end.39
  %sub44 = sub nsw i32 %add, %ni
  br label %cond.end.45

cond.end.45:                                      ; preds = %cond.false.43, %cond.true.42
  %cond46 = phi i32 [ %add, %cond.true.42 ], [ %sub44, %cond.false.43 ]
  %sub47 = sub nsw i32 %ni, 1
  %cmp48 = icmp eq i32 %i.0, %sub47
  br i1 %cmp48, label %cond.true.49, label %cond.false.50

cond.true.49:                                     ; preds = %cond.end.45
  br label %cond.end.52

cond.false.50:                                    ; preds = %cond.end.45
  %add51 = add nsw i32 %add, %ni
  br label %cond.end.52

cond.end.52:                                      ; preds = %cond.false.50, %cond.true.49
  %cond53 = phi i32 [ %add, %cond.true.49 ], [ %add51, %cond.false.50 ]
  %idxprom = sext i32 %add to i64
  %arrayidx = getelementptr inbounds float, float* %A, i64 %idxprom
  %tmp = load float, float* %arrayidx, align 4
  %mul54 = fmul float 4.000000e+00, %tmp
  %idxprom55 = sext i32 %cond46 to i64
  %arrayidx56 = getelementptr inbounds float, float* %A, i64 %idxprom55
  %tmp1 = load float, float* %arrayidx56, align 4
  %idxprom57 = sext i32 %cond33 to i64
  %arrayidx58 = getelementptr inbounds float, float* %A, i64 %idxprom57
  %tmp2 = load float, float* %arrayidx58, align 4
  %add59 = fadd float %tmp1, %tmp2
  %idxprom60 = sext i32 %cond40 to i64
  %arrayidx61 = getelementptr inbounds float, float* %A, i64 %idxprom60
  %tmp3 = load float, float* %arrayidx61, align 4
  %add62 = fadd float %add59, %tmp3
  %idxprom63 = sext i32 %cond53 to i64
  %arrayidx64 = getelementptr inbounds float, float* %A, i64 %idxprom63
  %tmp4 = load float, float* %arrayidx64, align 4
  %add65 = fadd float %add62, %tmp4
  %sub66 = fsub float %mul54, %add65
  %conv = sitofp i32 %cond27 to float
  %div = fdiv float %sub66, %conv
  %mul67 = fmul float 0xBF98E21960000000, %div
  %mul68 = fmul float %mul67, 0x3F50624DE0000000
  %idxprom69 = sext i32 %add to i64
  %arrayidx70 = getelementptr inbounds float, float* %A, i64 %idxprom69
  %tmp5 = load float, float* %arrayidx70, align 4
  %add71 = fadd float %tmp5, %mul68
  %mul72 = mul nsw i32 %i.0, %nj
  %add73 = add nsw i32 %mul72, %j.0
  %idxprom74 = sext i32 %add73 to i64
  %arrayidx75 = getelementptr inbounds float, float* %WIND_X, i64 %idxprom74
  %tmp6 = load float, float* %arrayidx75, align 4
  %mul76 = mul nsw i32 %i.0, %nj
  %add77 = add nsw i32 %mul76, %j.0
  %idxprom78 = sext i32 %add77 to i64
  %arrayidx79 = getelementptr inbounds float, float* %WIND_Y, i64 %idxprom78
  %tmp7 = load float, float* %arrayidx79, align 4
  %cmp80 = fcmp ogt float %tmp6, 0.000000e+00
  br i1 %cmp80, label %cond.true.82, label %cond.false.85

cond.true.82:                                     ; preds = %cond.end.52
  %idxprom83 = sext i32 %cond40 to i64
  %arrayidx84 = getelementptr inbounds float, float* %A, i64 %idxprom83
  %tmp8 = load float, float* %arrayidx84, align 4
  br label %cond.end.88

cond.false.85:                                    ; preds = %cond.end.52
  %idxprom86 = sext i32 %cond33 to i64
  %arrayidx87 = getelementptr inbounds float, float* %A, i64 %idxprom86
  %tmp9 = load float, float* %arrayidx87, align 4
  br label %cond.end.88

cond.end.88:                                      ; preds = %cond.false.85, %cond.true.82
  %cond89 = phi float [ %tmp8, %cond.true.82 ], [ %tmp9, %cond.false.85 ]
  %cmp90 = fcmp ogt float %tmp7, 0.000000e+00
  br i1 %cmp90, label %cond.true.92, label %cond.false.95

cond.true.92:                                     ; preds = %cond.end.88
  %idxprom93 = sext i32 %cond53 to i64
  %arrayidx94 = getelementptr inbounds float, float* %A, i64 %idxprom93
  %tmp10 = load float, float* %arrayidx94, align 4
  br label %cond.end.98

cond.false.95:                                    ; preds = %cond.end.88
  %idxprom96 = sext i32 %cond46 to i64
  %arrayidx97 = getelementptr inbounds float, float* %A, i64 %idxprom96
  %tmp11 = load float, float* %arrayidx97, align 4
  br label %cond.end.98

cond.end.98:                                      ; preds = %cond.false.95, %cond.true.92
  %cond99 = phi float [ %tmp10, %cond.true.92 ], [ %tmp11, %cond.false.95 ]
  %cmp100 = fcmp ogt float %tmp6, 0.000000e+00
  %cond102 = select i1 %cmp100, i32 1, i32 -1
  %cmp103 = fcmp ogt float %tmp7, 0.000000e+00
  %cond105 = select i1 %cmp103, i32 1, i32 -1
  %conv106 = sitofp i32 %cond102 to float
  %mul107 = fmul float %conv106, %tmp6
  %conv108 = sitofp i32 %cond105 to float
  %mul109 = fmul float %conv108, %tmp7
  %sub110 = fsub float -0.000000e+00, %mul107
  %idxprom111 = sext i32 %add to i64
  %arrayidx112 = getelementptr inbounds float, float* %A, i64 %idxprom111
  %tmp12 = load float, float* %arrayidx112, align 4
  %sub113 = fsub float %tmp12, %cond89
  %div114 = fdiv float %sub113, 0x3FB99999A0000000
  %mul115 = fmul float %sub110, %div114
  %idxprom116 = sext i32 %add to i64
  %arrayidx117 = getelementptr inbounds float, float* %A, i64 %idxprom116
  %tmp13 = load float, float* %arrayidx117, align 4
  %sub118 = fsub float %tmp13, %cond99
  %div119 = fdiv float %sub118, 0x3FB99999A0000000
  %mul120 = fmul float %mul109, %div119
  %sub121 = fsub float %mul115, %mul120
  %cmp122 = icmp eq i32 %cond27, 4
  br i1 %cmp122, label %cond.true.124, label %cond.false.126

cond.true.124:                                    ; preds = %cond.end.98
  %mul125 = fmul float %sub121, 0x3F50624DE0000000
  br label %cond.end.127

cond.false.126:                                   ; preds = %cond.end.98
  br label %cond.end.127

cond.end.127:                                     ; preds = %cond.false.126, %cond.true.124
  %cond128 = phi float [ %mul125, %cond.true.124 ], [ 0.000000e+00, %cond.false.126 ]
  %add129 = fadd float %add71, %cond128
  %mul130 = mul nsw i32 %i.0, %nj
  %add131 = add nsw i32 %mul130, %j.0
  %idxprom132 = sext i32 %add131 to i64
  %arrayidx133 = getelementptr inbounds float, float* %B, i64 %idxprom132
  store float %add129, float* %arrayidx133, align 4
  br label %for.inc

for.inc:                                          ; preds = %cond.end.127
  %inc = add nsw i32 %j.0, 1
  br label %for.cond.4

for.end:                                          ; preds = %for.cond.4
  br label %for.inc.134

for.inc.134:                                      ; preds = %for.end
  %inc135 = add nsw i32 %i.0, 1
  br label %for.cond.1

for.end.136:                                      ; preds = %for.cond.1
  br label %for.cond.137

for.cond.137:                                     ; preds = %for.inc.156, %for.end.136
  %i.1 = phi i32 [ 0, %for.end.136 ], [ %inc157, %for.inc.156 ]
  %cmp138 = icmp slt i32 %i.1, %n.1
  br i1 %cmp138, label %for.body.140, label %for.end.158

for.body.140:                                     ; preds = %for.cond.137
  br label %for.cond.141

for.cond.141:                                     ; preds = %for.inc.153, %for.body.140
  %j.1 = phi i32 [ 0, %for.body.140 ], [ %inc154, %for.inc.153 ]
  %cmp142 = icmp slt i32 %j.1, %n.1
  br i1 %cmp142, label %for.body.144, label %for.end.155

for.body.144:                                     ; preds = %for.cond.141
  %mul145 = mul nsw i32 %i.1, %n.1
  %add146 = add nsw i32 %mul145, %j.1
  %idxprom147 = sext i32 %add146 to i64
  %arrayidx148 = getelementptr inbounds float, float* %B, i64 %idxprom147
  %tmp14 = load float, float* %arrayidx148, align 4
  %mul149 = mul nsw i32 %i.1, %n.1
  %add150 = add nsw i32 %mul149, %j.1
  %idxprom151 = sext i32 %add150 to i64
  %arrayidx152 = getelementptr inbounds float, float* %A, i64 %idxprom151
  store float %tmp14, float* %arrayidx152, align 4
  br label %for.inc.153

for.inc.153:                                      ; preds = %for.body.144
  %inc154 = add nsw i32 %j.1, 1
  br label %for.cond.141

for.end.155:                                      ; preds = %for.cond.141
  br label %for.inc.156

for.inc.156:                                      ; preds = %for.end.155
  %inc157 = add nsw i32 %i.1, 1
  br label %for.cond.137

for.end.158:                                      ; preds = %for.cond.137
  br label %for.inc.159

for.inc.159:                                      ; preds = %for.end.158
  %inc160 = add nsw i32 %t.0, 1
  br label %for.cond

for.end.161:                                      ; preds = %for.cond
  ret void
}

; Function Attrs: nounwind uwtable
define i32 @main(i32 %argc, i8** %argv) #0 {
entry:
  %mul = mul nsw i32 1024, 1024
  %conv = sext i32 %mul to i64
  %mul1 = mul i64 %conv, 4
  %call = call noalias i8* @malloc(i64 %mul1) #4
  %tmp = bitcast i8* %call to float*
  %mul2 = mul nsw i32 1024, 1024
  %conv3 = sext i32 %mul2 to i64
  %mul4 = mul i64 %conv3, 4
  %call5 = call noalias i8* @malloc(i64 %mul4) #4
  %tmp1 = bitcast i8* %call5 to float*
  %mul6 = mul nsw i32 1024, 1024
  %conv7 = sext i32 %mul6 to i64
  %mul8 = mul i64 %conv7, 4
  %call9 = call noalias i8* @malloc(i64 %mul8) #4
  %tmp2 = bitcast i8* %call9 to float*
  %mul10 = mul nsw i32 1024, 1024
  %conv11 = sext i32 %mul10 to i64
  %mul12 = mul i64 %conv11, 4
  %call13 = call noalias i8* @malloc(i64 %mul12) #4
  %tmp3 = bitcast i8* %call13 to float*
  call void @init_array(i32 1024, i32 1024, float* %tmp, float* %tmp1)
  call void @init_wind(i32 1024, i32 1024, float* %tmp2, float* %tmp3)
  %call14 = call double @rtclock()
  call void @cloudsim(i32 10, i32 1024, i32 1024, float* %tmp, float* %tmp1, float* %tmp2, float* %tmp3)
  %call15 = call double @rtclock()
  %tmp4 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %sub = fsub double %call15, %call14
  %call16 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %tmp4, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.1, i32 0, i32 0), double %sub)
  %tmp5 = bitcast float* %tmp to i8*
  call void @free(i8* %tmp5) #4
  %tmp6 = bitcast float* %tmp1 to i8*
  call void @free(i8* %tmp6) #4
  %tmp7 = bitcast float* %tmp2 to i8*
  call void @free(i8* %tmp7) #4
  %tmp8 = bitcast float* %tmp3 to i8*
  call void @free(i8* %tmp8) #4
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
attributes #3 = { nounwind readnone "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { nounwind }
attributes #5 = { nounwind readnone }

!llvm.ident = !{!0}

!0 = !{!"clang version 3.7.1 (https://github.com/llvm-mirror/clang.git 0dbefa1b83eb90f7a06b5df5df254ce32be3db4b) (https://github.com/llvm-mirror/llvm.git 33c352b3eda89abc24e7511d9045fa2e499a42e3)"}
