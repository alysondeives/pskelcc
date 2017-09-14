; ModuleID = 'conv3d.c'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, i8*, i8*, i8*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type { %struct._IO_marker*, %struct._IO_FILE*, i32 }
%struct.timezone = type { i32, i32 }
%struct.timeval = type { i64, i64 }

@.str = private unnamed_addr constant [35 x i8] c"Error return from gettimeofday: %d\00", align 1
@.str.1 = private unnamed_addr constant [74 x i8] c"Non-Matching CPU-GPU Outputs Beyond Error Threshold of %4.2f Percent: %d\0A\00", align 1
@stdout = external global %struct._IO_FILE*, align 8
@.str.2 = private unnamed_addr constant [42 x i8] c">> Three dimensional (3D) convolution <<\0A\00", align 1
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
define void @conv3d(i32 %x, i32 %y, i32 %z, float* %A, float* %B) #0 {
entry:
  %x.addr = alloca i32, align 4
  %y.addr = alloca i32, align 4
  %z.addr = alloca i32, align 4
  %A.addr = alloca float*, align 8
  %B.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %k = alloca i32, align 4
  %c11 = alloca float, align 4
  %c12 = alloca float, align 4
  %c13 = alloca float, align 4
  %c21 = alloca float, align 4
  %c22 = alloca float, align 4
  %c23 = alloca float, align 4
  %c31 = alloca float, align 4
  %c32 = alloca float, align 4
  %c33 = alloca float, align 4
  store i32 %x, i32* %x.addr, align 4
  store i32 %y, i32* %y.addr, align 4
  store i32 %z, i32* %z.addr, align 4
  store float* %A, float** %A.addr, align 8
  store float* %B, float** %B.addr, align 8
  store float 0x4000FCD360000000, float* %c11, align 4
  store float 5.000000e+00, float* %c21, align 4
  store float -8.000000e+00, float* %c31, align 4
  store float -3.000000e+00, float* %c12, align 4
  store float 6.000000e+00, float* %c22, align 4
  store float -9.000000e+00, float* %c32, align 4
  store float 4.000000e+00, float* %c13, align 4
  store float 7.000000e+00, float* %c23, align 4
  store float 1.000000e+01, float* %c33, align 4
  store i32 1, i32* %j, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.311, %entry
  %0 = load i32, i32* %j, align 4
  %1 = load i32, i32* %y.addr, align 4
  %sub = sub nsw i32 %1, 1
  %cmp = icmp slt i32 %0, %sub
  br i1 %cmp, label %for.body, label %for.end.313

for.body:                                         ; preds = %for.cond
  store i32 1, i32* %i, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc.308, %for.body
  %2 = load i32, i32* %i, align 4
  %3 = load i32, i32* %x.addr, align 4
  %sub2 = sub nsw i32 %3, 1
  %cmp3 = icmp slt i32 %2, %sub2
  br i1 %cmp3, label %for.body.4, label %for.end.310

for.body.4:                                       ; preds = %for.cond.1
  store i32 1, i32* %k, align 4
  br label %for.cond.5

for.cond.5:                                       ; preds = %for.inc, %for.body.4
  %4 = load i32, i32* %k, align 4
  %5 = load i32, i32* %z.addr, align 4
  %sub6 = sub nsw i32 %5, 1
  %cmp7 = icmp slt i32 %4, %sub6
  br i1 %cmp7, label %for.body.8, label %for.end

