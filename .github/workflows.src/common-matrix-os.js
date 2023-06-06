/* eslint-disable no-template-curly-in-string */

let _ = require('lodash-firecloud');

// https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners#supported-runners-and-hardware-resources // editorconfig-checker-disable-line

let matrixOs = {
  ubuntu: [
    // obsolete 2020-09 https://github.com/actions/virtual-environments/issues/3287
    // 'ubuntu-16.04',
    // https://github.com/actions/runner-images/issues/6002
    // 'ubuntu-18.04',
    'ubuntu-20.04',
    'ubuntu-22.04'
  ],
  macos: [
    // obsolete 2022-08 https://github.com/actions/virtual-environments/issues/5583
    // 'macos-10.15',
    'macos-11',
    'macos-12',
    'macos-13'
  ],
  windows: [
    // obsolete 2022-03 https://github.com/actions/virtual-environments/issues/5238
    // 'windows-2016',
    'windows-2019',
    'windows-2022'
  ]
};

module.exports = {
  matrixOs
};
