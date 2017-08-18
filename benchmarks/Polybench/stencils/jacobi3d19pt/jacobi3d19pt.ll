; ModuleID = 'jacobi3d19pt-base.ll'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, i8*, i8*, i8*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type { %struct._IO_marker*, %struct._IO_FILE*, i32 }
%struct.timezone = type { i32, i32 }
%struct.timeval = type { i64, i64 }

@.str = private unnamed_addr constant [35 x i8] c"Error return from gettimeofday: %d\00", align 1
@.str.1 = private unnamed_addr constant [51 x i8] c"Expected: %f, received: %f at position [%d,%d,%d]\0A\00", align 1
@.str.2 = private unnamed_addr constant [74 x i8] c"Non-Matching CPU-GPU Outputs Beyond Error Threshold of %4.2f Percent: %d\0A\00", align 1
@stdout = external global %struct._IO_FILE*, align 8
@.str.3 = private unnamed_addr constant [29 x i8] c">> 3D 7PT Jacobi Stencil <<\0A\00", align 1
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
define void @jacobi3d19pt(i32 %tsteps, i32 %x, i32 %y, i32 %z, float* %A, float* %B) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.244, %entry
  %t.0 = phi i32 [ 0, %entry ], [ %inc245, %for.inc.244 ]
  %cmp = icmp slt i32 %t.0, %tsteps
  br i1 %cmp, label %for.body, label %for.end.246

for.body:                                         ; preds = %for.cond
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc.206, %for.body
  %i.0 = phi i32 [ 3, %for.body ], [ %inc207, %for.inc.206 ]
  %sub = sub nsw i32 %z, 3
  %cmp2 = icmp slt i32 %i.0, %sub
  br i1 %cmp2, label %for.body.3, label %for.end.208

for.body.3:                                       ; preds = %for.cond.1
  br label %for.cond.4

for.cond.4:                                       ; preds = %for.inc.203, %for.body.3
  %j.0 = phi i32 [ 3, %for.body.3 ], [ %inc204, %for.inc.203 ]
  %sub5 = sub nsw i32 %y, 3
  %cmp6 = icmp slt i32 %j.0, %sub5
  br i1 %cmp6, label %for.body.7, label %for.end.205

for.body.7:                                       ; preds = %for.cond.4
  br label %for.cond.8

for.cond.8:                                       ; preds = %for.inc, %for.body.7
  %k.0 = phi i32 [ 3, %for.body.7 ], [ %inc, %for.inc ]
  %sub9 = sub nsw i32 %x, 3
  %cmp10 = icmp slt i32 %k.0, %sub9
  br i1 %cmp10, label %for.body.11, label %for.end