for.body.8:                                       ; preds = %for.cond.5
  %6 = load float, float* %c11, align 4
  %7 = load i32, i32* %i, align 4
  %sub9 = sub nsw i32 %7, 1
  %8 = load i32, i32* %z.addr, align 4
  %9 = load i32, i32* %y.addr, align 4
  %mul = mul nsw i32 %8, %9
  %mul10 = mul nsw i32 %sub9, %mul
  %10 = load i32, i32* %j, align 4
  %sub11 = sub nsw i32 %10, 1
  %11 = load i32, i32* %z.addr, align 4
  %mul12 = mul nsw i32 %sub11, %11
  %add = add nsw i32 %mul10, %mul12
  %12 = load i32, i32* %k, align 4
  %sub13 = sub nsw i32 %12, 1
  %add14 = add nsw i32 %add, %sub13
  %idxprom = sext i32 %add14 to i64
  %13 = load float*, float** %A.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %13, i64 %idxprom
  %14 = load float, float* %arrayidx, align 4
  %mul15 = fmul float %6, %14
  %15 = load float, float* %c13, align 4
  %16 = load i32, i32* %i, align 4
  %17 = load i32, i32* %z.addr, align 4
  %18 = load i32, i32* %y.addr, align 4
  %mul16 = mul nsw i32 %17, %18
  %mul17 = mul nsw i32 %16, %mul16
  %19 = load i32, i32* %j, align 4
  %sub18 = sub nsw i32 %19, 1
  %20 = load i32, i32* %z.addr, align 4
  %mul19 = mul nsw i32 %sub18, %20
  %add20 = add nsw i32 %mul17, %mul19
  %21 = load i32, i32* %k, align 4
  %sub21 = sub nsw i32 %21, 1
  %add22 = add nsw i32 %add20, %sub21
  %idxprom23 = sext i32 %add22 to i64
  %22 = load float*, float** %A.addr, align 8
  %arrayidx24 = getelementptr inbounds float, float* %22, i64 %idxprom23
  %23 = load float, float* %arrayidx24, align 4
  %mul25 = fmul float %15, %23
  %add26 = fadd float %mul15, %mul25
  %24 = load float, float* %c21, align 4
  %25 = load i32, i32* %i, align 4
  %add27 = add nsw i32 %25, 1
  %26 = load i32, i32* %z.addr, align 4
  %27 = load i32, i32* %y.addr, align 4
  %mul28 = mul nsw i32 %26, %27
  %mul29 = mul nsw i32 %add27, %mul28
  %28 = load i32, i32* %j, align 4
  %sub30 = sub nsw i32 %28, 1
  %29 = load i32, i32* %z.addr, align 4
  %mul31 = mul nsw i32 %sub30, %29
  %add32 = add nsw i32 %mul29, %mul31
  %30 = load i32, i32* %k, align 4
  %sub33 = sub nsw i32 %30, 1
  %add34 = add nsw i32 %add32, %sub33
  %idxprom35 = sext i32 %add34 to i64
  %31 = load float*, float** %A.addr, align 8
  %arrayidx36 = getelementptr inbounds float, float* %31, i64 %idxprom35
  %32 = load float, float* %arrayidx36, align 4
  %mul37 = fmul float %24, %32
  %add38 = fadd float %add26, %mul37
  %33 = load float, float* %c11, align 4
  %34 = load i32, i32* %i, align 4
  %sub39 = sub nsw i32 %34, 1
  %35 = load i32, i32* %z.addr, align 4
  %36 = load i32, i32* %y.addr, align 4
  %mul40 = mul nsw i32 %35, %36
  %mul41 = mul nsw i32 %sub39, %mul40
  %37 = load i32, i32* %j, align 4
  %sub42 = sub nsw i32 %37, 1
  %38 = load i32, i32* %z.addr, align 4
  %mul43 = mul nsw i32 %sub42, %38
  %add44 = add nsw i32 %mul41, %mul43
  %39 = load i32, i32* %k, align 4
  %add45 = add nsw i32 %add44, %39
  %idxprom46 = sext i32 %add45 to i64
  %40 = load float*, float** %A.addr, align 8
  %arrayidx47 = getelementptr inbounds float, float* %40, i64 %idxprom46
  %41 = load float, float* %arrayidx47, align 4
  %mul48 = fmul float %33, %41
  %add49 = fadd float %add38, %mul48
  %42 = load float, float* %c13, align 4
  %43 = load i32, i32* %i, align 4
  %44 = load i32, i32* %z.addr, align 4
  %45 = load i32, i32* %y.addr, align 4
  %mul50 = mul nsw i32 %44, %45
  %mul51 = mul nsw i32 %43, %mul50
  %46 = load i32, i32* %j, align 4
  %sub52 = sub nsw i32 %46, 1
  %47 = load i32, i32* %z.addr, align 4
  %mul53 = mul nsw i32 %sub52, %47
  %add54 = add nsw i32 %mul51, %mul53
  %48 = load i32, i32* %k, align 4
  %add55 = add nsw i32 %add54, %48
  %idxprom56 = sext i32 %add55 to i64
  %49 = load float*, float** %A.addr, align 8
  %arrayidx57 = getelementptr inbounds float, float* %49, i64 %idxprom56
  %50 = load float, float* %arrayidx57, align 4
  %mul58 = fmul float %42, %50
  %add59 = fadd float %add49, %mul58
  %51 = load float, float* %c21, align 4
  %52 = load i32, i32* %i, align 4
  %add60 = add nsw i32 %52, 1
  %53 = load i32, i32* %z.addr, align 4
  %54 = load i32, i32* %y.addr, align 4
  %mul61 = mul nsw i32 %53, %54
  %mul62 = mul nsw i32 %add60, %mul61
  %55 = load i32, i32* %j, align 4
  %sub63 = sub nsw i32 %55, 1
  %56 = load i32, i32* %z.addr, align 4
  %mul64 = mul nsw i32 %sub63, %56
  %add65 = add nsw i32 %mul62, %mul64
  %57 = load i32, i32* %k, align 4
  %add66 = add nsw i32 %add65, %57
  %idxprom67 = sext i32 %add66 to i64
  %58 = load float*, float** %A.addr, align 8
  %arrayidx68 = getelementptr inbounds float, float* %58, i64 %idxprom67
  %59 = load float, float* %arrayidx68, align 4
  %mul69 = fmul float %51, %59
  %add70 = fadd float %add59, %mul69
  %60 = load float, float* %c11, align 4
  %61 = load i32, i32* %i, align 4
  %sub71 = sub nsw i32 %61, 1
  %62 = load i32, i32* %z.addr, align 4
  %63 = load i32, i32* %y.addr, align 4
  %mul72 = mul nsw i32 %62, %63
  %mul73 = mul nsw i32 %sub71, %mul72
  %64 = load i32, i32* %j, align 4
  %sub74 = sub nsw i32 %64, 1
  %65 = load i32, i32* %z.addr, align 4
  %mul75 = mul nsw i32 %sub74, %65
  %add76 = add nsw i32 %mul73, %mul75
  %66 = load i32, i32* %k, align 4
  %add77 = add nsw i32 %66, 1
  %add78 = add nsw i32 %add76, %add77
  %idxprom79 = sext i32 %add78 to i64
  %67 = load float*, float** %A.addr, align 8
  %arrayidx80 = getelementptr inbounds float, float* %67, i64 %idxprom79
  %68 = load float, float* %arrayidx80, align 4
  %mul81 = fmul float %60, %68
  %add82 = fadd float %add70, %mul81
  %69 = load float, float* %c13, align 4
  %70 = load i32, i32* %i, align 4
  %71 = load i32, i32* %z.addr, align 4
  %72 = load i32, i32* %y.addr, align 4
  %mul83 = mul nsw i32 %71, %72
  %mul84 = mul nsw i32 %70, %mul83
  %73 = load i32, i32* %j, align 4
  %sub85 = sub nsw i32 %73, 1
  %74 = load i32, i32* %z.addr, align 4
  %mul86 = mul nsw i32 %sub85, %74
  %add87 = add nsw i32 %mul84, %mul86
  %75 = load i32, i32* %k, align 4
  %add88 = add nsw i32 %75, 1
  %add89 = add nsw i32 %add87, %add88
  %idxprom90 = sext i32 %add89 to i64
  %76 = load float*, float** %A.addr, align 8
  %arrayidx91 = getelementptr inbounds float, float* %76, i64 %idxprom90
  %77 = load float, float* %arrayidx91, align 4
  %mul92 = fmul float %69, %77
  %add93 = fadd float %add82, %mul92
  %78 = load float, float* %c21, align 4
  %79 = load i32, i32* %i, align 4
  %add94 = add nsw i32 %79, 1
  %80 = load i32, i32* %z.addr, align 4
  %81 = load i32, i32* %y.addr, align 4
  %mul95 = mul nsw i32 %80, %81
  %mul96 = mul nsw i32 %add94, %mul95
  %82 = load i32, i32* %j, align 4
  %sub97 = sub nsw i32 %82, 1
  %83 = load i32, i32* %z.addr, align 4
  %mul98 = mul nsw i32 %sub97, %83
  %add99 = add nsw i32 %mul96, %mul98
  %84 = load i32, i32* %k, align 4
  %add100 = add nsw i32 %84, 1
  %add101 = add nsw i32 %add99, %add100
  %idxprom102 = sext i32 %add101 to i64
  %85 = load float*, float** %A.addr, align 8
  %arrayidx103 = getelementptr inbounds float, float* %85, i64 %idxprom102
  %86 = load float, float* %arrayidx103, align 4
  %mul104 = fmul float %78, %86
  %add105 = fadd float %add93, %mul104
  %87 = load float, float* %c11, align 4
  %88 = load i32, i32* %i, align 4
  %sub106 = sub nsw i32 %88, 1
  %89 = load i32, i32* %z.addr, align 4
  %90 = load i32, i32* %y.addr, align 4
  %mul107 = mul nsw i32 %89, %90
  %mul108 = mul nsw i32 %sub106, %mul107
  %91 = load i32, i32* %j, align 4
  %92 = load i32, i32* %z.addr, align 4
  %mul109 = mul nsw i32 %91, %92
  %add110 = add nsw i32 %mul108, %mul109
  %93 = load i32, i32* %k, align 4
  %sub111 = sub nsw i32 %93, 1
  %add112 = add nsw i32 %add110, %sub111
  %idxprom113 = sext i32 %add112 to i64
  %94 = load float*, float** %A.addr, align 8
  %arrayidx114 = getelementptr inbounds float, float* %94, i64 %idxprom113
  %95 = load float, float* %arrayidx114, align 4
  %mul115 = fmul float %87, %95
  %add116 = fadd float %add105, %mul115
  %96 = load float, float* %c13, align 4
  %97 = load i32, i32* %i, align 4
  %98 = load i32, i32* %z.addr, align 4
  %99 = load i32, i32* %y.addr, align 4
  %mul117 = mul nsw i32 %98, %99
  %mul118 = mul nsw i32 %97, %mul117
  %100 = load i32, i32* %j, align 4
  %101 = load i32, i32* %z.addr, align 4
  %mul119 = mul nsw i32 %100, %101
  %add120 = add nsw i32 %mul118, %mul119
  %102 = load i32, i32* %k, align 4
  %sub121 = sub nsw i32 %102, 1
  %add122 = add nsw i32 %add120, %sub121
  %idxprom123 = sext i32 %add122 to i64
  %103 = load float*, float** %A.addr, align 8
  %arrayidx124 = getelementptr inbounds float, float* %103, i64 %idxprom123
  %104 = load float, float* %arrayidx124, align 4
  %mul125 = fmul float %96, %104
  %add126 = fadd float %add116, %mul125
  %105 = load float, float* %c21, align 4
  %106 = load i32, i32* %i, align 4
  %add127 = add nsw i32 %106, 1
  %107 = load i32, i32* %z.addr, align 4
  %108 = load i32, i32* %y.addr, align 4
  %mul128 = mul nsw i32 %107, %108
  %mul129 = mul nsw i32 %add127, %mul128
  %109 = load i32, i32* %j, align 4
  %110 = load i32, i32* %z.addr, align 4
  %mul130 = mul nsw i32 %109, %110
  %add131 = add nsw i32 %mul129, %mul130
  %111 = load i32, i32* %k, align 4
  %sub132 = sub nsw i32 %111, 1
  %add133 = add nsw i32 %add131, %sub132
  %idxprom134 = sext i32 %add133 to i64
  %112 = load float*, float** %A.addr, align 8
  %arrayidx135 = getelementptr inbounds float, float* %112, i64 %idxprom134
  %113 = load float, float* %arrayidx135, align 4
  %mul136 = fmul float %105, %113
  %add137 = fadd float %add126, %mul136
  %114 = load float, float* %c11, align 4
  %115 = load i32, i32* %i, align 4
  %sub138 = sub nsw i32 %115, 1
  %116 = load i32, i32* %z.addr, align 4
  %117 = load i32, i32* %y.addr, align 4
  %mul139 = mul nsw i32 %116, %117
  %mul140 = mul nsw i32 %sub138, %mul139
  %118 = load i32, i32* %j, align 4
  %119 = load i32, i32* %z.addr, align 4
  %mul141 = mul nsw i32 %118, %119
  %add142 = add nsw i32 %mul140, %mul141
  %120 = load i32, i32* %k, align 4
  %add143 = add nsw i32 %add142, %120
  %idxprom144 = sext i32 %add143 to i64
  %121 = load float*, float** %A.addr, align 8
  %arrayidx145 = getelementptr inbounds float, float* %121, i64 %idxprom144
  %122 = load float, float* %arrayidx145, align 4
  %mul146 = fmul float %114, %122
  %add147 = fadd float %add137, %mul146
  %123 = load float, float* %c13, align 4
  %124 = load i32, i32* %i, align 4
  %125 = load i32, i32* %z.addr, align 4
  %126 = load i32, i32* %y.addr, align 4
  %mul148 = mul nsw i32 %125, %126
  %mul149 = mul nsw i32 %124, %mul148
  %127 = load i32, i32* %j, align 4
  %128 = load i32, i32* %z.addr, align 4
  %mul150 = mul nsw i32 %127, %128
  %add151 = add nsw i32 %mul149, %mul150
  %129 = load i32, i32* %k, align 4
  %add152 = add nsw i32 %add151, %129
  %idxprom153 = sext i32 %add152 to i64
  %130 = load float*, float** %A.addr, align 8
  %arrayidx154 = getelementptr inbounds float, float* %130, i64 %idxprom153
  %131 = load float, float* %arrayidx154, align 4
  %mul155 = fmul float %123, %131
  %add156 = fadd float %add147, %mul155
  %132 = load float, float* %c21, align 4
  %133 = load i32, i32* %i, align 4
  %add157 = add nsw i32 %133, 1
  %134 = load i32, i32* %z.addr, align 4
  %135 = load i32, i32* %y.addr, align 4
  %mul158 = mul nsw i32 %134, %135
  %mul159 = mul nsw i32 %add157, %mul158
  %136 = load i32, i32* %j, align 4
  %137 = load i32, i32* %z.addr, align 4
  %mul160 = mul nsw i32 %136, %137
  %add161 = add nsw i32 %mul159, %mul160
  %138 = load i32, i32* %k, align 4
  %add162 = add nsw i32 %add161, %138
  %idxprom163 = sext i32 %add162 to i64
  %139 = load float*, float** %A.addr, align 8
  %arrayidx164 = getelementptr inbounds float, float* %139, i64 %idxprom163
  %140 = load float, float* %arrayidx164, align 4
  %mul165 = fmul float %132, %140
  %add166 = fadd float %add156, %mul165
  %141 = load float, float* %c11, align 4
  %142 = load i32, i32* %i, align 4
  %sub167 = sub nsw i32 %142, 1
  %143 = load i32, i32* %z.addr, align 4
  %144 = load i32, i32* %y.addr, align 4
  %mul168 = mul nsw i32 %143, %144
  %mul169 = mul nsw i32 %sub167, %mul168
  %145 = load i32, i32* %j, align 4
  %146 = load i32, i32* %z.addr, align 4
  %mul170 = mul nsw i32 %145, %146
  %add171 = add nsw i32 %mul169, %mul170
  %147 = load i32, i32* %k, align 4
  %add172 = add nsw i32 %147, 1
  %add173 = add nsw i32 %add171, %add172
  %idxprom174 = sext i32 %add173 to i64
  %148 = load float*, float** %A.addr, align 8
  %arrayidx175 = getelementptr inbounds float, float* %148, i64 %idxprom174
  %149 = load float, float* %arrayidx175, align 4
  %mul176 = fmul float %141, %149
  %add177 = fadd float %add166, %mul176
  %150 = load float, float* %c13, align 4
  %151 = load i32, i32* %i, align 4
  %152 = load i32, i32* %z.addr, align 4
  %153 = load i32, i32* %y.addr, align 4
  %mul178 = mul nsw i32 %152, %153
  %mul179 = mul nsw i32 %151, %mul178
  %154 = load i32, i32* %j, align 4
  %155 = load i32, i32* %z.addr, align 4
  %mul180 = mul nsw i32 %154, %155
  %add181 = add nsw i32 %mul179, %mul180
  %156 = load i32, i32* %k, align 4
  %add182 = add nsw i32 %156, 1
  %add183 = add nsw i32 %add181, %add182
  %idxprom184 = sext i32 %add183 to i64
  %157 = load float*, float** %A.addr, align 8
  %arrayidx185 = getelementptr inbounds float, float* %157, i64 %idxprom184
  %158 = load float, float* %arrayidx185, align 4
  %mul186 = fmul float %150, %158
  %add187 = fadd float %add177, %mul186
  %159 = load float, float* %c21, align 4
  %160 = load i32, i32* %i, align 4
  %add188 = add nsw i32 %160, 1
  %161 = load i32, i32* %z.addr, align 4
  %162 = load i32, i32* %y.addr, align 4
  %mul189 = mul nsw i32 %161, %162
  %mul190 = mul nsw i32 %add188, %mul189
  %163 = load i32, i32* %j, align 4
  %164 = load i32, i32* %z.addr, align 4
  %mul191 = mul nsw i32 %163, %164
  %add192 = add nsw i32 %mul190, %mul191
  %165 = load i32, i32* %k, align 4
  %add193 = add nsw i32 %165, 1
  %add194 = add nsw i32 %add192, %add193
  %idxprom195 = sext i32 %add194 to i64
  %166 = load float*, float** %A.addr, align 8
  %arrayidx196 = getelementptr inbounds float, float* %166, i64 %idxprom195
  %167 = load float, float* %arrayidx196, align 4
  %mul197 = fmul float %159, %167
  %add198 = fadd float %add187, %mul197
  %168 = load float, float* %c11, align 4
  %169 = load i32, i32* %i, align 4
  %sub199 = sub nsw i32 %169, 1
  %170 = load i32, i32* %z.addr, align 4
  %171 = load i32, i32* %y.addr, align 4
  %mul200 = mul nsw i32 %170, %171
  %mul201 = mul nsw i32 %sub199, %mul200
  %172 = load i32, i32* %j, align 4
  %add202 = add nsw i32 %172, 1
  %173 = load i32, i32* %z.addr, align 4
  %mul203 = mul nsw i32 %add202, %173
  %add204 = add nsw i32 %mul201, %mul203
  %174 = load i32, i32* %k, align 4
  %sub205 = sub nsw i32 %174, 1
  %add206 = add nsw i32 %add204, %sub205
  %idxprom207 = sext i32 %add206 to i64
  %175 = load float*, float** %A.addr, align 8
  %arrayidx208 = getelementptr inbounds float, float* %175, i64 %idxprom207
  %176 = load float, float* %arrayidx208, align 4
  %mul209 = fmul float %168, %176
  %add210 = fadd float %add198, %mul209
  %177 = load float, float* %c13, align 4
  %178 = load i32, i32* %i, align 4
  %179 = load i32, i32* %z.addr, align 4
  %180 = load i32, i32* %y.addr, align 4
  %mul211 = mul nsw i32 %179, %180
  %mul212 = mul nsw i32 %178, %mul211
  %181 = load i32, i32* %j, align 4
  %add213 = add nsw i32 %181, 1
  %182 = load i32, i32* %z.addr, align 4
  %mul214 = mul nsw i32 %add213, %182
  %add215 = add nsw i32 %mul212, %mul214
  %183 = load i32, i32* %k, align 4
  %sub216 = sub nsw i32 %183, 1
  %add217 = add nsw i32 %add215, %sub216
  %idxprom218 = sext i32 %add217 to i64
  %184 = load float*, float** %A.addr, align 8
  %arrayidx219 = getelementptr inbounds float, float* %184, i64 %idxprom218
  %185 = load float, float* %arrayidx219, align 4
  %mul220 = fmul float %177, %185
  %add221 = fadd float %add210, %mul220
  %186 = load float, float* %c21, align 4
  %187 = load i32, i32* %i, align 4
  %add222 = add nsw i32 %187, 1
  %188 = load i32, i32* %z.addr, align 4
  %189 = load i32, i32* %y.addr, align 4
  %mul223 = mul nsw i32 %188, %189
  %mul224 = mul nsw i32 %add222, %mul223
  %190 = load i32, i32* %j, align 4
  %add225 = add nsw i32 %190, 1
  %191 = load i32, i32* %z.addr, align 4
  %mul226 = mul nsw i32 %add225, %191
  %add227 = add nsw i32 %mul224, %mul226
  %192 = load i32, i32* %k, align 4
  %sub228 = sub nsw i32 %192, 1
  %add229 = add nsw i32 %add227, %sub228
  %idxprom230 = sext i32 %add229 to i64
  %193 = load float*, float** %A.addr, align 8
  %arrayidx231 = getelementptr inbounds float, float* %193, i64 %idxprom230
  %194 = load float, float* %arrayidx231, align 4
  %mul232 = fmul float %186, %194
  %add233 = fadd float %add221, %mul232
  %195 = load float, float* %c11, align 4
  %196 = load i32, i32* %i, align 4
  %sub234 = sub nsw i32 %196, 1
  %197 = load i32, i32* %z.addr, align 4
  %198 = load i32, i32* %y.addr, align 4
  %mul235 = mul nsw i32 %197, %198
  %mul236 = mul nsw i32 %sub234, %mul235
  %199 = load i32, i32* %j, align 4
  %add237 = add nsw i32 %199, 1
  %200 = load i32, i32* %z.addr, align 4
  %mul238 = mul nsw i32 %add237, %200
  %add239 = add nsw i32 %mul236, %mul238
  %201 = load i32, i32* %k, align 4
  %add240 = add nsw i32 %add239, %201
  %idxprom241 = sext i32 %add240 to i64
  %202 = load float*, float** %A.addr, align 8
  %arrayidx242 = getelementptr inbounds float, float* %202, i64 %idxprom241
  %203 = load float, float* %arrayidx242, align 4
  %mul243 = fmul float %195, %203
  %add244 = fadd float %add233, %mul243
  %204 = load float, float* %c13, align 4
  %205 = load i32, i32* %i, align 4
  %206 = load i32, i32* %z.addr, align 4
  %207 = load i32, i32* %y.addr, align 4
  %mul245 = mul nsw i32 %206, %207
  %mul246 = mul nsw i32 %205, %mul245
  %208 = load i32, i32* %j, align 4
  %add247 = add nsw i32 %208, 1
  %209 = load i32, i32* %z.addr, align 4
  %mul248 = mul nsw i32 %add247, %209
  %add249 = add nsw i32 %mul246, %mul248
  %210 = load i32, i32* %k, align 4
  %add250 = add nsw i32 %add249, %210
  %idxprom251 = sext i32 %add250 to i64
  %211 = load float*, float** %A.addr, align 8
  %arrayidx252 = getelementptr inbounds float, float* %211, i64 %idxprom251
  %212 = load float, float* %arrayidx252, align 4
  %mul253 = fmul float %204, %212
  %add254 = fadd float %add244, %mul253
  %213 = load float, float* %c21, align 4
  %214 = load i32, i32* %i, align 4
  %add255 = add nsw i32 %214, 1
  %215 = load i32, i32* %z.addr, align 4
  %216 = load i32, i32* %y.addr, align 4
  %mul256 = mul nsw i32 %215, %216
  %mul257 = mul nsw i32 %add255, %mul256
  %217 = load i32, i32* %j, align 4
  %add258 = add nsw i32 %217, 1
  %218 = load i32, i32* %z.addr, align 4
  %mul259 = mul nsw i32 %add258, %218
  %add260 = add nsw i32 %mul257, %mul259
  %219 = load i32, i32* %k, align 4
  %add261 = add nsw i32 %add260, %219
  %idxprom262 = sext i32 %add261 to i64
  %220 = load float*, float** %A.addr, align 8
  %arrayidx263 = getelementptr inbounds float, float* %220, i64 %idxprom262
  %221 = load float, float* %arrayidx263, align 4
  %mul264 = fmul float %213, %221
  %add265 = fadd float %add254, %mul264
  %222 = load float, float* %c11, align 4
  %223 = load i32, i32* %i, align 4
  %sub266 = sub nsw i32 %223, 1
  %224 = load i32, i32* %z.addr, align 4
  %225 = load i32, i32* %y.addr, align 4
  %mul267 = mul nsw i32 %224, %225
  %mul268 = mul nsw i32 %sub266, %mul267
  %226 = load i32, i32* %j, align 4
  %add269 = add nsw i32 %226, 1
  %227 = load i32, i32* %z.addr, align 4
  %mul270 = mul nsw i32 %add269, %227
  %add271 = add nsw i32 %mul268, %mul270
  %228 = load i32, i32* %k, align 4
  %add272 = add nsw i32 %228, 1
  %add273 = add nsw i32 %add271, %add272
  %idxprom274 = sext i32 %add273 to i64
  %229 = load float*, float** %A.addr, align 8
  %arrayidx275 = getelementptr inbounds float, float* %229, i64 %idxprom274
  %230 = load float, float* %arrayidx275, align 4
  %mul276 = fmul float %222, %230
  %add277 = fadd float %add265, %mul276
  %231 = load float, float* %c13, align 4
  %232 = load i32, i32* %i, align 4
  %233 = load i32, i32* %z.addr, align 4
  %234 = load i32, i32* %y.addr, align 4
  %mul278 = mul nsw i32 %233, %234
  %mul279 = mul nsw i32 %232, %mul278
  %235 = load i32, i32* %j, align 4
  %add280 = add nsw i32 %235, 1
  %236 = load i32, i32* %z.addr, align 4
  %mul281 = mul nsw i32 %add280, %236
  %add282 = add nsw i32 %mul279, %mul281
  %237 = load i32, i32* %k, align 4
  %add283 = add nsw i32 %237, 1
  %add284 = add nsw i32 %add282, %add283
  %idxprom285 = sext i32 %add284 to i64
  %238 = load float*, float** %A.addr, align 8
  %arrayidx286 = getelementptr inbounds float, float* %238, i64 %idxprom285
  %239 = load float, float* %arrayidx286, align 4
  %mul287 = fmul float %231, %239
  %add288 = fadd float %add277, %mul287
  %240 = load float, float* %c21, align 4
  %241 = load i32, i32* %i, align 4
  %add289 = add nsw i32 %241, 1
  %242 = load i32, i32* %z.addr, align 4
  %243 = load i32, i32* %y.addr, align 4
  %mul290 = mul nsw i32 %242, %243
  %mul291 = mul nsw i32 %add289, %mul290
  %244 = load i32, i32* %j, align 4
  %add292 = add nsw i32 %244, 1
  %245 = load i32, i32* %z.addr, align 4
  %mul293 = mul nsw i32 %add292, %245
  %add294 = add nsw i32 %mul291, %mul293
  %246 = load i32, i32* %k, align 4
  %add295 = add nsw i32 %246, 1
  %add296 = add nsw i32 %add294, %add295
  %idxprom297 = sext i32 %add296 to i64
  %247 = load float*, float** %A.addr, align 8
  %arrayidx298 = getelementptr inbounds float, float* %247, i64 %idxprom297
  %248 = load float, float* %arrayidx298, align 4
  %mul299 = fmul float %240, %248
  %add300 = fadd float %add288, %mul299
  %249 = load i32, i32* %i, align 4
  %250 = load i32, i32* %z.addr, align 4
  %251 = load i32, i32* %y.addr, align 4
  %mul301 = mul nsw i32 %250, %251
  %mul302 = mul nsw i32 %249, %mul301
  %252 = load i32, i32* %j, align 4
  %253 = load i32, i32* %z.addr, align 4
  %mul303 = mul nsw i32 %252, %253
  %add304 = add nsw i32 %mul302, %mul303
  %254 = load i32, i32* %k, align 4
  %add305 = add nsw i32 %add304, %254
  %idxprom306 = sext i32 %add305 to i64
  %255 = load float*, float** %B.addr, align 8
  %arrayidx307 = getelementptr inbounds float, float* %255, i64 %idxprom306
  store float %add300, float* %arrayidx307, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.8
  %256 = load i32, i32* %k, align 4
  %inc = add nsw i32 %256, 1
  store i32 %inc, i32* %k, align 4
  br label %for.cond.5

