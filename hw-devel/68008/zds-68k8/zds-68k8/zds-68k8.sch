EESchema Schematic File Version 4
LIBS:zds-ym2149-cache
EELAYER 29 0
EELAYER END
$Descr A1 33110 23386
encoding utf-8
Sheet 1 1
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Wire Wire Line
	5000 1200 2300 1200
Wire Wire Line
	2300 1200 2300 1850
Connection ~ 4400 5150
Wire Wire Line
	4400 5700 4400 5150
Wire Wire Line
	1800 3950 2900 3950
Wire Wire Line
	2900 3950 2900 3850
Wire Wire Line
	2900 3850 4650 3850
Wire Wire Line
	4650 3150 1800 3150
Wire Wire Line
	3800 3600 4650 3600
Wire Wire Line
	4650 3600 4650 3550
Wire Wire Line
	4650 3450 3800 3450
Wire Wire Line
	7300 4550 6450 4550
Wire Wire Line
	7300 4750 6450 4750
Wire Wire Line
	7300 4950 6450 4950
Wire Wire Line
	7300 5150 6450 5150
Wire Wire Line
	7300 4050 6450 4050
Wire Wire Line
	7300 3650 6450 3650
Wire Wire Line
	7300 3250 6450 3250
Wire Wire Line
	7300 2450 6450 2450
Wire Wire Line
	7300 2850 6450 2850
Wire Wire Line
	7000 4150 6450 4150
Wire Wire Line
	7000 3750 6450 3750
Wire Wire Line
	7000 3350 6450 3350
Wire Wire Line
	7000 2950 6450 2950
Wire Wire Line
	7000 2550 6450 2550
Wire Wire Line
	7000 2150 6450 2150
Wire Wire Line
	4000 5300 4200 5300
Wire Wire Line
	4200 5300 4200 3050
Wire Wire Line
	4200 3050 4650 3050
Wire Wire Line
	4650 5050 3650 5050
Wire Wire Line
	2300 4850 4650 4850
Wire Wire Line
	4650 2450 4000 2450
Wire Wire Line
	4650 2650 4000 2650
Wire Wire Line
	5000 1850 4650 1850
Connection ~ 2000 2050
Wire Wire Line
	2000 2150 2000 2050
Connection ~ 1300 2050
Wire Wire Line
	2000 1350 2000 1550
Connection ~ 1300 2150
Wire Wire Line
	1300 1850 1300 1950
Connection ~ 1300 1950
Connection ~ 2000 1950
Wire Wire Line
	4650 1850 4650 2150
Connection ~ 4650 1850
Wire Wire Line
	4650 2550 3600 2550
Wire Wire Line
	2800 4750 4650 4750
Wire Wire Line
	4650 4950 4000 4950
Wire Wire Line
	4650 5150 4400 5150
Wire Wire Line
	4650 2250 4000 2250
Wire Wire Line
	7000 2350 6450 2350
Wire Wire Line
	7000 2750 6450 2750
Wire Wire Line
	7000 3150 6450 3150
Wire Wire Line
	7000 3550 6450 3550
Wire Wire Line
	7000 3950 6450 3950
Wire Wire Line
	7300 3050 6450 3050
Wire Wire Line
	7300 2650 6450 2650
Wire Wire Line
	7300 2250 6450 2250
Wire Wire Line
	7300 3450 6450 3450
Wire Wire Line
	7300 3850 6450 3850
Wire Wire Line
	7300 4250 6450 4250
Wire Wire Line
	7000 5050 6450 5050
Wire Wire Line
	7000 4850 6450 4850
Wire Wire Line
	7000 4650 6450 4650
Wire Wire Line
	7000 4450 6450 4450
Wire Wire Line
	4650 3350 4650 3300
Wire Wire Line
	4650 3300 3800 3300
Wire Wire Line
	4650 2950 1800 2950
Wire Wire Line
	4650 3750 1800 3750
Wire Wire Line
	3800 6300 3300 6300
Wire Wire Line
	2000 1850 2300 1850
Text GLabel 5000 1200 2    60   Output ~ 0
/CLK
Text Label 2100 6200 2    60   ~ 0
FC1
Text Notes 2950 3400 0    60   ~ 0
Select.sch\n& Reset.sch
Text GLabel 3800 3600 0    60   Output ~ 0
FC2
Text GLabel 3800 3450 0    60   Output ~ 0
FC1
Text GLabel 3800 3300 0    60   Output ~ 0
FC0
$Comp
L babyM68K-rescue:74F04 U?
U 6 1 4E013A69
P 4850 5700
F 0 "U?" H 5045 5815 60  0000 C CNN
F 1 "74F04" H 5040 5575 60  0000 C CNN
F 2 "" H 4850 5700 50  0001 C CNN
F 3 "" H 4850 5700 50  0001 C CNN
	6    4850 5700
	1    0    0    -1  
$EndComp
Text GLabel 5300 5700 2    60   Output ~ 0
W/R
Text Label 2100 6400 2    60   ~ 0
/BGACK
Text Notes 4100 6350 0    60   ~ 0
to Reset.sch
Text GLabel 3800 6300 2    55   Output ~ 0
M1
$Comp
L babyM68K-rescue:74LS08 U?
U 3 1 4E00F658
P 2700 6300
F 0 "U?" H 2700 6350 60  0000 C CNN
F 1 "74LS08" H 2700 6250 60  0000 C CNN
F 2 "" H 2700 6300 50  0001 C CNN
F 3 "" H 2700 6300 50  0001 C CNN
	3    2700 6300
	1    0    0    -1  
$EndComp
NoConn ~ 1300 1750
NoConn ~ 1300 1650
NoConn ~ 1300 1550
NoConn ~ 2000 1650
NoConn ~ 2000 1750
Text GLabel 1800 3950 0    60   Input ~ 0
/BGACK
Text GLabel 1800 3750 0    60   Output ~ 0
/BG
Text GLabel 1800 2950 0    60   Input ~ 0
/BR
Text GLabel 1800 3150 0    60   Input ~ 0
/BERR
Text GLabel 7300 5150 2    60   3State ~ 0
D7
Text GLabel 7300 4950 2    60   3State ~ 0
D5
Text GLabel 7300 4750 2    60   3State ~ 0
D3
Text GLabel 7300 4550 2    60   3State ~ 0
D1
Text GLabel 7000 5050 2    60   3State ~ 0
D6
Text GLabel 7000 4850 2    60   3State ~ 0
D4
Text GLabel 7000 4650 2    60   3State ~ 0
D2
Text GLabel 7000 4450 2    60   3State ~ 0
D0
Text GLabel 7300 4250 2    60   3State ~ 0
A21
Text GLabel 7300 4050 2    60   3State ~ 0
A19
Text GLabel 7300 3850 2    60   3State ~ 0
A17
Text GLabel 7300 3650 2    60   3State ~ 0
A15
Text GLabel 7300 3450 2    60   3State ~ 0
A13
Text GLabel 7300 3250 2    60   3State ~ 0
A11
Text GLabel 7300 3050 2    60   3State ~ 0
A9
Text GLabel 7000 4150 2    60   3State ~ 0
A20
Text GLabel 7000 3950 2    60   3State ~ 0
A18
Text GLabel 7000 3750 2    60   3State ~ 0
A16
Text GLabel 7000 3550 2    60   3State ~ 0
A14
Text GLabel 7000 3350 2    60   3State ~ 0
A12
Text GLabel 7000 3150 2    60   3State ~ 0
A10
Text GLabel 7000 2950 2    60   3State ~ 0
A8
Text GLabel 7300 2850 2    60   3State ~ 0
A7
Text GLabel 7300 2650 2    60   3State ~ 0
A5
Text GLabel 7000 2750 2    60   3State ~ 0
A6
Text GLabel 7000 2550 2    60   3State ~ 0
A4
Text GLabel 7300 2450 2    60   3State ~ 0
A3
Text GLabel 7000 2350 2    60   3State ~ 0
A2
Text GLabel 7300 2250 2    60   3State ~ 0
A1
Text GLabel 7000 2150 2    60   3State ~ 0
A0
Text GLabel 2300 4850 0    60   Input ~ 0
/RESET
Text GLabel 2800 4750 0    60   Input ~ 0
/HALT
Text GLabel 4000 5150 0    60   Input ~ 0
R/W
Text GLabel 3650 5050 0    60   Input ~ 0
/DS
Text GLabel 4000 4950 0    60   Input ~ 0
/AS
Text GLabel 4000 5300 0    60   Input ~ 0
/DTACK
NoConn ~ 4650 3950
Text GLabel 4000 2650 0    60   Input ~ 0
/IPL2
Text GLabel 3600 2550 0    60   Input ~ 0
/IPL1
Text GLabel 4000 2450 0    60   Input ~ 0
/IPL0
Text GLabel 4000 2250 0    60   Input ~ 0
/VPA
Text GLabel 5000 1850 2    60   Output ~ 0
CLK
$Comp
L babyM68K-rescue:74F04 U?
U 4 1 4DFF899B
P 2750 1850
F 0 "U?" H 2945 1965 60  0000 C CNN
F 1 "74F04" H 2940 1725 60  0000 C CNN
F 2 "" H 2750 1850 50  0001 C CNN
F 3 "" H 2750 1850 50  0001 C CNN
	4    2750 1850
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:GND #PWR?
U 1 1 4DFF8938
P 1300 2550
F 0 "#PWR?" H 1300 2550 30  0001 C CNN
F 1 "GND" H 1300 2480 30  0001 C CNN
F 2 "" H 1300 2550 50  0001 C CNN
F 3 "" H 1300 2550 50  0001 C CNN
	1    1300 2550
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:VCC #PWR?
U 1 1 4DFF891F
P 2000 1350
F 0 "#PWR?" H 2000 1450 30  0001 C CNN
F 1 "VCC" H 2000 1450 30  0000 C CNN
F 2 "" H 2000 1350 50  0001 C CNN
F 3 "" H 2000 1350 50  0001 C CNN
	1    2000 1350
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:DIL14 U?
U 1 1 4DFF88DD
P 1650 1850
F 0 "U?" H 1650 2250 60  0000 C CNN
F 1 "OSC 8Mhz" V 1650 1850 50  0000 C CNN
F 2 "" H 1650 1850 50  0001 C CNN
F 3 "" H 1650 1850 50  0001 C CNN
	1    1650 1850
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:68008FN U?
U 1 1 4DFF8621
P 5550 3650
F 0 "U?" H 5550 3750 70  0000 C CNN
F 1 "68008FN" H 5550 3550 70  0000 C CNN
F 2 "PLCC52" H 5550 3400 60  0000 C CNN
F 3 "" H 5550 3650 50  0001 C CNN
	1    5550 3650
	1    0    0    -1  
$EndComp
Wire Wire Line
	4400 5150 4000 5150
Wire Wire Line
	2000 2050 2000 1950
Wire Wire Line
	1300 2050 1300 2150
Wire Wire Line
	1300 2150 1300 2550
Wire Wire Line
	1300 1950 1300 2050
Wire Wire Line
	2000 1950 2000 1850
Wire Wire Line
	3200 1850 4650 1850
Connection ~ 2000 1850
Connection ~ 2300 1850
$Comp
L babyM68K-rescue:74LS109 U?
U 1 1 4E054162
P 5100 10450
F 0 "U?" H 5100 10550 60  0000 C CNN
F 1 "74LS109" H 5100 10350 60  0000 C CNN
F 2 "" H 5100 10450 50  0001 C CNN
F 3 "" H 5100 10450 50  0001 C CNN
	1    5100 10450
	1    0    0    -1  
$EndComp
Wire Wire Line
	3050 12000 1750 12000
Connection ~ 6500 10700
Wire Wire Line
	8150 11200 6500 11200
Wire Wire Line
	6500 11200 6500 10700
Wire Wire Line
	4450 10450 3850 10450
Wire Wire Line
	3850 10450 3850 10700
Wire Wire Line
	3850 10700 3000 10700
Connection ~ 4450 12000
Wire Wire Line
	4450 10700 4450 12000
Wire Wire Line
	2650 10100 2350 10100
Wire Wire Line
	9400 10200 7550 10200
Connection ~ 6150 10700
Wire Wire Line
	7450 10700 6500 10700
Wire Wire Line
	3850 10200 4450 10200
Wire Wire Line
	6250 11800 6150 11800
Wire Wire Line
	6150 11800 6150 10700
Wire Wire Line
	3950 12000 4450 12000
Wire Wire Line
	6650 10200 6500 10200
Wire Wire Line
	5100 9600 5100 9750
Wire Wire Line
	2650 10300 2350 10300
Wire Wire Line
	3000 11150 5100 11150
Wire Wire Line
	8150 9700 6500 9700
Wire Wire Line
	6500 9700 6500 10200
Connection ~ 6500 10200
Wire Wire Line
	8150 11900 7450 11900
Text GLabel 8150 11900 2    60   Output ~ 0
/BR
Text GLabel 8150 11200 2    60   Output ~ 0
/BUSAK
Text GLabel 8150 9700 2    60   Output ~ 0
BUSAK
Text GLabel 3000 10700 0    60   Input ~ 0
/CLK
Text GLabel 3000 11150 0    60   Input ~ 0
/RESET
$Comp
L babyM68K-rescue:VCC #PWR?
U 1 1 4E027D55
P 5100 9600
F 0 "#PWR?" H 5100 9700 30  0001 C CNN
F 1 "VCC" H 5100 9700 30  0000 C CNN
F 2 "" H 5100 9600 50  0001 C CNN
F 3 "" H 5100 9600 50  0001 C CNN
	1    5100 9600
	1    0    0    -1  
$EndComp
Text GLabel 9400 10200 2    60   Output ~ 0
B_/BUSAK
$Comp
L babyM68K-rescue:74LS06 U?
U 1 1 4E027D25
P 7100 10200
F 0 "U?" H 7295 10315 60  0000 C CNN
F 1 "74LS06" H 7290 10075 60  0000 C CNN
F 2 "" H 7100 10200 50  0001 C CNN
F 3 "" H 7100 10200 50  0001 C CNN
	1    7100 10200
	1    0    0    -1  
