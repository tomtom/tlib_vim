" vcs.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2012-03-08.
" @Last Change: 2012-03-11.
" @Revision:    50


" A dictionare of supported VCS.
TLet g:tlib#vcs#def = {
            \ 'git': {
            \     'dir': '.git',
            \     'ls': 'git ls-files --full-name %s',
            \     'diff': 'git diff --no-ext-diff -U0 %s'
            \ }
            \ }
            " \ , 'hg': {'ls': 'hg diff -U0 %s', 'dir': '.hg'}
            " \ , 'svn': {'ls': 'svn diff --diff-cmd diff --extensions -U0 %s', 'dir': '.svn'}
            " \ , 'bzr': {'ls': 'bzr diff --diff-options=-U0 %s', 'dir': '.bzr'}


" If non-empty, use it as a format string to check whether a VCS is 
" installed on your computer.
TLet g:tlib#vcs#check = has('win16') || has('win32') || has('win64') ? '%s.exe' : '%s'

if !empty(g:tlib#vcs#check)
    for [s:cmd, s:def] in items(g:tlib#vcs#def)
        let s:cmd1 = printf(g:tlib#vcs#check, s:cmd)
        if !executable(s:cmd1)
            call remove(g:tlib#vcs#def, s:cmd)
        endif
    endfor
endif


function! tlib#vcs#FindVCS(filename) "{{{3
    let type = ''
    let dir  = ''
    let path = escape(fnamemodify(a:filename, ':p'), ',:') .';'
    let depth = -1
    for vcs in keys(g:tlib#vcs#def)
        let dir = g:tlib#vcs#def[vcs].dir
        " TLogVAR dir
        let vcsdir = finddir(dir, path)
        if !empty(vcsdir)
            let vcsdir_depth = len(split(fnamemodify(vcsdir, ':p'), '\/'))
            if vcsdir_depth > depth
                let depth = vcsdir_depth
                let type = vcs
                let dir = vcsdir
                " TLogVAR type, depth
            endif
        endif
    endfor
    return [type, vcsdir]
endf


" :display: tlib#vcs#Ls(?filename=bufname('%'), ?vcs=[type, dir])
" Return the files under VCS.
function! tlib#vcs#Ls(...) "{{{3
    if a:0 >= 2
        let vcs = a:2
    else
        let vcs = tlib#vcs#FindVCS(a:0 >= 1 ? a:1 : bufname('%'))
    endif
    " TLogVAR vcs
    if !empty(vcs)
        let [vcstype, vcsdir] = vcs
        if has_key(g:tlib#vcs#def, vcstype)
            let vcsdef = g:tlib#vcs#def[vcstype]
            " TLogVAR vcsdef
            if has_key(vcsdef, 'ls')
                let rootdir = fnamemodify(vcsdir, ':p:h:h')
                " TLogVAR vcsdir, rootdir
                let cmd = printf(vcsdef.ls, shellescape(rootdir))
                " TLogVAR cmd
                let filess = system(cmd)
                " TLogVAR filess
                let files = split(filess, '\n')
                call map(files, 'join([rootdir, v:val], "/")')
                return files
            endif
        endif
    endif
    return []
endf


" :display: tlib#vcs#Diff(filename, ?vcs=[type, dir])
" Return the diff for "filename"
function! tlib#vcs#Diff(filename, ...) "{{{3
    let vcs = a:0 >= 1 ? a:1 : tlib#vcs#FindVCS(a:filename)
    if !empty(vcs)
        let [vcstype, vcsdir] = vcs
        if has_key(g:tlib#vcs#def, vcstype)
            let vcsdef = g:tlib#vcs#def[vcstype]
            if has_key(vcsdef, 'diff')
                let cmd = printf(vcsdef.diff, shellescape(fnamemodify(a:filename, ':p')))
                let diff = system(cmd)
                return diff
            endif
        endif
    endif
    return []
endf