for.end:                                          ; preds = %for.cond.5
  br label %for.inc.308

for.inc.308:                                      ; preds = %for.end
  %257 = load i32, i32* %i, align 4
  %inc309 = add nsw i32 %257, 1
  store i32 %inc309, i32* %i, align 4
  br label %for.cond.1

for.end.310:                                      ; preds = %for.cond.1
  br label %for.inc.311

for.inc.311:                                      ; preds = %for.end.310
  %258 = load i32, i32* %j, align 4
  %inc312 = add nsw i32 %258, 1
  store i32 %inc312, i32* %j, align 4
  br label %for.cond

for.end.313:                                      ; preds = %for.cond
  ret void
}

; Function Attrs: nounwind uwtable
define void @init(float* %A) #0 {
entry:
  %A.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %k = alloca i32, align 4
  store float* %A, float** %A.addr, align 8
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.18, %entry
  %0 = load i32, i32* %i, align 4
  %cmp = icmp slt i32 %0, 256
  br i1 %cmp, label %for.body, label %for.end.20

for.body:                                         ; preds = %for.cond
  store i32 0, i32* %j, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc.15, %for.body
  %1 = load i32, i32* %j, align 4
  %cmp2 = icmp slt i32 %1, 246
  br i1 %cmp2, label %for.body.3, label %for.end.17

