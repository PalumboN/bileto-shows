Ticketek = require('../src/models/ticketek')
tuentrada = require('../src/models/tuentrada')

ticketek = new Ticketek()
  
describe 'Shows', -> 
  
	it 'Ticketek should get performances', ->
    ticketek.getPerformances 'KANKA19NIC'
    .then console.log 

  it 'Tu Entrada should get performances', ->
    tuentrada.getPerformances '07F2362F-7825-4F28-88E2-F63DEDB44D2D'
    .then console.log 


describe 'Telegram', -> 
  
	it 'should send messages for humans', ->
    ticketek.getPerformances 'KANKA19NIC'
    .then console.log 
