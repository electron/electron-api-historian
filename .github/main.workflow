workflow "Update and release" {
  on = "schedule(0 9 * * *)"
  resolves = ["Update data and release"]
}

action "Update data and release" {
  uses = "actions/npm@master"
  args = "run update"
  secrets = [
    "GH_TOKEN",
    "NPM_AUTH_TOKEN",
  ]
}
