// Generated by CoffeeScript 1.6.3
/*
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
*/

var copy, createObject, crypto, filenameRegex, fs, hash, identity, insertAfterFilename, path;

fs = require("fs");

path = require("path");

crypto = require("crypto");

copy = function(file, newFileFn, callback) {
  return fs.readFile(file, function(error, contents) {
    var newFile;
    if (error) {
      return callback(error);
    }
    try {
      newFile = newFileFn(file, contents);
    } catch (_error) {
      error = _error;
      return callback(error);
    }
    return fs.writeFile(newFile, contents, function(error) {
      if (error) {
        return callback(error);
      }
      return callback(null, newFile);
    });
  });
};

hash = function(string, options) {
  return crypto.createHash(options.algorithm).update(string).digest("hex").substr(0, options.length);
};

filenameRegex = /^\.?[^.]*/;

insertAfterFilename = function(file, string) {
  return path.join(path.dirname(file), path.basename(file).replace(filenameRegex, "$&-" + string));
};

identity = function(x) {
  return x;
};

createObject = function(keys, values, format) {
  if (format == null) {
    format = identity;
  }
  return keys.reduce((function(obj, key, index) {
    obj[format(key)] = format(values[index]);
    return obj;
  }), {});
};

module.exports = {
  copy: copy,
  hash: hash,
  insertAfterFilename: insertAfterFilename,
  createObject: createObject
};