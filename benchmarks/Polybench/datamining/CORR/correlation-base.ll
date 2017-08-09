; ModuleID = 'correlation.c'
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
@.str.3 = private unnamed_addr constant [22 x i8] c"GPU Runtime: %0.6lfs\0A\00", align 1
@.str.4 = private unnamed_addr constant [22 x i8] c"CPU Runtime: %0.6lfs\0A\00", align 1

; Function Attrs: nounwind uwtable
define double @rtclock() #0 {
entry:
  %Tzp = alloca %struct.timezone, align 4
  %Tp = alloca %struct.timeval, align 8
  %stat = alloca i32, align 4
  %call = call i32 @gettimeofday(%struct.timeval* %Tp, %struct.timezone* %Tzp) #3
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
define void @init_arrays(float* %data) #0 {
entry:
  %data.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  store float* %data, float** %data.addr, align 8
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.6, %entry
  %0 = load i32, i32* %i, align 4
  %cmp = icmp slt i32 %0, 2049
  br i1 %cmp, label %for.body, label %for.end.8

for.body:                                         ; preds = %for.cond
  store i32 0, i32* %j, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %1 = load i32, i32* %j, align 4
  %cmp2 = icmp slt i32 %1, 2049
  br i1 %cmp2, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.cond.1
  %2 = load i32, i32* %i, align 4
  %conv = sitofp i32 %2 to float
  %3 = load i32, i32* %j, align 4
  %conv4 = sitofp i32 %3 to float
  %mul = fmul float %conv, %conv4
  %div = fdiv float %mul, 2.049000e+03
  %4 = load i32, i32* %i, align 4
  %mul5 = mul nsw i32 %4, 2049
  %5 = load i32, i32* %j, align 4
  %add = add nsw i32 %mul5, %5
  %idxprom = sext i32 %add to i64
  %6 = load float*, float** %data.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %6, i64 %idxprom
  store float %div, float* %arrayidx, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.3
  %7 = load i32, i32* %j, align 4
  %inc = add nsw i32 %7, 1
  store i32 %inc, i32* %j, align 4
  br label %for.cond.1

for.end:                                          ; preds = %for.cond.1
  br label %for.inc.6

for.inc.6:                                        ; preds = %for.end
  %8 = load i32, i32* %i, align 4
  %inc7 = add nsw i32 %8, 1
  store i32 %inc7, i32* %i, align 4
  br label %for.cond

for.end.8:                                        ; preds = %for.cond
  ret void
}

; Function Attrs: nounwind uwtable
define void @correlation(float* %data, float* %mean, float* %stddev, float* %symmat) #0 {
entry:
  %data.addr = alloca float*, align 8
  %mean.addr = alloca float*, align 8
  %stddev.addr = alloca float*, align 8
  %symmat.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %j1 = alloca i32, align 4
  %j2 = alloca i32, align 4
  store float* %data, float** %data.addr, align 8
  store float* %mean, float** %mean.addr, align 8
  store float* %stddev, float** %stddev.addr, align 8
  store float* %symmat, float** %symmat.addr, align 8
  store i32 1, i32* %j, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.11, %entry
  %0 = load i32, i32* %j, align 4
  %cmp = icmp slt i32 %0, 2049
  br i1 %cmp, label %for.body, label %for.end.13

for.body:                                         ; preds = %for.cond
  %1 = load i32, i32* %j, align 4
  %idxprom = sext i32 %1 to i64
  %2 = load float*, float** %mean.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %2, i64 %idxprom
  store float 0.000000e+00, float* %arrayidx, align 4
  store i32 1, i32* %i, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %3 = load i32, i32* %i, align 4
  %cmp2 = icmp slt i32 %3, 2049
  br i1 %cmp2, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.cond.1
  %4 = load i32, i32* %i, align 4
  %mul = mul nsw i32 %4, 2049
  %5 = load i32, i32* %j, align 4
  %add = add nsw i32 %mul, %5
  %idxprom4 = sext i32 %add to i64
  %6 = load float*, float** %data.addr, align 8
  %arrayidx5 = getelementptr inbounds float, float* %6, i64 %idxprom4
  %7 = load float, float* %arrayidx5, align 4
  %8 = load i32, i32* %j, align 4
  %idxprom6 = sext i32 %8 to i64
  %9 = load float*, float** %mean.addr, align 8
  %arrayidx7 = getelementptr inbounds float, float* %9, i64 %idxprom6
  %10 = load float, float* %arrayidx7, align 4
  %add8 = fadd float %10, %7
  store float %add8, float* %arrayidx7, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.3
  %11 = load i32, i32* %i, align 4
  %inc = add nsw i32 %11, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond.1

for.end:                                          ; preds = %for.cond.1
  %12 = load i32, i32* %j, align 4
  %idxprom9 = sext i32 %12 to i64
  %13 = load float*, float** %mean.addr, align 8
  %arrayidx10 = getelementptr inbounds float, float* %13, i64 %idxprom9
  %14 = load float, float* %arrayidx10, align 4
  %div = fdiv float %14, 3.214212e+06
  store float %div, float* %arrayidx10, align 4
  br label %for.inc.11

for.inc.11:                                       ; preds = %for.end
  %15 = load i32, i32* %j, align 4
  %inc12 = add nsw i32 %15, 1
  store i32 %inc12, i32* %j, align 4
  br label %for.cond

for.end.13:                                       ; preds = %for.cond
  store i32 1, i32* %j, align 4
  br label %for.cond.14

for.cond.14:                                      ; preds = %for.inc.60, %for.end.13
  %16 = load i32, i32* %j, align 4
  %cmp15 = icmp slt i32 %16, 2049
  br i1 %cmp15, label %for.body.16, label %for.end.62

