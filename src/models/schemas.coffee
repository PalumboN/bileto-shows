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
    enum: ["ticketek", "ticketportal", "tuentrada"]
  lastUpdate:
    type: Date
    required: true
,
  toObject:
    virtuals: true
  toJSON:
    virtuals: true

    
Show.statics.findOpen = -> this.find archive: false
Show.statics.findArchive = -> this.find archive: true
Show.statics.newTicketek = (model) -> this.newShow model, "ticketek"
Show.statics.newTuentrada = (model) -> this.newShow model, "tuentrada"
Show.statics.newTicketportal = (model) -> this.newShow model, "ticketportal"
Show.statics.newShow = (model, site) ->
  this.create {
    model
    site
    lastUpdate: new Date()
  }

Show.virtual("date").get () -> this.model[0]?.date
Show.virtual("author").get () -> this.model[0]?.author
Show.virtual("place").get () -> this.model[0]?.place?.title
Show.virtual("id").get () -> this.model.id || this.model[0]?.id || this.name
Show.virtual("name").get () -> 
  this.model.name ||
  this.model[0]?.name
Show.virtual("description").get () -> 
  this.name + " - " + (this.model.description || this.author || "")

module.exports = (db) ->
  Show: db.model 'Show', Show
