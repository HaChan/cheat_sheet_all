## Install Ctags
### Ubuntu
 ```
 sudo apt-get install exuberant-ctags
 ```
### On Mac OSX you could use Homebrew:
 ```
 brew install ctags
 ```

## Ctags for Vim
### Generated
  - Run `ctags -R [options]` for Ctags generated automatically
  - Config ctags in .vimrc

  ```
  let g:vim_tags_auto_generate=1
  let g:vim_tags_ctags_binary="ctags"
  let g:vim_tags_project_tags_command = "{CTAGS} -R {OPTIONS} {DIRECTORY} 2>/dev/null"
  let g:vim_tags_gems_tags_command = "{CTAGS} -R {OPTIONS} `bundle show --paths` 2>/dev/null"
  let g:vim_tags_use_vim_dispatch = 0
  let g:vim_tags_use_language_field = 1
  let g:vim_tags_ignore_files = ['.gitignore', '.svnignore', '.cvsignore']
  let g:vim_tags_ignore_file_comment_pattern = '^[#"]'
  let g:vim_tags_directories = [".git", ".hg", ".svn", ".bzr", "_darcs", "CVS"]
  let g:vim_tags_main_file = 'tags'
  let g:vim_tags_extension = '.tags'
  let g:vim_tags_extension = expand($HOME)
  ```
### How to using ctags in vim:

  ```
    CTRL + ] => Jump to method
    CTRL + T or :tp => to to previous search result
    :tag update_user => Jump to update_user method
    :tn => to do next search result
    :ts => List search result
  ```
