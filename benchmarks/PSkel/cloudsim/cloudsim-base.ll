; ModuleID = 'cloudsim.c'
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
  %stat = alloca i32, align 4
  %call = call i32 @gettimeofday(%struct.timeval* %Tp, %struct.timezone* %Tzp) #4
  store i32 %call, i32* %stat, align 4
  %0 = load i32, i32* %stat, align 4
  %cmp = icmp ne i32 %0, 0
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %1 = load i32, i32* %stat, align 4
  %call1 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([35 x i8], [35 x i8]* @.str, i32 0, i32 0), i32 %1)
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  %tv_sec = getelementptr inbounds %struct.timeval, %struct.timeval* %Tp, i32 0, i32 0
  %2 = load i64, i64* %tv_sec, align 8
  %conv = sitofp i64 %2 to double
  %tv_usec = getelementptr inbounds %struct.timeval, %struct.timeval* %Tp, i32 0, i32 1
  %3 = load i64, i64* %tv_usec, align 8
  %conv2 = sitofp i64 %3 to double
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
  %retval = alloca float, align 4
  %a.addr = alloca float, align 4
  store float %a, float* %a.addr, align 4
  %0 = load float, float* %a.addr, align 4
  %cmp = fcmp olt float %0, 0.000000e+00
  br i1 %cmp, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  %1 = load float, float* %a.addr, align 4
  %mul = fmul float %1, -1.000000e+00
  store float %mul, float* %retval
  br label %return

if.else:                                          ; preds = %entry
  %2 = load float, float* %a.addr, align 4
  store float %2, float* %retval
  br label %return

return:                                           ; preds = %if.else, %if.then
  %3 = load float, float* %retval
  ret float %3
}

; Function Attrs: nounwind uwtable
define float @percentDiff(double %val1, double %val2) #0 {
entry:
  %retval = alloca float, align 4
  %val1.addr = alloca double, align 8
  %val2.addr = alloca double, align 8
  store double %val1, double* %val1.addr, align 8
  store double %val2, double* %val2.addr, align 8
  %0 = load double, double* %val1.addr, align 8
  %conv = fptrunc double %0 to float
  %call = call float @absVal(float %conv)
  %conv1 = fpext float %call to double
  %cmp = fcmp olt double %conv1, 1.000000e-02
  br i1 %cmp, label %land.lhs.true, label %if.else

land.lhs.true:                                    ; preds = %entry
  %1 = load double, double* %val2.addr, align 8
  %conv3 = fptrunc double %1 to float
  %call4 = call float @absVal(float %conv3)
  %conv5 = fpext float %call4 to double
  %cmp6 = fcmp olt double %conv5, 1.000000e-02
  br i1 %cmp6, label %if.then, label %if.else

if.then:                                          ; preds = %land.lhs.true
  store float 0.000000e+00, float* %retval
  br label %return

if.else:                                          ; preds = %land.lhs.true, %entry
  %2 = load double, double* %val1.addr, align 8
  %3 = load double, double* %val2.addr, align 8
  %sub = fsub double %2, %3
  %conv8 = fptrunc double %sub to float
  %call9 = call float @absVal(float %conv8)
  %4 = load double, double* %val1.addr, align 8
  %add = fadd double %4, 0x3E45798EE0000000
  %conv10 = fptrunc double %add to float
  %call11 = call float @absVal(float %conv10)
  %div = fdiv float %call9, %call11
  %call12 = call float @absVal(float %div)
  %mul = fmul float 1.000000e+02, %call12
  store float %mul, float* %retval
  br label %return

return:                                           ; preds = %if.else, %if.then
  %5 = load float, float* %retval
  ret float %5
}

; Function Attrs: nounwind uwtable
define float @Convert_Celsius_To_Kelvin(float %number_celsius) #0 {
entry:
  %number_celsius.addr = alloca float, align 4
  %number_kelvin = alloca float, align 4
  store float %number_celsius, float* %number_celsius.addr, align 4
  %0 = load float, float* %number_celsius.addr, align 4
  %add = fadd float %0, 0x4071126660000000
  store float %add, float* %number_kelvin, align 4
  %1 = load float, float* %number_kelvin, align 4
  ret float %1
}

; Function Attrs: nounwind uwtable
define float @Convert_hPa_To_mmHg(float %number_hpa) #0 {
entry:
  %number_hpa.addr = alloca float, align 4
  %number_mmHg = alloca float, align 4
  store float %number_hpa, float* %number_hpa.addr, align 4
  %0 = load float, float* %number_hpa.addr, align 4
  %mul = fmul float %0, 0x3FE8008200000000
  store float %mul, float* %number_mmHg, align 4
  %1 = load float, float* %number_mmHg, align 4
  ret float %1
}

; Function Attrs: nounwind uwtable
define float @Convert_milibars_To_mmHg(float %number_milibars) #0 {
entry:
  %number_milibars.addr = alloca float, align 4
  %number_mmHg = alloca float, align 4
  store float %number_milibars, float* %number_milibars.addr, align 4
  %0 = load float, float* %number_milibars.addr, align 4
  %mul = fmul float %0, 0x3FE8008200000000
  store float %mul, float* %number_mmHg, align 4
  %1 = load float, float* %number_mmHg, align 4
  ret float %1
}

