EESchema Schematic File Version 4
LIBS:babyM68K-cache
EELAYER 29 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 5 10
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
	5250 6900 4100 6900
Connection ~ 6800 5500
Wire Wire Line
	8100 5500 6300 5500
Wire Wire Line
	10150 5600 9800 5600
Connection ~ 4800 5950
Wire Wire Line
	4800 4600 4800 5950
Wire Wire Line
	4800 4600 5000 4600
Wire Wire Line
	5450 6900 6800 6900
Wire Wire Line
	6800 6900 6800 6250
Wire Wire Line
	4800 6250 4800 6100
Wire Wire Line
	4800 6100 4950 6100
Wire Wire Line
	6150 5950 6800 5950
Wire Wire Line
	6800 5950 6800 5500
Wire Wire Line
	6300 5500 6300 5100
Wire Wire Line
	6300 5100 6500 5100
Connection ~ 6300 4200
Wire Wire Line
	6500 4900 6300 4900
Wire Wire Line
	6300 4900 6300 4200
Wire Wire Line
	9950 4300 9300 4300
Wire Wire Line
	8100 4200 5700 4200
Wire Wire Line
	8100 4400 8100 4800
Wire Wire Line
	1200 3200 950  3200
Wire Wire Line
	950  3200 950  3300
Wire Wire Line
	950  3300 650  3300
Wire Wire Line
	1100 3900 1400 3900
Wire Wire Line
	2200 3800 2300 3800
Wire Wire Line
	2300 3800 2300 3700
Wire Wire Line
	2600 1300 2850 1300
Wire Wire Line
	2600 1700 2850 1700
Wire Wire Line
	1200 1300 950  1300
Wire Wire Line
	950  1700 1200 1700
Wire Wire Line
	950  2100 1200 2100
Wire Wire Line
	950  2500 1200 2500
Wire Wire Line
	950  2700 1200 2700
Wire Wire Line
	1200 2300 950  2300
Wire Wire Line
	1200 1900 950  1900
Wire Wire Line
	1200 1500 950  1500
Wire Wire Line
	950  1100 1200 1100
Wire Wire Line
	2600 1500 2850 1500
Wire Wire Line
	2600 1100 2850 1100
Wire Wire Line
	1200 2800 1050 2800
Wire Wire Line
	1050 2800 1050 3800
Wire Wire Line
	1050 3800 1400 3800
Wire Wire Line
	1200 2900 1150 2900
Wire Wire Line
	1150 2900 1150 4250
Wire Wire Line
	1150 4250 2200 4250
Wire Wire Line
	2200 4250 2200 3900
Wire Wire Line
	1200 3100 950  3100
Wire Wire Line
	7600 4600 8100 4600
Connection ~ 8100 4600
Wire Wire Line
	9950 4900 9300 4900
Wire Wire Line
	2400 5400 2900 5400
Wire Wire Line
	4100 5100 4400 5100
Wire Wire Line
	4400 5100 4400 5800
Wire Wire Line
	4400 5800 4950 5800
Wire Wire Line
	7700 5000 8100 5000
Wire Wire Line
	2900 5800 2250 5800
Wire Wire Line
	2250 5800 2250 6000
Wire Wire Line
	4300 5950 4950 5950
Wire Wire Line
	7150 6250 4800 6250
Connection ~ 6800 6250
Wire Wire Line
	9300 5600 9600 5600
Wire Wire Line
	7650 5700 8100 5700
$Comp
L babyM68K-rescue:74LS02 U1
U 3 2 5228C292
P 3500 6900
F 0 "U1" H 3500 6950 60  0000 C CNN
F 1 "74LS02" H 3550 6850 60  0000 C CNN
F 2 "" H 3500 6900 50  0001 C CNN
F 3 "" H 3500 6900 50  0001 C CNN
	3    3500 6900
	1    0    0    -1  
$EndComp
Text Notes 1600 5600 0    60   ~ 0
from select.sch
Text GLabel 7650 5700 0    60   Input ~ 0
R/W
Text Notes 10050 5400 0    60   ~ 0
pull-up on\nselect.sch
$Comp
L babyM68K-rescue:CONN_2 J10
U 1 1 51028C32
P 9700 5950
F 0 "J10" V 9650 5950 40  0000 C CNN
F 1 "CONN_2" V 9750 5950 40  0000 C CNN
F 2 "" H 9700 5950 50  0001 C CNN
F 3 "" H 9700 5950 50  0001 C CNN
	1    9700 5950
	0    1    1    0   
