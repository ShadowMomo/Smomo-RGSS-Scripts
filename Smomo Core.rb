#==============================================================================
# ■ Smomo脚本核心
#  作者：影月千秋
#  版本：V 1.0
#  最近更新：2014.04.05
#------------------------------------------------------------------------------
# ● 简介
#  Smomo脚本的核心，提供了一些常用功能，有些脚本需要依靠此脚本以正常工作
#==============================================================================
# ● 使用方法
#  插入到其他Smomo脚本上方
#==============================================================================
# ● 更新
#   V 1.0 2014.04.05 新建
#==============================================================================
# ● 声明
#   本脚本来自【影月千秋】，使用、修改和转载请保留此信息
#==============================================================================

$smomo ||= {}
if $smomo["Core"].nil? || $smomo["Core"] < 1.0
$smomo["Core"] = 1.0

$smomo["RGSS Version"] = 
  defined?(Audio.setup_midi) ? :VA : defined?(Graphics.wait) ? :VX : :XP

#==============================================================================
# ■ Smomo!module_function
#----------------------------------------------------------------------------
# ·text_size(str, font = nil) 确定合适的文字大小(Rect矩形类)
#
# ·moveAE(aim, x = :x, y = :y) 动态移动效果，返回一个移动对象mover
#     aim 被移动的对象 x y 横纵坐标的属性名
#     ● 该方法需要Smomo::Kit
#   mover对象：
#     ·moveto(tx, ty, duration = 1) 在duration次操作内移动至tx, ty处
#         如果正在移动中 则保持原有移动状态 不前往新位置
#         原则上该方法应该每帧调用一次
#     ·lock(type = :switch) 锁定/解锁  可以使用参数 :on 和 :off
#         锁定状态下，会完成当前移动，但不会接受新的指令
#     ·stop 停止移动
#     ·apos 获取目标点坐标 返回一个包含两个元素的数组
#     ·opos 获取起始点坐标
#     ·arrived? 是否已经到达
#
# ·web(url = "") 调用浏览器打开网页
#
# ·deep_clone(obj) 深度复制对象
#
# ·
#============================================================================
module Smomo
  module_function
  
  # text_size
  def text_size(str, font = nil)
    tmp = Bitmap.new
    tmp.font = font if font
    rect = tmp.text_size(str)
    tmp.dispose
    rect.width += 2
    rect
  end
  
  # moveAE
  def moveAE(aim, x = :x, y = :y)
    reg = Smomo::Kit.register[:moveAE]
    id = aim.object_id
    return reg[id] if reg[id]
    reg[id] = Object.new
    # class << reg[id]
    class << reg[id]
      attr_accessor :moving, :aim_id, :duration, :locked
      attr_accessor :ox, :oy, :ax, :ay, :x, :y, :rx, :ry
      # moveto
      def moveto(tx, ty, duration)
        unless @moving || @locked
          a = ObjectSpace._id2ref(@aim_id)
          @ox, @oy = a.send(@x), a.send(@y)
          @ax, @ay = *[tx, ty].collect(&:to_i)
          @rx, @ry = *[@ox, @oy].collect(&:to_f)
          @duration = duration
          @moving = true
        end
        _moveto
      end
      # lock
      def lock(type = :switch)
        @locked = type == :on ? true : type == :off ? false : !@locked
      end
      # stop
      define_method(:stop){@moving = false}
      # apos
      define_method(:apos){[@ax, @ay]}
      # opos
      define_method(:opos){[@ox, @oy]}
      # arrived?
      define_method(:arrived?){a.send(@x) == @ax && a.send(@y) == @ay}
      private
      # _moveto
      def _moveto
        return unless @moving
        a = ObjectSpace._id2ref(@aim_id)
        @rx += (@ax - @ox).to_f / @duration
        @ry += (@ay - @oy).to_f / @duration
        a.instance_eval %!self.#{@x}, self.#{@y} = #{@rx}, #{@ry}!
        stop if (@rx - @ax).to_i == 0 && (@ry - @ay).to_i == 0
      end
    end # class << reg[id]
    reg[id].moving, reg[id].locked, reg[id].x, reg[id].y, reg[id].aim_id =
             false,          false,         x,         y,             id
    reg[id]
  end # moveAE
  
  # web
  def web(url = "")
    eval %Q!`start #{url}`!
  end
  
  # deep_clone
  def deep_clone(obj)
    Marshal.load Marshal.dump obj
  end
  
end # Smomo


#============================================================================
# ■ Smomo::Kit
#============================================================================
module Smomo::Kit
  # 公用寄存表
  @@register = {
    moveAE: []
  } # @@register
  module_function
  # 获取寄存表
  def register
    @@register
  end
  
end # Smomo::Kit


#============================================================================
# ■ Smomo::Mixin
#----------------------------------------------------------------------------
# ·_def_ sym, type = :a, &append 快速重定义方法 添加新增的内容
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
#      为了提高兼容性，建议使用|*args, &block|来定义形参，因为调用的时候会检查参数
#      对于:c和:v，建议使用|old, *args, &block|，这样可以方便地获得原方法
#============================================================================
module Smomo::Mixin
  # _def_
  def _def_ sym, type = :a, &append
    access = public_method_defined?(sym) ? :public :
             protected_method_defined?(sym) ? :protected :
             private_method_defined?(sym) ? :private : :impossible
    return false if access == :impossible
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
    else; define_method sym do |*args, &block|
        origin_method.bind(self).call *args, &block
      end
    end
    send access, sym
    return true
  end
  
  # 混入Module模块类以便调用
  Module.send(:include, self)
end # Smomo::Mixin

else
  msgbox "你已经安装过了更高版本的Smomo脚本核心，不需要重复安装 : )"
end # if $smomo
#==============================================================================#
#=====                        =================================================#
           "■ 脚 本 尾"
#=====                        =================================================#
#==============================================================================#
