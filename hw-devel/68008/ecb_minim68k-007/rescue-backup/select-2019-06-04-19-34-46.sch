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
Sheet 8 10
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
	6400 3000 4500 3000
Connection ~ 4700 2800
Wire Wire Line
	6400 2800 4700 2800
Wire Wire Line
	6800 6000 8450 6000
Wire Wire Line
	2100 5800 2400 5800
Wire Wire Line
	9650 3050 9300 3050
Wire Wire Line
	5100 7500 4300 7500
Wire Wire Line
	4300 7300 5100 7300
Connection ~ 5400 5000
Wire Wire Line
	6100 5000 5400 5000
Wire Wire Line
	5100 7100 4300 7100
Wire Wire Line
	5100 6700 4450 6700
Wire Wire Line
	5550 1900 5550 1200
Wire Wire Line
	5100 6600 5100 6400
Wire Wire Line
	7800 4900 7300 4900
Wire Wire Line
	5400 5750 3600 5750
Wire Wire Line
	5400 5750 5400 3200
Wire Wire Line
	2400 5600 2100 5600
Connection ~ 2050 2000
Wire Wire Line
	2050 4100 2050 2000
Wire Wire Line
	2050 4100 2500 4100
Wire Wire Line
	1750 2000 2400 2000
Connection ~ 2300 3200
Wire Wire Line
	2500 3200 2300 3200
Wire Wire Line
	7800 1800 7250 1800
Wire Wire Line
	6050 1950 5750 1950
Wire Wire Line
	5750 1950 5750 1900
Wire Wire Line
	5750 1900 5550 1900
Wire Wire Line
	6050 1650 5750 1650
Wire Wire Line
	5750 1650 5750 1700
Wire Wire Line
	5750 1700 3600 1700
Wire Wire Line
	3600 1600 4500 1600
Wire Wire Line
	3600 1400 4500 1400
Wire Wire Line
	2150 1500 2400 1500
Wire Wire Line
	2400 1300 2150 1300
Wire Wire Line
	2150 1400 2400 1400
Wire Wire Line
	3600 1300 3950 1300
Wire Wire Line
	3600 1500 3950 1500
Wire Wire Line
	3600 1800 6050 1800
Wire Wire Line
	5350 1900 3600 1900
Wire Wire Line
	2300 3100 2300 3400
Wire Wire Line
	2300 3400 2500 3400
Wire Wire Line
	1900 4900 2950 4900
Wire Wire Line
	2950 4900 2950 4750
Wire Wire Line
	2400 2000 2400 1900
Wire Wire Line
	2400 1800 2300 1800
Wire Wire Line
	2300 1800 2300 2600
Wire Wire Line
	4500 2600 2300 2600
Wire Wire Line
	4500 2600 4500 4250
Wire Wire Line
	4700 2000 3600 2000
Wire Wire Line
	4700 4800 6100 4800
Wire Wire Line
	4700 2000 4700 4800
Wire Wire Line
	5100 6900 4300 6900
Wire Wire Line
	5550 1200 6500 1200
Wire Wire Line
	5400 3200 8100 3200
Wire Wire Line
	4750 7200 5100 7200
Wire Wire Line
	4500 4250 3900 4250
Wire Wire Line
	5100 7400 4900 7400
Connection ~ 4500 3000
Wire Wire Line
	1700 5700 2400 5700
Wire Wire Line
	700  5900 2400 5900
Wire Wire Line
	6000 6000 6600 6000
Wire Wire Line
	7600 2900 8100 2900
$Comp
L 74LS00 U21
U 4 2 5228C3B5
P 7000 2900
F 0 "U21" H 7000 2950 60  0000 C CNN
F 1 "74LS00" H 7000 2800 60  0000 C CNN
	4    7000 2900
	1    0    0    -1  
$EndComp
Text Label 800  5900 0    60   ~ 0
SUPV/USER
Text Notes 9200 6200 2    60   ~ 0
to memory.sch also
Text GLabel 8450 6000 2    60   Output ~ 0
SUPV/USER
$Comp
L VCC #PWR017
U 1 1 5105EB60
P 6800 5500
F 0 "#PWR017" H 6800 5600 30  0001 C CNN
F 1 "VCC" H 6800 5600 30  0000 C CNN
	1    6800 5500
	1    0    0    -1  
$EndComp
$Comp
L R R3
U 1 1 5105EB1F
P 6800 5750
F 0 "R3" V 6880 5750 50  0000 C CNN
F 1 "47K" V 6800 5750 50  0000 C CNN
	1    6800 5750
	1    0    0    -1  
$EndComp
$Comp
L CONN_2 J9
U 1 1 5105EAB9
P 6700 6350
F 0 "J9" V 6650 6350 40  0000 C CNN
F 1 "CONN_2" V 6750 6350 40  0000 C CNN
	1    6700 6350
	0    1    1    0   
$EndComp
Text Notes 1000 6200 0    70   ~ 0
2013-01-25 update:\nadd FC2 so User mode\nmay not do I/O
Text GLabel 6000 6000 0    60   Input ~ 0
FC2
$Comp
L 74LS20 U30
U 1 1 5101E835
P 3000 5750
F 0 "U30" H 3000 5850 60  0000 C CNN
F 1 "74LS20" H 3000 5650 60  0000 C CNN
	1    3000 5750
	1    0    0    -1  
