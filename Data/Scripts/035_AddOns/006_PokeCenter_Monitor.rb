#==============================================================================#
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\#
#==============================================================================#
#                           PokeCenter Monitor Icons                           #
#                                    v1.2                                      #
#                             By Ulithium_Dragon                               #
#                                                                              #
#==============================================================================#
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\#
#==============================================================================#
# Shows your Party Pokemon's icons on the monitor when healing at a PokeCenter.#
#                                                                              #
#------------------------------------------------------------------------------#
#        :::::This script is compatible with both PE v16 and v17:::::          #
#==============================================================================#
#                                                                              #
#------------------------------------------------------------------------------#
# **Place this script somewhere above Main and below Compiler.                 #
#------------------------------------------------------------------------------#
#                                                                              #
# You will need to set the x and y coordinates to line up with your PokeCenter #
#  screen manually. Unfortunately the best way to do this is "guess and check".#
# Example: pbPokemonCenterIcons(240,48)                                        #
#                                                                              #
# The third parameter controls the icon's scale. By default, this is 0.45      #
# because that is the largest I could make them to line up with the stock FrLg #
# PokeCenter monitor. If your monitors are larger or you'd rather have minor   #
# clipping instead of icon warping[1], set the scale to 0.5 or anything else.  #
#                                                                              #
# Example: pbPokemonCenterIcons(240,48,0.45)                                   #
#  ^^These values are designed to fit the FrLg screens on PE's example maps.   #
#                                                                              #
# [1]The icons will warp a bit if you don't use whole numbers (or 0.5) to scale#
#    them. I.e. 0.5, 1, 2, 3, etc. should be fine, but 1.25 or 0.75 will warp. #
#                                                                              #
#==============================================================================#
# To use this script in a Pokemon Center, replace is script command in         #
# the Nurse event with the new pbPokemonCenterIcons function:                  #
#------------------------------------------------------------------------------#
#                                                                              #
#   count=$Trainer.pokemonCount                                                #
#   for i in 1..count                                                          #
#     pbSet(6,i)                                                               #
#     pbSEPlay("ballshake")                                                    #
#     pbWait(16)                                                               #
#   end                                                                        #
#                                                                              #
# ...Then delete the "Play ME" in the event (this script takes care of that).  #
# ____________________________________________                                 #
#                                                                              #
# Here's an image of how the event would look:                                 #
#    https://i.imgur.com/F8GKC0v.png                                           #
# ____________________________________________                                 #
#                                                                              #
#==============================================================================#
# *NOTE: Depending on what version of Pokemon Essentials used, the sound file  #
#        names may be slightly different (this won't matter, just replace it). #
#                                                                              #
#------------------------------------------------------------------------------#
# *NOTE: If you are using mej71's Improved PokeCenters, there will be two      #
#        script commands in the Nurse Event, so replace them both!             #
#                                                                              #
#------------------------------------------------------------------------------#
#==============================================================================#
#//////////////////////////////////////////////////////////////////////////////#
#==============================================================================#


# If you are using mej71's Improved PokeCenters, set this to "true".
# *NOTE: By default, Improved PokeCenters is included with the Gen 6 Project!
USING_NEWBALLSYSTEM = false  #Defaut: false




#pbPokemonCenterIcons(240,48,0.45)
def pbPokemonCenterIcons(xcoord=nil,ycoord=nil,scale=nil)
  height = 0  #The vertical screen coord to display the icons at.
  width = 0   #The horizontal screen coord to display the icons at.
  scale = 0.45 if !scale #Sets the icon size. Default is used if undefined.
  currentIndex = 0
  arrayindex = 0
  totalpkmn = $Trainer.pokemonCount  #Gets and stores the party size.
  pbSet(1,28347)  #Sets temp var 1 to a random number to use in messagebox checks.
  $pkmncentermonitor_soundchecktype = 0  #Global used in sound name checking.


  # Throws an error if the player has no pokemon yet and escapes to not crash.
  if !defined?($Trainer.party)
    return false
  end
  # Cycles through the party pokemon in order (eggs are skipped).
  # Uses gender, shiny, alt-form, and/or shadow pokemon sprites (if they exist).
  while arrayindex < totalpkmn
    species=$Trainer.party[arrayindex].species
    bitmapFileName=pbPokemonIconFile($Trainer.party[arrayindex])
    bitmap=pbResolveBitmap(bitmapFileName)
    bitmapFileName=BitmapCache.load_bitmap(bitmap)
      # Initializes full Pokemon icon bitmap.
    bitmap=Bitmap.new(bitmapFileName.width,bitmapFileName.height)
    bitmap.blt(0,0,bitmapFileName,Rect.new(0,0,bitmapFileName.width,bitmapFileName.height))
    width=bitmap.height*scale
    height=bitmap.height*scale
    bitmap=Bitmap.new(width,height)
    bitmap.stretch_blt(Rect.new(0,0,width,height),bitmapFileName,Rect.new((width/scale),0,width/scale,height/scale))
    if bitmap
      iconwindow = PictureWindow.new(bitmap)
      # Checks if the coordinates were defined.
      if !xcoord && !ycoord  #If undefined, use the center of the screen instead.
        iconwindow.x=(Graphics.width/2)-(iconwindow.width/2)
        iconwindow.y=((Graphics.height-96)/2)-(iconwindow.height/2)
      else
        iconwindow.x=xcoord
        iconwindow.y=ycoord
      end
      # Safeguard checks. Makes sure neither of the coordinates are undefined.
      if !xcoord
        iconwindow.x=(Graphics.width/2)-(iconwindow.width/2)
      elsif !ycoord
        iconwindow.y=((Graphics.height-96)/2)-(iconwindow.height/2)
      end
      $pkmncentermonitor_soundchecktype = 1
      if USING_NEWBALLSYSTEM  #New Ball System
        pbSet(6,pbGet(6)+1)
        pbPCMIGetSoundTypes
        if arrayindex < totalpkmn-1
          pbWait(16)
          iconwindow.dispose
        else
          pbWait(6)
        end
      else #Original Ball System
        pbSet(6,pbGet(6)+1)
        pbPCMIGetSoundTypes
        pbWait(16)
        iconwindow.dispose
      end
    end
    arrayindex = arrayindex+1
  end
  $pkmncentermonitor_soundchecktype = 2
  pbPCMIGetSoundTypes
  pbWait(4)
  iconwindow.dispose
  pbSet(1,false)