$EndComp
Text GLabel 7450 10700 2    60   Output ~ 0
/BGACK
Text GLabel 2350 10300 0    60   Input ~ 0
AS
Text GLabel 2350 10100 0    60   Input ~ 0
/BG
$Comp
L babyM68K-rescue:74LS02 U?
U 1 2 4E027C4B
P 3250 10200
F 0 "U?" H 3250 10250 60  0000 C CNN
F 1 "74LS02" H 3300 10150 60  0000 C CNN
F 2 "" H 3250 10200 50  0001 C CNN
F 3 "" H 3250 10200 50  0001 C CNN
	1    3250 10200
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:74LS00 U?
U 1 1 4E027BD0
P 6850 11900
F 0 "U?" H 6850 11950 60  0000 C CNN
F 1 "74LS00" H 6850 11800 60  0000 C CNN
F 2 "" H 6850 11900 50  0001 C CNN
F 3 "" H 6850 11900 50  0001 C CNN
	1    6850 11900
	1    0    0    -1  
$EndComp
Text GLabel 1750 12000 0    60   Input ~ 0
B_/BUSRQ
$Comp
L babyM68K-rescue:74LS14 U?
U 1 1 4E027B9B
P 3500 12000
F 0 "U?" H 3650 12100 40  0000 C CNN
F 1 "74LS14" H 3700 11900 40  0000 C CNN
F 2 "" H 3500 12000 50  0001 C CNN
F 3 "" H 3500 12000 50  0001 C CNN
	1    3500 12000
	1    0    0    -1  
$EndComp
Wire Wire Line
	6500 10700 6150 10700
Wire Wire Line
	4450 12000 6250 12000
Wire Wire Line
	6150 10700 5750 10700
Wire Wire Line
	6500 10200 5750 10200
Wire Wire Line
	11100 4200 11500 4200
Wire Wire Line
	10450 7350 10700 7350
Wire Wire Line
	9900 4250 9450 4250
Wire Wire Line
	9450 4250 9450 4500
Wire Wire Line
	9450 4500 9100 4500
Wire Wire Line
	9900 4050 9600 4050
Wire Wire Line
	9600 4050 9600 4000
Wire Wire Line
	9600 4000 9100 4000
Wire Wire Line
	12700 2150 12700 2350
Wire Wire Line
	11950 2900 11700 2900
Wire Wire Line
	11500 4400 11400 4400
Wire Wire Line
	11400 4400 11400 5150
Wire Wire Line
	11400 5150 9850 5150
Connection ~ 11700 2900
Wire Wire Line
	11700 2350 11700 2900
Wire Wire Line
	12600 1450 11650 1450
Wire Wire Line
	16600 2900 16050 2900
Wire Wire Line
	16600 5350 15550 5350
Connection ~ 16050 3400
Wire Wire Line
	16050 3400 16050 3900
Wire Wire Line
	15250 3400 16050 3400
Wire Wire Line
	13500 1450 16050 1450
Wire Wire Line
	10700 6850 10250 6850
Wire Wire Line
	10700 6550 10500 6550
Wire Wire Line
	10500 6550 10500 6350
Wire Wire Line
	9550 1450 10750 1450
Wire Wire Line
	16050 3900 16600 3900
Wire Wire Line
	10200 3150 9550 3150
Wire Wire Line
	13700 6150 14350 6150
Wire Wire Line
	14350 6150 14350 5500
Wire Wire Line
	10700 7150 10300 7150
Wire Wire Line
	9600 7250 10700 7250
Wire Wire Line
	16050 1450 16050 2900
Connection ~ 16050 2900
Wire Wire Line
	11700 2350 12700 2350
Wire Wire Line
	13450 2900 14350 2900
Wire Wire Line
	11700 3400 11950 3400
Wire Wire Line
	11100 3150 11950 3150
Wire Wire Line
	12700 4300 12700 3950
Wire Wire Line
	14350 2900 14350 3400
Connection ~ 14350 3400
Wire Wire Line
	9900 4150 9600 4150
Wire Wire Line
	9600 4150 9600 4200
Wire Wire Line
	9600 4200 9100 4200
Wire Wire Line
	9100 4700 9700 4700
Wire Wire Line
	9700 4700 9700 4350
Wire Wire Line
	9700 4350 9900 4350
Wire Wire Line
	9600 7450 10700 7450
Text GLabel 9600 7450 0    60   Output ~ 0
PU_MEM64K/4K
Text GLabel 10450 7350 0    60   Output ~ 0
PU_MEM4K/1K
$Comp
L babyM68K-rescue:74LS20 U?
U 2 1 5101E6FB
P 10500 4200
F 0 "U?" H 10500 4300 60  0000 C CNN
F 1 "74LS20" H 10500 4100 60  0000 C CNN
F 2 "" H 10500 4200 50  0001 C CNN
F 3 "" H 10500 4200 50  0001 C CNN
	2    10500 4200
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:74LS109 U?
U 2 1 4E0540C4
P 12700 3150
F 0 "U?" H 12700 3250 60  0000 C CNN
F 1 "74LS109" H 12700 3050 60  0000 C CNN
F 2 "" H 12700 3150 50  0001 C CNN
F 3 "" H 12700 3150 50  0001 C CNN
	2    12700 3150
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:74LS06 U?
U 4 1 4E02576A
P 14800 3400
F 0 "U?" H 14995 3515 60  0000 C CNN
F 1 "74LS06" H 14990 3275 60  0000 C CNN
F 2 "" H 14800 3400 50  0001 C CNN
F 3 "" H 14800 3400 50  0001 C CNN
	4    14800 3400
	1    0    0    -1  
$EndComp
NoConn ~ 13450 3400
Text GLabel 9100 4700 0    60   Input ~ 0
IORQ
Text GLabel 9100 4500 0    60   Input ~ 0
M1
Text GLabel 9100 4200 0    60   Input ~ 0
A3
Text GLabel 9100 4000 0    60   Input ~ 0
A1
Text GLabel 9850 5150 0    60   Input ~ 0
/RESET
$Comp
L babyM68K-rescue:74LS08 U?
U 4 2 4E053C90
P 12100 4300
F 0 "U?" H 12100 4350 60  0000 C CNN
F 1 "74LS08" H 12100 4250 60  0000 C CNN
F 2 "" H 12100 4300 50  0001 C CNN
F 3 "" H 12100 4300 50  0001 C CNN
	4    12100 4300
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:VCC #PWR?
U 1 1 4E053B5D
P 12700 2150
F 0 "#PWR?" H 12700 2250 30  0001 C CNN
F 1 "VCC" H 12700 2250 30  0000 C CNN
F 2 "" H 12700 2150 50  0001 C CNN
F 3 "" H 12700 2150 50  0001 C CNN
	1    12700 2150
	1    0    0    -1  
$EndComp
Text GLabel 9600 7250 0    60   Output ~ 0
B_/BUSAK
Text GLabel 10300 7150 0    60   Output ~ 0
B_/BUSRQ
Text GLabel 16600 5350 2    60   Output ~ 0
/VPA
Text GLabel 13700 6150 0    60   Input ~ 0
AS
$Comp
L babyM68K-rescue:74LS10 U?
U 2 1 4E0260ED
P 14950 5350
F 0 "U?" H 14950 5400 60  0000 C CNN
F 1 "74LS10" H 14950 5300 60  0000 C CNN
F 2 "" H 14950 5350 50  0001 C CNN
F 3 "" H 14950 5350 50  0001 C CNN
	2    14950 5350
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:74LS14 U?
U 4 2 4E0260DB
P 13900 5350
F 0 "U?" H 14050 5450 40  0000 C CNN
F 1 "74LS14" H 14100 5250 40  0000 C CNN
F 2 "" H 13900 5350 50  0001 C CNN
F 3 "" H 13900 5350 50  0001 C CNN
	4    13900 5350
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:74LS14 U?
U 3 2 4E0260B1
P 10650 3150
F 0 "U?" H 10800 3250 40  0000 C CNN
F 1 "74LS14" H 10850 3050 40  0000 C CNN
F 2 "" H 10650 3150 50  0001 C CNN
F 3 "" H 10650 3150 50  0001 C CNN
	3    10650 3150
	1    0    0    -1  
$EndComp
Text GLabel 12250 5500 0    60   Input ~ 0
FC2
Text GLabel 12250 5350 0    60   Input ~ 0
FC1
Text GLabel 12250 5200 0    60   Input ~ 0
FC0
$Comp
L babyM68K-rescue:74LS10 U?
U 1 1 4E025FEB
P 12850 5350
F 0 "U?" H 12850 5400 60  0000 C CNN
F 1 "74LS10" H 12850 5300 60  0000 C CNN
F 2 "" H 12850 5350 50  0001 C CNN
F 3 "" H 12850 5350 50  0001 C CNN
	1    12850 5350
	1    0    0    -1  
$EndComp
Text GLabel 16600 3400 2    60   Output ~ 0
/IPL0
Text GLabel 16600 3900 2    60   Output ~ 0
/IPL2
$Comp
L babyM68K-rescue:74LS06 U?
U 3 1 4E025758
P 14800 2900
F 0 "U?" H 14995 3015 60  0000 C CNN
F 1 "74LS06" H 14990 2775 60  0000 C CNN
F 2 "" H 14800 2900 50  0001 C CNN
F 3 "" H 14800 2900 50  0001 C CNN
	3    14800 2900
	1    0    0    -1  
$EndComp
Text GLabel 9550 3150 0    60   Input ~ 0
B_/NMI
Text GLabel 16600 2900 2    60   Output ~ 0
/IPL1
$Comp
L babyM68K-rescue:74LS06 U?
U 2 1 4E025673
P 13050 1450
F 0 "U?" H 13245 1565 60  0000 C CNN
F 1 "74LS06" H 13240 1325 60  0000 C CNN
F 2 "" H 13050 1450 50  0001 C CNN
F 3 "" H 13050 1450 50  0001 C CNN
	2    13050 1450
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:74LS14 U?
U 2 2 4E025666
P 11200 1450
F 0 "U?" H 11350 1550 40  0000 C CNN
F 1 "74LS14" H 11400 1350 40  0000 C CNN
F 2 "" H 11200 1450 50  0001 C CNN
F 3 "" H 11200 1450 50  0001 C CNN
	2    11200 1450
	1    0    0    -1  
$EndComp
Text Label 10700 7050 2    60   ~ 0
/IPL2
Text Label 10700 6950 2    60   ~ 0
/IPL1
Text GLabel 10250 6850 0    60   Output ~ 0
B_/RFSH
Text Label 10700 6750 2    60   ~ 0
B_/NMI
Text Label 10700 6650 2    60   ~ 0
B_/INT
$Comp
L babyM68K-rescue:VCC #PWR?
U 1 1 4E025525
P 10500 6350
F 0 "#PWR?" H 10500 6450 30  0001 C CNN
F 1 "VCC" H 10500 6450 30  0000 C CNN
F 2 "" H 10500 6350 50  0001 C CNN
F 3 "" H 10500 6350 50  0001 C CNN
	1    10500 6350
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:RR9 RR?
U 1 1 4E02550B
P 11050 7050
F 0 "RR?" H 11100 7650 70  0000 C CNN
F 1 "4700 bussed" V 11080 7050 70  0000 C CNN
F 2 "" H 11050 7050 50  0001 C CNN
F 3 "" H 11050 7050 50  0001 C CNN
	1    11050 7050
	1    0    0    -1  
$EndComp
Text GLabel 9550 1450 0    60   Input ~ 0
B_/INT
Connection ~ 12700 2350
Connection ~ 14350 2900
Wire Wire Line
	11700 2900 11700 3400
Wire Wire Line
	16050 3400 16600 3400
Wire Wire Line
	16050 2900 15250 2900
Wire Wire Line
	14350 3400 14350 5200
Wire Wire Line
	16000 14350 14850 14350
Connection ~ 17550 12950
Wire Wire Line
	18850 12950 17550 12950
Wire Wire Line
	20900 13050 20550 13050
Connection ~ 15550 13400
Wire Wire Line
	15550 12050 15550 13400
Wire Wire Line
	15550 12050 15750 12050
Wire Wire Line
	16200 14350 17550 14350
Wire Wire Line
	17550 14350 17550 13700
Wire Wire Line
	15550 13700 15550 13550
Wire Wire Line
	15550 13550 15700 13550
Wire Wire Line
	16900 13400 17550 13400
Wire Wire Line
	17550 13400 17550 12950
Wire Wire Line
	17050 12950 17050 12550
Wire Wire Line
	17050 12550 17250 12550
Connection ~ 17050 11650
Wire Wire Line
	17250 12350 17050 12350
Wire Wire Line
	17050 12350 17050 11650
Wire Wire Line
	20700 11750 20050 11750
Wire Wire Line
	18850 11650 17050 11650
Wire Wire Line
	18850 11850 18850 12050
Wire Wire Line
	11950 10650 11700 10650
Wire Wire Line
	11700 10650 11700 10750
Wire Wire Line
	11700 10750 11400 10750
Wire Wire Line
	11850 11350 12150 11350
Wire Wire Line
	12950 11250 13050 11250
Wire Wire Line
	13050 11250 13050 11150
Wire Wire Line
	13350 8750 13600 8750
Wire Wire Line
	13350 9150 13600 9150
Wire Wire Line
	11950 8750 11700 8750
Wire Wire Line
	11700 9150 11950 9150
Wire Wire Line
	11700 9550 11950 9550
Wire Wire Line
	11700 9950 11950 9950
Wire Wire Line
	11700 10150 11950 10150
Wire Wire Line
	11950 9750 11700 9750
Wire Wire Line
	11950 9350 11700 9350
Wire Wire Line
	11950 8950 11700 8950
Wire Wire Line
	11700 8550 11950 8550
Wire Wire Line
	13350 8950 13600 8950
Wire Wire Line
	13350 8550 13600 8550
Wire Wire Line
	11950 10250 11800 10250
Wire Wire Line
	11800 10250 11800 11250
Wire Wire Line
	11800 11250 12150 11250
Wire Wire Line
	11950 10350 11900 10350
Wire Wire Line
	11900 10350 11900 11700
Wire Wire Line
	11900 11700 12950 11700
Wire Wire Line
	12950 11700 12950 11350
Wire Wire Line
	11950 10550 11700 10550
Wire Wire Line
	18350 12050 18850 12050
Connection ~ 18850 12050
Wire Wire Line
	20700 12350 20050 12350
Wire Wire Line
	13150 12850 13650 12850
Wire Wire Line
	14850 12550 15150 12550
Wire Wire Line
	15150 12550 15150 13250
Wire Wire Line
	15150 13250 15700 13250
Wire Wire Line
	18450 12450 18850 12450
