#===============================================================================
#  New animated Title Screens for Pokemon Essentials
#    by Luka S.J.
#
#  Adds new visual styles to the Pokemon Essentials title screen, and animates
#  depending on the style selected
#
#  A lot of time and effort went into making this an extensive and comprehensive
#  resource. So please be kind enough to give credit when using it.
#
#  Enjoy the script, and make sure to give credit!
#  (DO NOT ALTER THE NAMES OF THE INDIVIDUAL SCRIPT SECTIONS OR YOU WILL BREAK
#   YOUR SYSTEM!)
#===============================================================================                           
VIEWPORT_HEIGHT = 512

class Scene_Intro
  
  
  alias main_old main
  def main
    $DEBUG = $memDebug
    # fix for Mej's Challenge Modes script
    if $game_switches && defined?(TEMP_DISABLE_RANDOMIZERS_SWITCH)
      @switch_bak = $game_switches[TEMP_DISABLE_RANDOMIZERS_SWITCH]
      $game_switches[TEMP_DISABLE_RANDOMIZERS_SWITCH] = true
    end
    Graphics.transition(0)
    # Loads up a species cry for the title screen
    $Trainer = PokeBattle_Trainer.new("",0)
    # Cycles through the intro pictures
    @skip = false
    self.cyclePics(@pics)
    case PLAY_INTRO_SCENE
    when 3
      ClassicIntro.new
    end
    # Selects title screen style
    case SCREENSTYLE
    when 1
      @screen = GenOneStyle.new
    when 2
      @screen = GenTwoStyle.new
    when 3
      @screen = GenThreeStyle.new
    when 4
      @screen = GenFourStyle.new
    when 5
      @screen = GenFiveStyle.new
    when 6
      @screen = GenSixStyle.new
    when 7
      @screen = GenSevenStyle.new
    when 0
      @screen = GenCustomStyle.new
    else
      @screen = EssentialsTitleScreen.new # For compatibility sake if SCREENSTYLE is wrong value
    end
    # Plays the title screen intro (is skippable)
    @screen.intro
    # Creates/updates the main title screen loop
    self.update
    # fix for Mej's Challenge Modes script
    if $game_switches && defined?(TEMP_DISABLE_RANDOMIZERS_SWITCH)
      $game_switches[TEMP_DISABLE_RANDOMIZERS_SWITCH] = @switch_bak
    end
    Graphics.freeze
  end
  
  def update
    ret=0
    loop do
      @screen.update
      Graphics.update
      Input.update
      if Input.press?(Input::DOWN) &&
        Input.press?(Input::B) &&
        Input.press?(Input::CTRL)
        ret=1
        break
      end
      if Input.trigger?(Input::C) || (defined?($mouse) && $mouse.leftClick?)
        ret=2
        break
      end
    end
    case ret
    when 1
      closeTitleDelete
    when 2
      closeTitle 
    end
  end
  
  def closeTitle
    # Play Pokemon cry
    pbSEPlay(@cry,100,100) if @cry && SCREENSTYLE!=6
    # Fade out
    pbBGMStop(1.0)
    # disposes current title screen
    disposeTitle
    # initializes load screen
    sscene=PokemonLoad_Scene.new
    sscreen=PokemonLoadScreen.new(sscene)
    sscreen.pbStartLoadScreen
  end
  
  def closeTitleDelete
    pbBGMStop(1.0)
    # disposes current title screen
    disposeTitle
    # initializes delete screen
    sscene=PokemonLoad_Scene.new
    sscreen=PokemonLoad.new(sscene)
    sscreen.pbStartDeleteScreen
  end
  
  def cyclePics(pics)
    sprite=Sprite.new
    sprite.opacity=0
    for i in 0...pics.length
      bitmap=pbBitmap("Graphics/Titles/#{pics[i]}")
      sprite.bitmap=bitmap
      15.times do
        sprite.opacity+=17
        pbWait(1)
      end
      wait(32)
      15.times do
        sprite.opacity-=17
        pbWait(1)
      end
    end
    sprite.dispose
  end
  
  def disposeTitle
    @screen.dispose
  end
  
  def wait(frames,advance=true)
    return false if @skip
    frames.times do
      Graphics.update
      Input.update
      @skip=true if Input.trigger?(Input::C)
    end
    return true
  end
end
#===============================================================================
# Styled to look like the FRLG games
#===============================================================================
class GenOneStyle  
  def initialize
    # sound file for playing the title screen BGM
    bgm = GEN_ONE_BGM
    str = "Audio/BGM/"+pbResolveAudioFile(bgm).name
    @mp3 = (File.extname(str)==".ogg") ? true : false
    @skip = false
    # speed of the effect movement
    @speed = 16
    @opacity = 17
    @disposed = false
    
    @currentFrame = 0
    # calculates after how many frames the game will reset
    @totalFrames=getPlayTime(str).to_i*Graphics.frame_rate
    pbBGMPlay(bgm)
    pbWait(10) if @mp3
    
    # creates all the necessary graphics
    @viewport = Viewport.new(0,0,Graphics.width,VIEWPORT_HEIGHT)
    @viewport.z = 99999
    @sprites = {}
    
    @sprites["bars"] = Sprite.new(@viewport)
    @sprites["bars"].bitmap = pbBitmap("Graphics/Titles/gen_1_bars")
    @sprites["bars"].x = @viewport.rect.width
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg"].bitmap = pbBitmap("Graphics/Titles/gen_1_bg")
    @sprites["bg"].x = -@viewport.rect.width
    @sprites["start"] = Sprite.new(@viewport)
    @sprites["start"].bitmap = pbBitmap("Graphics/Titles/pokestart")
    @sprites["start"].x = 138
    @sprites["start"].y = 314
    @sprites["start"].opacity = 0
    @sprites["effect"] = AnimatedPlane.new(@viewport)
    @sprites["effect"].bitmap = pbBitmap("Graphics/Titles/gen_1_effect")
    @sprites["effect"].visible = false
    @sprites["poke"] = Sprite.new(@viewport)
    @sprites["poke"].bitmap = pbBitmap("Graphics/Titles/gen_1_poke")
    @sprites["poke"].tone = Tone.new(0,0,0,255)
    @sprites["poke"].opacity = 0
    @sprites["poke2"] = Sprite.new(@viewport)
    @sprites["poke2"].bitmap = pbBitmap("Graphics/Titles/gen_1_poke")
    @sprites["poke2"].tone = Tone.new(255,255,255,255)
    @sprites["poke2"].src_rect.set(0,@viewport.rect.height,@viewport.rect.width,48)
    @sprites["poke2"].y = @viewport.rect.height
    @sprites["logo"] = Sprite.new(@viewport)
    bitmap1=pbBitmap("Graphics/Titles/pokelogo")
    bitmap2=pbBitmap("Graphics/Titles/pokelogo2")
    @sprites["logo"].bitmap = Bitmap.new(bitmap1.width,bitmap1.height)
    @sprites["logo"].bitmap.blt(0,0,bitmap2,Rect.new(0,0,bitmap2.width,bitmap2.height))
    @sprites["logo"].bitmap.blt(0,0,bitmap1,Rect.new(0,0,bitmap1.width,bitmap1.height))
    @sprites["logo"].tone = Tone.new(255,255,255,255)
    @sprites["logo"].x = 8
    @sprites["logo"].y = 24
    @sprites["logo"].opacity = 0
    
  end
  
  def intro
    wait(16)
    16.times do
      @sprites["poke2"].src_rect.y-=24
      @sprites["poke2"].y-=24
      wait(1)
    end
    @sprites["poke2"].opacity=0
    @sprites["poke2"].src_rect.set(0,0,@viewport.rect.width,@viewport.rect.height)
    @sprites["poke2"].y=0
    wait(32)
    64.times do
      @sprites["poke"].opacity+=4
      wait(1)
    end
    @sprites["poke2"].opacity=255
    8.times do
      @sprites["poke2"].opacity-=51
      @sprites["bg"].x+=64
      wait(1)
    end
    wait(8)
    @sprites["poke2"].opacity=255
    8.times do
      @sprites["poke2"].opacity-=51
      @sprites["bars"].x-=64
      wait(1)
    end
    wait(8)
    @sprites["logo"].opacity=255
    @sprites["poke2"].opacity=255
    @sprites["poke"].tone=Tone.new(0,0,0,0)
    @sprites["effect"].visible=true
    c=255.0
    16.times do
      @sprites["poke2"].opacity-=255.0/16
      c-=255.0/16
      @sprites["logo"].tone=Tone.new(c,c,c)
      @sprites["effect"].ox+=@speed
      wait(1)
    end
    @skip = false
  end
  
  def update
    @currentFrame+=1 if !@skip
    @sprites["effect"].ox+=@speed
    @sprites["start"].opacity+=@opacity
    @opacity=-17 if @sprites["start"].opacity>=255
    @opacity=+17 if @sprites["start"].opacity<=0
    
    if @currentFrame==@totalFrames
      self.restart if RESTART_TITLE
    end
  end
  
  def restart
    pbBGMStop(0)
    51.times do
      @viewport.tone.red-=5
      @viewport.tone.green-=5
      @viewport.tone.blue-=5
      self.update
      wait(1)
    end
    raise Reset.new
  end
  
  def dispose
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    @disposed=true
  end
  
  def disposed?
    return @disposed
  end
  
  def wait(frames,advance=true)
    return false if @skip
    frames.times do
      @currentFrame+=1 if advance
      Graphics.update
      Input.update
      @skip=true if Input.trigger?(Input::C)
    end
    return true
  end
  
end
#===============================================================================
# Styled to look like the HGSS games
#===============================================================================
class GenTwoStyle
  def initialize
    # sound file for playing the title screen BGM
    bgm = GEN_TWO_BGM
    str = "Audio/BGM/"+pbResolveAudioFile(bgm).name
    @mp3 = (File.extname(str)==".ogg") ? true : false
    @skip = false
    # speed of the effect movement
    @speed = 2
    @frame = 0
    @opacity = 17
    @particles = 16
    @effo = 1
    @disposed = false
    
    @currentFrame = 0
    # calculates after how many frames the game will reset
    @totalFrames=getPlayTime(str).to_i*Graphics.frame_rate - 40
    pbBGMPlay(bgm)
    pbWait(10) if @mp3
    
    # creates all the necessary graphics
    @viewport = Viewport.new(0,0,Graphics.width,VIEWPORT_HEIGHT)
    @viewport.z = 99999
    @viewport.tone = Tone.new(-255,-255,-255)
    @viewport2 = Viewport.new(0,0,Graphics.width,VIEWPORT_HEIGHT)
    @viewport2.z = 99998
    @sprites = {}
    
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg2"] = Sprite.new(@viewport2)
    @sprites["bg2"].bitmap = pbBitmap("Graphics/Titles/gen_2_bg")
    
    @sprites["effect2"] = AnimatedPlane.new(@viewport2)
    @sprites["effect2"].bitmap = pbBitmap("Graphics/Titles/gen_2_effect2")
    
    @sprites["effect"] = Sprite.new(@viewport)
    @sprites["effect"].bitmap = pbBitmap("Graphics/Titles/gen_2_effect")
    @sprites["effect"].ox = @sprites["effect"].bitmap.width/2
    @sprites["effect"].oy = @sprites["effect"].bitmap.height/2
    @sprites["effect"].x = @viewport.rect.width*0.75
    @sprites["effect"].y = @viewport.rect.height/2
    @sprites["effect3"] = Sprite.new(@viewport)
    @sprites["effect3"].bitmap = pbBitmap("Graphics/Titles/gen_2_effect3")
    @sprites["effect3"].ox = @sprites["effect3"].bitmap.width/2
    @sprites["effect3"].oy = @sprites["effect3"].bitmap.height/2
    @sprites["effect3"].x = @sprites["effect"].x
    @sprites["effect3"].y = @sprites["effect"].y
    @sprites["effect3"].opacity = 0
    
    view = @viewport
    @sprites["particle"] = Sprite.new(view)
    @sprites["particle"].bitmap = pbBitmap("Graphics/Titles/gen_2_particle")
    @sprites["particle"].src_rect.set(0,0,@sprites["particle"].bitmap.width/2,@sprites["particle"].bitmap.height)
    @sprites["particle"].oy = @sprites["particle"].bitmap.height/2
    @sprites["particle"].x = view.rect.width/2
    @sprites["particle"].y = view.rect.height/2 + 20
    @sprites["particle"].y+=64
    @sprites["particle"].visible = false
    
    @sprites["pokemon"] = Sprite.new(view)
    @sprites["pokemon"].bitmap = pbBitmap("Graphics/Titles/gen_2_pokemon")
    @sprites["pokemon"].src_rect.set(0,0,@sprites["pokemon"].bitmap.height,@sprites["pokemon"].bitmap.height)
    @sprites["pokemon"].ox = @sprites["pokemon"].src_rect.width/2
    @sprites["pokemon"].oy = @sprites["pokemon"].src_rect.height/2
    @sprites["pokemon"].x = view.rect.width/2
    @sprites["pokemon"].y = view.rect.height/2
    @sprites["pokemon"].y+=64
    @sprites["pokemon"].visible = false
    
    @sprites["start"] = Sprite.new(@viewport)
    @sprites["start"].bitmap = pbBitmap("Graphics/Titles/pokestart")
    @sprites["start"].ox = @sprites["start"].bitmap.width/2
    @sprites["start"].x = @viewport2.rect.width/2
    @sprites["start"].y = @viewport2.rect.height-32
    @sprites["start"].z = 10
    @sprites["start"].opacity = 0
    @sprites["start"].visible = false
    
    @sprites["logo"] = Sprite.new(@viewport)
    bitmap1=pbBitmap("Graphics/Titles/pokelogo")
    bitmap2=pbBitmap("Graphics/Titles/pokelogo2")
    @sprites["logo"].bitmap = Bitmap.new(bitmap1.width,bitmap1.height)
    @sprites["logo"].bitmap.blt(0,0,bitmap2,Rect.new(0,0,bitmap2.width,bitmap2.height))
    @sprites["logo"].bitmap.blt(0,0,bitmap1,Rect.new(0,0,bitmap1.width,bitmap1.height))
    @sprites["logo"].ox = @sprites["logo"].bitmap.width/4
    @sprites["logo"].oy = @sprites["logo"].bitmap.height/4
    @sprites["logo"].x = @viewport.rect.width/4
    @sprites["logo"].y = @viewport.rect.height/4
    @sprites["logo"].z = 10
    @sprites["logo"].opacity = 0
        
  end
  
  def intro
    @logolock = true
    10.times do
      @viewport.tone.red+=25.5
      @viewport.tone.green+=25.5
      @viewport.tone.blue+=25.5
      self.update
      wait(1,false)
    end
    22.times do
      self.update
      wait(1,false)
    end
    @sprites["logo"].y+=64
    64.times do
      @sprites["logo"].y-=1
      @sprites["logo"].opacity+=4
      @sprites["logo"].tone.red+=2
      @sprites["logo"].tone.green+=2
      @sprites["logo"].tone.blue+=2
      self.update
      wait(1,false)
    end
    16.times do
      @sprites["logo"].tone.red+=8
      @sprites["logo"].tone.green+=8
      @sprites["logo"].tone.blue+=8
      self.update
      wait(1,false)
    end
    @sprites["start"].opacity = 0
    @sprites["start"].visible = true
    @opacity = 17
    @viewport.tone = Tone.new(255,255,255)
    @logolock = false
    for i in 0...@particles
      @sprites["p#{i}"] = AnimatedSpriteParticle.new(@viewport)
      @sprites["p#{i}"].dx = @sprites["effect"].x
      @sprites["p#{i}"].dy = @sprites["effect"].y
      @sprites["p#{i}"].inverted = false
      @sprites["p#{i}"].repeat = 1
      @sprites["p#{i}"].count = 0
      @sprites["p#{i}"].refresh
    end
    @sprites["pokemon"].visible = true
    @sprites["particle"].visible = true
    17.times do
      @viewport.tone.red-=15 if @viewport.tone.red > 0
      @viewport.tone.green-=15 if @viewport.tone.green > 0
      @viewport.tone.blue-=15 if @viewport.tone.blue > 0
      self.update
      wait(1,false)
    end
  end
  
  def update
    @currentFrame+=1 if !@skip
    @frame+=1
    if !@logolock
      @sprites["logo"].tone.red-=15 if @sprites["logo"].tone.red > 0
      @sprites["logo"].tone.green-=15 if @sprites["logo"].tone.green > 0
      @sprites["logo"].tone.blue-=15 if @sprites["logo"].tone.blue > 0
    end
    @sprites["pokemon"].src_rect.x+=@sprites["pokemon"].src_rect.width if @frame > @speed
    @sprites["pokemon"].src_rect.x=0 if @sprites["pokemon"].src_rect.x >= @sprites["pokemon"].bitmap.width
    @sprites["particle"].src_rect.x-=16
    @sprites["particle"].src_rect.x=@sprites["particle"].bitmap.width/2 if @sprites["particle"].src_rect.x <= 0
    @frame = 0 if @frame > @speed
    @sprites["start"].opacity+=@opacity
    @sprites["effect"].angle+=0.4 if $ResizeFactor <= 1
    @sprites["effect2"].ox-=1
    @sprites["effect3"].angle+=0.2 if $ResizeFactor <= 1
    @sprites["effect3"].opacity-=@effo
    if @sprites["effect3"].opacity <= 0
      @effo = -1
    elsif @sprites["effect3"].opacity >= 255
      @effo = 1
    end
    @opacity=-17 if @sprites["start"].opacity>=255
    @opacity=+17 if @sprites["start"].opacity<=0
    for i in 0...@particles
      @sprites["p#{i}"].update if @sprites["p#{i}"]
    end
    if @currentFrame==@totalFrames
      self.restart if RESTART_TITLE
    end
  end
  
  def restart
    pbBGMStop(0)
    51.times do
      @viewport.tone.red-=5
      @viewport.tone.green-=5
      @viewport.tone.blue-=5
      @viewport2.tone.red-=5
      @viewport2.tone.green-=5
      @viewport2.tone.blue-=5
      self.update
      wait(1)
    end
    raise Reset.new
  end
  
  def dispose
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    @disposed=true
  end
  
  def disposed?
    return @disposed
  end
  
  def wait(frames,advance=true)
    return false if @skip
    frames.times do
      @currentFrame+=1 if advance
      Graphics.update
      Input.update
      @skip=true if Input.trigger?(Input::C)
    end
    return true
  end
  
