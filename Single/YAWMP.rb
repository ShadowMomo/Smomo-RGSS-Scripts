##
# Yet Another Window Message with Portrait
# Esphas
#
# v4.1.2 2018.04.02 bug fix: anime --x--> face image
# v4.1.1 2018.04.01 new feature: when missing portrait, use face image instead
# v4.1.0 2018.04.01 happy fool's day! I decide to change the version number to
#                   v4.1.0, but actually not much changes are made:
#                     a fix to a vallana bug;
#                     portrait offset;
#                     shake control improvments.
# v3.0.0 2017.12.31 alright, shake overhaul, compatible with v2.0
# v2.2.0 2017.12.31 new feature: shakes now supports up to 4 parameters
# v2.1.0 2017.12.31 new features: shake dialog, play SE
# v2.0.1 2017.10.18 fixed bugs displaying wrong dialog skin
# v2.0.0 2017.07.21 release
#
# https://github.com/ShadowMomo/Smomo-RGSS-Scripts/blob/master/Single/YAWMP.rb
# http://rm.66rpg.com/forum.php?mod=viewthread&tid=401822

##
# 前置
#   Interactive.weaken_type.dim 需要 Bitmap#change_tone
#   说人话的话，如果交互对话时采取的弱化效果是变暗，
#   那么就需要提供 Bitmap 类的 change_tone 方法
#     # 已知的提供方
#       * TKTK_Bitmap
#         http://www.tktkgame.com/tkool/rgss_common/files/tktk_bitmap.zip

module Cache
  ##
  # 存放立绘的位置
  PortraitFolder = 'Graphics/Faces/Large/'

  def self.generate_portrait_filename name, index, frame
    ##
    # 生成文件名的规则
    filename = "#{name}_L#{index}"
    filename = "#{filename}_#{frame}" if frame > 0
    filename
  end
end

class Window_ChoiceList
  ##
  # 用于修复一个原生 bug：显示选项时使用图标造成的长度不当
  # 如果你已经使用了其他修复手段，那么请将下方标注的 true 改为 false
  def max_choice_width
    $game_message.choices.collect do |s|
      s = convert_escape_characters s
      height = calc_line_height s
      pos = {x: 0, y: -Graphics.height, new_x: 0, height: height}
      process_character(s.slice!(0, 1), s, pos) until s.empty?
      pos[:x]
    end.max
  end if true ## 此处标注
end

