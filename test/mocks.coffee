module.exports.ApiMock = class
    constructor: ({@shouldError = false}) ->

    getPerformances: (id) =>
        if (@shouldError)
            Promise.resolve [error: 'MockError']
        else  
            Promise.resolve []

module.exports.TelegramMock = class
    sendError: () -> Promise.resolve()
    sendShowChange: () -> Promise.resolve()