" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     https://github.com/tomtom
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Last Change: 2015-10-27
" @Revision:    31


if !exists('g:tlib#debug#backtrace')
    let g:tlib#debug#backtrace = 2   "{{{2
endif


function! tlib#debug#Trace(caller, vars, values) abort "{{{3
    if get(a:values, 0, 0)
        let msg = ['TRACE']
        if has('reltime')
            call add(msg, reltimestr(reltime()) .':')
        endif
        if g:tlib#debug#backtrace > 0
            let caller = split(a:caller, '\.\.')
            let start  = max([0, len(caller) - g:tlib#debug#backtrace - 1])
            let caller = caller[start : -1]
            if !empty(caller)
                call add(msg, join(caller, '..') .':')
            endif
        endif
        for i in range(1, len(a:vars) - 1)
            let v = substitute(a:vars[i], ',$', '', '')
            let r = string(a:values[i])
            call add(msg, v .'='. r .';')
        endfor
        echom join(msg)
    endif
endf


function! tlib#debug#Init() abort "{{{3
    command! -nargs=+ TLibTrace call tlib#debug#Trace(expand('<sfile>'), [<f-args>], [<args>])
endf