class Window_Message

  ##
  # 主设定区
  #   所有开关 ID，若设为 0，则认为对应的值为开关关闭
  #   所有变量 ID，若设为 0，则认为对应的值为 0

  ##
  # Skin
  #  basename: 对话框皮肤的基础文件名
  #  var: 表示具体使用几号皮肤的变量
  #  # 皮肤文件位于 Graphics/System
  #  #  命名格式为 basename+var，例如 dialog1，dialog4,
  #  #  var 为零时省略：dialog 而不是 dialog0
  #  # 如果文件不存在，就使用默认的窗体而不是对话框
  Skin = {
    basename: 'dialog',
    var: 81
  }

  ##
  # Portrait
  #  on_the_right_switch: 开关打开时，立绘首先显示在右边
  #  left_mirror_switch:  开关打开时，在左边的立绘会镜像
  #  right_mirror_switch: 开关打开时，在右边的立绘会镜像
  #  under_dialogbox_switch: 开关打开时，立绘重叠次序在对话框下方
  Portrait = {
    on_the_right_switch: 81,
    left_mirror_switch: 82,
    right_mirror_switch: 83,
    under_dialogbox_switch: 84
  }

  ##
  # Name
  #  disable_switch: 开关打开时，不把第一行文字识别为名字
  #  deco: 有两个字符串的数组，名字会放置在这两个字符串中间
  #  color: 名字的颜色
  #    default: 默认颜色
  #    face: 按脸图判断的特殊颜色
  #      'abc' => 4: 以 abc 开头的脸图的名字使用 4 号颜色
  #      # 字母不区分大小写
  #    name: 按文字字面判断的特殊颜色
  #      '德国士兵' => 6: 以 德国士兵 开头的名字用 7 号颜色
  #      # 字母区分大小写
  #    # 优先依据脸图的判断结果，脸图无匹配的情况采用字面匹配
  #    # 均无匹配才使用默认颜色
  #  indent: 正文的缩进量，以半角空格为单位
  Name = {
    disable_switch: 85,
    deco: ['【', '】'],
    color: {
      default: 6,
      face: {
        'Agn' => 2,
        'def' => 7,
        'Gal' => 5,
      },
      name: {
        '路人' => 3,
      }
    },
    indent: 2
  }

  ##
  # Fading
  #  dialogbox_in:  对话框淡入需要的时间
  #  dialogbox_out: 对话框淡出需要的时间
  #  portrait_in:  立绘淡入需要的时间
  #  portrait_out: 立绘淡出需要的时间
  #  portrait_dist: 立绘淡入滑动的距离
  #  together: 淡入效果是否可以同时进行
  Fading = {
    dialogbox_in: 10,
    dialogbox_out: 10,
    portrait_in: 15,
    portrait_out: 15,
    portrait_dist: 30,
    together: false
  }

  ##
  # Anime
  #  disable_switch: 开关打开时，完全禁用动画效果
  #  interval_var: 表示帧与帧之间间隔的变量
  #  repeat_var: 表示动画最多播放次数的变量
  #    # 若为零，则一直重播
  #  stop_var: 表示动画最终应该停留的帧序数的变量
  #    # 帧序数从零开始
  #    # 若变量值超过动画最大帧数，则停留在第一帧
  #  repeat_inteval_var: 两个变量
  #    # 第一个为表示动画重播之间等待的时间的变量
  #    # 第二个为表示等待时间波动范围的变量
  #    # 实际等待时间在 var1 ± var2 内
  #    # 第一次播放之前也会等待
  Anime = {
    disable_switch: 86,
    interval_var: 82,
    repeat_var: 83,
    stop_var: 84,
    repeat_inteval_var: [85, 86]
  }

  ##
  # Offset
  #  portrait_x_back: X 方向向后方（立绘在左即左方，在右即右方）的偏移量
  #  portrait_y_down: Y 方向向下的偏移量
  #  face_side_left: 无立绘时，脸图在左侧时的侧边距
  #  face_side_right: 无立绘时，脸图在右侧时的侧边距
  #  face_bottom:  无立绘时脸图的下边距
  #  text_without_face: 没有立绘时的文本左偏移量
  #  text_with_face: 有立绘时的文本左偏移量
  Offset = {
    portrait_x_back: 0,
    portrait_y_down: 0,
    face_side_left: 20,
    face_side_right: 20,
    face_bottom: 20,
    text_without_face: 40,
    text_with_face: 10
  }

  ##
  # Interactive
  #  enable_switch: 开关打开时，启用交互对话模式
  #  host_mode_switch: 开关打开时，交互对话模式有一个主角
  #  weaken_time: 立绘弱化所需要的帧数
  #  weaken_type: 立绘弱化的类型
  #    # :dim     变暗
  #    # :opacity 透明
  #    # :blur    模糊
  #  weaken_rate: 立绘弱化的程度
  #    # 变暗时，0 为不变，255 为全黑
  #    # 透明时，0 为不变，255 为完全透明
  #    # 模糊不受影响
  #  down_pixel: 立绘弱化时的下移量
  #  back_pixel: 立绘弱化时的后移量
  Interactive = {
    enable_switch: 87,
    host_mode_switch: 88,
    weaken_time: 10,
    weaken_type: :dim,
    weaken_rate: 100,
    down_pixel: 0,
    back_pixel: 10
  }

  ##
  # Text
  #  character_wait_var: 表示两个字符之间等待时间的变量
  #    # 超过 15 按 15 处理
  #  escape: 控制符
  #    shake: 抖动立绘，参数：抖动对象,半周期,次数,幅度
  #      # 缺省参数为 x,5,3,5
  #      # 抖动对象：x 或 y 或 opacity（不透明度）
  #      # 半周期（帧）和次数（次）和幅度顾名思义
  #      # 幅度的单位是像素（对于 x 和 y）或者取值0~255（对于 opacity）
  #      # 例：【\d】【\d[x,10]】【\d[y,7,6,-15]】【\d[opacity,30,6,128]】
  #    shake_dialog: 抖动对话框
  #      # 参数配置同 shake
  #    wait_for_shake_complete: 等待抖动完成
  #    switch: 切换立绘，参数为立绘图编号或全称，如【\S[6]】【\S[AgnesC_L0]】
  #    se: 播放音效(SE)，参数为音效文件名，不带拓展名，如【\X[Absorb1]】
  #      # 也可以带上一个额外参数表示音量，如【\X[Absorb1,100]】
  #      # 还可再带一个额外参数表示音调，如【\X[Absorb1,100,150]】
  #    # 控制符必须是单个字符，不区分大小写
  Text = {
    character_wait_var: 87,
    escape: {
      shake: 'D',
      shake_dialog: 'Z',
      wait_for_shake_complete: 'W',
      switch: 'S',
      se: 'X'
    }
  }

  ##
  # Misc
  #  comp: 识别同一角色时比较前多少个字母
  #    # 字母不区分大小写
  #  adjust_choice_switch: 开关打开时，选项显示在立绘的另一侧
  Misc = {
    comp: 3,
    adjust_choice_switch: 89
  }

  ##
  # ErrorMessage
  # 错误信息
  ErrorMessage = {
    invalid_switch: '无效的切换，只支持切换同一角色的立绘！'
  }

  'Edit Anything Below At Your Own Risk'
  'Edit Anything Below At Your Own Risk'
  'Edit Anything Below At Your Own Risk'
  
  module SpriteContainer
    
    def clear_shake
      @shake = { x: [], y: [], opacity: [] }
    end

    def shaking?
      !@shake.values.all?(&:empty?)
    end

    def update_shake sprite
      sprite.ox = @shake[:x].pop || 0
      sprite.oy = @shake[:y].pop || 0
      sprite.opacity = @shake[:opacity].pop || 255
    end

    def start_shake param
      type, halfperiod, count, amplitude = param.split ','
      type       = (type       || :x).downcase.to_sym
      halfperiod = (halfperiod || 5).to_i
      count      = (count      || 3).to_i
      amplitude  = (amplitude  || 5).to_i
      if type == :opacity
        list = shaker1d halfperiod, count, amplitude, &Math.method(:cos)
        list.map!{ |v| v + 255 - amplitude }
      else
        list = shaker1d halfperiod, count, amplitude, &Math.method(:sin)
      end
      @shake[type] = list
    end
    
    def shaker1d halfperiod, count, amplitude
      period = 2*halfperiod
      list = period.times.map do |p|
        amplitude*yield(2*Math::PI*p/period)
      end
      list*count
    end
  end

  class DialogBox
    
    include SpriteContainer

    attr_accessor :state

    def get_game_variable id, default
      id.zero? ? default : $game_variables[id]
    end

    def initialize
      @sprite = Sprite.new
      @sprite.opacity = 0
      @state = nil
      @update_frame_count = 0
      load_skin
      clear_shake
    end

    def load_skin
      skin = Skin[:basename]
      index = get_game_variable Skin[:var], 0
      skin = "#{skin}#{index}" if index > 0
      @sprite.bitmap = Cache.system skin
      @valid = true
    rescue Errno::ENOENT
      @valid = false
    end

    def valid?
      @valid
    end

    %w[x y z visible].each do |prop|
      define_method "#{prop}=" do |value|
        @sprite.send "#{prop}=", value
      end
    end

    %w[x y z visible width height].each do |prop|
      define_method prop do
        @sprite.send prop
      end
    end

    def update
      case @state
      when :fading_in
        @update_frame_count += 1
        do_fading_in
        state_end = @update_frame_count >= Fading[:dialogbox_in]
      when :fading_out
        @update_frame_count += 1
        do_fading_out
        state_end = @update_frame_count >= Fading[:dialogbox_out]
      else
        if shaking?
          update_shake @sprite
        end
      end
      if state_end
        @update_frame_count = 0
        @state = nil
      end
      @sprite.update
    end

    def transitioning?
      not @state.nil?
    end

    def do_fading_in
      return if @sprite.opacity == 255
      progress = @update_frame_count.to_f / Fading[:dialogbox_in]
      @sprite.opacity = 255 * progress
    end

    def do_fading_out
      return if @sprite.opacity == 0
      progress = @update_frame_count.to_f / Fading[:dialogbox_out]
      @sprite.opacity = 255 - 255 * progress
    end

    def dispose
      @sprite.dispose
    end

    def disposed?
      @sprite.disposed?
    end
  end

  class PortraitFrame
    
    include SpriteContainer

    attr_reader :face_name
    attr_reader :face_index
    attr_reader :guest
    attr_reader :right

    attr_accessor :state

    def inspect
      "<PortraitFrame: #{@face_name}_L#{@face_index}_#{@frame}*#{@state}>"
    end

    def get_game_variable id, default
      id.zero? ? default : $game_variables[id]
    end

    def get_game_switch id
      id.zero? ? false : $game_switches[id]
    end

    def initialize face_name, face_index, guest = false
      @face_name = face_name
      @face_index = face_index
      @guest = guest
      @sprite = Sprite.new
      @helper = Sprite.new
      @sprite.opacity = @helper.opacity = 0
      @state = :fading_in
      @update_frame_count = 0
      @weakened = false
      reset_anime
      clear_shake
      right!
    end

    def right!
      @right = get_game_switch Portrait[:on_the_right_switch]
      @right = !@right if @guest
      mirror = @right ? :right_mirror_switch : :left_mirror_switch
      @sprite.mirror = get_game_switch Portrait[mirror]
      load_portrait
    end

    def load_portrait
      @sprite.bitmap = Cache.portrait @face_name, @face_index, @frame, @right
      prepare_helper
      adjust_placement
    end

    def adjust_placement
      if @right
        self.x = Graphics.width - width + Offset[:portrait_x_back]
        self.x += Interactive[:back_pixel] if weakened?
      else
        self.x = -Offset[:portrait_x_back]
        self.x -= Interactive[:back_pixel] if weakened?
      end
      self.y = Graphics.height - height + Offset[:portrait_y_down]
      self.y += Interactive[:down_pixel] if weakened?
    end

    def hotload face_name, face_index
      reset_anime
      @face_name = face_name
      @face_index = face_index
      load_portrait
    end

    def reset_anime
      @frame = 0
      @anime_frame_count = 0
      @anime_repeat_count = 0
      @anime_repeat_interval = anime_repeat_interval
      @wait_for_repeat = true
    end

    def prepare_helper
      @helper.mirror = @sprite.mirror
      case Interactive[:weaken_type]
      when :dim
        @helper.bitmap = get_portrait_dim
      when :opacity
      when :blur
        @helper.bitmap = get_portrait_blur
      end
    end

    def same_character? face_name
      @face_name[0, Misc[:comp]].downcase == face_name[0, Misc[:comp]].downcase
    end

    %w[x y z].each do |prop|
      define_method "#{prop}=" do |value|
        @sprite.send "#{prop}=", value
        @helper.send "#{prop}=", value
      end
    end

    %w[x y z width height].each do |prop|
      define_method prop do
        @sprite.send prop
      end
    end

    def update
      case @state
      when :fading_in
        @update_frame_count += 1
        do_fading_in
        if @update_frame_count >= Fading[:portrait_in]
          @update_frame_count = 0
          @state = nil
        end
      when :fading_out
        @update_frame_count += 1
        do_fading_out
        if @update_frame_count >= Fading[:portrait_out]
          dispose
        end
      when :weakening
        @update_frame_count += 1
        do_weakening
        if @update_frame_count >= Interactive[:weaken_time]
          @update_frame_count = 0
          @state = nil
          @weakened = true
        end
      when :strengthening
        @update_frame_count += 1
        do_strengthening
        if @update_frame_count >= Interactive[:weaken_time]
          @update_frame_count = 0
          @state = nil
          @weakened = false
        end
      else
        if shaking?
          update_shake @sprite
        else
          update_anime unless anime_disabled?
        end
      end
      return if disposed?
      @sprite.update
      @helper.update
    end

    def transitioning?
      not @state.nil?
    end

    def weakened?
      @weakened
    end

    def do_fading_in
      return if @sprite.opacity == 255
      progress = @update_frame_count.to_f / Fading[:portrait_in]
      @sprite.opacity = 255 * progress
      if @right
        target = Graphics.width - width
        origin = target + Fading[:portrait_dist]
      else
        target = 0
        origin = target - Fading[:portrait_dist]
      end
      self.x = progress * target + (1-progress) * origin
    end

    def do_fading_out
      sprite = weakened? ? @helper : @sprite
      return if sprite.opacity == 0
      progress = @update_frame_count.to_f / Fading[:portrait_out]
      sprite.opacity = 255 - 255 * progress
      if @right
        origin = Graphics.width - width
        origin += Interactive[:back_pixel] if weakened?
        target = origin + Fading[:portrait_dist]
      else
        origin = 0
        origin -= Interactive[:back_pixel] if weakened?
        target = origin - Fading[:portrait_dist]
      end
      self.x = progress * target + (1-progress) * origin
    end

    def get_portrait_dim
      dimness = Interactive[:weaken_rate]
      Cache.portrait_dim @face_name, @face_index, @frame, @right, dimness
    end

    def get_portrait_blur
      Cache.portrait_blur @face_name, @face_index, @frame, @right
    end

    def do_weakening
      return if weakened?
      progress = @update_frame_count.to_f / Interactive[:weaken_time]
      case Interactive[:weaken_type]
      when :dim
        blending_civet_cat_and_prince_edward progress
      when :opacity
        @sprite.opacity = 255 - Interactive[:weaken_rate] * progress
      when :blur
        blending_civet_cat_and_prince_edward progress
      end
      if @right
        originx = Graphics.width - width
        targetx = originx + Interactive[:back_pixel]
      else
        originx = 0
        targetx = originx - Interactive[:back_pixel]
      end
      originy = Graphics.height - height
      targety = originy + Interactive[:down_pixel]
      self.x = progress * targetx + (1-progress) * originx
      self.y = progress * targety + (1-progress) * originy
    end

    def do_strengthening
      return unless weakened?
      progress = @update_frame_count.to_f / Interactive[:weaken_time]
      case Interactive[:weaken_type]
      when :dim
        blending_civet_cat_and_prince_edward 1-progress
      when :opacity
        @sprite.opacity = 255 - Interactive[:weaken_rate] * (1 - progress)
      when :blur
        blending_civet_cat_and_prince_edward 1-progress
      end
      if @right
        targetx = Graphics.width - width
        originx = targetx + Interactive[:back_pixel]
      else
        targetx = 0
        originx = targetx - Interactive[:back_pixel]
      end
      targety = Graphics.height - height
      originy = targety + Interactive[:down_pixel]
      self.x = progress * targetx + (1-progress) * originx
      self.y = progress * targety + (1-progress) * originy
    end

    def blending_civet_cat_and_prince_edward progress
      @helper.opacity = 255 * progress
      @sprite.opacity = 255 - 128 * progress
    end

    def anime_disabled?
      get_game_switch Anime[:disable_switch]
    end

    def update_anime
      return if anime_limit_reached?
      @anime_frame_count += 1
      if @wait_for_repeat
        if @anime_frame_count >= @anime_repeat_interval
          @wait_for_repeat = false
        end
      elsif @anime_frame_count >= anime_frame_interval
        @anime_frame_count = 0
        @frame += 1
        unless load_next_frame
          @frame = 0
          @anime_repeat_count += 1
          @wait_for_repeat = true
          @anime_repeat_interval = anime_repeat_interval
          load_next_frame
        end
      end
    end

    def anime_limit_reached?
      stop_var = get_game_variable Anime[:stop_var], 0
      repeat_var = get_game_variable Anime[:repeat_var], 0
      repeat_var = Float::INFINITY if repeat_var.zero?
      @anime_repeat_count == repeat_var && @frame >=  stop_var ||
      @anime_repeat_count  > repeat_var
    end

    def anime_frame_interval
      interval = get_game_variable Anime[:interval_var], 0
      interval = 5 if interval.zero?
      interval
    end

    def anime_repeat_interval
      interval = get_game_variable Anime[:repeat_inteval_var][0], 0
      interval = 120 if interval.zero?
      range = get_game_variable Anime[:repeat_inteval_var][1], 0
      interval += rand(range*2) - range
      interval
    end

    def load_next_frame
      file = Cache.generate_portrait_filename @face_name, @face_index, @frame
      file = Cache::PortraitFolder + file
      if %w[.png .jpg .bmp].any?{ |ext| FileTest.exist? file + ext }
        load_portrait
        return true
      else
        return false
      end
    end

    def dispose
      @helper.dispose
      @sprite.dispose
    end

    def disposed?
      @sprite.disposed?
    end
  end

  def get_game_variable id, default
    id.zero? ? default : $game_variables[id]
  end

  def get_game_switch id
    id.zero? ? false : $game_switches[id]
  end

  alias :yawmp_initialize :initialize
  def initialize
    yawmp_initialize
    create_dialogbox
    create_portraits
  end

  alias :yawmp_create_all_windows :create_all_windows
  def create_all_windows
    yawmp_create_all_windows
    @gold_window.z =
    @choice_window.z =
    @number_window.z =
    @item_window.z = z+10
  end

  def create_dialogbox
    @dialogbox = DialogBox.new
    @dialogbox.z = z-1
  end

  def create_portraits
    @portraits = []
    @active_portraits = []
  end

  def portraits_under_dialog?
    get_game_switch Portrait[:under_dialogbox_switch]
  end

  alias :yawmp_clear_flags :clear_flags
  def clear_flags
    yawmp_clear_flags
    clear_portrait_flags
  end

  def clear_portrait_flags
    @first_time_window_open = true
  end

  alias :yawmp_dispose :dispose
  def dispose
    yawmp_dispose
    dispose_dialog
    dispose_portraits
  end

  def dispose_dialog
    @dialogbox.dispose
  end

  def dispose_portraits
    @portraits.each &:dispose
  end

  alias :yawmp_update :update
  def update
    yawmp_update
    update_dialog
    update_portraits
  end

  def update_dialog
    if !Fading[:together] && portraits_transitioning?
      return unless (@dialogbox.state == :fading_in) ^ portraits_under_dialog?
    end
    @dialogbox.update
  end

  def update_portraits
    if !Fading[:together] && dialog_transitioning?
      return unless (@dialogbox.state == :fading_in) ^ !portraits_under_dialog?
    end
    return unless has_portrait?
    return if adjust_choice? && @choice_window.active
    first = @active_portraits.first
    while @portraits[first].disposed?
      @portraits[first] = nil
      @portraits.compact!
      @active_portraits.delete first
      @active_portraits.map! do |value|
        value > first ? value-1 : value
      end
      return if @portraits.size.zero?
      first = @active_portraits.first
    end
    if @portraits[first].weakened? && @portraits[first].state.nil?
      weakened = @active_portraits.shift
      @active_portraits.push weakened
    end
    @portraits[@active_portraits.first].update
  end

  def dialog_transitioning?
    @dialogbox.transitioning?
  end

  def portraits_transitioning?
    return false if @portraits.size.zero?
    @portraits[@active_portraits.first].transitioning?
  end

  def transitioning?
    dialog_transitioning? || portraits_transitioning?
  end

  def interactive_mode?
    get_game_switch Interactive[:enable_switch]
  end

  def host_mode?
    get_game_switch Interactive[:host_mode_switch]
  end

  def portrait_alone?
    @active_portraits.size == 1
  end

  def current_is_host?
    !@portraits[@active_portraits.first].guest
  end

  def update_background
    @background = $game_message.background
    @dialogbox.load_skin
    update_dialog_validation
  end

  def update_dialog_validation
    if @dialogbox.valid?
      @dialogbox.visible = @background.zero?
      self.opacity = 0
    else
      @dialogbox.visible = false
      self.opacity = @background.zero? ? 255 : 0
    end
  end

  alias :yawmp_update_placement :update_placement
  def update_placement
    yawmp_update_placement
    @dialogbox.y = @position * (Graphics.height - @dialogbox.height) / 2
  end

  def adjust_placement
    @portraits.each &:right!
  end

  def refresh_portraits
    Fiber.yield while transitioning?
    adjust_placement
    validate_portraits
    update_portraits_z
  end

  def update_portraits_z
    @portraits.each do |portrait|
      portrait.z = z-1 + (portraits_under_dialog? ? -1 : 1)
    end
  end

  def face_changed?
    portrait = @portraits[@active_portraits.first]
    portrait.face_name  != $game_message.face_name ||
    portrait.face_index != $game_message.face_index
  end

  def has_portrait?
    !@active_portraits.size.zero?
  end

  def has_portrait_in_left?
    @portraits.any? do |portrait|
      !portrait.right
    end
  end

  def validate_portraits
    return create_first_portrait unless has_portrait?
    return unless face_changed?
    if interactive_mode?
      validate_interactive_mode
    else
      validate_basic_mode
    end
  end

  def create_first_portrait
    face_name  = $game_message.face_name
    face_index = $game_message.face_index
    return if face_name.empty?
    @active_portraits.push 0
    portrait = PortraitFrame.new face_name, face_index
    @portraits.push portrait
  end

  def validate_basic_mode
    face_name  = $game_message.face_name
    face_index = $game_message.face_index
    if face_name.empty?
      @portraits[@active_portraits.first].state = :fading_out
    elsif @portraits[@active_portraits.first].same_character? face_name
      @portraits[@active_portraits.first].hotload face_name, face_index
    else
      change_to_new_portrait face_name, face_index
    end
  end

  def validate_interactive_mode
    face_name  = $game_message.face_name
    face_index = $game_message.face_index
    if face_name.empty?
      @portraits.each do |portrait|
        portrait.state = :fading_out
      end
    elsif @portraits[@active_portraits.first].same_character? face_name
      @portraits[@active_portraits.first].hotload face_name, face_index
    else
      if host_mode?
        if portrait_alone?
          create_second_portrait face_name, face_index
        else
          if current_is_host?
            switch_to_new_portrait face_name, face_index
          else
            if get_interactive_host.same_character? face_name
              switch_to_new_portrait face_name, face_index
            else
              change_to_new_portrait face_name, face_index
            end
          end
        end
      else
        if portrait_alone?
          create_second_portrait face_name, face_index
        else
          switch_to_new_portrait face_name, face_index
        end
      end
    end
  end

  def get_interactive_host
    @portraits.find do |portrait|
      !portrait.guest
    end
  end

  def create_second_portrait face_name, face_index
    @portraits[@active_portraits.first].state = :weakening
    @active_portraits.insert 1, @portraits.size
    portrait = PortraitFrame.new face_name, face_index, current_is_host?
    @portraits.push portrait
  end

  def change_to_new_portrait face_name, face_index
    @portraits[@active_portraits.first].state = :fading_out
    @active_portraits.insert 1, @portraits.size
    portrait = PortraitFrame.new face_name, face_index, !current_is_host?
    @portraits.push portrait
  end

  def switch_to_new_portrait face_name, face_index
    @portraits[@active_portraits.first].state = :weakening
    current = @active_portraits.shift
    if @portraits[@active_portraits.first].same_character? face_name
      portrait = @portraits[@active_portraits.first]
      portrait.state = :strengthening
      if portrait.face_name != face_name || portrait.face_index != face_index
        @portraits[@active_portraits.first].hotload face_name, face_index
      end
    else
      change_to_new_portrait face_name, face_index
    end
    @active_portraits.unshift current
  end

  def open_and_wait
    @dialogbox.load_skin
    update_dialog_validation
    if @first_time_window_open
      @dialogbox.state = :fading_in
      @first_time_window_open = false
    end
    open
    Fiber.yield until open?
  end

  def close_and_wait
    clear_portrait_flags
    @dialogbox.state = :fading_out
    @portraits.each do |portrait|
      portrait.state = :fading_out
    end
    close
    Fiber.yield until all_close?
    Fiber.yield while transitioning?
  end

  def process_all_text
    open_and_wait
    text = $game_message.all_text
    disable_name = get_game_switch Name[:disable_switch]
    text = convert_escape_characters text
    unless disable_name
      text = pre_process_name text
    end
    pos = {}
    new_page text, pos
    process_character text.slice!(0, 1), text, pos until text.empty?
  end

  def pre_process_name text
    return text unless @background.zero?
    ls = text.split ?\n
    if ls[0] && !ls[0].empty?
      ldeco = Name[:deco][0]
      rdeco = Name[:deco][1]
      color = Name[:color][:default]
      matched = false
      face_name = $game_message.face_name
      Name[:color][:face].each do |match, mcolor|
        next if match == :default
        if face_name.downcase.start_with? match.downcase
          color = mcolor
          break matched = true
        end
      end
      Name[:color][:name].each do |match, mcolor|
        next if match == :default
        if ls[0].start_with? match
          color = mcolor
          break matched = true
        end
      end unless matched
      ls[0] = "\e>\ec[#{color}]#{ldeco}#{ls[0]}#{rdeco}\ec[0]"
      text = ls.join ?\n + ?\s * Name[:indent]
    end
    text.rstrip
  end

  def wait_for_one_character
    update_show_fast
    duration = get_game_variable Text[:character_wait_var], 0
    duration = 15 if duration > 15
    wait duration + 1 unless @show_fast || @line_show_fast
  end

  def new_page text, pos
    contents.clear
    @dialogbox.load_skin
    update_dialog_validation
    refresh_portraits
    Fiber.yield while transitioning?
    reset_font_settings
    pos[:x] = new_line_x
    pos[:y] = 0
    pos[:new_x] = new_line_x
    pos[:height] = calc_line_height text
    yawmp_clear_flags
  end

  def new_line_x
    if has_portrait_in_left? && !portraits_under_dialog?
      max_portrait_width = @portraits.map do |portrait|
        portrait.right ? 0 : portrait.width
      end.max
      return max_portrait_width - Offset[:text_with_face]
    elsif @background.zero?
      return @dialogbox.valid? ? Offset[:text_without_face] : 0
    else
      return 0
    end
  end

  alias :yawmp_process_escape_character :process_escape_character
  def process_escape_character code, text, pos
    case code.upcase
    when Text[:escape][:shake].upcase
      param = obtain_escape_param_string text
      @portraits[@active_portraits.first].start_shake param
    when Text[:escape][:shake_dialog].upcase
      param = obtain_escape_param_string text
      @dialogbox.start_shake param
    when Text[:escape][:wait_for_shake_complete].upcase
      Fiber.yield while @dialogbox.shaking? || @portraits.any?(&:shaking?)
    when Text[:escape][:switch].upcase
      param = obtain_escape_param_string text
      if param =~ /^\d+$/
        face_index = param.to_i
        portrait = @portraits[@active_portraits.first]
        portrait.hotload portrait.face_name, face_index
      else
        face_name, face_index = param.split '_L'
        face_index = face_index.to_i
        portrait = @portraits[@active_portraits.first]
        if portrait.same_character? face_name
          portrait.hotload face_name, face_index
        else
          msgbox ErrorMessage[:invalid_switch]
        end
      end
    when Text[:escape][:se].upcase
      param = obtain_escape_param_string text
      params = param.split ','
      params[0] = 'Audio/SE/' + params[0]
      params[1] = (params[1] ||  80).to_i
      params[2] = (params[2] || 100).to_i
      Audio.se_stop
      Audio.se_play *params
    else
      yawmp_process_escape_character code, text, pos
    end
  end

  def obtain_escape_param_string text
    text.slice!(/^\[[^\[\]]+\]/)[/[^\[\]]+/] rescue ''
  end

  def adjust_choice?
    get_game_switch Misc[:adjust_choice_switch]
  end

  def input_choice
    @choice_window.start
    if has_portrait? && adjust_choice?
      @choice_window.close
      @choice_window.deactivate
      Fiber.yield while transitioning?
      if interactive_mode? && host_mode?
        current = get_interactive_host
        fade_out_all_guest
        current.state = :strengthening if current.weakened?
      else
        current = @portraits[@active_portraits.first]
        fade_out_side !current.right
      end
      if current.right
        @choice_window.x = 0
      end
      Fiber.yield while transitioning?
      @choice_window.open
      @choice_window.activate
    end
    Fiber.yield while @choice_window.active
  end

  def fade_out_all_that
    newlist = []
    @active_portraits.each do |id|
      if yield @portraits[id]
        @portraits[id].state = :fading_out
        newlist.unshift id
      else
        newlist.push id
      end
    end
    @active_portraits = newlist
  end

  def fade_out_all_guest
    fade_out_all_that do |portrait|
      portrait.guest
    end
  end

  def fade_out_side right
    fade_out_all_that do |portrait|
      portrait.right == right
    end
  end
