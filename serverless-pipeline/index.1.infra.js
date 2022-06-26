let util = require('./util');

let partial = async function({env = {}} = {}) {
  const bucketRes = 'ImportS3Bucket';

  let Resources = {};
  let Outputs = {};

  Resources[bucketRes] = {
    Type: 'AWS::S3::Bucket',
    // DeletionPolicy: 'Retain',
    Properties: {
      AccessControl: 'Private',
      BucketEncryption: {
        ServerSideEncryptionConfiguration: [{
          ServerSideEncryptionByDefault: {
            SSEAlgorithm: 'AES256'
          }
        }]
      },
      // BucketName: ''
      NotificationConfiguration: {
        EventBridgeConfiguration: {
          EventBridgeEnabled: true
        }
      },
      PublicAccessBlockConfiguration: {
        BlockPublicAcls: true,
        BlockPublicPolicy: true,
        IgnorePublicAcls: true,
        RestrictPublicBuckets: true
      },
      VersioningConfiguration: {
        Status: 'Enabled'
      }
    }
  };

  Outputs[`${bucketRes}Name`] = {
    Value: util.ref(bucketRes)
  };

  return {
    Resources,
    Outputs
  };
};

module.exports = partial;
