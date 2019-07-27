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
Sheet 7 10
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
L 74LS164 U23
U 1 1 4E023B2B
P 3400 2200
F 0 "U23" H 3400 2350 60  0000 C CNN
F 1 "74LS164" H 3400 2000 60  0000 C CNN
	1    3400 2200
	1    0    0    -1  
$EndComp
Wire Wire Line
	4100 1850 6300 1850
Wire Wire Line
	9700 4500 9500 4500
Wire Wire Line
	6300 2400 6300 2500
Wire Wire Line
	6300 2500 4550 2500
Wire Wire Line
	4550 2500 4550 2000
Wire Wire Line
	6300 1850 6300 2200
Wire Wire Line
	6850 2300 6300 2300
Connection ~ 5150 3600
Wire Wire Line
	5150 3600 5150 4500
Wire Wire Line
	5150 4500 5600 4500
Wire Wire Line
	5600 4400 5300 4400
Wire Wire Line
	5300 4400 5300 3500
Wire Wire Line
	5300 3500 5600 3500
Wire Wire Line
	5600 4600 4750 4600
Wire Wire Line
	4100 1700 5500 1700
Wire Wire Line
	3000 5800 5600 5800
Wire Wire Line
	4100 1350 2700 1350
Wire Wire Line
	2700 1350 2700 1700
Wire Wire Line
	2100 1600 2100 1900
Wire Wire Line
	2100 1900 2700 1900
Wire Wire Line
	1550 3800 1800 3800
Wire Wire Line
	2700 3800 3500 3800
Wire Wire Line
	3150 3250 3150 3800
Connection ~ 3150 3800
Wire Wire Line
	1550 2600 2700 2600
Wire Wire Line
	2700 1700 2100 1700
Connection ~ 2100 1700
Wire Wire Line
	5600 5700 3600 5700
Wire Wire Line
	5600 4850 5100 4850
Wire Wire Line
	5100 4850 5100 5100
Wire Wire Line
	5600 4700 4750 4700
Wire Wire Line
	5500 2300 5000 2300
Wire Wire Line
	4550 2000 4100 2000
Wire Wire Line
	4850 3600 5600 3600
Wire Wire Line
	4850 3400 5600 3400
Wire Wire Line
	5500 1700 5500 2200
Wire Wire Line
	5500 2400 4700 2400
Wire Wire Line
	4700 2400 4700 1850
Connection ~ 4700 1850
Wire Wire Line
	7100 4600 8300 4600
Wire Wire Line
	8050 4400 8300 4400
Text Notes 6250 3350 0    60   ~ 0
Memory write wait states:\n    1-2 (0 ws)\n    2-3 (1 ws)\n\nMemory reads are always 0 wait states.\n
Text Label 7250 4600 0    60   ~ 0
RDY
Text GLabel 8050 4400 0    60   Input ~ 0
/WAIT
Text GLabel 9700 4500 2    60   Output ~ 0
/DTACK
$Comp
L 74LS00 U21
U 2 1 4E01424E
P 8900 4500
F 0 "U21" H 8900 4550 60  0000 C CNN
F 1 "74LS00" H 8900 4400 60  0000 C CNN
	2    8900 4500
	1    0    0    -1  
$EndComp
Text Label 5050 3400 2    60   ~ 0
1WS
$Comp
L CONN_3 J3
U 1 1 4E013FC9
P 5950 3500
F 0 "J3" V 5900 3500 50  0000 C CNN
F 1 "MemW-WS" V 6000 3500 40  0000 C CNN
	1    5950 3500
	1    0    0    1   
$EndComp
Text Notes 5200 2650 0    60   ~ 0
I/O wait states:  \n    read:  1-3  (1 ws),  3-5 (2 ws)\n    write:  2-4  (2 ws),  4-6 (3 ws)\n
Text Label 6450 2300 0    60   ~ 0
WS-IOWR
Text Label 5000 2300 0    60   ~ 0
WS-IORD
Text Label 4750 4600 0    60   ~ 0
WS-IOWR
Text Label 4750 4700 0    60   ~ 0
WS-IORD
$Comp
L GND #PWR015
U 1 1 4E013CDF
P 5100 5100
F 0 "#PWR015" H 5100 5100 30  0001 C CNN
F 1 "GND" H 5100 5030 30  0001 C CNN
	1    5100 5100
	1    0    0    -1  
$EndComp
Text Label 5050 3600 2    60   ~ 0
0WS
NoConn ~ 7100 5250
NoConn ~ 5600 5050
NoConn ~ 5600 5150
NoConn ~ 5600 5250
NoConn ~ 5600 5350
NoConn ~ 5600 5500
Text GLabel 3000 5800 0    60   Input ~ 0
IORQ
Text GLabel 3600 5700 0    60   Input ~ 0
R/W
NoConn ~ 4100 2150
NoConn ~ 4100 2300
NoConn ~ 4100 2450
NoConn ~ 4100 2600
NoConn ~ 4100 2750
Text Label 4100 2600 0    60   ~ 0
7WS
Text Label 4100 2450 0    60   ~ 0
6WS
Text Label 4100 2300 0    60   ~ 0
5WS
Text Label 4100 2150 0    60   ~ 0
4WS
Text Label 4100 2750 0    60   ~ 0
8WS
Text Label 4100 2000 0    60   ~ 0
3WS
Text Label 4100 1850 0    60   ~ 0
2WS
Text Label 4100 1700 0    60   ~ 0
1WS
Text Label 4100 1350 0    60   ~ 0
0WS
$Comp
L VCC #PWR016
U 1 1 4E013B40
P 2100 1600
F 0 "#PWR016" H 2100 1700 30  0001 C CNN
F 1 "VCC" H 2100 1700 30  0000 C CNN
	1    2100 1600
	1    0    0    -1  
$EndComp
Text GLabel 1550 2600 0    60   Input ~ 0
CLK
Text GLabel 1550 3800 0    60   Input ~ 0
/AS
Text GLabel 3500 3800 2    60   Output ~ 0
AS
$Comp
L 74F04 U13
U 2 2 4E013ACE
P 2250 3800
F 0 "U13" H 2445 3915 60  0000 C CNN
F 1 "74F04" H 2440 3675 60  0000 C CNN
	2    2250 3800
	1    0    0    -1  
$EndComp
$Comp
L 74LS153 U24
U 1 1 4E013A1E
P 6350 5100
F 0 "U24" H 6350 5400 60  0000 C CNN
F 1 "74LS153" H 6350 5250 60  0000 C CNN
	1    6350 5100
	1    0    0    -1  
$EndComp
$Comp
L CONN_3X2 J2
U 1 1 4E0139CE
P 5900 2350
F 0 "J2" H 5900 2600 50  0000 C CNN
F 1 "WAIT" V 5900 2400 40  0000 C CNN
	1    5900 2350
	1    0    0    -1  
$EndComp
$EndSCHEMATC
