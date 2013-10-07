[![Build Status](https://travis-ci.org/lydell/hash-filename.png?branch=master)](https://travis-ci.org/lydell/hash-filename)

Overview
========

hash-filename is a command line tool that puts the hash of a file into its filename.

Installation: `npm install -g hash-filename`

```sh
$ ls
app.css  app.js  vendor.js
$ hash-filename *.css *.js
{
  "app.css": "app-f1d2d2f924e.css",
  "app.js": "app-e242ed3bffc.js",
  "vendor.js": "vendor-6eadeac2dad.js"
}
$ ls
app-e242ed3bffc.js  app-f1d2d2f924e.css  app.css  app.js  vendor-6eadeac2dad.js  vendor.js
$ hash-filename --help

  Usage: hash-filename [options] <files>

  Options:

    -h, --help              output usage information
    -V, --version           output the version number
    -a, --algorithm <name>  Hash algorithm [sha1]
    -l, --length <n>        Hash length [11]

Copies the given files with a hash of their contents put into to their filenames.
Writes a JSON map of original filenames to hashed filenames to stdout.
```

It is useful for cache busting. The outputted JSON map can be used to update references to the
unhashed filenames.

For example, you could create a function such as the following, expose it to templates and wrap file
paths in it.

```javascript
var map = production ? require("./map") : {} // You can even require .json files!
function file(path) {
  return map[path] || path
}
```

The above function uses the original paths during development and the hashed ones during production.
And if for some reason a path would be missing from the map during production, it falls back to the
original path.

You could also feed the map directly to a replacement tool such as [map-replace] to update static
files:

```sh
hash-filename *.css *.js | map-replace -m "<[^>]+>" *.html
```

[map-replace]: https://github.com/lydell/map-replace


License
=======

[GPLv3](COPYING).