; Function Attrs: nounwind uwtable
define float @CalculateRPV(float %temperature_Kelvin, float %pressure_mmHg) #0 {
entry:
  %temperature_Kelvin.addr = alloca float, align 4
  %pressure_mmHg.addr = alloca float, align 4
  %realPressureVapor = alloca float, align 4
  %PsychrometricConstant = alloca float, align 4
  %PsychrometricDepression = alloca float, align 4
  %esu = alloca float, align 4
  store float %temperature_Kelvin, float* %temperature_Kelvin.addr, align 4
  store float %pressure_mmHg, float* %pressure_mmHg.addr, align 4
  %call = call float @powf(float 1.000000e+01, float -4.000000e+00) #4
  %mul = fmul float 0x401ACCCCC0000000, %call
  store float %mul, float* %PsychrometricConstant, align 4
  store float 0x3FF3333340000000, float* %PsychrometricDepression, align 4
  %0 = load float, float* %temperature_Kelvin.addr, align 4
  %div = fdiv float 0xC0A6F2CCC0000000, %0
  %conv = fpext float %div to double
  %1 = load float, float* %temperature_Kelvin.addr, align 4
  %conv1 = fpext float %1 to double
  %call2 = call double @log10(double %conv1) #4
  %mul3 = fmul double 0x4013B69440000000, %call2
  %sub = fsub double %conv, %mul3
  %add = fadd double %sub, 0x40378C0840000000
  %call4 = call double @pow(double 1.000000e+01, double %add) #4
  %conv5 = fptrunc double %call4 to float
  store float %conv5, float* %esu, align 4
  %2 = load float, float* %esu, align 4
  %call6 = call float @Convert_milibars_To_mmHg(float %2)
  %3 = load float, float* %PsychrometricConstant, align 4
  %4 = load float, float* %pressure_mmHg.addr, align 4
  %mul7 = fmul float %3, %4
  %5 = load float, float* %PsychrometricDepression, align 4
  %mul8 = fmul float %mul7, %5
  %sub9 = fsub float %call6, %mul8
  store float %sub9, float* %realPressureVapor, align 4
  %6 = load float, float* %realPressureVapor, align 4
  ret float %6
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
  %temperature_Kelvin.addr = alloca float, align 4
  %pressure_mmHg.addr = alloca float, align 4
  %dewPoint = alloca float, align 4
  %realPressureVapor = alloca float, align 4
  store float %temperature_Kelvin, float* %temperature_Kelvin.addr, align 4
  store float %pressure_mmHg, float* %pressure_mmHg.addr, align 4
  %0 = load float, float* %temperature_Kelvin.addr, align 4
  %1 = load float, float* %pressure_mmHg.addr, align 4
  %call = call float @CalculateRPV(float %0, float %1)
  store float %call, float* %realPressureVapor, align 4
  %2 = load float, float* %realPressureVapor, align 4
  %conv = fpext float %2 to double
  %call1 = call double @log10(double %conv) #4
  %mul = fmul double 0x406DA999A0000000, %call1
  %sub = fsub double 0x40674FB220000000, %mul
  %3 = load float, float* %realPressureVapor, align 4
  %conv2 = fpext float %3 to double
  %call3 = call double @log10(double %conv2) #4
  %sub4 = fsub double %call3, 0x4020926180000000
  %div = fdiv double %sub, %sub4
  %conv5 = fptrunc double %div to float
  store float %conv5, float* %dewPoint, align 4
  %4 = load float, float* %dewPoint, align 4
  ret float %4
}

; Function Attrs: nounwind uwtable
define void @init_wind(i32 %ni, i32 %nj, float* %A, float* %B) #0 {
entry:
  %ni.addr = alloca i32, align 4
  %nj.addr = alloca i32, align 4
  %A.addr = alloca float*, align 8
  %B.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  store i32 %ni, i32* %ni.addr, align 4
  store i32 %nj, i32* %nj.addr, align 4
  store float* %A, float** %A.addr, align 8
  store float* %B, float** %B.addr, align 8
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.17, %entry
  %0 = load i32, i32* %i, align 4
  %1 = load i32, i32* %ni.addr, align 4
  %cmp = icmp slt i32 %0, %1
  br i1 %cmp, label %for.body, label %for.end.19

for.body:                                         ; preds = %for.cond
  store i32 0, i32* %j, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %2 = load i32, i32* %j, align 4
  %3 = load i32, i32* %nj.addr, align 4
  %cmp2 = icmp slt i32 %2, %3
  br i1 %cmp2, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.cond.1
  %call = call i32 @rand() #4
  %conv = sitofp i32 %call to float
  %div = fdiv float %conv, 0x41E0000000000000
  %mul = fmul float %div, 2.000000e+00
  %mul4 = fmul float %mul, 0x3FB99999A0000000
  %add = fadd float 0x402DCCCCC0000000, %mul4
  %4 = load i32, i32* %i, align 4
  %5 = load i32, i32* %nj.addr, align 4
  %mul5 = mul nsw i32 %4, %5
  %6 = load i32, i32* %j, align 4
  %add6 = add nsw i32 %mul5, %6
  %idxprom = sext i32 %add6 to i64
  %7 = load float*, float** %A.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %7, i64 %idxprom
  store float %add, float* %arrayidx, align 4
  %call7 = call i32 @rand() #4
  %conv8 = sitofp i32 %call7 to float
  %div9 = fdiv float %conv8, 0x41E0000000000000
  %mul10 = fmul float %div9, 2.000000e+00
  %mul11 = fmul float %mul10, 0x3FB99999A0000000
  %add12 = fadd float 0x4027CCCCC0000000, %mul11
  %8 = load i32, i32* %i, align 4
  %9 = load i32, i32* %nj.addr, align 4
  %mul13 = mul nsw i32 %8, %9
  %10 = load i32, i32* %j, align 4
  %add14 = add nsw i32 %mul13, %10
  %idxprom15 = sext i32 %add14 to i64
  %11 = load float*, float** %B.addr, align 8
  %arrayidx16 = getelementptr inbounds float, float* %11, i64 %idxprom15
  store float %add12, float* %arrayidx16, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.3
  %12 = load i32, i32* %j, align 4
  %inc = add nsw i32 %12, 1
  store i32 %inc, i32* %j, align 4
  br label %for.cond.1

for.end:                                          ; preds = %for.cond.1
  br label %for.inc.17

for.inc.17:                                       ; preds = %for.end
  %13 = load i32, i32* %i, align 4
  %inc18 = add nsw i32 %13, 1
  store i32 %inc18, i32* %i, align 4
  br label %for.cond

for.end.19:                                       ; preds = %for.cond
  ret void
}

