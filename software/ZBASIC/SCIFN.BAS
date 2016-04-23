00001 REM *****************************************************
00002 REM ****  ZBasic 3.0 Scientific Functions  09/25/85  ****
00003 REM **** Accuracy up to 50 digits, DBL & SCI set=54  ****
00004 REM *****************************************************
00005 REM ************ Constants used by Functions ************
00006 Log10v# = LOG(10.) : e# = EXP(1.)
00007 Pid4# = ATN(1.) : Pid2# = Pid4# << 1 : Pi# = Pid2# << 1
00008 REM ********** Sub-function used by functions ***********
00009 DEF FN Sqrxx#(x#) = SQR(x#*x#-1.)
00010 REM ******************* Other TRIG Functions ************
00011 DEF FN Sec#(x#)   = 1. \ COS(x#)
00012 DEF FN Csc#(x#)   = 1. \ SIN(x#)
00013 DEF FN Cot#(x#)   = 1. \ TAN(x#)
00014 REM ************** Inverse TRIG Functions ***************
00015 DEF FN ArcSin#(x#) = ATN( x# \ SQR( 1. - x# * x# ) )
00016 DEF FN ArcCos#(x#) = Pid2# - FN ArcSin#(x#)
00017 DEF FN ArcCsc#(x#) = ATN(1\FN Sqrxx#(x#))+(x#<0) * Pi#
00018 DEF FN ArcSec#(x#) = ATN(FN Sqrxx#(x#))+(SGN(x#)-1.)*Pid2
00019 DEF FN ArcCot#(x#) = Pid2# - ATN(x#)
00020 REM ************* Hyperbolic TRIG Functions *************
00021 DEF FN SinH#(x#) = (EXP(x#)-EXP(-x#)) >> 1.
00022 DEF FN CosH#(x#) = (EXP(x#)+EXP(-x#)) >> 1.
00023 DEF FN TanH#(x#) = 1.-2.*EXP(-x#)/(EXP(x#)+EXP(-x#))
00024 DEF FN SecH#(x#) = 2./(EXP(x#)+EXP(-x#))
00025 DEF FN CscH#(x#) = 2./(EXP(x#)-EXP(-x#))
00026 DEF FN CtnH#(x#) = (EXP(x#)+EXP(-x#))\(EXP(x#)-EXP(-x#))
00027 REM ********* Inverse Hyperbolic TRIG Functions *********
00028 DEF FN AsinH#(x#)= LOG(x#+SQR(x#*x#+1.))
00029 DEF FN AcosH#(x#)= LOG(x#+SQR(x#*x#-1.))
00030 DEF FN AtanH#(x#)= LOG((1.+x#)\(1.-x#)) >> 1.
00031 DEF FN AsecH#(x#)= LOG((SQR(1.-x#*x#)+1.)\x#)
00032 DEF FN AcscH#(x#)= LOG((SGN(x#)*SQR(x#*x#+1.)+1.)\x#)
00033 DEF FN AcotH#(x#)= LOG((x#+1.)\(x#-1.)) >> 1.
00034 REM **** Angle Conversions for RADIANS,DEGREES,BRADs ****
00035 DEF FN DegRad#(x#) =x#*Pid4#\90.
00036 DEF FN RadDeg#(x#) =x#*90\Pid4#
00037 DEF FN DegBrad#(x#)=x#*Pid4#\64.
00038 DEF FN BradDeg#(x#)=x#*64.\Pid4#
00039 DEF FN BradRad#(x#)=x#*1.40625 : REM * 1.40625 = 90/64 *
00040 DEF FN RadBrad#(x#)=x#*64.\90.
00041 REM ***************** LOG base 10 ***********************
00042 DEF FN Log10#(x#)= LOG(x#)/Log10v#
00043 REM ************Test Routine For Accuracy ***************
00044 DEFDBL A-Z
00045 FOR I=.01 TO .76 STEP .25
00046 TRONX : PRINT"Should be:";I#
00047 PRINT FN ArcSin#(SIN(FN ArcCos#(COS(ATN(TAN(I#))))))
00048 PRINT FN ArcCot#(FN Cot#(FN AcotH#(FN CtnH#(I#))))
00049 PRINT FN AsecH#(FN SecH#(FN AcscH#(FN CscH#(I#))))
00050 PRINT FN AtanH#(FN TanH#(FN ArcCot#(FN Cot#(I#))))
00051 PRINT FN AcosH#(FN CosH#(FN ArcSec#(FN Sec#(I#))))
00052 PRINT FN AsinH#(FN SinH#(FN ArcCsc#(FN Csc#(I#))))
00053 PRINT FN DegRad(FN RadDeg(FN DegBrad(FN BradDeg(I#))))
00054 PRINT FN RadBrad(FN BradRad(10^FN Log10(I#)))
00055 NEXT
IANS,DEGREES,BRADs ****
00035 DEF FN DegRad#