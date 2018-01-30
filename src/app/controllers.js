class ShowsController {
  constructor($http) {
    this.$http = $http
    this.loadJobs()
  }

  loadJobs() {
    this.get("jobs")
    .then((it) => { this.jobs = it })
  }

  loadArchived() {
    this.get("jobs/archive")
    .then((it) => { this.archivedJobs = it })
  }

  runJobs() {
    this.runningJob = true
    this.post("jobs/run")
    .then(() => this.loadJobs())
    .then(() => this.runningJob = false)
  }

  searchShow() {
    this.get("shows/" + this.search)
    .then((shows) => {
      shows.forEach((it) => {
        it.name = this.search
        it.sections.forEach((it) => it.selected = true)
      })
      this.show = shows[0]
    })
  }

  noneSectionSelected() {
    return !_.some(this.show.sections, "selected")
  }

  createNewJob() {
    _.remove(this.show.sections, (it) => !it.selected)

    this.post("jobs", this.show)
    .then(() => delete this.show)
    .then(() => this.loadJobs())
    .then(() => $('.collapse').collapse())
  }

  archive(job) {
    this.delete(`jobs/${job._id}`)
    .then(() => this.loadJobs())
  }

  reactive(job) {
    this.post(`jobs/reopen/${job._id}`)
    .then(() => this.loadJobs())
    .then(() => this.loadArchived())
  }

  get(path) {
    var getData = (response) => response.data
    return this.$http.get(path).then(getData)
  }

  post(path, body) {
    var getData = (response) => response.data
    return this.$http.post(path, body).then(getData)
  }

  delete(path) {
    var getData = (response) => response.data
    return this.$http.delete(path).then(getData)
  }
}
