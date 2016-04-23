	$lines

	REM XAMN Disk track and sector editor.
	REM No warranty is made, expressed, or implied.
	REM ----------------------------------------------------
	REM Additional modifications 6/5/85 by S. Mitchell
	REM to permit lower case input in response to menu
	REM prompt, to advise user on exit procedure, and
	REM and to correct misspellings in menu.
	rem
	rem Further modifications 4/25/86 by Stephen Mitchell
	rem to permit lower case file name input, to ask for drive
	rem letter rather than drive number, and to change exit
	rem command to allow exit on either a '0' or the ESCape key
        rem rather than control-C.
	rem
	rem Further modifications 10/15/87 to force put_sector
	rem to write to disk, which it would not always do on
	rem Kaypro because of deblocking algorithm.
	REM ----------------------------------------------------

	var	hl,de,bc,a_psw	; cpu registers
		dph		; location of disk parameter header
		block_size	; cp/m logical block size
		max_tracks	; number of tracks/disk
		seldsk		; bios select disk
		settrk		; bios set track routine
		setsec		; bios set sector routine
		setdma		; bios set dma address
		b_read		; bios read sector
		b_write		; bios write sector
		sectran		; bios sector skew
		disk_number	; disk number to examine
		= integer

	var	crt		; logical device
		list		; logical device
		CR		; ASCII CR
		BS		; ASCII BS
		ascii_mask	; ASCII mask
		bit_0_mask	; mask used to look at bit 0
		true, false	; true/false logical flags
		= integer

	var	menu_selection	; prompt return
		disk_letter	; disk drive to examine
		= char

	var	r1, r2, r3, r4	; Real number for computations
		= real

	based	spt		; sectors/track
		dsm		; max data block number
		drm		; number of dir blocks
		off		; number of reserved tracks
		wboot		; entry to bios
		dpb		; location of disk parameter block
		skew_table	; location of bios skew table (used by sectran)
		alv		; pointer to allocation table
		= integer

	based	bsh		; block shift factor
		blm		; block mask
		exm		; extent mask
		alloc_byte	; used in searching allocation table
		= byte


	crt = 0				rem S-BASIC device # for con:
	list = 1			rem S-BASIC device # for lst:
	CR = 0DH
	BS = 8
	ascii_mask = 007FH
	bit_0_mask = 1
	true = -1
	false = not true

	base wboot at 1			rem location of bios wboot entry
	seldsk = wboot + 0018H		rem set up bios entry address
	settrk = wboot + 001BH
	setsec = wboot + 001EH
	setdma = wboot + 0021H
	b_read = wboot + 0024H
	b_write= wboot + 0027H
	sectran= wboot + 002DH

	rem dma buffer for read/write sector operations
	dim byte sector(128)
	var loc_sector = integer
	location array loc_sector = sector
	dim base char file_chars(11) fcb_name(11)  byte_dm(15)
	dim base integer word_dm(7)

	based bios_return = byte	rem high order byte of a_psw
	location var hl = a_psw
	base bios_return at hl+1

	function upcase(ch = char) = char
   		if ch >= 'a' and ch <= 'z' \
   		then ch = chr(asc(ch) - 32)
	end = ch

	function DiskNum(letter = char) = integer
		var num = integer
		letter = upcase(letter)
		num = asc(letter) - 65
	end = num

	function allcaps(source = string : 80) = string
	rem  Converts string to all upper case characters
   		var p = integer
   		for p = 1 to len(source) do
   		mid(source,p,1) = upcase(mid(source,p,1))
   		next p
	end = source