for.body.16:                                      ; preds = %for.cond.14
  %17 = load i32, i32* %j, align 4
  %idxprom17 = sext i32 %17 to i64
  %18 = load float*, float** %stddev.addr, align 8
  %arrayidx18 = getelementptr inbounds float, float* %18, i64 %idxprom17
  store float 0.000000e+00, float* %arrayidx18, align 4
  store i32 1, i32* %i, align 4
  br label %for.cond.19

for.cond.19:                                      ; preds = %for.inc.39, %for.body.16
  %19 = load i32, i32* %i, align 4
  %cmp20 = icmp slt i32 %19, 2049
  br i1 %cmp20, label %for.body.21, label %for.end.41

for.body.21:                                      ; preds = %for.cond.19
  %20 = load i32, i32* %i, align 4
  %mul22 = mul nsw i32 %20, 2049
  %21 = load i32, i32* %j, align 4
  %add23 = add nsw i32 %mul22, %21
  %idxprom24 = sext i32 %add23 to i64
  %22 = load float*, float** %data.addr, align 8
  %arrayidx25 = getelementptr inbounds float, float* %22, i64 %idxprom24
  %23 = load float, float* %arrayidx25, align 4
  %24 = load i32, i32* %j, align 4
  %idxprom26 = sext i32 %24 to i64
  %25 = load float*, float** %mean.addr, align 8
  %arrayidx27 = getelementptr inbounds float, float* %25, i64 %idxprom26
  %26 = load float, float* %arrayidx27, align 4
  %sub = fsub float %23, %26
  %27 = load i32, i32* %i, align 4
  %mul28 = mul nsw i32 %27, 2049
  %28 = load i32, i32* %j, align 4
  %add29 = add nsw i32 %mul28, %28
  %idxprom30 = sext i32 %add29 to i64
  %29 = load float*, float** %data.addr, align 8
  %arrayidx31 = getelementptr inbounds float, float* %29, i64 %idxprom30
  %30 = load float, float* %arrayidx31, align 4
  %31 = load i32, i32* %j, align 4
  %idxprom32 = sext i32 %31 to i64
  %32 = load float*, float** %mean.addr, align 8
  %arrayidx33 = getelementptr inbounds float, float* %32, i64 %idxprom32
  %33 = load float, float* %arrayidx33, align 4
  %sub34 = fsub float %30, %33
  %mul35 = fmul float %sub, %sub34
  %34 = load i32, i32* %j, align 4
  %idxprom36 = sext i32 %34 to i64
  %35 = load float*, float** %stddev.addr, align 8
  %arrayidx37 = getelementptr inbounds float, float* %35, i64 %idxprom36
  %36 = load float, float* %arrayidx37, align 4
  %add38 = fadd float %36, %mul35
  store float %add38, float* %arrayidx37, align 4
  br label %for.inc.39

for.inc.39:                                       ; preds = %for.body.21
  %37 = load i32, i32* %i, align 4
  %inc40 = add nsw i32 %37, 1
  store i32 %inc40, i32* %i, align 4
  br label %for.cond.19

for.end.41:                                       ; preds = %for.cond.19
  %38 = load i32, i32* %j, align 4
  %idxprom42 = sext i32 %38 to i64
  %39 = load float*, float** %stddev.addr, align 8
  %arrayidx43 = getelementptr inbounds float, float* %39, i64 %idxprom42
  %40 = load float, float* %arrayidx43, align 4
  %div44 = fdiv float %40, 3.214212e+06
  store float %div44, float* %arrayidx43, align 4
  %41 = load i32, i32* %j, align 4
  %idxprom45 = sext i32 %41 to i64
  %42 = load float*, float** %stddev.addr, align 8
  %arrayidx46 = getelementptr inbounds float, float* %42, i64 %idxprom45
  %43 = load float, float* %arrayidx46, align 4
  %conv = fpext float %43 to double
  %call = call double @sqrt(double %conv) #3
  %conv47 = fptrunc double %call to float
  %44 = load i32, i32* %j, align 4
  %idxprom48 = sext i32 %44 to i64
  %45 = load float*, float** %stddev.addr, align 8
  %arrayidx49 = getelementptr inbounds float, float* %45, i64 %idxprom48
  store float %conv47, float* %arrayidx49, align 4
  %46 = load i32, i32* %j, align 4
  %idxprom50 = sext i32 %46 to i64
  %47 = load float*, float** %stddev.addr, align 8
  %arrayidx51 = getelementptr inbounds float, float* %47, i64 %idxprom50
  %48 = load float, float* %arrayidx51, align 4
  %cmp52 = fcmp ole float %48, 0x3F747AE140000000
  br i1 %cmp52, label %cond.true, label %cond.false

cond.true:                                        ; preds = %for.end.41
  br label %cond.end

cond.false:                                       ; preds = %for.end.41
  %49 = load i32, i32* %j, align 4
  %idxprom54 = sext i32 %49 to i64
  %50 = load float*, float** %stddev.addr, align 8
  %arrayidx55 = getelementptr inbounds float, float* %50, i64 %idxprom54
  %51 = load float, float* %arrayidx55, align 4
  %conv56 = fpext float %51 to double
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi double [ 1.000000e+00, %cond.true ], [ %conv56, %cond.false ]
  %conv57 = fptrunc double %cond to float
  %52 = load i32, i32* %j, align 4
  %idxprom58 = sext i32 %52 to i64
  %53 = load float*, float** %stddev.addr, align 8
  %arrayidx59 = getelementptr inbounds float, float* %53, i64 %idxprom58
  store float %conv57, float* %arrayidx59, align 4
  br label %for.inc.60

