EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title "Vga_FX"
Date "2020-08-19"
Rev "1.0"
Comp ""
Comment1 "ZDS Project"
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L MultiF-Board-rescue:PINHD-1X24 JPB1
U 1 1 535944CA
P 750 5000
F 0 "JPB1" H 500 6225 50  0000 L BNN
F 1 "PINHD-1X24" H 500 3600 50  0000 L BNN
F 2 "Pin_Headers:Pin_Header_Angled_1x24" H 750 5150 50  0001 C CNN
F 3 "" H 750 5000 60  0000 C CNN
	1    750  5000
	-1   0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:PINHD-1X24 JPA1
U 1 1 5359460E
P 750 1850
F 0 "JPA1" H 500 3075 50  0000 L BNN
F 1 "PINHD-1X24" H 500 450 50  0000 L BNN
F 2 "Pin_Headers:Pin_Header_Angled_1x24" H 750 2000 50  0001 C CNN
F 3 "" H 750 1850 60  0000 C CNN
	1    750  1850
	-1   0    0    -1  
$EndComp
Text GLabel 1150 5500 2    60   BiDi ~ 0
D7
Text GLabel 1150 5600 2    60   BiDi ~ 0
D6
Text GLabel 1150 5700 2    60   BiDi ~ 0
D5
Text GLabel 1150 5800 2    60   BiDi ~ 0
D4
Text GLabel 1150 5900 2    60   BiDi ~ 0
D3
Text GLabel 1150 6000 2    60   BiDi ~ 0
D2
Text GLabel 1150 6100 2    60   BiDi ~ 0
D1
Text GLabel 1150 6200 2    60   BiDi ~ 0
D0
$Comp
L MultiF-Board-rescue:74LS244 U5
U 1 1 535A6855
P 2600 5550
F 0 "U5" H 2650 5350 60  0000 C CNN
F 1 "74LS244" H 2700 5150 60  0000 C CNN
F 2 "" H 2600 5550 60  0000 C CNN
F 3 "~" H 2600 5550 60  0000 C CNN
	1    2600 5550
	1    0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:74LS244 U4
U 1 1 535A687E
P 2600 4000
F 0 "U4" H 2650 3800 60  0000 C CNN
F 1 "74LS244" H 2700 3600 60  0000 C CNN
F 2 "" H 2600 4000 60  0000 C CNN
F 3 "~" H 2600 4000 60  0000 C CNN
	1    2600 4000
	1    0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:GND-RESCUE-MultiF-Board #PWR01
U 1 1 535A69D6
P 1900 6300
F 0 "#PWR01" H 1900 6300 30  0001 C CNN
F 1 "GND" H 1900 6230 30  0001 C CNN
F 2 "" H 1900 6300 60  0000 C CNN
F 3 "" H 1900 6300 60  0000 C CNN
	1    1900 6300
	1    0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:GND-RESCUE-MultiF-Board #PWR02
U 1 1 535A69E5
P 1900 4650
F 0 "#PWR02" H 1900 4650 30  0001 C CNN
F 1 "GND" H 1900 4580 30  0001 C CNN
F 2 "" H 1900 4650 60  0000 C CNN
F 3 "" H 1900 4650 60  0000 C CNN
	1    1900 4650
	1    0    0    -1  
$EndComp
Text GLabel 3400 3500 2    60   Input ~ 0
A0
Text GLabel 3400 3600 2    60   Input ~ 0
A1
Text GLabel 3400 3700 2    60   Input ~ 0
A2
Text GLabel 3400 3800 2    60   Input ~ 0
A3
Text GLabel 3400 3900 2    60   Input ~ 0
A4
Text GLabel 3400 4000 2    60   Input ~ 0
A5
Text GLabel 3400 4100 2    60   Input ~ 0
A6
Text GLabel 3400 4200 2    60   Input ~ 0
A7
Text GLabel 3400 5050 2    60   Input ~ 0
A8
Text GLabel 3400 5150 2    60   Input ~ 0
A9
Text GLabel 3400 5250 2    60   Input ~ 0
A10
Text GLabel 3400 5350 2    60   Input ~ 0
A11
Text GLabel 3400 5450 2    60   Input ~ 0
A12
Text GLabel 3400 5550 2    60   Input ~ 0
A13
Text GLabel 3400 5650 2    60   Input ~ 0
A14
Text GLabel 3400 5750 2    60   Input ~ 0
A15
NoConn ~ 1200 750 
NoConn ~ 1200 850 
NoConn ~ 1200 950 
$Comp
L MultiF-Board-rescue:-12V #PWR5
U 1 1 535A7B8F
P 1450 2350
F 0 "#PWR5" H 1450 2480 20  0001 C CNN
F 1 "-12V" H 1450 2450 30  0000 C CNN
F 2 "" H 1450 2350 60  0000 C CNN
F 3 "" H 1450 2350 60  0000 C CNN
	1    1450 2350
	1    0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:+5V #PWR03
U 1 1 535A7BFD
P 1300 1950
F 0 "#PWR03" H 1300 2040 20  0001 C CNN
F 1 "+5V" H 1300 2040 30  0000 C CNN
F 2 "" H 1300 1950 60  0000 C CNN
F 3 "" H 1300 1950 60  0000 C CNN
	1    1300 1950
	1    0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:GND-RESCUE-MultiF-Board #PWR04
