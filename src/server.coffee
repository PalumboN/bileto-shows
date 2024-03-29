module.exports = (db) ->
  express = require('express')
  session = require('express-session')
  passport = require('passport')
  bodyParser = require('body-parser')
  syncer = require('./job')
  config = require('./config')
  {Show} = require('./models/schemas')(db)
  Ticketek = require('./models/ticketek')
  tuentrada = require('./models/tuentrada')
  ticketportal = require('./models/ticketportal')
  {TicketekSearcher, TuentradaSearcher, TicketportalSearcher} = require('./models/searcher')

  app = express()
  app.use(session({ secret: "tickets", resave: false, saveUninitialized: true }))
  app.use(bodyParser.json())
  app.use(bodyParser.urlencoded({ extended: true }))
  app.use(passport.initialize())
  app.use(passport.session())

  require("./auth")

  authMiddleware = (req, res, next) ->
    if (req.isAuthenticated())
      next()
    else
      res.redirect('/login')

  send = (res) -> (result) -> res.send result
  errorHandler = (res) -> (error) ->
    console.log error
    res.status(500).send {error}

  finish = (res, promise) ->
    promise
    .then send res
    .catch errorHandler res


  ## PING
  app.get '/ping', (req, res) ->  res.send("pong")

  ## API
  app.get '/api/shows', authMiddleware, (req, res) ->
    finish res, Show.findOpen()

  app.get '/api/shows/archive', authMiddleware, (req, res) ->
    finish res, Show.findArchive()

  app.delete '/api/shows/:job', authMiddleware, ({params}, res) ->
    finish res, Show.findByIdAndUpdate(params.job, archive: true)

  app.put '/api/shows/:job', authMiddleware, ({params, body}, res) ->
    finish res, Show.findByIdAndUpdate(params.job, alertIds: body.alertIds)

  app.post '/api/shows/reopen/:job', authMiddleware, ({params}, res) ->
    finish res, Show.findByIdAndUpdate(params.job, archive: false)


  app.post '/api/shows/sync', (req, res) ->
    finish res, Show.findOpen().then syncer.run


  # TICKETEK
  app.get '/api/sites/ticketek/shows', ({params}, res) ->
    res.write "["
    cb = (link) -> 
      new Ticketek()
      .getPerformances(link)
      .then (show) -> res.write Buffer.from(JSON.stringify(show) + ",")

    new TicketekSearcher()
    .run(cb)
    .then -> res.end("null]")

  app.get '/api/sites/ticketek/shows/:show', ({params}, res) ->
    finish res, new Ticketek().getPerformances params.show

  app.post '/api/sites/ticketek/shows/:show/follow', authMiddleware, ({params}, res) ->
    finish res, new Ticketek().getPerformances(params.show).then (it) -> Show.newTicketek it

  # TICKETPORTAL
  app.get '/api/sites/ticketportal/shows', ({params}, res) ->
    res.write "["
    cb = (link) -> 
      ticketportal
      .getPerformances(link)
      .then (show) -> res.write Buffer.from(JSON.stringify(show) + ",")

    new TicketportalSearcher()
    .run(cb)
    .then -> res.end("null]")

  app.get '/api/sites/ticketportal/shows/:show', ({params}, res) ->
    finish res, ticketportal.getPerformances params.show

  app.post '/api/sites/ticketportal/shows/:show/follow', authMiddleware, ({params}, res) ->
    finish res, ticketportal.getPerformances(params.show).then (it) -> Show.newTicketportal it

  # TUENTRADA
  app.get '/api/sites/tuentrada/shows', ({params}, res) ->
    res.write "["
    cb = (link) -> 
      tuentrada
      .getPerformances(link)
      .then (show) -> res.write Buffer.from(JSON.stringify(show) + ",")

    new TuentradaSearcher()
    .run(cb)
    .then -> res.end("null]")

  app.get '/api/sites/tuentrada/shows/:show', ({params}, res) ->
    finish res, tuentrada.getPerformances params.show

  app.post '/api/sites/tuentrada/shows/:show/follow', authMiddleware, ({params}, res) ->
    finish res, tuentrada.getPerformances(params.show).then (it) -> Show.newTuentrada it





  ## APP
  path = __dirname + "/app"
  app.set "views", path

  app.use express.static(__dirname + "/..") # node_modules
  app.use express.static(path)
  app.set "appPath", path

  app.get '/', authMiddleware, (req, res) -> res.sendFile "#{path}/app.html"

  app.get '/login', (req, res) => res.sendFile "#{path}/login.html"
  app.post '/login',
    passport.authenticate('local',
      successRedirect: '/'
      failureRedirect: '/login'
      session: true
    )

  port = config.port
  app.listen port, ->
    console.log "Listen port #{port}"
