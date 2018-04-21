require("coffee-script/register")
require('./src/globals')

const mongoose = require('mongoose')
const {mongo} = require('./src/config')
mongoose
  .connect(mongo.uri, { useMongoClient: true })
  .then((db) => {
    require("./src/searcher")(db)
    // return require("./src/job")(db).run()
  })
  // .then(() => process.exit(0))
  // .catch((error) => {console.log(error); process.exit(-1)})