for.body.3:                                       ; preds = %for.cond.1
  store i32 0, i32* %k, align 4
  br label %for.cond.4

for.cond.4:                                       ; preds = %for.inc, %for.body.3
  %2 = load i32, i32* %k, align 4
  %cmp5 = icmp slt i32 %2, 256
  br i1 %cmp5, label %for.body.6, label %for.end

for.body.6:                                       ; preds = %for.cond.4
  %3 = load i32, i32* %i, align 4
  %rem = srem i32 %3, 12
  %4 = load i32, i32* %j, align 4
  %rem7 = srem i32 %4, 7
  %mul = mul nsw i32 2, %rem7
  %add = add nsw i32 %rem, %mul
  %5 = load i32, i32* %k, align 4
  %rem8 = srem i32 %5, 13
  %mul9 = mul nsw i32 3, %rem8
  %add10 = add nsw i32 %add, %mul9
  %conv = sitofp i32 %add10 to float
  %6 = load i32, i32* %i, align 4
  %mul11 = mul nsw i32 %6, 62976
  %7 = load i32, i32* %j, align 4
  %mul12 = mul nsw i32 %7, 256
  %add13 = add nsw i32 %mul11, %mul12
  %8 = load i32, i32* %k, align 4
  %add14 = add nsw i32 %add13, %8
  %idxprom = sext i32 %add14 to i64
  %9 = load float*, float** %A.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %9, i64 %idxprom
  store float %conv, float* %arrayidx, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.6
  %10 = load i32, i32* %k, align 4
  %inc = add nsw i32 %10, 1
  store i32 %inc, i32* %k, align 4
  br label %for.cond.4

