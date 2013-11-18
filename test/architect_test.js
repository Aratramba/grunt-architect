'use strict';

var grunt = require('grunt');


exports.architect = {
  setUp: function(done) {
    done();
  },

  // ---
  // json files
  // ---
  json: function(test) {
    test.expect(1);

    var actual = grunt.file.read('test/tmp/json.json');
    var expected = grunt.file.read('test/expected/family.json');
    test.equal(actual, expected, 'should parse json.');

    test.done();
  },



  // ---
  // cson files
  // ---
  cson: function(test) {
    test.expect(1);

    var actual = grunt.file.read('test/tmp/cson.json');
    var expected = grunt.file.read('test/expected/family.json');
    test.equal(actual, expected, 'should parse cson.');

    test.done();
  },
  

  
  // ---
  // yaml files
  // ---
  yaml: function(test) {
    test.expect(1);

    var actual = grunt.file.read('test/tmp/yaml.json');
    var expected = grunt.file.read('test/expected/family.json');
    test.equal(actual, expected, 'should parse yaml.');

    test.done();
  },
  

  
  // ---
  // custom template specified
  // ---
  customtemplate: function(test) {
    test.expect(1);

    var actual = grunt.file.read('test/tmp/custom-template.json');
    var expected = grunt.file.read('test/expected/simple.json');
    test.equal(actual, expected, 'should be able to use a custom template.');

    test.done();
  },
  

  
  // ---
  // custom keyword specified
  // ---
  customkeyword: function(test) {
    test.expect(1);

    var actual = grunt.file.read('test/tmp/custom-keyword.json');
    var expected = grunt.file.read('test/expected/simple.json');
    test.equal(actual, expected, 'should be able to use a custom keyword.');

    test.done();
  }
};