Wire Wire Line
	13650 13250 13000 13250
Wire Wire Line
	13000 13250 13000 13450
Wire Wire Line
	15050 13400 15550 13400
Wire Wire Line
	17900 13700 17550 13700
Connection ~ 17550 13700
Wire Wire Line
	20050 13050 20350 13050
Wire Wire Line
	18400 13150 18850 13150
$Comp
L babyM68K-rescue:74LS02 U?
U 3 2 5228C292
P 14250 14350
F 0 "U?" H 14250 14400 60  0000 C CNN
F 1 "74LS02" H 14300 14300 60  0000 C CNN
F 2 "" H 14250 14350 50  0001 C CNN
F 3 "" H 14250 14350 50  0001 C CNN
	3    14250 14350
	1    0    0    -1  
$EndComp
Text Notes 12350 13050 0    60   ~ 0
from select.sch
Text GLabel 18400 13150 0    60   Input ~ 0
R/W
Text Notes 20800 12850 0    60   ~ 0
pull-up on\nselect.sch
$Comp
L babyM68K-rescue:CONN_2 J?
U 1 1 51028C32
P 20450 13400
F 0 "J?" V 20400 13400 40  0000 C CNN
F 1 "CONN_2" V 20500 13400 40  0000 C CNN
F 2 "" H 20450 13400 50  0001 C CNN
F 3 "" H 20450 13400 50  0001 C CNN
	1    20450 13400
	0    1    1    0   
$EndComp
$Comp
L babyM68K-rescue:74LS32 U?
U 3 2 51028BBC
P 19450 13050
F 0 "U?" H 19450 13100 60  0000 C CNN
F 1 "74LS32" H 19450 13000 60  0000 C CNN
F 2 "" H 19450 13050 50  0001 C CNN
F 3 "" H 19450 13050 50  0001 C CNN
	3    19450 13050
	1    0    0    -1  
$EndComp
Text GLabel 15750 12050 2    60   Input ~ 0
PU_MEM64K/4K
Text GLabel 17900 13700 2    60   Input ~ 0
PU_MEM4K/1K
$Comp
L babyM68K-rescue:CONN_2 J?
U 1 1 5101EED9
P 14950 13750
F 0 "J?" V 14900 13750 40  0000 C CNN
F 1 "CONN_2" V 15000 13750 40  0000 C CNN
F 2 "" H 14950 13750 50  0001 C CNN
F 3 "" H 14950 13750 50  0001 C CNN
	1    14950 13750
	0    1    1    0   
$EndComp
$Comp
L babyM68K-rescue:CONN_2 J?
U 1 1 5101EE74
P 16100 14700
F 0 "J?" V 16050 14700 40  0000 C CNN
F 1 "CONN_2" V 16150 14700 40  0000 C CNN
F 2 "" H 16100 14700 50  0001 C CNN
F 3 "" H 16100 14700 50  0001 C CNN
	1    16100 14700
	0    1    1    0   
$EndComp
Text Label 17200 12950 0    60   ~ 0
/USERLOWMEM
$Comp
L babyM68K-rescue:74LS260 U?
U 1 2 5101E528
P 14250 12550
F 0 "U?" H 14250 12600 60  0000 C CNN
F 1 "74LS260" H 14250 12500 60  0000 C CNN
F 2 "" H 14250 12550 50  0001 C CNN
F 3 "" H 14250 12550 50  0001 C CNN
	1    14250 12550
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:GND #PWR?
U 1 1 5101E4D1
P 13000 13450
F 0 "#PWR?" H 13000 13450 30  0001 C CNN
F 1 "GND" H 13000 13380 30  0001 C CNN
F 2 "" H 13000 13450 50  0001 C CNN
F 3 "" H 13000 13450 50  0001 C CNN
	1    13000 13450
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:74LS00 U?
U 3 1 5101E300
P 17850 12450
F 0 "U?" H 17850 12500 60  0000 C CNN
F 1 "74LS00" H 17850 12350 60  0000 C CNN
F 2 "" H 17850 12450 50  0001 C CNN
F 3 "" H 17850 12450 50  0001 C CNN
	3    17850 12450
	1    0    0    -1  
$EndComp
Text GLabel 20900 13050 2    60   Output ~ 0
/BERR
$Comp
L babyM68K-rescue:74LS10 U?
U 3 1 5101DF9B
P 16300 13400
F 0 "U?" H 16300 13450 60  0000 C CNN
F 1 "74LS10" H 16300 13350 60  0000 C CNN
F 2 "" H 16300 13400 50  0001 C CNN
F 3 "" H 16300 13400 50  0001 C CNN
	3    16300 13400
	1    0    0    -1  
$EndComp
Text GLabel 13150 12850 0    60   Input ~ 0
SUPV/USER
Text Label 13650 12700 2    60   ~ 0
/CSRAM0
Text Label 13650 14450 2    60   ~ 0
A10
Text Label 13650 14250 2    60   ~ 0
A11
Text Label 13650 12250 2    60   ~ 0
A18
Text Label 13650 12400 2    60   ~ 0
A17
Text Label 13650 12550 2    60   ~ 0
A16
Text Label 13650 13400 2    60   ~ 0
A14
Text Label 13650 13100 2    60   ~ 0
A15
Text Label 13650 13550 2    60   ~ 0
A13
Text Label 13650 13700 2    60   ~ 0
A12
$Comp
L babyM68K-rescue:74LS260 U?
U 2 2 5101DC7B
P 14250 13400
F 0 "U?" H 14250 13450 60  0000 C CNN
F 1 "74LS260" H 14250 13350 60  0000 C CNN
F 2 "" H 14250 13400 50  0001 C CNN
F 3 "" H 14250 13400 50  0001 C CNN
	2    14250 13400
	1    0    0    -1  
$EndComp
Text GLabel 20700 12350 2    60   Output ~ 0
/WR
Text GLabel 20700 11750 2    60   Output ~ 0
/RD
$Comp
L babyM68K-rescue:74LS32 U?
U 2 2 4E01537D
P 19450 12350
F 0 "U?" H 19450 12400 60  0000 C CNN
F 1 "74LS32" H 19450 12300 60  0000 C CNN
F 2 "" H 19450 12350 50  0001 C CNN
F 3 "" H 19450 12350 50  0001 C CNN
	2    19450 12350
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:74LS32 U?
U 1 2 4E015372
P 19450 11750
F 0 "U?" H 19450 11800 60  0000 C CNN
F 1 "74LS32" H 19450 11700 60  0000 C CNN
F 2 "" H 19450 11750 50  0001 C CNN
F 3 "" H 19450 11750 50  0001 C CNN
	1    19450 11750
	1    0    0    -1  
$EndComp
Text GLabel 16450 11650 0    60   Input ~ 0
W/R
Text GLabel 18350 12050 0    60   Input ~ 0
/DS
Text Label 11600 10750 2    60   ~ 0
/RD
Text GLabel 11700 10550 0    60   Input ~ 0
/ROM
Text Notes 11950 11900 0    60   ~ 0
128K, 256K, 512K Flash\n    1-2, 3-4
Text Notes 12200 12250 0    60   ~ 0
512K EPROM\n   1-3, 2-4
$Comp
L babyM68K-rescue:VCC #PWR?
U 1 1 4E014ED1
P 13050 11150
F 0 "#PWR?" H 13050 11250 30  0001 C CNN
F 1 "VCC" H 13050 11250 30  0000 C CNN
F 2 "" H 13050 11150 50  0001 C CNN
F 3 "" H 13050 11150 50  0001 C CNN
	1    13050 11150
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:CONN_2X2 J?
U 1 1 4E014D97
P 12550 11300
F 0 "J?" H 12550 11500 50  0000 C CNN
F 1 "FLSH/EPR" H 12550 11100 50  0000 C CNN
F 2 "" H 12550 11300 50  0001 C CNN
F 3 "" H 12550 11300 50  0001 C CNN
	1    12550 11300
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:29F040 U?
U 1 1 4E014CFD
P 12650 9350
F 0 "U?" H 12650 9250 70  0000 C CNN
F 1 "29F040" H 12750 9050 70  0000 C CNN
F 2 "" H 12650 9350 50  0001 C CNN
F 3 "" H 12650 9350 50  0001 C CNN
	1    12650 9350
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:SRAM_512K U?
U 1 1 4E014957
P 18750 9550
F 0 "U?" H 18750 9650 60  0000 C CNN
F 1 "SRAM_512K" H 18800 8750 60  0000 C CNN
F 2 "" H 18750 9550 50  0001 C CNN
F 3 "" H 18750 9550 50  0001 C CNN
	1    18750 9550
	1    0    0    -1  
$EndComp
Text Label 18050 8450 2    60   ~ 0
A0
Text Label 18050 8550 2    60   ~ 0
A1
Text Label 18050 8650 2    60   ~ 0
A2
Text Label 18050 8750 2    60   ~ 0
A3
Text Label 18050 8850 2    60   ~ 0
A4
Text Label 18050 8950 2    60   ~ 0
A5
Text Label 18050 9050 2    60   ~ 0
A6
Text Label 18050 9150 2    60   ~ 0
A7
Text Label 18050 9250 2    60   ~ 0
A8
Text Label 18050 9350 2    60   ~ 0
A9
Text Label 18050 9450 2    60   ~ 0
A10
Text Label 18050 9550 2    60   ~ 0
A11
Text Label 18050 9650 2    60   ~ 0
A12
Text Label 18050 9750 2    60   ~ 0
A13
Text Label 18050 9850 2    60   ~ 0
A14
Text Label 18050 9950 2    60   ~ 0
A15
Text Label 18050 10050 2    60   ~ 0
A16
Text Label 18050 10150 2    60   ~ 0
A17
Text Label 18050 10250 2    60   ~ 0
A18
Text Label 19450 8450 0    60   ~ 0
D0
Text Label 19450 8550 0    60   ~ 0
D1
Text Label 19450 8650 0    60   ~ 0
D2
Text Label 19450 8750 0    60   ~ 0
D3
Text Label 19450 8850 0    60   ~ 0
D4
Text Label 19450 8950 0    60   ~ 0
D5
Text Label 19450 9050 0    60   ~ 0
D6
Text Label 19450 9150 0    60   ~ 0
D7
Text Label 18050 10450 2    60   ~ 0
/RD
Text Label 18050 10550 2    60   ~ 0
/WR
Text GLabel 18050 10650 0    60   Input ~ 0
/CSRAM2
Text GLabel 19950 10650 0    60   Input ~ 0
/CSRAM3
Text Label 19950 10550 2    60   ~ 0
/WR
Text Label 19950 10450 2    60   ~ 0
/RD
Text Label 21350 9150 0    60   ~ 0
D7
Text Label 21350 9050 0    60   ~ 0
D6
Text Label 21350 8950 0    60   ~ 0
D5
Text Label 21350 8850 0    60   ~ 0
D4
Text Label 21350 8750 0    60   ~ 0
D3
Text Label 21350 8650 0    60   ~ 0
D2
Text Label 21350 8550 0    60   ~ 0
D1
Text Label 21350 8450 0    60   ~ 0
D0
Text Label 19950 10250 2    60   ~ 0
A18
Text Label 19950 10150 2    60   ~ 0
A17
Text Label 19950 10050 2    60   ~ 0
A16
Text Label 19950 9950 2    60   ~ 0
A15
Text Label 19950 9850 2    60   ~ 0
A14
Text Label 19950 9750 2    60   ~ 0
A13
Text Label 19950 9650 2    60   ~ 0
A12
Text Label 19950 9550 2    60   ~ 0
A11
Text Label 19950 9450 2    60   ~ 0
A10
Text Label 19950 9350 2    60   ~ 0
A9
Text Label 19950 9250 2    60   ~ 0
A8
Text Label 19950 9150 2    60   ~ 0
A7
Text Label 19950 9050 2    60   ~ 0
A6
Text Label 19950 8950 2    60   ~ 0
A5
Text Label 19950 8850 2    60   ~ 0
A4
Text Label 19950 8750 2    60   ~ 0
A3
Text Label 19950 8650 2    60   ~ 0
A2
Text Label 19950 8550 2    60   ~ 0
A1
Text Label 19950 8450 2    60   ~ 0
A0
$Comp
L babyM68K-rescue:SRAM_512K U?
U 1 1 4E014938
P 20650 9550
F 0 "U?" H 20650 9650 60  0000 C CNN
F 1 "SRAM_512K" H 20700 8750 60  0000 C CNN
F 2 "" H 20650 9550 50  0001 C CNN
F 3 "" H 20650 9550 50  0001 C CNN
	1    20650 9550
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:SRAM_512K U?
U 1 1 4E014925
P 16850 9550
F 0 "U?" H 16850 9650 60  0000 C CNN
F 1 "SRAM_512K" H 16900 8750 60  0000 C CNN
F 2 "" H 16850 9550 50  0001 C CNN
F 3 "" H 16850 9550 50  0001 C CNN
	1    16850 9550
	1    0    0    -1  
