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
Sheet 4 10
Title "mini M68K CPU"
Date "5 sep 2013"
Rev "2.0.007"
Comp "N8VEM User Group"
Comment1 "by John R. Coffman"
Comment2 "EXPERIMENTAL with I/O and memory protection and BERR"
Comment3 ""
Comment4 ""
$EndDescr
Text Notes 5250 3400 0    70   ~ 0
L*R + L*/B + /B*/R  ==  L*R + /B*/R
Wire Wire Line
	6800 2200 6800 2750
Wire Wire Line
	8300 3250 8300 2850
Wire Wire Line
	5800 5900 7300 5900
Wire Wire Line
	8150 4600 7700 4600
Connection ~ 1800 2100
Wire Wire Line
	2350 2000 2350 2100
Wire Wire Line
	2350 2100 1700 2100
Wire Wire Line
	1700 1100 1900 1100
Wire Wire Line
	8700 5200 9200 5200
Wire Wire Line
	8700 5500 9200 5500
Wire Wire Line
	7300 6100 6500 6100
Wire Wire Line
	8700 6000 8900 6000
Wire Wire Line
	7300 5700 6650 5700
Wire Wire Line
	6650 5700 6650 5100
Wire Wire Line
	6650 5100 7500 5100
Wire Wire Line
	7300 5500 7200 5500
Wire Wire Line
	7300 6200 7200 6200
Wire Wire Line
	7300 6400 7200 6400
Wire Wire Line
	9500 3350 9500 2450
Wire Wire Line
	9500 2450 7300 2450
Wire Wire Line
	7300 2450 7300 1700
Wire Wire Line
	7300 1700 7600 1700
Wire Wire Line
	8300 2850 8100 2850
Wire Wire Line
	6900 3750 6200 3750
Wire Wire Line
	6800 2200 6650 2200
Wire Wire Line
	7600 2000 7600 1800
Wire Wire Line
	7250 1300 7600 1300
Wire Wire Line
	7250 900  7600 900 
Wire Wire Line
	9450 1200 9000 1200
Wire Wire Line
	9450 800  9000 800 
Wire Wire Line
	3700 3000 3200 3000
Wire Wire Line
	3700 4400 3200 4400
Wire Wire Line
	3200 4800 3700 4800
Wire Wire Line
	3200 6200 3700 6200
Wire Wire Line
	3200 6600 3700 6600
Wire Wire Line
	1800 4300 1450 4300
Wire Wire Line
	1800 4700 1450 4700
Wire Wire Line
	1800 6100 1450 6100
Wire Wire Line
	1800 6500 1450 6500
Wire Wire Line
	1450 3100 1800 3100
Wire Wire Line
	1800 2700 1450 2700
Wire Wire Line
	1500 5200 1800 5200
Wire Wire Line
	1800 3700 1800 3500
Wire Wire Line
	1800 5500 1800 5300
Wire Wire Line
	1800 7300 1800 7100
Wire Wire Line
	1450 3400 1800 3400
Wire Wire Line
	1500 7000 1800 7000
Wire Wire Line
	1800 2900 1450 2900
Wire Wire Line
	1450 6700 1800 6700
Wire Wire Line
	1450 6300 1800 6300
Wire Wire Line
	1450 4900 1800 4900
Wire Wire Line
	1800 4500 1450 4500
Wire Wire Line
	3700 6800 3200 6800
Wire Wire Line
	3700 6400 3200 6400
Wire Wire Line
	3700 5000 3200 5000
Wire Wire Line
	3700 4600 3200 4600
Wire Wire Line
	3200 3200 3700 3200
Wire Wire Line
	3200 2800 3700 2800
Wire Wire Line
	9000 1000 9450 1000
Wire Wire Line
	9000 1400 9450 1400
Wire Wire Line
	7600 1100 7250 1100
Wire Wire Line
	7600 1500 7250 1500
Wire Wire Line
	6200 3950 6900 3950
Wire Wire Line
	6800 2750 6900 2750
Wire Wire Line
	6900 2950 6200 2950
Wire Wire Line
	8100 3850 8300 3850
Wire Wire Line
	6500 6500 7300 6500
Wire Wire Line
	8900 6200 8700 6200
Wire Wire Line
	9500 5700 8700 5700
Wire Wire Line
	7300 5600 6150 5600
Wire Wire Line
	8700 5600 9500 5600
Wire Wire Line
	9500 5600 9500 5000
Wire Wire Line
	9500 5000 8700 5000
Wire Wire Line
	9500 6100 8700 6100
Wire Wire Line
	7300 6000 7200 6000
Wire Wire Line
	8700 5800 8900 5800
