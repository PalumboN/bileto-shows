require("coffee-script/register")
require('./src/globals')

const mongoose = require('mongoose')
const {mongo} = require('./src/config')
mongoose
  .connect(mongo.uri, { useMongoClient: true })
  .then((db) => require("./src/server")(db))
