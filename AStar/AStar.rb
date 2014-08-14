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
  def make_route(origin, target)
    target = Point.new(*target)
    return [] unless [2, 4, 6, 8].any? do |d|
      x = target.x + (d == 4 ? -1 : d == 6 ? 1 : 0)
      y = target.y + (d == 8 ? -1 : d == 2 ? 1 : 0)
      $game_map.passable?(x, y, 10 - d)
    end
    open  = [origin = Point.new(*origin).tap{|o|
      o.g = 0
      o.h = (o.x - target.x).abs + (o.y - target.y).abs
    }]
    close = []
    include_open  = ->(x, y){  !open.find{|pt| pt.x == x && pt.y == y}.nil? }
    include_close = ->(x, y){ !close.find{|pt| pt.x == x && pt.y == y}.nil? }
    exist = false
    until open.empty?
      nod = open.shift
      [2, 4, 6, 8].each do |d|
        next unless $game_map.passable?(nod.x, nod.y, d)
        x = nod.x + (d == 4 ? -1 : d == 6 ? 1 : 0)
        y = nod.y + (d == 8 ? -1 : d == 2 ? 1 : 0)
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
          child.h = (x - target.x).abs + (y - target.y).abs
          open.unshift child
          open.sort_by!{|pt| pt.g + pt.h}
        end
      end
      close.push nod
      break exist = true if include_close.(target.x, target.y)
    end
    return [] unless exist
    routes = []
    nod = close.find{|pt| pt.x == target.x && pt.y == target.y}
    until nod.x == origin.x && nod.y == origin.y
      routes.push 10 - nod.d
      x = nod.x + (nod.d == 4 ? -1 : nod.d == 6 ? 1 : 0)
      y = nod.y + (nod.d == 8 ? -1 : nod.d == 2 ? 1 : 0)
      nod = close.find{|pt| pt.x == x && pt.y == y}
    end
    routes.reverse
  end
end