for.body.11:                                      ; preds = %for.cond.8
  %add = add nsw i32 %i.0, 3
  %mul = mul nsw i32 %x, %y
  %mul12 = mul nsw i32 %add, %mul
  %mul13 = mul nsw i32 %j.0, %x
  %add14 = add nsw i32 %mul12, %mul13
  %add15 = add nsw i32 %add14, %k.0
  %idxprom = sext i32 %add15 to i64
  %arrayidx = getelementptr inbounds float, float* %A, i64 %idxprom
  %tmp = load float, float* %arrayidx, align 4
  %mul16 = fmul float 0x3FC99999A0000000, %tmp
  %sub17 = sub nsw i32 %i.0, 3
  %mul18 = mul nsw i32 %x, %y
  %mul19 = mul nsw i32 %sub17, %mul18
  %mul20 = mul nsw i32 %j.0, %x
  %add21 = add nsw i32 %mul19, %mul20
  %add22 = add nsw i32 %add21, %k.0
  %idxprom23 = sext i32 %add22 to i64
  %arrayidx24 = getelementptr inbounds float, float* %A, i64 %idxprom23
  %tmp1 = load float, float* %arrayidx24, align 4
  %mul25 = fmul float 2.000000e+00, %tmp1
  %add26 = fadd float %mul16, %mul25
  %add27 = add nsw i32 %i.0, 2
  %mul28 = mul nsw i32 %x, %y
  %mul29 = mul nsw i32 %add27, %mul28
  %mul30 = mul nsw i32 %j.0, %x
  %add31 = add nsw i32 %mul29, %mul30
  %add32 = add nsw i32 %add31, %k.0
  %idxprom33 = sext i32 %add32 to i64
  %arrayidx34 = getelementptr inbounds float, float* %A, i64 %idxprom33
  %tmp2 = load float, float* %arrayidx34, align 4
  %mul35 = fmul float 0x3FC99999A0000000, %tmp2
  %add36 = fadd float %add26, %mul35
  %sub37 = sub nsw i32 %i.0, 2
  %mul38 = mul nsw i32 %x, %y
  %mul39 = mul nsw i32 %sub37, %mul38
  %mul40 = mul nsw i32 %j.0, %x
  %add41 = add nsw i32 %mul39, %mul40
  %add42 = add nsw i32 %add41, %k.0
  %idxprom43 = sext i32 %add42 to i64
  %arrayidx44 = getelementptr inbounds float, float* %A, i64 %idxprom43
  %tmp3 = load float, float* %arrayidx44, align 4
  %mul45 = fmul float 2.000000e+00, %tmp3
  %add46 = fadd float %add36, %mul45
  %add47 = add nsw i32 %i.0, 1
  %mul48 = mul nsw i32 %x, %y
  %mul49 = mul nsw i32 %add47, %mul48
  %mul50 = mul nsw i32 %j.0, %x
  %add51 = add nsw i32 %mul49, %mul50
  %add52 = add nsw i32 %add51, %k.0
  %idxprom53 = sext i32 %add52 to i64
  %arrayidx54 = getelementptr inbounds float, float* %A, i64 %idxprom53
  %tmp4 = load float, float* %arrayidx54, align 4
  %mul55 = fmul float 0x3FC99999A0000000, %tmp4
  %add56 = fadd float %add46, %mul55
  %sub57 = sub nsw i32 %i.0, 1
  %mul58 = mul nsw i32 %x, %y
  %mul59 = mul nsw i32 %sub57, %mul58
  %mul60 = mul nsw i32 %j.0, %x
  %add61 = add nsw i32 %mul59, %mul60
  %add62 = add nsw i32 %add61, %k.0
  %idxprom63 = sext i32 %add62 to i64
  %arrayidx64 = getelementptr inbounds float, float* %A, i64 %idxprom63
  %tmp5 = load float, float* %arrayidx64, align 4
  %mul65 = fmul float 2.000000e+00, %tmp5
  %add66 = fadd float %add56, %mul65
  %mul67 = mul nsw i32 %x, %y
  %mul68 = mul nsw i32 %i.0, %mul67
  %add69 = add nsw i32 %j.0, 3
  %mul70 = mul nsw i32 %add69, %x
  %add71 = add nsw i32 %mul68, %mul70
  %add72 = add nsw i32 %add71, %k.0
  %idxprom73 = sext i32 %add72 to i64
  %arrayidx74 = getelementptr inbounds float, float* %A, i64 %idxprom73
  %tmp6 = load float, float* %arrayidx74, align 4
  %mul75 = fmul float 0x3FC99999A0000000, %tmp6
  %add76 = fadd float %add66, %mul75
  %mul77 = mul nsw i32 %x, %y
  %mul78 = mul nsw i32 %i.0, %mul77
  %sub79 = sub nsw i32 %j.0, 3
  %mul80 = mul nsw i32 %sub79, %x
  %add81 = add nsw i32 %mul78, %mul80
  %add82 = add nsw i32 %add81, %k.0
  %idxprom83 = sext i32 %add82 to i64
  %arrayidx84 = getelementptr inbounds float, float* %A, i64 %idxprom83
  %tmp7 = load float, float* %arrayidx84, align 4
  %mul85 = fmul float 2.000000e+00, %tmp7
  %add86 = fadd float %add76, %mul85
  %mul87 = mul nsw i32 %x, %y
  %mul88 = mul nsw i32 %i.0, %mul87
  %add89 = add nsw i32 %j.0, 2
  %mul90 = mul nsw i32 %add89, %x
  %add91 = add nsw i32 %mul88, %mul90
  %add92 = add nsw i32 %add91, %k.0
  %idxprom93 = sext i32 %add92 to i64
  %arrayidx94 = getelementptr inbounds float, float* %A, i64 %idxprom93
  %tmp8 = load float, float* %arrayidx94, align 4
  %mul95 = fmul float 0x3FC99999A0000000, %tmp8
  %add96 = fadd float %add86, %mul95
  %mul97 = mul nsw i32 %x, %y
  %mul98 = mul nsw i32 %i.0, %mul97
  %sub99 = sub nsw i32 %j.0, 2
  %mul100 = mul nsw i32 %sub99, %x
  %add101 = add nsw i32 %mul98, %mul100
  %add102 = add nsw i32 %add101, %k.0
  %idxprom103 = sext i32 %add102 to i64
  %arrayidx104 = getelementptr inbounds float, float* %A, i64 %idxprom103
  %tmp9 = load float, float* %arrayidx104, align 4
  %mul105 = fmul float 2.000000e+00, %tmp9
  %add106 = fadd float %add96, %mul105
  %mul107 = mul nsw i32 %x, %y
  %mul108 = mul nsw i32 %i.0, %mul107
  %add109 = add nsw i32 %j.0, 1
  %mul110 = mul nsw i32 %add109, %x
  %add111 = add nsw i32 %mul108, %mul110
  %add112 = add nsw i32 %add111, %k.0
  %idxprom113 = sext i32 %add112 to i64
  %arrayidx114 = getelementptr inbounds float, float* %A, i64 %idxprom113
  %tmp10 = load float, float* %arrayidx114, align 4
  %mul115 = fmul float 0x3FC99999A0000000, %tmp10
  %add116 = fadd float %add106, %mul115
  %mul117 = mul nsw i32 %x, %y
  %mul118 = mul nsw i32 %i.0, %mul117
  %sub119 = sub nsw i32 %j.0, 1
  %mul120 = mul nsw i32 %sub119, %x
  %add121 = add nsw i32 %mul118, %mul120
  %add122 = add nsw i32 %add121, %k.0
  %idxprom123 = sext i32 %add122 to i64
  %arrayidx124 = getelementptr inbounds float, float* %A, i64 %idxprom123
  %tmp11 = load float, float* %arrayidx124, align 4
  %mul125 = fmul float 2.000000e+00, %tmp11
  %add126 = fadd float %add116, %mul125
  %mul127 = mul nsw i32 %x, %y
  %mul128 = mul nsw i32 %i.0, %mul127
  %mul129 = mul nsw i32 %j.0, %x
  %add130 = add nsw i32 %mul128, %mul129
  %add131 = add nsw i32 %k.0, 3
  %add132 = add nsw i32 %add130, %add131
  %idxprom133 = sext i32 %add132 to i64
  %arrayidx134 = getelementptr inbounds float, float* %A, i64 %idxprom133
  %tmp12 = load float, float* %arrayidx134, align 4
  %mul135 = fmul float 0x3FC99999A0000000, %tmp12
  %add136 = fadd float %add126, %mul135
  %mul137 = mul nsw i32 %x, %y
  %mul138 = mul nsw i32 %i.0, %mul137
  %mul139 = mul nsw i32 %j.0, %x
  %add140 = add nsw i32 %mul138, %mul139
  %sub141 = sub nsw i32 %k.0, 3
  %add142 = add nsw i32 %add140, %sub141
  %idxprom143 = sext i32 %add142 to i64
  %arrayidx144 = getelementptr inbounds float, float* %A, i64 %idxprom143
  %tmp13 = load float, float* %arrayidx144, align 4
  %mul145 = fmul float 2.000000e+00, %tmp13
  %add146 = fadd float %add136, %mul145
  %mul147 = mul nsw i32 %x, %y
  %mul148 = mul nsw i32 %i.0, %mul147
  %mul149 = mul nsw i32 %j.0, %x
  %add150 = add nsw i32 %mul148, %mul149
  %add151 = add nsw i32 %k.0, 2
  %add152 = add nsw i32 %add150, %add151
  %idxprom153 = sext i32 %add152 to i64
  %arrayidx154 = getelementptr inbounds float, float* %A, i64 %idxprom153
  %tmp14 = load float, float* %arrayidx154, align 4
  %mul155 = fmul float 0x3FC99999A0000000, %tmp14
  %add156 = fadd float %add146, %mul155
  %mul157 = mul nsw i32 %x, %y
  %mul158 = mul nsw i32 %i.0, %mul157
  %mul159 = mul nsw i32 %j.0, %x
  %add160 = add nsw i32 %mul158, %mul159
  %sub161 = sub nsw i32 %k.0, 2
  %add162 = add nsw i32 %add160, %sub161
  %idxprom163 = sext i32 %add162 to i64
  %arrayidx164 = getelementptr inbounds float, float* %A, i64 %idxprom163
  %tmp15 = load float, float* %arrayidx164, align 4
  %mul165 = fmul float 2.000000e+00, %tmp15
  %add166 = fadd float %add156, %mul165
  %mul167 = mul nsw i32 %x, %y
  %mul168 = mul nsw i32 %i.0, %mul167
  %mul169 = mul nsw i32 %j.0, %x
  %add170 = add nsw i32 %mul168, %mul169
  %add171 = add nsw i32 %k.0, 1
  %add172 = add nsw i32 %add170, %add171
  %idxprom173 = sext i32 %add172 to i64
  %arrayidx174 = getelementptr inbounds float, float* %A, i64 %idxprom173
  %tmp16 = load float, float* %arrayidx174, align 4
  %mul175 = fmul float 0x3FC99999A0000000, %tmp16
  %add176 = fadd float %add166, %mul175
  %mul177 = mul nsw i32 %x, %y
  %mul178 = mul nsw i32 %i.0, %mul177
  %mul179 = mul nsw i32 %j.0, %x
  %add180 = add nsw i32 %mul178, %mul179
  %sub181 = sub nsw i32 %k.0, 1
  %add182 = add nsw i32 %add180, %sub181
  %idxprom183 = sext i32 %add182 to i64
  %arrayidx184 = getelementptr inbounds float, float* %A, i64 %idxprom183
  %tmp17 = load float, float* %arrayidx184, align 4
  %mul185 = fmul float 2.000000e+00, %tmp17
  %add186 = fadd float %add176, %mul185
  %mul187 = mul nsw i32 %x, %y
  %mul188 = mul nsw i32 %i.0, %mul187
  %mul189 = mul nsw i32 %j.0, %x
  %add190 = add nsw i32 %mul188, %mul189
  %add191 = add nsw i32 %add190, %k.0
  %idxprom192 = sext i32 %add191 to i64
  %arrayidx193 = getelementptr inbounds float, float* %A, i64 %idxprom192
  %tmp18 = load float, float* %arrayidx193, align 4
  %mul194 = fmul float 0x3FC99999A0000000, %tmp18
  %add195 = fadd float %add186, %mul194
  %mul196 = mul nsw i32 %x, %y
  %mul197 = mul nsw i32 %i.0, %mul196
  %mul198 = mul nsw i32 %j.0, %x
  %add199 = add nsw i32 %mul197, %mul198
  %add200 = add nsw i32 %add199, %k.0
  %idxprom201 = sext i32 %add200 to i64
  %arrayidx202 = getelementptr inbounds float, float* %B, i64 %idxprom201
  store float %add195, float* %arrayidx202, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.11
  %inc = add nsw i32 %k.0, 1
  br label %for.cond.8

