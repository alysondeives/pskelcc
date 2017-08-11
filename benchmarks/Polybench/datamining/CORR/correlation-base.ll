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
@.str.3 = private unnamed_addr constant [22 x i8] c"CPU Runtime: %0.6lfs\0A\00", align 1

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
define void @correlation(i32 %m, i32 %n, float* %data, float* %mean, float* %stddev, float* %symmat) #0 {
entry:
  %m.addr = alloca i32, align 4
  %n.addr = alloca i32, align 4
  %data.addr = alloca float*, align 8
  %mean.addr = alloca float*, align 8
  %stddev.addr = alloca float*, align 8
  %symmat.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %j1 = alloca i32, align 4
  %j2 = alloca i32, align 4
  store i32 %m, i32* %m.addr, align 4
  store i32 %n, i32* %n.addr, align 4
  store float* %data, float** %data.addr, align 8
  store float* %mean, float** %mean.addr, align 8
  store float* %stddev, float** %stddev.addr, align 8
  store float* %symmat, float** %symmat.addr, align 8
  store i32 0, i32* %j, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.11, %entry
  %0 = load i32, i32* %j, align 4
  %1 = load i32, i32* %m.addr, align 4
  %cmp = icmp slt i32 %0, %1
  br i1 %cmp, label %for.body, label %for.end.13

for.body:                                         ; preds = %for.cond
  %2 = load i32, i32* %j, align 4
  %idxprom = sext i32 %2 to i64
  %3 = load float*, float** %mean.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %3, i64 %idxprom
  store float 0.000000e+00, float* %arrayidx, align 4
  store i32 0, i32* %i, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %4 = load i32, i32* %i, align 4
  %5 = load i32, i32* %n.addr, align 4
  %cmp2 = icmp slt i32 %4, %5
  br i1 %cmp2, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.cond.1
  %6 = load i32, i32* %i, align 4
  %7 = load i32, i32* %m.addr, align 4
  %mul = mul nsw i32 %6, %7
  %8 = load i32, i32* %j, align 4
  %add = add nsw i32 %mul, %8
  %idxprom4 = sext i32 %add to i64
  %9 = load float*, float** %data.addr, align 8
  %arrayidx5 = getelementptr inbounds float, float* %9, i64 %idxprom4
  %10 = load float, float* %arrayidx5, align 4
  %11 = load i32, i32* %j, align 4
  %idxprom6 = sext i32 %11 to i64
  %12 = load float*, float** %mean.addr, align 8
  %arrayidx7 = getelementptr inbounds float, float* %12, i64 %idxprom6
  %13 = load float, float* %arrayidx7, align 4
  %add8 = fadd float %13, %10
  store float %add8, float* %arrayidx7, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.3
  %14 = load i32, i32* %i, align 4
  %inc = add nsw i32 %14, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond.1

for.end:                                          ; preds = %for.cond.1
  %15 = load i32, i32* %j, align 4
  %idxprom9 = sext i32 %15 to i64
  %16 = load float*, float** %mean.addr, align 8
  %arrayidx10 = getelementptr inbounds float, float* %16, i64 %idxprom9
  %17 = load float, float* %arrayidx10, align 4
  %div = fdiv float %17, 3.214212e+06
  store float %div, float* %arrayidx10, align 4
  br label %for.inc.11

for.inc.11:                                       ; preds = %for.end
  %18 = load i32, i32* %j, align 4
  %inc12 = add nsw i32 %18, 1
  store i32 %inc12, i32* %j, align 4
  br label %for.cond

for.end.13:                                       ; preds = %for.cond
  store i32 0, i32* %j, align 4
  br label %for.cond.14

for.cond.14:                                      ; preds = %for.inc.60, %for.end.13
  %19 = load i32, i32* %j, align 4
  %20 = load i32, i32* %m.addr, align 4
  %cmp15 = icmp slt i32 %19, %20
  br i1 %cmp15, label %for.body.16, label %for.end.62

for.body.16:                                      ; preds = %for.cond.14
  %21 = load i32, i32* %j, align 4
  %idxprom17 = sext i32 %21 to i64
  %22 = load float*, float** %stddev.addr, align 8
  %arrayidx18 = getelementptr inbounds float, float* %22, i64 %idxprom17
  store float 0.000000e+00, float* %arrayidx18, align 4
  store i32 0, i32* %i, align 4
  br label %for.cond.19

for.cond.19:                                      ; preds = %for.inc.39, %for.body.16
  %23 = load i32, i32* %i, align 4
  %24 = load i32, i32* %n.addr, align 4
  %cmp20 = icmp slt i32 %23, %24
  br i1 %cmp20, label %for.body.21, label %for.end.41

