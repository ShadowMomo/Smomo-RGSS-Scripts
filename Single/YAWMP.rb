##
# Yet Another Window Message with Portrait
# Esphas
#
# v5.0.0 2018.07.24 reworked, and of course, fixed all known bugs
#                   some settings have been changed
#                   this version is completely compatable with RGD(v1.1.2+)
#                   new features:
#                     use \W and \NW to wait for specified number of frames;
#                     use a key (default to Ctrl) to skip message.
# v4.2.1 2018.04.08 ...and Interactive.weaken_type now supports variable
# v4.2.0 2018.04.08 new features: change dialog skin according to character name
#                               & new interactive weaken type: exit
# v4.1.3 2018.04.05 shakes will abort when message ends
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
# https://rpg.blue/thread-401822-1-1.html

module YAWMP

  ##
  # 设定区
  # - 在进行设置之前，建议先通过在线文档或者 demo 来了解各功能的意义
  # - 仅可修改注释指示的内容，尤其注意不要碰逗号冒号花括号
  # - 部分功能可能需要其他脚本的支持，请仔细阅读注释
  # - 所有开关 ID，若设为 0，则认为对应的值为开关关闭
  # - 所有变量 ID，若设为 0，则认为对应的值为 0
  # - 原则上，不为不看这些注释的人提供任何技术支持
  # -- 但是你可以用金钱来挑战这条原则，钱要多
  # -- 开玩笑的，给钱我也会咕咕咕
  
  ##
  # 字体及大小
  Font.default_name = "SimHei"
  Font.default_size = 20

  ##
  # 对话框
  Dialogbox = {
    var_skin: 81, # 指示当前对话框皮肤的变量
  }

  ##
  # 立绘
  Portrait = {
    swi_major_right:  81, # 指示立绘是否居右的开关
    swi_mirror_left:  82, # 指示左侧立绘或脸图是否镜像处理的开关
    swi_mirror_right: 83, # 指示右侧立绘或脸图是否镜像处理的开关
    compare_count: 3, # 判别同一角色时比较脸图文件名的前多少个字母
  }

  ##
  # 动态效果
  Dynamic = {
    # 淡入与淡出
    dialogbox_in:  10, # 对话框淡入所需时间
    dialogbox_out: 10, # 对话框淡出所需时间
    portrait_in:   15, # 立绘淡入所需时间
    portrait_out:  15, # 立绘淡出所需时间
    portrait_dist: 30, # 立绘滑入距离
    # 多帧立绘
    swi_disable:     86, # 指示禁用此功能的开关
    var_interval:    82, # 指示两关键帧之间的时间的变量
    var_max_loops:   83, # 指示最大循环次数的变量，为零代表无限循环
    var_final_frame: 84, # 指示最终的停留帧的变量，超过帧数则停留在首帧
    var_loop_interval: [85, 86] # 指示循环之间的停顿时间的两个变量
    # - 第一个变量指示基准时长，第二个变量指示波动范围
    # - 即，实际等待时长在 var1 ± var2 内
    # - 在首次循环开始之前，也会进行等待
  }

  ##
  # 布局
  # - 经过深思，决定支持不对称的布局
  # -- 立绘或脸图在左侧时，生效的是左边距和左底边距
  # -- 反之则是右边距和右底边距
  # - 脸图仅在没有对应的立绘时使用
  Layout = {
    portrait: {
      # 立绘
      left:          0, # 左边距
      right:         0, # 右边距
      left_bottom:   0, # 左底边距
      right_bottom:  0, # 右底边距
    },
    face: {
      # 脸图
      left:          20, # 左边距
      right:         20, # 右边距
      left_bottom:   12, # 左底边距
      right_bottom:  12, # 右底边距
    },
    text: {
      # 文本
      plain:    40, # 未使用立绘或脸图时的左边距
      portrait: 10, # 左侧有立绘时的左边距，相对于立绘的右边缘
      face:      5, # 左侧有脸图时的左边距，相对于脸图的右边缘
    },
    # 杂项
    swi_under_dialogbox: 84, # 指示立绘置于对话框之下的开关
    swi_choice_opposite: 89, # 指示将显示选项窗口放在立绘的对面一侧的开关
  }

  ##
  # 交替式对话
  Dialogue = {
    swi_enable:    87, # 指示启用交替式对话的开关
    swi_host_mode: 88, # 指示交替式对话存在主持人的开关
    deactivation: { # 弱化非活跃角色立绘
      type: :dim, # 弱化类型
      # - 可选类型有四种
      # -- :dim     变暗
      # -- :opacity 半透明
      # -- :blur    模糊
      # -- :exit    退出
      # --- 也可使用数字，表示由变量指示
      # --- 变量的值为 0 则相当于使用 :dim，为 1 相当于使用 :opacity，以此类推
      rate: 100, # 弱化程度
      # - 对于 :dim，0 表示不变，255 表示全黑
      # - 对于 :opacity，0 表示不变，255 表示全透明
      # - 对于其他两项无影响
      duration: 10, # 弱化耗时
      offset_back: 10, # 弱化时立绘后移的距离
      offset_down: 10  # 弱化时立绘下移的距离
    }
  }

  ##
  # 文本控制
  Text = {
    var_wait_for_character: 87, # 指示两个字之间等待时间的变量
    skip_button: :CTRL, # 用于快进对话的按键
    swi_disable_skip: 90, # 指示禁用快进对话的开关
    control: {
      # 控制符，不区分大小写
      shake: 'D', # 抖动当前立绘
      # - 参数：抖动对象,半周期,次数,幅度
      # - 缺省参数为 x,5,3,5
      # - 抖动对象：x 或 y 或 opacity（不透明度）
      # - 半周期、次数和幅度顾名思义
      # - 幅度的单位是像素（对于 x 和 y）或者取值 0~255（对于 opacity）
      # - 例：【\d】【\d[x,10]】【\d[y,7,6,-15]】【\d[opacity,30,6,128]】
      shake_dialogbox:  'Z', # 抖动对话框，参数同上
      wait_for_shake:  'WS', # 等待抖动完成
      wait_frame:       'W', # 等待指定帧数，可被按键跳过，如【\W[3]】
      wait_frame_hard: 'NW', # 等待指定帧数，不可被跳过
      switch_portrait:  'S', # 切换当前立绘的图形
      # - 参数为立绘图编号或全称，如【\S[6]】【\S[AgnesC_L0]】
      # - 为了防止各式各样的手滑，只允许切换同一角色的立绘，否则会主动报错
      se: 'X' # 播放音效
      # - 参数为音效文件名，不带拓展名，如【\X[Absorb1]】
      # - 也可以带上一个额外参数表示音量，如【\X[Absorb1,100]】
      # - 还可再带一个额外参数表示音调，如【\X[Absorb1,100,150]】
    }
  }

  ##
  # 名字识别与处理
  # - 启用时，第一行文字视为名字
  # - 无论是否启用，只在正常背景下生效
  Name = {
    swi_disable: 85, # 禁用名字识别的开关
    deco: ['【', '】'], # 应用在名字两侧的装饰文字
    indent: 2, # 正文内容相对于名字的缩进量，以半角空格为单位
    color: {
      default: 6, # 默认名字颜色
      name: {
        # 依据名字决定的名字颜色，优先于默认颜色
        # 若使用字符串，则代表“匹配名字开头”
        # 若使用正则表达式，则直接进行匹配
        '以此开头' => 3,
        '路人' => 3,
        /正则匹配/ => 6,
      },
      face: {
        # 依据脸图文件名决定的名字颜色，优先于默认颜色和名字匹配
        '以此开头' => 3,
        'Agn' => 2,
        'def' => 7,
        'Gal' => 5,
        /正则匹配/ => 6,
        /^esphas$/ => 7,
      }
    },
    skin: {
      # 为某些名字采用单独的对话框皮肤
      name: {
        # 依据名字决定
        '以此开头' => 3,
        /正则匹配/ => 1,
        /测试员/   => 5,
      },
      face: {
        # 依据脸图文件名决定
        '以此开头' => 3,
        /正则匹配/ => 1,
      }
    }
  }

  ErrorMessage = {
    no_portrait: "无效的操作，根本就不存在立绘",
    invalid_switch_wrong_name: "无效的切换，根本不是同一个人"
  }

  ##
  # 文件名相关的设置
  # - 对这部分的修改需要掌握基础的 ruby 知识
  # -- 或者也可以使用勇气、决断和想象力来代替
  # - 请自由修改方法内容
  def self.dialogbox_skin_name id
    # 对话框文件名
    "dialog" + (id.zero? ? "" : "#{id}")
  end
  def self.portrait_name facename, faceindex, framecount
    # 立绘文件名
    "Graphics/Faces/Large/#{facename}_L#{faceindex}" +
    (framecount.zero? ? "" : "_#{framecount}")
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

                 'Edit Anything Below At Your Own Risk'
                 'Edit Anything Below At Your Own Risk'
                 'Edit Anything Below At Your Own Risk'

