class Scene_DebugIntro
  def main
    Graphics.update
    Graphics.transition(0)
    if File.exists?("Data/LastSave.dat")
      lastsave=pbGetLastPlayed
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
    Graphics.freeze
  end
end

def pbCallTitle #:nodoc:
  if $DEBUG
    Graphics.update
    return Scene_DebugIntro.new
  else
    # First parameter is an array of images in the Titles
    # directory without a file extension, to show before the
    # actual title screen.  Second parameter is the actual
    # title screen filename, also in Titles with no extension.
    return Scene_Intro.new(['intro1'], 'splash') 
  end
end

#if $DEBUG==true 
#  pbCompileAllData(true) { |msg| Win32API.SetWindowText(msg) }
#end

def mainFunction #:nodoc:
  if $DEBUG
    Graphics.update
    pbCriticalCode { mainFunctionDebug }
  else
    mainFunctionDebug
  end
  return 1
end

def mainFunctionDebug #:nodoc:
  begin
    getCurrentProcess=Win32API.new("kernel32.dll","GetCurrentProcess","","l")
    setPriorityClass=Win32API.new("kernel32.dll","SetPriorityClass",%w(l i),"")
    setPriorityClass.call(getCurrentProcess.call(),32768) # "Above normal" priority class
    $data_animations    = pbLoadRxData("Data/Animations")
    $data_tilesets      = pbLoadRxData("Data/Tilesets")
    $data_common_events = pbLoadRxData("Data/CommonEvents")
    $data_system        = pbLoadRxData("Data/System")
    $game_system        = Game_System.new
    setScreenBorderName("border") # Sets image file for the border
    Graphics.update
    Graphics.freeze
    $scene = pbCallTitle
    while $scene != nil
      $scene.main
    end
    Graphics.transition(20)
  rescue Hangup
    pbEmergencySave
    raise
  end
end

loop do
  retval=mainFunction
  if retval==0 # failed
    loop do
      Graphics.update
    end
  elsif retval==1 # ended successfully
    break
  end
end


