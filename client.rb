require File.dirname(__FILE__) + '/lib/sametime'

sametime = Sametime::Base.new('Test User1', 'Passw0rd', 'Test.User1@demo.com')
sametime.login

room = sametime.rooms.first
room.on :chat_message do |message|
  p message
end

room.listen
