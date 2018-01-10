require('./globals')
express = require('express')
bodyParser = require('body-parser')
config = require('./config')
job = require('./models/job')
{Show} = require('./models/schemas')
ticketek = require('./models/ticketek')

app = express()

app.use bodyParser.json()


send = (res) -> (result) -> res.send result
errorHandler = (res) -> (error) -> res.status(500).send {error}

finish = (res, promise) ->
  promise
  .then send res
  .catch errorHandler res


app.get '/ping', (req, res) ->
  res.send("pong")

app.get '/jobs', (req, res) ->
  finish res, Show.find()

app.post '/jobs', ({body}, res) ->
  finish res, Show.create body

app.post '/jobs/run', (req, res) ->
  finish res, job.run()

app.get '/shows/:show', ({ params }, res) ->
  finish res, ticketek.getPerformances params.show


path = __dirname + "/app"
app.set "views", path

app.use express.static(__dirname + "/..")
app.use express.static(path)
app.set "appPath", path

app.get '/', (req, res) -> res.sendFile path + "/index.html"


port = config.port
app.listen port, ->
  console.log "Listen port #{port}"
