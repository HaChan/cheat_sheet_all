#SBT
sbt is a build tool for Scala and Java projects.

##Hello World

####Create a project directory with source code

A valid `sbt` project can be a directory containing a source file. Example: Creating a directory `hello` containing `hello.scala` source file with the following content:

```scala
object Hi {
  def main(args: Array[String]) = println("Hi!")
}
```

The command on Linux/Unix environment:

```bash
$ mkdir hello
$ cd !$
$ echo 'object Hi { def main(args: Array[String]) = println("Hi!") }' > helloe.scala
$ sbt
...
> run
...
Hi!
```

`sbt` works by convention in this case. `sbt` will find the following automatically:

  - Sources in the directory

  - Sources in `src/main/scala` or `src/main/java`

  - Tests in `src/test/scala` or `src/test/java`

  - Data files in `src/main/resources` or `src/test/resources`

  - Jars in `lib/`

`sbt` will build the project with the same version of Scala used to run the `sbt` it self.

Use `sbt run` or enter REPL with `sbt console` to run the project.

####Build definition

Basic build settings go in `build.sbt`, located in the project's base directory.

Example: with the `hello` directory, the build setting for it is `hello/build.sbt`.

##Directory structure

####Base directory

Base directory is the directory containing the project. Example: project `hello` that containing `hello/build.sbt` and `hello/hello.scala`, so `hello` is the base directory.

####Source code

Source code can be placed in the project's base directory.

`sbt` uses the same directory structure as `Maven` for source files by default (all paths are relative to the base directory):

```
src/
  main/
    resources/
       <files to include in main jar here>
    scala/
       <main Scala sources>
    java/
       <main Java sources>
  test/
    resources
       <files to include in test jar here>
    scala/
       <test Scala sources>
    java/
       <test Java sources>
```

Other directories in `src/` will be ignored

####sbt build definition files

Other `sbt` build definition files appear in a `project` subdirectory (of base directory).

`project` can contain `.scala` files, which are combined with `.sbt` files to form the complete build definition.

```
build.sbt
project/
  Build.scala
```

####Build products

Generated files (compiled classes, packaged jars, managed files, caches, and documentation) will be written to the `target` directory bu default.

`.gitignore` should contain the `target/` folder by default.

##Running sbt

####Interactive mode

Run `sbt` in a project with no arguments:

    $ sbt

will start `sbt` in interactive mode. Interactive mode has command prompt. Example: type `compile` in `sbt` command prompt will compile the source files.

To run the program, type `run`.

####Batch mode

`sbt` can be run in batch mode, specifying a space-separated list of `sbt` commands as arguments. For `sbt` command that take arguments, pass the command and arguments as one argument to `sbt` by _enclosing them in quotes_. Example:

    $ sbt clean compile "test-only file1 file2"

The `test-only` command has arguments (`file1`, `file2`). These command will be run in sequence (`clean`, `compile`, then `test-only`)

####Continuous build and test

`sbt` can automatically recompile or run tests whenever a source file is saved.  To make a `sbt` command run when one or more source files change by prefixing the command with `~`. Example, in Interactive mode type:

    > ~ compile

to auto compile when a file is saved.

To stop watching for file change, press `ENTER`.

The `~` prefix can be used with either interactive mode or batch mode.

####Common commands

  - `clean` Deletes all generated files (in the `target` directory).

  - `compile` Compiles the main sources (in `src/main/scala` and `src/main/java` directories).

  - `test` Compiles and runs all tests.

  - `console` Starts the Scala interpreter with a classpath including the compiled sources and all dependencies. To return to `sbt`, type `:quit`, `Ctrl+D` (Unix), or `Ctrl+Z` (Windows).

  - `run <argument>*` Runs the **main class** for the project in the same virtual machine as `sbt`.

  - `package` Creates a jar file containing the files in `src/main/resources` and the classes compiled from `src/main/scala` and `src/main/java`.

  - `help <command>` Displays detailed help for the specified command. If no command is provided, displays brief descriptions of all commands.

  - `reload` Reloads the build definition (`build.sbt`, `project/*.scala`, `project/*.sbt` files). Needed if you change the build definition

