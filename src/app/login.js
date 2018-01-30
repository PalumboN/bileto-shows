class LoginCtrl {
  constructor($window, $http) {
    this.http = $http
    this.credentials = {}
  }

  login() {
    return this.http
    .post("/login")
  }
}

angular.module('bileto.login', []).controller("LoginCtrl", LoginCtrl)