; Function Attrs: nounwind
declare i32 @rand() #1

; Function Attrs: nounwind uwtable
define void @init_array(i32 %ni, i32 %nj, float* %A, float* %B) #0 {
entry:
  %ni.addr = alloca i32, align 4
  %nj.addr = alloca i32, align 4
  %A.addr = alloca float*, align 8
  %B.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %y = alloca i32, align 4
  %x0 = alloca i32, align 4
  %y0 = alloca i32, align 4
  %raio_nuvem = alloca i32, align 4
  %temperaturaAtmosferica = alloca float, align 4
  %pressaoAtmosferica = alloca float, align 4
  %deltaT = alloca float, align 4
  %pontoOrvalho = alloca float, align 4
  %limInfPO = alloca float, align 4
  %limSupPO = alloca float, align 4
  store i32 %ni, i32* %ni.addr, align 4
  store i32 %nj, i32* %nj.addr, align 4
  store float* %A, float** %A.addr, align 8
  store float* %B, float** %B.addr, align 8
  %0 = load i32, i32* %nj.addr, align 4
  %div = sdiv i32 %0, 2
  store i32 %div, i32* %x0, align 4
  %1 = load i32, i32* %ni.addr, align 4
  %div1 = sdiv i32 %1, 2
  store i32 %div1, i32* %y0, align 4
  store i32 20, i32* %raio_nuvem, align 4
  store float -3.000000e+00, float* %temperaturaAtmosferica, align 4
  store float 7.000000e+02, float* %pressaoAtmosferica, align 4
  store float 0x3F50624DE0000000, float* %deltaT, align 4
  %2 = load float, float* %temperaturaAtmosferica, align 4
  %call = call float @Convert_Celsius_To_Kelvin(float %2)
  %3 = load float, float* %pressaoAtmosferica, align 4
  %call2 = call float @Convert_hPa_To_mmHg(float %3)
  %call3 = call float @CalculateDewPoint(float %call, float %call2)
  store float %call3, float* %pontoOrvalho, align 4
  %4 = load float, float* %pontoOrvalho, align 4
  %sub = fsub float %4, 5.000000e-01
  store float %sub, float* %limInfPO, align 4
  %5 = load float, float* %pontoOrvalho, align 4
  %add = fadd float %5, 5.000000e-01
  store float %add, float* %limSupPO, align 4
  call void @srand(i32 1) #4
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.12, %entry
  %6 = load i32, i32* %i, align 4
  %7 = load i32, i32* %ni.addr, align 4
  %cmp = icmp slt i32 %6, %7
  br i1 %cmp, label %for.body, label %for.end.14

for.body:                                         ; preds = %for.cond
  store i32 0, i32* %j, align 4
  br label %for.cond.4

for.cond.4:                                       ; preds = %for.inc, %for.body
  %8 = load i32, i32* %j, align 4
  %9 = load i32, i32* %nj.addr, align 4
  %cmp5 = icmp slt i32 %8, %9
  br i1 %cmp5, label %for.body.6, label %for.end

for.body.6:                                       ; preds = %for.cond.4
  %10 = load float, float* %temperaturaAtmosferica, align 4
  %11 = load i32, i32* %i, align 4
  %12 = load i32, i32* %nj.addr, align 4
  %mul = mul nsw i32 %11, %12
  %13 = load i32, i32* %j, align 4
  %add7 = add nsw i32 %mul, %13
  %idxprom = sext i32 %add7 to i64
  %14 = load float*, float** %A.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %14, i64 %idxprom
  store float %10, float* %arrayidx, align 4
  %15 = load float, float* %temperaturaAtmosferica, align 4
  %16 = load i32, i32* %i, align 4
  %17 = load i32, i32* %nj.addr, align 4
  %mul8 = mul nsw i32 %16, %17
  %18 = load i32, i32* %j, align 4
  %add9 = add nsw i32 %mul8, %18
  %idxprom10 = sext i32 %add9 to i64
  %19 = load float*, float** %B.addr, align 8
  %arrayidx11 = getelementptr inbounds float, float* %19, i64 %idxprom10
  store float %15, float* %arrayidx11, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.6
  %20 = load i32, i32* %j, align 4
  %inc = add nsw i32 %20, 1
  store i32 %inc, i32* %j, align 4
  br label %for.cond.4

for.end:                                          ; preds = %for.cond.4
  br label %for.inc.12

for.inc.12:                                       ; preds = %for.end
  %21 = load i32, i32* %i, align 4
  %inc13 = add nsw i32 %21, 1
  store i32 %inc13, i32* %i, align 4
  br label %for.cond

for.end.14:                                       ; preds = %for.cond
  %22 = load i32, i32* %x0, align 4
  %23 = load i32, i32* %raio_nuvem, align 4
  %sub15 = sub nsw i32 %22, %23
  store i32 %sub15, i32* %i, align 4
  br label %for.cond.16

for.cond.16:                                      ; preds = %for.inc.52, %for.end.14
  %24 = load i32, i32* %i, align 4
  %25 = load i32, i32* %x0, align 4
  %26 = load i32, i32* %raio_nuvem, align 4
  %add17 = add nsw i32 %25, %26
  %cmp18 = icmp slt i32 %24, %add17
  br i1 %cmp18, label %for.body.19, label %for.end.54

