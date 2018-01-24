" Vim script for typographic correction of texts
" TODO: improve verbosity
" TODO: make vim status line display the current replacement being processed
" TODO: make vim stop on errors
" TODO: improve testing process

:let SCRIPT_NAME='correct.vim'

:set laststatus=2

:echomsg "[".SCRIPT_NAME."] STARTING TYPOGRAPHIC CORRECTION"

" NOTE: '&' MUST NOT be escaped in the search pattern and MUST BE escaped in the
"  replacement pattern

" NON-BREAKABLE SPACES ('&nbsp;') BEFORE [?;:!]
:echomsg "[".SCRIPT_NAME."] CORRECTING NON-BREAKABLE SPACES"
" ';' (not after '&nbsp[;]?') -> '&nbsp;;'
:%s/\(&nbsp[;]\?\)\@<!;/\&nbsp;;/gc
" ':' (not after '&nbsp;', nor YAML parameter like '^title', '^date', etc, nor footnote like '[^this_ref]: THAT') -> '&nbsp;:'
:%s/\(&nbsp;\|^layout\|^toc\|^title\|^subtitle\|^author\|^date\|^year\|^month\|^\[\^[^\]]\+\]\)\@<!:/\&nbsp;:/gc
" '([!?])' (not after '&nbsp;') -> '&nbsp;\1'
:%s/\(&nbsp;\)\@<!\([?!]\)/\&nbsp;\2/gc

" SPACES AFTER [?,;.:!]
:echomsg "[".SCRIPT_NAME."] CORRECTING SPACES"
" ';(\W)' (not after '&nbsp') -> '&nbsp;; \1'
:%s/\(&nbsp\)\@<!;\([^ ]\)/\&nbsp;; \2/gc
" '([?,.:!])(\W)' -> '\1 \2'
":%s/\([?,.:!]\)\([^ \_$]\)/\1 \2/gc

" ACCENTUATED CAPITAL LETTERS [ÉÈÀ]
:echomsg "[".SCRIPT_NAME."] CORRECTING ACCENTUATED CAPITAL LETTERS"
"' A ' -> ' À '
:%s/\(^\| \)A[ ]/\1À /gc

" GUILLEMETS
:%s/\(&nbsp;\)\@<![ ]*»/\&nbsp;»/gc
:%s/«[ ]*\(\w\)/«\&nbsp;\1/gc

" DOUBLE SPACES
:%s/[ ]\+&nbsp;/\&nbsp;/gc
:%s/&nbsp;[ ]\+/\&nbsp;/gc

" EXPOSANTS
:%s/\([IVX0-9]\)\(ème\|er\)/\1<sup>\2<\/sup>/gc

" FAUTE DE FRAPPES
:%s/\([Cc]\)'est [aà] dire/\1'est-à-dire/gc

" NDLR
:%s/ndlr/*NDLR*/gic
