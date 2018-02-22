request = require('request')
cheerio = require('cheerio')
ticketek = require('./models/ticketek')

base = "https://www.ticketek.com.ar"

module.exports = (db) ->
  {Show} = require('./models/schemas')(db)
  visited = []

  importShow = (name) =>
    Show
    .findOne({name})
    .then (show) =>
      if _.isEmpty show
        ticketek
        .getPerformances name
        .then (performances) => Show.create performances

  analizeShowLink = (link) =>
    if _.includes link, "websource/show"
      importShow _.last _.compact _.split(link, "/")
    else
      analizeShow link if link != "/" and link.startsWith("/")

  analizeShow = (link) =>
    return if _.includes visited, link
    visited.push link
    console.log visited.length, "SITIOS VISITADOS"
    inspectLinksIn(link)
    .then((it) => it.each((i, href) => analizeShowLink href))

  inspectLinksIn = (resource, clazz = null) =>
    request
    .getAsync(base + resource)
    .then(({body}) => cheerio.load(body))
    .then(($) => $('a', clazz).map((i, el) => $(el).attr("href")))


  inspectLinksIn("/buscar", ".artists-list-item")
  .then((it) => it.each((i, href) => analizeShow href))

  # guasones = "/guasones/sala-de-las-artes"
  # inspectLinksIn(guasones)
  # .then((it) => it.filter((i, el) => _.includes(el, "websource/show")))
  # .then(($) => $('a.comprar').attr("href"))
