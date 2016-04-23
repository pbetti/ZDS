
########## Tcl recorder starts at 04/26/14 17:39:19 ##########

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
if [runCmd "\"$cpld_bin/sch2jhd\" \"2to4dec.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/26/14 17:39:19 ###########


########## Tcl recorder starts at 04/26/14 17:39:59 ##########

# Commands to make the Process: 
# Compile Test Vectors
if [runCmd "\"$cpld_bin/ahdl2blf\" \"2to4dec.abv\" -vec -ovec \"2to4dec.tmv\" -sim 2to4dec  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/26/14 17:39:59 ###########


########## Tcl recorder starts at 04/26/14 17:40:04 ##########

# Commands to make the Process: 
# Functional Simulation
if [runCmd "\"$cpld_bin/sch2tf\" -template \"$install_dir/ispcpld/plsi/latsim/plsi.tft\" -prj 2to4dec -ext .lsi 2to4dec.sch "] {
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
if [runCmd "\"$cpld_bin/iblifopt\" -i \"2to4dec.bl0\" -o \"2to4dec.blo\" -red bypin choose -sweep -collapse none -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"2to4dec.blo\" -o \"2to4dec.blh\" -omod 2to4dec -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"2to4dec.blh\" -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" -i \"2to4dec.bli\" -o \"2to4dec.blj\" -idev PLSI -propadd -dev pla_basic -err automake.err "] {
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
-cfg oaipldtg.fdk \"2to4dec.lts\" -map \"2to4dec.lsi\"
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

########## Tcl recorder end at 04/26/14 17:40:04 ###########


########## Tcl recorder starts at 04/26/14 17:40:49 ##########

# Commands to make the Process: 
# Timing Simulation
if [runCmd "\"$cpld_bin/sch2tf\" -template \"$install_dir/ispcpld/pld/j2mod.tft\" -prj 2to4dec -ext .btp 2to4dec.sch "] {
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
if [runCmd "\"$cpld_bin/iblflink\" \"2to4dec.bl1\" -o \"2to4dec.bl2\" -omod 2to4dec -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" 2to4dec.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" 2to4dec.bl3 -pla -o 2to4dec.tt2 -dev p16v8 -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" 2to4dec.tt2 -dev p16v8 -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fuseasm\" 2to4dec.tt3 -dev p16v8 -o 2to4dec.jed -ivec 2to4dec.tmv -rep 2to4dec.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 2to4dec.psl w} rspFile] {
	puts stderr "Cannot create response file 2to4dec.psl: $rspFile"
} else {
	puts $rspFile "-dev p16v8 -part LAT GAL16V8D-10LJ GAL -o 2to4dec.tim
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/timsel\" @2to4dec.psl"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 2to4dec.psl
if [catch {open 2to4dec._sp w} rspFile] {
	puts stderr "Cannot create response file 2to4dec._sp: $rspFile"
} else {
	puts $rspFile "#insert -- NOTE: Do not edit this file.
#insert -- Auto generated by Post-Route Verilog Simulation Models
#insert --
#unixpath
#unixpath $install_dir/ispcpld/pld/verilog
#libfile pldlib.v
#unixpath
#vlog \"$proj_dir/2to4dec.vt\"
#insert -- End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" \"2to4dec._sp\" \"2to4dec.vtl\" none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 2to4dec._sp
if [catch {open 2to4dec._sp w} rspFile] {
	puts stderr "Cannot create response file 2to4dec._sp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by Post-Route Verilog Simulation Models
#insert #
#unixpath
#unixpath $install_dir/ispcpld/pld/verilog
#libfile pldlib.v
#unixpath
#vlog \"$proj_dir/2to4dec.vt\"
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" \"2to4dec._sp\" \"2to4dec.vatl\" none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 2to4dec._sp
if [runCmd "\"$cpld_bin/j2sim\" 2to4dec.jed -dly custom 2to4dec.tim -pldbus default 2to4dec.btp -o 2to4dec.sim -module 2to4dec -suppress -err automake.err"] {
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
-cfg oaipldtg.fdk \"2to4dec.lts\" -map \"2to4dec.lsi\"
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

########## Tcl recorder end at 04/26/14 17:40:50 ###########

