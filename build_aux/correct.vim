" Vim script for typographic correction of texts

:set laststatus=2

" should be "[NAME_OF_SCRIPT] STARTING..."
:echomsg "STARTING TYPOGRAPHIC CORRECTION"

" not a space, nor a YAML parameter like '^title', '^date' '^author' '^year' '^subtitle' etc. , nor '\&nbsp\;', nor on footnote like "[^this_ref]: THAT"
:%s/\([^ ]\)\([:;!?]\)/\1\&nbsp;\2/gc
" Correct form more like
:%s/\(\&nbsp;\)\([:;!?]\)/\1\&nbsp;\2/gc
