_ = require('lodash')
request = require('request')
Promise = require('bluebird')
{ticketek} = require('./config')
rp = Promise.promisify request



makeShowURI = (show) -> "http://www.ticketek.com.ar/websource/show/#{show}/"

makeShowRequest = (show) ->
  jar = request.jar()
  cookie = request.cookie("sessionid=#{ticketek.sessionid}")
  url = makeShowURI show
  console.log url
  jar.setCookie(cookie, url)
  rp {url, jar}


getScript = (body) ->
  scripts = _.split body, '<script type="text/javascript">'
  script = _.find scripts, (it) -> it.includes "json_context"
  script = _.split script, '</script>', 1
  script[0]

toCategoryString = (category) => category.description + '($' + category.full_price + ') - ' + category.section_availability

importantData = (performace) =>
  prices = performace["price-types"]
  {
    id: performace.id
    place: performace.venue
    author: performace.who
    date: performace.when
    description: performace.desc
    sections: prices[0]
      .price_categories
      .map (it) => _.pick it, "id", "description", "section_availability", "full_price"
  }

toPerformances = ({performances}) =>
  Object.values performances
  .filter (it) => it != undefined
  .map importantData


module.exports =
  getPerformances: (show) ->
    makeShowRequest show
    .then ({body}) =>
      eval getScript body
      toPerformances json_context
