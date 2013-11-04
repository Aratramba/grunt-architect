
module.exports = (grunt) ->

  grunt.loadNpmTasks('grunt-contrib-nodeunit')
  grunt.loadTasks('tasks/')
  
  # By default, lint and run all tests.
  grunt.registerTask('default', ['architect'])
  grunt.registerTask('test', ['nodeunit'])


  grunt.initConfig

    architect:
      architect:
        options: {
          parser: 'json'
        }
        files: {
          'blueprints.json': ['test/fixtures/**/*-json.html']
        }

    nodeunit:
      tests: ['test/*_test.js'],

  