workflow "Update data" {
  resolves = ["Update history files"]
  on = "schedule(0 9 * * *)"
}

action "Update history files" {
  uses = "actions/npm@master"
  args = "run update"
  secrets = [
    "GH_TOKEN",
    "NPM_AUTH_TOKEN",
  ]
}


workflow "Publish new release" {
  resolves = "Publish via semantic-release"
  on = "push"
}

action "Release master branch only" {
  uses = "BinaryMuse/tip-of-branch@master"
  args = "master"
  secrets = ["GITHUB_TOKEN"]
}

action "Install dependencies" {
  uses = "actions/npm@master"
  needs = "Release master branch only"
  args = "ci"
}

action "Run tests" {
  uses = "actions/npm@master"
  needs = ["Install dependencies"]
  args = "test"
}

action "Publish via semantic-release" {
  uses = "actions/npm@master"
  needs = ["Run tests"]
  args = "run semantic-release"
  secrets = [
    "GH_TOKEN",
    "NPM_AUTH_TOKEN",
  ]
}
