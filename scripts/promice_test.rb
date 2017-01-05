require 'concurrent'

p =
  Concurrent::Promise.new { 10 }
  .then { |res| res + 10 }
  .then { |res| raise 'error' }
  .then { |res| puts res }
  .rescue { |reason| puts reason }
  .execute

while !p.complete?
  sleep 0.1
end
