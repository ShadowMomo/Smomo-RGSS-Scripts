#==============================================================================
# ■ 变量槽显示
#    作者：影月千秋
#------------------------------------------------------------------------------
# ● 简介
#   本脚本用以在菜单或地图界面显示一个值槽，它的进度由变量控制
#------------------------------------------------------------------------------
# ● 使用方法
#   插入到其他脚本以下，Main以上，按要求在下方设定即可
#------------------------------------------------------------------------------
# ● 声明
#   本脚本作者为【影月千秋】，保留原作者前提下，允许一切商业或非商业使用
#==============================================================================
  
if true  # <= 设为 true/false 来 启用/禁用 这个脚本
  
$smomo ||= {}
unless $smomo["VarBar"]
$smomo["VarBar"] = true
  
#==============================================================================
# ■ MoVarBar
#------------------------------------------------------------------------------
#   变量槽的设定区域
#==============================================================================
module Smomo
module MoVarBar
    
  MAPLOC = 3
  #在地图中变量窗口显示的位置
  # 0不使用 1左上 2左下 3右上 4右下
    
  KEY = :Y
  #玩家在地图界面显示/隐藏窗口的键，:Y一般为S键，不使用请设为0
    
  MAPSWI = 0
  #游戏中决定是否屏蔽在地图显示窗口的开关，优先级高于KEY
  #开关打开时，绝不会显示
    
  MENUSW = true
  #是否在菜单显示变量窗口
  #如果和其他修改了菜单的脚本不兼容请设为false
    
  MENUSWI = 0
  #游戏中决定是否在菜单显示窗口的开关
    
  VARC = 1
  #控制当前进度的变量ID
    
  VARF = 2
  #控制最大值的变量ID
    
  BASES = 100
  #当前进度的基础值
  #在计算当前进度时，永远会加上这样一个值
    
  BEGINM = 1000
  #最大值的初始值
  #因为游戏开始时变量值为0，为了避免除数为0，使用了这样的常量
  #这个值仅在 由VARF指向的变量 为0时 生效
    
  NUMSHOW = true
  #是否显示进度值
  #进度值就是类似于【64/100】的文字
    
  TEXT = "击破数"
  #变量槽上方显示的文字
    
  BCOLOR1 = 16
  BCOLOR2 = 12
  #变量槽的渐变色 *
    
  TCOLOR = 4
  #文字颜色 *
    
  # * 颜色请填写一个整数，参照事件【显示文章】中转移字符【/C[]】的参数
end # module MoVarBar
end # module Smomo
  
################################################################################
#                                                                              #
#        Do        Not        Edit        Over        This        Line!        #
#                                                                              #
################################################################################
  
#==============================================================================
# ■ Window_MoVarBar
#------------------------------------------------------------------------------
#   显示变量槽的窗口
#==============================================================================
   
class Window_MoVarBar < Window_Base
  include Smomo::MoVarBar
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(type, gold_window = nil)
    case type
    when :map
      case MAPLOC
      when 1
        super(0, 20, 160, fitting_height(2) - 20)
      when 2
        super(0,Graphics.height - fitting_height(2),160,fitting_height(2) - 20)
      when 3
        super(Graphics.width - 160, 20, 160, fitting_height(2) - 20)
      when 4
        super(Graphics.width - 160, Graphics.height - fitting_height(2), 160,
        fitting_height(2) - 20)
      end
    when :menu
      super(gold_window.x,gold_window.y-fitting_height(2)+20,gold_window.width,
      fitting_height(2) - 20)
    end
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    super
    update_bar
  end
  #--------------------------------------------------------------------------
  # ● 更新值槽
  #--------------------------------------------------------------------------
  def update_bar
    refresh if $game_map.need_refresh
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    change_color(text_color(TCOLOR))
    draw_gauge(0, line_height - 20, contents.width, mobarrate,
    text_color(BCOLOR1), text_color(BCOLOR2))
    draw_text(0, 0, contents.width, line_height, mobarratetext, 1)
  end
  #--------------------------------------------------------------------------
  # ● 获取进度值
  #--------------------------------------------------------------------------
  def mobarratetext
    TEXT + (NUMSHOW ? ("    " + ($game_variables[VARC] + BASES).to_s + "/" +
    ($game_variables[VARF] == 0 ? BEGINM : $game_variables[VARF]).to_s) : "")
  end
  #--------------------------------------------------------------------------
  # ● 获取进度比
  #--------------------------------------------------------------------------
  def mobarrate
    ($game_variables[VARC] + BASES).to_f / 
    ($game_variables[VARF] == 0 ? BEGINM : $game_variables[VARF]).to_f
  end
end
#==============================================================================
# ■ Scene_Map
#==============================================================================
class Scene_Map
  alias :movarbarcaw :create_all_windows
  def create_all_windows
    movarbarcaw
    create_var_bar_window
  end
  #--------------------------------------------------------------------------
  # ● 创建变量槽窗口
  #--------------------------------------------------------------------------
  def create_var_bar_window
    @var_bar_window = Window_MoVarBar.new(:map) unless
    Smomo::MoVarBar::MAPLOC == 0
  end
  alias :movarbaruds :update_scene
  def update_scene
    movarbaruds
    update_call_var_bar
  end
  #--------------------------------------------------------------------------
  # ● 监听变量槽的控制按键
  #--------------------------------------------------------------------------
  def update_call_var_bar
    return if @var_bar_window.nil?
    return if Smomo::MoVarBar::KEY == 0
    return unless Input.trigger?(Smomo::MoVarBar::KEY)
    if $game_switches[Smomo::MoVarBar::MAPSWI]
      @var_bar_window.hide
    else
      @var_bar_window.visible = !@var_bar_window.visible
    end
  end
end
#==============================================================================
# ■ Scene_Menu
#==============================================================================
class Scene_Menu
  alias :movarbarstt :start
  def start
    movarbarstt
    create_var_bar_window
  end
  #--------------------------------------------------------------------------
  # ● 创建变量槽窗口
  #  要求有金钱窗口
  #--------------------------------------------------------------------------
  def create_var_bar_window
    return if !Smomo::MoVarBar::MENUSW||$game_switches[Smomo::MoVarBar::MENUSWI]
    @var_bar_window = Window_MoVarBar.new(:menu, @gold_window)
  end
end
  
else # unless $smomo["VarBar"]
  msgbox "请不要重复加载此脚本 : )\n(变量槽显示 MoVarBar)"
end # unless $smomo["VarBar"]
  
else # if true
  p "脚本MoVarBar已被禁用"
end # if true
#==============================================================================#
#=====                        =================================================#
           "■ 脚 本 尾"
#=====                        =================================================#
#==============================================================================#
