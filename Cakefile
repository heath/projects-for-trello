{exec} = require "child_process"
task "build", "compile all coffeescript to javascript", ->
  exec "coffee -c *.coffee", (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr
