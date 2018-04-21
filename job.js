require("coffee-script/register")
require('./src/globals')
const request = require('request')

const base = process.env.SELF || "https://bileto-shows.herokuapp.com"
const uri = base + "/api/shows/sync"

console.log("QUERING: " + uri);

request
.postAsync(uri)
.then(({body, statusCode}) => { console.log({body, statusCode}); process.exit(0)})
.catch((error) => {console.log({error}); process.exit(-1)})
