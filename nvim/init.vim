" refer: http://d.hatena.ne.jp/wiredool/20120618/1340019962
filetype off
filetype plugin indent off

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call plug#begin('~/.vim/plugged')

Plug 'Shougo/neomru.vim'

Plug 'Shougo/unite.vim'
let g:unite_source_history_yank_enable =1
let g:unite_source_file_mru_limit = 50
let g:unite_split_rule = 'botright'
nnoremap <silent> <Space>b :<C-u>Unite -vertical buffer:-<CR>
nnoremap <silent> <Space>f :<C-u>Unite -vertical file_rec/async:!<CR>
nnoremap <silent> <Space>r :<C-u>Unite -vertical -buffer-name=register register<CR>

Plug 'Shougo/vimproc.vim', { 'do' : 'make' }

Plug 'tomasr/molokai'

Plug 'tyru/caw.vim'
let g:caw_no_default_keymappings = 1
nmap <silent> ,/ <Plug>(caw:zeropos:toggle)
vmap <silent> ,/ <Plug>(caw:zeropos:toggle)

Plug 'airblade/vim-gitgutter'
let g:rooter_disable_map = 1
let g:rooter_change_directory_for_non_project_files = 1
set signcolumn=yes
let g:gitgutter_sign_added = '+'
let g:gitgutter_sign_modified = '➜'
let g:gitgutter_sign_removed = '_'
let g:gitgutter_realtime = 0
let g:gitgutter_eager = 1
let g:gitgutter_max_signs = 2000
let g:gitgutter_escape_grep = 1

Plug 'kannokanno/previm', { 'for' : 'markdown' }
let g:previm_open_cmd = 'chromium'
let g:previm_enable_realtime = 1
augroup PrevimSettings
    autocmd!
    autocmd BufNewFile,BufRead *.{md,markdown}  set filetype=markdown
augroup END

Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'

"""""""" go """"""""
Plug 'mattn/vim-lsp-settings'
Plug 'mattn/vim-goimports'

""""""" rust """""""
Plug 'rust-lang/rust.vim'
let g:rustfmt_autosave = 1

call plug#end()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" general vim settings
" カーソルの位置を表示
set ruler

" マウス邪魔
set mouse=c

" ファイル閉じても undo したい
set undofile

" 検索でループしない
set nowrapscan

" 表示できない文字を 16 進数で表示
set display=uhex

" 行番号を表示
set number

" TAB 関連の設定
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set smarttab

" nvim では ~/.local/share/nvim/swap の下に作成されるので別にいいや？
" スワップファイルを作らない
" set noswapfile

" yank したら clipboard
set clipboard+=unnamedplus

" 自動インデント
set smartindent

" タブ
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set smarttab

" マーカーで折りたたみ
set foldmethod=marker

let mapleader = "\<Space>"

" status line に文字コードを改行コード表示
"set statusline=%<%F\ %m%r%h%w%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}%=%l,%c%V%8P
" refer: http://tasuten.hatenablog.com/entry/20120505/1336217620
let ff_table = {'dos' : 'CR+LF', 'unix' : 'LF', 'mac' : 'CR' }
set statusline=%<%F%=%m%r%h%w%{'['.(&fenc!=''?&fenc:&enc).']['.ff_table[&ff].']'}\ %l,%c
highlight statusline term=NONE cterm=NONE ctermfg=yellow ctermbg=235

" 対応する括弧のデフォルトハイライトが見づらい
highlight MatchParen ctermbg=0

" カーソル行をハイライト
" refer: http://qiita.com/koara-local/items/57b5f2847b3506a6485b
" 初期状態はcursorlineを表示しない
" 以下の一行は必ずcolorschemeの設定後に追加すること
highlight clear CursorLine