$EndComp
Text Label 16150 8450 2    60   ~ 0
A0
Text Label 16150 8550 2    60   ~ 0
A1
Text Label 16150 8650 2    60   ~ 0
A2
Text Label 16150 8750 2    60   ~ 0
A3
Text Label 16150 8850 2    60   ~ 0
A4
Text Label 16150 8950 2    60   ~ 0
A5
Text Label 16150 9050 2    60   ~ 0
A6
Text Label 16150 9150 2    60   ~ 0
A7
Text Label 16150 9250 2    60   ~ 0
A8
Text Label 16150 9350 2    60   ~ 0
A9
Text Label 16150 9450 2    60   ~ 0
A10
Text Label 16150 9550 2    60   ~ 0
A11
Text Label 16150 9650 2    60   ~ 0
A12
Text Label 16150 9750 2    60   ~ 0
A13
Text Label 16150 9850 2    60   ~ 0
A14
Text Label 16150 9950 2    60   ~ 0
A15
Text Label 16150 10050 2    60   ~ 0
A16
Text Label 16150 10150 2    60   ~ 0
A17
Text Label 16150 10250 2    60   ~ 0
A18
Text Label 17550 8450 0    60   ~ 0
D0
Text Label 17550 8550 0    60   ~ 0
D1
Text Label 17550 8650 0    60   ~ 0
D2
Text Label 17550 8750 0    60   ~ 0
D3
Text Label 17550 8850 0    60   ~ 0
D4
Text Label 17550 8950 0    60   ~ 0
D5
Text Label 17550 9050 0    60   ~ 0
D6
Text Label 17550 9150 0    60   ~ 0
D7
Text Label 16150 10450 2    60   ~ 0
/RD
Text Label 16150 10550 2    60   ~ 0
/WR
Text GLabel 16150 10650 0    60   Input ~ 0
/CSRAM1
Text GLabel 14250 10650 0    60   Input ~ 0
/CSRAM0
Text Label 14250 10550 2    60   ~ 0
/WR
Text Label 14250 10450 2    60   ~ 0
/RD
Text Label 15650 9150 0    60   ~ 0
D7
Text Label 15650 9050 0    60   ~ 0
D6
Text Label 15650 8950 0    60   ~ 0
D5
Text Label 15650 8850 0    60   ~ 0
D4
Text Label 15650 8750 0    60   ~ 0
D3
Text Label 15650 8650 0    60   ~ 0
D2
Text Label 15650 8550 0    60   ~ 0
D1
Text Label 15650 8450 0    60   ~ 0
D0
Text Label 14250 10250 2    60   ~ 0
A18
Text Label 14250 10150 2    60   ~ 0
A17
Text Label 14250 10050 2    60   ~ 0
A16
Text Label 14250 9950 2    60   ~ 0
A15
Text Label 14250 9850 2    60   ~ 0
A14
Text Label 14250 9750 2    60   ~ 0
A13
Text Label 14250 9650 2    60   ~ 0
A12
Text Label 14250 9550 2    60   ~ 0
A11
Text Label 14250 9450 2    60   ~ 0
A10
Text Label 14250 9350 2    60   ~ 0
A9
Text Label 14250 9250 2    60   ~ 0
A8
Text Label 14250 9150 2    60   ~ 0
A7
Text Label 14250 9050 2    60   ~ 0
A6
Text Label 14250 8950 2    60   ~ 0
A5
Text Label 14250 8850 2    60   ~ 0
A4
Text Label 14250 8750 2    60   ~ 0
A3
Text Label 14250 8650 2    60   ~ 0
A2
Text Label 14250 8550 2    60   ~ 0
A1
Text Label 14250 8450 2    60   ~ 0
A0
Text GLabel 13600 9150 2    60   BiDi ~ 0
D7
Text GLabel 13350 9050 2    60   BiDi ~ 0
D6
Text GLabel 13600 8950 2    60   BiDi ~ 0
D5
Text GLabel 13350 8850 2    60   BiDi ~ 0
D4
Text GLabel 13600 8750 2    60   BiDi ~ 0
D3
Text GLabel 13350 8650 2    60   BiDi ~ 0
D2
Text GLabel 13600 8550 2    60   BiDi ~ 0
D1
Text GLabel 13350 8450 2    60   BiDi ~ 0
D0
Text GLabel 11850 11350 0    60   Input ~ 0
A18
Text GLabel 11700 10150 0    60   Input ~ 0
A17
Text GLabel 11950 10050 0    60   Input ~ 0
A16
Text GLabel 11700 9950 0    60   Input ~ 0
A15
Text GLabel 11950 9850 0    60   Input ~ 0
A14
Text GLabel 11700 9750 0    60   Input ~ 0
A13
Text GLabel 11950 9650 0    60   Input ~ 0
A12
Text GLabel 11700 9550 0    60   Input ~ 0
A11
Text GLabel 11950 9450 0    60   Input ~ 0
A10
Text GLabel 11700 9350 0    60   Input ~ 0
A9
Text GLabel 11950 9250 0    60   Input ~ 0
A8
Text GLabel 11700 9150 0    60   Input ~ 0
A7
Text GLabel 11950 9050 0    60   Input ~ 0
A6
Text GLabel 11700 8950 0    60   Input ~ 0
A5
Text GLabel 11950 8850 0    60   Input ~ 0
A4
Text GLabel 11700 8750 0    60   Input ~ 0
A3
Text GLabel 11950 8650 0    60   Input ~ 0
A2
Text GLabel 11700 8550 0    60   Input ~ 0
A1
Text GLabel 11950 8450 0    60   Input ~ 0
A0
$Comp
L babyM68K-rescue:SRAM_512K U?
U 1 1 4E014532
P 14950 9550
F 0 "U?" H 14950 9650 60  0000 C CNN
F 1 "SRAM_512K" H 15000 8750 60  0000 C CNN
F 2 "" H 14950 9550 50  0001 C CNN
F 3 "" H 14950 9550 50  0001 C CNN
	1    14950 9550
	1    0    0    -1  
$EndComp
Wire Wire Line
	17550 12950 17050 12950
Wire Wire Line
	15550 13400 15700 13400
Wire Wire Line
	17050 11650 16450 11650
Wire Wire Line
	18850 12050 18850 12250
Wire Wire Line
	17550 13700 15550 13700
Text Notes 22200 3700 0    70   ~ 0
L*R + L*/B + /B*/R  ==  L*R + /B*/R
Wire Wire Line
	23750 2500 23750 3050
Wire Wire Line
	25250 3550 25250 3150
Wire Wire Line
	22750 6200 24250 6200
Wire Wire Line
	25100 4900 24650 4900
Connection ~ 18750 2400
Wire Wire Line
	19300 2300 19300 2400
Wire Wire Line
	19300 2400 18750 2400
Wire Wire Line
	18650 1400 18850 1400
Wire Wire Line
	25650 5500 26150 5500
Wire Wire Line
	25650 5800 26150 5800
Wire Wire Line
	24250 6400 23450 6400
Wire Wire Line
	25650 6300 25850 6300
Wire Wire Line
	24250 6000 23600 6000
Wire Wire Line
	23600 6000 23600 5400
Wire Wire Line
	23600 5400 24450 5400
Wire Wire Line
	24250 5800 24150 5800
Wire Wire Line
	24250 6500 24150 6500
Wire Wire Line
	24250 6700 24150 6700
Wire Wire Line
	26450 3650 26450 2750
Wire Wire Line
	26450 2750 24250 2750
Wire Wire Line
	24250 2750 24250 2000
Wire Wire Line
	24250 2000 24550 2000
Wire Wire Line
	25250 3150 25050 3150
Wire Wire Line
	23850 4050 23150 4050
Wire Wire Line
	23750 2500 23600 2500
Wire Wire Line
	24550 2300 24550 2100
Wire Wire Line
	24200 1600 24550 1600
Wire Wire Line
	24200 1200 24550 1200
Wire Wire Line
	26400 1500 25950 1500
Wire Wire Line
	26400 1100 25950 1100
Wire Wire Line
	20650 3300 20150 3300
Wire Wire Line
	20650 4700 20150 4700
Wire Wire Line
	20150 5100 20650 5100
Wire Wire Line
	20150 6500 20650 6500
Wire Wire Line
	20150 6900 20650 6900
Wire Wire Line
	18750 4600 18400 4600
Wire Wire Line
	18750 5000 18400 5000
Wire Wire Line
	18750 6400 18400 6400
Wire Wire Line
	18750 6800 18400 6800
Wire Wire Line
	18400 3400 18750 3400
Wire Wire Line
	18750 3000 18400 3000
Wire Wire Line
	18450 5500 18750 5500
Wire Wire Line
	18750 4000 18750 3800
Wire Wire Line
	18750 5800 18750 5600
Wire Wire Line
	18750 7600 18750 7400
Wire Wire Line
	18400 3700 18750 3700
Wire Wire Line
	18450 7300 18750 7300
Wire Wire Line
	18750 3200 18400 3200
Wire Wire Line
	18400 7000 18750 7000
Wire Wire Line
	18400 6600 18750 6600
Wire Wire Line
	18400 5200 18750 5200
Wire Wire Line
	18750 4800 18400 4800
Wire Wire Line
	20650 7100 20150 7100
Wire Wire Line
	20650 6700 20150 6700
Wire Wire Line
	20650 5300 20150 5300
Wire Wire Line
	20650 4900 20150 4900
Wire Wire Line
	20150 3500 20650 3500
Wire Wire Line
	20150 3100 20650 3100
Wire Wire Line
	25950 1300 26400 1300
Wire Wire Line
	25950 1700 26400 1700
Wire Wire Line
	24550 1400 24200 1400
Wire Wire Line
	24550 1800 24200 1800
Wire Wire Line
	23150 4250 23850 4250
Wire Wire Line
	23750 3050 23850 3050
Wire Wire Line
	23850 3250 23150 3250
Wire Wire Line
	25050 4150 25250 4150
Wire Wire Line
	23450 6800 24250 6800
Wire Wire Line
	25850 6500 25650 6500
Wire Wire Line
	26450 6000 25650 6000
Wire Wire Line
	24250 5900 23100 5900
Wire Wire Line
	25650 5900 26450 5900
Wire Wire Line
	26450 5900 26450 5300
Wire Wire Line
	26450 5300 25650 5300
Wire Wire Line
	26450 6400 25650 6400
Wire Wire Line
	24250 6300 24150 6300
Wire Wire Line
	25650 6100 25850 6100
Wire Wire Line
	18850 1400 18850 2000
Wire Wire Line
	19300 1700 18750 1700
Wire Wire Line
	18750 1700 18750 2400
Wire Wire Line
	22900 5300 24200 5300
Connection ~ 26150 5500
Wire Wire Line
	26150 5800 26150 5500
Wire Wire Line
	26150 4900 26000 4900
Wire Wire Line
	24250 6100 23500 6100
Wire Wire Line
	24200 5300 24200 5200
Wire Wire Line
	23750 4900 23050 4900
Wire Wire Line
	25650 6200 26450 6200
Wire Wire Line
	25250 4150 25250 3750
Text Notes 21200 6150 0    60   ~ 0
2011-10-27 update:\nadd DT/R to the ECB bus
Text GLabel 26450 6200 2    60   Output ~ 0
B_DT/R
Text GLabel 22750 6200 0    60   Input ~ 0
W/R
Text GLabel 25850 6100 2    60   Output ~ 0
/AS
Text GLabel 23500 6100 0    60   Input ~ 0
B_/MREQ
$Comp
L babyM68K-rescue:74F04 U?
U 1 2 4E0269F4
P 25550 4900
F 0 "U?" H 25745 5015 60  0000 C CNN
F 1 "74F04" H 25740 4775 60  0000 C CNN
F 2 "" H 25550 4900 50  0001 C CNN
F 3 "" H 25550 4900 50  0001 C CNN
	1    25550 4900
	-1   0    0    -1  
$EndComp
Text GLabel 22900 5300 0    60   Input ~ 0
/BUSAK
$Comp
L babyM68K-rescue:74LS125 U?
U 4 1 4E026F2E
P 24200 4900
F 0 "U?" H 24200 5000 50  0000 L BNN
F 1 "74LS125" H 24250 4750 40  0000 L TNN
F 2 "" H 24200 4900 50  0001 C CNN
F 3 "" H 24200 4900 50  0001 C CNN
	4    24200 4900
	-1   0    0    -1  
$EndComp
NoConn ~ 18750 2800
NoConn ~ 18750 2900
NoConn ~ 20150 2800
NoConn ~ 20150 2900
Text GLabel 18650 2400 0    60   Input ~ 0
BUSAK
$Comp
L babyM68K-rescue:GND #PWR?
U 1 1 4E026E39
P 21300 1700
F 0 "#PWR?" H 21300 1700 30  0001 C CNN
F 1 "GND" H 21300 1630 30  0001 C CNN
F 2 "" H 21300 1700 50  0001 C CNN
F 3 "" H 21300 1700 50  0001 C CNN
	1    21300 1700
	1    0    0    -1  
$EndComp
Text GLabel 20850 1400 0    60   Input ~ 0
CLK
Text GLabel 21750 1400 2    60   Output ~ 0
B_/CLK
$Comp
L babyM68K-rescue:74LS125 U?
U 3 1 4E026DB0
P 21300 1400
F 0 "U?" H 21300 1500 50  0000 L BNN
F 1 "74LS125" H 21350 1250 40  0000 L TNN
F 2 "" H 21300 1400 50  0001 C CNN
F 3 "" H 21300 1400 50  0001 C CNN
	3    21300 1400
	1    0    0    -1  
$EndComp
Text GLabel 19750 2000 2    60   3State ~ 0
B_A22
Text GLabel 19750 1400 2    60   3State ~ 0
B_A23
Text GLabel 18650 1400 0    60   Input ~ 0
IORQ
$Comp
L babyM68K-rescue:74LS125 U?
U 1 1 4E026CEF
P 19300 1400
F 0 "U?" H 19300 1500 50  0000 L BNN
F 1 "74LS125" H 19350 1250 40  0000 L TNN
F 2 "" H 19300 1400 50  0001 C CNN
F 3 "" H 19300 1400 50  0001 C CNN
	1    19300 1400
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:74LS125 U?
U 2 1 4E026CDC
P 19300 2000
F 0 "U?" H 19300 2100 50  0000 L BNN
F 1 "74LS125" H 19350 1850 40  0000 L TNN
F 2 "" H 19300 2000 50  0001 C CNN
F 3 "" H 19300 2000 50  0001 C CNN
	2    19300 2000
	1    0    0    -1  
$EndComp
Text GLabel 23050 4900 0    60   Output ~ 0
R/W
Text GLabel 23450 6400 0    60   Input ~ 0
/WR
Text GLabel 24150 6300 0    60   Input ~ 0
/RD
$Comp
L babyM68K-rescue:74LS08 U?
U 1 2 4E026840
P 25050 5400
F 0 "U?" H 25050 5450 60  0000 C CNN
F 1 "74LS08" H 25050 5350 60  0000 C CNN
F 2 "" H 25050 5400 50  0001 C CNN
F 3 "" H 25050 5400 50  0001 C CNN
	1    25050 5400
	-1   0    0    -1  
$EndComp
Text GLabel 26450 6000 2    60   Output ~ 0
/DS
Text GLabel 26450 6400 2    60   Output ~ 0
B_/WR
Text GLabel 25850 6300 2    60   Output ~ 0
B_/RD
Text GLabel 24150 5800 0    60   Input ~ 0
B_/RD
Text GLabel 23100 5900 0    60   Input ~ 0
B_/WR
Text GLabel 25850 6500 2    60   Output ~ 0
/WAIT
Text GLabel 24150 6500 0    60   Input ~ 0
B_/WAIT
Text Notes 23000 6700 2    60   ~ 0
DMA\n\n& non-DMA
Text GLabel 23450 6800 0    60   Input ~ 0
BUSAK
Text GLabel 24150 6700 0    60   Input ~ 0
/BUSAK
$Comp
L babyM68K-rescue:74LS244 U?
U 1 1 4E026521
P 24950 6300
F 0 "U?" H 25000 6100 60  0000 C CNN
F 1 "74LS244" H 25050 5900 60  0000 C CNN
F 2 "" H 24950 6300 50  0001 C CNN
F 3 "" H 24950 6300 50  0001 C CNN
	1    24950 6300
	1    0    0    -1  
