#==============================================================================#
# * RGSS3 Script - Show Choice Fixed                                           #
#  * Author - Shadwo Momo                                                      #
#  * Version - 1.0                                                             #
#  * Last Update - 2013.12.21                                                  #
#------------------------------------------------------------------------------#
# * Introduce                                                                  #
#  In the Show Choice command, if you use a lot of escape character, the       #
# choice window will be too wide. This can help.                               #
#------------------------------------------------------------------------------#
# * Instruction                                                                #
#  Insert the script below other materials but above Main.                     #
#------------------------------------------------------------------------------#
# * Update                                                                     #
#  V 1.0 2013.12.21 Build                                                      #
#------------------------------------------------------------------------------#
# * License                                                                    #
#  This script is written by Shadow Momo. Please keep this information if you  #
# use or edit it.                                                              #
#==============================================================================#
class Window_ChoiceList
  def max_choice_width
    temp_win = Window_Base.new(Graphics.width, Graphics.height, 1, 1)
    width = $game_message.choices.collect {|s|
      temp_win.reset_font_settings
      pos = {:x => 0, :y => 0, :new_x => 0, :height =>
      calc_line_height(s = convert_escape_characters(s))}
      temp_win.process_character(s.slice!(0, 1), s, pos) until s.empty?; pos[:x]
    }.max
    temp_win.dispose; width
  end
end
#==============================================================================#
#===========================                        ===========================#
#                             End     of     File                              #
#===========================                        ===========================#
#==============================================================================#
