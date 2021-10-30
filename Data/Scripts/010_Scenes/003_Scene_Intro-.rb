class IntroEventScene < EventScene
  TICKS_PER_PIC         = 40   # 20 ticks per second, so 2 seconds
  TICKS_PER_ENTER_FLASH = 40
  FADE_TICKS            = 8

  def initialize(pics,splash,_viewport=nil)
    super(nil)
    @pics   = pics
    @splash = splash
    @pic = addImage(0,0,"")
    @pic.setOpacity(0,0)    # set opacity to 0 after waiting 0 frames
    @pic2 = addImage(0,0,"")   # flashing "Press Enter" picture
    @pic2.setOpacity(0,0)
    @index = 0
    data_system = pbLoadRxData("Data/System")
    pbBGMPlay(data_system.title_bgm)
    openPic(self,nil)
  end

  def openPic(_scene,*args)
    onCTrigger.clear
    @pic.name = "Graphics/Titles/"+@pics[@index]
    # fade to opacity 255 in FADE_TICKS ticks after waiting 0 frames
    @pic.moveOpacity(0,FADE_TICKS,255)
    pictureWait
    @timer = 0                          # reset the timer
    onUpdate.set(method(:picUpdate))    # call picUpdate every frame
    onCTrigger.set(method(:closePic))   # call closePic when C key is pressed
  end

  def closePic(scene,args)
    onUpdate.clear
    onCTrigger.clear
    @pic.moveOpacity(0,FADE_TICKS,0)
    pictureWait
    @index += 1   # Move to the next picture
    if @index>=@pics.length
      openSplash(scene,args)
    else
      openPic(scene,args)
    end
  end

  def picUpdate(scene,args)
    @timer += 1
    if @timer>TICKS_PER_PIC*Graphics.frame_rate/20
      @timer = 0
      closePic(scene,args)   # Close the picture
    end
  end

  def openSplash(_scene,*args)
    onUpdate.clear
    onCTrigger.clear
    @pic.name = "Graphics/Titles/"+@splash
    @pic.moveOpacity(0,FADE_TICKS,255)
    @pic2.name = "Graphics/Titles/start"
    @pic2.setXY(0,0,322)
    @pic2.setVisible(0,true)
    @pic2.moveOpacity(0,FADE_TICKS,255)
    pictureWait
    onUpdate.set(method(:splashUpdate))    # call splashUpdate every frame
    onCTrigger.set(method(:closeSplash))   # call closeSplash when C key is pressed
  end

  def closeSplash(scene,args)
    onCTrigger.clear
    onUpdate.clear
    # Play random cry
    cry=pbResolveAudioSE(pbCryFile(1+rand(PBSpecies.maxValue)))
    pbSEPlay(cry,100,100) if cry
    # Fade out
    @pic.moveOpacity(15,0,0)
    @pic2.moveOpacity(15,0,0)
    pbBGMStop(1.0)
    pictureWait
    scene.dispose # Close the scene
    Graphics.transition(0)
    if File.exists?("Data/LastSave.dat")
      lastsave=pbGetLastPlayed
      lastsave[0]=lastsave[0].to_i
      if lastsave[1].to_s=="true"
        if lastsave[0]==0 || lastsave[0]==1
          savefile=RTP.getSaveFileName("Game_autosave.rxdata")
        else  
          savefile = RTP.getSaveFileName("Game_#{lastsave[0]}_autosave.rxdata")
        end 
      elsif lastsave[0]==0 || lastsave[0]==1
        savefile=RTP.getSaveFileName("Game.rxdata")
      else
        savefile = RTP.getSaveFileName("Game_#{lastsave[0]}.rxdata")
      end
      lastsave[1]=nil if lastsave[1]!="true"
      if safeExists?(savefile)
        sscene=PokemonLoad_Scene.new
        sscreen=PokemonLoadScreen.new(sscene)
        sscreen.pbStartLoadScreen(lastsave[0].to_i,lastsave[1],"Save File #{lastsave[0]}")
      else
        sscene=PokemonLoad_Scene.new
        sscreen=PokemonLoadScreen.new(sscene)
        sscreen.pbStartLoadScreen
      end
    else
      sscene=PokemonLoad_Scene.new
      sscreen=PokemonLoadScreen.new(sscene)
      sscreen.pbStartLoadScreen
    end
  end

  def closeSplashDelete(scene,args)
    onCTrigger.clear
    onUpdate.clear
    # Play random cry
    cry=pbResolveAudioSE(pbCryFile(1+rand(PBSpecies.maxValue)))
    pbSEPlay(cry,100,100) if cry
    # Fade out
    @pic.moveOpacity(15,0,0)
    @pic2.moveOpacity(15,0,0)
    pbBGMStop(1.0)
    pictureWait
    scene.dispose # Close the scene
    Graphics.transition(0)
    if File.exists?("Data/LastSave.dat")
      lastsave=pbGetLastPlayed
      lastsave[0]=lastsave[0].to_i
      if lastsave[1].to_s=="true"
        if lastsave[0]==0 || lastsave[0]==1
          savefile=RTP.getSaveFileName("Game_autosave.rxdata")
        else  
          savefile = RTP.getSaveFileName("Game_#{lastsave[0]}_autosave.rxdata")
        end 
      elsif lastsave[0]==0 || lastsave[0]==1
        savefile=RTP.getSaveFileName("Game.rxdata")
      else
        savefile = RTP.getSaveFileName("Game_#{lastsave[0]}.rxdata")
      end
      lastsave[1]=nil if lastsave[1]!="true"
      if safeExists?(savefile)
        sscene=PokemonLoad_Scene.new
        sscreen=PokemonLoadScreen.new(sscene)
        sscreen.pbStartLoadScreen(lastsave[0].to_i,lastsave[1],"Save File #{lastsave[0]}")
      else
        sscene=PokemonLoad_Scene.new
        sscreen=PokemonLoadScreen.new(sscene)
        sscreen.pbStartLoadScreen
      end
    else
      sscene=PokemonLoad_Scene.new
      sscreen=PokemonLoadScreen.new(sscene)
      sscreen.pbStartLoadScreen
    end
  end


  def splashUpdate(scene,args)
    # Flashing of "Press Enter" picture
    if !@pic2.running?
      @pic2.moveOpacity(TICKS_PER_ENTER_FLASH*2/10,TICKS_PER_ENTER_FLASH*4/10,0)
      @pic2.moveOpacity(TICKS_PER_ENTER_FLASH*6/10,TICKS_PER_ENTER_FLASH*4/10,255)
    end
    if Input.press?(Input::DOWN) &&
       Input.press?(Input::B) &&
       Input.press?(Input::CTRL)
      closeSplashDelete(scene,args)
    end
  end
end



class Scene_Intro
  def initialize(pics, splash = nil)
    @pics   = pics
    @splash = splash
  end

  def main
    Graphics.transition(0)
    @eventscene = IntroEventScene.new(@pics,@splash)
    @eventscene.main
    Graphics.freeze
  end
end
