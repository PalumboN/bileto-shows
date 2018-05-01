request = require('request')

baseUrl = "https://www.tuentrada.com/Online/default.asp?BOparam::WScontent::loadArticle::article_id="

mapTexts = ($, elems) -> elems.map((i, el) -> $(el).text()).get()

findScript = (body) ->
  scripts = _.split body, '<script type="text/javascript">'
  script = _.find scripts, (it) -> it.includes "articleContext"
  script = _.split script, '</script>', 1
  script[0]

getDataFromContext = ({searchNames, searchResults}) -> searchResults.map (it) -> _.zipObject searchNames, it

importantProperties =  (performance) -> _.pick performance, "name", "short_description", "start_date", "availability_status", "availability_num", "min_price"

getPerformances = (id) ->
    url = baseUrl + id 
    headers = "User-Agent": ""
    console.log "QUERING: " + url
    request
    .getAsync {url, headers}
    .then ({body}) -> body
    .then findScript
    .then (context) ->
        try eval context # TODO: Mejorar parseo y control de errores
        getDataFromContext articleContext
    .map importantProperties
    # .tap (it) -> console.log it

module.exports = { getPerformances }


