" An example for a vimrc file.
"
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last change:	2019 Dec 17
"
" To use it, copy it to
"	       for Unix:  ~/.vimrc
"	      for Amiga:  s:.vimrc
"	 for MS-Windows:  $VIM\_vimrc
"	      for Haiku:  ~/config/settings/vim/vimrc
"	    for OpenVMS:  sys$login:.vimrc

" When started as "evim", evim.vim will already have done these settings, bail
" out.
if v:progname =~? "evim"
  finish
endif

" Get the defaults that most users want.
source $VIMRUNTIME/defaults.vim

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file (restore to previous version)
  if has('persistent_undo')
    set undofile	" keep an undo file (undo changes after closing)
  endif
endif

if &t_Co > 2 || has("gui_running")
  " Switch on highlighting the last used search pattern.
  set hlsearch
endif

" Put these in an autocmd group, so that we can delete them easily.
augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78
augroup END

" Add optional packages.
"
" The matchit plugin makes the % command work better, but it is not backwards
" compatible.
" The ! means the package won't be loaded right away but when plugins are
" loaded during initialization.
if has('syntax') && has('eval')
  packadd! matchit
endif

" my vim options
set autoindent
set ruler
set incsearch
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set mouse=a
set number
set nocompatible
filetype plugin on
runtime macros/matchit.vim
set nobackup
set nowritebackup
set laststatus=2
set encoding=utf-8  " The encoding displayed.
set fileencoding=utf-8  " The encoding written to file.

" keymap
noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>
nnoremap <C-p> : <C-u>Fzf<CR>
nnoremap <C-p><C-a> : <C-u>FzfAll<CR>
map <C-c> :%s///gn<CR> " 统计当前模式的统计个数

" use minpac to help  manage packages
packadd minpac
call minpac#init()

call minpac#add('k-takata/minpac', {'type': 'opt'})
call minpac#add('tpope/vim-unimpaired')
call minpac#add('tpope/vim-surround')
call minpac#add('tpope/vim-scriptease', {'type': 'opt'})
call minpac#add('tpope/vim-commentary')
call minpac#add('tpope/vim-projectionist')
call minpac#add('tpope/vim-obsession')
call minpac#add('tpope/vim-abolish')
call minpac#add('tpope/vim-dispatch')
call minpac#add('junegunn/fzf')
call minpac#add('nelstrom/vim-qargs')
call minpac#add('kana/vim-textobj-user')
call minpac#add('kana/vim-textobj-lastpat')
call minpac#add('mileszs/ack.vim')
call minpac#add('dense-analysis/ale')
call minpac#add('posva/vim-vue')
call minpac#add('pangloss/vim-javascript')
call minpac#add('janko-m/vim-test')

command! PackUpdate call minpac#update()
command! PackClean call minpac#clean()

" search & substitution
xnoremap * :<C-u>call <SID>VSetSearch('/')<CR>/<C-R>=@/<CR><CR>
xnoremap # :<C-u>call <SID>VSetSearch('?')<CR>?<C-R>=@/<CR><CR>

