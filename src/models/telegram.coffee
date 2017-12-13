request = require('request')
{telegram} = require('../config')
token = telegram.token

forHumans = ({show, sync, error}) ->
  if error?
    status = error
  else
    status = if sync then "OK" else "CHANGED"

  "#{show.name} - #{show.date}: #{status}"

sendMessage = (message) ->
  opts =
    method: "POST"
    uri: "https://api.telegram.org/bot#{token}/sendMessage"
    json: true
    body:
      chat_id: 303722247
      text: message

  request.postAsync opts


sendResults = (results) ->
  sendMessage "RESULTADO DE LA CORRIDA:\n" + results.map(forHumans).join('\n')


module.exports = { sendResults }