for.inc.60:                                       ; preds = %cond.end
  %54 = load i32, i32* %j, align 4
  %inc61 = add nsw i32 %54, 1
  store i32 %inc61, i32* %j, align 4
  br label %for.cond.14

for.end.62:                                       ; preds = %for.cond.14
  store i32 1, i32* %i, align 4
  br label %for.cond.63

for.cond.63:                                      ; preds = %for.inc.93, %for.end.62
  %55 = load i32, i32* %i, align 4
  %cmp64 = icmp slt i32 %55, 2049
  br i1 %cmp64, label %for.body.66, label %for.end.95

for.body.66:                                      ; preds = %for.cond.63
  store i32 1, i32* %j, align 4
  br label %for.cond.67

for.cond.67:                                      ; preds = %for.inc.90, %for.body.66
  %56 = load i32, i32* %j, align 4
  %cmp68 = icmp slt i32 %56, 2049
  br i1 %cmp68, label %for.body.70, label %for.end.92

for.body.70:                                      ; preds = %for.cond.67
  %57 = load i32, i32* %j, align 4
  %idxprom71 = sext i32 %57 to i64
  %58 = load float*, float** %mean.addr, align 8
  %arrayidx72 = getelementptr inbounds float, float* %58, i64 %idxprom71
  %59 = load float, float* %arrayidx72, align 4
  %60 = load i32, i32* %i, align 4
  %mul73 = mul nsw i32 %60, 2049
  %61 = load i32, i32* %j, align 4
  %add74 = add nsw i32 %mul73, %61
  %idxprom75 = sext i32 %add74 to i64
  %62 = load float*, float** %data.addr, align 8
  %arrayidx76 = getelementptr inbounds float, float* %62, i64 %idxprom75
  %63 = load float, float* %arrayidx76, align 4
  %sub77 = fsub float %63, %59
  store float %sub77, float* %arrayidx76, align 4
  %call78 = call double @sqrt(double 3.214212e+06) #3
  %64 = load i32, i32* %j, align 4
  %idxprom79 = sext i32 %64 to i64
  %65 = load float*, float** %stddev.addr, align 8
  %arrayidx80 = getelementptr inbounds float, float* %65, i64 %idxprom79
  %66 = load float, float* %arrayidx80, align 4
  %conv81 = fpext float %66 to double
  %mul82 = fmul double %call78, %conv81
  %67 = load i32, i32* %i, align 4
  %mul83 = mul nsw i32 %67, 2049
  %68 = load i32, i32* %j, align 4
  %add84 = add nsw i32 %mul83, %68
  %idxprom85 = sext i32 %add84 to i64
  %69 = load float*, float** %data.addr, align 8
  %arrayidx86 = getelementptr inbounds float, float* %69, i64 %idxprom85
  %70 = load float, float* %arrayidx86, align 4
  %conv87 = fpext float %70 to double
  %div88 = fdiv double %conv87, %mul82
  %conv89 = fptrunc double %div88 to float
  store float %conv89, float* %arrayidx86, align 4
  br label %for.inc.90

for.inc.90:                                       ; preds = %for.body.70
  %71 = load i32, i32* %j, align 4
  %inc91 = add nsw i32 %71, 1
  store i32 %inc91, i32* %j, align 4
  br label %for.cond.67

for.end.92:                                       ; preds = %for.cond.67
  br label %for.inc.93

for.inc.93:                                       ; preds = %for.end.92
  %72 = load i32, i32* %i, align 4
  %inc94 = add nsw i32 %72, 1
  store i32 %inc94, i32* %i, align 4
  br label %for.cond.63

for.end.95:                                       ; preds = %for.cond.63
  store i32 1, i32* %j1, align 4
  br label %for.cond.96

for.cond.96:                                      ; preds = %for.inc.145, %for.end.95
  %73 = load i32, i32* %j1, align 4
  %cmp97 = icmp slt i32 %73, 2048
  br i1 %cmp97, label %for.body.99, label %for.end.147

for.body.99:                                      ; preds = %for.cond.96
  %74 = load i32, i32* %j1, align 4
  %mul100 = mul nsw i32 %74, 2049
  %75 = load i32, i32* %j1, align 4
  %add101 = add nsw i32 %mul100, %75
  %idxprom102 = sext i32 %add101 to i64
  %76 = load float*, float** %symmat.addr, align 8
  %arrayidx103 = getelementptr inbounds float, float* %76, i64 %idxprom102
  store float 1.000000e+00, float* %arrayidx103, align 4
  %77 = load i32, i32* %j1, align 4
  %add104 = add nsw i32 %77, 1
  store i32 %add104, i32* %j2, align 4
  br label %for.cond.105

for.cond.105:                                     ; preds = %for.inc.142, %for.body.99
  %78 = load i32, i32* %j2, align 4
  %cmp106 = icmp slt i32 %78, 2049
  br i1 %cmp106, label %for.body.108, label %for.end.144

for.body.108:                                     ; preds = %for.cond.105
  %79 = load i32, i32* %j1, align 4
  %mul109 = mul nsw i32 %79, 2049
  %80 = load i32, i32* %j2, align 4
  %add110 = add nsw i32 %mul109, %80
  %idxprom111 = sext i32 %add110 to i64
  %81 = load float*, float** %symmat.addr, align 8
  %arrayidx112 = getelementptr inbounds float, float* %81, i64 %idxprom111
  store float 0.000000e+00, float* %arrayidx112, align 4
  store i32 1, i32* %i, align 4
  br label %for.cond.113

for.cond.113:                                     ; preds = %for.inc.131, %for.body.108
  %82 = load i32, i32* %i, align 4
  %cmp114 = icmp slt i32 %82, 2049
  br i1 %cmp114, label %for.body.116, label %for.end.133

