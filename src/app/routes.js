var routes = ($stateProvider, $urlRouterProvider) => {

  $stateProvider
    .state('shows', {
      url: "/",
      templateUrl: "partials/shows.html",
      controller: "ShowsController as ctrl"
    })
    .state('ticketek', {
      url: "/ticketek",
      templateUrl: "partials/ticketek.html",
      controller: "TicketekController as ctrl"
    })
    .state('tuentrada', {
      url: "/tuentrada",
      templateUrl: "partials/tuentrada.html",
      controller: "TuentradaController as ctrl"
    })
    .state('ticketportal', {
      url: "/ticketportal",
      templateUrl: "partials/ticketportal.html",
      controller: "TicketportalController as ctrl"
    })

  $urlRouterProvider.otherwise("/")

}
