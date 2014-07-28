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
  if Dir.exist? output
    output += Time.now.strftime("%j-%H-%M-%S")
    msgbox "Directory already exists! Will extract to new directory: #{output}"
  end
  Dir.mkdir output
  
  logfile = File.open output + "\\" + "decrypt.log", "w+" if islog
  log = ->(string){logfile.puts string if islog; puts string}
  
  log.("Begin")
  
  log.("")
  
  log.("Try to open archive...")
  file = open path, "rb"
  if file.read(8) != "RGSSAD\0\3"
    log.("Standard RPG Maker VX Ace Encrypted Archive Expected!")
    raise TypeError, "Standard RPG Maker VX Ace Encrypted Archive Expected!"
  end
  log.("Archive opened successfully.")
  
  key = file.read(4).unpack("L")[0]
  key = key * 9 + 3
  
  offset   = []
  length   = []
  magickey = []
  filename = []
  
  log.("")
  
  log.("Analyse Files...")
  i = 0
  loop do
    break if (offset[i] = file.read(4).unpack("L")[0] ^ key) == 0
    length[i]   = file.read(4).unpack("L")[0] ^ key
    magickey[i] = file.read(4).unpack("L")[0] ^ key
    flength     = file.read(4).unpack("L")[0] ^ key
    filename[i] = file.read(flength)
    _ = "L" * (flength / 4 + (flength % 4 > 0 ? 1 : 0))
    filename[i] += "\0" * (4 - flength % 4)
    filename[i] = filename[i].unpack(_).map{|x| x ^ key}.pack(_)
    filename[i] = filename[i][0, flength]
    log.("-File:#{filename[i]}\t\tOffset:#{offset[i]}\tLength:#{length[i]}")
    i += 1
  end
  log.("Total: #{i}")
  
  log.("")
  
  log.("Extract Files...")
  i = 0
  loop do
    break if i == filename.size
    log.("-Extracting File: #{filename[i]}")
    file.pos = offset[i]
    contents = file.read(length[i])
    _ = "L" * (length[i] / 4 + (length[i] % 4 > 0 ? 1 : 0))
    contents += "\0" * (4 - length[i] % 4)
    contents = contents.unpack(_).map{|x|
      r = x ^ magickey[i]
      magickey[i] = magickey[i] * 7 + 3 % (1 << (4 * 8))
      r
    }.pack(_)
    contents = contents[0, length[i]]
    filename[i].scan(/^(.*)\\/).each{|(d)|
      next if Dir.exist? _ = output + "\\" + d
      Dir.mkdir _
    }
    File.open output + "\\" + filename[i], "wb" do |data|
      data.write contents
    end
    log.("--Succeed.")
    i += 1
  end
  log.("Total: #{i}")
  
  log.("")
  
  log.("End")
  
  log.("")
  
  log.("")
  
  log.("Now Check Completeness...")
  
  flag = true
  
  %W{Actors.rvdata2 Animations.rvdata2 Armors.rvdata2 Classes.rvdata2
    CommonEvents.rvdata2 Enemies.rvdata2 Items.rvdata2 Map001.rvdata2
    MapInfos.rvdata2 Scripts.rvdata2 Skills.rvdata2 States.rvdata2
    System.rvdata2 Tilesets.rvdata2 Troops.rvdata2 Weapons.rvdata2
  }.each{|x|
    begin
      load_data(output + "\\Data\\" + x)
      log.("-#{x} OK!")
    rescue
      log.("-#{x} Failed!")
      flag = false
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
  file.close rescue nil
end
