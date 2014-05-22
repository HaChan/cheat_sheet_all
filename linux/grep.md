###Grep command syntax
 - `grep [option] "text string to search" directory-path`.

#####Examples
 - `$ grep "redeem reward" /home/tom/*.txt`.

Or

 - `$ grep "redeem reward" ~/*.txt`.

###Options

 - Ignore case: `-i` .
 - Recursively: Read all file under the directory `-r`  or `-R`.
 - Suppress the filename included in the result: `-h`.
 - Use grep to search whole words only: `grep -w "boo" file`.
 - Use grep to search 2 different words: `egrep -w 'word1|word2' /path/to/file`.
 - Count line when words has been matched: `grep -c 'word' /path/to/file`.
 - Pass the -n option to precede each line of output with the number of the line in the text file from which it was obtained: `grep -n 'root' /etc/passwd`.
 - Grep invert match: matches only those lines that do not contain the given word `grep -v bar /path/to/file`.
 - List just the names of matching files: `grep -l`.
 - Grep to display output in colors: `grep --color`.