module YAWMP

  # actually this is the first time I introduce a version string here
  VERSION = "5.0.0"

  def self.get_variable id
    return 0 if id.zero?
    $game_variables[id]
  end

  def self.get_switch id
    return false if id.zero?
    $game_switches[id]
  end

  def self.has_portrait? name, index, frame
    filename = portrait_name name, index, frame
    ["", ".png", ".jpg"].any? do |ext|
      FileTest.exist? filename + ext
    end
  end

  def self.same_character? name1, name2
    beg1 = name1.downcase[0, Portrait[:compare_count]]
    beg2 = name2.downcase[0, Portrait[:compare_count]]
    beg1 == beg2
  end

  def self.deactivation_type
    type = Dialogue[:deactivation][:type]
    if type.is_a? Integer
      type = get_variable type
      type = [:dim, :opacity, :blur, :exit][type]
    end
    type
  end
    
  module C
  end
end

class Window_Message

  def initialize
    super(0, 0, window_width, window_height)
    self.z = 200
    self.openness = 0
    create_all_windows
    create_back_bitmap
    create_back_sprite
    create_dialogbox
    create_portraits
    clear_instance_variables
  end

  def create_dialogbox
    @dialogbox = YAWMP::C::Dialogbox.new
    @dialogbox.x = 0
    @dialogbox.z = z - 1
  end

  def create_portraits
    @portraits = YAWMP::C::PortraitManager.new
    @portraits.z = z
  end

  def dispose
    super
    dispose_all_windows
    dispose_back_bitmap
    dispose_back_sprite
    dispose_dialogbox
    dispose_portraits
  end

  def dispose_dialogbox
    @dialogbox.dispose
  end

  def dispose_portraits
    @portraits.dispose
  end

  def update
    super
    update_all_windows
    update_back_sprite
    update_dialogbox
    update_portraits
    update_fiber
  end

  def update_dialogbox
    @dialogbox.y = y
    @dialogbox.update
  end

  def update_portraits
    @portraits.update
  end

  def update_background
    @background = $game_message.background
    @dialogbox.visible = false
    self.opacity = 0
  end

  def process_all_text
    text = convert_escape_characters $game_message.all_text
    skin_id = YAWMP.get_variable YAWMP::Dialogbox[:var_skin]
    if @background.zero? # normal background
      unless YAWMP.get_switch YAWMP::Name[:swi_disable]
        ls = text.split "\n"
        if ls[0] && !ls[0].empty?
          ldeco = YAWMP::Name[:deco][0]
          rdeco = YAWMP::Name[:deco][1]
          color = YAWMP::Name[:color][:default]
          YAWMP::Name[:color][:name].each do |name, ncolor|
            if name.is_a? String
              if ls[0].start_with? name
                color = ncolor
                break
              end
            elsif name.is_a? Regexp
              if ls[0].match name
                color = ncolor
                break
              end
            end
          end
          YAWMP::Name[:color][:face].each do |face, fcolor|
            if face.is_a? String
              if $game_message.face_name.downcase.start_with? face.downcase
                color = fcolor
                break
              end
            elsif face.is_a? Regexp
              if $game_message.face_name.match face
                color = fcolor
                break
              end
            end
          end
          YAWMP::Name[:skin][:name].each do |name, nskin|
            if name.is_a? String
              if ls[0].start_with? name
                skin_id = nskin
                break
              end
            elsif name.is_a? Regexp
              if ls[0].match name
                skin_id = nskin
                break
              end
            end
          end
          YAWMP::Name[:skin][:face].each do |face, fskin|
            if face.is_a? String
              if $game_message.face_name.downcase.start_with? face.downcase
                skin_id = fskin
                break
              end
            elsif face.is_a? Regexp
              if $game_message.face_name.match face
                skin_id = fskin
                break
              end
            end
          end
          ls[0] = "\e>\ec[#{color}]#{ldeco}#{ls[0]}#{rdeco}\ec[0]"
          text = ls.join "\n" + "\s" * YAWMP::Name[:indent]
        end
      end
    end
    load_dialogbox skin_id
    open_and_wait
    pos = {}
    new_page text, pos
    process_character(text.slice!(0, 1), text, pos) until text.empty?
  end

  def load_dialogbox skin_id
    if @background.zero? # normal background
      @dialogbox.load_skin skin_id
      @dialogbox.y = y
      @dialogbox.visible = @dialogbox.valid
      self.opacity = @dialogbox.valid ? 0 : 255
    else
      self.opacity = 0
    end
  end

  def open_and_wait
    @dialogbox.enter
    open
    Fiber.yield until open? && !@dialogbox.busy?
  end

  def close_and_wait
    @dialogbox.exit
    @portraits.exit_all
    close
    Fiber.yield until all_close? && !@dialogbox.busy? && !@portraits.busy?
    contents.clear
  end

  def wait duration
    if YAWMP.get_switch YAWMP::Text[:swi_disable_skip]
      duration.times { Fiber.yield }
    else
      duration.times do
        if Input.press? YAWMP::Text[:skip_button]
          break
        else
          Fiber.yield
        end
      end
    end
  end

  def update_show_fast
    @show_fast = true if Input.trigger?(:C)
    unless YAWMP.get_switch YAWMP::Text[:swi_disable_skip]
      @show_fast ||= Input.press? YAWMP::Text[:skip_button]
    end
  end

  def wait_for_one_character
    update_show_fast
    duration = YAWMP.get_variable YAWMP::Text[:var_wait_for_character]
    duration = 0 if duration < 0
    duration = 15 if duration > 15
    wait duration + 1 unless @show_fast || @line_show_fast
  end

  def new_page text, pos
    contents.clear
    reset_font_settings
    name, index = $game_message.face_name, $game_message.face_index
    @portraits.push name, index
    if YAWMP.get_switch YAWMP::Text[:swi_disable_skip]
      Fiber.yield while @portraits.busy?
    else
      while @portraits.busy?
        if Input.press? YAWMP::Text[:skip_button]
          @portraits.skip
          break
        end
        Fiber.yield
      end
    end
    if @portraits.current_left &&
      @portraits.current_left.z > z
      if @portraits.current_left.type == :portrait
        new_line_x = @portraits.current_left.width
        new_line_x += YAWMP::Layout[:portrait][:left]
        new_line_x += YAWMP::Layout[:text][:portrait]
      else
        new_line_x = @portraits.current_left.width
        new_line_x += YAWMP::Layout[:face][:left]
        new_line_x += YAWMP::Layout[:text][:face]
      end
    else
      new_line_x = YAWMP::Layout[:text][:plain]
    end
    pos[:x] = new_line_x
    pos[:y] = 0
    pos[:new_x] = new_line_x
    pos[:height] = calc_line_height(text)
    clear_flags
  end

  alias :yawmp_process_escape_character :process_escape_character
  def process_escape_character code, text, pos
    control = YAWMP::Text[:control]
    case code.upcase
    when control[:shake].upcase
      param = obtain_escape_param_string text
      @portraits.shake_active param
    when control[:shake_dialogbox].upcase
      param = obtain_escape_param_string text
      @dialogbox.shake param
    when control[:wait_for_shake].upcase
      if YAWMP.get_switch YAWMP::Text[:swi_disable_skip]
        Fiber.yield while @dialogbox.busy? || @portraits.busy?
      else
        while @dialogbox.busy? || @portraits.busy?
          if Input.press? YAWMP::Text[:skip_button]
            @dialogbox.skip
            @portraits.skip
            break
          end
          Fiber.yield
        end
      end
    when control[:wait_frame].upcase
      [obtain_escape_param(text),0].max.times do |i|
        update_show_fast
        Fiber.yield unless @show_fast || @line_show_fast
      end
    when control[:wait_frame_hard].upcase
      ([obtain_escape_param(text),0].max).times { Fiber.yield }
    when control[:switch_portrait].upcase
      param = obtain_escape_param_string text
      @portraits.switch_active_to param
    when control[:se].upcase
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

  def input_pause
    if YAWMP.get_switch YAWMP::Text[:swi_disable_skip]
      self.pause = true
      wait(10)
      Fiber.yield until Input.trigger?(:B) || Input.trigger?(:C)
      Input.update
      self.pause = false
    else
      self.pause = true
      wait(10)
      Fiber.yield until Input.trigger?(:B) || Input.trigger?(:C) ||
        Input.press?(YAWMP::Text[:skip_button])
      Input.update
      self.pause = false
    end
  end

  def input_choice
    @choice_window.start
    if YAWMP.get_switch YAWMP::Layout[:swi_choice_opposite]
      @choice_window.x = 0 if @portraits.current_right
    end
    Fiber.yield while @choice_window.active
  end
