#==============================================================================
# ** RGSS3-Based A-Star Find Path
#  * Shadow Momo
#  * Base Pack
#==============================================================================
module AStar
  class Point
    attr_accessor :x, :y, :g, :h, :d
    def initialize(*point)
      self.x, self.y = point
    end
  end
  module_function
  def make_route(origin, target, *characters)
    target = Point.new(*target)
    is_passable = ->(x, y, d){
      x = $game_map.round_x_with_direction(x, d)
      y = $game_map.round_y_with_direction(y, d)
      $game_map.valid?(x, y) && $game_map.passable?(x, y, d) &&
      $game_map.events_xy_nt(x, y).all? do |event|
        !event.normal_priority? || characters.any?{|c| c.id == event.id}
      end
    }
    return [] unless [2, 4, 6, 8].any? do |d|
      x = target.x + (d == 4 ? -1 : d == 6 ? 1 : 0)
      y = target.y + (d == 8 ? -1 : d == 2 ? 1 : 0)
      is_passable.(x, y, 10 - d)
    end
    origin = Point.new(*origin)
    target.g = 0
    target.h = (target.x - origin.x).abs + (target.y - origin.y).abs
    open  = [target]
    close = []
    include_open  = ->(x, y){  !open.find{|pt| pt.x == x && pt.y == y}.nil? }
    include_close = ->(x, y){ !close.find{|pt| pt.x == x && pt.y == y}.nil? }
    until open.empty?
      nod = open.shift
      [2, 4, 6, 8].each do |d|
        x = nod.x + (d == 4 ? -1 : d == 6 ? 1 : 0)
        y = nod.y + (d == 8 ? -1 : d == 2 ? 1 : 0)
        next unless is_passable.(x, y, 10 - d)
        if include_open.(x, y)
          nex = open.find{|pt| pt.x == x && pt.y == y}
          if nod.g + 10 < nex.g
            nex.d = 10 - d
            nex.g = nod.g + 10
          end
        elsif !include_close.(x, y)
          child = Point.new(x, y)
          child.d = 10 - d
          child.g = nod.g + 10
          child.h = (x - origin.x).abs + (y - origin.y).abs
          open.unshift child
          open.sort_by!{|pt| pt.g + pt.h}
        end
      end
      close.push nod
      break if include_close.(origin.x, origin.y)
    end
    return [] unless include_close.(origin.x, origin.y)
    routes = []
    nod = close.find{|pt| pt.x == origin.x && pt.y == origin.y}
    until nod.x == target.x && nod.y == target.y
      routes.push nod.d
      x = nod.x + (nod.d == 4 ? -1 : nod.d == 6 ? 1 : 0)
      y = nod.y + (nod.d == 8 ? -1 : nod.d == 2 ? 1 : 0)
      nod = close.find{|pt| pt.x == x && pt.y == y}
    end
    routes
  end
end
