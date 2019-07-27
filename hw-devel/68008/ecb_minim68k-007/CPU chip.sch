EESchema Schematic File Version 4
LIBS:babyM68K-cache
EELAYER 29 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 9 10
Title "mini M68K CPU"
Date "5 sep 2013"
Rev "2.0.007"
Comp "N8VEM User Group"
Comment1 "by John R. Coffman"
Comment2 "EXPERIMENTAL with I/O and memory protection and BERR"
Comment3 ""
Comment4 ""
$EndDescr
Wire Wire Line
	5400 1100 2700 1100
Wire Wire Line
	2700 1100 2700 1750
Connection ~ 4800 5050
Wire Wire Line
	4800 5600 4800 5050
Wire Wire Line
	2200 3850 3300 3850
Wire Wire Line
	3300 3850 3300 3750
Wire Wire Line
	3300 3750 5050 3750
Wire Wire Line
	5050 3050 2200 3050
Wire Wire Line
	4200 3500 5050 3500
Wire Wire Line
	5050 3500 5050 3450
Wire Wire Line
	5050 3350 4200 3350
Wire Wire Line
	7700 4450 6850 4450
Wire Wire Line
	7700 4650 6850 4650
Wire Wire Line
	7700 4850 6850 4850
Wire Wire Line
	7700 5050 6850 5050
Wire Wire Line
	7700 3950 6850 3950
Wire Wire Line
	7700 3550 6850 3550
Wire Wire Line
	7700 3150 6850 3150
Wire Wire Line
	7700 2350 6850 2350
Wire Wire Line
	7700 2750 6850 2750
Wire Wire Line
	7400 4050 6850 4050
Wire Wire Line
	7400 3650 6850 3650
Wire Wire Line
	7400 3250 6850 3250
Wire Wire Line
	7400 2850 6850 2850
Wire Wire Line
	7400 2450 6850 2450
Wire Wire Line
	7400 2050 6850 2050
Wire Wire Line
	4400 5200 4600 5200
Wire Wire Line
	4600 5200 4600 2950
Wire Wire Line
	4600 2950 5050 2950
Wire Wire Line
	5050 4950 4050 4950
Wire Wire Line
	2700 4750 5050 4750
Wire Wire Line
	5050 2350 4400 2350
Wire Wire Line
	5050 2550 4400 2550
Wire Wire Line
	5400 1750 5050 1750
Connection ~ 2400 1950
Wire Wire Line
	2400 2050 2400 1950
Connection ~ 1700 1950
Wire Wire Line
	2400 1250 2400 1450
Connection ~ 1700 2050
Wire Wire Line
	1700 1750 1700 1850
Connection ~ 1700 1850
Connection ~ 2400 1850
Wire Wire Line
	5050 1750 5050 2050
Connection ~ 5050 1750
Wire Wire Line
	5050 2450 4000 2450
Wire Wire Line
	3200 4650 5050 4650
Wire Wire Line
	5050 4850 4400 4850
Wire Wire Line
	5050 5050 4800 5050
Wire Wire Line
	5050 2150 4400 2150
Wire Wire Line
	7400 2250 6850 2250
Wire Wire Line
	7400 2650 6850 2650
Wire Wire Line
	7400 3050 6850 3050
Wire Wire Line
	7400 3450 6850 3450
Wire Wire Line
	7400 3850 6850 3850
Wire Wire Line
	7700 2950 6850 2950
Wire Wire Line
	7700 2550 6850 2550
Wire Wire Line
	7700 2150 6850 2150
Wire Wire Line
	7700 3350 6850 3350
Wire Wire Line
	7700 3750 6850 3750
Wire Wire Line
	7700 4150 6850 4150
Wire Wire Line
	7400 4950 6850 4950
Wire Wire Line
	7400 4750 6850 4750
Wire Wire Line
	7400 4550 6850 4550
Wire Wire Line
	7400 4350 6850 4350
Wire Wire Line
	5050 3250 5050 3200
Wire Wire Line
	5050 3200 4200 3200
Wire Wire Line
	5050 2850 2200 2850
Wire Wire Line
	5050 3650 2200 3650
Wire Wire Line
	4200 6200 3700 6200
Wire Wire Line
	2400 1750 2700 1750
Text GLabel 5400 1100 2    60   Output ~ 0
/CLK
Text Label 2500 6100 2    60   ~ 0
FC1
Text Notes 3350 3300 0    60   ~ 0
Select.sch\n& Reset.sch
Text GLabel 4200 3500 0    60   Output ~ 0
FC2
Text GLabel 4200 3350 0    60   Output ~ 0
FC1
Text GLabel 4200 3200 0    60   Output ~ 0
FC0
$Comp
L babyM68K-rescue:74F04 U13
U 6 1 4E013A69
P 5250 5600
F 0 "U13" H 5445 5715 60  0000 C CNN
F 1 "74F04" H 5440 5475 60  0000 C CNN
F 2 "" H 5250 5600 50  0001 C CNN
F 3 "" H 5250 5600 50  0001 C CNN
	6    5250 5600
	1    0    0    -1  
$EndComp
Text GLabel 5700 5600 2    60   Output ~ 0
W/R
Text Label 2500 6300 2    60   ~ 0
/BGACK
Text Notes 4500 6250 0    60   ~ 0
to Reset.sch
Text GLabel 4200 6200 2    55   Output ~ 0
M1
$Comp
L babyM68K-rescue:74LS08 U12
U 3 1 4E00F658
P 3100 6200
F 0 "U12" H 3100 6250 60  0000 C CNN
F 1 "74LS08" H 3100 6150 60  0000 C CNN
F 2 "" H 3100 6200 50  0001 C CNN
F 3 "" H 3100 6200 50  0001 C CNN
	3    3100 6200
	1    0    0    -1  
