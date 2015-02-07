To switch on spell checking, use this command:

    :setlocal spell

add specify language:

    :setlocal spell spelllang=en_us

Spell check per filetype:

    autocmd FileType "file type name" setlocal spell
    autocmd BufRead,BufNewFile "*.extension" setlocal spell

Word completion(`CTRL-N` or `CTRL-P`):

    set complete+=kspell

Moving to misspelled word:

    ]s and [s

`]s`: move cursor to the next misspelled word

`[s`: move cursor to the previous misspelled word

Suggesting the correct word:

    z=

Underline misspelled word:

    hi clear SpellBad
    hi SpellBad cterm=underline
