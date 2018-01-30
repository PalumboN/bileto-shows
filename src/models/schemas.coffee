mongoose = require('mongoose')
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
  archive:
    type: Boolean
    required: true
    default: false

module.exports = (db) ->
  Show: db.model 'Show', Show
