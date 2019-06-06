workflow "Update and release" {
  resolves = ["Update data and release"]
  on = "schedule(0 21 * * *)"
}

action "Update data and release" {
  uses = "actions/npm@master"
  args = "run update"
  secrets = [
    "GH_TOKEN",
    "NPM_AUTH_TOKEN",
  ]
}
