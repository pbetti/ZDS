EESchema Schematic File Version 4
LIBS:MultiF-Board-cache
EELAYER 26 0
EELAYER END
$Descr A3 16535 11693
encoding utf-8
Sheet 1 1
Title "MultiF-Board"
Date "2018-09-26"
Rev "2.1"
Comp ""
Comment1 "pbetti@lpconsul.net"
Comment2 "by Piergiorgio Betti - 2014-2018"
Comment3 "Extended RAM/ROM, IDE and Serial Interface"
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
$Comp
L MultiF-Board-rescue:MMU_GAL U10
U 1 1 535A9722
P 5100 5350
F 0 "U10" H 4950 5800 60  0000 C CNN
F 1 "MMU_GAL" H 4900 4650 60  0000 C CNN
F 2 "" H 4950 5800 60  0000 C CNN
F 3 "~" H 4950 5800 60  0000 C CNN
	1    5100 5350
	1    0    0    -1  
$EndComp
Text Label 4300 5050 2    60   ~ 0
/M1
Text Label 4300 5150 2    60   ~ 0
A2
Text Label 4300 5250 2    60   ~ 0
A1
Text Label 4300 5350 2    60   ~ 0
A0
Text Label 4300 5450 2    60   ~ 0
/RD
Text Label 4300 5550 2    60   ~ 0
/RST
Text Label 4300 5650 2    60   ~ 0
/WR
Text Label 4300 5750 2    60   ~ 0
/IORQ
Text Label 4300 5850 2    60   ~ 0
A7
Text Label 4300 5950 2    60   ~ 0
GND
Text Label 5450 5250 0    60   ~ 0
A5
Text Label 5450 5350 0    60   ~ 0
A4
Text Label 5450 5650 0    60   ~ 0
A3
Text Label 5450 5950 0    60   ~ 0
A6
Text Label 5450 5050 0    60   ~ 0
+5V
$Comp
L MultiF-Board-rescue:7489 U12
U 1 1 535A9EB9
P 6600 6150
F 0 "U12" H 6650 5650 60  0000 C CNN
F 1 "7489" H 6450 6750 60  0000 C CNN
F 2 "" H 6300 6400 60  0001 C CNN
F 3 "" H 6300 6400 60  0000 C CNN
	1    6600 6150
	1    0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:7489 U11
U 1 1 535A9EC8
P 6600 4950
F 0 "U11" H 6650 4450 60  0000 C CNN
F 1 "7489" H 6450 5550 60  0000 C CNN
F 2 "" H 6300 5200 60  0001 C CNN
F 3 "" H 6300 5200 60  0000 C CNN
	1    6600 4950
	1    0    0    -1  
$EndComp
Text Label 6000 5300 2    60   ~ 0
GND
Text Label 6000 5150 2    60   ~ 0
VCC
Text Label 5450 5150 0    60   ~ 0
/MENA
Text Label 6000 6350 2    60   ~ 0
VCC
Text Label 6000 6500 2    60   ~ 0
GND
Text Label 6000 4500 2    60   ~ 0
A12
Text Label 6000 4600 2    60   ~ 0
A13
Text Label 6000 4700 2    60   ~ 0
A14
Text Label 6000 4800 2    60   ~ 0
A15
Text Label 6000 5700 2    60   ~ 0
A12
Text Label 6000 5800 2    60   ~ 0
A13
Text Label 6000 5900 2    60   ~ 0
A14
Text Label 6000 6000 2    60   ~ 0
A15
Text Label 7150 5000 0    60   ~ 0
D0
Text Label 7150 5100 0    60   ~ 0
D1
Text Label 7150 5200 0    60   ~ 0
D2
Text Label 7150 5300 0    60   ~ 0
D3
Text Label 7150 6200 0    60   ~ 0
D4
Text Label 7150 6300 0    60   ~ 0
D5
Text Label 7150 6400 0    60   ~ 0
D6
Text Label 7150 6500 0    60   ~ 0
D7
$Comp
L MultiF-Board-rescue:74LS240 U16
U 1 1 535AA4B4
P 8450 5500
F 0 "U16" H 8500 5300 60  0000 C CNN
F 1 "74LS240" H 8550 5100 60  0000 C CNN
F 2 "" H 8450 5500 60  0000 C CNN
F 3 "~" H 8450 5500 60  0000 C CNN
	1    8450 5500
	1    0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:GND-RESCUE-MultiF-Board #PWR08
U 1 1 535AAAA8
P 7750 6200
F 0 "#PWR08" H 7750 6200 30  0001 C CNN
F 1 "GND" H 7750 6130 30  0001 C CNN
F 2 "" H 7750 6200 60  0000 C CNN
F 3 "" H 7750 6200 60  0000 C CNN
	1    7750 6200
	1    0    0    -1  
$EndComp
Text Label 9700 5700 0    60   ~ 0
MA19
Text Label 9700 5600 0    60   ~ 0
MA18
Text Label 9700 5500 0    60   ~ 0
MA17
Text Label 9700 5400 0    60   ~ 0
MA16
Text Label 9700 5300 0    60   ~ 0
MA15
Text Label 9700 5200 0    60   ~ 0
MA14
Text Label 9700 5100 0    60   ~ 0
MA13
Text Label 9700 5000 0    60   ~ 0
MA12
$Comp
L MultiF-Board-rescue:74LS244 U15
U 1 1 535AB231
P 8300 4100
F 0 "U15" H 8350 3900 60  0000 C CNN
F 1 "74LS244" H 8400 3700 60  0000 C CNN
F 2 "" H 8300 4100 60  0000 C CNN
F 3 "~" H 8300 4100 60  0000 C CNN
	1    8300 4100
	-1   0    0    -1  
$EndComp
Text Label 5450 5550 0    60   ~ 0
/MRD
Text Label 8900 4800 2    60   ~ 0
/MRD
Text Label 7600 4300 2    60   ~ 0
D0
Text Label 7600 4200 2    60   ~ 0
D1
Text Label 7600 4100 2    60   ~ 0
D2
Text Label 7600 4000 2    60   ~ 0
D3
Text Label 7600 3900 2    60   ~ 0
D4
Text Label 7600 3800 2    60   ~ 0
D5
Text Label 7600 3700 2    60   ~ 0
D6
Text Label 7600 3600 2    60   ~ 0
D7
$Comp
L MultiF-Board-rescue:29EE020 U25
U 1 1 535BB815
P 12450 1950
F 0 "U25" H 12450 2050 60  0000 C CNN
F 1 "29EE020" H 12500 1150 60  0000 C CNN
F 2 "" H 12450 1950 60  0000 C CNN
F 3 "~" H 12450 1950 60  0000 C CNN
	1    12450 1950
	1    0    0    -1  
$EndComp
Text Label 10550 4300 2    60   ~ 0
/WR
Text Label 10550 4400 2    60   ~ 0
/MREQ
Text Label 10550 4500 2    60   ~ 0
/RD
Text Label 10550 4600 2    60   ~ 0
/RFH
Text Label 10550 4700 2    60   ~ 0
/MENA
Text Label 11900 4400 0    60   ~ 0
/MOE
Text Label 11900 4600 0    60   ~ 0
/MBUSEN
Text Label 11900 4800 0    60   ~ 0
/MWE
Text Label 11750 2950 2    60   ~ 0
/MWE
Text Label 11750 2850 2    60   ~ 0
/MOE
Text Label 11750 2550 2    60   ~ 0
MA17
Text Label 11750 2450 2    60   ~ 0
MA16
Text Label 11750 2350 2    60   ~ 0
MA15
Text Label 11750 2250 2    60   ~ 0
MA14
Text Label 11750 2150 2    60   ~ 0
MA13
Text Label 11750 2050 2    60   ~ 0
MA12
Text Label 11750 1950 2    60   ~ 0
A11
Text Label 11750 1850 2    60   ~ 0
A10
Text Label 11750 1750 2    60   ~ 0
A9
Text Label 11750 1650 2    60   ~ 0
A8
Text Label 11750 1550 2    60   ~ 0
A7
Text Label 11750 1450 2    60   ~ 0
A6
Text Label 11750 1350 2    60   ~ 0
A5
Text Label 11750 1250 2    60   ~ 0
A4
Text Label 11750 1150 2    60   ~ 0
A3
Text Label 11750 1050 2    60   ~ 0
A2
Text Label 11750 950  2    60   ~ 0
A1
Text Label 11750 850  2    60   ~ 0
A0
Text Label 13150 850  0    60   ~ 0
MD0
Text Label 13150 950  0    60   ~ 0
MD1
Text Label 13150 1050 0    60   ~ 0
MD2
Text Label 13150 1150 0    60   ~ 0
MD3
Text Label 13150 1250 0    60   ~ 0
MD4
Text Label 13150 1350 0    60   ~ 0
MD5
Text Label 13150 1450 0    60   ~ 0
MD6
Text Label 13150 1550 0    60   ~ 0
MD7
Text Label 11300 850  0    60   ~ 0
MD0
Text Label 11300 950  0    60   ~ 0
MD1
Text Label 11300 1050 0    60   ~ 0
MD2
Text Label 11300 1150 0    60   ~ 0
MD3
Text Label 11300 1250 0    60   ~ 0
MD4
Text Label 11300 1350 0    60   ~ 0
MD5
Text Label 11300 1450 0    60   ~ 0
MD6
Text Label 11300 1550 0    60   ~ 0
MD7
Text Label 9900 2950 2    60   ~ 0
/MWE
Text Label 9900 2850 2    60   ~ 0
/MOE
Text Label 9900 2450 2    60   ~ 0
MA16
Text Label 9900 2350 2    60   ~ 0
MA15
Text Label 9900 2250 2    60   ~ 0
MA14
Text Label 9900 2150 2    60   ~ 0
MA13
Text Label 9900 2050 2    60   ~ 0
MA12
Text Label 9900 1950 2    60   ~ 0
A11
Text Label 9900 1850 2    60   ~ 0
A10
Text Label 9900 1750 2    60   ~ 0
A9
Text Label 9900 1650 2    60   ~ 0
A8
Text Label 9900 1550 2    60   ~ 0
A7
Text Label 9900 1450 2    60   ~ 0
A6
Text Label 9900 1350 2    60   ~ 0
A5
Text Label 9900 1250 2    60   ~ 0
A4
Text Label 9900 1150 2    60   ~ 0
A3
Text Label 9900 1050 2    60   ~ 0
A2
Text Label 9900 950  2    60   ~ 0
A1
Text Label 9900 850  2    60   ~ 0
A0
Text Label 8050 850  2    60   ~ 0
A0
Text Label 8050 950  2    60   ~ 0
A1
Text Label 8050 1050 2    60   ~ 0
A2
Text Label 8050 1150 2    60   ~ 0
A3
Text Label 8050 1250 2    60   ~ 0
A4
Text Label 8050 1350 2    60   ~ 0
A5
Text Label 8050 1450 2    60   ~ 0
A6
Text Label 8050 1550 2    60   ~ 0
A7
Text Label 8050 1650 2    60   ~ 0
A8
Text Label 8050 1750 2    60   ~ 0
A9
Text Label 8050 1850 2    60   ~ 0
A10
Text Label 8050 1950 2    60   ~ 0
A11
Text Label 8050 2050 2    60   ~ 0
MA12
Text Label 8050 2150 2    60   ~ 0
MA13
Text Label 8050 2250 2    60   ~ 0
MA14
Text Label 8050 2350 2    60   ~ 0
MA15
Text Label 8050 2450 2    60   ~ 0
MA16
Text Label 8050 2550 2    60   ~ 0
MA17
Text Label 8050 2650 2    60   ~ 0
MA18
Text Label 8050 2850 2    60   ~ 0
/MOE
Text Label 8050 2950 2    60   ~ 0
/MWE
$Comp
L MultiF-Board-rescue:SRAM_512K U18
U 1 1 535BB7EB
P 8750 1950
F 0 "U18" H 8750 2050 60  0000 C CNN
F 1 "SRAM_512K" H 8800 1150 60  0000 C CNN
F 2 "" H 8750 1950 60  0001 C CNN
F 3 "" H 8750 1950 60  0000 C CNN
	1    8750 1950
	1    0    0    -1  
