
module.exports = (grunt) ->

  grunt.loadNpmTasks('grunt-contrib-nodeunit')
  grunt.loadNpmTasks('grunt-contrib-clean')

  grunt.loadTasks('tasks/')
  
  # By default, lint and run all tests.
  grunt.registerTask('default', ['clean','architect', 'nodeunit'])
  grunt.registerTask('test', ['clean','architect','nodeunit'])


  grunt.initConfig

    architect:
      json:
        options: {
          parser: 'json'
        }
        files: {
          'test/tmp/json.json': ['test/fixtures/json*.html']
        }

      cson:
        options: {
          parser: 'cson'
        }
        files: {
          'test/tmp/cson.json': ['test/fixtures/cson*.html']
        }

      yaml:
        options: {
          parser: 'yaml'
        }
        files: {
          'test/tmp/yaml.json': ['test/fixtures/yaml*.html']
        }


      customtemplate:
        options: {
          template: {
            foo: {
              baz: "baz"
            }
          }
        }
        files: {
          'test/tmp/custom-template.json': ['test/fixtures/custom-template.html']
        }


      # todo: keyword
      customkeyword:
        options: {
          keyword: 'customkeyword'
        }
        files: {
          'test/tmp/custom-keyword.json': ['test/fixtures/custom-keyword.html']
        }





    clean:
      tests: ['test/tmp']


    nodeunit:
      all: ['test/architect_test.js']

  