" hash.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2012-12-14.
" @Last Change: 2010-09-26.
" @Revision:    139


function! tlib#hash#NumBits(num) "{{{3
    let bits = []
    for bitx in [1, 2, 4, 8, 16, 32, 64, 128]
        call add(bits, and(a:num, bitx) != 0)
    endfor
    return bits
endf


function! tlib#hash#CRC32(chars) "{{{3
    if has('ruby')
        let rv = ''
        ruby << EOR
        require 'zlib'
        VIM::command('let rv = "%08x"' % Zlib.crc32(VIM::evaluate("a:chars")))
EOR
    " elseif has('python')
    " elseif has('perl')
    " elseif has('tcl')
    else
        throw "tlib: No implementation for CRC32"
        " " crc32
        " let crc32 = 0
        " " let crc32 = 0xffffffff
        " let crc32poly = 0x04C11DB7
        " for char in split(a:chars, '\zs')
        "     let bits = tlib#hash#NumBits(char2nr(char))
        "     TLogVAR char, bits
        "     for bit in bits
        "         let cc = and(crc32, 0x80000000) ? 1 : 0
        "         TLogVAR bit, cc, bit != cc
        "         if cc != bit
        "             let crc32 = xor(crc32 * 2, crc32poly)
        "         else
        "             let crc32 = crc32 * 2
        "         endif
        "     endfor
        " endfor
        " " let crc32 = xor(crc32, 0xffffffff)
        " let rv = printf("%08X", crc32)
        "
        " " crc32rev
        " let crc32 = 0xffffffff
        " " let crc32 = 0xffffffff
        " let crc32poly = 0xEDB88320
        " for char in split(a:chars, '\zs')
        "     let bits = tlib#hash#NumBits(char2nr(char))
        "     for bit in bits
        "         let cc = and(crc32, 1)
        "         if cc != bit
        "             let crc32 = xor(crc32 / 2, crc32poly)
        "         else
        "             let crc32 = crc32 / 2
        "         endif
        "     endfor
        " endfor
        " let crc32 = xor(crc32, 0xffffffff)
        " let rv = printf("%08X", crc32)
    endif
    return rv
endf


function! tlib#hash#Adler32(chars) "{{{3
    if !exists('*or')
        throw "TLIB: Vim version doesn't support bitwise or()"
    endif
    let mod_adler = 65521
    let a = 1
    let b = 0
    for index in range(len(a:chars))
        let c = char2nr(a:chars[index])
        let a = (a + c) % mod_adler
        let b = (b + a) % mod_adler
    endfor
    let checksum = or(b * float2nr(pow(2, 16)), a)
    return printf("%08X", checksum)
endf


