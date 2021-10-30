def pbSameThread(wnd)
  return false if wnd==0
  processid = [0].pack('l')
  getCurrentThreadId       = Win32API.new('kernel32','GetCurrentThreadId', '%w()','l')
  getWindowThreadProcessId = Win32API.new('user32','GetWindowThreadProcessId', '%w(l p)','l')
  threadid    = getCurrentThreadId.call
  wndthreadid = getWindowThreadProcessId.call(wnd,processid)
  return (wndthreadid==threadid)
end



module Input
  DOWN   = 2
  LEFT   = 4
  RIGHT  = 6
  UP     = 8
  A      = 11
  B      = 12
  C      = 13
  X      = 14
  Y      = 15
  Z      = 16
  L      = 17
  R      = 18
  SHIFT  = 21
  CTRL   = 22
  ALT    = 23
  F5 = F = 25
  F6     = 26
  F7     = 27
  F8     = 28
  F9     = 29
  LeftMouseKey  = 1
  RightMouseKey = 2
  # GetAsyncKeyState or GetKeyState will work here
  @GetKeyState         = Win32API.new("user32","GetAsyncKeyState","i","i")
  @GetForegroundWindow = Win32API.new("user32","GetForegroundWindow","","i")

  # Returns whether a key is being pressed
  def self.getstate(key)
    return (@GetKeyState.call(key)&0x8000)>0
  end

  def self.updateKeyState(i)
    gfw = pbSameThread(@GetForegroundWindow.call())
    if !@stateUpdated[i]
      newstate = self.getstate(i) && gfw
      @triggerstate[i] = (newstate && @keystate[i]==0)
      @releasestate[i] = (!newstate && @keystate[i]>0)
      @keystate[i] = (newstate) ? @keystate[i]+1 : 0
      @stateUpdated[i] = true
    end
  end

  def self.update
    if @keystate
      for i in 0...256
        # just noting that the state should be updated
        # instead of thunking to Win32 256 times
        @stateUpdated[i] = false
        if @keystate[i]>0
          # If there is a repeat count, update anyway
          # (will normally apply only to a very few keys)
          updateKeyState(i)
        end
      end    
    else
      @stateUpdated = []
      @keystate     = []
      @triggerstate = []
      @releasestate = []
      for i in 0...256
        @stateUpdated[i] = true
        @keystate[i]     = (self.getstate(i)) ? 1 : 0
        @triggerstate[i] = false
        @releasestate[i] = false
      end
    end
  end

  def self.buttonToKey(button)
    case button
    when Input::DOWN;  return [0x28]                # Down
    when Input::LEFT;  return [0x25]                # Left
    when Input::RIGHT; return [0x27]                # Right
    when Input::UP;    return [0x26]                # Up
    when Input::A;     return [0x5A,0x57,0x59,0x10] # Z, W, Y, Shift
    when Input::B;     return [0x58,0x1B]           # X, ESC
    when Input::C;     return [0x43,0x0D,0x20]      # C, ENTER, Space
