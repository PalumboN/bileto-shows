class Controller {
  constructor(Api) {
    this.api = Api
  }

  post(path, body) {
    return this.api.post(path, body)
  }

  put(path, body) {
    return this.api.put(path, body)
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
    .then((it) => {
      it.forEach((show) =>
        show.tickets.forEach((ticket) => 
          ticket.alert = show.alertIds && show.alertIds.includes(ticket.id)
        )
      )
      return it
    })
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
    .finally(() => this.syncing = false)
  }

  archive(show) {
    show.deleting = true
    this.delete(`shows/${show._id}`)
    .then(() => this.loadShows(true))
    .finally(() => show.deleting = false)
  }

  reactive(show) {
    this.post(`shows/reopen/${show._id}`)
    .then(() => this.loadShows(true))
    .then(() => this.loadArchived(true))
  }

  changeAlerts(show) {
    show.alertIds = show.tickets.filter((it) => it.alert).map((it) => it.id)
    this.put(`shows/${show._id}`, show)
    .then(() => this.loadShows(true))  
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
    .then((it) => { this.shows = _.uniqBy(it.filter((show) => !_.isEmpty(show)), "[0].id") })
    .then(() => this.quering = false)
  }

  follow(performance) {
    performance.following = true
    this.post(`sites/ticketek/shows/${performance.name}/follow`)
    .then(() => performance.following = false)
  }
}

class TicketportalController extends Controller {
  constructor(Api) {
    super(Api)
    this.loadShows()
  }

  loadShows() {
    this.quering = true
    this.api.getTicketportalShows()
    .then((it) => { this.shows = it })
    .then(() => this.quering = false)
  }

  follow(performance) {
    performance.following = true
    this.post(`sites/ticketportal/shows/${performance.id}/follow`)
    .then(() => performance.following = false)
  }
}

class TuentradaController extends Controller {
  constructor(Api) {
    super(Api)
    this.loadShows()
  }

  loadShows() {
    this.quering = true
    this.api.getTuentradaShows()
    .then((it) => { this.shows = _.uniqBy(it.filter((show) => show && !show[0].error), "[0].id") })
    .then(() => this.quering = false)
  }

  follow(performance) {
    performance.following = true
    this.post(`sites/tuentrada/shows/${performance.id}/follow`)
    .then(() => performance.following = false)
  }
}
