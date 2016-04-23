
########## Tcl recorder starts at 04/24/14 12:48:17 ##########

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
if [runCmd "\"$cpld_bin/sch2jhd\" \"mmu_gal.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/24/14 12:48:17 ###########


########## Tcl recorder starts at 04/24/14 12:57:26 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"mmu_gal.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/24/14 12:57:26 ###########


########## Tcl recorder starts at 04/24/14 12:58:25 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"mmu_gal.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/24/14 12:58:25 ###########


########## Tcl recorder starts at 04/24/14 13:03:56 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"mmu_gal.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/24/14 13:03:57 ###########


########## Tcl recorder starts at 04/24/14 13:06:38 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"mmu_gal.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/24/14 13:06:38 ###########


########## Tcl recorder starts at 04/24/14 13:11:01 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"mmu_gal.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/24/14 13:11:01 ###########


########## Tcl recorder starts at 04/24/14 13:12:37 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"mmu_gal.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/24/14 13:12:38 ###########


########## Tcl recorder starts at 04/24/14 13:13:43 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"mmu_gal.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/24/14 13:13:44 ###########


########## Tcl recorder starts at 04/24/14 13:20:09 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"mmu_gal.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/24/14 13:20:09 ###########


########## Tcl recorder starts at 04/24/14 13:22:02 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"mmu_gal.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/24/14 13:22:02 ###########


########## Tcl recorder starts at 04/24/14 13:34:28 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"mmu_gal.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/24/14 13:34:28 ###########


########## Tcl recorder starts at 04/24/14 13:35:35 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"mmu_gal.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/24/14 13:35:35 ###########


########## Tcl recorder starts at 04/24/14 14:05:52 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"mmu_gal.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/24/14 14:05:52 ###########


########## Tcl recorder starts at 04/24/14 14:08:06 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"mmu_gal.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/24/14 14:08:07 ###########


########## Tcl recorder starts at 04/24/14 14:09:54 ##########

# Commands to make the Process: 
# Link Design
if [runCmd "\"$cpld_bin/sch2blf\" -sup \"mmu_gal.sch\" -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"mmu_gal.bls\" -o \"mmu_gal.bl0\" -ipo -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" -i \"mmu_gal.bl0\" -o \"mmu_gal.bl1\" -red bypin choose -sweep -collapse none -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"mmu_gal.bl1\" -o \"untitled.bl2\" -omod mmu_gal -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/24/14 14:09:55 ###########


########## Tcl recorder starts at 04/24/14 14:10:17 ##########

# Commands to make the Process: 
# Linked Equations
if [runCmd "\"$cpld_bin/blif2eqn\" \"untitled.bl2\" -o \"untitled.eq2\" -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/24/14 14:10:17 ###########


########## Tcl recorder starts at 04/24/14 14:10:43 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" untitled.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" untitled.bl3 -pla -o untitled.tt2 -dev p16v8 -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" untitled.tt2 -dev p16v8 -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/24/14 14:10:43 ###########


########## Tcl recorder starts at 04/24/14 14:31:54 ##########

# Commands to make the Process: 
# Compile Test Vectors
if [runCmd "\"$cpld_bin/ahdl2blf\" \"mmu_gal_tst.abv\" -vec -ovec \"mmu_gal_tst.tmv\" -sim Untitled  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/24/14 14:31:55 ###########


########## Tcl recorder starts at 04/24/14 14:32:27 ##########

# Commands to make the Process: 
# Compile Test Vectors
if [runCmd "\"$cpld_bin/ahdl2blf\" \"mmu_gal_tst.abv\" -vec -ovec \"mmu_gal_tst.tmv\" -sim Untitled  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/24/14 14:32:28 ###########


########## Tcl recorder starts at 04/24/14 14:32:36 ##########

# Commands to make the Process: 
# Functional Simulation
if [runCmd "\"$cpld_bin/sch2tf\" -template \"$install_dir/ispcpld/plsi/latsim/plsi.tft\" -prj untitled -ext .lsi mmu_gal.sch "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/sch2blf\" -sup \"mmu_gal.sch\" -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"mmu_gal.bls\" -o \"mmu_gal.bl0\" -ipo -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" -i \"mmu_gal.bl0\" -o \"mmu_gal.blo\" -red bypin choose -sweep -collapse none -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"mmu_gal.blo\" -o \"untitled.blh\" -omod untitled -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"untitled.blh\" -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" -i \"untitled.bli\" -o \"untitled.blj\" -idev PLSI -propadd -dev pla_basic -err automake.err "] {
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
-cfg oaipldtg.fdk \"mmu_gal_tst.lts\" -map \"mmu_gal.lsi\"
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

########## Tcl recorder end at 04/24/14 14:32:36 ###########


########## Tcl recorder starts at 04/24/14 14:37:36 ##########

# Commands to make the Process: 
# Compile Test Vectors
if [runCmd "\"$cpld_bin/ahdl2blf\" \"mmu_gal_tst.abv\" -vec -ovec \"mmu_gal_tst.tmv\" -sim Untitled  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/24/14 14:37:36 ###########


########## Tcl recorder starts at 04/24/14 14:37:45 ##########

# Commands to make the Process: 
# Functional Simulation
# - none -
# Application to view the Process: 
# Functional Simulation
if [catch {open simcp._sp w} rspFile] {
	puts stderr "Cannot create response file simcp._sp: $rspFile"
} else {
	puts $rspFile "simcp.pre1 -ini simcpls.ini -unit simcp.pre1
-cfg oaipldtg.fdk \"mmu_gal_tst.lts\" -map \"mmu_gal.lsi\"
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

########## Tcl recorder end at 04/24/14 14:37:45 ###########


########## Tcl recorder starts at 04/24/14 14:41:27 ##########

# Commands to make the Process: 
# Compiler Listing
if [runCmd "\"$cpld_bin/ahdl2blf\" \"mmu_gal_tst.abv\" -vec -ovec \"mmu_gal_tst.tmv\" -list -sim Untitled -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/24/14 14:41:27 ###########


########## Tcl recorder starts at 04/24/14 14:42:30 ##########

# Commands to make the Process: 
# Timing Simulation
if [runCmd "\"$cpld_bin/sch2tf\" -template \"$install_dir/ispcpld/pld/j2mod.tft\" -prj untitled -ext .btp mmu_gal.sch "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" -i \"mmu_gal.bl0\" -o \"mmu_gal.bl1\" -red bypin choose -sweep -collapse none -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"mmu_gal.bl1\" -o \"untitled.bl2\" -omod mmu_gal -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" untitled.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" untitled.bl3 -pla -o untitled.tt2 -dev p16v8 -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" untitled.tt2 -dev p16v8 -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fuseasm\" untitled.tt3 -dev p16v8 -o untitled.jed -ivec mmu_gal_tst.tmv -rep untitled.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open untitled.psl w} rspFile] {
	puts stderr "Cannot create response file untitled.psl: $rspFile"
} else {
	puts $rspFile "-dev p16v8 -part LAT GAL16V8D-15LP GAL -o untitled.tim
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/timsel\" @untitled.psl"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete untitled.psl
if [catch {open untitled._sp w} rspFile] {
	puts stderr "Cannot create response file untitled._sp: $rspFile"
} else {
	puts $rspFile "#insert -- NOTE: Do not edit this file.
#insert -- Auto generated by Post-Route Verilog Simulation Models
#insert --
#unixpath
#unixpath $install_dir/ispcpld/pld/verilog
#libfile pldlib.v
#unixpath
#vlog \"$proj_dir/untitled.vt\"
#insert -- End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" \"untitled._sp\" \"untitled.vtl\" none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete untitled._sp
if [catch {open untitled._sp w} rspFile] {
	puts stderr "Cannot create response file untitled._sp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by Post-Route Verilog Simulation Models
#insert #
#unixpath
#unixpath $install_dir/ispcpld/pld/verilog
#libfile pldlib.v
#unixpath
#vlog \"$proj_dir/untitled.vt\"
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" \"untitled._sp\" \"untitled.vatl\" none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete untitled._sp
if [runCmd "\"$cpld_bin/j2sim\" untitled.jed -dly custom untitled.tim -pldbus default mmu_gal.btp -o untitled.sim -module mmu_gal -suppress -err automake.err"] {
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
-cfg oaipldtg.fdk \"mmu_gal_tst.lts\" -map \"mmu_gal.lsi\"
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

########## Tcl recorder end at 04/24/14 14:42:30 ###########


########## Tcl recorder starts at 04/24/14 14:46:20 ##########

# Commands to make the Process: 
# Compile Test Vectors
if [runCmd "\"$cpld_bin/ahdl2blf\" \"mmu_gal_tst.abv\" -vec -ovec \"mmu_gal_tst.tmv\" -sim Untitled  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/24/14 14:46:20 ###########


########## Tcl recorder starts at 04/24/14 14:46:29 ##########

# Commands to make the Process: 
# Functional Simulation
# - none -
# Application to view the Process: 
# Functional Simulation
if [catch {open simcp._sp w} rspFile] {
	puts stderr "Cannot create response file simcp._sp: $rspFile"
} else {
	puts $rspFile "simcp.pre1 -ini simcpls.ini -unit simcp.pre1
-cfg oaipldtg.fdk \"mmu_gal_tst.lts\" -map \"mmu_gal.lsi\"
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

########## Tcl recorder end at 04/24/14 14:46:29 ###########


########## Tcl recorder starts at 04/24/14 14:52:15 ##########

# Commands to make the Process: 
# Compile Test Vectors
if [runCmd "\"$cpld_bin/ahdl2blf\" \"mmu_gal_tst.abv\" -vec -ovec \"mmu_gal_tst.tmv\" -sim Untitled  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/24/14 14:52:15 ###########


########## Tcl recorder starts at 04/24/14 14:52:20 ##########

# Commands to make the Process: 
# Functional Simulation
# - none -
# Application to view the Process: 
# Functional Simulation
if [catch {open simcp._sp w} rspFile] {
	puts stderr "Cannot create response file simcp._sp: $rspFile"
} else {
	puts $rspFile "simcp.pre1 -ini simcpls.ini -unit simcp.pre1
-cfg oaipldtg.fdk \"mmu_gal_tst.lts\" -map \"mmu_gal.lsi\"
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

########## Tcl recorder end at 04/24/14 14:52:20 ###########


########## Tcl recorder starts at 04/24/14 14:58:04 ##########

# Commands to make the Process: 
# Compile Test Vectors
if [runCmd "\"$cpld_bin/ahdl2blf\" \"mmu_gal_tst.abv\" -vec -ovec \"mmu_gal_tst.tmv\" -sim Untitled  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/24/14 14:58:04 ###########


########## Tcl recorder starts at 04/24/14 14:58:13 ##########

# Commands to make the Process: 
# Timing Simulation
if [runCmd "\"$cpld_bin/fuseasm\" untitled.tt3 -dev p16v8 -o untitled.jed -ivec mmu_gal_tst.tmv -rep untitled.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/j2sim\" untitled.jed -dly custom untitled.tim -pldbus default mmu_gal.btp -o untitled.sim -module mmu_gal -suppress -err automake.err"] {
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
-cfg oaipldtg.fdk \"mmu_gal_tst.lts\" -map \"mmu_gal.lsi\"
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

########## Tcl recorder end at 04/24/14 14:58:13 ###########


########## Tcl recorder starts at 04/24/14 15:00:22 ##########

# Commands to make the Process: 
# Compile Test Vectors
if [runCmd "\"$cpld_bin/ahdl2blf\" \"mmu_gal_tst.abv\" -vec -ovec \"mmu_gal_tst.tmv\" -sim Untitled  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/24/14 15:00:22 ###########


########## Tcl recorder starts at 04/24/14 15:00:26 ##########

# Commands to make the Process: 
# Functional Simulation
# - none -
# Application to view the Process: 
# Functional Simulation
if [catch {open simcp._sp w} rspFile] {
	puts stderr "Cannot create response file simcp._sp: $rspFile"
} else {
	puts $rspFile "simcp.pre1 -ini simcpls.ini -unit simcp.pre1
-cfg oaipldtg.fdk \"mmu_gal_tst.lts\" -map \"mmu_gal.lsi\"
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

########## Tcl recorder end at 04/24/14 15:00:27 ###########


########## Tcl recorder starts at 04/24/14 15:03:03 ##########

# Commands to make the Process: 
# Timing Simulation
if [runCmd "\"$cpld_bin/fuseasm\" untitled.tt3 -dev p16v8 -o untitled.jed -ivec mmu_gal_tst.tmv -rep untitled.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/j2sim\" untitled.jed -dly custom untitled.tim -pldbus default mmu_gal.btp -o untitled.sim -module mmu_gal -suppress -err automake.err"] {
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
-cfg oaipldtg.fdk \"mmu_gal_tst.lts\" -map \"mmu_gal.lsi\"
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

########## Tcl recorder end at 04/24/14 15:03:04 ###########


########## Tcl recorder starts at 04/24/14 15:05:45 ##########

# Commands to make the Process: 
# Compile Test Vectors
if [runCmd "\"$cpld_bin/ahdl2blf\" \"mmu_gal_tst.abv\" -vec -ovec \"mmu_gal_tst.tmv\" -sim Untitled  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/24/14 15:05:46 ###########


########## Tcl recorder starts at 04/24/14 15:05:49 ##########

# Commands to make the Process: 
# Functional Simulation
# - none -
# Application to view the Process: 
# Functional Simulation
if [catch {open simcp._sp w} rspFile] {
	puts stderr "Cannot create response file simcp._sp: $rspFile"
} else {
	puts $rspFile "simcp.pre1 -ini simcpls.ini -unit simcp.pre1
-cfg oaipldtg.fdk \"mmu_gal_tst.lts\" -map \"mmu_gal.lsi\"
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

########## Tcl recorder end at 04/24/14 15:05:49 ###########


########## Tcl recorder starts at 04/24/14 15:11:15 ##########

# Commands to make the Process: 
# Timing Simulation
if [runCmd "\"$cpld_bin/fuseasm\" untitled.tt3 -dev p16v8 -o untitled.jed -ivec mmu_gal_tst.tmv -rep untitled.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/j2sim\" untitled.jed -dly custom untitled.tim -pldbus default mmu_gal.btp -o untitled.sim -module mmu_gal -suppress -err automake.err"] {
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
-cfg oaipldtg.fdk \"mmu_gal_tst.lts\" -map \"mmu_gal.lsi\"
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

########## Tcl recorder end at 04/24/14 15:11:16 ###########


########## Tcl recorder starts at 04/24/14 15:14:42 ##########

# Commands to make the Process: 
# JEDEC Simulation Waveform
if [runCmd "\"$cpld_bin/jedsim\" Untitled.jed -o mmu_gal_tst.smj -ostatus mmu_gal_tst.sts -tra table detail -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# JEDEC Simulation Waveform
if [runCmd "\"$cpld_bin/waves\" -hst jedec.hst"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/24/14 15:14:42 ###########


########## Tcl recorder starts at 04/24/14 15:15:15 ##########

# Commands to make the Process: 
# JEDEC Simulation Waveform
# - none -
# Application to view the Process: 
# JEDEC Simulation Waveform
if [runCmd "\"$cpld_bin/waves\" -hst jedec.hst"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/24/14 15:15:15 ###########


########## Tcl recorder starts at 04/24/14 15:15:38 ##########

# Commands to make the Process: 
# JEDEC Simulation Waveform
# - none -
# Application to view the Process: 
# JEDEC Simulation Waveform
if [runCmd "\"$cpld_bin/waves\" -hst jedec.hst"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/24/14 15:15:38 ###########


########## Tcl recorder starts at 04/24/14 15:16:12 ##########

# Commands to make the Process: 
# Functional Simulation
# - none -
# Application to view the Process: 
# Functional Simulation
if [catch {open simcp._sp w} rspFile] {
	puts stderr "Cannot create response file simcp._sp: $rspFile"
} else {
	puts $rspFile "simcp.pre1 -ini simcpls.ini -unit simcp.pre1
-cfg oaipldtg.fdk \"mmu_gal_tst.lts\" -map \"mmu_gal.lsi\"
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

########## Tcl recorder end at 04/24/14 15:16:12 ###########


########## Tcl recorder starts at 04/24/14 15:19:19 ##########

# Commands to make the Process: 
# Compile Test Vectors
if [runCmd "\"$cpld_bin/ahdl2blf\" \"mmu_gal_tst.abv\" -vec -ovec \"mmu_gal_tst.tmv\" -sim Untitled  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/24/14 15:19:19 ###########


########## Tcl recorder starts at 04/24/14 15:19:22 ##########

# Commands to make the Process: 
# Functional Simulation
# - none -
# Application to view the Process: 
# Functional Simulation
if [catch {open simcp._sp w} rspFile] {
	puts stderr "Cannot create response file simcp._sp: $rspFile"
} else {
	puts $rspFile "simcp.pre1 -ini simcpls.ini -unit simcp.pre1
-cfg oaipldtg.fdk \"mmu_gal_tst.lts\" -map \"mmu_gal.lsi\"
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

########## Tcl recorder end at 04/24/14 15:19:22 ###########


########## Tcl recorder starts at 04/24/14 15:39:37 ##########

# Commands to make the Process: 
# Compile Test Vectors
if [runCmd "\"$cpld_bin/ahdl2blf\" \"mmu_gal_tst.abv\" -vec -ovec \"mmu_gal_tst.tmv\" -sim Untitled  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/24/14 15:39:37 ###########


########## Tcl recorder starts at 04/24/14 15:39:44 ##########

# Commands to make the Process: 
# Functional Simulation
# - none -
# Application to view the Process: 
# Functional Simulation
if [catch {open simcp._sp w} rspFile] {
	puts stderr "Cannot create response file simcp._sp: $rspFile"
} else {
	puts $rspFile "simcp.pre1 -ini simcpls.ini -unit simcp.pre1
-cfg oaipldtg.fdk \"mmu_gal_tst.lts\" -map \"mmu_gal.lsi\"
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

########## Tcl recorder end at 04/24/14 15:39:44 ###########


########## Tcl recorder starts at 04/24/14 15:40:55 ##########

# Commands to make the Process: 
# Timing Simulation
if [runCmd "\"$cpld_bin/fuseasm\" untitled.tt3 -dev p16v8 -o untitled.jed -ivec mmu_gal_tst.tmv -rep untitled.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/j2sim\" untitled.jed -dly custom untitled.tim -pldbus default mmu_gal.btp -o untitled.sim -module mmu_gal -suppress -err automake.err"] {
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
-cfg oaipldtg.fdk \"mmu_gal_tst.lts\" -map \"mmu_gal.lsi\"
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

########## Tcl recorder end at 04/24/14 15:40:55 ###########


########## Tcl recorder starts at 04/24/14 15:46:46 ##########

# Commands to make the Process: 
# Compile Test Vectors
if [runCmd "\"$cpld_bin/ahdl2blf\" \"mmu_gal_tst.abv\" -vec -ovec \"mmu_gal_tst.tmv\" -sim Untitled  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/24/14 15:46:46 ###########


########## Tcl recorder starts at 04/24/14 15:46:57 ##########

# Commands to make the Process: 
# Compiler Listing
if [runCmd "\"$cpld_bin/ahdl2blf\" \"mmu_gal_tst.abv\" -vec -ovec \"mmu_gal_tst.tmv\" -list -sim Untitled -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/24/14 15:46:57 ###########


########## Tcl recorder starts at 04/24/14 15:47:02 ##########

# Commands to make the Process: 
# Functional Simulation
# - none -
# Application to view the Process: 
# Functional Simulation
if [catch {open simcp._sp w} rspFile] {
	puts stderr "Cannot create response file simcp._sp: $rspFile"
} else {
	puts $rspFile "simcp.pre1 -ini simcpls.ini -unit simcp.pre1
-cfg oaipldtg.fdk \"mmu_gal_tst.lts\" -map \"mmu_gal.lsi\"
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

########## Tcl recorder end at 04/24/14 15:47:02 ###########


########## Tcl recorder starts at 04/24/14 15:48:30 ##########

# Commands to make the Process: 
# Timing Simulation
if [runCmd "\"$cpld_bin/fuseasm\" untitled.tt3 -dev p16v8 -o untitled.jed -ivec mmu_gal_tst.tmv -rep untitled.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/j2sim\" untitled.jed -dly custom untitled.tim -pldbus default mmu_gal.btp -o untitled.sim -module mmu_gal -suppress -err automake.err"] {
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
-cfg oaipldtg.fdk \"mmu_gal_tst.lts\" -map \"mmu_gal.lsi\"
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

########## Tcl recorder end at 04/24/14 15:48:30 ###########


########## Tcl recorder starts at 04/24/14 15:54:10 ##########

# Commands to make the Process: 
# Compile Test Vectors
if [runCmd "\"$cpld_bin/ahdl2blf\" \"mmu_gal_tst.abv\" -vec -ovec \"mmu_gal_tst.tmv\" -sim Untitled  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/24/14 15:54:10 ###########


########## Tcl recorder starts at 04/24/14 15:54:16 ##########

# Commands to make the Process: 
# Functional Simulation
# - none -
# Application to view the Process: 
# Functional Simulation
if [catch {open simcp._sp w} rspFile] {
	puts stderr "Cannot create response file simcp._sp: $rspFile"
} else {
	puts $rspFile "simcp.pre1 -ini simcpls.ini -unit simcp.pre1
-cfg oaipldtg.fdk \"mmu_gal_tst.lts\" -map \"mmu_gal.lsi\"
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

########## Tcl recorder end at 04/24/14 15:54:16 ###########


########## Tcl recorder starts at 04/24/14 15:56:53 ##########

# Commands to make the Process: 
# Compile Test Vectors
if [runCmd "\"$cpld_bin/ahdl2blf\" \"mmu_gal_tst.abv\" -vec -ovec \"mmu_gal_tst.tmv\" -sim Untitled  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/24/14 15:56:54 ###########


########## Tcl recorder starts at 04/24/14 15:56:58 ##########

# Commands to make the Process: 
# Functional Simulation
# - none -
# Application to view the Process: 
# Functional Simulation
if [catch {open simcp._sp w} rspFile] {
	puts stderr "Cannot create response file simcp._sp: $rspFile"
} else {
	puts $rspFile "simcp.pre1 -ini simcpls.ini -unit simcp.pre1
-cfg oaipldtg.fdk \"mmu_gal_tst.lts\" -map \"mmu_gal.lsi\"
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

########## Tcl recorder end at 04/24/14 15:56:58 ###########


########## Tcl recorder starts at 04/24/14 15:57:36 ##########

# Commands to make the Process: 
# Update All Schematic Files
if [runCmd "\"$cpld_bin/updatesc\" mmu_gal.sch -yield"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/24/14 15:57:36 ###########


########## Tcl recorder starts at 04/24/14 15:57:57 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/fuseasm\" untitled.tt3 -dev p16v8 -o untitled.jed -ivec mmu_gal_tst.tmv -rep untitled.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj untitled -if untitled.jed -j2s -log untitled.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/24/14 15:57:57 ###########


########## Tcl recorder starts at 06/13/14 19:35:58 ##########

# Commands to make the Process: 
# Update All Schematic Files
if [runCmd "\"$cpld_bin/updatesc\" mmu_gal.sch -yield"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/13/14 19:35:58 ###########


########## Tcl recorder starts at 06/13/14 19:38:37 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"mmu_gal.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/13/14 19:38:37 ###########


########## Tcl recorder starts at 06/13/14 19:38:46 ##########

# Commands to make the Process: 
# Update All Schematic Files
if [runCmd "\"$cpld_bin/updatesc\" mmu_gal.sch -yield"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/13/14 19:38:46 ###########


########## Tcl recorder starts at 06/13/14 19:38:53 ##########

# Commands to make the Process: 
# Link Design
if [runCmd "\"$cpld_bin/sch2blf\" -sup \"mmu_gal.sch\" -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"mmu_gal.bls\" -o \"mmu_gal.bl0\" -ipo -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" -i \"mmu_gal.bl0\" -o \"mmu_gal.bl1\" -red bypin choose -sweep -collapse none -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"mmu_gal.bl1\" -o \"untitled.bl2\" -omod mmu_gal -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/13/14 19:38:53 ###########


########## Tcl recorder starts at 06/13/14 19:39:03 ##########

# Commands to make the Process: 
# Linked Equations
if [runCmd "\"$cpld_bin/blif2eqn\" \"untitled.bl2\" -o \"untitled.eq2\" -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/13/14 19:39:03 ###########


########## Tcl recorder starts at 06/13/14 19:39:09 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" untitled.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" untitled.bl3 -pla -o untitled.tt2 -dev p16v8 -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" untitled.tt2 -dev p16v8 -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/13/14 19:39:09 ###########


########## Tcl recorder starts at 06/14/14 18:24:50 ##########

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

########## Tcl recorder end at 06/14/14 18:24:50 ###########


########## Tcl recorder starts at 06/14/14 20:37:06 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"mmu_gal.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 20:37:06 ###########


########## Tcl recorder starts at 06/14/14 20:44:09 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"mmu_gal.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 20:44:09 ###########


########## Tcl recorder starts at 06/14/14 20:44:24 ##########

# Commands to make the Process: 
# Compile Schematic
if [runCmd "\"$cpld_bin/sch2blf\" -sup \"mmu_gal.sch\" -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"mmu_gal.bls\" -o \"mmu_gal.bl0\" -ipo -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 20:44:24 ###########


########## Tcl recorder starts at 06/14/14 20:44:33 ##########

# Commands to make the Process: 
# Generate Schematic Symbol
if [runCmd "\"$cpld_bin/naf2sym\" \"mmu_gal\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 20:44:33 ###########


########## Tcl recorder starts at 06/14/14 20:44:48 ##########

# Commands to make the Process: 
# ABEL Test Vector Template
if [runCmd "\"$cpld_bin/blif2eqn\" \"mmu_gal.bl0\" -o \"mmu_gal.abt\" -testfix -template \"$install_dir/ispcpld/plsi/abel/plsiabt.tft\" -prj untitled -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 20:44:48 ###########


########## Tcl recorder starts at 06/14/14 20:44:58 ##########

# Commands to make the Process: 
# Verilog Test Fixture Declarations
if [runCmd "\"$cpld_bin/sch2tf\" -template \"$install_dir/ispcpld/generic/verilog/tfi.tft\" -prj untitled mmu_gal.sch "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 20:44:58 ###########


########## Tcl recorder starts at 06/14/14 20:45:03 ##########

# Commands to make the Process: 
# Verilog Test Fixture Template
if [runCmd "\"$cpld_bin/sch2tf\" -template \"$install_dir/ispcpld/generic/verilog/tft.tft\" -prj untitled -ext .tft mmu_gal.sch "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 20:45:03 ###########


########## Tcl recorder starts at 06/14/14 20:45:11 ##########

# Commands to make the Process: 
# VHDL Test Bench Template
if [runCmd "\"$cpld_bin/vhdl\" -tmmu_gal.vht -s mmu_gal.sch"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 20:45:11 ###########


########## Tcl recorder starts at 06/14/14 20:45:15 ##########

# Commands to make the Process: 
# Reduce Schematic Logic
if [runCmd "\"$cpld_bin/iblifopt\" -i \"mmu_gal.bl0\" -o \"mmu_gal.bl1\" -red bypin choose -sweep -collapse none -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 20:45:15 ###########


########## Tcl recorder starts at 06/14/14 20:45:30 ##########

# Commands to make the Process: 
# Reduced Equations
if [runCmd "\"$cpld_bin/blif2eqn\" \"mmu_gal.bl1\" -o \"mmu_gal.eq1\" -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 20:45:30 ###########


########## Tcl recorder starts at 06/14/14 20:45:54 ##########

# Commands to make the Process: 
# Update All Schematic Files
if [runCmd "\"$cpld_bin/updatesc\" mmu_gal.sch -yield"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 20:45:54 ###########


########## Tcl recorder starts at 06/14/14 20:46:01 ##########

# Commands to make the Process: 
# Link Design
if [runCmd "\"$cpld_bin/iblflink\" \"mmu_gal.bl1\" -o \"untitled.bl2\" -omod mmu_gal -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 20:46:01 ###########


########## Tcl recorder starts at 06/14/14 20:46:15 ##########

# Commands to make the Process: 
# Linked Equations
if [runCmd "\"$cpld_bin/blif2eqn\" \"untitled.bl2\" -o \"untitled.eq2\" -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 20:46:15 ###########


########## Tcl recorder starts at 06/14/14 20:46:22 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" untitled.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" untitled.bl3 -pla -o untitled.tt2 -dev p16v8 -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" untitled.tt2 -dev p16v8 -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 20:46:22 ###########


########## Tcl recorder starts at 06/14/14 20:47:15 ##########

# Commands to make the Process: 
# Pre-Fit Equations
if [runCmd "\"$cpld_bin/blif2eqn\" untitled.tt2 -o untitled.eq3 -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 20:47:15 ###########


########## Tcl recorder starts at 06/14/14 20:47:35 ##########

# Commands to make the Process: 
# Post-Fit Equations
if [runCmd "\"$cpld_bin/fit\" untitled.tt2 -dev p16v8 -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blif2eqn\" untitled.tt3 -o untitled.eq4 -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 20:47:35 ###########


########## Tcl recorder starts at 06/14/14 20:48:37 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"mmu_gal.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 20:48:37 ###########


########## Tcl recorder starts at 06/14/14 20:55:49 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"mmu_gal.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 20:55:49 ###########


########## Tcl recorder starts at 06/14/14 20:56:20 ##########

# Commands to make the Process: 
# Update All Schematic Files
if [runCmd "\"$cpld_bin/updatesc\" mmu_gal.sch -yield"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 20:56:20 ###########


########## Tcl recorder starts at 06/14/14 20:56:27 ##########

# Commands to make the Process: 
# Link Design
if [runCmd "\"$cpld_bin/sch2blf\" -sup \"mmu_gal.sch\" -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"mmu_gal.bls\" -o \"mmu_gal.bl0\" -ipo -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" -i \"mmu_gal.bl0\" -o \"mmu_gal.bl1\" -red bypin choose -sweep -collapse none -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"mmu_gal.bl1\" -o \"untitled.bl2\" -omod mmu_gal -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 20:56:27 ###########


########## Tcl recorder starts at 06/14/14 20:56:42 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" untitled.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" untitled.bl3 -pla -o untitled.tt2 -dev p16v8 -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" untitled.tt2 -dev p16v8 -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 20:56:42 ###########


########## Tcl recorder starts at 06/14/14 21:00:14 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"mmu_gal.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 21:00:14 ###########


########## Tcl recorder starts at 06/14/14 21:00:25 ##########

# Commands to make the Process: 
# Update All Schematic Files
if [runCmd "\"$cpld_bin/updatesc\" mmu_gal.sch -yield"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 21:00:25 ###########


########## Tcl recorder starts at 06/14/14 21:00:33 ##########

# Commands to make the Process: 
# Link Design
if [runCmd "\"$cpld_bin/sch2blf\" -sup \"mmu_gal.sch\" -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"mmu_gal.bls\" -o \"mmu_gal.bl0\" -ipo -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" -i \"mmu_gal.bl0\" -o \"mmu_gal.bl1\" -red bypin choose -sweep -collapse none -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"mmu_gal.bl1\" -o \"untitled.bl2\" -omod mmu_gal -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 21:00:33 ###########


########## Tcl recorder starts at 06/14/14 21:00:44 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" untitled.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" untitled.bl3 -pla -o untitled.tt2 -dev p16v8 -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" untitled.tt2 -dev p16v8 -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/14/14 21:00:45 ###########


########## Tcl recorder starts at 06/16/14 18:59:39 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"mmu_gal.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 18:59:39 ###########


########## Tcl recorder starts at 06/16/14 19:05:49 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"mmu_gal.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 19:05:49 ###########


########## Tcl recorder starts at 06/16/14 19:06:05 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"mmu_gal.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 19:06:05 ###########


########## Tcl recorder starts at 06/16/14 19:06:17 ##########

# Commands to make the Process: 
# Compile Schematic
if [runCmd "\"$cpld_bin/sch2blf\" -sup \"mmu_gal.sch\" -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"mmu_gal.bls\" -o \"mmu_gal.bl0\" -ipo -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 19:06:17 ###########


########## Tcl recorder starts at 06/16/14 19:06:26 ##########

# Commands to make the Process: 
# Generate Schematic Symbol
if [runCmd "\"$cpld_bin/naf2sym\" \"mmu_gal\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 19:06:26 ###########


########## Tcl recorder starts at 06/16/14 19:06:42 ##########

# Commands to make the Process: 
# ABEL Test Vector Template
if [runCmd "\"$cpld_bin/blif2eqn\" \"mmu_gal.bl0\" -o \"mmu_gal.abt\" -testfix -template \"$install_dir/ispcpld/plsi/abel/plsiabt.tft\" -prj untitled -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 19:06:42 ###########


########## Tcl recorder starts at 06/16/14 19:06:51 ##########

# Commands to make the Process: 
# Verilog Test Fixture Declarations
if [runCmd "\"$cpld_bin/sch2tf\" -template \"$install_dir/ispcpld/generic/verilog/tfi.tft\" -prj untitled mmu_gal.sch "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 19:06:52 ###########


########## Tcl recorder starts at 06/16/14 19:07:00 ##########

# Commands to make the Process: 
# Verilog Test Fixture Template
if [runCmd "\"$cpld_bin/sch2tf\" -template \"$install_dir/ispcpld/generic/verilog/tft.tft\" -prj untitled -ext .tft mmu_gal.sch "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 19:07:00 ###########


########## Tcl recorder starts at 06/16/14 19:07:08 ##########

# Commands to make the Process: 
# VHDL Test Bench Template
if [runCmd "\"$cpld_bin/vhdl\" -tmmu_gal.vht -s mmu_gal.sch"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 19:07:08 ###########


########## Tcl recorder starts at 06/16/14 19:07:12 ##########

# Commands to make the Process: 
# Reduce Schematic Logic
if [runCmd "\"$cpld_bin/iblifopt\" -i \"mmu_gal.bl0\" -o \"mmu_gal.bl1\" -red bypin choose -sweep -collapse none -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 19:07:12 ###########


########## Tcl recorder starts at 06/16/14 19:07:29 ##########

# Commands to make the Process: 
# Reduced Equations
if [runCmd "\"$cpld_bin/blif2eqn\" \"mmu_gal.bl1\" -o \"mmu_gal.eq1\" -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 19:07:29 ###########


########## Tcl recorder starts at 06/16/14 19:07:46 ##########

# Commands to make the Process: 
# Update All Schematic Files
if [runCmd "\"$cpld_bin/updatesc\" mmu_gal.sch -yield"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 19:07:47 ###########


########## Tcl recorder starts at 06/16/14 19:07:56 ##########

# Commands to make the Process: 
# Link Design
if [runCmd "\"$cpld_bin/iblflink\" \"mmu_gal.bl1\" -o \"untitled.bl2\" -omod mmu_gal -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 19:07:56 ###########


########## Tcl recorder starts at 06/16/14 19:08:03 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" untitled.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" untitled.bl3 -pla -o untitled.tt2 -dev p16v8 -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" untitled.tt2 -dev p16v8 -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 19:08:03 ###########


########## Tcl recorder starts at 06/16/14 19:30:53 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"mmu_gal.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 19:30:53 ###########


########## Tcl recorder starts at 06/16/14 19:31:03 ##########

# Commands to make the Process: 
# Compile Schematic
if [runCmd "\"$cpld_bin/sch2blf\" -sup \"mmu_gal.sch\" -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"mmu_gal.bls\" -o \"mmu_gal.bl0\" -ipo -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 19:31:03 ###########


########## Tcl recorder starts at 06/16/14 19:31:10 ##########

# Commands to make the Process: 
# ABEL Test Vector Template
if [runCmd "\"$cpld_bin/blif2eqn\" \"mmu_gal.bl0\" -o \"mmu_gal.abt\" -testfix -template \"$install_dir/ispcpld/plsi/abel/plsiabt.tft\" -prj untitled -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 19:31:11 ###########


########## Tcl recorder starts at 06/16/14 19:31:17 ##########

# Commands to make the Process: 
# Generate Schematic Symbol
if [runCmd "\"$cpld_bin/naf2sym\" \"mmu_gal\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 19:31:17 ###########


########## Tcl recorder starts at 06/16/14 19:31:24 ##########

# Commands to make the Process: 
# Verilog Test Fixture Declarations
if [runCmd "\"$cpld_bin/sch2tf\" -template \"$install_dir/ispcpld/generic/verilog/tfi.tft\" -prj untitled mmu_gal.sch "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 19:31:24 ###########


########## Tcl recorder starts at 06/16/14 19:31:29 ##########

# Commands to make the Process: 
# Verilog Test Fixture Template
if [runCmd "\"$cpld_bin/sch2tf\" -template \"$install_dir/ispcpld/generic/verilog/tft.tft\" -prj untitled -ext .tft mmu_gal.sch "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 19:31:30 ###########


########## Tcl recorder starts at 06/16/14 19:31:34 ##########

# Commands to make the Process: 
# VHDL Test Bench Template
if [runCmd "\"$cpld_bin/vhdl\" -tmmu_gal.vht -s mmu_gal.sch"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 19:31:34 ###########


########## Tcl recorder starts at 06/16/14 19:31:39 ##########

# Commands to make the Process: 
# Reduce Schematic Logic
if [runCmd "\"$cpld_bin/iblifopt\" -i \"mmu_gal.bl0\" -o \"mmu_gal.bl1\" -red bypin choose -sweep -collapse none -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 19:31:39 ###########


########## Tcl recorder starts at 06/16/14 19:31:47 ##########

# Commands to make the Process: 
# Update All Schematic Files
if [runCmd "\"$cpld_bin/updatesc\" mmu_gal.sch -yield"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 19:31:47 ###########


########## Tcl recorder starts at 06/16/14 19:31:53 ##########

# Commands to make the Process: 
# Link Design
if [runCmd "\"$cpld_bin/iblflink\" \"mmu_gal.bl1\" -o \"untitled.bl2\" -omod mmu_gal -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 19:31:53 ###########


########## Tcl recorder starts at 06/16/14 19:32:00 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" untitled.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" untitled.bl3 -pla -o untitled.tt2 -dev p16v8 -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" untitled.tt2 -dev p16v8 -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 19:32:01 ###########


########## Tcl recorder starts at 06/16/14 19:32:33 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"mmu_gal.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 19:32:34 ###########


########## Tcl recorder starts at 06/16/14 22:50:34 ##########

# Commands to make the Process: 
# Compile Schematic
if [runCmd "\"$cpld_bin/sch2blf\" -sup \"mmu_gal.sch\" -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"mmu_gal.bls\" -o \"mmu_gal.bl0\" -ipo -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 22:50:34 ###########


########## Tcl recorder starts at 06/16/14 22:50:44 ##########

# Commands to make the Process: 
# Generate Schematic Symbol
if [runCmd "\"$cpld_bin/naf2sym\" \"mmu_gal\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 22:50:44 ###########


########## Tcl recorder starts at 06/16/14 22:50:53 ##########

# Commands to make the Process: 
# ABEL Test Vector Template
if [runCmd "\"$cpld_bin/blif2eqn\" \"mmu_gal.bl0\" -o \"mmu_gal.abt\" -testfix -template \"$install_dir/ispcpld/plsi/abel/plsiabt.tft\" -prj untitled -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 22:50:53 ###########


########## Tcl recorder starts at 06/16/14 22:50:59 ##########

# Commands to make the Process: 
# Verilog Test Fixture Declarations
if [runCmd "\"$cpld_bin/sch2tf\" -template \"$install_dir/ispcpld/generic/verilog/tfi.tft\" -prj untitled mmu_gal.sch "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 22:50:59 ###########


########## Tcl recorder starts at 06/16/14 22:51:04 ##########

# Commands to make the Process: 
# Verilog Test Fixture Template
if [runCmd "\"$cpld_bin/sch2tf\" -template \"$install_dir/ispcpld/generic/verilog/tft.tft\" -prj untitled -ext .tft mmu_gal.sch "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 22:51:04 ###########


########## Tcl recorder starts at 06/16/14 22:51:08 ##########

# Commands to make the Process: 
# VHDL Test Bench Template
if [runCmd "\"$cpld_bin/vhdl\" -tmmu_gal.vht -s mmu_gal.sch"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 22:51:08 ###########


########## Tcl recorder starts at 06/16/14 22:51:13 ##########

# Commands to make the Process: 
# Reduce Schematic Logic
if [runCmd "\"$cpld_bin/iblifopt\" -i \"mmu_gal.bl0\" -o \"mmu_gal.bl1\" -red bypin choose -sweep -collapse none -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 22:51:13 ###########


########## Tcl recorder starts at 06/16/14 22:51:16 ##########

# Commands to make the Process: 
# Reduced Equations
if [runCmd "\"$cpld_bin/blif2eqn\" \"mmu_gal.bl1\" -o \"mmu_gal.eq1\" -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 22:51:16 ###########


########## Tcl recorder starts at 06/16/14 22:51:47 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"mmu_gal.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 22:51:47 ###########


########## Tcl recorder starts at 06/16/14 22:51:55 ##########

# Commands to make the Process: 
# Compile Schematic
if [runCmd "\"$cpld_bin/sch2blf\" -sup \"mmu_gal.sch\" -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"mmu_gal.bls\" -o \"mmu_gal.bl0\" -ipo -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 22:51:55 ###########


########## Tcl recorder starts at 06/16/14 22:52:01 ##########

# Commands to make the Process: 
# Generate Schematic Symbol
if [runCmd "\"$cpld_bin/naf2sym\" \"mmu_gal\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 22:52:01 ###########


########## Tcl recorder starts at 06/16/14 22:52:07 ##########

# Commands to make the Process: 
# ABEL Test Vector Template
if [runCmd "\"$cpld_bin/blif2eqn\" \"mmu_gal.bl0\" -o \"mmu_gal.abt\" -testfix -template \"$install_dir/ispcpld/plsi/abel/plsiabt.tft\" -prj untitled -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 22:52:08 ###########


########## Tcl recorder starts at 06/16/14 22:52:13 ##########

# Commands to make the Process: 
# Verilog Test Fixture Declarations
if [runCmd "\"$cpld_bin/sch2tf\" -template \"$install_dir/ispcpld/generic/verilog/tfi.tft\" -prj untitled mmu_gal.sch "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 22:52:13 ###########


########## Tcl recorder starts at 06/16/14 22:52:18 ##########

# Commands to make the Process: 
# Verilog Test Fixture Template
if [runCmd "\"$cpld_bin/sch2tf\" -template \"$install_dir/ispcpld/generic/verilog/tft.tft\" -prj untitled -ext .tft mmu_gal.sch "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 22:52:18 ###########


########## Tcl recorder starts at 06/16/14 22:52:24 ##########

# Commands to make the Process: 
# VHDL Test Bench Template
if [runCmd "\"$cpld_bin/vhdl\" -tmmu_gal.vht -s mmu_gal.sch"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 22:52:24 ###########


########## Tcl recorder starts at 06/16/14 22:52:28 ##########

# Commands to make the Process: 
# Reduce Schematic Logic
if [runCmd "\"$cpld_bin/iblifopt\" -i \"mmu_gal.bl0\" -o \"mmu_gal.bl1\" -red bypin choose -sweep -collapse none -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 22:52:29 ###########


########## Tcl recorder starts at 06/16/14 22:52:37 ##########

# Commands to make the Process: 
# Reduced Equations
if [runCmd "\"$cpld_bin/blif2eqn\" \"mmu_gal.bl1\" -o \"mmu_gal.eq1\" -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 22:52:37 ###########


########## Tcl recorder starts at 06/16/14 22:53:08 ##########

# Commands to make the Process: 
# Update All Schematic Files
if [runCmd "\"$cpld_bin/updatesc\" mmu_gal.sch -yield"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 22:53:08 ###########


########## Tcl recorder starts at 06/16/14 22:53:16 ##########

# Commands to make the Process: 
# Link Design
if [runCmd "\"$cpld_bin/iblflink\" \"mmu_gal.bl1\" -o \"untitled.bl2\" -omod mmu_gal -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 22:53:16 ###########


########## Tcl recorder starts at 06/16/14 22:53:21 ##########

# Commands to make the Process: 
# Linked Equations
if [runCmd "\"$cpld_bin/blif2eqn\" \"untitled.bl2\" -o \"untitled.eq2\" -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 22:53:22 ###########


########## Tcl recorder starts at 06/16/14 22:53:30 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" untitled.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" untitled.bl3 -pla -o untitled.tt2 -dev p16v8 -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" untitled.tt2 -dev p16v8 -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 22:53:30 ###########


########## Tcl recorder starts at 06/16/14 22:54:30 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/ahdl2blf\" \"mmu_gal_tst.abv\" -vec -ovec \"mmu_gal_tst.tmv\"  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fuseasm\" untitled.tt3 -dev p16v8 -o untitled.jed -ivec mmu_gal_tst.tmv -rep untitled.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj untitled -if untitled.jed -j2s -log untitled.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 22:54:31 ###########


########## Tcl recorder starts at 06/16/14 23:01:25 ##########

# Commands to make the Process: 
# Hierarchy Browser
# - none -
# Application to view the Process: 
# Hierarchy Browser
if [runCmd "\"$cpld_bin/hierbro\" \"untitled.jid\"  mmu_gal"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 23:01:25 ###########


########## Tcl recorder starts at 06/16/14 23:11:07 ##########

# Commands to make the Process: 
# Pre-Fit Equations
if [runCmd "\"$cpld_bin/blif2eqn\" untitled.tt2 -o untitled.eq3 -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 23:11:07 ###########


########## Tcl recorder starts at 06/16/14 23:12:08 ##########

# Commands to make the Process: 
# Post-Fit Equations
if [runCmd "\"$cpld_bin/blif2eqn\" untitled.tt3 -o untitled.eq4 -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 23:12:08 ###########


########## Tcl recorder starts at 06/16/14 23:19:43 ##########

# Commands to make the Process: 
# Compile Test Vectors
if [runCmd "\"$cpld_bin/ahdl2blf\" \"mmu_gal_tst.abv\" -vec -ovec \"mmu_gal_tst.tmv\" -sim Untitled  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 23:19:44 ###########


########## Tcl recorder starts at 06/16/14 23:19:49 ##########

# Commands to make the Process: 
# Compiler Listing
if [runCmd "\"$cpld_bin/ahdl2blf\" \"mmu_gal_tst.abv\" -vec -ovec \"mmu_gal_tst.tmv\" -list -sim Untitled -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 23:19:50 ###########


########## Tcl recorder starts at 06/16/14 23:19:56 ##########

# Commands to make the Process: 
# Functional Simulation
if [runCmd "\"$cpld_bin/sch2tf\" -template \"$install_dir/ispcpld/plsi/latsim/plsi.tft\" -prj untitled -ext .lsi mmu_gal.sch "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" -i \"mmu_gal.bl0\" -o \"mmu_gal.blo\" -red bypin choose -sweep -collapse none -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"mmu_gal.blo\" -o \"untitled.blh\" -omod untitled -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" \"untitled.blh\" -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" -i \"untitled.bli\" -o \"untitled.blj\" -idev PLSI -propadd -dev pla_basic -err automake.err "] {
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
-cfg oaipldtg.fdk \"mmu_gal_tst.lts\" -map \"mmu_gal.lsi\"
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

########## Tcl recorder end at 06/16/14 23:19:57 ###########


########## Tcl recorder starts at 06/17/14 00:07:18 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"mmu_gal.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/17/14 00:07:18 ###########


########## Tcl recorder starts at 06/17/14 00:08:33 ##########

# Commands to make the Process: 
# Compile Schematic
if [runCmd "\"$cpld_bin/sch2blf\" -sup \"mmu_gal.sch\" -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"mmu_gal.bls\" -o \"mmu_gal.bl0\" -ipo -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/17/14 00:08:33 ###########


########## Tcl recorder starts at 06/17/14 00:08:41 ##########

# Commands to make the Process: 
# Generate Schematic Symbol
if [runCmd "\"$cpld_bin/naf2sym\" \"mmu_gal\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/17/14 00:08:42 ###########


########## Tcl recorder starts at 06/17/14 00:08:51 ##########

# Commands to make the Process: 
# ABEL Test Vector Template
if [runCmd "\"$cpld_bin/blif2eqn\" \"mmu_gal.bl0\" -o \"mmu_gal.abt\" -testfix -template \"$install_dir/ispcpld/plsi/abel/plsiabt.tft\" -prj untitled -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/17/14 00:08:51 ###########


########## Tcl recorder starts at 06/17/14 00:08:59 ##########

# Commands to make the Process: 
# Verilog Test Fixture Declarations
if [runCmd "\"$cpld_bin/sch2tf\" -template \"$install_dir/ispcpld/generic/verilog/tfi.tft\" -prj untitled mmu_gal.sch "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/17/14 00:08:59 ###########


########## Tcl recorder starts at 06/17/14 00:09:08 ##########

# Commands to make the Process: 
# Verilog Test Fixture Template
if [runCmd "\"$cpld_bin/sch2tf\" -template \"$install_dir/ispcpld/generic/verilog/tft.tft\" -prj untitled -ext .tft mmu_gal.sch "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/17/14 00:09:08 ###########


########## Tcl recorder starts at 06/17/14 00:09:16 ##########

# Commands to make the Process: 
# VHDL Test Bench Template
if [runCmd "\"$cpld_bin/vhdl\" -tmmu_gal.vht -s mmu_gal.sch"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/17/14 00:09:17 ###########


########## Tcl recorder starts at 06/17/14 00:09:25 ##########

# Commands to make the Process: 
# Reduce Schematic Logic
if [runCmd "\"$cpld_bin/iblifopt\" -i \"mmu_gal.bl0\" -o \"mmu_gal.bl1\" -red bypin choose -sweep -collapse none -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/17/14 00:09:25 ###########


########## Tcl recorder starts at 06/17/14 00:09:35 ##########

# Commands to make the Process: 
# Reduced Equations
if [runCmd "\"$cpld_bin/blif2eqn\" \"mmu_gal.bl1\" -o \"mmu_gal.eq1\" -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/17/14 00:09:35 ###########


########## Tcl recorder starts at 06/17/14 00:09:44 ##########

# Commands to make the Process: 
# Update All Schematic Files
if [runCmd "\"$cpld_bin/updatesc\" mmu_gal.sch -yield"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/17/14 00:09:45 ###########


########## Tcl recorder starts at 06/17/14 00:09:51 ##########

# Commands to make the Process: 
# Link Design
if [runCmd "\"$cpld_bin/iblflink\" \"mmu_gal.bl1\" -o \"untitled.bl2\" -omod mmu_gal -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/17/14 00:09:52 ###########


########## Tcl recorder starts at 06/17/14 00:09:58 ##########

# Commands to make the Process: 
# Linked Equations
if [runCmd "\"$cpld_bin/blif2eqn\" \"untitled.bl2\" -o \"untitled.eq2\" -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/17/14 00:09:58 ###########


########## Tcl recorder starts at 06/17/14 00:10:12 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" untitled.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" untitled.bl3 -pla -o untitled.tt2 -dev p16v8 -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" untitled.tt2 -dev p16v8 -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/17/14 00:10:12 ###########


########## Tcl recorder starts at 06/17/14 00:11:41 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"mmu_gal.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/17/14 00:11:41 ###########


########## Tcl recorder starts at 06/17/14 00:11:52 ##########

# Commands to make the Process: 
# Link Design
if [runCmd "\"$cpld_bin/sch2blf\" -sup \"mmu_gal.sch\" -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"mmu_gal.bls\" -o \"mmu_gal.bl0\" -ipo -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" -i \"mmu_gal.bl0\" -o \"mmu_gal.bl1\" -red bypin choose -sweep -collapse none -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"mmu_gal.bl1\" -o \"untitled.bl2\" -omod mmu_gal -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/17/14 00:11:52 ###########


########## Tcl recorder starts at 06/17/14 00:12:02 ##########

# Commands to make the Process: 
# Linked Equations
if [runCmd "\"$cpld_bin/blif2eqn\" \"untitled.bl2\" -o \"untitled.eq2\" -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/17/14 00:12:03 ###########


########## Tcl recorder starts at 06/17/14 00:12:08 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" untitled.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" untitled.bl3 -pla -o untitled.tt2 -dev p16v8 -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" untitled.tt2 -dev p16v8 -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/17/14 00:12:08 ###########


########## Tcl recorder starts at 06/17/14 00:15:43 ##########

# Commands to make the Process: 
# Link Design
if [runCmd "\"$cpld_bin/sch2blf\" -sup \"mmu_gal.sch\" -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"mmu_gal.bls\" -o \"mmu_gal.bl0\" -ipo -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" -i \"mmu_gal.bl0\" -o \"mmu_gal.bl1\" -red bypin choose -sweep -collapse none -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"mmu_gal.bl1\" -o \"untitled.bl2\" -omod mmu_gal -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/17/14 00:15:43 ###########


########## Tcl recorder starts at 06/17/14 00:15:54 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" untitled.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" untitled.bl3 -pla -o untitled.tt2 -dev p20v8lcc -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" untitled.tt2 -dev p20v8lcc -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/17/14 00:15:54 ###########


########## Tcl recorder starts at 06/17/14 00:17:18 ##########

# Commands to make the Process: 
# Link Design
if [runCmd "\"$cpld_bin/sch2blf\" -sup \"mmu_gal.sch\" -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"mmu_gal.bls\" -o \"mmu_gal.bl0\" -ipo -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblifopt\" -i \"mmu_gal.bl0\" -o \"mmu_gal.bl1\" -red bypin choose -sweep -collapse none -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"mmu_gal.bl1\" -o \"untitled.bl2\" -omod mmu_gal -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/17/14 00:17:18 ###########


########## Tcl recorder starts at 06/17/14 00:17:28 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" untitled.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" untitled.bl3 -pla -o untitled.tt2 -dev p18v10g -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" untitled.tt2 -dev p18v10g -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/17/14 00:17:28 ###########


########## Tcl recorder starts at 06/17/14 00:18:06 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/ahdl2blf\" \"mmu_gal_tst.abv\" -vec -ovec \"mmu_gal_tst.tmv\"  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fuseasm\" untitled.tt3 -dev p18v10g -o untitled.jed -ivec mmu_gal_tst.tmv -rep untitled.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj untitled -if untitled.jed -j2s -log untitled.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/17/14 00:18:06 ###########


########## Tcl recorder starts at 06/25/15 12:13:22 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/sch2jhd\" \"mmu_gal.sch\" "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/25/15 12:13:22 ###########


########## Tcl recorder starts at 06/25/15 12:13:54 ##########

# Commands to make the Process: 
# Hierarchy Browser
# - none -
# Application to view the Process: 
# Hierarchy Browser
if [runCmd "\"$cpld_bin/hierbro\" \"untitled.jid\"  mmu_gal"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/25/15 12:13:54 ###########


########## Tcl recorder starts at 06/25/15 12:14:30 ##########

# Commands to make the Process: 
# Hierarchy Browser
# - none -
# Application to view the Process: 
# Hierarchy Browser
if [runCmd "\"$cpld_bin/hierbro\" \"untitled.jid\"  mmu_gal"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/25/15 12:14:30 ###########


########## Tcl recorder starts at 06/25/15 12:15:48 ##########

# Commands to make the Process: 
# Compile Schematic
if [runCmd "\"$cpld_bin/sch2blf\" -sup \"mmu_gal.sch\" -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/iblflink\" \"mmu_gal.bls\" -o \"mmu_gal.bl0\" -ipo -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/25/15 12:15:49 ###########


########## Tcl recorder starts at 06/25/15 12:16:09 ##########

# Commands to make the Process: 
# Generate Schematic Symbol
if [runCmd "\"$cpld_bin/naf2sym\" \"mmu_gal\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/25/15 12:16:09 ###########


########## Tcl recorder starts at 06/25/15 12:16:21 ##########

# Commands to make the Process: 
# ABEL Test Vector Template
if [runCmd "\"$cpld_bin/blif2eqn\" \"mmu_gal.bl0\" -o \"mmu_gal.abt\" -testfix -template \"$install_dir/ispcpld/plsi/abel/plsiabt.tft\" -prj untitled -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/25/15 12:16:21 ###########


########## Tcl recorder starts at 06/25/15 12:16:40 ##########

# Commands to make the Process: 
# Verilog Test Fixture Declarations
if [runCmd "\"$cpld_bin/sch2tf\" -template \"$install_dir/ispcpld/generic/verilog/tfi.tft\" -prj untitled mmu_gal.sch "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/25/15 12:16:41 ###########


########## Tcl recorder starts at 06/25/15 12:16:46 ##########

# Commands to make the Process: 
# Verilog Test Fixture Template
if [runCmd "\"$cpld_bin/sch2tf\" -template \"$install_dir/ispcpld/generic/verilog/tft.tft\" -prj untitled -ext .tft mmu_gal.sch "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/25/15 12:16:46 ###########


########## Tcl recorder starts at 06/25/15 12:16:51 ##########

# Commands to make the Process: 
# VHDL Test Bench Template
if [runCmd "\"$cpld_bin/vhdl\" -tmmu_gal.vht -s mmu_gal.sch"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/25/15 12:16:51 ###########


########## Tcl recorder starts at 06/25/15 12:16:59 ##########

# Commands to make the Process: 
# Reduce Schematic Logic
if [runCmd "\"$cpld_bin/iblifopt\" -i \"mmu_gal.bl0\" -o \"mmu_gal.bl1\" -red bypin choose -sweep -collapse none -pterms 8 -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/25/15 12:17:00 ###########


########## Tcl recorder starts at 06/25/15 12:17:03 ##########

# Commands to make the Process: 
# Reduced Equations
if [runCmd "\"$cpld_bin/blif2eqn\" \"mmu_gal.bl1\" -o \"mmu_gal.eq1\" -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/25/15 12:17:04 ###########


########## Tcl recorder starts at 06/25/15 12:17:21 ##########

# Commands to make the Process: 
# Update All Schematic Files
if [runCmd "\"$cpld_bin/updatesc\" mmu_gal.sch -yield"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/25/15 12:17:21 ###########


########## Tcl recorder starts at 06/25/15 12:17:28 ##########

# Commands to make the Process: 
# Link Design
if [runCmd "\"$cpld_bin/iblflink\" \"mmu_gal.bl1\" -o \"untitled.bl2\" -omod mmu_gal -family -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/25/15 12:17:28 ###########


########## Tcl recorder starts at 06/25/15 12:17:34 ##########

# Commands to make the Process: 
# Linked Equations
if [runCmd "\"$cpld_bin/blif2eqn\" \"untitled.bl2\" -o \"untitled.eq2\" -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/25/15 12:17:34 ###########


########## Tcl recorder starts at 06/25/15 12:17:40 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/iblifopt\" untitled.bl2 -red bypin choose -sweep -collapse all -pterms 8 -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/idiofft\" untitled.bl3 -pla -o untitled.tt2 -dev p16v8 -define N -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fit\" untitled.tt2 -dev p16v8 -str -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/25/15 12:17:40 ###########


########## Tcl recorder starts at 06/25/15 12:17:54 ##########

# Commands to make the Process: 
# Post-Fit Equations
if [runCmd "\"$cpld_bin/blif2eqn\" untitled.tt3 -o untitled.eq4 -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/25/15 12:17:54 ###########


########## Tcl recorder starts at 06/25/15 12:18:01 ##########

# Commands to make the Process: 
# Pre-Fit Equations
if [runCmd "\"$cpld_bin/blif2eqn\" untitled.tt2 -o untitled.eq3 -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/25/15 12:18:01 ###########


########## Tcl recorder starts at 06/25/15 12:18:08 ##########

# Commands to make the Process: 
# Create Fuse Map
if [runCmd "\"$cpld_bin/ahdl2blf\" \"mmu_gal_tst.abv\" -vec -ovec \"mmu_gal_tst.tmv\"  -def _PLSI_ _LATTICE_  -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/fuseasm\" untitled.tt3 -dev p16v8 -o untitled.jed -ivec mmu_gal_tst.tmv -rep untitled.rpt -doc brief -con ptblown -for brief -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj untitled -if untitled.jed -j2s -log untitled.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/25/15 12:18:08 ###########


########## Tcl recorder starts at 06/25/15 12:18:33 ##########

# Commands to make the Process: 
# Verilog Post-Route Simulation Model
if [runCmd "\"$cpld_bin/sch2tf\" -template \"$install_dir/ispcpld/pld/j2mod.tft\" -prj untitled -ext .btp mmu_gal.sch "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open untitled.psl w} rspFile] {
	puts stderr "Cannot create response file untitled.psl: $rspFile"
} else {
	puts $rspFile "-dev p16v8 -part LAT GAL16V8D-10LJ GAL -o untitled.tim
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/timsel\" @untitled.psl"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete untitled.psl
if [catch {open untitled._sp w} rspFile] {
	puts stderr "Cannot create response file untitled._sp: $rspFile"
} else {
	puts $rspFile "#insert -- NOTE: Do not edit this file.
#insert -- Auto generated by Post-Route Verilog Simulation Models
#insert --
#unixpath
#unixpath $install_dir/ispcpld/pld/verilog
#libfile pldlib.v
#unixpath
#vlog \"$proj_dir/untitled.vt\"
#insert -- End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" \"untitled._sp\" \"untitled.vtl\" none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete untitled._sp
if [catch {open untitled._sp w} rspFile] {
	puts stderr "Cannot create response file untitled._sp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by Post-Route Verilog Simulation Models
#insert #
#unixpath
#unixpath $install_dir/ispcpld/pld/verilog
#libfile pldlib.v
#unixpath
#vlog \"$proj_dir/untitled.vt\"
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" \"untitled._sp\" \"untitled.vatl\" none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete untitled._sp
if [runCmd "\"$cpld_bin/j2vlog\" untitled.jed -dly custom untitled.tim -pldbus default mmu_gal.btp -o untitled.vt -module mmu_gal -suppress -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/25/15 12:18:34 ###########


########## Tcl recorder starts at 06/25/15 12:18:45 ##########

# Commands to make the Process: 
# VHDL Post-Route Simulation Model
if [catch {open untitled._sp w} rspFile] {
	puts stderr "Cannot create response file untitled._sp: $rspFile"
} else {
	puts $rspFile "#insert -- NOTE: Do not edit this file.
#insert -- Auto generated by Post-Route VHDL Simulation Models
#insert --
#unixpath $proj_dir
#vcom untitled.vhq
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" \"untitled._sp\" \"untitled.vtd\" none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete untitled._sp
if [catch {open untitled._sp w} rspFile] {
	puts stderr "Cannot create response file untitled._sp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by Post-Route VHDL Simulation Models
#insert #
#unixpath $proj_dir
#vcom untitled.vhq
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" \"untitled._sp\" \"untitled.vatd\" none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete untitled._sp
if [runCmd "\"$cpld_bin/j2svhdl\" untitled.jed -dly custom untitled.tim max -pldbus default mmu_gal.btp -o untitled.vhq -module mmu_gal -suppress -err automake.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/25/15 12:18:45 ###########

