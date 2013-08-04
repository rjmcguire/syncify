chai = require 'chai'

should = chai.should()

{delay} = require '../lib/util'
blocking = require '../lib'

# F is a function that takes 100MS to reply 'foo'
f = (cb) -> delay 100, -> cb null, 'foo'


describe 'blocked', (done) ->

  it 'should return true when a blocked function is still blocking', ->

    # F1 is a blocking version of F ( it is now sync )
    f1 = blocking.block f

    # F2 is a sync function that tells us whether F1
    # is still blocked or not
    f2 = -> blocking.blocked f1

    # We unblock F2 so we can call it outside of an evaluation scope
    # it is now a normal async function that takes a callback
    f3 = blocking.unblock f2

    # execute F3 for the first time
    # as soon as we do this, F2 will start its execution
    f3 (e, r) ->
      # F2 is not ready yet
      if e? then console.log e.stack # debug visually
      should.not.exist e
      # thus the result of blocking is true
      r.should.equal yes
      delay 200, ->
        # we wait 200ms, which should be enough time
        # for F2 to finish working
        f3 (e, r) ->
          if e? then console.log e.stack # debug visually
          should.not.exist e
          # F2 should be finished by now
          r.should.equal no
          done()