end
#===============================================================================
# Styled to look like the RSE games
#===============================================================================
class GenThreeStyle
 
  def initialize
    # sound file for playing the title screen BGM
    bgm = GEN_THREE_BGM
    str = "Audio/BGM/"+pbResolveAudioFile(bgm).name
    @mp3 = (File.extname(str)==".ogg") ? true : false
    @skip = false
    # speed of the effect movement
    @speed = 1
    @opacity = 2
    @frame = 0
    @disposed = false
    # decides whether to use the OR/AS or R/S/E transitioning
    @new = NEW_GENERATION
    
    @currentFrame = 0
    # calculates after how many frames the game will reset
    @totalFrames=getPlayTime(str).to_i*Graphics.frame_rate
    pbBGMPlay(bgm)
    
    # creates all the necessary graphics
    @viewport = Viewport.new(0,0,Graphics.width,VIEWPORT_HEIGHT)
    @viewport.z = 99999
    @viewport2 = Viewport.new(0,0,Graphics.width,VIEWPORT_HEIGHT)
    @viewport2.z = 99998
    @sprites = {}
    
    @sprites["bg"] = Sprite.new(@viewport2)
    @sprites["bg"].bitmap = pbBitmap("Graphics/Titles/gen_3_bg")
    @sprites["bg"].tone = Tone.new(255,255,255)
    @sprites["bg"].opacity = 0
    @sprites["bg2"] = Sprite.new(@viewport)
    @sprites["bg2"].bitmap = pbBitmap("Graphics/Titles/gen_3_bg_ds1") if @new
    @sprites["bg2"].opacity = 0
    @sprites["poke1"] = Sprite.new(@viewport2)
    @sprites["poke1"].bitmap=pbBitmap("Graphics/Titles/gen_3_poke1")
    @sprites["poke1"].opacity = 0
    @sprites["poke2"] = Sprite.new(@viewport2)
    @sprites["poke2"].bitmap=pbBitmap("Graphics/Titles/gen_3_poke2")
    @sprites["poke2"].opacity=0
    @sprites["effect"] = AnimatedPlane.new(@viewport2)
    @sprites["effect"].bitmap = pbBitmap("Graphics/Titles/gen_3_effect")
    @sprites["effect"].visible = false
    @sprites["logo2"] = Sprite.new(@viewport)
    @sprites["logo2"].bitmap = pbBitmap("Graphics/Titles/pokelogo2")
    @sprites["logo2"].x = 50
    @sprites["logo2"].y = 24-32
    @sprites["logo2"].opacity = 0
    @sprites["logo1"] = Sprite.new(@viewport)
    @sprites["logo1"].bitmap = pbBitmap("Graphics/Titles/pokelogo")
    @sprites["logo1"].x = 50
    @sprites["logo1"].y = 24+64
    @sprites["logo1"].opacity=0
    @sprites["logo3"] = Sprite.new(@viewport)
    @sprites["logo3"].bitmap = pbBitmap("Graphics/Titles/pokelogo")
    @sprites["logo3"].tone = Tone.new(255,255,255)
    @sprites["logo3"].x = 18
    @sprites["logo3"].y = 24+64
    @sprites["logo3"].src_rect.set(-34,0,34,230)
    @sprites["start"] = Sprite.new(@viewport)
    @sprites["start"].bitmap = pbBitmap("Graphics/Titles/pokestart")
    @sprites["start"].x = 178
    @sprites["start"].y = 712
    @sprites["start"].visible = false
  end
  
  def intro
    if @new
      @sprites["logo1"].src_rect.width = 0
      @sprites["logo1"].opacity = 255
    end
    16.times do
      if @new
        @sprites["logo1"].src_rect.width+=(@sprites["logo1"].bitmap.width/16.0).ceil
      else
        @sprites["logo1"].opacity+=16
      end
      wait(1)
    end
    wait(16)
    12.times do
      if !@new
        @sprites["logo3"].x+=34
        @sprites["logo3"].src_rect.x+=34
      end
      wait(1)
    end
    @sprites["logo3"].x=18
    @sprites["logo3"].src_rect.x=-34
    wait(32)
    2.times do
      12.times do
        @sprites["logo3"].x+=34
        @sprites["logo3"].src_rect.x+=34
        @sprites["bg"].opacity+=21.5 if !@new
        @sprites["bg2"].opacity+=1 if @new
        wait(1)
      end
      @sprites["logo3"].x=18
      @sprites["logo3"].src_rect.x=-34
      4.times do
        @sprites["bg2"].opacity+=1 if @new
        wait(1)
      end
      16.times do
        @sprites["bg"].opacity-=16 if !@new
        @sprites["bg2"].opacity+=1 if @new
        wait(1)
      end
      32.times do
        @sprites["bg2"].opacity+=1 if @new
        wait(1)
      end
    end
    @sprites["logo3"].visible=false
    if @new
      @sprites["logo2"].ox = @sprites["logo2"].bitmap.width/2
      @sprites["logo2"].oy = @sprites["logo2"].bitmap.height/2
      @sprites["logo2"].x = @viewport.rect.width/2
      @sprites["logo2"].y+=96+@sprites["logo2"].bitmap.height/2
      @sprites["logo2"].zoom_x = 1.4
      @sprites["logo2"].zoom_y = 1.4
      @sprites["logo2"].opacity = 0
      @sprites["logo2"].tone = Tone.new(255,255,255)
    end
    16.times do
      if @new
        @sprites["logo1"].tone.red+=3
        @sprites["logo1"].tone.green+=3
        @sprites["logo1"].tone.blue+=3
      else
        @sprites["logo1"].y-=2
      end
      @sprites["bg2"].opacity+=1 if @new
      wait(1)
    end
    16.times do
      if @new
        @sprites["logo1"].tone.red+=3
        @sprites["logo1"].tone.green+=3
        @sprites["logo1"].tone.blue+=3
      else
        @sprites["logo1"].y-=2
        @sprites["logo2"].y+=2
        @sprites["logo2"].opacity+=16
      end
      @sprites["bg2"].opacity+=1 if @new
      wait(1)
    end
    43.times do
      if @new
        @sprites["logo1"].tone.red+=3
        @sprites["logo1"].tone.green+=3
        @sprites["logo1"].tone.blue+=3
        @sprites["bg2"].tone.red+=3
        @sprites["bg2"].tone.green+=3
        @sprites["bg2"].tone.blue+=3
      end
      @sprites["bg2"].opacity+=1 if @new
      wait(1)
    end
    8.times do
      if @new
        @sprites["logo1"].tone.red+=3
        @sprites["logo1"].tone.green+=3
        @sprites["logo1"].tone.blue+=3
        @sprites["logo2"].opacity+=36
        @sprites["logo2"].zoom_x-=0.05
        @sprites["logo2"].zoom_y-=0.05
        @sprites["bg2"].tone.red+=3
        @sprites["bg2"].tone.green+=3
        @sprites["bg2"].tone.blue+=3
      end
      wait(1)
    end
    if @new
      @viewport.tone = Tone.new(255,255,255)
      @viewport2.tone = Tone.new(255,255,255)
      @sprites["logo1"].y-=64
      @sprites["logo2"].y-=64
      @sprites["bg2"].visible = false
    end
    wait(5)
    @sprites["logo1"].tone = Tone.new(0,0,0)
    @sprites["logo2"].tone = Tone.new(0,0,0)
    @sprites["bg"].tone=Tone.new(0,0,0)
    @sprites["bg"].opacity=255
    @sprites["bg2"].tone = Tone.new(0,0,0)
    @sprites["bg2"].opacity = 255
    @sprites["poke1"].opacity=255
    @sprites["effect"].visible=true
    @skip = false
  end
  
  def update
    @currentFrame+=1 if !@skip
    @frame+=1
    @viewport.tone.red-=15 if @viewport.tone.red > 0
    @viewport.tone.green-=15 if @viewport.tone.green > 0
    @viewport.tone.blue-=15 if @viewport.tone.blue > 0
    @viewport2.tone.red-=15 if @viewport.tone.red > 0
    @viewport2.tone.green-=15 if @viewport.tone.green > 0
    @viewport2.tone.blue-=15 if @viewport.tone.blue > 0
    @sprites["effect"].oy+=@speed
    @sprites["poke2"].opacity+=@opacity
    @opacity=-2 if @sprites["poke2"].opacity>=255
    @opacity=+2 if @sprites["poke2"].opacity<=0
    if @frame==8
      @sprites["start"].visible=true
    elsif @frame==24
      @sprites["start"].visible=false
      @frame=0
    end
      
    if @currentFrame==@totalFrames
      self.restart if RESTART_TITLE
    end
  end
  
  def restart
    pbBGMStop(0)
    51.times do
      @viewport.tone.red-=5
      @viewport.tone.green-=5
      @viewport.tone.blue-=5
      @viewport2.tone.red-=5
      @viewport2.tone.green-=5
      @viewport2.tone.blue-=5
      self.update
      wait(1)
    end
    raise Reset.new
  end
  
  def dispose
    @viewport.tone=Tone.new(0,0,0)
    @viewport2.tone=Tone.new(0,0,0)
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    @viewport2.dispose
    @disposed=true
  end
  
  def disposed?
    return @disposed
  end
  
  def wait(frames,advance=true)
    return false if @skip
    frames.times do
      @currentFrame+=1 if advance
      Graphics.update
      Input.update
      @skip=true if Input.trigger?(Input::C)
    end
    return true
  end
  
end
#===============================================================================
# Styled to look like the DPPT games
#===============================================================================
class GenFourStyle
  def initialize
    # sound file for playing the title screen BGM
    bgm = GEN_FOUR_BGM
    str = "Audio/BGM/"+pbResolveAudioFile(bgm).name
    @mp3 = (File.extname(str)==".ogg") ? true : false
    @skip = false
    # speed of the silhouette animation
    @speed = 3
    @sframe = 0
    @opacity = 17
    @disposed = false
    
    @currentFrame = 0
    # calculates after how many frames the game will reset
    @totalFrames=getPlayTime(str).to_i*Graphics.frame_rate
    pbBGMPlay(bgm)
    
    # creates all the necessary graphics
    @viewport = Viewport.new(0,0,Graphics.width,VIEWPORT_HEIGHT)
    @viewport.z = 99999
    @viewport2 = Viewport.new(0,0,Graphics.width,VIEWPORT_HEIGHT)
    @viewport2.z = 99998
    @sprites = {}
    
    @sprites["background"] = Sprite.new(@viewport)
    @sprites["background"].opacity = 0
    
    @sprites["effect"] = Sprite.new(@viewport2)
    @sprites["effect"].bitmap = pbBitmap("Graphics/Titles/gen_4_eff")
    @sprites["effect"].y = @viewport.rect.height
    @sprites["effect"].opacity = 0
    
    @sprites["sil"] = Sprite.new(@viewport2)
    @sprites["sil"].bitmap = pbBitmap("Graphics/Titles/gen_4_sil")
    @sprites["sil"].src_rect.set(0,0,@viewport.rect.width,@viewport.rect.height)
    @sprites["sil"].opacity = 0
    
    @sprites["overlay"] = Sprite.new(@viewport2)
    @sprites["overlay"].bitmap = pbBitmap("Graphics/Titles/gen_4_over")
    @sprites["overlay"].z = 20
    @sprites["overlay"].opacity = 0
    
    @sprites["start"] = Sprite.new(@viewport)
    @sprites["start"].bitmap = pbBitmap("Graphics/Titles/pokestart")
    @sprites["start"].x = (@viewport.rect.width-@sprites["start"].bitmap.width)/2
    @sprites["start"].y = @viewport.rect.height - 32
    @sprites["start"].opacity = 0
    @sprites["start"].z = 45
    
    @sprites["logo"] = Sprite.new(@viewport)
    bitmap1=pbBitmap("Graphics/Titles/pokelogo")
    bitmap2=pbBitmap("Graphics/Titles/pokelogo2")
    @sprites["logo"].bitmap = Bitmap.new(bitmap1.width,bitmap1.height)
    @sprites["logo"].bitmap.blt(0,0,bitmap2,Rect.new(0,0,bitmap2.width,bitmap2.height))
    @sprites["logo"].bitmap.blt(0,0,bitmap1,Rect.new(0,0,bitmap1.width,bitmap1.height))
    @sprites["logo"].tone = Tone.new(0,0,0,255)
    @sprites["logo"].ox = @sprites["logo"].bitmap.width/2
    @sprites["logo"].oy = @sprites["logo"].bitmap.height/2
    @sprites["logo"].x = @viewport.rect.width/2 - 4
    @sprites["logo"].y = @viewport.rect.height/2 - 30
    @sprites["logo"].z = 50
    @sprites["logo"].opacity = 0
    
  end
  
  def intro
    for i in 0...80
      @sprites["logo"].opacity+=3.2
      @sprites["overlay"].opacity+=3.2
      @sprites["logo"].y-=1 if i%4==0
      wait(1)
    end
    c = 255
    @viewport.tone = Tone.new(c,c,c)
    @viewport2.tone = Tone.new(c,c,c)
    @sprites["logo"].tone = Tone.new(0,0,0)
    @sprites["overlay"].opacity = 255
    @sprites["background"].opacity = 255
    @sprites["effect"].opacity = 255
    @sprites["sil"].opacity = 255
    17.times do
      c-=15
      @viewport.tone = Tone.new(c,c,c)
      @viewport2.tone = Tone.new(c,c,c)
      self.update
      wait(1)
    end
    @skip = false
  end
  
  def update
    @currentFrame+=1 if !@skip
    @sframe+=1
    if @sframe > @speed
      @sprites["sil"].src_rect.x+=@viewport.rect.width
      @sprites["sil"].src_rect.x=0 if @sprites["sil"].src_rect.x>=@sprites["sil"].bitmap.width
      @sframe=0
    end
    @sprites["start"].opacity+=@opacity
    @opacity=-17 if @sprites["start"].opacity>=255
    @opacity=+17 if @sprites["start"].opacity<=0
    @sprites["effect"].y-=16
    @sprites["effect"].y = @viewport.rect.height if @sprites["effect"].y<-(@viewport.rect.height*12)
    
    if @currentFrame==@totalFrames
      #self.restart if RESTART_TITLE
    end
  end
  
  def restart
    pbBGMStop(0)
    51.times do
      @viewport.tone.red-=5
      @viewport.tone.green-=5
      @viewport.tone.blue-=5
      @viewport2.tone.red-=5
      @viewport2.tone.green-=5
      @viewport2.tone.blue-=5
      self.update
      wait(1)
    end
    raise Reset.new
  end
  
  def dispose
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    @disposed=true
  end
  
  def disposed?
    return @disposed
  end
  
  def wait(frames,advance=true)
    return false if @skip
    frames.times do
      @currentFrame+=1 if advance
      Graphics.update
      Input.update
      @skip=true if Input.trigger?(Input::C)
    end
    return true
  end
  