U 1 1 535A7C0C
P 1300 2100
F 0 "#PWR04" H 1300 2100 30  0001 C CNN
F 1 "GND" H 1300 2030 30  0001 C CNN
F 2 "" H 1300 2100 60  0000 C CNN
F 3 "" H 1300 2100 60  0000 C CNN
	1    1300 2100
	1    0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:74LS244 U3
U 1 1 535A7C2A
P 2600 2750
F 0 "U3" H 2650 2550 60  0000 C CNN
F 1 "74LS244" H 2700 2350 60  0000 C CNN
F 2 "" H 2600 2750 60  0000 C CNN
F 3 "~" H 2600 2750 60  0000 C CNN
	1    2600 2750
	1    0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:GND-RESCUE-MultiF-Board #PWR05
U 1 1 535A7C39
P 1900 3350
F 0 "#PWR05" H 1900 3350 30  0001 C CNN
F 1 "GND" H 1900 3280 30  0001 C CNN
F 2 "" H 1900 3350 60  0000 C CNN
F 3 "" H 1900 3350 60  0000 C CNN
	1    1900 3350
	1    0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:+12V #PWR06
U 1 1 535A8003
P 1400 2250
F 0 "#PWR06" H 1400 2200 20  0001 C CNN
F 1 "+12V" H 1400 2350 30  0000 C CNN
F 2 "" H 1400 2250 60  0000 C CNN
F 3 "" H 1400 2250 60  0000 C CNN
	1    1400 2250
	1    0    0    -1  
$EndComp
Text GLabel 3400 2950 2    60   Input ~ 0
/MREQ
Text GLabel 3400 2750 2    60   Input ~ 0
/IORQ
Text GLabel 3400 2650 2    60   Input ~ 0
/M1
Text GLabel 3400 2550 2    60   Input ~ 0
/WR
Text GLabel 3400 2450 2    60   Input ~ 0
/RD
Text GLabel 3400 2350 2    60   Input ~ 0
/RST
NoConn ~ 1200 1450
NoConn ~ 1200 1550
NoConn ~ 1200 1750
Text Notes 1200 1800 0    60   ~ 0
/BUSRQ
Text Notes 1200 1600 0    60   ~ 0
/NMI
Text Notes 1200 1500 0    60   ~ 0
/WAIT
NoConn ~ 1200 1650
Text Notes 1200 1700 0    60   ~ 0
/BUSAK
$Comp
L MultiF-Board-rescue:VCC #PWR07
U 1 1 535A94C5
P 1450 1950
F 0 "#PWR07" H 1450 2050 30  0001 C CNN
F 1 "VCC" H 1450 2050 30  0000 C CNN
F 2 "" H 1450 1950 60  0000 C CNN
F 3 "" H 1450 1950 60  0000 C CNN
	1    1450 1950
	1    0    0    -1  
$EndComp
NoConn ~ 4500 5350
NoConn ~ 4500 5450
$Comp
L MultiF-Board-rescue:C-RESCUE-MultiF-Board C12
U 1 1 535ED49F
P 15450 1300
F 0 "C12" H 15450 1400 40  0000 L CNN
F 1 "0.1" H 15456 1215 40  0000 L CNN
F 2 "" H 15488 1150 30  0000 C CNN
F 3 "~" H 15450 1300 60  0000 C CNN
	1    15450 1300
	0    -1   -1   0   
$EndComp
$Comp
L MultiF-Board-rescue:C-RESCUE-MultiF-Board C13
U 1 1 535ED4A5
P 15450 1500
F 0 "C13" H 15450 1600 40  0000 L CNN
F 1 "0.1" H 15456 1415 40  0000 L CNN
F 2 "" H 15488 1350 30  0000 C CNN
F 3 "~" H 15450 1500 60  0000 C CNN
	1    15450 1500
	0    -1   -1   0   
$EndComp
$Comp
L MultiF-Board-rescue:C-RESCUE-MultiF-Board C14
U 1 1 535ED4AB
P 15450 1700
F 0 "C14" H 15450 1800 40  0000 L CNN
F 1 "0.1" H 15456 1615 40  0000 L CNN
F 2 "" H 15488 1550 30  0000 C CNN
F 3 "~" H 15450 1700 60  0000 C CNN
	1    15450 1700
	0    -1   -1   0   
$EndComp
$Comp
L MultiF-Board-rescue:C-RESCUE-MultiF-Board C15
U 1 1 535ED4C5
P 15450 1900
F 0 "C15" H 15450 2000 40  0000 L CNN
F 1 "0.1" H 15456 1815 40  0000 L CNN
F 2 "" H 15488 1750 30  0000 C CNN
F 3 "~" H 15450 1900 60  0000 C CNN
	1    15450 1900
	0    -1   -1   0   
$EndComp
$Comp
L MultiF-Board-rescue:C-RESCUE-MultiF-Board C16
U 1 1 535ED4CB
P 15450 2100
F 0 "C16" H 15450 2200 40  0000 L CNN
F 1 "0.1" H 15456 2015 40  0000 L CNN
F 2 "" H 15488 1950 30  0000 C CNN
F 3 "~" H 15450 2100 60  0000 C CNN
	1    15450 2100
	0    -1   -1   0   
$EndComp
$Comp
L MultiF-Board-rescue:C-RESCUE-MultiF-Board C17
U 1 1 535ED4D1
P 15450 2300
F 0 "C17" H 15450 2400 40  0000 L CNN
F 1 "0.1" H 15456 2215 40  0000 L CNN
F 2 "" H 15488 2150 30  0000 C CNN
F 3 "~" H 15450 2300 60  0000 C CNN
	1    15450 2300
	0    -1   -1   0   