for.body.19:                                      ; preds = %for.cond.16
  %27 = load i32, i32* %raio_nuvem, align 4
  %conv = sitofp i32 %27 to float
  %conv20 = fpext float %conv to double
  %call21 = call double @pow(double %conv20, double 2.000000e+00) #4
  %28 = load i32, i32* %x0, align 4
  %conv22 = sitofp i32 %28 to float
  %29 = load i32, i32* %i, align 4
  %conv23 = sitofp i32 %29 to float
  %sub24 = fsub float %conv22, %conv23
  %conv25 = fpext float %sub24 to double
  %call26 = call double @pow(double %conv25, double 2.000000e+00) #4
  %sub27 = fsub double %call21, %call26
  %call28 = call double @sqrt(double %sub27) #4
  %30 = load i32, i32* %y0, align 4
  %conv29 = sitofp i32 %30 to double
  %sub30 = fsub double %call28, %conv29
  %call31 = call double @floor(double %sub30) #5
  %mul32 = fmul double %call31, -1.000000e+00
  %conv33 = fptosi double %mul32 to i32
  store i32 %conv33, i32* %y, align 4
  %31 = load i32, i32* %y0, align 4
  %32 = load i32, i32* %y0, align 4
  %33 = load i32, i32* %y, align 4
  %sub34 = sub nsw i32 %32, %33
  %add35 = add nsw i32 %31, %sub34
  store i32 %add35, i32* %j, align 4
  br label %for.cond.36

for.cond.36:                                      ; preds = %for.inc.50, %for.body.19
  %34 = load i32, i32* %j, align 4
  %35 = load i32, i32* %y, align 4
  %cmp37 = icmp sge i32 %34, %35
  br i1 %cmp37, label %for.body.39, label %for.end.51

for.body.39:                                      ; preds = %for.cond.36
  %36 = load float, float* %limInfPO, align 4
  %call40 = call i32 @rand() #4
  %conv41 = sitofp i32 %call40 to float
  %div42 = fdiv float %conv41, 0x41E0000000000000
  %37 = load float, float* %limSupPO, align 4
  %38 = load float, float* %limInfPO, align 4
  %sub43 = fsub float %37, %38
  %mul44 = fmul float %div42, %sub43
  %add45 = fadd float %36, %mul44
  %39 = load i32, i32* %i, align 4
  %40 = load i32, i32* %nj.addr, align 4
  %mul46 = mul nsw i32 %39, %40
  %41 = load i32, i32* %j, align 4
  %add47 = add nsw i32 %mul46, %41
  %idxprom48 = sext i32 %add47 to i64
  %42 = load float*, float** %A.addr, align 8
  %arrayidx49 = getelementptr inbounds float, float* %42, i64 %idxprom48
  store float %add45, float* %arrayidx49, align 4
  br label %for.inc.50

for.inc.50:                                       ; preds = %for.body.39
  %43 = load i32, i32* %j, align 4
  %dec = add nsw i32 %43, -1
  store i32 %dec, i32* %j, align 4
  br label %for.cond.36

for.end.51:                                       ; preds = %for.cond.36
  br label %for.inc.52

for.inc.52:                                       ; preds = %for.end.51
  %44 = load i32, i32* %i, align 4
  %inc53 = add nsw i32 %44, 1
  store i32 %inc53, i32* %i, align 4
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
  %tsteps.addr = alloca i32, align 4
  %ni.addr = alloca i32, align 4
  %nj.addr = alloca i32, align 4
  %A.addr = alloca float*, align 8
  %B.addr = alloca float*, align 8
  %WIND_X.addr = alloca float*, align 8
  %WIND_Y.addr = alloca float*, align 8
  %t = alloca i32, align 4
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %c = alloca i32, align 4
  %w = alloca i32, align 4
  %e = alloca i32, align 4
  %n = alloca i32, align 4
  %s = alloca i32, align 4
  %xfactor = alloca i32, align 4
  %yfactor = alloca i32, align 4
  %numNeighbor = alloca i32, align 4
  %deltaT = alloca float, align 4
  %temperatura_conducao = alloca float, align 4
  %sum = alloca float, align 4
  %temperaturaNeighborX = alloca float, align 4
  %temperaturaNeighborY = alloca float, align 4
  %componenteVentoX = alloca float, align 4
  %componenteVentoY = alloca float, align 4
  %temp_wind = alloca float, align 4
  %result = alloca float, align 4
  %xwind = alloca float, align 4
  %ywind = alloca float, align 4
  store i32 %tsteps, i32* %tsteps.addr, align 4
  store i32 %ni, i32* %ni.addr, align 4
  store i32 %nj, i32* %nj.addr, align 4
  store float* %A, float** %A.addr, align 8
  store float* %B, float** %B.addr, align 8
  store float* %WIND_X, float** %WIND_X.addr, align 8
  store float* %WIND_Y, float** %WIND_Y.addr, align 8
  store i32 4, i32* %numNeighbor, align 4
  store float 0x3F50624DE0000000, float* %deltaT, align 4
  store float 0.000000e+00, float* %temperatura_conducao, align 4
  store float 0.000000e+00, float* %sum, align 4
  store i32 0, i32* %t, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.159, %entry
  %0 = load i32, i32* %t, align 4
  %1 = load i32, i32* %tsteps.addr, align 4
  %cmp = icmp slt i32 %0, %1
  br i1 %cmp, label %for.body, label %for.end.161

for.body:                                         ; preds = %for.cond
  store i32 0, i32* %i, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc.134, %for.body
  %2 = load i32, i32* %i, align 4
  %3 = load i32, i32* %ni.addr, align 4
  %cmp2 = icmp slt i32 %2, %3
  br i1 %cmp2, label %for.body.3, label %for.end.136

for.body.3:                                       ; preds = %for.cond.1
  store i32 0, i32* %j, align 4
  br label %for.cond.4

for.cond.4:                                       ; preds = %for.inc, %for.body.3
  %4 = load i32, i32* %j, align 4
  %5 = load i32, i32* %nj.addr, align 4
  %cmp5 = icmp slt i32 %4, %5
  br i1 %cmp5, label %for.body.6, label %for.end

for.body.6:                                       ; preds = %for.cond.4
  %6 = load i32, i32* %j, align 4
  %cmp7 = icmp eq i32 %6, 0
  br i1 %cmp7, label %cond.true, label %cond.false

cond.true:                                        ; preds = %for.body.6
  %7 = load i32, i32* %numNeighbor, align 4
  %sub = sub nsw i32 %7, 1
  br label %cond.end

