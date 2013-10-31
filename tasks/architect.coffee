fs = require('fs')
JSONR = require('json-toolkit').Resource
CSON = require('cson')


class Architect

  init: (@file) ->

    if not fs.existsSync(@file)
      template = require('./templates/blueprints')
      fs.writeFileSync @file, JSON.stringify(template)

    @blueprints = JSON.parse(fs.readFileSync(@file, 'utf8'))



  # ---
  # generate blueprint
  generate: (json, meta) =>

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
    # path doesnt exist

    # create empty object for every non existing step

    cursor = pathArr.shift()
    for step in pathArr
      cursor += ".#{step}"
      if not inject.get(cursor)
        inject.set(cursor, {})

    inject.set(path, json)

    # inject new json
    #inject.set(path, json)
    @blueprints = inject.data

    str = JSON.stringify(@blueprints, null, 4) 

    # write to file only once is preferred
    fs.writeFileSync @file, str



  # ---
  # gather comments from input html
  process: ($, cb) ->

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


    # callback
    cb()
        



module.exports = Architect