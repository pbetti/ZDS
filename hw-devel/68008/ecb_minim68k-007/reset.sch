EESchema Schematic File Version 4
LIBS:babyM68K-cache
EELAYER 29 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 6 10
Title "mini M68K CPU"
Date "5 sep 2013"
Rev "2.0.007"
Comp "N8VEM User Group"
Comment1 "by John R. Coffman"
Comment2 "EXPERIMENTAL with I/O and memory protection and BERR"
Comment3 ""
Comment4 ""
$EndDescr
Text Notes 3900 4700 0    60   ~ 0
RED:  Supervisor Mode\nGREEN:  User Mode
Wire Wire Line
	10200 4800 9900 4800
Wire Wire Line
	9900 4800 9900 4700
Wire Wire Line
	4100 4200 9200 4200
Connection ~ 3600 5300
Wire Wire Line
	3600 4900 3600 6400
Wire Wire Line
	3600 6400 7800 6400
Wire Wire Line
	7800 6400 7800 5400
Wire Wire Line
	6400 5300 3600 5300
Wire Wire Line
	5400 1150 5400 3500
Wire Wire Line
	5400 1150 6000 1150
Wire Wire Line
	1300 1900 2500 1900
Wire Wire Line
	1300 1900 1300 6850
Wire Wire Line
	1300 6850 8500 6850
Wire Wire Line
	8500 6850 8500 5900
Wire Wire Line
	8500 5900 9400 5900
Connection ~ 9400 5200
Wire Wire Line
	9400 5700 9400 5200
Wire Wire Line
	3900 2500 3000 2500
Wire Wire Line
	6400 5000 5600 5000
Wire Wire Line
	6400 5600 5600 5600
Wire Wire Line
	3600 2100 3600 1900
Wire Wire Line
	7800 1900 7700 1900
Wire Wire Line
	5700 5200 6400 5200
Wire Wire Line
	6400 5700 6400 6300
Connection ~ 5400 2500
Wire Wire Line
	5400 3500 5700 3500
Wire Wire Line
	6600 2500 7700 2500
Connection ~ 1600 3800
Wire Wire Line
	1600 3800 3300 3800
Wire Wire Line
	3300 3800 3300 2900
Connection ~ 1600 2800
Wire Wire Line
	1600 2800 2300 2800
Wire Wire Line
	1600 4050 1600 2500
Wire Wire Line
	1600 2500 1900 2500
Wire Wire Line
	3650 1500 3300 1500
Wire Wire Line
	3300 1500 3300 2500
Connection ~ 3300 2500
Wire Wire Line
	4800 2500 5700 2500
Wire Wire Line
	6600 3500 7700 3500
Wire Wire Line
	3600 4500 3600 4200
Wire Wire Line
	7800 5200 10200 5200
Wire Wire Line
	6800 1900 6800 2500
Connection ~ 6800 2500
Wire Wire Line
	8600 5100 7800 5100
Wire Wire Line
	8000 5000 7800 5000
Wire Wire Line
	8600 4900 7800 4900
Connection ~ 3600 2500
Wire Wire Line
	6900 1150 7800 1150
Wire Wire Line
	2500 1900 2500 2800
Connection ~ 2500 2500
Wire Wire Line
	9400 5800 9200 5800
Wire Wire Line
	9200 5800 9200 6300
Wire Wire Line
	9200 6300 10200 6300
Wire Wire Line
	1800 5400 6400 5400
Wire Wire Line
	7800 5300 9200 5300
Wire Wire Line
	9200 5300 9200 4200
Wire Wire Line
	9900 3900 9900 4200
$Comp
L babyM68K-rescue:VCC #PWR011
U 1 1 5227E60C
P 9900 3900
F 0 "#PWR011" H 9900 4000 30  0001 C CNN
F 1 "VCC" H 9900 4000 30  0000 C CNN
F 2 "" H 9900 3900 50  0001 C CNN
F 3 "" H 9900 3900 50  0001 C CNN
	1    9900 3900
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:R R4
U 1 1 5227E5E9
P 9900 4450
F 0 "R4" V 9980 4450 50  0000 C CNN
F 1 "4700" V 9900 4450 50  0000 C CNN
F 2 "" H 9900 4450 50  0001 C CNN
F 3 "" H 9900 4450 50  0001 C CNN
	1    9900 4450
	1    0    0    -1  