end
#===============================================================================
# Styled to look like the BW games
#===============================================================================
class PokeBattle_Pokemon
  # provides a fix for forms crashing game
  def spoofForm(val)
    @form = val
    @forcedform = val
  end
end

class GenFiveStyle
  def getAvgColor(bitmap,width,height)
    red = 0
    green = 0
    blue = 0
    n = 0
    for x in 0...width
      for y in 0...height
        c = bitmap.get_pixel(x,y)
        red+=c.red
        green+=c.green
        blue+=c.blue
        n+=1
      end
    end
    return Color.new((red/n)+60,(green/n)+60,(blue/n)+60)
  end
  
  def initialize
    # creates a dummy Pokemon object
    species = SPECIES
    species = getConst(PBSpecies,SPECIES) if !SPECIES.is_a?(Numeric)
    pokemon = PokeBattle_Pokemon.new(species,5)
    pokemon.spoofForm(SPECIES_FORM)
    bmp = pbLoadPokemonBitmap(pokemon).bitmap
    # coloures background according to the SPECIES sprite
    color = self.getAvgColor(bmp,bmp.width,bmp.height)
    # sound file for playing the title screen BGM
    bgm = GEN_FIVE_BGM
    str = "Audio/BGM/"+pbResolveAudioFile(bgm).name
    @mp3 = (File.extname(str)==".ogg") ? true : false
    @skip = false
    # speed of the silhouette animation
    @speed = 3
    @sframe = 0
    @lframe = 0
    @opacity = 17
    @disposed = false
    
    @currentFrame = 0
    # calculates after how many frames the game will reset
    @totalFrames=getPlayTime(str).to_i*Graphics.frame_rate - 40
    pbBGMPlay(bgm)
    
    # creates all the necessary graphics
    @viewport = Viewport.new(0,0,Graphics.width,VIEWPORT_HEIGHT)
    @viewport.z = 99999
    @viewport2 = Viewport.new(0,0,Graphics.width,VIEWPORT_HEIGHT)
    @viewport2.z = 99998
    @sprites = {}
    
    @sprites["background"] = Sprite.new(@viewport)
    @sprites["background"].color = color if EXPAND_STYLE
    @sprites["background"].visible = false
    
    @sprites["background2"] = Sprite.new(@viewport2)
    @sprites["background2"].bitmap = pbBitmap("Graphics/Titles/gen_5_bg")
    @sprites["background2"].color = color if EXPAND_STYLE
    
    @sprites["effect"] = AnimatedPlane.new(@viewport)
    @sprites["effect"].visible = false
    @sprites["effect2"] = AnimatedPlane.new(@viewport2)
    @sprites["effect2"].bitmap = pbBitmap("Graphics/Titles/gen_5_eff")
    
    @sprites["shine"] = Sprite.new(@viewport2)
    @sprites["shine"].bitmap = pbBitmap("Graphics/Titles/gen_5_shine")
    @sprites["shine"].ox = @sprites["shine"].bitmap.width/2
    @sprites["shine"].oy = @sprites["shine"].bitmap.height/2
        
    @sprites["reflection"] = AnimatedPokemonSprite.new(@viewport2)
    @sprites["reflection"].setBitmap(pokemon)
    @sprites["reflection"].y = @viewport.rect.height - 32
    @sprites["reflection"].angle = 180
    @sprites["reflection"].mirror = true
    @sprites["reflection"].z = 5
    @sprites["reflection"].zoom_x = ($ResizeFactor==0.5) ? 2.0 : 1.5
    @sprites["reflection"].zoom_y = ($ResizeFactor==0.5) ? 2.0 : 1.5
    @sprites["reflection"].opacity = 255*0.2
    
    @sprites["sprite"] = AnimatedPokemonSprite.new(@viewport2)
    @sprites["sprite"].setBitmap(pokemon)
    @sprites["sprite"].x = @viewport.rect.width
    @sprites["sprite"].y = @viewport.rect.height - 64
    @sprites["sprite"].z = 10
    @sprites["sprite"].zoom_x = ($ResizeFactor==0.5) ? 2.0 : 1.5
    @sprites["sprite"].zoom_y = ($ResizeFactor==0.5) ? 2.0 : 1.5
    
    @sprites["shine"].x = @viewport.rect.width/2
    @sprites["shine"].y = @sprites["sprite"].y-@sprites["sprite"].height/2
    
    @sprites["start"] = Sprite.new(@viewport)
    @sprites["start"].bitmap = pbBitmap("Graphics/Titles/pokestart")
    @sprites["start"].x = (@viewport.rect.width-@sprites["start"].bitmap.width)/2
    @sprites["start"].y = @viewport.rect.height - 24
    @sprites["start"].opacity = 0
    @sprites["start"].z = 45
    
    @sprites["logo"] = Sprite.new(@viewport)
    @bitmap1=pbBitmap("Graphics/Titles/pokelogo")
    @bitmap2=pbBitmap("Graphics/Titles/pokelogo2")
    @sprites["logo"].bitmap = Bitmap.new(@bitmap1.width,@bitmap1.height)
    @sprites["logo"].bitmap.blt(0,0,@bitmap2,Rect.new(0,0,@bitmap2.width,@bitmap2.height))
    @sprites["logo"].bitmap.blt(0,0,@bitmap1,Rect.new(0,0,@bitmap1.width,@bitmap1.height))
    @sprites["logo"].ox = @sprites["logo"].bitmap.width/2
    @sprites["logo"].oy = @sprites["logo"].bitmap.height/2
    @sprites["logo"].x = @viewport.rect.width/2 - 4
    @sprites["logo"].y = 24+64+99
    @sprites["logo"].z = 5
    
    @logy = 2
    @logo = -17
  end
  
  def intro
    @viewport.tone = Tone.new(255,255,255)
    @viewport2.tone = Tone.new(255,255,255)
    @skip = false
  end
  
  def update
    @currentFrame+=1 if !@skip
    @sframe+=1
    @lframe+=1
    @sprites["reflection"].update
    @sprites["sprite"].update
    @sprites["shine"].angle+=1
    @sprites["logo"].y-=@logy
    y = 123
    @sprites["logo"].y = y if @sprites["logo"].y < y && @sframe < Graphics.frame_rate*10
    if @sprites["logo"].y == y-8
      @logy = -2
    elsif @sprites["logo"].y > y && @sprites["logo"].y <= y+2
      @logy = +2
      @sframe = 0
    end
    
    @sprites["start"].opacity+=@opacity
    @opacity=-17 if @sprites["start"].opacity>=255
    @opacity=+17 if @sprites["start"].opacity<=0
    @sprites["effect"].ox+=1
    @sprites["effect2"].ox+=1
    @sprites["sprite"].x+=(@viewport.rect.width/2 - @sprites["sprite"].x)*0.1
    @sprites["reflection"].x = @sprites["sprite"].x
    
    @viewport.tone.red-=17 if @viewport.tone.red > 0
    @viewport.tone.green-=17 if @viewport.tone.green > 0
    @viewport.tone.blue-=17 if @viewport.tone.blue > 0
    @viewport2.tone.red-=17 if @viewport2.tone.red > 0
    @viewport2.tone.green-=17 if @viewport2.tone.green > 0
    @viewport2.tone.blue-=17 if @viewport2.tone.blue > 0
    
    if @currentFrame==@totalFrames
      self.restart if RESTART_TITLE
    end
  end
  
  def restart
    pbBGMStop(0)
    51.times do
      @viewport.tone.red-=5
      @viewport.tone.green-=5
      @viewport.tone.blue-=5
      @viewport2.tone.red-=5
      @viewport2.tone.green-=5
      @viewport2.tone.blue-=5
      self.update
      wait(1)
    end
    raise Reset.new
  end
  
  
  def dispose
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    @viewport2.dispose
    @disposed=true
  end
  
  def disposed?
    return @disposed
  end
  
  def wait(frames,advance=true)
    return false if @skip
    frames.times do
      @currentFrame+=1 if advance
      Graphics.update
      Input.update
      @skip=true if Input.trigger?(Input::C)
    end
    return true
  end
  