for.end:                                          ; preds = %for.cond.8
  br label %for.inc.203

for.inc.203:                                      ; preds = %for.end
  %inc204 = add nsw i32 %j.0, 1
  br label %for.cond.4

for.end.205:                                      ; preds = %for.cond.4
  br label %for.inc.206

for.inc.206:                                      ; preds = %for.end.205
  %inc207 = add nsw i32 %i.0, 1
  br label %for.cond.1

for.end.208:                                      ; preds = %for.cond.1
  br label %for.cond.209

for.cond.209:                                     ; preds = %for.inc.241, %for.end.208
  %i.1 = phi i32 [ 3, %for.end.208 ], [ %inc242, %for.inc.241 ]
  %sub210 = sub nsw i32 %z, 3
  %cmp211 = icmp slt i32 %i.1, %sub210
  br i1 %cmp211, label %for.body.212, label %for.end.243

for.body.212:                                     ; preds = %for.cond.209
  br label %for.cond.213

for.cond.213:                                     ; preds = %for.inc.238, %for.body.212
  %j.1 = phi i32 [ 3, %for.body.212 ], [ %inc239, %for.inc.238 ]
  %sub214 = sub nsw i32 %y, 3
  %cmp215 = icmp slt i32 %j.1, %sub214
  br i1 %cmp215, label %for.body.216, label %for.end.240