$EndComp
$Comp
L MultiF-Board-rescue:C-RESCUE-MultiF-Board C18
U 1 1 535ED4D7
P 15450 2500
F 0 "C18" H 15450 2600 40  0000 L CNN
F 1 "0.1" H 15456 2415 40  0000 L CNN
F 2 "" H 15488 2350 30  0000 C CNN
F 3 "~" H 15450 2500 60  0000 C CNN
	1    15450 2500
	0    -1   -1   0   
$EndComp
$Comp
L MultiF-Board-rescue:C-RESCUE-MultiF-Board C19
U 1 1 535ED505
P 15450 2700
F 0 "C19" H 15450 2800 40  0000 L CNN
F 1 "0.1" H 15456 2615 40  0000 L CNN
F 2 "" H 15488 2550 30  0000 C CNN
F 3 "~" H 15450 2700 60  0000 C CNN
	1    15450 2700
	0    -1   -1   0   
$EndComp
$Comp
L MultiF-Board-rescue:C-RESCUE-MultiF-Board C20
U 1 1 535ED50B
P 15450 2900
F 0 "C20" H 15450 3000 40  0000 L CNN
F 1 "0.1" H 15456 2815 40  0000 L CNN
F 2 "" H 15488 2750 30  0000 C CNN
F 3 "~" H 15450 2900 60  0000 C CNN
	1    15450 2900
	0    -1   -1   0   
$EndComp
$Comp
L MultiF-Board-rescue:C-RESCUE-MultiF-Board C21
U 1 1 535ED511
P 15450 3100
F 0 "C21" H 15450 3200 40  0000 L CNN
F 1 "0.1" H 15456 3015 40  0000 L CNN
F 2 "" H 15488 2950 30  0000 C CNN
F 3 "~" H 15450 3100 60  0000 C CNN
	1    15450 3100
	0    -1   -1   0   
$EndComp
$Comp
L MultiF-Board-rescue:C-RESCUE-MultiF-Board C22
U 1 1 535ED517
P 15450 3300
F 0 "C22" H 15450 3400 40  0000 L CNN
F 1 "0.1" H 15456 3215 40  0000 L CNN
F 2 "" H 15488 3150 30  0000 C CNN
F 3 "~" H 15450 3300 60  0000 C CNN
	1    15450 3300
	0    -1   -1   0   
$EndComp
$Comp
L MultiF-Board-rescue:C-RESCUE-MultiF-Board C23
U 1 1 535ED51D
P 15450 3500
F 0 "C23" H 15450 3600 40  0000 L CNN
F 1 "0.1" H 15456 3415 40  0000 L CNN
F 2 "" H 15488 3350 30  0000 C CNN
F 3 "~" H 15450 3500 60  0000 C CNN
	1    15450 3500
	0    -1   -1   0   
$EndComp
$Comp
L MultiF-Board-rescue:C-RESCUE-MultiF-Board C24
U 1 1 535ED523
P 15450 3700
F 0 "C24" H 15450 3800 40  0000 L CNN
F 1 "0.1" H 15456 3615 40  0000 L CNN
F 2 "" H 15488 3550 30  0000 C CNN
F 3 "~" H 15450 3700 60  0000 C CNN
	1    15450 3700
	0    -1   -1   0   
$EndComp
$Comp
L MultiF-Board-rescue:C-RESCUE-MultiF-Board C25
U 1 1 535ED529
P 15450 3900
F 0 "C25" H 15450 4000 40  0000 L CNN
F 1 "0.1" H 15456 3815 40  0000 L CNN
F 2 "" H 15488 3750 30  0000 C CNN
F 3 "~" H 15450 3900 60  0000 C CNN
	1    15450 3900
	0    -1   -1   0   
$EndComp
$Comp
L MultiF-Board-rescue:C-RESCUE-MultiF-Board C26
U 1 1 535ED52F
P 15450 4100
F 0 "C26" H 15450 4200 40  0000 L CNN
F 1 "0.1" H 15456 4015 40  0000 L CNN
F 2 "" H 15488 3950 30  0000 C CNN
F 3 "~" H 15450 4100 60  0000 C CNN
	1    15450 4100
	0    -1   -1   0   
$EndComp
$Comp
L MultiF-Board-rescue:C-RESCUE-MultiF-Board C27
U 1 1 535ED535
P 15450 4300
F 0 "C27" H 15450 4400 40  0000 L CNN
F 1 "0.1" H 15456 4215 40  0000 L CNN
F 2 "" H 15488 4150 30  0000 C CNN
F 3 "~" H 15450 4300 60  0000 C CNN
	1    15450 4300
	0    -1   -1   0   
$EndComp
$Comp
L MultiF-Board-rescue:C-RESCUE-MultiF-Board C28
U 1 1 535ED53B
P 15450 4500
F 0 "C28" H 15450 4600 40  0000 L CNN
F 1 "0.1" H 15456 4415 40  0000 L CNN
F 2 "" H 15488 4350 30  0000 C CNN
F 3 "~" H 15450 4500 60  0000 C CNN
	1    15450 4500
	0    -1   -1   0   
$EndComp
$Comp
L MultiF-Board-rescue:C-RESCUE-MultiF-Board C29
U 1 1 535ED541
P 15450 4700
F 0 "C29" H 15450 4800 40  0000 L CNN
F 1 "0.1" H 15456 4615 40  0000 L CNN
F 2 "" H 15488 4550 30  0000 C CNN
F 3 "~" H 15450 4700 60  0000 C CNN
	1    15450 4700
	0    -1   -1   0   
