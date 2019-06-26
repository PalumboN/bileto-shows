request = require('request')
{telegram: {token, chatId}} = require('../config')

forHumans = (show) -> show.alerts.join "\n"

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
  .then ({body}) ->
    # console.log body
    throw "telegram_error: #{body.description} - #{body.error_code}" if not body.ok


sendShowChange = (show) ->
  sendMessage forHumans(show) if show.shouldAlert

sendError = (error) ->
  sendMessage "ERROR\n" + error

module.exports = {
  sendShowChange
  sendError
  forHumans
 }