cond.false:                                       ; preds = %for.body.6
  %8 = load i32, i32* %numNeighbor, align 4
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi i32 [ %sub, %cond.true ], [ %8, %cond.false ]
  store i32 %cond, i32* %numNeighbor, align 4
  %9 = load i32, i32* %i, align 4
  %cmp8 = icmp eq i32 %9, 0
  br i1 %cmp8, label %cond.true.9, label %cond.false.11

cond.true.9:                                      ; preds = %cond.end
  %10 = load i32, i32* %numNeighbor, align 4
  %sub10 = sub nsw i32 %10, 1
  br label %cond.end.12

cond.false.11:                                    ; preds = %cond.end
  %11 = load i32, i32* %numNeighbor, align 4
  br label %cond.end.12

cond.end.12:                                      ; preds = %cond.false.11, %cond.true.9
  %cond13 = phi i32 [ %sub10, %cond.true.9 ], [ %11, %cond.false.11 ]
  store i32 %cond13, i32* %numNeighbor, align 4
  %12 = load i32, i32* %j, align 4
  %13 = load i32, i32* %nj.addr, align 4
  %sub14 = sub nsw i32 %13, 1
  %cmp15 = icmp eq i32 %12, %sub14
  br i1 %cmp15, label %cond.true.16, label %cond.false.18

cond.true.16:                                     ; preds = %cond.end.12
  %14 = load i32, i32* %numNeighbor, align 4
  %sub17 = sub nsw i32 %14, 1
  br label %cond.end.19

cond.false.18:                                    ; preds = %cond.end.12
  %15 = load i32, i32* %numNeighbor, align 4
  br label %cond.end.19

cond.end.19:                                      ; preds = %cond.false.18, %cond.true.16
  %cond20 = phi i32 [ %sub17, %cond.true.16 ], [ %15, %cond.false.18 ]
  store i32 %cond20, i32* %numNeighbor, align 4
  %16 = load i32, i32* %i, align 4
  %17 = load i32, i32* %ni.addr, align 4
  %sub21 = sub nsw i32 %17, 1
  %cmp22 = icmp eq i32 %16, %sub21
  br i1 %cmp22, label %cond.true.23, label %cond.false.25

cond.true.23:                                     ; preds = %cond.end.19
  %18 = load i32, i32* %numNeighbor, align 4
  %sub24 = sub nsw i32 %18, 1
  br label %cond.end.26

cond.false.25:                                    ; preds = %cond.end.19
  %19 = load i32, i32* %numNeighbor, align 4
  br label %cond.end.26

cond.end.26:                                      ; preds = %cond.false.25, %cond.true.23
  %cond27 = phi i32 [ %sub24, %cond.true.23 ], [ %19, %cond.false.25 ]
  store i32 %cond27, i32* %numNeighbor, align 4
  %20 = load i32, i32* %i, align 4
  %21 = load i32, i32* %nj.addr, align 4
  %mul = mul nsw i32 %20, %21
  %22 = load i32, i32* %j, align 4
  %add = add nsw i32 %mul, %22
  store i32 %add, i32* %c, align 4
  %23 = load i32, i32* %j, align 4
  %cmp28 = icmp eq i32 %23, 0
  br i1 %cmp28, label %cond.true.29, label %cond.false.30

cond.true.29:                                     ; preds = %cond.end.26
  %24 = load i32, i32* %c, align 4
  br label %cond.end.32

cond.false.30:                                    ; preds = %cond.end.26
  %25 = load i32, i32* %c, align 4
  %sub31 = sub nsw i32 %25, 1
  br label %cond.end.32

cond.end.32:                                      ; preds = %cond.false.30, %cond.true.29
  %cond33 = phi i32 [ %24, %cond.true.29 ], [ %sub31, %cond.false.30 ]
  store i32 %cond33, i32* %w, align 4
  %26 = load i32, i32* %j, align 4
  %27 = load i32, i32* %nj.addr, align 4
  %sub34 = sub nsw i32 %27, 1
  %cmp35 = icmp eq i32 %26, %sub34
  br i1 %cmp35, label %cond.true.36, label %cond.false.37

cond.true.36:                                     ; preds = %cond.end.32
  %28 = load i32, i32* %c, align 4
  br label %cond.end.39

cond.false.37:                                    ; preds = %cond.end.32
  %29 = load i32, i32* %c, align 4
  %add38 = add nsw i32 %29, 1
  br label %cond.end.39

cond.end.39:                                      ; preds = %cond.false.37, %cond.true.36
  %cond40 = phi i32 [ %28, %cond.true.36 ], [ %add38, %cond.false.37 ]
  store i32 %cond40, i32* %e, align 4
  %30 = load i32, i32* %i, align 4
  %cmp41 = icmp eq i32 %30, 0
  br i1 %cmp41, label %cond.true.42, label %cond.false.43

cond.true.42:                                     ; preds = %cond.end.39
  %31 = load i32, i32* %c, align 4
  br label %cond.end.45

cond.false.43:                                    ; preds = %cond.end.39
  %32 = load i32, i32* %c, align 4
  %33 = load i32, i32* %ni.addr, align 4
  %sub44 = sub nsw i32 %32, %33
  br label %cond.end.45

cond.end.45:                                      ; preds = %cond.false.43, %cond.true.42
  %cond46 = phi i32 [ %31, %cond.true.42 ], [ %sub44, %cond.false.43 ]
  store i32 %cond46, i32* %n, align 4
  %34 = load i32, i32* %i, align 4
  %35 = load i32, i32* %ni.addr, align 4
  %sub47 = sub nsw i32 %35, 1
  %cmp48 = icmp eq i32 %34, %sub47
  br i1 %cmp48, label %cond.true.49, label %cond.false.50

cond.true.49:                                     ; preds = %cond.end.45
  %36 = load i32, i32* %c, align 4
  br label %cond.end.52

cond.false.50:                                    ; preds = %cond.end.45
  %37 = load i32, i32* %c, align 4
  %38 = load i32, i32* %ni.addr, align 4
  %add51 = add nsw i32 %37, %38
  br label %cond.end.52