end

module Cache

  def self.portrait name, index, frame, right
    filename = generate_portrait_filename name, index, frame
    filename = PortraitFolder + filename
    key = [filename, right]
    unless include? key
      begin
        @cache[key] = normal_bitmap(filename)
      rescue Errno::ENOENT
        src = face name
        rect = Rect.new index % 4 * 96, index / 4 * 96, 96, 96
        right = right ? "right" : "left"
        right = "face_side_" + right
        right = right.to_sym
        side_padding = Window_Message::Offset[right]
        bottom_padding = Window_Message::Offset[:face_bottom]
        bmp = Bitmap.new 2*side_padding + 96, bottom_padding + 96
        bmp.blt side_padding, 0, src, rect
        src.dispose
        @cache[key] = bmp
      end
    end
    @cache[key]
  end

  def self.portrait_dim name, index, frame, right, dimness
    filename = generate_portrait_filename name, index, frame
    filename = PortraitFolder + filename
    key = [filename, :dim, dimness, right]
    unless include? key
      bmp = portrait name, index, frame, right
      @cache[key] = bmp.clone
      tone = Array.new 3, -dimness
      @cache[key].change_tone *tone
    end
    @cache[key]
  end

  def self.portrait_blur name, index, frame, right
    filename = generate_portrait_filename name, index, frame
    filename = PortraitFolder + filename
    key = [filename, :blur, right]
    unless include? key
      bmp = portrait name, index, frame, right
      @cache[key] = bmp.clone
      @cache[key].blur
    end
    @cache[key]
  end
end