for.body.216:                                     ; preds = %for.cond.213
  br label %for.cond.217

for.cond.217:                                     ; preds = %for.inc.235, %for.body.216
  %k.1 = phi i32 [ 3, %for.body.216 ], [ %inc236, %for.inc.235 ]
  %sub218 = sub nsw i32 %x, 3
  %cmp219 = icmp slt i32 %k.1, %sub218
  br i1 %cmp219, label %for.body.220, label %for.end.237

for.body.220:                                     ; preds = %for.cond.217
  %mul221 = mul nsw i32 %x, %y
  %mul222 = mul nsw i32 %i.1, %mul221
  %mul223 = mul nsw i32 %j.1, %x
  %add224 = add nsw i32 %mul222, %mul223
  %add225 = add nsw i32 %add224, %k.1
  %idxprom226 = sext i32 %add225 to i64
  %arrayidx227 = getelementptr inbounds float, float* %B, i64 %idxprom226
  %tmp19 = load float, float* %arrayidx227, align 4
  %mul228 = mul nsw i32 %x, %y
  %mul229 = mul nsw i32 %i.1, %mul228
  %mul230 = mul nsw i32 %j.1, %z
  %add231 = add nsw i32 %mul229, %mul230
  %add232 = add nsw i32 %add231, %k.1
  %idxprom233 = sext i32 %add232 to i64
  %arrayidx234 = getelementptr inbounds float, float* %A, i64 %idxprom233
  store float %tmp19, float* %arrayidx234, align 4
  br label %for.inc.235

