module Sametime
  class Library
    attr_reader :room, :documents, :urls

    def initialize(room)
      @room = room
      @documents = {}
      @urls = {}
    end

    def receive(packet)
      case packet['op']
      when 'change'
        id, key = packet['key'].split('.')
        
        case packet['cn']
        when 'meetings.map.documents'
          document = (@documents[id] ||= Document.new(room))
          document[key] = packet['value']
          room.notify(:document_change, document)
        when 'meetings.map.urls'
          url = (@urls[id] ||= URL.new(room))
          url[key] = packet['value']
          room.notify(:url_change, url)
        else
          puts "Unknow cn for library: #{packet}"
        end
      else
        puts "Unknow document operation: #{packet}"
      end
    end
    
    def send_document(filename)
      Document.default_cookies.add_cookies(@room.class.default_cookies.to_cookie_string)
      response = Document.post("/#{@room.id}", 'Rtc4web-Nonce' => @room.nonce, :ownerId => @room.base.email, :query => {
        file: File.new(File.expand_path(filename))
      })
    end
  end
end