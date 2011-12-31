module Sametime
  class Room
    include HTTParty
    no_follow true
    base_uri 'http://foresee.dyndns.biz/rtc'
  
    attr_reader :base, :id, :nonce
  
    def initialize(base, data)
      self.class.default_cookies.add_cookies(base.class.default_cookies.to_cookie_string)
      @base = base
      @id = data['id']
      @map = {}
      @handler = {}
      @nonce = nil
    end
  
    def join
      response = self.class.post("/RTCServlet/#{@id}/user", :body => {
        userInfo: Sametime.escape({'displayName' => @base.username, 'stproxyCommunityFQDN' => '', 'stproxyCommunityUserId' => '', 'clientType' => 'web'}.to_json),
        userName: @base.email,
        method: 'put'
      })
      @nonce = response['Rtc4web-Nonce']
      self.class.default_cookies.add_cookies(response.response['set-cookie'])
    end
  
    def receive
      response_object = self.class.get('/RTCServlet', :query => {format: 'json'})
      response = response_object.parsed_response
      handle_packets(response) if response
    end
  
    def send(cn, key, value)
      response = self.class.post("/map/#{@id}/#{cn}", :body => {
        key: key,
        value: value.is_a?(Hash) ? value.to_json : value,
        method: 'put'
      })
    end
  
    def chat
      @map['meetings.map.messages'] ||= Chat.new(self)
    end
    
    def library
      @map['meetings.map.documents'] ||= Library.new(self)
    end
    
    def projector
      @map['meetings.map.projector']
    end
    
    def projector_receive(packet)
      case packet['op']
      when 'change'
        projector = (@map['meetings.map.projector'] ||= Projector.new(self))
        projector.attributes = (packet['value'])
        notify(:projector_changed, projector)
      when 'remove'
        projector = @map.delete('meetings.map.projector')
        notify(:projector_removed, projector)
      else
        puts "Unknow projector operation: #{packet}"
      end
    end
    
    def notify(types, object)
      (Array(types) << :all).each do |type|
        (@handler[type] || []).each { |block| block.call(object, types) }
      end
    end
    
    def on(*types, &block)
      types.each do |type|
        (@handler[type] ||= []) << block
      end
    end
    
    def listen
      join
      http = Thread.start do
        while true
          receive
        end
      end
    end
    
    private
  
      def handle_packets(packets)
        packets['update'].each do |packet|
          case packet['cn']
          when 'meetings.map.messages'
            chat.receive(packet)
          when 'meetings.map.documents', 'meetings.map.urls'
            library.receive(packet)
          when 'meetings.map.projector'
            projector_receive(packet)
          else
            puts "Unknow packet: #{packet}"
          end
        end
        
        puts "Unknow packet: #{packets['truncated']}"
      end
  end
end