for.inc.235:                                      ; preds = %for.body.220
  %inc236 = add nsw i32 %k.1, 1
  br label %for.cond.217

for.end.237:                                      ; preds = %for.cond.217
  br label %for.inc.238

for.inc.238:                                      ; preds = %for.end.237
  %inc239 = add nsw i32 %j.1, 1
  br label %for.cond.213

for.end.240:                                      ; preds = %for.cond.213
  br label %for.inc.241

for.inc.241:                                      ; preds = %for.end.240
  %inc242 = add nsw i32 %i.1, 1
  br label %for.cond.209

for.end.243:                                      ; preds = %for.cond.209
  br label %for.inc.244

for.inc.244:                                      ; preds = %for.end.243
  %inc245 = add nsw i32 %t.0, 1
  br label %for.cond

for.end.246:                                      ; preds = %for.cond
  ret void
}

; Function Attrs: nounwind uwtable
define void @init(float* %A, i32 %x, i32 %y, i32 %z, i32 %offset_x, i32 %offset_y, i32 %offset_z) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.37, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc38, %for.inc.37 ]
  %cmp = icmp slt i32 %i.0, %z
  br i1 %cmp, label %for.body, label %for.end.39

for.body:                                         ; preds = %for.cond
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc.34, %for.body
  %j.0 = phi i32 [ 0, %for.body ], [ %inc35, %for.inc.34 ]
  %cmp2 = icmp slt i32 %j.0, %y
  br i1 %cmp2, label %for.body.3, label %for.end.36

for.body.3:                                       ; preds = %for.cond.1
  br label %for.cond.4