$EndComp
Text Label 9450 850  0    60   ~ 0
MD0
Text Label 9450 950  0    60   ~ 0
MD1
Text Label 9450 1050 0    60   ~ 0
MD2
Text Label 9450 1150 0    60   ~ 0
MD3
Text Label 9450 1250 0    60   ~ 0
MD4
Text Label 9450 1350 0    60   ~ 0
MD5
Text Label 9450 1450 0    60   ~ 0
MD6
Text Label 9450 1550 0    60   ~ 0
MD7
Text Label 4400 3500 2    60   ~ 0
D0
Text Label 4400 3600 2    60   ~ 0
D1
Text Label 4400 3700 2    60   ~ 0
D2
Text Label 4400 3800 2    60   ~ 0
D3
Text Label 4400 3900 2    60   ~ 0
D4
Text Label 4400 4000 2    60   ~ 0
D5
$Comp
L MultiF-Board-rescue:74LS245 U9
U 1 1 535E59A0
P 5100 4000
F 0 "U9" H 5200 4575 60  0000 L BNN
F 1 "74LS245" H 5150 3425 60  0000 L TNN
F 2 "" H 5100 4000 60  0000 C CNN
F 3 "~" H 5100 4000 60  0000 C CNN
	1    5100 4000
	1    0    0    -1  
$EndComp
Text Label 4400 4100 2    60   ~ 0
D6
Text Label 4400 4200 2    60   ~ 0
D7
Text Label 4400 4500 2    60   ~ 0
/MBUSEN
Text Label 4400 4400 2    60   ~ 0
/RD
Text Label 5800 3500 0    60   ~ 0
MD0
Text Label 5800 3600 0    60   ~ 0
MD1
Text Label 5800 3700 0    60   ~ 0
MD2
Text Label 5800 3800 0    60   ~ 0
MD3
Text Label 5800 3900 0    60   ~ 0
MD4
Text Label 5800 4000 0    60   ~ 0
MD5
Text Label 5800 4100 0    60   ~ 0
MD6
Text Label 5800 4200 0    60   ~ 0
MD7
$Comp
L MultiF-Board-rescue:MEM_GAL U23
U 1 1 535E53B7
P 11350 4600
F 0 "U23" H 11200 5050 60  0000 C CNN
F 1 "MEM_GAL" H 11150 3900 60  0000 C CNN
F 2 "" H 11200 5050 60  0000 C CNN
F 3 "~" H 11200 5050 60  0000 C CNN
	1    11350 4600
	1    0    0    -1  
$EndComp
Text Label 4650 10650 2    60   ~ 0
~PC7
Text Label 4650 10250 2    60   ~ 0
~PC6
Text Label 3350 10650 0    60   ~ 0
PC7
Text Label 3350 10250 0    60   ~ 0
PC6
Text Label 3350 9850 0    60   ~ 0
PC5
Text Label 3350 9450 0    60   ~ 0
PC4
Text Label 3350 9050 0    60   ~ 0
PC3
Text Label 4650 9850 2    60   ~ 0
~PC5
Text Label 4650 9450 2    60   ~ 0
~PC4
Text Label 4650 9050 2    60   ~ 0
~PC3
Text Label 3000 10250 2    60   ~ 0
PC7
Text Label 3000 10150 2    60   ~ 0
PC6
Text Label 3000 10050 2    60   ~ 0
PC5
Text Label 3000 9950 2    60   ~ 0
PC4
Text Label 3000 9850 2    60   ~ 0
PC3
Text Label 3000 9750 2    60   ~ 0
PC2
Text Label 3000 9650 2    60   ~ 0
PC1
Text Label 3000 9550 2    60   ~ 0
PC0
Text Label 3000 9350 2    60   ~ 0
PB7
Text Label 3000 9250 2    60   ~ 0
PB6
Text Label 3000 9150 2    60   ~ 0
PB5
Text Label 3000 9050 2    60   ~ 0
PB4
Text Label 3000 8950 2    60   ~ 0
PB3
Text Label 3000 8850 2    60   ~ 0
PB2
Text Label 3000 8750 2    60   ~ 0
PB1
Text Label 3000 8650 2    60   ~ 0
PB0
Text Label 3000 8450 2    60   ~ 0
PA7
Text Label 3000 8350 2    60   ~ 0
PA6
Text Label 3000 8250 2    60   ~ 0
PA5
Text Label 3000 8150 2    60   ~ 0
PA4
Text Label 3000 8050 2    60   ~ 0
PA3
Text Label 3000 7950 2    60   ~ 0
PA2
Text Label 3000 7850 2    60   ~ 0
PA1
Text Label 3000 7750 2    60   ~ 0
PA0
$Comp
L MultiF-Board-rescue:8255 U2
U 1 1 535E6E03
P 1900 9000
F 0 "U2" H 1900 9050 60  0000 C CNN
F 1 "8255" H 1900 8950 60  0000 C CNN
F 2 "" H 1900 9000 60  0001 C CNN
F 3 "" H 1900 9000 60  0001 C CNN
	1    1900 9000
	1    0    0    -1  
$EndComp
Text Label 4800 8150 2    60   ~ 0
PA7
$Comp
L MultiF-Board-rescue:R-RESCUE-MultiF-Board R3
U 1 1 535E6E0A
P 4150 8150
F 0 "R3" V 4230 8150 50  0000 C CNN
F 1 "10k" V 4150 8150 50  0000 C CNN
F 2 "Discret:R3-5" H 4150 8150 60  0001 C CNN
F 3 "" H 4150 8150 60  0001 C CNN
	1    4150 8150
	0    -1   -1   0   
$EndComp
$Comp
L MultiF-Board-rescue:74LS14 U1
U 4 1 535E6E10
P 4000 9850
F 0 "U1" H 3950 9700 60  0000 C CNN
F 1 "74LS14" H 4000 10000 60  0000 C CNN
F 2 "" H 4000 9850 60  0001 C CNN
F 3 "" H 4000 9850 60  0001 C CNN
	4    4000 9850
	1    0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:VCC #PWR09
U 1 1 535E6E16
P 3800 7850
F 0 "#PWR09" H 3800 7950 30  0001 C CNN
F 1 "VCC" H 3800 7950 30  0000 C CNN
F 2 "" H 3800 7850 60  0001 C CNN
F 3 "" H 3800 7850 60  0001 C CNN
	1    3800 7850
	1    0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:74LS14 U1
U 6 1 535E6E1C
P 4000 10650
F 0 "U1" H 3950 10500 60  0000 C CNN
F 1 "74LS14" H 4000 10800 60  0000 C CNN
F 2 "" H 4000 10650 60  0001 C CNN
F 3 "" H 4000 10650 60  0001 C CNN
	6    4000 10650
	1    0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:74LS14 U1
U 2 1 535E6E22
P 4000 9050
F 0 "U1" H 3950 8900 60  0000 C CNN
F 1 "74LS14" H 4000 9200 60  0000 C CNN
F 2 "" H 4000 9050 60  0001 C CNN
F 3 "" H 4000 9050 60  0001 C CNN
	2    4000 9050
	1    0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:R-RESCUE-MultiF-Board R7
U 1 1 535E6E28
P 5400 8550
F 0 "R7" V 5480 8550 50  0000 C CNN
F 1 "470" V 5400 8550 50  0000 C CNN
F 2 "Discret:R3-5" H 5400 8550 60  0001 C CNN
F 3 "" H 5400 8550 60  0001 C CNN
	1    5400 8550
	0    1    1    0   
$EndComp
$Comp
L MultiF-Board-rescue:CONN_2 P4
U 1 1 535E6E2E
P 6700 8450
F 0 "P4" V 6650 8450 40  0000 C CNN
F 1 "IDE_LED" V 6750 8450 40  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x02" H 6700 8450 60  0001 C CNN
F 3 "" H 6700 8450 60  0001 C CNN
	1    6700 8450
	1    0    0    1   
$EndComp
$Comp
L MultiF-Board-rescue:R-RESCUE-MultiF-Board R4
U 1 1 535E6E34
P 4150 8350
F 0 "R4" V 4230 8350 50  0000 C CNN
F 1 "10k" V 4150 8350 50  0000 C CNN
F 2 "Discret:R3-5" H 4150 8350 60  0001 C CNN
F 3 "" H 4150 8350 60  0001 C CNN
	1    4150 8350
	0    -1   -1   0   
$EndComp
$Comp
L MultiF-Board-rescue:VCC #PWR010
U 1 1 535E6E3A
P 5050 7750
F 0 "#PWR010" H 5050 7850 30  0001 C CNN
F 1 "VCC" H 5050 7850 30  0000 C CNN
F 2 "" H 5050 7750 60  0001 C CNN
F 3 "" H 5050 7750 60  0001 C CNN
	1    5050 7750
	1    0    0    -1  
