" Filter_fuzzy.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2008-11-25.
" @Last Change: 2009-02-15.
" @Revision:    0.0.31

let s:save_cpo = &cpo
set cpo&vim


let s:prototype = tlib#Filter_cnf#New({'_class': ['Filter_fuzzy'], 'name': 'fuzzy'}) "{{{2

" Support for "fuzzy" pattern matching in |tlib#input#List()|. 
" Characters are interpreted as if connected with '.\{-}'.
function! tlib#Filter_fuzzy#New(...) "{{{3
    let object = s:prototype.New(a:0 >= 1 ? a:1 : {})
    return object
endf


" :nodoc:
function! s:prototype.DisplayFilter(filter) dict "{{{3
    " TLogVAR a:filter
    let filter1 = deepcopy(a:filter)
    call map(filter1, '"{". join(reverse(v:val), " OR ") ."}"')
    return join(reverse(filter1), ' AND ')
endf


" :nodoc:
function! s:prototype.SetFrontFilter(world, pattern) dict "{{{3
    let a:world.filter[0] = map(reverse(split(a:pattern, '\s*|\s*')), 'join(map(split(v:val, ''\zs''), ''tlib#rx#Escape(v:val, "V")''), ''\.\{-}'')') + a:world.filter[0][1 : -1]
    endif
endf


" :nodoc:
function! s:prototype.PushFrontFilter(world, char) dict "{{{3
    let ch = tlib#rx#Escape(nr2char(a:char), 'V')
    if empty(a:world.filter[0][0])
        let a:world.filter[0][0] .= ch
    else
        let a:world.filter[0][0] .= '\.\{-}'. ch
    endif
endf


" :nodoc:
function! s:prototype.ReduceFrontFilter(world) dict "{{{3
    let a:world.filter[0][0] = substitute(a:world.filter[0][0], '\(\\\.\\{-}\)\?.$', '', '')
endf


" :nodoc:
function! s:prototype.CleanFilter(filter) dict "{{{3
    return substitute(a:filter, '\\\.\\{-}', '', 'g')
endf



let &cpo = s:save_cpo
unlet s:save_cpo