$EndComp
NoConn ~ 1700 1650
NoConn ~ 1700 1550
NoConn ~ 1700 1450
NoConn ~ 2400 1550
NoConn ~ 2400 1650
Text GLabel 2200 3850 0    60   Input ~ 0
/BGACK
Text GLabel 2200 3650 0    60   Output ~ 0
/BG
Text GLabel 2200 2850 0    60   Input ~ 0
/BR
Text GLabel 2200 3050 0    60   Input ~ 0
/BERR
Text GLabel 7700 5050 2    60   3State ~ 0
D7
Text GLabel 7700 4850 2    60   3State ~ 0
D5
Text GLabel 7700 4650 2    60   3State ~ 0
D3
Text GLabel 7700 4450 2    60   3State ~ 0
D1
Text GLabel 7400 4950 2    60   3State ~ 0
D6
Text GLabel 7400 4750 2    60   3State ~ 0
D4
Text GLabel 7400 4550 2    60   3State ~ 0
D2
Text GLabel 7400 4350 2    60   3State ~ 0
D0
Text GLabel 7700 4150 2    60   3State ~ 0
A21
Text GLabel 7700 3950 2    60   3State ~ 0
A19
Text GLabel 7700 3750 2    60   3State ~ 0
A17
Text GLabel 7700 3550 2    60   3State ~ 0
A15
Text GLabel 7700 3350 2    60   3State ~ 0
A13
Text GLabel 7700 3150 2    60   3State ~ 0
A11
Text GLabel 7700 2950 2    60   3State ~ 0
A9
Text GLabel 7400 4050 2    60   3State ~ 0
A20
Text GLabel 7400 3850 2    60   3State ~ 0
A18
Text GLabel 7400 3650 2    60   3State ~ 0
A16
Text GLabel 7400 3450 2    60   3State ~ 0
A14
Text GLabel 7400 3250 2    60   3State ~ 0
A12
Text GLabel 7400 3050 2    60   3State ~ 0
A10
Text GLabel 7400 2850 2    60   3State ~ 0
A8
Text GLabel 7700 2750 2    60   3State ~ 0
A7
Text GLabel 7700 2550 2    60   3State ~ 0
A5
Text GLabel 7400 2650 2    60   3State ~ 0
A6
Text GLabel 7400 2450 2    60   3State ~ 0
A4
Text GLabel 7700 2350 2    60   3State ~ 0
A3
Text GLabel 7400 2250 2    60   3State ~ 0
A2
Text GLabel 7700 2150 2    60   3State ~ 0
A1
Text GLabel 7400 2050 2    60   3State ~ 0
A0
Text GLabel 2700 4750 0    60   Input ~ 0
/RESET
Text GLabel 3200 4650 0    60   Input ~ 0
/HALT
Text GLabel 4400 5050 0    60   Input ~ 0
R/W
Text GLabel 4050 4950 0    60   Input ~ 0
/DS
Text GLabel 4400 4850 0    60   Input ~ 0
/AS
Text GLabel 4400 5200 0    60   Input ~ 0
/DTACK
NoConn ~ 5050 3850
Text GLabel 4400 2550 0    60   Input ~ 0
/IPL2
Text GLabel 4000 2450 0    60   Input ~ 0
/IPL1
Text GLabel 4400 2350 0    60   Input ~ 0
/IPL0
Text GLabel 4400 2150 0    60   Input ~ 0
/VPA
Text GLabel 5400 1750 2    60   Output ~ 0
CLK
$Comp
L babyM68K-rescue:74F04 U13
U 4 1 4DFF899B
P 3150 1750
F 0 "U13" H 3345 1865 60  0000 C CNN
F 1 "74F04" H 3340 1625 60  0000 C CNN
F 2 "" H 3150 1750 50  0001 C CNN
F 3 "" H 3150 1750 50  0001 C CNN
	4    3150 1750
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:GND #PWR020
U 1 1 4DFF8938
P 1700 2450
F 0 "#PWR020" H 1700 2450 30  0001 C CNN
F 1 "GND" H 1700 2380 30  0001 C CNN
F 2 "" H 1700 2450 50  0001 C CNN
F 3 "" H 1700 2450 50  0001 C CNN
	1    1700 2450
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:VCC #PWR021
U 1 1 4DFF891F
P 2400 1250
F 0 "#PWR021" H 2400 1350 30  0001 C CNN
F 1 "VCC" H 2400 1350 30  0000 C CNN
F 2 "" H 2400 1250 50  0001 C CNN
F 3 "" H 2400 1250 50  0001 C CNN
	1    2400 1250
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:DIL14 U28
U 1 1 4DFF88DD
P 2050 1750
F 0 "U28" H 2050 2150 60  0000 C CNN
F 1 "OSC 8Mhz" V 2050 1750 50  0000 C CNN
F 2 "" H 2050 1750 50  0001 C CNN
F 3 "" H 2050 1750 50  0001 C CNN
	1    2050 1750
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:68008FN U29
U 1 1 4DFF8621
P 5950 3550
F 0 "U29" H 5950 3650 70  0000 C CNN
F 1 "68008FN" H 5950 3450 70  0000 C CNN
F 2 "PLCC52" H 5950 3300 60  0000 C CNN
F 3 "" H 5950 3550 50  0001 C CNN
	1    5950 3550
	1    0    0    -1  
$EndComp
Wire Wire Line
	4800 5050 4400 5050
Wire Wire Line
	2400 1950 2400 1850
Wire Wire Line
	1700 1950 1700 2050
Wire Wire Line
	1700 2050 1700 2450
Wire Wire Line
	1700 1850 1700 1950
Wire Wire Line
	2400 1850 2400 1750
Wire Wire Line
	3600 1750 5050 1750
$EndSCHEMATC
