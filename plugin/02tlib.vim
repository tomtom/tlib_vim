" tlib.vim -- Some utility functions
" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-04-10.
" @Last Change: 2010-11-12.
" @Revision:    653
" GetLatestVimScripts: 1863 1 tlib.vim

if &cp || exists("loaded_tlib")
    finish
endif
if v:version < 700 "{{{2
    echoerr "tlib requires Vim >= 7"
    finish
endif
let loaded_tlib = 41

let s:save_cpo = &cpo
set cpo&vim


" Init~ {{{1
" call tlib#autocmdgroup#Init()


" Commands~ {{{1

" :display: TRequire NAME [VERSION [FILE]]
" Make a certain vim file is loaded.
"
" Conventions: If FILE isn't defined, plugin/NAME.vim is loaded. The 
" file must provide a variable loaded_{NAME} that represents the version 
" number.
command! -nargs=+ TRequire let s:require = [<f-args>]
            \ | if !exists('loaded_'. get(s:require, 0))
                \ | exec 'runtime '. get(s:require, 2, 'plugin/'. get(s:require, 0) .'.vim')
                \ | if !exists('loaded_'. get(s:require, 0)) || loaded_{get(s:require, 0)} < get(s:require, 1, loaded_{get(s:require, 0)})
                    \ | echoerr 'Require '.  get(s:require, 0) .' >= '. get(s:require, 1, 'any version will do')
                    \ | finish
                    \ | endif
                \ | endif | unlet s:require


" :display: :TLet VAR = VALUE
" Set a variable only if it doesn't already exist.
" EXAMPLES: >
"   TLet foo = 1
"   TLet foo = 2
"   echo foo
"   => 1
command! -nargs=+ TLet if !exists(matchstr(<q-args>, '^[^=[:space:]]\+')) | exec 'let '. <q-args> | endif


" Open a scratch buffer (a buffer without a file).
"   TScratch  ... use split window
"   TScratch! ... use the whole frame
" This command takes an (inner) dictionnary as optional argument.
" EXAMPLES: >
"   TScratch 'scratch': '__FOO__'
"   => Open a scratch buffer named __FOO__
command! -bar -nargs=* -bang TScratch call tlib#scratch#UseScratch({'scratch_split': '<bang>' != '!', <args>})


" :display: :TVarArg VAR1, [VAR2, DEFAULT2] ...
" A convenience wrapper for |tlib#arg#Let|.
" EXAMPLES: >
"   function! Foo(...)
"       TVarArg ['a', 1], 'b'
"       echo 'a='. a
"       echo 'b='. b
"   endf
command! -nargs=+ TVarArg exec tlib#arg#Let([<args>])


" :display: :TKeyArg DICT, VAR1, [VAR2, DEFAULT2] ...
" A convenience wrapper for |tlib#arg#Let|.
" EXAMPLES: >
"   function! Foo(keyargs)
"       TKeyArg a:keyargs, ['a', 1], 'b'
"       echo 'a='. a
"       echo 'b='. b
"   endf
command! -nargs=+ TKeyArg exec tlib#arg#Key([<args>])


" :display: TBrowseOutput COMMAND
" Ever wondered how to effciently browse the output of a command 
" without redirecting it to a file? This command takes a command as 
" argument and presents the output via |tlib#input#List()| so that you 
" can easily search for a keyword (e.g. the name of a variable or 
" function) and the like.
"
" If you press enter, the selected line will be copied to the command 
" line. Press ESC to cancel browsing.
"
" EXAMPLES: >
"   TBrowseOutput 20verb TeaseTheCulprit
command! -nargs=1 -complete=command TBrowseOutput call tlib#cmd#BrowseOutput(<q-args>)


" :display: TTimeCommand CMD
" Time the execution time of CMD.
command! -nargs=1 -complete=command TTimeCommand call tlib#cmd#Time(<q-args>)



" Variables~ {{{1