$EndComp
$Comp
L MultiF-Board-rescue:C-RESCUE-MultiF-Board C30
U 1 1 535ED547
P 15450 4900
F 0 "C30" H 15450 5000 40  0000 L CNN
F 1 "0.1" H 15456 4815 40  0000 L CNN
F 2 "" H 15488 4750 30  0000 C CNN
F 3 "~" H 15450 4900 60  0000 C CNN
	1    15450 4900
	0    -1   -1   0   
$EndComp
$Comp
L MultiF-Board-rescue:C-RESCUE-MultiF-Board C31
U 1 1 535ED54D
P 15450 5100
F 0 "C31" H 15450 5200 40  0000 L CNN
F 1 "0.1" H 15456 5015 40  0000 L CNN
F 2 "" H 15488 4950 30  0000 C CNN
F 3 "~" H 15450 5100 60  0000 C CNN
	1    15450 5100
	0    -1   -1   0   
$EndComp
$Comp
L MultiF-Board-rescue:C-RESCUE-MultiF-Board C32
U 1 1 535ED553
P 15450 5300
F 0 "C32" H 15450 5400 40  0000 L CNN
F 1 "0.1" H 15456 5215 40  0000 L CNN
F 2 "" H 15488 5150 30  0000 C CNN
F 3 "~" H 15450 5300 60  0000 C CNN
	1    15450 5300
	0    -1   -1   0   
$EndComp
$Comp
L MultiF-Board-rescue:C-RESCUE-MultiF-Board C33
U 1 1 535ED559
P 15450 5500
F 0 "C33" H 15450 5600 40  0000 L CNN
F 1 "0.1" H 15456 5415 40  0000 L CNN
F 2 "" H 15488 5350 30  0000 C CNN
F 3 "~" H 15450 5500 60  0000 C CNN
	1    15450 5500
	0    -1   -1   0   
$EndComp
$Comp
L MultiF-Board-rescue:C-RESCUE-MultiF-Board C34
U 1 1 535ED55F
P 15450 5700
F 0 "C34" H 15450 5800 40  0000 L CNN
F 1 "0.1" H 15456 5615 40  0000 L CNN
F 2 "" H 15488 5550 30  0000 C CNN
F 3 "~" H 15450 5700 60  0000 C CNN
	1    15450 5700
	0    -1   -1   0   
$EndComp
$Comp
L MultiF-Board-rescue:CP1-RESCUE-MultiF-Board C11
U 1 1 535ED567
P 15450 1050
F 0 "C11" H 15500 1150 50  0000 L CNN
F 1 "10 uF" H 15500 950 50  0000 L CNN
F 2 "" H 15450 1050 60  0000 C CNN
F 3 "~" H 15450 1050 60  0000 C CNN
	1    15450 1050
	0    -1   -1   0   
$EndComp
$Comp
L MultiF-Board-rescue:GND-RESCUE-MultiF-Board #PWR014
U 1 1 535EFD16
P 15900 1150
F 0 "#PWR014" H 15900 1150 30  0001 C CNN
F 1 "GND" H 15900 1080 30  0001 C CNN
F 2 "" H 15900 1150 60  0000 C CNN
F 3 "" H 15900 1150 60  0000 C CNN
	1    15900 1150
	1    0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:VCC #PWR015
U 1 1 535F2729
P 15000 950
F 0 "#PWR015" H 15000 1050 30  0001 C CNN
F 1 "VCC" H 15000 1050 30  0000 C CNN
F 2 "" H 15000 950 60  0000 C CNN
F 3 "" H 15000 950 60  0000 C CNN
	1    15000 950 
	1    0    0    -1  
$EndComp
Text GLabel 3400 2250 2    60   Input ~ 0
/RFH
Text Label 4500 5550 2    60   ~ 0
SER_CLK
Text GLabel 3400 2850 2    60   Input ~ 0
CLK
$Comp
L MultiF-Board-rescue:C-RESCUE-MultiF-Board C35
U 1 1 5368D306
P 15450 5900
F 0 "C35" H 15450 6000 40  0000 L CNN
F 1 "0.1" H 15456 5815 40  0000 L CNN
F 2 "" H 15488 5750 30  0000 C CNN
F 3 "~" H 15450 5900 60  0000 C CNN
	1    15450 5900
	0    -1   1    0   
$EndComp
$Comp
L MultiF-Board-rescue:C-RESCUE-MultiF-Board C36
U 1 1 5368D318
P 15450 6100
F 0 "C36" H 15450 6200 40  0000 L CNN
F 1 "0.1" H 15456 6015 40  0000 L CNN
F 2 "" H 15488 5950 30  0000 C CNN
F 3 "~" H 15450 6100 60  0000 C CNN
	1    15450 6100
	0    -1   1    0   
$EndComp
$Comp
L MultiF-Board-rescue:C-RESCUE-MultiF-Board C37
U 1 1 5368D31E
P 15450 6300
F 0 "C37" H 15450 6400 40  0000 L CNN
F 1 "0.1" H 15456 6215 40  0000 L CNN
F 2 "" H 15488 6150 30  0000 C CNN
F 3 "~" H 15450 6300 60  0000 C CNN
	1    15450 6300
	0    -1   1    0   
$EndComp
$Comp
L MultiF-Board-rescue:C-RESCUE-MultiF-Board C38
U 1 1 5368D324
P 15450 6500
F 0 "C38" H 15450 6600 40  0000 L CNN
F 1 "0.1" H 15456 6415 40  0000 L CNN
F 2 "" H 15488 6350 30  0000 C CNN
F 3 "~" H 15450 6500 60  0000 C CNN
	1    15450 6500
	0    -1   1    0   