0seldsk	input "Which disk drive (A, B, C ... )";disk_letter
	disk_number = DiskNum(disk_letter)
	bc = disk_number
	call ( seldsk, dph, de, bc, a_psw )
	if dph=0 then 0seldsk
	base skew_table at dph
	base dpb at dph+10
	base alv at dph+14
	bc = loc_sector+1
	call ( setdma, hl, de, bc, a_psw )

	base spt at dpb
	base bsh at dpb+2
	base blm at dpb+3
	base exm at dpb+4
	base dsm at dpb+5
	base drm at dpb+7
	base off at dpb+13

	block_size = 1024*(2^(bsh-3))
	r1 = ((dsm+1)*(block_size/128))/spt
	max_tracks = r1 + off

	function physical_sec ( sectr = integer ) = integer
		if skew_table=0 then sectr=sectr-1
	end = sectr

	function skew ( sectr = integer ) = integer
		if skew_table<>0 then begin
			bc = sectr - 1
			de = skew_table
			call (sectran, hl, de, bc, a_psw)
			end
		    else hl = sectr - 1
	end = hl

	procedure get_sector( track, sec = integer )
		var x = integer
		for x=1 to 128
		  sector[x] = 0
		next x
		bc = track
		call ( settrk, hl, de, bc, a_psw )
		bc = sec
		call ( setsec, hl, de, bc, a_psw )
		call ( b_read, hl, de, bc, a_psw )
		sector[0] = bios_return
	end of get_sector

	procedure put_sector( track, sec = integer )
		var i = integer
		bc = track
		call ( settrk, hl, de, bc, a_psw )
		bc = sec
		call ( setsec, hl, de, bc, a_psw )
		bc = 1		rem force write
		call ( b_write, hl, de, bc, a_psw )
		sector[0] = bios_return
	end of put_sector

	function ascii_character ( x = integer ) = char
	  x = x and ascii_mask
	  if x<32 then x = 46
	end = x

	procedure display_sector  ( device = integer )
		var x, j = integer
		for x=1 to 128 step 16
			print hex$(x-1);"  ";
			for j=0 to 15
			  if j=8 then print ' ';
			  print #device; right$(hex$(sector[x+j]),2);' ';
			next hex byte
			for j=0 to 15
			  if j=8 then print ' ';
			  print #device; ascii_character(sector[x+j]);
			next ascii byte
			print #device
		next line of sector display
	end of display sector

0menu	print
	print
	print	"Drive number ...............";disk_number, "Current disk ";'A'+disk_number;':'
	print	"Sectors/track ..............";spt, '['; hex$(spt) ;']'
	print	"Tracks/Disk ................";max_tracks, '['; hex$(max_tracks) ;']',\
"XAMN Disk editor"
	print	"Number of reserved tracks ..";off, '['; hex$(off) ;']',\
"Version 1.1c"
	print	"# of logical blocks ........";dsm+1, '['; hex$(dsm+1) ;']'
	print	"# of directory entries .....";drm+1, '['; hex$(drm) ;']'
	print	"Block size .................";block_size, '['; hex$(block_size) ;']'
	print	"128 byte sectors/block .....";block_size/128, '['; hex$(block_size/128) ;']'
	print	"Disk size in K .............";(dsm+1)*(2^(bsh-3)), '['; hex$( (dsm+1)*(2^(bsh-3)) ) ;']'

	text 0,%
							Help
		Examine a sector (physical)........ 1	 A
		Examine a sector (logical skew).... 2	 B
		Move Sectors ...................... 3	 C
		Produce a map of a file ........... 4	 D
		Produce a map of disk ............. 5	 E
		Find bad sectors .................. 6	 F
		Compute Block from Trk & Sec ...... 7	 G
		Compute Trk & Sec from Block ...... 8	 H
		Select disk ....................... 9	 I
		Exit this program ................. 0 or ESC

%
	input2 "Please enter selection ==>"; menu_selection
	menu_selection = upcase(menu_selection)

	var track, sectr =integer
	var letter = char

	function group ( trk, sec = integer ) = integer
		var sectrs, grp = real
		sectrs = ((trk-off)*spt)+sec-1
		grp = sectrs/(block_size/128)
	end = grp

	procedure trk_sec ( grp = integer ) = integer
		var sectrs, sec, trk = real
		sectrs = grp*(block_size/128)
		trk = sectrs/spt
		track = trk + off
		sec = sectrs-((track-off)*spt)
		sectr = sec + 1
	end

	procedure bump ( amount = integer )
		sectr = sectr + amount
		if sectr>spt then begin
			track = track +1
			if track>=max_tracks then track=max_tracks-1
			sectr = 1
			end
		if sectr<1 then begin
			track = track -1
			if track<0 then track=0
			sectr = spt
			end
	end of bump

	procedure dump_physical ( device = integer )
	    get_sector track, physical_sec(sectr)
	    print #device; "Track=";track; "  Physical sector=";sectr, \
		" Logical sector=";skew(sectr);
	    if sector[0]=1 then print #device; " {BAD}" else print #device
	    display_sector device
	    print
	end of dump_physical

	procedure dump_logical ( device = integer )
	    get_sector track, skew(sectr)
	    print #device; "Track=";track; "   Logical sector=";sectr, \
		" Physical sector=";skew(sectr);
	    if sector[0]=1 then print #device; " {BAD}" else print #device
	    display_sector device
	    print
	end of dump_logical

	function hex_byte ( c = char ) = char
		c = c-'0'
		if c>9 then c=c-7
	end = c

	procedure modify ( t, s = integer )
	var c=char
	var x=integer
	repeat begin
		x=1
		repeat begin
			print hex$(x-1) ;' '; right$(hex$(sector[x]),2) ;' ';\
				ascii_character(sector[x]);' ';
			input3 c
			if c<>'.' and c<>CR and c<>BS then begin
				sector[x]=hex_byte(c)
				input3 c
				if c<>'.' and c<>CR and c<>BS then 
					sector[x]=(sector[x]*16)+hex_byte(c)
				end
			if c='.' then x=128
			if c=BS then begin
				x = x-2
				if x<0 then x=0
				end
			if c=CR and x=128 then x=127
			print
			x=x+1
		end until x>128
		print
		print t,s
		display_sector crt
		repeat begin
			print
			input "(W)rite to disk, (C)hange more bytes, (A)bort ";c
			c = upcase(c)
			if c='W' then begin
				print "Writing sector to disk..."
				put_sector t, s
				if sector[0]=1 then begin
					input2 "Write fault. <ret> to continue";c
					print
					display_sector crt
					c=' '
					end
				    else
					c='A'
				end of write
		end until c='A' or c='C'
	end until c='A'
	end of procedure modify

	$page
	case menu_selection of