for.body.21:                                      ; preds = %for.cond.19
  %25 = load i32, i32* %i, align 4
  %26 = load i32, i32* %m.addr, align 4
  %mul22 = mul nsw i32 %25, %26
  %27 = load i32, i32* %j, align 4
  %add23 = add nsw i32 %mul22, %27
  %idxprom24 = sext i32 %add23 to i64
  %28 = load float*, float** %data.addr, align 8
  %arrayidx25 = getelementptr inbounds float, float* %28, i64 %idxprom24
  %29 = load float, float* %arrayidx25, align 4
  %30 = load i32, i32* %j, align 4
  %idxprom26 = sext i32 %30 to i64
  %31 = load float*, float** %mean.addr, align 8
  %arrayidx27 = getelementptr inbounds float, float* %31, i64 %idxprom26
  %32 = load float, float* %arrayidx27, align 4
  %sub = fsub float %29, %32
  %33 = load i32, i32* %i, align 4
  %34 = load i32, i32* %m.addr, align 4
  %mul28 = mul nsw i32 %33, %34
  %35 = load i32, i32* %j, align 4
  %add29 = add nsw i32 %mul28, %35
  %idxprom30 = sext i32 %add29 to i64
  %36 = load float*, float** %data.addr, align 8
  %arrayidx31 = getelementptr inbounds float, float* %36, i64 %idxprom30
  %37 = load float, float* %arrayidx31, align 4
  %38 = load i32, i32* %j, align 4
  %idxprom32 = sext i32 %38 to i64
  %39 = load float*, float** %mean.addr, align 8
  %arrayidx33 = getelementptr inbounds float, float* %39, i64 %idxprom32
  %40 = load float, float* %arrayidx33, align 4
  %sub34 = fsub float %37, %40
  %mul35 = fmul float %sub, %sub34
  %41 = load i32, i32* %j, align 4
  %idxprom36 = sext i32 %41 to i64
  %42 = load float*, float** %stddev.addr, align 8
  %arrayidx37 = getelementptr inbounds float, float* %42, i64 %idxprom36
  %43 = load float, float* %arrayidx37, align 4
  %add38 = fadd float %43, %mul35
  store float %add38, float* %arrayidx37, align 4
  br label %for.inc.39

for.inc.39:                                       ; preds = %for.body.21
  %44 = load i32, i32* %i, align 4
  %inc40 = add nsw i32 %44, 1
  store i32 %inc40, i32* %i, align 4
  br label %for.cond.19

for.end.41:                                       ; preds = %for.cond.19
  %45 = load i32, i32* %j, align 4
  %idxprom42 = sext i32 %45 to i64
  %46 = load float*, float** %stddev.addr, align 8
  %arrayidx43 = getelementptr inbounds float, float* %46, i64 %idxprom42
  %47 = load float, float* %arrayidx43, align 4
  %div44 = fdiv float %47, 3.214212e+06
  store float %div44, float* %arrayidx43, align 4
  %48 = load i32, i32* %j, align 4
  %idxprom45 = sext i32 %48 to i64
  %49 = load float*, float** %stddev.addr, align 8
  %arrayidx46 = getelementptr inbounds float, float* %49, i64 %idxprom45
  %50 = load float, float* %arrayidx46, align 4
  %conv = fpext float %50 to double
  %call = call double @sqrt(double %conv) #3
  %conv47 = fptrunc double %call to float
  %51 = load i32, i32* %j, align 4
  %idxprom48 = sext i32 %51 to i64
  %52 = load float*, float** %stddev.addr, align 8
  %arrayidx49 = getelementptr inbounds float, float* %52, i64 %idxprom48
  store float %conv47, float* %arrayidx49, align 4
  %53 = load i32, i32* %j, align 4
  %idxprom50 = sext i32 %53 to i64
  %54 = load float*, float** %stddev.addr, align 8
  %arrayidx51 = getelementptr inbounds float, float* %54, i64 %idxprom50
  %55 = load float, float* %arrayidx51, align 4
  %cmp52 = fcmp ole float %55, 0x3F747AE140000000
  br i1 %cmp52, label %cond.true, label %cond.false

cond.true:                                        ; preds = %for.end.41
  br label %cond.end

