" Vim script for typographic correction of texts
" TODO: improve verbosity : make vim status line display the current replacement being processed
" TODO: make vim stop on errors
" TODO: improve testing process

let g:SCRIPT_NAME='correct.vim'
set laststatus=2
" Retrieve original statusline format
let s:stl_orig = &statusline

"
" Display a message to the statusline
" message (string), current step number, total step number
"
function! s:f_say ( msg )
 	"let &statusline = '['.g:SCRIPT_NAME.'] '.a:msg.' (phase '.a:step_num.'/'.a:step_tot.') in "%f" (%p%%)'
	let &statusline = '['.g:SCRIPT_NAME.'] '.a:msg.' in "%f" (%p%%)'
	echomsg '['.g:SCRIPT_NAME.'] '.a:msg
endfunc


echomsg '['.g:SCRIPT_NAME.'] STARTING...'

" NOTE: '&' MUST NOT be escaped in the search pattern and MUST BE escaped in the
"  replacement pattern

" NON-BREAKABLE SPACES ('&nbsp;') BEFORE [?;:!]
call s:f_say('CORRECTING NON-BREAKABLE SPACES (1/3)')
" ';' (not after '&nbsp[;]?', with space before or not) -> '&nbsp;;'
:%s/\(&nbsp[;]\?\)\@<![ ]*;/\&nbsp;;/gc
":%s/\(&nbsp[;]\?\)\@<!;/\&nbsp;;/gc
call s:f_say('CORRECTING NON-BREAKABLE SPACES (2/3)')
" ':' (not after '&nbsp;', nor YAML parameter like '^title', '^date', etc, nor footnote like '[^this_ref]: THAT', with space before or not) -> '&nbsp;:'
:%s/\(&nbsp;\|^layout\|^toc\|^title\|^subtitle\|^nav\|^author\|^date\|^year\|^month\|^\[\^[^\]]\+\]\)\@<![ ]*:/\&nbsp;:/gc
call s:f_say('CORRECTING NON-BREAKABLE SPACES (3/3)')
" '([!?])' (not after '&nbsp;', with space before or not) -> '&nbsp;\1'
:%s/\(&nbsp;\)\@<![ ]*\([?!]\)/\&nbsp;\2/gc

" SPACES AFTER [?,;.:!]
call s:f_say('CORRECTING SPACES')
" ';(\W)' (not after '&nbsp') -> '&nbsp;; \1'
:%s/\(&nbsp\)\@<!;\([^ ]\)/\&nbsp;; \2/gc
" '([?,.:!])(\W)' -> '\1 \2'
":%s/\([?,.:!]\)\([^ \_$]\)/\1 \2/gc

" GUILLEMETS
call s:f_say('CORRECTING GUILLEMETS (1/2)')
:%s/«[ ]*\(\w\|-\|(\|\[\)/«\&nbsp;\1/gc
call s:f_say('CORRECTING GUILLEMETS (2/2)')
:%s/\(&nbsp;\)\@<![ ]*»/\&nbsp;»/gc

" ACCENTUATED CAPITAL LETTERS [ÉÈÀ]
call s:f_say('CORRECTING ACCENTUATED CAPITAL LETTERS')
"' A ' -> ' À '
:%s/\(^\| \)A[ ]/\1À /gc

" DOUBLE SPACES
call s:f_say('CORRECTING DOUBLE SPACES (1/2)')
:%s/[ ]\+&nbsp;/\&nbsp;/gc
call s:f_say('CORRECTING DOUBLE SPACES (2/2)')
:%s/&nbsp;[ ]\+/\&nbsp;/gc

call s:f_say('CORRECTING MINOR THINGS (1/3)')
" EXPOSANTS
:%s/\([IVX0-9]\)\(ème\|er\)/\1<sup>\2<\/sup>/gc
call s:f_say('CORRECTING MINOR THINGS (2/3)')
" FAUTE DE FRAPPES
:%s/\([Cc]\)'est [aà] dire/\1'est-à-dire/gc
:%s/Etat/État/gc
call s:f_say('CORRECTING MINOR THINGS (3/3)')
" NDLR
:%s/ndlr/*NDLR*/gic

call s:f_say('CHECKING SPELL')
" CHECKING SPELL
setlocal spelllang=fr spell

echomsg '['.g:SCRIPT_NAME.'] ALL DONE!'

let &statusline = s:stl_orig
