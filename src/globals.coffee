{promisifyAll} = require('bluebird')
promisifyAll require('request')


global.include = (path) -> require "#{__dirname}/#{path}"
