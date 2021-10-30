class NumSelectionSprite < SpriteWrapper
  attr_reader :preselected
  attr_reader :index
  attr_reader :row
  attr_reader :column

  def initialize(viewport=nil)
    super(viewport)
    @movesel=AnimatedBitmap.new("Graphics/Pictures/palpadselregisternum")
    @frame=0
    @index=0
    @row=0
    @column=0
    @preselected=false
    @updating=false
    @spriteVisible=true
    refresh
  end

  def dispose
    @movesel.dispose
    super
  end

  def index=(value)
    @index=value
    refresh
  end
  
  def row=(value)
    @row=value
    refresh
  end
  
  def column=(value)
    @column=value
    refresh
  end

  def preselected=(value)
    @preselected=value
    refresh
  end

  def visible=(value)
    super
    @spriteVisible=value if !@updating
  end

  def refresh
    w=@movesel.width
    h=@movesel.height/2
    self.x=24+(self.column*96)
    self.y=119+(self.row*96)
    self.bitmap=@movesel.bitmap
    if self.preselected
      self.src_rect.set(0,h,w,h)
    else
      self.src_rect.set(0,0,w,h)
    end
  end

  def update
    @updating=true
    super
    @movesel.update
    @updating=false
    refresh
  end
end


BASECOLOR=Color.new(255,255,255)
SHADOWCOLOR=Color.new(0,0,0)

class PalPadRegisterScene
  
  def update
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene
    @textPositions=[]
    @sprites={}
    @num=0
    @totalNums=0
    @y=0
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    addBackgroundPlane(@sprites,"bg","palpad3",@viewport)
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["menusel"]=NumSelectionSprite.new(@viewport)
    @sprites["menusel"].visible=true
    pbFadeInAndShow(@sprites) { update }
  end

  def pbPalPad
    loop do
      Graphics.update
      Input.update
      self.update
      if Input.trigger?(Input::B)
        break
      end
      if Input.trigger?(Input::C)
        if @sprites["menusel"].row == 0
          @num=@sprites["menusel"].column
        else
          @num=(@sprites["menusel"].column + 5)
        end
        if @totalNums < 5
          @y = 24+(@totalNums*38)
          @y+=16 if @totalNums > 3
          @y+=19 if @totalNums > 7
          @textPositions.push([_INTL("{1}",@num),@y,36,false,SHADOWCOLOR,BASECOLOR])
          @totalNums+=1
        end
        if @totalNums == 5
          friend_id = _INTL("{1}{2}{3}{4}{5}",@textPositions[0][0],@textPositions[1][0],@textPositions[2][0],@textPositions[3][0],@textPositions[4][0])
          friend_name = pbEnterText("Friends name?",1,7)
          Kernel.pbMessage("Friend registered")
          $FriendsList.push(friend_id,friend_name)
          $game_variables[101] = $FriendsList
          break
        end
        if !@textPositions.empty?
          pbDrawTextPositions(@sprites["overlay"].bitmap,@textPositions)
        end
      end
      if Input.trigger?(Input::UP)
        @sprites["menusel"].row-=1 if @sprites["menusel"].row == 1
      end
      if Input.trigger?(Input::DOWN)
        @sprites["menusel"].row+=1 if @sprites["menusel"].row == 0
      end
      if Input.trigger?(Input::RIGHT)
        @sprites["menusel"].column+=1 if @sprites["menusel"].column < 4
      end
      if Input.trigger?(Input::LEFT)
        @sprites["menusel"].column-=1 if @sprites["menusel"].column > 0
      end
    end 
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end



class PalPadRegister
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbPalPad
    @scene.pbEndScene
  end
end