$EndComp
$Comp
L MultiF-Board-rescue:C-RESCUE-MultiF-Board C39
U 1 1 5368D32A
P 15450 6700
F 0 "C39" H 15450 6800 40  0000 L CNN
F 1 "0.1" H 15456 6615 40  0000 L CNN
F 2 "" H 15488 6550 30  0000 C CNN
F 3 "~" H 15450 6700 60  0000 C CNN
	1    15450 6700
	0    -1   1    0   
$EndComp
$Comp
L MultiF-Board-rescue:C-RESCUE-MultiF-Board C40
U 1 1 5368D330
P 15450 6900
F 0 "C40" H 15450 7000 40  0000 L CNN
F 1 "0.1" H 15456 6815 40  0000 L CNN
F 2 "" H 15488 6750 30  0000 C CNN
F 3 "~" H 15450 6900 60  0000 C CNN
	1    15450 6900
	0    -1   1    0   
$EndComp
Wire Wire Line
	850  5500 1150 5500
Wire Wire Line
	850  5600 1150 5600
Wire Wire Line
	850  5700 1150 5700
Wire Wire Line
	850  5800 1150 5800
Wire Wire Line
	850  5900 1150 5900
Wire Wire Line
	850  6000 1150 6000
Wire Wire Line
	850  6100 1150 6100
Wire Wire Line
	850  6200 1150 6200
Wire Wire Line
	850  5400 1450 5400
Wire Wire Line
	1450 5400 1450 5750
Wire Wire Line
	1450 5750 1900 5750
Wire Wire Line
	850  5300 1500 5300
Wire Wire Line
	1500 5300 1500 5650
Wire Wire Line
	1500 5650 1900 5650
Wire Wire Line
	850  5200 1550 5200
Wire Wire Line
	1550 5200 1550 5550
Wire Wire Line
	1550 5550 1900 5550
Wire Wire Line
	850  5100 1600 5100
Wire Wire Line
	1600 5100 1600 5450
Wire Wire Line
	1600 5450 1900 5450
Wire Wire Line
	850  5000 1650 5000
Wire Wire Line
	1650 5000 1650 5350
Wire Wire Line
	1650 5350 1900 5350
Wire Wire Line
	850  4900 1700 4900
Wire Wire Line
	1700 4900 1700 5250
Wire Wire Line
	1700 5250 1900 5250
Wire Wire Line
	850  4800 1750 4800
Wire Wire Line
	1750 4800 1750 5150
Wire Wire Line
	1750 5150 1900 5150
Wire Wire Line
	850  4700 1800 4700
Wire Wire Line
	1800 4700 1800 5050
Wire Wire Line
	1800 5050 1900 5050
Wire Wire Line
	1900 4400 1900 4500
Connection ~ 1900 4500
Wire Wire Line
	1900 5950 1900 6050
Connection ~ 1900 6050
Wire Wire Line
	850  4600 1800 4600
Wire Wire Line
	1800 4600 1800 4200
Wire Wire Line
	1800 4200 1900 4200
Wire Wire Line
	850  4500 1750 4500
Wire Wire Line
	1750 4500 1750 4100
Wire Wire Line
	1750 4100 1900 4100
Wire Wire Line
	850  4400 1700 4400
Wire Wire Line
	1700 4400 1700 4000
Wire Wire Line
	1700 4000 1900 4000
Wire Wire Line
	850  4300 1650 4300
Wire Wire Line
	1650 4300 1650 3900
Wire Wire Line
	1650 3900 1900 3900
Wire Wire Line
	1600 4200 850  4200
Wire Wire Line
	1600 3800 1600 4200
Wire Wire Line
	1600 3800 1900 3800
Wire Wire Line
	850  4100 1550 4100
Wire Wire Line
	1550 4100 1550 3700
Wire Wire Line
	1550 3700 1900 3700
Wire Wire Line
	850  4000 1500 4000
Wire Wire Line
	1500 4000 1500 3600
Wire Wire Line
	1500 3600 1900 3600
Wire Wire Line
	850  3900 1450 3900
Wire Wire Line
	1450 3900 1450 3500
Wire Wire Line
	1450 3500 1900 3500
Wire Wire Line
	3300 3500 3400 3500
Wire Wire Line
	3300 3600 3400 3600
Wire Wire Line
	3300 3700 3400 3700
Wire Wire Line
	3300 3800 3400 3800
Wire Wire Line
	3300 3900 3400 3900
Wire Wire Line
	3300 4000 3400 4000
Wire Wire Line
	3300 4100 3400 4100
Wire Wire Line
	3300 4200 3400 4200
Wire Wire Line
	3300 5050 3400 5050
Wire Wire Line
	3300 5150 3400 5150
Wire Wire Line
	3300 5250 3400 5250
Wire Wire Line
	3300 5350 3400 5350
Wire Wire Line
	3300 5450 3400 5450
Wire Wire Line
	3300 5550 3400 5550
Wire Wire Line
	3300 5650 3400 5650
Wire Wire Line
	3300 5750 3400 5750
Wire Wire Line
	850  750  1200 750 
Wire Wire Line
	850  850  1200 850 
Wire Wire Line
	850  950  1200 950 
Wire Wire Line
	850  1050 1700 1050
Wire Wire Line
	850  2050 1200 2050
Wire Wire Line
	850  2150 1200 2150
