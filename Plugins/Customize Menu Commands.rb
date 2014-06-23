#==============================================================================
# ■ 自定义菜单
#  作者：影月千秋
#  适用：VA
#------------------------------------------------------------------------------
# ● 简介
#  在菜单中插入一些自定义的命令，可以执行特定的语句
#  可以用来调用其他脚本、提示游戏信息等
#==============================================================================
# ● 使用方法
#   将此脚本插入到其他脚本以下，Main以上，在下方进行相关设置即可
#==============================================================================
# ● 更新
#   V 1.2 2014.06.23 提升兼容性
#   V 1.1 2014.04.25 修正过程无法获取变化信息的bug
#   V 1.0 2014.01.23 新建
#==============================================================================
# ● 声明
#   本脚本来自【影月千秋】，使用、修改和转载请保留此信息
#==============================================================================

$smomo ||= {}
if $smomo["CustomizeMenuCommands"].nil?
$smomo["CustomizeMenuCommands"] = true

#==============================================================================
# ■ Smomo
#==============================================================================
module Smomo
  #============================================================================
  # ■ Smomo::CustomizeMenuCommands
  #============================================================================
  module CustomizeMenuCommands
    Error_box = false
    # 出错时，报错是否使用提示框，如果不使用，则在控制台输出
    Refresh = true
    # 每次执行命令后 是否刷新菜单各窗口 如果你的命令改变了某些值(比如金钱) 最好刷新
    # 此功能一般不会影响效率 但如果感觉卡顿 可以设为false以禁用
    Command = [ # do not touch
    #---------------------------------------------------------------------->|
    #·填写格式
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~>|
    # ["<位置>,<名称>",%Q!<过程>},<变量>!,
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~>|
    #
    # 引号、逗号、方括号（中括号）、花括号（大括号）均为英文半角符号
    # 尖括号不用写
    # 结尾处有一个逗号
    #
    # 位置：从上往下数的位置，初始为0
    #       如果超出了指令个数 会排在指令最后
    # 名称：在菜单中显示的名称
    # 过程：合法的RGSS3语句，如果不填，这个按钮就没有任何实际意义
    # 变量：当此变量值为0，按钮可用；为1，不可用；为2，不可见。可以不指定变量
    #       这样按钮会一直可用
    #
    #---------------------------------------------------------------------->|
    #·例
    # [3,"点我",%Q!msgbox "你好！"!],
    #---------------------------------------------------------------------->|
    # 比较常用的调用语句
    #  $game_party.gain_item($data_items[编号],数量) ~~~~~获得物品
    #  $game_party.gain_item($data_weapons[编号],数量) ~~~~~获得武器
    #  $game_party.gain_item($data_armors[编号],数量) ~~~~~获得防具
    #  $game_temp.reserve_common_event(编号) ~~~~~呼出公共事件
    #  $game_switches[编号] = true 或 false ~~~~~开启或关闭开关
    #  $game_variables[编号] = 数值 ~~~~~设置变量
    #  DataManager.save_game(档位) ~~~~~存档
    #  DataManager.load_game(档位) ~~~~~读档
    #  SceneManager.call(场景) ~~~~~打开场景，如Scene_Save存档 Scene_Load读档
    # 其他任何合法的RGSS3语句都可以使用
    #---------------------------------------------------------------------->|
    # 下面有两个模板，你可以直接复制并填写，最大限度避免出错
    # （把光标停在某行  按Ctrl+D可以复制此行  Ctrl+Q可以注释/撤销注释）
    #---------------------------------------------------------------------->|
    #·模板
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~>|
#~       [位置,"按钮名",%Q!过程!,变量ID],
#~       [位置,"按钮名",%Q!过程!],

    # 下面这些是例子，当你自己使用时应该删去
      [5,"※读档界面",%Q!SceneManager.call(Scene_Load)!,2],
      [6,"※失败例子",], # 这个例子没有写过程
      [7,"※出错例子",%Q!哈哈哈!], # 这个例子中的过程不是合法语句
      [4,"※特别说明",%Q!msgbox "虽然例子中所有的按钮都有一个※，但这不是
必须的"!],
      [5,"※特殊情况",%Q!msgbox "注意！如果有两个按钮使用了同一个位置ID，
其中一个不会显示"!],
      [111,"※获得金钱",%Q!$game_party.gain_gold(10000);msgbox "拿钱！"
msgbox "多个语句间用英文半角分号;分开就可以正常运行，或者干脆分两行写\n像这样"!],


#=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+#
#-------------                     --------------------------------------------#
               "请勿跨过这块区域"
#-------------                     --------------------------------------------#
#+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=#
      ["Close the array"]
      ] # close the array
    Command.pop
    Command.uniq!
    Command.sort!
    Error_msg = "脚本 MoCustomizeMenuCommands 参数填写非法!\n"
    Error_met = Error_box ? method(:msgbox) : method(:print)
    key_error = false
    Command.each_with_index do |cmd,i|
      if cmd.size > 1 && cmd.size < 5 && cmd[0].is_a?(Integer) &&
      cmd[1].is_a?(String)
        unless cmd[2].is_a?(String)
          Error_met.call Error_msg + "第#{i}个参数,内容:\n#{cmd}\n未填写过程\n"
          cmd[2] = %Q!Error_met.call "未填写过程\n"}!
        end # unless
      else
        Error_met.call Error_msg + "第#{i}个参数,内容:\n#{cmd}\n数量或类型错误\n"
        key_error = true
      end # if
    end # Command
    exit if key_error
  end # module CustomCommand
end # module Smomo

#==============================================================================
# ■ Window_MenuCommand
#==============================================================================
class Window_MenuCommand
  #--------------------------------------------------------------------------
  # ● 生成指令列表
  #--------------------------------------------------------------------------
  alias :mo_mk_cmd_list_cus :make_command_list unless
  defined?(:mo_mk_cmd_list_cus)
  def make_command_list
    mo_mk_cmd_list_cus
    mo_add_cus_commands rescue Smomo::CustomizeMenuCommands::Error_met.
    call "脚本 MoCustomizeMenuCommands 出错!\n未知错误\n"
  end
  #--------------------------------------------------------------------------
  # ● 添加自定义指令
  #--------------------------------------------------------------------------
  def mo_add_cus_commands
    mo_addon_cmds = Smomo::CustomizeMenuCommands::Command.clone
    return if mo_addon_cmds.empty?
    # 删除无效指令
    mo_addon_cmds.reject!{|cmd|!cmd[3].nil? &&
    ![0,1].include?($game_variables[cmd[3]])}
    # 创建临时变量 寄存原列表
    list = @list.clone
    # 获取列表长度 创建新列表
    @list = Array.new(size = list.size + mo_addon_cmds.size)
    # 若在列表范围之内 则添加指令(允许覆盖)
    mo_addon_cmds.each{|cmd|@list[cmd[0]] = {:name=>cmd[1],
    :symbol=>eval(":mo_cus_add_mcmds#{cmd[0]}"),
    :enabled=>cmd[3].nil? || $game_variables[cmd[3]] == 0,
    :ext=>cmd[2]} if cmd[0] < size}
    # 删除已添加的指令(舍弃被覆盖指令)
    mo_addon_cmds.reject!{|cmd|cmd[0]<size}
    # 合并原列表 不应存在遗漏
    @list.each_with_index{|cmd, index|@list[index] = list.shift if cmd.nil?}
    # 若有遗漏的项目（位置超出范围或被覆盖） 先删除nil元素 再添加指令
    @list.compact!
    mo_addon_cmds.reject!{|cmd|add_command(cmd[1],
    eval(":mo_cus_add_mcmds#{cmd[0]}"),
    cmd[3].nil? || $game_variables[cmd[3]] == 0, cmd[2])}
  end # def
end # class Window_MenuCommand

#==============================================================================
# ■ Scene_Menu
#==============================================================================
class Scene_Menu
  #--------------------------------------------------------------------------
  # ● 生成指令窗口
  #--------------------------------------------------------------------------
  alias :mo_cre_cmd_win_cus :create_command_window unless
  defined?(:mo_cre_cmd_win_cus)
  def create_command_window
    mo_cre_cmd_win_cus
    Smomo::CustomizeMenuCommands::Command.each do |cmd|
      eval("@command_window.set_handler(:mo_cus_add_mcmds#{cmd[0]},
      method(:mo_cus_add_cmd_call))")
    end
  end
  #--------------------------------------------------------------------------
  # ● 执行自定义指令
  #--------------------------------------------------------------------------
  def mo_cus_add_cmd_call
    eval(@command_window.current_ext) rescue
    Smomo::CustomizeMenuCommands::Error_met.
    call "脚本 MoCustomizeMenuCommands 参数填写非法!\n错误的过程\n"
    if SceneManager.scene_is?(Scene_Menu)
      instance_variables.each do |varname|
        ivar = instance_variable_get(varname)
        ivar.refresh if ivar.is_a?(Window) rescue ivar.update
      end if Smomo::CustomizeMenuCommands::Refresh
      @command_window.activate
    end
  end
end

else # if $smomo["CustomizeMenuCommands"].nil?
  msgbox "请不要重复加载此脚本 ：）\n（CustomizeMenuCommands）"
end # if $smomo["CustomizeMenuCommands"].nil?
#==============================================================================#
#=====                        =================================================#
           "脚 本 尾"
#=====                        =================================================#
#==============================================================================#
