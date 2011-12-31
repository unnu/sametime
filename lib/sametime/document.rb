module Sametime
  class Document < Map
    include HTTMultiParty
    no_follow true
    base_uri 'http://foresee.dyndns.biz/DocumentShare/docshare'
  
    def activate
      value = {presenter: room.base.email, presentTime: 0, mediaId: id, mediaName: name, mediaType: "Slides"}
      room.send('meetings.map.projector', 'DefaultProjector', value)
    end
    
    def id
      attributes['id']
    end
  
    def name
      attributes['name']
    end
    
    def page_count
      attributes['pageCount'] || 0
    end
    
    def current_page
      attributes['currentPage'] || 0
    end
  end
end