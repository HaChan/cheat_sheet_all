##Basic Keyboard Shortcuts
 - **Up/Down Arrows**: the _up_ and _down_ arrow key move through the last used commands.

 - **Crtl + Left and Ctrl + Right**: jump between words in the command. On MacOS and Windows, the shortcut is **ESC + B** and **ESC + F** instead.

 - **Home and End**: move cursor to the beginning and the end of the current command, respectively.

 - **Ctrl A** and **Ctrl E**: same with **Home** and **End** keys.

 - **Ctrl + U**: clear entire line

 - **Ctrl + K**: deletesthe line from the current position cursor to the end of the line.

 - **Ctrl + W**: deletes the word before the cursor only.


##Searching for Commands in the History
 - **Ctrl + r**
 - **Ctrl + g**:, Quit the search and back to the command line empty-handed.


##Terminal Shorthand
###File Path
#####File path shorthand
`(-)`: `cd -`

This will move back to the last working directory.

Thus, if you are working in, say, your documents folder `(~/Documents)` and moved over to the `/etc/` briefly, you could switch right back by typing `cd -` and hitting Enter.

#####Using history
Accessing recently used commands is something Terminal users often need to do. And there is some pretty nice shorthand, most of which use the handy bang symbol (!).

------

To reuse the last typed command, using `!!`. If you run a command that needs root privileges but forget to use `sudo` at beginning, use:

    sudo !!

This will run the last command using root privileges.

`!!`: Refer to the previous command.  This is a synonym for `!-1`.


If the command is further back in the history, use bang conjunction with the command string to find and run it. Example: to run the last `cat` command, types:

    !cat

`!string`: Refer to the most recent command preceding the current position in the history list starting with string.

To see the last `cat` command, types:

    !cat:p

This will print and add it to the end of history. To run it, simply type `!!` and hit enter.

------

To run a differrent command with the same arguments with the last command, use `!$`. For example: create a new folder and the cd to the new directory

    mkdir new/file/path
    cd !$

The `!$` represents the arguments from the last command

------

Another common problem is mistyping the command. Example, using `touch` to create new file, but accidentally type `toich`:

    toich /path/to/a/new/document/buried/deep/in/the/filesystem

Instead of typing the hole thing, just run:

    ^toich^touch

`^string1^string2^`: Quick substitution.  Repeat the last command, replacing string1 with string2.  Equivalent to ``!!:s/string1/string2/``

This will find the first instance of `toich` in the last command and replace it with `touch`.

`!number` Refer to command line _number_ in history command. So, typing `!1000` will run the command in the line 1000 in the `history`.

------

#####Expansions
When working with variations of a file - like backups or differrent file types -, typing the file path over and over again is a tedious part. Using the brace symbols `{}` will help perform batch operations on multiple versions of a file.

Example, to rename a part of a filename. Instead of typing:

    mv /path/to/file.txt /path/to/file.xml

just type:

    mv /path/to/file.{txt,xml}

This runs the command with the same arguments, only with the parts inside the brace changed - the first part corresponding to the first argument, the second part corresponding to the seconf argument.


The most common example of this is when backing up a file. Example, for back up `rc.conf` file, type:

    sudo cp /etc/rc.conf{,-old}

This will append `-old` to the filename after copying. If the new file does not work, to restore the backed up file, just type:

    sudo mv /etc/rc.conf{-old,}


The braces can also work when moving or creating multiple files at once. Example: to create 3 numberred directories, type:

    mkdir new_folder{1,2,3}

