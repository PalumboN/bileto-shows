module.exports = (db) ->
  express = require('express')
  bodyParser = require('body-parser')
  config = require('./config')
  job = require('./job')
  {Show} = require('./models/schemas')(db)
  ticketek = require('./models/ticketek')

  app = express()

  app.use bodyParser.json()


  send = (res) -> (result) -> res.send result
  errorHandler = (res) -> (error) ->
    console.log error
    res.status(500).send {error}

  finish = (res, promise) ->
    promise
    .then send res
    .catch errorHandler res


  ## JOBS
  app.get '/jobs', (req, res) ->
    finish res, Show.findOpen()

  app.get '/jobs/archive', (req, res) ->
    finish res, Show.findArchive()

  app.post '/jobs', ({body}, res) ->
    finish res, Show.create body

  app.delete '/jobs/:job', ({params}, res) ->
    finish res, Show.findByIdAndUpdate(params.job, archive: true)

  app.post '/jobs/reopen/:job', ({params}, res) ->
    finish res, Show.findByIdAndUpdate(params.job, archive: false)

  ## SHOWS
  app.post '/jobs/run', (req, res) ->
    finish res, job(db).run()

  app.get '/shows/:show', ({params}, res) ->
    finish res, ticketek.getPerformances params.show


  ## PING
  app.get '/ping', (req, res) ->  res.send("pong")

  path = __dirname + "/app"
  app.set "views", path

  app.use express.static(__dirname + "/..") # node_modules
  app.use express.static(path)
  app.set "appPath", path

  app.get '/', (req, res) -> res.sendFile path + "/index.html"


  port = config.port
  app.listen port, ->
    console.log "Listen port #{port}"
