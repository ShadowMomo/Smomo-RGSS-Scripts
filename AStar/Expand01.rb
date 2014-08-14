#==============================================================================
# ** RGSS3-Based A-Star Find Path
#  * Shadow Momo
#  * Expand 01
#==============================================================================

#==============================================================================
# ** Game_Character
#==============================================================================
class Game_Character
  def goto_AStar(tx, ty)
    route = RPG::MoveRoute.new
    route.repeat = false
    route.skippable = true
    AStar.make_route([self.x, self.y], [tx, ty]).each do |d|
      route.list.unshift RPG::MoveCommand.new.tap{|c| c.code = d >> 1}
    end
    force_move_route(route)
  end
  alias :astar_move_toward_character :move_toward_character
  def move_toward_character(character)
    dir = AStar.make_route([x, y], [character.x, character.y]).shift
    dir.nil? ? astar_move_toward_character(character) : move_straight(dir)
  end
end
#==============================================================================
# ** Game_Event
#==============================================================================
class Game_Event
  alias :astar_move_type_toward_player :move_type_toward_player
  def move_type_toward_player
    if @astar_last_player_pos != [$game_player.x, $game_player.y]
      @astar_last_player_pos = $game_player.x, $game_player.y
      @astar_route = AStar.make_route([x, y], @astar_last_player_pos)
    end
    (dir = @astar_route.shift).nil? ?
    astar_move_type_toward_player :
    move_straight(dir)
  end
end