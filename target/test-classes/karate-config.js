function fn() {
  var env = karate.env; // get system property 'karate.env'
  var data_file = karate.callSingle('classpath:services/bookstore/support.feature@ReadAndGenerateTestData');

  if (!env) {
    env = 'dev';
  }

  karate.log('karate.env system property was:', env);

  var config = {
    env: env,
    data_file: data_file
  }

  if (env == 'dev') {
    // customize
    // e.g. config.foo = 'bar';
  } else if (env == 'e2e') {
    // customize
  }

  karate.configure("retry", {
    count: 10,
    interval: 5000
  });

  return config;
}