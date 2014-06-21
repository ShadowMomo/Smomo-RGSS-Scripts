
# beta

#==============================================================================
# ** Input
#------------------------------------------------------------------------------
# * Smomo Advanced Input
# * Author: Shadow Momo
# * Version: 1.0
#------------------------------------------------------------------------------
#  * Usage
#   * KeyBoard
#    * Input.press?(key)
#    * Input.trigger?(key)
#    * Input.repeat?(key)
#      All these methods accept a symbol or a string.
#      If it's a symbol, it should be one of the defalt key.
#      If it's a string, it can be a letter from 'A' to 'Z', a number
#    from '0' to '9', or a special string listed in the Key Table below.
#    * Input.typing?
#      Returns whether the player is typing, excluding Shift, Tab, F1 etc.,
#    including Spacebar, Comma etc..
#    * Input.key_type
#      Returns a string refering to the key typed, for example, ',' for Comma.
#   * Mouse
#    * Smomo.mouse method, classname
#      Register functions for class.
#      * Argument: method
#         Can be one of the metioned below.
#           :register
#             Initial functions. This will define some instance methods for the
#           class. When mouse event performed in the area, specific methods will
#           be called. You should rewrite these methods.
#           :dragable
#             Allow the instances of this class to be dragged. Define methods.
#         About the methods, check out the Mouse Methods below.
#      * Argument: classname
#         Reference to the operated class. No Quote. Can be <self> in a class,
#       or a variable pointing to a class.
#      * Example
#         class SomeClass
#           Smomo.mouse :register, self
#           def onClick
#             # do something
#           end
#         end
#------------------------------------------------------------------------------
# * Key Table
#   Odd-numbered line for Strings, and others for Keys
#   Letters, Numbers and Punctuations stands for themselves.
#   Case insensitive
#   ==================================================================
#    | Line |                        Strings                        |
#    |--------------------------------------------------------------|
#    |   1  |  shift            lshift           rshift             |
#    |   2  |  Shift-Key        Left-Shift-Key   Right-Shift-Key    |
#    |   3  |  ctrl             lctrl            rctrl              |
#    |   4  |  Ctrl-Key         Left-Ctrl-Key    Right-Ctrl-Key     |
#    |   5  |  alt              lalt             ralt               |
#    |   6  |  Alt-Key          Left-Alt-Key     Right-Alt-Key      |
#    |   7  |  app              tab              capslock           |
#    |   8  |  App-Key          Tab-Key          Caps-Lock-Key      |
#    |   9  |  numlock          scrolllock       enter              |
#    |  10  |  Num-Lock-Key     Scroll-Lock-Key  Enter-Key          |
#    |  11  |  backspace        space            ins                |
#    |  12  |  Backspace-Key    SpaceBar         Insert-Key         |
#    |  13  |  del              home             end                |
#    |  14  |  Delete-Key       Home-Key         End-Key            |
#    |  15  |  pageup           pagedown         esc                |
#    |  16  |  Page-Up-Key      Page-Down-Key    Escape-Key         |
#    |  17  |  uparrow          downarrow        leftarrow          |
#    |  18  |  Up-Arrow-Key     Down-Arrow-Key   Left-Arrow-Key     |
#    |  19  |  rightarrow       printscreen      select             |
#    |  20  |  Right-Arrow-Key  Print-Screen-Key SELECT-Key         |
#    |  21  |  win              lwin             rwin               |
#    |  22  |  Windows-Key      Left-Windows-Key Right-Windows-Key  |
#    |  23  |  print                                                |
#    |  24  |  PRINT-Key                                            |
#   ==================================================================
#------------------------------------------------------------------------------
# * Mouse Methods
#  :register
#    update_mouse
#      Update mouse and call mouse events.
#      This method is automatically called in update. No need to call it.
#    mouse_in_area?
#      The update_mouse method functions only when this method return true.
#    
#    mouse_pos
#      Get current mouse position. Return a Array: [x, y]
#    mouse_button_state
#      Get current button state
#      0 normal 1 left 2 right 4 middle
#    mouse_state
#      Get current mouse state
#      0 normal 1 down 2 hold 3 up 4 click 5 clicked 6 dbclick 7 hold after db
#    mouse_moving?
#      Returns true if the mouse is moving
#    mouse_timer
#      Returns how long the current mouse state has lasted (since last change)
#    
#    
#    onMouseMove
#      Empty. Will be called when no button is pressed and mouse is moving.
#    
#    onMouseDown
#      Empty. Will be called when left button is getting pressed down.
#    onHold
#      Empty. Will be called when left button is being holding down.
#    onMouseUp
#      Empty. Will be called when left button is released.
#    onClick
#      Empty. Will be called when after onMouseUp.
#    onDoubleClick
#      Empty. Will be called when double-click.
#    
#    onRightMouseDown
#      Empty. Will be called when right button is getting pressed down.
#    onRightHold
#      Empty. Will be called when right button is being holding down.
#    onRightMouseUp
#      Empty. Will be called when right button is released.
#    onRightClick
#      Empty. Will be called when after onRightMouseUp.
#    onRightDoubleClick
#      Empty. Will be called when double-click by right button.
#    
#    onMiddleMouseDown
#      Empty. Will be called when middle button is getting pressed down.
#    onMiddleHold
#      Empty. Will be called when middle button is being holding down.
#    onMiddleMouseUp
#      Empty. Will be called when middle button is released.
#    onMiddleClick
#      Empty. Will be called when after onMiddleMouseUp.
#    onMiddleDoubleClick
#      Empty. Will be called when double-click by middle button.
#  :dragable
#    mouse_drag_interval
#      This is set to Smomo::InputSet::DragInterval by default.
#    onDrag
#      TODO
#------------------------------------------------------------------------------
# 
# 
# * Do Not Edit Anything Over This Line!
# 
# 
#==============================================================================
module Input
  #--------------------------------------------------------------------------
  # * Constants
  #--------------------------------------------------------------------------
  DEFAULT = [
    :DOWN, :LEFT, :RIGHT, :UP,
    :A, :B, :C, :X, :Y, :Z, :L, :R,
    :SHIFT, :CTRL, :ALT,
    :F5, :F6, :F7, :F8, :F9
  ]
  
  Mouse = {left: 0x01, right: 0x02, middle: 0x04}
  
  LETTERS = {
    'A' => 0x41, 'B' => 0x42, 'C' => 0x43, 'D' => 0x44, 'E' => 0x45,
    'F' => 0x46, 'G' => 0x47, 'H' => 0x48, 'I' => 0x49, 'J' => 0x4A,
    'K' => 0x4B, 'L' => 0x4C, 'M' => 0x4D, 'N' => 0x4E, 'O' => 0x4F,
    'P' => 0x50, 'Q' => 0x51, 'R' => 0x52, 'S' => 0x53, 'T' => 0x54,
    'U' => 0x55, 'V' => 0x56, 'W' => 0x57, 'X' => 0x58, 'Y' => 0x59,
    'Z' => 0x5A
  }
  
  #             0     1     2     3     4     5     6     7     8     9
  NUMBERS = [0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39]
  NUMPAD  = [0x60, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69]
  
  #             *           +                -              /
  Multiply = 0x6A; Add = 0x6B; Subtract = 0x6D; Divide = 0x6F;
  #              ,               .
  Separator = 0x6C; Decimal = 0x6E;
  #          ;             =             ,             -             .
  SCOLON = 186; EQUALS = 187; COMMA  = 188; USCORE = 189; PERIOD = 190;
  #          /             `             [             \             ]
  SLASH  = 191; TILDE  = 192; LBRACE = 219; BSLASH = 220; RBRACE = 221;
  #          '
  QUOTE  = 222;
  
  # ENDK for END!
  BACKSPACE    = 0x08; TAB       = 0x09; ENTER      = 0x0D; SHIFT       = 0x10;
  CTRL         = 0x11; ALT       = 0x12; PAUSE      = 0x13; CAPSLOCK    = 0x14;
  ESC          = 0x1B; SPACEBAR  = 0x20; PAGEUP     = 0x21; PAGEDOWN    = 0x22;
  ENDK         = 0x23; HOME      = 0x24; LEFTARROW  = 0x25; UPARROW     = 0x26;
  RIGHTARROW   = 0x27; DOWNARROW = 0x28; SELECT     = 0x29; PRINT       = 0x2A;
  PRINTSCREEN  = 0x2C; INS       = 0x2D; DEL        = 0x2E; NUMLOCK     = 0x90;
  SCROLLLOCK   = 0x91; LeftSHIFT = 0xA0; RightSHIFT = 0xA1; LeftCONTROL = 0xA2;
  RightCONTROL = 0xA3; LeftALT   = 0xA4; RightALT   = 0xA5; LeftWin     = 0x5B;
  RightWin     = 0x5C; App       = 0x5D;
  
  #    nil,  F1,  F2   F3,  F4,  F5,  F6,  F7,  F8,  F9, F10, F11, F12
  F = [nil,0x70,0x71,0x72,0x73,0x74,0x75,0x76,0x77,0x78,0x79,0x7A,0x7B]
  
  KeyRepeatCounter = {}
  MouseMonitor = [0, 0, 0, 0, [0, 0], false]
  # 0 timer
  # 1 state: 0 normal 1 down 2 hold 3 up 4 click 5 clicked 6 dbclick 7 hold a db
  # 2 button: 0 normal 1 left 2 right 4 middle
  # 3 last button
  # 4 last pos
  # 5 moving?
  
  # APIs
  GetCursorPos     = _api "user32|GetCursorPos|p|i"
  ScreenToClient   = _api "user32|ScreenToClient|pp|i"
  GetActiveWindow  = _api "user32|GetActiveWindow||i"
  GetAsyncKeyState = _api "user32|GetAsyncKeyState|i|i"
  GetKeyState      = _api "user32|GetKeyState|i|i"
  ShowCursor       = _api "user32|ShowCursor|i|i"
  
