# **uglify-watcher** is a script that can watch
# a directory and minify your [.js scripts] if they change.
#
# uglify-watcher requires:
#
# * [node.js](http://nodejs.org/)
# * [find](http://en.wikipedia.org/wiki/Find)
# * [watcher_lib](https://github.com/amix/watcher_lib)
# * [commander.js](https://github.com/visionmedia/commander.js)


# Specify the command line arguments for the script (using commander)
usage = "Watch a directory and minify .js scripts if they change.\nUsage: uglify-watcher -p [prefix] -d [directory]."

program = require('commander')

program
  .version('1.0.0')
  .usage(usage)

  .option('-d, --directory <path>',
          'Specify which directory to scan. [Default: .]')

  .parse(process.argv)

# Set defaults
program.directory = program.directory or '.'

# Use `watcher-lib`, a library that abstracts away most of the implementation details.
# This library also makes it possible to implement any watchers (see uglify-watcher for an example).
watcher_lib = require 'watcher_lib'


# Searches through a directory structure for *.uglify files using `find`.
# For each .src.js file it runs `compileIfNeeded` to compile the file if it's modified.
findFiles = (dir) ->
    watcher_lib.findFiles('*.src.js', dir, compileIfNeeded)


# Keeps a track of modified times for .src.js files in a in-memory object,
# if a .src.js file is modified it recompiles it using compileScript.
#
# When starting the script all files will be recompiled.
WATCHED_FILES = {}
compileIfNeeded = (file) ->
    watcher_lib.compileIfNeeded(WATCHED_FILES, file, compileScript)


# Compiles a file using `uglifyjs`. Compilation errors are printed out to stdout.
compileScript = (file) ->
    fnGetOutputFile = (file) -> file.replace(/([^\/\\]+)\.src.js/, "#{program.prefix}$1.js")
    watcher_lib.compileFile("uglifyjs #{ file }", file, fnGetOutputFile)


# Starts a poller that polls each second in a directory that's
# either by default the current working directory or a directory that's passed through process arguments.
watcher_lib.startDirectoryPoll(program.directory, findFiles)
