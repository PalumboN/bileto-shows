var routes = ($stateProvider, $urlRouterProvider) => {

  $stateProvider
    .state('shows', {
      url: "/",
      templateUrl: "partials/shows.html",
      controller: "ShowsController as ctrl"
    })

  $urlRouterProvider.otherwise("/")

}