end




def pbPCMIGetSoundTypes
  # Since PE v17 changed a lot of the sound effect names, I use
  #  the "Sprite_SurfBase" added in v17 as a version check.
  if $pkmncentermonitor_soundchecktype == 1
    if defined?(Sprite_SurfBase)  #PE v17
      pbSEPlay("Battle ball shake")
    else    #PE v16
      pbSEPlay("ballshake")
    end
    $pkmncentermonitor_soundchecktype = 0
  elsif $pkmncentermonitor_soundchecktype == 2
    if defined?(Sprite_SurfBase)  #PE v17
      pbMEPlay("Pkmn healing",100,100)
    else    #PE v16
      pbMEPlay("Pokemon Healing",100,100)
    end
    $pkmncentermonitor_soundchecktype = 0
  end
  $pkmncentermonitor_soundchecktype = 0 #Redundancy catch.
end


#==============================================================================#
#     Utilities                                                                #
#==============================================================================#
# *Overwrites the base function to removes the windowbox bg for this script.
class SpriteWindow_Base < SpriteWindow
  TEXTPADDING=4 # In pixels


  def initialize(x, y, width, height)
    super()
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.z = 100
    @curframe=MessageConfig.pbGetSystemFrame()
    @curfont=MessageConfig.pbGetSystemFontName()
    @sysframe=AnimatedBitmap.new(@curframe)
    @customskin=nil
    __setWindowskin(@sysframe.bitmap)
    __resolveSystemFrame()
    pbSetSystemFont(self.contents) if self.contents
  end


  def __setWindowskin(skin)
    if pbGet(1) != 28347  #Random number so it can't be in use by something else.
      if skin && (skin.width==192 && skin.height==128) ||  # RPGXP Windowskin
                 (skin.width==128 && skin.height==128)     # RPGVX Windowskin
        self.skinformat=0
      else
        self.skinformat=1
      end
      self.windowskin=skin
    end
  end


  def __resolveSystemFrame
    if self.skinformat==1
      if !@resolvedFrame
        @resolvedFrame=MessageConfig.pbGetSystemFrame()
        @resolvedFrame.sub!(/\.[^\.\/\\]+$/,"")
      end
      self.loadSkinFile("#{@resolvedFrame}.txt") if @resolvedFrame!=""
    end
  end


  def setSkin(skin) # Filename of windowskin to apply. Supports XP, VX, and animated skins.
    @customskin.dispose if @customskin
    @customskin=nil
    resolvedName=pbResolveBitmap(skin)
    return if !resolvedName || resolvedName==""
    @customskin=AnimatedBitmap.new(resolvedName)
    __setWindowskin(@customskin.bitmap)
    if self.skinformat==1
      skinbase=resolvedName.sub(/\.[^\.\/\\]+$/,"")
      self.loadSkinFile("#{skinbase}.txt")
    end
  end


  def setSystemFrame
    @customskin.dispose if @customskin
    @customskin=nil
    __setWindowskin(@sysframe.bitmap)
    __resolveSystemFrame()
  end


  def update
    super
    if self.windowskin
      if @customskin
        if @customskin.totalFrames>1
          @customskin.update
          __setWindowskin(@customskin.bitmap)
        end
      elsif @sysframe
        if @sysframe.totalFrames>1
          @sysframe.update
          __setWindowskin(@sysframe.bitmap)
        end
      end
    end
    if @curframe!=MessageConfig.pbGetSystemFrame()
      @curframe=MessageConfig.pbGetSystemFrame()
      if @sysframe && !@customskin
        @sysframe.dispose if @sysframe
        @sysframe=AnimatedBitmap.new(@curframe)
        @resolvedFrame=nil
        __setWindowskin(@sysframe.bitmap)
        __resolveSystemFrame()   
      end
      begin
        refresh
      rescue NoMethodError
      end
    end
    if @curfont!=MessageConfig.pbGetSystemFontName()
      @curfont=MessageConfig.pbGetSystemFontName()
      if self.contents && !self.contents.disposed?
        pbSetSystemFont(self.contents)
      end
      begin
        refresh
      rescue NoMethodError
      end
    end
  end


  def dispose
    self.contents.dispose if self.contents
    @sysframe.dispose
    @customskin.dispose if @customskin
    super
  end
end
#==============================================================================#
#//////////////////////////////////////////////////////////////////////////////#
#==============================================================================#