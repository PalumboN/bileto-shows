class Api {
  constructor($http) {
    this.$http = $http
  }

  getShows(force) {
    return this.cachedGet("shows", force)
  }

  getArchived(force) {
    return this.cachedGet("shows/archive", force)
  }

  getTicketekShows(force) {
    return this.cachedGet("sites/ticketek/shows", force)
  }

  cachedGet(path, force) {
    if (this[path] && !force)
      return Promise.resolve(this[path])

    return this.get(path)
    .then((it) => {
      this[path] = it
      return it
    })
  }

  get(path) {
    var getData = (response) => response.data
    return this.$http.get("/api/" + path).then(getData)
  }

  post(path, body) {
    var getData = (response) => response.data
    return this.$http.post("/api/" + path, body).then(getData)
  }

  delete(path) {
    var getData = (response) => response.data
    return this.$http.delete("/api/" + path).then(getData)
  }
}
