A command has an exit code. By default, the test expects 0.

  $ false

When a command exits with a nonzero exit code,
specify it between square brackets after its output:

  $ echo hello; false
  hello
  [1]
