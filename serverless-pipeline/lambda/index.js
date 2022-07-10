Error.stackTraceLimit = Infinity;

console.debugging = true;

console.debug = function(...args) {
  if (!console.debugging) {
    return;
  }
  console.info(...args);
};

let j = function(json) {
  return JSON.stringify(json, null, 2);
};

let _ = require('lodash');
let aws = require('aws-sdk');
let csvtojson = require('csvtojson');
let fs = require('fs');
let objectHash = require('object-hash');
let s3 = new aws.S3();
let s3SyncClient = require('s3-sync-client');
let {S3Client} = require('@aws-sdk/client-s3');
let {sync} = new s3SyncClient({client: new S3Client({})});

aws.config.logger = console;

let assertKinesisRecord = function(record) {
  // poor man's json schema validator
  let expected = {
    eventSource: 'aws:kinesis',
    eventName: 'aws:kinesis:record',
    kinesis: {
      kinesisSchemaVersion: '1.0'
    }
  };

  if (!_.isMatch(record, expected)) {
    console.error(`Unexpected record.`, j({record, expected}));
    throw new Error('Unexpected record.');

  }
};

let assertS3PubOjectData = function(data, record) {
  // poor man's json schema validator
  let expected = {
    version: '0',
    'detail-type': 'Object Created',
    source: 'aws.s3',
    detail: {
      version: '0',
      reason: 'PutObject'
    }
  };

  if (!_.isMatch(data, expected)) {
    console.error(`Unexpected data.`, j({record, data, expected}));
    throw new Error('Unexpected data.');
  }
};

let handleRecord = async function(record) {
  console.debug("RECORD: \n" + j(record));

  assertKinesisRecord(record);

  let stringData = Buffer.from(record.kinesis.data, 'base64').toString('ascii');
  let data = JSON.parse(stringData);

  console.debug("RECORD: \n" + j(record));

  assertS3PubOjectData(data, record);

  let recordHash = objectHash(record);
  let tmpProductDir = `/tmp/products/${recordHash}`;
  if (fs.existsSync(tmpProductDir)) {
    fs.rmdirSync(tmpProductDir, {
      recursive: true,
      force: true
    });
  }
  fs.mkdirSync(tmpProductDir, {
    recursive: true
  });

  let objMeta;
  try {
    objMeta = await s3.headObject({
      Bucket: data.detail.bucket.name,
      Key: data.detail.object.key,
      IfMatch: data.detail.object.etag,
      VersionId: data.detail.object['version-id']
    }).promise();
  } catch(err) {
    console.warn('Skipping. S3 reference cannot be found.', j({err, record, data}));
    return;
  }

  // NOTE could split object based on objMeta.ContentLength
  // if the size is too big, though 10000 items with 1KB/item is ~10 MB
  // so that would be premature optimization

  let stream = await s3.getObject({
    Bucket: data.detail.bucket.name,
    Key: data.detail.object.key,
    IfMatch: data.detail.object.etag,
    VersionId: data.detail.object['version-id']
  }).createReadStream();

  let products;
  try {
    products = csvtojson.fromStream(stream);
  } catch(err) {
    console.warn('Skipping. Invalid CSV format.', j({err, record, data}));
    return;
  }

  // NOTE could possibly chunk to sync in parallel for performance

  products.subscribe(async function(product) {
    let hash = hash(product);
    fs.writeFileSync(`${tmpProductDir}/${hash}`, JSON.stringify(product, null, 2));
  });

  await sync(tmpProductDir, `s3://${process.env.PRODUCT_BUCKET}`);
};

let handler = async function(event, context) {
  console.debug("EVENT: \n" + j(event));

  if (!event?.Records?.length) {
    console.error('Unknown lambda event. Expected event.Records[].', j({event}));
    throw new Error('Unknown lambda event.');
  }

  await Promise.all(_.map(event.Records, handleRecord));
};

module.exports = {
  handler
}
