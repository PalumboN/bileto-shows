# request = require('request') 
request = require('requestretry')
cheerio = require('cheerio')

class Searcher
  shows: []
  visited: []

  constructor: (@base) ->

  normalize: (link) => if link.startsWith("/") then link else "/" + link

  analizeShowLink: (link) =>
    if @_isShowLink link
      @shows.push @_data link
    else
      @analizeShow @normalize(link) 

  analizeShow: (link, clazz = null) =>
    return Promise.resolve() if _.includes @visited, link
    @visited.push link
    console.log @visited.length, "LINKS ANALIZADOS"
    @inspectLinksIn(link, clazz)
    .then (it) =>
      ps = []
      it.each((i, href) => ps.push(@analizeShowLink href))
      Promise.all ps

  inspectLinksIn: (resource, clazz = null) =>
    url = @base + resource
    headers = "User-Agent": ""
    console.log "QUERING: " + url
    request
    .getAsync {url, headers}
    .tap ({statusCode}) -> console.log statusCode
    .then(({body}) => cheerio.load(body))
    .then(($) => $('a', clazz).map((i, el) => $(el).attr("href")))

  _isShowLink : (link) => throw "Implement abstract method"
  _data : (link) => throw "Implement abstract method"



module.exports.TicketekSearcher =
class TicketekSearcher extends Searcher

  constructor: () -> super("https://www.ticketek.com.ar")

  _isShowLink : (link) => _.includes link, "websource/show"
  _data : (link) => _.last _.compact _.split(link, "/")

  run: () =>
    @analizeShow("/buscar", ".artists-list-item")
    .tap => console.log "*********FINISH*********"
    .then (it) => @shows



module.exports.TicketportalSearcher =
class TicketportalSearcher extends Searcher

  constructor: () -> super("http://www.ticketportal.com.ar")
  
  _isShowLink : (link) => _.includes link, "eventperformances"
  _data : (link) => _.last _.compact _.split(link, "=")

  run: () =>
    @analizeShow("/")
    .tap => console.log "*********FINISH*********"
    .then (it) => @shows


module.exports.TuentradaSearcher =
class TuentradaSearcher extends Searcher

  constructor: () -> super("https://www.tuentrada.com/Online")
  
  _isShowLink : (link) => _.includes link, "article_id"
  _data : (link) => _.last _.compact _.split(link, "=")

  run: () =>
    @analizeShow("/")
    .tap => console.log "*********FINISH*********"
    .then (it) => @shows