# Given a line
VAR_TO_OVERRIDE := foo

# calling 'VAR_TO_OVERRIDE=bar make'
# would run with VAR_TO_OVERRIDE set to 'foo'

# while   'make VAR_TO_OVERRIDE=bar'
# would run with VAR_TO_OVERRIDE set to 'bar'

# Given a line
override VAR_TO_OVERRIDE := foo
# would run with VAR_TO_OVERRIDE set to 'foo' no matter the invocation
