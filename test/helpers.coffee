###
Copyright 2013 Simon Lydell

This file is part of map-replace.

map-replace is free software: you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

map-replace is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License along with map-replace. If not,
see <http://www.gnu.org/licenses/>.
###

path = require "path"
{expect, sinon, readFile, writeFile} = require "./common"
{copy, hash, insertAfterFilename, createObject} = require "../lib/helpers"


describe "copy", ->

	beforeEach ->
		readFile.reset()
		readFile.resetBehavior()
		writeFile.reset()
		writeFile.resetBehavior()


	it "copies the given file using the given function to get the new path", ->
		newFileFn = sinon.stub().returns("new path")
		callback = sinon.spy()
		contents = new Buffer "contents"
		readFile.yields(null, contents)
		writeFile.yields(null)

		copy "file", newFileFn, callback

		expect(readFile).to.have.been.calledWith("file")
		expect(newFileFn).to.have.been.calledWith("file", contents)
		expect(writeFile).to.have.been.calledWith("new path", contents)
		expect(callback).to.have.been.calledWith(null)


	it "handles read errors", ->
		newFileFn = sinon.spy()
		callback = sinon.spy()
		error = new Error
		readFile.yields(error)

		copy "file", newFileFn, callback

		expect(readFile).to.have.been.called
		expect(callback).to.have.been.calledWith(error)
		expect(newFileFn).to.not.have.been.called
		expect(writeFile).to.not.have.been.called


	it "handles write errors", ->
		newFileFn = sinon.spy()
		callback = sinon.spy()
		readFile.yields(null, new Buffer "contents")
		error = new Error
		writeFile.yields(error)

		copy "file", newFileFn, callback

		expect(readFile).to.have.been.called
		expect(newFileFn).to.have.been.called
		expect(writeFile).to.have.been.called
		expect(callback).to.have.been.calledWith(error)


	it "handles new file path function errors", ->
		error = new Error
		newFileFn = sinon.stub().throws(error)
		callback = sinon.spy()
		readFile.yields(null, new Buffer "contents")

		copy "file", newFileFn, callback

		expect(readFile).to.have.been.called
		expect(newFileFn).to.have.been.called
		expect(callback).to.have.been.calledWith(error)
		expect(writeFile).to.not.have.been.called


describe "hash", ->

	it "returns the hex digest of the hash of a string, using the supplied algorithm", ->
		expect(hash("foo", {algorithm: "sha1"})).to.equal("0beec7b5ea3f0fdbc95d0dd47f3c5bc275da8a33")
		expect(hash("foo", {algorithm: "md5"})).to.equal("acbd18db4cc2f85cedef654fccc4a4d8")


	it "returns only the supplied length of the hash", ->
		hashFoo = (length)-> hash("foo", {algorithm: "sha1", length})

		expect(hashFoo(-1)).to.equal("")
		expect(hashFoo(0)).to.equal("")
		expect(hashFoo(1)).to.equal("0")
		expect(hashFoo(2)).to.equal("0b")
		expect(hashFoo(3)).to.equal("0be")
		expect(hashFoo(300)).to.equal("0beec7b5ea3f0fdbc95d0dd47f3c5bc275da8a33")


describe "insertAfterFilename", ->

	sep = (string)-> string.replace(/[\/\\]/g, path.sep)

	it "inserts a string before the first file extension of a file path", ->
		expect(insertAfterFilename("foo.ext", "test"))
			.to.equal("foo-test.ext")
		expect(insertAfterFilename("./sys.path/to/foo.ext.ext2.", "test"))
			.to.equal(sep "sys.path/to/foo-test.ext.ext2.")


	it "allows files to start with a dot", ->
		expect(insertAfterFilename(".gitignore", "test"))
			.to.equal(".gitignore-test")
		expect(insertAfterFilename("./sys.path/to/.gitignore.ext.ext2.", "test"))
			.to.equal(sep "sys.path/to/.gitignore-test.ext.ext2.")
		expect(insertAfterFilename(".", ""))
			.to.equal(".-")


describe "createObject", ->

	it "takes an array of keys and an array of values and creates an object from them", ->
		expect(createObject(["key1", "key2", "key3"], ["value1", "value2"])).to.eql
			key1: "value1"
			key2: "value2"
			key3: undefined

		expect(createObject(["key1"], ["value1", "value2"])).to.eql
			key1: "value1"


	it "optionally applies a supplied format function to the keys and values", ->
		format = (string)-> string.toUpperCase()
		expect(createObject(["key1", "key2"], ["value1", "value2"], format)).to.eql
			KEY1: "VALUE1"
			KEY2: "VALUE2"
