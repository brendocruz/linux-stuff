#!/bin/bash


readonly -A OPT_MODES=(
	b    1    # bold
	t    2    # dim or faint
	i	 3    # italic
	u    4    # underline
	k    5    # blinking
	v    7    # reverse or inverse
	h    8    # hidden or invisible
	s    9    # strikethrough
)

readonly -A CODE_COLORS=(
	black    0
	red      1
	green    2
	yellow   3
	blue     4
	magenta  5
	cyan     6
	white    7
	default  9
)

readonly PFX_MODE_RESET=2
readonly -A OPT_PFX=(
	r   0    # reset all
	d	3    # dim_fg
	D	4    # dim_bg
	l	9    # bright_fg
	L	10   # bright_bg
)


function get_color() {

	# Get all the options.
	IFS=''
	local SET_MODES="${!OPT_MODES[*]}"
	local RES_MODES="${SET_MODES@U}"
	local PFX_FLAGS="${!OPT_PFX[*]}"
	local COLORS_FLAGS="f:g:"
	local ALL_OPTIONS="${SET_MODES}${RES_MODES}${PFX_FLAGS}${COLORS_FLAGS}"
	unset IFS


	local RCV_OPTS=''
	local RCV_FG=''
	local RCV_BG=''
	# Get the function arguments.
	while getopts ${ALL_OPTIONS} OPTION
	do
		RCV_OPTS+=${OPTION}
		case ${OPTION} in
			f) RCV_FG=${OPTARG} ;;
			g) RCV_BG=${OPTARG} ;;
		esac
	done


	if echo ${RCV_OPTS} | grep 'r'
	then
		RETURN="\033[0m"
		return 0
	fi


	# Process function arguments.
	# If a no valid color name is specified, reset to the default color.
	local FG_COLOR=''
	if [[ -v "CODE_COLORS[${RCV_FG}]" ]]
	then
		FG_COLOR=${CODE_COLORS[${RCV_FG}]}
	else
		FG_COLOR=${CODE_COLORS['default']}
	fi

	local BG_COLOR=''
	if [[ -v "CODE_COLORS[${RCV_BG}]" ]]
	then
		BG_COLOR=${CODE_COLORS[${RCV_BG}]}
	else
		BG_COLOR=${CODE_COLORS['default']}
	fi

	# If no color "ton" is specified, set to the default.
	declare -a FG_FLAGS=( d $(echo ${RCV_OPTS} | grep -o [dl]) )
	declare -a BG_FLAGS=( D $(echo ${RCV_OPTS} | grep -o [DL]) )
	local FG_PFX=${OPT_PFX[${FG_FLAGS[-1]}]}
	local BG_PFX=${OPT_PFX[${BG_FLAGS[-1]}]}

	local FG="${FG_PFX}${FG_COLOR}"
	local BG="${BG_PFX}${BG_COLOR}"


	local PATTERN="[${PFX_FLAGS}fg]"
	local RCV_MODES=${RCV_OPTS//${PATTERN}}


	local MODES=''
	for MODE in $(echo ${RCV_MODES} | fold -w 1)
	do

		if [[ ${MODE} =~ [A-Z] ]]
		then
			local TO_LOWER=${MODE@L}
			local MODE_CODE=${OPT_MODES[${TO_LOWER}]}
			MODES+="${PFX_MODE_RESET}${MODE_CODE};"
		else
			local MODE_CODE=${OPT_MODES[${MODE}]}
			MODES+="${MODE_CODE};"
		fi
	done

	RETURN="\033[${MODES}${FG};${BG}m"
}


# Calls the function if the script is called with arguments.
if [[ ${#@} -gt 0 ]]
then
	get_color "${@}"
	echo ${RETURN}
fi
