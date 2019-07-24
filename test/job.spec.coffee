mongoose = require('mongoose')
{ mongo } = require('../src/config')
telegram = require('../src/models/telegram')
Ticketek = require('../src/models/ticketek')
tuentrada = require('../src/models/tuentrada')
{ run } = require('../src/job')
{ ApiMock, TelegramMock } = require('./mocks')

ticketek = new Ticketek()
  
xdescribe 'GET shows', -> 
  
	it 'Ticketek should get performances', ->
    ticketek.getPerformances 'KANKA19NIC'
    .then console.log 

  it 'Tu Entrada should get performances', ->
    tuentrada.getPerformances '07F2362F-7825-4F28-88E2-F63DEDB44D2D'
    .then console.log 


Show = null
ticketekShow = null
tuentradaShow = null
notFollowTuentradaShow = null

ticketekJson = [
  { 
    name: 'KANKA19NIC',
    id: 31750,
    place: { 
      city: 'Palermo',
      state: 'Capital Federal',
      address: 'Av Cnel. Niceto Vega 5510',
      title: 'Niceto Club' 
    },
    author: 'EL KANKA',
    date: 'Martes 4/6  Pta 20:30Hs',
    description: 'Martes 4/6  Pta 20:30Hs',
    sections: [
      {
        "id":723313,
        "description":"GRAL PTA 20:30",
        "section_availability":"AVAILABLE",
        "full_price":"700.00"
      }
    ],
    archive: true
  }
]

tuentradaJson = [ { 
  availability_num: "100"
  availability_status: "S"
  id: "44AB5CE3-3A7D-41D2-9145-26FA51B8012A"
  min_price: "$950,00"
  name: "El Teatro Flores - Divididos - 20Jun2019"
  short_description: "Divididos"
  start_date: "jueves 20 de jun 2019 21:00 hs"
}, {
  availability_num: "30"
  availability_status: "S"
  id: "44AB5CE3-3A7D-41D2-9145-26FA51B8012B"
  min_price: "$950,00"
  name: "El Teatro Flores - Divididos - 21Jun2019"
  short_description: "Divididos"
  start_date: "viernes 21 de jun 2019 21:00 hs"
}, {
  availability_num: "5"
  availability_status: "S"
  id: "44AB5CE3-3A7D-41D2-9145-26FA51B8012C"
  min_price: "$950,00"
  name: "El Teatro Flores - Divididos - 22Jun2019"
  short_description: "Divididos"
  start_date: "viernes 22 de jun 2019 21:00 hs"
}]

notFollowTuentradaJson = [ {
  availability_num: "30"
  availability_status: "S"
  id: "44ABAAAA-3A7D-41D2-9145-26FA51B8012B"
  min_price: "$950,00"
  name: "El Teatro Flores - Los Piojos - 21Jun2019"
  short_description: "Los Piojos"
  start_date: "viernes 21 de jun 2019 21:00 hs"
}, {
  availability_num: "5"
  availability_status: "S"
  id: "44ABAAAA-3A7D-41D2-9145-26FA51B8012C"
  min_price: "$950,00"
  name: "El Teatro Flores - Los Piojos - 22Jun2019"
  short_description: "Los Piojos"
  start_date: "viernes 22 de jun 2019 21:00 hs"
}]

