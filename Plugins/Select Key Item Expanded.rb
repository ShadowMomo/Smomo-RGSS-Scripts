#==============================================================================#
# ** Select Key Item Expanded                                                  #
# * Author: Shadwo Momo                                                        #
#------------------------------------------------------------------------------#
# * Introduction                                                               #
#  This script allows you to select normal items, weapons or armors when you   #
# call the Event Command [Select Key Item].                                    #
#------------------------------------------------------------------------------#
# * Instruction                                                                #
#  Insert the script below other materials but above Main.                     #
#  Use script call[mca_change(symbol)], and the next [Select Key Item] will    #
# show the corresponding items.                                                #
#  The argument [symbol] should be [:item], [:armor] or [:weapon]. You can use #
# [:key_item] as well but there is no need to do this.                         #
#  Change reverts once it functioned. For example:                             #
#    [Script: mca_change(:armor)]                                              #
#    [Select Key Item...] #=> Select Armor                                     #
#    [Select Key Item...] #=> Select Key Item                                  #
#------------------------------------------------------------------------------#
# * License                                                                    #
#  Free to use in any games. I will appreciate it if you keep my name.         #
#==============================================================================#
(MoVar[:skie] = :key_item) rescue MoVar = Struct.new(:skie).new(:key_item)
class Game_Interpreter
  def mca_change(symbol)
    MoVar[:skie] = symbol
  end
end
class Window_KeyItem
  def enable?(*); true end
  def category=(category)
    @category = MoVar[:skie]
    MoVar[:skie] = category
    refresh
    self.oy = 0
  end
end
#==============================================================================#
#===========================                        ===========================#
#                             End     of     File                              #
#===========================                        ===========================#
#==============================================================================#
