#==============================================================================
# ** Smomo脚本核心
#  作者：影月千秋
#------------------------------------------------------------------------------
# * 简介
#  Smomo脚本的核心，提供了一些常用功能，有些脚本需要依靠此脚本以正常工作
#------------------------------------------------------------------------------
# * 使用方法
#  插入到其他Smomo脚本上方
#------------------------------------------------------------------------------
# * 更新
#   V 1.41 2014.06.21 加入shell_execute系列
#   V 1.4  2014.06.20 加入括号匹配
#   V 1.3  2014.06.14 mail并入register 加入两个api moveAE优化并更名transition
#   V 1.2  2014.06.11 优化text_size的处理 为Smomo::Kit新增功能mail
#   V 1.1  2014.05.10 新方法：Smomo.traverse_dir
#   V 1.0  2014.04.05 新建
#------------------------------------------------------------------------------
# * 声明
#   本脚本来自"影月千秋", 使用/修改/转载请保留此信息
#==============================================================================

$smomo ||= {}
if $smomo["Core"].nil? || $smomo["Core"] < 1.41
$smomo["Core"] = 1.41

$smomo["RGSS Version"] =
  defined?(Audio.setup_midi) ? :VA : defined?(Graphics.wait) ? :VX : :XP

#==============================================================================
# ** Smomo!module_function
#----------------------------------------------------------------------------
# * text_size(str, font = nil) 确定合适的文字大小(Rect矩形类)
# 
# * transition(object, attribute) 属性值的过渡渐变 返回一个渐变对象signal
#     object: 被操作的对象   attribute: 进行变换属性名
#   signal对象：
#     * target(value, duration = 1) 在duration帧内变换为value
#         如果正在变换中 则将该变换添加至原变换后 顺次执行
#         指令添加成功 返回true 否则false
#     * turn 改变变换方向 本质上是将指令队列反向执行
#     * lock(state = :switch) 锁定/解锁  可以使用参数 :on 和 :off
#         锁定状态下 会完成当前变换 但不再接受新的指令
#     * clear 停止移动 并清空指令队列
#     * kill 删除该signal对象
#     * arrived? 判定是否到达终点 判定条件和变换方向有关
#     * update 执行更新 不需要手动调用
#     如果被操作的属性不能读写 对应的signal对象将自动报废 不响应任何方法
#     返回值均为 nil
# 
# * shell_execute 使用API调用外部程序打开文件或超链接
#   参数说明
#     * hwnd 整型 为用于展现用户接口或者错误信息的父窗口句柄 可以为空
#     * lpOperation 字符串 操作模式
#       可以使用的值 均可以顾名思义
#       "edit" "explore" "find" "open" "print"
#       可以为空 意味着默认方式 如果未定义默认方式 使用"open"
#     * lpFile 字符串 被操作的文件或超链接
#     * lpParameters 字符串 传递给所调用程序的参数
#     * lpDirectory 字符串 行为的默认工作目录
#     * nShowCmd 整型 标识应用程序应该如何被打开
#       可以使用的值及意义
#       0 隐藏 1 正常大小 2 激活并最小化 3 最大化 4 不激活 5 激活 6 最小化
#       7 最小化但仍保持激活 8 保持当前状态 9 激活并恢复正常大小 10 根据环境变量
#       请注意 这些值单纯的发送给被调用者 具体如何处理由被调用者决定
#   返回值
#     大于32时，操作成功，否则失败
# 
# * quick_shell 快速调用shell_execute 改变了参数顺序 设置了默认值
#   新的参数顺序及默认值
#     lpFile 无默认值
#     lpOperation "open"  nShowCmd 1  hwnd 0  lpParameters ""  lpDirectory ""
# 
# * web(url = "") 调用浏览器打开网页
# 
# * deep_clone(obj) 深度复制对象
# 
# * traverse_dir(file_path = "."){} 遍历目录
# 
# * mBrackets(str, brackets = {'(' => ')', '[' => ']', '{' => '}', '<' => '>'})
#   对字符串进行括号匹配
#============================================================================
module Smomo
  module_function
  
  # text_size
  def text_size(str, font = nil)
    tmp = Window_Base.new(Graphics.width, 0, Graphics.width, 1)
    tmp.reset_font_settings
    tmp.contents.font = font if font
    width = 0
    pos = {x: 0, y: 0, height: tmp.calc_line_height(str)}
    str.each_line do |s|
      s.gsub!(/[\n]/){""}
      tmp.process_character(s.slice!(0, 1), s, pos) until s.empty?
      width = [pos[:x], width].max
      pos[:x] = 0
      pos[:y] += pos[:height]
      pos[:height] = tmp.calc_line_height s
    end
    Rect.new 0, 0, width, pos[:y]
  end
  
  # transition
  def transition(object, attribute)
    ::Smomo::Kit.register[:transition].push signal = Object.new
    # Class Signal
    class << signal
      # target
      def target(value, duration = 1)
        return false if @lock
        @targets[-1][0] = (@current = @object.send(@attribute).to_f).to_i if
        @targets.size == 1
        @targets[-1][1] = @targets[-1][2] =
        duration.round == 0 ? 1 : duration.round
        @targets.push [value.round]
        return true
      end
      # turn
      def turn
        @position -= 1 if @direction == 1 && @position == @targets.size - 1
        @position += 1 if @direction == -1 && @position == -1
        @targets.each{|e| e[2] = e[1] - e[2] unless e[1].nil?}
        @direction = -@direction
      end
      # lock
      def lock(state = :switch)
        @lock = state == :on ? true : state == :off ? false : !@lock
      end
      # update
      def update
        return if @targets.size == 1
        return if arrived?
        @object.send "#{@attribute}=", @current +=
        (@targets[@position + (@direction == 1 ? 1 : 0)][0] - @current).to_f /
        @targets[@position][2]
        @targets[@position][2] -= 1
        if @targets[@position][2] == 0
          @position += @direction
          @object.send "#{@attribute}=", @current =
          @targets[@position + (@direction == 1 ? 0 : 1)][0].to_f
        end
      rescue RGSSError
        kill
      end
      # clear
      def clear
        @direction = 1
        @targets = [[@position = @current = 0]]
      end
      # arrived?
      def arrived?
        @position == (@direction == 1 ? @targets.size - 1 : -1)
      end
      # kill
      def kill
        dead = Object.new
        class << dead; def method_missing *args; end; end
        ::Smomo::Kit.register[:transition][@uid] = dead
      end
      # init
      def init object, attribute, uid
        clear
        @lock, @object, @attribute, @uid = false, object, attribute, uid
      end
    end # Class Signal
    signal.init object, attribute, ::Smomo::Kit.register[:transition].size - 1
    class << signal; undef init; end
    signal
  end
    
  # shell_execute
  def shell_execute(*args)
    __api "Shell32|ShellExecute|ippppi|i".call *args
  end
  
  # quick_shell
  def quick_shell(f, o = "open", n = 1, h = 0, p = "", d = "")
    shell_execute h, o, f, p, d, n
  end
  
  # web
  def web(url = "")
    quick_shell(url)
  end
  
  # deep_clone
  def deep_clone(obj)
    Marshal.load Marshal.dump obj
  end
    
  # traverse_dir
  def traverse_dir(file_path = ".")
    return unless block_given?
    if FileTest.directory? file_path
      Dir.foreach(file_path) do |file|
        traverse_dir("#{file_path}/#{file}"){|x| yield x} if
        file != "." && file != ".."
      end
    else
      yield file_path
    end
  end
  
  # mBrackets
  def mBrackets str, brackets = {'(' => ')', '[' => ']', '{' => '}', '<' => '>'}
    matched = []
    result = [""]
    valid = [0]
    str.each_char do |c|
      valid.each{|v| result[v].concat(c)}
      if brackets.keys.include?(c)
        matched.push(c)
        valid.push(result.size)
        result.push("")
      elsif brackets.values.include?(c)
        if brackets[matched[-1]] == c
          result[valid[-1]].chop!
          valid.pop
          matched.pop
        else
          raise ArgumentError, "False Matching!"
        end
      end
    end
    result
  end
