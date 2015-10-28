" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Last Change: 2015-10-28.
" @Revision:    216


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


" :display: tlib#arg#GetOpts(args, ?def={})
" Convert a list of strings of command-line arguments into a dictonary.
"
" The main use case is to pass [<f-args>], i.e. the command-line 
" arguments of a command as list, from a command definition to this 
" function.
"
" Example:
" ['-h']
" => If def contains a 'help' key, invoke |:help| on its value.
"
" ['-ab', '--foo', '--bar=BAR', 'bla', bla']
" => {'a': 1, 'b': 1, 'foo': 1, 'bar': 'BAR', '__rest__': ['bla', 'bla']}
"
" ['-ab', '--', '--foo', '--bar=BAR']
" => {'a': 1, 'b': 1, '__rest__': ['--foo', '--bar=BAR']}
function! tlib#arg#GetOpts(args, ...) abort "{{{3
    let throw = a:0 == 0
    TVarArg ['def', {}]
    " TLogVAR def
    let opts = {'__exit__': 0}
    for [key, vdef] in items(get(def, 'values', {}))
        if has_key(vdef, 'default')
            let opts[key] = vdef.default
        endif
    endfor
    let idx = 0
    for o in a:args
        let [break, idx] = s:SetOpt(def, opts, idx, o)
        if break == 1
            break
        elseif break == 2
            if throw
                throw 'tlib#arg#GetOpts: Show help'
            else
                let opts.__exit__ = 5
            endif
        endif
    endfor
    let opts.__rest__ = a:args[idx : -1]
    return opts
endf


function! s:GetValueType(def) abort "{{{3
    return get(a:def, 'type', type(get(a:def, 'default', '')))
endf


function! s:SetOpt(def, opts, idx, opt) abort "{{{3
    " TLogVAR a:def
    let idx = a:idx + 1
    let break = 0
    if a:opt =~# '^\%(-[?h]\|--help\)$'
        if has_key(a:def, 'help')
            exec 'help' a:def.help
        else
            " TLogVAR a:def
            let values = get(a:def, 'values', {})
            let flags = get(a:def, 'flags', {})
            if empty(values) && empty(flags)
                echom 'No help'
            else
                if !empty(values)
                    echom 'Options:'
                    for [key, vdef] in sort(items(values))
                        let opt = key
                        let default = get(vdef, 'default', '')
                        let type = s:GetValueType(vdef)
                        if default =~ '^-\?\d\+\%(\.\d\+\)$'
                            if type == -1
                                let opt .= ' (flag)'
                            elseif type == 1
                                let opt .= '=INT'
                            else
                                let opt .= '=INT or maybe BOOL'
                            endif
                        elseif type(default) == 1
                            let opt .= '=STRING'
                        endif
                        echom printf('  --%20s (default: %s)', opt, string(default))
                    endfor
                endif
                if !empty(flags)
                    echom 'Short flags:'
                    for [sflag, lflag] in sort(items(flags))
                        echom printf('  -%s -> %s', sflag, lflag)
                    endfor
                endif
            endif
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
    elseif a:opt =~# '^-\w='
        let flagdefs = get(a:def, 'flags', {})
        let flag = matchstr(a:opt, '^-\zs\w')
        let rest = matchstr(a:opt, '^-\w\zs.*$')
        call s:SetFlag(a:def, a:opts, idx, flag, rest, flagdefs)
    elseif a:opt =~# '^-\w\+$'
        let flagdefs = get(a:def, 'flags', {})
        for flag in split(substitute(a:opt, '^-', '', ''), '\zs')
            call s:SetFlag(a:def, a:opts, idx, flag, '', flagdefs)
        endfor
    else
        let break = 1
        if a:opt !=# '--'
            let idx -= 1
        endif
    endif
    return [break, idx]
endf


function! s:SetFlag(def, opts, idx, flag, rest, flagdefs) abort "{{{3
    " TLogVAR a:def
    if has_key(a:flagdefs, a:flag)
        call s:SetOpt(a:def, a:opts, a:idx, a:flagdefs[a:flag] . a:rest)
    else
        let a:opts[a:flag] = 1
    endif
endf


":nodoc:
function! tlib#arg#CComplete(def, ArgLead) abort "{{{3
    let cs = {'-h': 1, '--help': 1}
    let values = get(a:def, 'values', {})
    for [name, vdef] in items(values)
        let type = s:GetValueType(vdef)
        if type >= 0
            let name .= '='
        else
            let cs['--no-'. name] = 1
        endif
        let cs['--'. name] = 1
    endfor
    for [name, subst] in items(get(a:def, 'flags', {}))
        let ldef = get(values, substitute(subst, '^--', '', ''), {})
        let type = s:GetValueType(ldef)
        if type >= 0
            let name .= '='
        endif
        let cs['-'. name] = 1
    endfor
    let nchar = len(a:ArgLead)
    if nchar > 0
        call filter(cs, 'strpart(v:key, 0, nchar) ==# a:ArgLead')
    endif
    return sort(keys(cs))
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