describe 'Model', -> 

  beforeEach ->
    this.timeout 5000
    mongoose
    .connect(mongo.uri, { useMongoClient: true })
    .then (db) -> 
      { Show } = require("../src/models/schemas")(db)
      Show.newTicketek(ticketekJson).then (show) -> 
        ticketekShow = show
        ticketekShow.alertIds = _.map ticketekShow.tickets, "id"

      Show.newTuentrada(tuentradaJson).then (show) -> 
        tuentradaShow = show
        tuentradaShow.alertIds = _.map tuentradaShow.tickets, "id"

      Show.newTuentrada(notFollowTuentradaJson).then (show) -> 
        notFollowTuentradaShow = show

  after ->
    mongoose
    .connect(mongo.uri, { useMongoClient: true })
    .then (db) -> 
      { Show } = require("../src/models/schemas")(db)
      Show.remove {}

  describe 'Ticketek', ->

    it 'trasform to tickets', ->
      ticketekShow.tickets
      .should.be.eql [
        {
          id: '31750723313'
          name: 'KANKA19NIC - EL KANKA'
          date: 'Martes 4/6  Pta 20:30Hs'
          section: 'GRAL PTA 20:30'
          price: '700.00'
          availability: 'AVAILABLE'
        }
      ]

  describe 'TuEntrada', ->

    it 'trasform to tickets', ->
      tuentradaShow.tickets
      .should.be.eql [
        {
          id: '44AB5CE3-3A7D-41D2-9145-26FA51B8012A'
          name: 'El Teatro Flores - Divididos - 20Jun2019'
          date: 'jueves 20 de jun 2019 21:00 hs'
          section: 'UNICA'
          price: '$950,00'
          availability: '100'
        },
        {
          id: '44AB5CE3-3A7D-41D2-9145-26FA51B8012B'
          name: 'El Teatro Flores - Divididos - 21Jun2019'
          date: 'viernes 21 de jun 2019 21:00 hs'
          section: 'UNICA'
          price: '$950,00'
          availability: '30'
        },
        {
          id: '44AB5CE3-3A7D-41D2-9145-26FA51B8012C'
          name: 'El Teatro Flores - Divididos - 22Jun2019'
          date: 'viernes 22 de jun 2019 21:00 hs'
          section: 'UNICA'
          price: '$950,00'
          availability: '5'
        }
      ]

  describe 'Telegram', -> 

    it 'transform alerts for humans from Ticketek', ->
      telegram.forHumans ticketekShow
      .should.be.eql "KANKA19NIC - EL KANKA - Martes 4/6  Pta 20:30Hs\nGRAL PTA 20:30 ($700.00) - AVAILABLE"
    
    it 'transform alerts for humans from Tu Entrada', ->
      telegram.forHumans tuentradaShow
      .should.be.eql "El Teatro Flores - Divididos - 21Jun2019 ($950,00) - Quedan 30 entradas disponibles \nEl Teatro Flores - Divididos - 22Jun2019 ($950,00) - Quedan 5 entradas disponibles - ¡PAUSAR EVENTO!"

    it 'should alert for Ticketek', ->
      ticketekShow.shouldAlert
      .should.be.true
    
    it 'should alert for Tu Entrada', ->
      tuentradaShow.shouldAlert
      .should.be.true

    it 'should only alert for following tickets', ->
      notFollowTuentradaShow.shouldAlert
      .should.be.false

  describe 'Job', -> 
    runJob = (params = {}) -> 
      run([tuentradaShow, ticketekShow], (() -> new ApiMock(params)), new TelegramMock())

    validateFailures = (count) ->
        _([tuentradaShow, ticketekShow]) 
        .map 'failures'
        .map 'length'
        .value()
        .should.be.eql [count, count]

    setFailures = (failures) ->
      [tuentradaShow, ticketekShow].forEach (show) -> show.failures = failures


    beforeEach ->
      setFailures ["ERROR"]

    it 'should sync', ->
      Promise.all runJob()
      .tap (results) -> 
        _.every results, 'sync'
        .should.be.true

    it 'on sync should clean errors', ->
      Promise.all runJob()
      .tap (results) -> validateFailures 0

    it 'on error should not sync', ->
      Promise.all runJob({ shouldError: true })
      .tap (results) -> 
        _.every results, 'sync'
        .should.be.false

    it 'on error should remember', ->
      Promise.all runJob({ shouldError: true })
      .tap (results) -> validateFailures 2

    it 'should skip for broken shows', ->
      setFailures _.times(100, "ERROR")
      Promise.all runJob({ shouldError: true })
      .tap (results) -> 
        _.every results, 'skip'
        .should.be.true
