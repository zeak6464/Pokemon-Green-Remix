class FriendSelectionSprite < SpriteWrapper
  attr_reader :preselected
  attr_reader :index
  attr_reader :row
  attr_reader :column

  def initialize(viewport=nil)
    super(viewport)
    @movesel=AnimatedBitmap.new("Graphics/Pictures/palpadsellist")
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
    self.x=34+(self.column*224)
    self.y=64+(self.row*65)
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

class PalPadFriendScene
  def update
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene
    @index=0
    @page=0
    @p=0
    @sprites={}
    @textPositions=[]
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    addBackgroundPlane(@sprites,"bg","palpad4",@viewport)
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    pbDrawText
    @sprites["menusel"]=FriendSelectionSprite.new(@viewport)
    @sprites["menusel"].visible=true
    pbFadeInAndShow(@sprites) { update }
  end

  def pbDrawText
    overlay=@sprites["overlay"].bitmap
    overlay.clear
    
    @textPositions=[
       [_INTL("FRIEND ROSTER"),34,10,0,BASECOLOR,SHADOWCOLOR],
       [_INTL("PAGE {1}", @page),285,10,0,BASECOLOR,SHADOWCOLOR],
    ]
    x=[65,285]
    y=[65,130,195,260]
    
    if $Trainer.id != 0
       data1 = $game_variables[101]
        @textPositions.push([_INTL("{1}",data1[0+@page*16]),x[0],y[0]+25,false,SHADOWCOLOR,BASECOLOR]) if @page == @p
        @textPositions.push([_INTL("{1}",data1[1+@page*16]),x[0],y[0],false,SHADOWCOLOR,BASECOLOR]) if @page == @p
        @textPositions.push([_INTL("{1}",data1[2+@page*16]),x[1],y[0]+25,false,SHADOWCOLOR,BASECOLOR]) if @page == @p
        @textPositions.push([_INTL("{1}",data1[3+@page*16]),x[1],y[0],false,SHADOWCOLOR,BASECOLOR]) if @page == @p
        @textPositions.push([_INTL("{1}",data1[4+@page*16]),x[0],y[1]+25,false,SHADOWCOLOR,BASECOLOR]) if @page == @p
        @textPositions.push([_INTL("{1}",data1[5+@page*16]),x[0],y[1],false,SHADOWCOLOR,BASECOLOR]) if @page == @p
        @textPositions.push([_INTL("{1}",data1[6+@page*16]),x[1],y[1]+25,false,SHADOWCOLOR,BASECOLOR]) if @page == @p
        @textPositions.push([_INTL("{1}",data1[7+@page*16]),x[1],y[1],false,SHADOWCOLOR,BASECOLOR]) if @page == @p
        @textPositions.push([_INTL("{1}",data1[8+@page*16]),x[0],y[2]+25,false,SHADOWCOLOR,BASECOLOR]) if @page == @p
        @textPositions.push([_INTL("{1}",data1[9+@page*16]),x[0],y[2],false,SHADOWCOLOR,BASECOLOR]) if @page == @p
        @textPositions.push([_INTL("{1}",data1[10+@page*16]),x[1],y[2]+25,false,SHADOWCOLOR,BASECOLOR]) if @page == @p
        @textPositions.push([_INTL("{1}",data1[11+@page*16]),x[1],y[2],false,SHADOWCOLOR,BASECOLOR]) if @page == @p
        @textPositions.push([_INTL("{1}",data1[12+@page*16]),x[0],y[3]+25,false,SHADOWCOLOR,BASECOLOR]) if @page == @p
        @textPositions.push([_INTL("{1}",data1[13+@page*16]),x[0],y[3],false,SHADOWCOLOR,BASECOLOR]) if @page == @p
        @textPositions.push([_INTL("{1}",data1[14+@page*16]),x[1],y[3]+25,false,SHADOWCOLOR,BASECOLOR]) if @page == @p
        @textPositions.push([_INTL("{1}",data1[15+@page*16]),x[1],y[3],false,SHADOWCOLOR,BASECOLOR]) if @page == @p
    end
    
    pbSetSystemFont(@sprites["overlay"].bitmap)
    if !@textPositions.empty?
      pbDrawTextPositions(@sprites["overlay"].bitmap,@textPositions)
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
          choices=[
           _INTL("Delete"),
           _INTL("CableClub"),
           _INTL("Cancel")
           ]
        choice=Kernel.pbMessage("What do you want to do?",choices,1)
        if choice == 0
          $FriendsList.delete_at(choice)
          $FriendsList.delete_at(choice)
          $game_variables[101] = $FriendsList
          Kernel.pbMessage("Friend removed")
          pbDrawText
        end
        if choice == 1 
          pbCableClub
        end
      end
      if Input.trigger?(Input::UP)
        @sprites["menusel"].row-=1 if @sprites["menusel"].row>0
      end
      if Input.trigger?(Input::DOWN)
        @sprites["menusel"].row+=1 if @sprites["menusel"].row <3
      end
      if Input.trigger?(Input::RIGHT) 
        @sprites["menusel"].column+=1 if @sprites["menusel"].column<2
        @p+=1 if @sprites["menusel"].column==2 && @page<8
        @page+=1 if @sprites["menusel"].column==2 && @page<8
        @sprites["menusel"].column=0 if @sprites["menusel"].column==2
        pbDrawText
      end
      if Input.trigger?(Input::LEFT) 
        @sprites["menusel"].column-=1 if @sprites["menusel"].column>-1
        @p-=1 if @sprites["menusel"].column==-1 && @page>0
        @page-=1 if @sprites["menusel"].column==-1 && @page>0
        @sprites["menusel"].column=1 if @sprites["menusel"].column==-1
        pbDrawText
      end
    end 
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end



class PalPadFriend
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbPalPad
    @scene.pbEndScene
  end
end