$EndComp
NoConn ~ 6750 10350
NoConn ~ 6750 10450
NoConn ~ 5150 10350
NoConn ~ 5150 10150
$Comp
L MultiF-Board-rescue:74LS14 U1
U 3 1 535E6E51
P 4000 9450
F 0 "U1" H 3950 9300 60  0000 C CNN
F 1 "74LS14" H 4000 9600 60  0000 C CNN
F 2 "" H 4000 9450 60  0001 C CNN
F 3 "" H 4000 9450 60  0001 C CNN
	3    4000 9450
	1    0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:74LS14 U1
U 5 1 535E6E57
P 4000 10250
F 0 "U1" H 3950 10100 60  0000 C CNN
F 1 "74LS14" H 4000 10400 60  0000 C CNN
F 2 "" H 4000 10250 60  0001 C CNN
F 3 "" H 4000 10250 60  0001 C CNN
	5    4000 10250
	1    0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:LED-RESCUE-MultiF-Board D1
U 1 1 535E6E5E
P 5950 8150
F 0 "D1" H 5950 8250 50  0000 C CNN
F 1 "IDE_LED" H 5950 8050 50  0000 C CNN
F 2 "LEDs:LED-3MM" H 5950 8150 60  0001 C CNN
F 3 "" H 5950 8150 60  0001 C CNN
	1    5950 8150
	1    0    0    -1  
$EndComp
Text Label 6750 8150 2    60   ~ 0
~ACTIVE
$Comp
L MultiF-Board-rescue:R-RESCUE-MultiF-Board R6
U 1 1 535E6E65
P 5400 8150
F 0 "R6" V 5480 8150 50  0000 C CNN
F 1 "470" V 5400 8150 50  0000 C CNN
F 2 "Discret:R3-5" H 5400 8150 60  0001 C CNN
F 3 "" H 5400 8150 60  0001 C CNN
	1    5400 8150
	0    1    1    0   
$EndComp
Text Label 6750 10750 2    60   ~ 0
GND
Text Label 6750 10650 2    60   ~ 0
~PC4
Text Label 6750 10550 2    60   ~ 0
PC2
Text Label 6750 10450 2    60   ~ 0
~PDIAG
Text Label 6750 10350 2    60   ~ 0
~IOCS16
Text Label 6750 10250 2    60   ~ 0
GND
Text Label 6750 10150 2    60   ~ 0
CSEL
Text Label 6750 10050 2    60   ~ 0
GND
Text Label 6750 9950 2    60   ~ 0
GND
Text Label 6750 9850 2    60   ~ 0
GND
Text Label 6750 9750 2    60   ~ 0
IDE_VCC
Text Label 6750 9650 2    60   ~ 0
PB7
Text Label 6750 9550 2    60   ~ 0
PB6
Text Label 6750 9450 2    60   ~ 0
PB5
Text Label 6750 9350 2    60   ~ 0
PB4
Text Label 6750 9250 2    60   ~ 0
PB3
Text Label 6750 9150 2    60   ~ 0
PB2
Text Label 6750 9050 2    60   ~ 0
PB1
Text Label 6750 8950 2    60   ~ 0
PB0
Text Label 6750 8850 2    60   ~ 0
GND
Text Label 5150 10750 0    60   ~ 0
~ACTIVE
Text Label 5150 10650 0    60   ~ 0
~PC3
Text Label 5150 10550 0    60   ~ 0
PC0
Text Label 5150 10450 0    60   ~ 0
PC1
Text Label 5150 10350 0    60   ~ 0
INTRQ
Text Label 5150 10250 0    60   ~ 0
~DMACK
Text Label 5150 10150 0    60   ~ 0
IORDY
Text Label 5150 10050 0    60   ~ 0
~PC6
Text Label 5150 9950 0    60   ~ 0
~PC5
Text Label 5150 9850 0    60   ~ 0
DMARQ
Text Label 5150 9750 0    60   ~ 0
GND
Text Label 5150 9650 0    60   ~ 0
PA0
Text Label 5150 9550 0    60   ~ 0
PA1
Text Label 5150 9450 0    60   ~ 0
PA2
Text Label 5150 9350 0    60   ~ 0
PA3
Text Label 5150 9250 0    60   ~ 0
PA4
Text Label 5150 9150 0    60   ~ 0
PA5
Text Label 5150 9050 0    60   ~ 0
PA6
Text Label 5150 8950 0    60   ~ 0
PA7
Text Label 5150 8850 0    60   ~ 0
~PC7
$Comp
L MultiF-Board-rescue:GND-RESCUE-MultiF-Board #PWR011
U 1 1 535E6E93
P 3800 8650
F 0 "#PWR011" H 3800 8650 30  0001 C CNN
F 1 "GND" H 3800 8580 30  0001 C CNN
F 2 "" H 3800 8650 60  0001 C CNN
F 3 "" H 3800 8650 60  0001 C CNN
	1    3800 8650
	1    0    0    -1  
$EndComp
Text Label 4800 7950 2    60   ~ 0
~DMACK
$Comp
L MultiF-Board-rescue:R-RESCUE-MultiF-Board R2
U 1 1 535E6E9A
P 4150 7950
F 0 "R2" V 4230 7950 50  0000 C CNN
F 1 "10k" V 4150 7950 50  0000 C CNN
F 2 "Discret:R3-5" H 4150 7950 60  0001 C CNN
F 3 "" H 4150 7950 60  0001 C CNN
	1    4150 7950
	0    -1   -1   0   
$EndComp
Text Label 4800 8550 2    60   ~ 0
DMARQ
$Comp
L MultiF-Board-rescue:R-RESCUE-MultiF-Board R5
U 1 1 535E6EA1
P 4150 8550
F 0 "R5" V 4230 8550 50  0000 C CNN
F 1 "10k" V 4150 8550 50  0000 C CNN
F 2 "Discret:R3-5" H 4150 8550 60  0001 C CNN
F 3 "" H 4150 8550 60  0001 C CNN
	1    4150 8550
	0    -1   -1   0   
$EndComp
Text Label 4800 8350 2    60   ~ 0
CSEL
$Comp
L MultiF-Board-rescue:CONN_20X2 P3
U 1 1 535E6EA8
P 5950 9800
F 0 "P3" H 5950 10900 60  0000 C CNN
F 1 "IDE" V 5950 9800 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_2x20" H 5950 9800 60  0001 C CNN
F 3 "" H 5950 9800 60  0001 C CNN
	1    5950 9800
	1    0    0    -1  
$EndComp
Text Label 3850 850  0    60   ~ 0
TX1
Text Label 4850 650  0    60   ~ 0
CTS1
Text Label 3850 750  0    60   ~ 0
RX1
$Comp
L MultiF-Board-rescue:GND-RESCUE-MultiF-Board #PWR012
U 1 1 535E78EF
P 4000 1150
F 0 "#PWR012" H 4000 1150 30  0001 C CNN
F 1 "GND" H 4000 1080 30  0001 C CNN
F 2 "" H 4000 1150 60  0001 C CNN
F 3 "" H 4000 1150 60  0001 C CNN
	1    4000 1150
	1    0    0    -1  
$EndComp
NoConn ~ 4800 1050
NoConn ~ 4800 950 
NoConn ~ 4000 650 
$Comp
L MultiF-Board-rescue:CONN_5X2 P1
U 1 1 535E78FC
P 4400 850
F 0 "P1" H 4400 1150 60  0000 C CNN
F 1 "SERIAL1" V 4400 850 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_2x05" V 4500 850 50  0001 C CNN
F 3 "" H 4400 850 60  0001 C CNN
	1    4400 850 
	1    0    0    -1  
$EndComp
Text Label 3850 950  0    60   ~ 0
RTS1
Text Label 1200 1350 0    60   ~ 0
/INT
$Comp
L MultiF-Board-rescue:74LS90 U14
U 1 1 535EA335
P 8050 10650
F 0 "U14" H 8150 10650 60  0000 C CNN
F 1 "74LS90" H 8250 10450 60  0000 C CNN
F 2 "" H 8050 10650 60  0000 C CNN
F 3 "~" H 8050 10650 60  0000 C CNN
	1    8050 10650
	-1   0    0    -1  
$EndComp
NoConn ~ 7300 10450
NoConn ~ 7300 10550
$Comp
L MultiF-Board-rescue:GND-RESCUE-MultiF-Board #PWR013
U 1 1 535EA982
P 8750 11100
F 0 "#PWR013" H 8750 11100 30  0001 C CNN
F 1 "GND" H 8750 11030 30  0001 C CNN
F 2 "" H 8750 11100 60  0000 C CNN
F 3 "" H 8750 11100 60  0000 C CNN
	1    8750 11100
	1    0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:OSC QG1
U 1 1 535EAB24
P 9800 10600
F 0 "QG1" H 9600 10950 60  0000 C CNN
F 1 "OSC" H 9600 10250 60  0000 C CNN
F 2 "Oscillators:KXO-200_LargePads" H 9800 10600 60  0001 C CNN
F 3 "" H 9800 10600 60  0000 C CNN
	1    9800 10600
	-1   0    0    -1  
$EndComp
Text Label 10400 10400 0    60   ~ 0
VCC
Text Label 10400 10800 0    60   ~ 0
GND
Text Notes 10200 10600 0    60   ~ 0
18.432 MHz
NoConn ~ 4800 850 
NoConn ~ 4800 750 
Text Label 1000 7750 2    60   ~ 0
C_D0
Text Label 1000 7850 2    60   ~ 0
C_D1
Text Label 1000 7950 2    60   ~ 0
C_D2
Text Label 1000 8050 2    60   ~ 0
C_D3
Text Label 1000 8150 2    60   ~ 0
C_D4
Text Label 1000 8250 2    60   ~ 0
C_D5
Text Label 1000 8350 2    60   ~ 0
C_D6
Text Label 1000 8450 2    60   ~ 0
C_D7
Text Label 1000 8650 2    60   ~ 0
/RD
Text Label 1000 8750 2    60   ~ 0
/WR
Text Label 1000 8850 2    60   ~ 0
A0
Text Label 1000 8950 2    60   ~ 0
A1
Text Label 1000 9150 2    60   ~ 0
/E_IDE
$Comp
L MultiF-Board-rescue:74LS14 U1
U 1 1 535EB95A
P 1650 10700
F 0 "U1" H 1800 10800 40  0000 C CNN
F 1 "74LS14" H 1850 10600 40  0000 C CNN
F 2 "" H 1650 10700 60  0000 C CNN
F 3 "~" H 1650 10700 60  0000 C CNN
	1    1650 10700
	-1   0    0    -1  
