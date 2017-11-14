;
; MDZ80 configuration file for sys7_offset_0000.bin
; Generated by MDZ80 V0.9.0 on 2015/09/23 23:42
;
c 0000-0043	; Code space
c 0044		; Unknown - assumed code space
c 0045-004E	; Code space
c 004F		; Unknown - assumed code space
c 0050-005E	; Code space
c 005F		; Unknown - assumed code space
c 0060-00B8	; Code space
i 00B9-00BA	; ignore data
c 00BB-0128	; Code space
i 0129-012A	; ignore data
c 012B-0212	; Code space
i 0213-0214	; ignore data
c 0215-0216	; Code space
t 0217-021B	; ASCII text
c 021C-02A3	; Code space
i 02A4-02AA	; ignore data
i 02AB		; ignore data
c 02AC-0308	; Code space
i 0309-030A	; ignore data
c 030B-0356	; Code space
c 0357		; Unknown - assumed code space
c 0358-040B	; Code space
i 040C-0411	; ignore data
i 0412		; ignore data
c 0413-0452	; Code space
c 0453		; Unknown - assumed code space
c 0454-0696	; Code space
t 0697-0699	; ASCII text
c 069A-06A9	; Code space
i 06AA-06AB	; ignore data
c 06AC-06B1	; Code space
t 06B2-06B6	; ASCII text
c 06B7		; Code space
b 06B8		; 8-bit data
i 06B9-06BC	; ignore data
i 06BD		; ignore data
c 06BE-06C9	; Code space
i 06CA-06CB	; ignore data
c 06CC-06DE	; Code space
i 06DF-06E0	; ignore data
c 06E1		; Code space
i 06E2-06E3	; ignore data
c 06E4-06E5	; Code space
c 06E6		; Unknown - assumed code space
c 06E7-07F7	; Code space
i 07F8-07F9	; ignore data
i 07FA		; ignore data
c 07FB-0C6F	; Code space
t 0C70-0C73	; ASCII text
c 0C74-0DD3	; Code space
i 0DD4-0DD8	; ignore data
i 0DD9		; ignore data
c 0DDA-1363	; Code space
i 1364-1366	; ignore data
i 1367		; ignore data
c 1368-137C	; Code space
i 137D-1381	; ignore data
i 1382		; ignore data
c 1383-139F	; Code space
i 13A0-13A1	; ignore data
c 13A2-147C	; Code space
t 147D-1482	; ASCII text
c 1483-158E	; Code space
i 158F-1590	; ignore data
i 1591		; ignore data
c 1592-1603	; Code space
b 1604-1607	; ignore data
w 1608-164f	; Code space
t 1650-181d	; ASCII text
c 181e-18c8	; Code space
t 18c9-18f8	; Code space
c 18f9-191d	; Code space
t 192D-1935	; ASCII text
c 1936-1980	; Code space
t 1981		; ASCII text
c 1982-1CA0	; Code space
t 1CA1-1CA3	; ASCII text
c 1CA4-2091	; Code space
i 2092-2099	; ignore data
i 209A		; ignore data
c 209B-2177	; Code space
t 2178-217C	; ASCII text
c 217D-2285	; Code space
t 2286-2293	; ASCII text
c 2294-2BFD	; Code space
i 2BFE-2C03	; ignore data
i 2C04		; ignore data
c 2C05-2C3C	; Code space
t 2C3D-2C3F	; ASCII text
c 2C40-2CA8	; Code space
c 2CA9		; Unknown - assumed code space
c 2CAA-2F44	; Code space
i 2F45-2F48	; ignore data
i 2F49		; ignore data
c 2F4A-3031	; Code space
c 3032		; Unknown - assumed code space
c 3033-303C	; Code space
i 303D-303E	; ignore data
i 303F		; ignore data
c 3040-3041	; Code space
i 3042		; ignore data
i 3043		; ignore data
c 3044-3060	; Code space
i 3061-3062	; ignore data
t 3063-3065	; ASCII text
c 3066-30D8	; Code space
t 30D9-30DB	; ASCII text
c 30DC-3135	; Code space
i 3136-3137	; ignore data
i 3138		; ignore data
c 3139-3173	; Code space
c 3174		; Unknown - assumed code space
c 3175-3185	; Code space
i 3186-3187	; ignore data
i 3188		; ignore data
c 3189-31F2	; Code space
i 31F3-31F4	; ignore data
i 31F5		; ignore data
c 31F6-3230	; Code space
i 3231-3232	; ignore data
s   60	blifastblok		; from Common.inc.asm
s   6a	blifastline		; from Common.inc.asm
s   40	blislowblok		; from Common.inc.asm
s   4a	blislowline		; from Common.inc.asm
s   4f	colbuf		; from Common.inc.asm
s   8c	crt6545adst		; from Common.inc.asm
s   8d	crt6545data		; from Common.inc.asm
s   8f	crtbeepport		; from Common.inc.asm
s   87	crtkeybcnt		; from Common.inc.asm
s   85	crtkeybdat		; from Common.inc.asm
s   83	crtprntcnt		; from Common.inc.asm
s   81	crtprntdat		; from Common.inc.asm
s   82	crtram0cnt		; from Common.inc.asm
s   80	crtram0dat		; from Common.inc.asm
s   86	crtram1cnt		; from Common.inc.asm
s   84	crtram1dat		; from Common.inc.asm
s   8a	crtram2cnt		; from Common.inc.asm
s   88	crtram2dat		; from Common.inc.asm
s   8e	crtram3port		; from Common.inc.asm
s   8b	crtservcnt		; from Common.inc.asm
s   89	crtservdat		; from Common.inc.asm
s   48	curpbuf		; from Common.inc.asm
s   4e	dselbf		; from Common.inc.asm
s  7cf	endvid		; from Common.inc.asm
s   1b	esc		; from Common.inc.asm
s   d0	fdccmdstatr		; from Common.inc.asm
s   d7	fdcdatareg		; from Common.inc.asm
s   d6	fdcdrvrcnt		; from Common.inc.asm
;s   88	fdcreadc		; from Common.inc.asm
;s   d0	fdcreset		; from Common.inc.asm
s   d2	fdcsectreg		; from Common.inc.asm
s   16	fdcseekc		; from Common.inc.asm
s   d1	fdctrakreg		; from Common.inc.asm
s   a8	fdcwritc		; from Common.inc.asm
s   45	fdrvbuf		; from Common.inc.asm
s   41	frdpbuf		; from Common.inc.asm
s   43	fsecbuf		; from Common.inc.asm
s   3f	fsekbuf		; from Common.inc.asm
s   46	ftrkbuf		; from Common.inc.asm
s   4d	kbdbyte		; from Common.inc.asm
s   4c	miobyte		; from Common.inc.asm
s   3b	ram0buf		; from Common.inc.asm
s   3c	ram1buf		; from Common.inc.asm
s   3d	ram2buf		; from Common.inc.asm
s   3e	ram3buf		; from Common.inc.asm
s   38	rst7sp1		; from Common.inc.asm
s   39	rst7sp2		; from Common.inc.asm
s   3a	rst7sp3		; from Common.inc.asm
s   4b	tmpbyte		; from Common.inc.asm
s  100	tpa		; from Common.inc.asm
s   13	xofc		; from Common.inc.asm
s   11	xonc		; from Common.inc.asm