for.body.116:                                     ; preds = %for.cond.113
  %83 = load i32, i32* %i, align 4
  %mul117 = mul nsw i32 %83, 2049
  %84 = load i32, i32* %j1, align 4
  %add118 = add nsw i32 %mul117, %84
  %idxprom119 = sext i32 %add118 to i64
  %85 = load float*, float** %data.addr, align 8
  %arrayidx120 = getelementptr inbounds float, float* %85, i64 %idxprom119
  %86 = load float, float* %arrayidx120, align 4
  %87 = load i32, i32* %i, align 4
  %mul121 = mul nsw i32 %87, 2049
  %88 = load i32, i32* %j2, align 4
  %add122 = add nsw i32 %mul121, %88
  %idxprom123 = sext i32 %add122 to i64
  %89 = load float*, float** %data.addr, align 8
  %arrayidx124 = getelementptr inbounds float, float* %89, i64 %idxprom123
  %90 = load float, float* %arrayidx124, align 4
  %mul125 = fmul float %86, %90
  %91 = load i32, i32* %j1, align 4
  %mul126 = mul nsw i32 %91, 2049
  %92 = load i32, i32* %j2, align 4
  %add127 = add nsw i32 %mul126, %92
  %idxprom128 = sext i32 %add127 to i64
  %93 = load float*, float** %symmat.addr, align 8
  %arrayidx129 = getelementptr inbounds float, float* %93, i64 %idxprom128
  %94 = load float, float* %arrayidx129, align 4
  %add130 = fadd float %94, %mul125
  store float %add130, float* %arrayidx129, align 4
  br label %for.inc.131

for.inc.131:                                      ; preds = %for.body.116
  %95 = load i32, i32* %i, align 4
  %inc132 = add nsw i32 %95, 1
  store i32 %inc132, i32* %i, align 4
  br label %for.cond.113

for.end.133:                                      ; preds = %for.cond.113
  %96 = load i32, i32* %j1, align 4
  %mul134 = mul nsw i32 %96, 2049
  %97 = load i32, i32* %j2, align 4
  %add135 = add nsw i32 %mul134, %97
  %idxprom136 = sext i32 %add135 to i64
  %98 = load float*, float** %symmat.addr, align 8
  %arrayidx137 = getelementptr inbounds float, float* %98, i64 %idxprom136
  %99 = load float, float* %arrayidx137, align 4
  %100 = load i32, i32* %j2, align 4
  %mul138 = mul nsw i32 %100, 2049
  %101 = load i32, i32* %j1, align 4
  %add139 = add nsw i32 %mul138, %101
  %idxprom140 = sext i32 %add139 to i64
  %102 = load float*, float** %symmat.addr, align 8
  %arrayidx141 = getelementptr inbounds float, float* %102, i64 %idxprom140
  store float %99, float* %arrayidx141, align 4
  br label %for.inc.142

for.inc.142:                                      ; preds = %for.end.133
  %103 = load i32, i32* %j2, align 4
  %inc143 = add nsw i32 %103, 1
  store i32 %inc143, i32* %j2, align 4
  br label %for.cond.105

for.end.144:                                      ; preds = %for.cond.105
  br label %for.inc.145

for.inc.145:                                      ; preds = %for.end.144
  %104 = load i32, i32* %j1, align 4
  %inc146 = add nsw i32 %104, 1
  store i32 %inc146, i32* %j1, align 4
  br label %for.cond.96

for.end.147:                                      ; preds = %for.cond.96
  %105 = load float*, float** %symmat.addr, align 8
  %arrayidx148 = getelementptr inbounds float, float* %105, i64 4198400
  store float 1.000000e+00, float* %arrayidx148, align 4
  ret void
}

; Function Attrs: nounwind
declare double @sqrt(double) #1

; Function Attrs: nounwind uwtable
define void @GPU__correlation(float* %data, float* %mean, float* %stddev, float* %symmat) #0 {
entry:
  %data.addr = alloca float*, align 8
  %mean.addr = alloca float*, align 8
  %stddev.addr = alloca float*, align 8
  %symmat.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %k = alloca i32, align 4
  store float* %data, float** %data.addr, align 8
  store float* %mean, float** %mean.addr, align 8
  store float* %stddev, float** %stddev.addr, align 8
  store float* %symmat, float** %symmat.addr, align 8
  store i32 1, i32* %j, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.11, %entry
  %0 = load i32, i32* %j, align 4
  %cmp = icmp slt i32 %0, 2049
  br i1 %cmp, label %for.body, label %for.end.13

for.body:                                         ; preds = %for.cond
  %1 = load i32, i32* %j, align 4
  %idxprom = sext i32 %1 to i64
  %2 = load float*, float** %mean.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %2, i64 %idxprom
  store float 0.000000e+00, float* %arrayidx, align 4
  store i32 1, i32* %i, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %3 = load i32, i32* %i, align 4
  %cmp2 = icmp slt i32 %3, 2049
  br i1 %cmp2, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.cond.1
  %4 = load i32, i32* %i, align 4
  %mul = mul nsw i32 %4, 2049
  %5 = load i32, i32* %j, align 4
  %add = add nsw i32 %mul, %5
  %idxprom4 = sext i32 %add to i64
  %6 = load float*, float** %data.addr, align 8
  %arrayidx5 = getelementptr inbounds float, float* %6, i64 %idxprom4
  %7 = load float, float* %arrayidx5, align 4
  %8 = load i32, i32* %j, align 4
  %idxprom6 = sext i32 %8 to i64
  %9 = load float*, float** %mean.addr, align 8
  %arrayidx7 = getelementptr inbounds float, float* %9, i64 %idxprom6
  %10 = load float, float* %arrayidx7, align 4
  %add8 = fadd float %10, %7
  store float %add8, float* %arrayidx7, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.3
  %11 = load i32, i32* %i, align 4
  %inc = add nsw i32 %11, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond.1

