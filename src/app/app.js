const app = angular.module('bileto.shows', ['ui.router', 'angularMoment'])

app.controller('ShowsController', ShowsController)
app.controller('TicketekController', TicketekController)

app.config(routes)

moment.locale('es')