for.end:                                          ; preds = %for.cond.4
  br label %for.inc.15

for.inc.15:                                       ; preds = %for.end
  %11 = load i32, i32* %j, align 4
  %inc16 = add nsw i32 %11, 1
  store i32 %inc16, i32* %j, align 4
  br label %for.cond.1

for.end.17:                                       ; preds = %for.cond.1
  br label %for.inc.18

for.inc.18:                                       ; preds = %for.end.17
  %12 = load i32, i32* %i, align 4
  %inc19 = add nsw i32 %12, 1
  store i32 %inc19, i32* %i, align 4
  br label %for.cond

for.end.20:                                       ; preds = %for.cond
  ret void
}

; Function Attrs: nounwind uwtable
define void @compareResults(float* %B, float* %B_GPU) #0 {
entry:
  %B.addr = alloca float*, align 8
  %B_GPU.addr = alloca float*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %k = alloca i32, align 4
  %fail = alloca i32, align 4
  store float* %B, float** %B.addr, align 8
  store float* %B_GPU, float** %B_GPU.addr, align 8
  store i32 0, i32* %fail, align 4
  store i32 1, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc.23, %entry
  %0 = load i32, i32* %i, align 4
  %cmp = icmp slt i32 %0, 255
  br i1 %cmp, label %for.body, label %for.end.25

