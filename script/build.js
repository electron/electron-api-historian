#!/usr/bin/env node

require('make-promises-safe')
const fs = require('fs')
const path = require('path')
const { chain } = require('lodash')
const { GitProcess } = require('dugite')
const util = require('util')
const semver = require('semver')
const execAsync = util.promisify(require('child_process').exec)

async function git (command) {
  const gitDir = path.resolve(__dirname, '../electron')
  const { stdout, stderr, exitCode } = await GitProcess.exec(command.split(' '), gitDir)

  if (exitCode !== 0) {
    console.error(stderr)
    process.exit(1)
  }

  return chain(stdout.split('\n'))
    .map(line => line.trim())
    .compact()
    .value()
}

async function exec (command) {
  const options = {
    cwd: path.resolve(__dirname, '../electron')
  }

  const { stdout, stderr } = await execAsync(command, options)

  if (stderr && stderr.lenth) {
    console.error(stderr)
    process.exit(1)
  }

  return chain(stdout.split('\n'))
    .map(line => line.trim())
    .compact()
    .value()
}

async function go () {
  const tagFiles = {}
  const allFiles = new Set()
  let tags = await git('tag')
  tags = tags.sort(semver.compare)

  await git('checkout main')
  const mainFiles = await exec('find docs -name \'*.md\'')
  mainFiles.forEach(file => allFiles.add(file))

  for (const tag of tags) {
    console.log(tag)
    await git(`checkout ${tag}`)
    try {
      const files = await exec('find docs -name \'*.md\'')
      files.forEach(file => allFiles.add(file))
      tagFiles[tag] = files
    } catch (e) {
      continue
    }
  }

  const results = {}
  for (const file of allFiles) {
    const firstTag = tags.find(tag => tagFiles[tag] && tagFiles[tag].includes(file))
    if (firstTag) results[file] = firstTag
  }

  fs.writeFileSync(
    path.join(__dirname, '../index.json'),
    JSON.stringify(results, null, 2)
  )
  console.log(results)
}

go()
