
# unfinished

def load_gif(filename)
  GIF.new(filename)
end

class GIF
  attr_accessor :version, :gtable, :width, :height, :bgcolor
  Color ||= Struct.new(:red, :green, :blue)
  ImageDescriptor         = 0x2C
  Extension               = 0x21
  CommentExtension        = 0xFE
  GraphicControlExtension = 0xF9
  PlainTextExtension      = 0x01
  ApplicationExtension    = 0xFF
  Trailer                 = 0x3B
  def initialize(filename)
    data = open(filename, "rb")
    #### Header
    raise TypeError, "Not a valid gif!" if data.read(3) != "GIF"
    @version = data.read(3) #=> 87a|89a
    #### GIF Data Stream
    reada = ->(bytes = 1){ data.read(bytes) }
    readc = ->{ data.read(1).unpack("C")[0] }
    reads = ->{ data.read(2).unpack("S")[0] }
    ### Logical Screen Descriptor
    @width        = reads.call#
    @height       = reads.call#
    packed_fields = readc.call
    @bgcolor      = readc.call#
    pixel_aspect_ratio      = readc.call #
    ## Unpack packed fields
    gtable_flag      = packed_fields & 0x80
    color_resoluTion = packed_fields & 0x70#
    sort_flag        = packed_fields & 0x08#
    pixel            = packed_fields & 0x07
    ### Global Color Table
    @gtable = reada.(3 * 2 ** (pixel + 1)).split("").each_slice(3).collect{|c|
    Color.new(*c.map{|x| x.unpack("C")[0]})} if gtable_flag == 0x80
    #
    while (descriptor = readc.call) != Trailer
      case descriptor
      when ImageDescriptor
        x             = reads.call
        y             = reads.call
        width         = reads.call
        height        = reads.call
        packed_fields = readc.call
        # Unpack packed fields
        raise Exception, "Unexpected Error!" if packed_fields & 0x18 != 0x00
        ltable_flag    = packed_fields & 0x80
        interlace_flag = packed_fields & 0x40
        sort_flag      = packed_fields & 0x20#
        pixel          = packed_fields & 0x07
        ## Local Color Table
        table = nil
        table = reada.(3 * 2 ** (pixel + 1)).split("").each_slice(3).collect{|c|
        Color.new(*c.map{|x| x.unpack("C")[0]})} if ltable_flag == 0x80
        ## Table-Based Image Data
        # LZW Minimum Code Size => Clear Code
        clear_code = 1 << readc.call#
        # Image Data
        while (code_size = readc.call) != 0x00
          # Data Sub-blocks
          code = reada.(code_size)
          #================#
          #     Decode     #
          #================#
          #dictionary = 
          if interlace_flag == 0x40 # Interlace
          else # Continuous
          end
          #================#
          #      Draw      #
          #================#
        end
        # reset
        disposal_method          = 0
        use_input_flag           = 0
        transparent_color_flag   = 0
        delay_time               = 1
        transparent_color_index  = 0
      when Extension
        case readc.call
        when CommentExtension
          code = reada.(code_size) while (code_size = readc.call) != 0x00
        when GraphicControlExtension
          raise Exception, "Unexpected Error!" if readc.call != 0x04
          packed_fields            = readc.call
          delay_time               = reads.call#
          transparent_color_index  = readc.call#
          # Unpack packed fields
          disposal_method          = packed_fields & 0x3C#
          use_input_flag           = packed_fields & 0x02#
          transparent_color_flag   = packed_fields & 0x01#
          raise Exception, "Unexpected Error!" if readc.call != 0x00
        when PlainTextExtension
          raise Exception, "Unexpected Error!" if readc.call != 0x0C
          text_glid_left_posotion      = reads.call#
          text_glid_top_posotion       = reads.call#
          text_glid_width              = reads.call#
          text_glid_height             = reads.call#
          character_cell_width         = readc.call#
          character_cell_height        = readc.call#
          text_foreground_color_index  = readc.call#
          text_blackground_color_index = readc.call#
          while (code_size = readc.call) != 0x00
            # Data Sub-blocks
            code = reada.(code_size)
          end
          #================#
          #      Draw      #
          #================#
          # reset
          disposal_method          = 0
          use_input_flag           = 0
          transparent_color_flag   = 0
          delay_time               = 1
          transparent_color_index  = 0
        when ApplicationExtension
          raise Exception, "Unexpected Error!" if readc.call != 0x0B
          reada.(8)
          reada.(3)
          code = reada.(code_size) while (code_size = readc.call) != 0x00
        end
      else
        raise Exception, "Unexpected Error!" unless data.pos = data.size - 1
      end
    end
  rescue => e
    p e
  ensure
    data.close
  end
end
