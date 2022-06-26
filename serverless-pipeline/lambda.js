Error.stackTraceLimit = Infinity;

let handler = async function(event, context) {
  // debug
  console.log("EVENT: \n" + JSON.stringify(event, null, 2));

  // if not from kinesis, exit early
  // if not base64 data, exit early
  // if data is not from s3, exit early

  // https://dev.to/rajeshkumaryadavdotcom/node-js-determining-the-line-count-of-a-text-file-195l

  // - copy s3 file to tmp
  // - start reading file, skip lines as by event
  // - while enough time left (calculate metrics!), transform line to json, write to s3
  // - if not done, and no time left, resend s3 event with "start from line number x" addition
};

module.exports = {
  handler
}
