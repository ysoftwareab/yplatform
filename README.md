## Fun task: naive-rsync

## How to

`bin/naive-rsync.go.sugar <src> <target>` will print the operations needed to
sync `target` to the state of `src`

Internally `bin/naive-rsync.go <folder>` will produce a reference on stdout
of the state of `folder`. This can be later used as input to
`bin/naive-rsync.go -reference <path-to-src-reference> <target>`.

## Why the bash version

The same flow exists with `bin/naive-rsync` and `bin/naive-rsync.sugar` executables.

This is a reference implementation, wanting to structure patterns, flows, etc.
before writing non-idiomatic Go :)