Wire Wire Line
	1900 1100 1900 1700
Wire Wire Line
	2350 1400 1800 1400
Wire Wire Line
	1800 1400 1800 2100
Wire Wire Line
	5950 5000 7250 5000
Connection ~ 9200 5200
Wire Wire Line
	9200 5500 9200 4600
Wire Wire Line
	9200 4600 9050 4600
Wire Wire Line
	7300 5800 6550 5800
Wire Wire Line
	7250 5000 7250 4900
Wire Wire Line
	6800 4600 6100 4600
Wire Wire Line
	8700 5900 9500 5900
Wire Wire Line
	8300 3850 8300 3450
Text Notes 4250 5850 0    60   ~ 0
2011-10-27 update:\nadd DT/R to the ECB bus
Text GLabel 9500 5900 2    60   Output ~ 0
B_DT/R
Text GLabel 5800 5900 0    60   Input ~ 0
W/R
Text GLabel 8900 5800 2    60   Output ~ 0
/AS
Text GLabel 6550 5800 0    60   Input ~ 0
B_/MREQ
$Comp
L 74F04 U13
U 1 2 4E0269F4
P 8600 4600
F 0 "U13" H 8795 4715 60  0000 C CNN
F 1 "74F04" H 8790 4475 60  0000 C CNN
	1    8600 4600
	-1   0    0    -1  
$EndComp
Text GLabel 5950 5000 0    60   Input ~ 0
/BUSAK
$Comp
L 74LS125 U7
U 4 1 4E026F2E
P 7250 4600
F 0 "U7" H 7250 4700 50  0000 L BNN
F 1 "74LS125" H 7300 4450 40  0000 L TNN
	4    7250 4600
	-1   0    0    -1  
$EndComp
NoConn ~ 1800 2500
NoConn ~ 1800 2600
NoConn ~ 3200 2500
NoConn ~ 3200 2600
Text GLabel 1700 2100 0    60   Input ~ 0
BUSAK
$Comp
L GND #PWR04
U 1 1 4E026E39
P 4350 1400
F 0 "#PWR04" H 4350 1400 30  0001 C CNN
F 1 "GND" H 4350 1330 30  0001 C CNN
	1    4350 1400
	1    0    0    -1  
$EndComp
Text GLabel 3900 1100 0    60   Input ~ 0
CLK
Text GLabel 4800 1100 2    60   Output ~ 0
B_/CLK
$Comp
L 74LS125 U7
U 3 1 4E026DB0
P 4350 1100
F 0 "U7" H 4350 1200 50  0000 L BNN
F 1 "74LS125" H 4400 950 40  0000 L TNN
	3    4350 1100
	1    0    0    -1  
$EndComp
Text GLabel 2800 1700 2    60   3State ~ 0
B_A22
Text GLabel 2800 1100 2    60   3State ~ 0
B_A23
Text GLabel 1700 1100 0    60   Input ~ 0
IORQ
$Comp
L 74LS125 U7
U 1 1 4E026CEF
P 2350 1100
F 0 "U7" H 2350 1200 50  0000 L BNN
F 1 "74LS125" H 2400 950 40  0000 L TNN
	1    2350 1100
	1    0    0    -1  
$EndComp
$Comp
L 74LS125 U7
U 2 1 4E026CDC
P 2350 1700
F 0 "U7" H 2350 1800 50  0000 L BNN
F 1 "74LS125" H 2400 1550 40  0000 L TNN
	2    2350 1700
	1    0    0    -1  
$EndComp
Text GLabel 6100 4600 0    60   Output ~ 0
R/W
Text GLabel 6500 6100 0    60   Input ~ 0
/WR
Text GLabel 7200 6000 0    60   Input ~ 0
/RD
$Comp
L 74LS08 U12
U 1 2 4E026840
P 8100 5100
F 0 "U12" H 8100 5150 60  0000 C CNN
F 1 "74LS08" H 8100 5050 60  0000 C CNN
	1    8100 5100
	-1   0    0    -1  
$EndComp
Text GLabel 9500 5700 2    60   Output ~ 0
/DS
Text GLabel 9500 6100 2    60   Output ~ 0
B_/WR
Text GLabel 8900 6000 2    60   Output ~ 0
B_/RD
Text GLabel 7200 5500 0    60   Input ~ 0
B_/RD
Text GLabel 6150 5600 0    60   Input ~ 0
B_/WR
Text GLabel 8900 6200 2    60   Output ~ 0
/WAIT
Text GLabel 7200 6200 0    60   Input ~ 0
B_/WAIT
Text Notes 6050 6400 2    60   ~ 0
DMA\n\n& non-DMA
Text GLabel 6500 6500 0    60   Input ~ 0
BUSAK
Text GLabel 7200 6400 0    60   Input ~ 0
/BUSAK
$Comp
L 74LS244 U11
U 1 1 4E026521
P 8000 6000
F 0 "U11" H 8050 5800 60  0000 C CNN
F 1 "74LS244" H 8100 5600 60  0000 C CNN
	1    8000 6000
	1    0    0    -1  
