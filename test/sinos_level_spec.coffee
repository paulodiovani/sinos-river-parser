chai  = require('chai')
spies = require('chai-spies')
fs    = require('fs')

chai.use spies
expect = chai.expect

SinosLevel = require('../lib/sinos_level')
Reader     = require('../lib/reader')
Parser     = require('../lib/parser')

describe 'SinosLevel', ->
  before ->
    @file  = './test/fixtures/dummy.html'

  beforeEach ->
    @sinos = new SinosLevel(@file)

  describe '.self', ->
    it 'contains a Reader', ->
      expect(SinosLevel.Reader).to.be.eql Reader

    it 'contains a Parser', ->
      expect(SinosLevel.Parser).to.be.eql Parser

  describe '#constructor', ->
    it 'has a default source', ->
      sinos = new SinosLevel()
      expect(sinos.source).to.be.not.null

    it 'accepts a different source', ->
      sinos = new SinosLevel @file
      expect(sinos.source).to.be.eql @file

  describe '#init', ->
    it 'sets reader', (done) ->
      @sinos.init (err) =>
        expect(err).to.be.null
        expect(@sinos.reader).to.be.instanceof Reader
        done()

    it 'sets parser', (done) ->
      @sinos.init (err) =>
        expect(err).to.be.null
        expect(@sinos.parser).to.be.instanceof Parser
        done()

    it 'fails with invalid source', (done) ->
      @sinos.source = './foo.txt'
      @sinos.init (err) ->
        expect(err).to.be.instanceof Error
        done()

  context 'when not initialized', ->
    describe '#getYears', ->
      it 'fails', ->
        expect(@sinos.getYears.bind @sinos).to.throw 'parser is not defined'

  context 'when initialized', ->
    beforeEach (done) ->
      @sinos.init done

    describe '#getYears', ->
      it 'delegates to Parser#getYears', ->
        chai.spy.on Parser::, 'getYears'
        @sinos.getYears()
        expect(Parser::getYears).to.be.called()
