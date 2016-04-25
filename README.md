# ZDS

What you find here are all my stuff about Nuova Elettronica Z80. Software, ideas &amp; projects, both software and hardware.
See more at http://www.z80cpu.eu/projects/14-data-articles/116-z80ne-where-it-all-began

Microcomputer Z80 by Nuova Elettronica

The system consists of dedicated boards. Each card performs a specific function and all the main boards are connected on a propietary bus.
As i found out later, the original design of the system was effectively developed by a company called Micro Design of Genoa and not by Nuova Elettronica.
The orientation however, is to provide an educational system as evidenced by the basic system that consists of the CPU board and an hexadecimal keyboard.
The magazine, however, has introduced later a comprehensive set of additional hardware to allow the construction of a complete system of a level comparable to systems like S-100s or TRS-80 just for an example.
The kits provided by Nuova Elettronica were presented fairly quickly at the beginning and then slow down over time.
The whole system is developed, however, covering a period of considerably long time from 1979 to 1985, which is much greater in life expectancy then today's PC.
The decision to break up the presentation and furniture of the Z80NE hardware, worked well for both the magazine, interested in selling kits and so to maintains high the interest in his system, both for the users who can spread over time the costs (quite remarkable at the end) of buying the whole system and, at the same time, having the time to "assimilate" what the magazine continues to offer in terms of didactic information a kit after another.

The board design is sophisticated and robust, with low component density so to put even the less "technically savvy" people able to mount the components without errors (well... almost).
As to be noticed, not all the hardware presented can be used simultaneously, for example, there are two video interfaces, a low resolution and a hi-res which are mutually incompatible, as well as various memory cards that can only be used in certain configurations to obtain a maximum of up to 56K of RAM which is the limit for our computer. This is because the upper 4kbytes are used by the monitor and lower 4k of RAM (a single kbyte used actually) from E000H to EFFFH is reserved for the lo-res video card.
Another interesting case is the system monitor originally present on the CPU board, which maps 1kb of EPROM at address 8000H, thus blocking any expansion above 32k, chip that infact was removed almost immediately, and placed on the floppy interface card (mapped at F000H).

This apparent schizophrenic design is explained, over the time, with the intent to have a system that users can set up accordingly to their needs and interests.
Even if, i'm willing to bet that the most of them have brought their Z80NE to its maximum potential.
Many of these limitations can easily be overcome with small interventions, as we'll see later.

The system BUS is parallel, consisting of 48 lines divided on two single-in-line connectors of 24 pins each.
The connector "A" drives power (-12V, + 12V, + 5V) and all control signals of Z80 cpu including IEI, IEO pins that should established a daisy-chain interrupt priority between the cards according to the position of insertion, feature never used by Nuova Elettronica, while the connector "B" was dedicated to the address and data lines.

Normally, the power supply and the boards were enclosed in a 5U rack mount black case. This all-black style led me to give to my system the nickname of Z80Darkstar, for which you'll find references in the next articles.

For all details about every board and also original schematics and magazine articles, please, look here: http://www.z80ne.com/eng/hardware.asp
