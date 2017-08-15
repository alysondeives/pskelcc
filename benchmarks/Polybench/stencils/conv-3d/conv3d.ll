; ModuleID = 'conv3d-base.ll'
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
define void @conv3d(i32 %ni, i32 %nj, i32 %nk, float* %A, float* %B) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.311, %entry
  %j.0 = phi i32 [ 1, %entry ], [ %inc312, %for.inc.311 ]
  %sub = sub nsw i32 %nj, 1
  %cmp = icmp slt i32 %j.0, %sub
  br i1 %cmp, label %for.body, label %for.end.313

for.body:                                         ; preds = %for.cond
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc.308, %for.body
  %i.0 = phi i32 [ 1, %for.body ], [ %inc309, %for.inc.308 ]
  %sub2 = sub nsw i32 %ni, 1
  %cmp3 = icmp slt i32 %i.0, %sub2
  br i1 %cmp3, label %for.body.4, label %for.end.310

for.body.4:                                       ; preds = %for.cond.1
  br label %for.cond.5

for.cond.5:                                       ; preds = %for.inc, %for.body.4
  %k.0 = phi i32 [ 1, %for.body.4 ], [ %inc, %for.inc ]
  %sub6 = sub nsw i32 %nk, 1
  %cmp7 = icmp slt i32 %k.0, %sub6
  br i1 %cmp7, label %for.body.8, label %for.end

