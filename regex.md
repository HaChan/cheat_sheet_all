###Regular-expression patterns:
| Pattern  | Description |
| ---------|:-----------|
|  ^       | Matches beginning of line|
|  $       | Matches end of line.|
|  .       | Matches any single character except newline. Using m option allows|
|          | it to match newline as well.|
|  [..]    | Matches any single character in brackets.|
|  [^..]   | Matches any single character not in brackets|
|  re*     | Matches 0 or more occurrences of preceding expression.|
|  re+     | Matches 1 or more occurrences of preceding expression.|
|  re?     | Matches 0 or 1 occurrence of preceding expression.|
|  re{n}   | Matches exactly n number of occurrences of preceding expression.|
|  re{n,}  | Matches n or more occurrences of preceding expression.|
|  re{n,m} | Matches at least n and at most m occurrences of preceding expression.|
|a&#124;b| Matches either a or b|
|  (re)    | Groups regular expressions and remembers matched text.|
|  (?imx)  | Temporarily toggles on i, m, or x options within a regular expression. If in parentheses, only that area is affected.|
|  (?-imx) | Temporarily toggles off i, m, or x options within a regular expression If in parentheses, only that area is affected.|
|  (?:re)  | Groups regular expressions without remembering matched text. [non capturing group](http://stackoverflow.com/questions/3512471/non-capturing-group)|
| (?imx:re)| Temporarily toggles on i, m, or x options within parentheses.|
|(?-imx:re)| Temporarily toggles off i, m, or x options within parentheses.|
|  (?#..)  | Comment.|
| (?=re)   | Specifies position using a pattern. Does not have a range.|
| (?!re)   | Specifies position using pattern negation. Does not have a range.|
| (?>re)   | Matches independent pattern without backtracking.|
|  \w      | Matches word characters.|
|  \W      | Matches nonword characters.|
|  \s      | Matches whitespace. Equivalent to [\t\n\r\f].|
|  \S      | Matches nonwhitespace.|
|  \d      | Matches digits. Equivalent to [0-9].|
|  \D      | Matches nondigits.|
|  \A      | Matches beginning of string.|
|  \Z      | Matches end of string. If "\n" exists, it matches just before newline.|
|  \z      | Matches end of string.|
|  \G      | Matches point where last match finished.|
|  \b      | Matches word boundaries when outside brackets. Matches backspace (0x08) when inside brackets.|
|  \B      | Matches nonword boundaries.|
| \n,\t,.. | Matches newlines, carriage returns, tabs, etc.|
| \1..\9   | Matches nth grouped subexpression.|
| \10      | Matches nth grouped subexpression if it matched already. Otherwise refers to the octal representation of a character code.|


###Regular-expression Modifiers - Option Flags
| Modifier | Description |
| ---------|:-----------|
|  ^       | Matches beginning of line|
|  $       | Matches end of line.|
|  .       | Matches any single character except newline. Using m option allows it to match newline as well.|
|  [..]    | Matches any single character in brackets.|
|  [^..]   | Matches any single character not in brackets|
|  re*     | Matches 0 or more occurrences of preceding expression.|
|   re.I   | Performs case-insensitive matching.|
|   re.L   | Interprets words according to the current locale. This interpretation affects the alphabetic group (\w and \W), as well as word boundary behavior (\b and \B).|
|   re.M   | Makes $ match the end of a line (not just the end of the string) and makes ^ match the start of any line (not just the start of the string)|
|   re.S   | Makes a period (dot) match any character, including a newline.|
|   re.U   | Interprets letters according to the Unicode character set. This flag affects the behavior of \w, \W, \b, \B.|
|   re.X   | Permits "cuter" regular expression syntax. It ignores whitespace (except inside a set [] or when escaped by a backslash) and treats unescaped # as a comment marker.|

###Regular-expression Examples
 - Literal characters:.

	|   Example   |    Description    |
	|-------------|:-----------------|
	|   python    |    Match "python".|

 - Character classes:.

	|   Example   | Description |
	|-------------|:-----------|
	| [Pp]ython   | Match "Python" or "python"|
	| rub[ye]     | Match "ruby" or "rube"|
	| [^aeiou]    | Match any one lowercase vowel|
	| [0-9]       | Match any digit; same as [0123456789]|
	| [a-z]       | Match any lowercase ASCII letter|
	| [A-Z]       | Match any uppercase ASCII letter|
	| [a-zA-Z0-9] | Match any of the above|
	| [^aeiou]    | Match anything other than a lowercase vowel|
	| [^0-9]      | Match anything other than a digit|

 - Repetition Cases:.

	|   Example   | Description |
	|-------------|:-----------|
	| ruby?       | Match "rub" or "ruby": the y is optional|
	| ruby*       | Match "rub" plus 0 or more ys|
	| ruby+       | Match "rub" plus 1 or more ys|
	| \d{3}       | Match exactly 3 digits|
	| \d{3,}      | Match 3 or more digits|
	| \d{3,5}     | Match 3, 4, or 5 digits|

 - Nongreedy repetition: This matches the smallest number of repetitions:.

	|   Example   | Description |
	|-------------|:-----------|
	| <.*>        | Greedy repetition: matches "<python>perl>"|
	| <.*?>       | Nongreedy: matches "<python>" in "<python>perl>"|

 - Grouping with parentheses:.

	|   Example         | Description |
	|-------------------|:-----------|
	| \D\d+             | No group: + repeats \d |
	| (\D\d)+           | Grouped: + repeats \D\d pair |
	| ([Pp]ython(, )?)+ | Match "Python", "Python, python, python", etc.|

 - Backreferences: This matches a previously matched group again.

	|   Example          | Description |
	|--------------------|:-----------|
	| ([Pp])ython&\1ails | Match python&pails or Python&Pails |
	| (['"])[^\1]*\1     | Single or double-quoted string. \1 matches whatever the 1st group matched . \2 matches  whatever the 2nd group matched, etc. |


 - Alternatives:

	|   Example         | Description |
	|-------------------|:-----------|
	| python&#124;perl       |  Match "python" or "perl" |
	| rub(y&#124;le))        | Match "ruby" or "ruble" |
	| Python(!+&#124;\?)     | "Python" followed by one or more ! or one ? |


 - Anchors: This need to specify match position.

	|   Example   | Description |
	|-------------|:-----------|
	| ^Python     | Match "Python" at the start of a string or internal line|
	| Python$     | Match "Python" at the end of a string or line |
	| \APython    | Match "Python" at the start of a string |
	| Python\Z    | Match "Python" at the end of a string |
	| \bPython\b  | Match "Python" at a word boundary |
	| \brub\B     | \B is nonword boundary: match "rub" in "rube" and "ruby" but not alone |
	| Python(?=!) | Match "Python", if followed by an exclamation point |
	| Python(?!!) | Match "Python", if not followed by an exclamation point |


 - Special syntax with parentheses:.

	|   Example   | Description |
	|-------------|:-----------|
	| R(?#comment)| Matches "R". All the rest is a comment |
	| R(?i)uby    | Case-insensitive while matching "uby" |
	| R(?i:uby)   | Same as above |
	| rub(?:y&#124;le))| Group only without creating \1 backreference |

##Language sepecific

###Python:

####The match Function
This function attempts to match RE pattern to string with optional flags. Here is the syntax for this function:
	`re.match(pattern, string, flags=0)`
EXAMPLE:
```python
#!/usr/bin/python
import re

line = "Cats are smarter than dogs"

matchObj = re.match( r'(.*) are (.*?) .*', line, re.M|re.I)

if matchObj:
   print "matchObj.group() : ", matchObj.group()
   print "matchObj.group(1) : ", matchObj.group(1)
   print "matchObj.group(2) : ", matchObj.group(2)
else:
   print "No match!!"
```
When the above code is executed, it produces following result:
	`matchObj.group() :  Cats are smarter than dogs
	 matchObj.group(1) :  Cats
	 matchObj.group(2) :  smarter`

####The search funtion
This function searches for first occurrence of RE pattern within string with optional flags.
	[re.search(pattern, string, flags=0)]

```python
#!/usr/bin/python
import re

line = "Cats are smarter than dogs";

searchObj = re.search( r'(.*) are (.*?) .*', line, re.M|re.I)

if searchObj:
   print "searchObj.group() : ", searchObj.group()
   print "searchObj.group(1) : ", searchObj.group(1)
   print "searchObj.group(2) : ", searchObj.group(2)
else:
   print "Nothing found!!"
```
Result:
	`matchObj.group() :  Cats are smarter than dogs
	 matchObj.group(1) :  Cats
	 matchObj.group(2) :  smarter`

####Matching vs Searching:
Python offers two different primitive operations based on regular expressions: match checks for a match only at the beginning of the string, while search checks for a match anywhere in the string (this is what Perl does by default).
EXAMPLE:
```python
#!/usr/bin/python
import re

line = "Cats are smarter than dogs";

matchObj = re.match( r'dogs', line, re.M|re.I)
if matchObj:
   print "match --> matchObj.group() : ", matchObj.group()
else:
   print "No match!!"

searchObj = re.search( r'dogs', line, re.M|re.I)
if searchObj:
   print "search --> searchObj.group() : ", searchObj.group()
else:
   print "Nothing found!!"
```
Result:
`No match!!
search --> matchObj.group() :  dogs`

####Search and Replace:
`re.sub(pattern, repl, string, max=0)`