for.cond.4:                                       ; preds = %for.inc, %for.body.3
  %k.0 = phi i32 [ 0, %for.body.3 ], [ %inc, %for.inc ]
  %cmp5 = icmp slt i32 %k.0, %x
  br i1 %cmp5, label %for.body.6, label %for.end

for.body.6:                                       ; preds = %for.cond.4
  %cmp7 = icmp slt i32 %i.0, %offset_z
  br i1 %cmp7, label %if.then, label %lor.lhs.false

lor.lhs.false:                                    ; preds = %for.body.6
  %cmp8 = icmp slt i32 %j.0, %offset_y
  br i1 %cmp8, label %if.then, label %lor.lhs.false.9

lor.lhs.false.9:                                  ; preds = %lor.lhs.false
  %sub = sub nsw i32 %z, %offset_z
  %cmp10 = icmp sge i32 %i.0, %sub
  br i1 %cmp10, label %if.then, label %lor.lhs.false.11

lor.lhs.false.11:                                 ; preds = %lor.lhs.false.9
  %sub12 = sub nsw i32 %y, %offset_y
  %cmp13 = icmp sge i32 %j.0, %sub12
  br i1 %cmp13, label %if.then, label %lor.lhs.false.14

lor.lhs.false.14:                                 ; preds = %lor.lhs.false.11
  %cmp15 = icmp slt i32 %k.0, %offset_x
  br i1 %cmp15, label %if.then, label %lor.lhs.false.16

lor.lhs.false.16:                                 ; preds = %lor.lhs.false.14
  %sub17 = sub nsw i32 %x, %offset_x
  %cmp18 = icmp sge i32 %k.0, %sub17
  br i1 %cmp18, label %if.then, label %if.else

if.then:                                          ; preds = %lor.lhs.false.16, %lor.lhs.false.14, %lor.lhs.false.11, %lor.lhs.false.9, %lor.lhs.false, %for.body.6
  %mul = mul nsw i32 %x, %y
  %mul19 = mul nsw i32 %i.0, %mul
  %mul20 = mul nsw i32 %j.0, %x
  %add = add nsw i32 %mul19, %mul20
  %add21 = add nsw i32 %add, %k.0
  %idxprom = sext i32 %add21 to i64
  %arrayidx = getelementptr inbounds float, float* %A, i64 %idxprom
  store float 0.000000e+00, float* %arrayidx, align 4
  br label %if.end

if.else:                                          ; preds = %lor.lhs.false.16
  %add22 = add nsw i32 %i.0, %j.0
  %sub23 = sub nsw i32 %x, %k.0
  %add24 = add nsw i32 %add22, %sub23
  %conv = sitofp i32 %add24 to float
  %mul25 = fmul float %conv, 1.000000e+01
  %conv26 = sitofp i32 %x to float
  %div = fdiv float %mul25, %conv26
  %mul27 = mul nsw i32 %x, %y
  %mul28 = mul nsw i32 %i.0, %mul27
  %mul29 = mul nsw i32 %j.0, %x
  %add30 = add nsw i32 %mul28, %mul29
  %add31 = add nsw i32 %add30, %k.0
  %idxprom32 = sext i32 %add31 to i64
  %arrayidx33 = getelementptr inbounds float, float* %A, i64 %idxprom32
  store float %div, float* %arrayidx33, align 4
  br label %if.end

if.end:                                           ; preds = %if.else, %if.then
  br label %for.inc

for.inc:                                          ; preds = %if.end
  %inc = add nsw i32 %k.0, 1
  br label %for.cond.4

for.end:                                          ; preds = %for.cond.4
  br label %for.inc.34

for.inc.34:                                       ; preds = %for.end
  %inc35 = add nsw i32 %j.0, 1
  br label %for.cond.1

for.end.36:                                       ; preds = %for.cond.1
  br label %for.inc.37

for.inc.37:                                       ; preds = %for.end.36
  %inc38 = add nsw i32 %i.0, 1
  br label %for.cond

for.end.39:                                       ; preds = %for.cond
  ret void
}

