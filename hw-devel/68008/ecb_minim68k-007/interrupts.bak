EESchema Schematic File Version 2  date 9/5/2013 10:56:11 AM
LIBS:00N8VEM
LIBS:SBC-188
LIBS:74xx
LIBS:power
LIBS:device
LIBS:conn
LIBS:transistors
LIBS:linear
LIBS:motorola
LIBS:regul
LIBS:cmos4000
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:special
LIBS:microcontrollers
LIBS:dsp
LIBS:microchip
LIBS:analog_switches
LIBS:texas
LIBS:intel
LIBS:audio
LIBS:interface
LIBS:digital-audio
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:valves
LIBS:babyM68K-cache
EELAYER 25  0
EELAYER END
$Descr A4 11700 8267
encoding utf-8
Sheet 3 10
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
	4000 3950 4400 3950
Wire Wire Line
	3350 7100 3600 7100
Wire Wire Line
	2800 4000 2350 4000
Wire Wire Line
	2350 4000 2350 4250
Wire Wire Line
	2350 4250 2000 4250
Wire Wire Line
	2800 3800 2500 3800
Wire Wire Line
	2500 3800 2500 3750
Wire Wire Line
	2500 3750 2000 3750
Wire Wire Line
	5600 1900 5600 2100
Wire Wire Line
	4850 2650 4600 2650
Wire Wire Line
	4400 4150 4300 4150
Wire Wire Line
	4300 4150 4300 4900
Wire Wire Line
	4300 4900 2750 4900
Connection ~ 4600 2650
Wire Wire Line
	4600 2100 4600 3150
Wire Wire Line
	5500 1200 4550 1200
Wire Wire Line
	9500 2650 8150 2650
Wire Wire Line
	9500 5100 8450 5100
Connection ~ 8950 3150
Wire Wire Line
	8950 3150 8950 3650
Wire Wire Line
	8150 3150 9500 3150
Wire Wire Line
	6400 1200 8950 1200
Wire Wire Line
	3600 6600 3150 6600
Wire Wire Line
	3600 6300 3400 6300
Wire Wire Line
	3400 6300 3400 6100
Wire Wire Line
	2450 1200 3650 1200
Wire Wire Line
	8950 3650 9500 3650
Wire Wire Line
	3100 2900 2450 2900
Wire Wire Line
	6600 5900 7250 5900
Wire Wire Line
	7250 5900 7250 5250
Wire Wire Line
	3600 6900 3200 6900
Wire Wire Line
	2500 7000 3600 7000
Wire Wire Line
	8950 1200 8950 2650
Connection ~ 8950 2650
Wire Wire Line
	4600 2100 5600 2100
Wire Wire Line
	6350 2650 7250 2650
Wire Wire Line
	4600 3150 4850 3150
Wire Wire Line
	4000 2900 4850 2900
Wire Wire Line
	5600 4050 5600 3700
Wire Wire Line
	7250 2650 7250 4950
Connection ~ 7250 3150
Wire Wire Line
	2800 3900 2500 3900
Wire Wire Line
	2500 3900 2500 3950
Wire Wire Line
	2500 3950 2000 3950
Wire Wire Line
	2000 4450 2600 4450
Wire Wire Line
	2600 4450 2600 4100
Wire Wire Line
	2600 4100 2800 4100
Wire Wire Line
	2500 7200 3600 7200
Text GLabel 2500 7200 0    60   Output ~ 0
PU_MEM64K/4K
Text GLabel 3350 7100 0    60   Output ~ 0
PU_MEM4K/1K
$Comp
L 74LS20 U30
U 2 1 5101E6FB
P 3400 3950
F 0 "U30" H 3400 4050 60  0000 C CNN
F 1 "74LS20" H 3400 3850 60  0000 C CNN
	2    3400 3950
	1    0    0    -1  
$EndComp
$Comp
L 74LS109 U3
U 2 1 4E0540C4
P 5600 2900
F 0 "U3" H 5600 3000 60  0000 C CNN
F 1 "74LS109" H 5600 2800 60  0000 C CNN
	2    5600 2900
	1    0    0    -1  
$EndComp
$Comp
L 74LS06 U5
U 4 1 4E02576A
P 7700 3150
F 0 "U5" H 7895 3265 60  0000 C CNN
F 1 "74LS06" H 7890 3025 60  0000 C CNN
	4    7700 3150
	1    0    0    -1  