$EndComp
Text Notes 950  4550 0    70   ~ 0
2013-01-24 update:\nuse /Power On Clear for\nbootstrap, not /RESET
Text GLabel 1900 4900 0    70   Input ~ 0
/POClear
Text Notes 1200 1000 0    60   ~ 0
2011-08-15 update:\nfix reversed address lines
Text GLabel 4300 7500 0    60   Output ~ 0
/BERR
Text GLabel 4900 7400 0    60   Output ~ 0
B_/WAIT
$Comp
L 74LS164 U27
U 1 1 4E023ACC
P 3200 3700
F 0 "U27" H 3200 3850 60  0000 C CNN
F 1 "74LS164" H 3200 3500 60  0000 C CNN
	1    3200 3700
	1    0    0    -1  
$EndComp
Text GLabel 4300 7300 0    60   Input ~ 0
FC2
Text GLabel 4750 7200 0    60   Input ~ 0
FC1
Text Notes 8150 2000 0    60   ~ 0
External (4MEM, e.g.)\nmemory request
Text Notes 5800 2200 0    60   ~ 0
Close to enable external memory from\n$30xxxx to $37xxxx
Text GLabel 8100 3050 0    60   Input ~ 0
AS
Text GLabel 4300 7100 0    60   Input ~ 0
FC0
Text Label 6300 1200 2    60   ~ 0
PU-10K-A
Text GLabel 5100 7000 0    60   Output ~ 0
/HALT
Text GLabel 4300 6900 0    60   Output ~ 0
/RESET
Text GLabel 5100 6800 0    60   Output ~ 0
PU-10K-clear
Text Label 4950 6700 2    60   ~ 0
PU-10K-A
Text Notes 7550 5300 0    60   ~ 0
IORQ combines with M1 (CPU) to\ngenerate the Interrupt Acknowledge\nsequence.
Text GLabel 7800 1800 2    60   Output ~ 0
MREQ
$Comp
L VCC #PWR018
U 1 1 4DFFBCB1
P 5100 6400
F 0 "#PWR018" H 5100 6500 30  0001 C CNN
F 1 "VCC" H 5100 6500 30  0000 C CNN
	1    5100 6400
	1    0    0    -1  
$EndComp
$Comp
L RR9 RR2
U 1 1 4DFFBC43
P 5450 7100
F 0 "RR2" H 5500 7700 70  0000 C CNN
F 1 "10k bussed" V 5480 7100 70  0000 C CNN
	1    5450 7100
	1    0    0    -1  
$EndComp
Text GLabel 7800 4900 2    60   Output ~ 0
IORQ
Text Label 3600 5750 0    60   ~ 0
/IOSPACE
$Comp
L 74LS02 U1
U 4 2 4DFFB88A
P 6700 4900
F 0 "U1" H 6700 4950 60  0000 C CNN
F 1 "74LS02" H 6750 4850 60  0000 C CNN
	4    6700 4900
	1    0    0    -1  
$EndComp
Text GLabel 2100 5800 0    60   Input ~ 0
A16
Text GLabel 1700 5700 0    60   Input ~ 0
A17
Text GLabel 2100 5600 0    60   Input ~ 0
A18
Text Label 4000 2600 2    60   ~ 0
/ROMONLY
$Comp
L 74LS10 U26
U 3 1 4DFFB69F
P 8700 3050
F 0 "U26" H 8700 3100 60  0000 C CNN
F 1 "74LS10" H 8700 3000 60  0000 C CNN
	3    8700 3050
	1    0    0    -1  
$EndComp
Text GLabel 9650 3050 2    60   Output ~ 0
/ROM
NoConn ~ 3900 3950
NoConn ~ 3900 3800
NoConn ~ 3900 3650
NoConn ~ 3900 3500
NoConn ~ 3900 3350
NoConn ~ 3900 3200
NoConn ~ 3900 4100
$Comp
L VCC #PWR019
U 1 1 4DFFB50D
P 2300 3100
F 0 "#PWR019" H 2300 3200 30  0001 C CNN
F 1 "VCC" H 2300 3200 30  0000 C CNN
	1    2300 3100
	1    0    0    -1  
$EndComp
Text GLabel 1750 2000 0    60   Input ~ 0
/AS
$Comp
L CONN_2 J4
U 1 1 4DFFB37E
P 5450 2250
F 0 "J4" V 5400 2250 40  0000 C CNN
F 1 "CONN_2" V 5500 2250 40  0000 C CNN
	1    5450 2250
	0    1    1    0   
$EndComp
$Comp
L 74LS10 U26
U 2 2 4DFFB336
P 6650 1800
F 0 "U26" H 6650 1850 60  0000 C CNN
F 1 "74LS10" H 6650 1750 60  0000 C CNN
	2    6650 1800
	1    0    0    -1  
$EndComp
Text GLabel 4500 1600 2    60   Output ~ 0
/CSRAM3
Text GLabel 3950 1500 2    60   Output ~ 0
/CSRAM2
Text GLabel 4500 1400 2    60   Output ~ 0
/CSRAM1
Text GLabel 3950 1300 2    60   Output ~ 0
/CSRAM0
Text GLabel 2150 1300 0    60   Input ~ 0
A19
Text GLabel 2150 1400 0    60   Input ~ 0
A20
Text GLabel 2150 1500 0    60   Input ~ 0
A21
$Comp
L 74LS138 U25
U 1 1 4DFFB1DE
P 3000 1650
F 0 "U25" H 3000 2150 60  0000 C CNN
F 1 "74LS138" H 3000 1100 60  0000 C CNN
	1    3000 1650
	1    0    0    -1  
$EndComp
$EndSCHEMATC
