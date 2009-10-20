" FILE:     autoload/subprocess/shell_translate.vim
" AUTHOR:   Nico Raffo <nicoraffo@gmail.com>
" MODIFIED: __MODIFIED__
" VERSION:  __VERSION__, for Vim 7.0
" LICENSE:  MIT License "{{{
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
" 
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
" 
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
" THE SOFTWARE.
" }}}
"
" Translate shell escape/control characters into Vim formatting

" Control sequences {{{
let s:control_sequences = { 
\ 'G' : 'Bell',
\ 'H' : 'Backspace',
\ 'I' : 'Horizontal Tab',
\ 'J' : 'Line Feed or New Line',
\ 'K' : 'Vertical Tab',
\ 'L' : 'Form Feed or New Page',
\ 'M' : 'Carriage Return'
\ } 
" }}}

" Escape sequences {{{
let s:escape_sequences = [ 
\ {'code':'[\(\d*;\)*\d*m', 'name':'font', 'description':'Font manipulation'},
\ {'code':']0;.*__BELL__', 'name':'title', 'description':'Change Title'},
\ {'code':'[\d*J', 'name':'clear_screen', 'description':'Clear in screen'},
\ {'code':'[\d*K', 'name':'clear_line', 'description':'Clear in line'},
\ {'code':'[\d*@', 'name':'add_spaces', 'description':'Add n spaces'},
\ {'code':'[\d*A', 'name':'cursor_up', 'description':'Cursor up n spaces'},
\ {'code':'[\d*B', 'name':'cursor_down', 'description':'Cursor down n spaces'},
\ {'code':'[\d*C', 'name':'cursor_right', 'description':'Cursor right n spaces'},
\ {'code':'[\d*D', 'name':'cursor_left', 'description':'Cursor back n spaces'},
\ {'code':'[\d*G', 'name':'cursor_to_column', 'description':'Move cursor to column'},
\ {'code':'[\d*H', 'name':'cursor', 'description':'Move cursor to x;y'},
\ {'code':'[\d*;\d*H', 'name':'cursor', 'description':'Move cursor to x;y'},
\ {'code':'[\d*L', 'name':'insert_lines', 'description':'Insert n lines'},
\ {'code':'[\d*M', 'name':'delete_lines', 'description':'Delete n lines'},
\ {'code':'[\d*P', 'name':'delete_chars', 'description':'Delete n characters'},
\ {'code':'[\d*d', 'name':'cusor_vpos', 'description':'Cursor vertical position'},
\ {'code':'[\d*;\d*f', 'name':'xy_pos', 'description':'x;y position'},
\ {'code':'[\d*g', 'name':'tab_clear', 'description':'Tab clear'},
\ {'code':'(.', 'name':'char_set', 'description':'Character set'},
\ {'code':'[?\d*l', 'name':'cursor_settings', 'description':'Misc cursor'},
\ {'code':'[?\d*h', 'name':'cursor_settings', 'description':'Misc cursor'}
\ ] 
" }}}

" Font codes {{{
let s:font_codes = {
\ '0': {'description':'Normal (default)', 'attributes': {'cterm':'NONE','ctermfg':'NONE','ctermbg':'NONE','gui':'NONE','guifg':'NONE','guibg':'NONE'}},
\ '00': {'description':'Normal (default) alternate', 'attributes': {'cterm':'NONE','ctermfg':'NONE','ctermbg':'NONE','gui':'NONE','guifg':'NONE','guibg':'NONE'}},
\ '1': {'description':'Bold', 'attributes': {'cterm':'BOLD','gui':'BOLD'}},
\ '01': {'description':'Bold', 'attributes': {'cterm':'BOLD','gui':'BOLD'}},
\ '4': {'description':'Underlined', 'attributes': {'cterm':'UNDERLINE','gui':'UNDERLINE'}},
\ '04': {'description':'Underlined', 'attributes': {'cterm':'UNDERLINE','gui':'UNDERLINE'}},
\ '5': {'description':'Blink (appears as Bold)', 'attributes': {'cterm':'BOLD','gui':'BOLD'}},
\ '05': {'description':'Blink (appears as Bold)', 'attributes': {'cterm':'BOLD','gui':'BOLD'}},
\ '7': {'description':'Inverse', 'attributes': {'cterm':'REVERSE','gui':'REVERSE'}},
\ '07': {'description':'Inverse', 'attributes': {'cterm':'REVERSE','gui':'REVERSE'}},
\ '8': {'description':'Invisible (hidden)', 'attributes': {'ctermfg':'0','ctermbg':'0','guifg':'#000000','guibg':'#000000'}},
\ '08': {'description':'Invisible (hidden)', 'attributes': {'ctermfg':'0','ctermbg':'0','guifg':'#000000','guibg':'#000000'}},
\ '22': {'description':'Normal (neither bold nor faint)', 'attributes': {'cterm':'NONE','gui':'NONE'}},
\ '24': {'description':'Not underlined', 'attributes': {'cterm':'NONE','gui':'NONE'}},
\ '25': {'description':'Steady (not blinking)', 'attributes': {'cterm':'NONE','gui':'NONE'}},
\ '27': {'description':'Positive (not inverse)', 'attributes': {'cterm':'NONE','gui':'NONE'}},
\ '28': {'description':'Visible (not hidden)', 'attributes': {'ctermfg':'NONE','ctermbg':'NONE','guifg':'NONE','guibg':'NONE'}},
\ '30': {'description':'Set foreground color to Black', 'attributes': {'ctermfg':'16','guifg':'#000000'}},
\ '31': {'description':'Set foreground color to Red', 'attributes': {'ctermfg':'1','guifg':'#ff0000'}},
\ '32': {'description':'Set foreground color to Green', 'attributes': {'ctermfg':'2','guifg':'#00ff00'}},
\ '33': {'description':'Set foreground color to Yellow', 'attributes': {'ctermfg':'3','guifg':'#ffff00'}},
\ '34': {'description':'Set foreground color to Blue', 'attributes': {'ctermfg':'4','guifg':'#0000ff'}},
\ '35': {'description':'Set foreground color to Magenta', 'attributes': {'ctermfg':'5','guifg':'#990099'}},
\ '36': {'description':'Set foreground color to Cyan', 'attributes': {'ctermfg':'6','guifg':'#009999'}},
\ '37': {'description':'Set foreground color to White', 'attributes': {'ctermfg':'7','guifg':'#ffffff'}},
\ '39': {'description':'Set foreground color to default (original)', 'attributes': {'ctermfg':'NONE','guifg':'NONE'}},
\ '40': {'description':'Set background color to Black', 'attributes': {'ctermbg':'16','guibg':'#000000'}},
\ '41': {'description':'Set background color to Red', 'attributes': {'ctermbg':'1','guibg':'#ff0000'}},
\ '42': {'description':'Set background color to Green', 'attributes': {'ctermbg':'2','guibg':'#00ff00'}},
\ '43': {'description':'Set background color to Yellow', 'attributes': {'ctermbg':'3','guibg':'#ffff00'}},
\ '44': {'description':'Set background color to Blue', 'attributes': {'ctermbg':'4','guibg':'#0000ff'}},
\ '45': {'description':'Set background color to Magenta', 'attributes': {'ctermbg':'5','guibg':'#990099'}},
\ '46': {'description':'Set background color to Cyan', 'attributes': {'ctermbg':'6','guibg':'#009999'}},
\ '47': {'description':'Set background color to White', 'attributes': {'ctermbg':'7','guibg':'#ffffff'}},
\ '49': {'description':'Set background color to default (original).', 'attributes': {'ctermbg':'NONE','guibg':'NONE'}},
\ '90': {'description':'Set foreground color to Black', 'attributes': {'ctermfg':'16','guifg':'#000000'}},
\ '91': {'description':'Set foreground color to Red', 'attributes': {'ctermfg':'1','guifg':'#ff0000'}},
\ '92': {'description':'Set foreground color to Green', 'attributes': {'ctermfg':'2','guifg':'#00ff00'}},
\ '93': {'description':'Set foreground color to Yellow', 'attributes': {'ctermfg':'3','guifg':'#ffff00'}},
\ '94': {'description':'Set foreground color to Blue', 'attributes': {'ctermfg':'4','guifg':'#0000ff'}},
\ '95': {'description':'Set foreground color to Magenta', 'attributes': {'ctermfg':'5','guifg':'#990099'}},
\ '96': {'description':'Set foreground color to Cyan', 'attributes': {'ctermfg':'6','guifg':'#009999'}},
\ '97': {'description':'Set foreground color to White', 'attributes': {'ctermfg':'7','guifg':'#ffffff'}},
\ '100': {'description':'Set background color to Black', 'attributes': {'ctermbg':'16','guibg':'#000000'}},
\ '101': {'description':'Set background color to Red', 'attributes': {'ctermbg':'1','guibg':'#ff0000'}},
\ '102': {'description':'Set background color to Green', 'attributes': {'ctermbg':'2','guibg':'#00ff00'}},
\ '103': {'description':'Set background color to Yellow', 'attributes': {'ctermbg':'3','guibg':'#ffff00'}},
\ '104': {'description':'Set background color to Blue', 'attributes': {'ctermbg':'4','guibg':'#0000ff'}},
\ '105': {'description':'Set background color to Magenta', 'attributes': {'ctermbg':'5','guibg':'#990099'}},
\ '106': {'description':'Set background color to Cyan', 'attributes': {'ctermbg':'6','guibg':'#009999'}},
\ '107': {'description':'Set background color to White', 'attributes': {'ctermbg':'7','guibg':'#ffffff'}}
\ } 
" }}}

function! subprocess#shell_translate#process_current_line() "{{{
    call s:log.profile_start('process_current_line')
	  let start = reltime()
    let l:line_nr = line('.')
    let l:current_line = getline(l:line_nr)

    let l:current_line = substitute(l:current_line, '\r\+$', '', '')
    "let l:current_line = substitute(l:current_line, '^.*\r', '', '')

    " short circuit
    if l:current_line !~ "\e" && l:current_line !~ "\r"
        " control characters
        while l:current_line =~ '\b'
            let l:current_line = substitute(l:current_line, '[^\b]\b', '', 'g')
            let l:current_line = substitute(l:current_line, '^\b', '', 'g')
        endwhile

        " check for Bells
        if l:current_line =~ nr2char(7)
            let l:current_line = substitute(l:current_line, nr2char(7), '', 'g')
            echohl WarningMsg | echomsg "For shame!" | echohl None
        endif
        call setline(line('$'), l:current_line)
        return
    endif

    call setline(line('$'), l:current_line)

    let l:line_len = strlen(l:current_line)
    let l:final_line = ''
    let final_chars = []
    let l:color_changes = []

    let idx = 0
    let line_pos = 0
    while idx < l:line_len
        "call s:log.debug("checking char " . idx)
        let c = l:current_line[idx]
        " first, escape sequences
        if c == "\<Esc>"
            "call s:log.debug('looking for a match')
            " start looking for a match
            let l:seq = ''
            let l:seq_pos = 1
            let l:finished = 0
            while idx + l:seq_pos < l:line_len && l:finished == 0
                if l:current_line[idx + l:seq_pos] == "\<Esc>"
                    break
                endif
                let l:seq = l:seq . l:current_line[idx + l:seq_pos]
                let l:seq = substitute(l:seq, nr2char(7), '__BELL__', 'g')
                "call s:log.debug('evaluating sequence ' . l:seq)
                for esc in s:escape_sequences
                    if l:seq =~ esc.code
                        " do something
                        "call s:log.debug(l:seq)
                        if esc.name == 'font'
                            call add(l:color_changes, {'col':line_pos,'esc':esc,'val':l:seq})
                        elseif esc.name == 'clear_line' && idx == 0
                            normal! kdd
                        elseif esc.name == 'clear_line'
                            let final_chars = final_chars[:line_pos - 1]
                        elseif esc.name == 'cursor_right'
                            let line_pos = line_pos + 1
                        elseif esc.name == 'cursor_left'
                            let line_pos = line_pos - 1
                        elseif esc.name == 'cursor_to_column'
                            call s:log.debug('cursor to column: ' . l:seq)
                            let l:col = substitute(l:seq, '^\[', '', '')
                            let l:col = substitute(l:col, 'G$', '', '')
                            let line_pos = l:col - 1
                        endif
                        let l:finished = 1
                        let idx = idx + strlen(l:seq)
                        break
                    endif
                endfor
                let l:seq_pos = l:seq_pos + 1
            endwhile
            if l:finished == 0
                if line_pos >= len(final_chars)
                    call add(final_chars, c)
                else
                    let final_chars[line_pos] = c
                endif
                let line_pos = line_pos + 1
            endif
        elseif c == "\<CR>"
            let line_pos = 0
        elseif c == "\b"
            let line_pos = line_pos - 1
            let final_chars[line_pos] = ''
        else
            "call s:log.debug('adding ' . c . ' to final chars at line position ' . line_pos . ' comparing to ' . len(final_chars))
            if line_pos >= len(final_chars)
                call add(final_chars, c)
            else
                let final_chars[line_pos] = c
            endif
            let line_pos = line_pos + 1
        endif
        let idx = idx + 1
    endwhile

    let l:final_line = join(final_chars, '')
    "call s:log.debug(string(final_chars))

    " check for Bells
    if l:final_line =~ nr2char(7)
        let l:final_line = substitute(l:final_line, nr2char(7), '', 'g')
        echohl WarningMsg | echomsg "For shame!" | echohl None
    endif

    " strip trailing spaces
    let l:final_line = substitute(l:final_line, '\s\+$', '', '')
    if line_pos > len(l:final_line)
        let l:final_line = l:final_line . ' '
    endif

    call setline(line('.'), l:final_line)

    let l:hi_ct = 1
    for cc in l:color_changes
        "call s:log.debug(cc.val)
        let l:color_code = cc.val
        let l:color_code = substitute(l:color_code, '^\[', '', 1)
        let l:color_code = substitute(l:color_code, 'm$', '', 1)
        if l:color_code == ''
            let l:color_code = '0'
        endif
        let l:color_params = split(l:color_code, ';', 1)
        let l:highlight = ''
        for param in l:color_params
            if exists('s:font_codes['.param.']')
                for attr in keys(s:font_codes[param].attributes)
                    let l:highlight = l:highlight . ' ' . attr . '=' . s:font_codes[param].attributes[attr]
                endfor
            endif
        endfor

        let syntax_name = ' EscapeSequenceAt_' . bufnr('%') . '_' . l:line_nr . '_' . l:hi_ct
        let syntax_region = 'syntax match ' . syntax_name . ' /\%' . l:line_nr . 'l\%' . (cc.col + 1) . 'c.*$/ contains=ALL oneline'
        let syntax_link = 'highlight link ' . syntax_name . ' Normal'
        let syntax_highlight = 'highlight ' . syntax_name . l:highlight

        execute syntax_region
        execute syntax_link
        execute syntax_highlight

        "call s:log.debug(syntax_name)
        "call s:log.debug(syntax_region)
        "call s:log.debug(syntax_link)
        "call s:log.debug(syntax_highlight)

        let l:hi_ct = l:hi_ct + 1
    endfor

    " \%15l\%>2c.*\%<6c

    "call s:log.debug(string(l:color_changes))
    "call s:log.debug("start line: " . l:current_line)
    "call s:log.debug("final line: " . l:final_line)
    "call s:log.debug('FUNCTION TIME: '.reltimestr(reltime(start)))

    call s:log.profile_end('process_current_line')
endfunction
"}}}

" Logging {{{
if exists('g:Conque_Logging') && g:Conque_Logging == 1
    let s:log = log#getLogger(expand('<sfile>:t'))
    let s:profiles = {}
    function! s:log.profile_start(name)
        let s:profiles[a:name] = reltime()
    endfunction
    function! s:log.profile_end(name)
        let time = reltimestr(reltime(s:profiles[a:name]))
        call s:log.debug('PROFILE "' . a:name . '": ' . time)
    endfunction
else
    let s:log = {}
    function! s:log.debug(msg)
    endfunction
    function! s:log.info(msg)
    endfunction
    function! s:log.warn(msg)
    endfunction
    function! s:log.error(msg)
    endfunction
    function! s:log.fatal(msg)
    endfunction
endif
" }}}

" vim: foldmethod=marker
