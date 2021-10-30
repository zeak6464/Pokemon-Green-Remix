class Friends
  FRIENDS = Array.new
  $FriendsList = FRIENDS
end

class MenuSelectionSprite < SpriteWrapper
  attr_reader :preselected
  attr_reader :index

  def initialize(viewport=nil)
    super(viewport)
    @movesel=AnimatedBitmap.new("Graphics/Pictures/palpadsel")
    @frame=0
    @index=0
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
    self.x=38
    self.y=66+(self.index*80)
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

class PalPadScene
  def update
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene
    @index=0
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    addBackgroundPlane(@sprites,"bg","palpad1",@viewport)
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    pbDrawText
    @sprites["menusel"]=MenuSelectionSprite.new(@viewport)
    @sprites["menusel"].visible=true
    pbFadeInAndShow(@sprites) { update }
  end

  def pbDrawText
    overlay=@sprites["overlay"].bitmap
    overlay.clear
    
    textPositions=[
       [_INTL("PAL PAD"),34,10,0,BASECOLOR,SHADOWCOLOR],
       [_INTL("CHECK FRIEND ROSTER"),155,79,0,BASECOLOR,SHADOWCOLOR],
       [_INTL("REGISTER FRIEND CODE"),150,160,0,BASECOLOR,SHADOWCOLOR],
       [_INTL("{1}'s FRIEND CODE",$Trainer.name),150,238,0,BASECOLOR,SHADOWCOLOR],
       [_INTL("EXIT"),225,320,0,BASECOLOR,SHADOWCOLOR],
    ]
    
    pbSetSystemFont(@sprites["overlay"].bitmap)
    if !textPositions.empty?
      pbDrawTextPositions(@sprites["overlay"].bitmap,textPositions)
    end
    
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
        case @sprites["menusel"].index
        when 0
          # Check Friends
          oldsprites=pbFadeOutAndHide(@sprites)
          scene=PalPadFriendScene.new
          screen=PalPadFriend.new(scene)
          screen.pbStartScreen
          pbFadeInAndShow(@sprites,oldsprites)
        when 1
          # Register Friend
          oldsprites=pbFadeOutAndHide(@sprites)
          scene=PalPadRegisterScene.new
          screen=PalPadRegister.new(scene)
          screen.pbStartScreen
          pbFadeInAndShow(@sprites,oldsprites)
        when 2
          # Check Own Friend Code
          oldsprites=pbFadeOutAndHide(@sprites)
          scene=PalPadOwnScene.new
          screen=PalPadOwn.new(scene)
          screen.pbStartScreen
          pbFadeInAndShow(@sprites,oldsprites)
        when 3
          # Exit
          break
        end  
      end
      if Input.trigger?(Input::DOWN)
        @sprites["menusel"].index+=1
        if @sprites["menusel"].index > 3
          @sprites["menusel"].index = 0
        end
      end
      if Input.trigger?(Input::UP)
        @sprites["menusel"].index-=1
        if @sprites["menusel"].index < 0
            @sprites["menusel"].index = 3
        end
      end
    end 
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end



class PalPad
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbPalPad
    @scene.pbEndScene
  end
end