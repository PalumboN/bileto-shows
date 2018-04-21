Ticketek = require('./models/ticketek')
telegram = require('./models/telegram')
{mapSeries} = Promise

update = (show) ->
  console.log "Saving changes"
  show.lastUpdate = new Date()
  show.save()

notFound = (show) ->
  throw "show_not_found: #{show.name}"

sync = (show) ->
  console.log "Analizando: " + show.description
  result = {show}

  new Ticketek()
  .getPerformances "show.name"
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
  .tap ({show, sync, error}) ->
    return telegram.sendError error if error?
    telegram.sendShowChange show if not sync
  .tap ({show, error}) ->
    update show if not error

run = (shows) -> mapSeries shows, sync

module.exports =  { run }