$EndComp
Text GLabel 10200 4800 2    55   Output ~ 0
B_/HALT
Text GLabel 1800 5400 0    60   Input ~ 0
FC2
$Comp
L babyM68K-rescue:74F04 U13
U 5 1 5101D8D2
P 6450 1150
F 0 "U13" H 6645 1265 60  0000 C CNN
F 1 "74F04" H 6640 1025 60  0000 C CNN
F 2 "" H 6450 1150 50  0001 C CNN
F 3 "" H 6450 1150 50  0001 C CNN
	5    6450 1150
	1    0    0    -1  
$EndComp
Text Notes 9100 6600 0    70   ~ 0
1-2  N8VEM reset out on C31\n2-3  Kontron reset in on C31\n       out on C26
Text Label 1600 1900 0    70   ~ 0
/RESET_IN
Text GLabel 10200 6300 2    60   Output ~ 0
B_/RESET
$Comp
L babyM68K-rescue:CONN_3 J5
U 1 1 510179F0
P 9750 5800
F 0 "J5" V 9700 5800 50  0000 C CNN
F 1 "CONN_3" V 9800 5800 40  0000 C CNN
F 2 "" H 9750 5800 50  0001 C CNN
F 3 "" H 9750 5800 50  0001 C CNN
	1    9750 5800
	1    0    0    -1  
$EndComp
Text Notes 8550 1100 0    70   ~ 0
2013-01-24 update:\nuse /Power On Clear for\nbootstrap, not /RESET
Text GLabel 7800 1150 2    70   Output ~ 0
/POClear
NoConn ~ 6400 4800
NoConn ~ 6400 4700
NoConn ~ 7800 4700
NoConn ~ 7800 4800
Text GLabel 6400 4900 0    60   Input ~ 0
MREQ
Text GLabel 8600 4900 2    60   Output ~ 0
B_/MREQ
Text GLabel 8000 5000 2    60   Output ~ 0
B_/IORQ
Text GLabel 5600 5000 0    60   Input ~ 0
IORQ
Text GLabel 5600 5600 0    60   Input ~ 0
BUSAK
$Comp
L babyM68K-rescue:R R1
U 1 1 4E015674
P 2750 2500
F 0 "R1" V 2830 2500 50  0000 C CNN
F 1 "10" V 2750 2500 50  0000 C CNN
F 2 "" H 2750 2500 50  0001 C CNN
F 3 "" H 2750 2500 50  0001 C CNN
	1    2750 2500
	0    1    1    0   
$EndComp
$Comp
L babyM68K-rescue:VCC #PWR012
U 1 1 4E0155D3
P 3600 1900
F 0 "#PWR012" H 3600 2000 30  0001 C CNN
F 1 "VCC" H 3600 2000 30  0000 C CNN
F 2 "" H 3600 1900 50  0001 C CNN
F 3 "" H 3600 1900 50  0001 C CNN
	1    3600 1900
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:DIODE D1
U 1 1 4E0155B9
P 3600 2300
F 0 "D1" V 3600 2400 40  0000 C CNN
F 1 "BAT43" H 3600 2200 40  0000 C CNN
F 2 "" H 3600 2300 50  0001 C CNN
F 3 "" H 3600 2300 50  0001 C CNN
	1    3600 2300
	0    -1   -1   0   
$EndComp
Text GLabel 6400 5100 0    60   Input ~ 0
M1
Text GLabel 8600 5100 2    55   Output ~ 0
B_/M1
Text GLabel 7800 1900 2    55   Output ~ 0
RESET
$Comp
L babyM68K-rescue:74LS14 U2
U 6 2 4E00F537
P 7250 1900
F 0 "U2" H 7400 2000 40  0000 C CNN
F 1 "74LS14" H 7450 1800 40  0000 C CNN
F 2 "" H 7250 1900 50  0001 C CNN
F 3 "" H 7250 1900 50  0001 C CNN
	6    7250 1900
	1    0    0    -1  
$EndComp
Text Notes 8200 3550 0    55   ~ 0
to CPU
Text Notes 8200 2550 0    55   ~ 0
to CPU
Text Label 5950 5200 2    55   ~ 0
RESET
Text GLabel 10200 5200 2    55   Output ~ 0
B_/RESOUT
$Comp
L babyM68K-rescue:R R2
U 1 1 4E00F38F
P 3850 4200
F 0 "R2" V 3930 4200 50  0000 C CNN
F 1 "47" V 3850 4200 50  0000 C CNN
F 2 "" H 3850 4200 50  0001 C CNN
F 3 "" H 3850 4200 50  0001 C CNN
	1    3850 4200
	0    1    1    0   
