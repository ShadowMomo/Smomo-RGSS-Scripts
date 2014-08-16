#==============================================================================
# ** 找不到文件时报错降格为警告
# 影月千秋
#==============================================================================
module NoFileWarning
  Append = "请联系作者：webmaster@example.com。为您造成的不便我深感抱歉。"
  # 找不到文件时，提醒的附加信息
  Met = defined?(msgbox) ? method(:msgbox) : method(:p)
end
#==============================================================================
# ** Bitmap
#==============================================================================
class << Bitmap
  alias :debug_kit_for_scripters_new :new
  def new(*args)
    debug_kit_for_scripters_new(*args)
  rescue Errno::ENOENT
    NoFileWarning::Met.("图像文件[#{args[0]}]未找到！#{NoFileWarning::Append}")
    debug_kit_for_scripters_new(1, 1)
  end
end
#==============================================================================
# ** Audio
#==============================================================================
class << Audio
  [:bgm, :bgs, :me, :se].each do |sym|
    eval %Q!
      alias :debug_kit_for_scripters_#{sym}_play :#{sym}_play
      def #{sym}_play(*args)
        debug_kit_for_scripters_#{sym}_play(*args)
      rescue Errno::ENOENT
        NoFileWarning::Met.("音频文件[\#{args[0]}]未找到！" +
        NoFileWarning::Append)
        #{ sym == :se ? "" : "#{sym}_stop" }
      end
    !
  end
end
#==============================================================================
# ** Graphics
#==============================================================================
class << Graphics
if defined?(msgbox)
  alias :debug_kit_for_scripters_play_movie :play_movie
  def play_movie(*args)
    debug_kit_for_scripters_play_movie(*args)
  rescue Errno::ENOENT
    NoFileWarning::Met.("视频文件[#{args[0]}]未找到！#{NoFileWarning::Append}")
  end
end
end