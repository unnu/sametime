module Sametime
  class Room
    include HTTParty
    no_follow true
    base_uri 'http://foresee.dyndns.biz/rtc'
  
    attr_reader :base
  
    def initialize(base, data)
      self.class.default_cookies.add_cookies(base.class.default_cookies.to_cookie_string)
      @base = base
      @id = data['id']
      @map = {}
    end
  
    def join
      response = self.class.post("/RTCServlet/#{@id}/user", :body => {
        userInfo: Sametime.escape({'displayName' => @base.username, 'stproxyCommunityFQDN' => '', 'stproxyCommunityUserId' => '', 'clientType' => 'web'}.to_json),
        userName: @base.email,
        method: 'put'
      })
      self.class.default_cookies.add_cookies(response.response['set-cookie'])
    end
  
    def receive
      response = self.class.get('/RTCServlet', :query => {format: 'json'}).parsed_response
      if response
        handle_packets(response)
      end
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
  
    private
  
      def handle_packets(packets)
        packets['update'].each do |packet|
          case packet['cn']
          when 'meetings.map.messages'
            chat.receive(packet)
          else
            puts "Unknow packet: #{packet}"
          end
        end
      end
  end
end