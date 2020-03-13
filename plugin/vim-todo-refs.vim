" Author: Daniel Csillag

function! MatchStrPosAll(expr, pat, ...)
    let start = a:0 ? a:1 : 0
    let lst = []
    let cnt = 1
    let found = match(a:expr, a:pat, start, cnt)
    while found != -1
        call add(lst, matchstrpos(a:expr, a:pat, start, cnt))
        let cnt += 1
        let found = match(a:expr, a:pat, start, cnt)
    endwhile
    return lst
endfunction

function! CountTODOs()
    let l:pattern = "\\<TODO\\>\\|\\<FIXME\\>\\|\\<BUG\\>"

    let b:todorefs_todos = []
    call map(getline(1,'$'), { i,v -> extend(b:todorefs_todos, map(MatchStrPosAll(v, l:pattern), { j,w -> [i+1] + w })) })
endfunction

augroup todo_refs
    autocmd!
    autocmd CursorHold,BufReadPost,BufWritePost * let b:todorefs_todoCount = CountTODOs()
augroup END

function! GetTODOCount()
    if exists("b:todorefs_offset")
        let l:offset = b:todorefs_offset
    elseif exists("g:todorefs_offset")
        let l:offset = g:todorefs_offset
    else
        let l:offset = 0
    endif

    if exists("b:todorefs_todos")
        return len(b:todorefs_todos) + l:offset
    else
        return 0
    endif
endfunction

function! OpenTODOQuickfix()
    if !exists("b:todorefs_todos")
        call CountTODOs()
    endif

    cexpr map(b:todorefs_todos, { i,v -> expand('%') . ":" . v[0] . ":" . v[2] })
    copen
endfunction

command! TODORefsQuickfix :call OpenTODOQuickfix()

" VIM: let b:todorefs_offset=-3