cond.end.52:                                      ; preds = %cond.false.50, %cond.true.49
  %cond53 = phi i32 [ %36, %cond.true.49 ], [ %add51, %cond.false.50 ]
  store i32 %cond53, i32* %s, align 4
  %39 = load i32, i32* %c, align 4
  %idxprom = sext i32 %39 to i64
  %40 = load float*, float** %A.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %40, i64 %idxprom
  %41 = load float, float* %arrayidx, align 4
  %mul54 = fmul float 4.000000e+00, %41
  %42 = load i32, i32* %n, align 4
  %idxprom55 = sext i32 %42 to i64
  %43 = load float*, float** %A.addr, align 8
  %arrayidx56 = getelementptr inbounds float, float* %43, i64 %idxprom55
  %44 = load float, float* %arrayidx56, align 4
  %45 = load i32, i32* %w, align 4
  %idxprom57 = sext i32 %45 to i64
  %46 = load float*, float** %A.addr, align 8
  %arrayidx58 = getelementptr inbounds float, float* %46, i64 %idxprom57
  %47 = load float, float* %arrayidx58, align 4
  %add59 = fadd float %44, %47
  %48 = load i32, i32* %e, align 4
  %idxprom60 = sext i32 %48 to i64
  %49 = load float*, float** %A.addr, align 8
  %arrayidx61 = getelementptr inbounds float, float* %49, i64 %idxprom60
  %50 = load float, float* %arrayidx61, align 4
  %add62 = fadd float %add59, %50
  %51 = load i32, i32* %s, align 4
  %idxprom63 = sext i32 %51 to i64
  %52 = load float*, float** %A.addr, align 8
  %arrayidx64 = getelementptr inbounds float, float* %52, i64 %idxprom63
  %53 = load float, float* %arrayidx64, align 4
  %add65 = fadd float %add62, %53
  %sub66 = fsub float %mul54, %add65
  store float %sub66, float* %sum, align 4
  %54 = load float, float* %sum, align 4
  %55 = load i32, i32* %numNeighbor, align 4
  %conv = sitofp i32 %55 to float
  %div = fdiv float %54, %conv
  %mul67 = fmul float 0xBF98E21960000000, %div
  %56 = load float, float* %deltaT, align 4
  %mul68 = fmul float %mul67, %56
  store float %mul68, float* %temperatura_conducao, align 4
  %57 = load i32, i32* %c, align 4
  %idxprom69 = sext i32 %57 to i64
  %58 = load float*, float** %A.addr, align 8
  %arrayidx70 = getelementptr inbounds float, float* %58, i64 %idxprom69
  %59 = load float, float* %arrayidx70, align 4
  %60 = load float, float* %temperatura_conducao, align 4
  %add71 = fadd float %59, %60
  store float %add71, float* %result, align 4
  %61 = load i32, i32* %i, align 4
  %62 = load i32, i32* %nj.addr, align 4
  %mul72 = mul nsw i32 %61, %62
  %63 = load i32, i32* %j, align 4
  %add73 = add nsw i32 %mul72, %63
  %idxprom74 = sext i32 %add73 to i64
  %64 = load float*, float** %WIND_X.addr, align 8
  %arrayidx75 = getelementptr inbounds float, float* %64, i64 %idxprom74
  %65 = load float, float* %arrayidx75, align 4
  store float %65, float* %xwind, align 4
  %66 = load i32, i32* %i, align 4
  %67 = load i32, i32* %nj.addr, align 4
  %mul76 = mul nsw i32 %66, %67
  %68 = load i32, i32* %j, align 4
  %add77 = add nsw i32 %mul76, %68
  %idxprom78 = sext i32 %add77 to i64
  %69 = load float*, float** %WIND_Y.addr, align 8
  %arrayidx79 = getelementptr inbounds float, float* %69, i64 %idxprom78
  %70 = load float, float* %arrayidx79, align 4
  store float %70, float* %ywind, align 4
  %71 = load float, float* %xwind, align 4
  %cmp80 = fcmp ogt float %71, 0.000000e+00
  br i1 %cmp80, label %cond.true.82, label %cond.false.85

cond.true.82:                                     ; preds = %cond.end.52
  %72 = load i32, i32* %e, align 4
  %idxprom83 = sext i32 %72 to i64
  %73 = load float*, float** %A.addr, align 8
  %arrayidx84 = getelementptr inbounds float, float* %73, i64 %idxprom83
  %74 = load float, float* %arrayidx84, align 4
  br label %cond.end.88

cond.false.85:                                    ; preds = %cond.end.52
  %75 = load i32, i32* %w, align 4
  %idxprom86 = sext i32 %75 to i64
  %76 = load float*, float** %A.addr, align 8
  %arrayidx87 = getelementptr inbounds float, float* %76, i64 %idxprom86
  %77 = load float, float* %arrayidx87, align 4
  br label %cond.end.88

cond.end.88:                                      ; preds = %cond.false.85, %cond.true.82
  %cond89 = phi float [ %74, %cond.true.82 ], [ %77, %cond.false.85 ]
  store float %cond89, float* %temperaturaNeighborX, align 4
  %78 = load float, float* %ywind, align 4
  %cmp90 = fcmp ogt float %78, 0.000000e+00
  br i1 %cmp90, label %cond.true.92, label %cond.false.95

cond.true.92:                                     ; preds = %cond.end.88
  %79 = load i32, i32* %s, align 4
  %idxprom93 = sext i32 %79 to i64
  %80 = load float*, float** %A.addr, align 8
  %arrayidx94 = getelementptr inbounds float, float* %80, i64 %idxprom93
  %81 = load float, float* %arrayidx94, align 4
  br label %cond.end.98

cond.false.95:                                    ; preds = %cond.end.88
  %82 = load i32, i32* %n, align 4
  %idxprom96 = sext i32 %82 to i64
  %83 = load float*, float** %A.addr, align 8
  %arrayidx97 = getelementptr inbounds float, float* %83, i64 %idxprom96
  %84 = load float, float* %arrayidx97, align 4
  br label %cond.end.98

