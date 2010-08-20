" Filter_seq.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2008-11-25.
" @Last Change: 2009-02-15.
" @Revision:    0.0.22

let s:save_cpo = &cpo
set cpo&vim


let s:prototype = tlib#Filter_cnf#New({'_class': ['Filter_seq'], 'name': 'seq'}) "{{{2

" The search pattern for |tlib#input#List()| is interpreted as a 
" disjunction of 'magic' regular expressions with the exception of a dot 
" ".", which is interpreted as ".\{-}".
" The pattern is a '/magic' regexp pattern.
function! tlib#Filter_seq#New(...) "{{{3
    let object = s:prototype.New(a:0 >= 1 ? a:1 : {})
    return object
endf


" :nodoc:
function! s:prototype.Match(world, text) dict "{{{3
    " TLogVAR a:text
    for rx in a:world.filter_neg
        if a:text !~ rx
            " TLogDBG "filter_neg ". rx
            return 1
        endif
    endfor
    for rx in a:world.filter_pos
        if a:text =~ rx
            " TLogDBG "filter_pos ". rx
            return 1
        endif
    endfor
    return 0
endf


" :nodoc:
function! s:prototype.DisplayFilter(filter) dict "{{{3
    let filter1 = deepcopy(a:filter)
    call map(filter1, '"(". join(reverse(v:val), "_") .")"')
    return join(reverse(filter1), ' OR ')
endf


" :nodoc:
function! s:prototype.SetFrontFilter(world, pattern) dict "{{{3
    let a:world.filter[0] = map(reverse(split(a:pattern, '\s*|\s*')), 'join(split(v:val, ''\.''), ''.\{-}'')') + a:world.filter[0][1 : -1]
endf


" :nodoc:
function! s:prototype.PushFrontFilter(world, char) dict "{{{3
    let cc = nr2char(a:char)
    if cc == '.'
        let a:world.filter[0][0] .= '.\{-}'
    else
        let a:world.filter[0][0] .= nr2char(a:char)
    endif
endf


" :nodoc:
function! s:prototype.ReduceFrontFilter(world) dict "{{{3
    let flt = a:world.filter[0][0]
    if flt =~ '\.\\{-}$'
        let a:world.filter[0][0] = flt[0:-6]
    else
        let a:world.filter[0][0] = flt[0:-2]
    endif
endf


" :nodoc:
function! s:prototype.FilterRxPrefix() dict "{{{3
    return ''
endf


" :nodoc:
function! s:prototype.CleanFilter(filter) dict "{{{3
    return substitute(a:filter, '.\\{-}', '.', 'g')
endf



let &cpo = s:save_cpo
unlet s:save_cpo