for.end:                                          ; preds = %for.cond.1
  %12 = load i32, i32* %j, align 4
  %idxprom9 = sext i32 %12 to i64
  %13 = load float*, float** %mean.addr, align 8
  %arrayidx10 = getelementptr inbounds float, float* %13, i64 %idxprom9
  %14 = load float, float* %arrayidx10, align 4
  %div = fdiv float %14, 3.214212e+06
  store float %div, float* %arrayidx10, align 4
  br label %for.inc.11

for.inc.11:                                       ; preds = %for.end
  %15 = load i32, i32* %j, align 4
  %inc12 = add nsw i32 %15, 1
  store i32 %inc12, i32* %j, align 4
  br label %for.cond

for.end.13:                                       ; preds = %for.cond
  store i32 1, i32* %j, align 4
  br label %for.cond.14

for.cond.14:                                      ; preds = %for.inc.56, %for.end.13
  %16 = load i32, i32* %j, align 4
  %cmp15 = icmp slt i32 %16, 2049
  br i1 %cmp15, label %for.body.16, label %for.end.58

for.body.16:                                      ; preds = %for.cond.14
  %17 = load i32, i32* %j, align 4
  %idxprom17 = sext i32 %17 to i64
  %18 = load float*, float** %stddev.addr, align 8
  %arrayidx18 = getelementptr inbounds float, float* %18, i64 %idxprom17
  store float 0.000000e+00, float* %arrayidx18, align 4
  store i32 1, i32* %i, align 4
  br label %for.cond.19

for.cond.19:                                      ; preds = %for.inc.39, %for.body.16
  %19 = load i32, i32* %i, align 4
  %cmp20 = icmp slt i32 %19, 2049
  br i1 %cmp20, label %for.body.21, label %for.end.41

for.body.21:                                      ; preds = %for.cond.19
  %20 = load i32, i32* %i, align 4
  %mul22 = mul nsw i32 %20, 2049
  %21 = load i32, i32* %j, align 4
  %add23 = add nsw i32 %mul22, %21
  %idxprom24 = sext i32 %add23 to i64
  %22 = load float*, float** %data.addr, align 8
  %arrayidx25 = getelementptr inbounds float, float* %22, i64 %idxprom24
  %23 = load float, float* %arrayidx25, align 4
  %24 = load i32, i32* %j, align 4
  %idxprom26 = sext i32 %24 to i64
  %25 = load float*, float** %mean.addr, align 8
  %arrayidx27 = getelementptr inbounds float, float* %25, i64 %idxprom26
  %26 = load float, float* %arrayidx27, align 4
  %sub = fsub float %23, %26
  %27 = load i32, i32* %i, align 4
  %mul28 = mul nsw i32 %27, 2049
  %28 = load i32, i32* %j, align 4
  %add29 = add nsw i32 %mul28, %28
  %idxprom30 = sext i32 %add29 to i64
  %29 = load float*, float** %data.addr, align 8
  %arrayidx31 = getelementptr inbounds float, float* %29, i64 %idxprom30
  %30 = load float, float* %arrayidx31, align 4
  %31 = load i32, i32* %j, align 4
  %idxprom32 = sext i32 %31 to i64
  %32 = load float*, float** %mean.addr, align 8
  %arrayidx33 = getelementptr inbounds float, float* %32, i64 %idxprom32
  %33 = load float, float* %arrayidx33, align 4
  %sub34 = fsub float %30, %33
  %mul35 = fmul float %sub, %sub34
  %34 = load i32, i32* %j, align 4
  %idxprom36 = sext i32 %34 to i64
  %35 = load float*, float** %stddev.addr, align 8
  %arrayidx37 = getelementptr inbounds float, float* %35, i64 %idxprom36
  %36 = load float, float* %arrayidx37, align 4
  %add38 = fadd float %36, %mul35
  store float %add38, float* %arrayidx37, align 4
  br label %for.inc.39

for.inc.39:                                       ; preds = %for.body.21
  %37 = load i32, i32* %i, align 4
  %inc40 = add nsw i32 %37, 1
  store i32 %inc40, i32* %i, align 4
  br label %for.cond.19

for.end.41:                                       ; preds = %for.cond.19
  %38 = load i32, i32* %j, align 4
  %idxprom42 = sext i32 %38 to i64
  %39 = load float*, float** %stddev.addr, align 8
  %arrayidx43 = getelementptr inbounds float, float* %39, i64 %idxprom42
  %40 = load float, float* %arrayidx43, align 4
  %div44 = fdiv float %40, 3.214212e+06
  store float %div44, float* %arrayidx43, align 4
  %41 = load i32, i32* %j, align 4
  %idxprom45 = sext i32 %41 to i64
  %42 = load float*, float** %stddev.addr, align 8
  %arrayidx46 = getelementptr inbounds float, float* %42, i64 %idxprom45
  %43 = load float, float* %arrayidx46, align 4
  %conv = fpext float %43 to double
  %call = call double @sqrt(double %conv) #3
  %conv47 = fptrunc double %call to float
  %44 = load i32, i32* %j, align 4
  %idxprom48 = sext i32 %44 to i64
  %45 = load float*, float** %stddev.addr, align 8
  %arrayidx49 = getelementptr inbounds float, float* %45, i64 %idxprom48
  store float %conv47, float* %arrayidx49, align 4
  %46 = load i32, i32* %j, align 4
  %idxprom50 = sext i32 %46 to i64
  %47 = load float*, float** %stddev.addr, align 8
  %arrayidx51 = getelementptr inbounds float, float* %47, i64 %idxprom50
  %48 = load float, float* %arrayidx51, align 4
  %cmp52 = fcmp ole float %48, 0x3F747AE140000000
  br i1 %cmp52, label %if.then, label %if.end