" When 1, automatically select a the last remaining item after applying 
" any filters.
TLet g:tlib_pick_last_item = 1

" If a list is bigger than this value, don't try to be smart when 
" selecting an item. Be slightly faster instead.
TLet g:tlib_sortprefs_threshold = 200

" Scratch window position. By default the list window is opened on the 
" bottom. Set this variable to 'topleft' or '' to change this behaviour.
TLet g:tlib_scratch_pos = 'botright'

" Size of the input list window (in percent) from the main size (of &lines).
TLet g:tlib_inputlist_pct = 50

" Size of filename columns when listing filenames
TLet g:tlib_inputlist_width_filename = '&co / 3'
" TLet g:tlib_inputlist_width_filename = 25

" The highlight group to use for showing matches in the input list window.
TLet g:tlib_inputlist_higroup = 'IncSearch'

" If a list contains more items, don't do an incremental "live search", 
" but use |input()| the quere the user for a filter. This is useful on 
" slower machines or with very long lists.
TLet g:tlib_inputlist_livesearch_threshold = 1000

" If true, show some indicators about the status of a filename (eg 
" buflisted(), bufloaded() etc.).
" This is disabled by default because vim checks also for the file on 
" disk when doing this.
TLet g:tlib_inputlist_filename_indicators = 0

" Can be "cnf", "cnfd", "seq", or "fuzzy". See:
"   cnf :: Match substrings
"     - |tlib#Filter_cnf#New()| (this is the default method)
"     - |tlib#Filter_cnfd#New()|
"   seq :: Match sequences of characters
"     - |tlib#Filter_seq#New()|
"   fuzzy :: Match fuzzy character sequences
"     - |tlib#Filter_fuzzy#New()|
TLet g:tlib_inputlist_match = 'cnf'

" If non null, display only a short info about the filter.
TLet g:tlib_inputlist_shortmessage = 0

" Extra tags for |tlib#tag#Retrieve()| (see there). Can also be buffer-local.
TLet g:tlib_tags_extra = ''

" Filter the tag description through |substitute()| for these filetypes. 
" This applies only if the tag cmd field (see |taglist()|) is used.
" :nodefault:
TLet g:tlib_tag_substitute = {
            \ 'java': [['\s*{\s*$', '', '']],
            \ 'ruby': [['\<\(def\|class\|module\)\>\s\+', '', '']],
            \ 'vim':  [
            \   ['^\s*com\%[mand]!\?\(\s\+-\S\+\)*\s*\u\w*\zs.*$', '', ''],
            \   ['^\s*\(let\|aug\%[roup]\|fu\%[nction]!\?\|com\%[mand]!\?\(\s\+-\S\+\)*\)\s*', '', ''],
            \   ['"\?\s*{{{\d.*$', '', ''],
            \ ],
            \ }

" " Alternative rx for keywords, in case 'iskeyword' is inadequate for 
" " the purposes of tlib but you don't want to change it's value.
" TLet g:tlib_keyword_rx = {
"             \ 'vim': '\(\w\|#\)',
"             \ }

