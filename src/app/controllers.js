class Controller {
  constructor($http) {
    this.$http = $http
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

class ShowsController extends Controller {
  constructor($http) {
    super($http)
    this.loadShows()
  }

  loadShows() {
    this.get("shows")
    .then((it) => { this.shows = it })
  }

  loadArchived() {
    this.get("shows/archive")
    .then((it) => { this.archivedShows = it })
  }

  sync() {
    this.syncing = true
    this.post("shows/sync")
    .then(() => this.loadShows())
    .then(() => this.syncing = false)
  }

  archive(show) {
    this.delete(`shows/${show._id}`)
    .then(() => this.loadShows())
  }

  reactive(show) {
    this.post(`shows/reopen/${show._id}`)
    .then(() => this.loadShows())
    .then(() => this.loadArchived())
  }
}

class TicketekController extends Controller {
  constructor($http) {
    super($http)
    this.loadShows()
  }

  loadShows() {
    this.quering = true
    this.get("sites/ticketek/shows")
    .then((it) => { this.shows = it })
    .then(() => this.quering = false)
  }

}
