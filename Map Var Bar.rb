#==============================================================================
# ■ 变量槽显示
#  作者：影月千秋
#  适用：VA
#  要求：Smomo Core 1.1+
#------------------------------------------------------------------------------
# ● 简介
#   本脚本用以在菜单或地图界面显示一个值槽，它的进度由变量控制
#------------------------------------------------------------------------------
# ● 使用方法
#   插入到其他脚本以下，Main以上，按要求在下方设定即可
#==============================================================================
# ● 更新
#   V 1.3 2014.05.10 支持图标型显示
#   V 1.2 2014.05.01 劳动节 现在支持更丰富的显示效果了
#   V 1.1 2014.02.08 功能微调
#   V 1.0 2013.12.?? 新建
#==============================================================================
# ● 声明
#   本脚本来自【影月千秋】，使用、修改和转载请保留此信息
#==============================================================================

if $smomo["Core"].nil? || $smomo["Core"] < 1.1
  msgbox "请先安装Smomo脚本核心！"; %x!start http://tinyurl.com/l9kvg2p!
elsif $smomo["MapVarBar"].nil?
$smomo["MapVarBar"] = 1.3

#==============================================================================
# ■ MapVarBar
#------------------------------------------------------------------------------
#   变量槽的设定区域
#==============================================================================
module Smomo::MapVarBar
  
  SWI = 0
  # 游戏中决定是否在地图显示窗口的开关
  # 开关打开时，才会显示 如果设为0 则一直显示

  POS = 3
  # 在地图中变量窗口显示的位置
  #  0不使用 1左上 2左下 3右上 4右下
  
  KEY = :Y
  # 玩家在地图界面显示/隐藏窗口的键，:Y一般为S键，不使用请设为0
    
  VAR = [
  #============================================================================
  # ■ 填写格式
  #----------------------------------------------------------------------------
  # ● 变量槽模式
  #
  # [当前进度变量, 最大值变量, 附加文本, 基础值, 初始最大值, 进度显示方式, 渐变色1,
  # 渐变色2, 文本颜色, 进度颜色],
  #
  # 变量需要填写变量ID 附加文本形如 "击破数"
  # 附加文本允许使用控制符 因此可以使用图标
  # 基础值：计算比例时，先把当前值加上基础值再进行计算
  # 初始最大值：因为游戏开始时变量为0 不能计算比例（除数不为零） 临时使用这个作为
  #  最大值 当最大值变量不为0时 此值无意义
  # 进度显示方式：有三种选项
  #  '-'   不显示值 只显示附加文本
  #  '/'   在附加文本后 以 69/731 的方式显示进度
  #  '%'   在附加文本后 以 37.1% 的方式显示进度（精确到一位小数）
  # 渐变色1 渐变色2 ：描绘值槽使用的渐变颜色*
  # 文本颜色 进度颜色：描绘附加文本和进度值使用的颜色*
  #
  # * 颜色请填写一个整数，参照事件【显示文章】中转义字符【\C[]】的参数
  #
  # 非必填项中 如果想只写后面不写前面，就用 nil 占位
  #
  # 前三项为必填项！
  #----------------------------------------------------------------------------
  # ● 图标模式
  #
  # [当前进度变量, 附加文本, 基础值, 图标ID, 步长, 文本颜色],
  #
  # 图标ID可在数据库中查看 例： 3、28、31、67
  # 步长： 一个图标所表示的进度量，即多少量绘制一整个图标
  #  举例 用 爱心符号 表示当前生命（九号变量控制）步长为20
  #  当 九号变量 在20-40之间 绘制一个爱心和一个不完整的爱心
  #   在 40-60之间 绘制两个爱心和一个不完整的爱心
  #    刚好60 绘制三个爱心
  #     诸如此类
  #
  # 前五项为必填项！
  #============================================================================
  # ■ 示例
  # 将光标定位在下面的某一行 按Ctrl+D 再按Ctrl+Q 然后填写数据项 就可以直接生效了
#~     [1, 2, "击破数", 0, 1000, '/', 16, 12, 4, 9],
#~     [1, 2, "击破数"],
#~     [1, 2, "击破数", nil, nil, '%'],
#~     [1, 2, "击破数", 20, nil, '-', nil, nil, nil, 15],
#~     [9, "生命", 0, 122, 20],
  #============================================================================
    [1, 2, "\\I[9]击破数"],
    [3, 4, "完成度"],
    [5, 6, "熟练等级"],
    [7, 8, "远征", nil, nil, '%'],
    [9, "生命", 0, 122, 20],
  ] #<-|
  
  D_BA = 0    # 默认基础值
  D_OM = 1000 # 默认初始最大值 不能为零
  D_DM = '/'  # 默认进度显示方式
  D_C1 = 16   # 默认渐变色1
  D_C2 = 12   # 默认渐变色2
  D_CT = 4    # 默认文本颜色
  D_CR = 9    # 默认进度颜色
  
  T_TEXT  = "游戏进度"
  # 在窗口最上方显示的文字 不希望显示的话使用 ""
  T_COLOR = 2
  # 如果显示 使用什么颜色
  
  BV = true
  # 是否描绘窗口本身
  