$EndComp
Text Label 2100 10700 0    60   ~ 0
/RST
Text Label 9500 6250 2    60   ~ 0
A5
Text Label 9500 6350 2    60   ~ 0
A6
Text Label 9500 6450 2    60   ~ 0
A7
Text Label 9400 6750 2    60   ~ 0
/M1
Text Label 10700 6850 0    60   ~ 0
/E_SER
Text Notes 11100 6850 0    60   ~ 0
C0H
Text Notes 11100 6950 0    60   ~ 0
E0H\n
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
Text Label 11900 4300 0    60   ~ 0
VCC
Text Label 10550 5200 2    60   ~ 0
GND
NoConn ~ 10700 6250
NoConn ~ 10700 6350
NoConn ~ 10700 6450
NoConn ~ 10700 6550
NoConn ~ 10700 6650
NoConn ~ 10700 6750
$Comp
L MultiF-Board-rescue:GND-RESCUE-MultiF-Board #PWR016
U 1 1 535F7A43
P 8300 11150
F 0 "#PWR016" H 8300 11150 30  0001 C CNN
F 1 "GND" H 8300 11080 30  0001 C CNN
F 2 "" H 8300 11150 60  0000 C CNN
F 3 "" H 8300 11150 60  0000 C CNN
	1    8300 11150
	1    0    0    -1  
$EndComp
Text Label 7300 10650 2    60   ~ 0
SER_CLK
$Comp
L MultiF-Board-rescue:TI16550 U17
U 1 1 5367CCE5
P 8500 8750
F 0 "U17" H 8600 10000 60  0000 C CNN
F 1 "TI16550" H 8600 7500 60  0000 C CNN
F 2 "" H 8600 9950 60  0001 C CNN
F 3 "" H 8600 9950 60  0000 C CNN
	1    8500 8750
	1    0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:MAX-232 U20
U 1 1 5367CDBC
P 10350 9200
F 0 "U20" H 10200 9250 70  0000 C CNN
F 1 "MAX-232" H 10200 9100 70  0000 C CNN
F 2 "" H 10250 9200 60  0001 C CNN
F 3 "" H 10250 9200 60  0000 C CNN
	1    10350 9200
	1    0    0    -1  
$EndComp
Text Label 7700 7600 2    60   ~ 0
C_D0
Text Label 7700 7700 2    60   ~ 0
C_D1
Text Label 7700 7800 2    60   ~ 0
C_D2
Text Label 7700 7900 2    60   ~ 0
C_D3
Text Label 7700 8000 2    60   ~ 0
C_D4
Text Label 7700 8100 2    60   ~ 0
C_D5
Text Label 7700 8200 2    60   ~ 0
C_D6
Text Label 7700 8300 2    60   ~ 0
C_D7
Text Label 7700 8500 2    60   ~ 0
A0
Text Label 7700 8600 2    60   ~ 0
A1
Text Label 7700 8700 2    60   ~ 0
A2
Text Label 7700 9000 2    60   ~ 0
VCC
$Comp
L MultiF-Board-rescue:GND-RESCUE-MultiF-Board #PWR017
U 1 1 5367D8E9
P 7400 9950
F 0 "#PWR017" H 7400 9950 30  0001 C CNN
F 1 "GND" H 7400 9880 30  0001 C CNN
F 2 "" H 7400 9950 60  0000 C CNN
F 3 "" H 7400 9950 60  0000 C CNN
	1    7400 9950
	1    0    0    -1  
$EndComp
Text Label 7700 9200 2    60   ~ 0
/ESR1
Text Label 7700 9400 2    60   ~ 0
/RD
Text Label 7700 9600 2    60   ~ 0
/WR
Text Label 9050 7600 0    60   ~ 0
SER_CLK
NoConn ~ 9050 7700
NoConn ~ 9050 8400
NoConn ~ 9050 8500
NoConn ~ 9050 8700
NoConn ~ 9050 8800
NoConn ~ 9050 9600
NoConn ~ 9050 9700
NoConn ~ 9050 9900
Text Label 9050 9800 0    60   ~ 0
IRQ1
$Comp
L MultiF-Board-rescue:CP-RESCUE-MultiF-Board C1
U 1 1 5367DC2E
P 9550 8700
F 0 "C1" H 9600 8800 40  0000 L CNN
F 1 "1.0 uF" H 9600 8600 40  0000 L CNN
F 2 "Cap2.5" H 9650 8550 30  0000 C CNN
F 3 "~" H 9550 8700 300 0000 C CNN
	1    9550 8700
	1    0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:CP-RESCUE-MultiF-Board C2
U 1 1 5367DC3D
P 9550 9200
F 0 "C2" H 9600 9300 40  0000 L CNN
F 1 "1.0 uF" H 9600 9100 40  0000 L CNN
F 2 "Cap2.5" H 9650 9050 30  0000 C CNN
F 3 "~" H 9550 9200 300 0000 C CNN
	1    9550 9200
	1    0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:CP-RESCUE-MultiF-Board C3
U 1 1 5367DC5D
P 10850 8700
F 0 "C3" H 10900 8800 40  0000 L CNN
F 1 "1.0 uF" H 10900 8600 40  0000 L CNN
F 2 "Cap2.5" H 10950 8550 30  0000 C CNN
F 3 "~" H 10850 8700 300 0000 C CNN
	1    10850 8700
	1    0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:CP-RESCUE-MultiF-Board C4
U 1 1 5367DC6C
P 11150 8700
F 0 "C4" H 11200 8800 40  0000 L CNN
F 1 "1.0 uF" H 11200 8600 40  0000 L CNN
F 2 "Cap2.5" H 11250 8550 30  0000 C CNN
F 3 "~" H 11150 8700 300 0000 C CNN
	1    11150 8700
	1    0    0    -1  
$EndComp
Text Label 10850 9600 0    60   ~ 0
RTS1
Text Label 10850 9700 0    60   ~ 0
TX1
Text Label 10850 9800 0    60   ~ 0
CTS1
Text Label 10850 9900 0    60   ~ 0
RX1
$Comp
L MultiF-Board-rescue:CP-RESCUE-MultiF-Board C5
U 1 1 5367DC7C
P 11150 9200
F 0 "C5" H 11200 9300 40  0000 L CNN
F 1 "1.0 uF" H 11200 9100 40  0000 L CNN
F 2 "Cap2.5" H 11250 9050 30  0000 C CNN
F 3 "~" H 11150 9200 300 0000 C CNN
	1    11150 9200
	1    0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:GND-RESCUE-MultiF-Board #PWR018
U 1 1 5367E165
P 10850 9250
F 0 "#PWR018" H 10850 9250 30  0001 C CNN
F 1 "GND" H 10850 9180 30  0001 C CNN
F 2 "" H 10850 9250 60  0000 C CNN
F 3 "" H 10850 9250 60  0000 C CNN
	1    10850 9250
	1    0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:VCC #PWR019
U 1 1 5367E4B7
P 10850 8350
F 0 "#PWR019" H 10850 8450 30  0001 C CNN
F 1 "VCC" H 10850 8450 30  0000 C CNN
F 2 "" H 10850 8350 60  0000 C CNN
F 3 "" H 10850 8350 60  0000 C CNN
	1    10850 8350
	1    0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:TI16550 U26
U 1 1 5367F778
P 12700 8700
F 0 "U26" H 12800 9950 60  0000 C CNN
F 1 "TI16550" H 12800 7450 60  0000 C CNN
F 2 "" H 12800 9900 60  0001 C CNN
F 3 "" H 12800 9900 60  0000 C CNN
	1    12700 8700
	1    0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:MAX-232 U29
U 1 1 5367F77E
P 14550 9150
F 0 "U29" H 14400 9200 70  0000 C CNN
F 1 "MAX-232" H 14400 9050 70  0000 C CNN
F 2 "" H 14450 9150 60  0001 C CNN
F 3 "" H 14450 9150 60  0000 C CNN
	1    14550 9150
	1    0    0    -1  
$EndComp
Text Label 11900 7550 2    60   ~ 0
C_D0
Text Label 11900 7650 2    60   ~ 0
C_D1
Text Label 11900 7750 2    60   ~ 0
C_D2
Text Label 11900 7850 2    60   ~ 0
C_D3
Text Label 11900 7950 2    60   ~ 0
C_D4
Text Label 11900 8050 2    60   ~ 0
C_D5
Text Label 11900 8150 2    60   ~ 0
C_D6
Text Label 11900 8250 2    60   ~ 0
C_D7
Text Label 11900 8450 2    60   ~ 0
A0
Text Label 11900 8550 2    60   ~ 0
A1
Text Label 11900 8650 2    60   ~ 0
A2
Text Label 11900 8950 2    60   ~ 0
VCC
$Comp
L MultiF-Board-rescue:GND-RESCUE-MultiF-Board #PWR020
U 1 1 5367F796
P 11600 9900
F 0 "#PWR020" H 11600 9900 30  0001 C CNN
F 1 "GND" H 11600 9830 30  0001 C CNN
F 2 "" H 11600 9900 60  0000 C CNN
F 3 "" H 11600 9900 60  0000 C CNN
	1    11600 9900
	1    0    0    -1  
$EndComp
Text Label 11900 9150 2    60   ~ 0
/ESR2
Text Label 11900 9350 2    60   ~ 0
/RD
Text Label 11900 9550 2    60   ~ 0
/WR
Text Label 13250 7550 0    60   ~ 0
SER_CLK
NoConn ~ 13250 7650
NoConn ~ 13250 8350
NoConn ~ 13250 8450
NoConn ~ 13250 8650
NoConn ~ 13250 8750
NoConn ~ 13250 9550
NoConn ~ 13250 9650
NoConn ~ 13250 9850
Text Label 13250 9750 0    60   ~ 0
IRQ2
$Comp
L MultiF-Board-rescue:CP-RESCUE-MultiF-Board C6
U 1 1 5367F7AE
P 13750 8650
F 0 "C6" H 13800 8750 40  0000 L CNN
F 1 "1.0 uF" H 13800 8550 40  0000 L CNN
F 2 "Cap2.5" H 13850 8500 30  0000 C CNN
F 3 "~" H 13750 8650 300 0000 C CNN
	1    13750 8650
	1    0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:CP-RESCUE-MultiF-Board C7