'1':	begin
	    input "Track, sectr"; track, sectr
	    print
	    dump_physical crt
	    repeat begin
		input "(F)oward, (B)ackward, (R)ange, (C)hange, (E)xit ";letter
		letter = upcase(letter)
		case letter of
		    'F': begin
			     bump 1
			     dump_physical crt
			     end
		    'B': begin
			     bump -1
			     dump_physical crt
			     end
		    'R': begin
				var s, c, device =integer
				input "Number of sectors to display";c
				device = crt
				for s=1 to c
				    dump_physical device
				    bump 1
				next Sector
			end of 'R'
		    'C': modify track, physical_sec(sectr)
		    end of case
		end until letter='E'
	    end of option #1
'2':	begin
	    input "Track, sectr"; track, sectr
	    print
	    dump_logical crt
	    repeat begin
		input "(F)oward, (B)ackward, (R)ange, (C)hange, (E)xit ";letter
		letter = upcase(letter)
		case letter of
		    'F': begin
			     bump 1
			     dump_logical crt
			     end
		    'B': begin
			     bump -1
			     dump_logical crt
			     end
		    'R': begin
				var s, c, device =integer
				input "Number of sectors to display";c
				device = crt
				for s=1 to c
				    dump_logical device
				    bump 1
				next Sector
			end of 'R'
		    'C': modify track, skew(sectr)
		    end of case
		end until letter='E'
	    end of option #2
'3':	begin
		var t = char
		repeat begin
		t = ' '
		while t<>'L' and t<>'P' and t<>'E' do
			input "Move (L)logical sectors, (P)hysical sectors, (E)xit ";t
		t = upcase(t)
		if t<>'E' then begin
			var ok = char
			var trk1, trk2, sec1, sec2, cnt, x = integer
			ok = ' '
			while ok<>'Y' and ok<>'A' do begin
				input "Source Track, Sector ";trk1, sec1
				input "Dest. Track, Sector  ";trk2, sec2
				input "Number of sectors to move";cnt
				print
				print "Source Track, Sector = ";trk1, sec1
				print "Dest. Track, Sector  = ";trk2, sec2
				print "Number of sectors to move ";cnt
				print
				input "Is the above correct (Y/N/(A)bort) ";ok
				ok = upcase(ok)
				end
			if ok<>'A' then begin
				for x=1 to cnt
					print "Reading track";trk1;" Sector";sec1;
					if t='L' then print " Physical #";skew(sec1);
					if t='P' then get_sector trk1, physical_sec(sec1)
					    else get_sector trk1, skew(sec1)
					if sector[0]<>0 then print " Fault" else print

					print "Writing track";trk2;" Sector";sec2;
					if t='L' then print " Physical #";skew(sec2);
					if t='P' then put_sector trk2, physical_sec(sec2)
					    else put_sector trk2, skew(sec2)
					if sector[0]<>0 then print " Fault" else print

					track = trk1
					sectr = sec1
					bump 1
					trk1 = track
					sec1 = sectr
					track = trk2
					sectr = sec2
					bump 1
					trk2 = track
					sec2 = sectr
				next sector
				end
			end
		end until t='E'
	end of option #3
