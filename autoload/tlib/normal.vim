" normal.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2008-10-06.
" @Last Change: 2009-02-15.
" @Revision:    10

let s:save_cpo = &cpo
set cpo&vim


function! tlib#normal#WithRegister(cmd, ...) "{{{3
    TVarArg ['register', 't'], ['norm_cmd', 'norm!']
    exec 'let reg = @'. register
    try
        exec norm_cmd .' '. a:cmd
        exec 'return @'. register
    finally
        exec 'let @'. register .' = reg'
    endtry
endf


let &cpo = s:save_cpo
unlet s:save_cpo
