require('./globals')
_ = require('lodash')
express = require('express')
bodyParser = require('body-parser')
config = require('./config')
job = require('./models/job')
{Show} = require('./models/schemas')
ticketek = require('./models/ticketek')

app = express()
port = config.port

app.use bodyParser.json()

send = (res) ->
  (result, error) ->
    res.send {error} if error?
    res.send result

app.get '/ping', (req, res) ->
  res.send("pong")

app.get '/jobs', (req, res) ->
  Show
  .find()
  .then send res

app.post '/jobs', ({body}, res) ->
  console.log body
  Show
  .create body
  .then send res

app.post '/jobs/run', (req, res) ->
  job
  .run()
  .then send res


app.get '/shows/:show', ({ params }, res) ->
  ticketek
  .getPerformances params.show
  .then send res


path = __dirname + "/app"
app.set "views", path

app.use express.static(__dirname + "/..")
app.use express.static(path)
app.set "appPath", path

app.get '/', (req, res) -> res.sendFile path + "/index.html"


app.listen port, ->
  console.log "Listen port #{port}"