#    when Input::X;     return [0x41]               # A
#    when Input::Y;     return [0x53]               # S
#    when Input::Z;     return [0x44]               # D
    when Input::L;     return [0x41,0x51,0x21]           # A, Q
    when Input::R;     return [0x53,0x22]           # S, Page Down
    when Input::SHIFT; return [0x10]                # Shift
    when Input::CTRL;  return [0x11]                # Ctrl
    when Input::ALT;   return [0x12]                # Alt
    when Input::F5;    return [0x46,0x74,0x09]      # F, F5, Tab
    when Input::F6;    return [0x75]                # F6
    when Input::F7;    return [0x76]                # F7
    when Input::F8;    return [0x77]                # F8
    when Input::F9;    return [0x78]                # F9
    else; return []
    end
  end

  def self.dir4
    button      = 0
    repeatcount = 0
    return 0 if self.press?(Input::DOWN) && self.press?(Input::UP)
    return 0 if self.press?(Input::LEFT) && self.press?(Input::RIGHT)
    for b in [Input::DOWN,Input::LEFT,Input::RIGHT,Input::UP]
      rc = self.count(b)
      if rc>0
        if repeatcount==0 || rc<repeatcount
          button      = b
          repeatcount = rc
        end
      end
    end
    return button
  end

  def self.dir8
    buttons = []
    for b in [Input::DOWN,Input::LEFT,Input::RIGHT,Input::UP]
      rc = self.count(b)
      buttons.push([b,rc]) if rc>0
    end
    if buttons.length==0
      return 0
    elsif buttons.length==1
      return buttons[0][0]
    elsif buttons.length==2
      # since buttons sorted by button, no need to sort here
      return 0 if (buttons[0][0]==Input::DOWN && buttons[1][0]==Input::UP)
      return 0 if (buttons[0][0]==Input::LEFT && buttons[1][0]==Input::RIGHT)
    end
    buttons.sort!{|a,b| a[1]<=>b[1]}
    updown    = 0
    leftright = 0
    for b in buttons
      updown    = b[0] if updown==0 && (b[0]==Input::UP || b[0]==Input::DOWN)
      leftright = b[0] if leftright==0 && (b[0]==Input::LEFT || b[0]==Input::RIGHT)
    end
    if updown==Input::DOWN
      return 1 if leftright==Input::LEFT
      return 3 if leftright==Input::RIGHT
      return 2
    elsif updown==Input::UP
      return 7 if leftright==Input::LEFT
      return 9 if leftright==Input::RIGHT
      return 8
    else
      return 4 if leftright==Input::LEFT
      return 6 if leftright==Input::RIGHT
      return 0
    end
  end

  def self.count(button)
    for btn in self.buttonToKey(button)
      c = self.repeatcount(btn)
      return c if c>0
    end
    return 0
  end

  def self.release?(button)
    rc = 0
    for btn in self.buttonToKey(button)
      c = self.repeatcount(btn)
      return false if c>0
      rc += 1 if self.releaseex?(btn)
    end
    return rc>0
  end

  def self.trigger?(button)
    return self.buttonToKey(button).any? {|item| self.triggerex?(item) }
  end

  def self.repeat?(button)
    return self.buttonToKey(button).any? {|item| self.repeatex?(item) }
  end

  def self.press?(button)
    return self.count(button)>0
  end

  def self.repeatex?(key)
    return false if !@keystate
    updateKeyState(key)
    return @keystate[key]==1 || (@keystate[key]>20 && (@keystate[key]&1)==0)
  end

  def self.releaseex?(key)
    return false if !@releasestate
    updateKeyState(key)
    return @releasestate[key]
  end

  def self.triggerex?(key)
    return false if !@triggerstate
    updateKeyState(key)
    return @triggerstate[key]
  end

  def self.repeatcount(key)
    return 0 if !@keystate
    updateKeyState(key)
    return @keystate[key]
  end

  def self.pressex?(key)
    return self.repeatcount(key)>0
  end
end



# Requires Win32API
module Mouse
  gsm             = Win32API.new('user32','GetSystemMetrics','i','i')
  @GetCursorPos   = Win32API.new('user32','GetCursorPos','p','i')
  @SetCapture     = Win32API.new('user32','SetCapture','p','i')
  @ReleaseCapture = Win32API.new('user32','ReleaseCapture','','i')
  module_function

  def getMouseGlobalPos
    pos = [0, 0].pack('ll')
    return (@GetCursorPos.call(pos)!=0) ? pos.unpack('ll') : nil
  end

  def screen_to_client(x, y)
    return nil unless x and y
    screenToClient = Win32API.new('user32','ScreenToClient',%w(l p),'i')
    pos = [x, y].pack('ll')
    return pos.unpack('ll') if screenToClient.call(Win32API.pbFindRgssWindow,pos)!=0
    return nil
  end

  def setCapture
    @SetCapture.call(Win32API.pbFindRgssWindow)
  end

  def releaseCapture
    @ReleaseCapture.call
  end

  # Returns the position of the mouse relative to the game window.
  def getMousePos(catch_anywhere=false)
    resizeFactor = ($ResizeFactor) ? $ResizeFactor : 1
    x, y = screen_to_client(*getMouseGlobalPos)
    width, height = Win32API.client_size
    if catch_anywhere or (x>=0 and y>=0 and x<width and y<height)
      return (x/resizeFactor).to_i, (y/resizeFactor).to_i
    end
    return nil
  end

  def del
    return if @oldcursor==nil
    @SetClassLong.call(Win32API.pbFindRgssWindow,-12,@oldcursor)
    @oldcursor = nil
  end
end


