mongoose = require('mongoose')
{maxFailures} = require('../config')

Schema = mongoose.Schema
Mixed = Schema.Types.Mixed
mongoose.plugin (schema) -> schema.options.usePushEach = true

Show = new Schema
  model:
    type: Mixed
    required: true
  alertIds:
    type: [String]
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
  failures:
    type: [String]
    default: []
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

Show.virtual("date").get () -> this.model[0]?.date || this.model[0]?.start_date
Show.virtual("author").get () -> this.model[0]?.author
Show.virtual("place").get () -> this.model[0]?.place?.title
Show.virtual("id").get () -> this.model.id || if (this.site == "tuentrada") then this.model[0]?.id else this.name
Show.virtual("name").get () -> 
  this.model.name ||
  this.model[0]?.name
Show.virtual("description").get () -> 
  this.name + " - " + (this.model.description || this.author || "")
Show.virtual("isBroken").get () ->
  this.failures?.length > maxFailures


Show.virtual("shouldAlert").get () -> !_.isEmpty this.alerts
Show.virtual("alerts").get () -> this.strategy.alerts(this)

Show.virtual("tickets").get () -> this.strategy.tickets(this)
Show.virtual("followingTickets").get () -> this.tickets.filter(({id}) => this.alertIds.includes(id))


Show.virtual("strategy").get () -> 
  switch this.site
    when "ticketek" then new TicketekShow()
    when "tuentrada" then new TuentradaShow()



class TicketekShow
  tickets: ({model}) =>
    _.flatMap model, (oneModel) =>
      oneModel.sections.map (section) =>
        this._toTicket oneModel, section

  alerts: (show) =>
    _.map _.groupBy(show.followingTickets, "name"), (sectionTickets) =>
      sectionTickets[0].name + " - " + sectionTickets[0].date + "\n" +
      sectionTickets
      .map ({section, availability, price}) -> "#{section} ($#{price}) - #{availability}"
      .join('\n')

  _toTicket: (oneModel, section) =>
    {
      id: oneModel.id.toString() + section.id.toString()
      name: oneModel.name + ' - ' + oneModel.author
      date: oneModel.date
      section: section.description
      price: section.full_price
      availability: section.section_availability
    }


class TuentradaShow
  tickets: ({model}) =>
    _.map model, (oneModel) =>
      {
        id: oneModel.id
        name: oneModel.name
        date: oneModel.start_date
        section: 'UNICA'
        price: oneModel.min_price
        availability: oneModel.availability_num
      }

  isTriggered: (availability) -> Number.parseInt(availability) < 50
  isCritical: (availability) -> Number.parseInt(availability) < 10

  alerts: (show) =>
    show
    .followingTickets
    .filter ({availability}) => this.isTriggered availability
    .map ({name, availability, price}) => 
      "#{name} (#{price}) - Quedan #{availability} entradas disponibles #{if (this.isCritical availability) then '- ¡PAUSAR EVENTO!' else ''}"




module.exports = (db) ->
  Show: db.model 'Show', Show
