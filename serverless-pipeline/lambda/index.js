Error.stackTraceLimit = Infinity;

console.debugging = true;

console.debug = function(...args) {
  if (!console.debugging) {
    return;
  }
  console.info(...args);
};

let aws = require('aws-sdk');
let s3 = new aws.S3();

let assertKinesisRecord = function(record) {
  if (record?.eventName === 'aws:kinesis:record') {
    console.error(`Unknown record.eventName. Expected aws:kinesis:record.`, {record});
    throw new Error(`Unknown record.eventName.`);
  }

  if (record.kinesis.kinesisSchemaVersion === '1.0') {
    console.error(`Unknown record.kinesis.kinesisSchemaVersion . Expected 1.0.`, {record});
    throw new Error(`Unknown record.kinesis.kinesisSchemaVersion.`);
  }
};

let assertS3PubOjectData = function(data, record) {
  if (data.source !== 'aws.s3') {
    console.error(`Unknown record.kinesis.data.source . Expected aws:s3.`, {record, data});
    throw new Error(`Unknown record.kinesis.data.source.`);
  }

  if (data.version !== '0') {
    console.error(`Unknown record.kinesis.data.version . Expected 0.`, {record, data});
    throw new Error(`Unknown record.kinesis.data.version.`);
  }

  if (data['detail-type'] !== 'Object Created') {
    console.error(`Unknown record.kinesis.data.detail-type . Expected Object Created.`, {record, data});
    throw new Error(`Unknown record.kinesis.data.detail-type.`);
  }

  if (data.detail.version !== '0') {
    console.error(`Unknown record.kinesis.data.detail.version . Expected 0.`, {record, data});
    throw new Error(`Unknown record.kinesis.data.detail.version.`);
  }

  if (data.version !== '0') {
    console.error(`Unknown record.kinesis.data.version . Expected 0.`, {record, data});
    throw new Error(`Unknown record.kinesis.data.version.`);
  }
};

let handleRecord = async function(record) {
  console.debug("RECORD: \n" + JSON.stringify(record, null, 2));

  assertKinesisRecord(record);

  let stringData = Buffer.from(record.kinesis.data, 'base64').toString('ascii');
  let data = JSON.parse(stringData);

  console.debug("RECORD: \n" + JSON.stringify(record, null, 2));

  assertS3PubOjectData(data, record);

  let objMeta;
  try {
    objMeta = await s3.headObject({
      Bucket: data.detail.bucket.name,
      Key: data.detail.object.key,
      IfMatch: data.detail.object.etag,
      VersionId: data.detail.object['version-id']
    }).promise();
  } catch(err) {
    console.warn('Skipping. S3 reference cannot be found.', {record, data});
    return;
  }

  // TODO split object based on objMeta.ContentLength

  let obj;
  try {
    obj = await s3.getObject({
      Bucket: data.detail.bucket.name,
      Key: data.detail.object.key,
      IfMatch: data.detail.object.etag,
      VersionId: data.detail.object['version-id']
    }).promise();
  } catch(err) {
    console.warn('Skipping. S3 reference cannot be found.', {record, data});
    return;
  }

  let objBody = obj.Body.toString('ascii');


};

let handler = async function(event, context) {
  console.debug("EVENT: \n" + JSON.stringify(event, null, 2));

  if (!event?.Records?.length) {
    console.error('Unknown lambda event. Expected event.Records[].', {event});
    throw new Error('Unknown lambda event.');
  }

  await Promise.all(event.Records.map(handleRecord));



  // if not from kinesis, exit early
  // if not base64 data, exit early
  // if data is not from s3, exit early

  // https://dev.to/rajeshkumaryadavdotcom/node-js-determining-the-line-count-of-a-text-file-195l
  // https://github.com/aws-samples/reactive-refarch-cloudformation/blob/master/infrastructure/lambda.yaml
  // https://www.itonaut.com/2020/01/14/kinesis-data-stream-as-lambda-trigger-in-aws-cloudformation/
  // https://www.derpturkey.com/a-simple-aws-cloudformation-example-with-lambda-and-kinesis/

  // - copy s3 file to tmp (with range if available)
  // - start reading file
  // - while enough time left (calculate metrics!), transform line to json, write to s3
  // - if not done, and no time left, resend s3 event with "skip first x bytes" addition
  // ps: simpler alternative: use lines, not bytes


};

module.exports = {
  handler
}
