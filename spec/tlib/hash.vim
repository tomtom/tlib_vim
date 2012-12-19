" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    13


SpecBegin 'title': 'tlib#hash'


It should calculate CRC32B checksums.

let g:tlib_hash_use_crc32 = g:tlib#hash#use_crc32

let g:tlib#hash#use_crc32 = 'ruby'
Should be equal tlib#hash#CRC32B('The quick brown fox jumps over the lazy dog'), '414FA339'
Should be equal tlib#hash#CRC32B('foo'), '8C736521'
Should be equal tlib#hash#CRC32B('f'), '76D32BE0'

let g:tlib#hash#use_crc32 = 'vim'
Should be equal tlib#hash#CRC32B('The quick brown fox jumps over the lazy dog'), '414FA339'
Should be equal tlib#hash#CRC32B('foo'), '8C736521'
Should be equal tlib#hash#CRC32B('f'), '76D32BE0'

let g:tlib#hash#use_crc32 = g:tlib_hash_use_crc32