class << self
  #--------------------------------------------------------------------------
  # * Alias method: update
  #--------------------------------------------------------------------------
  _def_ :update do |*args, &block|
    update_mouse
    update_keyboard
  end
  #--------------------------------------------------------------------------
  # * Alias method: press?
  #--------------------------------------------------------------------------
  _def_ :press?, :c do |old, key|
    return string_key(key, :press?) if key.is_a?(String)
    return old.call(key) if default_key? key
    return true unless KeyRepeatCounter[key].nil?
    return _press? key
  end
  #--------------------------------------------------------------------------
  # * Alias method: trigger?
  #--------------------------------------------------------------------------
  _def_ :trigger?, :c do |old, key|
    return string_key(key, :trigger?) if key.is_a?(String)
    return old.call(key) if default_key? key
    count = KeyRepeatCounter[key]
    return count == 0 || (count.nil? ? _press?(key) : false)
  end
  #--------------------------------------------------------------------------
  # * Alias method: repeat?
  #--------------------------------------------------------------------------
  _def_ :repeat?, :c do |old, key|
    return string_key(key, :repeat?) if key.is_a?(String)
    return old.call(key) if default_key? key
    count = KeyRepeatCounter[key]
    return true if count == 0
    return count.nil? ? _press?(key) : count >= 23 && (count - 23) % 6 == 0
  end
  #--------------------------------------------------------------------------
  # * Update Mouse
  #--------------------------------------------------------------------------
  def update_mouse
    # get current button state
    MouseMonitor[2] = 0
    Mouse.each_value{|k| MouseMonitor[2] += k if _mouse_press? k}
    # the button pressed differs?
    if MouseMonitor[2] != 0 && MouseMonitor[3] != 0 &&
    MouseMonitor[2] != MouseMonitor[3]
      [MouseMonitor[0] = 0, MouseMonitor[1] = 1] # if so
    else
      case MouseMonitor[1] # check the state if not
      when 0 # normal
        [MouseMonitor[0] = 0, MouseMonitor[1] += 1] if MouseMonitor[2] != 0
      when 1 # down
        [MouseMonitor[0] = 0, MouseMonitor[1] += 1]
      when 2 # hold
        [MouseMonitor[0] = 0, MouseMonitor[1] += 1] if MouseMonitor[2] == 0
      when 3 # up
        [MouseMonitor[0] = 0, MouseMonitor[1] += 1]
      when 4 # click
        [MouseMonitor[0] = 0, MouseMonitor[1] += 1]
      when 5 # clicked
        if MouseMonitor[2] != 0 then [MouseMonitor[0] = 0, MouseMonitor[1] += 1]
        elsif MouseMonitor[0] > Smomo::InputSet::DoubleClickInterval
          MouseMonitor[0] = MouseMonitor[1] = MouseMonitor[3] = 0
        end
      when 6 # dbclick
        [MouseMonitor[0] = 0, MouseMonitor[1] += 1]
      when 7 # hold after dbclick
        MouseMonitor[0] = MouseMonitor[1] = MouseMonitor[3] = 0 if
        MouseMonitor[2] == 0
      end
    end
    # save button state
    MouseMonitor[3] = MouseMonitor[2] unless MouseMonitor[2] == 0
    # moving?
    MouseMonitor[4] = get_cursor_pos if MouseMonitor[5] =
    MouseMonitor[4] != get_cursor_pos
    # timer
    MouseMonitor[0] += 1
  end
  #--------------------------------------------------------------------------
  # * The Button Is Pressed?
  #--------------------------------------------------------------------------
  def _mouse_press? button
    GetAsyncKeyState.call(button).abs & 0x8000 == 0x8000
  end
  #--------------------------------------------------------------------------
  # * Get The Time Current State Lasts
  #--------------------------------------------------------------------------
  def get_mouse_timer
    MouseMonitor[0]
  end
  #--------------------------------------------------------------------------
  # * Get Current Mouse State
  #--------------------------------------------------------------------------
  def get_mouse_state
    MouseMonitor[1]
  end
  #--------------------------------------------------------------------------
  # * Get Current Button State
  #--------------------------------------------------------------------------
  def get_button_state
    MouseMonitor[2]
  end
  #--------------------------------------------------------------------------
  # * Get Last Button State
  #--------------------------------------------------------------------------
  def get_last_button_state
    MouseMonitor[3]
  end
  #--------------------------------------------------------------------------
  # * Get Cursor Pos
  #--------------------------------------------------------------------------
  def get_cursor_pos
    GetCursorPos.call buffer = "\0"*8
    ScreenToClient.call  GetActiveWindow.call, buffer
    buffer.unpack "ll"
  end
  #--------------------------------------------------------------------------
  # * The Mouse Is Moving?
  #--------------------------------------------------------------------------
  def mouse_moving?
    MouseMonitor[5]
  end
  #--------------------------------------------------------------------------
  # * Update Keyboard
  #--------------------------------------------------------------------------
  def update_keyboard
    KeyRepeatCounter.each_key do |key|
      if GetAsyncKeyState.call(key).abs & 0x8000 == 0x8000
        KeyRepeatCounter[key] += 1
      else
        KeyRepeatCounter.delete(key)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * The Key Is Pressed?
  #--------------------------------------------------------------------------
  def _press? key
    if GetAsyncKeyState.call(key).abs & 0x8000 == 0x8000
      KeyRepeatCounter[key] = 0
      return true
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * The Key Is A Default Key?
  #--------------------------------------------------------------------------
  def default_key? key
    return DEFAULT.include? key
  end
  #--------------------------------------------------------------------------
  # * Interpret Strings And Handle The Quest
  #--------------------------------------------------------------------------
  def string_key key, sym
    if key.bitween? 'A'..'Z'
      method(sym).call LETTERS[key]
    elsif key.bitween? '0'..'9'
      method(sym).call(NUMBERS[key.to_i]) || method(sym).call(NUMPAD[key.to_i])
    else
      case key.downcase
      when '*'; method(sym).call Multiply
      when '+'; method(sym).call(Add)       || method(sym).call(EQUALS)
      when '-'; method(sym).call(Subtract)  || method(sym).call(USCORE)
      when '/'; method(sym).call(Divide)    || method(sym).call(SLASH)
      when ','; method(sym).call(Separator) || method(sym).call(COMMA)
      when '.'; method(sym).call(Decimal)   || method(sym).call(PERIOD)
      when '<'; method(sym).call COMMA
      when '>'; method(sym).call PERIOD
      when '?'; method(sym).call SLASH
      when ';' , ':'; method(sym).call SCOLON
      when '\'', '"'; method(sym).call QUOTE
      when '[' , '{'; method(sym).call LBRACE
      when ']' , '}'; method(sym).call RBRACE
      when '`' , '~'; method(sym).call TILDE
      when '\\', '|'; method(sym).call BSLASH
      when '!'; method(sym).call NUMBERS[1]
      when '@'; method(sym).call NUMBERS[2]
      when '#'; method(sym).call NUMBERS[3]
      when '$'; method(sym).call NUMBERS[4]
      when '%'; method(sym).call NUMBERS[5]
      when '^'; method(sym).call NUMBERS[6]
      when '&'; method(sym).call NUMBERS[7]
      when '*'; method(sym).call NUMBERS[8]
      when '('; method(sym).call NUMBERS[9]
      when ')'; method(sym).call NUMBERS[0]
      when '_'; method(sym).call USCORE
      when '='; method(sym).call EQUALS
      when 'shift'      ; method(sym).call SHIFT
      when 'lshift'     ; method(sym).call LeftSHIFT
      when 'rshift'     ; method(sym).call RightSHIFT
      when 'ctrl'       ; method(sym).call CTRL
      when 'lctrl'      ; method(sym).call LeftCTRL
      when 'rctrl'      ; method(sym).call RightCTRL
      when 'alt'        ; method(sym).call ALT
      when 'lalt'       ; method(sym).call LeftALT
      when 'ralt'       ; method(sym).call RightALT
      when 'app'        ; method(sym).call App
      when 'tab'        ; method(sym).call TAB
      when 'capslock'   ; method(sym).call CAPSLOCK
      when 'numlock'    ; method(sym).call NUMLOCK
      when 'scrolllock' ; method(sym).call SCROLLLOCK
      when 'enter'      ; method(sym).call ENTER
      when 'backspace'  ; method(sym).call BACKSPACE
      when 'space'      ; method(sym).call SPACEBAR
      when 'ins'        ; method(sym).call INS
      when 'del'        ; method(sym).call DEL
      when 'home'       ; method(sym).call HOME
      when 'end'        ; method(sym).call ENDK
      when 'pageup'     ; method(sym).call PAGEUP
      when 'pagedown'   ; method(sym).call PAGEDOWN
      when 'esc'        ; method(sym).call ESC
      when 'uparrow'    ; method(sym).call UPARROW
      when 'downarrow'  ; method(sym).call DOWNARROW
      when 'leftarrow'  ; method(sym).call LEFTARROW
      when 'rightarrow' ; method(sym).call RIGHTARROW
      when 'printscreen'; method(sym).call PRINTSCREEN
      when 'select'     ; method(sym).call SELECT
      when 'print'      ; method(sym).call PRINT
      when 'lwin'       ; method(sym).call LeftWin
      when 'rwin'       ; method(sym).call RightWin
      when 'win'; method(sym).call(LeftWin) || method(sym).call(RightWin)
      else; key == key.slice(0, 1) ? false : string_key(key.slice(0, 1), sym)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Typing?
  #--------------------------------------------------------------------------
  def typing?
    repeat?(SPACEBAR) || LETTERS.any?{|l, c| repeat? c} ||
    NUMBERS.any?{|n| repeat? n} || NUMPAD.any?{|n| repeat? n} ||
    repeat?(Multiply) || repeat?(Decimal)|| repeat?(Divide)|| repeat?(COMMA) ||
    repeat?(Separator)|| repeat?(Add)    || repeat?(EQUALS)|| repeat?(SLASH) ||
    repeat?(SCOLON)   || repeat?(USCORE) || repeat?(PERIOD)|| repeat?(TILDE) ||
    repeat?(Subtract) || repeat?(LBRACE) || repeat?(BSLASH)|| repeat?(RBRACE)||
    repeat?(QUOTE)
  end
  #--------------------------------------------------------------------------
  # * Type of the key typed
  #--------------------------------------------------------------------------
  def key_type
    return " " if repeat? SPACEBAR
    LETTERS.each{|l, c| return upcase? ? l.upcase : l.downcase if repeat? c}
    NUMPAD.each_with_index{|n, i| return i.to_s if repeat? n}
    if press? SHIFT
      NUMBERS.each_with_index do |n, i|
        next unless repeat? n
        case i
        when 1; return "!"
        when 2; return "@"
        when 3; return "#"
        when 4; return "$"
        when 5; return "%"
        when 6; return "^"
        when 7; return "&"
        when 8; return "*"
        when 9; return "("
        when 0; return ")"
        end
      end
    else
      NUMBERS.each_with_index{|n, i| return i.to_s if repeat? n}
    end
    return "*" if press? Multiply
    return "+" if press? Add
    return "-" if press? Subtract
    return "/" if press? Divide
    return "," if press? Separator
    return "." if press? Decimal
    return press?(SHIFT) ? ":" : ";"  if press? SCOLON
    return press?(SHIFT) ? "+" : "="  if press? EQUALS
    return press?(SHIFT) ? "<" : ","  if press? COMMA
    return press?(SHIFT) ? "_" : "-"  if press? USCORE
    return press?(SHIFT) ? ">" : "."  if press? PERIOD
    return press?(SHIFT) ? "?" : "/"  if press? SLASH
    return press?(SHIFT) ? "~" : "`"  if press? TILDE
    return press?(SHIFT) ? "{" : "["  if press? LBRACE
    return press?(SHIFT) ? "|" : "\\" if press? BSLASH
    return press?(SHIFT) ? "}" : "]"  if press? RBRACE
    return press?(SHIFT) ? '"' : "'"  if press? QUOTE
    return ""
  end
  #--------------------------------------------------------------------------
  # * Upcase?
  #--------------------------------------------------------------------------
  def upcase?
    return press?(SHIFT) != (GetKeyState.call(CAPSLOCK) == 1)
  end
  #--------------------------------------------------------------------------
  # * Hide Methods
  #--------------------------------------------------------------------------
  private :_mouse_press?, :_press?, :upcase?