" 'cursorline' を必要な時にだけ有効にする
" http://d.hatena.ne.jp/thinca/20090530/1243615055
" を少し改造、number の highlight は常に有効にする
augroup vimrc-auto-cursorline
  autocmd!
  autocmd CursorMoved,CursorMovedI * call s:auto_cursorline('CursorMoved')
  autocmd CursorHold,CursorHoldI * call s:auto_cursorline('CursorHold')
  autocmd WinEnter * call s:auto_cursorline('WinEnter')
  autocmd WinLeave * call s:auto_cursorline('WinLeave')

  setlocal cursorline
  highlight clear CursorLine

  let s:cursorline_lock = 0
  function! s:auto_cursorline(event)
    if a:event ==# 'WinEnter'
      setlocal cursorline
      highlight CursorLine term=underline cterm=underline guibg=Grey90 " ADD
      let s:cursorline_lock = 2
    elseif a:event ==# 'WinLeave'
      setlocal nocursorline
      highlight clear CursorLine " ADD
    elseif a:event ==# 'CursorMoved'
      if s:cursorline_lock
        if 1 < s:cursorline_lock
          let s:cursorline_lock = 1
        else
          " setlocal nocursorline
          highlight clear CursorLine " ADD
          let s:cursorline_lock = 0
        endif
      endif
    elseif a:event ==# 'CursorHold'
      " setlocal cursorline
      highlight CursorLine term=underline cterm=underline guibg=Grey90 " ADD
      let s:cursorline_lock = 1
    endif
  endfunction
augroup END

" diff の色を git っぽくしたい。
function! s:diff_color()
    highlight DiffAdded ctermfg=2
    highlight DiffRemoved ctermfg=160
    highlight PreProc ctermfg=15
    highlight Statement ctermfg=30
    highlight Type ctermfg=15 cterm=BOLD
endfunction

augroup diffColor
    autocmd!
    autocmd FileType diff call s:diff_color()
augroup END

" Ctrl+h, Ctrl+l で 行頭、行末。
noremap <C-h> 0
noremap <C-l> $

" grep
function! s:ngrep()
    " -auto-preview HDD I/O が凄い時に grep すると固まる。。。
    " 面倒だけど毎回 p で preview する。
    " -winwidth なんとかならんか。。。
    Unite -vertical -no-quit -multi-line -max-multi-lines=1 -no-empty -winwidth=116 grep
endfunction
nnoremap <silent> <C-g><C-g> :<C-u>call <SID>ngrep()<CR>

" refer: http://stackoverflow.com/questions/1533565/how-to-get-visually-selected-text-in-vimscript
function! s:get_visual_selection()
    " Why is this not a built-in Vim script function?!
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ''
    endif
    let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
    return join(lines, "\n")
endfunction

function! s:vgrep()
    UniteWithCursorWord -vertical -no-quit -multi-line -max-multi-lines=1 -no-empty -winwidth=116 grep
endfunction
vnoremap <silent> <C-g><C-g> :<C-u>call <SID>vgrep()<CR>

if executable('hw')
    let g:unite_source_grep_command = 'hw'
    let g:unite_source_grep_default_opts = '--no-group --no-color'
    let g:unite_source_grep_recursive_opt = ''
    "vnoremap ,g y:Unite grep::-iRn:<C-R>=escape(@", '\\.*$^[]')<CR><CR>
endif

" clang-format
function! s:clang_format(...)
    let now_line = line(".")
    let col = 110
    if a:0 >= 1
        let col = a:1
    end
    exec ":%! clang-format-3.8 -style=\"{BasedOnStyle: Google, ColumnLimit: ".col.", IndentWidth: 4, Standard: C++11, AccessModifierOffset: -4, IndentCaseLabels: false, BreakConstructorInitializersBeforeComma: true}\""
    exec ":" . now_line
endfunction

if executable('clang-format-3.8')
    command! -nargs=? Format :call s:clang_format(<f-args>)
endif

function! s:tig_blame()
    let directory = expand("%:p:h")
    let filename = expand("%:p:t")
    exec ":! tmux new-window 'cd " . directory ." ;and tig blame " . filename . "'"
endfunction

if !empty($TMUX)
    " 個人的に blame は tig の方が見やすい。
    command! Blame :call s:tig_blame()
else
    " tmux 上じゃない場合は新しい terminal?
endif

" 選択範囲の構造体の stringer を出力する
if executable('go-stringer')
    function! s:go_stringer()
        let selection_text = s:get_visual_selection()
        let [line_end, column_end] = getpos("'>")[1:2]
        let input_text = system("go-stringer \"" . selection_text . "\"")
        :call cursor(line_end, column_end)
        exec ":set paste"
        exec ":normal o \n" . input_text
        exec ":set nopaste"
    endfunction

    command! -range GoString call s:go_stringer()
endif


set noshowmode
filetype plugin indent on

" カラースキーム
colorscheme molokai
