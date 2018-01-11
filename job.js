require("coffee-script/register")
require('./src/globals')
require("./src/job").run().then(() => process.exit(0)).catch((error) => {console.log(error); process.exit(-1)})
