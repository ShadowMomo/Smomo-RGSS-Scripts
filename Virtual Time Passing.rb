#==============================================================================
# ■ 时间流逝
#  作者：影月千秋
#  版本：2.4
#------------------------------------------------------------------------------
# ● 简介：
#   1.本脚本适用于【VX Ace】，用于XP或VX造成的错误本人不提供支持；发现BUG欢迎报告，
# 但本人不保证有时间修改
#   2.本脚本用于在游戏中模拟真实的时间流逝：昼夜、年份日期
#   3.战斗中、菜单中、对话中都不会进行计时，只有玩家在地图活动时才会计算
#   4.请为本脚本准备变量，默认占用81 - 85号变量，可以在【设定区A】设定
#   5.请为本脚本准备开关，默认占用16号开关，可以在【设定区A】设定
#------------------------------------------------------------------------------
# ● 使用方法：
#  插入到其他脚本以下 Main之前，在下面给出的设定区进行设定后即可（非必须）
#  在事件中改变所设定变量和开关，便可以改变时间
#------------------------------------------------------------------------------
# ● 版本：
#   V 2.4 2014.01.31 修正读档时报错的BUG
#   V 2.3 2014.01.29 可以自定义地图窗体的位置
#   V 2.2 2013.12.27 修正Window_MoVMe的错误
#   V 2.1 2013.12.15 修正过卡的BUG
#   V 2.0 2013.10.04 基本重写
#   V 1.0 2013.08.31 公开
#------------------------------------------------------------------------------
# ● 声明：
#   本脚本由来自【影月千秋】，使用和转载请保留此信息
#==============================================================================

#==============================================================================
# ■ MoVTData
#------------------------------------------------------------------------------
# 　虚拟时间主模块
#==============================================================================

