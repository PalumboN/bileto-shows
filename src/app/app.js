const app = angular.module('bileto.shows', ['ui.router'])

app.controller('ShowsController', ShowsController)

app.config(routes)
