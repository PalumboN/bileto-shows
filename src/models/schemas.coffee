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
    enum: ["ticketek", "ticketportal"]
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
Show.statics.newTicketek = (model) ->
  this.create {
    model
    site: "ticketek"
    lastUpdate: new Date()
  }
Show.statics.newTicketportal = (model) ->
  this.create {
    model
    site: "ticketportal"
    lastUpdate: new Date()
  }

Show.virtual("date").get () -> this.model[0]?.date
Show.virtual("author").get () -> this.model[0]?.author
Show.virtual("place").get () -> this.model[0]?.place?.title
Show.virtual("id").get () -> this.model.id || this.name
Show.virtual("name").get () -> 
  this.model.name ||
  this.model[0].name
Show.virtual("description").get () -> 
  this.name + " - " + (this.model.description || this.author)

module.exports = (db) ->
  Show: db.model 'Show', Show
