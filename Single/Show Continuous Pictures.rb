#==============================================================================
# ■ 播放连续图片
#  作者：影月千秋
#  版本：V 1.1
#  适用：VA
#------------------------------------------------------------------------------
# ● 简介
#  可以按顺序播放一连串图片 形成动画效果
#  XP版作者：天地有正气
#  详见发布帖：http://bbs.66rpg.com/thread-351129-1-1.html
#==============================================================================
# ● 使用方法
#   将此脚本插入到其他脚本以下，Main以上
#   在Graphics下新建文件夹，名为MoviePics
#   假设你需要一个动画 名为"ani" 那么在MoviePics下再新建一个文件夹 名为ani
#    把图片碎片保存在Graphics/MoviePics/ani下
#    将图片碎片命名，形如【"(1).png"，"(2).png"，……】不需要加上"ani"
#   事件脚本调用：
#    picmovie(文件夹名, 横坐标, 纵坐标, 图片张数, 每张图片停留的帧数, 显示端口)
#   每张图片停留的帧数可以省略 默认为一帧  显示端口也可以省略
#   在这个例子中 也就是：
#    picmovie("ani", 100, 150, 20, 3)
#   代表总共有20张图片 显示在(100,150)这个地方 图片在ani文件夹内 每张停留3帧
#   也可以使用
#    picmovie2(文件夹名, 事件ID, 图片张数, 每张图片停留的帧数, 显示端口)
#   将在指定ID的事件上播放动画 事件ID为0 则为当前事件 为-1 则为玩家
#   注意这个是picmovie2 而不是picmovie
#==============================================================================
# ● 更新
#   V 1.1 2014.02.16 新增了在指定事件播放的功能
#   V 1.0 2014.02.15 新建
#==============================================================================
# ● 声明
#   本脚本来自【影月千秋】
#   本脚本XP版来自【天地有正气】
#   使用、修改和转载请保留此信息
#==============================================================================

#==============================================================================
# ■ Cache
#==============================================================================
class << Cache
  def moviepics(folder, seq)
    load_bitmap("Graphics/MoviePics/#{folder}/", "(#{seq})")
  end
end
#==============================================================================
# ■ Game_Interpreter
#==============================================================================
class Game_Interpreter
  def picmovie(folder, x, y, fcount, wcount = 1, viewport = nil)
    sp = Sprite.new(viewport)
    sp.x, sp.y = x, y
    seq = 1
    until seq >= fcount
      sp.bitmap.dispose if sp.bitmap
      sp.bitmap = Cache.moviepics(folder, seq)
      wcount.times{Graphics.update; Fiber.yield}
      seq += 1
    end
  rescue
    msgbox "错误信息：#{$!}\n播放到第#{seq}张,在动画#{folder}" if $TEST || $BTEST
  ensure
    sp.dispose rescue nil
  end
  def picmovie2(folder, cid, fcount, wcount = 1, viewport = nil)
    sp = Sprite.new(viewport)
    seq = 1
    sp.bitmap = Cache.moviepics(folder, seq)
    sp.ox, sp.oy = sp.bitmap.width / 2, sp.bitmap.height / 2
    sp.x, sp.y = get_character(cid).screen_x, get_character(cid).screen_y
    until seq >= fcount
      sp.bitmap.dispose if sp.bitmap
      sp.bitmap = Cache.moviepics(folder, seq)
      wcount.times{Graphics.update; Fiber.yield}
      seq += 1
    end
  rescue
    msgbox "错误信息：#{$!}\n播放到第#{seq}张,在动画#{folder}" if $TEST || $BTEST
  ensure
    sp.dispose rescue nil
  end
end
