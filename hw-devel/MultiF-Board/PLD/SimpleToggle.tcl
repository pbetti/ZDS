
########## Tcl recorder starts at 06/14/14 19:47:56 ##########

set version "1.7"
set proj_dir "Y:/Z80-CPM/hardware/Z80DarkStar/MultiF-Board/PLD"
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
if [runCmd "\"$cpld_bin/sch2jhd\" \"simpletoggle.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 19:47:56 ###########


########## Tcl recorder starts at 06/14/14 19:49:28 ##########

# Commands to make the Process: 
# Update All Schematic Files
if [runCmd "\"$cpld_bin/updatesc\" simpletoggle.sch -yield"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 19:49:28 ###########


########## Tcl recorder starts at 06/14/14 19:49:46 ##########

# Commands to make the Process: 
# Link Design
if [runCmd "\"$cpld_bin/sch2blf\" -sup \"simpletoggle.sch\" -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"simpletoggle.bls\" -o \"simpletoggle.bl0\" -ipo -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" -i \"simpletoggle.bl0\" -o \"simpletoggle.bl1\" -red bypin choose -sweep -collapse none -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"simpletoggle.bl1\" -o \"simpletoggle.bl2\" -omod simpletoggle -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 19:49:46 ###########


########## Tcl recorder starts at 06/14/14 19:50:01 ##########

# Commands to make the Process: 
# Linked Equations
if [runCmd "\"$cpld_bin/blif2eqn\" \"simpletoggle.bl2\" -o \"simpletoggle.eq2\" -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 19:50:02 ###########


########## Tcl recorder starts at 06/14/14 19:50:11 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" simpletoggle.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" simpletoggle.bl3 -pla -o simpletoggle.tt2 -dev p16v8 -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" simpletoggle.tt2 -dev p16v8 -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 19:50:11 ###########


########## Tcl recorder starts at 06/14/14 19:53:32 ##########

# Commands to make the Process: 
# ABEL Test Vector Template
if [runCmd "\"$cpld_bin/blif2eqn\" \"simpletoggle.bl0\" -o \"simpletoggle.abt\" -testfix -template \"$install_dir/ispcpld/plsi/abel/plsiabt.tft\" -prj simpletoggle -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 19:53:33 ###########


########## Tcl recorder starts at 06/14/14 19:53:40 ##########

# Commands to make the Process: 
# Verilog Test Fixture Declarations
if [runCmd "\"$cpld_bin/sch2tf\" -template \"$install_dir/ispcpld/generic/verilog/tfi.tft\" -prj simpletoggle simpletoggle.sch "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 19:53:41 ###########


########## Tcl recorder starts at 06/14/14 19:53:46 ##########

# Commands to make the Process: 
# Verilog Test Fixture Template
if [runCmd "\"$cpld_bin/sch2tf\" -template \"$install_dir/ispcpld/generic/verilog/tft.tft\" -prj simpletoggle -ext .tft simpletoggle.sch "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 19:53:46 ###########


########## Tcl recorder starts at 06/14/14 19:53:53 ##########

# Commands to make the Process: 
# VHDL Test Bench Template
if [runCmd "\"$cpld_bin/vhdl\" -tsimpletoggle.vht -s simpletoggle.sch"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 19:53:53 ###########


########## Tcl recorder starts at 06/14/14 19:54:02 ##########

# Commands to make the Process: 
# Reduced Equations
if [runCmd "\"$cpld_bin/blif2eqn\" \"simpletoggle.bl1\" -o \"simpletoggle.eq1\" -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 19:54:02 ###########


########## Tcl recorder starts at 06/14/14 19:54:56 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/ahdl2blf\" \"simpletoggle.abv\" -vec -ovec \"simpletoggle.tmv\"  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fuseasm\" simpletoggle.tt3 -dev p16v8 -o simpletoggle.jed -ivec simpletoggle.tmv -rep simpletoggle.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj simpletoggle -if simpletoggle.jed -j2s -log simpletoggle.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 19:54:56 ###########


########## Tcl recorder starts at 06/14/14 19:55:05 ##########

# Commands to make the Process: 
# Verilog Post-Route Simulation Model
if [runCmd "\"$cpld_bin/sch2tf\" -template \"$install_dir/ispcpld/pld/j2mod.tft\" -prj simpletoggle -ext .btp simpletoggle.sch "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open simpletoggle.psl w} rspFile] {
	puts stderr "Cannot create response file simpletoggle.psl: $rspFile"
} else {
	puts $rspFile "-dev p16v8 -part LAT GAL16V8D-10LJ GAL -o simpletoggle.tim
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/timsel\" @simpletoggle.psl"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete simpletoggle.psl
if [catch {open simpletoggle._sp w} rspFile] {
	puts stderr "Cannot create response file simpletoggle._sp: $rspFile"
} else {
	puts $rspFile "#insert -- NOTE: Do not edit this file.
#insert -- Auto generated by Post-Route Verilog Simulation Models
#insert --
#unixpath
#unixpath $install_dir/ispcpld/pld/verilog
#libfile pldlib.v
#unixpath
#vlog \"$proj_dir/simpletoggle.vt\"
#insert -- End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" \"simpletoggle._sp\" \"simpletoggle.vtl\" none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete simpletoggle._sp
if [catch {open simpletoggle._sp w} rspFile] {
	puts stderr "Cannot create response file simpletoggle._sp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by Post-Route Verilog Simulation Models
#insert #
#unixpath
#unixpath $install_dir/ispcpld/pld/verilog
#libfile pldlib.v
#unixpath
#vlog \"$proj_dir/simpletoggle.vt\"
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" \"simpletoggle._sp\" \"simpletoggle.vatl\" none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete simpletoggle._sp
if [runCmd "\"$cpld_bin/j2vlog\" simpletoggle.jed -dly custom simpletoggle.tim -pldbus default simpletoggle.btp -o simpletoggle.vt -module simpletoggle -suppress -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 19:55:06 ###########


########## Tcl recorder starts at 06/14/14 19:55:18 ##########

# Commands to make the Process: 
# VHDL Post-Route Simulation Model
if [catch {open simpletoggle._sp w} rspFile] {
	puts stderr "Cannot create response file simpletoggle._sp: $rspFile"
} else {
	puts $rspFile "#insert -- NOTE: Do not edit this file.
#insert -- Auto generated by Post-Route VHDL Simulation Models
#insert --
#unixpath $proj_dir
#vcom simpletoggle.vhq
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" \"simpletoggle._sp\" \"simpletoggle.vtd\" none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete simpletoggle._sp
if [catch {open simpletoggle._sp w} rspFile] {
	puts stderr "Cannot create response file simpletoggle._sp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by Post-Route VHDL Simulation Models
#insert #
#unixpath $proj_dir
#vcom simpletoggle.vhq
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" \"simpletoggle._sp\" \"simpletoggle.vatd\" none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete simpletoggle._sp
if [runCmd "\"$cpld_bin/j2svhdl\" simpletoggle.jed -dly custom simpletoggle.tim max -pldbus default simpletoggle.btp -o simpletoggle.vhq -module simpletoggle -suppress -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 19:55:18 ###########


########## Tcl recorder starts at 06/14/14 19:57:54 ##########

# Commands to make the Process: 
# Hierarchy Browser
# - none -
# Application to view the Process: 
# Hierarchy Browser
if [runCmd "\"$cpld_bin/hierbro\" \"simpletoggle.jid\"  simpletoggle"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 19:57:54 ###########


########## Tcl recorder starts at 06/14/14 19:59:12 ##########

# Commands to make the Process: 
# Compile Test Vectors
if [runCmd "\"$cpld_bin/ahdl2blf\" \"simpletoggle.abv\" -vec -ovec \"simpletoggle.tmv\" -sim SimpleToggle  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 19:59:12 ###########


########## Tcl recorder starts at 06/14/14 19:59:19 ##########

# Commands to make the Process: 
# Compiler Listing
if [runCmd "\"$cpld_bin/ahdl2blf\" \"simpletoggle.abv\" -vec -ovec \"simpletoggle.tmv\" -list -sim SimpleToggle -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 19:59:19 ###########


########## Tcl recorder starts at 06/14/14 19:59:27 ##########

# Commands to make the Process: 
# Functional Simulation
if [runCmd "\"$cpld_bin/sch2tf\" -template \"$install_dir/ispcpld/plsi/latsim/plsi.tft\" -prj simpletoggle -ext .lsi simpletoggle.sch "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" -i \"simpletoggle.bl0\" -o \"simpletoggle.blo\" -red bypin choose -sweep -collapse none -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"simpletoggle.blo\" -o \"simpletoggle.blh\" -omod simpletoggle -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"simpletoggle.blh\" -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" -i \"simpletoggle.bli\" -o \"simpletoggle.blj\" -idev PLSI -propadd -dev pla_basic -err automake.err "] {
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
-cfg oaipldtg.fdk \"simpletoggle.lts\" -map \"simpletoggle.lsi\"
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

########## Tcl recorder end at 06/14/14 19:59:28 ###########


########## Tcl recorder starts at 06/14/14 20:09:04 ##########

# Commands to make the Process: 
# Compile Test Vectors
if [runCmd "\"$cpld_bin/ahdl2blf\" \"simpletoggle.abv\" -vec -ovec \"simpletoggle.tmv\" -sim SimpleToggle  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 20:09:04 ###########


########## Tcl recorder starts at 06/14/14 20:09:11 ##########

# Commands to make the Process: 
# Compiler Listing
if [runCmd "\"$cpld_bin/ahdl2blf\" \"simpletoggle.abv\" -vec -ovec \"simpletoggle.tmv\" -list -sim SimpleToggle -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 20:09:11 ###########


########## Tcl recorder starts at 06/14/14 20:09:27 ##########

# Commands to make the Process: 
# Functional Simulation
# - none -
# Application to view the Process: 
# Functional Simulation
if [catch {open simcp._sp w} rspFile] {
	puts stderr "Cannot create response file simcp._sp: $rspFile"
} else {
	puts $rspFile "simcp.pre1 -ini simcpls.ini -unit simcp.pre1
-cfg oaipldtg.fdk \"simpletoggle.lts\" -map \"simpletoggle.lsi\"
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

########## Tcl recorder end at 06/14/14 20:09:27 ###########


########## Tcl recorder starts at 06/14/14 20:10:57 ##########

# Commands to make the Process: 
# Compile Test Vectors
if [runCmd "\"$cpld_bin/ahdl2blf\" \"simpletoggle.abv\" -vec -ovec \"simpletoggle.tmv\" -sim SimpleToggle  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 20:10:57 ###########


########## Tcl recorder starts at 06/14/14 20:11:09 ##########

# Commands to make the Process: 
# Functional Simulation
# - none -
# Application to view the Process: 
# Functional Simulation
if [catch {open simcp._sp w} rspFile] {
	puts stderr "Cannot create response file simcp._sp: $rspFile"
} else {
	puts $rspFile "simcp.pre1 -ini simcpls.ini -unit simcp.pre1
-cfg oaipldtg.fdk \"simpletoggle.lts\" -map \"simpletoggle.lsi\"
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

########## Tcl recorder end at 06/14/14 20:11:10 ###########


########## Tcl recorder starts at 06/14/14 20:13:40 ##########

# Commands to make the Process: 
# Compile Test Vectors
if [runCmd "\"$cpld_bin/ahdl2blf\" \"simpletoggle.abv\" -vec -ovec \"simpletoggle.tmv\" -sim SimpleToggle  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 20:13:40 ###########


########## Tcl recorder starts at 06/14/14 20:13:47 ##########

# Commands to make the Process: 
# Functional Simulation
# - none -
# Application to view the Process: 
# Functional Simulation
if [catch {open simcp._sp w} rspFile] {
	puts stderr "Cannot create response file simcp._sp: $rspFile"
} else {
	puts $rspFile "simcp.pre1 -ini simcpls.ini -unit simcp.pre1
-cfg oaipldtg.fdk \"simpletoggle.lts\" -map \"simpletoggle.lsi\"
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

########## Tcl recorder end at 06/14/14 20:13:47 ###########

