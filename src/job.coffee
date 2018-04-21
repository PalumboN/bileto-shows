ticketek = require('./models/ticketek')
telegram = require('./models/telegram')
{mapSeries} = Promise

update = (show) ->
  console.log "Saving changes"
  show.lastUpdate = new Date()
  show.save()

notFound = (show) ->
  show.archive = true
  show.save()
  throw "Delete show: #{show.name}"

sync = (show) ->
  console.log "Analizando: " + show.description
  result = {show}

  ticketek
  .getPerformances show.name
  .then (response) ->
    console.log {response}
    notFound show if response?.error?
    result.sync = _.isEqual response, show.toJSON().model
    show.model = response
  .then -> result
  .catch (err) ->
    console.log {err}
    result.error = err
    result
  .tap (result) ->
    telegram.sendShowChange result if not result.sync
  .tap ({show, error}) ->
    update show if not error

run = (shows) -> mapSeries shows, sync

module.exports =  { run }
