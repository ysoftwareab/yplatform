
---

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