cond.end.98:                                      ; preds = %cond.false.95, %cond.true.92
  %cond99 = phi float [ %81, %cond.true.92 ], [ %84, %cond.false.95 ]
  store float %cond99, float* %temperaturaNeighborY, align 4
  %85 = load float, float* %xwind, align 4
  %cmp100 = fcmp ogt float %85, 0.000000e+00
  %cond102 = select i1 %cmp100, i32 1, i32 -1
  store i32 %cond102, i32* %xfactor, align 4
  %86 = load float, float* %ywind, align 4
  %cmp103 = fcmp ogt float %86, 0.000000e+00
  %cond105 = select i1 %cmp103, i32 1, i32 -1
  store i32 %cond105, i32* %yfactor, align 4
  %87 = load i32, i32* %xfactor, align 4
  %conv106 = sitofp i32 %87 to float
  %88 = load float, float* %xwind, align 4
  %mul107 = fmul float %conv106, %88
  store float %mul107, float* %componenteVentoX, align 4
  %89 = load i32, i32* %yfactor, align 4
  %conv108 = sitofp i32 %89 to float
  %90 = load float, float* %ywind, align 4
  %mul109 = fmul float %conv108, %90
  store float %mul109, float* %componenteVentoY, align 4
  %91 = load float, float* %componenteVentoX, align 4
  %sub110 = fsub float -0.000000e+00, %91
  %92 = load i32, i32* %c, align 4
  %idxprom111 = sext i32 %92 to i64
  %93 = load float*, float** %A.addr, align 8
  %arrayidx112 = getelementptr inbounds float, float* %93, i64 %idxprom111
  %94 = load float, float* %arrayidx112, align 4
  %95 = load float, float* %temperaturaNeighborX, align 4
  %sub113 = fsub float %94, %95
  %div114 = fdiv float %sub113, 0x3FB99999A0000000
  %mul115 = fmul float %sub110, %div114
  %96 = load float, float* %componenteVentoY, align 4
  %97 = load i32, i32* %c, align 4
  %idxprom116 = sext i32 %97 to i64
  %98 = load float*, float** %A.addr, align 8
  %arrayidx117 = getelementptr inbounds float, float* %98, i64 %idxprom116
  %99 = load float, float* %arrayidx117, align 4
  %100 = load float, float* %temperaturaNeighborY, align 4
  %sub118 = fsub float %99, %100
  %div119 = fdiv float %sub118, 0x3FB99999A0000000
  %mul120 = fmul float %96, %div119
  %sub121 = fsub float %mul115, %mul120
  store float %sub121, float* %temp_wind, align 4
  %101 = load float, float* %result, align 4
  %102 = load i32, i32* %numNeighbor, align 4
  %cmp122 = icmp eq i32 %102, 4
  br i1 %cmp122, label %cond.true.124, label %cond.false.126

cond.true.124:                                    ; preds = %cond.end.98
  %103 = load float, float* %temp_wind, align 4
  %104 = load float, float* %deltaT, align 4
  %mul125 = fmul float %103, %104
  br label %cond.end.127

cond.false.126:                                   ; preds = %cond.end.98
  br label %cond.end.127

cond.end.127:                                     ; preds = %cond.false.126, %cond.true.124
  %cond128 = phi float [ %mul125, %cond.true.124 ], [ 0.000000e+00, %cond.false.126 ]
  %add129 = fadd float %101, %cond128
  %105 = load i32, i32* %i, align 4
  %106 = load i32, i32* %nj.addr, align 4
  %mul130 = mul nsw i32 %105, %106
  %107 = load i32, i32* %j, align 4
  %add131 = add nsw i32 %mul130, %107
  %idxprom132 = sext i32 %add131 to i64
  %108 = load float*, float** %B.addr, align 8
  %arrayidx133 = getelementptr inbounds float, float* %108, i64 %idxprom132
  store float %add129, float* %arrayidx133, align 4
  br label %for.inc

for.inc:                                          ; preds = %cond.end.127
  %109 = load i32, i32* %j, align 4
  %inc = add nsw i32 %109, 1
  store i32 %inc, i32* %j, align 4
  br label %for.cond.4

for.end:                                          ; preds = %for.cond.4
  br label %for.inc.134

for.inc.134:                                      ; preds = %for.end
  %110 = load i32, i32* %i, align 4
  %inc135 = add nsw i32 %110, 1
  store i32 %inc135, i32* %i, align 4
  br label %for.cond.1

for.end.136:                                      ; preds = %for.cond.1
  store i32 0, i32* %i, align 4
  br label %for.cond.137

for.cond.137:                                     ; preds = %for.inc.156, %for.end.136
  %111 = load i32, i32* %i, align 4
  %112 = load i32, i32* %n, align 4
  %cmp138 = icmp slt i32 %111, %112
  br i1 %cmp138, label %for.body.140, label %for.end.158

for.body.140:                                     ; preds = %for.cond.137
  store i32 0, i32* %j, align 4
  br label %for.cond.141

for.cond.141:                                     ; preds = %for.inc.153, %for.body.140
  %113 = load i32, i32* %j, align 4
  %114 = load i32, i32* %n, align 4
  %cmp142 = icmp slt i32 %113, %114
  br i1 %cmp142, label %for.body.144, label %for.end.155

for.body.144:                                     ; preds = %for.cond.141
  %115 = load i32, i32* %i, align 4
  %116 = load i32, i32* %n, align 4
  %mul145 = mul nsw i32 %115, %116
  %117 = load i32, i32* %j, align 4
  %add146 = add nsw i32 %mul145, %117
  %idxprom147 = sext i32 %add146 to i64
  %118 = load float*, float** %B.addr, align 8
  %arrayidx148 = getelementptr inbounds float, float* %118, i64 %idxprom147
  %119 = load float, float* %arrayidx148, align 4
  %120 = load i32, i32* %i, align 4
  %121 = load i32, i32* %n, align 4
  %mul149 = mul nsw i32 %120, %121
  %122 = load i32, i32* %j, align 4
  %add150 = add nsw i32 %mul149, %122
  %idxprom151 = sext i32 %add150 to i64
  %123 = load float*, float** %A.addr, align 8
  %arrayidx152 = getelementptr inbounds float, float* %123, i64 %idxprom151
  store float %119, float* %arrayidx152, align 4
  br label %for.inc.153