#=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+#
#------------------------------------------------------------------------------#
#                               请勿跨过这块区域                                #
#------------------------------------------------------------------------------#
#+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=#
  ICONNUMBER = 0
  VAR.each do |bar|
    ICONNUMBER += 1 if bar[1].is_a?(String)
    bar[3] ||= D_BA
    bar[4] ||= D_OM
    bar[5] ||= D_DM
    bar[6] ||= D_C1
    bar[7] ||= D_C2
    bar[8] ||= D_CT
    bar[9] ||= D_CR
  end
end

#==============================================================================
# ■ Window_MapVarBar
#==============================================================================
class Window_MapVarBar < Window_Base
  include Smomo::MapVarBar
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize
    fh = fitting_height (T_TEXT == "" ? 0 : 1) + VAR.size + ICONNUMBER
    case POS
    when 1
      super(0, 20, 160, fh)
    when 2
      super(0, Graphics.height - fh, 160, fh)
    when 3
      super(Graphics.width - 160, 20, 160, fh)
    when 4
      super(Graphics.width - 160, Graphics.height - fh, 160, fh)
    end
    self.openness = 0
    self.opacity = 0 unless BV
    @showing = true
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def update
    super
    if Smomo::MapVarBar::SWI == 0 || $game_switches[Smomo::MapVarBar::SWI]
      @showing = !@showing if Input.trigger?(Smomo::MapVarBar::KEY)
      if @showing
        open if close?
        refresh if $game_map.need_refresh
      else
        close if open?
      end
    else
      close if open?
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    unless T_TEXT == ""
      change_color text_color(T_COLOR)
      draw_text(0, 0, contents.width, line_height, T_TEXT, 1)
    end
    VAR.each_with_index do |(a, b, c, d, e, f, g, h, i, j), id|
      b.is_a?(String) ?
      draw_with_icon(id, a, b, c, d, e, f) :
      draw(id, g, h, i, j, c, *make_rate_n_text(f, a, b, d, e))
    end
  end
  #--------------------------------------------------------------------------
  # ● 生成进度值
  #--------------------------------------------------------------------------
  def make_rate_n_text(display, current, max, base, origin_max)
    c = $game_variables[current] + base
    m = $game_variables[max] == 0 ? origin_max : $game_variables[max]
    [rate = c.to_f / m.to_f,
    case display
    when '-'; ""
    when '/'; "#{c}/#{m}"
    when '%'; "#{(rate * 1000).round.to_f / 10.0}%"
    end]
  end
  #--------------------------------------------------------------------------
  # ● 进度槽式描绘
  #--------------------------------------------------------------------------
  def draw(index, c1, c2, ct, cr, text, rate, atext)
    pos = fitting_height(index - (T_TEXT == "" ? 1 : 0))
    draw_gauge(0, pos, contents.width, rate, text_color(c1), text_color(c2))
    draw_var_text(ct, pos, text, cr, atext)
  end
  #--------------------------------------------------------------------------
  # ● 图标式描绘
  #--------------------------------------------------------------------------
  def draw_with_icon(index, current, text, base, id, step, ct)
    pos = fitting_height(index - (T_TEXT == "" ? 1 : 0))
    ct = ct.is_a?(String) ? D_CT : ct
    draw_var_text(ct, pos, text)
    pos += line_height
    (($game_variables[current] + base) / step).times do |i|
      draw_icon(id, 24 * i, pos)
    end
  end
  #--------------------------------------------------------------------------
  # ● 通用描绘文字
  #--------------------------------------------------------------------------
  def draw_var_text(ct, pos, text, cr = nil, atext = nil)
    make_font_smaller
    change_color(text_color(ct))
    text = convert_escape_characters(text)
    oo = {:x => 0, :y => pos, :new_x => 0, :height => calc_line_height(text)}
    process_character(text.slice!(0, 1), text, oo) until text.empty?
    if cr
      change_color(text_color(cr))
      draw_text(0, pos, contents.width, line_height, atext, 2)
    end
    make_font_bigger
  end
end
#==============================================================================
# ■ Scene_Map
#==============================================================================
class Scene_Map
  _def_ :create_all_windows do
    @mo_var_bar_window = Window_MapVarBar.new unless Smomo::MapVarBar::POS == 0
  end
end

else # unless $smomo["VarBar"]
  msgbox "请不要重复加载此脚本 : )\n(变量槽显示 MapVarBar)"
end # unless $smomo["VarBar"]

#==============================================================================#
#=====                        =================================================#
           "■ 脚 本 尾"
#=====                        =================================================#
#==============================================================================#