U 1 1 5367F7B4
P 13750 9150
F 0 "C7" H 13800 9250 40  0000 L CNN
F 1 "1.0 uF" H 13800 9050 40  0000 L CNN
F 2 "Cap2.5" H 13850 9000 30  0000 C CNN
F 3 "~" H 13750 9150 300 0000 C CNN
	1    13750 9150
	1    0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:CP-RESCUE-MultiF-Board C8
U 1 1 5367F7BA
P 15050 8650
F 0 "C8" H 15100 8750 40  0000 L CNN
F 1 "1.0 uF" H 15100 8550 40  0000 L CNN
F 2 "Cap2.5" H 15150 8500 30  0000 C CNN
F 3 "~" H 15050 8650 300 0000 C CNN
	1    15050 8650
	1    0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:CP-RESCUE-MultiF-Board C9
U 1 1 5367F7C0
P 15350 8650
F 0 "C9" H 15400 8750 40  0000 L CNN
F 1 "1.0 uF" H 15400 8550 40  0000 L CNN
F 2 "Cap2.5" H 15450 8500 30  0000 C CNN
F 3 "~" H 15350 8650 300 0000 C CNN
	1    15350 8650
	1    0    0    -1  
$EndComp
Text Label 15050 9550 0    60   ~ 0
RTS2
Text Label 15050 9650 0    60   ~ 0
TX2
Text Label 15050 9750 0    60   ~ 0
CTS2
Text Label 15050 9850 0    60   ~ 0
RX2
$Comp
L MultiF-Board-rescue:CP-RESCUE-MultiF-Board C10
U 1 1 5367F7CA
P 15350 9150
F 0 "C10" H 15400 9250 40  0000 L CNN
F 1 "1.0 uF" H 15400 9050 40  0000 L CNN
F 2 "Cap2.5" H 15450 9000 30  0000 C CNN
F 3 "~" H 15350 9150 300 0000 C CNN
	1    15350 9150
	1    0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:GND-RESCUE-MultiF-Board #PWR021
U 1 1 5367F7D5
P 15050 9200
F 0 "#PWR021" H 15050 9200 30  0001 C CNN
F 1 "GND" H 15050 9130 30  0001 C CNN
F 2 "" H 15050 9200 60  0000 C CNN
F 3 "" H 15050 9200 60  0000 C CNN
	1    15050 9200
	1    0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:VCC #PWR022
U 1 1 5367F7DD
P 15050 8300
F 0 "#PWR022" H 15050 8400 30  0001 C CNN
F 1 "VCC" H 15050 8400 30  0000 C CNN
F 2 "" H 15050 8300 60  0000 C CNN
F 3 "" H 15050 8300 60  0000 C CNN
	1    15050 8300
	1    0    0    -1  
$EndComp
Text Label 5300 850  0    60   ~ 0
TX2
Text Label 6300 650  0    60   ~ 0
CTS2
Text Label 5300 750  0    60   ~ 0
RX2
$Comp
L MultiF-Board-rescue:GND-RESCUE-MultiF-Board #PWR023
U 1 1 5367FB79
P 5450 1150
F 0 "#PWR023" H 5450 1150 30  0001 C CNN
F 1 "GND" H 5450 1080 30  0001 C CNN
F 2 "" H 5450 1150 60  0001 C CNN
F 3 "" H 5450 1150 60  0001 C CNN
	1    5450 1150
	1    0    0    -1  
$EndComp
NoConn ~ 6250 1050
NoConn ~ 6250 950 
NoConn ~ 5450 650 
$Comp
L MultiF-Board-rescue:CONN_5X2 P2
U 1 1 5367FB82
P 5850 850
F 0 "P2" H 5850 1150 60  0000 C CNN
F 1 "SERIAL2" V 5850 850 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_2x05" V 5950 850 50  0001 C CNN
F 3 "" H 5850 850 60  0001 C CNN
	1    5850 850 
	1    0    0    -1  
$EndComp
Text Label 5300 950  0    60   ~ 0
RTS2
NoConn ~ 6250 850 
NoConn ~ 6250 750 
$Comp
L MultiF-Board-rescue:74LS138 U19
U 1 1 535EC2EF
P 10100 6600
F 0 "U19" H 10100 6650 60  0000 C CNN
F 1 "74LS138" H 10100 6550 60  0000 C CNN
F 2 "" H 10100 6600 60  0001 C CNN
F 3 "" H 10100 6600 60  0001 C CNN
	1    10100 6600
	1    0    0    -1  
$EndComp
Text Label 7800 7050 2    60   ~ 0
/E_SER
$Comp
L MultiF-Board-rescue:74LS32 U7
U 4 1 536802A5
P 8400 7150
F 0 "U7" H 8400 7200 60  0000 C CNN
F 1 "74LS32" H 8400 7100 60  0000 C CNN
F 2 "" H 8400 7150 60  0000 C CNN
F 3 "~" H 8400 7150 60  0000 C CNN
	4    8400 7150
	1    0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:74LS14 U6
U 2 1 536802E2
P 7100 7250
F 0 "U6" H 7250 7350 40  0000 C CNN
F 1 "74LS14" H 7300 7150 40  0000 C CNN
F 2 "" H 7100 7250 60  0000 C CNN
F 3 "~" H 7100 7250 60  0000 C CNN
	2    7100 7250
	1    0    0    -1  
$EndComp
Text Label 6650 7250 2    60   ~ 0
A3
Text Label 9000 7150 0    60   ~ 0
/ESR2
$Comp
L MultiF-Board-rescue:Z80-CTC U28
U 1 1 5368081E
P 14000 6150
F 0 "U28" H 14000 7250 60  0000 C CNN
F 1 "Z80-CTC" H 14000 5050 60  0000 C CNN
F 2 "" H 14000 6150 60  0001 C CNN
F 3 "" H 14000 6150 60  0000 C CNN
	1    14000 6150
	1    0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:74LS245 U13
U 1 1 536812D1
P 6650 2700
F 0 "U13" H 6750 3275 60  0000 L BNN
F 1 "74LS245" H 6700 2125 60  0000 L TNN
F 2 "" H 6650 2700 60  0000 C CNN
F 3 "~" H 6650 2700 60  0000 C CNN
	1    6650 2700
	1    0    0    -1  
$EndComp
Text Label 5950 2200 2    60   ~ 0
D0
Text Label 5950 2300 2    60   ~ 0
D1
Text Label 5950 2400 2    60   ~ 0
D2
Text Label 5950 2500 2    60   ~ 0
D3
Text Label 5950 2600 2    60   ~ 0
D4
Text Label 5950 2700 2    60   ~ 0
D5
Text Label 5950 2800 2    60   ~ 0
D6
Text Label 5950 2900 2    60   ~ 0
D7
Text Label 7350 2200 0    60   ~ 0
C_D0
Text Label 7350 2300 0    60   ~ 0
C_D1
Text Label 7350 2400 0    60   ~ 0
C_D2
Text Label 7350 2500 0    60   ~ 0
C_D3
Text Label 7350 2600 0    60   ~ 0
C_D4
Text Label 7350 2700 0    60   ~ 0
C_D5
Text Label 7350 2800 0    60   ~ 0
C_D6
Text Label 7350 2900 0    60   ~ 0
C_D7
$Comp
L MultiF-Board-rescue:74LS244 U27
U 1 1 5368167A
P 14000 3150
F 0 "U27" H 14050 2950 60  0000 C CNN
F 1 "74LS244" H 14100 2750 60  0000 C CNN
F 2 "" H 14000 3150 60  0000 C CNN
F 3 "~" H 14000 3150 60  0000 C CNN
	1    14000 3150
	-1   0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:74LS11 U8
U 1 1 536882E4
P 4850 3050
F 0 "U8" H 4850 3100 60  0000 C CNN
F 1 "74LS11" H 4850 3000 60  0000 C CNN
F 2 "" H 4850 3050 60  0000 C CNN
F 3 "~" H 4850 3050 60  0000 C CNN
	1    4850 3050
	1    0    0    -1  
$EndComp
Text Label 4250 2900 2    60   ~ 0
/E_IDE
Text Label 4250 3050 2    60   ~ 0
/E_SER
Text Label 4250 3200 2    60   ~ 0
/E_CTC
$Comp
L MultiF-Board-rescue:PINHD-1X3 JP2
U 1 1 536884C8
P 3000 1850
F 0 "JP2" H 2750 2075 50  0000 L BNN
F 1 "PINHD-1X3" H 2750 1550 50  0000 L BNN
F 2 "Pin_Headers:Pin_Header_Straight_1x03" H 3000 2000 50  0001 C CNN
F 3 "" H 3000 1850 60  0000 C CNN
	1    3000 1850
	0    -1   1    0   
$EndComp
$Comp
L MultiF-Board-rescue:PINHD-1X3 JP1
U 1 1 536884E0
P 2200 1850
F 0 "JP1" H 1950 2075 50  0000 L BNN
F 1 "PINHD-1X3" H 1950 1550 50  0000 L BNN
F 2 "Pin_Headers:Pin_Header_Straight_1x03" H 2200 2000 50  0001 C CNN
F 3 "" H 2200 1850 60  0000 C CNN
	1    2200 1850
	0    -1   1    0   
$EndComp
$Comp
L MultiF-Board-rescue:R-RESCUE-MultiF-Board R1
U 1 1 53688E14
P 2300 900
F 0 "R1" V 2380 900 40  0000 C CNN
F 1 "3300" V 2307 901 40  0000 C CNN
F 2 "Discret:R3-5" V 2230 900 30  0000 C CNN
F 3 "~" H 2300 900 30  0000 C CNN
	1    2300 900 
	1    0    0    -1  
$EndComp
Text Label 2300 650  1    60   ~ 0
VCC
Text Label 2400 1500 0    60   ~ 0
C_IEI
Text Label 3150 1500 0    60   ~ 0
C_IEO
Text Label 14900 7000 0    60   ~ 0
/RST
Text Label 14900 6600 0    60   ~ 0
IRQ1
Text Label 14900 6200 0    60   ~ 0
IRQ2
NoConn ~ 14900 6300
Text Label 14900 5800 0    60   ~ 0
T1
Text Label 14900 5900 0    60   ~ 0
Z1
Text Label 14900 5300 0    60   ~ 0
T0
Text Label 14900 5400 0    60   ~ 0
Z0
Text GLabel 3400 2850 2    60   Input ~ 0
CLK
$Comp
L MultiF-Board-rescue:74LS06 U24
U 3 1 5368B36E
P 12200 7000
F 0 "U24" H 12395 7115 60  0000 C CNN
F 1 "74LS06" H 12390 6875 60  0000 C CNN
F 2 "" H 12200 7000 60  0000 C CNN
F 3 "~" H 12200 7000 60  0000 C CNN
	3    12200 7000
	-1   0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:74LS06 U24