end
end
#==============================================================================
# ** Smomo.mouse
#==============================================================================
module Smomo  
  module_function
  #--------------------------------------------------------------------------
  # * Register Classes
  #--------------------------------------------------------------------------
  def mouse method, classname
    case method
    when :register
      classname.class_eval %Q!
        #--------------------------------------------------------------------
        # * Alias method: update
        #--------------------------------------------------------------------
        _def_ :update do |*args, &block| update_mouse if mouse_in_area? end
        #--------------------------------------------------------------------
        # * Update mouse
        #--------------------------------------------------------------------
        def update_mouse
          case mouse_button_state
          when 0
            onMouseMove if mouse_moving?
          when 1, 5
            case mouse_state
            when 1; onMouseDown
            when 2; onHold
            when 3; onMouseUp
            when 4; onClick
            when 6; onDoubleClick
            end
          when 2, 3, 6
            case mouse_state
            when 1; onRightMouseDown
            when 2; onRightHold
            when 3; onRightMouseUp
            when 4; onRightClick
            when 6; onRightDoubleClick
            end
          when 4
            case mouse_state
            when 1; onMiddleMouseDown
            when 2; onMiddleHold
            when 3; onMiddleMouseUp
            when 4; onMiddleClick
            when 6; onMiddleDoubleClick
            end
          end
        end
        #--------------------------------------------------------------------
        # * The Mouse Is In Area?
        #--------------------------------------------------------------------
        def mouse_in_area?
          pos = mouse_pos
          pos[0].between?((self.x), (self.x + self.width)) &&
          pos[1].between?((self.y), (self.y + self.height))
        end
        #--------------------------------------------------------------------
        # * On-Drag Interval
        #--------------------------------------------------------------------
        def mouse_drag_interval
          #{ Smomo::InputSet::DragInterval }
        end
        #--------------------------------------------------------------------
        # * Receivers
        #--------------------------------------------------------------------
        def onDrag;              end unless defined?(onDrag)
        def onMouseMove;         end unless defined?(onMouseMove)
        def onMouseDown;         end unless defined?(onMouseDown)
        def onHold;              end unless defined?(onHold)
        def onMouseUp;           end unless defined?(onMouseUp)
        def onClick;             end unless defined?(onClick)
        def onDoubleClick;       end unless defined?(onDoubleClick)
        def onRightMouseDown;    end unless defined?(onRightMouseDown)
        def onRightHold;         end unless defined?(onRightHold)
        def onRightMouseUp;      end unless defined?(onRightMouseUp)
        def onRightClick;        end unless defined?(onRightClick)
        def onRightDoubleClick;  end unless defined?(onRightDoubleClick)
        def onMiddleMouseDown;   end unless defined?(onMiddleMouseDown)
        def onMiddleHold;        end unless defined?(onMiddleHold)
        def onMiddleMouseUp;     end unless defined?(onMiddleMouseUp)
        def onMiddleClick;       end unless defined?(onMiddleClick)
        def onMiddleDoubleClick; end unless defined?(onMiddleDoubleClick)
        #--------------------------------------------------------------------
        # * Shortcuts
        #--------------------------------------------------------------------
        def mouse_pos
          Input.get_cursor_pos
        end
        def mouse_button_state
          Input.get_last_button_state
        end
        def mouse_state
          Input.get_mouse_state
        end
        def mouse_moving?
          Input.mouse_moving?
        end
        def mouse_timer
          Input.get_mouse_timer
        end
      !
    when :dragable # TODO
      classname.class_eval %Q!
        def onHold
          onDrag if mouse_timer > mouse_drag_interval
        end
        def onDrag
          @mouse_pos_blablablabla ||= mouse_pos
          self.x += mouse_pos[0] - @mouse_pos_blablablabla[0]
          self.y += mouse_pos[1] - @mouse_pos_blablablabla[1]
          @mouse_pos_blablablabla = mouse_pos
        end
        def onMouseUp
          @mouse_pos_blablablabla = nil
        end
      !
    else
      raise ArgumentError, "Invalid Argument '#{method}'!"
    end
  end
end