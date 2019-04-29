mongoose = require('mongoose')
{ mongo } = require('../src/config')
telegram = require('../src/models/telegram')
Ticketek = require('../src/models/ticketek')
tuentrada = require('../src/models/tuentrada')

ticketek = new Ticketek()
  
xdescribe 'Shows', -> 
  
	it 'Ticketek should get performances', ->
    ticketek.getPerformances 'KANKA19NIC'
    .then console.log 

  it 'Tu Entrada should get performances', ->
    tuentrada.getPerformances '07F2362F-7825-4F28-88E2-F63DEDB44D2D'
    .then console.log 


Show = null
ticketekShow = null
tuentradaShow = null

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
    ] 
  }
]

tuentradaJson = [ { 
  name: 'PL - Anfiteatro Municipal, Rosario - Andres Calamaro - 30Nov',
  short_description: 'Andres Calamaro',
  start_date: 'sábado 30 de nov 2019 22:00 hs',
  availability_status: 'L',
  availability_num: '809',
  min_price: '$2.500,00',
  id: '07F2362F-7825-4F28-88E2-F63DEDB44D2D' 
}]


describe 'Telegram', -> 

  before ->
    this.timeout 5000
    mongoose
    .connect(mongo.uri, { useMongoClient: true })
    .then (db) -> 
      { Show } = require("../src/models/schemas")(db)
      Show.newTicketek(ticketekJson).then (show) -> ticketekShow = show
      Show.newTuentrada(tuentradaJson).then (show) -> tuentradaShow = show

  describe 'Telegram', -> 

    it 'should send messages for humans from Ticketek', ->
      telegram.forHumans ticketekShow
      .should.be.eql "KANKA19NIC - Martes 4/6  Pta 20:30Hs\nGRAL PTA 20:30 - AVAILABLE"
    
    it 'should send messages for humans from Tu Entrada', ->
      telegram.forHumans tuentradaShow
      .should.be.eql "PL - Anfiteatro Municipal, Rosario - Andres Calamaro - 30Nov - sábado 30 de nov 2019 22:00 hs\nQuedan 809 entradas disponibles"