U 2 1 5368B37D
P 12200 6600
F 0 "U24" H 12395 6715 60  0000 C CNN
F 1 "74LS06" H 12390 6475 60  0000 C CNN
F 2 "" H 12200 6600 60  0000 C CNN
F 3 "~" H 12200 6600 60  0000 C CNN
	2    12200 6600
	1    0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:R-RESCUE-MultiF-Board R9
U 1 1 5368B39B
P 11550 6750
F 0 "R9" V 11630 6750 40  0000 C CNN
F 1 "3300" V 11557 6751 40  0000 C CNN
F 2 "Discret:R3-5" V 11480 6750 30  0000 C CNN
F 3 "~" H 11550 6750 30  0000 C CNN
	1    11550 6750
	1    0    0    -1  
$EndComp
Text Label 12650 6600 1    60   ~ 0
/INT
Text Label 13100 7100 2    60   ~ 0
CLK
Text Label 13100 6900 2    60   ~ 0
C_IEO
Text Label 13100 6700 2    60   ~ 0
C_IEI
Text Label 13100 6600 2    60   ~ 0
/RD
Text Label 13100 6500 2    60   ~ 0
/IORQ
Text Label 13100 6400 2    60   ~ 0
/M1
Text Label 10700 6950 0    60   ~ 0
/IDECTC
Text Label 4750 7150 2    60   ~ 0
/IDECTC
$Comp
L MultiF-Board-rescue:74LS32 U7
U 2 1 5368BB4E
P 5350 7250
F 0 "U7" H 5350 7300 60  0000 C CNN
F 1 "74LS32" H 5350 7200 60  0000 C CNN
F 2 "" H 5350 7250 60  0000 C CNN
F 3 "~" H 5350 7250 60  0000 C CNN
	2    5350 7250
	1    0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:74LS14 U6
U 1 1 5368BB54
P 4050 7350
F 0 "U6" H 4200 7450 40  0000 C CNN
F 1 "74LS14" H 4250 7250 40  0000 C CNN
F 2 "" H 4050 7350 60  0000 C CNN
F 3 "~" H 4050 7350 60  0000 C CNN
	1    4050 7350
	1    0    0    -1  
$EndComp
Text Label 3600 7350 2    60   ~ 0
A3
Text Label 5950 7250 0    60   ~ 0
/E_CTC
$Comp
L MultiF-Board-rescue:74LS32 U7
U 1 1 5368BB65
P 4700 6650
F 0 "U7" H 4700 6700 60  0000 C CNN
F 1 "74LS32" H 4700 6600 60  0000 C CNN
F 2 "" H 4700 6650 60  0000 C CNN
F 3 "~" H 4700 6650 60  0000 C CNN
	1    4700 6650
	-1   0    0    -1  
$EndComp
Text Label 5300 6550 0    60   ~ 0
/IDECTC
Text Label 5300 6750 0    60   ~ 0
A3
Text Label 4100 6650 2    60   ~ 0
/E_IDE
Text Notes 10000 7900 2    60   ~ 0
C0H
Text Notes 9100 7300 0    60   ~ 0
C8H
Text Notes 4100 6800 0    60   ~ 0
E0H
Text Notes 5750 7400 0    60   ~ 0
E8H
Text Label 13100 6300 2    60   ~ 0
A1
Text Label 13100 6200 2    60   ~ 0
A0
Text Label 13100 6100 2    60   ~ 0
/E_CTC
Text Label 13100 5900 2    60   ~ 0
C_D7
Text Label 13100 5800 2    60   ~ 0
C_D6
Text Label 13100 5700 2    60   ~ 0
C_D5
Text Label 13100 5600 2    60   ~ 0
C_D4
Text Label 13100 5500 2    60   ~ 0
C_D3
Text Label 13100 5400 2    60   ~ 0
C_D2
Text Label 13100 5300 2    60   ~ 0
C_D1
Text Label 13100 5200 2    60   ~ 0
C_D0
$Comp
L MultiF-Board-rescue:74LS06 U24
U 1 1 5368BF73
P 12200 6250
F 0 "U24" H 12395 6365 60  0000 C CNN
F 1 "74LS06" H 12390 6125 60  0000 C CNN
F 2 "" H 12200 6250 60  0000 C CNN
F 3 "~" H 12200 6250 60  0000 C CNN
	1    12200 6250
	1    0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:R-RESCUE-MultiF-Board R8
U 1 1 5368C16A
P 11550 6050
F 0 "R8" V 11630 6050 40  0000 C CNN
F 1 "3300" V 11557 6051 40  0000 C CNN
F 2 "Discret:R3-5" V 11480 6050 30  0000 C CNN
F 3 "~" H 11550 6050 30  0000 C CNN
	1    11550 6050
	1    0    0    -1  
$EndComp
Text Label 11400 6300 1    60   ~ 0
VCC
Text Label 12650 5700 1    60   ~ 0
/ISR
Text Label 14700 2650 0    60   ~ 0
C_D0
Text Label 14700 2750 0    60   ~ 0
C_D1
Text Label 14700 2850 0    60   ~ 0
C_D2
Text Label 14700 2950 0    60   ~ 0
C_D3
Text Label 14700 3050 0    60   ~ 0
C_D4
Text Label 14700 3150 0    60   ~ 0
C_D5
Text Label 14700 3250 0    60   ~ 0
C_D6
Text Label 14700 3350 0    60   ~ 0
C_D7
Text Label 13300 2650 2    60   ~ 0
D0
Text Label 13300 2750 2    60   ~ 0
D1
Text Label 13300 2850 2    60   ~ 0
D2
Text Label 13300 2950 2    60   ~ 0
D3
Text Label 13300 3050 2    60   ~ 0
D4
Text Label 13300 3150 2    60   ~ 0
D5
Text Label 13300 3250 2    60   ~ 0
D6
Text Label 13300 3350 2    60   ~ 0
D7
$Comp
L MultiF-Board-rescue:74LS32 U22
U 3 1 5368C929
P 14050 4700
F 0 "U22" H 14050 4750 60  0000 C CNN
F 1 "74LS32" H 14050 4650 60  0000 C CNN
F 2 "" H 14050 4700 60  0000 C CNN
F 3 "~" H 14050 4700 60  0000 C CNN
	3    14050 4700
	1    0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:74LS32 U22
U 2 1 5368C938
P 14050 4100
F 0 "U22" H 14050 4150 60  0000 C CNN
F 1 "74LS32" H 14050 4050 60  0000 C CNN
F 2 "" H 14050 4100 60  0000 C CNN
F 3 "~" H 14050 4100 60  0000 C CNN
	2    14050 4100
	1    0    0    -1  
$EndComp
Text Label 13450 4800 2    60   ~ 0
/M1
Text Label 13450 4600 2    60   ~ 0
/IORQ
Text Label 13450 4000 2    60   ~ 0
/ISR
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
$Comp
L MultiF-Board-rescue:GND-RESCUE-MultiF-Board #PWR024
U 1 1 5368F133
P 10600 3400
F 0 "#PWR024" H 10600 3400 30  0001 C CNN
F 1 "GND" H 10600 3330 30  0001 C CNN
F 2 "" H 10600 3400 60  0000 C CNN
F 3 "" H 10600 3400 60  0000 C CNN
	1    10600 3400
	1    0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:74LS11 U8
U 2 1 538ACE27
P 2250 6900
F 0 "U8" H 2250 6950 60  0000 C CNN
F 1 "74LS11" H 2250 6850 60  0000 C CNN
F 2 "" H 2250 6900 60  0000 C CNN
F 3 "~" H 2250 6900 60  0000 C CNN
	2    2250 6900
	1    0    0    -1  
$EndComp
Text Label 5450 5450 0    60   ~ 0
/MWR
Text Label 6000 4950 2    60   ~ 0
/MME
Text Label 6000 6150 2    60   ~ 0
/MME
Text Label 3150 6900 2    60   ~ 0
/MME
Text Label 1350 7050 0    60   ~ 0
/MENA
Text Label 1350 6750 0    60   ~ 0
/MWR
$Comp
L MultiF-Board-rescue:R-RESCUE-MultiF-Board R10
U 1 1 53E1C167
P 7200 950
F 0 "R10" V 7280 950 40  0000 C CNN
F 1 "330" V 7207 951 40  0000 C CNN
F 2 "Discret:R3-5" V 7130 950 30  0000 C CNN
F 3 "~" H 7200 950 30  0000 C CNN
	1    7200 950 
	1    0    0    -1  
$EndComp
Text Label 7000 700  0    60   ~ 0
VCC
$Comp
L MultiF-Board-rescue:C-RESCUE-MultiF-Board C41
U 1 1 53E1C37D
P 6900 1400
F 0 "C41" H 6900 1500 40  0000 L CNN
F 1 "0.047" H 6906 1315 40  0000 L CNN
F 2 "" H 6938 1250 30  0000 C CNN
F 3 "~" H 6900 1400 60  0000 C CNN
	1    6900 1400
	1    0    0    -1  
$EndComp
$Comp
L MultiF-Board-rescue:GND-RESCUE-MultiF-Board #PWR025
U 1 1 53E1C7A7
P 6900 1750
F 0 "#PWR025" H 6900 1750 30  0001 C CNN
F 1 "GND" H 6900 1680 30  0001 C CNN
F 2 "" H 6900 1750 60  0000 C CNN
F 3 "" H 6900 1750 60  0000 C CNN
	1    6900 1750
	1    0    0    -1  
$EndComp
Text Label 7500 1200 2    60   ~ 0
MPUP
$Comp
L MultiF-Board-rescue:SRAM_256K U21
U 1 1 535BB804
P 10600 1950
F 0 "U21" H 10600 2050 60  0000 C CNN
F 1 "SRAM_512K" H 10650 1150 60  0000 C CNN
F 2 "" H 10600 1950 60  0000 C CNN
F 3 "~" H 10600 1950 60  0000 C CNN
	1    10600 1950
	1    0    0    -1  