end
#===============================================================================
# Styled to look like the XY games
#===============================================================================
class GenSixStyle
  def initialize
    # decides whether or not to show another layer of the title screen
    @showPoke = EXPAND_STYLE
    # sound file for playing the title screen BGM
    bgm = GEN_SIX_BGM
    str = "Audio/BGM/"+pbResolveAudioFile(bgm).name
    @mp3 = (File.extname(str)==".ogg") ? true : false
    @skip = false
    @disposed = false
    @swapped = false
    @particles = 32
    @opacity = 5
    @pframe = [0,0,0,0,0]
    @speed = 3
    
    @currentFrame = 0
    # calculates after how many frames the game will reset
    @totalFrames=getPlayTime(str).to_i*Graphics.frame_rate
    
    pbBGMPlay(bgm)
    pbWait(30) if @mp3
    @totalFrames-=100 if @mp3
    
    # creates all the necessary graphics
    h = @showPoke ? 2 : 1
    @viewport = Viewport.new(0,0,Graphics.width,VIEWPORT_HEIGHT*h)
    @viewport.z = 99999
    if @showPoke
      @viewport2 = Viewport.new(0,VIEWPORT_HEIGHT+VIEWPORT_OFFSET,Graphics.width,VIEWPORT_HEIGHT)
      @viewport2.z = 99990
      @viewport2.tone = Tone.new(-255,-255,-255)
    end
    @viewport2b = Viewport.new(0,0,Graphics.width,VIEWPORT_HEIGHT)
    @viewport2b.z = 99999
    @sprites = {}
    
    self.drawPanorama if @showPoke
    
    @sprites["background"] = Sprite.new(@viewport)
    @sprites["background"].bitmap = pbBitmap("Graphics/Titles/gen_6_bg")
    @sprites["effect"] = Sprite.new(@viewport)
    @sprites["effect"].bitmap = pbBitmap("Graphics/Titles/gen_6_effect")
    @sprites["effect"].ox = @sprites["effect"].bitmap.width/2
    @sprites["effect"].oy = @sprites["effect"].bitmap.height/2
    @sprites["effect"].x = @viewport.rect.width/2
    @sprites["effect"].y = @viewport.rect.height/(2*h)
    @sprites["effect2"] = Sprite.new(@viewport)
    @sprites["effect2"].bitmap = pbBitmap("Graphics/Titles/gen_6_effect2")
    @sprites["effect2"].ox = @sprites["effect2"].bitmap.width/2
    @sprites["effect2"].oy = @sprites["effect2"].bitmap.height/2
    @sprites["effect2"].x = @viewport.rect.width/2
    @sprites["effect2"].y = @viewport.rect.height/(2*h)
    @sprites["effect2"].opacity = 0
    @sprites["effect2"].z = 21
    @sprites["effect2"].angle = 20
    @effo = 1
    @sprites["shine"] = Sprite.new(@viewport)
    @sprites["shine"].bitmap = pbBitmap("Graphics/Titles/gen_6_shine")
    @sprites["shine"].ox = @sprites["shine"].bitmap.width/2
    @sprites["shine"].oy = @sprites["shine"].bitmap.height/2
    @sprites["shine"].x = @viewport.rect.width/2 + 1
    @sprites["shine"].y = @viewport.rect.height/(2*h) - 2
    @sprites["shine"].zoom_x = 0
    @sprites["shine"].zoom_y = 0
    @sprites["shine"].opacity = 0
    
    for i in 0...@particles
      @sprites["p#{i}"] = AnimatedSpriteParticle.new(@viewport,rand(32))
      @sprites["p#{i}"].dy = @viewport.rect.height/(2*h)
      @sprites["p#{i}"].z = 21 
      @sprites["p#{i}"].inverted = true
      @sprites["p#{i}"].refresh
    end
    
    @sprites["glow"] = Sprite.new(@viewport)
    @sprites["glow"].bitmap = pbBitmap("Graphics/Titles/gen_6_glow")
    @sprites["glow"].opacity = 0
    @sprites["overlay"] = Sprite.new(@viewport)
    @sprites["overlay"].bitmap = pbBitmap("Graphics/Titles/gen_6_overlay")
    @sprites["overlay"].z = 4
    
    @sprites["startrect"] = Sprite.new(@viewport2b)
    @sprites["startrect"].bitmap = Bitmap.new(@viewport2b.rect.width,@viewport2b.rect.height)
    @sprites["startrect"].bitmap.fill_rect(0,@sprites["startrect"].bitmap.height-38,@sprites["startrect"].bitmap.width,28,Color.new(0,0,0,92))
    @sprites["startrect"].visible = false
    
    @sprites["logo"] = Sprite.new(@viewport2b)
    @bitmap1=pbBitmap("Graphics/Titles/pokelogo")
    @bitmap2=pbBitmap("Graphics/Titles/pokelogo2")
    @sprites["logo"].bitmap = Bitmap.new(@bitmap1.width,@bitmap1.height)
    @sprites["logo"].bitmap.blt(0,0,@bitmap2,Rect.new(0,0,@bitmap2.width,@bitmap2.height))
    @sprites["logo"].bitmap.blt(0,0,@bitmap1,Rect.new(0,0,@bitmap1.width,@bitmap1.height))
    @sprites["logo"].ox = @sprites["logo"].bitmap.width/2
    @sprites["logo"].oy = @sprites["logo"].bitmap.height/2
    @sprites["logo"].x = @viewport2b.rect.width/2 - 4
    @sprites["logo"].y = @viewport2b.rect.height/2
    @sprites["logo"].zoom_x = 1.2
    @sprites["logo"].zoom_y = 1.2
    @sprites["logo"].opacity = 0
    @sprites["logo"].z = 5
    
    @sprites["start"] = Sprite.new(@viewport2b)
    @sprites["start"].bitmap = pbBitmap("Graphics/Titles/pokestart")
    @sprites["start"].x = (@viewport2b.rect.width-@sprites["start"].bitmap.width)/2
    @sprites["start"].y = @viewport2b.rect.height - 32
    @sprites["start"].visible = false
    @sprites["start"].z = 5
    
    @glow = 1
  end
  
  def intro
    h = @showPoke ? 2 : 1
    @viewport.rect.height/=h
    @black1 = Sprite.new(@viewport)
    @black1.bitmap = Bitmap.new(@viewport.rect.width,2)
    @black1.bitmap.fill_rect(0,0,@black1.bitmap.width,2,Color.new(0,0,0))
    @black1.zoom_y = @viewport.rect.height/4
    @black1.z = 20
    @black2 = Sprite.new(@viewport)
    @black2.bitmap = @black1.bitmap.clone
    @black2.oy = 2
    @black2.zoom_y = @black1.zoom_y
    @black2.y = @viewport.rect.height
    @black2.z = 20
    @sprites["shine"].z = 22
    @box = Sprite.new(@viewport)
    @box.z = 10
    @box.bitmap = pbBitmap("Graphics/Titles/gen_6_letter2")
    @box.ox = @box.bitmap.width/2
    @box.oy = @box.bitmap.height/2
    @box.x = @viewport.rect.width/2
    @box.y = @viewport.rect.height/2
    @box.zoom_x = 0
    @box.zoom_y = 0
    @box.angle = -12
    @letter = Sprite.new(@viewport)
    @letter.bitmap = pbBitmap("Graphics/Titles/gen_6_letter")
    @letter.ox = @letter.bitmap.width/2
    @letter.oy = @letter.bitmap.height/2
    @letter.tone = Tone.new(-64,-64,-64)
    @letter.x = @box.x
    @letter.y = @box.y
    @letter.z = 25
    @letter.zoom_x = 0
    @letter.zoom_y = 0
    @letter.angle = -8
    f = @mp3 ? 100 : 120
    f.times do
      next if !wait(1,false)
      @sprites["shine"].opacity+=5
      @sprites["shine"].zoom_x+=0.0025
      @sprites["shine"].zoom_y+=0.0025
      self.update
    end
    @viewport.tone = Tone.new(200,200,200)
    @sprites["effect2"].z = 1
    for i in 0...@particles
      @sprites["p#{i}"].inverted = false
      @sprites["p#{i}"].refresh
    end    
    for i in 0...10
      next if !wait(1,false)
      @black1.zoom_y-=27 if i>6
      @black2.zoom_y-=27 if i>6
      @box.zoom_x+=0.11
      @box.zoom_y+=0.11
      self.update
    end
    5.times do
      next if !wait(1,false)
      @letter.zoom_x+=0.2
      @letter.zoom_y+=0.2
      self.update
    end
    @sprites["shine"].z = 1
    @sprites["shine"].zoom_x = 1
    @sprites["shine"].zoom_y = 1
    160.times do
      next if !wait(1,false)
      @letter.tone.red+=4 if @letter.tone.red < 0
      @letter.tone.green+=4 if @letter.tone.green < 0
      @letter.tone.blue+=4 if @letter.tone.blue < 0
      @box.angle+=0.1
      @box.zoom_x-=0.0015
      @box.zoom_y-=0.0015
      @letter.zoom_x+=0.0015
      @letter.zoom_y+=0.0015
      @letter.angle+=0.08
      self.update
    end
    for i in 0...@particles
      @sprites["p#{i}"].z = 1
    end
    f = @mp3 ? 38 : 48
    f.times do
      next if !wait(1,false)
      @black1.zoom_y-=1
      @black2.zoom_y-=1
      @box.zoom_x+=0.5
      @box.zoom_y+=0.5
      @letter.zoom_x+=0.001
      @letter.zoom_y+=0.001
      @letter.x+=@viewport.rect.width/16
      self.update
    end
    @black1.dispose
    @black2.dispose
    @box.dispose
    @letter.dispose
    50.times do
      @sprites["logo"].zoom_x-=0.004
      @sprites["logo"].zoom_y-=0.004
      @sprites["logo"].opacity+=5
      self.update
      wait(1,false)
    end
    @sprites["logo"].opacity+=5
    @viewport.tone = Tone.new(200,200,200)
    @sprites["logo"].tone = Tone.new(255,255,255)
    f = 160-36-16
    f-= 60 if @mp3
    f.times do
      self.update
      wait(1,false)
    end
    @sprites["start"].visible = true
    @sprites["start"].opacity = 255
    @opacity = -5
    @sprites["startrect"].visible = true
    @viewport2.tone = Tone.new(0,0,0) if @showPoke
    @viewport2.rect.height = 0 if @showPoke
    @skip = false
  end
  
  def update
    @currentFrame+=1 if !@skip
    @sprites["start"].opacity+=@opacity
    @opacity=-5 if @sprites["start"].opacity>=255
    @opacity=+5 if @sprites["start"].opacity<=0
    self.swapViewports if @showPoke && (@currentFrame==1040 || @currentFrame==1780)
    self.update1
    self.update2 if @showPoke
    if @currentFrame==@totalFrames
      self.restart if RESTART_TITLE
    end
  end
  
  def update1
    @sprites["effect"].angle+=1 if $ResizeFactor <= 1
    @sprites["effect2"].angle+=0.2 if $ResizeFactor <= 1
    @sprites["effect2"].opacity-=@effo
    if @sprites["effect2"].opacity < 32
      @effo = -1
    elsif @sprites["effect2"].opacity >= 255
      @effo = 1
    end
    @sprites["shine"].angle-=1 if $ResizeFactor <= 1
    @sprites["glow"].opacity-=@glow
    @sprites["logo"].tone.red-=2 if @sprites["logo"].tone.red > 0
    @sprites["logo"].tone.green-=2 if @sprites["logo"].tone.green > 0
    @sprites["logo"].tone.blue-=2 if @sprites["logo"].tone.blue > 0
    @viewport.tone.red-=5 if @viewport.tone.red > 0
    @viewport.tone.green-=5 if @viewport.tone.green > 0
    @viewport.tone.blue-=5 if @viewport.tone.blue > 0
    if @sprites["glow"].opacity <= 0
      @glow = -1
    elsif @sprites["glow"].opacity >= 255
      @glow = 1
    end
    for i in 0...@particles
      @sprites["p#{i}"].update
    end
  end
  
  def update2
    for i in 0...@pframe.length
      @pframe[i]+=1
    end
    @sprites["grass"].ox-=4
    @sprites["trees1"].ox-=1
    @sprites["trees2"].ox-=1 if @pframe[0]>1
    @sprites["trees3"].ox-=1 if @pframe[1]>2
    @sprites["clouds"].ox+=1 if @pframe[3]>3
    @sprites["pokemon"].src_rect.x+=@sprites["pokemon"].src_rect.width if @pframe[4]>@speed
    @sprites["pokemon"].src_rect.x=0 if @sprites["pokemon"].src_rect.x>=@sprites["pokemon"].bitmap.width
      
    @pframe[0]=0 if @pframe[0]>1
    @pframe[1]=0 if @pframe[1]>2
    @pframe[2]=0 if @pframe[2]>1
    @pframe[3]=0 if @pframe[3]>3
    @pframe[4]=0 if @pframe[4]>@speed
  end
        
  def swapViewports
    view1 = @swapped ? @viewport2 : @viewport
    view2 = @swapped ? @viewport : @viewport2
    y = @swapped ? -6*4 : 6
    o = @swapped ? -4*4 : 6
    @viewport2b.tone = Tone.new(200,200,200) if !@swapped
    f = @swapped ? 32/2 : 64
    f.times do
      @viewport2b.tone.red-=5 if @viewport2b.tone.red > 0
      @viewport2b.tone.green-=5 if @viewport2b.tone.green > 0
      @viewport2b.tone.blue-=5 if @viewport2b.tone.blue > 0
      @viewport2.rect.height+=y
      @viewport.rect.height+=y
      @sprites["overlay"].opacity-=o
      view1.rect.y-=y
      view2.rect.y-=y
      @sprites["logo"].y-=y/6
      self.update
      wait(1,false)
    end
    @swapped = !@swapped
  end
  
  def drawPanorama
    viewport = @viewport2
    @sprites["background2"] = Sprite.new(viewport)
    @sprites["background2"].bitmap = pbBitmap("Graphics/Titles/Panorama/background")
    @sprites["clouds"] = AnimatedPlane.new(viewport)
    @sprites["clouds"].bitmap = pbBitmap("Graphics/Titles/Panorama/clouds")
    @sprites["mountains"] = Sprite.new(viewport)
    @sprites["mountains"].bitmap = pbBitmap("Graphics/Titles/Panorama/mountains")
    @sprites["trees3"] = AnimatedPlane.new(viewport)
    @sprites["trees3"].bitmap = pbBitmap("Graphics/Titles/Panorama/trees_3")
    @sprites["trees2"] = AnimatedPlane.new(viewport)
    @sprites["trees2"].bitmap = pbBitmap("Graphics/Titles/Panorama/trees_2")
    @sprites["trees1"] = AnimatedPlane.new(viewport)
    @sprites["trees1"].bitmap = pbBitmap("Graphics/Titles/Panorama/trees_1")    
    @sprites["grass"] = AnimatedPlane.new(viewport)
    @sprites["grass"].bitmap = pbBitmap("Graphics/Titles/Panorama/grass")
    @sprites["pokemon"] = Sprite.new(viewport)
    @sprites["pokemon"].bitmap = pbBitmap("Graphics/Titles/Panorama/pokemon")
    @sprites["pokemon"].src_rect.set(0,0,@sprites["pokemon"].bitmap.height,@sprites["pokemon"].bitmap.height)
    @sprites["pokemon"].x = viewport.rect.width - @sprites["pokemon"].src_rect.width - 32
    @sprites["pokemon"].y = viewport.rect.height - @sprites["pokemon"].src_rect.height
  
    @sprites["overlay2"] = Sprite.new(viewport)
    @sprites["overlay2"].bitmap = Bitmap.new(viewport.rect.width,viewport.rect.height)
    @sprites["overlay2"].z = 4
    @sprites["overlay2"].bitmap.fill_rect(0,@sprites["overlay2"].bitmap.height-38,@sprites["overlay2"].bitmap.width,28,Color.new(0,0,0,92))
  end
    
  def restart
    pbBGMStop(0)
    51.times do
      @viewport.tone.red-=5
      @viewport.tone.green-=5
      @viewport.tone.blue-=5
      @viewport2.tone.red-=5
      @viewport2.tone.green-=5
      @viewport2.tone.blue-=5
      @viewport2b.tone.red-=5
      @viewport2b.tone.green-=5
      @viewport2b.tone.blue-=5
      self.update
      wait(1)
    end
    self.dispose(false)
    PlayEBDemo.new if defined?(DynamicPokemonSprite)
    raise Reset.new
  end
  
  def dispose(fade=true)
    pbFadeOutAndHide(@sprites) if fade
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose if @viewport
    @viewport2.dispose if @viewport2
    @viewport2b.dispose if @viewport2b
    @disposed=true
  end
  
  def disposed?
    return @disposed
  end
  
  def wait(frames,advance=true)
    return false if @skip
    frames.times do
      @currentFrame+=1 if advance
      Graphics.update
      Input.update
      @skip=true if Input.trigger?(Input::C)
    end
    return true
  end
  
