#!/bin/bash - 
#===============================================================================
#         USAGE: ./pdc-gen.sh --help
# 
#   DESCRIPTION: RTFM (--help)
#  REQUIREMENTS: find, xargs, sed, pandoc
#        AUTHOR: Sylvain S. (ResponSyS), mail@sylsau.com
#       CREATED: 11/27/2017 16:07
#===============================================================================
################################################################################
# TODO: avoid bash aliases by executing `which find` instead of `find` etc.
################################################################################

# Set debug parameters
[[ $DEBUG ]] && set -o nounset
set -o errexit -o pipefail

SCRIPT_NAME="${0##*/}"
VERSION=0.9

# Format characters
FMT_BOLD='\e[1m'
FMT_UNDERL='\e[4m'
FMT_OFF='\e[0m'
# Error codes
ERR_WRONG_ARG=2
ERR_NO_FILE=127
# Return value
RET=

# Root path for searching files
SEARCH_PATH=
# Name of new converted files (without the extension); if unset, new files will 
# have the same filename
FNAME_NEW=
# Extension of input files (without the dot)
EXT_IN="pdc"
# List of output files extension(s) (without the dot) separated by ':' (e.g. 
#  pdf:html:epub, etc.)
EXT_OUT=
# Number of simultaneous conversions (through `xargs -P${JOBS}`)
JOBS=4
# Pandoc additional arguments (--template, etc.)
PANDOC_ARGS="--fail-if-warnings"
# Prefix prepended to output pathes
PREFIX=
## xargs flags
# -L1: run command for each line; -r: don't run if empty line
# As to be a fucking array otherwise it fucks up for some reason?
XARGS_FLAGS=( -L1 -r )
XARGS_JOBS="-P${JOBS}"
# Set to '-p' or '--interactive' if interactive mode, unset otherwise
XARGS_PROMPT=
# Set if dry-run mode, unset if normal mode
DRY_RUN=

# Test if a file exists (dir or not)
# $1: path to file (string)
fn_need_file() {
	[[ -e "$1" ]] || fn_exit_err "need '$1' (file not found)" $ERR_NO_FILE
}
# Test if a dir exists
# $1: path to dir (string)
fn_need_dir() {
	[[ -d "$1" ]] || fn_exit_err "need '$1' (directory not found)" $ERR_NO_FILE
}
# Test if a command exists
# $1: command (string)
fn_need_cmd() {
	command -v "$1" > /dev/null 2>&1
	[[ $? -eq 0 ]] || fn_exit_err "need '$1' (command not found)" $ERR_NO_FILE
}
# $1: message (string)
m_say() {
	echo -e "$SCRIPT_NAME: $1"
	#echo -e "$1"
}
# $1: debug message (string)
m_say_debug() {
	echo -e "[DEBUG] $1"
}
# Exit with message and provided error code
# $1: error message (string), $2: return code (int)
fn_exit_err() {
	m_say "${FMT_BOLD}ERROR${FMT_OFF}: $1" >&2
	exit $2
}
# Print help
fn_show_help() {
    cat << EOF
$SCRIPT_NAME $VERSION
    Bulk pandoc conversion tool (ideal for automation).
    Turn all matching *.EXT_IN files into *.EXT_OUT.
USAGE
    $SCRIPT_NAME -o EXT_OUT [OPTIONS] [SEARCH_PATH]
	where SEARCH_PATH is the path under which files will be searched
        (default: "${SEARCH_PATH:-./}")
OPTIONS
    -i EXT_IN           set extension of input files (default: "$EXT_IN")
    -o EXT_OUT          set extension(s) of output files; EXT_OUT is a 
                         ':'-separated list of extensions
    -n FNAME            if set, change filenames of converted files to 
                         FNAME.EXT_OUT
    -j JOBS             set the number of simultaneous parallel conversions
			 (default: $JOBS) (NOTE: see PARALLEL PROCESSING)
    -p, --interactive   prompt the user about whether to run each command line
    --dry-run           output command lines without executing them
    -a PANDOC_ARGS      set additional arguments to 'pandoc' invocation
                         (default: "$PANDOC_ARGS")
    --prefix PREFIX     prepend PREFIX to output pathes
PARALLEL PROCESSING
    The '-j' flag allows for parallel processing of potentially shared resources.
    Be sure to not output to the same file otherwise result are likely to be 
    mixed up (though pandoc seems to handle it well).
EXAMPLE
    $ ./$SCRIPT_NAME   -j 4   -n index   -i pdc   -o html:pdf:epub \\
              -a "--template ./tmpl.pandoc"       --prefix "_site/"
        Convert a file like "./marx/das_kapital.pdc" to:
         1) "_site/marx/index.html"
         2) "_site/marx/index.pdf"
         3) "_site/marx/index.epub"
        using the pandoc template "./tmpl.pandoc".
AUTHOR
    Written by Sylvain Saubier (<http://SystemicResponse.com>)
    Report bugs at: <feedback@sylsau.com>
EOF
}

fn_print_params() {
	cat 1>&2 << EOF
 EXT_IN         $EXT_IN
 EXT_OUT        $EXT_OUT
 JOBS           $JOBS
 FNAME_NEW      $FNAME_NEW
 PREFIX         $PREFIX
 SEARCH_PATH    $SEARCH_PATH
 XARGS_PROMPT   $XARGS_PROMPT
 PANDOC_ARGS    $PANDOC_ARGS
EOF
}

