" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @GIT:         http://github.com/tomtom/vimtlib/
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2010-08-30.
" @Last Change: 2010-08-30.
" @Revision:    15


function! tlib#balloon#Register(expr) "{{{3
    if !has('balloon_eval')
        return
    endif
    if !exists('b:tlib_balloons')
        let b:tlib_balloons = []
        if !empty(&balloonexpr)
            call add(b:tlib_balloons, &balloonexpr)
        endif
    endif
    if !&ballooneval
        setlocal ballooneval
    endif
    if &balloonexpr != 'tlib#balloon#Expr()'
        setlocal ballooneval balloonexpr=tlib#balloon#Expr()
    endif
    if index(b:tlib_balloons, a:expr) == -1
        call add(b:tlib_balloons, a:expr)
    endif
endf


function! tlib#balloon#Expr() "{{{3
    let text = map(copy(b:tlib_balloons), 'eval(v:val)')
    call filter(text, '!empty(v:val)')
    return join(text, "\n----------------------------------\n")
endf


