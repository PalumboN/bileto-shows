# request = require('request') 
request = require('requestretry')
cheerio = require('cheerio')

baseUrl = "http://lunapark.ticketportal.com.ar/eventperformances.asp?p="

mapTexts = ($, elems) -> elems.map((i, el) -> $(el).text()).get()

getPerformances = (id) ->
    url = baseUrl + id 
    console.log "QUERING: " + url
    request
    .getAsync url
    .then ({body}) -> body
    .then (it) -> cheerio.load it
    .then ($) -> 
        {
            id
            name: $('h2').text()
            description: mapTexts($, $('.event-performances-description').contents().slice(1,4)).join(' ')
            performances: mapTexts $, $('.plPerformanceName')
        }
    # .tap (it) -> console.log it

module.exports = { getPerformances }