# Count number of arguments for pandoc invocation via xargs
# Deprecated: just use '-L1' xargs flag
#fn_count_args() {
#	XARGS_CMD_COUNT=0
#	local PANDOC_ARGS_MODEL="$PANDOC_ARGS --resource-path=PATH IN -o OUT"
#	for arg in $PANDOC_ARGS_MODEL; do
#		# (( XARGS_CMD_COUNT++ )) returns 1 when XCC==0, which causes script to exit on `set -o errexit`
#		(( ++XARGS_CMD_COUNT ))
#	done
#	[[ $DEBUG ]] && m_say_debug "Number of pandoc arguments for xargs: $XARGS_CMD_COUNT"
#}
# Ensure recent enough 'pandoc' version
fn_check_pandoc_ver() {
	[[ "`pandoc --version | head -1 | cut -d' ' -f2- | cut -d'.' -f1`" = "2" ]] || fn_exit_err "need pandoc version 2" $ERR_WRONG_ARG
}

# return: result of 'find' invocation (string)
fn_find_files() {
	# <EXTOUT> is placeholder for extension of output files
	# "[.]$EXT_IN[.]<EXTOUT>" will then be replaced by $EXT_OUT so don't remove the "[.]$EXT_IN" part
	local FNAME_OUT="%p.<EXTOUT>"
	[[ $PREFIX ]] && PREFIX="${PREFIX}/"
	[[ $FNAME_NEW ]] && FNAME_OUT="%h/$FNAME_NEW.$EXT_IN.<EXTOUT>"
	RET="$(find $SEARCH_PATH -type f -name \*[.]${EXT_IN} -printf "$PANDOC_ARGS --resource-path='%h' '%p' -o '${PREFIX}${FNAME_OUT}'\n")"
}

# $1: list of files to convert, '\n'-separated (string)
fn_gen_files() {
	local IFS_OLD=$IFS
	local CMD="pandoc"
	local XARGS_VERBOSE="-t"
	IFS=':'
	# On dry-run, just echo the command-lines without prompting
	[[ $DRY_RUN ]] && { XARGS_PROMPT= ; CMD=(echo $CMD); XARGS_VERBOSE= ; }
	for EXT in $EXT_OUT; do
		echo -en "\t"
		echo "$1" | sort | uniq | sed "s/[.]$EXT_IN[.]<EXTOUT>/.$EXT/" | 
			xargs ${XARGS_FLAGS[@]} $XARGS_VERBOSE $XARGS_JOBS $XARGS_PROMPT ${CMD[@]}
	done
	IFS=$IFS_OLD
}

main() {
	fn_need_cmd "pandoc"
	fn_need_cmd "grep"
	fn_check_pandoc_ver
	fn_need_cmd "sed"
	fn_need_cmd "find"
	fn_need_cmd "xargs"
	fn_need_cmd "sort"
	fn_need_cmd "uniq"

	# PARSE ARGUMENTS
	[[ $# -eq 0 ]] && { fn_show_help; exit; }
	while [[ $# -ge 1 ]]; do
		case "$1" in
			"-n")
				[[ $2 ]] || fn_exit_err "missing argument to '-n'" $ERR_WRONG_ARG
				shift
				FNAME_NEW="$1"
				;;
			"-i")
				[[ $2 ]] || fn_exit_err "missing argument to '-i'" $ERR_WRONG_ARG
				shift
				EXT_IN="$1"
				;;
			"-o")
				[[ $2 ]] || fn_exit_err "missing argument to '-o'" $ERR_WRONG_ARG
				shift
				EXT_OUT="$1"
				;;
			"-j")
				[[ $2 ]] || fn_exit_err "missing argument to '-j'" $ERR_WRONG_ARG
				shift
				XARGS_JOBS="-P${1}"
				;;
			"--interactive"|"-p")
				XARGS_PROMPT=$1
				;;
			"--dry-run")
				DRY_RUN=1
				;;
			"-a")
				[[ $2 ]] || fn_exit_err "missing argument to '-a'" $ERR_WRONG_ARG
				shift
				PANDOC_ARGS="$1"
				;;
			"--prefix")
				shift
				PREFIX="$1"
				;;
			"-h"|"--help")
				fn_show_help
				exit
				;;
			*)
				# adds arg to search pathes
				SEARCH_PATH="$SEARCH_PATH $1"
				;;
		esac	# --- end of case ---
		# Delete $1
		shift
	done

	for FILE in $SEARCH_PATH ; do
		fn_need_file "$FILE"
	done

	[[ $EXT_IN ]]  || fn_exit_err "extension for input files (EXT_IN) not set" 		$ERR_WRONG_ARG
	[[ $EXT_OUT ]] || fn_exit_err "extension(s) for output files (EXT_OUT) not set" 	$ERR_WRONG_ARG

	[[ $DEBUG ]] && { m_say_debug "Parameters:"; fn_print_params; }
	[[ $DRY_RUN ]] && m_say "This is a dry-run; no file will be written!"

	m_say "Searching for files to convert in \"${SEARCH_PATH:-./}\"..."
	fn_find_files
	[[ -n "$RET" ]] || fn_exit_err "no file was found matching your criterias (**.$EXT_IN -> **.{$EXT_OUT} under ${SEARCH_PATH:-./})" $ERR_NO_FILE
	[[ $DEBUG ]] && m_say_debug "FIND list:\n$RET"
	[[ $DRY_RUN ]] && m_say "Commands:" || m_say "Converting..."
	#fn_count_args
	fn_gen_files "$RET"
	m_say "All done!"
}

main "$@"
