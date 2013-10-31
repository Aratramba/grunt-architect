'use strict';

module.exports = (grunt) ->

  # load cheerio
  cheerio = require('cheerio')
  Architect = require('./architect')


  # ---
  # grunt task

  grunt.registerMultiTask 'architect', 'Grunt plugin for creating blueprints', ->

    # Iterate over all specified file groups.
    @files.forEach (f) ->

      # Concat specified files.
      src = f.src
        .filter (filepath)->
            # Warn on and remove invalid source files (if nonull was set).
            if not grunt.file.exists(filepath) or not grunt.file.isFile(filepath)
              return false
            true

        .forEach (filepath) ->

          architect = new Architect()
          architect.init(f.dest)

          # read file
          srcContents = grunt.file.read(filepath)

          # load file into cheerio
          $ = cheerio.load(srcContents)

          # generate blueprints
          architect.process($)