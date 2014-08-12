#=============================================================================
# ** RGSS3 Decrypter
# Algorithm: fux2
# Implementator: Shadow Momo
#-----------------------------------------------------------------------------
# * eg: decrypt("Game.rgss3a")
#-----------------------------------------------------------------------------
# * It is strictly prohibited to use this decrypter for any purpose except
# learning and exchanging.
# * Do not spread it out.
# * We are not legally responsible for the decrypter provided.
#=============================================================================

def decrypt(path, output = "Decryption", islog = true)
  mkdir = ->(path){
    path.scan(/^(.*)\\/){ mkdir.($1) }
    Dir.mkdir path unless Dir.exist? path
  }
  
  if Dir.exist? output
    output += Time.now.strftime("%j-%H-%M-%S")
    msgbox "Directory already exists! Will extract to new directory: #{output}"
  end
  mkdir.(output)
  
  logfile = File.open output + "\\" + "Decrypt.log", "w+" if islog
  log = ->(string){logfile.puts string if islog; puts string}
  
  log.("Begin")
  
  log.("")
  
  log.("Try to open archive...")
  archive = open path, "rb"
  if archive.read(8) != "RGSSAD\0\3"
    log.("Standard RPG Maker VX Ace Encrypted Archive Expected!")
    raise TypeError, "Standard RPG Maker VX Ace Encrypted Archive Expected!"
  end
  log.("Archive opened successfully.")
  
  key = archive.read(4).unpack("L")[0] * 9 + 3
  
  files = []
  
  log.("")
  
  log.("Analyse Files...")
  i = 0
  loop do
    break if (offset = archive.read(4).unpack("L")[0] ^ key) == 0
    i += 1
    length   = archive.read(4).unpack("L")[0] ^ key
    magickey = archive.read(4).unpack("L")[0] ^ key
    flength     = archive.read(4).unpack("L")[0] ^ key
    filename = archive.read(flength)
    _ = "L" * ((flength + 3) / 4)
    filename += "\0" * 4
    filename = filename.unpack(_).map{|x| x ^ key}.pack(_)[0, flength]
    log.("-File ##{i}: #{filename}")
    log.("--Offset: #{offset}\tLength: #{length}")
    files.push [offset, length, magickey, filename.force_encoding('utf-8')]
  end
  log.("All files analysed.")
  
  log.("")
  
  log.("Extract Files...")
  files.each_with_index do |(offset, length, magickey, filename), i|
    log.("-Extracting File ##{i + 1}: #{filename}")
    archive.pos = offset
    contents = archive.read(length)
    _ = "L" * ((length + 3) / 4)
    contents = (contents + "\0" * 4).unpack(_).collect{|x|
      unit = x ^ magickey
      magickey = magickey * 7 + 3
      unit
    }.pack(_)[0, length]
    filename.scan(/^(.*)\\/){ mkdir.(output + "\\" + $1) }
    File.open output + "\\" + filename, "wb" do |data| data.write contents end
    log.("--Succeed.")
  end
  log.("All files extracted.")
  
  log.("")
  
  log.("End")
  
  log.("")
  
  log.("")
  
  log.("Now Check Completeness...")
  
  flag = true
  
  files.each_with_index{|(offset, length, magickey, filename), i|
    log.("-Checking File ##{i + 1}: #{filename}")
    begin
      load_data(output + "\\" + filename)
      log.("--OK!")
    rescue
      flag = false
      log.("--Failed!")
    end
  }
  
  log.(flag ? "Perfect!" : ":(")
rescue => e
  begin
    log.("")
    log.("Abort on exception: #{e.inspect}!")
    log.("Decrypting failed.")
  end rescue nil
ensure
  logfile.close if islog rescue nil
  archive.close rescue nil
end

decrypt("Encryption\\Game.rgss3a")
