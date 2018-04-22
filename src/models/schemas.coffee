mongoose = require('mongoose')
Schema = mongoose.Schema
Mixed = Schema.Types.Mixed

Show = new Schema
  model:
    type: Mixed
    required: true
  archive:
    type: Boolean
    required: true
    default: false
  site:
    type: String
    required: true
    enum: ["ticketek", "tuentrada"]
  lastUpdate:
    type: Date
    required: true

Show.statics.findOpen = -> this.find archive: false
Show.statics.findArchive = -> this.find archive: true
Show.statics.newTicketek = (model) ->
  this.create {
    model
    site: "ticketek"
    lastUpdate: new Date()
  }
Show.statics.newTuentrada = (model) ->
  this.create {
    model
    site: "tuentrada"
    lastUpdate: new Date()
  }

Show.virtual("name").get () -> this.model[0].name
Show.virtual("date").get () -> this.model[0].date
Show.virtual("description").get () -> this.name + " - " + this.date

module.exports = (db) ->
  Show: db.model 'Show', Show