$EndComp
Text Label 8150 2450 0    60   ~ 0
D_OUT
Text GLabel 6200 3750 0    60   Input ~ 0
W/R
Text GLabel 6200 2950 0    60   Input ~ 0
R/W
Text GLabel 6200 3950 0    60   Input ~ 0
/BUSAK
$Comp
L 74LS00 U4
U 4 1 4E024899
P 7500 3850
F 0 "U4" H 7500 3900 60  0000 C CNN
F 1 "74LS00" H 7500 3750 60  0000 C CNN
	4    7500 3850
	1    0    0    -1  
$EndComp
$Comp
L 74LS00 U4
U 2 1 4E024892
P 7500 2850
F 0 "U4" H 7500 2900 60  0000 C CNN
F 1 "74LS00" H 7500 2750 60  0000 C CNN
	2    7500 2850
	1    0    0    -1  
$EndComp
$Comp
L 74LS00 U4
U 3 2 4E024880
P 8900 3350
F 0 "U4" H 8900 3400 60  0000 C CNN
F 1 "74LS00" H 8900 3250 60  0000 C CNN
	3    8900 3350
	1    0    0    -1  
$EndComp
Text Label 6650 2200 0    60   ~ 0
LOCAL
Text GLabel 5450 2300 0    60   Input ~ 0
IORQ
Text GLabel 5450 2100 0    60   Input ~ 0
MREQ
$Comp
L 74LS02 U1
U 2 2 4E0245F7
P 6050 2200
F 0 "U1" H 6050 2250 60  0000 C CNN
F 1 "74LS02" H 6100 2150 60  0000 C CNN
	2    6050 2200
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR05
U 1 1 4E0236B2
P 7600 2000
F 0 "#PWR05" H 7600 2000 30  0001 C CNN
F 1 "GND" H 7600 1930 30  0001 C CNN
	1    7600 2000
	1    0    0    -1  
$EndComp
Text GLabel 7250 900  0    60   BiDi ~ 0
D6
Text GLabel 7250 1100 0    60   BiDi ~ 0
D4
Text GLabel 7250 1300 0    60   BiDi ~ 0
D2
Text GLabel 7250 1500 0    60   BiDi ~ 0
D0
Text GLabel 7600 1400 0    60   BiDi ~ 0
D1
Text GLabel 7600 1200 0    60   BiDi ~ 0
D3
Text GLabel 7600 1000 0    60   BiDi ~ 0
D5
Text GLabel 7600 800  0    60   BiDi ~ 0
D7
Text GLabel 9450 1200 2    60   BiDi ~ 0
B_D3
Text GLabel 9450 1000 2    60   BiDi ~ 0
B_D5
Text GLabel 9450 800  2    60   BiDi ~ 0
B_D7
Text GLabel 9000 900  2    60   BiDi ~ 0
B_D6
Text GLabel 9000 1100 2    60   BiDi ~ 0
B_D4
Text GLabel 9000 1300 2    60   BiDi ~ 0
B_D2
Text GLabel 9450 1400 2    60   BiDi ~ 0
B_D1
Text GLabel 9000 1500 2    60   BiDi ~ 0
B_D0
$Comp
L 74LS245 U14
U 1 1 4E023588
P 8300 1300
F 0 "U14" H 8400 1875 60  0000 L BNN
F 1 "74LS245" H 8350 725 60  0000 L TNN
	1    8300 1300
	1    0    0    -1  
