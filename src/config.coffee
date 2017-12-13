module.exports =
  port: process.env.PORT || 8083
  mongo:
    uri: process.env.MONGODB_URI or 'mongodb://localhost:27017/bileto-shows'
  ticketek:
    sessionid: process.env.TICKETEK_SESSION_ID or '49oe2ih8h253rs6e25ab0zw70e93eyak'
  telegram:
    token: process.env.TELEGRAM_TOKEN or '449934196:AAHyKsNcwpDDhvvnxCipCJVM38FNq3H_a5Q'
