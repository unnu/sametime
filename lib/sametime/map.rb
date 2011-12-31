module Sametime
  class Map
    attr_accessor :attributes
    attr_reader :room
    
    delegate :[]=, :[], :to => :attributes
    
    def initialize(room)
      @room = room
      @attributes = {}
    end
    
    def inspect
      attr_list = attributes.map { |key, value| "#{key}: #{value}" } * ', '
      "#<#{self.class} #{attr_list}>"
    end
  end
end