for.body.8:                                       ; preds = %for.cond.5
  %sub9 = sub nsw i32 %i.0, 1
  %mul = mul nsw i32 %nk, %nj
  %mul10 = mul nsw i32 %sub9, %mul
  %sub11 = sub nsw i32 %j.0, 1
  %mul12 = mul nsw i32 %sub11, %nk
  %add = add nsw i32 %mul10, %mul12
  %sub13 = sub nsw i32 %k.0, 1
  %add14 = add nsw i32 %add, %sub13
  %idxprom = sext i32 %add14 to i64
  %arrayidx = getelementptr inbounds float, float* %A, i64 %idxprom
  %tmp = load float, float* %arrayidx, align 4
  %mul15 = fmul float 0x4000FCD360000000, %tmp
  %mul16 = mul nsw i32 %nk, %nj
  %mul17 = mul nsw i32 %i.0, %mul16
  %sub18 = sub nsw i32 %j.0, 1
  %mul19 = mul nsw i32 %sub18, %nk
  %add20 = add nsw i32 %mul17, %mul19
  %sub21 = sub nsw i32 %k.0, 1
  %add22 = add nsw i32 %add20, %sub21
  %idxprom23 = sext i32 %add22 to i64
  %arrayidx24 = getelementptr inbounds float, float* %A, i64 %idxprom23
  %tmp1 = load float, float* %arrayidx24, align 4
  %mul25 = fmul float 4.000000e+00, %tmp1
  %add26 = fadd float %mul15, %mul25
  %add27 = add nsw i32 %i.0, 1
  %mul28 = mul nsw i32 %nk, %nj
  %mul29 = mul nsw i32 %add27, %mul28
  %sub30 = sub nsw i32 %j.0, 1
  %mul31 = mul nsw i32 %sub30, %nk
  %add32 = add nsw i32 %mul29, %mul31
  %sub33 = sub nsw i32 %k.0, 1
  %add34 = add nsw i32 %add32, %sub33
  %idxprom35 = sext i32 %add34 to i64
  %arrayidx36 = getelementptr inbounds float, float* %A, i64 %idxprom35
  %tmp2 = load float, float* %arrayidx36, align 4
  %mul37 = fmul float 5.000000e+00, %tmp2
  %add38 = fadd float %add26, %mul37
  %sub39 = sub nsw i32 %i.0, 1
  %mul40 = mul nsw i32 %nk, %nj
  %mul41 = mul nsw i32 %sub39, %mul40
  %sub42 = sub nsw i32 %j.0, 1
  %mul43 = mul nsw i32 %sub42, %nk
  %add44 = add nsw i32 %mul41, %mul43
  %add45 = add nsw i32 %add44, %k.0
  %idxprom46 = sext i32 %add45 to i64
  %arrayidx47 = getelementptr inbounds float, float* %A, i64 %idxprom46
  %tmp3 = load float, float* %arrayidx47, align 4
  %mul48 = fmul float 0x4000FCD360000000, %tmp3
  %add49 = fadd float %add38, %mul48
  %mul50 = mul nsw i32 %nk, %nj
  %mul51 = mul nsw i32 %i.0, %mul50
  %sub52 = sub nsw i32 %j.0, 1
  %mul53 = mul nsw i32 %sub52, %nk
  %add54 = add nsw i32 %mul51, %mul53
  %add55 = add nsw i32 %add54, %k.0
  %idxprom56 = sext i32 %add55 to i64
  %arrayidx57 = getelementptr inbounds float, float* %A, i64 %idxprom56
  %tmp4 = load float, float* %arrayidx57, align 4
  %mul58 = fmul float 4.000000e+00, %tmp4
  %add59 = fadd float %add49, %mul58
  %add60 = add nsw i32 %i.0, 1
  %mul61 = mul nsw i32 %nk, %nj
  %mul62 = mul nsw i32 %add60, %mul61
  %sub63 = sub nsw i32 %j.0, 1
  %mul64 = mul nsw i32 %sub63, %nk
  %add65 = add nsw i32 %mul62, %mul64
  %add66 = add nsw i32 %add65, %k.0
  %idxprom67 = sext i32 %add66 to i64
  %arrayidx68 = getelementptr inbounds float, float* %A, i64 %idxprom67
  %tmp5 = load float, float* %arrayidx68, align 4
  %mul69 = fmul float 5.000000e+00, %tmp5
  %add70 = fadd float %add59, %mul69
  %sub71 = sub nsw i32 %i.0, 1
  %mul72 = mul nsw i32 %nk, %nj
  %mul73 = mul nsw i32 %sub71, %mul72
  %sub74 = sub nsw i32 %j.0, 1
  %mul75 = mul nsw i32 %sub74, %nk
  %add76 = add nsw i32 %mul73, %mul75
  %add77 = add nsw i32 %k.0, 1
  %add78 = add nsw i32 %add76, %add77
  %idxprom79 = sext i32 %add78 to i64
  %arrayidx80 = getelementptr inbounds float, float* %A, i64 %idxprom79
  %tmp6 = load float, float* %arrayidx80, align 4
  %mul81 = fmul float 0x4000FCD360000000, %tmp6
  %add82 = fadd float %add70, %mul81
  %mul83 = mul nsw i32 %nk, %nj
  %mul84 = mul nsw i32 %i.0, %mul83
  %sub85 = sub nsw i32 %j.0, 1
  %mul86 = mul nsw i32 %sub85, %nk
  %add87 = add nsw i32 %mul84, %mul86
  %add88 = add nsw i32 %k.0, 1
  %add89 = add nsw i32 %add87, %add88
  %idxprom90 = sext i32 %add89 to i64
  %arrayidx91 = getelementptr inbounds float, float* %A, i64 %idxprom90
  %tmp7 = load float, float* %arrayidx91, align 4
  %mul92 = fmul float 4.000000e+00, %tmp7
  %add93 = fadd float %add82, %mul92
  %add94 = add nsw i32 %i.0, 1
  %mul95 = mul nsw i32 %nk, %nj
  %mul96 = mul nsw i32 %add94, %mul95
  %sub97 = sub nsw i32 %j.0, 1
  %mul98 = mul nsw i32 %sub97, %nk
  %add99 = add nsw i32 %mul96, %mul98
  %add100 = add nsw i32 %k.0, 1
  %add101 = add nsw i32 %add99, %add100
  %idxprom102 = sext i32 %add101 to i64
  %arrayidx103 = getelementptr inbounds float, float* %A, i64 %idxprom102
  %tmp8 = load float, float* %arrayidx103, align 4
  %mul104 = fmul float 5.000000e+00, %tmp8
  %add105 = fadd float %add93, %mul104
  %sub106 = sub nsw i32 %i.0, 1
  %mul107 = mul nsw i32 %nk, %nj
  %mul108 = mul nsw i32 %sub106, %mul107
  %mul109 = mul nsw i32 %j.0, %nk
  %add110 = add nsw i32 %mul108, %mul109
  %sub111 = sub nsw i32 %k.0, 1
  %add112 = add nsw i32 %add110, %sub111
  %idxprom113 = sext i32 %add112 to i64
  %arrayidx114 = getelementptr inbounds float, float* %A, i64 %idxprom113
  %tmp9 = load float, float* %arrayidx114, align 4
  %mul115 = fmul float 0x4000FCD360000000, %tmp9
  %add116 = fadd float %add105, %mul115
  %mul117 = mul nsw i32 %nk, %nj
  %mul118 = mul nsw i32 %i.0, %mul117
  %mul119 = mul nsw i32 %j.0, %nk
  %add120 = add nsw i32 %mul118, %mul119
  %sub121 = sub nsw i32 %k.0, 1
  %add122 = add nsw i32 %add120, %sub121
  %idxprom123 = sext i32 %add122 to i64
  %arrayidx124 = getelementptr inbounds float, float* %A, i64 %idxprom123
  %tmp10 = load float, float* %arrayidx124, align 4
  %mul125 = fmul float 4.000000e+00, %tmp10
  %add126 = fadd float %add116, %mul125
  %add127 = add nsw i32 %i.0, 1
  %mul128 = mul nsw i32 %nk, %nj
  %mul129 = mul nsw i32 %add127, %mul128
  %mul130 = mul nsw i32 %j.0, %nk
  %add131 = add nsw i32 %mul129, %mul130
  %sub132 = sub nsw i32 %k.0, 1
  %add133 = add nsw i32 %add131, %sub132
  %idxprom134 = sext i32 %add133 to i64
  %arrayidx135 = getelementptr inbounds float, float* %A, i64 %idxprom134
  %tmp11 = load float, float* %arrayidx135, align 4
  %mul136 = fmul float 5.000000e+00, %tmp11
  %add137 = fadd float %add126, %mul136
  %sub138 = sub nsw i32 %i.0, 1
  %mul139 = mul nsw i32 %nk, %nj
  %mul140 = mul nsw i32 %sub138, %mul139
  %mul141 = mul nsw i32 %j.0, %nk
  %add142 = add nsw i32 %mul140, %mul141
  %add143 = add nsw i32 %add142, %k.0
  %idxprom144 = sext i32 %add143 to i64
  %arrayidx145 = getelementptr inbounds float, float* %A, i64 %idxprom144
  %tmp12 = load float, float* %arrayidx145, align 4
  %mul146 = fmul float 0x4000FCD360000000, %tmp12
  %add147 = fadd float %add137, %mul146
  %mul148 = mul nsw i32 %nk, %nj
  %mul149 = mul nsw i32 %i.0, %mul148
  %mul150 = mul nsw i32 %j.0, %nk
  %add151 = add nsw i32 %mul149, %mul150
  %add152 = add nsw i32 %add151, %k.0
  %idxprom153 = sext i32 %add152 to i64
  %arrayidx154 = getelementptr inbounds float, float* %A, i64 %idxprom153
  %tmp13 = load float, float* %arrayidx154, align 4
  %mul155 = fmul float 4.000000e+00, %tmp13
  %add156 = fadd float %add147, %mul155
  %add157 = add nsw i32 %i.0, 1
  %mul158 = mul nsw i32 %nk, %nj
  %mul159 = mul nsw i32 %add157, %mul158
  %mul160 = mul nsw i32 %j.0, %nk
  %add161 = add nsw i32 %mul159, %mul160
  %add162 = add nsw i32 %add161, %k.0
  %idxprom163 = sext i32 %add162 to i64
  %arrayidx164 = getelementptr inbounds float, float* %A, i64 %idxprom163
  %tmp14 = load float, float* %arrayidx164, align 4
  %mul165 = fmul float 5.000000e+00, %tmp14
  %add166 = fadd float %add156, %mul165
  %sub167 = sub nsw i32 %i.0, 1
  %mul168 = mul nsw i32 %nk, %nj
  %mul169 = mul nsw i32 %sub167, %mul168
  %mul170 = mul nsw i32 %j.0, %nk
  %add171 = add nsw i32 %mul169, %mul170
  %add172 = add nsw i32 %k.0, 1
  %add173 = add nsw i32 %add171, %add172
  %idxprom174 = sext i32 %add173 to i64
  %arrayidx175 = getelementptr inbounds float, float* %A, i64 %idxprom174
  %tmp15 = load float, float* %arrayidx175, align 4
  %mul176 = fmul float 0x4000FCD360000000, %tmp15
  %add177 = fadd float %add166, %mul176
  %mul178 = mul nsw i32 %nk, %nj
  %mul179 = mul nsw i32 %i.0, %mul178
  %mul180 = mul nsw i32 %j.0, %nk
  %add181 = add nsw i32 %mul179, %mul180
  %add182 = add nsw i32 %k.0, 1
  %add183 = add nsw i32 %add181, %add182
  %idxprom184 = sext i32 %add183 to i64
  %arrayidx185 = getelementptr inbounds float, float* %A, i64 %idxprom184
  %tmp16 = load float, float* %arrayidx185, align 4
  %mul186 = fmul float 4.000000e+00, %tmp16
  %add187 = fadd float %add177, %mul186
  %add188 = add nsw i32 %i.0, 1
  %mul189 = mul nsw i32 %nk, %nj
  %mul190 = mul nsw i32 %add188, %mul189
  %mul191 = mul nsw i32 %j.0, %nk
  %add192 = add nsw i32 %mul190, %mul191
  %add193 = add nsw i32 %k.0, 1
  %add194 = add nsw i32 %add192, %add193
  %idxprom195 = sext i32 %add194 to i64
  %arrayidx196 = getelementptr inbounds float, float* %A, i64 %idxprom195
  %tmp17 = load float, float* %arrayidx196, align 4
  %mul197 = fmul float 5.000000e+00, %tmp17
  %add198 = fadd float %add187, %mul197
  %sub199 = sub nsw i32 %i.0, 1
  %mul200 = mul nsw i32 %nk, %nj
  %mul201 = mul nsw i32 %sub199, %mul200
  %add202 = add nsw i32 %j.0, 1
  %mul203 = mul nsw i32 %add202, %nk
  %add204 = add nsw i32 %mul201, %mul203
  %sub205 = sub nsw i32 %k.0, 1
  %add206 = add nsw i32 %add204, %sub205
  %idxprom207 = sext i32 %add206 to i64
  %arrayidx208 = getelementptr inbounds float, float* %A, i64 %idxprom207
  %tmp18 = load float, float* %arrayidx208, align 4
  %mul209 = fmul float 0x4000FCD360000000, %tmp18
  %add210 = fadd float %add198, %mul209
  %mul211 = mul nsw i32 %nk, %nj
  %mul212 = mul nsw i32 %i.0, %mul211
  %add213 = add nsw i32 %j.0, 1
  %mul214 = mul nsw i32 %add213, %nk
  %add215 = add nsw i32 %mul212, %mul214
  %sub216 = sub nsw i32 %k.0, 1
  %add217 = add nsw i32 %add215, %sub216
  %idxprom218 = sext i32 %add217 to i64
  %arrayidx219 = getelementptr inbounds float, float* %A, i64 %idxprom218
  %tmp19 = load float, float* %arrayidx219, align 4
  %mul220 = fmul float 4.000000e+00, %tmp19
  %add221 = fadd float %add210, %mul220
  %add222 = add nsw i32 %i.0, 1
  %mul223 = mul nsw i32 %nk, %nj
  %mul224 = mul nsw i32 %add222, %mul223
  %add225 = add nsw i32 %j.0, 1
  %mul226 = mul nsw i32 %add225, %nk
  %add227 = add nsw i32 %mul224, %mul226
  %sub228 = sub nsw i32 %k.0, 1
  %add229 = add nsw i32 %add227, %sub228
  %idxprom230 = sext i32 %add229 to i64
  %arrayidx231 = getelementptr inbounds float, float* %A, i64 %idxprom230
  %tmp20 = load float, float* %arrayidx231, align 4
  %mul232 = fmul float 5.000000e+00, %tmp20
  %add233 = fadd float %add221, %mul232
  %sub234 = sub nsw i32 %i.0, 1
  %mul235 = mul nsw i32 %nk, %nj
  %mul236 = mul nsw i32 %sub234, %mul235
  %add237 = add nsw i32 %j.0, 1
  %mul238 = mul nsw i32 %add237, %nk
  %add239 = add nsw i32 %mul236, %mul238
  %add240 = add nsw i32 %add239, %k.0
  %idxprom241 = sext i32 %add240 to i64
  %arrayidx242 = getelementptr inbounds float, float* %A, i64 %idxprom241
  %tmp21 = load float, float* %arrayidx242, align 4
  %mul243 = fmul float 0x4000FCD360000000, %tmp21
  %add244 = fadd float %add233, %mul243
  %mul245 = mul nsw i32 %nk, %nj
  %mul246 = mul nsw i32 %i.0, %mul245
  %add247 = add nsw i32 %j.0, 1
  %mul248 = mul nsw i32 %add247, %nk
  %add249 = add nsw i32 %mul246, %mul248
  %add250 = add nsw i32 %add249, %k.0
  %idxprom251 = sext i32 %add250 to i64
  %arrayidx252 = getelementptr inbounds float, float* %A, i64 %idxprom251
  %tmp22 = load float, float* %arrayidx252, align 4
  %mul253 = fmul float 4.000000e+00, %tmp22
  %add254 = fadd float %add244, %mul253
  %add255 = add nsw i32 %i.0, 1
  %mul256 = mul nsw i32 %nk, %nj
  %mul257 = mul nsw i32 %add255, %mul256
  %add258 = add nsw i32 %j.0, 1
  %mul259 = mul nsw i32 %add258, %nk
  %add260 = add nsw i32 %mul257, %mul259
  %add261 = add nsw i32 %add260, %k.0
  %idxprom262 = sext i32 %add261 to i64
  %arrayidx263 = getelementptr inbounds float, float* %A, i64 %idxprom262
  %tmp23 = load float, float* %arrayidx263, align 4
  %mul264 = fmul float 5.000000e+00, %tmp23
  %add265 = fadd float %add254, %mul264
  %sub266 = sub nsw i32 %i.0, 1
  %mul267 = mul nsw i32 %nk, %nj
  %mul268 = mul nsw i32 %sub266, %mul267
  %add269 = add nsw i32 %j.0, 1
  %mul270 = mul nsw i32 %add269, %nk
  %add271 = add nsw i32 %mul268, %mul270
  %add272 = add nsw i32 %k.0, 1
  %add273 = add nsw i32 %add271, %add272
  %idxprom274 = sext i32 %add273 to i64
  %arrayidx275 = getelementptr inbounds float, float* %A, i64 %idxprom274
  %tmp24 = load float, float* %arrayidx275, align 4
  %mul276 = fmul float 0x4000FCD360000000, %tmp24
  %add277 = fadd float %add265, %mul276
  %mul278 = mul nsw i32 %nk, %nj
  %mul279 = mul nsw i32 %i.0, %mul278
  %add280 = add nsw i32 %j.0, 1
  %mul281 = mul nsw i32 %add280, %nk
  %add282 = add nsw i32 %mul279, %mul281
  %add283 = add nsw i32 %k.0, 1
  %add284 = add nsw i32 %add282, %add283
  %idxprom285 = sext i32 %add284 to i64
  %arrayidx286 = getelementptr inbounds float, float* %A, i64 %idxprom285
  %tmp25 = load float, float* %arrayidx286, align 4
  %mul287 = fmul float 4.000000e+00, %tmp25
  %add288 = fadd float %add277, %mul287
  %add289 = add nsw i32 %i.0, 1
  %mul290 = mul nsw i32 %nk, %nj
  %mul291 = mul nsw i32 %add289, %mul290
  %add292 = add nsw i32 %j.0, 1
  %mul293 = mul nsw i32 %add292, %nk
  %add294 = add nsw i32 %mul291, %mul293
  %add295 = add nsw i32 %k.0, 1
  %add296 = add nsw i32 %add294, %add295
  %idxprom297 = sext i32 %add296 to i64
  %arrayidx298 = getelementptr inbounds float, float* %A, i64 %idxprom297
  %tmp26 = load float, float* %arrayidx298, align 4
  %mul299 = fmul float 5.000000e+00, %tmp26
  %add300 = fadd float %add288, %mul299
  %mul301 = mul nsw i32 %nk, %nj
  %mul302 = mul nsw i32 %i.0, %mul301
  %mul303 = mul nsw i32 %j.0, %nk
  %add304 = add nsw i32 %mul302, %mul303
  %add305 = add nsw i32 %add304, %k.0
  %idxprom306 = sext i32 %add305 to i64
  %arrayidx307 = getelementptr inbounds float, float* %B, i64 %idxprom306
  store float %add300, float* %arrayidx307, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.8
  %inc = add nsw i32 %k.0, 1
  br label %for.cond.5

