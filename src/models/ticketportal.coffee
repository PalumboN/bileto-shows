request = require('request')
cheerio = require('cheerio')

baseUrl = "http://lunapark.ticketportal.com.ar/eventperformances.asp?p="

mapTexts = ($, elems) -> elems.map((i, el) -> $(el).text()).get()

getPerformances = (id) ->
    request
    .getAsync baseUrl + id 
    .then ({body}) -> body
    .then (it) -> cheerio.load it
    .then ($) -> 
        name: $('h2').text()
        description: mapTexts($, $('.event-performances-description').contents().slice(1,4)).join(' ')
        performances: mapTexts $, $('.plPerformanceName')
    # .tap (it) -> console.log it

module.exports = { getPerformances }