chai   = require 'chai'

should = chai.should()

X      = require '../lib'
rcell  = require 'reactive-cell'

delay     = -> setTimeout arguments[1], arguments[0]
serial = 0
say_hello = ( cb ) -> delay 10, -> cb null, 'hello ' + serial++

describe 'global + subscribe + reset + busy', ->
  it 'should work', (done) ->
    
    serial = 0 # reset state

    say_hello_global = X say_hello, global: yes

    results = []

    f = ->
      if X.busy say_hello_global
        'busy'
      else
        say_hello_global()

    results.should.have.length 0
    X.subscribe f, -> results.push arguments

    results.should.have.length 1
    results[0][1].should.equal 'busy'  


    delay 20, ->

      results.should.have.length 2
      results[1][1].should.equal 'hello 0'

      # if we wait another 20 ms ( just in case )
      # nothing should happen

      delay 20, ->

        results.should.have.length 2


        say_hello_global.reset() # trigger a refresh

        results.should.have.length 3
        results[2][1].should.equal 'busy'  


        delay 20, ->
          results.should.have.length 4
          results[3][1].should.equal 'hello 1'

          done()