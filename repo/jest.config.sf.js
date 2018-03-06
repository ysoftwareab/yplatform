let collectCoverage = false;
if (process.env.CI === 'true') {
  collectCoverage = true;
};

module.exports = {
  collectCoverage,
  collectCoverageFrom: [
    '**/src/**/*.js'
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
