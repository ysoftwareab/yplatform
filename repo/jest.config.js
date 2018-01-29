module.exports = {
  collectCoverage: true,
  collectCoverageFrom: [
    '**/src/**/*.js'
  ],
  coverageReporters: [
    'json',
    'html',
    'lcov',
    'text'
  ],
  notify: true,
  testEnvironment: 'node',
  testMatch: [
    '**/test/**/*.test.js'
  ],
  transform: {
    '^.+\\.js$': 'babel-jest'
  }
};