Wire Wire Line
	1200 2150 1200 2050
Wire Wire Line
	1300 2050 1300 2100
Connection ~ 1200 2050
Wire Wire Line
	850  1850 1200 1850
Wire Wire Line
	1200 1850 1200 1950
Wire Wire Line
	850  1950 1200 1950
Connection ~ 1200 1950
Wire Wire Line
	850  2350 1450 2350
Wire Wire Line
	1900 3150 1900 3250
Connection ~ 1900 3250
Wire Wire Line
	850  3050 1850 3050
Wire Wire Line
	1850 3050 1850 2950
Wire Wire Line
	1850 2950 1900 2950
Wire Wire Line
	850  2950 1800 2950
Wire Wire Line
	1800 2950 1800 2850
Wire Wire Line
	1800 2850 1900 2850
Wire Wire Line
	850  2850 1750 2850
Wire Wire Line
	1750 2850 1750 2750
Wire Wire Line
	1750 2750 1900 2750
Wire Wire Line
	850  2750 1700 2750
Wire Wire Line
	1700 2750 1700 2650
Wire Wire Line
	1700 2650 1900 2650
Wire Wire Line
	850  2650 1650 2650
Wire Wire Line
	1650 2650 1650 2550
Wire Wire Line
	1650 2550 1900 2550
Wire Wire Line
	850  2550 1600 2550
Wire Wire Line
	1600 2550 1600 2450
Wire Wire Line
	1600 2450 1900 2450
Wire Wire Line
	850  2450 1550 2450
Wire Wire Line
	1550 2450 1550 2350
Wire Wire Line
	1550 2350 1900 2350
Wire Wire Line
	3300 2950 3400 2950
Wire Wire Line
	3300 2750 3400 2750
Wire Wire Line
	3300 2650 3400 2650
Wire Wire Line
	3300 2550 3400 2550
Wire Wire Line
	3300 2450 3400 2450
Wire Wire Line
	3300 2350 3400 2350
Wire Wire Line
	850  1750 1200 1750
Wire Wire Line
	850  1550 1200 1550
Wire Wire Line
	850  1450 1200 1450
Wire Wire Line
	850  1350 1200 1350
Wire Wire Line
	850  1650 1200 1650
Connection ~ 1300 1950
Wire Wire Line
	1400 2250 850  2250
Wire Wire Line
	4500 5250 4500 5100
Wire Wire Line
	15650 1050 15650 1300
Connection ~ 15650 5300
Connection ~ 15650 5500
Connection ~ 15650 4900
Connection ~ 15650 5100
Connection ~ 15650 4500
Connection ~ 15650 4700
Connection ~ 15650 4300
Connection ~ 15650 4100
Connection ~ 15650 3900
Connection ~ 15650 3700
Connection ~ 15650 3500
Connection ~ 15650 3300
Connection ~ 15650 3100
Connection ~ 15650 2900
Connection ~ 15650 2700
Connection ~ 15650 2500
Connection ~ 15650 2300
Connection ~ 15650 2100
Connection ~ 15650 1900
Connection ~ 15650 1700
Connection ~ 15650 1500
Connection ~ 15650 1300
Wire Wire Line
	15650 1050 15900 1050
Wire Wire Line
	15900 1050 15900 1150
Wire Wire Line
	15250 1050 15250 1300
Connection ~ 15250 5500
Connection ~ 15250 5300
Connection ~ 15250 5100
Connection ~ 15250 4900
Connection ~ 15250 4700
Connection ~ 15250 4500
Connection ~ 15250 4300
Connection ~ 15250 4100
Connection ~ 15250 3900
Connection ~ 15250 3700
Connection ~ 15250 3500
Connection ~ 15250 3300
Connection ~ 15250 3100
Connection ~ 15250 2900
Connection ~ 15250 2700
Connection ~ 15250 2500
Connection ~ 15250 2300
Connection ~ 15250 2100
Connection ~ 15250 1900
Connection ~ 15250 1700
Connection ~ 15250 1500
Connection ~ 15250 1300
Wire Wire Line
	15250 1050 15000 1050
Wire Wire Line
	15000 1050 15000 950 
Wire Wire Line
	1700 1050 1700 2250
Wire Wire Line
	1700 2250 1900 2250
Wire Wire Line
	3300 2250 3400 2250
Wire Wire Line
	3300 2850 3400 2850
Connection ~ 15250 5700
Connection ~ 15250 5900
Connection ~ 15250 6100
Connection ~ 15250 6300
Connection ~ 15250 6500
Connection ~ 15250 6700
Connection ~ 15650 5700
Connection ~ 15650 5900
Connection ~ 15650 6100
Connection ~ 15650 6300
Connection ~ 15650 6500
Connection ~ 15650 6700
$Comp
L MultiF-Board-rescue:CP1-RESCUE-MultiF-Board C42
U 1 1 5412FB9C
P 15450 7150
F 0 "C42" H 15500 7250 50  0000 L CNN
F 1 "10 uF" H 15500 7050 50  0000 L CNN
F 2 "" H 15450 7150 60  0000 C CNN
F 3 "~" H 15450 7150 60  0000 C CNN
	1    15450 7150
	0    -1   1    0   
$EndComp
Connection ~ 15250 6900
Connection ~ 15650 6900
Wire Wire Line
	1900 4500 1900 4650
Wire Wire Line
	1900 6050 1900 6300
Wire Wire Line
	1200 2050 1300 2050
Wire Wire Line
	1200 1950 1300 1950
Wire Wire Line
	1900 3250 1900 3350