; Function Attrs: nounwind uwtable
define i32 @checkResult(float* %a, float* %ref, i32 %dimx, i32 %dimy, i32 %dimz) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.36, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc37, %for.inc.36 ]
  %cmp = icmp slt i32 %i.0, %dimz
  br i1 %cmp, label %for.body, label %for.end.38

for.body:                                         ; preds = %for.cond
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc.33, %for.body
  %j.0 = phi i32 [ 0, %for.body ], [ %inc34, %for.inc.33 ]
  %cmp2 = icmp slt i32 %j.0, %dimy
  br i1 %cmp2, label %for.body.3, label %for.end.35

for.body.3:                                       ; preds = %for.cond.1
  br label %for.cond.4

for.cond.4:                                       ; preds = %for.inc, %for.body.3
  %k.0 = phi i32 [ 0, %for.body.3 ], [ %inc, %for.inc ]
  %cmp5 = icmp slt i32 %k.0, %dimx
  br i1 %cmp5, label %for.body.6, label %for.end

for.body.6:                                       ; preds = %for.cond.4
  %mul = mul nsw i32 %i.0, %dimx
  %mul7 = mul nsw i32 %mul, %dimy
  %mul8 = mul nsw i32 %j.0, %dimx
  %add = add nsw i32 %mul7, %mul8
  %add9 = add nsw i32 %add, %k.0
  %idxprom = sext i32 %add9 to i64
  %arrayidx = getelementptr inbounds float, float* %a, i64 %idxprom
  %tmp = load float, float* %arrayidx, align 4
  %mul10 = mul nsw i32 %i.0, %dimx
  %mul11 = mul nsw i32 %mul10, %dimy
  %mul12 = mul nsw i32 %j.0, %dimx
  %add13 = add nsw i32 %mul11, %mul12
  %add14 = add nsw i32 %add13, %k.0
  %idxprom15 = sext i32 %add14 to i64
  %arrayidx16 = getelementptr inbounds float, float* %ref, i64 %idxprom15
  %tmp1 = load float, float* %arrayidx16, align 4
  %cmp17 = fcmp une float %tmp, %tmp1
  br i1 %cmp17, label %if.then, label %if.end

if.then:                                          ; preds = %for.body.6
  %mul18 = mul nsw i32 %i.0, %dimx
  %mul19 = mul nsw i32 %mul18, %dimy
  %mul20 = mul nsw i32 %j.0, %dimx
  %add21 = add nsw i32 %mul19, %mul20
  %add22 = add nsw i32 %add21, %k.0
  %idxprom23 = sext i32 %add22 to i64
  %arrayidx24 = getelementptr inbounds float, float* %ref, i64 %idxprom23
  %tmp2 = load float, float* %arrayidx24, align 4
  %conv = fpext float %tmp2 to double
  %mul25 = mul nsw i32 %i.0, %dimx
  %mul26 = mul nsw i32 %mul25, %dimy
  %mul27 = mul nsw i32 %j.0, %dimx
  %add28 = add nsw i32 %mul26, %mul27
  %add29 = add nsw i32 %add28, %k.0
  %idxprom30 = sext i32 %add29 to i64
  %arrayidx31 = getelementptr inbounds float, float* %a, i64 %idxprom30
  %tmp3 = load float, float* %arrayidx31, align 4
  %conv32 = fpext float %tmp3 to double
  %call = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([51 x i8], [51 x i8]* @.str.1, i32 0, i32 0), double %conv, double %conv32, i32 %i.0, i32 %j.0, i32 %k.0)
  br label %return

if.end:                                           ; preds = %for.body.6
  br label %for.inc

for.inc:                                          ; preds = %if.end
  %inc = add nsw i32 %k.0, 1
  br label %for.cond.4

for.end:                                          ; preds = %for.cond.4
  br label %for.inc.33

for.inc.33:                                       ; preds = %for.end
  %inc34 = add nsw i32 %j.0, 1
  br label %for.cond.1

for.end.35:                                       ; preds = %for.cond.1
  br label %for.inc.36

