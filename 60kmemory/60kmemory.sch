EESchema Schematic File Version 2
LIBS:power
LIBS:device
LIBS:switches
LIBS:relays
LIBS:motors
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:cmos4000
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:microcontrollers
LIBS:dsp
LIBS:microchip
LIBS:analog_switches
LIBS:motorola
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
LIBS:60kmemory-cache
EELAYER 25 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L 74LS20 U1
U 1 1 59F65591
P 3900 2650
F 0 "U1" H 3900 2750 50  0000 C CNN
F 1 "74LS20" H 3900 2550 50  0000 C CNN
F 2 "" H 3900 2650 50  0001 C CNN
F 3 "" H 3900 2650 50  0001 C CNN
	1    3900 2650
	1    0    0    -1  
$EndComp
$Comp
L 74LS20 U1
U 2 1 59F655FE
P 3900 3250
F 0 "U1" H 3900 3350 50  0000 C CNN
F 1 "74LS20" H 3900 3150 50  0000 C CNN
F 2 "" H 3900 3250 50  0001 C CNN
F 3 "" H 3900 3250 50  0001 C CNN
	2    3900 3250
	1    0    0    -1  
$EndComp
$Comp
L C C1
U 1 1 59F6580B
P 2650 2450
F 0 "C1" H 2675 2550 50  0000 L CNN
F 1 "100nF" H 2675 2350 50  0000 L CNN
F 2 "" H 2688 2300 50  0001 C CNN
F 3 "" H 2650 2450 50  0001 C CNN
	1    2650 2450
	1    0    0    -1  
$EndComp
Text GLabel 2300 3100 0    60   Input ~ 0
A12
Text Notes 2050 3000 0    60   ~ 0
Connettore B
Text Notes 1700 3150 0    60   ~ 0
Pin 13
Text GLabel 2300 3200 0    60   Input ~ 0
A13
Text Notes 1700 3250 0    60   ~ 0
Pin 14
Text GLabel 2300 3300 0    60   Input ~ 0
A14
Text Notes 1700 3350 0    60   ~ 0
Pin 15
Text GLabel 2300 3400 0    60   Input ~ 0
A15
Text Notes 1700 3450 0    60   ~ 0
Pin 16
Wire Wire Line
	2300 3100 3300 3100
Wire Wire Line
	2300 3200 3300 3200
Wire Wire Line
	2300 3300 3300 3300
Wire Wire Line
	2300 3400 3300 3400
Text GLabel 2300 2150 0    60   Input ~ 0
+5V
Text Notes 2050 2050 0    60   ~ 0
Connettore A
Text Notes 1500 2200 0    60   ~ 0
Pin 12-13
Text GLabel 2300 2250 0    60   Input ~ 0
GND
Text Notes 1500 2300 0    60   ~ 0
Pin 14-15
$Comp
L GND #PWR?
U 1 1 59F6C914
P 2650 2650
F 0 "#PWR?" H 2650 2400 50  0001 C CNN
F 1 "GND" H 2650 2500 50  0000 C CNN
F 2 "" H 2650 2650 50  0001 C CNN
F 3 "" H 2650 2650 50  0001 C CNN
	1    2650 2650
	1    0    0    -1  
$EndComp
Wire Wire Line
	2650 2600 2650 2650
Wire Wire Line
	2450 2650 3300 2650
Wire Wire Line
	3300 2500 3300 2800
Connection ~ 3300 2600
Connection ~ 3300 2700
Wire Wire Line
	2300 2250 2450 2250
Wire Wire Line
	2450 2250 2450 2650
Connection ~ 2650 2650
Wire Wire Line
	2300 2150 3000 2150
Wire Wire Line
	2650 2150 2650 2300
$Comp
L +5V #PWR?
U 1 1 59F6CA55
P 3000 2150
F 0 "#PWR?" H 3000 2000 50  0001 C CNN
F 1 "+5V" H 3000 2290 50  0000 C CNN
F 2 "" H 3000 2150 50  0001 C CNN
F 3 "" H 3000 2150 50  0001 C CNN
	1    3000 2150
	1    0    0    -1  
$EndComp
Connection ~ 2650 2150
Text GLabel 4600 3250 2    60   Input ~ 0
Pin2
Wire Wire Line
	4500 3250 4600 3250
Text Notes 4500 3150 0    60   ~ 0
74LS139 (IC10)
NoConn ~ 4500 2650
$EndSCHEMATC