end
#===============================================================================
# Styled to look like the SM games
#===============================================================================
class GenSevenStyle
  def initialize
    # sound file for playing the title screen BGM
    @bgm = GEN_SEVEN_BGM
    str = "Audio/BGM/"+pbResolveAudioFile(@bgm).name
    @skip = false
    @disposed = false
    
    @currentFrame = 0
    # calculates after how many frames the game will reset
    @totalFrames = getPlayTime(str).to_i*Graphics.frame_rate
        
    # creates all the necessary graphics
    @viewport = Viewport.new(0,0,Graphics.width,VIEWPORT_HEIGHT)
    @viewport.z = 99999
    @viewport2 = Viewport.new(0,0,Graphics.width,VIEWPORT_HEIGHT)
    @viewport2.z = 99999

    @sprites = {}
    @intro = {}
    
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg"].bitmap = pbBitmap("Graphics/Titles/gen_7_bg")
    @sprites["rect"] = Sprite.new(@viewport)
    @sprites["rect"].bitmap = pbBitmap("Graphics/Titles/gen_7_bg2")
    @sprites["rect"].toggle = 1
    @sprites["rect3"] = Sprite.new(@viewport)
    @sprites["rect3"].bitmap = pbBitmap("Graphics/Titles/gen_7_bg4")
    @sprites["rect3"].opacity = 0
    @sprites["rect3"].toggle = -1
    
    for i in 0...6
      @sprites["f#{i}"] = Sprite.new(@viewport)
      @sprites["f#{i}"].z = 600
      @sprites["f#{i}"].bitmap = pbBitmap("Graphics/Titles/Panorama/flare#{i+1}")
      @sprites["f#{i}"].ox = @sprites["f#{i}"].bitmap.width/2
      @sprites["f#{i}"].oy = @sprites["f#{i}"].bitmap.height/2
      @sprites["f#{i}"].x = Graphics.width/2
      @sprites["f#{i}"].y = VIEWPORT_HEIGHT/2
      @sprites["f#{i}"].opacity = 0
      @sprites["f#{i}"].tone = Tone.new(128,128,128)
    end

    for i in 0...4
      @sprites["e#{i}"] = Sprite.new(@viewport)
      @sprites["e#{i}"].bitmap = pbBitmap("Graphics/Titles/gen_7_e#{i+1}")
      @sprites["e#{i}"].ox = @sprites["e#{i}"].bitmap.width/2
      @sprites["e#{i}"].oy = @sprites["e#{i}"].bitmap.height/2
      @sprites["e#{i}"].x = @viewport.rect.width/2
      @sprites["e#{i}"].y = @viewport.rect.height/2
    end
    @sprites["rect2"] = Sprite.new(@viewport)
    @sprites["rect2"].drawRect(@viewport.rect.width,@viewport.rect.height,Color.new(0,0,0))
    @sprites["rect2"].z = 450
    for i in 0...128
      n = [1,3,4,5,6,7][rand(6)]
      @sprites["s#{i}"] = Sprite.new(@viewport)
      @sprites["s#{i}"].bitmap = pbBitmap("Graphics/Titles/gen_7_s#{n}")
      @sprites["s#{i}"].ox = @sprites["s#{i}"].bitmap.width/2
      @sprites["s#{i}"].oy = @sprites["s#{i}"].bitmap.height/2
      z = [0.4,0.4,0.5,0.6,0.7][rand(5)]
      @sprites["s#{i}"].zoom_x = z
      @sprites["s#{i}"].zoom_y = z
      @sprites["s#{i}"].x = rand(@viewport.rect.width + 1)
      @sprites["s#{i}"].y = rand(@viewport.rect.height + 1)
      o = 85 + rand(130)
      s = 2 + rand(4)
      @sprites["s#{i}"].speed = s
      @sprites["s#{i}"].toggle = 1
      @sprites["s#{i}"].param = o
      @sprites["s#{i}"].opacity = o
    end
    @sprites["logo1"] = Sprite.new(@viewport)
    @sprites["logo1"].z = 400
    @sprites["logo2"] = Sprite.new(@viewport)
    @sprites["logo2"].z = 500
    @sprites["logo2"].color = Color.new(255,255,255)
    @sprites["logo2"].opacity = 0
    bmp1 = pbBitmap("Graphics/Titles/pokelogo2")
    bmp2 = pbBitmap("Graphics/Titles/pokelogo")
    @sprites["logo2"].bitmap = Bitmap.new(@viewport.rect.width,@viewport.rect.height)
    x = (@viewport.rect.width - bmp1.width)/2
    y = (@viewport.rect.height - bmp1.height)/2
    @sprites["logo2"].bitmap.blt(x,y,bmp1,Rect.new(0,0,bmp1.width,bmp1.height))
    @sprites["logo2"].bitmap.blt(x,y,bmp2,Rect.new(0,0,bmp2.width,bmp2.height))
    @sprites["logo1"].bitmap = @sprites["logo2"].bitmap.clone
    @sprites["logo1"].create_outline(Color.new(255,255,255,155),4)
    @sprites["logo1"].toggle = 2
    for j in 0...16
      @sprites["p#{j}"] = Sprite.new(@viewport)
      @sprites["p#{j}"].bitmap = pbBitmap("Graphics/Titles/gen_7_s2")
      @sprites["p#{j}"].ox = -(@viewport.rect.width/2 + @sprites["p#{j}"].bitmap.width)
      @sprites["p#{j}"].oy = @sprites["p#{j}"].bitmap.height/2
      @sprites["p#{j}"].zoom_x = 2
      @sprites["p#{j}"].zoom_y = 2
      @sprites["p#{j}"].angle = rand(360)
      @sprites["p#{j}"].x = @viewport.rect.width/2
      @sprites["p#{j}"].y = @viewport.rect.height/2
    end
    @i = 0
    
    @intro["bg"] = Sprite.new(@viewport2)
    @intro["bg"].bitmap = pbBitmap("Graphics/Titles/gen_7_bg3")
    @intro["bg"].ox = @intro["bg"].bitmap.width/2
    @intro["bg"].oy = @intro["bg"].bitmap.height/2
    @intro["bg"].x = @viewport.rect.width/2
    @intro["bg"].y = @viewport.rect.height/2
    
    for j in 0...128
      @intro["s#{j}"] = Sprite.new(@viewport2)
      @intro["s#{j}"].bitmap = pbBitmap("Graphics/Titles/gen_7_s8")
      a = rand(360)
      b = a*(Math::PI/180)
      r = (@viewport.rect.width*0.5)*Math.cos(b).abs + (@viewport.rect.height*0.5)*Math.sin(b).abs
      @intro["s#{j}"].ox = -(rand(r) + @sprites["s#{j}"].bitmap.width) 
      @intro["s#{j}"].oy = @sprites["s#{j}"].bitmap.height/2
      @intro["s#{j}"].angle = a
      @intro["s#{j}"].x = @viewport.rect.width/2
      @intro["s#{j}"].y = @viewport.rect.height/2
      @intro["s#{j}"].opacity = 25 + rand(130)
    end
    @viewport2.color = Color.new(0,0,0)
    @angle = -180
    
    @sprites["comet"] = Sprite.new(@viewport)
    @sprites["comet"].bitmap = pbBitmap("Graphics/Titles/gen_7_c1")
    @sprites["comet"].ox = @sprites["comet"].bitmap.width/2
    @sprites["comet"].z = 350
    @sprites["comet"].angle = @angle
    
    @sprites["start"] = Sprite.new(@viewport)
    @sprites["start"].drawRect(@viewport.rect.width,28,Color.new(0,0,0,85))
    bmp = pbBitmap("Graphics/Titles/pokestart")
    @sprites["start"].bitmap.blt((@viewport.rect.width - bmp.width)/2,(28 - bmp.height)/2,bmp,Rect.new(0,0,bmp.width,bmp.height))
    @sprites["start"].toggle = 1
    @sprites["start"].y = @viewport.rect.height - 64
    @sprites["start"].z = 350
  end
  
  def intro
    pbBGMPlay(@bgm)
    8.times do
      @viewport2.color.alpha -= 64 if @viewport2.color.alpha > 0
      @intro["bg"].angle += 0.5 if $PokemonSystem.screensize < 2
      for j in 0...128
        @intro["s#{j}"].angle += 0.5 if $PokemonSystem.screensize < 2
      end
      wait(1)
    end
    for j in 0...128
      ox = @intro["s#{j}"].ox
      @intro["s#{j}"].bitmap = pbBitmap("Graphics/Titles/gen_7_s2")
      @intro["s#{j}"].ox = ox
      @intro["s#{j}"].oy = @intro["s#{j}"].bitmap.height/2
    end
    32.times do
      @intro["bg"].angle += 2 if $PokemonSystem.screensize < 2
      @intro["bg"].opacity -= 32
      for j in 0...128
        @intro["s#{j}"].angle += 2 if $PokemonSystem.screensize < 2
        @intro["s#{j}"].zoom_x -= 0.03
        @intro["s#{j}"].zoom_y -= 0.03
        @intro["s#{j}"].opacity -= 8
      end
      wait(1)
    end
    pbDisposeSpriteHash(@intro)
    @viewport2.dispose
    @sprites["rect2"].color = Color.new(255,255,255,0)
    for i in 0...8
      @sprites["logo2"].opacity += 32
      @sprites["rect2"].color.alpha += 32
      wait(1)
    end
    for i in 0...16
      @sprites["logo2"].color.alpha -= 16
      self.update
      wait(1,false)
    end
  end
  
  def update
    @sprites["start"].opacity -= @sprites["start"].toggle * 2
    @sprites["start"].toggle *= -1 if @sprites["start"].opacity < 125 || @sprites["start"].opacity >= 255
    @sprites["rect"].opacity += @sprites["rect"].toggle
    @sprites["rect"].toggle *= -1 if @sprites["rect"].opacity <= 0 || @sprites["rect"].opacity >= 255
    @sprites["rect3"].opacity += @sprites["rect3"].toggle
    @sprites["rect3"].toggle *= -1 if @sprites["rect3"].opacity <= 0 || @sprites["rect3"].opacity >= 255
    @sprites["rect2"].opacity -= 8 if @sprites["rect2"].opacity > 0
    for i in 0...4
      a = [1,-1,2,-2]
      @sprites["e#{i}"].angle += a[i]*0.2 if $PokemonSystem.screensize < 2
    end
    for i in 0...128
      @sprites["s#{i}"].opacity += @sprites["s#{i}"].speed*@sprites["s#{i}"].toggle
      if @sprites["s#{i}"].opacity > @sprites["s#{i}"].param || @sprites["s#{i}"].opacity < 10
        @sprites["s#{i}"].toggle *= -1
      end
    end
    for j in 0...16
      next if j > @i/24
      if @sprites["p#{j}"].zoom_x <= 0
        @sprites["p#{j}"].zoom_x = 2
        @sprites["p#{j}"].zoom_y = 2
        @sprites["p#{j}"].opacity = 255
        @sprites["p#{j}"].angle = rand(360)
      end
      @sprites["p#{j}"].zoom_x -= 0.03125
      @sprites["p#{j}"].zoom_y -= 0.03125
      @sprites["p#{j}"].opacity -= 4
    end
    @sprites["logo1"].opacity -= @sprites["logo1"].toggle
    @sprites["logo1"].toggle *= -1 if @sprites["logo1"].opacity < 85 || @sprites["logo1"].opacity >= 255
    @i += 1 if @i < 1024
    #### Flare
    for j in 0...6
      next if j > @i
      @sprites["f#{j}"].opacity += (@i < 40) ? 32 : -16
      @sprites["f#{j}"].x -= (6-j)*(j < 5 ? 1 : -1)
      @sprites["f#{j}"].y += (6-j)*(j < 5 ? 1 : -1)
      @sprites["f#{j}"].tone.red -= 1
      @sprites["f#{j}"].tone.green -= 1
      @sprites["f#{j}"].tone.blue -= 1
    end
    ###########
    @currentFrame += 1
    ######### Math stuff
    @angle += 3 if @angle < 180 && @i >= 64
    a = @angle*(Math::PI/180)
    cx, cy = @viewport.rect.width, @viewport.rect.height
    w, h = @viewport.rect.width*2, @viewport.rect.height/2
    
    px = cx + w*Math.cos(a)
    py = cy - h*Math.sin(a)
    
    x1 = cx - w*0.8
    x2 = cx + w*0.8
    
    ax = (px - x1).abs
    ay = (cy - py).abs
    
    bx = (x2 - px).abs
    by = (cy - py).abs
    
    aA = Math.atan(ay.to_f/ax.to_f)*(180/Math::PI)
    bA = Math.atan(by.to_f/bx.to_f)*(180/Math::PI)
    
    c = (180 - aA - bA)/2
    d = (180 - bA - c)
    
    @sprites["comet"].x = px
    @sprites["comet"].y = py
    @sprites["comet"].angle = d - 90
    ############
    if @currentFrame == @totalFrames
      self.restart if RESTART_TITLE
    end
  end
                    
  def restart
    pbBGMStop(1)
    @viewport.color = Color.new(0,0,0,0)
    51.times do
      @viewport.color.alpha+=5
      self.update
      wait(1)
    end
    self.dispose(false)
    raise Reset.new
  end
  
  def dispose(fade=true)
    pbFadeOutAndHide(@sprites) if fade
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    @disposed=true
  end
  
  def disposed?
    return @disposed
  end
  
  def wait(frames,advance=true)
    return false if @skip
    frames.times do
      @currentFrame+=1 if advance
      Graphics.update
      Input.update
      @skip = true if Input.trigger?(Input::C)
    end
    return true
  end
  
