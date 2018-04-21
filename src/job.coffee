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

  update = (section, tShow) ->
    console.log "Actualizando sección: " + section.description
    tSection  = findSection(tShow, section)
    _.assign(section, tSection)

  save = (show) ->
    console.log "Saving changes"
    show.sections.forEach (it) -> it.timestamp = new Date()
    show.save()

  notFound = (show) ->
    show.archive = true
    show.save()
    throw "Delete show: #{show.name}"

  sync = (show) ->
    description = "#{show.name} - #{show.date}"
    console.log "Analizando: " + description
    result = {show}

    ticketek
    .getPerformances show.name
    .then (tShows) ->
      tShow = _.find tShows, { id: show.id }
      notFound show if _.isEmpty tShow
      result.sync = _.every show.sections, (it) -> isSync it, tShow
      show.sections.forEach (it) -> update it, tShow
    .then -> result
    .catch (err) ->
      console.log {err}
      result.error = err
      result
    .tap (result) ->
      telegram.sendShowChange result if not result.sync
    .tap ({show, error}) ->
      console.log error
      save show if not error

  run = ->
    Show
    .findOpen()
    .then (shows) -> mapSeries shows, sync

  return { run }
