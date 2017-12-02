#!/bin/bash - 
#===============================================================================
#
#        USAGE: ./gen_pdf.sh 
# 
#   DESCRIPTION: Build PDF pages from MD recursively
# 
#       OPTIONS: ---
#  REQUIREMENTS: find, sed, xargs, pandoc
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Sylvain Saubier (ResponSyS), mail@systemicresponse.com
#  ORGANIZATION: 
#       CREATED: 09/30/2017 10:45
#      REVISION:  ---
#===============================================================================

# TODO: --no-interactive option to deactive xargs '-p' flag
# TODO: customize the template
# `toc: true` et `lang: fr` in YAML header of MD works perfectly but:
# TODO: customize position of TOC in template

set -o nounset -o errexit

PROGRAM_NAME="gen_pdf.sh"
#BASEDIR="$HOME/Devel/Src/Web/responsyss.github.io/"
BASEDIR="."

F_TEMPL="template.pdf.pandoc"
F_TEXTES_DIR="${BASEDIR}/textes"
SEARCH_PATH=""

XARGS_FLAGS="-P4 -p"
# is log erased each time? if yes it's retarded to set it
#PANDOC_FLAGS="-f markdown --template ${BASEDIR}/${F_TEMPL} --fail-if-warnings --log=$PROGRAM_NAME.log"
PANDOC_FLAGS="-f markdown --template ${BASEDIR}/${F_TEMPL} --fail-if-warnings"

ERR_NO_CMD=127
ERR_WRONG_WORKING_DIR=101
ERR_NO_FILE=40

# $1 = message (string)
m_say() {
	echo "$PROGRAM_NAME: $1"
}
# $1 = error message (string), $2 = return code (int)
fn_err() {
	m_say "$1" >&2
	exit $2
}
# $1 = command to test (string)
fn_needCmd() {
	if ! command -v "$1" > /dev/null 2>&1
		then fn_err "need '$1' (command not found)" $ERR_NO_CMD
	fi
}
# $1 = file to test (string)
fn_needFile() {
	if ! test -e "$1" > /dev/null 2>&1
		then fn_err "need '$1' (file or directory not found)" $ERR_NO_FILE
	fi
}

fn_help() {
	cat 1>&2 << EOF
USAGE
    ./$PROGRAM_NAME [all|PATH]

OPTIONS
    all         recursively convert all MD files to PDF in ${F_TEXTES_DIR}/ (default)
    {PATH}      recursively convert all MD files to PDF in PATH

EXAMPLE
    $ ./$PROGRAM_NAME textes/jacques_camatte/
        Build textes/jacques_camatte/*.md to textes/jacques_camatte/*.pdf

AUTHOR
    Written by Sylvain Saubier (<http://SystemicResponse.com>)

REPORTING BUGS
    Mail at: <feedback@systemicresponse.com>
EOF
}

# « xargs c'est la vie » -- Mt, 12:24
# « Le gras c'est la vie » -- Karadoc, Kaamelott 
fn_genTextes() {
	find $SEARCH_PATH -type f -name "*.md" | sort | uniq | sed 's/[.]md$//' | xargs -I'{}' $XARGS_FLAGS pandoc $PANDOC_FLAGS   {}.md -o {}.pdf
}

fn_printParams() {
	cat 1>&2 << EOF
F_TEMPL        $F_TEMPL
F_TEXTES_DIR   $F_TEXTES_DIR
SEARCH_PATH    $SEARCH_PATH
XARGS_FLAGS    $XARGS_FLAGS
PANDOC_FLAGS   $PANDOC_FLAGS
EOF
}

fn_needCmd "find"
fn_needCmd "sed"
fn_needCmd "xargs"
fn_needCmd "pandoc"
fn_needFile "$F_TEMPL"
fn_needFile "$F_TEXTES_DIR"

# cd to script directory
cd "` dirname "$0" `" || fn_err "can't 'cd' to script dir" $ERR_WRONG_WORKING_DIR
m_say "current directory: `pwd`"

# USE GETOPT instead
# Arguments parsing
if test $# -eq 0; then
	fn_help
	exit
fi
while test $# -ge 1; do
	case "$1" in
		"all")
			# adds "textes/" to SEARCH_PATH
			SEARCH_PATH="$SEARCH_PATH $F_TEXTES_DIR"
			;;
		"-h"|"--help")
			fn_help
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
	fn_needFile "$FILE"
done

fn_printParams

m_say "generating..."
fn_genTextes
m_say "done!"

exit
