config = require('./config').mongo
mongoose = require('mongoose')
mongoose.connect(config.uri)
mongoose.Promise = require('bluebird')

Schema = mongoose.Schema
Mixed = Schema.Types.Mixed

Show = new Schema
  name:
    type: String
    required: true
  id:
    type: Number
    required: true
  author: String
  date: String
  sections: [
    id:
      type: Number
      required: true
    description: String
    section_availability: String
    full_price: String
    timestamp: Date
  ]

module.exports =
  Show: mongoose.model 'Show', Show