for.body:                                         ; preds = %for.cond
  store i32 1, i32* %j, align 4
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc.20, %for.body
  %1 = load i32, i32* %j, align 4
  %cmp2 = icmp slt i32 %1, 245
  br i1 %cmp2, label %for.body.3, label %for.end.22

for.body.3:                                       ; preds = %for.cond.1
  store i32 1, i32* %k, align 4
  br label %for.cond.4

for.cond.4:                                       ; preds = %for.inc, %for.body.3
  %2 = load i32, i32* %k, align 4
  %cmp5 = icmp slt i32 %2, 255
  br i1 %cmp5, label %for.body.6, label %for.end

for.body.6:                                       ; preds = %for.cond.4
  %3 = load i32, i32* %i, align 4
  %mul = mul nsw i32 %3, 62976
  %4 = load i32, i32* %j, align 4
  %mul7 = mul nsw i32 %4, 256
  %add = add nsw i32 %mul, %mul7
  %5 = load i32, i32* %k, align 4
  %add8 = add nsw i32 %add, %5
  %idxprom = sext i32 %add8 to i64
  %6 = load float*, float** %B.addr, align 8
  %arrayidx = getelementptr inbounds float, float* %6, i64 %idxprom
  %7 = load float, float* %arrayidx, align 4
  %conv = fpext float %7 to double
  %8 = load i32, i32* %i, align 4
  %mul9 = mul nsw i32 %8, 62976
  %9 = load i32, i32* %j, align 4
  %mul10 = mul nsw i32 %9, 256
  %add11 = add nsw i32 %mul9, %mul10
  %10 = load i32, i32* %k, align 4
  %add12 = add nsw i32 %add11, %10
  %idxprom13 = sext i32 %add12 to i64
  %11 = load float*, float** %B_GPU.addr, align 8
  %arrayidx14 = getelementptr inbounds float, float* %11, i64 %idxprom13
  %12 = load float, float* %arrayidx14, align 4
  %conv15 = fpext float %12 to double
  %call = call float @percentDiff(double %conv, double %conv15)
  %conv16 = fpext float %call to double
  %cmp17 = fcmp ogt double %conv16, 5.000000e-01
  br i1 %cmp17, label %if.then, label %if.end