$EndComp
Text Label 9900 2650 2    60   ~ 0
MPUP
NoConn ~ 13250 8150
NoConn ~ 13250 8850
NoConn ~ 9050 8200
NoConn ~ 9050 8900
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
	850  1150 2100 1150
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
	5700 5450 5450 5450
Wire Wire Line
	5700 5050 6000 5050
Wire Wire Line
	5700 5050 5700 5450
Wire Wire Line
	5700 6250 6000 6250
Connection ~ 5700 5450
Wire Wire Line
	7150 4500 7700 4500
Wire Wire Line
	7700 4500 7700 5000
Wire Wire Line
	7700 5000 7750 5000
Wire Wire Line
	7150 4600 7650 4600
Wire Wire Line
	7650 4600 7650 5100
Wire Wire Line
	7650 5100 7750 5100
Wire Wire Line
	7150 4700 7600 4700
Wire Wire Line
	7600 4700 7600 5200
Wire Wire Line
	7600 5200 7750 5200
Wire Wire Line
	7150 4800 7550 4800
Wire Wire Line
	7550 4800 7550 5300
Wire Wire Line
	7550 5300 7750 5300
Wire Wire Line
	7150 6000 7600 6000
Wire Wire Line
	7600 6000 7600 5700
Wire Wire Line
	7600 5700 7750 5700
Wire Wire Line
	7150 5900 7550 5900
Wire Wire Line
	7550 5900 7550 5600
Wire Wire Line
	7550 5600 7750 5600
Wire Wire Line
	7150 5800 7500 5800
Wire Wire Line
	7500 5800 7500 5500
Wire Wire Line
	7500 5500 7750 5500
Wire Wire Line
	7150 5700 7450 5700
Wire Wire Line
	7450 5700 7450 5400
Wire Wire Line
	7450 5400 7750 5400
Wire Wire Line
	7750 5900 7750 6000
Connection ~ 7750 6000
Wire Wire Line
	9700 5000 9200 5000
Wire Wire Line
	9700 5100 9250 5100
Wire Wire Line
	9700 5200 9300 5200
Wire Wire Line
	9700 5300 9350 5300
Wire Wire Line
	9700 5400 9400 5400
Wire Wire Line
	9700 5500 9450 5500
Wire Wire Line
	9150 5600 9500 5600
Wire Wire Line
	9150 5700 9550 5700
Wire Wire Line
	9000 4500 9000 4600
Wire Wire Line
	9000 4800 8900 4800
Connection ~ 9000 4600
Wire Wire Line
	9000 4300 9200 4300
Wire Wire Line
	9200 4300 9200 5000
Connection ~ 9200 5000
Wire Wire Line
	9000 4200 9250 4200
Wire Wire Line
	9250 4200 9250 5100
Connection ~ 9250 5100
Wire Wire Line
	9000 4100 9300 4100
Wire Wire Line
	9300 4100 9300 5200
Connection ~ 9300 5200
Wire Wire Line
	9000 4000 9350 4000
Wire Wire Line
	9350 4000 9350 5300
Connection ~ 9350 5300
Wire Wire Line
	9000 3900 9400 3900
Wire Wire Line
	9400 3900 9400 5400
Connection ~ 9400 5400
Wire Wire Line
	9000 3800 9450 3800
Wire Wire Line
	9450 3800 9450 5500
Connection ~ 9450 5500
Wire Wire Line
	9000 3700 9500 3700
Wire Wire Line
	9500 3700 9500 5600
Connection ~ 9500 5600
Wire Wire Line
	9000 3600 9550 3600
Wire Wire Line
	9550 3600 9550 5700
Connection ~ 9550 5700
Wire Wire Line
	10000 5600 10000 4800
Wire Wire Line
	10000 4800 10550 4800
Wire Wire Line
	10050 5700 10050 4900
Wire Wire Line
	10050 4900 10550 4900
Wire Wire Line
	12850 4900 11900 4900
Wire Wire Line
	12850 3200 12850 4900
Wire Wire Line
	12850 3200 11750 3200
Wire Wire Line
	11750 3200 11750 3050
Wire Wire Line
	8050 3050 8050 3300
Wire Wire Line
	11900 4700 12800 4700
Wire Wire Line
	12800 4700 12800 3250
Wire Wire Line
	12800 3250 9900 3250
Wire Wire Line
	11900 4500 12750 4500
Wire Wire Line
	12750 4500 12750 3300
Wire Wire Line
	12750 3300 8050 3300
Wire Wire Line
	3800 7850 3800 7950
Wire Wire Line
	3900 8150 3800 8150
Wire Wire Line
	5650 8550 6350 8550
Connection ~ 6250 8150
Wire Wire Line
	6250 8150 6250 8350
Wire Wire Line
	6250 8350 6350 8350
Wire Wire Line
	3800 8550 3900 8550
Wire Wire Line
	5650 8150 5750 8150
Wire Wire Line
	4400 8350 4800 8350
Wire Wire Line
	4400 8550 4800 8550
Wire Wire Line
	4400 7950 4800 7950
Wire Wire Line
	5150 8950 5550 8950
Wire Wire Line
	5150 9050 5550 9050
Wire Wire Line
	5150 9150 5550 9150
Wire Wire Line
	5150 9250 5550 9250
Wire Wire Line
	5150 9350 5550 9350
Wire Wire Line
	5150 9450 5550 9450
Wire Wire Line
	5150 9550 5550 9550
Wire Wire Line
	5150 9650 5550 9650
Wire Wire Line
	5150 9750 5550 9750
Wire Wire Line
	5150 9850 5550 9850
Wire Wire Line
	5150 9950 5550 9950
Wire Wire Line
	5150 10050 5550 10050
Wire Wire Line
	5150 10150 5550 10150
Wire Wire Line
	5150 10250 5550 10250
Wire Wire Line
	5150 10350 5550 10350
Wire Wire Line
	5150 10450 5550 10450
Wire Wire Line
	5150 10550 5550 10550
Wire Wire Line
	5150 10650 5550 10650
Wire Wire Line
	5150 10750 5550 10750
Wire Wire Line
	6350 8850 6750 8850
Wire Wire Line
	6350 8950 6750 8950
Wire Wire Line
	6350 9050 6750 9050
Wire Wire Line
	6350 9150 6750 9150
Wire Wire Line
	6350 9250 6750 9250
Wire Wire Line
	6350 9350 6750 9350
Wire Wire Line
	6350 9450 6750 9450
Wire Wire Line
	6350 9550 6750 9550
Wire Wire Line
	6350 9650 6750 9650
Wire Wire Line
	6350 9750 6750 9750
Wire Wire Line
	6350 9850 6750 9850
Wire Wire Line
	6350 9950 6750 9950
Wire Wire Line
	6350 10050 6750 10050
Wire Wire Line
	6350 10150 6750 10150
Wire Wire Line
	6350 10250 6750 10250
Wire Wire Line
	6350 10350 6750 10350
Wire Wire Line
	6350 10450 6750 10450
Wire Wire Line
	6350 10550 6750 10550
Wire Wire Line
	6350 10650 6750 10650
Wire Wire Line
	6350 10750 6750 10750
Wire Wire Line
	6150 8150 6250 8150
Wire Wire Line
	5150 8150 5050 8150
Wire Wire Line
	3800 7950 3900 7950
Connection ~ 3800 8550
Wire Wire Line
	3900 8350 3800 8350
Wire Wire Line
	5050 8550 5150 8550
Connection ~ 5050 8150
Wire Wire Line
	4400 8150 4800 8150
Wire Wire Line
	3800 8150 3800 8350
Connection ~ 3800 8350
Wire Wire Line
	4000 750  3800 750 
Wire Wire Line
	4000 850  3800 850 
Wire Wire Line
	4950 650  4800 650 
Wire Wire Line
	4000 1150 4000 1050
Wire Wire Line
	3800 950  4000 950 
Wire Wire Line
	7300 10350 7300 10200
Wire Wire Line
	7300 10200 8950 10200
Wire Wire Line
	8950 10200 8950 10450
Wire Wire Line
	8950 10450 8750 10450
Wire Wire Line
	8750 10600 8750 10700
Connection ~ 8750 10700
Connection ~ 8750 10850
Connection ~ 8750 10950
Wire Wire Line
	8750 10350 9200 10350
Wire Wire Line
	9200 10350 9200 10600
Wire Wire Line
	1000 9050 600  9050
Wire Wire Line
	600  9050 600  10700
Wire Wire Line
	600  10700 800  10700
Wire Wire Line
	9500 6750 9400 6750
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
	2800 10250 3000 10250
Wire Wire Line
	2800 10150 3000 10150
Wire Wire Line
	2800 10050 3000 10050
Wire Wire Line
	2800 9950 3000 9950
Wire Wire Line
	2800 9850 3000 9850
Wire Wire Line
	2800 9750 3000 9750
Wire Wire Line
	2800 9650 3000 9650
Wire Wire Line
	2800 9550 3000 9550
Wire Wire Line
	3350 10650 3550 10650
Wire Wire Line
	3350 10250 3550 10250
Wire Wire Line
	3350 9850 3550 9850
Wire Wire Line
	3350 9450 3550 9450
Wire Wire Line
	3350 9050 3550 9050
Wire Wire Line
	4450 9050 4650 9050
Wire Wire Line
	4450 9450 4650 9450
Wire Wire Line
	4450 9850 4650 9850
Wire Wire Line
	4450 10250 4650 10250
Wire Wire Line
	4450 10650 4650 10650
Wire Wire Line
	2800 9350 3000 9350
Wire Wire Line
	2800 9250 3000 9250
Wire Wire Line
	2800 9150 3000 9150
Wire Wire Line
	2800 9050 3000 9050
Wire Wire Line
	2800 8950 3000 8950
Wire Wire Line
	2800 8850 3000 8850
Wire Wire Line
	2800 8750 3000 8750
Wire Wire Line
	2800 8650 3000 8650
Wire Wire Line
	2800 7750 3000 7750
Wire Wire Line
	2800 7850 3000 7850
Wire Wire Line
	2800 7950 3000 7950
Wire Wire Line
	2800 8050 3000 8050
Wire Wire Line
	2800 8150 3000 8150
Wire Wire Line
	2800 8250 3000 8250
Wire Wire Line
	2800 8350 3000 8350
Wire Wire Line
	2800 8450 3000 8450
Wire Wire Line
	5150 8850 5550 8850
Wire Wire Line
	8300 11000 8300 11150
Wire Wire Line
	7400 9700 7700 9700