end # Smomo

#============================================================================
# ** Smomo::Kit
#============================================================================
module Smomo::Kit
  # 公用寄存表
  @@register = {
    transition: [],
    temp: nil,
  } # @@register
  module_function
  # 获取寄存表
  def register
    @@register
  end
end # Smomo::Kit

#============================================================================
# ** Smomo::Mixin
#----------------------------------------------------------------------------
# * _def_ sym, type = :a, &append 快速重定义方法 添加新增的内容
#    方法获得的参数会传递给新增的块
#    三个参数依次为：方法名 添加方式 添加的块
#    方法名为一Symbol
#    添加方式
#      :a   after 之后  在原方法后添加新的内容
#      :b   before之前  在原方法前添加新的内容
#      :c   chain 链    将原方法作为第一个参数传递给块 需要.call才会调用原方法
#      :v   value 值    将原方法求值，并将所得值传递给块的第一个参数 不需要.call
#      :if        如果  如果新增的部分计算结果为真 则继续执行原方法
#      :unless    若非  如果新增的部分计算结果为假 则继续执行原方法
#      :ifold     若旧  如果原方法计算结果为真 则继续执行新增的部分
#      :unlessold 非旧  如果原方法计算结果为假 则继续执行新增的部分
#      缺省值为 :a
#      如果是其他的值 则不会对原方法进行更改 _def_什么也不做
#    添加的块
#      为了提高兼容性 建议使用|*args, &block|来定义形参 因为调用的时候会检查参数
#      对于:c和:v，建议使用|old, *args, &block|，这样可以方便地获得原方法
# 
# * _api(code) 快速新建Win32API code的格式为"库|方法|参数类型|返回值类型"
# 
# * __api(code, *args) 快速新建Win32API并用参数call code同上
# 
#============================================================================
module Smomo::Mixin
  # _def_
  def _def_ sym, type = :a, &append
    access = public_method_defined?(sym) ? :public :
             protected_method_defined?(sym) ? :protected :
             private_method_defined?(sym) ? :private : :impossible
    origin_method = instance_method(sym)
    define_method sym, &append
    append_method = instance_method(sym)
    case type
    when :a; define_method sym do |*args, &block|
        origin_value = origin_method.bind(self).call *args, &block
        append_method.bind(self).call *args, &block
        origin_value
      end
    when :b; define_method sym do |*args, &block|
        append_method.bind(self).call *args, &block
        origin_method.bind(self).call *args, &block
      end
    when :c; define_method sym do |*args, &block|
        append_method.bind(self).call origin_method.bind(self), *args, &block
      end
    when :v; define_method sym do |*args, &block|
        origin_value = origin_method.bind(self).call *args, &block
        append_method.bind(self).call origin_value, *args, &block
      end
    when :if; define_method sym do |*args, &block|
        origin_method.bind(self).call *args, &block if
        append_method.bind(self).call *args, &block
      end
    when :unless; define_method sym do |*args, &block|
        origin_method.bind(self).call *args, &block unless
        append_method.bind(self).call *args, &block
      end
    when :ifold; define_method sym do |*args, &block|
        append_method.bind(self).call *args, &block if
        origin_method.bind(self).call *args, &block
      end
    when :unlessold; define_method sym do |*args, &block|
        append_method.bind(self).call *args, &block unless
        origin_method.bind(self).call *args, &block
      end
    else; define_method sym, origin_method
    end
    send access, sym
    return sym
  end
  
  # _api
  def _api code
    Win32API.new *code.split("|")
  end
  
  # __api
  def __api code, *args
    _api(code).call *args
  end
  
  # 混入Module模块类以便调用
  Module.send(:include, self)
end # Smomo::Mixin

#==============================================================================
# ** Graphics
#==============================================================================
class << Graphics
  _def_ :update do Smomo.update end
end

#==============================================================================
# ** Smomo!update
#==============================================================================
module Smomo
  module_function
  
  # update
  def update
    update_transition
  end
  
  # update_transition
  def update_transition
    ::Smomo::Kit.register[:transition].each &:update
  end
end # Smomo

else
  msgbox "你已经安装过了更高版本的Smomo脚本核心，不需要重复安装 : )"
end # if $smomo
#==============================================================================#
#=====                        =================================================#
           "■ 脚 本 尾"
#=====                        =================================================#
#==============================================================================#