$EndComp
Text Notes 3250 4700 2    55   ~ 0
red/green\nbicolor
$Comp
L babyM68K-rescue:LED D2
U 1 1 4E00F317
P 3600 4700
F 0 "D2" V 3600 4850 50  0000 C CNN
F 1 "LED" V 3600 4500 50  0000 C CNN
F 2 "" H 3600 4700 50  0001 C CNN
F 3 "" H 3600 4700 50  0001 C CNN
	1    3600 4700
	0    1    1    0   
$EndComp
$Comp
L babyM68K-rescue:GND #PWR013
U 1 1 4E00F2AF
P 6400 6300
F 0 "#PWR013" H 6400 6300 30  0001 C CNN
F 1 "GND" H 6400 6230 30  0001 C CNN
F 2 "" H 6400 6300 50  0001 C CNN
F 3 "" H 6400 6300 50  0001 C CNN
	1    6400 6300
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:74LS240 U22
U 1 1 4E00F268
P 7100 5200
F 0 "U22" H 7150 5000 60  0000 C CNN
F 1 "74LS240" H 7200 4800 60  0000 C CNN
F 2 "" H 7100 5200 50  0001 C CNN
F 3 "" H 7100 5200 50  0001 C CNN
	1    7100 5200
	1    0    0    -1  
$EndComp
Text Notes 7600 3050 0    60   ~ 0
Pull-ups on Select.sch
Text GLabel 7700 3500 2    60   Input ~ 0
/HALT
Text GLabel 7700 2500 2    60   Input ~ 0
/RESET
$Comp
L babyM68K-rescue:74LS06 U5
U 6 1 4E00EF4A
P 6150 3500
F 0 "U5" H 6345 3615 60  0000 C CNN
F 1 "74LS06" H 6340 3375 60  0000 C CNN
F 2 "" H 6150 3500 50  0001 C CNN
F 3 "" H 6150 3500 50  0001 C CNN
	6    6150 3500
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:74LS06 U5
U 5 1 4E00EF3B
P 6150 2500
F 0 "U5" H 6345 2615 60  0000 C CNN
F 1 "74LS06" H 6340 2375 60  0000 C CNN
F 2 "" H 6150 2500 50  0001 C CNN
F 3 "" H 6150 2500 50  0001 C CNN
	5    6150 2500
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:74LS14 U2
U 5 2 4E00EECA
P 4350 2500
F 0 "U2" H 4500 2600 40  0000 C CNN
F 1 "74LS14" H 4550 2400 40  0000 C CNN
F 2 "" H 4350 2500 50  0001 C CNN
F 3 "" H 4350 2500 50  0001 C CNN
	5    4350 2500
	1    0    0    -1  
$EndComp
Text Notes 4500 1550 0    60   ~ 0
Select.sch
Text GLabel 3650 1500 2    60   Input ~ 0
PU-10K-clear
Text Notes 2300 3450 0    60   ~ 0
Reset\nconnector
$Comp
L babyM68K-rescue:GND #PWR014
U 1 1 4E00ECFF
P 1600 4050
F 0 "#PWR014" H 1600 4050 30  0001 C CNN
F 1 "GND" H 1600 3980 30  0001 C CNN
F 2 "" H 1600 4050 50  0001 C CNN
F 3 "" H 1600 4050 50  0001 C CNN
	1    1600 4050
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:CP CP1
U 1 1 4E00ECE3
P 3300 2700
F 0 "CP1" H 3350 2800 50  0000 L CNN
F 1 "47uF" H 3350 2600 50  0000 L CNN
F 2 "" H 3300 2700 50  0001 C CNN
F 3 "" H 3300 2700 50  0001 C CNN
	1    3300 2700
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:CONN_2 P1
U 1 1 4E00ECC7
P 2400 3150
F 0 "P1" V 2350 3150 40  0000 C CNN
F 1 "CONN_2" V 2450 3150 40  0000 C CNN
F 2 "" H 2400 3150 50  0001 C CNN
F 3 "" H 2400 3150 50  0001 C CNN
	1    2400 3150
	0    1    1    0   
$EndComp
$Comp
L babyM68K-rescue:SW_PUSH SW1
U 1 1 4E00EC39
P 2200 2500
F 0 "SW1" H 2350 2610 50  0000 C CNN
F 1 "SW_PUSH" H 2200 2420 50  0000 C CNN
F 2 "" H 2200 2500 50  0001 C CNN
F 3 "" H 2200 2500 50  0001 C CNN
	1    2200 2500
	1    0    0    -1  
$EndComp
$EndSCHEMATC
