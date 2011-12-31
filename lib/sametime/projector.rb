module Sametime
  class Projector < Map
    
    def next
      room.send('meetings.map.projector', "#{document.id}.currentPage", [document.current_page + 1, document.page_count].min)
      meetings.map.documents
    end
    
    def document
      room.library.documents[self["media_id"]]
    end
  end
end