end

module Cache

  def self.portrait name, index, frame, type = :normal
    filename = YAWMP.portrait_name name, index, frame
    key = [:yawmp, filename, type]
    unless include? key
      case type
      when :blur
        @cache[key] = portrait name, index, frame
        @cache[key] = @cache[key].clone.blur
      else
        @cache[key] = normal_bitmap filename
      end
    end
    @cache[key]
  end

  def self.face_blur name
    key = [:yawmp, :face, name, :blur]
    unless include? key
      @cache[key] = face name
      @cache[key] = @cache[key].clone.blur
    end
    @caceh[key]
  end
end

class YAWMP::C::SpriteContainer

  def initialize
    @sprite = Sprite.new
    clear_sequence
    @sprite.opacity = 0
    @state = :out
    @intermediate_states = {
      entering: :in,
      exiting: :out,
      shaking: :in
    }
  end

  def clear_sequence
    @sequence = {
      x: [],
      y: [],
      opacity: []
    }
  end

  %w[ x= y= z= ].each do |setter|
    define_method setter do |value|
      @sprite.send setter, value
    end
  end

  %w[ x y z width height ].each do |getter|
    define_method getter do
      @sprite.send getter
    end
  end

  def update
    self.x = @sequence[:x].pop || self.x
    self.y = @sequence[:y].pop || self.y
    @sprite.opacity = @sequence[:opacity].pop || @sprite.opacity
    if @intermediate_states.key? @state
      @state = @intermediate_states[@state] unless busy?
    end
    @sprite.update
  end

  def skip
    self.x = @sequence[:x][0] || self.x
    self.y = @sequence[:y][0] || self.y
    @sprite.opacity = @sequence[:opacity][0] || @sprite.opacity
    clear_sequence
    if @intermediate_states.key? @state
      @state = @intermediate_states[@state]
    end
  end

  def busy?
    !@sequence.values.all?(&:empty?)
  end

  def dispose
    @sprite.dispose
  end

  def shake param
    return unless @state == :in
    @state = :shaking
    type, halfperiod, count, amplitude = param.split ','
    type       = (type       || :x).downcase.to_sym
    halfperiod = (halfperiod || 5).to_i
    count      = (count      || 3).to_i
    amplitude  = (amplitude  || 5).to_i
    if type == :opacity
      list = (2*halfperiod).times.map do |i|
        amplitude * Math.cos(Math::PI * i / halfperiod)
      end * count
      list.map!{ |v| v + 255 - amplitude }
    else
      base_value = send type
      list = (2*halfperiod).times.map do |i|
        amplitude * Math.sin(Math::PI * i / halfperiod) + base_value
      end * count
    end
    @sequence[type] = list
  end
