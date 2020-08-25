#!/bin/sh
##
##  '########'########::'######:::'##::: ##'########'########:'#######:::'#####:::
##  ..... ##: ##.... ##'##... ##:: ###:: ## ##.....:..... ##:'##.... ##:'##.. ##::
##  :::: ##:: ##:::: ## ##:::..::: ####: ## ##:::::::::: ##:: ##:::: ##'##:::: ##:
##  ::: ##::: ##:::: ##. ######::: ## ## ## ######::::: ##:::: #######: ##:::: ##:
##  :: ##:::: ##:::: ##:..... ##:: ##. #### ##...::::: ##::::'##.... ## ##:::: ##:
##  : ##::::: ##:::: ##'##::: ##:: ##:. ### ##::::::: ##::::: ##:::: ##. ##:: ##::
##   ######## ########:. ######::: ##::. ## ######## ########. #######::. #####:::
##  ........:........:::......::::..::::..:........:........::.......::::.....::::
##
##  Sysbios C interface library
##  P.Betti  <pbetti@lpconsul.eu>
##
##  Module: c_bios header
##
##  HISTORY:
##  -[Date]- -[Who]------------- -[What]---------------------------------------
##  28.09.18 Piergiorgio Betti   Creation date
##

USAGE=""
HELP_ARG="--help"
TOOL_CHECK="1"
TOOL_CHECK_ARG="--skip-tool-check"
JUST_CHECK=""
JUST_CHECK_ARG="--just-tool-check"

Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
NC="\e[m"               # Color Reset


check_args()
{
	BUILD="$0"
	while (( "$#" ))
	do
		argx="$1"
		case $argx in
			$TOOL_CHECK_ARG)
				TOOL_CHECK=""
				;;
			$HELP_ARG|-h)
				USAGE="1"
				;;
			*)
				USAGE="1"
				;;
		esac
		shift
	done
}

echo_tool_status()
{
	tname="$1"
	status="$2"
	printf "%-30s -" "$tname"
	if [ "$status" = "1" ]; then
		echo -e $Green OK $NC
	else
		echo -e $Red Missing $NC
	fi
}

check_tools()
{
	#Development system
	tool_desc="C/C++ Development system"
	okt=`which gcc`
	if [ -z "$okt" ]; then
		echo_tool_status "$tool_desc" "0"
	else
		echo_tool_status "$tool_desc" "1"
	fi
	#git
	tool_desc="git repository management"
	okt=`which git`
	if [ -z "$okt" ]; then
		echo_tool_status "tool_desc" "0"
	else
		echo_tool_status "$tool_desc" "1"
	fi
	#cmake
	tool_desc="cmake building tool"
	okt=`which cmake`
	if [ -z "$okt" ]; then
		echo_tool_status "tool_desc" "0"
	else
		echo_tool_status "$tool_desc" "1"
	fi
	#mzt
	tool_desc="mzt My Z80 Tools"
	okt=`which mzmac`
	if [ -z "$okt" ]; then
		echo_tool_status "tool_desc" "0"
	else
		echo_tool_status "$tool_desc" "1"
	fi
	#mzt
	tool_desc="zxcc Z80 Execution environment"
	okt=`which zxcc`
	if [ -z "$okt" ]; then
		echo_tool_status "tool_desc" "0"
	else
		echo_tool_status "$tool_desc" "1"
	fi
}

usage()
{
	echo -e "\nThis script will rebuild ZDS software from scratch.\n\n\
Usage:
`basename $0` [option(s)]\n\
\t--help or -h\t\tThis message\n\
\t--skip-tool-check\tDon't check for various tool presence\n\
\t--just-tool-check\tCheck for tool presence and quit\n"
}



# Body
check_args $*
if [ "$USAGE" = "1" ]; then
	usage
	exit 0
fi

if [ "$JUST_CHECK" = "1" ]; then
	check_tools
	exit 0
fi

if [ ! -z "$TOOL_CHECK" ]; then
	check_tools
else
	echo -e "Tool check skipped\n"
fi



