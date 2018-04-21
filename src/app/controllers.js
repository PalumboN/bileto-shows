class Controller {
  constructor(Api) {
    this.api = Api
  }

  post(path, body) {
    return this.api.post(path, body)
  }

  delete(path) {
    return this.api.delete(path)
  }
}

class ShowsController extends Controller {
  constructor(Api) {
    super(Api)
    this.loadShows()
  }

  loadShows(force) {
    this.api.getShows(force)
    .then((it) => { this.shows = it })
  }

  loadArchived(force) {
    this.api.getArchived(force)
    .then((it) => { this.archivedShows = it })
  }

  sync() {
    this.syncing = true
    this.post("shows/sync")
    .then(() => this.loadShows(true))
    .then(() => this.syncing = false)
  }

  archive(show) {
    this.delete(`shows/${show._id}`)
    .then(() => this.loadShows(true))
  }

  reactive(show) {
    this.post(`shows/reopen/${show._id}`)
    .then(() => this.loadShows(true))
    .then(() => this.loadArchived(true))
  }
}

class TicketekController extends Controller {
  constructor(Api) {
    super(Api)
    this.loadShows()
  }

  loadShows() {
    this.quering = true
    this.api.getTicketekShows()
    .then((it) => { this.shows = it })
    .then(() => this.quering = false)
  }

}
