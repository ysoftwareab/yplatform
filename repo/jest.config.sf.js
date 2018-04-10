module.exports = {
  collectCoverage: true,
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
