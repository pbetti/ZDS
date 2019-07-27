EESchema Schematic File Version 4
LIBS:babyM68K-cache
EELAYER 29 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 10
Title "mini M68K CPU"
Date "5 sep 2013"
Rev "2.0.007"
Comp "N8VEM User Group"
Comment1 "by John R. Coffman"
Comment2 "EXPERIMENTAL with I/O and memory protection and BERR"
Comment3 ""
Comment4 ""
$EndDescr
NoConn ~ 9100 4950
NoConn ~ 9100 4800
NoConn ~ 9100 4650
NoConn ~ 10300 4800
$Comp
L babyM68K-rescue:74LS10 U26
U 1 1 5228C549
P 9700 4800
F 0 "U26" H 9700 4850 60  0000 C CNN
F 1 "74LS10" H 9700 4750 60  0000 C CNN
F 2 "" H 9700 4800 50  0001 C CNN
F 3 "" H 9700 4800 50  0001 C CNN
	1    9700 4800
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:74LS32 U17
U 4 1 5228C4AB
P 9700 4100
F 0 "U17" H 9700 4150 60  0000 C CNN
F 1 "74LS32" H 9700 4050 60  0000 C CNN
F 2 "" H 9700 4100 50  0001 C CNN
F 3 "" H 9700 4100 50  0001 C CNN
	4    9700 4100
	1    0    0    -1  
$EndComp
NoConn ~ 9100 4000
NoConn ~ 9100 4200
NoConn ~ 10300 4100
NoConn ~ 9100 3500
NoConn ~ 9100 3300
NoConn ~ 10300 3400
$Comp
L babyM68K-rescue:74LS00 U21
U 1 1 5227E50F
P 9700 3400
F 0 "U21" H 9700 3450 60  0000 C CNN
F 1 "74LS00" H 9700 3300 60  0000 C CNN
F 2 "" H 9700 3400 50  0001 C CNN
F 3 "" H 9700 3400 50  0001 C CNN
	1    9700 3400
	1    0    0    -1  
$EndComp
NoConn ~ 10050 2700
NoConn ~ 9150 2700
NoConn ~ 9100 2100
NoConn ~ 9100 1900
NoConn ~ 10300 2000
$Comp
L babyM68K-rescue:74F04 U13
U 3 1 5227E039
P 9600 2700
F 0 "U13" H 9795 2815 60  0000 C CNN
F 1 "74F04" H 9790 2575 60  0000 C CNN
F 2 "" H 9600 2700 50  0001 C CNN
F 3 "" H 9600 2700 50  0001 C CNN
	3    9600 2700
	1    0    0    -1  
$EndComp
$Comp
L babyM68K-rescue:74LS08 U12
U 2 1 5227DFD9
P 9700 2000
F 0 "U12" H 9700 2050 60  0000 C CNN
F 1 "74LS08" H 9700 1950 60  0000 C CNN
F 2 "" H 9700 2000 50  0001 C CNN
F 3 "" H 9700 2000 50  0001 C CNN
	2    9700 2000
	1    0    0    -1  
$EndComp
Text Notes 9450 1550 0    70   ~ 0
SPARE:
$Sheet
S 7000 2400 600  550 
U 4E027B4C
F0 "DMA_bus" 60
F1 "dma_bus.sch" 60
$EndSheet
$Sheet
S 5500 2400 600  550 
U 4E025459
F0 "Interrupts" 60
F1 "interrupts.sch" 60
$EndSheet
$Sheet
S 4000 2400 600  550 
U 4E02306B
F0 "Tranceivers" 60
F1 "tranceivers.sch" 60
$EndSheet
$Sheet
S 2500 2400 600  550 
U 4E0144A0
F0 "Memory" 60
F1 "memory.sch" 60
$EndSheet
$Sheet
S 5500 1000 600  550 
U 4E00EB8E
F0 "Reset" 60
F1 "reset.sch" 60
$EndSheet
$Sheet
S 7000 1000 600  550 
U 4E00EB31
F0 "Wait State" 60
F1 "waitState.sch" 60
$EndSheet
$Sheet
S 4000 1000 600  550 
U 4DFFB181
F0 "Select" 60
F1 "select.sch" 60
$EndSheet
$Sheet
S 2500 1000 600  550 
U 4DFF84D5
F0 "CPU chip" 60
F1 "CPU chip.sch" 60
$EndSheet
$Sheet
S 1000 1000 600  550 
U 4DFF8367
F0 "ECB bus" 60
F1 "ECBbus.sch" 60
$EndSheet
$EndSCHEMATC