$EndComp
$Comp
L babyM68K-rescue:74LS32 U17
U 3 2 51028BBC
P 8700 5600
F 0 "U17" H 8700 5650 60  0000 C CNN
F 1 "74LS32" H 8700 5550 60  0000 C CNN
F 2 "" H 8700 5600 50  0001 C CNN
F 3 "" H 8700 5600 50  0001 C CNN
	3    8700 5600
	1    0    0    -1  
$EndComp
Text GLabel 5000 4600 2    60   Input ~ 0
PU_MEM64K/4K
Text GLabel 7150 6250 2    60   Input ~ 0
PU_MEM4K/1K
$Comp
L babyM68K-rescue:CONN_2 J8
U 1 1 5101EED9
P 4200 6300
F 0 "J8" V 4150 6300 40  0000 C CNN
F 1 "CONN_2" V 4250 6300 40  0000 C CNN
F 2 "" H 4200 6300 50  0001 C CNN
F 3 "" H 4200 6300 50  0001 C CNN
	1    4200 6300
	0    1    1    0   
$EndComp
$Comp
L babyM68K-rescue:CONN_2 J7
U 1 1 5101EE74
P 5350 7250
F 0 "J7" V 5300 7250 40  0000 C CNN
F 1 "CONN_2" V 5400 7250 40  0000 C CNN
F 2 "" H 5350 7250 50  0001 C CNN
F 3 "" H 5350 7250 50  0001 C CNN
	1    5350 7250
	0    1    1    0   
$EndComp
Text Label 6450 5500 0    60   ~ 0
/USERLOWMEM
$Comp
L babyM68K-rescue:74LS260 U31
U 1 2 5101E528
P 3500 5100
F 0 "U31" H 3500 5150 60  0000 C CNN
F 1 "74LS260" H 3500 5050 60  0000 C CNN
F 2 "" H 3500 5100 50  0001 C CNN
F 3 "" H 3500 5100 50  0001 C CNN
	1    3500 5100
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:GND #PWR09
U 1 1 5101E4D1
P 2250 6000
F 0 "#PWR09" H 2250 6000 30  0001 C CNN
F 1 "GND" H 2250 5930 30  0001 C CNN
F 2 "" H 2250 6000 50  0001 C CNN
F 3 "" H 2250 6000 50  0001 C CNN
	1    2250 6000
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:74LS00 U21
U 3 1 5101E300
P 7100 5000
F 0 "U21" H 7100 5050 60  0000 C CNN
F 1 "74LS00" H 7100 4900 60  0000 C CNN
F 2 "" H 7100 5000 50  0001 C CNN
F 3 "" H 7100 5000 50  0001 C CNN
	3    7100 5000
	1    0    0    -1  
$EndComp
Text GLabel 10150 5600 2    60   Output ~ 0
/BERR
$Comp
L babyM68K-rescue:74LS10 U6
U 3 1 5101DF9B
P 5550 5950
F 0 "U6" H 5550 6000 60  0000 C CNN
F 1 "74LS10" H 5550 5900 60  0000 C CNN
F 2 "" H 5550 5950 50  0001 C CNN
F 3 "" H 5550 5950 50  0001 C CNN
	3    5550 5950
	1    0    0    -1  
$EndComp
Text GLabel 2400 5400 0    60   Input ~ 0
SUPV/USER
Text Label 2900 5250 2    60   ~ 0
/CSRAM0
Text Label 2900 7000 2    60   ~ 0
A10
Text Label 2900 6800 2    60   ~ 0
A11
Text Label 2900 4800 2    60   ~ 0
A18
Text Label 2900 4950 2    60   ~ 0
A17
Text Label 2900 5100 2    60   ~ 0
A16
Text Label 2900 5950 2    60   ~ 0
A14
Text Label 2900 5650 2    60   ~ 0
A15
Text Label 2900 6100 2    60   ~ 0
A13
Text Label 2900 6250 2    60   ~ 0
A12
$Comp
L babyM68K-rescue:74LS260 U31
U 2 2 5101DC7B
P 3500 5950
F 0 "U31" H 3500 6000 60  0000 C CNN
F 1 "74LS260" H 3500 5900 60  0000 C CNN
F 2 "" H 3500 5950 50  0001 C CNN
F 3 "" H 3500 5950 50  0001 C CNN
	2    3500 5950
	1    0    0    -1  