cond.false:                                       ; preds = %for.end.41
  %56 = load i32, i32* %j, align 4
  %idxprom54 = sext i32 %56 to i64
  %57 = load float*, float** %stddev.addr, align 8
  %arrayidx55 = getelementptr inbounds float, float* %57, i64 %idxprom54
  %58 = load float, float* %arrayidx55, align 4
  %conv56 = fpext float %58 to double
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi double [ 1.000000e+00, %cond.true ], [ %conv56, %cond.false ]
  %conv57 = fptrunc double %cond to float
  %59 = load i32, i32* %j, align 4
  %idxprom58 = sext i32 %59 to i64
  %60 = load float*, float** %stddev.addr, align 8
  %arrayidx59 = getelementptr inbounds float, float* %60, i64 %idxprom58
  store float %conv57, float* %arrayidx59, align 4
  br label %for.inc.60

for.inc.60:                                       ; preds = %cond.end
  %61 = load i32, i32* %j, align 4
  %inc61 = add nsw i32 %61, 1
  store i32 %inc61, i32* %j, align 4
  br label %for.cond.14

for.end.62:                                       ; preds = %for.cond.14
  store i32 0, i32* %i, align 4
  br label %for.cond.63

for.cond.63:                                      ; preds = %for.inc.93, %for.end.62
  %62 = load i32, i32* %i, align 4
  %63 = load i32, i32* %n.addr, align 4
  %cmp64 = icmp slt i32 %62, %63
  br i1 %cmp64, label %for.body.66, label %for.end.95

for.body.66:                                      ; preds = %for.cond.63
  store i32 0, i32* %j, align 4
  br label %for.cond.67

for.cond.67:                                      ; preds = %for.inc.90, %for.body.66
  %64 = load i32, i32* %j, align 4
  %65 = load i32, i32* %m.addr, align 4
  %cmp68 = icmp slt i32 %64, %65
  br i1 %cmp68, label %for.body.70, label %for.end.92

for.body.70:                                      ; preds = %for.cond.67
  %66 = load i32, i32* %j, align 4
  %idxprom71 = sext i32 %66 to i64
  %67 = load float*, float** %mean.addr, align 8
  %arrayidx72 = getelementptr inbounds float, float* %67, i64 %idxprom71
  %68 = load float, float* %arrayidx72, align 4
  %69 = load i32, i32* %i, align 4
  %70 = load i32, i32* %m.addr, align 4
  %mul73 = mul nsw i32 %69, %70
  %71 = load i32, i32* %j, align 4
  %add74 = add nsw i32 %mul73, %71
  %idxprom75 = sext i32 %add74 to i64
  %72 = load float*, float** %data.addr, align 8
  %arrayidx76 = getelementptr inbounds float, float* %72, i64 %idxprom75
  %73 = load float, float* %arrayidx76, align 4
  %sub77 = fsub float %73, %68
  store float %sub77, float* %arrayidx76, align 4
  %call78 = call double @sqrt(double 3.214212e+06) #3
  %74 = load i32, i32* %j, align 4
  %idxprom79 = sext i32 %74 to i64
  %75 = load float*, float** %stddev.addr, align 8
  %arrayidx80 = getelementptr inbounds float, float* %75, i64 %idxprom79
  %76 = load float, float* %arrayidx80, align 4
  %conv81 = fpext float %76 to double
  %mul82 = fmul double %call78, %conv81
  %77 = load i32, i32* %i, align 4
  %78 = load i32, i32* %m.addr, align 4
  %mul83 = mul nsw i32 %77, %78
  %79 = load i32, i32* %j, align 4
  %add84 = add nsw i32 %mul83, %79
  %idxprom85 = sext i32 %add84 to i64
  %80 = load float*, float** %data.addr, align 8
  %arrayidx86 = getelementptr inbounds float, float* %80, i64 %idxprom85
  %81 = load float, float* %arrayidx86, align 4
  %conv87 = fpext float %81 to double
  %div88 = fdiv double %conv87, %mul82
  %conv89 = fptrunc double %div88 to float
  store float %conv89, float* %arrayidx86, align 4
  br label %for.inc.90

for.inc.90:                                       ; preds = %for.body.70
  %82 = load i32, i32* %j, align 4
  %inc91 = add nsw i32 %82, 1
  store i32 %inc91, i32* %j, align 4
  br label %for.cond.67

for.end.92:                                       ; preds = %for.cond.67
  br label %for.inc.93

for.inc.93:                                       ; preds = %for.end.92
  %83 = load i32, i32* %i, align 4
  %inc94 = add nsw i32 %83, 1
  store i32 %inc94, i32* %i, align 4
  br label %for.cond.63

for.end.95:                                       ; preds = %for.cond.63
  store i32 0, i32* %j1, align 4
  br label %for.cond.96