function! s:VSetSearch(cmdtype)
  let temp = @s
  norm! gv"sy
  let @/ = '\V' . substitute(escape(@s, a:cmdtype.'\'), '\n', '\\n', 'g')
  let @s = temp
endfunction


command! -nargs=0 -bar Qargs execute 'args' QuickfixFilenames()
function! QuickfixFilenames()
  let buffer_numbers = {}
  for quickfix_item in getqflist()
    let buffer_numbers[quickfix_item['bufnr']] = bufname(quickfix_item['bufnr'])
  endfor
  return join(map(values(buffer_numbers), 'fnameescape(v:val)'))
endfunction

" 简写
iab xtime <c-r>=strftime("%Y-%m-%d %H:%M:%S")<cr>
iab xdate <c-r>=strftime("%Y-%m-%d")<cr>
iab file_desc /* <cr>
      \@Author: fangqi<cr>
      \@Date: <c-r>=strftime("%Y-%m-%d %H:%M:%S")<cr><cr>
      \@LastEditors: fangqi<cr>
      \@LastEditTime: <c-r>=strftime("%Y-%m-%d %H:%M:%S")<cr><cr>
      \@Description: <cr>
      \@Copyright(c) 2021 CMIM Network Co.,Ltd. All Rights Reserve<cr>
      \/<Up><Up>

iab c_main #include <stdio.h><cr>
      \<cr>
      \int main(void) {<cr><cr>
      \<Tab>return 0;<cr>
      \<BS>}

iab cpp_main #include <iostream><cr>
      \<cr>
      \using namespace std;<cr><cr>
      \int main() {<cr><cr>
      \<Tab>return 0;<cr>
      \<BS>}

iab for for(int i = 0; i < length; i++) {<cr>
      \<Tab><cr>
      \<BS>}<Up>

iab forin for(const k in iter) {<cr>
      \<Tab><cr>
      \<BS>}<Up>

iab forof for(const v of iter) {<cr>
      \<Tab><cr>
      \<BS>}<Up>

iab for_2 for(int i = 0; i < length; i++) {<cr>
      \<Tab>for(int j = 0; j < length; j++) {<cr>
      \}<cr>
      \<BS>}<Up><Up>

iab if if () {<cr>
      \<Tab><cr>
      \<BS>}<Up><Up>

iab ife if () {<cr>
      \<Tab><cr>
      \<BS>} else {<cr>
      \<Tab><cr>
      \<BS>}<Up><Up><Up><Up>
" vue snippers
iab vue <template><cr>
      \<Tab><div class="comp-name-box"><cr></div><cr>
      \</template><cr>
      \<script><cr>
      \export default {<cr>}<cr>
      \</script><cr>
      \<style lang="scss" scoped></style><cr>
      \<Up><Up><Up><Up><Up><Up><Up>

" fzf
command! Fzf call fzf#run({'source': 'git ls-files', 'sink': 'tabe', 'window': {'width': 0.9, 'height': 0.6}})
command! FzfAll call fzf#run({'sink': 'tabe', 'window': {'width': 0.9, 'height': 0.6}})
command! FzfSource call fzf#run({'source': 'find node_modules/**/*.*', 'sink': 'tabe', 'window': {'width': 0.9, 'height': 0.6}})

" when write file
function! FileCommentCheck()
  let currFilePath = expand('%:p')
  let list = readfile(currFilePath)
  let idxLineLastEditTime = 5
  let lineLastEditTime = get(list, idxLineLastEditTime)
  if (stridx(lineLastEditTime, 'LastEditTime') > -1)
    let idxDate = match(lineLastEditTime, '\d')
    let list[idxLineLastEditTime] = strpart(lineLastEditTime, 0, idxDate) . strftime("%Y-%m-%d %H:%M:%S")

    let lineAuthor = get(list, idxLineLastEditTime - 1)
    let idxAuthor = match(lineAuthor, ':')
    let list[idxLineLastEditTime - 1] = strpart(lineAuthor, 0, idxAuthor) . ": fangqi"

    call writefile(list, currFilePath, "s")
    execute 'edit'
  endif
endfunction

function! AudoCommentFile()
  execute 'normal' "5Gf:lc$ xtime"
endfunction
command! Acf call FileCommentCheck()
augroup  fileComment
  autocmd!
  autocmd BufWritePost *.vue,*.js,*.scss,*.cpp,*.c Acf
  autocmd BufWritePost *.vim,vimrc source % 
augroup END

augroup FiletypeGroup
    autocmd!
    au BufNewFile,BufRead *.jsx set filetype=javascript.jsx
augroup END

" For JavaScript files, use 'eslint'
let g:ale_linter_aliases = {'jsx': ['css', 'javascript']}

let g:ale_linters = {
\ 'javascript': ['eslint'],
\ 'typescript': ['eslint'],
\ 'jsx': ['stylelint', 'eslint']
\ }

" Mapping in the style of unimpaired-next
nmap <silent> [W <Plug>(ale_first)
nmap <silent> [w <Plug>(ale_previous)
nmap <silent> ]w <Plug>(ale_next)
nmap <silent> ]W <Plug>(ale_last)

" prettier files
let g:ale_fixer_aliases = {'jsx': ['css', 'javascript']}

let g:ale_fixers = {
\ 'javascript': ['prettier'],
\ 'typescript': ['prettier'],
\ 'json': ['prettier'],
\ 'scss': ['prettier'],
\ 'css': ['prettier'],
\ 'vue': ['prettier'],
\ 'jsx': ['prettier'],
\ }
let g:ale_fix_on_save = 0

" Syntax: JavaScript, Vue, ...
let g:vue_pre_processors = ['scss']

" TDD(Test Driving Development)
let test#strategy = "dispatch"
