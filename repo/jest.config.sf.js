let path = require('path');

let transform = {};

// only add babel-jest transformer if babel-jest is a top-level dependency
try {
  require.resolve('babel-jest');

  let jestConfigModule = module;
  while (jestConfigModule.parent) {
    if (path.basename(jestConfigModule.filename) !== 'jest.config.js') {
      jestConfigModule = jestConfigModule.parent;
      continue;
    }
    break;
  }

  let topPackageJson = path.join(path.dirname(jestConfigModule.filename), 'package.json');
  // eslint-disable-next-line global-require
  let topPackage = require(topPackageJson);

  if (!topPackage.devDependencies['babel-jest']) {
    throw new Error(`babel-jest is not a dev dependency in ${topPackageJson}`);
  }

  transform['^.+\\.js$'] = 'babel-jest';
} catch (_err) {
  // console.log(_err);
}

module.exports = {
  // FIXME coverage is disabled due to https://github.com/facebook/jest/issues/3959
  collectCoverage: false,
  collectCoverageFrom: [
    '**/lib/**/*.js'
  ],
  coverageReporters: [
    'json',
    'html',
    'lcov',
    'text'
  ],
  notify: false,
  testEnvironment: 'node',
  testMatch: [
    '**/test/**/*.test.js'
  ],
  transform
};