for.end:                                          ; preds = %for.cond.5
  br label %for.inc.308

for.inc.308:                                      ; preds = %for.end
  %inc309 = add nsw i32 %i.0, 1
  br label %for.cond.1

for.end.310:                                      ; preds = %for.cond.1
  br label %for.inc.311

for.inc.311:                                      ; preds = %for.end.310
  %inc312 = add nsw i32 %j.0, 1
  br label %for.cond

for.end.313:                                      ; preds = %for.cond
  ret void
}

; Function Attrs: nounwind uwtable
define void @init(float* %A) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.18, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc19, %for.inc.18 ]
  %cmp = icmp slt i32 %i.0, 2048
  br i1 %cmp, label %for.body, label %for.end.20

for.body:                                         ; preds = %for.cond
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc.15, %for.body
  %j.0 = phi i32 [ 0, %for.body ], [ %inc16, %for.inc.15 ]
  %cmp2 = icmp slt i32 %j.0, 2048
  br i1 %cmp2, label %for.body.3, label %for.end.17

for.body.3:                                       ; preds = %for.cond.1
  br label %for.cond.4

for.cond.4:                                       ; preds = %for.inc, %for.body.3
  %k.0 = phi i32 [ 0, %for.body.3 ], [ %inc, %for.inc ]
  %cmp5 = icmp slt i32 %k.0, 2048
  br i1 %cmp5, label %for.body.6, label %for.end