Wire Wire Line
	1300 1950 1450 1950
Wire Wire Line
	15650 5300 15650 5500
Wire Wire Line
	15650 5500 15650 5700
Wire Wire Line
	15650 4900 15650 5100
Wire Wire Line
	15650 5100 15650 5300
Wire Wire Line
	15650 4500 15650 4700
Wire Wire Line
	15650 4700 15650 4900
Wire Wire Line
	15650 4300 15650 4500
Wire Wire Line
	15650 4100 15650 4300
Wire Wire Line
	15650 3900 15650 4100
Wire Wire Line
	15650 3700 15650 3900
Wire Wire Line
	15650 3500 15650 3700
Wire Wire Line
	15650 3300 15650 3500
Wire Wire Line
	15650 3100 15650 3300
Wire Wire Line
	15650 2900 15650 3100
Wire Wire Line
	15650 2700 15650 2900
Wire Wire Line
	15650 2500 15650 2700
Wire Wire Line
	15650 2300 15650 2500
Wire Wire Line
	15650 2100 15650 2300
Wire Wire Line
	15650 1900 15650 2100
Wire Wire Line
	15650 1700 15650 1900
Wire Wire Line
	15650 1500 15650 1700
Wire Wire Line
	15650 1300 15650 1500
Wire Wire Line
	15250 5500 15250 5700
Wire Wire Line
	15250 5300 15250 5500
Wire Wire Line
	15250 5100 15250 5300
Wire Wire Line
	15250 4900 15250 5100
Wire Wire Line
	15250 4700 15250 4900
Wire Wire Line
	15250 4500 15250 4700
Wire Wire Line
	15250 4300 15250 4500
Wire Wire Line
	15250 4100 15250 4300
Wire Wire Line
	15250 3900 15250 4100
Wire Wire Line
	15250 3700 15250 3900
Wire Wire Line
	15250 3500 15250 3700
Wire Wire Line
	15250 3300 15250 3500
Wire Wire Line
	15250 3100 15250 3300
Wire Wire Line
	15250 2900 15250 3100
Wire Wire Line
	15250 2700 15250 2900
Wire Wire Line
	15250 2500 15250 2700
Wire Wire Line
	15250 2300 15250 2500
Wire Wire Line
	15250 2100 15250 2300
Wire Wire Line
	15250 1900 15250 2100
Wire Wire Line
	15250 1700 15250 1900
Wire Wire Line
	15250 1500 15250 1700
Wire Wire Line
	15250 1300 15250 1500
Wire Wire Line
	15250 5700 15250 5900
Wire Wire Line
	15250 5900 15250 6100
Wire Wire Line
	15250 6100 15250 6300
Wire Wire Line
	15250 6300 15250 6500
Wire Wire Line
	15250 6500 15250 6700
Wire Wire Line
	15250 6700 15250 6900
Wire Wire Line
	15650 5700 15650 5900
Wire Wire Line
	15650 5900 15650 6100
Wire Wire Line
	15650 6100 15650 6300
Wire Wire Line
	15650 6300 15650 6500
Wire Wire Line
	15650 6500 15650 6700
Wire Wire Line
	15650 6700 15650 6900
Wire Wire Line
	15250 6900 15250 7150
Wire Wire Line
	15650 6900 15650 7150
Wire Wire Line
	4600 4600 4600 4850
Connection ~ 4600 4600
Connection ~ 4600 4400
Wire Wire Line
	4600 4400 4600 4600
Wire Wire Line
	4600 3700 4600 4400
Connection ~ 5000 1650
Wire Wire Line
	5000 1550 5000 1650
Wire Wire Line
	4500 1650 5000 1650
Wire Wire Line
	4500 1300 4500 1650
$Comp
L MultiF-Board-rescue:74LS32 U7
U 3 1 541FCFBB
P 3900 1300
F 0 "U7" H 3900 1350 60  0000 C CNN
F 1 "74LS32" H 3900 1250 60  0000 C CNN
F 2 "" H 3900 1300 60  0000 C CNN
F 3 "~" H 3900 1300 60  0000 C CNN
	3    3900 1300
	1    0    0    -1  
$EndComp
Text Label 3300 1200 2    60   ~ 0
A4
Text Label 3300 1400 2    60   ~ 0
/IORQ
Wire Wire Line
	5950 5850 5950 6000
Wire Wire Line
	5950 5750 5950 5850
Wire Wire Line
	5950 5600 5950 5750
Text Label 4900 4800 2    60   ~ 0
RST
Wire Wire Line
	6250 2800 6250 2900
Wire Wire Line
	4900 3900 4900 4000
Wire Wire Line
	4900 3700 4600 3700
Wire Wire Line
	4900 4400 4600 4400
Wire Wire Line
	4600 4600 4900 4600
Wire Wire Line
	5500 5900 5500 6050
Wire Wire Line
	5000 1450 4900 1450
Wire Wire Line
	6400 5250 6400 5500
Wire Wire Line
	5950 5250 6400 5250
Connection ~ 5950 5850
Connection ~ 5950 5750
Connection ~ 5950 5600
Wire Wire Line
	5950 5500 5950 5600
Wire Wire Line
	6150 5350 5950 5350
Wire Wire Line
	6150 5100 6150 5350
Wire Wire Line
	4500 5100 6150 5100
