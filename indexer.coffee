through = require 'through'
path = require 'path'
_ = require 'underscore'
gutil = require 'gulp-util'
moment = require 'moment'

module.exports = (site, options) ->

  files = []

  fileStreamHandler = (file) ->
    files.push file

  endStream = ->
    # Sort files by start date
    files = files.sort((post1, post2) ->
      date1 = moment(post1.meta.date)
      date2 = moment(post2.meta.date)
      if date1.isBefore(date2) then 1 else -1
    )

    # Add home page
    homepage = new gutil.File({
      base: path.join(__dirname, './content/'),
      cwd: __dirname,
      path: path.join(__dirname, './content/index.html')
    })
    homepage._contents = Buffer(generateHomePage(files))
    homepage['meta'] = { layout: 'post' }
    files.push homepage

    # Add styleguide
    styleguide = new gutil.File({
      base: path.join(__dirname, './content/'),
      cwd: __dirname,
      path: path.join(__dirname, './content/styleguide/index.html')
    })
    styleguide._contents = Buffer("")
    styleguide['meta'] = { layout: 'styleguide' }
    files.push styleguide

    for file in files
      @emit 'data', file

    @emit 'end'

  return through(fileStreamHandler, endStream)

generateHomePage = (files) ->
  homepage = ""

  for file in files
    if file.meta.draft
      continue
    date = moment(file.meta.date)
    url = path.dirname(file.relative)
    homepage += "<a href='#{ url }'>#{ date.format('YYYY MM DD') } #{ file.meta.title }</a><br>"

  return homepage