end

class YAWMP::C::Dialogbox < YAWMP::C::SpriteContainer

  attr_reader :valid

  def initialize
    super
    @valid = false
  end

  def visible= visible
    @sprite.visible = visible
  end

  def visible
    @sprite.visible
  end

  def update
    @state = :out unless @valid
    return unless @valid
    super
  end

  def load_skin skin_id
    skin_name = YAWMP.dialogbox_skin_name skin_id
    @sprite.bitmap = Cache.system skin_name
    @valid = true
  rescue Errno::ENOENT
    @valid = false
  end

  def enter
    return unless @state == :out
    @state = :entering
    n = YAWMP::Dynamic[:dialogbox_in]
    @sequence[:opacity] = n.times.map do |i|
      255.0 * (i + 1) / n
    end.reverse
    @sprite.opacity = 0
  end

  def exit
    return if @state == :out
    @state = :exiting
    n = YAWMP::Dynamic[:dialogbox_out]
    @sequence[:opacity] = n.times.map do |i|
      @sprite.opacity.to_f * i / n
    end
  end

  def busy?
    @valid && super
  end
end

class YAWMP::C::Portrait < YAWMP::C::SpriteContainer

  attr_reader :name
  attr_reader :index
  attr_reader :type

  def initialize name, index, side, z
    super()
    @intermediate_states[:deactivating] = :inactive
    @intermediate_states[:activating] = :in
    @helper = Sprite.new
    @side = side
    @base_z = z
    load name, index
  end

  def clear_sequence
    super
    @sequence[:helper] = []
  end

  def skip
    @helper.opacity = @sequence[:helper][0] || @helper.opacity
    super
  end

  %w[ x= y= z= ].each do |setter|
    define_method setter do |value|
      @sprite.send setter, value
      @helper.send setter, value
    end
  end

  def update
    super
    @helper.opacity = @sequence[:helper].pop || @helper.opacity
    @helper.update
    update_animation
  end

  def dispose
    super
    @helper.dispose
  end

  def update_animation
    return if YAWMP.get_switch YAWMP::Dynamic[:swi_disable]
    return if busy?
    return if @intermediate_states.include? @state
    return if @state == :out
    return if @animation[:stopped]
    if @animation[:max_loops] > 0 && # finite
      @animation[:loops] > @animation[:max_loops] && # last loop
      @animation[:frame] == @animation[:final_frame] # last frame
      @animation[:stopped] = true
      return
    end
    @animation[:counter] += 1
    if @animation[:frame] > 0
      # to next frame
      if @animation[:counter] >= @animation[:interval]
        @animation[:counter] = 0
        @animation[:frame] += 1
      end
      unless YAWMP.has_portrait? @name, @index, @animation[:frame]
        # to first frame
        @animation[:frame] = 0
      end
    else
      # to next loop
      if @animation[:counter] >= @animation[:cached_loop_interval]
        @animation[:counter] = 0
        @animation[:frame] = 1
        @animation[:loops] += 1
        loop_interval = @animation[:loop_interval]
        @animation[:cached_loop_interval] =
          loop_interval[0] - loop_interval[1] +
          (2*loop_interval[1] + 1).times.to_a.sample
      end
    end
    hotload @name, @index, @animation[:frame]
  end

  def load name, index
    is_same = name == @name && index == @index
    hotload name, index, 0
    reset_animation unless is_same
    reset_mirror
    reset_z
  end

  def hotload name, index, frame
    @name = name
    @index = index
    if YAWMP.has_portrait? @name, @index, frame
      @type = :portrait
      @sprite.bitmap = Cache.portrait @name, @index, frame
      @sprite.src_rect = @sprite.bitmap.rect
    else
      @type = :face
      @sprite.bitmap = Cache.face @name
      @sprite.src_rect = Rect.new 96*(@index%4), 96*(@index/4), 96, 96
    end
    type = YAWMP.deactivation_type
    rate = YAWMP::Dialogue[:deactivation][:rate]
    case type
    when :dim
      @helper.bitmap = @sprite.bitmap
      @helper.src_rect = @sprite.src_rect
      @helper.tone = Tone.new -rate, -rate, -rate
    when :opacity
      @helper.bitmap = nil
    when :blur
      if @type == :portrait
        @helper.bitmap = Cache.portrait @name, @index, frame, :blur
      else
        @helper.bitmap = Cache.face_blur @name
      end
      @helper.src_rect = @sprite.src_rect
      @helper.tone = Tone.new
    end
    if @state == :inactive
      @sprite.opacity = 0
      @helper.opacity = 255
      if type == :opacity
        @sprite.opacity = 255 - rate
      end
    else
      @sprite.opacity = 255
      @helper.opacity = 0
    end
  end

  def reset_animation
    @animation = {
      stopped: true
    }
    if @type == :portrait && YAWMP.has_portrait?(@name, @index, 1)
      @animation = {
        frame: 0,
        loops: 0,
        interval: YAWMP.get_variable(YAWMP::Dynamic[:var_interval]),
        max_loops: YAWMP.get_variable(YAWMP::Dynamic[:var_max_loops]),
        final_frame: YAWMP.get_variable(YAWMP::Dynamic[:var_final_frame]),
        loop_interval:
          YAWMP::Dynamic[:var_loop_interval].map do |v|
            YAWMP.get_variable v
          end,
        counter: 0,
        stopped: false
      }
      loop_interval = @animation[:loop_interval]
      @animation[:cached_loop_interval] =
        loop_interval[0] - loop_interval[1] +
        (2*loop_interval[1] + 1).times.to_a.sample
    end
  end

  def reset_mirror
    if @side == :left
      @sprite.mirror = YAWMP.get_switch YAWMP::Portrait[:swi_mirror_left]
      @helper.mirror = @sprite.mirror
    else
      @sprite.mirror = YAWMP.get_switch YAWMP::Portrait[:swi_mirror_right]
      @helper.mirror = @sprite.mirror
    end
  end

  def reset_z
    if YAWMP.get_switch YAWMP::Layout[:swi_under_dialogbox]
      self.z = @base_z - 2
    else
      self.z = @base_z + 1
    end
  end

  def enter
    return unless @state == :out
    @state = :entering
    n = YAWMP::Dynamic[:portrait_in]
    if @side == :left
      tx = YAWMP::Layout[@type][:left]
      sx = tx - YAWMP::Dynamic[:portrait_dist]
      ty = Graphics.height - self.height
      ty -= YAWMP::Layout[@type][:left_bottom]
      sy = ty
    else
      tx = Graphics.width - self.width
      tx -= YAWMP::Layout[@type][:right]
      sx = tx + YAWMP::Dynamic[:portrait_dist]
      ty = Graphics.height - self.height
      ty -= YAWMP::Layout[@type][:right_bottom]
      sy = ty
    end
    @sequence[:x] = n.times.map do |i|
      tx + (sx - tx).to_f * i / n
    end
    @sequence[:y] = []
    @sequence[:opacity] = n.times.map do |i|
      255.0 * (i + 1) / n
    end.reverse
    self.x = sx
    self.y = sy
    @sprite.opacity = 0
    @helper.opacity = 0
  end

  def exit
    return if @state == :out
    @state = :exiting
    n = YAWMP::Dynamic[:portrait_out]
    if @side == :left
      tx = YAWMP::Layout[@type][:left]
      tx -= YAWMP::Dynamic[:portrait_dist]
    else
      tx = Graphics.width - self.width
      tx -= YAWMP::Layout[@type][:right]
      tx += YAWMP::Dynamic[:portrait_dist]
    end
    sx = self.x
    @sequence[:x] = n.times.map do |i|
      tx + (sx - tx).to_f * i / n
    end
    @sequence[:opacity] = n.times.map do |i|
      @sprite.opacity.to_f * i / n
    end
    @sequence[:helper] = n.times.map do |i|
      @helper.opacity.to_f * i / n
    end
  end

  def activate
    return unless @state == :inactive || @state == :deactivating
    @state = :activating
    deactivation = YAWMP::Dialogue[:deactivation]
    n = deactivation[:duration]
    if @side == :left
      tx = YAWMP::Layout[@type][:left]
      ty = Graphics.height - self.height
      ty -= YAWMP::Layout[@type][:left_bottom]
    else
      tx = Graphics.width - self.width
      tx -= YAWMP::Layout[@type][:right]
      ty = Graphics.height - self.height
      ty -= YAWMP::Layout[@type][:right_bottom]
    end
    sx = self.x
    sy = self.y
    @sequence[:x] = n.times.map do |i|
      tx + (sx - tx).to_f * i / n
    end
    @sequence[:y] = n.times.map do |i|
      ty + (sy - ty).to_f * i / n
    end
    @sequence[:opacity] = n.times.map do |i|
      @sprite.opacity + (255.0 - @sprite.opacity) * (i + 1) / n
    end.reverse
    @sequence[:helper] = n.times.map do |i|
      @helper.opacity.to_f * i / n
    end
  end

  def deactivate
    return if @state == :inactive
    return if @state == :exiting
    return if @state == :out
    return if @state == :deactivating
    @state = :deactivating
    deactivation = YAWMP::Dialogue[:deactivation]
    n = deactivation[:duration]
    if @side == :left
      tx = YAWMP::Layout[@type][:left]
      tx -= deactivation[:offset_back]
      ty = Graphics.height - self.height
      ty -= YAWMP::Layout[@type][:left_bottom]
      ty += deactivation[:offset_down]
    else
      tx = Graphics.width - self.width
      tx -= YAWMP::Layout[@type][:right]
      tx += deactivation[:offset_back]
      ty = Graphics.height - self.height
      ty -= YAWMP::Layout[@type][:right_bottom]
      ty += deactivation[:offset_down]
    end
    sx = self.x
    sy = self.y
    @sequence[:x] = n.times.map do |i|
      tx + (sx - tx).to_f * i / n
    end
    @sequence[:y] = n.times.map do |i|
      ty + (sy - ty).to_f * i / n
    end
    topacity = 0
    if YAWMP.deactivation_type == :opacity
      rate = deactivation[:rate]
      topacity = 255 - rate
    end
    @sequence[:opacity] = n.times.map do |i|
      topacity + (@sprite.opacity - topacity).to_f * i / n
    end
    @sequence[:helper] = n.times.map do |i|
      255.0 * (i + 1) / n
    end.reverse
  end
