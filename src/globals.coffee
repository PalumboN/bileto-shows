global._ = require('lodash')
global.include = (path) -> require "#{__dirname}/#{path}"
global.Promise = require('bluebird')

require('mongoose').Promise = Promise
Promise.promisifyAll require('request')
Promise.promisifyAll require('requestretry')