$EndComp
Text Label 25100 2750 0    60   ~ 0
D_OUT
Text GLabel 23150 4050 0    60   Input ~ 0
W/R
Text GLabel 23150 3250 0    60   Input ~ 0
R/W
Text GLabel 23150 4250 0    60   Input ~ 0
/BUSAK
$Comp
L babyM68K-rescue:74LS00 U?
U 4 1 4E024899
P 24450 4150
F 0 "U?" H 24450 4200 60  0000 C CNN
F 1 "74LS00" H 24450 4050 60  0000 C CNN
F 2 "" H 24450 4150 50  0001 C CNN
F 3 "" H 24450 4150 50  0001 C CNN
	4    24450 4150
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:74LS00 U?
U 2 1 4E024892
P 24450 3150
F 0 "U?" H 24450 3200 60  0000 C CNN
F 1 "74LS00" H 24450 3050 60  0000 C CNN
F 2 "" H 24450 3150 50  0001 C CNN
F 3 "" H 24450 3150 50  0001 C CNN
	2    24450 3150
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:74LS00 U?
U 3 2 4E024880
P 25850 3650
F 0 "U?" H 25850 3700 60  0000 C CNN
F 1 "74LS00" H 25850 3550 60  0000 C CNN
F 2 "" H 25850 3650 50  0001 C CNN
F 3 "" H 25850 3650 50  0001 C CNN
	3    25850 3650
	1    0    0    -1  
$EndComp
Text Label 23600 2500 0    60   ~ 0
LOCAL
Text GLabel 22400 2600 0    60   Input ~ 0
IORQ
Text GLabel 22400 2400 0    60   Input ~ 0
MREQ
$Comp
L babyM68K-rescue:74LS02 U?
U 2 2 4E0245F7
P 23000 2500
F 0 "U?" H 23000 2550 60  0000 C CNN
F 1 "74LS02" H 23050 2450 60  0000 C CNN
F 2 "" H 23000 2500 50  0001 C CNN
F 3 "" H 23000 2500 50  0001 C CNN
	2    23000 2500
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:GND #PWR?
U 1 1 4E0236B2
P 24550 2300
F 0 "#PWR?" H 24550 2300 30  0001 C CNN
F 1 "GND" H 24550 2230 30  0001 C CNN
F 2 "" H 24550 2300 50  0001 C CNN
F 3 "" H 24550 2300 50  0001 C CNN
	1    24550 2300
	1    0    0    -1  
$EndComp
Text GLabel 24200 1200 0    60   BiDi ~ 0
D6
Text GLabel 24200 1400 0    60   BiDi ~ 0
D4
Text GLabel 24200 1600 0    60   BiDi ~ 0
D2
Text GLabel 24200 1800 0    60   BiDi ~ 0
D0
Text GLabel 24550 1700 0    60   BiDi ~ 0
D1
Text GLabel 24550 1500 0    60   BiDi ~ 0
D3
Text GLabel 24550 1300 0    60   BiDi ~ 0
D5
Text GLabel 24550 1100 0    60   BiDi ~ 0
D7
Text GLabel 26400 1500 2    60   BiDi ~ 0
B_D3
Text GLabel 26400 1300 2    60   BiDi ~ 0
B_D5
Text GLabel 26400 1100 2    60   BiDi ~ 0
B_D7
Text GLabel 25950 1200 2    60   BiDi ~ 0
B_D6
Text GLabel 25950 1400 2    60   BiDi ~ 0
B_D4
Text GLabel 25950 1600 2    60   BiDi ~ 0
B_D2
Text GLabel 26400 1700 2    60   BiDi ~ 0
B_D1
Text GLabel 25950 1800 2    60   BiDi ~ 0
B_D0
$Comp
L babyM68K-rescue:74LS245 U?
U 1 1 4E023588
P 25250 1600
F 0 "U?" H 25350 2175 60  0000 L BNN
F 1 "74LS245" H 25300 1025 60  0000 L TNN
F 2 "" H 25250 1600 50  0001 C CNN
F 3 "" H 25250 1600 50  0001 C CNN
	1    25250 1600
	1    0    0    -1  
$EndComp
Text GLabel 20650 7100 2    60   BiDi ~ 0
B_A0
Text GLabel 20650 6900 2    60   BiDi ~ 0
B_A2
Text GLabel 20650 6700 2    60   BiDi ~ 0
B_A4
Text GLabel 20650 6500 2    60   BiDi ~ 0
B_A6
Text GLabel 20650 5300 2    60   BiDi ~ 0
B_A8
Text GLabel 20650 5100 2    60   BiDi ~ 0
B_A10
Text GLabel 20650 4900 2    60   BiDi ~ 0
B_A12
Text GLabel 20650 4700 2    60   BiDi ~ 0
B_A14
Text GLabel 20650 3500 2    60   BiDi ~ 0
B_A16
Text GLabel 20650 3300 2    60   BiDi ~ 0
B_A18
Text GLabel 20650 3100 2    60   BiDi ~ 0
B_A20
Text GLabel 20150 3000 2    60   BiDi ~ 0
B_A21
Text GLabel 20150 3200 2    60   BiDi ~ 0
B_A19
Text GLabel 20150 3400 2    60   BiDi ~ 0
B_A17
Text GLabel 20150 4600 2    60   BiDi ~ 0
B_A15
Text GLabel 20150 4800 2    60   BiDi ~ 0
B_A13
Text GLabel 20150 5000 2    60   BiDi ~ 0
B_A11
Text GLabel 20150 5200 2    60   BiDi ~ 0
B_A9
Text GLabel 20150 6400 2    60   BiDi ~ 0
B_A7
Text GLabel 20150 6600 2    60   BiDi ~ 0
B_A5
Text GLabel 20150 6800 2    60   BiDi ~ 0
B_A3
Text GLabel 20150 7000 2    60   BiDi ~ 0
B_A1
Text GLabel 18400 7000 0    60   BiDi ~ 0
A1
Text GLabel 18400 6800 0    60   BiDi ~ 0
A3
Text GLabel 18400 6600 0    60   BiDi ~ 0
A5
Text GLabel 18400 6400 0    60   BiDi ~ 0
A7
Text GLabel 18400 5200 0    60   BiDi ~ 0
A9
Text GLabel 18400 5000 0    60   BiDi ~ 0
A11
Text GLabel 18400 4800 0    60   BiDi ~ 0
A13
Text GLabel 18400 4600 0    60   BiDi ~ 0
A15
Text GLabel 18400 3400 0    60   BiDi ~ 0
A17
Text GLabel 18400 3200 0    60   BiDi ~ 0
A19
Text GLabel 18400 3000 0    60   BiDi ~ 0
A21
Text GLabel 18750 3100 0    60   BiDi ~ 0
A20
Text GLabel 18750 3300 0    60   BiDi ~ 0
A18
Text GLabel 18750 3500 0    60   BiDi ~ 0
A16
Text GLabel 18750 4700 0    60   BiDi ~ 0
A14
Text GLabel 18750 4900 0    60   BiDi ~ 0
A12
Text GLabel 18750 5100 0    60   BiDi ~ 0
A10
Text GLabel 18750 5300 0    60   BiDi ~ 0
A8
Text GLabel 18750 6500 0    60   BiDi ~ 0
A6
Text GLabel 18750 6700 0    60   BiDi ~ 0
A4
Text GLabel 18750 6900 0    60   BiDi ~ 0
A2
Text GLabel 18750 7100 0    60   BiDi ~ 0
A0
Text GLabel 18450 7300 0    60   Input ~ 0
/BUSAK
Text GLabel 18400 3700 0    60   Input ~ 0
/BUSAK
Text GLabel 18450 5500 0    60   Input ~ 0
/BUSAK
$Comp
L babyM68K-rescue:GND #PWR?
U 1 1 4E023159
P 18750 4000
F 0 "#PWR?" H 18750 4000 30  0001 C CNN
F 1 "GND" H 18750 3930 30  0001 C CNN
F 2 "" H 18750 4000 50  0001 C CNN
F 3 "" H 18750 4000 50  0001 C CNN
	1    18750 4000
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:GND #PWR?
U 1 1 4E02314E
P 18750 5800
F 0 "#PWR?" H 18750 5800 30  0001 C CNN
F 1 "GND" H 18750 5730 30  0001 C CNN
F 2 "" H 18750 5800 50  0001 C CNN
F 3 "" H 18750 5800 50  0001 C CNN
	1    18750 5800
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:GND #PWR?
U 1 1 4E023126
P 18750 7600
F 0 "#PWR?" H 18750 7600 30  0001 C CNN
F 1 "GND" H 18750 7530 30  0001 C CNN
F 2 "" H 18750 7600 50  0001 C CNN
F 3 "" H 18750 7600 50  0001 C CNN
	1    18750 7600
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:74LS245 U?
U 1 1 4E0230F9
P 19450 6900
F 0 "U?" H 19550 7475 60  0000 L BNN
F 1 "74LS245" H 19500 6325 60  0000 L TNN
F 2 "" H 19450 6900 50  0001 C CNN
F 3 "" H 19450 6900 50  0001 C CNN
	1    19450 6900
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:74LS245 U?
U 1 1 4E0230EE
P 19450 5100
F 0 "U?" H 19550 5675 60  0000 L BNN
F 1 "74LS245" H 19500 4525 60  0000 L TNN
F 2 "" H 19450 5100 50  0001 C CNN
F 3 "" H 19450 5100 50  0001 C CNN
	1    19450 5100
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:74LS245 U?
U 1 1 4E0230E7
P 19450 3300
F 0 "U?" H 19550 3875 60  0000 L BNN
F 1 "74LS245" H 19500 2725 60  0000 L TNN
F 2 "" H 19450 3300 50  0001 C CNN
F 3 "" H 19450 3300 50  0001 C CNN
	1    19450 3300
	1    0    0    -1  
$EndComp
Connection ~ 18850 1400
Wire Wire Line
	18750 2400 18650 2400
Wire Wire Line
	26150 5500 26150 4900
$Comp
L babyM68K-rescue:74LS164 U?
U 1 1 4E023B2B
P 3550 14750
F 0 "U?" H 3550 14900 60  0000 C CNN
F 1 "74LS164" H 3550 14550 60  0000 C CNN
F 2 "" H 3550 14750 50  0001 C CNN
F 3 "" H 3550 14750 50  0001 C CNN
	1    3550 14750
	1    0    0    -1  
$EndComp
Wire Wire Line
	4250 14400 4850 14400
Wire Wire Line
	9850 17050 9650 17050
Wire Wire Line
	6450 14950 6450 15050
Wire Wire Line
	6450 15050 4700 15050
Wire Wire Line
	4700 15050 4700 14550
Wire Wire Line
	6450 14400 6450 14750
Wire Wire Line
	7000 14850 6450 14850
Connection ~ 5300 16150
Wire Wire Line
	5300 16150 5300 17050
Wire Wire Line
	5300 17050 5750 17050
Wire Wire Line
	5750 16950 5450 16950
Wire Wire Line
	5450 16950 5450 16050
Wire Wire Line
	5450 16050 5750 16050
Wire Wire Line
	5750 17150 4900 17150
Wire Wire Line
	4250 14250 5650 14250
Wire Wire Line
	3150 18350 5750 18350
Wire Wire Line
	4250 13900 2850 13900
Wire Wire Line
	2850 13900 2850 14250
Wire Wire Line
	2250 14150 2250 14250
Wire Wire Line
	2250 14450 2850 14450
Wire Wire Line
	1700 16350 1950 16350
Wire Wire Line
	2850 16350 3300 16350
Wire Wire Line
	3300 15800 3300 16350
Connection ~ 3300 16350
Wire Wire Line
	1700 15150 2850 15150
Wire Wire Line
	2850 14250 2250 14250
Connection ~ 2250 14250
Wire Wire Line
	5750 18250 3750 18250
Wire Wire Line
	5750 17400 5250 17400
Wire Wire Line
	5250 17400 5250 17650
Wire Wire Line
	5750 17250 4900 17250
Wire Wire Line
	5650 14850 5150 14850
Wire Wire Line
	4700 14550 4250 14550
Wire Wire Line
	5000 16150 5300 16150
Wire Wire Line
	5000 15950 5750 15950
Wire Wire Line
	5650 14250 5650 14750
Wire Wire Line
	5650 14950 4850 14950
Wire Wire Line
	4850 14950 4850 14400
Connection ~ 4850 14400
Wire Wire Line
	7250 17150 8450 17150
Wire Wire Line
	8200 16950 8450 16950
Text Notes 6400 15900 0    60   ~ 0
Memory write wait states:\n    1-2 (0 ws)\n    2-3 (1 ws)\n\nMemory reads are always 0 wait states.\n
Text Label 7400 17150 0    60   ~ 0
RDY
Text GLabel 8200 16950 0    60   Input ~ 0
/WAIT
Text GLabel 9850 17050 2    60   Output ~ 0
/DTACK
$Comp
L babyM68K-rescue:74LS00 U?
U 2 1 4E01424E
P 9050 17050
F 0 "U?" H 9050 17100 60  0000 C CNN
F 1 "74LS00" H 9050 16950 60  0000 C CNN
F 2 "" H 9050 17050 50  0001 C CNN
F 3 "" H 9050 17050 50  0001 C CNN
	2    9050 17050
	1    0    0    -1  
$EndComp
Text Label 5200 15950 2    60   ~ 0
1WS
$Comp
L babyM68K-rescue:CONN_3 J?
U 1 1 4E013FC9
P 6100 16050
F 0 "J?" V 6050 16050 50  0000 C CNN
F 1 "MemW-WS" V 6150 16050 40  0000 C CNN
F 2 "" H 6100 16050 50  0001 C CNN
F 3 "" H 6100 16050 50  0001 C CNN
	1    6100 16050
	1    0    0    1   
