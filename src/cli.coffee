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

path      = require "path"
program   = require "commander"
ucurry    = require "ucurry"
asyncEach = require "async-each"

{copy, hash, insertAfterFilename, createObject} = require "./helpers"
__ = undefined


module.exports = (process)->
	program
		.version(require("../package").version)
		.usage("[options] <files>")
		.option("-a, --algorithm <name>", "Hash algorithm [sha1]", "sha1")
		.option("-l, --length <n>", "Hash length [11]", parseInt, 11)

	program.on "--help", ->
		console.log """
			Copies the given files with a hash of their contents put into to their filenames.
			Writes a JSON map of original filenames to hashed filenames to stdout.
			"""

	program.parse(process.argv)

	if program.args.length is 0
		program.help()

	newFileFn = (file, contents)->
		insertAfterFilename(file, hash(contents, program))

	asyncEach program.args, ucurry(copy, __, newFileFn, __), (error, newFiles)->
		if error
			process.stderr.write error.toString() + "\n"
			process.exit 1
		else
			map = createObject(program.args, newFiles, path.basename)
			process.stdout.write JSON.stringify(map, null, 2) + "\n"
			process.exit 0
