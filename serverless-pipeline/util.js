let assumeRolePolicyDocument = function(service) {
  return {
    Version: '2012-10-17',
    Statement: [{
      Effect: 'Allow',
      Action: [
        'sts:AssumeRole'
      ],
      Principal: {
        Service: [
          `${service}.amazonaws.com`
        ]
      }
    }]
  };
};

let getAtt = function(res, prop) {
  return {
    'Fn::GetAtt': [res, prop]
  };
};

let ref = function(res) {
  return {
    Ref: res
  }
};

module.exports = {
  assumeRolePolicyDocument,
  getAtt,
  ref
}