$EndComp
Text Notes 5350 15200 0    60   ~ 0
I/O wait states:  \n    read:  1-3  (1 ws),  3-5 (2 ws)\n    write:  2-4  (2 ws),  4-6 (3 ws)\n
Text Label 6600 14850 0    60   ~ 0
WS-IOWR
Text Label 5150 14850 0    60   ~ 0
WS-IORD
Text Label 4900 17150 0    60   ~ 0
WS-IOWR
Text Label 4900 17250 0    60   ~ 0
WS-IORD
$Comp
L babyM68K-rescue:GND #PWR?
U 1 1 4E013CDF
P 5250 17650
F 0 "#PWR?" H 5250 17650 30  0001 C CNN
F 1 "GND" H 5250 17580 30  0001 C CNN
F 2 "" H 5250 17650 50  0001 C CNN
F 3 "" H 5250 17650 50  0001 C CNN
	1    5250 17650
	1    0    0    -1  
$EndComp
Text Label 5200 16150 2    60   ~ 0
0WS
NoConn ~ 7250 17800
NoConn ~ 5750 17600
NoConn ~ 5750 17700
NoConn ~ 5750 17800
NoConn ~ 5750 17900
NoConn ~ 5750 18050
Text GLabel 3150 18350 0    60   Input ~ 0
IORQ
Text GLabel 3750 18250 0    60   Input ~ 0
R/W
NoConn ~ 4250 14700
NoConn ~ 4250 14850
NoConn ~ 4250 15000
NoConn ~ 4250 15150
NoConn ~ 4250 15300
Text Label 4250 15150 0    60   ~ 0
7WS
Text Label 4250 15000 0    60   ~ 0
6WS
Text Label 4250 14850 0    60   ~ 0
5WS
Text Label 4250 14700 0    60   ~ 0
4WS
Text Label 4250 15300 0    60   ~ 0
8WS
Text Label 4250 14550 0    60   ~ 0
3WS
Text Label 4250 14400 0    60   ~ 0
2WS
Text Label 4250 14250 0    60   ~ 0
1WS
Text Label 4250 13900 0    60   ~ 0
0WS
$Comp
L babyM68K-rescue:VCC #PWR?
U 1 1 4E013B40
P 2250 14150
F 0 "#PWR?" H 2250 14250 30  0001 C CNN
F 1 "VCC" H 2250 14250 30  0000 C CNN
F 2 "" H 2250 14150 50  0001 C CNN
F 3 "" H 2250 14150 50  0001 C CNN
	1    2250 14150
	1    0    0    -1  
$EndComp
Text GLabel 1700 15150 0    60   Input ~ 0
CLK
Text GLabel 1700 16350 0    60   Input ~ 0
/AS
Text GLabel 3650 16350 2    60   Output ~ 0
AS
$Comp
L babyM68K-rescue:74F04 U?
U 2 2 4E013ACE
P 2400 16350
F 0 "U?" H 2595 16465 60  0000 C CNN
F 1 "74F04" H 2590 16225 60  0000 C CNN
F 2 "" H 2400 16350 50  0001 C CNN
F 3 "" H 2400 16350 50  0001 C CNN
	2    2400 16350
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:74LS153 U?
U 1 1 4E013A1E
P 6500 17650
F 0 "U?" H 6500 17950 60  0000 C CNN
F 1 "74LS153" H 6500 17800 60  0000 C CNN
F 2 "" H 6500 17650 50  0001 C CNN
F 3 "" H 6500 17650 50  0001 C CNN
	1    6500 17650
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:CONN_3X2 J?
U 1 1 4E0139CE
P 6050 14900
F 0 "J?" H 6050 15150 50  0000 C CNN
F 1 "WAIT" V 6050 14950 40  0000 C CNN
F 2 "" H 6050 14900 50  0001 C CNN
F 3 "" H 6050 14900 50  0001 C CNN
	1    6050 14900
	1    0    0    -1  
$EndComp
Connection ~ 2850 14250
Wire Wire Line
	5300 16150 5750 16150
Wire Wire Line
	3300 16350 3650 16350
Wire Wire Line
	2250 14250 2250 14450
Wire Wire Line
	4850 14400 6450 14400
Wire Wire Line
	14200 17450 14200 18700
Wire Wire Line
	12000 17650 12000 17850
Wire Wire Line
	11750 16450 12100 16450
Wire Wire Line
	15100 19450 15100 17650
Wire Wire Line
	14400 17250 14400 19250
Connection ~ 16500 20450
Connection ~ 15250 16350
Connection ~ 12100 16450
$Comp
L babyM68K-rescue:74LS138 U?
U 1 1 4DFFB1DE
P 12700 16100
F 0 "U?" H 12700 16600 60  0000 C CNN
F 1 "74LS138" H 12700 15550 60  0000 C CNN
F 2 "" H 12700 16100 50  0001 C CNN
F 3 "" H 12700 16100 50  0001 C CNN
	1    12700 16100
	1    0    0    -1  
$EndComp
Text GLabel 11850 15950 0    60   Input ~ 0
A21
Text GLabel 11850 15850 0    60   Input ~ 0
A20
Text GLabel 11850 15750 0    60   Input ~ 0
A19
Text GLabel 13650 15750 2    60   Output ~ 0
/CSRAM0
Text GLabel 14200 15850 2    60   Output ~ 0
/CSRAM1
Text GLabel 13650 15950 2    60   Output ~ 0
/CSRAM2
Text GLabel 14200 16050 2    60   Output ~ 0
/CSRAM3
$Comp
L babyM68K-rescue:74LS10 U?
U 2 2 4DFFB336
P 16350 16250
F 0 "U?" H 16350 16300 60  0000 C CNN
F 1 "74LS10" H 16350 16200 60  0000 C CNN
F 2 "" H 16350 16250 50  0001 C CNN
F 3 "" H 16350 16250 50  0001 C CNN
	2    16350 16250
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:CONN_2 J?
U 1 1 4DFFB37E
P 15150 16700
F 0 "J?" V 15100 16700 40  0000 C CNN
F 1 "CONN_2" V 15200 16700 40  0000 C CNN
F 2 "" H 15150 16700 50  0001 C CNN
F 3 "" H 15150 16700 50  0001 C CNN
	1    15150 16700
	0    1    1    0   
$EndComp
Text GLabel 11450 16450 0    60   Input ~ 0
/AS
$Comp
L babyM68K-rescue:VCC #PWR?
U 1 1 4DFFB50D
P 12000 17550
F 0 "#PWR?" H 12000 17650 30  0001 C CNN
F 1 "VCC" H 12000 17650 30  0000 C CNN
F 2 "" H 12000 17550 50  0001 C CNN
F 3 "" H 12000 17550 50  0001 C CNN
	1    12000 17550
	1    0    0    -1  
$EndComp
NoConn ~ 13600 18550
NoConn ~ 13600 17650
NoConn ~ 13600 17800
NoConn ~ 13600 17950
NoConn ~ 13600 18100
NoConn ~ 13600 18250
NoConn ~ 13600 18400
Text GLabel 19350 17500 2    60   Output ~ 0
/ROM
$Comp
L babyM68K-rescue:74LS10 U?
U 3 1 4DFFB69F
P 18400 17500
F 0 "U?" H 18400 17550 60  0000 C CNN
F 1 "74LS10" H 18400 17450 60  0000 C CNN
F 2 "" H 18400 17500 50  0001 C CNN
F 3 "" H 18400 17500 50  0001 C CNN
	3    18400 17500
	1    0    0    -1  
$EndComp
Text Label 13700 17050 2    60   ~ 0
/ROMONLY
Text GLabel 11800 20050 0    60   Input ~ 0
A18
Text GLabel 11400 20150 0    60   Input ~ 0
A17
Text GLabel 11800 20250 0    60   Input ~ 0
A16
$Comp
L babyM68K-rescue:74LS02 U?
U 4 2 4DFFB88A
P 16400 19350
F 0 "U?" H 16400 19400 60  0000 C CNN
F 1 "74LS02" H 16450 19300 60  0000 C CNN
F 2 "" H 16400 19350 50  0001 C CNN
F 3 "" H 16400 19350 50  0001 C CNN
	4    16400 19350
	1    0    0    -1  
$EndComp
Text Label 13300 20200 0    60   ~ 0
/IOSPACE
Text GLabel 17500 19350 2    60   Output ~ 0
IORQ
$Comp
L babyM68K-rescue:RR9 RR?
U 1 1 4DFFBC43
P 15150 21550
F 0 "RR?" H 15200 22150 70  0000 C CNN
F 1 "10k bussed" V 15180 21550 70  0000 C CNN
F 2 "" H 15150 21550 50  0001 C CNN
F 3 "" H 15150 21550 50  0001 C CNN
	1    15150 21550
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:VCC #PWR?
U 1 1 4DFFBCB1
P 14800 20850
F 0 "#PWR?" H 14800 20950 30  0001 C CNN
F 1 "VCC" H 14800 20950 30  0000 C CNN
F 2 "" H 14800 20850 50  0001 C CNN
F 3 "" H 14800 20850 50  0001 C CNN
	1    14800 20850
	1    0    0    -1  
$EndComp
Text GLabel 17500 16250 2    60   Output ~ 0
MREQ
Text Notes 17250 19750 0    60   ~ 0
IORQ combines with M1 (CPU) to\ngenerate the Interrupt Acknowledge\nsequence.
Text Label 14650 21150 2    60   ~ 0
PU-10K-A
Text GLabel 14800 21250 0    60   Output ~ 0
PU-10K-clear
Text GLabel 14000 21350 0    60   Output ~ 0
/RESET
Text GLabel 14800 21450 0    60   Output ~ 0
/HALT
Text Label 16000 15650 2    60   ~ 0
PU-10K-A
Text GLabel 14000 21550 0    60   Input ~ 0
FC0
Text GLabel 17800 17500 0    60   Input ~ 0
AS
Text Notes 15500 16650 0    60   ~ 0
Close to enable external memory from\n$30xxxx to $37xxxx
Text Notes 17850 16450 0    60   ~ 0
External (4MEM, e.g.)\nmemory request
Text GLabel 14450 21650 0    60   Input ~ 0
FC1
Text GLabel 14000 21750 0    60   Input ~ 0
FC2
$Comp
L babyM68K-rescue:74LS164 U?
U 1 1 4E023ACC
P 12900 18150
F 0 "U?" H 12900 18300 60  0000 C CNN
F 1 "74LS164" H 12900 17950 60  0000 C CNN
F 2 "" H 12900 18150 50  0001 C CNN
F 3 "" H 12900 18150 50  0001 C CNN
	1    12900 18150
	1    0    0    -1  
$EndComp
Text GLabel 14600 21850 0    60   Output ~ 0
B_/WAIT
Text GLabel 14000 21950 0    60   Output ~ 0
/BERR
Text Notes 10900 15450 0    60   ~ 0
2011-08-15 update:\nfix reversed address lines
Text GLabel 11600 19350 0    70   Input ~ 0
/POClear
Text Notes 10650 19000 0    70   ~ 0
2013-01-24 update:\nuse /Power On Clear for\nbootstrap, not /RESET
$Comp
L babyM68K-rescue:74LS20 U?
U 1 1 5101E835
P 12700 20200
F 0 "U?" H 12700 20300 60  0000 C CNN
F 1 "74LS20" H 12700 20100 60  0000 C CNN
F 2 "" H 12700 20200 50  0001 C CNN
F 3 "" H 12700 20200 50  0001 C CNN
	1    12700 20200
	1    0    0    -1  
$EndComp
Text GLabel 15700 20450 0    60   Input ~ 0
FC2
Text Notes 10700 20650 0    70   ~ 0
2013-01-25 update:\nadd FC2 so User mode\nmay not do I/O
$Comp
L babyM68K-rescue:CONN_2 J?
U 1 1 5105EAB9
P 16400 20800
F 0 "J?" V 16350 20800 40  0000 C CNN
F 1 "CONN_2" V 16450 20800 40  0000 C CNN
F 2 "" H 16400 20800 50  0001 C CNN
F 3 "" H 16400 20800 50  0001 C CNN
	1    16400 20800
	0    1    1    0   
$EndComp
$Comp
L babyM68K-rescue:R R?
U 1 1 5105EB1F
P 16500 20200
F 0 "R?" V 16580 20200 50  0000 C CNN
F 1 "47K" V 16500 20200 50  0000 C CNN
F 2 "" H 16500 20200 50  0001 C CNN
F 3 "" H 16500 20200 50  0001 C CNN
	1    16500 20200
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:VCC #PWR?
U 1 1 5105EB60
P 16500 19950
F 0 "#PWR?" H 16500 20050 30  0001 C CNN
F 1 "VCC" H 16500 20050 30  0000 C CNN
F 2 "" H 16500 19950 50  0001 C CNN
F 3 "" H 16500 19950 50  0001 C CNN
	1    16500 19950
	1    0    0    -1  
$EndComp
Text GLabel 18150 20450 2    60   Output ~ 0
SUPV/USER
Text Notes 18900 20650 2    60   ~ 0
to memory.sch also
Text Label 10500 20350 0    60   ~ 0
SUPV/USER
$Comp
L babyM68K-rescue:74LS00 U?
U 4 2 5228C3B5
P 16700 17350
F 0 "U?" H 16700 17400 60  0000 C CNN
F 1 "74LS00" H 16700 17250 60  0000 C CNN
F 2 "" H 16700 17350 50  0001 C CNN
F 3 "" H 16700 17350 50  0001 C CNN
	4    16700 17350
	1    0    0    -1  
$EndComp
Wire Wire Line
	17300 17350 17800 17350
Wire Wire Line
	15700 20450 16300 20450
Wire Wire Line
	10400 20350 12100 20350
Wire Wire Line
	11400 20150 12100 20150
Connection ~ 14200 17450
Wire Wire Line
	14800 21850 14600 21850
Wire Wire Line
	14200 18700 13600 18700
Wire Wire Line
	14450 21650 14800 21650
Wire Wire Line
	15100 17650 17800 17650
Wire Wire Line
	15250 15650 16200 15650
Wire Wire Line
	14800 21350 14000 21350
Wire Wire Line
	14400 16450 14400 17250
Wire Wire Line
	14400 19250 15800 19250
Wire Wire Line
	14400 16450 13300 16450
Wire Wire Line
	14200 17050 14200 17450
Wire Wire Line
	14200 17050 12000 17050
Wire Wire Line
	12000 16250 12000 17050
Wire Wire Line
	12100 16250 12000 16250
