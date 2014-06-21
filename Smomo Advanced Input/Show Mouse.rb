
# beta

#==============================================================================
# ** Input
#==============================================================================
module Input
  # hide system cursor
  ShowCursor.call 0
end
#==============================================================================
# ** Graphics
#==============================================================================
class << Graphics
  _def_ :update do |*args, &block|
    @mo_cursor_sprite = Sprite_MoCursor.new if @mo_cursor_sprite.nil? ||
    @mo_cursor_sprite.disposed?
    @mo_cursor_sprite.update
  end
end
#==============================================================================
# ** Sprite_MoCursor 
#==============================================================================
class Sprite_MoCursor < Sprite
  def initialize
    super Viewport.new
    self.viewport.z = 500
    load_cursor
  end
  
  def load_cursor
    self.bitmap = Cache.system "Cursors"
  rescue Errno::ENOENT
    self.bitmap = Bitmap.new(24, 24)
    icon_index = 398
    bitmap.blt(0, 0, Cache.system("Iconset"),
    Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24), 255)
  end
  
  def update
    self.x, self.y = *Input.get_cursor_pos
  end
  
  def dispose
    bitmap.dispose if bitmap
    super
  end
end