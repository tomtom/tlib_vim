" type.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-09-30.
" @Last Change: 2009-02-15.
" @Revision:    0.0.3

if &cp || exists("loaded_tlib_type_autoload")
    finish
endif
let loaded_tlib_type_autoload = 1

function! tlib#type#IsNumber(expr)
    return type(a:expr) == 0
endf

function! tlib#type#IsString(expr)
    return type(a:expr) == 1
endf

function! tlib#type#IsFuncref(expr)
    return type(a:expr) == 2
endf

function! tlib#type#IsList(expr)
    return type(a:expr) == 3
endf

function! tlib#type#IsDictionary(expr)
    return type(a:expr) == 4
endf