end
#===============================================================================
# Completely custom Title Screen style
#===============================================================================
class GenCustomStyle
  def initialize
    # decides whether or not to show another layer of the title screen
    @showPoke = true
    # sound file for playing the title screen BGM
    bgm = GEN_CUSTOM_BGM
    str = "Audio/BGM/"+pbResolveAudioFile(bgm).name
    @mp3 = (File.extname(str)==".ogg") ? true : false
    @skip = false
    @disposed = false
    @swapped = false
    @particles = 16
    @speed = 15
    @opacity = 15
    @pframe = [0,0,0,0,0]
    @speed = 3
    @effo = 1
    @moX = 0 
    @moY = 0
    @logoY = 0
    
    @currentFrame = 0
    # calculates after how many frames the game will reset
    @totalFrames=getPlayTime(str).to_i*Graphics.frame_rate
    
    pbBGMPlay(bgm)
    pbWait(30) if @mp3
    @totalFrames-=100 if @mp3
    
    # creates all the necessary graphics
    @viewport = Viewport.new(0,0,Graphics.width,VIEWPORT_HEIGHT)
    @viewport.z = 99999
    @cX = @viewport.rect.height/2
    @cInc = 2
    @sprites = {}
    
    @sprites["background"] = Sprite.new(@viewport)
    @sprites["background"].bitmap = pbBitmap("Graphics/Titles/custom_background")
    @sprites["background"].z = 99
    @sprites["background"].ox = @sprites["background"].bitmap.width/2
    @sprites["background"].oy = @sprites["background"].bitmap.height/2
    @sprites["background"].x = @viewport.rect.width/2
    @sprites["background"].y = @viewport.rect.height/2
    
    @sprites["plane"] = ScrollingSprite.new(@viewport)
    @sprites["plane"].setBitmap("Graphics/Titles/custom_plane")
    @sprites["plane"].speed = 1
    
    @sprites["black"] = Sprite.new(@viewport)
    @sprites["black"].bitmap = Bitmap.new(@viewport.rect.width,@viewport.rect.height)
    @sprites["black"].bitmap.fill_rect(0,0,@sprites["black"].bitmap.width,@sprites["black"].bitmap.height,Color.new(0,0,0))
    @sprites["black"].z = 99999
    
    @sprites["bars"] = Sprite.new(@viewport)
    @sprites["bars"].bitmap = pbBitmap("Graphics/Titles/custom_bars")
    @sprites["bars"].z = 99999
    @sprites["bars"].x = @viewport.rect.width
    @sprites["bars"].src_rect.height = @viewport.rect.height/2
    
    @sprites["bars2"] = Sprite.new(@viewport)
    @sprites["bars2"].bitmap = pbBitmap("Graphics/Titles/custom_bars")
    @sprites["bars2"].z = 99999
    @sprites["bars2"].x = -@viewport.rect.width
    @sprites["bars2"].y = @viewport.rect.height/2
    @sprites["bars2"].src_rect.y = @viewport.rect.height/2
    
    @sprites["start"] = Sprite.new(@viewport)
    @sprites["start"].bitmap = pbBitmap("Graphics/Titles/pokestart")
    @sprites["start"].ox = @sprites["start"].bitmap.width/2
    @sprites["start"].x = @viewport.rect.width/2
    @sprites["start"].oy = @sprites["start"].bitmap.height/2
    @sprites["start"].y = @viewport.rect.height - 16
    @sprites["start"].opacity = 0
    @sprites["start"].z = 99999
    
    @sprites["effect1"] = Sprite.new(@viewport)
    @sprites["effect1"].bitmap = pbBitmap("Graphics/Titles/custom_effect")
    @sprites["effect1"].ox = @sprites["effect1"].bitmap.width/2
    @sprites["effect1"].oy = @sprites["effect1"].bitmap.height/2
    @sprites["effect1"].x = @viewport.rect.width/2
    @sprites["effect1"].y = @viewport.rect.height/2 + 102
    
    @sprites["effect2"] = Sprite.new(@viewport)
    @sprites["effect2"].bitmap = pbBitmap("Graphics/Titles/gen_6_shine")
    @sprites["effect2"].ox = @sprites["effect2"].bitmap.width/2
    @sprites["effect2"].oy = @sprites["effect2"].bitmap.height/2
    @sprites["effect2"].x = @viewport.rect.width/2
    @sprites["effect2"].y = @viewport.rect.height/2 + 102
    
    for i in 0...@particles
      @sprites["p#{i}"] = AnimatedSpriteParticle.new(@viewport,rand(@particles))
      @sprites["p#{i}"].dy = @viewport.rect.height/(2) + 102
      @sprites["p#{i}"].inverted = false
      @sprites["p#{i}"].refresh
    end
    
    @sprites["effect3"] = Sprite.new(@viewport)
    @sprites["effect3"].bitmap = pbBitmap("Graphics/Titles/gen_6_effect2")
    @sprites["effect3"].ox = @sprites["effect3"].bitmap.width/2
    @sprites["effect3"].oy = @sprites["effect3"].bitmap.height/2
    @sprites["effect3"].x = @viewport.rect.width/2
    @sprites["effect3"].y = @viewport.rect.height/2 + 102
    
    @sprites["clouds2"] = Sprite.new(@viewport)
    @sprites["clouds2"].bitmap = pbBitmap("Graphics/Titles/custom_clouds_2")
    @sprites["clouds2"].ox = @sprites["clouds2"].bitmap.width/2
    @sprites["clouds2"].x = @viewport.rect.width/2
    @sprites["clouds2"].oy = @sprites["clouds2"].bitmap.height/2
    @sprites["clouds2"].y = @viewport.rect.height/2
    
    @sprites["clouds1"] = Sprite.new(@viewport)
    @sprites["clouds1"].bitmap = pbBitmap("Graphics/Titles/custom_clouds_1")
    @sprites["clouds1"].ox = @sprites["clouds2"].bitmap.width/2
    @sprites["clouds1"].x = @viewport.rect.width/2
    @sprites["clouds1"].oy = @sprites["clouds1"].bitmap.height/2
    @sprites["clouds1"].y = @viewport.rect.height/2
    
    @sprites["logo2"] = Sprite.new(@viewport)
    @sprites["logo2"].bitmap = pbBitmap("Graphics/Titles/pokelogo2")
    @sprites["logo2"].z = 99999
    @sprites["logo2"].opacity = 0
    @sprites["logo2"].ox = @sprites["logo2"].bitmap.width/2
    @sprites["logo2"].oy = @sprites["logo2"].bitmap.height/2
    @sprites["logo2"].x = @viewport.rect.width/2
    @sprites["logo2"].y = @viewport.rect.height/2 - 64
    
    @sprites["logo"] = Sprite.new(@viewport)
    @sprites["logo"].bitmap = pbBitmap("Graphics/Titles/custom_pokelogo")
    @sprites["logo"].z = 99999
    @sprites["logo"].ox = @sprites["logo"].bitmap.width/2
    @sprites["logo"].oy = @sprites["logo"].bitmap.height/2
    @sprites["logo"].x = @viewport.rect.width/2
    @sprites["logo"].y = @viewport.rect.height/2
    
    @sprites["shine1"] = Sprite.new(@viewport)
    @sprites["shine1"].bitmap = pbBitmap("Graphics/Titles/custom_pokelogo_shine")
    @sprites["shine1"].z = 99999
    @sprites["shine1"].ox = @sprites["shine1"].bitmap.width/2
    @sprites["shine1"].oy = @sprites["shine1"].bitmap.height/2
    @sprites["shine1"].x = @viewport.rect.width/2 - 32
    @sprites["shine1"].y = @viewport.rect.height/2
    @sprites["shine1"].visible = false
    @sprites["shine1"].src_rect.set(-32,0,32,@sprites["shine1"].bitmap.height)
    @sprites["shine1"].opacity = 128
    
    @sprites["shine2"] = Sprite.new(@viewport)
    @sprites["shine2"].bitmap = pbBitmap("Graphics/Titles/custom_bars_shine")
    @sprites["shine2"].z = 99999
    @sprites["shine2"].x = -32
    @sprites["shine2"].visible = false
    @sprites["shine2"].src_rect.set(-32,0,32,@sprites["shine2"].bitmap.height)
  end
  
  def intro
    @sprites["logo"].src_rect.set(0,@sprites["logo"].bitmap.height,@sprites["logo"].bitmap.width,32)
    @sprites["logo"].y+=@sprites["logo"].bitmap.height
    wait(16)
    36.times do
      @sprites["logo"].src_rect.y-=8
      @sprites["logo"].y-=8
      wait(1)
    end
    @sprites["logo"].y = @viewport.rect.height/2
    @sprites["logo"].src_rect.set(0,0,@sprites["logo"].bitmap.width,@sprites["logo"].bitmap.height)
    @sprites["logo"].opacity = 0
    wait(16)
    32.times do
      @sprites["bars"].x-=32
      @sprites["bars2"].x+=32
      wait(1)
    end
    @sprites["bars"].x = 0
    @sprites["bars"].opacity = 0
    @sprites["bars"].src_rect.height = @sprites["bars"].bitmap.height
    @sprites["bars2"].dispose
    wait(16)
    51.times do
      @sprites["bars"].opacity+=5
      @sprites["logo"].opacity+=5
      self.update
      @sprites["start"].opacity = 0
      wait(1)
    end
    16.times do
      self.update
      @sprites["start"].opacity = 0
      wait(1)
    end
    47.times do
      @sprites["black"].opacity-=2
      self.update
      @sprites["start"].opacity = 0
      wait(1)
    end
    @viewport.color = Color.new(255,255,255)
    @sprites["black"].opacity = 0
    @sprites["background"].z = -1
    @sprites["logo"].bitmap = pbBitmap("Graphics/Titles/pokelogo")
    16.times do
      @viewport.color.alpha-=255/16.0
      self.update
      @sprites["start"].opacity = 0
      wait(1)
    end
    16.times do
      self.update
      @sprites["start"].opacity = 0
      wait(1)
    end
    32.times do
      @logoY+=1
      @sprites["logo2"].opacity+=255/32.0
      self.update
      @sprites["start"].opacity = 0
      wait(1)
    end
    @sprites["shine1"].visible = true
    @sprites["shine2"].visible = true
  end
  
  def update(circle=EXPAND_STYLE)
    @sprites["start"].opacity+=@opacity
    @opacity=-15 if @sprites["start"].opacity>=255
    @opacity=+15 if @sprites["start"].opacity<=0
    @sprites["effect1"].angle+=1 if $ResizeFactor <= 1
    @sprites["effect3"].angle+=0.2 if $ResizeFactor <= 1
    @sprites["effect3"].opacity-=@effo
    if @sprites["effect3"].opacity < 32
      @effo = -1
    elsif @sprites["effect3"].opacity >= 255
      @effo = 1
    end
    @sprites["effect2"].angle-=1 if $ResizeFactor <= 1
    for i in 0...@particles
      @sprites["p#{i}"].update
    end
    @sprites["plane"].update
    
    @currentFrame+=1 if !@skip
    if @currentFrame==@totalFrames
      self.restart if RESTART_TITLE
    end
    
    if defined?($mouse) && circle
      mouseX = ($mouse.x < 0) ? @viewport.rect.width/2 : $mouse.x
      mouseY = ($mouse.y < 0) ? @viewport.rect.height/2 : $mouse.y
      mouseX = @viewport.rect.width if mouseX > @viewport.rect.width
      mouseY = @viewport.rect.height if mouseY > @viewport.rect.height
    else
      mouseX, mouseY = getCircleCoordinates
    end
    
    if circle
      @moY = ((@viewport.rect.height/2.0) - mouseY)/@viewport.rect.height/2.0
      @moX = ((@viewport.rect.width/2.0) - mouseX)/@viewport.rect.width/2.0
    else
      @moY = 0
      @moX = 0
    end
    
    @sprites["clouds2"].x = @viewport.rect.width/2 - @moX*24
    @sprites["clouds2"].y = @viewport.rect.height/2 - @moY*16
    @sprites["clouds1"].x = @viewport.rect.width/2 - @moX*36
    @sprites["clouds1"].y = @viewport.rect.height/2 - @moY*24
      
    @sprites["effect2"].x = @viewport.rect.width/2 - @moX*18
    @sprites["effect2"].y = @viewport.rect.height/2 + 102 - @moY*12
    
    @sprites["effect3"].x = @viewport.rect.width/2 - @moX*32
    @sprites["effect3"].y = @viewport.rect.height/2 + 102 - @moY*24
    
    @sprites["logo"].x = @viewport.rect.width/2 - @moX*48
    @sprites["logo"].y = @viewport.rect.width/2 - @logoY - 48 - @moY*32
    @sprites["logo2"].x = @sprites["logo"].x
    @sprites["logo2"].y = @sprites["logo"].y - 64 + @logoY*2
    
    @sprites["shine1"].src_rect.x+=8
    @sprites["shine1"].x = @sprites["logo"].x + @sprites["shine1"].src_rect.x
    @sprites["shine1"].y = @sprites["logo"].y
    @sprites["shine2"].src_rect.x+=8
    @sprites["shine2"].x+=8
    if @sprites["shine2"].x > @viewport.rect.width*6
      @sprites["shine1"].src_rect.x = -32
      @sprites["shine1"].x = @sprites["logo"].x - 32
      @sprites["shine2"].src_rect.x = -32
      @sprites["shine2"].x = -32
    end
      
  end
  
  def getCircleCoordinates
    height = @viewport.rect.height
    width = height
    offset = (@viewport.rect.width - @viewport.rect.height)/2
    x = @cX
    r = width/2
    # basic circle formula
    # (x - tx)**2 + (y - ty)**2 = r**2
    y1 = -Math.sqrt(r**2 - (x - width/2)**2).to_i
    y2 =  Math.sqrt(r**2 - (x - width/2)**2).to_i
    @cX+=@cInc
    @cInc = -2 if @cX >= width
    @cInc = +2 if @cX <= 0
    return (x + offset), (@cInc > 0 ? y1 : y2) + height/2
  end
                  
  def restart
    pbBGMStop(1)
    @viewport.color = Color.new(0,0,0,0)
    51.times do
      @viewport.color.alpha+=5
      self.update
      wait(1)
    end
    self.dispose(false)
    raise Reset.new
  end
  
  def dispose(fade=true)
    pbFadeOutAndHide(@sprites) if fade
    pbDisposeSpriteHash(@sprites)
    @disposed=true
  end
  
  def disposed?
    return @disposed
  end
  
  def wait(frames,advance=true)
    return false if @skip
    frames.times do
      @currentFrame+=1 if advance
      Graphics.update
      Input.update
      @skip=true if Input.trigger?(Input::C)
    end
    return true
  end
  
end
#===============================================================================
#  Default Essentials one
#===============================================================================
class EssentialsTitleScreen
  def initialize
    @skip = false
    @currentFrame = 0
    # calculates after how many frames the game will reset
    #@totalFrames=getPlayTime("Audio/BGM/#{bgm}")*Graphics.frame_rate
    @totalFrames = 90*Graphics.frame_rate
    @timer = 0
    
    @sprites = {}
    @sprites["pic"] = Sprite.new
    @sprites["pic"].bitmap = pbBitmap("Graphics/Titles/splash.png")
    
    @sprites["pic2"] = Sprite.new
    @sprites["pic2"].bitmap = pbBitmap("Graphics/Titles/start")
    @sprites["pic2"].y = 322
    
    data_system = pbLoadRxData("Data/System")
    pbBGMPlay(data_system.title_bgm)
  end

  def intro
    pbFadeInAndShow(@sprites)
  end

  def update
    @timer+=1
    @timer=0 if @timer>=80
    if @timer>=32
      @sprites["pic2"].opacity = 8*(@timer-32)
    else
      @sprites["pic2"].opacity = 255-(8*@timer)
    end
    if @currentFrame>=@totalFrames
      raise Reset.new if RESTART_TITLE
    end
  end
  
  def dispose(fade=true)
    pbFadeOutAndHide(@sprites) if fade
    pbDisposeSpriteHash(@sprites)
    @disposed=true
  end
  
  def disposed?
    return @disposed
  end
  
  def wait(frames)
    return if @skip
    frames.times do
      @currentFrame+=1
      Graphics.update
      Input.update
      @skip=true if Input.trigger?(Input::C)
    end
  end

end
#-------------------------------------------------------------------------------
#  Gen 5 Title Screen Pokemon sprite
#-------------------------------------------------------------------------------
class AnimatedPokemonSprite < Sprite
  def setBitmap(pokemon,back=false)                                          
    @bitmap = pbLoadPokemonBitmap(pokemon,back)                              
    self.bitmap = @bitmap.bitmap.clone
    self.ox = self.bitmap.width/2
    self.oy = self.bitmap.height
    metrics=load_data("Data/metrics.dat")
    self.oy+=metrics[2][pokemon.species]
    self.oy-=metrics[1][pokemon.species]
  end
  
  def animatedBitmap; return @bitmap; end
  def width; return @bitmap.width; end
  def height; return @bitmap.height; end
  
  def update
    @bitmap.update
    self.bitmap = @bitmap.bitmap.clone
  end
end
#-------------------------------------------------------------------------------
#  Gen 6 Title Screen particles
#-------------------------------------------------------------------------------
class AnimatedSpriteParticle < Sprite
  attr_accessor :inverted
  attr_accessor :repeat
  attr_accessor :count
  attr_accessor :dy
  attr_accessor :dx
  def initialize(viewport,delay=0)
    @dx = viewport.rect.width/2
    @dy = viewport.rect.height/4
    @repeat = -1
    @count = 0
    super(viewport)
    @inverted = true
    self.refresh
    @delay = delay
    @frame = 0
    self.visible = false
  end
  
  def update
    return if @repeat > 0 && @count > @repeat
    @frame+=1
    return if @frame < @delay
    self.visible = true
    @px-= @inverted ? (@px-@pos[0])*(0.002*@speed) : (@pos[0]-@px)*(0.002*@speed)
    @py-= @inverted ? (@py-@pos[1])*(0.002*@speed) : (@pos[1]-@py)*(0.002*@speed)
    self.x = @px
    self.y = @py
    s = @inverted ? 0.5 : 1
    self.opacity-=0.5*@speed*s
    self.refresh if self.opacity <= 0
  end
  
  def refresh
    self.opacity = 255
    self.x = @dx
    self.y = @dy
    x = rand(@dx*2 + 32*4)-32*2
    y = rand(@dy*2 + 32*4)-32*2
    x1 = rand(2)<1 ? -rand(32) : @dx*2+rand(32)
    y1 = @dy-46+rand(92)
    @pos = [
      @inverted ? @dx : x,
      @inverted ? @dy : y
    ]
    @px = @inverted ? x1 : @dx
    @py = @inverted ? y1 : @dy
    @speed = (rand(16)+1)*0.5
    @speed*=4 if @inverted
    if rand(2) < 1
      self.bitmap = pbBitmap("Graphics/Titles/gen_6_particle2")
    else
      self.bitmap = pbBitmap("Graphics/Titles/gen_6_particle")
    end
    self.ox = self.bitmap.width/2
    self.oy = self.bitmap.height/2
    @count+=1 if @repeat > 0
  end
