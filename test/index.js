require('chai').should()
const { describe, it } = require('mocha')
const historian = require('..')

describe('historian', () => {
  it('is an object', () => {
    historian.should.be.an('object')
  })
})
