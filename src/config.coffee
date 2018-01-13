module.exports =
  port: process.env.PORT || 8083
  mongo:
    uri: process.env.MONGODB_URI or 'mongodb://localhost:27017/bileto-shows'
  ticketek:
    login: process.env.TICKETEK_LOGIN
    password: process.env.TICKETEK_PASSWORD
  telegram:
    token: process.env.TELEGRAM_TOKEN
    chatId: process.env.TELEGRAM_CHAT_ID
