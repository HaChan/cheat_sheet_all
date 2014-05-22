###git ignore vim temporary files
Vim temporary files end with ~ so you can add to the file .gitignore the line
 - *~ .
Or
 - *.swp .
 - *.swo .
for temporary files

If you want to do it globally, you can create a .gitignore file in your home, and use the following command
 - git config --global core.excludesfile ~/.gitignore .

###Config netrc in Window
You must define:
 - environment variable %HOME% .
 - put a _netrc file in %HOME% .
If you are using Windows 7, run the cmd type this:
 - setx HOME %USERPROFILE% .
and the %HOME% will be set to 'C:\Users\"username"'
then go to it and make a file called '_netrc'
Note: for Windows, you need a '_netrc' file, not a '.netrc'.
Content:
 - machine <hostname1> .
 - login <login1> .
 - password <password1> .

For further info, please visit to: http://stackoverflow.com/questions/6031214/git-how-to-use-netrc-file-on-windows-to-save-user-and-password
