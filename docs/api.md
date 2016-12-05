# API

## Commands

Command Functions are of the form: `turtleminer.command_name(owner, pos, ...)`  
If the command is successful, they will return a new position.
If there was an error, they will return nil.

`turtleminer.run_command(owner, pos, command, ...)` can be used to run any
command from it's name - this is useful when it comes to scripting.

Note that `...` is any number of optional parameters.

* `move(owner, pos, direction)`
* `rotate(owner, pos, direction)`
* `build(owner, pos, where)` - `where` is "front" or "below"
* `dig(owner, pos, where)` - `where` is "front" or "below"