end

class YAWMP::C::PortraitManager

  attr_accessor :z

  def initialize
    @current = {
      left: nil,
      right: nil
    }
    @exiting = {
      left: nil,
      right: nil
    }
    @opposite_side = {left: :right, right: :left}
    @active = nil
  end

  def mode
    if YAWMP.get_switch YAWMP::Dialogue[:swi_enable]
      if YAWMP.get_switch YAWMP::Dialogue[:swi_host_mode]
        :host
      else
        :turn
      end
    else
      :normal
    end
  end

  def dispose
    (@current.values + @exiting.values).compact.each &:dispose
  end

  def update
    @active = nil if mode == :normal
    dispose_exited
    (@current.values + @exiting.values).compact.each &:update
  end

  def skip
    (@current.values + @exiting.values).compact.each &:skip
  end

  def busy?
    (@current.values + @exiting.values).compact.any? &:busy?
  end

  def major_side
    if YAWMP.get_switch YAWMP::Portrait[:swi_major_right]
      :right
    else
      :left
    end
  end

  def push name, index
    case mode
    when :normal
      push_normal name, index
    when :turn
      push_turn name, index
    when :host
      push_host name, index
    end
  end

  def push_normal name, index
    side = major_side
    clear_side @opposite_side[side]
    push_to_side name, index, side
  end

  def push_turn name, index
    side = major_side
    oside = @opposite_side[side]
    if @current[side] # major side is filled
      if @current[oside] # both sides are filled
        if YAWMP.same_character? name, @current[@active].name
          # active side remains active
        else
          deactivate @active
          @active = @opposite_side[@active]
        end
      else # opposite side is empty
        if YAWMP.same_character? name, @current[side].name
          @active = side
        else
          deactivate side
          @active = oside
        end
      end
    else # major side is empty
      if @current[oside] # opposite side is filled
        if YAWMP.same_character? name, @current[oside].name
          @active = oside
        else
          deactivate oside
          @active = side
        end
      else # both sides are empty
        @active = side
      end
    end
    push_to_side name, index, @active
  end

  def push_host name, index
    side = major_side
    oside = @opposite_side[side]
    if @current[side] # has host
      if YAWMP.same_character? name, @current[side].name # is host
        deactivate oside
        @active = side
      else
        deactivate side
        @active = oside
      end
    else # no host
      if @current[oside] # has guest
        if YAWMP.same_character? name, @current[oside].name # is guest
          @active = oside
        else
          deactivate oside
          @active = side
        end
      else
        @active = side
      end
    end
    push_to_side name, index, @active
  end

  def push_to_side name, index, side
    if @current[side] &&
      YAWMP.same_character?(name, @current[side].name)
      @current[side].load name, index
      @current[side].activate
    else
      clear_side side
      unless name.empty?
        @current[side] = YAWMP::C::Portrait.new name, index, side, z
        @current[side].enter
      end
    end
  end

  def deactivate side
    type = YAWMP.deactivation_type
    if type == :exit
      clear_side side
    else
      @current[side].deactivate
    end
  end

  def shake_active param
    portrait = active_portrait
    if portrait.nil?
      msgbox YAWMP::ErrorMessage[:no_portrait]
      return
    end
    portrait.shake param
  end

  def switch_active_to param
    portrait = active_portrait
    if portrait.nil?
      msgbox YAWMP::ErrorMessage[:no_portrait]
      return
    end
    if param =~ /^\d+$/
      index = param.to_i
      portrait.load portrait.name, index
    else
      name, index = param.split '_L'
      index = index.to_i
      if YAWMP.same_character? name, portrait.name
        portrait.load name, index
      else
        msgbox YAWMP::ErrorMessage[:invalid_switch_wrong_name]
      end
    end
  end

  def active_portrait
    side = major_side
    case mode
    when :normal
      @current[side]
    when :turn
      if @current[side] && @current[@opposite_side[side]]
        @current[@active]
      elsif @current[side]
        @current[side]
      else
        @current[@opposite[side]]
      end
    when :host
      if @current[side] && @current[@opposite_side[side]]
        @current[@active]
      elsif @current[side]
        @current[side]
      else
        @current[@opposite_side[side]]
      end
    end
  end

  def current_left
    @current[:left]
  end

  def current_right
    @current[:right]
  end

  def clear_side side
    if @current[side]
      @exiting[side].dispose if @exiting[side]
      @current[side].exit
      @exiting[side] = @current[side]
      @current[side] = nil
    end
  end

  def dispose_exited
    [:left, :right].each do |side|
      if @exiting[side] && !@exiting[side].busy?
        @exiting[side].dispose
        @exiting[side] = nil
      end
    end
  end

  def exit_all
    clear_side :left
    clear_side :right
  end
end
