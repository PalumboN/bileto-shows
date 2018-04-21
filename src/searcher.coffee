request = require('request')
cheerio = require('cheerio')
ticketek = require('./models/ticketek')

base = "https://www.ticketek.com.ar"

shows = []
visited = []

analizeShowLink = (link) =>
  if _.includes link, "websource/show"
    shows.push _.last _.compact _.split(link, "/")
  else
    analizeShow link if link != "/" and link.startsWith("/")

analizeShow = (link, clazz = null) =>
  return if _.includes visited, link
  visited.push link
  console.log visited.length, "LINKS ANALIZADOS"
  inspectLinksIn(link, clazz)
  .then (it) =>
    ps = []
    it.each((i, href) => ps.push(analizeShowLink href))
    Promise.all ps

inspectLinksIn = (resource, clazz = null) =>
  request
  .getAsync(base + resource)
  .then(({body}) => cheerio.load(body))
  .then(($) => $('a', clazz).map((i, el) => $(el).attr("href")))


module.exports = () ->
  analizeShow("/buscar", ".artists-list-item")
  .tap -> console.log "*********FINISH*********"
  .then (it) => shows