$EndComp
Text GLabel 3700 6800 2    60   BiDi ~ 0
B_A0
Text GLabel 3700 6600 2    60   BiDi ~ 0
B_A2
Text GLabel 3700 6400 2    60   BiDi ~ 0
B_A4
Text GLabel 3700 6200 2    60   BiDi ~ 0
B_A6
Text GLabel 3700 5000 2    60   BiDi ~ 0
B_A8
Text GLabel 3700 4800 2    60   BiDi ~ 0
B_A10
Text GLabel 3700 4600 2    60   BiDi ~ 0
B_A12
Text GLabel 3700 4400 2    60   BiDi ~ 0
B_A14
Text GLabel 3700 3200 2    60   BiDi ~ 0
B_A16
Text GLabel 3700 3000 2    60   BiDi ~ 0
B_A18
Text GLabel 3700 2800 2    60   BiDi ~ 0
B_A20
Text GLabel 3200 2700 2    60   BiDi ~ 0
B_A21
Text GLabel 3200 2900 2    60   BiDi ~ 0
B_A19
Text GLabel 3200 3100 2    60   BiDi ~ 0
B_A17
Text GLabel 3200 4300 2    60   BiDi ~ 0
B_A15
Text GLabel 3200 4500 2    60   BiDi ~ 0
B_A13
Text GLabel 3200 4700 2    60   BiDi ~ 0
B_A11
Text GLabel 3200 4900 2    60   BiDi ~ 0
B_A9
Text GLabel 3200 6100 2    60   BiDi ~ 0
B_A7
Text GLabel 3200 6300 2    60   BiDi ~ 0
B_A5
Text GLabel 3200 6500 2    60   BiDi ~ 0
B_A3
Text GLabel 3200 6700 2    60   BiDi ~ 0
B_A1
Text GLabel 1450 6700 0    60   BiDi ~ 0
A1
Text GLabel 1450 6500 0    60   BiDi ~ 0
A3
Text GLabel 1450 6300 0    60   BiDi ~ 0
A5
Text GLabel 1450 6100 0    60   BiDi ~ 0
A7
Text GLabel 1450 4900 0    60   BiDi ~ 0
A9
Text GLabel 1450 4700 0    60   BiDi ~ 0
A11
Text GLabel 1450 4500 0    60   BiDi ~ 0
A13
Text GLabel 1450 4300 0    60   BiDi ~ 0
A15
Text GLabel 1450 3100 0    60   BiDi ~ 0
A17
Text GLabel 1450 2900 0    60   BiDi ~ 0
A19
Text GLabel 1450 2700 0    60   BiDi ~ 0
A21
Text GLabel 1800 2800 0    60   BiDi ~ 0
A20
Text GLabel 1800 3000 0    60   BiDi ~ 0
A18
Text GLabel 1800 3200 0    60   BiDi ~ 0
A16
Text GLabel 1800 4400 0    60   BiDi ~ 0
A14
Text GLabel 1800 4600 0    60   BiDi ~ 0
A12
Text GLabel 1800 4800 0    60   BiDi ~ 0
A10
Text GLabel 1800 5000 0    60   BiDi ~ 0
A8
Text GLabel 1800 6200 0    60   BiDi ~ 0
A6
Text GLabel 1800 6400 0    60   BiDi ~ 0
A4
Text GLabel 1800 6600 0    60   BiDi ~ 0
A2
Text GLabel 1800 6800 0    60   BiDi ~ 0
A0
Text GLabel 1500 7000 0    60   Input ~ 0
/BUSAK
Text GLabel 1450 3400 0    60   Input ~ 0
/BUSAK
Text GLabel 1500 5200 0    60   Input ~ 0
/BUSAK
$Comp
L GND #PWR06
U 1 1 4E023159
P 1800 3700
F 0 "#PWR06" H 1800 3700 30  0001 C CNN
F 1 "GND" H 1800 3630 30  0001 C CNN
	1    1800 3700
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR07
U 1 1 4E02314E
P 1800 5500
F 0 "#PWR07" H 1800 5500 30  0001 C CNN
F 1 "GND" H 1800 5430 30  0001 C CNN
	1    1800 5500
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR08
U 1 1 4E023126
P 1800 7300
F 0 "#PWR08" H 1800 7300 30  0001 C CNN
F 1 "GND" H 1800 7230 30  0001 C CNN
	1    1800 7300
	1    0    0    -1  
$EndComp
$Comp
L 74LS245 U10
U 1 1 4E0230F9
P 2500 6600
F 0 "U10" H 2600 7175 60  0000 L BNN
F 1 "74LS245" H 2550 6025 60  0000 L TNN
	1    2500 6600
	1    0    0    -1  
$EndComp
$Comp
L 74LS245 U9
U 1 1 4E0230EE
P 2500 4800
F 0 "U9" H 2600 5375 60  0000 L BNN
F 1 "74LS245" H 2550 4225 60  0000 L TNN
	1    2500 4800
	1    0    0    -1  
$EndComp
$Comp
L 74LS245 U8
U 1 1 4E0230E7
P 2500 3000
F 0 "U8" H 2600 3575 60  0000 L BNN
F 1 "74LS245" H 2550 2425 60  0000 L TNN
	1    2500 3000
	1    0    0    -1  
$EndComp
$EndSCHEMATC