module MoVTData
  #============================================================================
  # ■ 设定区A - 基础设定
  #============================================================================
    WinOn = true
      #WinOn - 是否在菜单内显示日历
    CalOn = true
      #CalOn - 是否在地图上显示日历
    CalOnTop = true
      #CalOnTop - 地图上的日历是否显示在屏幕上方，否的话在屏幕下方
    Icon = 234
      #Icon - 时间前的图标 设为0则不显示
    Chro = "公元"
      #Chro - 设定纪元法的名称
    InDoors = [2,34]
      #InDoors - 填写室内地图ID 室内地图不会受昼夜影响，你也可以在B区取消昼夜
    Sta_Y = 2013
    Sta_M = 10
    Sta_D = 4
    Sta_H = 15
    Sta_I = 36
      #以上设置游戏起始日期时间
    Sta_WDay = 6
      #Sta_WDay - 游戏起始于什么时候 0为周期的第一天 周期在下面B区设定(默认为星期)
    TimV = [81,82,83,84,85]
      #TimV - 设定占用变量，分别对应年月日时分
    Pause = 16
      #Pause - 设定占用开关，当此开关打开时，暂停计时
  #============================================================================
  # ■ 设定区A结束
  #============================================================================
  
  #============================================================================
  # ■ 设定区B - 高级设定
  #============================================================================
    DayNight = true
      #是否有白昼和黑夜等各时段的区分
    Spe = 6
      #Spe - 游戏时间进行速度，代表经过多少帧后游戏内部经过一分钟，现实中1秒60帧
    YM = 12
      #YM - 游戏中一年多少月
    MD = 30
      #MD - 游戏中一月多少天
    DH = 24
      #DH - 游戏中一天几小时
    HM = 60
      #HM - 游戏中一小时几分钟
    Weeks = ["星期日","星期一","星期二","星期三","星期四","星期五","星期六"]
      #Weeks - 设定每个周期日子的名称，有意向的话也可以把所谓“星期”改为其他的周期
    VTTone = {
      :Dawn => [240 , Tone.new( -75,-100,   0,  75), "黎明"],
      :Morn => [360 , Tone.new(   0,   0,   0,   0), "上午"],
      :Noon => [660 , Tone.new(  50,  50,  10, -30), "中午"],
      :Aftr => [900 , Tone.new(   0,   0,   0,   0), "下午"],
      :Sset => [1080, Tone.new(  34, -34, -68, 170), "黄昏"],
      :Nigt => [1260, Tone.new( -75,-100,   0,  75), "夜晚"],
      :Dark => [60  , Tone.new(-125,-125, -10, 125), "深夜"]
    }
      #设置一天各时段的开始时间，1440为一天的长度，240是早上四点（240/1440*24）
      #从上到下：黎明 上午 中午 下午 黄昏 夜晚 深夜
      #后面是设置各时段的色调
  #============================================================================
  # ■ 设定区B结束
  #============================================================================
  
  #============================================================================
  # 如果你懂一点脚本，可以在下面对时间窗口的显示方式做一些调整
  # 建议不要将原来的方式删掉，而是进行注释，因为可能需要对照着修改
  #============================================================================
  
  #============================================================================
  # ■ Window_MoVMe
  #----------------------------------------------------------------------------
  # 　菜单画面中，显示当前游戏内部虚拟时间的窗口
  #============================================================================
  class Window_MoVMe < Window_Base
    #------------------------------------------------------------------------
    # ● 初始化对象
    #------------------------------------------------------------------------
    def initialize(*gold_window) # <= 不要动这里
      #  gold_window用于传递Scene_Menu中@gold_window，借以确定菜单中的位置
      #  即使不使用gold_window，也不要去掉(*gold_window)，因为Scene_Menu仍会
      # 将参数传递给initialize（通过Window_MoVMe.new）
      super(0, gold_window[0].y - 110, gold_window[0].width, 110)
      draw_text(0, 0, 200, 25, MoVTData::Chro + 
        "#{$game_variables[MoVTData::TimV[0]]}年" +
          "#{$game_variables[MoVTData::TimV[1]]}月" +
            "#{$game_variables[MoVTData::TimV[2]]}日")
      draw_text(0, 30, 130, 25, MoVTData::Weeks[MoVTData.wday], 2)
      draw_text(0, 60, 160, 25,
        format("%02d:", $game_variables[MoVTData::TimV[3]]) +
          format("%02d  ",$game_variables[MoVTData::TimV[4]]) + MoVTData.vtz)
      draw_icon(MoVTData::Icon, 0, 30) if MoVTData::Icon != 0
    end
  end
  #============================================================================
  # ■ Window_MoVCh
  #----------------------------------------------------------------------------
  # 　地图画面中，显示当前游戏内部虚拟时间的窗口
  #============================================================================
  class Window_MoVCh < Window_Base
    #------------------------------------------------------------------------
    # ● 初始化对象
    #------------------------------------------------------------------------
    def initialize
      if MoVTData::CalOnTop
        super(0, 0, Graphics.width, 48)
      else
        super(0, Graphics.height - 48, Graphics.width, 48)
      end
    end
    #------------------------------------------------------------------------
    # ● 更新画面
    #------------------------------------------------------------------------
    def update
      refresh if Graphics.frame_count % Spe == 0
    end
    #------------------------------------------------------------------------
    # ● 刷新
    #------------------------------------------------------------------------
    def refresh
      contents.clear
      if MoVTData::Icon != 0
        draw_icon(MoVTData::Icon,0,0)
        draw_text(30, 0, 400, 25,MoVTData::Chro +
          "#{$game_variables[MoVTData::TimV[0]]}年" +
            "#{$game_variables[MoVTData::TimV[1]]}月" +
              "#{$game_variables[MoVTData::TimV[2]]}日" + " " +
                MoVTData::Weeks[MoVTData.wday])
        draw_text(320, 0, 160, 25,
          format("%02d",$game_variables[MoVTData::TimV[3]]) + ":" +
            format("%02d",$game_variables[MoVTData::TimV[4]]) + " " +
              MoVTData.vtz, 2)
      else
        draw_text(0, 0, 400, 25,MoVTData::Chro +
          $game_variables[MoVTData::TimV[0]].to_s + "年" +
            $game_variables[MoVTData::TimV[1]].to_s + "月" +
              $game_variables[MoVTData::TimV[2]].to_s + "日" + " " +
                MoVTData::Weeks[MoVTData.wday])
        draw_text(400, 0, 160, 25,
          format("%02d",$game_variables[MoVTData::TimV[3]]) + ":" +
            format("%02d",$game_variables[MoVTData::TimV[4]]) + " " +
              MoVTData.vtz, 2)
      end # if MoVTData::Icon != 0
    end # def refresh
  end # class Window_MoVCh
end # module MoVTData

#=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+#
#------------------------------------------------------------------------------#
#                               请勿跨过这块区域                                #
#------------------------------------------------------------------------------#
#+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=#