if.then:                                          ; preds = %for.end.41
  %49 = load i32, i32* %j, align 4
  %idxprom54 = sext i32 %49 to i64
  %50 = load float*, float** %stddev.addr, align 8
  %arrayidx55 = getelementptr inbounds float, float* %50, i64 %idxprom54
  store float 1.000000e+00, float* %arrayidx55, align 4
  br label %if.end

if.end:                                           ; preds = %if.then, %for.end.41
  br label %for.inc.56

for.inc.56:                                       ; preds = %if.end
  %51 = load i32, i32* %j, align 4
  %inc57 = add nsw i32 %51, 1
  store i32 %inc57, i32* %j, align 4
  br label %for.cond.14

for.end.58:                                       ; preds = %for.cond.14
  store i32 1, i32* %i, align 4
  br label %for.cond.59

for.cond.59:                                      ; preds = %for.inc.89, %for.end.58
  %52 = load i32, i32* %i, align 4
  %cmp60 = icmp slt i32 %52, 2049
  br i1 %cmp60, label %for.body.62, label %for.end.91

for.body.62:                                      ; preds = %for.cond.59
  store i32 1, i32* %j, align 4
  br label %for.cond.63

for.cond.63:                                      ; preds = %for.inc.86, %for.body.62
  %53 = load i32, i32* %j, align 4
  %cmp64 = icmp slt i32 %53, 2049
  br i1 %cmp64, label %for.body.66, label %for.end.88

for.body.66:                                      ; preds = %for.cond.63
  %54 = load i32, i32* %j, align 4
  %idxprom67 = sext i32 %54 to i64
  %55 = load float*, float** %mean.addr, align 8
  %arrayidx68 = getelementptr inbounds float, float* %55, i64 %idxprom67
  %56 = load float, float* %arrayidx68, align 4
  %57 = load i32, i32* %i, align 4
  %mul69 = mul nsw i32 %57, 2049
  %58 = load i32, i32* %j, align 4
  %add70 = add nsw i32 %mul69, %58
  %idxprom71 = sext i32 %add70 to i64
  %59 = load float*, float** %data.addr, align 8
  %arrayidx72 = getelementptr inbounds float, float* %59, i64 %idxprom71
  %60 = load float, float* %arrayidx72, align 4
  %sub73 = fsub float %60, %56
  store float %sub73, float* %arrayidx72, align 4
  %call74 = call double @sqrt(double 3.214212e+06) #3
  %61 = load i32, i32* %j, align 4
  %idxprom75 = sext i32 %61 to i64
  %62 = load float*, float** %stddev.addr, align 8
  %arrayidx76 = getelementptr inbounds float, float* %62, i64 %idxprom75
  %63 = load float, float* %arrayidx76, align 4
  %conv77 = fpext float %63 to double
  %mul78 = fmul double %call74, %conv77
  %64 = load i32, i32* %i, align 4
  %mul79 = mul nsw i32 %64, 2049
  %65 = load i32, i32* %j, align 4
  %add80 = add nsw i32 %mul79, %65
  %idxprom81 = sext i32 %add80 to i64
  %66 = load float*, float** %data.addr, align 8
  %arrayidx82 = getelementptr inbounds float, float* %66, i64 %idxprom81
  %67 = load float, float* %arrayidx82, align 4
  %conv83 = fpext float %67 to double
  %div84 = fdiv double %conv83, %mul78
  %conv85 = fptrunc double %div84 to float
  store float %conv85, float* %arrayidx82, align 4
  br label %for.inc.86

for.inc.86:                                       ; preds = %for.body.66
  %68 = load i32, i32* %j, align 4
  %inc87 = add nsw i32 %68, 1
  store i32 %inc87, i32* %j, align 4
  br label %for.cond.63

for.end.88:                                       ; preds = %for.cond.63
  br label %for.inc.89

for.inc.89:                                       ; preds = %for.end.88
  %69 = load i32, i32* %i, align 4
  %inc90 = add nsw i32 %69, 1
  store i32 %inc90, i32* %i, align 4
  br label %for.cond.59

for.end.91:                                       ; preds = %for.cond.59
  store i32 1, i32* %k, align 4
  br label %for.cond.92

for.cond.92:                                      ; preds = %for.inc.141, %for.end.91
  %70 = load i32, i32* %k, align 4
  %cmp93 = icmp slt i32 %70, 2048
  br i1 %cmp93, label %for.body.95, label %for.end.143

for.body.95:                                      ; preds = %for.cond.92
  %71 = load i32, i32* %k, align 4
  %mul96 = mul nsw i32 %71, 2049
  %72 = load i32, i32* %k, align 4
  %add97 = add nsw i32 %mul96, %72
  %idxprom98 = sext i32 %add97 to i64
  %73 = load float*, float** %symmat.addr, align 8
  %arrayidx99 = getelementptr inbounds float, float* %73, i64 %idxprom98
  store float 1.000000e+00, float* %arrayidx99, align 4
  %74 = load i32, i32* %k, align 4
  %add100 = add nsw i32 %74, 1
  store i32 %add100, i32* %j, align 4
  br label %for.cond.101

for.cond.101:                                     ; preds = %for.inc.138, %for.body.95
  %75 = load i32, i32* %j, align 4
  %cmp102 = icmp slt i32 %75, 2049
  br i1 %cmp102, label %for.body.104, label %for.end.140

