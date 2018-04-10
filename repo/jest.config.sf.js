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
  transform: {
    '^.+\\.js$': 'babel-jest'
  }
};
