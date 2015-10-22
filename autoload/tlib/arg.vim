" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Last Change: 2015-10-22.
" @Revision:    121


" :def: function! tlib#arg#Get(n, var, ?default="", ?test='')
" Set a positional argument from a variable argument list.
" See tlib#string#RemoveBackslashes() for an example.
function! tlib#arg#Get(n, var, ...) "{{{3
    let default = a:0 >= 1 ? a:1 : ''
    let atest   = a:0 >= 2 ? a:2 : ''
    " TLogVAR default, atest
    if !empty(atest)
        let atest = ' && (a:'. a:n .' '. atest .')'
    endif
    let test = printf('a:0 >= %d', a:n) . atest
    return printf('let %s = %s ? a:%d : %s', a:var, test, a:n, string(default))
endf


" :def: function! tlib#arg#Let(list, ?default='')
" Set a positional arguments from a variable argument list.
" See tlib#input#List() for an example.
function! tlib#arg#Let(list, ...) "{{{3
    let default = a:0 >= 1 ? a:1 : ''
    let list = map(copy(a:list), 'type(v:val) == 3 ? v:val : [v:val, default]')
    let args = map(range(1, len(list)), 'call("tlib#arg#Get", [v:val] + list[v:val - 1])')
    return join(args, ' | ')
endf


" :def: function! tlib#arg#Key(dict, list, ?default='')
" See |:TKeyArg|.
function! tlib#arg#Key(list, ...) "{{{3
    let default = a:0 >= 1 ? a:1 : ''
    let dict = a:list[0]
    let list = map(copy(a:list[1:-1]), 'type(v:val) == 3 ? v:val : [v:val, default]')
    let args = map(list, '"let ". v:val[0] ." = ". string(get(dict, v:val[0], v:val[1]))')
    " TLogVAR dict, list, args
    return join(args, ' | ')
endf


" :def: function! tlib#arg#StringAsKeyArgs(string, ?keys=[], ?evaluate=0, ?sep=':', ?booleans=0)
function! tlib#arg#StringAsKeyArgs(string, ...) "{{{1
    TVarArg ['keys', {}], ['evaluate', 0], ['sep', ':'], ['booleans', 0]
    let keyargs = {}
    let args = split(a:string, '\\\@<! ')
    let key_rx = booleans ? '\([-+]\?\w\+\)' : '\(\w\+\)'
    let arglist = map(args, 'matchlist(v:val, ''^\%('. key_rx . sep .'\(.*\)\|\(.*\)\)$'')')
    " TLogVAR a:string, args, arglist
    let pos = -1
    for matchlist in arglist
        if !empty(matchlist[3])
            if booleans && matchlist[3] =~ '^[-+]'
                let key = substitute(matchlist[3], '^[-+]', '', '')
                let val = matchstr(matchlist[3], '^[-+]')
                let keyargs[key] = val ==# '+'
            else
                let pos += 1
                let keyargs[pos] = matchlist[3]
            endif
        else
            let [match, key, val; rest] = matchlist
            if empty(keys) || has_key(keys, key)
                let val = substitute(val, '\\\\', '\\', 'g')
                if evaluate
                    let val = eval(val)
                endif
                let keyargs[key] = val
            else
                echom 'Unknown key: '. key .'='. val
            endif
        endif
    endfor
    if pos >= 0
        let keyargs['__posargs__'] = range(0, pos)
    endif
    return keyargs
endf


function! tlib#arg#StringAsKeyArgsEqual(string) "{{{1
    return tlib#arg#StringAsKeyArgs(a:string, [], 0, '=', 1)
endf


function! tlib#arg#GetOpts(args, ...) abort "{{{3
    TVarArg ['def', {}]
    let opts = {'__exit__': 0}
    let idx = 0
    for o in a:args
        let [break, idx] = s:SetOpt(def, opts, idx, o)
        if break == 1
            break
        elseif break == 2
            throw 'tlib#arg#GetOpts: Show help'
        endif
    endfor
    let opts.__rest__ = a:args[idx : -1]
    return opts
endf


function! s:SetOpt(def, opts, idx, opt) abort "{{{3
    let idx = a:idx + 1
    let break = 0
    if a:opt =~# '^\%(-[?h]\|--help\)$'
        if has_key(a:def, 'help')
            exec 'help' a:def.help
        else
            echom "No help"
        endif
        let break = 2
    elseif a:opt =~# '^--no-.\+'
        let key = matchstr(a:opt, '^--no-\zs.\+$')
        let a:opts[key] = 0
    elseif a:opt =~# '^--\w\+$'
        let key = matchstr(a:opt, '^--\zs.\+$')
        let a:opts[key] = 1
    elseif a:opt =~# '^--\w\+='
        let ml = matchlist(a:opt, '^--\(\w\+\)=\(.*\)$')
        if empty(ml)
            throw 'tlib#arg#GetOpts: Cannot parse: '. a:opt
        else
            let a:opts[ml[1]] = ml[2]
        endif
    elseif a:opt =~# '^-\w\+$'
        let flagdefs = get(a:def, 'flags', {})
        for flag in split(substitute(a:opt, '^-', '', ''), '\zs')
            if has_key(flagdefs, flag)
                call s:SetOpt(a:def, a:opts, idx, flagdefs[flag])
            else
                let a:opts[flag] = 1
            endif
        endfor
    else
        let break = 1
        if a:opt !=# '--'
            let idx -= 1
        endif
    endif
    return [break, idx]
endf



""" Command line {{{1

" :def: function! tlib#arg#Ex(arg, ?chars='%#! ')
" Escape some characters in a string.
"
" Use |fnamescape()| if available.
"
" EXAMPLES: >
"   exec 'edit '. tlib#arg#Ex('foo%#bar.txt')
function! tlib#arg#Ex(arg, ...) "{{{3
    if exists('*fnameescape') && a:0 == 0
        return fnameescape(a:arg)
    else
        " let chars = '%# \'
        let chars = '%#! '
        if a:0 >= 1
            let chars .= a:1
        endif
        return escape(a:arg, chars)
    endif
endf


