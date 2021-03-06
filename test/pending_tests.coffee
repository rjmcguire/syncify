chai = require 'chai'

should = chai.should()

{delay} = require '../src/util'
syncify = require '../src'

f = (cb) -> delay 10, -> cb null, 'foo'

describe 'pending', ->

  it 'should return true when a blocked function is still syncify', ( done ) ->

    # F1 is a syncify version of F ( it is now sync )
    f1 = syncify f

    # F2 is a sync reactive function that tells us whether F1
    # is still blocked or not
    f2 = -> syncify.pending f1

    # We unblock F2 so we can call it outside of an evaluation scope
    # it is now a normal async function that takes a callback
    f3 = syncify.revert f2

    # execute F3 for the first time
    # as soon as we do this, F2 will start its execution
    f3 (e, r) ->
      # F2 is not ready yet
      if e? then console.log e.stack # debug visually
      should.not.exist e
      # thus the result of syncify is true
      r.should.equal yes
      delay 20, ->
        # we wait 200ms, which should be enough time
        # for F2 to finish working
        # and call F3 again
        f3 (e, r) ->
          if e? then console.log e.stack # debug visually
          should.not.exist e
          # F2 should be finished by now
          r.should.equal no
          done()