# Requires module Mouse
# ------------------------------------------------------------------------------
#  Mouse input class written by Luka S.J. to enable the usage of the native 
#  mouse module in Essentials.
#  Please give credit if used.
# ------------------------------------------------------------------------------
class Game_Mouse
  attr_reader :visible
  attr_reader :x
  attr_reader :y
  
  # replace nil with a valid path to a graphics location to display a sprite
  # for the mouse
  @@graphics_path = nil
  
  # starts up the mouse and determines initial co-ordinate
  def initialize
    @mouse = Mouse
    @position = @mouse.getMousePos
    @cursor = Win32API.new("user32", "ShowCursor", "i", "i" ) 
    @visible = false
    if @position.nil?
      @x = 0
      @y = 0
    else
      @x = @position[0]
      @y = @position[1]
    end
    @static_x = @x
    @static_y = @y
    @object_ox = nil
    @object_oy = nil
    # used to make on screen mouse sprite (if a graphics path is defined)
      @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
      @viewport.z = 0x3FFFFFFF
      @sprite = Sprite.new(@viewport)
      if !@@graphics_path.nil?
        @sprite.bitmap = BitmapCache.load_bitmap(@@graphics_path)
        self.show
      end
      @custome_bitmap=Sprite.new(@viewport)
      @custome_bitmap.bitmap = BitmapCache.load_bitmap("Graphics/Pictures/whitescreen")
      @custome_bitmap.visible=false
      @custome_bitmap.opacity=155
      @sprite.visible = @visible
      @sprite.x = @x
      @sprite.y = @y
    # ===================================================================
  end

  
  # updates the mouse (update placed in Input.update)
  def update
    @position = @mouse.getMousePos
    if !@position.nil?
      @x = @position[0] - $ResizeOffsetX
      @y = @position[1] - $ResizeOffsetY
    else
      @x = -5000
      @y = -5000
    end
    @sprite.visible = @visible
    @sprite.x = @x
    @sprite.y = @y
  end
   
  # manipulation of the visibility of the mouse sprite
  def show
    @cursor.call(0)
    @visible=true
  end
  
  def hide
    @cursor.call(1)
    @visible=false
  end
  
   # checks if mouse is over a sprite (can define custom width and height)
  def pbMouseOver?(image,width=-1,height=-1)
    width=image.bitmap.width if width==-1
    height=image.bitmap.height if height==-1
    if @x >= image.x && @x <= (image.x + width) and @y >= image.y && @y <= (image.y + height)
      return true
    else
      return false
    end
  end
  
  # checks if mouse is left clicking a sprite / continuous (can define custom width and height)
  def pbMouseLeftClick?(image,anim=true,width=-1,height=-1)
    width=image.bitmap.width if width==-1
    height=image.bitmap.height if height==-1
    if @x >= image.x && @x <= (image.x + width) and @y >= image.y && @y <= (image.y + height) && Input.pressed(Input::Mouse_Left)
      getObjectParams(image) if anim
      pbButtonAnim(image) if anim
      return true
    else
      return false
    end
  end
  
  
  # checks the initial left click of the sprite /non-continuous (can define custom width and height)
  def pbMouseLeftTrigger?(image,anim=true,width=-1,height=-1)
    width=image.bitmap.width if width==-1
    height=image.bitmap.height if height==-1
    if @x >= image.x && @x <= (image.x + width) and @y >= image.y && @y <= (image.y + height) && Input.triggerex?(Input::Mouse_Left)
       getObjectParams(image) if anim
      pbButtonAnim(image) if anim
      return true
    else
      return false
    end
  end
  
  # checks if mouse is right clicking a sprite / continuous (can define custom width and height)
  def pbMouseRightClick?(image,anim=true,width=-1,height=-1)
    width=image.bitmap.width if width==-1
    height=image.bitmap.height if height==-1
    if @x >= image.x && @x <= (image.x + width) and @y >= image.y && @y <= (image.y + height) && Input.pressed(Input::Mouse_Right)
       getObjectParams(image) if anim
      pbButtonAnim(image) if anim
      return true
    else
      return false
    end
  end
  
  # checks the initial right click of the sprite /non-continuous (can define custom width and height)
  def pbMouseRightTrigger?(image,anim=true,width=-1,height=-1)
    width=image.bitmap.width if width==-1
    height=image.bitmap.height if height==-1
    if @x >= image.x && @x <= (image.x + width) and @y >= image.y && @y <= (image.y + height) && Input.triggerex?(Input::Mouse_Right)
      getObjectParams(image) if anim
      pbButtonAnim(image) if anim
      return true
    else
      return false
    end
  end
  
  # checks if the mouse is in a certain area of the App window
  def pbMouseInAreaX?(x,width)
    if @x >= x && @x <= (x + width)
      return true
    else
      return false
    end
  end
  
    def pbMouseInAreaY?(y,height)
    if @y >= y && @y <= (y + height)
      return true
    else
      return false
    end
  end
  
    def pbMouseInArea?(x,y,width,height)
    if @x >= x && @x <= (x + width) and @y >= y && @y <= (y + height)
      return true
    else
      return false
    end
  end
  
  def pbMouseOpacity?(sprite)
    if self.pbMouseOver?(sprite)
     sprite.opacity+=15 if sprite.opacity<255
      else
        sprite.opacity-=15 if sprite.opacity>155
     end
  end
  
  # checks if the mouse is left clicking in a certain area of the App window / continuous
  def pbMouseInAreaLeft?(x,y,width,height)
    if @x >= x && @x <= (x + width) and @y >= y && @y <= (y + height) && Input.pressed(Input::Mouse_Left)
      return true
    else
      return false
    end
  end
  
  # checks if the mouse is right clicking in a certain area of the App window / continuous
  def pbMouseInAreaRight?(x,y,width,height)
    if @x >= x && @x <= (x + width) and @y >= y && @y <= (y + height) && Input.pressed(Input::Mouse_Right)
      return true
    else
      return false
    end
  end
  
  # checks the initial left click in a certain area of the App window / non-continuous
  def pbMouseInAreaTrigger?(x,y,width,height)
    if @x >= x && @x <= (x + width) and @y >= y && @y <= (y + height) && Input.triggerex?(Input::Mouse_Left)
      return true
    else
      return false
    end
  end  
        
  # checks if the mouse is idle/ not moving around
  def pbMouseIsStatic?
    if @static_x==@x && @static_y==@y
      ret=true
    else
      ret=false
    end
    if !(@static_x==@x) or !(@static_y==@y)
      @static_x=@x
      @static_y=@y
    end
    return ret
  end
  
  # moves a targeted object with the mouse.x when left clicked (range of movement can be specified in terms of position and dimensions in the App window)
  def pbDrag_X(object,limit_x=nil,limit_width=nil)
    if self.leftClick?(object,false)
      if @object_ox.nil?
        @object_ox = @x - object.x
      end
      object.x = @x - @object_ox
      object.x = limit_x if limit_x && object.x<limit_x
      object.x = limit_width if limit_width && object.x>limit_width
    else
      @object_ox=nil
    end
  end
  
  # moves a targeted object with the mouse.y when left clicked (range of movement can be specified in terms of position and dimensions in the App window)
  def pbDrag_Y(object,limit_y=nil,limit_height=nil)
    if self.leftClick?(object,false)
      if @object_oy.nil?
        @object_oy = @y - object.y
      end
      object.y = @y - @object_oy
      object.y = limit_y if limit_y && object.y<limit_y
      object.y = limit_height if limit_height && object.y>limit_height
    else
      @object_oy=nil
    end
  end
  
  # moves a targeted object with the mouse when left clicked (range of movement can be specified in terms of position and dimensions in the App window)
  def pbDragObjectOld(object,limit_x=nil,limit_y=nil,limit_width=nil,limit_height=nil)
    if self.pbMouseLeftClick?(object,false)
      if @object_ox.nil?
        @object_ox = @x - object.x
      end
      if @object_oy.nil?
        @object_oy = @y - object.y
      end
      object.x = @x - @object_ox
      object.x = limit_x if limit_x && object.x<limit_x
      object.x = limit_width if limit_width && object.x>limit_width
      object.y = @y - @object_oy
      object.y = limit_y if limit_y && object.y<limit_y
      object.y = limit_height if limit_height && object.y>limit_height
    else
      @object_ox=nil
      @object_oy=nil
    end
  end
  