NoConn ~ 6250 3800
NoConn ~ 6250 3100
Text Label 6900 1000 1    60   ~ 0
VCC
Text Label 6200 1650 0    60   ~ 0
/IDECTC
$Comp
L MultiF-Board-rescue:74LS138 U19
U 1 1 535EC2EF
P 5600 1300
F 0 "U19" H 5600 1350 60  0000 C CNN
F 1 "74LS138" H 5600 1250 60  0000 C CNN
F 2 "" H 5600 1300 60  0001 C CNN
F 3 "" H 5600 1300 60  0001 C CNN
	1    5600 1300
	1    0    0    -1  
$EndComp
NoConn ~ 6250 4800
NoConn ~ 6250 4600
NoConn ~ 6250 4500
NoConn ~ 6250 3700
NoConn ~ 6250 3600
NoConn ~ 6250 3400
NoConn ~ 6250 3300
NoConn ~ 6250 2600
Text Label 6250 2500 0    60   ~ 0
SER_CLK
Text Label 4900 4500 2    60   ~ 0
/WR
Text Label 4900 4300 2    60   ~ 0
/RD
Text Label 4900 4100 2    60   ~ 0
/ESR1
$Comp
L MultiF-Board-rescue:GND-RESCUE-MultiF-Board #PWR017
U 1 1 5367D8E9
P 4600 4850
F 0 "#PWR017" H 4600 4850 30  0001 C CNN
F 1 "GND" H 4600 4780 30  0001 C CNN
F 2 "" H 4600 4850 60  0000 C CNN
F 3 "" H 4600 4850 60  0000 C CNN
	1    4600 4850
	1    0    0    -1  
$EndComp
Text Label 4900 3900 2    60   ~ 0
VCC
Text Label 4900 3600 2    60   ~ 0
A2
Text Label 4900 3500 2    60   ~ 0
A1
Text Label 4900 3400 2    60   ~ 0
A0
Text Label 4900 3200 2    60   ~ 0
C_D7
Text Label 4900 3100 2    60   ~ 0
C_D6
Text Label 4900 3000 2    60   ~ 0
C_D5
Text Label 4900 2900 2    60   ~ 0
C_D4
Text Label 4900 2800 2    60   ~ 0
C_D3
Text Label 4900 2700 2    60   ~ 0
C_D2
Text Label 4900 2600 2    60   ~ 0
C_D1
Text Label 4900 2500 2    60   ~ 0
C_D0
$Comp
L MultiF-Board-rescue:TI16550 U17
U 1 1 5367CCE5
P 5700 3650
F 0 "U17" H 5800 4900 60  0000 C CNN
F 1 "TI16550" H 5800 2400 60  0000 C CNN
F 2 "" H 5800 4850 60  0001 C CNN
F 3 "" H 5800 4850 60  0000 C CNN
	1    5700 3650
	1    0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:GND-RESCUE-MultiF-Board #PWR016
U 1 1 535F7A43
P 5500 6050
F 0 "#PWR016" H 5500 6050 30  0001 C CNN
F 1 "GND" H 5500 5980 30  0001 C CNN
F 2 "" H 5500 6050 60  0000 C CNN
F 3 "" H 5500 6050 60  0000 C CNN
	1    5500 6050
	1    0    0    -1  
$EndComp
NoConn ~ 6200 1450
NoConn ~ 6200 1350
NoConn ~ 6200 1250
NoConn ~ 6200 1150
NoConn ~ 6200 1050
NoConn ~ 6200 950 
Text Notes 6600 1650 0    60   ~ 0
E0H\n
Text Notes 6600 1550 0    60   ~ 0
C0H
Text Label 6200 1550 0    60   ~ 0
/E_SER
Text Label 4900 1450 2    60   ~ 0
/M1
Text Label 5000 1150 2    60   ~ 0
A7
Text Label 5000 1050 2    60   ~ 0
A6
Text Label 5000 950  2    60   ~ 0
A5
Text Notes 7400 5500 0    60   ~ 0
18.432 MHz
Text Label 7600 5700 0    60   ~ 0
GND
Text Label 7600 5300 0    60   ~ 0
VCC
$Comp
L MultiF-Board-rescue:OSC QG1
U 1 1 535EAB24
P 7000 5500
F 0 "QG1" H 6800 5850 60  0000 C CNN
F 1 "OSC" H 6800 5150 60  0000 C CNN
F 2 "Oscillators:KXO-200_LargePads" H 7000 5500 60  0001 C CNN
F 3 "" H 7000 5500 60  0000 C CNN
	1    7000 5500
	-1   0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:GND-RESCUE-MultiF-Board #PWR013
U 1 1 535EA982
P 5950 6000
F 0 "#PWR013" H 5950 6000 30  0001 C CNN
F 1 "GND" H 5950 5930 30  0001 C CNN
F 2 "" H 5950 6000 60  0000 C CNN
F 3 "" H 5950 6000 60  0000 C CNN
	1    5950 6000
	1    0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:74LS90 U14
U 1 1 535EA335
P 5250 5550
F 0 "U14" H 5350 5550 60  0000 C CNN
F 1 "74LS90" H 5450 5350 60  0000 C CNN
F 2 "" H 5250 5550 60  0000 C CNN
F 3 "~" H 5250 5550 60  0000 C CNN
	1    5250 5550
	-1   0    0    -1  
$EndComp
Wire Wire Line
	850  1150 1200 1150
Wire Wire Line
	1200 1150 1200 1250
Wire Wire Line
	1200 1250 850  1250
NoConn ~ 1200 1350
Text Notes 1200 1400 0    50   ~ 0
/INT
NoConn ~ 6250 4700
NoConn ~ 6250 3900
NoConn ~ 6250 3200
$EndSCHEMATC