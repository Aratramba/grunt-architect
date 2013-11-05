fs = require('fs')
JSONR = require('json-toolkit').Resource
CSON = require('cson')
YAML = require('js-yaml')


class Architect

  init: (@options) ->
    @grunt = @options.grunt
    @blueprints = @grunt.file.readJSON(@options.jsonFile)



  # ---
  # generate blueprint
  generate: (json, meta) =>

    if not json or typeof json isnt 'object' or json.location?.first_line # ugly ugly check for failed cson parse (pending https://github.com/bevry/cson/issues/26)
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
    key = Object.keys(json)

    # log
    @grunt.verbose.oklns "#{key}: \"#{meta}\""


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


    # add meta (strip architect)
    json[key].meta = meta

    # inject new json
    inject.set("#{path}.#{key}", json[key])

    # inject new json
    @blueprints = inject.data


    # write to file
    str = JSON.stringify(@blueprints, null, 4)

    # write to file only once is probably preferred
    fs.writeFileSync @options.jsonFile, str



  # ---
  # gather fragments from input html
  process: (args, $, cb) ->

    # ---
    # filter fragments from html
    fragments = $("*").contents().filter (n, el) =>
      if el.type is 'comment' # check for comment
        if el.data.replace(/\s+/g, '').substring(0, args.keyword.length) is args.keyword # check for provided keyword
          return true
        return false
      return false

    # ---
    # loop fragments
    fragments.each (n, el) =>

      # parse
      switch args.parser
        when 'yaml'
          { meta, blueprint } = @processYAML(el)
        when 'cson'
          { meta, blueprint } = @processCSON(el)
        when 'json'
          { meta, blueprint } = @processJSON(el)


      # cleanup meta
      meta = @cleanMeta(meta, args.keyword)

      # generate blueprint
      @generate(blueprint, meta)


    # callback
    cb()



  # ---
  # yaml
  processYAML: (el) ->
    meta = ''
    blueprint = el.data.replace /^[^---]*/g, (a,b,c) ->
      meta = a.replace(/\s+/g, ' ')
      return ''

    blueprint = YAML.safeLoad(blueprint)
    return { meta, blueprint }



  # ---
  # cson
  processCSON: (el) ->
    meta = ''
    blueprint = el.data.replace /^[^{]*/g, (a,b,c) ->
      meta = a.replace(/\s+/g, ' ')
      return ''

    blueprint = CSON.parseSync(blueprint)
    return { meta, blueprint }



  # ---
  # json
  processJSON: (el) ->

    meta = ''
    blueprint = el.data.replace /^[^{]*/g, (a,b,c) ->
      meta = a.replace(/\s+/g, ' ')
      return ''

    blueprint = JSON.parse(blueprint)
    return { meta, blueprint }



  # ---
  # strip meta fragment
  cleanMeta: (meta, keyword) ->
    return meta.replace(new RegExp("^(\\s+)?#{keyword}(\\s+)"), '').trim()
    
  

module.exports = Architect