for.body.6:                                       ; preds = %for.cond.4
  %rem = srem i32 %i.0, 12
  %rem7 = srem i32 %j.0, 7
  %mul = mul nsw i32 2, %rem7
  %add = add nsw i32 %rem, %mul
  %rem8 = srem i32 %k.0, 13
  %mul9 = mul nsw i32 3, %rem8
  %add10 = add nsw i32 %add, %mul9
  %conv = sitofp i32 %add10 to float
  %mul11 = mul nsw i32 %i.0, 4194304
  %mul12 = mul nsw i32 %j.0, 2048
  %add13 = add nsw i32 %mul11, %mul12
  %add14 = add nsw i32 %add13, %k.0
  %idxprom = sext i32 %add14 to i64
  %arrayidx = getelementptr inbounds float, float* %A, i64 %idxprom
  store float %conv, float* %arrayidx, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.6
  %inc = add nsw i32 %k.0, 1
  br label %for.cond.4

for.end:                                          ; preds = %for.cond.4
  br label %for.inc.15

for.inc.15:                                       ; preds = %for.end
  %inc16 = add nsw i32 %j.0, 1
  br label %for.cond.1

for.end.17:                                       ; preds = %for.cond.1
  br label %for.inc.18

for.inc.18:                                       ; preds = %for.end.17
  %inc19 = add nsw i32 %i.0, 1
  br label %for.cond

