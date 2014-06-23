This tutorial is from http://www.ee.surrey.ac.uk/Teaching/Unix/index.html.
I have cloned and made some modification (my point of view) from it to github markdown.

#Unix Introduction

Content

[Unix Tutorial 1](#unix-tutorial-one-listing-making-changing-directory-and-file)

[Unix Tutorial 2](#unix-tutorial-two-copy-move-remove-display-search-file-and-folder)

[Unix Tutorial 3](#unix-tutorial-three-redirect-and-pipe)

[Unix Tutorial 4](#unix-tutorial-four-wildcards-filename-convention-get-help)

[Unix Tutorial 5](#unix-tutorial-five-file-security-access-right-process-and-jobs)

[Unix Tutorial 6](#unix-tutorial-six-other-useful-commands)

[Unix Tutorial 7](#unix-tutorial-seven-compiling-unix-software-packages)

[Unix Tutorial 8](#unix-tutorial-eight)

###The UNIX operating system
The Unix operating system is made up of three part: _the kernel_, _the shell_ and
_the program_.
**The Kernel**
 - It allocates time and memory to programs and handles the filestore and communication in response to systemcall.
 As an illustration of the way that the shell and the kernel work together, suppose a user types rm myfile (which has the effect of removing the file myfile). The shell searches the filestore for the file containing the program rm, and then requests the kernel, through system calls, to execute the program rm on myfile. When the process rm myfile has finished running, the shell then returns the UNIX prompt % to the user, indicating that it is waiting for further commands.

**The shell**
 - It act as an interface between the user and the kernel. The shell is th CLI (command line interface). It interprets the commands the users types in and arranges for them to be carried out. The commands are themselves programs.
User can use different shell on the same machine.

###File and process
- Everything in UNIX is either a process or file.
- A process is an executing program idenified by a unique PID (process identifier)
- A file is a collection of data. They are created by users using text editor, running complier etc.

###Directory structure
![alt text](unix-tree.png "Unix directory structure")


# Unix tutorial one (listing, making, changing directory and file)

###Listing files and directories
**ls (list)**

When you first login, your current working directory is your home directory. Your home directory has the same name as your user-name, and it is where your personal files and subdirectories are saved.

To see what file and folder is in the directory, type:

- `ls`

**ls** can only list all the files whose name dose not begin with a dot (.). Files beginning with a dot (.) are known as hidden files and usually contain important program configuration information.

To list all files, use:

- `ls -a`

###Making directory
`mkdir file_name`

###The directory . and ..
**The current directory (.)**
In UNIX (.) means the current directory

**The parent directory (..)**
In UNIX (..) means the parent directory

**pwd (print working directory)**

**~ (home directory)**
Home directories can also be referred to by the tilde ~ character. It can be used to specify paths starting at your home directory

#UNIX tutorial two (copy, move, remove, display, search file and folder)

###Copying files
**cp (copy)**

`cp file1 file2` is the command which make a copy of file1 in the current directory and call it file2.

More particular form: `cp path/to/file1 path/to/destination`

###Moving files
`mv file1 file2` moves or renames (file1 to file2)

To move a file from one place to another, use the mv command. This has the effect of moving rather than copying the file, so you end up with only one file rather than two.

It can also be used to rename a file, by moving the file to the same directory, but giving it a different name.

###Removing files and directories
`rm path/to/file` delete a file located in the path

`rmdir path/to/directory` delete a directory

###Displaying the contents of a file on the screen
**cat (concatenate)**

The command `cat` can be used to display the content of a file on the screen.

`cat path/to/file`

**less**
This command writes the contents of a file onto the screena page at a time.

`less path/to/file`

Press the [space-bar] if you want to see another page, type[q] to quit.

**head**
Writes the first 10 lines of a file to the screen.

`head path/to/file`

**tail**
The tail command writes the last ten lines of a file to the screen.

`tail path/to/file`

###Searching the contents of a file
#####Simple searching using less
Using less, you can search though a text file for a keyword (pattern). Example:

`less file`

then:

`/pattern`

less finds and highlights the keyword. Type [n] to search for the next occurrence of the word.

#####grep
`grep` searchs files for specified words or patterns.

`grep pattern path/to/file`

#####wc(word count)
To do a word count on a file, type:

`wc -w path/to/file`

To count how many line the file has, type:

`wc -l path/to/file`


#Unix Tutorial three (redirect and pipe)

###Redirection
Most processes initiated by UNIX commands write to the standard output (terminal screen), and many take their input from the standard input (read from keyboard). There is also the standard error, where processes write their error messages, by default, to the terminal screen.

We have already seen one use of the cat command to write the contents of a file to the screen.

Now type cat without specifing a file to read
`cat`
Then type a few words on the keyboard and press the [Return] key.

Finally press `[ctrl] + [d]` (^D) to end thee input

If you run the cat command without specifing a file to read, it reads the standard input (the keyboard), and on receiving the 'end of file' (^D), copies it to the standard output (the screen).

In UNIX, we can redirect both the input and the output of commands.

###Redirecting the Output
We use the `>` symbol to redirect the output of a command. Example, to create a file **list1**, type:

`cat > list1`

The `cat` command will read the standard input (keyboard) because there is no specific file to read. and when receiving the 'end of file' (ctrl-d or ^D), it copied to the output, which now redirected to file **list1**.

To read the file list1, type: `cat list1`.

###Apending to a file
The form >> appends standard output to a file. So to add more items to the file **list1**, type

`cat >> list1`

The type lines that you want to append, and hit ^D to stop.

To join files into one file, simply do:

`cat file1 file2 ... filen > another_file`

###Redirecting the Input
We use the `<` symbol to redirect the input of a command.

To sort a list alphabetically or numerically, type:

`sort [list of word]`

Using `<` to redirect the input to come from file rather than the keyboard.

Example:

`sort < file_list`

The list in **file_list** will be sorted and output to screen

To output the sorted list to a file, type,

`sort < file_input > file_output`

Use `cat` to read the contents of the file_output

###Pipes
To see who is on the system (logged-in user), type:

`who`

One method to get a sorted list of names is to type:

`who > names.txt
sort < names.txt`

This is a bit slow and you have to remember to remove the temporary file called names when you have finished. What you really want to do is connect the output of the who command directly to the input of the sort command. This is exactly what pipes do. The symbol for a pipe is the vertical bar `|`

`who | sort`

To see how many users are logged on, type:

`who | wc -l`

#UNIX Tutorial Four (wildcards, filename convention, get help)
###Wildcards
#####The * wildcard
The character `*` is called a wildcard, and will match against none or more character(s) in a file (or directory) name. Example, in your directory, type:

`ls list*`

This will list all files in the current directory starting with **list...**

Typing:

`ls *list`

will list all files in the current directory ending with **...list**

#####The ? wildcard
The character `?` will match exactly one character

So **?ouse** will maych files like **house** or **mouse**, but not **grouse**

###Filename conventions
A directory is merely a special type of file. So rules and conventions for naming files apply also to directories.

In naming files, character with special meanings such as `/ * & %`, chould be avoided. Also, avoid using space within names. The safest way to name a file is to use only alphanumeric characters, that is, letters and numbers, together with _ (underscore) and . (dot).

File names conventionally start with a lower-case letter, and may end with a dot followed by a group of letters indicating the contents of the file. For example, all files consisting of C code may be named with the ending .c like **file1.c**.

###Getting Help
#####On-line Manuals
There are on-line manuals which gives information about most commands. The manual pages tell you which options a particular command can take, and how each option modifies the behaviour of the command. Type **_man command_** to read the manual page for a particular command.

Example:

`man wc` to find out more about the wc (word count) command.

Alternatively

`whatis wc` gives a one-line description of the command, but omits any information about options etc.

#####Apropos
When you are not sure of the exact name of a command, type:

`apropos keyword`

will give you the commands with the keyword in their manual page header.

#UNIX Tutorial Five (file security, access right, process and jobs)
###File system security (access right)
To view lots of details about the contents of the directory, type:

`ls -l (l for long listing!)`

Each file (and directory) has associated access rights, which may be found by typing `ls -l`. Also, `ls -lg` give additional information as to which group owns the file.

`-rwxrw-r-- 1 user group 2450 Jun19 13:14 file1`

In the left-hand column is a 10 symbol string consisting of the symbols d, r, w, x, -, and, occasionally, s or S. If d is present, it will be at the left hand end of the string, and indicates a directory, otherwise - will be the starting symbol of the string.

The 9 remaing symbols indicate the permissions (rights), and are taken as three group of 3.
- The left group of 3 gives the file permissions for the user that owns the file (or directory).
- The middle group of 3 gives the file permissions for the group of people that own the file (or directory).
- the rigthmost group gives the permissions for all other.

The symbols r, w, etc.., have slightly different meanings depending on whether they refer to a simple file or to a directory.

#####Access right on files
- `r` (or -), indicates read permissions (or otherwise), that is, the presence or absence of permission to read and copy the file.
- `w`(or -), indicates write permission (or otherwise), that is, the permission (or otherwise) to change a file 
- `x` (or -), indicates execution permission (or otherwise), that is, the permission to execute a file, where appropriate

#####Access right on drectories.
- r allows users to list files in the directory;
- w means that users may delete files from the directory or move file onto it;
- x means the right to access files in the directory. This implies that you may read files in the directory provided you have read permission on the individual files.

Example:

|          |                                                               |
|:---------|:--------------------------------------------------------------|
|-rwxrwxrwx| a file that everyone can read, write and execute (and delete).|
|-rw-------|a file that only the owner can read and write - no-one else can read or write and no-one has execution rights (e.g. your mailbox file)|

###Changing access right
#####chmod (changeing a file mode)
Only the owner of a file can use chmod to change the permissions of a file. The options of chmod are as follows

|**Symbol**| Meaning |
|:--------:|:--------|
|u| user |
|g| group |
|o| other |
|a| all |
|r| read |
|w| write (and delete) |
|x|execute (and access directory)|
|+| add permission |
|-| take away permission |

Example:

To remove read, write and execure permissions on a file for the group and others, type:

`chmod go-rwx filename`

To give read and write permissions on a file to all, type:

`chmod a+rw file_name`

#####Processes and Jobs
A process is an executing program identified by a unique PID (process identifier). To see information about processes with PID and status, type:

`ps`

A process maybe in foreground, background, or be suspended. In general the shell does not return the UNIX prompt until the process has finished executing.

Some processes take a long time to run and hold up the terminal. Backgrounding a long process has the effect that the UNIX prompt is returned immediately, and other tasks can be carried out while the original process continues executing.

**Running background processes**

To background a process, type `&` at the end of the command line. Example, the command `sleep` waits a given number of seconds before continuing.

`sleep 10`

This will wait 10 seconds before returning the command prompt. Until the command prompt is returned, you can do nothing except wait.

To run it in the background, type:

`sleep 10 &`

The `&` runs the job in background and returns the prompt strait away, allowing you to run other programs.

Backgrounding is useful for jobs which take along time to complete.

**Backgrounding a current foreground process**

At the terminal (propmt) typpe:

`sleep 1000`

You can suspend the process running in the foreground by typing `^Z` (mean `[crtl] + [z]`. Then to put it in the background, type:

`bg`

###Listing suspended and background processes
When a process is running, backgrounded or suspended, it will be entered onto a list along with job number. To examine this list, type:

`jobs`

An example of a job list could be:

`[1] Suspended sleep 1000
[2] Running netscape
[3] Running matlab`

To restart (foreground) a suspended processes, type:

`fg %jobnumber`

Example, to restart sleep 1000, type:

`fg %1`

Typing `fg` with no job number foregrounds the last suspended process.

###Killing a process
#####Kill (terminate or signal a process)
It is sometimes necessary to kill a process (for example, when an executing program is in an infinite loop)

To kill a job running in the foreground, type ^C ([ctrl]+[c]). For example, run

`sleep 10000
^C`

To kill a suspended or background processes, type:

`kill %jobnumber`

Example:

`sleep 1000 &
jobs`

If it is job number 2, type:

`kill %2`

Check job list again to see if the process has been removed.

#####ps (process status)

Alternatively, processes can be killed by finding their process number (PIDs) and using `kill PID_number`

`sleep 1000 &
ps`

`PID TT S TIME COMMAND
20077 pts/5 S 0:05 sleep 1000
21563 pts/5 T 0:00 ps
21873 pts/5 S 0:25 bash`

To kill off the process **sleep 1000**, type:

`kill 20077`

and type ps again to o check if it has been removed from the list.

If a process refuses to be killed, use the -9 option, type:

`kill -9 20077`


#UNIX tutorial six (other useful commands)

#####df
The **df** command outputs reports on the space left on the file system. Example, to find out how much space is left, type:

`df .`

#####du
The **du** command outputs the number of kilobytes used by each subdirectory.

`du -s *`

The `-s` flag will display only a sumary (total size) and the `*` means all files and directory in the folder.

#####gzip
This reduces the size of a file, Example, type:

`ls -l file.txt`

then note the size of the file. Then to compress file.txt, type:

`gzip file.txt`

This will compress the file and replace it in a file called **file.txt.gz**

To expand the file, use **gunzip** command

`gunzip file.txt.gz`

#####zcat

**zcat** will read gzipped file without needing to uncompress them first

`zcat file.txt.gz`

If the text is too long, pipe the output through **less**

``zcat file.txt.gz | less`

#####file
**file** classifies the named files according to the type of data they contain, for example ascii (text), pictures, compressed data, etc..

`file *`

#####diff
This command compares the contents of two files and display the differences.

`diff file1 file2`

Lines beginning with a < denotes file1, while lines beginning with a > denotes file2.

#####find
This searches through the directories for files and directories with a given name, date, size, or any other attribute you care to specify.

To search for all file with extension **.txt** in the current directory (.) then printing the name of file to the screen, type:

`find . -name *.txt -print`

In linux (ubuntu), just type:

`find . *txt`

To find files over 1Mb in size + display the result as a long listing, type:

`find . -size +1M -ls`

#####history
The shell keeps an ordered list of all the commands that you have entered. Each command is given a number according to the order it was entered.

`history (show command history list)`

To recall commands, use:

`!! (recall last command)`

`!-3 (recall third most recent command)`

`!5 (recall 5th command in list)`

`!grep (recall last command starting with grep)`

To increase the size of the history buffer, type:

`set history=1000`

#UNIX tutorial Seven (compiling UNIX software packages)
There are a number of step to install the software:
- Locate and download the source code (whish usually compressed).
- Unpacke the source code.
- Compile the source code.
- Install the executable.
- Set paths to the installation directory.

The most difficult is the compilation stage.

#####Compiling Source code
All high-level language code must be converted into a form the computer understands.

For example, C language source code is converted into a lower-level language called assembly language.

The assembly language code is then converted into object code which are fragments of code which the computer understands directly.

The final stage in compiling a program involves linking the object code to code libraries which contain certain built-in functions. This final stage produces an executable program.

#####make and the MakeFile
The **make** command allows programmers to manage large programs or groups of programs. It aids in developing large programs by keeping track of which portions of the entire program have been changed, compiling only those parts of the program which have changed since the last compile.

The **make** program gets its set of compile rules from a text file called **Makefile** which resides in the same directory as the source files. It contains information on how to compile the software, e.g, the optimisation level, whether to include debugging info in the executable. It also contains information on where to install the finished compiled binaries (executables), manual pages, data files, dependent library files, configuration files, etc.

Some packages require you to edit the Makefile by hand to set the final installation directory and any other parameters. However, many packages are now being distributed with the GNU configure utility.

#####configure
As the number of UNIX variants increased, it became harder to write programs which could run on all variants. Developers frequently did not have access to every system, and the characteristics of some systems changed from version to version. The GNU configure and build system simplifies the building of programs distributed as source code. All programs are built using a simple, standardised, two step process. The program builder need not install any special tools in order to build the program.

The configure shell script attempts to guess correct values for various system-dependent variables used during compilation. It uses those values to create a Makefile in each directory of the package.

The simpliest way to compile a package is:

1. cd to the directory containing the source code.
2. Type ./configure to configure the package for your system.
3. Type **make** to compile the package.
4. Optionally, type **make check** to run any self-tests that come with the package.
5. Type **make install** to install the programs and any data files and documentation.
6. Optionally, type make clean to remove the program binaries and object files from the source code directory 

The configure utility supports a wide variety of options. You can usually use the --help option to get a list of interesting options for a particular configure script.

The only generic options you are likely to use are the --prefix and --exec-prefix options. These options are used to specify the installation directories.  

The directory named by the --prefix option will hold machine independent files such as documentation, data and configuration files.

The directory named by the --exec-prefix option, (which is normally a subdirectory of the --prefix directory), will hold machine dependent files such as executables.

###Downloading and extracting source code
Find an appropriate package, source code and put it in a folder.

Then using `gunzip` and `tar -xvf` to uncompress the file.

###Configuring and creating the Makefile
The first thing to do is carefully read the README and INSTALL text files (use the less command). These contain important information on how to compile and run the software.

We need to create an install directory in the home directory.

`mkdir ~/directory_for_install`

Then run the configure utility setting the installation path to this.

`./configure --prefix=$HOME/directory_for_install`

If configure has run correctly, it will have created a Makefile with all necessary options. You can view the Makefile but do not edit its content.

###Building the package
Now you can build the package by running the make command:

`make`

You can check to see everything compiled successfully by typing:

`make check`

If everything is okay, you can now install the package:

`make install`

This will install the files into the ~/directory_for_install directory you created earlier

###Running the software
To run the program, change to the **bin** (directory_for_install/bin) directory and type the executable file, like:

`./files`

###Stripping unnecessary code
When a piece of software is being developed, it is useful for the programmer to include debugging information into the resulting executable. This way, if there are problems encountered when running the executable, the programmer can load the executable into a debugging software package and track down any software bugs.

This is useful for programmer, but unnecessary for the user. Since it is unlikey that we are going to need this debugging information, we can strip it out of the final executable. One of the advantages of this is a much smaller executable, which should run slightly faster.

To strip all the debug and line numbering information out of the binary file, use the strip command:

`strip files`

#UNIX tutorial eight
###UNIX variables
Variables are a way of passing information from the shell to programs when you run them. Programs look "in the environment" for particular variables and if they are found will use the values stored. Some are set by the system, others by you, yet others by the shell, or any program that loads another program.

Standard UNIX variables are split into two categories:
  1. Environment variables: apply when user login and valid for the duration of the session.
  2. Shell variables, apply only to the current instance of the shell and are used to set short-term working conditions

By convention, environment variables have UPPERCASE and shell variables have lower case names.

###Environment Variables
An example of an environment variable is the OSTYPE variable. The value of this is the current operating system you are using. Type:

`echo $OSTYPE`

More examples of environment variables are:
 - USER (your login name).
 - HOME (the path name of your home directory).
 - HOST (the name of the computer you are using).
 - ARCH (the architecture of the computer processor).
 - DISPLAY (the name of the computer screen to display X windows)
 - Printer (the default printer to send print jobs)
 - PATH (the directories the shell should search to find a command)

**Finding out the current values of these variables**

ENVIRONMENT variables are set using the **setenv** command, displayed using **printenv** or **env** commands, and unset using **unsetenv** command.

To show all values of these variables, type:

`printenv | less`

###Shell Variables
An example of a shell variable is the history variable. The value of this is how many shell commands to save, allow the user to scroll back through all the commands they have previously entered. Type:

`echo $history`

More example of shell variables are:
 - cwd (your current directory)
 - home (the path name of your home directory)
 - path (the directories the shell should search to find a command)
 - prompt (the text string used to prompt for interactive commands shell your login shell)

**Finding out the current values of these variables.**

SHELL variables are both set and displayed using the **set** command. They can be unset by using the **unset** command.

To show all values of these variables, type:

`set | less`

**Difference between PATH and path**

In general, environment and shell variables that have the same name (apart from the case) are distinct and independent, except for possibly having the same initial values. There are, however, exceptions.

Each time the shell variables **home**, **user** and **term** are changed, the corresponding variables **HOME**, **USER** and **TERM** recieve the same values. However, altering the environment variables has no effect on the corresponding shell variables.

**PATH** and **path** specify directories to search for commands and programs. Both variables always represent the same directory list, and altering either automatically causes the other to be changed.

###Using and setting variables
Each time you login to a UNIX host, the system looks in your home directory for initialisation files. Information in these files is used to set up your working environment. 

The C and TC shells uses two files called .login and .cshrc.

The bash shell uses .bash_profile and .bashrc files.

At login the C shell first reads .cshrc followed by .login

.login is to set conditions which will apply to the whole session and to perform actions that are relevant only at login.

.cshrc is used to set conditions and perform actions specific to the shell and to each invocation of it.

The guidelines are to set ENVIRONMENT variables in the .login file and SHELL variables in the .cshrc file.

###Setting shell variables in the .cshrc file
For example, to change the number of shell commands saved in the history list, you need to set the shell variable history. It is set to 100 by default, but you can increase this if you wish.

`set history = 200`

However, this has only set the variable for the lifetime of the current shell. If you open a new xterm window, it will only have the default history value set. To PERMANENTLY set the value of history, you will need to add the set command to the .cshrc file.

First open the .cshrc file in a text editor:

`(vi | nano | nedit) ~/.cshrc`

Add the `set history` command AFTER the list of other commands.

Save the file and force the shell to reread its .cshrc file buy using the shell source command.

`source .cshrc`

###Setting the path
When you type a command, your path (or PATH) variable defines in which directories the shell will look to find the command you typed. If the system returns a message saying "command: Command not found", this indicates that either the command does not exist at all on the system or it is simply not in your path.

You can add new path for the program yppu want to run in the shell to the end of your existing path, using this command:

`set path = ($path ~/path/to/bin)`

You can set it PERMANENTLY by adding it in .cshrc file AFTER the list of other commands.


