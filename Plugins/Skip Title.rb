#==============================================================================#
# * RGSS3 Script - Skip Title                                                  #
#  * Author - Shadwo Momo                                                      #
#  * Version - 1.0                                                             #
#  * Last Update - 2013.12.15                                                  #
#------------------------------------------------------------------------------#
# * Introduce                                                                  #
#  Skip the Scene Title, start game at once.                                   #
#------------------------------------------------------------------------------#
# * Instruction                                                                #
#  Insert the script below other materials but above Main.                     #
#------------------------------------------------------------------------------#
# * Update                                                                     #
#  V 1.0 2013.12.15 Build                                                      #
#------------------------------------------------------------------------------#
# * License                                                                    #
#  This script is written by Shadow Momo. Please keep this information if you  #
# use or edit it.                                                              #
#==============================================================================#
class Scene_Title
  def start
    super
    SceneManager.clear
    Graphics.freeze
    DataManager.setup_new_game
    $game_map.autoplay
    SceneManager.goto(Scene_Map)
  end
  def terminate
    super
  end
end
#==============================================================================#
#===========================                        ===========================#
#                             End     of     File                              #
#===========================                        ===========================#
#==============================================================================#
