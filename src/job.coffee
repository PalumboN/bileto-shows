Ticketek = require('./models/ticketek')
telegram = require('./models/telegram')
{mapSeries} = Promise

analiseError = ({show}, {error, statusCode}) ->
  if statusCode == 404
    show.archive = true
    show.save()
  throw error

update = (show) ->
  console.log "Saving changes"
  show.lastUpdate = new Date()
  show.save()

doSync = (result, response) ->
  result.sync = _.isEqual response, result.show.toJSON().model
  result.show.model = response

sync = (show) ->
  console.log "Analizando: " + show.description
  result = {show}

  new Ticketek()
  .getPerformances show.name
  .then (response) ->
    console.log {response}
    analiseError result, response if response?.error?
    doSync result, response
  .then -> result
  .catch (err) ->
    console.log {err}
    result.error = err
    result
  .tap ({show, sync, error}) ->
    return telegram.sendError error if error?
    return telegram.sendShowChange show if not sync
  .tap ({show, error}) ->
    update show if not error

run = (shows) -> mapSeries shows, sync

module.exports =  { run }
