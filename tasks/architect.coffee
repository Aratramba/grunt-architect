fs = require('fs')
JSONR = require('json-toolkit').Resource
CSON = require('cson')


class Architect

  init: (@file) ->
    if not fs.exists(@file)
      template = require('./templates/blueprints')
      fs.writeFileSync @file, JSON.stringify(template)

    @blueprints = JSON.parse(fs.readFileSync(@file, 'utf8'))



  # ---
  # generate blueprint
  generate: (json, meta) =>

    console.log '----'

    if typeof json isnt 'object'
      console.log "Failed parsing cson (#{meta})"

    # no path specified
    if not json.path
      console.log 'No json path specified. Exiting.'
      return


    # create json resource
    inject = new JSONR(@blueprints, { from_file: false, key_sep: '.' })


    # get path and remove it from json
    path = json.path
    pathArr = path.split('.')
    delete json.path


    # traverse / manipulate blueprints
    # path already exists
    if inject.get(path)?

      # insert into array
      if inject.get(path).push?
        inject.get(path).push(json)

    # path doesnt exist
    else
      console.log 'path doesnt exist'
      #console.log inject.search(path)



      tmpArr = pathArr
      for p in pathArr
        if not inject.get(tmpArr.join('.'))
          tmpArr.shift()
          #inject.set(tmpArr.join('.'), {})

        console.log tmpArr




    # inject new json
    #inject.set(path, json)
    @blueprints = inject.data

    str = JSON.stringify(@blueprints, null, 4) 

    # write to file only once is preferred
    fs.writeFileSync @file, str



  # ---
  # gather comments from input html
  process: ($) ->

      # ---
      # filter comments from html
      comments = $("*").contents().filter (n, el) =>
        if el.type is 'comment' # check for comment
          if el.data.replace(/\s+/g, '').substring(0, 9) is 'architect' # check for 'architect'
            return true
          return false
        return false

      # ---
      # loop comments
      comments.each (n, el) =>
        meta = ''

        # remove meta information from blueprint
        blueprint = el.data.replace /^[^{]*/g, (a,b,c) ->
          meta = a.replace(/\s+/g, ' ')
          return ''

        blueprint = CSON.parseSync(blueprint)
        if blueprint
          @generate(blueprint, meta)
          



module.exports = Architect