Wire Wire Line
	12100 16450 12100 16350
Wire Wire Line
	12650 19350 12650 19200
Wire Wire Line
	11600 19350 12650 19350
Wire Wire Line
	12000 17850 12200 17850
Wire Wire Line
	12000 17550 12000 17650
Wire Wire Line
	15050 16350 13300 16350
Wire Wire Line
	13300 16250 15750 16250
Wire Wire Line
	13300 15950 13650 15950
Wire Wire Line
	13300 15750 13650 15750
Wire Wire Line
	11850 15850 12100 15850
Wire Wire Line
	12100 15750 11850 15750
Wire Wire Line
	11850 15950 12100 15950
Wire Wire Line
	13300 15850 14200 15850
Wire Wire Line
	13300 16050 14200 16050
Wire Wire Line
	15450 16150 13300 16150
Wire Wire Line
	15450 16100 15450 16150
Wire Wire Line
	15750 16100 15450 16100
Wire Wire Line
	15450 16350 15250 16350
Wire Wire Line
	15450 16400 15450 16350
Wire Wire Line
	15750 16400 15450 16400
Wire Wire Line
	17500 16250 16950 16250
Wire Wire Line
	12200 17650 12000 17650
Connection ~ 12000 17650
Wire Wire Line
	11450 16450 11750 16450
Wire Wire Line
	11750 18550 12200 18550
Wire Wire Line
	11750 18550 11750 16450
Connection ~ 11750 16450
Wire Wire Line
	12100 20050 11800 20050
Wire Wire Line
	15100 20200 15100 19450
Wire Wire Line
	15100 20200 13300 20200
Wire Wire Line
	17500 19350 17000 19350
Wire Wire Line
	14800 21050 14800 20850
Wire Wire Line
	15250 16350 15250 15650
Wire Wire Line
	14800 21150 14150 21150
Wire Wire Line
	14800 21550 14000 21550
Wire Wire Line
	15800 19450 15100 19450
Connection ~ 15100 19450
Wire Wire Line
	14000 21750 14800 21750
Wire Wire Line
	14800 21950 14000 21950
Wire Wire Line
	19350 17500 19000 17500
Wire Wire Line
	11800 20250 12100 20250
Wire Wire Line
	16500 20450 18150 20450
Wire Wire Line
	16100 17250 14400 17250
Connection ~ 14400 17250
Wire Wire Line
	16100 17450 14200 17450
Wire Wire Line
	21850 17100 21850 17400
Wire Wire Line
	22950 17100 22650 17100
Wire Wire Line
	26150 17100 27050 17100
Wire Wire Line
	22650 17100 22350 17100
Wire Wire Line
	20950 17400 20950 17100
Wire Wire Line
	20950 18400 20950 17400
Wire Wire Line
	24750 17100 25050 17100
Wire Wire Line
	24750 17100 24750 18100
Wire Wire Line
	28750 19800 29550 19800
Wire Wire Line
	22950 19900 22950 21000
$Comp
L babyM68K-rescue:SW_PUSH SW?
U 1 1 4E00EC39
P 21550 17100
F 0 "SW?" H 21700 17210 50  0000 C CNN
F 1 "SW_PUSH" H 21550 17020 50  0000 C CNN
F 2 "" H 21550 17100 50  0001 C CNN
F 3 "" H 21550 17100 50  0001 C CNN
	1    21550 17100
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:CONN_2 P?
U 1 1 4E00ECC7
P 21750 17750
F 0 "P?" V 21700 17750 40  0000 C CNN
F 1 "CONN_2" V 21800 17750 40  0000 C CNN
F 2 "" H 21750 17750 50  0001 C CNN
F 3 "" H 21750 17750 50  0001 C CNN
	1    21750 17750
	0    1    1    0   
$EndComp
$Comp
L babyM68K-rescue:CP CP?
U 1 1 4E00ECE3
P 22650 17300
F 0 "CP?" H 22700 17400 50  0000 L CNN
F 1 "47uF" H 22700 17200 50  0000 L CNN
F 2 "" H 22650 17300 50  0001 C CNN
F 3 "" H 22650 17300 50  0001 C CNN
	1    22650 17300
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:GND #PWR?
U 1 1 4E00ECFF
P 20950 18650
F 0 "#PWR?" H 20950 18650 30  0001 C CNN
F 1 "GND" H 20950 18580 30  0001 C CNN
F 2 "" H 20950 18650 50  0001 C CNN
F 3 "" H 20950 18650 50  0001 C CNN
	1    20950 18650
	1    0    0    -1  
$EndComp
Text Notes 21650 18050 0    60   ~ 0
Reset\nconnector
Text GLabel 23000 16100 2    60   Input ~ 0
PU-10K-clear
Text Notes 23850 16150 0    60   ~ 0
Select.sch
$Comp
L babyM68K-rescue:74LS14 U?
U 5 2 4E00EECA
P 23700 17100
F 0 "U?" H 23850 17200 40  0000 C CNN
F 1 "74LS14" H 23900 17000 40  0000 C CNN
F 2 "" H 23700 17100 50  0001 C CNN
F 3 "" H 23700 17100 50  0001 C CNN
	5    23700 17100
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:74LS06 U?
U 5 1 4E00EF3B
P 25500 17100
F 0 "U?" H 25695 17215 60  0000 C CNN
F 1 "74LS06" H 25690 16975 60  0000 C CNN
F 2 "" H 25500 17100 50  0001 C CNN
F 3 "" H 25500 17100 50  0001 C CNN
	5    25500 17100
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:74LS06 U?
U 6 1 4E00EF4A
P 25500 18100
F 0 "U?" H 25695 18215 60  0000 C CNN
F 1 "74LS06" H 25690 17975 60  0000 C CNN
F 2 "" H 25500 18100 50  0001 C CNN
F 3 "" H 25500 18100 50  0001 C CNN
	6    25500 18100
	1    0    0    -1  
$EndComp
Text GLabel 27050 17100 2    60   Input ~ 0
/RESET
Text GLabel 27050 18100 2    60   Input ~ 0
/HALT
Text Notes 26950 17650 0    60   ~ 0
Pull-ups on Select.sch
$Comp
L babyM68K-rescue:74LS240 U?
U 1 1 4E00F268
P 26450 19800
F 0 "U?" H 26500 19600 60  0000 C CNN
F 1 "74LS240" H 26550 19400 60  0000 C CNN
F 2 "" H 26450 19800 50  0001 C CNN
F 3 "" H 26450 19800 50  0001 C CNN
	1    26450 19800
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:GND #PWR?
U 1 1 4E00F2AF
P 25750 20900
F 0 "#PWR?" H 25750 20900 30  0001 C CNN
F 1 "GND" H 25750 20830 30  0001 C CNN
F 2 "" H 25750 20900 50  0001 C CNN
F 3 "" H 25750 20900 50  0001 C CNN
	1    25750 20900
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:LED D?
U 1 1 4E00F317
P 22950 19300
F 0 "D?" V 22950 19450 50  0000 C CNN
F 1 "LED" V 22950 19100 50  0000 C CNN
F 2 "" H 22950 19300 50  0001 C CNN
F 3 "" H 22950 19300 50  0001 C CNN
	1    22950 19300
	0    1    1    0   
$EndComp
Text Notes 22600 19300 2    55   ~ 0
red/green\nbicolor
$Comp
L babyM68K-rescue:R R?
U 1 1 4E00F38F
P 23200 18800
F 0 "R?" V 23280 18800 50  0000 C CNN
F 1 "47" V 23200 18800 50  0000 C CNN
F 2 "" H 23200 18800 50  0001 C CNN
F 3 "" H 23200 18800 50  0001 C CNN
	1    23200 18800
	0    1    1    0   
$EndComp
Text GLabel 29550 19800 2    55   Output ~ 0
B_/RESOUT
Text Label 25300 19800 2    55   ~ 0
RESET
Text Notes 27550 17150 0    55   ~ 0
to CPU
Text Notes 27550 18150 0    55   ~ 0
to CPU
$Comp
L babyM68K-rescue:74LS14 U?
U 6 2 4E00F537
P 26600 16500
F 0 "U?" H 26750 16600 40  0000 C CNN
F 1 "74LS14" H 26800 16400 40  0000 C CNN
F 2 "" H 26600 16500 50  0001 C CNN
F 3 "" H 26600 16500 50  0001 C CNN
	6    26600 16500
	1    0    0    -1  
$EndComp
Text GLabel 27150 16500 2    55   Output ~ 0
RESET
Text GLabel 27950 19700 2    55   Output ~ 0
B_/M1
Text GLabel 25750 19700 0    60   Input ~ 0
M1
$Comp
L babyM68K-rescue:DIODE D?
U 1 1 4E0155B9
P 22950 16900
F 0 "D?" V 22950 17000 40  0000 C CNN
F 1 "BAT43" H 22950 16800 40  0000 C CNN
F 2 "" H 22950 16900 50  0001 C CNN
F 3 "" H 22950 16900 50  0001 C CNN
	1    22950 16900
	0    -1   -1   0   
$EndComp
$Comp
L babyM68K-rescue:VCC #PWR?
U 1 1 4E0155D3
P 22950 16500
F 0 "#PWR?" H 22950 16600 30  0001 C CNN
F 1 "VCC" H 22950 16600 30  0000 C CNN
F 2 "" H 22950 16500 50  0001 C CNN
F 3 "" H 22950 16500 50  0001 C CNN
	1    22950 16500
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:R R?
U 1 1 4E015674
P 22100 17100
F 0 "R?" V 22180 17100 50  0000 C CNN
F 1 "10" V 22100 17100 50  0000 C CNN
F 2 "" H 22100 17100 50  0001 C CNN
F 3 "" H 22100 17100 50  0001 C CNN
	1    22100 17100
	0    1    1    0   
$EndComp
Text GLabel 24950 20200 0    60   Input ~ 0
BUSAK
Text GLabel 24950 19600 0    60   Input ~ 0
IORQ
Text GLabel 27350 19600 2    60   Output ~ 0
B_/IORQ
Text GLabel 27950 19500 2    60   Output ~ 0
B_/MREQ
Text GLabel 25750 19500 0    60   Input ~ 0
MREQ
NoConn ~ 27150 19400
NoConn ~ 27150 19300
NoConn ~ 25750 19300
NoConn ~ 25750 19400
Text GLabel 27150 15750 2    70   Output ~ 0
/POClear
Text Notes 27900 15700 0    70   ~ 0
2013-01-24 update:\nuse /Power On Clear for\nbootstrap, not /RESET
$Comp
L babyM68K-rescue:CONN_3 J?
U 1 1 510179F0
P 29100 20400
F 0 "J?" V 29050 20400 50  0000 C CNN
F 1 "CONN_3" V 29150 20400 40  0000 C CNN
F 2 "" H 29100 20400 50  0001 C CNN
F 3 "" H 29100 20400 50  0001 C CNN
	1    29100 20400
	1    0    0    -1  
$EndComp
Text GLabel 29550 20900 2    60   Output ~ 0
B_/RESET
Text Label 20950 16500 0    70   ~ 0
/RESET_IN
Text Notes 28450 21200 0    70   ~ 0
1-2  N8VEM reset out on C31\n2-3  Kontron reset in on C31\n       out on C26
$Comp
L babyM68K-rescue:74F04 U?
U 5 1 5101D8D2
P 25800 15750
F 0 "U?" H 25995 15865 60  0000 C CNN
F 1 "74F04" H 25990 15625 60  0000 C CNN
F 2 "" H 25800 15750 50  0001 C CNN
F 3 "" H 25800 15750 50  0001 C CNN
	5    25800 15750
	1    0    0    -1  
$EndComp
Text GLabel 21150 20000 0    60   Input ~ 0
FC2
Text GLabel 29550 19400 2    55   Output ~ 0
B_/HALT
$Comp
L babyM68K-rescue:R R?
U 1 1 5227E5E9
P 29250 19050
F 0 "R?" V 29330 19050 50  0000 C CNN
F 1 "4700" V 29250 19050 50  0000 C CNN
F 2 "" H 29250 19050 50  0001 C CNN
F 3 "" H 29250 19050 50  0001 C CNN
	1    29250 19050
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:VCC #PWR?
U 1 1 5227E60C
P 29250 18500
F 0 "#PWR?" H 29250 18600 30  0001 C CNN
F 1 "VCC" H 29250 18600 30  0000 C CNN
F 2 "" H 29250 18500 50  0001 C CNN
F 3 "" H 29250 18500 50  0001 C CNN
	1    29250 18500
	1    0    0    -1  
$EndComp
Wire Wire Line
	29250 18500 29250 18800
Wire Wire Line
	28550 19900 28550 18800
Wire Wire Line
	27150 19900 28550 19900
Wire Wire Line
	21150 20000 25750 20000
Wire Wire Line
	28550 20900 29550 20900
Wire Wire Line
	28550 20400 28550 20900
Wire Wire Line
	28750 20400 28550 20400
Connection ~ 21850 17100
Wire Wire Line
	21850 16500 21850 17100
Wire Wire Line
	26250 15750 27150 15750
Connection ~ 22950 17100
Wire Wire Line
	27950 19500 27150 19500
Wire Wire Line
	27350 19600 27150 19600
Wire Wire Line
	27950 19700 27150 19700
Connection ~ 26150 17100
Wire Wire Line
	26150 16500 26150 17100
Wire Wire Line
	27150 19800 28750 19800
Wire Wire Line
	22950 19100 22950 18800
Wire Wire Line
	25950 18100 27050 18100
Wire Wire Line
	24150 17100 24750 17100
Connection ~ 22650 17100
Wire Wire Line
	22650 16100 22650 17100
Wire Wire Line
	23000 16100 22650 16100
Wire Wire Line
	20950 17100 21250 17100
Wire Wire Line
	20950 18650 20950 18400
Wire Wire Line
	20950 17400 21650 17400
Connection ~ 20950 17400
Wire Wire Line
	22650 18400 22650 17500
Wire Wire Line
	20950 18400 22650 18400
Connection ~ 20950 18400
Wire Wire Line
	25950 17100 26150 17100
Wire Wire Line
	24750 18100 25050 18100
Connection ~ 24750 17100
Wire Wire Line
	25750 20300 25750 20900
Wire Wire Line
	25050 19800 25750 19800
Wire Wire Line
	27150 16500 27050 16500
Wire Wire Line
	22950 16700 22950 16500
Wire Wire Line
	25750 20200 24950 20200
