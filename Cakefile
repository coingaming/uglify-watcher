{spawn, exec} = require 'child_process'

option '-p', '--prefix [DIR]', 'set the installation prefix for `cake install`'

task 'build', 'continually build the uglify-watcher library with --watch', ->
  coffee = spawn 'coffee', ['-c', '-o', 'lib', 'src']
  coffee.stdout.on 'data', (data) -> console.log data.toString().trim()

task 'install', 'install the `uglify-watcher` command into /usr/local (or --prefix)', (options) ->
  base = options.prefix or '/usr/local'
  lib  = base + '/lib/uglify-watcher'
  exec([
    'mkdir -p ' + lib
    'cp -rf bin README.markdown resources lib ' + lib
    'ln -sf ' + lib + '/bin/coffee-watcher ' + base + '/bin/uglify-watcher'
  ].join(' && '), (err, stdout, stderr) ->
   if err then console.error stderr
  )