for.body.104:                                     ; preds = %for.cond.101
  %76 = load i32, i32* %k, align 4
  %mul105 = mul nsw i32 %76, 2049
  %77 = load i32, i32* %j, align 4
  %add106 = add nsw i32 %mul105, %77
  %idxprom107 = sext i32 %add106 to i64
  %78 = load float*, float** %symmat.addr, align 8
  %arrayidx108 = getelementptr inbounds float, float* %78, i64 %idxprom107
  store float 0.000000e+00, float* %arrayidx108, align 4
  store i32 1, i32* %i, align 4
  br label %for.cond.109

for.cond.109:                                     ; preds = %for.inc.127, %for.body.104
  %79 = load i32, i32* %i, align 4
  %cmp110 = icmp slt i32 %79, 2049
  br i1 %cmp110, label %for.body.112, label %for.end.129

for.body.112:                                     ; preds = %for.cond.109
  %80 = load i32, i32* %i, align 4
  %mul113 = mul nsw i32 %80, 2049
  %81 = load i32, i32* %k, align 4
  %add114 = add nsw i32 %mul113, %81
  %idxprom115 = sext i32 %add114 to i64
  %82 = load float*, float** %data.addr, align 8
  %arrayidx116 = getelementptr inbounds float, float* %82, i64 %idxprom115
  %83 = load float, float* %arrayidx116, align 4
  %84 = load i32, i32* %i, align 4
  %mul117 = mul nsw i32 %84, 2049
  %85 = load i32, i32* %j, align 4
  %add118 = add nsw i32 %mul117, %85
  %idxprom119 = sext i32 %add118 to i64
  %86 = load float*, float** %data.addr, align 8
  %arrayidx120 = getelementptr inbounds float, float* %86, i64 %idxprom119
  %87 = load float, float* %arrayidx120, align 4
  %mul121 = fmul float %83, %87
  %88 = load i32, i32* %k, align 4
  %mul122 = mul nsw i32 %88, 2049
  %89 = load i32, i32* %j, align 4
  %add123 = add nsw i32 %mul122, %89
  %idxprom124 = sext i32 %add123 to i64
  %90 = load float*, float** %symmat.addr, align 8
  %arrayidx125 = getelementptr inbounds float, float* %90, i64 %idxprom124
  %91 = load float, float* %arrayidx125, align 4
  %add126 = fadd float %91, %mul121
  store float %add126, float* %arrayidx125, align 4
  br label %for.inc.127

for.inc.127:                                      ; preds = %for.body.112
  %92 = load i32, i32* %i, align 4
  %inc128 = add nsw i32 %92, 1
  store i32 %inc128, i32* %i, align 4
  br label %for.cond.109

for.end.129:                                      ; preds = %for.cond.109
  %93 = load i32, i32* %k, align 4
  %mul130 = mul nsw i32 %93, 2049
  %94 = load i32, i32* %j, align 4
  %add131 = add nsw i32 %mul130, %94
  %idxprom132 = sext i32 %add131 to i64
  %95 = load float*, float** %symmat.addr, align 8
  %arrayidx133 = getelementptr inbounds float, float* %95, i64 %idxprom132
  %96 = load float, float* %arrayidx133, align 4
  %97 = load i32, i32* %j, align 4
  %mul134 = mul nsw i32 %97, 2049
  %98 = load i32, i32* %k, align 4
  %add135 = add nsw i32 %mul134, %98
  %idxprom136 = sext i32 %add135 to i64
  %99 = load float*, float** %symmat.addr, align 8
  %arrayidx137 = getelementptr inbounds float, float* %99, i64 %idxprom136
  store float %96, float* %arrayidx137, align 4
  br label %for.inc.138

for.inc.138:                                      ; preds = %for.end.129
  %100 = load i32, i32* %j, align 4
  %inc139 = add nsw i32 %100, 1
  store i32 %inc139, i32* %j, align 4
  br label %for.cond.101

for.end.140:                                      ; preds = %for.cond.101
  br label %for.inc.141

for.inc.141:                                      ; preds = %for.end.140
  %101 = load i32, i32* %k, align 4
  %inc142 = add nsw i32 %101, 1
  store i32 %inc142, i32* %k, align 4
  br label %for.cond.92

for.end.143:                                      ; preds = %for.cond.92
  %102 = load float*, float** %symmat.addr, align 8
  %arrayidx144 = getelementptr inbounds float, float* %102, i64 4198400
  store float 1.000000e+00, float* %arrayidx144, align 4
  ret void
}

; Function Attrs: nounwind uwtable
define void @compareResults(float* %symmat, float* %symmat_outputFromGpu) #0 {
entry:
  %symmat.addr = alloca float*, align 8
  %symmat_outputFromGpu.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %fail = alloca i32, align 4
  store float* %symmat, float** %symmat.addr, align 8
  store float* %symmat_outputFromGpu, float** %symmat_outputFromGpu.addr, align 8
  store i32 0, i32* %fail, align 4
  store i32 1, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.13, %entry
  %0 = load i32, i32* %i, align 4
  %cmp = icmp slt i32 %0, 2049
  br i1 %cmp, label %for.body, label %for.end.15