for.inc.36:                                       ; preds = %for.end.35
  %inc37 = add nsw i32 %i.0, 1
  br label %for.cond

for.end.38:                                       ; preds = %for.cond
  br label %return

return:                                           ; preds = %for.end.38, %if.then
  %retval.0 = phi i32 [ 0, %if.then ], [ 1, %for.end.38 ]
  ret i32 %retval.0
}

; Function Attrs: nounwind uwtable
define void @compareResults(float* %B, float* %B_GPU) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.23, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc24, %for.inc.23 ]
  %fail.0 = phi i32 [ 0, %entry ], [ %fail.1, %for.inc.23 ]
  %cmp = icmp slt i32 %i.0, 128
  br i1 %cmp, label %for.body, label %for.end.25

for.body:                                         ; preds = %for.cond
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc.20, %for.body
  %j.0 = phi i32 [ 0, %for.body ], [ %inc21, %for.inc.20 ]
  %fail.1 = phi i32 [ %fail.0, %for.body ], [ %fail.2, %for.inc.20 ]
  %cmp2 = icmp slt i32 %j.0, 128
  br i1 %cmp2, label %for.body.3, label %for.end.22

for.body.3:                                       ; preds = %for.cond.1
  br label %for.cond.4

for.cond.4:                                       ; preds = %for.inc, %for.body.3
  %k.0 = phi i32 [ 0, %for.body.3 ], [ %inc19, %for.inc ]
  %fail.2 = phi i32 [ %fail.1, %for.body.3 ], [ %fail.3, %for.inc ]
  %cmp5 = icmp slt i32 %k.0, 128
  br i1 %cmp5, label %for.body.6, label %for.end

for.body.6:                                       ; preds = %for.cond.4
  %mul = mul nsw i32 %i.0, 16384
  %mul7 = mul nsw i32 %j.0, 128
  %add = add nsw i32 %mul, %mul7
  %add8 = add nsw i32 %add, %k.0
  %idxprom = sext i32 %add8 to i64
  %arrayidx = getelementptr inbounds float, float* %B, i64 %idxprom
  %tmp = load float, float* %arrayidx, align 4
  %conv = fpext float %tmp to double
  %mul9 = mul nsw i32 %i.0, 16384
  %mul10 = mul nsw i32 %j.0, 128
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
  %call26 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([74 x i8], [74 x i8]* @.str.2, i32 0, i32 0), double 5.000000e-01, i32 %fail.0)
  ret void
}

; Function Attrs: nounwind uwtable
define i32 @main(i32 %argc, i8** %argv) #0 {
entry:
  %call = call noalias i8* @calloc(i64 2406104, i64 4) #3
  %tmp = bitcast i8* %call to float*
  %call1 = call noalias i8* @calloc(i64 2406104, i64 4) #3
  %tmp1 = bitcast i8* %call1 to float*
  %tmp2 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %call2 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %tmp2, i8* getelementptr inbounds ([29 x i8], [29 x i8]* @.str.3, i32 0, i32 0))
  call void @init(float* %tmp, i32 134, i32 134, i32 134, i32 3, i32 3, i32 3)
  %call3 = call double @rtclock()
  %add = add nsw i32 128, 6
  %add4 = add nsw i32 128, 6
  %add5 = add nsw i32 128, 6
  call void @jacobi3d19pt(i32 10, i32 %add, i32 %add4, i32 %add5, float* %tmp, float* %tmp1)
  %call6 = call double @rtclock()
  %tmp3 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %sub = fsub double %call6, %call3
  %call7 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %tmp3, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.4, i32 0, i32 0), double %sub)
  %tmp4 = bitcast float* %tmp to i8*
  call void @free(i8* %tmp4) #3
  %tmp5 = bitcast float* %tmp1 to i8*
  call void @free(i8* %tmp5) #3
  ret i32 0
}

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

!0 = !{!"clang version 3.7.1 (http://llvm.org/git/clang.git 0dbefa1b83eb90f7a06b5df5df254ce32be3db4b) (http://llvm.org/git/llvm.git 33c352b3eda89abc24e7511d9045fa2e499a42e3)"}
