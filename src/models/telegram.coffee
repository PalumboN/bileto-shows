request = require('request')
{telegram: {token, chatId}} = require('../config')

sectionString = ({description, full_price, section_availability}) ->
  "#{description} - $#{full_price}: #{section_availability}"

forHumans = ({show, sync, error}) ->
  text = "#{show.name} - #{show.date}\n"
  return text + error if error?
  text + show.sections.map(sectionString).join('\n')


sendMessage = (message) ->
  console.log "Enviando mensaje: " + message

  opts =
    method: "POST"
    uri: "https://api.telegram.org/bot#{token}/sendMessage"
    json: true
    body:
      chat_id: chatId
      text: message

  request
  .postAsync opts
  .then (res) ->
    console.log {res}


sendShowChange = (result) ->
  sendMessage "CAMBIÓ LA DISPONIBILIDAD DE\n" + forHumans result


module.exports = { sendShowChange }
