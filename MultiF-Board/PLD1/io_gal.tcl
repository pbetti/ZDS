
########## Tcl recorder starts at 04/26/14 16:43:51 ##########

set version "1.7"
set proj_dir "Y:/Z80-CPM/hardware/Z80DarkStar/MultiF-Board/PLD1"
cd $proj_dir

# Get directory paths
set pver $version
regsub -all {\.} $pver {_} pver
set lscfile "lsc_"
append lscfile $pver ".ini"
set lsvini_dir [lindex [array get env LSC_INI_PATH] 1]
set lsvini_path [file join $lsvini_dir $lscfile]
if {[catch {set fid [open $lsvini_path]} msg]} {
	 puts "File Open Error: $lsvini_path"
	 return false
} else {set data [read $fid]; close $fid }
foreach line [split $data '\n'] { 
	set lline [string tolower $line]
	set lline [string trim $lline]
	if {[string compare $lline "\[paths\]"] == 0} { set path 1; continue}
	if {$path && [regexp {^\[} $lline]} {set path 0; break}
	if {$path && [regexp {^bin} $lline]} {set cpld_bin $line; continue}
	if {$path && [regexp {^fpgapath} $lline]} {set fpga_dir $line; continue}
	if {$path && [regexp {^fpgabinpath} $lline]} {set fpga_bin $line}}

set cpld_bin [string range $cpld_bin [expr [string first "=" $cpld_bin]+1] end]
regsub -all "\"" $cpld_bin "" cpld_bin
set cpld_bin [file join $cpld_bin]
set install_dir [string range $cpld_bin 0 [expr [string first "ispcpld" $cpld_bin]-2]]
regsub -all "\"" $install_dir "" install_dir
set install_dir [file join $install_dir]
set fpga_dir [string range $fpga_dir [expr [string first "=" $fpga_dir]+1] end]
regsub -all "\"" $fpga_dir "" fpga_dir
set fpga_dir [file join $fpga_dir]
set fpga_bin [string range $fpga_bin [expr [string first "=" $fpga_bin]+1] end]
regsub -all "\"" $fpga_bin "" fpga_bin
set fpga_bin [file join $fpga_bin]

if {[string match "*$fpga_bin;*" $env(PATH)] == 0 } {
   set env(PATH) "$fpga_bin;$env(PATH)" }

if {[string match "*$cpld_bin;*" $env(PATH)] == 0 } {
   set env(PATH) "$cpld_bin;$env(PATH)" }

lappend auto_path [file join $install_dir "ispcpld" "tcltk" "lib" "ispwidget" "runproc"]
package require runcmd

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"io_gal.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/26/14 16:43:51 ###########


########## Tcl recorder starts at 04/26/14 16:49:51 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"io_gal.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/26/14 16:49:51 ###########


########## Tcl recorder starts at 04/26/14 17:00:30 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"2to4dec.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/26/14 17:00:30 ###########


########## Tcl recorder starts at 04/26/14 17:08:33 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"2to4dec.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/26/14 17:08:33 ###########


########## Tcl recorder starts at 04/26/14 17:12:57 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"2to4dec.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/26/14 17:12:57 ###########


########## Tcl recorder starts at 04/26/14 17:17:26 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"2to4dec.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/26/14 17:17:27 ###########


########## Tcl recorder starts at 04/26/14 17:21:57 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"2to4dec.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/26/14 17:21:57 ###########


########## Tcl recorder starts at 04/26/14 17:22:42 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"2to4dec.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/26/14 17:22:42 ###########


########## Tcl recorder starts at 04/26/14 17:31:25 ##########

# Commands to make the Process: 
# Compile Test Vectors
if [runCmd "\"$cpld_bin/ahdl2blf\" \"2to4dec.abv\" -vec -ovec \"2to4dec.tmv\" -sim io_gal  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/26/14 17:31:25 ###########


########## Tcl recorder starts at 04/26/14 17:33:22 ##########

# Commands to make the Process: 
# Compile Test Vectors
if [runCmd "\"$cpld_bin/ahdl2blf\" \"2to4dec.abv\" -vec -ovec \"2to4dec.tmv\" -sim io_gal  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/26/14 17:33:22 ###########


########## Tcl recorder starts at 04/26/14 17:33:50 ##########

# Commands to make the Process: 
# Compile Test Vectors
if [runCmd "\"$cpld_bin/ahdl2blf\" \"2to4dec.abv\" -vec -ovec \"2to4dec.tmv\" -sim io_gal  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/26/14 17:33:50 ###########


########## Tcl recorder starts at 04/26/14 17:34:52 ##########

# Commands to make the Process: 
# Compile Test Vectors
if [runCmd "\"$cpld_bin/ahdl2blf\" \"2to4dec.abv\" -vec -ovec \"2to4dec.tmv\" -sim io_gal  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/26/14 17:34:53 ###########


########## Tcl recorder starts at 04/26/14 17:35:51 ##########

# Commands to make the Process: 
# Compile Test Vectors
if [runCmd "\"$cpld_bin/ahdl2blf\" \"2to4dec.abv\" -vec -ovec \"2to4dec.tmv\" -sim io_gal  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/26/14 17:35:51 ###########


########## Tcl recorder starts at 04/26/14 17:36:35 ##########

# Commands to make the Process: 
# Compile Test Vectors
if [runCmd "\"$cpld_bin/ahdl2blf\" \"2to4dec.abv\" -vec -ovec \"2to4dec.tmv\" -sim io_gal  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/26/14 17:36:36 ###########


########## Tcl recorder starts at 04/26/14 17:36:45 ##########

# Commands to make the Process: 
# Functional Simulation
if [runCmd "\"$cpld_bin/sch2tf\" -template \"$install_dir/ispcpld/plsi/latsim/plsi.tft\" -prj io_gal -ext .lsi io_gal.sch "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/sch2blf\" -sup \"io_gal.sch\" -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"io_gal.bls\" -o \"io_gal.bl0\" -ipo -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" -i \"io_gal.bl0\" -o \"io_gal.blo\" -red bypin choose -sweep -collapse none -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"io_gal.blo\" -o \"io_gal.blh\" -omod io_gal -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"io_gal.blh\" -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" -i \"io_gal.bli\" -o \"io_gal.blj\" -idev PLSI -propadd -dev pla_basic -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Functional Simulation
if [catch {open simcp._sp w} rspFile] {
	puts stderr "Cannot create response file simcp._sp: $rspFile"
} else {
	puts $rspFile "simcp.pre1 -ini simcpls.ini -unit simcp.pre1
-cfg oaipldtg.fdk \"2to4dec.lts\" -map \"io_gal.lsi\"
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/simcp\" @simcp._sp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/26/14 17:36:45 ###########


########## Tcl recorder starts at 04/26/14 17:38:03 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"io_gal.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/26/14 17:38:03 ###########


########## Tcl recorder starts at 04/26/14 17:51:02 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"io_gal.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/26/14 17:51:02 ###########


########## Tcl recorder starts at 04/28/14 10:17:38 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"io_gal.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 10:17:38 ###########


########## Tcl recorder starts at 04/28/14 10:25:27 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"io_gal.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 10:25:27 ###########


########## Tcl recorder starts at 04/28/14 10:36:53 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"io_gal.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 10:36:53 ###########


########## Tcl recorder starts at 04/28/14 10:37:29 ##########

# Commands to make the Process: 
# Update All Schematic Files
if [runCmd "\"$cpld_bin/updatesc\" io_gal.sch -yield"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 10:37:29 ###########


########## Tcl recorder starts at 04/28/14 10:37:37 ##########

# Commands to make the Process: 
# Link Design
if [runCmd "\"$cpld_bin/sch2blf\" -sup \"io_gal.sch\" -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"io_gal.bls\" -o \"io_gal.bl0\" -ipo -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" -i \"io_gal.bl0\" -o \"io_gal.bl1\" -red bypin choose -sweep -collapse none -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"io_gal.bl1\" -o \"io_gal.bl2\" -omod io_gal -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 10:37:37 ###########


########## Tcl recorder starts at 04/28/14 10:37:48 ##########

# Commands to make the Process: 
# Linked Equations
if [runCmd "\"$cpld_bin/blif2eqn\" \"io_gal.bl2\" -o \"io_gal.eq2\" -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 10:37:48 ###########


########## Tcl recorder starts at 04/28/14 10:38:21 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" io_gal.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" io_gal.bl3 -pla -o io_gal.tt2 -dev p16v8 -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" io_gal.tt2 -dev p16v8 -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 10:38:21 ###########


########## Tcl recorder starts at 04/28/14 10:49:17 ##########

# Commands to make the Process: 
# Compile Test Vectors
if [runCmd "\"$cpld_bin/ahdl2blf\" \"io_gal.abv\" -vec -ovec \"io_gal.tmv\" -sim io_gal  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 10:49:17 ###########


########## Tcl recorder starts at 04/28/14 10:49:22 ##########

# Commands to make the Process: 
# Functional Simulation
if [runCmd "\"$cpld_bin/sch2tf\" -template \"$install_dir/ispcpld/plsi/latsim/plsi.tft\" -prj io_gal -ext .lsi io_gal.sch "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/sch2blf\" -sup \"io_gal.sch\" -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"io_gal.bls\" -o \"io_gal.bl0\" -ipo -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" -i \"io_gal.bl0\" -o \"io_gal.blo\" -red bypin choose -sweep -collapse none -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"io_gal.blo\" -o \"io_gal.blh\" -omod io_gal -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"io_gal.blh\" -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" -i \"io_gal.bli\" -o \"io_gal.blj\" -idev PLSI -propadd -dev pla_basic -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Functional Simulation
if [catch {open simcp._sp w} rspFile] {
	puts stderr "Cannot create response file simcp._sp: $rspFile"
} else {
	puts $rspFile "simcp.pre1 -ini simcpls.ini -unit simcp.pre1
-cfg oaipldtg.fdk \"io_gal.lts\" -map \"io_gal.lsi\"
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/simcp\" @simcp._sp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 10:49:23 ###########


########## Tcl recorder starts at 04/28/14 10:51:24 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"2to4dec.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 10:51:24 ###########


########## Tcl recorder starts at 04/28/14 10:52:02 ##########

# Commands to make the Process: 
# Update All Schematic Files
if [runCmd "\"$cpld_bin/updatesc\" io_gal.sch -yield"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/updatesc\" 2to4dec.sch -yield"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 10:52:02 ###########


########## Tcl recorder starts at 04/28/14 10:52:09 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"io_gal.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/sch2jhd\" \"2to4dec.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 10:52:09 ###########


########## Tcl recorder starts at 04/28/14 10:52:12 ##########

# Commands to make the Process: 
# Link Design
if [runCmd "\"$cpld_bin/sch2blf\" -sup \"io_gal.sch\" -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"io_gal.bls\" -o \"io_gal.bl0\" -ipo -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" -i \"io_gal.bl0\" -o \"io_gal.bl1\" -red bypin choose -sweep -collapse none -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/sch2blf\" -sup \"2to4dec.sch\" -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"2to4dec.bls\" -o \"2to4dec.bl0\" -ipo -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" -i \"2to4dec.bl0\" -o \"2to4dec.bl1\" -red bypin choose -sweep -collapse none -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"io_gal.bl1\" -o \"io_gal.bl2\" -omod io_gal -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 10:52:12 ###########


########## Tcl recorder starts at 04/28/14 10:52:19 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" io_gal.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" io_gal.bl3 -pla -o io_gal.tt2 -dev p16v8 -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" io_gal.tt2 -dev p16v8 -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 10:52:19 ###########


########## Tcl recorder starts at 04/28/14 10:52:37 ##########

# Commands to make the Process: 
# Compile Test Vectors
if [runCmd "\"$cpld_bin/ahdl2blf\" \"io_gal.abv\" -vec -ovec \"io_gal.tmv\" -sim io_gal  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 10:52:38 ###########


########## Tcl recorder starts at 04/28/14 10:52:43 ##########

# Commands to make the Process: 
# Functional Simulation
if [runCmd "\"$cpld_bin/sch2tf\" -template \"$install_dir/ispcpld/plsi/latsim/plsi.tft\" -prj io_gal -ext .lsi io_gal.sch "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" -i \"io_gal.bl0\" -o \"io_gal.blo\" -red bypin choose -sweep -collapse none -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" -i \"2to4dec.bl0\" -o \"2to4dec.blo\" -red bypin choose -sweep -collapse none -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"io_gal.blo\" -o \"io_gal.blh\" -omod io_gal -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"io_gal.blh\" -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" -i \"io_gal.bli\" -o \"io_gal.blj\" -idev PLSI -propadd -dev pla_basic -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Functional Simulation
if [catch {open simcp._sp w} rspFile] {
	puts stderr "Cannot create response file simcp._sp: $rspFile"
} else {
	puts $rspFile "simcp.pre1 -ini simcpls.ini -unit simcp.pre1
-cfg oaipldtg.fdk \"io_gal.lts\" -map \"io_gal.lsi\"
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/simcp\" @simcp._sp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 10:52:43 ###########


########## Tcl recorder starts at 04/28/14 10:58:41 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"io_gal.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 10:58:41 ###########


########## Tcl recorder starts at 04/28/14 10:59:00 ##########

# Commands to make the Process: 
# Update All Schematic Files
if [runCmd "\"$cpld_bin/updatesc\" io_gal.sch -yield"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 10:59:00 ###########


########## Tcl recorder starts at 04/28/14 10:59:07 ##########

# Commands to make the Process: 
# Link Design
if [runCmd "\"$cpld_bin/sch2blf\" -sup \"io_gal.sch\" -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"io_gal.bls\" -o \"io_gal.bl0\" -ipo -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" -i \"io_gal.bl0\" -o \"io_gal.bl1\" -red bypin choose -sweep -collapse none -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"io_gal.bl1\" -o \"io_gal.bl2\" -omod io_gal -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 10:59:07 ###########


########## Tcl recorder starts at 04/28/14 10:59:15 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" io_gal.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" io_gal.bl3 -pla -o io_gal.tt2 -dev p16v8 -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" io_gal.tt2 -dev p16v8 -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 10:59:15 ###########


########## Tcl recorder starts at 04/28/14 11:05:20 ##########

# Commands to make the Process: 
# Compile Test Vectors
if [runCmd "\"$cpld_bin/ahdl2blf\" \"io_gal.abv\" -vec -ovec \"io_gal.tmv\" -sim io_gal  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 11:05:20 ###########


########## Tcl recorder starts at 04/28/14 11:05:28 ##########

# Commands to make the Process: 
# Functional Simulation
if [runCmd "\"$cpld_bin/sch2tf\" -template \"$install_dir/ispcpld/plsi/latsim/plsi.tft\" -prj io_gal -ext .lsi io_gal.sch "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" -i \"io_gal.bl0\" -o \"io_gal.blo\" -red bypin choose -sweep -collapse none -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"io_gal.blo\" -o \"io_gal.blh\" -omod io_gal -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"io_gal.blh\" -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" -i \"io_gal.bli\" -o \"io_gal.blj\" -idev PLSI -propadd -dev pla_basic -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Functional Simulation
if [catch {open simcp._sp w} rspFile] {
	puts stderr "Cannot create response file simcp._sp: $rspFile"
} else {
	puts $rspFile "simcp.pre1 -ini simcpls.ini -unit simcp.pre1
-cfg oaipldtg.fdk \"io_gal.lts\" -map \"io_gal.lsi\"
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/simcp\" @simcp._sp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 11:05:28 ###########


########## Tcl recorder starts at 04/28/14 11:08:58 ##########

# Commands to make the Process: 
# Compile Test Vectors
if [runCmd "\"$cpld_bin/ahdl2blf\" \"io_gal.abv\" -vec -ovec \"io_gal.tmv\" -sim io_gal  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 11:08:59 ###########


########## Tcl recorder starts at 04/28/14 11:09:03 ##########

# Commands to make the Process: 
# Functional Simulation
# - none -
# Application to view the Process: 
# Functional Simulation
if [catch {open simcp._sp w} rspFile] {
	puts stderr "Cannot create response file simcp._sp: $rspFile"
} else {
	puts $rspFile "simcp.pre1 -ini simcpls.ini -unit simcp.pre1
-cfg oaipldtg.fdk \"io_gal.lts\" -map \"io_gal.lsi\"
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/simcp\" @simcp._sp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 11:09:03 ###########


########## Tcl recorder starts at 04/28/14 11:09:44 ##########

# Commands to make the Process: 
# Functional Simulation
# - none -
# Application to view the Process: 
# Functional Simulation
if [catch {open simcp._sp w} rspFile] {
	puts stderr "Cannot create response file simcp._sp: $rspFile"
} else {
	puts $rspFile "simcp.pre1 -ini simcpls.ini -unit simcp.pre1
-cfg oaipldtg.fdk \"io_gal.lts\" -map \"io_gal.lsi\"
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/simcp\" @simcp._sp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 11:09:44 ###########


########## Tcl recorder starts at 04/28/14 11:10:27 ##########

# Commands to make the Process: 
# Compile Test Vectors
if [runCmd "\"$cpld_bin/ahdl2blf\" \"io_gal.abv\" -vec -ovec \"io_gal.tmv\" -sim io_gal  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 11:10:27 ###########


########## Tcl recorder starts at 04/28/14 11:10:33 ##########

# Commands to make the Process: 
# Functional Simulation
# - none -
# Application to view the Process: 
# Functional Simulation
if [catch {open simcp._sp w} rspFile] {
	puts stderr "Cannot create response file simcp._sp: $rspFile"
} else {
	puts $rspFile "simcp.pre1 -ini simcpls.ini -unit simcp.pre1
-cfg oaipldtg.fdk \"io_gal.lts\" -map \"io_gal.lsi\"
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/simcp\" @simcp._sp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 11:10:33 ###########


########## Tcl recorder starts at 04/28/14 11:12:40 ##########

# Commands to make the Process: 
# Compile Test Vectors
if [runCmd "\"$cpld_bin/ahdl2blf\" \"io_gal.abv\" -vec -ovec \"io_gal.tmv\" -sim io_gal  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 11:12:41 ###########


########## Tcl recorder starts at 04/28/14 11:12:45 ##########

# Commands to make the Process: 
# Functional Simulation
# - none -
# Application to view the Process: 
# Functional Simulation
if [catch {open simcp._sp w} rspFile] {
	puts stderr "Cannot create response file simcp._sp: $rspFile"
} else {
	puts $rspFile "simcp.pre1 -ini simcpls.ini -unit simcp.pre1
-cfg oaipldtg.fdk \"io_gal.lts\" -map \"io_gal.lsi\"
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/simcp\" @simcp._sp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 11:12:45 ###########


########## Tcl recorder starts at 04/28/14 11:15:11 ##########

# Commands to make the Process: 
# Compile Test Vectors
if [runCmd "\"$cpld_bin/ahdl2blf\" \"io_gal.abv\" -vec -ovec \"io_gal.tmv\" -sim io_gal  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 11:15:11 ###########


########## Tcl recorder starts at 04/28/14 11:15:16 ##########

# Commands to make the Process: 
# Functional Simulation
# - none -
# Application to view the Process: 
# Functional Simulation
if [catch {open simcp._sp w} rspFile] {
	puts stderr "Cannot create response file simcp._sp: $rspFile"
} else {
	puts $rspFile "simcp.pre1 -ini simcpls.ini -unit simcp.pre1
-cfg oaipldtg.fdk \"io_gal.lts\" -map \"io_gal.lsi\"
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/simcp\" @simcp._sp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 11:15:16 ###########


########## Tcl recorder starts at 04/28/14 11:17:52 ##########

# Commands to make the Process: 
# Compile Test Vectors
if [runCmd "\"$cpld_bin/ahdl2blf\" \"io_gal.abv\" -vec -ovec \"io_gal.tmv\" -sim io_gal  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 11:17:52 ###########


########## Tcl recorder starts at 04/28/14 11:17:57 ##########

# Commands to make the Process: 
# Functional Simulation
# - none -
# Application to view the Process: 
# Functional Simulation
if [catch {open simcp._sp w} rspFile] {
	puts stderr "Cannot create response file simcp._sp: $rspFile"
} else {
	puts $rspFile "simcp.pre1 -ini simcpls.ini -unit simcp.pre1
-cfg oaipldtg.fdk \"io_gal.lts\" -map \"io_gal.lsi\"
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/simcp\" @simcp._sp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 11:17:57 ###########


########## Tcl recorder starts at 04/28/14 11:27:49 ##########

# Commands to make the Process: 
# Compile Test Vectors
if [runCmd "\"$cpld_bin/ahdl2blf\" \"io_gal.abv\" -vec -ovec \"io_gal.tmv\" -sim io_gal  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 11:27:49 ###########


########## Tcl recorder starts at 04/28/14 11:27:54 ##########

# Commands to make the Process: 
# Functional Simulation
# - none -
# Application to view the Process: 
# Functional Simulation
if [catch {open simcp._sp w} rspFile] {
	puts stderr "Cannot create response file simcp._sp: $rspFile"
} else {
	puts $rspFile "simcp.pre1 -ini simcpls.ini -unit simcp.pre1
-cfg oaipldtg.fdk \"io_gal.lts\" -map \"io_gal.lsi\"
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/simcp\" @simcp._sp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 11:27:54 ###########


########## Tcl recorder starts at 04/28/14 11:35:02 ##########

# Commands to make the Process: 
# Compile Test Vectors
if [runCmd "\"$cpld_bin/ahdl2blf\" \"io_gal.abv\" -vec -ovec \"io_gal.tmv\" -sim io_gal  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 11:35:03 ###########


########## Tcl recorder starts at 04/28/14 11:35:07 ##########

# Commands to make the Process: 
# Functional Simulation
# - none -
# Application to view the Process: 
# Functional Simulation
if [catch {open simcp._sp w} rspFile] {
	puts stderr "Cannot create response file simcp._sp: $rspFile"
} else {
	puts $rspFile "simcp.pre1 -ini simcpls.ini -unit simcp.pre1
-cfg oaipldtg.fdk \"io_gal.lts\" -map \"io_gal.lsi\"
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/simcp\" @simcp._sp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 11:35:07 ###########


########## Tcl recorder starts at 04/28/14 11:39:08 ##########

# Commands to make the Process: 
# Compile Test Vectors
if [runCmd "\"$cpld_bin/ahdl2blf\" \"io_gal.abv\" -vec -ovec \"io_gal.tmv\" -sim io_gal  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 11:39:08 ###########


########## Tcl recorder starts at 04/28/14 11:39:17 ##########

# Commands to make the Process: 
# Functional Simulation
# - none -
# Application to view the Process: 
# Functional Simulation
if [catch {open simcp._sp w} rspFile] {
	puts stderr "Cannot create response file simcp._sp: $rspFile"
} else {
	puts $rspFile "simcp.pre1 -ini simcpls.ini -unit simcp.pre1
-cfg oaipldtg.fdk \"io_gal.lts\" -map \"io_gal.lsi\"
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/simcp\" @simcp._sp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 11:39:17 ###########


########## Tcl recorder starts at 04/28/14 11:44:34 ##########

# Commands to make the Process: 
# Compile Test Vectors
if [runCmd "\"$cpld_bin/ahdl2blf\" \"io_gal.abv\" -vec -ovec \"io_gal.tmv\" -sim io_gal  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 11:44:34 ###########


########## Tcl recorder starts at 04/28/14 11:44:39 ##########

# Commands to make the Process: 
# Functional Simulation
# - none -
# Application to view the Process: 
# Functional Simulation
if [catch {open simcp._sp w} rspFile] {
	puts stderr "Cannot create response file simcp._sp: $rspFile"
} else {
	puts $rspFile "simcp.pre1 -ini simcpls.ini -unit simcp.pre1
-cfg oaipldtg.fdk \"io_gal.lts\" -map \"io_gal.lsi\"
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/simcp\" @simcp._sp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 11:44:39 ###########


########## Tcl recorder starts at 04/28/14 11:53:57 ##########

# Commands to make the Process: 
# Compile Test Vectors
if [runCmd "\"$cpld_bin/ahdl2blf\" \"io_gal.abv\" -vec -ovec \"io_gal.tmv\" -sim io_gal  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 11:53:57 ###########


########## Tcl recorder starts at 04/28/14 11:54:02 ##########

# Commands to make the Process: 
# Functional Simulation
# - none -
# Application to view the Process: 
# Functional Simulation
if [catch {open simcp._sp w} rspFile] {
	puts stderr "Cannot create response file simcp._sp: $rspFile"
} else {
	puts $rspFile "simcp.pre1 -ini simcpls.ini -unit simcp.pre1
-cfg oaipldtg.fdk \"io_gal.lts\" -map \"io_gal.lsi\"
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/simcp\" @simcp._sp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 11:54:02 ###########


########## Tcl recorder starts at 04/28/14 11:55:45 ##########

# Commands to make the Process: 
# Compile Test Vectors
if [runCmd "\"$cpld_bin/ahdl2blf\" \"io_gal.abv\" -vec -ovec \"io_gal.tmv\" -sim io_gal  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 11:55:45 ###########


########## Tcl recorder starts at 04/28/14 11:55:48 ##########

# Commands to make the Process: 
# Functional Simulation
# - none -
# Application to view the Process: 
# Functional Simulation
if [catch {open simcp._sp w} rspFile] {
	puts stderr "Cannot create response file simcp._sp: $rspFile"
} else {
	puts $rspFile "simcp.pre1 -ini simcpls.ini -unit simcp.pre1
-cfg oaipldtg.fdk \"io_gal.lts\" -map \"io_gal.lsi\"
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/simcp\" @simcp._sp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 11:55:49 ###########


########## Tcl recorder starts at 04/28/14 12:05:59 ##########

# Commands to make the Process: 
# Compile Test Vectors
if [runCmd "\"$cpld_bin/ahdl2blf\" \"io_gal.abv\" -vec -ovec \"io_gal.tmv\" -sim io_gal  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 12:05:59 ###########


########## Tcl recorder starts at 04/28/14 12:06:04 ##########

# Commands to make the Process: 
# Functional Simulation
# - none -
# Application to view the Process: 
# Functional Simulation
if [catch {open simcp._sp w} rspFile] {
	puts stderr "Cannot create response file simcp._sp: $rspFile"
} else {
	puts $rspFile "simcp.pre1 -ini simcpls.ini -unit simcp.pre1
-cfg oaipldtg.fdk \"io_gal.lts\" -map \"io_gal.lsi\"
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/simcp\" @simcp._sp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 12:06:04 ###########


########## Tcl recorder starts at 04/28/14 12:14:16 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"io_gal.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 12:14:16 ###########


########## Tcl recorder starts at 04/28/14 12:14:26 ##########

# Commands to make the Process: 
# Update All Schematic Files
if [runCmd "\"$cpld_bin/updatesc\" io_gal.sch -yield"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 12:14:26 ###########


########## Tcl recorder starts at 04/28/14 12:14:32 ##########

# Commands to make the Process: 
# Link Design
if [runCmd "\"$cpld_bin/sch2blf\" -sup \"io_gal.sch\" -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"io_gal.bls\" -o \"io_gal.bl0\" -ipo -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" -i \"io_gal.bl0\" -o \"io_gal.bl1\" -red bypin choose -sweep -collapse none -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"io_gal.bl1\" -o \"io_gal.bl2\" -omod io_gal -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 12:14:32 ###########


########## Tcl recorder starts at 04/28/14 12:14:39 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" io_gal.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" io_gal.bl3 -pla -o io_gal.tt2 -dev p16v8 -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" io_gal.tt2 -dev p16v8 -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 12:14:39 ###########


########## Tcl recorder starts at 04/28/14 12:14:55 ##########

# Commands to make the Process: 
# Functional Simulation
if [runCmd "\"$cpld_bin/sch2tf\" -template \"$install_dir/ispcpld/plsi/latsim/plsi.tft\" -prj io_gal -ext .lsi io_gal.sch "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" -i \"io_gal.bl0\" -o \"io_gal.blo\" -red bypin choose -sweep -collapse none -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"io_gal.blo\" -o \"io_gal.blh\" -omod io_gal -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"io_gal.blh\" -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" -i \"io_gal.bli\" -o \"io_gal.blj\" -idev PLSI -propadd -dev pla_basic -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Functional Simulation
if [catch {open simcp._sp w} rspFile] {
	puts stderr "Cannot create response file simcp._sp: $rspFile"
} else {
	puts $rspFile "simcp.pre1 -ini simcpls.ini -unit simcp.pre1
-cfg oaipldtg.fdk \"io_gal.lts\" -map \"io_gal.lsi\"
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/simcp\" @simcp._sp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 12:14:56 ###########


########## Tcl recorder starts at 04/28/14 12:16:16 ##########

# Commands to make the Process: 
# Timing Simulation
if [runCmd "\"$cpld_bin/sch2tf\" -template \"$install_dir/ispcpld/pld/j2mod.tft\" -prj io_gal -ext .btp io_gal.sch "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fuseasm\" io_gal.tt3 -dev p16v8 -o io_gal.jed -ivec io_gal.tmv -rep io_gal.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open io_gal.psl w} rspFile] {
	puts stderr "Cannot create response file io_gal.psl: $rspFile"
} else {
	puts $rspFile "-dev p16v8 -part LAT GAL16V8D-10LJ GAL -o io_gal.tim
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/timsel\" @io_gal.psl"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete io_gal.psl
if [catch {open io_gal._sp w} rspFile] {
	puts stderr "Cannot create response file io_gal._sp: $rspFile"
} else {
	puts $rspFile "#insert -- NOTE: Do not edit this file.
#insert -- Auto generated by Post-Route Verilog Simulation Models
#insert --
#unixpath
#unixpath $install_dir/ispcpld/pld/verilog
#libfile pldlib.v
#unixpath
#vlog \"$proj_dir/io_gal.vt\"
#insert -- End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" \"io_gal._sp\" \"io_gal.vtl\" none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete io_gal._sp
if [catch {open io_gal._sp w} rspFile] {
	puts stderr "Cannot create response file io_gal._sp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by Post-Route Verilog Simulation Models
#insert #
#unixpath
#unixpath $install_dir/ispcpld/pld/verilog
#libfile pldlib.v
#unixpath
#vlog \"$proj_dir/io_gal.vt\"
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" \"io_gal._sp\" \"io_gal.vatl\" none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete io_gal._sp
if [runCmd "\"$cpld_bin/j2sim\" io_gal.jed -dly custom io_gal.tim -pldbus default io_gal.btp -o io_gal.sim -module io_gal -suppress -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Timing Simulation
if [catch {open simcp._sp w} rspFile] {
	puts stderr "Cannot create response file simcp._sp: $rspFile"
} else {
	puts $rspFile "simcp.post1 -ini simcpls.ini -all simcp.post1
-cfg oaipldtg.fdk \"io_gal.lts\" -map \"io_gal.lsi\"
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/simcp\" @simcp._sp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 12:16:16 ###########


########## Tcl recorder starts at 04/28/14 12:17:03 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj io_gal -if io_gal.jed -j2s -log io_gal.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/28/14 12:17:03 ###########