$EndComp
NoConn ~ 6350 3150
Text GLabel 2000 4450 0    60   Input ~ 0
IORQ
Text GLabel 2000 4250 0    60   Input ~ 0
M1
Text GLabel 2000 3950 0    60   Input ~ 0
A3
Text GLabel 2000 3750 0    60   Input ~ 0
A1
Text GLabel 2750 4900 0    60   Input ~ 0
/RESET
$Comp
L 74LS08 U12
U 4 2 4E053C90
P 5000 4050
F 0 "U12" H 5000 4100 60  0000 C CNN
F 1 "74LS08" H 5000 4000 60  0000 C CNN
	4    5000 4050
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR02
U 1 1 4E053B5D
P 5600 1900
F 0 "#PWR02" H 5600 2000 30  0001 C CNN
F 1 "VCC" H 5600 2000 30  0000 C CNN
	1    5600 1900
	1    0    0    -1  
$EndComp
Text GLabel 2500 7000 0    60   Output ~ 0
B_/BUSAK
Text GLabel 3200 6900 0    60   Output ~ 0
B_/BUSRQ
Text GLabel 9500 5100 2    60   Output ~ 0
/VPA
Text GLabel 6600 5900 0    60   Input ~ 0
AS
$Comp
L 74LS10 U6
U 2 1 4E0260ED
P 7850 5100
F 0 "U6" H 7850 5150 60  0000 C CNN
F 1 "74LS10" H 7850 5050 60  0000 C CNN
	2    7850 5100
	1    0    0    -1  
$EndComp
$Comp
L 74LS14 U2
U 4 2 4E0260DB
P 6800 5100
F 0 "U2" H 6950 5200 40  0000 C CNN
F 1 "74LS14" H 7000 5000 40  0000 C CNN
	4    6800 5100
	1    0    0    -1  
$EndComp
$Comp
L 74LS14 U2
U 3 2 4E0260B1
P 3550 2900
F 0 "U2" H 3700 3000 40  0000 C CNN
F 1 "74LS14" H 3750 2800 40  0000 C CNN
	3    3550 2900
	1    0    0    -1  
$EndComp
Text GLabel 5150 5250 0    60   Input ~ 0
FC2
Text GLabel 5150 5100 0    60   Input ~ 0
FC1
Text GLabel 5150 4950 0    60   Input ~ 0
FC0
$Comp
L 74LS10 U6
U 1 1 4E025FEB
P 5750 5100
F 0 "U6" H 5750 5150 60  0000 C CNN
F 1 "74LS10" H 5750 5050 60  0000 C CNN
	1    5750 5100
	1    0    0    -1  
$EndComp
Text GLabel 9500 3150 2    60   Output ~ 0
/IPL0
Text GLabel 9500 3650 2    60   Output ~ 0
/IPL2
$Comp
L 74LS06 U5
U 3 1 4E025758
P 7700 2650
F 0 "U5" H 7895 2765 60  0000 C CNN
F 1 "74LS06" H 7890 2525 60  0000 C CNN
	3    7700 2650
	1    0    0    -1  
$EndComp
Text GLabel 2450 2900 0    60   Input ~ 0
B_/NMI
Text GLabel 9500 2650 2    60   Output ~ 0
/IPL1
$Comp
L 74LS06 U5
U 2 1 4E025673
P 5950 1200
F 0 "U5" H 6145 1315 60  0000 C CNN
F 1 "74LS06" H 6140 1075 60  0000 C CNN
	2    5950 1200
	1    0    0    -1  
$EndComp
$Comp
L 74LS14 U2
U 2 2 4E025666
P 4100 1200
F 0 "U2" H 4250 1300 40  0000 C CNN
F 1 "74LS14" H 4300 1100 40  0000 C CNN
	2    4100 1200
	1    0    0    -1  
$EndComp
Text Label 3600 6800 2    60   ~ 0
/IPL2
Text Label 3600 6700 2    60   ~ 0
/IPL1
Text GLabel 3150 6600 0    60   Output ~ 0
B_/RFSH
Text Label 3600 6500 2    60   ~ 0
B_/NMI
Text Label 3600 6400 2    60   ~ 0
B_/INT
$Comp
L VCC #PWR03
U 1 1 4E025525
P 3400 6100
F 0 "#PWR03" H 3400 6200 30  0001 C CNN
F 1 "VCC" H 3400 6200 30  0000 C CNN
	1    3400 6100
	1    0    0    -1  
$EndComp
$Comp
L RR9 RR1
U 1 1 4E02550B
P 3950 6800
F 0 "RR1" H 4000 7400 70  0000 C CNN
F 1 "4700 bussed" V 3980 6800 70  0000 C CNN
	1    3950 6800
	1    0    0    -1  
$EndComp
Text GLabel 2450 1200 0    60   Input ~ 0
B_/INT
$EndSCHEMATC
