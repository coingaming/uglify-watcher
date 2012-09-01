# Specify the command line arguments for the script (using optimist)
usage = "Watch a directory and recompile .src.js styles if they change.\nUsage: uglify-watcher -o [output] -d [directory]."
specs = require('optimist')
        .usage(usage)

        .default('d', '.')
        .describe('d', 'Specify which directory to scan.')

        .default('o', './')
        .describe('o', 'Output directory. Default is ./')
        
        .boolean('h')
        .describe('h', 'Prints help')


# Handle the special -h case
if specs.parse(process.argv).h
    specs.showHelp()
    process.exit()
else
    argv = specs.argv

path = require 'path'
mkdirp = require 'mkdirp'

# Use `watcher-lib`, a library that abstracts away most of the implementation details.
# This library also makes it possible to implement any watchers (see coffee-watcher for an example).
watcher_lib = require 'watcher_lib'

# Searches through a directory structure for *.src.js files using `find`.
# For each .src.js file it runs `compileIfNeeded` to compile the file if it's modified.
findUglifyFiles = (dir) ->
    watcher_lib.findFiles('*.src.js', dir, compileIfNeeded)

# Keeps a track of modified times for .src.js files in a in-memory object,
# if a .src.js file is modified it recompiles it using compileUglifyScript.
#
# When starting the script all files will be recompiled.
WATCHED_FILES = {}
compileIfNeeded = (file) ->
    watcher_lib.compileIfNeeded(WATCHED_FILES, file, compileUglifyScript)

# Compiles a file using `uglifyjs`. Compilation errors are printed out to stdout.
compileUglifyScript = (file) ->
    fnGetOutputFile = (file) ->
        relativePath = path.relative argv.d, file
        file = path.join argv.o, relativePath;
        if not path.existsSync path.dirname file
            mkdirp.sync path.dirname file
        file.replace(/([^\/\\]+)\.src.js/, "$1.js")
    watcher_lib.compileFile("uglifyjs #{ file }", file, fnGetOutputFile)

# Starts a poller that polls each second in a directory that's
# either by default the current working directory or a directory that's passed through process arguments.
watcher_lib.startDirectoryPoll(argv.d, findUglifyFiles)
