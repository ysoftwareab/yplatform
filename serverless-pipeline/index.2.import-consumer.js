let util = require('./util');

let partial = async function({env = {}} = {}) {
  const bucketRes = 'ImportS3Bucket';
  const productBucketRes = 'Products3Bucket';
  const lambdaRes = 'ImportConsumerLambda';
  const lambdaRoleRes = `${lambdaRes}Role`;
  const streamRes = `${lambdaRes}Stream`;

  let Resources = {};
  let Outputs = {};

  Resources[productBucketRes] = {
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

  Resources[`${streamRes}Role`] = {
    Type: 'AWS::IAM::Role',
    Properties: {
      AssumeRolePolicyDocument: util.assumeRolePolicyDocument('events'),
      Policies: [{
        PolicyName: streamRes,
        PolicyDocument: {
          Version: '2012-10-17',
          Statement: {
            Effect: 'Allow',
            Action: [
              'kinesis:PutRecord*'
            ],
            Resource: [
              util.getAtt(streamRes, 'Arn')
            ]
          }
        }
      }]
    }
  };

  // s3 to kinesis stream
  Resources[`${streamRes}Event`] = {
    DependsOn: [
      streamRes
    ],
    Type: 'AWS::Events::Rule',
    Properties: {
      EventPattern: {
        source: [
          'aws.s3'
        ],
        'detail-type': [
          'Object Created'
        ],
        detail: {
          bucket: {
            name: [
              util.ref(bucketRes)
            ]
          }
        }
      },
      RoleArn: util.getAtt(`${streamRes}Role`, 'Arn'),
      State: 'ENABLED',
      Targets: [{
        Id: streamRes,
        Arn: util.getAtt(streamRes, 'Arn')
      }]
    }
  };

  Resources[streamRes] = {
    DependsOn: [],
    Type: 'AWS::Kinesis::Stream',
    // DeletionPolicy: 'Retain',
    Properties: {
      // Name: ''
      ShardCount: 1
    }
  };

  // kinesis stream to lambda
  Resources[`${lambdaRes}Event`] = {
    DependsOn: [
      lambdaRes,
      streamRes
    ],
    Type: 'AWS::Lambda::EventSourceMapping',
    Properties: {
      BatchSize: 1,
      // BisectBatchOnFunctionError: true,
      FunctionName: util.ref(lambdaRes),
      Enabled: true,
      EventSourceArn: util.getAtt(streamRes, 'Arn'),
      StartingPosition: 'TRIM_HORIZON'
    }
  };

  Resources[lambdaRoleRes] = {
    DependsOn: [],
    Type: 'AWS::IAM::Role',
    Properties: {
      AssumeRolePolicyDocument: util.assumeRolePolicyDocument('lambda'),
      ManagedPolicyArns: [
        'arn:aws:iam::aws:policy/service-role/AWSLambdaKinesisExecutionRole'
      ],
      Policies: [{
        PolicyName: streamRes,
        PolicyDocument: {
          Version: '2012-10-17',
          Statement: {
            Effect: 'Allow',
            Action: [
              's3:Get*',
              's3:List*'
            ],
            Resource: [
              util.getAtt(productBucketRes, 'Arn'),
              util.join([util.getAtt(productBucketRes, 'Arn'), '/*'])
            ]
          }
        }
      }]
      // RoleName: ''
    }
  };

  Resources[lambdaRes] = {
    DependsOn: [],
    Type: 'AWS::Lambda::Function',
    Properties: {
      Code: `${__dirname}/lambda`,
      // FunctionName: '',
      Environment: {
        Variables: {
          PRODUCT_BUCKET: productBucketRes
        }
      },
      Handler: 'index.handler',
      // fair price/perf ratio
      MemorySize: 1024,
      Role: util.getAtt(lambdaRoleRes, 'Arn'),
      Runtime: 'nodejs16.x',
      Timeout: 15 * 60
    }
  };

  Outputs[`${lambdaRes}Name`] = {
    Value: util.ref(lambdaRes)
  };

  Outputs[`${lambdaRoleRes}Name`] = {
    Value: util.ref(lambdaRoleRes)
  };

  Outputs[`${streamRes}Name`] = {
    Value: util.ref(streamRes)
  };

  Outputs[`${productBucketRes}Name`] = {
    Value: util.ref(productBucketRes)
  };

  return {
    Resources,
    Outputs
  };
};

module.exports = partial;