'4':	begin
		var count	; number of sectors to search
				= integer
		var file_name	; file name to search for
				= string:12
		location var count=file_name
		locate file_chars at count
		track = off		rem starting track
		sectr = 1		rem starting sector
		input "File name (<Ret> only to skip) ";file_name
		file_name = allcaps(file_name)
		if len(file_name)>0 then begin

			function match = integer
				var result, x = integer
				result = true
				if fcb_name[0]=0E5H then result=false else
				for x=1 to 11
					if file_chars[x]<>(fcb_name[x]) and file_chars[x]<>'?' \
						then result = false
				next x
			end = result

			procedure dump_fcb( device = integer )
				var x = integer
				print #device; "Track";track; " Sector";sectr; ' ';
				for x=1 to 11
					print #device; fcb_name[x];
				next x
				print #device; ' ';
				if dsm>255 then
					for x=0 to 7
					    print #device; hex$(word_dm[x]); ' ';
					next x
				    else
					for x=0 to 15
					    print #device; right$( hex$(byte_dm[x]),2 ); ' ';
					next x
				print #device
			end

			file_name = fcb$( file_name )
			print "Search for file:";file_name
			for count = 1 to (drm+1)/4
				get_sector track, skew(sectr)
				print "Searching Track:";track; " Sector:";skew(sectr);"      ";chr(0DH);
				locate fcb_name at loc_sector+1
				locate byte_dm at loc_sector+17
				locate word_dm at loc_sector+17
				if match then dump_fcb crt
				locate fcb_name at loc_sector+33
				locate byte_dm at loc_sector+49
				locate word_dm at loc_sector+49
				if match then dump_fcb crt
				locate fcb_name at loc_sector+65
				locate byte_dm at loc_sector+81
				locate word_dm at loc_sector+81
				if match then dump_fcb crt
				locate fcb_name at loc_sector+97
				locate byte_dm at loc_sector+113
				locate word_dm at loc_sector+113
				if match then dump_fcb crt
				bump 1
			next directory sector
			var x=char
			print
			input2 "Press <Ret> to continue";x
			end
	end of option #4
'5':	begin
		function bin( x = integer ) = string
			var bits = string:8
			var y = integer
			bits = ""
			for y=1 to 8
				if x and bit_0_mask then bits="1"+bits else
					bits="0"+bits
				x=x/2
			next y
		end = bits

		bc = 14
		de = disk_number
		call(5,hl,de,bc,a_psw)	rem bdos seldsk function
		var x, y = integer
		print
		for x = 0 to (dsm/8) step 8
			print hex$(x*8);": ";
			for y = 0 to 7
			    if x+y<=(dsm/8) then begin
				base alloc_byte at alv+x+y
				print bin(alloc_byte);' ';
				end
			next y
			print
		next x
		print "Last block is";dsm+1,'[';hex$(dsm+1);']'
		input2 "Press return to cont.";x
	end of option #5
'6':	begin
		var x = real
		var t1, t2 = integer
		input "Starting track, last track ";t1,t2
		track = t1
		sectr = 1
		for x = 1 to (t2-t1+1)*spt
			print "Track:";track; " Sector:";sectr; "  ";
			get_sector track, physical_sec(sectr)
			if sector[0]<>0 then print "{BAD}" else print chr(0DH);
			bump 1
		next x
		print
		input2 "Read complete, press <Ret> to cont.";x
	end of option #6
'7':	begin
		input "Track, Sector ";track,sectr
		print "Group #";group(track,sectr), hex$(group(track,sectr))
		input "Press <Ret> to cont. ";track
	end of #7
'8':	begin
		var x = integer
		input "Group number (add H if hex)";x
		trk_sec x
		print "Track:";track,"Sector:";sectr
		input "Press <Ret> to cont.";x
	end of #8

	end of function number menu selection

	if menu_selection = '9' then 0seldsk

	case menu_selection of
