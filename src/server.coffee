module.exports = (db) ->
  express = require('express')
  session = require('express-session')
  passport = require('passport')
  bodyParser = require('body-parser')
  job = require('./job')
  config = require('./config')
  {Show} = require('./models/schemas')(db)
  ticketek = require('./models/ticketek')
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


  ## JOBS
  app.get '/jobs', authMiddleware, (req, res) ->
    finish res, Show.findOpen()

  app.get '/jobs/archive', authMiddleware, (req, res) ->
    finish res, Show.findArchive()

  app.post '/jobs', authMiddleware, ({body}, res) ->
    finish res, Show.create body

  app.delete '/jobs/:job', authMiddleware, ({params}, res) ->
    finish res, Show.findByIdAndUpdate(params.job, archive: true)

  app.post '/jobs/reopen/:job', authMiddleware, ({params}, res) ->
    finish res, Show.findByIdAndUpdate(params.job, archive: false)

  ## SHOWS
  app.post '/jobs/run', (req, res) ->
    finish res, job(db).run()


  app.get '/shows/ticketek', ({params}, res) ->
    finish res, searcher().map (show) -> ticketek.getPerformances show

  app.get '/shows/ticketek/:show', ({params}, res) ->
    finish res, ticketek.getPerformances params.show


  ## PING
  app.get '/ping', (req, res) ->  res.send("pong")


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