def pbDragObject(image)
  if self.pbMouseLeftClick?(image)
   image.x = @x - (image.bitmap.width/2)
   image.y = @y - (image.bitmap.height/2)
  end
end
  
def pbMouseLeftClickAction?(image,width=-1,height=-1)
    width=image.bitmap.width if width==-1
    height=image.bitmap.height if height==-1
    if @x >= image.x && $mouse.x <= (image.x + width) and @y >= image.y && @y <= (image.y + height) && Input.triggerex?(Input::Mouse_Left)
      return true
    else
      return false
    end
  end
  
 # checks if mouse is over a sprite (can define custom width and height)
  def over?(object=nil,width=-1,height=-1)
    return false if object.nil?
    params=self.getObjectParams(object)
    x=params[0]
    y=params[1]
    width=params[2] if width < 0
    height=params[3] if height < 0
    return true if @x >= x && @x <= (x + width) and @y >= y && @y <= (y + height)
    return false
  end
  
  # special method to check whether the mouse is over sprites with special shapes
  def overPixel?(sprite)
    return false if !sprite.bitmap
    bitmap=sprite.bitmap
    return false if !self.over?(sprite)
    bx=@x-sprite.x
    by=@y-sprite.y
    if defined?(sprite.viewport) && sprite.viewport
      bx-=sprite.viewport.rect.x
      by-=sprite.viewport.rect.y
    end
    bx+=sprite.src_rect.x
    by+=sprite.src_rect.y
    pixel=bitmap.get_pixel(bx,by)
    return true if pixel.alpha>0
    return false
  end
  
  # checks if mouse is left clicking a sprite (can define custom width and height)
  def leftClick?(object=nil,width=-1,height=-1)
    if object.nil?
      return Input.triggerex?(Input::Mouse_Left)
    else
      return (self.over?(object,width,height) && Input.triggerex?(Input::Mouse_Left))
    end
  end
  
  # checks if mouse is right clicking a sprite (can define custom width and height)
  def rightClick?(object=nil,width=-1,height=-1)
    if object.nil?
      return Input.triggerex?(Input::Mouse_Right)
    else
      return (self.over?(object,width,height) && Input.triggerex?(Input::Mouse_Right))
    end
  end
  
  # checks if mouse is left clicking a sprite / continuous (can define custom width and height)
  def leftPress?(object=nil,width=-1,height=-1)
    if object.nil?
      return Input.pressed(Input::Mouse_Left)
    else
      return (self.over?(object,width,height) && Input.pressed(Input::Mouse_Left))
    end
  end
  
  # checks if mouse is right clicking a sprite / continuous (can define custom width and height)
  def rightPress?(object=nil,width=-1,height=-1)
    if object.nil?
      return Input.pressed(Input::Mouse_Left)
    else
      return (self.over?(object,width,height) && Input.pressed(Input::Mouse_Right))
    end
  end
    
  # checks if the mouse is in a certain area of the App window
  def inArea?(x,y,width,height)
    rect=Rect.new(x,y,width,height)
    return self.over?(rect)
  end
    
  # checks if the mouse is clicking in a certain area of the App window
  # click can either be "left" or "right", to specify which mouse button is clicked
  def inAreaClick?(x,y,width,height,click="left")
    case click
    when "left"
      return (self.inArea?(x,y,width,height) && Input.triggerex?(Input::Mouse_Left))
    when "right"
      return (self.inArea?(x,y,width,height) && Input.triggerex?(Input::Mouse_Right))
    else
      return false
    end
  end
  
  # checks if the mouse is pressing in a certain area of the App window
  # click can either be "left" or "right", to specify which mouse button is pressed
  def inAreaPress?(x,y,width,height,click="left")
    case click
    when "left"
      return (self.inArea?(x,y,width,height) && Input.pressed(Input::Mouse_Left))
    when "right"
      return (self.inArea?(x,y,width,height) && Input.pressed(Input::Mouse_Right))
    else
      return false
    end
  end
  
  # retained for compatibility
  def inAreaLeft?(x,y,width,height)
    return inAreaClick?(x,y,width,height,"left")
  end
  
  def inAreaRight?(x,y,width,height)
    return inAreaClick?(x,y,width,height,"right")
  end
          
  # checks if the mouse is idle/ not moving around
  def isStatic?
    ret=false
    ret=true if @static_x==@x && @static_y==@y
    if !(@static_x==@x) or !(@static_y==@y)
      @static_x=@x
      @static_y=@y
    end
    return ret
  end
  
  # moves a targeted object with the mouse.x when left clicked (range of movement can be specified in terms of position and dimensions in the App window)
  def drag_x(object,limit_x=nil,limit_width=nil)\
    return false if !defined?(object.x)
    if self.leftPress?(object)
      if @object_ox.nil?
        @object_ox = @x - object.x
      end
      object.x = @x - @object_ox
      object.x = limit_x if limit_x && object.xlimit_width
    else
      @object_ox=nil
    end
  end
  
  # moves a targeted object with the mouse.y when left clicked (range of movement can be specified in terms of position and dimensions in the App window)
  def drag_y(object,limit_y=nil,limit_height=nil)
    return false if !defined?(object.y)
    if self.leftPress?(object)
      if @object_oy.nil?
        @object_oy = @y - object.y
      end
      object.y = @y - @object_oy
      object.y = limit_y if limit_y && object.ylimit_height
    else
      @object_oy=nil
    end
  end
  
  # moves a targeted object with the mouse when left clicked (range of movement can be specified in terms of position and dimensions in the App window)
  def drag_xy(object,limit_x=nil,limit_y=nil,limit_width=nil,limit_height=nil)
    return false if !defined?(object.x) or !defined?(object.y)
    if self.leftPress?(object)
      if @object_ox.nil?
        @object_ox = @x - object.x
      end
      if @object_oy.nil?
        @object_oy = @y - object.y
      end
      object.x = @x - @object_ox
      object.x = limit_x if limit_x && object.xlimit_width
      object.y = @y - @object_oy
      object.y = limit_y if limit_y && object.ylimit_height
    else
      @object_ox=nil
      @object_oy=nil
    end
  end
    
  def getObjectParams(object)
    params=[0,0,0,0]
    if object.is_a?(Sprite)
      params[0]=(object.x)
      params[1]=(object.y)
      if defined?(object.viewport) && object.viewport
        params[0]+=object.viewport.rect.x
        params[1]+=object.viewport.rect.y
      end
      params[2]=(object.bitmap.width*object.zoom_x) if object.bitmap
      params[3]=(object.bitmap.height*object.zoom_y) if object.bitmap
      if defined?(object.src_rect)
        params[2]=(object.src_rect.width*object.zoom_x) if object.bitmap && object.src_rect.width != object.bitmap.width
        params[3]=(object.src_rect.height*object.zoom_y) if object.bitmap && object.src_rect.height != object.bitmap.height
      end
    elsif object.is_a?(Viewport)
      params=[object.rect.x,object.rect.y,object.rect.width,object.rect.height]
    else
      params[0]=(object.x) if object.x
      params[1]=(object.y) if object.y
      if defined?(object.viewport) && object.viewport
        params[0]+=object.viewport.rect.x
        params[1]+=object.viewport.rect.y
      end
      params[2]=(object.width) if object.width
      params[3]=(object.height) if object.height
    end
    return params
  end

    
  def drag_pc(object,limit_x=nil,limit_y=nil,limit_width=nil,limit_height=nil)
    if self.leftClick?(object,64,64)
      if @object_ox.nil?
        @object_ox = @x - object.x
      end
      if @object_oy.nil?
        @object_oy = @y - object.y
      end
      object.x = @x - @object_ox
      object.x = limit_x if limit_x && object.x<limit_x
      object.x = limit_width if limit_width && object.x>limit_width
      object.y = @y - @object_oy
      object.y = limit_y if limit_y && object.y<limit_y
      object.y = limit_height if limit_height && object.y>limit_height
    else
      @object_ox=nil
      @object_oy=nil
    end
  end
  