if.then:                                          ; preds = %for.body.6
  %13 = load i32, i32* %fail, align 4
  %inc = add nsw i32 %13, 1
  store i32 %inc, i32* %fail, align 4
  br label %if.end

if.end:                                           ; preds = %if.then, %for.body.6
  br label %for.inc

for.inc:                                          ; preds = %if.end
  %14 = load i32, i32* %k, align 4
  %inc19 = add nsw i32 %14, 1
  store i32 %inc19, i32* %k, align 4
  br label %for.cond.4

for.end:                                          ; preds = %for.cond.4
  br label %for.inc.20

for.inc.20:                                       ; preds = %for.end
  %15 = load i32, i32* %j, align 4
  %inc21 = add nsw i32 %15, 1
  store i32 %inc21, i32* %j, align 4
  br label %for.cond.1

for.end.22:                                       ; preds = %for.cond.1
  br label %for.inc.23

for.inc.23:                                       ; preds = %for.end.22
  %16 = load i32, i32* %i, align 4
  %inc24 = add nsw i32 %16, 1
  store i32 %inc24, i32* %i, align 4
  br label %for.cond

for.end.25:                                       ; preds = %for.cond
  %17 = load i32, i32* %fail, align 4
  %call26 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([74 x i8], [74 x i8]* @.str.1, i32 0, i32 0), double 5.000000e-01, i32 %17)
  ret void
}

