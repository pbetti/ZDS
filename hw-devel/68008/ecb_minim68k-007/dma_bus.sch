EESchema Schematic File Version 4
LIBS:babyM68K-cache
EELAYER 29 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 2 10
Title "mini M68K CPU"
Date "5 sep 2013"
Rev "2.0.007"
Comp "N8VEM User Group"
Comment1 "by John R. Coffman"
Comment2 "EXPERIMENTAL with I/O and memory protection and BERR"
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L babyM68K-rescue:74LS109 U3
U 1 1 4E054162
P 5150 3050
F 0 "U3" H 5150 3150 60  0000 C CNN
F 1 "74LS109" H 5150 2950 60  0000 C CNN
F 2 "" H 5150 3050 50  0001 C CNN
F 3 "" H 5150 3050 50  0001 C CNN
	1    5150 3050
	1    0    0    -1  
$EndComp
Wire Wire Line
	3100 4600 1800 4600
Connection ~ 6550 3300
Wire Wire Line
	8200 3800 6550 3800
Wire Wire Line
	6550 3800 6550 3300
Wire Wire Line
	4500 3050 3900 3050
Wire Wire Line
	3900 3050 3900 3300
Wire Wire Line
	3900 3300 3050 3300
Connection ~ 4500 4600
Wire Wire Line
	4500 3300 4500 4600
Wire Wire Line
	2700 2700 2400 2700
Wire Wire Line
	9450 2800 7600 2800
Connection ~ 6200 3300
Wire Wire Line
	7500 3300 5800 3300
Wire Wire Line
	3900 2800 4500 2800
Wire Wire Line
	6300 4400 6200 4400
Wire Wire Line
	6200 4400 6200 3300
Wire Wire Line
	4000 4600 6300 4600
Wire Wire Line
	6700 2800 5800 2800
Wire Wire Line
	5150 2200 5150 2350
Wire Wire Line
	2700 2900 2400 2900
Wire Wire Line
	3050 3750 5150 3750
Wire Wire Line
	8200 2300 6550 2300
Wire Wire Line
	6550 2300 6550 2800
Connection ~ 6550 2800
Wire Wire Line
	8200 4500 7500 4500
Text GLabel 8200 4500 2    60   Output ~ 0
/BR
Text GLabel 8200 3800 2    60   Output ~ 0
/BUSAK
Text GLabel 8200 2300 2    60   Output ~ 0
BUSAK
Text GLabel 3050 3300 0    60   Input ~ 0
/CLK
Text GLabel 3050 3750 0    60   Input ~ 0
/RESET
$Comp
L babyM68K-rescue:VCC #PWR01
U 1 1 4E027D55
P 5150 2200
F 0 "#PWR01" H 5150 2300 30  0001 C CNN
F 1 "VCC" H 5150 2300 30  0000 C CNN
F 2 "" H 5150 2200 50  0001 C CNN
F 3 "" H 5150 2200 50  0001 C CNN
	1    5150 2200
	1    0    0    -1  
$EndComp
Text GLabel 9450 2800 2    60   Output ~ 0
B_/BUSAK
$Comp
L babyM68K-rescue:74LS06 U5
U 1 1 4E027D25
P 7150 2800
F 0 "U5" H 7345 2915 60  0000 C CNN
F 1 "74LS06" H 7340 2675 60  0000 C CNN
F 2 "" H 7150 2800 50  0001 C CNN
F 3 "" H 7150 2800 50  0001 C CNN
	1    7150 2800
	1    0    0    -1  
$EndComp
Text GLabel 7500 3300 2    60   Output ~ 0
/BGACK
Text GLabel 2400 2900 0    60   Input ~ 0
AS
Text GLabel 2400 2700 0    60   Input ~ 0
/BG
$Comp
L babyM68K-rescue:74LS02 U1
U 1 2 4E027C4B
P 3300 2800
F 0 "U1" H 3300 2850 60  0000 C CNN
F 1 "74LS02" H 3350 2750 60  0000 C CNN
F 2 "" H 3300 2800 50  0001 C CNN
F 3 "" H 3300 2800 50  0001 C CNN
	1    3300 2800
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:74LS00 U4
U 1 1 4E027BD0
P 6900 4500
F 0 "U4" H 6900 4550 60  0000 C CNN
F 1 "74LS00" H 6900 4400 60  0000 C CNN
F 2 "" H 6900 4500 50  0001 C CNN
F 3 "" H 6900 4500 50  0001 C CNN
	1    6900 4500
	1    0    0    -1  
$EndComp
Text GLabel 1800 4600 0    60   Input ~ 0
B_/BUSRQ
$Comp
L babyM68K-rescue:74LS14 U2
U 1 1 4E027B9B
P 3550 4600
F 0 "U2" H 3700 4700 40  0000 C CNN
F 1 "74LS14" H 3750 4500 40  0000 C CNN
F 2 "" H 3550 4600 50  0001 C CNN
F 3 "" H 3550 4600 50  0001 C CNN
	1    3550 4600
	1    0    0    -1  
$EndComp
$EndSCHEMATC
