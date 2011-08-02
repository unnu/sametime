module Sametime
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
end