TLet g:tlib_filename_sep = '/'
" TLet g:tlib_filename_sep = exists('+shellslash') && !&shellslash ? '\' : '/'   " {{{2

" The cache directory. If empty, use |tlib#dir#MyRuntime|.'/cache'.
" You might want to delete old files from this directory from time to 
" time with a command like: >
"   find ~/vimfiles/cache/ -atime +31 -type f -print -delete
TLet g:tlib_cache = ''

" Where to display the line when using |tlib#buffer#ViewLine|.
" For possible values for position see |scroll-cursor|.
TLet g:tlib_viewline_position = 'zz'

" :doc:
" Keys for |tlib#input#List|~

TLet g:tlib_inputlist_and = ' '
TLet g:tlib_inputlist_or  = '|'
TLet g:tlib_inputlist_not = '-'

" When editing a list with |tlib#input#List|, typing these numeric chars 
" (as returned by getchar()) will select an item based on its index, not 
" based on its name. I.e. in the default setting, typing a "4" will 
" select the fourth item, not the item called "4".
" In order to make keys 0-9 filter the items in the list and make 
" <m-[0-9]> select an item by its index, remove the keys 48 to 57 from 
" this dictionary.
" Format: [KEY] = BASE ... the number is calculated as KEY - BASE.
" :nodefault:
TLet g:tlib_numeric_chars = {
            \ 176: 176,
            \ 177: 176,
            \ 178: 176,
            \ 179: 176,
            \ 180: 176,
            \ 181: 176,
            \ 182: 176,
            \ 183: 176,
            \ 184: 176,
            \ 185: 176,
            \}
            " \ 48: 48,
            " \ 49: 48,
            " \ 50: 48,
            " \ 51: 48,
            " \ 52: 48,
            " \ 53: 48,
            " \ 54: 48,
            " \ 55: 48,
            " \ 56: 48,
            " \ 57: 48,

" :nodefault:
" The default key bindings for single-item-select list views. If you 
" want to use <c-j>, <c-k> to move the cursor up and down, add these two 
" lines to after/plugin/02tlib.vim: >
"
"   let g:tlib_keyagents_InputList_s[10] = 'tlib#agent#Down'  " <c-j>
"   let g:tlib_keyagents_InputList_s[11] = 'tlib#agent#Up'    " <c-k>
TLet g:tlib_keyagents_InputList_s = {
            \ "\<PageUp>":   'tlib#agent#PageUp',
            \ "\<PageDown>": 'tlib#agent#PageDown',
            \ "\<Up>":       'tlib#agent#Up',
            \ "\<Down>":     'tlib#agent#Down',
            \ "\<c-Up>":     'tlib#agent#UpN',
            \ "\<c-Down>":   'tlib#agent#DownN',
            \ "\<Left>":     'tlib#agent#ShiftLeft',
            \ "\<Right>":    'tlib#agent#ShiftRight',
            \ 18:            'tlib#agent#Reset',
            \ 242:           'tlib#agent#Reset',
            \ 17:            'tlib#agent#Input',
            \ 241:           'tlib#agent#Input',
            \ 27:            'tlib#agent#Exit',
            \ 26:            'tlib#agent#Suspend',
            \ 250:           'tlib#agent#Suspend',
            \ 15:            'tlib#agent#SuspendToParentWindow',  
            \ 63:            'tlib#agent#Help',
            \ "\<F1>":       'tlib#agent#Help',
            \ "\<bs>":       'tlib#agent#ReduceFilter',
            \ "\<del>":      'tlib#agent#ReduceFilter',
            \ "\<c-bs>":     'tlib#agent#PopFilter',
            \ "\<m-bs>":     'tlib#agent#PopFilter',
            \ "\<c-del>":    'tlib#agent#PopFilter',
            \ "\<m-del>":    'tlib#agent#PopFilter',
            \ 191:           'tlib#agent#Debug',
            \ char2nr(g:tlib_inputlist_or):  'tlib#agent#OR',
            \ char2nr(g:tlib_inputlist_and): 'tlib#agent#AND',
            \ }

" Number of items to move when pressing <c-up/down> in the input list window.
TLet g:tlib_scroll_lines = 10

" :nodefault:
TLet g:tlib_keyagents_InputList_m = {
            \ 35:          'tlib#agent#Select',
            \ "\<s-up>":   'tlib#agent#SelectUp',
            \ "\<s-down>": 'tlib#agent#SelectDown',
            \ 1:           'tlib#agent#SelectAll',
            \ 225:         'tlib#agent#SelectAll',
            \ }
" "\<c-space>": 'tlib#agent#Select'

" :nodefault:
TLet g:tlib_handlers_EditList = [
            \ {'key': 5,  'agent': 'tlib#agent#EditItem',    'key_name': '<c-e>', 'help': 'Edit item'},
            \ {'key': 4,  'agent': 'tlib#agent#DeleteItems', 'key_name': '<c-d>', 'help': 'Delete item(s)'},
            \ {'key': 14, 'agent': 'tlib#agent#NewItem',     'key_name': '<c-n>', 'help': 'New item'},
            \ {'key': 24, 'agent': 'tlib#agent#Cut',         'key_name': '<c-x>', 'help': 'Cut item(s)'},
            \ {'key':  3, 'agent': 'tlib#agent#Copy',        'key_name': '<c-c>', 'help': 'Copy item(s)'},
            \ {'key': 22, 'agent': 'tlib#agent#Paste',       'key_name': '<c-v>', 'help': 'Paste item(s)'},
            \ {'pick_last_item': 0},
            \ {'return_agent': 'tlib#agent#EditReturnValue'},
            \ ]



" " TEST:
" TRequire tselectbuffer 6
" echo loaded_tselectbuffer



let &cpo = s:save_cpo
unlet s:save_cpo

finish
-----------------------------------------------------------------------

CHANGES:
0.1
Initial release

0.2
- More list convenience functions
- tlib#EditList()
- tlib#InputList(): properly handle duplicate items; it type contains 
'i', the list index + 1 is returned, not the element

0.3
- tlib#InputList(): Show feedback in statusline instead of the echo area
- tlib#GetVar(), tlib#GetValue()

0.4
- tlib#InputList(): Up/Down keys wrap around list
- tlib#InputList(): FIX: Problem when reducing the filter & using AND
- tlib#InputList(): Made <a-numeric> work (can be configured via 
- tlib#InputList(): special display_format: "filename"
- tlib#Object: experimental support for some kind of OOP
- tlib#World: Extracted some functions from tlib.vim to tlib/World.vim
- tlib#FileJoin(), tlib#FileSplit(), tlib#RelativeFilename()
- tlib#Let()
- tlib#EnsureDirectoryExists(dir)
- tlib#DirName(dir)
- tlib#DecodeURL(url), tlib#EncodeChar(char), tlib#EncodeURL(url)
- FIX: Problem when using shift-up/down with filtered lists

0.5
- tlib#InputList(): FIX: Selecting items in filtered view
- tlib#InputList(): <c-bs>: Remove last AND pattern from filter

0.6
- tlib#InputList(): Disabled <c-space> map
- tlib#InputList(): try to be smart about user itentions only if a 
list's length is < g:tlib_sortprefs_threshold (default: 200)
- tlib#Object: Super() method
- tlib#MyRuntimeDir()
- tlib#GetCacheName(), tlib#CacheSave(), tlib#CacheGet()
- tlib#Args(), tlib#GetArg()
- FIX: tlib#InputList(): Display problem with first item

0.7
- tlib#InputList(): <c-z> ... Suspend/Resume input
- tlib#InputList(): <c-q> ... Input text on the command line (useful on 
slow systems when working with very large lists)
- tlib#InputList(): AND-pattern starting with '!' will work as 'exclude 
matches'
- tlib#InputList(): FIX <c-bs> pop OR-patterns properly
- tlib#InputList(): display_format == filename: don't add '/' to 
directory names (avoid filesystem access)

0.8
- FIX: Return empty cache name for buffers that have no files attached to it
- Some re-arranging

0.9
- Re-arrangements & modularization (this means many function names have 
changed, on the other hand only those functions are loaded that are 
actually needed)
- tlib#input#List(): Added maps with m-modifiers for <c-q>, <c-z>, <c-a>
- tlib#input#List(): Make sure &fdm is manual
- tlib#input#List(): When exiting the list view, consume the next 5 
characters in the queue (if any)
- tlib#input#EditList(): Now has cut, copy, paste functionality.
- Added documentation and examples

0.10
- tlib#input#List(): (v)split type of commands leave the original window 
untouched (you may use <c-w> to replace its contents)
- tlib#file#With(): Check whether an existing buffer is loaded.
- Scratch related functions went to tlib/scratch.vim so that they are 
accessible from other scripts.
- Configure the list window height via g:tlib_inputlist_pct (1..100%)

0.11
NEW:
    - The :TLet command replaces :TLLet (which was removed)
    - :TScratch[!] command (with ! don't split but use the whole window)
    - tlib#rx#Escape(text, ?magic='m')
    - tlib#buffer#GetList(?show_hidden=0)
    - tlib#dir#CD(), tlib#dir#Push(), tlib#dir#Pop()
    - tlib#input#ListW: A slightly remodeled version of tlib#input#List 
    that takes a World as second argument.
    - Added some documentation doc/tlib.txt (most of it is automatically 
    compiled from the source files)
CHANGES:
    - tlib#input#List(): The default keys for AND, NOT have changed to 
    be more Google-like (space, minus); the keys can be configured via 
    global variables.
IMPROVEMENTS:
    - In file listings, indicate if a file is loaded, listed, modified 
    etc.
    - tlib#input#List(): Highlight the filter pattern
    - tlib#input#List(): <c-up/down> scrolls g:tlib_scroll_lines 
    (default=10) lines
FIXES:
    - tlib#input#List(): Centering line, clear match, clear & restore 
    the search register
    - tlib#input#List(): Ensure the window layout doesn't change (if the 
    number of windows hasn't changed)
    - tlib#arg#Ex(): Don't escape backslashes by default

0.12
NEW:
    - tlib/tab.vim
CHANGES:
    - Renamed tlib#win#SetWin() to tlib#win#Set()
IMPROVEMENTS:
    - tlib#input#List(): <left>, <right> keys work in some lists
    - tlib#input#List(): If an index_table is provided this will be used 
    instead of the item's list index.
FIXES:
    - tlib#input#List(): Problem with scrolling, when the list was 
    shorter than the window (eg when using a vertical window).
    - tlib#cache#Filename(): Don't rewrite name as relative filename if 
    explicitly given as argument. Avoid double (back)slashes.
    - TLet: simplified

0.13
CHANGES:
    - Scratch: Set &fdc=0.
    - The cache directory can be configured via g:tlib_cache
    - Renamed tlib#buffer#SetBuffer() to tlib#buffer#Set().
FIXES:
    - tlib#input#List(): Select the active item per mouse.
    - TLet: simplified

0.14
NEW:
    - tlib#buffer#InsertText()
CHANGES:
    - tlib#win#[SG]etLayout(): Use a dictionnary, set &cmdheight.
FIXES:
    - Wrong order with pre-defined filters.

0.15
NEW:
    - tlib#string#TrimLeft(), tlib#string#TrimRight(), tlib#string#Strip()
    - Progress bar

0.16
NEW:
    - tlib#string#Printf1()

0.17
NEW:
    - TBrowseOutput
- Some minor changes

0.18
NEW:
    - tlib/time.vim
    - g:tlib_inputlist_livesearch_threshold
CHANGES:
    - tlib#input#ListD(), World: Don't redisplay the list while typing 
    new letters; calculate filter regexps only once before filtering the 
    list.
    - World.vim: Minor changes to how filenames are handled.

0.19
NEW:
    - tag.vim
FIX:
    - dir.vim: Use plain dir name in tlib#dir#Ensure()
    - tlib#input#List(): An initial filter argument creates [[filter]] 
    and not as before [[''], [filter]].
    - tlib#input#List(): When type was "si" and the item was picked by 
    filter, the wrong index was returned.
    - tlib#input#List(): Don't check if chars are typed when displaying 
    the list for the first time.

0.20
- The arguments of tlib#tag#Collect() have changed.
- tlib#input#List(): The view can be "suspended" on initial display.
- tlib#input#List(): Follow/trace cursor functionality

0.21
- tlib#buffer#InsertText(): Respect tabs and (experimental) formatoptions+=or
- tlib/syntax.vim: Syntax-related functions

0.22
- FIX: very magic mode for tlib#rx#Escape() (thanks A Politz)
- FIX: tlib#arg#Ex: escape "!"

0.23
- Respect the setting of g:tlib_inputlist_filename_indicators
- tlib#input#List(): Reset syntax on resume; option to make list window "sticky"
- tlib#agent#ToggleStickyList()
- Simplified tlib#url#Decode()
- tlib#arg#Ex(): use fnameescape() if available

0.24
- s:prototype.SetInitialFilter: accept list as argument
- Maintain buffer MRU if required

0.25
- NEW: tlib#notify#TrimMessage(): trim message to prevent "Press ENTER" 
messages (contributed by Erik Falor)
- NEW: tlib#notify#Echo()
- FIX: World.CloseScratch(): Set window
- FIX: tlib#input#ListW(): Set initial_display = 1 on reset

0.26
- NEW: tlib#normal#WithRegister()
- FIX: Try not to change numbered registers

0.27
- FIX: Cosmetic bug, wrong packaging (thanks Nathan Neff)
- Meaning of World#filter_format changed; new World#filter_options 
- Filtering didn't work as advertised
- tlib#string#Count()

0.28
- tlib#input#List():
-- Improved handling of sticky lists; <cr> and <Leftmouse> resume a 
suspended list and immediately selects the item under the cursor
-- Experimental "seq" matching style: the conjunctions are sequentially 
ordered, they are combined with "OR" (disjunctions), the regexp is 
'magic', and "." is expanded to '.\{-}'
-- Experimental "cnfd" matching style: Same as cnf but with an "elastic" 
dot "." that matches '\.\{-}'
-- Filtering acts as if &ic=1 && $sc=1
-- Weighting is done by the filter
- tlib#agent#Input(): Consume <esc> when aborting input()
- INCOMPATIBLE CHANGE: Changed eligible values of g:tlib_inputlist_match 
to "cnf", "cnfd", "seq" and "fuzzy"
- NEW: tlib#buffer#KeepCursorPosition()
- tlib#buffer#InsertText(): Take care of the extra line when appending 
text to an empty buffer.

0.29
- tlib#string#Strip(): Strip also control characters (newlines etc.)
- tlib#rx#Suffixes(): 'suffixes' as Regexp
- World#RestoreOrigin(): Don't assume &splitbelow

0.30
- World#RestoreOrigin(): Don't assume &splitright

0.31
- :TRequire command
-tlib#input#List: For i-type list views, make sure agents are called 
with the base indices.

0.32
- tlib#agent#Exit: explicitly return empty value (as a consequence, 
pressing <esc> when browsing an index-list, returns 0 and not "")
- tlib#signs
- tlib#input#List: set local statusline

0.33
- Don't reset statusline
- Don't use fnamemodify() to split filenames (for performance reasons)
- scratch: Set ft after setting up scratch options
- tlib#map#PumAccept(key)

0.34
- tlib#buffer#HighlightLine(line): call tlib#autocmdgroup#Init() 
(reported by Sergey Khorev)

0.35
- tlib#input#EditList(): return the list if the user presses esc

0.36
- Display a message when the filter is for whatever reason invalid
- Removed tlib#paragraph#Delete()
- New: tlib#paragraph#Define(), tlib#textobjects#StandardParagraph()
- Try to speed up list display (a rewrite of World.DisplayList() etc. is 
required)

0.37
- g:tlib_inputlist_livesearch_threshold defaults to 1000
- tlib#World: optional scratch_pos field
- tlib#input#List: By default <m-NUMBER> selects by number but NUMBER is 
interpreted as string
- tlib#date
- TTimeCommand

0.38
- tlib#World#Resize: set winfix{height|width}

0.39
- g:tlib#cache#dont_purge
- tlib#vim#RestoreWindow()
- tlib#ballon#...()

0.40
- tlib#agent#ViewFile: Use split/sbuffer if nohidden && modified 
- tlib#buffer#GetList(): order by "basename"

