NODE = $(shell $(WHICH_Q) node || echo "NODE_NOT_FOUND")
NODE_NPM = $(shell realpath $(NODE) | $(SED) "s/bin\/node\$$/libexec\/npm\/bin\/npm/")
NPM = $(shell $(WHICH_Q) npm || echo "NPM_NOT_FOUND")
$(foreach VAR,NODE NODE_NPM NPM,$(call make-lazy,$(VAR)))

BABEL = $(shell PATH="$(PATH)" $(WHICH_Q) babel || echo "BABEL_NOT_FOUND")
NODE_BABEL = $(NODE) -r babel-register
$(foreach VAR,BABEL NODE_BABEL,$(call make-lazy,$(VAR)))

BUNYAN = $(shell PATH="$(PATH)" $(WHICH_Q) bunyan || echo "BUNYAN_NOT_FOUND")
NODEMON = $(shell PATH="$(PATH)" $(WHICH_Q) nodemon || echo "NODEMON_NOT_FOUND")
SASS = $(shell PATH="$(PATH)" $(WHICH_Q) node-sass || echo "SASS_NOT_FOUND")
WEBPACK = $(shell PATH="$(PATH)" $(WHICH_Q) webpack || echo "WEBPACK_NOT_FOUND")
$(foreach VAR,BABEL BUNYAN NODEMON SASS WEBPACK,$(call make-lazy,$(VAR)))

# TypeScript
TSC = $(shell PATH="$(PATH)" $(WHICH_Q) tsc || echo "TSC_NOT_FOUND")
TSFMT = $(shell PATH="$(PATH)" $(WHICH_Q) tsfmt || echo "TSFMT_NOT_FOUND")
TSLINT = $(shell PATH="$(PATH)" $(WHICH_Q) tslint || echo "TSLINT_NOT_FOUND")
TYPINGS = $(shell PATH="$(PATH)" $(WHICH_Q) typings || echo "TYPINGS_NOT_FOUND")
$(foreach VAR,TSC TSFMT TSLINT TYPINGS,$(call make-lazy,$(VAR)))

# Lint
ESLINT = $(shell PATH="$(PATH)" $(WHICH_Q) eslint || echo "ESLINT_NOT_FOUND")
FLOW = $(shell PATH="$(PATH)" $(WHICH_Q) flow || echo "FLOW_NOT_FOUND")
JSONLINT = $(shell PATH="$(PATH)" $(WHICH_Q) jsonlint || echo "JSONLINT_NOT_FOUND") -q
$(foreach VAR,ESLINT FLOW JSONLINT,$(call make-lazy,$(VAR)))

# Test
ISTANBUL = $(shell PATH="$(PATH)" $(WHICH_Q) istanbul || echo "ISTANBUL_NOT_FOUND")
MOCHA = $(shell PATH="$(PATH)" $(WHICH_Q) mocha || echo "MOCHA_NOT_FOUND")
MOCHA_BABEL = $(MOCHA) --compilers js:babel-register
_MOCHA = $(shell PATH="$(PATH)" $(WHICH_Q) _mocha || echo "_MOCHA_NOT_FOUND")
$(foreach VAR,ISTANBUL MOCHA MOCHA_BABEL _MOCHA,$(call make-lazy,$(VAR)))