for.cond.96:                                      ; preds = %for.inc.146, %for.end.95
  %84 = load i32, i32* %j1, align 4
  %85 = load i32, i32* %m.addr, align 4
  %sub97 = sub nsw i32 %85, 1
  %cmp98 = icmp slt i32 %84, %sub97
  br i1 %cmp98, label %for.body.100, label %for.end.148

for.body.100:                                     ; preds = %for.cond.96
  %86 = load i32, i32* %j1, align 4
  %87 = load i32, i32* %m.addr, align 4
  %mul101 = mul nsw i32 %86, %87
  %88 = load i32, i32* %j1, align 4
  %add102 = add nsw i32 %mul101, %88
  %idxprom103 = sext i32 %add102 to i64
  %89 = load float*, float** %symmat.addr, align 8
  %arrayidx104 = getelementptr inbounds float, float* %89, i64 %idxprom103
  store float 1.000000e+00, float* %arrayidx104, align 4
  %90 = load i32, i32* %j1, align 4
  %add105 = add nsw i32 %90, 1
  store i32 %add105, i32* %j2, align 4
  br label %for.cond.106

for.cond.106:                                     ; preds = %for.inc.143, %for.body.100
  %91 = load i32, i32* %j2, align 4
  %92 = load i32, i32* %m.addr, align 4
  %cmp107 = icmp slt i32 %91, %92
  br i1 %cmp107, label %for.body.109, label %for.end.145

for.body.109:                                     ; preds = %for.cond.106
  %93 = load i32, i32* %j1, align 4
  %94 = load i32, i32* %m.addr, align 4
  %mul110 = mul nsw i32 %93, %94
  %95 = load i32, i32* %j2, align 4
  %add111 = add nsw i32 %mul110, %95
  %idxprom112 = sext i32 %add111 to i64
  %96 = load float*, float** %symmat.addr, align 8
  %arrayidx113 = getelementptr inbounds float, float* %96, i64 %idxprom112
  store float 0.000000e+00, float* %arrayidx113, align 4
  store i32 0, i32* %i, align 4
  br label %for.cond.114

for.cond.114:                                     ; preds = %for.inc.132, %for.body.109
  %97 = load i32, i32* %i, align 4
  %98 = load i32, i32* %n.addr, align 4
  %cmp115 = icmp slt i32 %97, %98
  br i1 %cmp115, label %for.body.117, label %for.end.134

for.body.117:                                     ; preds = %for.cond.114
  %99 = load i32, i32* %i, align 4
  %100 = load i32, i32* %m.addr, align 4
  %mul118 = mul nsw i32 %99, %100
  %101 = load i32, i32* %j1, align 4
  %add119 = add nsw i32 %mul118, %101
  %idxprom120 = sext i32 %add119 to i64
  %102 = load float*, float** %data.addr, align 8
  %arrayidx121 = getelementptr inbounds float, float* %102, i64 %idxprom120
  %103 = load float, float* %arrayidx121, align 4
  %104 = load i32, i32* %i, align 4
  %105 = load i32, i32* %m.addr, align 4
  %mul122 = mul nsw i32 %104, %105
  %106 = load i32, i32* %j2, align 4
  %add123 = add nsw i32 %mul122, %106
  %idxprom124 = sext i32 %add123 to i64
  %107 = load float*, float** %data.addr, align 8
  %arrayidx125 = getelementptr inbounds float, float* %107, i64 %idxprom124
  %108 = load float, float* %arrayidx125, align 4
  %mul126 = fmul float %103, %108
  %109 = load i32, i32* %j1, align 4
  %110 = load i32, i32* %m.addr, align 4
  %mul127 = mul nsw i32 %109, %110
  %111 = load i32, i32* %j2, align 4
  %add128 = add nsw i32 %mul127, %111
  %idxprom129 = sext i32 %add128 to i64
  %112 = load float*, float** %symmat.addr, align 8
  %arrayidx130 = getelementptr inbounds float, float* %112, i64 %idxprom129
  %113 = load float, float* %arrayidx130, align 4
  %add131 = fadd float %113, %mul126
  store float %add131, float* %arrayidx130, align 4
  br label %for.inc.132

for.inc.132:                                      ; preds = %for.body.117
  %114 = load i32, i32* %i, align 4
  %inc133 = add nsw i32 %114, 1
  store i32 %inc133, i32* %i, align 4
  br label %for.cond.114