Wire Wire Line
	25750 19600 24950 19600
Wire Wire Line
	23250 17100 22950 17100
Wire Wire Line
	28750 20300 28750 19800
Connection ~ 28750 19800
Wire Wire Line
	27850 20500 28750 20500
Wire Wire Line
	27850 21450 27850 20500
Wire Wire Line
	20650 21450 27850 21450
Wire Wire Line
	20650 16500 20650 21450
Wire Wire Line
	20650 16500 21850 16500
Wire Wire Line
	24750 15750 25350 15750
Wire Wire Line
	24750 15750 24750 17100
Wire Wire Line
	25750 19900 22950 19900
Wire Wire Line
	27150 21000 27150 20000
Wire Wire Line
	22950 21000 27150 21000
Wire Wire Line
	22950 19500 22950 19900
Connection ~ 22950 19900
Wire Wire Line
	23450 18800 28550 18800
Wire Wire Line
	29250 19400 29250 19300
Wire Wire Line
	29550 19400 29250 19400
Text Notes 23250 19300 0    60   ~ 0
RED:  Supervisor Mode\nGREEN:  User Mode
$Comp
L Connector_Generic:Conn_01x24 JPB?
U 1 1 535944CA
P 30950 5800
F 0 "JPB?" H 30700 7025 50  0000 L BNN
F 1 "PINHD-1X24" H 30700 4400 50  0000 L BNN
F 2 "Pin_Headers:Pin_Header_Angled_1x24" H 30950 5950 50  0001 C CNN
F 3 "" H 30950 5800 60  0000 C CNN
	1    30950 5800
	-1   0    0    -1  
$EndComp
$Comp
L Connector_Generic:Conn_01x24 JPA?
U 1 1 5359460E
P 30950 2650
F 0 "JPA?" H 30700 3875 50  0000 L BNN
F 1 "PINHD-1X24" H 30700 1250 50  0000 L BNN
F 2 "Pin_Headers:Pin_Header_Angled_1x24" H 30950 2800 50  0001 C CNN
F 3 "" H 30950 2650 60  0000 C CNN
	1    30950 2650
	-1   0    0    -1  
$EndComp
Text GLabel 31350 6300 2    60   BiDi ~ 0
B_D7
Text GLabel 31350 6400 2    60   BiDi ~ 0
B_D6
Text GLabel 31350 6500 2    60   BiDi ~ 0
B_D5
Text GLabel 31350 6600 2    60   BiDi ~ 0
B_D4
Text GLabel 31350 6700 2    60   BiDi ~ 0
B_D3
Text GLabel 31350 6800 2    60   BiDi ~ 0
B_D2
Text GLabel 31350 6900 2    60   BiDi ~ 0
B_D1
Text GLabel 31350 7000 2    60   BiDi ~ 0
B_D0
NoConn ~ 31400 1550
NoConn ~ 31400 1650
$Comp
L power:-12V #PWR?
U 1 1 535A7B8F
P 31750 3150
F 0 "#PWR?" H 31750 3280 20  0001 C CNN
F 1 "-12V" H 31750 3250 30  0000 C CNN
F 2 "" H 31750 3150 60  0000 C CNN
F 3 "" H 31750 3150 60  0000 C CNN
	1    31750 3150
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR?
U 1 1 535A7BFD
P 31500 2750
F 0 "#PWR?" H 31500 2840 20  0001 C CNN
F 1 "+5V" H 31500 2840 30  0000 C CNN
F 2 "" H 31500 2750 60  0000 C CNN
F 3 "" H 31500 2750 60  0000 C CNN
	1    31500 2750
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 535A7C0C
P 31500 2900
F 0 "#PWR?" H 31500 2900 30  0001 C CNN
F 1 "GND" H 31500 2830 30  0001 C CNN
F 2 "" H 31500 2900 60  0000 C CNN
F 3 "" H 31500 2900 60  0000 C CNN
	1    31500 2900
	1    0    0    -1  
$EndComp
$Comp
L power:+12V #PWR?
U 1 1 535A8003
P 31600 3050
F 0 "#PWR?" H 31600 3000 20  0001 C CNN
F 1 "+12V" H 31600 3150 30  0000 C CNN
F 2 "" H 31600 3050 60  0000 C CNN
F 3 "" H 31600 3050 60  0000 C CNN
	1    31600 3050
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 535A94C5
P 31650 2750
F 0 "#PWR?" H 31650 2850 30  0001 C CNN
F 1 "VCC" H 31650 2850 30  0000 C CNN
F 2 "" H 31650 2750 60  0000 C CNN
F 3 "" H 31650 2750 60  0000 C CNN
	1    31650 2750
	1    0    0    -1  
$EndComp
Wire Wire Line
	31050 6300 31150 6300
Wire Wire Line
	31050 6400 31150 6400
Wire Wire Line
	31050 6500 31150 6500
Wire Wire Line
	31050 6600 31150 6600
Wire Wire Line
	31050 6700 31150 6700
Wire Wire Line
	31050 6800 31150 6800
Wire Wire Line
	31050 6900 31150 6900
Wire Wire Line
	31050 7000 31150 7000
Wire Wire Line
	31050 6200 31150 6200
Wire Wire Line
	31050 6100 31150 6100
Wire Wire Line
	31050 6000 31150 6000
Wire Wire Line
	31050 5900 31150 5900
Wire Wire Line
	31050 5800 31150 5800
Wire Wire Line
	31050 5700 31150 5700
Wire Wire Line
	31050 5600 31150 5600
Wire Wire Line
	31050 1550 31150 1550
Wire Wire Line
	31050 1650 31150 1650
Wire Wire Line
	31050 1750 31150 1750
Wire Wire Line
	31050 1850 31150 1850
Wire Wire Line
	31050 2850 31150 2850
Wire Wire Line
	31050 2950 31150 2950
Wire Wire Line
	31400 2950 31400 2850
Wire Wire Line
	31500 2850 31500 2900
Connection ~ 31400 2850
Wire Wire Line
	31050 2650 31150 2650
Wire Wire Line
	31400 2650 31400 2750
Wire Wire Line
	31050 2750 31150 2750
Connection ~ 31400 2750
Wire Wire Line
	31050 3450 31150 3450
Wire Wire Line
	31050 2550 31150 2550
Wire Wire Line
	31050 2350 31150 2350
Wire Wire Line
	31050 2250 31150 2250
Wire Wire Line
	31050 2150 31150 2150
Wire Wire Line
	31050 2450 31150 2450
Wire Wire Line
	31600 3050 31150 3050
Wire Wire Line
	31400 2850 31500 2850
Wire Wire Line
	31050 2050 31150 2050
Wire Wire Line
	31050 3850 31150 3850
Wire Wire Line
	31050 1950 31150 1950
Wire Wire Line
	31050 5500 31150 5500
Text GLabel 31350 3750 2    60   Input ~ 0
B_CLK
Text GLabel 31350 3450 2    60   Input ~ 0
B_*WR
Text GLabel 31350 3550 2    60   Input ~ 0
B_*M1
Text GLabel 31350 3650 2    60   Input ~ 0
B_*IORQ
Text GLabel 31350 3850 2    60   Input ~ 0
B_*MREQ
Text GLabel 31350 6200 2    60   Input ~ 0
B_A15
Text GLabel 31350 6100 2    60   Input ~ 0
B_A14
Text GLabel 31350 6000 2    60   Input ~ 0
B_A13
Text GLabel 31350 5900 2    60   Input ~ 0
B_A12
Text GLabel 31350 5800 2    60   Input ~ 0
B_A11
Text GLabel 31350 5700 2    60   Input ~ 0
B_A10
Text GLabel 31350 5600 2    60   Input ~ 0
B_A9
Text GLabel 31350 5500 2    60   Input ~ 0
B_A8
Text GLabel 31350 5400 2    60   Input ~ 0
B_A7
Text GLabel 31350 5300 2    60   Input ~ 0
B_A6
Text GLabel 31350 5200 2    60   Input ~ 0
B_A5
Text GLabel 31350 5100 2    60   Input ~ 0
B_A4
Text GLabel 31350 5000 2    60   Input ~ 0
B_A3
Text GLabel 31350 4900 2    60   Input ~ 0
B_A2
Text GLabel 31350 4800 2    60   Input ~ 0
B_A1
Text GLabel 31350 4700 2    60   Input ~ 0
B_A0
Wire Wire Line
	31050 3750 31150 3750
Wire Wire Line
	31050 3350 31150 3350
Wire Wire Line
	31050 3250 31150 3250
Wire Wire Line
	31050 3650 31150 3650
Wire Wire Line
	31050 3550 31150 3550
Wire Wire Line
	31050 3150 31150 3150
Wire Wire Line
	31350 5000 31150 5000
Wire Wire Line
	31050 5400 31150 5400
Wire Wire Line
	31050 4700 31150 4700
Wire Wire Line
	31050 5100 31150 5100
Wire Wire Line
	31050 4800 31150 4800
Wire Wire Line
	31050 5200 31150 5200
Wire Wire Line
	31050 4900 31150 4900
Wire Wire Line
	31050 5300 31150 5300
Text GLabel 31350 3350 2    60   Input ~ 0
B_*RD
Text GLabel 31350 3250 2    60   Input ~ 0
B_*RESET
Text GLabel 31350 2150 2    60   Input ~ 0
B_*INT
Text GLabel 31350 1850 2    60   Input ~ 0
B_*RFH
Text GLabel 31350 1750 2    60   Input ~ 0
B_*HLT
Text GLabel 31350 2550 2    60   Input ~ 0
B_*BUSREQ
Text GLabel 31350 2450 2    60   Input ~ 0
B_*BUSAK
Text GLabel 31350 2350 2    60   Input ~ 0
B_*NMI
Text GLabel 31350 2250 2    60   Input ~ 0
B_*WAIT
Text GLabel 31350 2050 2    60   Input ~ 0
B_*IEO
Text GLabel 31350 1950 2    60   Input ~ 0
B_*IEI
Wire Wire Line
	31400 2750 31500 2750
Connection ~ 31150 1550
Wire Wire Line
	31150 1550 31400 1550
Connection ~ 31150 1650
Wire Wire Line
	31150 1650 31400 1650
Connection ~ 31150 1750
Wire Wire Line
	31150 1750 31350 1750
Connection ~ 31150 1850
Wire Wire Line
	31150 1850 31350 1850
Connection ~ 31150 1950
Wire Wire Line
	31150 1950 31350 1950
Connection ~ 31150 2050
Wire Wire Line
	31150 2050 31350 2050
Connection ~ 31150 2150
Wire Wire Line
	31150 2150 31350 2150
Connection ~ 31150 2250
Wire Wire Line
	31150 2250 31350 2250
Connection ~ 31150 2350
Wire Wire Line
	31150 2350 31350 2350
Connection ~ 31150 2450
Wire Wire Line
	31150 2450 31350 2450
Connection ~ 31150 2550
Wire Wire Line
	31150 2550 31350 2550
Connection ~ 31150 2650
Wire Wire Line
	31150 2650 31400 2650
Connection ~ 31150 2750
Wire Wire Line
	31150 2750 31400 2750
Connection ~ 31150 2850
Wire Wire Line
	31150 2850 31400 2850
Connection ~ 31150 2950
Wire Wire Line
	31150 2950 31400 2950
Connection ~ 31150 3050
Wire Wire Line
	31150 3050 31050 3050
Connection ~ 31150 3150
Wire Wire Line
	31150 3150 31750 3150
Connection ~ 31150 3250
Wire Wire Line
	31150 3250 31350 3250
Connection ~ 31150 3350
Wire Wire Line
	31150 3350 31350 3350
Connection ~ 31150 3450
Wire Wire Line
	31150 3450 31350 3450
Connection ~ 31150 3550
Wire Wire Line
	31150 3550 31350 3550
Connection ~ 31150 3650
Wire Wire Line
	31150 3650 31350 3650
Connection ~ 31150 3750
Wire Wire Line
	31150 3750 31350 3750
Connection ~ 31150 3850
Wire Wire Line
	31150 3850 31350 3850
Connection ~ 31150 4700
Wire Wire Line
	31150 4700 31350 4700
Connection ~ 31150 4800
Wire Wire Line
	31150 4800 31350 4800
Connection ~ 31150 4900
Wire Wire Line
	31150 4900 31350 4900
Connection ~ 31150 5000
Wire Wire Line
	31150 5000 31050 5000
Connection ~ 31150 5100
Wire Wire Line
	31150 5100 31350 5100
Connection ~ 31150 5200
Wire Wire Line
	31150 5200 31350 5200
Connection ~ 31150 5300
Wire Wire Line
	31150 5300 31350 5300
Connection ~ 31150 5400
Wire Wire Line
	31150 5400 31350 5400
Connection ~ 31150 5500
Wire Wire Line
	31150 5500 31350 5500
Connection ~ 31150 5600
Wire Wire Line
	31150 5600 31350 5600
Connection ~ 31150 5700
Wire Wire Line
	31150 5700 31350 5700
Connection ~ 31150 5800
Wire Wire Line
	31150 5800 31350 5800
Connection ~ 31150 5900
Wire Wire Line
	31150 5900 31350 5900
Connection ~ 31150 6000
Wire Wire Line
	31150 6000 31350 6000
Connection ~ 31150 6100
Wire Wire Line
	31150 6100 31350 6100
Connection ~ 31150 6200
Wire Wire Line
	31150 6200 31350 6200
Connection ~ 31150 6300
Wire Wire Line
	31150 6300 31350 6300
Connection ~ 31150 6400
Wire Wire Line
	31150 6400 31350 6400
Connection ~ 31150 6500
Wire Wire Line
	31150 6500 31350 6500
Connection ~ 31150 6600
Wire Wire Line
	31150 6600 31350 6600
Connection ~ 31150 6700
Wire Wire Line
	31150 6700 31350 6700
Connection ~ 31150 6800
Wire Wire Line
	31150 6800 31350 6800
Connection ~ 31150 6900
Wire Wire Line
	31150 6900 31350 6900
Connection ~ 31150 7000
Wire Wire Line
	31150 7000 31350 7000
Connection ~ 31500 2750
Wire Wire Line
	31500 2750 31650 2750
Wire Wire Line
	31500 2850 31950 2850
Connection ~ 31500 2850
Text Label 31950 2850 0    50   ~ 0
GND
Wire Wire Line
	31150 1950 31150 2050
$EndSCHEMATC
