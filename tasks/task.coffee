'use strict';

module.exports = (grunt) ->

  # load cheerio
  cheerio = require('cheerio')
  Architect = require('./architect')


  # ---
  # grunt task

  grunt.registerMultiTask 'architect', 'Grunt plugin for creating blueprints', ->

    options = @options {
      parser: 'yaml',
      template: {
        global: {}
        nodes: {}
      }
    }

    done = @async()
    counter = 0

    # parser
    if ['yaml', 'json', 'cson'].indexOf(options.parser) is -1
      grunt.fail.warn 'Parser option must be one of yaml|json|cson'


    # Iterate over all specified file groups.
    @files.forEach (f) ->

      counter = f.src.length

      # Concat specified files.
      src = f.src
        .filter (filepath) -> 
          return grunt.file.exists(filepath) or grunt.file.isFile(filepath)

        .forEach (filepath) ->

          # check if blueprints exist
          if not grunt.file.exists(f.dest)

            # create from template
            grunt.file.write(f.dest, JSON.stringify(options.template))


          grunt.log.oklns(filepath)

          # read file
          srcContents = grunt.file.read(filepath)

          # load file into cheerio
          $ = cheerio.load(srcContents)

          architect = new Architect()

          args = {
            jsonFile: f.dest
            htmlFile: filepath
            template: options.template
            grunt
          }

          architect.init(args)

          # generate blueprints
          architect.process options.parser, $, =>
            --counter
            if counter is 0
              done()