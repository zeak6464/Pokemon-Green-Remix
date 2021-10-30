class ReturnSelectionSprite < SpriteWrapper
  attr_reader :preselected
  attr_reader :index

  def initialize(viewport=nil)
    super(viewport)
    @movesel=AnimatedBitmap.new("Graphics/Pictures/palpadselown")
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
    self.x=272
    self.y=320
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

class PalPadOwnScene
  def update
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene
    @index=0
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    addBackgroundPlane(@sprites,"bg","palpad2",@viewport)
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    pbDrawText
    @sprites["menusel"]=ReturnSelectionSprite.new(@viewport)
    @sprites["menusel"].visible=true
    pbFadeInAndShow(@sprites) { update }
  end

  def pbDrawText
    overlay=@sprites["overlay"].bitmap
    overlay.clear
        
    textPositions=[
       [_INTL("{1}'s PAL PAD", $Trainer.name),34,10,0,BASECOLOR,SHADOWCOLOR],
       [_INTL("{1}", $Trainer.publicID($Trainer.id)),170,92,0,SHADOWCOLOR,BASECOLOR],
       [_INTL("RETURN"),350,335,0,BASECOLOR,SHADOWCOLOR],
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
        break
      end
    end 
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end



class PalPadOwn
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbPalPad
    @scene.pbEndScene
  end
end