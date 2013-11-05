
module.exports = (grunt) ->

  grunt.loadNpmTasks('grunt-contrib-nodeunit')
  grunt.loadNpmTasks('grunt-contrib-clean')

  grunt.loadTasks('tasks/')
  
  # By default, lint and run all tests.
  grunt.registerTask('default', ['clean','architect'])
  grunt.registerTask('test', ['clean','architect','nodeunit'])


  grunt.initConfig

    architect:
      json:
        options: {
          parser: 'json'
        }
        files: {
          'test/tmp/input-json.json': ['test/fixtures/**/json*.html']
        }

      cson:
        options: {
          parser: 'cson'
        }
        files: {
          'test/tmp/input-cson.json': ['test/fixtures/**/cson*.html']
        }

      yaml:
        options: {
          parser: 'yaml'
        }
        files: {
          'test/tmp/input-yaml.json': ['test/fixtures/**/yaml*.html']
        }


      # todo: template
      template:
        options: {
          template: {
            foo: {
              bar: {}
            }
          }
        }
        files: {
          'test/tmp/template.json': ['test/fixtures/**/template.html']
        }


      # todo: keyword
      keyword:
        options: {
          parser: 'cson'
          keyword: 'customkeyword'
        }
        files: {
          'test/tmp/keyword.json': ['test/fixtures/**/keyword.html']
        }


      


    clean:
      tests: ['test/tmp']


    nodeunit:
      json: ['test/*_test.js'],

  