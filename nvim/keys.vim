let mapleader = ","

nnoremap <leader>n :tabnew

if has("nvim")
    nnoremap <leader>. :tabnew ~/.config/nvim/init.vim<CR>
else
    nnoremap <leader>. :tabnew ~/.vimrc<CR>
endif


" FloatTerm
nnoremap <leader>t :FloatermNew<CR>

" FuzzyFinder
noremap <leader>f :GFiles<CR>
noremap <leader>e :Files<CR>

" Cocexplorer
nmap <leader>1 :CocCommand explorer<CR>