$EndComp
Text GLabel 9950 4900 2    60   Output ~ 0
/WR
Text GLabel 9950 4300 2    60   Output ~ 0
/RD
$Comp
L babyM68K-rescue:74LS32 U17
U 2 2 4E01537D
P 8700 4900
F 0 "U17" H 8700 4950 60  0000 C CNN
F 1 "74LS32" H 8700 4850 60  0000 C CNN
F 2 "" H 8700 4900 50  0001 C CNN
F 3 "" H 8700 4900 50  0001 C CNN
	2    8700 4900
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:74LS32 U17
U 1 2 4E015372
P 8700 4300
F 0 "U17" H 8700 4350 60  0000 C CNN
F 1 "74LS32" H 8700 4250 60  0000 C CNN
F 2 "" H 8700 4300 50  0001 C CNN
F 3 "" H 8700 4300 50  0001 C CNN
	1    8700 4300
	1    0    0    -1  
$EndComp
Text GLabel 5700 4200 0    60   Input ~ 0
W/R
Text GLabel 7600 4600 0    60   Input ~ 0
/DS
Text Label 850  3300 2    60   ~ 0
/RD
Text GLabel 950  3100 0    60   Input ~ 0
/ROM
Text Notes 1200 4450 0    60   ~ 0
128K, 256K, 512K Flash\n    1-2, 3-4
Text Notes 1450 4800 0    60   ~ 0
512K EPROM\n   1-3, 2-4
$Comp
L babyM68K-rescue:VCC #PWR010
U 1 1 4E014ED1
P 2300 3700
F 0 "#PWR010" H 2300 3800 30  0001 C CNN
F 1 "VCC" H 2300 3800 30  0000 C CNN
F 2 "" H 2300 3700 50  0001 C CNN
F 3 "" H 2300 3700 50  0001 C CNN
	1    2300 3700
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:CONN_2X2 J1
U 1 1 4E014D97
P 1800 3850
F 0 "J1" H 1800 4050 50  0000 C CNN
F 1 "FLSH/EPR" H 1800 3650 50  0000 C CNN
F 2 "" H 1800 3850 50  0001 C CNN
F 3 "" H 1800 3850 50  0001 C CNN
	1    1800 3850
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:29F040 U15
U 1 1 4E014CFD
P 1900 1900
F 0 "U15" H 1900 1800 70  0000 C CNN
F 1 "29F040" H 2000 1600 70  0000 C CNN
F 2 "" H 1900 1900 50  0001 C CNN
F 3 "" H 1900 1900 50  0001 C CNN
	1    1900 1900
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:SRAM_512K U19
U 1 1 4E014957
P 8000 2100
F 0 "U19" H 8000 2200 60  0000 C CNN
F 1 "SRAM_512K" H 8050 1300 60  0000 C CNN
F 2 "" H 8000 2100 50  0001 C CNN
F 3 "" H 8000 2100 50  0001 C CNN
	1    8000 2100
	1    0    0    -1  
