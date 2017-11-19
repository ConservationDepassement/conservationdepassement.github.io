#!/bin/bash - 
#===============================================================================
#
#         USAGE: ./gen_pdf.sh 
# 
#   DESCRIPTION: Build PDF pages recursively
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Sylvain Saubier (ResponSyS), mail@systemicresponse.com
#  ORGANIZATION: 
#       CREATED: 09/30/2017 10:45
#      REVISION:  ---
#===============================================================================

# TODO: NOT WORKING YET

set -o nounset -o errexit

PROGRAM_NAME="gen.sh"
#BASEDIR="$HOME/Devel/Src/Web/responsyss.github.io/"
BASEDIR="."

F_TEMPL="texte.pdf.pandoc"
F_TEXTES_DIR="textes"
SEARCH_PATH="$F_TEXTES_DIR"

ERR_NO_CMD=127
ERR_WRONG_WORKING_DIR=101
ERR_NO_FILE=40

# $1 = message (string)
fn_say() {
    echo "$PROGRAM_NAME: $1"
}
# $1 = error message (string), $2 = return code (int)
fn_err() {
    fn_say "$1" >&2
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
    if ! test -f "$1" > /dev/null 2>&1
    then fn_err "need '$1' (file not found)" $ERR_NO_FILE
    fi
}

fn_help() {
    cat 1>&2 << EOF
USAGE
    ./$PROGRAM_NAME [textes|PATH]

OPTIONS
    textes      recursively convert all MD files to PDF in /textes/ (default)
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

fn_genTextes() {
    find $SEARCH_PATH -name "*.pdc" -execdir echo \
        pandoc -t pdf --template ${BASEDIR}/${F_TEMPL} {} -o {}.pdf \;
    find $SEARCH_PATH -name "*.pdc" -execdir \
        pandoc -t pdf --template ${BASEDIR}/${F_TEMPL} {} -o {}.pdf \;
}

fn_needCmd "find"
fn_needCmd "pandoc"
fn_needFile "$F_TEMPL"
fn_needFile "$F_TEXTES_DIR"

# cd to script directory
cd "` dirname "$0" `" || fn_err "can't 'cd' to script dir" $ERR_WRONG_WORKING_DIR
fn_say "current directory: `pwd`"

# USE GETOPT instead
# Arguments parsing
if test $# -eq 0; then
    fn_help
    exit
fi
while test $# -ge 1; do
    case "$1" in
        "textes")
		# adds "textes/" to SEARCH_PATH
		SEARCH_PATH="$SEARCH_PATH $F_TEXTES_DIR"
            ;;
        *)
		# adds arg to search pathes
            ;;
    esac	# --- end of case ---
    # Delete $1
    shift
done

# if all files in SEARCH_PATH are existing files
# for f in $SEARCH_PATH ; do
# 	if not test -f $f
# 		fn_help
# 		exit
# done

fn_say "generating..."
fn_genTextes
fn_say "done!"

exit