#==============================================================================
# ■ MoVTData
#==============================================================================
module MoVTData
  def self.ini
    $game_variables[TimV[0]] = Sta_Y
    $game_variables[TimV[1]] = Sta_M
    $game_variables[TimV[2]] = Sta_D
    $game_variables[TimV[3]] = Sta_H
    $game_variables[TimV[4]] = Sta_I
    @wday = Sta_WDay
    @vtz = ""
    @ttone = nil
    check_vtz
  end
  
  def self.refresh
    return if $game_message.visible
    return if $game_switches[Pause]
    $game_variables[TimV[4]] += 1
    if $game_variables[TimV[4]] >= HM
      $game_variables[TimV[4]] = 0
      $game_variables[TimV[3]] += 1
      if $game_variables[TimV[3]] >= DH
        $game_variables[TimV[3]] = 0
        $game_variables[TimV[2]] += 1
        @wday += 1
        @wday = 0 if @wday >= Weeks.size - 1
        if $game_variables[TimV[2]] >= MD
          $game_variables[TimV[2]] = 0
          $game_variables[TimV[1]] += 1
          if $game_variables[TimV[1]] >= YM
            $game_variables[TimV[1]] = 0
            $game_variables[TimV[0]] += 1
          end
        end
      end
    end
    check_vtz
    cdaynight if DayNight
  end
  
  def self.check_vtz
    case ($game_variables[TimV[3]] * HM + $game_variables[TimV[4]]) * 1440
    when VTTone[:Dawn][0] * DH * HM..VTTone[:Morn][0] * DH * HM
      @ttone = VTTone[:Dawn][1]
      @vtz = VTTone[:Dawn][2]
    when VTTone[:Morn][0] * DH * HM..VTTone[:Noon][0] * DH * HM
      @ttone = VTTone[:Morn][1]
      @vtz = VTTone[:Morn][2]
    when VTTone[:Noon][0] * DH * HM..VTTone[:Aftr][0] * DH * HM
      @ttone = VTTone[:Noon][1]
      @vtz = VTTone[:Noon][2]
    when VTTone[:Aftr][0] * DH * HM..VTTone[:Sset][0] * DH * HM
      @ttone = VTTone[:Aftr][1]
      @vtz = VTTone[:Aftr][2]
    when VTTone[:Sset][0] * DH * HM..VTTone[:Nigt][0] * DH * HM
      @ttone = VTTone[:Sset][1]
      @vtz = VTTone[:Sset][2]
    when VTTone[:Nigt][0] * DH * HM..1440 * DH * HM
      @ttone = VTTone[:Nigt][1]
      @vtz = VTTone[:Nigt][2]
    when 0..VTTone[:Dark][0] * DH * HM
      @ttone = VTTone[:Nigt][1]
      @vtz = VTTone[:Nigt][2]
    when VTTone[:Dark][0] * DH * HM..VTTone[:Dawn][0] * DH * HM
      @ttone = VTTone[:Dark][1]
      @vtz = VTTone[:Dark][2]
    end
  end
  def self.cdaynight(t = 60)
    return if !$game_map
    return if !SceneManager::scene_is?(Scene_Map)
    if InDoors.include?($game_map.map_id)
      $game_map.screen.start_tone_change(Tone.new(0,0,0,0),0)
    else
      $game_map.screen.start_tone_change(@ttone, t)
    end
  end
  def self.vtz
    @vtz
  end
  def self.vtz=(vtz)
    @vtz = vtz
  end
  def self.wday
    @wday
  end
  def self.wday=(wday)
    @wday = wday
  end
end
#==============================================================================
# ■ Scene_Menu
#==============================================================================
class Scene_Menu
  alias motstt start
  def start
    motstt
    @movtime_window = MoVTData::Window_MoVMe.new(@gold_window)if MoVTData::WinOn
  end
end

#==============================================================================
# ■ Scene_Map
#==============================================================================
class Scene_Map
  alias motudt update
  alias motptr post_transfer
  alias motcaw create_all_windows
  def update
    motudt
    MoVTData.refresh
  end
  def post_transfer
    MoVTData.cdaynight(0)
    motptr
  end
  def create_all_windows
    motcaw
    @vtchr = MoVTData::Window_MoVCh.new if MoVTData::CalOn
  end
end
#==============================================================================
# ■ DataManager
#==============================================================================
class << DataManager
  alias motsng setup_new_game
  alias motmsc make_save_contents
  alias motesc extract_save_contents
  def setup_new_game
    motsng
    MoVTData.ini
  end
  def make_save_contents
    contents = motmsc
    contents[:vwday] = MoVTData.wday
    contents[:vwvtz] = MoVTData.vtz
    contents
  end
  def extract_save_contents(contents)
    motesc(contents)
    MoVTData.wday = contents[:vwday]
    MoVTData.vtz = contents[:vwvtz]
  end
end

#==============================================================================#
#=====                        =================================================#
#          ■ 脚 本 尾
#=====                        =================================================#
#==============================================================================#