$EndComp
Text Label 7300 1000 2    60   ~ 0
A0
Text Label 7300 1100 2    60   ~ 0
A1
Text Label 7300 1200 2    60   ~ 0
A2
Text Label 7300 1300 2    60   ~ 0
A3
Text Label 7300 1400 2    60   ~ 0
A4
Text Label 7300 1500 2    60   ~ 0
A5
Text Label 7300 1600 2    60   ~ 0
A6
Text Label 7300 1700 2    60   ~ 0
A7
Text Label 7300 1800 2    60   ~ 0
A8
Text Label 7300 1900 2    60   ~ 0
A9
Text Label 7300 2000 2    60   ~ 0
A10
Text Label 7300 2100 2    60   ~ 0
A11
Text Label 7300 2200 2    60   ~ 0
A12
Text Label 7300 2300 2    60   ~ 0
A13
Text Label 7300 2400 2    60   ~ 0
A14
Text Label 7300 2500 2    60   ~ 0
A15
Text Label 7300 2600 2    60   ~ 0
A16
Text Label 7300 2700 2    60   ~ 0
A17
Text Label 7300 2800 2    60   ~ 0
A18
Text Label 8700 1000 0    60   ~ 0
D0
Text Label 8700 1100 0    60   ~ 0
D1
Text Label 8700 1200 0    60   ~ 0
D2
Text Label 8700 1300 0    60   ~ 0
D3
Text Label 8700 1400 0    60   ~ 0
D4
Text Label 8700 1500 0    60   ~ 0
D5
Text Label 8700 1600 0    60   ~ 0
D6
Text Label 8700 1700 0    60   ~ 0
D7
Text Label 7300 3000 2    60   ~ 0
/RD
Text Label 7300 3100 2    60   ~ 0
/WR
Text GLabel 7300 3200 0    60   Input ~ 0
/CSRAM2
Text GLabel 9200 3200 0    60   Input ~ 0
/CSRAM3
Text Label 9200 3100 2    60   ~ 0
/WR
Text Label 9200 3000 2    60   ~ 0
/RD
Text Label 10600 1700 0    60   ~ 0
D7
Text Label 10600 1600 0    60   ~ 0
D6
Text Label 10600 1500 0    60   ~ 0
D5
Text Label 10600 1400 0    60   ~ 0
D4
Text Label 10600 1300 0    60   ~ 0
D3
Text Label 10600 1200 0    60   ~ 0
D2
Text Label 10600 1100 0    60   ~ 0
D1
Text Label 10600 1000 0    60   ~ 0
D0
Text Label 9200 2800 2    60   ~ 0
A18
Text Label 9200 2700 2    60   ~ 0
A17
Text Label 9200 2600 2    60   ~ 0
A16
Text Label 9200 2500 2    60   ~ 0
A15
Text Label 9200 2400 2    60   ~ 0
A14
Text Label 9200 2300 2    60   ~ 0
A13
Text Label 9200 2200 2    60   ~ 0
A12
Text Label 9200 2100 2    60   ~ 0
A11
Text Label 9200 2000 2    60   ~ 0
A10
Text Label 9200 1900 2    60   ~ 0
A9
Text Label 9200 1800 2    60   ~ 0
A8
Text Label 9200 1700 2    60   ~ 0
A7
Text Label 9200 1600 2    60   ~ 0
A6
Text Label 9200 1500 2    60   ~ 0
A5
Text Label 9200 1400 2    60   ~ 0
A4
Text Label 9200 1300 2    60   ~ 0
A3
Text Label 9200 1200 2    60   ~ 0
A2
Text Label 9200 1100 2    60   ~ 0
A1
Text Label 9200 1000 2    60   ~ 0
A0
$Comp
L babyM68K-rescue:SRAM_512K U20
U 1 1 4E014938
P 9900 2100
F 0 "U20" H 9900 2200 60  0000 C CNN
F 1 "SRAM_512K" H 9950 1300 60  0000 C CNN
F 2 "" H 9900 2100 50  0001 C CNN
F 3 "" H 9900 2100 50  0001 C CNN
	1    9900 2100
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:SRAM_512K U18
U 1 1 4E014925
P 6100 2100
F 0 "U18" H 6100 2200 60  0000 C CNN
F 1 "SRAM_512K" H 6150 1300 60  0000 C CNN
F 2 "" H 6100 2100 50  0001 C CNN
F 3 "" H 6100 2100 50  0001 C CNN
	1    6100 2100
	1    0    0    -1  
