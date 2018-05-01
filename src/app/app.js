const app = angular.module('bileto.shows', ['ui.router', 'angularMoment'])

app.service('Api', Api)

app.controller('ShowsController', ShowsController)
app.controller('TicketekController', TicketekController)
app.controller('TicketportalController', TicketportalController)

app.directive('showPerformance', function() { return { templateUrl: 'directives/show-performance.html' }})
app.directive('ticketekPerformance', function() { return { templateUrl: 'directives/ticketek-performance.html' }})
app.directive('ticketportalPerformance', function() { return { templateUrl: 'directives/ticketportal-performance.html' }})

app.config(routes)

moment.locale('es')