; Function Attrs: nounwind uwtable
define i32 @main(i32 %argc, i8** %argv) #0 {
entry:
  %retval = alloca i32, align 4
  %argc.addr = alloca i32, align 4
  %argv.addr = alloca i8**, align 8
  %x = alloca i32, align 4
  %y = alloca i32, align 4
  %z = alloca i32, align 4
  %t_start = alloca double, align 8
  %t_end = alloca double, align 8
  %A = alloca float*, align 8
  %B = alloca float*, align 8
  store i32 0, i32* %retval
  store i32 %argc, i32* %argc.addr, align 4
  store i8** %argv, i8*** %argv.addr, align 8
  store i32 256, i32* %x, align 4
  store i32 246, i32* %y, align 4
  store i32 256, i32* %z, align 4
  %call = call noalias i8* @malloc(i64 64487424) #3
  %0 = bitcast i8* %call to float*
  store float* %0, float** %A, align 8
  %call1 = call noalias i8* @malloc(i64 64487424) #3
  %1 = bitcast i8* %call1 to float*
  store float* %1, float** %B, align 8
  %2 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %call2 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %2, i8* getelementptr inbounds ([42 x i8], [42 x i8]* @.str.2, i32 0, i32 0))
  %3 = load float*, float** %A, align 8
  call void @init(float* %3)
  %call3 = call double @rtclock()
  store double %call3, double* %t_start, align 8
  %4 = load i32, i32* %x, align 4
  %5 = load i32, i32* %y, align 4
  %6 = load i32, i32* %z, align 4
  %7 = load float*, float** %A, align 8
  %8 = load float*, float** %B, align 8
  call void @conv3d(i32 %4, i32 %5, i32 %6, float* %7, float* %8)
  %call4 = call double @rtclock()
  store double %call4, double* %t_end, align 8
  %9 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %10 = load double, double* %t_end, align 8
  %11 = load double, double* %t_start, align 8
  %sub = fsub double %10, %11
  %call5 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %9, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.3, i32 0, i32 0), double %sub)
  %12 = load float*, float** %A, align 8
  %13 = bitcast float* %12 to i8*
  call void @free(i8* %13) #3
  %14 = load float*, float** %B, align 8
  %15 = bitcast float* %14 to i8*
  call void @free(i8* %15) #3
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
