require "rubygems"
require "bundler/setup"
require "httparty"
require "active_support/ordered_hash"
require "active_support/json"

module Sametime
  extend self
  
  def escape(string)
    URI.escape(string, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
  end
  
  class Room
    include HTTParty
    no_follow true
    base_uri 'http://foresee.dyndns.biz/rtc'
    
    def initialize(base, data)
      self.class.default_cookies.add_cookies(base.class.default_cookies.to_cookie_string)
      @base = base
      @id = data['id']
      @map = {}
    end
    
    def join
      user_info1 = {'displayName' => @base.username, 'stproxyCommunityFQDN' => '', 'stproxyCommunityUserId' => '', 'clientType' => 'web'}.to_json
      user_info2 = "{'displayName':'#{@base.username}','stproxyCommunityFQDN':'','stproxyCommunityUserId':'','clientType':'web'}"
      p [user_info1, user_info2]
      response = self.class.post("/RTCServlet/#{@id}/user", :body => {
        userInfo: Sametime.escape(user_info2),
        userName: @base.email,
        method: 'put'
      })
      self.class.default_cookies.add_cookies(response.response['set-cookie'])
    end
    
    def receive
      response = self.class.get('', :query => {format: 'json'}).parsed_response
      if response
        handle_packets(response)
      end
    end
    
    def send(cn, key, value)
      response = self.class.post("/map/#{@id}/cn", :body => {
        key: Sametime.escape("{'displayName':'#{@base.username}','stproxyCommunityFQDN':'','stproxyCommunityUserId':'','clientType':'web'}"),
        value: @base.email,
        method: 'put'
      })
    end
    
    private
      def handle_packets(packets)
        packets['update'].each do |packet|
          case packet['cn']
          when 'meetings.map.messages'
            (@map['meetings.map.messages'] ||= Chat.new(self)).receive(packet)
          else
            puts "Unknow packet: #{packet}"
          end
        end
      end
  end

  class Base
    include HTTParty
    no_follow true
    base_uri 'http://foresee.dyndns.biz/stmeetings'
  
    attr_reader :username, :password, :email
  
    def initialize(username, password, email)
      @username, @password, @email = username, password, email
    end
  
    def login
      self.class.post('/j_security_check', :body => {
        loginType: 'authenticated',
        j_username: @username,
        j_password: @password,
        loginId: 'guest/0011',
        displayName: '',
        rememberDisplayName: 'on'
      })
    rescue HTTParty::RedirectionTooDeep => e
      # redirects to room selection
      self.class.default_cookies.add_cookies(e.response['set-cookie'])
    end
  
    def rooms
      self.class.get('/restapi?myRooms=true&sortKey=meetingName&sortOrder=ascending&count=10&start=1').parsed_response['results'].map { |data| Room.new(self, data) }
    end
  end
  
  class Chat
     
    class Message
      
      def initialize(message)
        @message = message['message']
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
        p message
      else
        puts "Unknow chat operation: #{packet}"
      end
    end
    
    def send(text)
      #key = "#{@room.base.email}:#{Time.now.to_i}"
      #value = 
      #@room.send('meetings.map.messages', )
      
      #key=Test.User1@demo.com:1312288466750&value={"message":" bla","tags":["chat"]}&method=put
    end
  end
end

sametime = Sametime::Base.new('Test User1', 'Passw0rd', 'Test.User1@demo.com')
sametime.login
room = sametime.rooms.first
room.join

while true
  room.receive
end