for.end.20:                                       ; preds = %for.cond
  ret void
}

; Function Attrs: nounwind uwtable
define void @compareResults(float* %B, float* %B_GPU) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.23, %entry
  %i.0 = phi i32 [ 1, %entry ], [ %inc24, %for.inc.23 ]
  %fail.0 = phi i32 [ 0, %entry ], [ %fail.1, %for.inc.23 ]
  %cmp = icmp slt i32 %i.0, 2047
  br i1 %cmp, label %for.body, label %for.end.25

for.body:                                         ; preds = %for.cond
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc.20, %for.body
  %j.0 = phi i32 [ 1, %for.body ], [ %inc21, %for.inc.20 ]
  %fail.1 = phi i32 [ %fail.0, %for.body ], [ %fail.2, %for.inc.20 ]
  %cmp2 = icmp slt i32 %j.0, 2047
  br i1 %cmp2, label %for.body.3, label %for.end.22

for.body.3:                                       ; preds = %for.cond.1
  br label %for.cond.4

for.cond.4:                                       ; preds = %for.inc, %for.body.3
  %k.0 = phi i32 [ 1, %for.body.3 ], [ %inc19, %for.inc ]
  %fail.2 = phi i32 [ %fail.1, %for.body.3 ], [ %fail.3, %for.inc ]
  %cmp5 = icmp slt i32 %k.0, 2047
  br i1 %cmp5, label %for.body.6, label %for.end

