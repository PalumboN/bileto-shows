global._ = require('lodash')
global.include = (path) -> require "#{__dirname}/#{path}"
global.Promise = require('bluebird')


Promise.promisifyAll require('request')
