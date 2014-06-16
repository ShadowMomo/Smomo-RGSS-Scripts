#==============================================================================
# ■ 自动存档
#  作者：影月千秋
#  版本：V 1.7
#  最近更新：2014.04.07
#  适用：VA
#  要求：Smomo脚本核心
#------------------------------------------------------------------------------
# ● 简介
#  在很多解谜、生存、养成类游戏中，不需要玩家主动存档，而是由系统自动保存进度，这时
# 就可以使用此脚本
#  你可以设定脚本，使每次场所移动时自动存档（记录场景），也可以通过下面的事件脚本，
# 配合其他时间系统使用（记录时间），根据你的设定，还可以做其他用途
#  本脚本需要Smomo脚本核心，请到此下载：http://tinyurl.com/l9kvg2p
#  如果链接失效，请到bbs.66rpg.com，@余烬之中 或 @影月千秋
#==============================================================================
# ● 使用方法
#  将此脚本插入到其他脚本以下，Main以上
#  在下面进行相关设定，就可以达成基本使用效果
#  另外：
#   在事件中使用脚本：
#    Smomo.autosave(type, value)
#     type为一符号 可以是
#        :save 进行自动存档 会覆盖原自动存档文件
#        :load 读取自动存档
#        :kill 删除自动存档文件
#      此时value不必填写
#     type也可以是下面设定中的符号之一 此时脚本用于调整对应的设置
#      value即为设置的值
#     例：
#      Smomo.autosave(:load)      进行读档
#      Smomo.autosave(:SaveID, 9) 将存档号改为9（原存档文件未跟随移动）
#     也可以把value写为【:get】
#     这样就可以取得对应的项目
#     例：
#      Smomo.autosave(:ReadAllowed, :get) 获取ReadAllowed的信息
#==============================================================================
# ● 更新
#   V 1.7 2014.04.07 规范化脚本 纳入Smomo登记 需要依赖Smomo脚本核心
#   V 1.6 2013.12.22 修正算法 规范化脚本
#   V 1.5 2013.10.05 小修改，降低和其他脚本冲突的可能 新增功能
#   V 1.4 2013.10.04 新增功能
#   V 1.3 2013.09.28 小修改
#   V 1.2 2013.09.20 修正$ADSLO无效的BUG 添加详细备注
#   V 1.0 2013.09.19 新建 公开
#==============================================================================
# ● 声明
#   本脚本来自【影月千秋】，使用、修改和转载请保留此信息
#==============================================================================

if $smomo["Core"].nil? || $smomo["Core"] < 1.0
  msgbox "请先安装Smomo脚本核心！"; %x!start http://tinyurl.com/l9kvg2p!
elsif $smomo["AutoSave"].nil?
$smomo["AutoSave"] = true

#===============================================================================
# ■ Smomo
#===============================================================================
module Smomo
  #=============================================================================
  # ■ Smomo::AutoSave
  #=============================================================================
  class AutoSave
    attr_accessor :sets
    def initialize
      @sets = {
        LoadWhenStart: true,
        # 开始新游戏时是否自动读档
      
        ContinueShow: false,
        # 标题画面中是否提供“继续游戏”选项
         # 仅当 LoadWhenStart 不生效时生效
        
        ContinueName: "继续游戏",
        # “继续游戏”按钮的名字
         # 仅当 ContinueShow 生效时生效
      
        ContinueSetFocus: true,
        # 标题菜单中 是否自动把光标设在“继续游戏”上
         # 仅当 ContinueShow 生效时生效
      
        ReadAllowed: false,
        # 自动存档是否遵循一般存档命名规则
         # 遵循时，允许在读档界面读取自动存档内容
      
        SaveID: 3,
        # 存档号 0对应第一个存档 1对应第二个 依此类推
         # 仅当 ReadAllowed 为 生效时生效
      
        CrossMapAutoSave: true,
        # 场所移动时是否自动存档
      
        GameOverKillFile: true,
        # 事件【结束游戏】时是否删除自动存档
      
        GameCompleteKillFile: true,
        # 事件【返回标题画面】时是否删除自动存档
      
#=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+#
#------------------------------------------------------------------------------#
#                               请勿跨过这块区域                                #
#------------------------------------------------------------------------------#
#+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=#
        Saving: false
      }
    end
  end
  #--------------------------------------------------------------------------
  # ● 进行自动存档
  #--------------------------------------------------------------------------
  def self.autosave(type, value = nil)
    case type
    when :save
      DataManager.mo_auto_save_game
    when :load
      if DataManager.mo_auto_load_game
        SceneManager.scene.fadeout_all
        $game_system.on_after_load
        SceneManager.goto(Scene_Map)
      end
    when :kill
      DataManager.mo_autosave_file_kill
    else
      value == :get ? $mo_autosave[type] : ($mo_autosave[type] = value)
    end
  end