Wire Wire Line
	7700 9500 7400 9500
Wire Wire Line
	7700 8800 7400 8800
Wire Wire Line
	7400 8800 7400 9500
Connection ~ 7400 9500
Wire Wire Line
	7700 9000 7700 9100
Connection ~ 7400 9700
Wire Wire Line
	9050 7900 9050 8000
Wire Wire Line
	10850 9400 11150 9400
Wire Wire Line
	10850 9100 11050 9100
Wire Wire Line
	11050 9100 11050 9000
Wire Wire Line
	11050 9000 11150 9000
Wire Wire Line
	11150 9000 11150 8900
Wire Wire Line
	10850 9100 10850 9250
Wire Wire Line
	10850 8500 11150 8500
Wire Wire Line
	10850 8350 10850 8500
Wire Wire Line
	9450 9600 9550 9600
Wire Wire Line
	9400 9800 9550 9800
Wire Wire Line
	9050 9200 9350 9200
Wire Wire Line
	9350 9200 9350 9700
Wire Wire Line
	9350 9700 9550 9700
Wire Wire Line
	9050 9400 9300 9400
Wire Wire Line
	9300 9400 9300 9900
Wire Wire Line
	9300 9900 9550 9900
Wire Wire Line
	11600 9650 11900 9650
Wire Wire Line
	11900 9450 11600 9450
Wire Wire Line
	11900 8750 11600 8750
Wire Wire Line
	11600 8750 11600 9450
Connection ~ 11600 9450
Wire Wire Line
	11900 8950 11900 9050
Connection ~ 11600 9650
Wire Wire Line
	13250 7850 13250 7950
Wire Wire Line
	15050 9350 15350 9350
Wire Wire Line
	15050 9050 15250 9050
Wire Wire Line
	15250 9050 15250 8950
Wire Wire Line
	15250 8950 15350 8950
Wire Wire Line
	15350 8950 15350 8850
Wire Wire Line
	15050 9050 15050 9200
Wire Wire Line
	15050 8450 15350 8450
Wire Wire Line
	15050 8300 15050 8450
Wire Wire Line
	13650 9550 13750 9550
Wire Wire Line
	13600 9750 13750 9750
Wire Wire Line
	13250 9150 13550 9150
Wire Wire Line
	13550 9150 13550 9650
Wire Wire Line
	13550 9650 13750 9650
Wire Wire Line
	13250 9350 13500 9350
Wire Wire Line
	13500 9350 13500 9850
Wire Wire Line
	13500 9850 13750 9850
Wire Wire Line
	5450 750  5250 750 
Wire Wire Line
	5450 850  5250 850 
Wire Wire Line
	6400 650  6250 650 
Wire Wire Line
	5450 1150 5450 1050
Wire Wire Line
	5250 950  5450 950 
Wire Wire Line
	7550 7250 7800 7250
Wire Wire Line
	2100 1150 2100 1750
Wire Wire Line
	2300 1150 2300 1750
Wire Wire Line
	2200 1750 2200 1500
Wire Wire Line
	2200 1500 2400 1500
Wire Wire Line
	2100 2050 3100 2050
Wire Wire Line
	3100 2050 3100 1750
Connection ~ 2100 1750
Wire Wire Line
	850  1250 3000 1250
Wire Wire Line
	3000 1250 3000 1750
Wire Wire Line
	2900 1750 2900 1500
Wire Wire Line
	2900 1500 3150 1500
Wire Wire Line
	3300 2850 3400 2850
Wire Wire Line
	13100 7000 12650 7000
Wire Wire Line
	11750 7000 11550 7000
Wire Wire Line
	11750 6250 11750 6600
Wire Wire Line
	4500 7350 4750 7350
Connection ~ 11750 6600
Wire Wire Line
	11550 6300 11550 6500
Wire Wire Line
	11550 6300 11400 6300
Wire Wire Line
	11550 5800 12650 5800
Wire Wire Line
	12650 5700 12650 5800
Connection ~ 12650 5800
Wire Wire Line
	13450 4200 13450 4400
Wire Wire Line
	13450 4400 14650 4400
Wire Wire Line
	14650 4400 14650 4700
Wire Wire Line
	14700 3550 14800 3550
Wire Wire Line
	14800 3550 14800 3650
Wire Wire Line
	14800 4100 14650 4100
Wire Wire Line
	14700 3650 14800 3650
Connection ~ 14800 3650
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
Wire Wire Line
	10600 3100 10600 3400
Wire Wire Line
	1650 6750 1350 6750
Wire Wire Line
	1650 7050 1350 7050
Wire Wire Line
	2850 6900 3150 6900
Wire Wire Line
	1650 6900 1650 7050
Wire Wire Line
	7200 700  7000 700 
Wire Wire Line
	6900 1200 7200 1200
Connection ~ 7200 1200
Wire Wire Line
	6900 1750 6900 1600
Wire Wire Line
	13650 9550 13650 8250
Wire Wire Line
	13650 8250 13250 8250
Wire Wire Line
	13600 9750 13600 8950
Wire Wire Line
	13600 8950 13250 8950
Wire Wire Line
	9450 9600 9450 8300
Wire Wire Line
	9450 8300 9050 8300
Wire Wire Line
	9400 9800 9400 9000
Wire Wire Line
	9400 9000 9050 9000
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
	9900 3250 9900 3050
Text Label 9900 2550 2    60   ~ 0
MA17
Wire Wire Line
	800  10700 800  10500
Connection ~ 800  10700
Text Label 800  10500 0    60   ~ 0
RST
Text Label 7700 9900 2    60   ~ 0
RST
Text Label 11900 9850 2    60   ~ 0
RST
Wire Wire Line
	5450 2700 5450 3050
Wire Wire Line
	5150 2400 5550 2400
Wire Wire Line
	5550 2400 5550 3100
Wire Wire Line
	5550 3100 5950 3100
Text Label 14800 4100 3    60   ~ 0
/INTACK
Wire Wire Line
	5300 1750 5700 1750
Wire Wire Line
	5700 1750 5700 3200
Wire Wire Line
	5700 3200 5950 3200
Text Label 4700 1750 2    60   ~ 0
/INTACK
Text Label 5700 1750 1    60   ~ 0
INTACK
Text Label 4250 2300 2    60   ~ 0
/RD
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
	5700 5450 5700 6250
Wire Wire Line
	7750 6000 7750 6200
Wire Wire Line
	9000 4600 9000 4800
Wire Wire Line
	9200 5000 9150 5000
Wire Wire Line
	9250 5100 9150 5100
Wire Wire Line
	9300 5200 9150 5200
Wire Wire Line
	9350 5300 9150 5300
Wire Wire Line
	9400 5400 9150 5400
Wire Wire Line
	9450 5500 9150 5500
Wire Wire Line
	9500 5600 10000 5600
Wire Wire Line
	9550 5700 10050 5700
Wire Wire Line
	6250 8150 6750 8150
Wire Wire Line
	3800 8550 3800 8650
Wire Wire Line
	5050 8150 5050 8550
Wire Wire Line
	3800 8350 3800 8550
Wire Wire Line
	8750 10700 8750 10850
Wire Wire Line
	8750 10850 8750 10950
Wire Wire Line
	8750 10950 8750 11100
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
	7400 9500 7400 9700
Wire Wire Line
	7400 9700 7400 9950
Wire Wire Line
	11600 9450 11600 9650
Wire Wire Line
	11600 9650 11600 9900
Wire Wire Line
	2100 1750 2100 2050
Wire Wire Line
	11750 6600 11750 7000
Wire Wire Line
	12650 5800 12650 6250
Wire Wire Line
	14800 3650 14800 4100
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
	7200 1200 7500 1200
Wire Wire Line
	15250 6900 15250 7150
Wire Wire Line
	15650 6900 15650 7150
Wire Wire Line
	800  10700 1200 10700
$Comp
L 74xx:74LS32 U22
U 1 1 5BBB275E
P 10350 7750
F 0 "U22" H 10350 7433 50  0000 C CNN
F 1 "74LS32" H 10350 7524 50  0000 C CNN
F 2 "" H 10350 7750 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS32" H 10350 7750 50  0001 C CNN
	1    10350 7750
	-1   0    0    1   
$EndComp
Wire Wire Line
	9850 7750 10050 7750
Text Label 9850 7750 0    50   ~ 0
/ESR1
Wire Wire Line
	10800 7850 10650 7850
Text Label 10800 7850 0    50   ~ 0
/E_SER
Wire Wire Line
	10800 7650 10650 7650
Text Label 10800 7650 0    50   ~ 0
A3
$Comp
L 74xx:74LS32 U22
U 4 1 5BD9039C
P 4850 2400
F 0 "U22" H 4850 2725 50  0000 C CNN
F 1 "74LS32" H 4850 2634 50  0000 C CNN
F 2 "" H 4850 2400 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS32" H 4850 2400 50  0001 C CNN
	4    4850 2400
	1    0    0    -1  
$EndComp
Wire Wire Line
	4550 2300 4250 2300
Wire Wire Line
	4550 2700 5450 2700
Wire Wire Line
	4550 2500 4550 2700
$Comp
L 74xx:74LS14 U6
U 4 1 5BFF61F4
P 5000 1750
F 0 "U6" H 5000 2067 50  0000 C CNN
F 1 "74LS14" H 5000 1976 50  0000 C CNN
F 2 "" H 5000 1750 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS14" H 5000 1750 50  0001 C CNN
	4    5000 1750
	1    0    0    -1  
$EndComp
Text Label 7800 6700 2    60   ~ 0
/IORQ
Text Label 7800 6500 2    60   ~ 0
A4
$Comp
L MultiF-Board-rescue:74LS32 U7
U 3 1 541FCFBB
P 8400 6600
F 0 "U7" H 8400 6650 60  0000 C CNN
F 1 "74LS32" H 8400 6550 60  0000 C CNN
F 2 "" H 8400 6600 60  0000 C CNN
F 3 "~" H 8400 6600 60  0000 C CNN
	3    8400 6600
	1    0    0    -1  
$EndComp
Wire Wire Line
	9000 6600 9000 6950
Wire Wire Line
	9000 6950 9500 6950
Wire Wire Line
	9500 6850 9500 6950
Connection ~ 9500 6950
Wire Wire Line
	5050 7750 5050 8150
Wire Wire Line
	14900 5400 14900 5800
Connection ~ 11750 7000
Connection ~ 11550 6300
$EndSCHEMATC
