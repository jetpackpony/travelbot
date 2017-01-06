require "promise"

p = Promise.new.tap do |promise|
    sleep(3)
    promise.fulfill(10)
  end
p.then { |res| res + 10 }
  .then { |res| puts res }
  .rescue { |reason| puts reason }