for.body.6:                                       ; preds = %for.cond.4
  %mul = mul nsw i32 %i.0, 4194304
  %mul7 = mul nsw i32 %j.0, 2048
  %add = add nsw i32 %mul, %mul7
  %add8 = add nsw i32 %add, %k.0
  %idxprom = sext i32 %add8 to i64
  %arrayidx = getelementptr inbounds float, float* %B, i64 %idxprom
  %tmp = load float, float* %arrayidx, align 4
  %conv = fpext float %tmp to double
  %mul9 = mul nsw i32 %i.0, 4194304
  %mul10 = mul nsw i32 %j.0, 2048
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
  %call = call noalias i8* @malloc(i64 0) #3
  %tmp = bitcast i8* %call to float*
  %call1 = call noalias i8* @malloc(i64 0) #3
  %tmp1 = bitcast i8* %call1 to float*
  %tmp2 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %call2 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %tmp2, i8* getelementptr inbounds ([42 x i8], [42 x i8]* @.str.2, i32 0, i32 0))
  call void @init(float* %tmp)
  %call3 = call double @rtclock()
  call void @conv3d(i32 2048, i32 2048, i32 2048, float* %tmp, float* %tmp1)
  %call4 = call double @rtclock()
  %tmp3 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %sub = fsub double %call4, %call3
  %call5 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %tmp3, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.3, i32 0, i32 0), double %sub)
  %tmp4 = bitcast float* %tmp to i8*
  call void @free(i8* %tmp4) #3
  %tmp5 = bitcast float* %tmp1 to i8*
  call void @free(i8* %tmp5) #3
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