end
#==============================================================================
# ■ DataManager
#==============================================================================
class << DataManager
  _def_ :create_game_objects do |*args|
    $mo_autosave = load_data("Data/MoAutosaveSets.rvdata2") rescue
    Smomo::AutoSave.new.sets
  end

  def mo_autosave_save_sets
    save_data($mo_autosave, "Data/MoAutosaveSets.rvdata2")
  rescue
    File.delete("Data/MoAutosaveSets.rvdata2") rescue nil
  end

  _def_ :make_filename, :v do |old, *args|
    $mo_autosave[:Saving] && !$mo_autosave[:ReadAllowed] ? 
    old.gsub(/save\d+/i){"MoAutoSave"} : old
  end

  _def_ :save_game, :b do |*args| mo_autosave_save_sets end

  def mo_auto_save_game
    $mo_autosave[:Saving] = true
    save_game($mo_autosave[:SaveID])
    $mo_autosave[:Saving] = false
  end

  def mo_auto_load_game
    $mo_autosave[:Saving] = true
    s = Dir.glob(make_filename($mo_autosave[:SaveID])).empty? ? false : 
    [load_game($mo_autosave[:SaveID])]
    $mo_autosave[:Saving] = false
    s
  end

  def mo_autosave_file_kill
    $mo_autosave[:Saving] = true
    File.delete(make_filename($mo_autosave[:SaveID])) rescue nil
    $mo_autosave[:Saving] = false
  end
end
#==============================================================================
# ■ Game_Interpreter
#==============================================================================
class Game_Interpreter
  _def_ :command_353, :b do |*args| Smomo.autosave(:kill) end
  _def_ :command_354, :b do |*args| Smomo.autosave(:kill) end
end
#==============================================================================
# ■ Window_TitleCommand
#==============================================================================
class Window_TitleCommand
  _def_ :initialize do |*args|
    (select_symbol(:mo_auto_save_continue) if
    mo_auto_save_continue_enabled) rescue nil
  end

  _def_ :make_command_list do |*args|
    add_command($mo_autosave[:ContinueName], :mo_auto_save_continue,
    mo_auto_save_continue_enabled) if !$mo_autosave[:LoadWhenStart] &&
    $mo_autosave[:ContinueShow]
  end

  def mo_auto_save_continue_enabled
    $mo_autosave[:Saving] = true
    enabled = !Dir.glob(DataManager.make_filename($mo_autosave[:SaveID])).empty?
    $mo_autosave[:Saving] = false
    enabled
  end
end
#==============================================================================
# ■ Scene_Title
#==============================================================================
class Scene_Title
  _def_ :create_command_window do |*args|
    @command_window.set_handler(:mo_auto_save_continue,
    lambda{Smomo.autosave(:load)})
  end
  
  _def_ :command_new_game, :c do |old, *args, &block|
    return Smomo.autosave(:load) if $mo_autosave[:LoadWhenStart] &&
    @command_window.mo_auto_save_continue_enabled
    old.call(*args, &block)
  end
end
#==============================================================================
# ■ Scene_Map
#==============================================================================
class Scene_Map
  _def_ :perform_transfer do |*args|
    Smomo.autosave(:save) if $mo_autosave[:CrossMapAutoSave]
  end
end

else # if $smomo
  msgbox "请不要重复加载此脚本 : )\n【自动存档 MoAutoSave】"
end
#==============================================================================#
#=====                        =================================================#
           "■ 脚 本 尾"
#=====                        =================================================#
#==============================================================================#
