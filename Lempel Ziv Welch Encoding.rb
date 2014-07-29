#=============================================================================
# ** Lempel Ziv Welch Encoding
# Implementator: Shadow Momo
#-----------------------------------------------------------------------------
# Compressor:   LZW.com(somestring, spliter = "#")
# Decompressor: LZW.dec(somecode,   spliter = "#")
# eg: LZW.dec(LZW.com("somestring")) #=> "somestring"
#     LZW.dec(LZW.com("somestring", "T")) #=> "Cannot Decompress!"
#     LZW.dec(LZW.com("somestring"), "T") #=> "Cannot Decompress!"
#     LZW.dec(LZW.com("somestring", "R"), "T") #=> "Cannot Decompress!"
#     LZW.dec(LZW.com("somestring", "T"), "T") #=> "somestring"
#=============================================================================
module LZW
  # module_function
  module_function
  # Compressor
  def com(charstream, spliter = "#")
    charstream = charstream.clone
    dictionary = 0x100.times.map &:chr
    prefix = String.new
    codestream = []
    char = charstream.slice!(0, 1)
    until char.empty?
      if dictionary.include?(prefix + char)
        prefix.concat char
      else
        dictionary.push prefix + char
        codestream.push dictionary.index prefix
        prefix = char
      end
      char = charstream.slice!(0, 1)
    end
    codestream.push dictionary.index prefix
    codestream.join spliter
  end
  # Decompressor
  def dec(codestream, spliter = "#")
    codestream = codestream.split(spliter).map &:to_i
    dictionary = 0x100.times.map &:chr
    code = codestream.shift
    return String.new if code.nil?
    (charstream = String.new).concat dictionary[old = code]
    code = codestream.shift
    until code.nil?
      if dictionary[code]
        charstream.concat dictionary[code]
        prefix = dictionary[old]
        char = dictionary[code][0]
        dictionary.push prefix + char
        old = code
      else
        prefix = dictionary[old]
        char = prefix[0]
        charstream.concat prefix + char
        dictionary.push prefix + char
        old = code
      end
      code = codestream.shift
    end
    charstream
  rescue
    "Cannot Decompress!"
  end
end
