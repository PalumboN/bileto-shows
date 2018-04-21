module.exports = (db) ->
  express = require('express')
  session = require('express-session')
  passport = require('passport')
  bodyParser = require('body-parser')
  syncer = require('./job')
  config = require('./config')
  {Show} = require('./models/schemas')(db)
  Ticketek = require('./models/ticketek')
  searcher = require('./searcher')

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
  app.get '/shows', authMiddleware, (req, res) ->
    finish res, Show.findOpen()

  app.get '/shows/archive', authMiddleware, (req, res) ->
    finish res, Show.findArchive()

  app.post '/shows', authMiddleware, ({body}, res) ->
    finish res, Show.create body

  app.delete '/shows/:job', authMiddleware, ({params}, res) ->
    finish res, Show.findByIdAndUpdate(params.job, archive: true)

  app.post '/shows/reopen/:job', authMiddleware, ({params}, res) ->
    finish res, Show.findByIdAndUpdate(params.job, archive: false)


  app.post '/shows/sync', (req, res) ->
    finish res, Show.findOpen().then syncer.run


  app.get '/sites/ticketek/shows', ({params}, res) ->
    finish res, searcher().map (show) -> ticketek.getPerformances show

  app.get '/sites/ticketek/shows/:show', ({params}, res) ->
    finish res, new Ticketek().getPerformances params.show

  app.post '/sites/ticketek/shows/:show/import', ({params}, res) ->
    finish res, new Ticketek().getPerformances(params.show).then (it) -> Show.newTicketek it





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