for.inc.153:                                      ; preds = %for.body.144
  %124 = load i32, i32* %j, align 4
  %inc154 = add nsw i32 %124, 1
  store i32 %inc154, i32* %j, align 4
  br label %for.cond.141

for.end.155:                                      ; preds = %for.cond.141
  br label %for.inc.156

for.inc.156:                                      ; preds = %for.end.155
  %125 = load i32, i32* %i, align 4
  %inc157 = add nsw i32 %125, 1
  store i32 %inc157, i32* %i, align 4
  br label %for.cond.137

for.end.158:                                      ; preds = %for.cond.137
  br label %for.inc.159

for.inc.159:                                      ; preds = %for.end.158
  %126 = load i32, i32* %t, align 4
  %inc160 = add nsw i32 %126, 1
  store i32 %inc160, i32* %t, align 4
  br label %for.cond

for.end.161:                                      ; preds = %for.cond
  ret void
}

; Function Attrs: nounwind uwtable
define i32 @main(i32 %argc, i8** %argv) #0 {
entry:
  %retval = alloca i32, align 4
  %argc.addr = alloca i32, align 4
  %argv.addr = alloca i8**, align 8
  %ni = alloca i32, align 4
  %nj = alloca i32, align 4
  %tsteps = alloca i32, align 4
  %t_start = alloca double, align 8
  %t_end = alloca double, align 8
  %A = alloca float*, align 8
  %B = alloca float*, align 8
  %WIND_X = alloca float*, align 8
  %WIND_Y = alloca float*, align 8
  store i32 0, i32* %retval
  store i32 %argc, i32* %argc.addr, align 4
  store i8** %argv, i8*** %argv.addr, align 8
  store i32 1024, i32* %ni, align 4
  store i32 1024, i32* %nj, align 4
  store i32 10, i32* %tsteps, align 4
  %0 = load i32, i32* %ni, align 4
  %1 = load i32, i32* %nj, align 4
  %mul = mul nsw i32 %0, %1
  %conv = sext i32 %mul to i64
  %mul1 = mul i64 %conv, 4
  %call = call noalias i8* @malloc(i64 %mul1) #4
  %2 = bitcast i8* %call to float*
  store float* %2, float** %A, align 8
  %3 = load i32, i32* %ni, align 4
  %4 = load i32, i32* %nj, align 4
  %mul2 = mul nsw i32 %3, %4
  %conv3 = sext i32 %mul2 to i64
  %mul4 = mul i64 %conv3, 4
  %call5 = call noalias i8* @malloc(i64 %mul4) #4
  %5 = bitcast i8* %call5 to float*
  store float* %5, float** %B, align 8
  %6 = load i32, i32* %ni, align 4
  %7 = load i32, i32* %nj, align 4
  %mul6 = mul nsw i32 %6, %7
  %conv7 = sext i32 %mul6 to i64
  %mul8 = mul i64 %conv7, 4
  %call9 = call noalias i8* @malloc(i64 %mul8) #4
  %8 = bitcast i8* %call9 to float*
  store float* %8, float** %WIND_X, align 8
  %9 = load i32, i32* %ni, align 4
  %10 = load i32, i32* %nj, align 4
  %mul10 = mul nsw i32 %9, %10
  %conv11 = sext i32 %mul10 to i64
  %mul12 = mul i64 %conv11, 4
  %call13 = call noalias i8* @malloc(i64 %mul12) #4
  %11 = bitcast i8* %call13 to float*
  store float* %11, float** %WIND_Y, align 8
  %12 = load i32, i32* %ni, align 4
  %13 = load i32, i32* %nj, align 4
  %14 = load float*, float** %A, align 8
  %15 = load float*, float** %B, align 8
  call void @init_array(i32 %12, i32 %13, float* %14, float* %15)
  %16 = load i32, i32* %ni, align 4
  %17 = load i32, i32* %nj, align 4
  %18 = load float*, float** %WIND_X, align 8
  %19 = load float*, float** %WIND_Y, align 8
  call void @init_wind(i32 %16, i32 %17, float* %18, float* %19)
  %call14 = call double @rtclock()
  store double %call14, double* %t_start, align 8
  %20 = load i32, i32* %tsteps, align 4
  %21 = load i32, i32* %ni, align 4
  %22 = load i32, i32* %nj, align 4
  %23 = load float*, float** %A, align 8
  %24 = load float*, float** %B, align 8
  %25 = load float*, float** %WIND_X, align 8
  %26 = load float*, float** %WIND_Y, align 8
  call void @cloudsim(i32 %20, i32 %21, i32 %22, float* %23, float* %24, float* %25, float* %26)
  %call15 = call double @rtclock()
  store double %call15, double* %t_end, align 8
  %27 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %28 = load double, double* %t_end, align 8
  %29 = load double, double* %t_start, align 8
  %sub = fsub double %28, %29
  %call16 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %27, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.1, i32 0, i32 0), double %sub)
  %30 = load float*, float** %A, align 8
  %31 = bitcast float* %30 to i8*
  call void @free(i8* %31) #4
  %32 = load float*, float** %B, align 8
  %33 = bitcast float* %32 to i8*
  call void @free(i8* %33) #4
  %34 = load float*, float** %WIND_X, align 8
  %35 = bitcast float* %34 to i8*
  call void @free(i8* %35) #4
  %36 = load float*, float** %WIND_Y, align 8
  %37 = bitcast float* %36 to i8*
  call void @free(i8* %37) #4
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