[Command line referencea](http://www.scala-sbt.org/0.12.4/docs/Detailed-Topics/Command-Line-Reference.html)

####History Commands

`sbt` interactive mode support history commands of Unix/Linux environment.

##Build definition

####.sbt vs. .scala Definition

An `sbt` build definition can contain files ending in `.sbt`, located in the base directory, and files ending in `.scala`, located in the project subdirectory of the base directory.

Both can be used exclusively or in conjunction. A best practise is to use `.sbt` files for most purpose and use `.scala` files only to contain what can't be done in `.sbt` like:

  - to customize `sbt` (add new setting or tasks)

  - to define nested sub-projects

####What is a build definition?

`sbt` will create an immutable map describing the build after examining a project and processing any build definition files. Example: the key `name` is map to a string value, the name of the project.

`Build definition` **do not affect sbt's map directly**. Instead, it creates a list of objects with type `Setting[T]` where `T` is the type of the value in the map. A `Setting` describes a _transformation to the map_, such as _adding a new key-value pair_ or _appending to an existing value_.

In `build.sbt`, the project name can be created through a `Setting[String]` like this:

    name := "hello"

This `Setting[String]` transforms the map by adding (or replacing) the `name` key with the value `"hello"`. The transformed becomes the `sbt`'s new map.

####How build.sbt defines settings

`build.sbt` defines a `Seq[Setting[_]]`, a list of Scala expressions, **separated by blank lines**, each line is a `Setting` element. The alternative `scala` code has the `Seq(` at the beginning of the file and `)` at the end of the file.

Example:

```
name := "hello"

version := "1.0"

scalaVersion := "2.9.2"
```

Each `Setting` is defined with a Scala expression.

The expression in `build.sbt` are independent of one another. `val`, `object`, class or method can not be defined in `build.sbt`.

ON the left of the `build.sbt` is keys, such as `name`, `version`, `scalaVersion`. A key is an instance of `Settingkey[T]`, `TaskKey[T]`, `InputKey[T]` where `T` is the expected value type.

Keys have method called `:=` which returns a `Setting[T]`. In

    name := "hello"

`"hello"` is the argument of method `:=`. The `:=` on key `name` here returns a `Setting[String]`. In this case, the returned `Setting[String]` is a transformation to add or replace the `name` key in `sbt`'s map, giving it the value `"hello"`.

Using the wrong value type will make the compilation of `build.sbt` fail:

    scala name := 42 // will not compile.

`sbt` files contain a list of Scala expressions, not a single Scala program. These expressions have to be split up and passed to the compiler individually.

####Keys are defined in the Keys object

The built-in keys are just fields in an object called [Keys](http://www.scala-sbt.org/0.12.4/sxr/Keys.scala.html). A `build.sbt` implicitly has an `import sbt.Keys._` so it can be referred as `name` in `build.sbt` file.

Custom keys can be defined in a `.scala` file or a [plugin](http://www.scala-sbt.org/0.12.4/docs/Getting-Started/Using-Plugins.html)

####Task Keys

There are three type of keys:

  - `SettingKey[T]`: a key with a value computed once (the value is computed one time when loading the project and kept around).

  - `TaskKey[T]`: a key with a value that has to be recomputed each time, potentially creating side effects.

  - `InputKey[T]`: a task key which has command line arguments as input. Check out [Input Tasks](http://www.scala-sbt.org/0.12.4/docs/Extending/Input-Tasks.html) for more

A `TaskKey[T]` define a _task_. Tasks are operations such as `compile` or `package`. They may return `Unit` (`Unit` is Scala for `void`), or they may return a value related to the task. Example `package` is a `TaskKey[File]` and its value is the jar file it creates.

Each time a task is executed, for example by typing `compile` at the interactive prompt, `sbt` will re-run any task involved exactly once.

**A given key always refers to either a task or a plain setting**. That mean it is the key's property that it can re-run each time or not.

Using `:=` to assign a computation to a task, and that computation will be re-run each time:

    hello := { println("hello") }

####Keys in sbt interactive mode

In interactive mode, typing a name of any task will execute that task. This is why typing `compile` runs the `compile` task (`compile` is a task key).

Typing a task key name executes the task but doesn't display the resulting value. To see the result, use `show <task name>`.

In build definition files, keys are named with `camelCase` (Scala convention), but the `sbt` command line use `hyphen-separated-words` instead. The hyphen-separated string used in sbt comes from the definition of the key:

    val scalacOptions = TaskKey[Seq[String]]("scalac-options", "Options for the Scala compiler.")

`sbt` use `scalac-options` but in a build definition file, it use `scalacOptions`.

To learn more about any key, type `inspect <keyname>` at interactive prompt.

####Imports in build.sbt

`import` statements can be placed at the top of `build.sbt`; they need not be separated by blank lines.

Some implied default imports:

```scala
import sbt._
import Process._
import Keys._
```

####Adding library dependencies

To depend on third-party libraries, there are two options. First is drop jars in `lib/` and the other is to add managed dependencies, which will look like this:

    libraryDependencies += "org.apache.derby" % "derby" % "10.4.1.3"

##Library Dependencies


