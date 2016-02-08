chai = require 'chai'
sinon = require 'sinon'
chai.use require 'sinon-chai'

expect = chai.expect

describe 'sumologic', ->
  beforeEach ->
    @robot =
      respond: sinon.spy()
      hear: sinon.spy()

    require('../src/scripts/sumologic')(@robot)

  it 'registers a sumo dashboards listener', ->
    expect(@robot.respond).to.have.been.calledWith(/sumo dashboards/i)

  it 'registers a sumo dashboard id data listener', ->
    expect(@robot.respond).to.have.been.calledWith(/sumo dashboard (.+) data/i)

  it 'registers a sumo search count query last minutes listener', ->
    expect(@robot.respond).to.have.been.calledWith(/sumo search count (.+) last (.+)$/i)

  it 'registers a sumo search count query listener', ->
    expect(@robot.respond).to.have.been.calledWith(/sumo search count (.+)?$/i)

  it 'registers a sumo ui url listener', ->
    expect(@robot.respond).to.have.been.calledWith(/sumo ui url/i)

  it 'registers a sumo help listener', ->
    expect(@robot.respond).to.have.been.calledWith(/sumo help/i)
