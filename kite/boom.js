#!/usr/bin/env node

// Frame Extraction Challenge (node.js)
// Design a JavaScript function getYoutubeFrames() that:
// - Takes a Youtube url as its input
// - Fetches the video
// - Extracts a frame from every scene/cut of the video (hint: use ffmpeg)
// - Converts every frame to jpg format with maximum 800px width
// - **Returns** a list of temp paths or base64 buffers

// NOTE: assumes `npm install` is ran first
// NOTE: assumes ffmpeg is installed on the host

// WAT??? No 'const'? :)
// See https://github.com/rokmoln/eslint-plugin-firecloud/blob/master/rules/no-const.js
let fs = require('fs');
let os = require('os');
let readline = require('readline');
let util = require('util');

let ffmpeg = require('fluent-ffmpeg');
let glob = require('glob');
let youtubedl = require('youtube-dl-exec');

let globAsync = util.promisify(glob);
let question = async function(text) {
  let rl = readline.createInterface({
    input: process.stdin,
    output: process.stderr
  });
  let rlQuestion = util.promisify(rl.question).bind(rl);
  let result = await rlQuestion(text);
  rl.close();
  return result;
};

let getYoutubeFrames = async function({url, tmpDir}) {
  let filename = await youtubedl(url, {
    getFilename: true
  });

  console.info(`Downloading ${url}...`);
  await youtubedl(url, {
    // cheating. scene-change images need to be max-width 800px
    format: 'bestvideo[width<=800]/best[width<=800]',
    output: `${tmpDir}/${filename}`
  });

  console.info("Extracting scene-change frames as JPG images...");
  let ffmpegPromise = new Promise(function(resolve, reject) {
    let ffmpegCmd = ffmpeg(`${tmpDir}/${filename}`);
    ffmpegCmd = ffmpegCmd.videoFilter('select=gt(scene\\,0.7)');
    ffmpegCmd = ffmpegCmd.outputOption('-vsync vfr');
    ffmpegCmd = ffmpegCmd.saveToFile(`${tmpDir}/scene-%04d.jpg`);

    ffmpegCmd.on('error', function(err) {
      reject(err);
    });
    ffmpegCmd.on('end', function() {
      resolve();
    });
    ffmpegCmd.run();
  });
  await ffmpegPromise;

  let files = await globAsync(`${tmpDir}/scene-*.jpg`);
  return {
    files
  };
};

// main ------------------------------------------------------------------------

(async function() {
  let tmpDir = fs.mkdtempSync(`${os.tmpdir()}/boom-`);
  console.info(`Setting working dir to temp dir ${tmpDir}...`);

  let url = await question(`
What video url should we extract scene-change frames from?
Example: https://vimeo.com/575996892
`);

  let {files} = await getYoutubeFrames({url, tmpDir});
  console.info("Scene-change images:");
  console.log(files.join('\n'));
})();
