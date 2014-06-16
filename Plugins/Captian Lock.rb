#==============================================================================#
# * RGSS3 Script - Captian Lock                                                #
#  * Author - Shadwo Momo                                                      #
#  * Version - 1.0                                                             #
#  * Last Update - 2013.12.15                                                  #
#------------------------------------------------------------------------------#
# * Introduce                                                                  #
#  Prevent the captian from being replaced.                                    #
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
class Scene_Menu
  alias :on_formation_ok_captian_lock :on_formation_ok
  def on_formation_ok
    if @status_window.index == 0
      Graphics.wait(20)
      Sound.play_buzzer
      @status_window.activate
    else
      on_formation_ok_captian_lock
    end
  end
end
#==============================================================================#
#===========================                        ===========================#
#                             End     of     File                              #
#===========================                        ===========================#
#==============================================================================#
