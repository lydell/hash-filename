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

{expect, sinon, readFile, writeFile, exec} = require "./common"


describe "cli", ->

	beforeEach ->
		readFile.reset()
		readFile.resetBehavior()
		writeFile.reset()
		writeFile.resetBehavior()

		delete require.cache[require.resolve("../lib/cli")]
		delete require.cache[require.resolve("commander")]
		cli = require "../lib/cli"
		@exec = exec.bind(undefined, cli)


	it "shows usage information if given no files", (done)->
		help = sinon.stub(require("commander"), "help")

		count = 0
		callback = (code, stdout, stderr)->
			count++
			expect(help.callCount).to.equal(count)
			if count == 2
				help.restore()
				done()

		@exec callback
		@exec "-a", "algo", callback


	it "copies the given files with a hash of their contents put into to their filenames", (done)->
		readFile
			.yields(null, "foo")
			.yields(null, "bar")
			.yields(null, "baz")
		writeFile.yields(null)

		@exec "file1", "file2", "file3", (code, stdout, stderr)->
			expect(code).to.equal(0)
			expect(stdout).to.not.be.empty
			expect(stderr).to.be.empty

			expect(readFile).calledThrice
			expect(readFile.firstCall).to.have.been.calledWith("file1")
			expect(readFile.secondCall).to.have.been.calledWith("file2")
			# For some reason `.thirdCall` is `null`. Weird.
			expect(readFile.getCall(2)).to.have.been.calledWith("file3")

			expect(writeFile).calledThrice
			expect(writeFile.firstCall).to.have.been.calledWith("file1-0beec7b5ea3", "foo")
			expect(writeFile.secondCall).to.have.been.calledWith("file2-62cdb7020ff", "bar")
			# For some reason `.thirdCall` is `null`. Weird.
			expect(writeFile.getCall(2)).to.have.been.calledWith("file3-bbe960a25ea", "baz")

			done()


	it "writes a JSON map of original filenames to hashed filenames to stdout", (done)->
		readFile
			.yields(null, "foo")
			.yields(null, "bar")
			.yields(null, "baz")
		writeFile.yields(null)

		@exec "path/to/file1", "path/to/file2", "path/to/file3", (code, stdout, stderr)->
			expect(code).to.equal(0)
			expect(stdout).to.equal """
				{
				  "file1": "file1-0beec7b5ea3",
				  "file2": "file2-62cdb7020ff",
				  "file3": "file3-bbe960a25ea"
				}\n
				"""
			expect(stderr).to.be.empty
			done()


	describe "-a, --algorithm", ->

		it "uses the supplied algorithm", ->
			readFile.yields(null, new Buffer "foo")

			count = 0
			callback = (hashed, code, stdout, stderr)->
				expect(code).to.equal(0)
				expect(stdout).to.not.be.empty
				expect(stderr).to.be.empty
				expect(writeFile).to.have.been.calledWith(hashed)
				if ++count == 2
					done()

			execFile = (algorithm, hashed)=>
				@exec "file", "-a", algorithm, callback.bind(undefined, hashed)

			execFile "sha1", "file-0beec7b5ea3"
			execFile "md5", "file-acbd18db4cc"


	describe "-l, --length", ->

		it "returns only the supplied length of the hash", ->
			readFile.yields(null, new Buffer "foo")

			count = 0
			callback = (hashed, code, stdout, stderr)->
				expect(code).to.equal(0)
				expect(stdout).to.not.be.empty
				expect(stderr).to.be.empty
				expect(writeFile).to.have.been.calledWith(hashed)
				if ++count == 6
					done()

			execFile = (length, hashed)=>
				@exec "file", "-l", length, callback.bind(undefined, hashed)

			execFile "invalid", "file-"
			execFile "0", "file-"
			execFile "1", "file-0"
			execFile "2", "file-0b"
			execFile "3", "file-0be"
			execFile "300", "file-0beec7b5ea3f0fdbc95d0dd47f3c5bc275da8a33"


	describe "error handling", ->

		it "handles read errors", (done)->
			readFile.yields(new Error "Message")

			@exec "file", (code, stdout, stderr)->
				expect(code).to.equal(1)
				expect(stdout).to.be.empty
				expect(stderr).to.equal("Error: Message\n")
				done()


		it "handles write errors", (done)->
			readFile.yields(null, new Buffer "contents")
			writeFile.yields(new Error "Message")

			@exec "file", (code, stdout, stderr)->
				expect(code).to.equal(1)
				expect(stdout).to.be.empty
				expect(stderr).to.equal("Error: Message\n")
				done()


		it "handles invalid algorithm errors", (done)->
			readFile.yields(null, new Buffer "contents")

			@exec "-a", "invalid algo", "file", (code, stdout, stderr)->
				expect(code).to.equal(1)
				expect(stdout).to.be.empty
				expect(stderr).to.equal("Error: Digest method not supported\n")
				done()
