" date.vim
" @Author:      Thomas Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.lithom.net
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2010-03-25.
" @Last Change: 2010-04-03.
" @Revision:    0.0.14

let s:save_cpo = &cpo
set cpo&vim


if !exists('g:tlib#date#ShortDatePrefix') | let g:tlib#date#ShortDatePrefix = '20' | endif "{{{2
if !exists('g:tlib#date#TimeZoneShift')   | let g:tlib#date#TimeZoneShift = 0      | endif "{{{2

let g:tlib#date#dayshift = 60 * 60 * 24


" :display: tlib#date#DiffInDays(date1, ?date2=localtime(), ?allow_zero=0)
function! tlib#date#DiffInDays(date, ...)
    let allow_zero = a:0 >= 2 ? a:2 : 0
    let s0 = tlib#date#SecondsSince1970(a:date, 0, allow_zero)
    let s1 = a:0 >= 1 ? tlib#date#SecondsSince1970(a:1, 0, allow_zero) : localtime()
    let dd = (s0 - s1) / g:tlib#date#dayshift
    " TLogVAR dd
    return dd
endf


" tlib#date#SecondsSince1970(date, ?daysshift=0, ?allow_zero=0)
function! tlib#date#SecondsSince1970(date, ...) "{{{3
    let allow_zero = a:0 >= 2 ? a:2 : 0
    let min = allow_zero ? 0 : 1
    " TLogVAR a:date
    let year  = matchstr(a:date, '^\(\d\+\)\ze-\(\d\+\)-\(\d\+\)$')
    let month = matchstr(a:date, '^\(\d\+\)-\zs\(\d\+\)\ze-\(\d\+\)$')
    let days  = matchstr(a:date, '^\(\d\+\)-\(\d\+\)-\zs\(\d\+\)$')
    if year == '' || month == '' || days == '' || 
                \ month < min || month > 12 || days < min || days > 31
        echoerr 'PIM: Invalid date: '. a:date
        return 0
    endif
    if strlen(year) == 2
        let year = g:tlib#date#ShortDatePrefix . year
    endif
    if a:0 >= 1 && a:1 > 0
        let days = days + a:1
    end
    let days_passed = days
    let i = 1970
    while i < year
        let days_passed = days_passed + 365
        if i % 4 == 0 || i == 2000
            let days_passed = days_passed + 1
        endif
        let i = i + 1
    endwh
    let i = 1
    while i < month
        if i == 1
            let days_passed = days_passed + 31
        elseif i == 2
            let days_passed = days_passed + 28
            if year % 4 == 0 || year == 2000
                let days_passed = days_passed + 1
            endif
        elseif i == 3
            let days_passed = days_passed + 31
        elseif i == 4
            let days_passed = days_passed + 30
        elseif i == 5
            let days_passed = days_passed + 31
        elseif i == 6
            let days_passed = days_passed + 30
        elseif i == 7
            let days_passed = days_passed + 31
        elseif i == 8
            let days_passed = days_passed + 31
        elseif i == 9
            let days_passed = days_passed + 30
        elseif i == 10
            let days_passed = days_passed + 31
        elseif i == 11
            let days_passed = days_passed + 30
        endif
        let i = i + 1
    endwh
    let seconds = (days_passed - 1) * 24 * 60 * 60
    let seconds = seconds + (strftime('%H') + g:tlib#date#TimeZoneShift) * 60 * 60
    let seconds = seconds + strftime('%M') * 60
    let seconds = seconds + strftime('%S')
    return seconds
endf


let &cpo = s:save_cpo
unlet s:save_cpo