'A':	begin
	    text 0,%
        	To examine a physical sector use this command.  Sectors are 
        numbered from 1 to the end of the track. Tracks are numbered from 0 
        to the end of the disk. The physical sector number displayed is the 
        sector number from 1 to end of track,  the logical sector number is 
        the number your BIOS uses to access this physical sector.
        	When  you type this command you will be asked for the track 
        and sector you wish to examine.  After you respond the sector  will 
        be displayed. You will then be asked if you want to move forward or 
        backward from your current position on the disk.  You may,  at this 
        time,  specify  a range of sectors to be displayed from the current 
        position on the disk.  You may also edit the sector making  changes 
        to it in an buffer internal to XAMN. And last but not least you can 
        exit  to the main menu.  Each option is selected by one key  press. 
        The letters are F, B, R, C, and E.
        	When  changing  a sector the sector address in hex will  be 
        displayed  along  with the hex contents of the byte and  the  ASCII 
        character it represents (Period if none). To enter a new value type 
        it in,  to move forward push return,  backward push back space, and 
        to exit push period. Upon exit you may re-edit, write the sector to 
        the disk, or abort leaving the sector on the disk un-changed.
	%
	input2 "Press <Ret> to cont.";track
	end of 'A'
'B':	begin
	    text 0,%
        	Use  this  command  to examine and  edit  logical  sectors. 
        Logical  sectors  are  the sectors that the  BDOS  refers  to,  the 
        physical sector number may be different. It is the physical sectors 
        that the BIOS access.
        	For more info see 'A' above.
	%
	input2 "Press <Ret> to cont.";track
	end of 'B'
'C':	begin
	    text 0,%
        	This command is used to move sectors around on the disk. It 
        can be used to move physical sectors or logical sectors around. The 
        main purpose for moving sectors around is to allow re-formatting of 
        a track on the disk.  First, move the data on the track you wish to 
        re-format to an unused  area of the disk. This area can be found by 
        generating a map of the disk using another of XAMN's commands  (Map 
        disk,  see also help 'E').  Second, exit XAMN and using your system 
        format utility format ONLY the track with the bad sector.  Re-enter 
        XAMN. Third, move the data back onto the track.
        	This command will start by asking you if this is a physical 
        move or a logical move (use logical if you want to move CP/M groups 
        around).  You can exit at this point.  Next,  you will be asked for 
        the  starting  track and sector number,  the destination track  and 
        sector and the number of sectors to move.
        	BEFORE  each sector is read or written you will be told  of 
        it,  if  an error occurs you can see where it  happens.  AFTER  the 
        operation  the  program will move on to the next sector if  all  is 
        well or print "Fault" to show a read or write error.
	%
	input2 "Press <Ret> to cont.";track
	end of 'C'
'D':	begin
	    text 0,%
        	This command generates a map of a file showing all the CP/M 
        groups  assigned  to that file.  It also reports on  the  directory 
        sectors  that contain that file's FCB.  As each directory sector is 
        searched a report of that operation is made sector by sector.
	%
	input2 "Press <Ret> to cont.";track
	end of 'D'
'E':	begin
	    text 0,%
        	This command generated a disk map showing allocated groups. 
        A 0 is an empty group,  un-used by any file.  A 1 is a group in use 
        by a file. WARNING: this command makes a BDOS disk select call.
        	At the end of the map a few groups that do not exist may be 
        displayed  as  empty.  This is because the disk map is made  up  of 
        bytes where each bit in the byte is a group,  the last byte in  the 
        map may not be fully used up.  At the end of the map the last group 
        number is given, use this number.
        	This command can be used to find unused disk space. 
	%
	input2 "Press <Ret> to cont.";track
	end of 'E'
'F':	begin
	    text 0,%
        	This command is used to find a bad sector.  It will ask for 
        a  starting track and an ending track.  As it reads each track  and 
        sector  it  will  report  its progress.  Any bad  sectors  will  be 
        reported.
	%
	input2 "Press <Ret> to cont.";track
	end of 'F'
'G':	begin
	    text 0,%
        	Use  this  command  to  compute a  group  number  from  the 
        LOGICAL  track and sector.  Remember that  logical groups start  in 
        the directory, NOT in the reserved, or 'OFF' tracks.
	%
	input2 "Press <Ret> to cont.";track
	end of 'G'
'H':	begin
	    text 0,%
        	Use  this command to compute the track and  LOGICAL  sector 
        number for a given group.
	%
	input2 "Press <Ret> to cont.";track
	end of 'H'
'I':	begin
	    text 0,%
        	Use  this command to select another disk. XAMN commands are 
        in reference to the current disk number (see the display above  the 
        menu).
	%
	input2 "Press <Ret> to cont.";track
	end of 'I'
	end of help case statement

	if menu_selection = '0' or menu_selection = 1BH then stop

	goto 0menu
