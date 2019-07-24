Ticketek = require('./models/ticketek')
tuentrada = require('./models/tuentrada')
ticketportal = require('./models/ticketportal')
telegram = require('./models/telegram')
{mapSeries} = Promise

getApi = ({site}) ->
  switch site
    when 'ticketek' then new Ticketek()
    when 'ticketportal' then ticketportal
    when 'tuentrada' then tuentrada

analiseError = ({show}, {error, statusCode}) ->
  if not show.failures then show.failures = []  
  show.failures.push error
  show.save()
  throw error

update = (show) ->
  console.log "Saving changes"
  show.lastUpdate = new Date()
  show.save()

doSync = (result, response) -> #TODO: Sacar a un objeto y testear
  if (_.isEmpty response)
    throw "Empty response"
  console.log "SYNCING"
  result.sync = not _.isEqual response, result.show.toJSON().model
  result.show.model = response
  result.show.failures = []

isHeroku = (error) -> error.toString().includes("TypeError")

sync = (apiResolver, messageSender) -> (show) ->
  console.log "Analizando: " + show.description
  result = {show}
  if (show.isBroken)
    console.log "Broken show, skiping..."
    result.skip = true
    return Promise.resolve result

  apiResolver show
  .getPerformances show.id
  .then (response) ->
    console.log "Before SYNC", {response}
    analiseError result, response[0] if response?[0]?.error?
    doSync result, response
  .then -> result
  .catch (err) ->
    console.log {err}
    result.error = err
    result
  .tap ({show, sync, error}) ->
    return messageSender.sendError error if error? and not isHeroku(error)
    return messageSender.sendShowChange show if sync
  .tap ({show, error}) ->
    update show if not error

run = (shows, apiResolver = getApi, messageSender = telegram) -> shows.map sync(apiResolver, messageSender)

module.exports =  { run }
