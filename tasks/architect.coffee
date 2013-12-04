fs = require('fs')
JSONR = require('json-toolkit').Resource
CSON = require('cson')
YAML = require('js-yaml')


class Architect

  init: (@options) ->
    @grunt = @options.grunt
    @blueprints = @grunt.file.readJSON(@options.jsonFile)



  # ---
  # gather fragments from input html
  process: (comments, parser, keyword, cb) ->

    # ---
    # loop fragments
    for comment in comments
      { meta, blueprint } = @[parser](comment)

      # something went wrong
      if not meta or not blueprint
        cb(false)
        return

      # cleanup meta
      meta = @cleanMeta(meta, keyword)

      # generate blueprint
      @generate(blueprint, meta)

    # callback
    cb()



  # ---
  # yaml
  yaml: (comment) ->
    data = comment.split('---')
    meta = data[0].replace(/\s+/g, ' ')
    blueprint = data[1]

    try 
      blueprint = YAML.safeLoad(blueprint)
      return { meta, blueprint }
    catch err
      @grunt.log.error("#{err} (#{meta})")
      return false




  # ---
  # cson
  cson: (comment) ->
    meta = ''
    blueprint = comment.replace /^[^{]*/g, (a,b,c) ->
      meta = a.replace(/\s+/g, ' ')
      return ''

    try 
      blueprint = CSON.parseSync(blueprint)
      return { meta, blueprint }
    catch err
      @grunt.log.error("#{err} (#{meta})")
      return false




  # ---
  # json
  json: (comment) ->
    meta = ''
    blueprint = comment.replace /^[^{]*/g, (a,b,c) ->
      meta = a.replace(/\s+/g, ' ')
      return ''

    try 
      blueprint = JSON.parse(blueprint)
      return { meta, blueprint }
    catch err
      @grunt.log.error("#{err} (#{meta})")
      return false




  # ---
  # strip meta fragment
  cleanMeta: (meta, keyword) ->
    return meta.replace(new RegExp("^(\\s+)?#{keyword}(\\s+)"), '').trim()




  # ---
  # generate blueprint
  generate: (json, meta) =>

    # ugly ugly check for failed cson parse (pending https://github.com/bevry/cson/issues/26)
    if not json or typeof json isnt 'object' or json.location?.first_line
      @grunt.log.error "Error parsing json (#{meta})"
      return


    # no path specified
    if not json.path
      @grunt.log.error "No json path specified (#{meta})"
      return


    # cleanup json
    # get path and remove it from json
    path = json.path
    pathArr = path.split('.')
    delete json.path


    # get json key
    keys = Object.keys(json)

    # traverse / manipulate blueprints
    # create empty object for every non existing step
    # create json toolkit resource
    inject = new JSONR(@blueprints, { from_file: false, key_sep: '.' })


    # create empty object for steps in path that don't exist
    cursor = pathArr.shift()
    for step in pathArr
      cursor += ".#{step}"
      if not inject.get(cursor)
        inject.set(cursor, {})
      

    # manipulate all keys
    for key in keys

      # log
      @grunt.verbose.oklns "#{key}: \"#{meta}\""

      # add meta (strip architect)
      #json[key].meta = meta

      # inject new json
      inject.set("#{path}.#{key}", json[key])

      # inject new json
      @blueprints = inject.data


    # write to file
    str = JSON.stringify(@blueprints, null, 4)

    # write to file only once is probably preferred
    fs.writeFileSync @options.jsonFile, str
  



module.exports = Architect