module Sametime
  class Chat
     
    class Message
      
      attr_reader :text
      
      def initialize(message)
        @text = message['message']
      end
    end

    def initialize(room)
      @room = room
      @messages = {}
    end

    def receive(packet)
      case packet['op']
      when 'change'
        message = @messages[packet['key']] = Message.new(packet['value'])
        @room.notify(:chat_message, message)
      else
        puts "Unknow chat operation: #{packet}"
      end
    end
    
    def send(text)
      key = "#{@room.base.email}:#{Time.now.utc.to_i}"
      value = {"message" => text, "tags" => ["chat"]}
      @room.send('meetings.map.messages', key, value)
    end
  end
end