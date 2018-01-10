request = require('request')
{ticketek} = require('../config')
rp = Promise.promisify request

baseUrl = "https://www.ticketek.com.ar"


login = ->
  jar = request.jar()
  url = "#{baseUrl}/websource/auth/login/"
  request
  .postAsync url, {
    form:
      login: ticketek.login
      password: ticketek.password
    jar
  }
  .then (response) ->
    cookies = jar.getCookies url
    cookies[0].value


makeShowURI = (show) -> "#{baseUrl}/websource/show/#{show}/"
makeShowRequest = (show) ->
  login().then (sessionid) ->
    jar = request.jar()
    cookie = request.cookie("sessionid=#{sessionid}")
    url = makeShowURI show
    console.log url
    jar.setCookie(cookie, url)
    rp {url, jar}


parseScript = (body) ->
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
      eval parseScript body
      try
        json_context
      catch error
        throw "'json_context' not found"
      toPerformances json_context
