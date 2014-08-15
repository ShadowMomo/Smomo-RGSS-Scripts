#==============================================================================
# ** 快捷调试工具 Debug Kit for Scripters
#------------------------------------------------------------------------------
# * 主要功能
#  * 跳过标题
#  * 快速注释一整段脚本
#  * 事件脚本出错时正确定位到脚本框
#  * 缺少素材时弹框提示，但并不退出游戏
#  * 异常堆栈（不常用）
#------------------------------------------------------------------------------
# * 使用说明
#  * 将该脚本插入到所有脚本的最上方
#  * 对于要注释的脚本，在左下角的脚本名上追加一个前缀（默认为"#"）即可
#     例如：Scene_Map -> #Scene_Map
#       则该脚本内所有内容都不会生效
#------------------------------------------------------------------------------
# * 跳过标题的设定项
  skiptitle = true # 是否跳过标题
#------------------------------------------------------------------------------
# * 事件脚本出错定位的设定项
  eventbinding = true # 是否启用
#------------------------------------------------------------------------------
# * 快捷注释的设定项
  easydisable = [
    /^#(.*)/, # 用于匹配脚本名的正则式
    true      # 是否在控制台显示已经被屏蔽的脚本
  ]
#------------------------------------------------------------------------------
# * 缺少素材提示的设定项
  nofilemsg = true # 是否启用缺少素材的提示
#------------------------------------------------------------------------------
# * 异常堆栈
  exceptionstack = true # 是否启用异常堆栈
#  发生异常时 如果使用了指定的后缀进行修饰 可以将异常捕获 并不报错
#  捕获的异常会压入一个堆栈 可以重抛出
#  生效范围：本脚本以下，因此建议将本脚本放在所有脚本的最上方
#   可使用的修饰：
#     rescue! 捕获错误并压入栈中
#       例子：
#         raise "Error" rescue!
#         # 不抛出异常
#     rescue: alt
#     rescue; alt
#     rescued. alt
#       捕获错误 同时用alt的值来替代之前的值 可以不填写alt（形如 rescue:）
#       例子：
#         a = 1 / 0 rescue: 5
#         puts a    #=> 5
#         b = 9 / 0 rescued.
#         puts b    #=> nil
#   可使用的方法：
#     exlast 抛出上一个压入栈中的异常对象 如果栈空 返回true
#     weaken{...} 弱化异常
#     reraise(ex) 将异常对象抛出
#     exstore 将上一个异常对象压入栈中
#     expush(alt=nil) 压栈并返回alt
#   默认的捕捉只能捕捉标准异常 某些异常不能被捕捉
#   这时请使用【weaken{原语句} rescue!】的形式（或者rescue: rescue; rescued.）
#==============================================================================

mainscript = $RGSS_SCRIPTS.find do |script|
  script[3] =~ /rgss_main/ && script[3] !~ /e2fa8436e6a77aef37280d72ef68105e/
end


puts "================================" if easydisable[1]

easydisable[2] = []
$RGSS_SCRIPTS.each do |script|
  if script[1] =~ easydisable[0]
    script[3] = "# Disabled"
    easydisable[2].push $1
  else
    script[3].gsub!(/rescue!/){"rescue exstore "}
    script[3].gsub!(/rescue(:|;|d\.)/){"rescue expush "}
  end
end

puts  easydisable[2], "       上述脚本已被禁用。" if easydisable[1]
puts "================================" if easydisable[1]
puts

if skiptitle
  function = %Q!class Scene_Title
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
    def transition_speed
      0
    end
  end;!
  mainscript[3] = function + mainscript[3]
end

if eventbinding
  function = %Q!class Game_Interpreter
    def command_355
      script = @list[@index].parameters[0] + "\n"
      while next_event_code == 655
        @index += 1
        script += @list[@index].parameters[0] + "\n"
      end
      eval(script, binding)
    end
  end;!
  mainscript[3] = function + mainscript[3]
end

if nofilemsg
  class << Bitmap
    alias :debug_kit_for_scripters_new :new
    def new(*args)
      debug_kit_for_scripters_new(*args)
    rescue Errno::ENOENT
      msgbox "图像文件[#{ args[0] }]未找到！"
      debug_kit_for_scripters_new(1, 1)
    rescue RGSSError
      debug_kit_for_scripters_new(1, 1)
    end
  end
  class << Audio
    [:bgm, :bgs, :me, :se].each do |sym|
      eval %Q!
        alias :debug_kit_for_scripters_#{sym}_play :#{sym}_play
        def #{sym}_play(*args)
          debug_kit_for_scripters_#{sym}_play(*args)
        rescue Errno::ENOENT
          msgbox "音频文件[\#{ args[0] }]未找到！"
          #{ sym == :se ? "" : "#{sym}_stop" }
        end
      !
    end
  end
  class << Graphics
    alias :debug_kit_for_scripters_play_movie :play_movie
    def play_movie(*args)
      debug_kit_for_scripters_play_movie(*args)
    rescue Errno::ENOENT
      msgbox "视频文件[#{ args[0] }]未找到！"
    end
  end
end

if exceptionstack
  module Reraise
    $exstack = []
    # reraise
    def reraise ex
      raise ex.class, ex.message, ex.backtrace
    end
    # exstore
    def exstore
      $exstack.push $!
    end
    # expush
    def expush alt = nil
      exstore
      alt
    end
    # exlast
    def exlast
      return true if $exstack.empty?
      reraise $exstack.pop
    end
    # weaken
    def weaken
      yield if block_given?
    rescue StandardError => ex
      raise
    rescue Exception => ex
      raise StandardError, ex.message, ex.backtrace
    ensure
      $@.slice!(0, 2) if $@
    end
  end
  
  include Reraise
end
