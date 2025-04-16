" Add these to your .vimrc or init.vim

" Set path to the AI assistant script
let g:ai_assistant_path = expand('~/bin/vim-ai-assistant.py')

" Define available personas
let g:ai_personas = ['general', 'hemingway', 'formal', 'academic', 'creative']
let g:ai_current_persona = 'general'

" Function to get AI suggestions with persona
function! GetAISuggestions(mode, ...) abort
  let l:filename = expand('%:p')
  if empty(l:filename)
    echo "Save the file first"
    return
  endif
  
  " Get persona (optional argument or use current)
  let l:persona = a:0 > 0 ? a:1 : g:ai_current_persona
  
  " Save current file
  silent write
  
  " Call external script
  let l:cmd = g:ai_assistant_path . ' "' . l:filename . '" --mode=' . a:mode . ' --persona=' . l:persona
  let l:output = system(l:cmd)
  
  if a:mode == 'inline'
    " Load suggestions into quickfix list
    let l:qf_entries = json_decode(l:output)
    call setqflist(l:qf_entries)
    copen
    echo "Showing " . l:persona . " style suggestions"
  else
    " Open suggestions in a split
    " Trim any whitespace from the output to get the clean filename
    let l:file_path = substitute(l:output, '^\s*\(.\{-}\)\s*$', '\1', '')
    if filereadable(l:file_path)
      execute 'split ' . fnameescape(l:file_path)
      setlocal readonly
    else
      echo "Error: Could not read suggestions file"
      echo "Output was: " . l:output
    endif
  endif
endfunction

" Function to change current persona
function! ChangeAIPersona(persona) abort
  if index(g:ai_personas, a:persona) >= 0
    let g:ai_current_persona = a:persona
    echo "AI persona changed to: " . a:persona
  else
    echo "Invalid persona. Available: " . join(g:ai_personas, ", ")
  endif
endfunction

" Commands
command! -nargs=? AISuggest call GetAISuggestions('comments', <f-args>)
command! -nargs=? AIInline call GetAISuggestions('inline', <f-args>)
command! -nargs=? AISummary call GetAISuggestions('summary', <f-args>)
command! -nargs=1 -complete=customlist,AIPersonaComplete AIPersona call ChangeAIPersona(<q-args>)

" Command completion for personas
function! AIPersonaComplete(ArgLead, CmdLine, CursorPos)
  return filter(copy(g:ai_personas), 'v:val =~ "^" . a:ArgLead')
endfunction

" Create commands for each persona
for persona in g:ai_personas
  let capitalized_persona = toupper(persona[0]) . persona[1:]
  execute 'command! ' . capitalized_persona . 'Suggest call GetAISuggestions("comments", "' . persona . '")'
  execute 'command! ' . capitalized_persona . 'Inline call GetAISuggestions("inline", "' . persona . '")'
endfor

" Key mappings for default persona
nnoremap <Leader>as :AISuggest<CR>
nnoremap <Leader>ai :AIInline<CR>
nnoremap <Leader>au :AISummary<CR>

" Optional: Quick persona selection menu
function! AIPersonaMenu()
  let l:choices = {}
  let l:i = 1
  for persona in g:ai_personas
    let l:choices[l:i] = persona
    let l:i += 1
  endfor
  
  echo "Select AI Persona:"
  for [key, val] in items(l:choices)
    echo key . ": " . val
  endfor
  
  let l:choice = input("Persona (1-" . len(l:choices) . "): ")
  if has_key(l:choices, l:choice)
    call ChangeAIPersona(l:choices[l:choice])
  endif
endfunction

nnoremap <Leader>ap :call AIPersonaMenu()<CR>

" Optional: Add syntax highlighting for different personas in quickfix list
augroup AIPersonaSyntax
  autocmd!
  autocmd BufEnter quickfix call s:HighlightAIPersonas()
augroup END

" Function to get AI suggestions from all personas and combine them
function! GetAllPersonaSuggestions() abort
  let l:filename = expand('%:p')
  if empty(l:filename)
    echo "Save the file first"
    return
  endif
  
  " Save current file
  silent write
  
  " Initialize empty quickfix list
  call setqflist([])
  
  " Show progress
  echo "Getting suggestions from all personas (this may take a while)..."
  
  " Process each persona
  for persona in g:ai_personas
    echo "Processing " . persona . " suggestions..."
    
    " Call external script with proper argument format
    let l:cmd = g:ai_assistant_path . ' "' . l:filename . '" --mode inline --persona ' . persona
    let l:output = system(l:cmd)
    
    " Parse output and add to quickfix list
    let l:qf_entries = json_decode(l:output)
    call setqflist(l:qf_entries, 'a')  " Append to the quickfix list
  endfor
  
  " Open the quickfix window
  copen
  echo "Showing combined suggestions from all personas"
endfunction

" Command for getting suggestions from all personas
command! AIAll call GetAllPersonaSuggestions()

function! s:HighlightAIPersonas()
  syntax match qfPersonaHemingway /\[HEMINGWAY\].*/ contained
  syntax match qfPersonaFormal /\[FORMAL\].*/ contained
  syntax match qfPersonaAcademic /\[ACADEMIC\].*/ contained
  syntax match qfPersonaCreative /\[CREATIVE\].*/ contained
  syntax match qfPersonaGeneral /\[GENERAL\].*/ contained
  
  highlight qfPersonaHemingway ctermfg=red guifg=#FF5555
  highlight qfPersonaFormal ctermfg=yellow guifg=#FFAA55
  highlight qfPersonaAcademic ctermfg=blue guifg=#5599FF
  highlight qfPersonaCreative ctermfg=green guifg=#55DD55
  highlight qfPersonaGeneral ctermfg=white guifg=#DDDDDD
  
  syntax cluster qfPersonas contains=qfPersonaHemingway,qfPersonaFormal,qfPersonaAcademic,qfPersonaCreative,qfPersonaGeneral
  syntax match qfLine /^.*/  contains=@qfPersonas
endfunction