def actionButtonTrigger?
 if $scene && $scene.is_a?(Scene_Map) && !pbIsFaded? and !clockDisabled?
 menu=$scene.pbGetMenu
  return false if menu.nil?
  button=menu.getActionButton
  if $mouse.pbMouseLeftTrigger?(button) 
    return true
  else 
    return false
  end
 else 
  return false
 end
end

 def pbButtonAnim(sprite)
    3.times do
      Graphics.update
      $game_map.update
      sprite.tone.red+=26*2
      sprite.tone.blue+=26*2
      sprite.tone.green+=26*2
    end
    3.times do
      Graphics.update
      $game_map.update
      sprite.tone.red-=26*2
      sprite.tone.blue-=26*2
      sprite.tone.green-=26*2
    end
  end
  
  def pbInAreaCustome?(x,y,width,height)
    if @x >= x && @x <= (x + width) and @y >= y && @y <= (y + height) && Input.triggerex?(Input::Mouse_Left)
      return true
    else
      return false
    end
  end  
  
end

#===============================================================================
#  Initializes the Game_Mouse class
#===============================================================================
$mouse = Game_Mouse.new
#===============================================================================
#  Mouse input methods for the Input module
#===============================================================================
module Input
  Mouse_Left = 1
  Mouse_Right = 2
  Mouse_Middle = 4
  
  class << Input
    alias update_org update
  end
  
  def self.update
    $mouse.update if defined?($mouse) && $mouse
    update_org
  end
  
  def self.pressed(key)
    return true unless Win32API.new("user32","GetKeyState",['i'],'i').call(key).between?(0, 1)
    return false
  end
end