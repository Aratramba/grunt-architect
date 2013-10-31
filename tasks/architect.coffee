fs = require('fs')
JSONR = require('json-toolkit').Resource
CSON = require('cson')
YAML = require('js-yaml')


class Architect

  init: (@jsonFile, @htmlFile, @grunt, @$) ->

    # check if blueprints exist
    if not fs.existsSync(@jsonFile)

      # create from template
      template = require('./templates/blueprints')
      fs.writeFileSync @jsonFile, JSON.stringify(template)

    # read blueprints
    @blueprints = JSON.parse(fs.readFileSync(@jsonFile, 'utf8'))



  # ---
  # strip meta comment
  cleanMeta: (meta) ->
    return meta.replace(/^(\s+)?architect(\s+)/, '').trim()



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
    fs.writeFileSync @jsonFile, str



  # ---
  # gather comments from input html
  process: (cb) ->

    # ---
    # filter comments from html
    comments = @$("*").contents().filter (n, el) =>
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

      meta = @cleanMeta(meta)

      console.log YAML.load(blueprint)
      
      blueprint = CSON.parseSync(blueprint)
      @generate(blueprint, meta)


    # callback
    cb()
        



module.exports = Architect