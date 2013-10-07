###
Copyright 2013 Simon Lydell

This file is part of hash-filename.

hash-filename is free software: you can redistribute it and/or modify it under the terms of the
GNU General Public License as published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

hash-filename is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License along with hash-filename. If not,
see <http://www.gnu.org/licenses/>.
###

fs     = require "fs"
path   = require "path"
crypto = require "crypto"


copy = (file, newFileFn, callback)->
	fs.readFile file, (error, contents)->
		return callback(error) if error

		try
			newFile = newFileFn(file, contents)
		catch error
			return callback(error)

		fs.writeFile newFile, contents, (error)->
			return callback(error) if error
			callback(null, newFile)


hash = (string, options)->
	crypto.createHash(options.algorithm)
		.update(string)
		.digest("hex")
		.substr(0, options.length)


filenameRegex = ///
	^\.?  # A filename is allowed to start with a dot,
	[^.]* # but then cannot contain dots.
	///

insertAfterFilename = (file, string)->
	path.join(
		path.dirname(file),
		path.basename(file).replace(filenameRegex, "$&-#{string}")
		)


identity = (x)-> x

createObject = (keys, values, format=identity)->
	keys.reduce( ((obj, key, index)-> obj[format(key)] = format(values[index]); obj), {} )


module.exports = {
	copy
	hash
	insertAfterFilename
	createObject
	}