end
#-------------------------------------------------------------------------------
#  Gen 6 EB demo
#-------------------------------------------------------------------------------
# If the Elite Battle system is detected, the game will play a little demo of it
# after the title screen finishes playing.
class PlayEBDemo
  
  def initialize(bgm=EB_DEMO_BGM)
    @viewport = {}
    $Trainer = PokeBattle_Trainer.new("",0)
    
    @skip = false
    @files = readDirectoryFiles("Graphics/Titles/Extra/",["*.png"]).sort_by { |x| x[/\d+/].to_i }
    return if @files.length<7
    pbBGMPlay(bgm)
    
    @sprites = {}
    @viewport["2"] = Viewport.new(0,0,Graphics.width,VIEWPORT_HEIGHT)
    @viewport["2"].tone = Tone.new(-255,-255,-255)
    @ballframe = 0
    @sprites["pokeball"]=Sprite.new(@viewport["2"])
    @sprites["pokeball"].bitmap=BitmapCache.load_bitmap("#{checkEBFolderPath}/pokeballs")
    @sprites["pokeball"].src_rect.set(0,@ballframe*40,41,40)
    @sprites["pokeball"].ox=20
    @sprites["pokeball"].oy=20
    @sprites["pokeball"].zoom_x = 1.5
    @sprites["pokeball"].zoom_y = 1.5
    @sprites["pokeball"].z = 20
    @sprites["pokeball"].x = @viewport["2"].rect.width/2
    @sprites["pokeball"].y = @viewport["2"].rect.height*0.6-128
    for i in 1..3
      y = [-VIEWPORT_HEIGHT,0,VIEWPORT_HEIGHT]
      @viewport["#{i}"] = Viewport.new((Graphics.width/3+5)*(i-1),y[i-1],Graphics.width/3-8,VIEWPORT_HEIGHT) if i!=2
      @viewport["#{i}"].z = 1 if i!=2
      pkmn = PokeBattle_Pokemon.new(EB_SPECIES[i-1],5)
      
      @sprites["bg#{i}"] = Sprite.new(@viewport["#{i}"])
      @sprites["bg#{i}"].bitmap = Bitmap.new(@viewport["#{i}"].rect.width,@viewport["#{i}"].rect.height-24)
      bmp = pbBitmap("Graphics/Battlebacks/battlebg#{EB_BG[i-1]}")
      @sprites["bg#{i}"].bitmap.stretch_blt(Rect.new(0,0,@viewport["#{i}"].rect.width,@viewport["#{i}"].rect.height),bmp,Rect.new(bmp.width/4,bmp.height/4,bmp.width/2,bmp.height/2))
      @sprites["bg#{i}"].ox = @sprites["bg#{i}"].bitmap.width/2
      @sprites["bg#{i}"].oy = @sprites["bg#{i}"].bitmap.height/2
      @sprites["bg#{i}"].x = @viewport["#{i}"].rect.width/2
      @sprites["bg#{i}"].y = @viewport["#{i}"].rect.height/2
      
      @sprites["base#{i}"] = Sprite.new(@viewport["#{i}"])
      @sprites["base#{i}"].bitmap = pbBitmap("Graphics/Battlebacks/enemybase#{EB_BASE[i-1]}")
      @sprites["base#{i}"].ox = @sprites["base#{i}"].bitmap.width/2
      @sprites["base#{i}"].oy = @sprites["base#{i}"].bitmap.height/2
      @sprites["base#{i}"].x = @viewport["#{i}"].rect.width/2
      @sprites["base#{i}"].y = @viewport["#{i}"].rect.height*0.6
      @sprites["base#{i}"].zoom_x = 1.5
      @sprites["base#{i}"].zoom_y = 1.5
      
      @sprites["pokemon#{i}"]=DynamicPokemonSprite.new(false,0,@viewport["#{i}"])
      @sprites["pokemon#{i}"].setPokemonBitmap(pkmn,false)
      @sprites["pokemon#{i}"].mirror = true
      @sprites["pokemon#{i}"].x = @sprites["base#{i}"].x
      @sprites["pokemon#{i}"].y = @sprites["base#{i}"].y
      @sprites["pokemon#{i}"].zoom_x = 1.5
      @sprites["pokemon#{i}"].zoom_y = 1.5
    end
    @viewport["3"].rect.height = 0
    @oy = @sprites["pokemon2"].oy
    @sprites["pokemon2"].oy = @sprites["pokemon2"].bitmap.width/2
    @sprites["pokemon2"].y-=128+@sprites["pokemon2"].oy/2
    @sprites["pokemon2"].zoom_x = 0
    @sprites["pokemon2"].zoom_y = 0
    @sprites["pokemon2"].tone = Tone.new(255,255,255)
    @sprites["pokemon2"].showshadow = false
    
    self.play
    @viewport.dispose
    self.dispose
  end
  
  def play
    15.times do
      @viewport["2"].tone.red+=17
      @viewport["2"].tone.green+=17
      @viewport["2"].tone.blue+=17
      @sprites["pokeball"].src_rect.set(0,@ballframe*40,41,40)
      wait(1)
    end
    wait(1)
    8.times do
      @sprites["pokeball"].src_rect.set(0,@ballframe*40,41,40)
      wait(1)
    end
    @sprites["pokeball"].visible=false
    8.times do
      @sprites["pokemon2"].zoom_x+=0.125*1.5
      @sprites["pokemon2"].zoom_y+=0.125*1.5
      wait(1)
    end
    8.times do
      @sprites["pokemon2"].tone.red-=32
      @sprites["pokemon2"].tone.green-=32
      @sprites["pokemon2"].tone.blue-=32
      wait(1)
    end
    @sprites["pokemon2"].y+=@sprites["pokemon2"].oy/2
    @sprites["pokemon2"].oy = @oy
    8.times do
      @sprites["pokemon2"].y+=16
      wait(1)
    end
    @sprites["pokemon2"].showshadow = true
    4.times do
      @viewport["2"].rect.y+=2
      wait(1)
    end
    4.times do
      @viewport["2"].rect.y-=2
      wait(1)
    end
    wait(8)
    8.times do
      @viewport["2"].rect.x+=22
      @viewport["2"].rect.width-=44
      @sprites["bg2"].x = @viewport["2"].rect.width/2
      @sprites["base2"].x = @viewport["2"].rect.width/2
      @sprites["pokemon2"].x = @sprites["base2"].x
      wait(1)
    end
    wait(16)
    8.times do
      @viewport["1"].rect.y+=48
      wait(1)
    end
    wait(16)
    8.times do
      @viewport["3"].rect.y-=48
      @viewport["3"].rect.height+=48
      wait(1)
    end
    wait(24)
    16.times do
      @viewport["1"].rect.y-=24
      @viewport["2"].rect.y+=24
      @viewport["2"].rect.height-=24
      @viewport["3"].rect.y-=24
      wait(1)
    end
    self.dispose
    wait(8)
    @viewport = Viewport.new(0,0,Graphics.width,VIEWPORT_HEIGHT)
    for i in 0..1
      pbDisposeSpriteHash(@sprites)
      f = [1,-1][i]
      @viewport.tone = Tone.new(255,255,255)
      @sprites["#{i}"] = Sprite.new(@viewport)
      @sprites["#{i}"].bitmap = pbBitmap("Graphics/Titles/Extra/#{@files[i]}")
      @sprites["#{i}"].ox = @sprites["#{i}"].bitmap.width/2
      @sprites["#{i}"].oy = @sprites["#{i}"].bitmap.height/2
      @sprites["#{i}"].x = @viewport.rect.width/2
      @sprites["#{i}"].y = @viewport.rect.height/2
      @sprites["#{i}"].angle=-4*f
      51.times do
        @viewport.tone.red-=10 if @viewport.tone.red>0
        @viewport.tone.green-=10 if @viewport.tone.green>0
        @viewport.tone.blue-=10 if @viewport.tone.blue>0
        @sprites["#{i}"].angle+=0.1*f
        
        wait(1)
      end
    end
    pbDisposeSpriteHash(@sprites)
    for i in 2..5
      @sprites["#{i}"] = Sprite.new(@viewport)
      @sprites["#{i}"].bitmap = pbBitmap("Graphics/Titles/Extra/#{@files[i]}")
      @sprites["#{i}"].ox = @sprites["#{i}"].bitmap.width/2
      @sprites["#{i}"].oy = @sprites["#{i}"].bitmap.height/2
      @sprites["#{i}"].x = -@viewport.rect.width/2
      @sprites["#{i}"].y = @viewport.rect.height/2
      16.times do
        @sprites["#{i}"].x+=32
        if i>2
          @sprites["#{i-1}"].opacity-=16
        end
        wait(1)
      end
      wait(8)
    end
    wait(8)
    pbDisposeSpriteHash(@sprites)
    for i in 6..6
      @viewport.tone = Tone.new(255,255,255)
      @sprites["#{i}"] = Sprite.new(@viewport)
      @sprites["#{i}"].bitmap = pbBitmap("Graphics/Titles/Extra/#{@files[i]}")
      @sprites["#{i}"].ox = @sprites["#{i}"].bitmap.width/2
      @sprites["#{i}"].oy = @sprites["#{i}"].bitmap.height/2
      @sprites["#{i}"].x = @viewport.rect.width/2
      @sprites["#{i}"].y = @viewport.rect.height/2
      51.times do
        @viewport.tone.red-=5
        @viewport.tone.green-=5
        @viewport.tone.blue-=5
        wait(1)
      end
    end
    wait(12)
    pbDisposeSpriteHash(@sprites)
    wait(40)
    pbBGMStop(1.0)
    wait(20)
  end
  
  def dispose
    pbDisposeSpriteHash(@sprites)
    pbDisposeSpriteHash(@viewport) if @viewport.is_a?(Hash)
  end
  
  def wait(frames)
    return false if @skip
    frames.times do
      Graphics.update
      Input.update
      for i in 1..3
        @sprites["pokemon#{i}"].update if @sprites["pokemon#{i}"]
      end
      @ballframe+=1
      @ballframe=0 if @ballframe > 7
      @skip=true if Input.trigger?(Input::C)
    end
    return true
  end
  
end
#-------------------------------------------------------------------------------
#  Custom credits scene
#  creates an animated Panorama with a running trainer sprite
#-------------------------------------------------------------------------------
if defined?(CUSTOM_CREDITS) && CUSTOM_CREDITS
class Scene_Credits
  
  def main; end
 
  def initialize
    @pframe = [0,0,0,0,0]
    @speed = 3
    @cpeed = 1
    @viewport1 = Viewport.new(0,VIEWPORT_HEIGHT,Graphics.width,VIEWPORT_HEIGHT)
    @viewport1.z = 99999
    @viewport2 = Viewport.new(0,0,Graphics.width,VIEWPORT_HEIGHT*2)
    @viewport2.z = 99999
    @viewport3 = Viewport.new(0,0,Graphics.width,VIEWPORT_HEIGHT)
    @viewport3.z = 99999
    @viewport3.color = Color.new(0,0,0,0)
    16.times do
      @viewport3.color.alpha += 16
      pbWait(1)
    end
    $scene = self
    @sprites = {}
    credits = CREDIT.split(/\n/)
    
    @sprites["credits"] = Sprite.new(@viewport1)
    @sprites["credits"].bitmap = Bitmap.new(Graphics.width,32 * credits.length)
    @sprites["credits"].z = 99
    @sprites["credits"].y = VIEWPORT_HEIGHT
    pbSetSystemFont(@sprites["credits"].bitmap)
    gw = Graphics.width*0.8
    ox = (Graphics.width-gw)/2
    
    for i in 0...credits.length
      c = credits[i]
      if c.include?("<s>")
        n = c.split("<s>")
        width = gw/n.length
        for s in n
          pbDrawOutlineText(@sprites["credits"].bitmap,ox+width*n.index(s),i*32,width,32,s,CREDITS_FILL,CREDITS_OUTLINE,1)
        end
      else
        pbDrawOutlineText(@sprites["credits"].bitmap,ox,i*32,gw,32,c,CREDITS_FILL,CREDITS_OUTLINE,1)
      end
    end
    
    self.compileLogo
    self.drawSky
    self.drawPanorama
    @sprites["trainer"] = Sprite.new(@viewport1)
    @sprites["trainer"].bitmap = pbBitmap(self.getTrainer)
    @sprites["trainer"].src_rect.set(0,0,@sprites["trainer"].bitmap.height,@sprites["trainer"].bitmap.width/6)
    @sprites["trainer"].z = 99999
    @sprites["trainer"].ox = @sprites["trainer"].src_rect.width/2
    @sprites["trainer"].oy = @sprites["trainer"].src_rect.height
    @sprites["trainer"].x = Graphics.width*0.75
    @sprites["trainer"].y = VIEWPORT_HEIGHT - 12
    #Stops all audio but background music.
    self.stopAudio
    20.times do
      @viewport3.color.alpha -= 16
      Graphics.update
    end
    self.flareAnimation
    loop do
      Graphics.update
      Input.update
      @cpeed = Input.press?(Input::C) ? 0 : 1
      self.update
      break if @sprites["credits"].y <= -@sprites["credits"].bitmap.height
    end
    pbBGMFade(3.0)
    for i in 0...128
      @sprites["blank"].opacity += 16
      @sprites["trainer"].x -= 2
      @sprites["trainer"].opacity -= 4 if i >= 64
      self.update
      Graphics.update
    end
    $PokemonGlobal.creditsPlayed=true
    pbDisposeSpriteHash(@sprites)
    @viewport1.dispose
    @viewport2.dispose
    @viewport3.dispose
    pbBGMPlay(@previousBGM)
  end

  def stopAudio
    @previousBGM = $game_system.getPlayingBGM
    pbMEStop()
    pbBGSStop()
    pbSEStop()
    pbBGMFade(2.0)
    pbBGMPlay(CREDITS_BGM)
  end
  
  def last?
  end

  def update
    self.updatePanorama
  end
    
  def drawSky
    @sprites["rect1"] = Sprite.new(@viewport3)
    @sprites["rect1"].bitmap = Bitmap.new(Graphics.width,VIEWPORT_HEIGHT/2)
    @sprites["rect1"].bitmap.fill_rect(0,0,@sprites["rect1"].bitmap.width,@sprites["rect1"].bitmap.height,Color.new(0,0,0))
    @sprites["rect2"] = Sprite.new(@viewport3)
    @sprites["rect2"].bitmap = Bitmap.new(Graphics.width,VIEWPORT_HEIGHT/2)
    @sprites["rect2"].bitmap.fill_rect(0,0,@sprites["rect2"].bitmap.width,@sprites["rect2"].bitmap.height,Color.new(0,0,0))
    @sprites["rect2"].y = VIEWPORT_HEIGHT/2
    @sprites["sky"] = Sprite.new(@viewport2)
    @sprites["sky"].bitmap = pbBitmap("graphics/Titles/Panorama/background_sky")
    @sprites["sun2"] = Sprite.new(@viewport2)
    @sprites["sun2"].bitmap = pbBitmap("Graphics/Titles/Panorama/sun2")
    @sprites["sun2"].ox = @sprites["sun2"].bitmap.width/2
    @sprites["sun2"].oy = @sprites["sun2"].bitmap.height/2
    @sprites["sun2"].x = Graphics.width/2
    @sprites["sun2"].y = VIEWPORT_HEIGHT/2
    @sprites["sun1"] = Sprite.new(@viewport2)
    @sprites["sun1"].bitmap = pbBitmap("Graphics/Titles/Panorama/sun1")
    @sprites["sun1"].ox = @sprites["sun1"].bitmap.width/2
    @sprites["sun1"].oy = @sprites["sun1"].bitmap.height/2
    @sprites["sun1"].x = Graphics.width/2
    @sprites["sun1"].y = VIEWPORT_HEIGHT/2
  end
  
  def updateSky
    @sprites["sun2"].angle += 1 if $PokemonSystem.screensize < 2
    @sprites["sun1"].angle -= 1 if $PokemonSystem.screensize < 2
  end
  
  def flareAnimation
    @flare = {}
    for i in 0...6
      @flare["#{i}"] = Sprite.new(@viewport3)
      @flare["#{i}"].z = 99
      @flare["#{i}"].bitmap = pbBitmap("Graphics/Titles/Panorama/flare#{i+1}")
      @flare["#{i}"].ox = @flare["#{i}"].bitmap.width/2
      @flare["#{i}"].oy = @flare["#{i}"].bitmap.height/2
      @flare["#{i}"].x = Graphics.width/2
      @flare["#{i}"].y = VIEWPORT_HEIGHT/2
      @flare["#{i}"].opacity = 0
      @flare["#{i}"].tone = Tone.new(128,128,128)
    end
    for i in 0...60
      @sprites["rect1"].y -= 8
      @sprites["rect2"].y += 8
      @viewport3.color = Color.new(255,255,255) if i == 2
      for j in 0...6
        next if j > i
        @flare["#{j}"].opacity += (i<40) ? 32 : -16
        @flare["#{j}"].x -= (6-j)*(j<5 ? 1 : -1)
        @flare["#{j}"].y += (6-j)*(j<5 ? 1 : -1)
        @flare["#{j}"].tone.red -= 1
        @flare["#{j}"].tone.green -= 1
        @flare["#{j}"].tone.blue -= 1
      end
      @viewport3.color.alpha -= 8 if @viewport3.color.alpha > 0
      Graphics.update
      self.updateSky
    end
    for i in 0...128
      @viewport1.rect.y -= @viewport1.rect.height/128
      @viewport2.rect.y -= @viewport2.rect.height/256
      @viewport3.rect.y -= @viewport3.rect.height/128
      if i >= 64
        @sprites["sun1"].opacity -= 4
        @sprites["sun2"].opacity -= 4
      end
      Graphics.update
      self.updatePanorama
      self.updateSky
    end
  end
  
  def drawPanorama
    @sprites["background"] = Sprite.new(@viewport1)
    @sprites["background"].bitmap = pbBitmap("Graphics/Titles/Panorama/background")
    @sprites["background2"] = Sprite.new(@viewport1)
    @sprites["background2"].bitmap = pbBitmap("Graphics/Titles/Panorama/background_cover")
    @sprites["background2"].z = 999
    @sprites["clouds"] = AnimatedPlane.new(@viewport1)
    @sprites["clouds"].bitmap = pbBitmap("Graphics/Titles/Panorama/clouds")
    @sprites["mountains"] = Sprite.new(@viewport1)
    @sprites["mountains"].bitmap = pbBitmap("Graphics/Titles/Panorama/mountains")
    @sprites["trees3"] = AnimatedPlane.new(@viewport1)
    @sprites["trees3"].bitmap = pbBitmap("Graphics/Titles/Panorama/trees_3")
    @sprites["trees2"] = AnimatedPlane.new(@viewport1)
    @sprites["trees2"].bitmap = pbBitmap("Graphics/Titles/Panorama/trees_2")
    @sprites["trees1"] = AnimatedPlane.new(@viewport1)
    @sprites["trees1"].bitmap = pbBitmap("Graphics/Titles/Panorama/trees_1")    
    @sprites["grass"] = AnimatedPlane.new(@viewport1)
    @sprites["grass"].bitmap = pbBitmap("Graphics/Titles/Panorama/grass")
    @sprites["grass"].z = 999
    @sprites["blank"] = Sprite.new(@viewport1)
    @sprites["blank"].bitmap = Bitmap.new(Graphics.width,VIEWPORT_HEIGHT)
    @sprites["blank"].bitmap.fill_rect(0,0,Graphics.width,VIEWPORT_HEIGHT,Color.new(0,0,0))
    @sprites["blank"].z = 9999
    @sprites["blank"].opacity = 0
  end
  
  def updatePanorama
    for i in 0...@pframe.length
      @pframe[i]+=1
    end
    @sprites["grass"].ox-=4
    @sprites["trees1"].ox-=1
    @sprites["trees2"].ox-=1 if @pframe[0]>1
    @sprites["trees3"].ox-=1 if @pframe[1]>2
    @sprites["clouds"].ox+=1 if @pframe[2]>3
    @sprites["credits"].y -= 1+(1-@cpeed) if @pframe[3]>@cpeed
    
    @sprites["trainer"].src_rect.x += @sprites["trainer"].src_rect.width if @pframe[4]>@speed
    @sprites["trainer"].src_rect.x = 0 if @sprites["trainer"].src_rect.x >= @sprites["trainer"].bitmap.width
    if Input.press?(Input::LEFT)
      @speed = 2
      @sprites["trainer"].x -= 1 if @sprites["trainer"].x > Graphics.width*0.25
    else
      @speed = 3
      @sprites["trainer"].x += 1 if @sprites["trainer"].x < Graphics.width*0.75 && @pframe[3]>1
    end
    
    @pframe[0]=0 if @pframe[0]>1
    @pframe[1]=0 if @pframe[1]>2
    @pframe[2]=0 if @pframe[2]>3
    @pframe[3]=0 if @pframe[3]>@cpeed
    @pframe[4]=0 if @pframe[4]>@speed
  end
  
  def compileLogo
    @sprites["logo"] = Sprite.new(@viewport3)
    @sprites["logo"].z = 999
    @sprites["logo"].bitmap = Bitmap.new(Graphics.width,VIEWPORT_HEIGHT)
    wdh = @sprites["logo"].bitmap.width
    hgh = @sprites["logo"].bitmap.height
    bmp = pbBitmap("Graphics/Titles/pokelogo2")
    @sprites["logo"].bitmap.blt((wdh-bmp.width)/2,(hgh-bmp.height)/2,bmp,Rect.new(0,0,bmp.width,bmp.height))
    bmp = pbBitmap("Graphics/Titles/pokelogo")
    @sprites["logo"].bitmap.blt((wdh-bmp.width)/2,(hgh-bmp.height)/2,bmp,Rect.new(0,0,bmp.width,bmp.height))
  end
  
  def getTrainer(type=$Trainer.trainertype)
    outfit = $Trainer ? $Trainer.outfit : 0
    bitmapFileName = sprintf("Graphics/Titles/Panorama/trainer%s_%d",
       getConstantName(PBTrainers,type),outfit) rescue nil
    if !pbResolveBitmap(bitmapFileName)
      bitmapFileName = sprintf("Graphics/Titles/Panorama/trainer%03d_%d",type,outfit)
      if !pbResolveBitmap(bitmapFileName)
        bitmapFileName = sprintf("Graphics/Titles/Panorama/trainer%03d",type)
      end
    end
    return bitmapFileName
  end
  