for.body:                                         ; preds = %for.cond
  store i32 1, i32* %j, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %1 = load i32, i32* %j, align 4
  %cmp2 = icmp slt i32 %1, 2049
  br i1 %cmp2, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.cond.1
  %2 = load i32, i32* %i, align 4
  %mul = mul nsw i32 %2, 2049
  %3 = load i32, i32* %j, align 4
  %add = add nsw i32 %mul, %3
  %idxprom = sext i32 %add to i64
  %4 = load float*, float** %symmat.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %4, i64 %idxprom
  %5 = load float, float* %arrayidx, align 4
  %conv = fpext float %5 to double
  %6 = load i32, i32* %i, align 4
  %mul4 = mul nsw i32 %6, 2049
  %7 = load i32, i32* %j, align 4
  %add5 = add nsw i32 %mul4, %7
  %idxprom6 = sext i32 %add5 to i64
  %8 = load float*, float** %symmat_outputFromGpu.addr, align 8
  %arrayidx7 = getelementptr inbounds float, float* %8, i64 %idxprom6
  %9 = load float, float* %arrayidx7, align 4
  %conv8 = fpext float %9 to double
  %call = call float @percentDiff(double %conv, double %conv8)
  %conv9 = fpext float %call to double
  %cmp10 = fcmp ogt double %conv9, 1.050000e+00
  br i1 %cmp10, label %if.then, label %if.end

if.then:                                          ; preds = %for.body.3
  %10 = load i32, i32* %fail, align 4
  %inc = add nsw i32 %10, 1
  store i32 %inc, i32* %fail, align 4
  br label %if.end

if.end:                                           ; preds = %if.then, %for.body.3
  br label %for.inc

for.inc:                                          ; preds = %if.end
  %11 = load i32, i32* %j, align 4
  %inc12 = add nsw i32 %11, 1
  store i32 %inc12, i32* %j, align 4
  br label %for.cond.1

for.end:                                          ; preds = %for.cond.1
  br label %for.inc.13

for.inc.13:                                       ; preds = %for.end
  %12 = load i32, i32* %i, align 4
  %inc14 = add nsw i32 %12, 1
  store i32 %inc14, i32* %i, align 4
  br label %for.cond

for.end.15:                                       ; preds = %for.cond
  %13 = load i32, i32* %fail, align 4
  %call16 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([74 x i8], [74 x i8]* @.str.1, i32 0, i32 0), double 1.050000e+00, i32 %13)
  ret void
}

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
entry:
  %retval = alloca i32, align 4
  %t_start = alloca double, align 8
  %t_end = alloca double, align 8
  %data = alloca float*, align 8
  %mean = alloca float*, align 8
  %stddev = alloca float*, align 8
  %symmat = alloca float*, align 8
  %symmat_GPU = alloca float*, align 8
  store i32 0, i32* %retval
  %call = call noalias i8* @malloc(i64 16793604) #3
  %0 = bitcast i8* %call to float*
  store float* %0, float** %data, align 8
  %call1 = call noalias i8* @malloc(i64 8196) #3
  %1 = bitcast i8* %call1 to float*
  store float* %1, float** %mean, align 8
  %call2 = call noalias i8* @malloc(i64 8196) #3
  %2 = bitcast i8* %call2 to float*
  store float* %2, float** %stddev, align 8
  %call3 = call noalias i8* @malloc(i64 16793604) #3
  %3 = bitcast i8* %call3 to float*
  store float* %3, float** %symmat, align 8
  %call4 = call noalias i8* @malloc(i64 16793604) #3
  %4 = bitcast i8* %call4 to float*
  store float* %4, float** %symmat_GPU, align 8
  %5 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %call5 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %5, i8* getelementptr inbounds ([31 x i8], [31 x i8]* @.str.2, i32 0, i32 0))
  %6 = load float*, float** %data, align 8
  call void @init_arrays(float* %6)
  %call6 = call double @rtclock()
  store double %call6, double* %t_start, align 8
  %7 = load float*, float** %data, align 8
  %8 = load float*, float** %mean, align 8
  %9 = load float*, float** %stddev, align 8
  %10 = load float*, float** %symmat_GPU, align 8
  call void @GPU__correlation(float* %7, float* %8, float* %9, float* %10)
  %call7 = call double @rtclock()
  store double %call7, double* %t_end, align 8
  %11 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %12 = load double, double* %t_end, align 8
  %13 = load double, double* %t_start, align 8
  %sub = fsub double %12, %13
  %call8 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %11, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.3, i32 0, i32 0), double %sub)
  %14 = load float*, float** %data, align 8
  call void @init_arrays(float* %14)
  %call9 = call double @rtclock()
  store double %call9, double* %t_start, align 8
  %15 = load float*, float** %data, align 8
  %16 = load float*, float** %mean, align 8
  %17 = load float*, float** %stddev, align 8
  %18 = load float*, float** %symmat, align 8
  call void @correlation(float* %15, float* %16, float* %17, float* %18)
  %call10 = call double @rtclock()
  store double %call10, double* %t_end, align 8
  %19 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %20 = load double, double* %t_end, align 8
  %21 = load double, double* %t_start, align 8
  %sub11 = fsub double %20, %21
  %call12 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %19, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.4, i32 0, i32 0), double %sub11)
  %22 = load float*, float** %symmat, align 8
  %23 = load float*, float** %symmat_GPU, align 8
  call void @compareResults(float* %22, float* %23)
  %24 = load float*, float** %data, align 8
  %25 = bitcast float* %24 to i8*
  call void @free(i8* %25) #3
  %26 = load float*, float** %mean, align 8
  %27 = bitcast float* %26 to i8*
  call void @free(i8* %27) #3
  %28 = load float*, float** %stddev, align 8
  %29 = bitcast float* %28 to i8*
  call void @free(i8* %29) #3
  %30 = load float*, float** %symmat, align 8
  %31 = bitcast float* %30 to i8*
  call void @free(i8* %31) #3
  %32 = load float*, float** %symmat_GPU, align 8
  %33 = bitcast float* %32 to i8*
  call void @free(i8* %33) #3
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
