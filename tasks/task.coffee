'use strict';

module.exports = (grunt) ->

  # load cheerio
  cheerio = require('cheerio')
  Architect = require('./architect')


  # ---
  # grunt task

  grunt.registerMultiTask 'architect', 'Grunt plugin for creating blueprints', ->

    done = @async()
    counter = 0

    # Iterate over all specified file groups.
    @files.forEach (f) ->

      counter = f.src.length

      # Concat specified files.
      src = f.src
        .filter (filepath) ->
          # Warn on and remove invalid source files (if nonull was set).
          return grunt.file.exists(filepath) or grunt.file.isFile(filepath)

        .forEach (filepath) ->

          grunt.log.oklns(filepath)

          # read file
          srcContents = grunt.file.read(filepath)

          # load file into cheerio
          $ = cheerio.load(srcContents)

          architect = new Architect()
          architect.init(f.dest, filepath, grunt, $)

          # generate blueprints
          architect.process =>
            --counter
            if counter is 0
              done()