end
end
#-------------------------------------------------------------------------------
#  Gen 1 intro before the Title Screen
#-------------------------------------------------------------------------------
class ClassicIntro
  
  def initialize(bgm=CLASSIC_INTRO_BGM)
    @viewport = Viewport.new(0,96,Graphics.width,192)
    @sprites = {}
    @skip = false
    
    pbBGMPlay(bgm)
    
    @sprites["backdrop"] = Sprite.new(@viewport)
    @sprites["backdrop"].bitmap = pbBitmap("Graphics/Titles/Intro/backdrop")
    @sprites["backdrop"].ox = @sprites["backdrop"].bitmap.width/2
    @sprites["backdrop"].oy = @sprites["backdrop"].bitmap.height/2
    @sprites["backdrop"].x = @viewport.rect.width/2
    @sprites["backdrop"].y = @viewport.rect.height/2
    
    @sprites["background"] = Sprite.new(@viewport)
    @sprites["background"].bitmap = pbBitmap("Graphics/Titles/Intro/background")
    @sprites["background"].src_rect.set(0,0,480,192)
    @sprites["background"].ox = @sprites["background"].bitmap.width/6
    @sprites["background"].oy = @sprites["background"].bitmap.height/2
    @sprites["background"].x = @viewport.rect.width/2
    @sprites["background"].y = @viewport.rect.height/2
    
    for i in 0...2*3
      @sprites["background"].src_rect.x = 480*(i%3)
      wait(3)
    end
    @viewport.color = Color.new(255,255,255,0)
    5.times do
      @viewport.color.alpha+=51
      @sprites["backdrop"].zoom_x+=0.1
      @sprites["backdrop"].zoom_y+=0.1
      @sprites["background"].zoom_x+=0.1
      @sprites["background"].zoom_y+=0.1
      wait(1)
    end
    pbDisposeSpriteHash(@sprites)
    
    @sprites["backdrop"] = Sprite.new(@viewport)
    @sprites["backdrop"].bitmap = Bitmap.new(@viewport.rect.width,@viewport.rect.height)
    @sprites["backdrop"].bitmap.fill_rect(0,0,@sprites["backdrop"].bitmap.width,@sprites["backdrop"].bitmap.height,Color.new(255,146,0))
   
    @sprites["panorama"] = AnimatedPlane.new(@viewport)
    @sprites["panorama"].bitmap = pbBitmap("Graphics/Titles/Intro/panorama2")
    
    @sprites["grass1"] = AnimatedPlane.new(@viewport)
    @sprites["grass1"].bitmap = pbBitmap("Graphics/Titles/Intro/grass")
    @sprites["grass1"].z = 9
    
    @sprites["pokemon1"] = Sprite.new(@viewport)
    @sprites["pokemon1"].bitmap = pbBitmap("Graphics/Titles/Intro/pokemon1")
    width1 = @sprites["pokemon1"].bitmap.width/6
    @sprites["pokemon1"].ox = @sprites["pokemon1"].bitmap.width/12
    @sprites["pokemon1"].oy = @sprites["pokemon1"].bitmap.height
    @sprites["pokemon1"].x = @viewport.rect.width*(1.0/3) - 32
    @sprites["pokemon1"].y = @viewport.rect.height
    @sprites["pokemon1"].src_rect.set(0,0,width1,@sprites["pokemon1"].bitmap.height)
    @sprites["pokemon1"].z = 2
    
    @sprites["pokemon2"] = Sprite.new(@viewport)
    @sprites["pokemon2"].bitmap = pbBitmap("Graphics/Titles/Intro/pokemon2")
    width2 = @sprites["pokemon2"].bitmap.width/7
    @sprites["pokemon2"].ox = @sprites["pokemon2"].bitmap.width/14
    @sprites["pokemon2"].oy = @sprites["pokemon2"].bitmap.height
    @sprites["pokemon2"].x = @viewport.rect.width*(2.0/3) + 32
    @sprites["pokemon2"].y = @viewport.rect.height
    @sprites["pokemon2"].src_rect.set(0,0,width2,@sprites["pokemon2"].bitmap.height)
    
    @sprites["grass2"] = Sprite.new(@viewport)
    @sprites["grass2"].bitmap = pbBitmap("Graphics/Titles/Intro/grass2")
    @sprites["grass2"].z = 10
    @sprites["grass2"].oy = @sprites["grass2"].bitmap.height
    @sprites["grass2"].y = @viewport.rect.height
    @sprites["grass2"].x = @viewport.rect.width*1.5
    
    48.times do
      @viewport.color.alpha-=51 if @viewport.color.alpha > 0
      @sprites["panorama"].ox-=2
      @sprites["grass1"].ox+=2
      wait(1)
    end    
    @sprites["panorama"].visible = false
    @sprites["grass1"].visible = false
    @sprites["pokemon1"].src_rect.x = width1*5
    @sprites["pokemon1"].y+=20
    @sprites["pokemon2"].src_rect.x = width2*6
    @sprites["pokemon2"].x = @viewport.rect.width - @sprites["pokemon2"].ox
    for i in 0...48
      @sprites["pokemon1"].y-=1 if i%4==0
      @sprites["pokemon2"].y+=1 if i%4==0
      wait(1)
    end
    @sprites["panorama"].visible = true
    @sprites["panorama"].bitmap = pbBitmap("Graphics/Titles/Intro/panorama1")
    @sprites["pokemon1"].src_rect.x = width1*1
    @sprites["pokemon1"].x = @viewport.rect.width + 92
    @sprites["pokemon2"].src_rect.x = width2*1
    @sprites["pokemon2"].x = -110
    32.times do
      @sprites["panorama"].ox-=8
      @sprites["pokemon1"].x-=14
      @sprites["pokemon2"].x+=16
      @sprites["grass2"].x-=22
      wait(1)
    end
    @sprites["pokemon1"].src_rect.x = width1*2
    16.times do
      @sprites["panorama"].ox-=2
      @sprites["grass2"].x-=6
      wait(1)
    end
    @sprites["pokemon1"].src_rect.x = width1*1
    @sprites["pokemon2"].src_rect.x = width2*2
    @sprites["pokemon2"].y+=4
    4.times do
      @sprites["panorama"].ox-=2
      @sprites["grass2"].x-=6
      wait(1)
    end
    @sprites["pokemon2"].src_rect.x = width2*3
    pbPlayCry(PBSpecies::NIDORINO) if !@skip
    u = false
    for i in 0...32
      u = !u if i%4==0
      @sprites["pokemon1"].src_rect.x = width1*2 if i==23
      @sprites["pokemon2"].y = @viewport.rect.height + 4*(u ? 1 : 0)
      @sprites["panorama"].ox-=1
      @sprites["grass2"].x-=6
      wait(1)
    end    
    @sprites["pokemon1"].src_rect.x = width1*1
    @sprites["pokemon2"].src_rect.x = width2*1
    @sprites["pokemon2"].y+=4
    22.times do
      @sprites["panorama"].ox-=1
      wait(1)
    end   
    @sprites["pokemon1"].src_rect.x = width1*3
    8.times do
      @sprites["pokemon1"].x-=4
      @sprites["panorama"].ox-=1
      wait(1)
    end  
    4.times do
      @sprites["panorama"].ox-=1
      wait(1)
    end 
    @sprites["pokemon2"].src_rect.x = width2*2
    for i in 0...12
      @sprites["pokemon1"].src_rect.x = width1*4 if i==2
      @sprites["pokemon2"].src_rect.x = width2*4 if i==2
      @sprites["pokemon1"].x+=10
      @sprites["pokemon2"].x+=6
      if i >= 6
        @sprites["pokemon2"].y+=4
      else
        @sprites["pokemon2"].y-=4
      end
      @sprites["panorama"].ox-=1
      wait(1)
    end  
    @sprites["pokemon1"].x-=64
    @sprites["pokemon1"].src_rect.x = width1*1
    @sprites["pokemon2"].src_rect.x = width2*2
    for i in 0...8
      @sprites["pokemon2"].src_rect.x = width2*1 if i==2
      @sprites["pokemon2"].x+=2
      @sprites["panorama"].ox-=1
      wait(1)
    end 
    4.times do
      @sprites["panorama"].ox-=1
      @sprites["grass2"].x-=6
      wait(1)
    end 
    @sprites["pokemon2"].src_rect.x = width2*2
    for i in 0...12
      @sprites["pokemon2"].src_rect.x = width2*4 if i==2
      @sprites["pokemon2"].x-=8
      if i >= 6
        @sprites["pokemon2"].y+=4
      else
        @sprites["pokemon2"].y-=4
      end
      @sprites["panorama"].ox-=1
      wait(1)
    end  
    @sprites["pokemon2"].src_rect.x = width2*1
    12.times do
      @sprites["panorama"].ox-=1
      wait(1)
    end 
    @sprites["pokemon2"].src_rect.x = width2*2
    for i in 0...12
      if i < 8
        @sprites["pokemon2"].src_rect.x = width2*4 if i==2
        @sprites["pokemon2"].x+=4
        if i >= 4
          @sprites["pokemon2"].y+=2
        else
          @sprites["pokemon2"].y-=2
        end
      elsif i==8
        @sprites["pokemon2"].src_rect.x = width2*2
      end
      @sprites["panorama"].ox-=1
      wait(1)
    end  
    for i in 0...32
      if i < 8
        @sprites["pokemon2"].src_rect.x = width2*4 if i==2
        @sprites["pokemon2"].x+=4
        if i >= 4
          @sprites["pokemon2"].y+=2
        else
          @sprites["pokemon2"].y-=2
        end
      elsif i==8
        @sprites["pokemon2"].src_rect.x = width2*2
      end
      @sprites["panorama"].ox-=1
      wait(1)
    end  
    u = false
    for i in 0...16
      u = !u if i%4==0
      @sprites["pokemon2"].x+=1*(u ? -1 : 1)
      @sprites["panorama"].ox-=1
      wait(1)
    end 
    16.times do
      @sprites["panorama"].ox-=1
      wait(1)
    end 
    @sprites["pokemon2"].src_rect.x = width2*5
    @sprites["pokemon2"].y+=32
    x = @sprites["pokemon2"].x
    y = @sprites["pokemon2"].y
    for i in 0...68
      x -= (@sprites["pokemon2"].x - (@viewport.rect.width/2 + 40))*0.04
      y -= (@sprites["pokemon2"].y - (@viewport.rect.height - 30))*0.04
      if i >= 32
        @sprites["panorama"].tone.red+=12.8
        @sprites["panorama"].tone.green+=12.8
        @sprites["panorama"].tone.blue+=12.8
      end
      @sprites["pokemon2"].zoom_x+=0.002
      @sprites["pokemon2"].zoom_y+=0.002
      @sprites["pokemon2"].x = x
      @sprites["pokemon2"].y = y
      @sprites["panorama"].ox-=1
      wait(1)
    end
    overlay = Sprite.new(@viewport)
    overlay.z = 99999
    overlay.snapScreen
    overlay.ox = overlay.src_rect.width/2
    overlay.oy = overlay.src_rect.height/2
    overlay.x = @viewport.rect.width/2
    overlay.y = @viewport.rect.height/2
    
    @viewport.color = Color.new(0,0,0,0)
    for i in 0...18
      overlay.zoom_x+=0.1
      overlay.zoom_y+=0.1
      if i >= 8
        @viewport.color.alpha+=25.5
      end
      wait(1)
    end
    @viewport.color = Color.new(0,0,0,255)
    wait(32)
    if @skip
      pbBGMFade(0)
    else
      pbBGMFade(0.5)
    end
    Graphics.update
    overlay.dispose
    self.dispose
  end
  
  def dispose
    pbDisposeSpriteHash(@sprites)
    if @viewport.is_a?(Hash)
      pbDisposeSpriteHash(@viewport) 
    else
      @viewport.dispose
    end
  end
  
  def wait(frames)
    return false if @skip
    frames.times do
      Graphics.update
      Input.update
      @skip=true if Input.trigger?(Input::C)
    end
    return true
  end
  
end