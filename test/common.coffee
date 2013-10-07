###
Copyright 2013 Simon Lydell

This file is part of hash-filename.

hash-filename is free software: you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

hash-filename is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License along with hash-filename. If not,
see <http://www.gnu.org/licenses/>.
###

fs        = require "fs"
chai      = require "chai"
sinon     = require "sinon"
sinonChai = require "sinon-chai"

chai.use sinonChai
{expect} = chai

exec = (cli, args..., callback)->
	stdinEvents = {}
	stdinResumed = no
	stdin = stdout = stderr = ""
	if args[0]?.stdin then {stdin} = args.shift()
	process =
		argv: ["path/to/node", "path/to/hash-filename", args...]
		stdin:
			resume: -> stdinResumed = yes
			on: (event, callback)-> stdinEvents[event] = callback
		stdout:
			write: (string)-> stdout += string
		stderr:
			write: (string)-> stderr += string
		exit: (code)-> callback(code, stdout, stderr)

	cli(process)
	if stdinResumed
		stdinEvents.data(chunk) for chunk in stdin
		stdinEvents.end()

module.exports = {
	expect
	sinon
	readFile:  sinon.stub(fs, "readFile")
	writeFile: sinon.stub(fs, "writeFile")
	exec
	}
