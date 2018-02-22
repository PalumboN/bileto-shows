module.exports = (db) ->
  {Show} = require('./models/schemas')(db)
  ticketek = require('./models/ticketek')
  telegram = require('./models/telegram')
  {mapSeries} = Promise

  findSection = ({sections}, {id, description, full_price}) ->
    _.find(sections, { id }) || _.find(sections, { description, full_price })

  isSync = (section, tShow) ->
    console.log "Buscando sección: " + section.description, section.id
    tSection  = findSection(tShow, section)
    tSection.section_availability == section?.section_availability

  sync = (section, tShow) ->
    console.log "Actualizando sección: " + section.description
    tSection  = findSection(tShow, section)
    _.assign(section, tSection)

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
      show.sections.forEach (it) -> sync it, tShow
    .then -> result
    .catch (err) ->
      console.log {err}
      result.error = err
      result

  run = ->
    Show
    .findOpen()
    .map (shows) ->
      mapSeries shows, update
    .tap (results) ->
      results.filter(({sync, error}) -> not sync and not error).forEach(telegram.sendShowChange)
    .tap (results) ->
      mapSeries(results.filter(({error}) -> not error), ({show}) -> save show)

  return { run }