$EndComp
Text Label 5400 1000 2    60   ~ 0
A0
Text Label 5400 1100 2    60   ~ 0
A1
Text Label 5400 1200 2    60   ~ 0
A2
Text Label 5400 1300 2    60   ~ 0
A3
Text Label 5400 1400 2    60   ~ 0
A4
Text Label 5400 1500 2    60   ~ 0
A5
Text Label 5400 1600 2    60   ~ 0
A6
Text Label 5400 1700 2    60   ~ 0
A7
Text Label 5400 1800 2    60   ~ 0
A8
Text Label 5400 1900 2    60   ~ 0
A9
Text Label 5400 2000 2    60   ~ 0
A10
Text Label 5400 2100 2    60   ~ 0
A11
Text Label 5400 2200 2    60   ~ 0
A12
Text Label 5400 2300 2    60   ~ 0
A13
Text Label 5400 2400 2    60   ~ 0
A14
Text Label 5400 2500 2    60   ~ 0
A15
Text Label 5400 2600 2    60   ~ 0
A16
Text Label 5400 2700 2    60   ~ 0
A17
Text Label 5400 2800 2    60   ~ 0
A18
Text Label 6800 1000 0    60   ~ 0
D0
Text Label 6800 1100 0    60   ~ 0
D1
Text Label 6800 1200 0    60   ~ 0
D2
Text Label 6800 1300 0    60   ~ 0
D3
Text Label 6800 1400 0    60   ~ 0
D4
Text Label 6800 1500 0    60   ~ 0
D5
Text Label 6800 1600 0    60   ~ 0
D6
Text Label 6800 1700 0    60   ~ 0
D7
Text Label 5400 3000 2    60   ~ 0
/RD
Text Label 5400 3100 2    60   ~ 0
/WR
Text GLabel 5400 3200 0    60   Input ~ 0
/CSRAM1
Text GLabel 3500 3200 0    60   Input ~ 0
/CSRAM0
Text Label 3500 3100 2    60   ~ 0
/WR
Text Label 3500 3000 2    60   ~ 0
/RD
Text Label 4900 1700 0    60   ~ 0
D7
Text Label 4900 1600 0    60   ~ 0
D6
Text Label 4900 1500 0    60   ~ 0
D5
Text Label 4900 1400 0    60   ~ 0
D4
Text Label 4900 1300 0    60   ~ 0
D3
Text Label 4900 1200 0    60   ~ 0
D2
Text Label 4900 1100 0    60   ~ 0
D1
Text Label 4900 1000 0    60   ~ 0
D0
Text Label 3500 2800 2    60   ~ 0
A18
Text Label 3500 2700 2    60   ~ 0
A17
Text Label 3500 2600 2    60   ~ 0
A16
Text Label 3500 2500 2    60   ~ 0
A15
Text Label 3500 2400 2    60   ~ 0
A14
Text Label 3500 2300 2    60   ~ 0
A13
Text Label 3500 2200 2    60   ~ 0
A12
Text Label 3500 2100 2    60   ~ 0
A11
Text Label 3500 2000 2    60   ~ 0
A10
Text Label 3500 1900 2    60   ~ 0
A9
Text Label 3500 1800 2    60   ~ 0
A8
Text Label 3500 1700 2    60   ~ 0
A7
Text Label 3500 1600 2    60   ~ 0
A6
Text Label 3500 1500 2    60   ~ 0
A5
Text Label 3500 1400 2    60   ~ 0
A4
Text Label 3500 1300 2    60   ~ 0
A3
Text Label 3500 1200 2    60   ~ 0
A2
Text Label 3500 1100 2    60   ~ 0
A1
Text Label 3500 1000 2    60   ~ 0
A0
Text GLabel 2850 1700 2    60   BiDi ~ 0
D7
Text GLabel 2600 1600 2    60   BiDi ~ 0
D6
Text GLabel 2850 1500 2    60   BiDi ~ 0
D5
Text GLabel 2600 1400 2    60   BiDi ~ 0
D4
Text GLabel 2850 1300 2    60   BiDi ~ 0
D3
Text GLabel 2600 1200 2    60   BiDi ~ 0
D2
Text GLabel 2850 1100 2    60   BiDi ~ 0
D1
Text GLabel 2600 1000 2    60   BiDi ~ 0
D0
Text GLabel 1100 3900 0    60   Input ~ 0
A18
Text GLabel 950  2700 0    60   Input ~ 0
A17
Text GLabel 1200 2600 0    60   Input ~ 0
A16
Text GLabel 950  2500 0    60   Input ~ 0
A15
Text GLabel 1200 2400 0    60   Input ~ 0
A14
Text GLabel 950  2300 0    60   Input ~ 0
A13
Text GLabel 1200 2200 0    60   Input ~ 0
A12
Text GLabel 950  2100 0    60   Input ~ 0
A11
Text GLabel 1200 2000 0    60   Input ~ 0
A10
Text GLabel 950  1900 0    60   Input ~ 0
A9
Text GLabel 1200 1800 0    60   Input ~ 0
A8
Text GLabel 950  1700 0    60   Input ~ 0
A7
Text GLabel 1200 1600 0    60   Input ~ 0
A6
Text GLabel 950  1500 0    60   Input ~ 0
A5
Text GLabel 1200 1400 0    60   Input ~ 0
A4
Text GLabel 950  1300 0    60   Input ~ 0
A3
Text GLabel 1200 1200 0    60   Input ~ 0
A2
Text GLabel 950  1100 0    60   Input ~ 0
A1
Text GLabel 1200 1000 0    60   Input ~ 0
A0
$Comp
L babyM68K-rescue:SRAM_512K U16
U 1 1 4E014532
P 4200 2100
F 0 "U16" H 4200 2200 60  0000 C CNN
F 1 "SRAM_512K" H 4250 1300 60  0000 C CNN
F 2 "" H 4200 2100 50  0001 C CNN
F 3 "" H 4200 2100 50  0001 C CNN
	1    4200 2100
	1    0    0    -1  
$EndComp
$EndSCHEMATC
