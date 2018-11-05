# request = require('request') 
request = require('requestretry')
cheerio = require('cheerio')

class Searcher
  constructor: (@base) ->
    @shows = []
    @visited = []

  normalize: (link) => if link.startsWith("/") then link else "/" + link

  shouldAnalize: (link) => link.startsWith("/") or link.startsWith(@base)

  analizeShowLink: (cb, link) =>
    if @_isShowLink link
      show = @_data link
      @shows.push show
      cb show
    else
      @analizeShow cb, @normalize(link) if @shouldAnalize link

  analizeShow: (cb, link, clazz = null) =>
    return Promise.resolve() if _.includes @visited, link
    @visited.push link
    console.log @visited.length, "LINKS ANALIZADOS"
    @inspectLinksIn(link, clazz)
    .then (it) =>
      ps = []
      it.each((i, href) => ps.push(@analizeShowLink cb, href))
      Promise.all ps

  inspectLinksIn: (resource, clazz = null) =>
    url = if resource.startsWith(@base) then resource else @base + resource
    headers = "User-Agent": ""
    console.log "QUERING: " + url
    request
    .getAsync {url, headers}
    # .tap ({statusCode}) -> console.log statusCode
    .then(({body}) => cheerio.load(body))
    .then(($) => $('a', clazz).map((i, el) => $(el).attr("href")))


  run: (cb) =>
    @_start cb
    .tap => console.log "*********FINISH*********"
    .then (it) => @shows

  _isShowLink : (link) => throw "Implement abstract method"
  _data : (link) => throw "Implement abstract method"

  _start: (cb) => @analizeShow(cb, "/")

module.exports.TicketekSearcher =
class TicketekSearcher extends Searcher

  constructor: () -> super("https://www.ticketek.com.ar")

  _isShowLink : (link) => _.includes link, "websource/show"
  _data : (link) => _.last _.compact _.split(link, "/")

  _start: (cb) => @analizeShow(cb, "/buscar", ".artists-list-item")

module.exports.TicketportalSearcher =
class TicketportalSearcher extends Searcher

  constructor: () -> super("http://www.ticketportal.com.ar")
  
  _isShowLink : (link) => _.includes link, "eventperformances"
  _data : (link) => _.last _.compact _.split(link, "=")



module.exports.TuentradaSearcher =
class TuentradaSearcher extends Searcher

  constructor: () -> super("https://www.tuentrada.com/Online")
  
  _isShowLink : (link) => _.includes link, "article_id"
  _data : (link) => _.last _.compact _.split(link, "=")
