_ = require('lodash')
{Show} = require('./schemas')
ticketek = require('./ticketek')
telegram = require('./telegram')
{mapSeries} = require('bluebird')


isSync = (section, tShow) ->
  console.log "Buscando sección: " + section.description
  tSection  = _.find tShow.sections, { id: section.id }
  tSection.section_availability == section.section_availability

sync = (section, tShow) ->
  console.log "Actualizando sección: " + section.description
  tSection  = _.find tShow.sections, { id: section.id }
  section.section_availability = tSection.section_availability

save = (show) ->
  show.sections.forEach (it) -> it.timestamp = new Date()
  Show.update { _id: show._id }, show

update = (show) ->
  description = "#{show.name} - #{show.date}"
  console.log "Analizando: " + description
  result = {show}

  ticketek
  .getPerformances show.name
  .then (tShows) ->
    tShow = _.find tShows, { id: show.id }
    result.sync = _.every show.sections, (it) -> isSync it, tShow
    if not result.sync
      show.sections.forEach (it) -> sync it, tShow
  .then -> result
  .catch (err) ->
    console.log {err}
    result.error = err
    result

run = ->
  Show
  .find()
  .then (shows) ->
    mapSeries shows, update
  .tap (results) ->
    telegram.sendResults results if not _.every results, "sync"
  .tap (results) ->
    mapSeries results, ({show}) -> save show

module.exports = { run }
