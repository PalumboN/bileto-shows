
class ShowsController {
  constructor($http) {
    this.$http = $http
    this.loadJobs()
  }

  loadJobs() {
    this.get("jobs")
    .then((it) => { this.jobs = it })
  }

  runJobs() {
    this.post("jobs/run")
    .then(() => this.loadJobs())
  }

  searchShow() {
    this.get("shows/" + this.search)
    .then((shows) => {
      shows.forEach((it) => { it.name = this.search })
      this.shows = shows
      this.show = shows[0]
    })
  }

  createNewJob() {
    _.remove(this.show.sections, (it) => !it.selected)
    this.post("jobs", this.show)
    .then(() => this.loadJobs())
  }

  get(path) {
    var getData = (response) => response.data
    return this.$http.get(path).then(getData)
  }

  post(path, body) {
    var getData = (response) => response.data
    return this.$http.post(path, body).then(getData)
  }
}