for.end.134:                                      ; preds = %for.cond.114
  %115 = load i32, i32* %j1, align 4
  %116 = load i32, i32* %m.addr, align 4
  %mul135 = mul nsw i32 %115, %116
  %117 = load i32, i32* %j2, align 4
  %add136 = add nsw i32 %mul135, %117
  %idxprom137 = sext i32 %add136 to i64
  %118 = load float*, float** %symmat.addr, align 8
  %arrayidx138 = getelementptr inbounds float, float* %118, i64 %idxprom137
  %119 = load float, float* %arrayidx138, align 4
  %120 = load i32, i32* %j2, align 4
  %121 = load i32, i32* %m.addr, align 4
  %mul139 = mul nsw i32 %120, %121
  %122 = load i32, i32* %j1, align 4
  %add140 = add nsw i32 %mul139, %122
  %idxprom141 = sext i32 %add140 to i64
  %123 = load float*, float** %symmat.addr, align 8
  %arrayidx142 = getelementptr inbounds float, float* %123, i64 %idxprom141
  store float %119, float* %arrayidx142, align 4
  br label %for.inc.143

for.inc.143:                                      ; preds = %for.end.134
  %124 = load i32, i32* %j2, align 4
  %inc144 = add nsw i32 %124, 1
  store i32 %inc144, i32* %j2, align 4
  br label %for.cond.106

for.end.145:                                      ; preds = %for.cond.106
  br label %for.inc.146

for.inc.146:                                      ; preds = %for.end.145
  %125 = load i32, i32* %j1, align 4
  %inc147 = add nsw i32 %125, 1
  store i32 %inc147, i32* %j1, align 4
  br label %for.cond.96

for.end.148:                                      ; preds = %for.cond.96
  %126 = load i32, i32* %m.addr, align 4
  %sub149 = sub nsw i32 %126, 1
  %127 = load i32, i32* %m.addr, align 4
  %mul150 = mul nsw i32 %sub149, %127
  %128 = load i32, i32* %m.addr, align 4
  %sub151 = sub nsw i32 %128, 1
  %add152 = add nsw i32 %mul150, %sub151
  %idxprom153 = sext i32 %add152 to i64
  %129 = load float*, float** %symmat.addr, align 8
  %arrayidx154 = getelementptr inbounds float, float* %129, i64 %idxprom153
  store float 1.000000e+00, float* %arrayidx154, align 4
  ret void
}

; Function Attrs: nounwind
declare double @sqrt(double) #1

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
  %n = alloca i32, align 4
  %m = alloca i32, align 4
  %data = alloca float*, align 8
  %mean = alloca float*, align 8
  %stddev = alloca float*, align 8
  %symmat = alloca float*, align 8
  store i32 0, i32* %retval
  store i32 2048, i32* %n, align 4
  store i32 2048, i32* %m, align 4
  %call = call noalias i8* @malloc(i64 16777216) #3
  %0 = bitcast i8* %call to float*
  store float* %0, float** %data, align 8
  %call1 = call noalias i8* @malloc(i64 8192) #3
  %1 = bitcast i8* %call1 to float*
  store float* %1, float** %mean, align 8
  %call2 = call noalias i8* @malloc(i64 8192) #3
  %2 = bitcast i8* %call2 to float*
  store float* %2, float** %stddev, align 8
  %call3 = call noalias i8* @malloc(i64 16777216) #3
  %3 = bitcast i8* %call3 to float*
  store float* %3, float** %symmat, align 8
  %4 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %call4 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %4, i8* getelementptr inbounds ([31 x i8], [31 x i8]* @.str.2, i32 0, i32 0))
  %5 = load float*, float** %data, align 8
  call void @init_arrays(float* %5)
  %call5 = call double @rtclock()
  store double %call5, double* %t_start, align 8
  %6 = load i32, i32* %m, align 4
  %7 = load i32, i32* %n, align 4
  %8 = load float*, float** %data, align 8
  %9 = load float*, float** %mean, align 8
  %10 = load float*, float** %stddev, align 8
  %11 = load float*, float** %symmat, align 8
  call void @correlation(i32 %6, i32 %7, float* %8, float* %9, float* %10, float* %11)
  %call6 = call double @rtclock()
  store double %call6, double* %t_end, align 8
  %12 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %13 = load double, double* %t_end, align 8
  %14 = load double, double* %t_start, align 8
  %sub = fsub double %13, %14
  %call7 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %12, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.3, i32 0, i32 0), double %sub)
  %15 = load float*, float** %data, align 8
  %16 = bitcast float* %15 to i8*
  call void @free(i8* %16) #3
  %17 = load float*, float** %mean, align 8
  %18 = bitcast float* %17 to i8*
  call void @free(i8* %18) #3
  %19 = load float*, float** %stddev, align 8
  %20 = bitcast float* %19 to i8*
  call void @free(i8* %20) #3
  %21 = load float*, float** %symmat, align 8
  %22 = bitcast float* %21 to i8*
  call void @free(i8* %22) #3
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
