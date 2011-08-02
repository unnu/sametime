require File.dirname(__FILE__) + '/lib/sametime'

sametime = Sametime::Base.new('Test User1', 'Passw0rd', 'Test.User1@demo.com')
sametime.login
room = sametime.rooms.first
room.join

while true
  room.receive
end
