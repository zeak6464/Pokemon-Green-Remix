#===============================================================================
# * Simple HUD Optimized - by FL (Credits will be apreciated)
#===============================================================================
#
# This script is for Pokémon Essentials. It displays a simple HUD with the
# party icons, HP Bars and some small text.
#
#===============================================================================
#
# Zeak6464 - Modded for Streamer Mode 
#
#===============================================================================
# in Settings change 
# BORDERWIDTH          = 200
# BORDERHEIGHT         = 0
#
# Add the new graphics "Graphics/Pictures/Hud1" & "Graphics/Pictures/Hud2"
#===============================================================================

DEFAULTSCREENWIDTH   = 512
POKEMONICONZOOM = 1

class HUD   
    
    # If you wish to use a background picture, put the image path below, like
    # BGPATH="Graphics/Pictures/battleMessage". I recommend a 512x64 picture
    BGPATH="Graphics/Pictures/Hud1"
    BG2PATH="Graphics/Pictures/Hud2"

    # Make as 'false' to don't show the blue bar
    USEBAR=true

    # Make as 'false' to don't show the hp bars
    SHOWHPBARS=true

    # Lower this number = more lag.
    FRAMESPERUPDATE=2


    def initialize
      @sprites = {}
    end

    def showHUD?
      return (
        $Trainer && $PokemonSystem.border==1
      )
    end

    def create
      @sprites.clear

      @partySpecies = Array.new(6, 0)
      @partyForm = Array.new(6, 0)
      @partyIsEgg = Array.new(6, false)
      @partyHP = Array.new(6, 0)
      @partyTotalHP = Array.new(6, 0)

      drawBarFromPath = BGPATH != ""
      drawBarFromPath = BG2PATH != ""
      
      if USEBAR
        #left background
          @sprites["bar"]=IconSprite.new(-208,0)
          @sprites["bar"].setBitmap(BGPATH)
        #right background
          @sprites["bar2"]=IconSprite.new(512,0)
          @sprites["bar2"].setBitmap(BG2PATH)
        end
        

    
      @sprites["player"]=IconSprite.new(550,75)
      @sprites["player"].setBitmap(pbTrainerSpriteFile($Trainer.trainertype))
      @currentTexts = textsDefined
      drawText
    # zeak6464  
    # removed @viewport1 , +16+64*i
      for i in 0...6
        x = -200
        y = 62*i
        y-=8 if SHOWHPBARS
        @sprites["pokeicon#{i}"]=IconSprite.new(x,y)
      end
      refreshPartyIcons

      if SHOWHPBARS
        borderWidth = 36
        borderHeight = 10
        fillWidth = 32
        fillHeight = 6
        for i in 0...6
          x=-170
          y=(62-8)+(62)*i

          @sprites["hpbarborder#{i}"] = BitmapSprite.new(
            borderWidth,borderHeight
          )
          @sprites["hpbarborder#{i}"].x = x-borderWidth/2
          @sprites["hpbarborder#{i}"].y = y-borderHeight/2
          @sprites["hpbarborder#{i}"].bitmap.fill_rect(
            Rect.new(0,0,borderWidth,borderHeight),
            Color.new(32,32,32)
          )
          @sprites["hpbarborder#{i}"].bitmap.fill_rect(
            (borderWidth-fillWidth)/2,
            (borderHeight-fillHeight)/2,
            fillWidth,
            fillHeight,
            Color.new(96,96,96)
          )
          @sprites["hpbarborder#{i}"].visible = false

          @sprites["hpbarfill#{i}"] = BitmapSprite.new(
            fillWidth,fillHeight
          )
          @sprites["hpbarfill#{i}"].x = x-fillWidth/2
          @sprites["hpbarfill#{i}"].y = y-fillHeight/2
        end
        refreshHPBars
      end

      for sprite in @sprites.values
        sprite.z+=600
      end
    end
    

  #removed viewport1
    def drawText
      baseColor=Color.new(31*8,31*8,31*8)
      shadowColor=Color.new(14*8,14*8,14*8)

      if @sprites.include?("overlay")
        @sprites["overlay"].bitmap.clear
      else
        @sprites["overlay"] = BitmapSprite.new(DEFAULTSCREENWIDTH+400,384)
      end
      @sprites["overlay"].z=999999

    if $Trainer.party.size == 0   
      textPositions=[
        [@currentTexts[12],812,23,2,baseColor,shadowColor],
        [@currentTexts[13],812,218,2,baseColor,shadowColor],
        [@currentTexts[14],812,258,2,baseColor,shadowColor],
        [@currentTexts[15],812,298,2,baseColor,shadowColor],
        [@currentTexts[16],812,338,2,baseColor,shadowColor]
        ]
      else 
        textPositions=[
      #left side
      #pokemon 1 
        [@currentTexts[0],120,2,2,baseColor,shadowColor],
        [@currentTexts[1],120,32,2,baseColor,shadowColor],
      #pokemon 2  
        [@currentTexts[2],120,64,2,baseColor,shadowColor],
        [@currentTexts[3],120,96,2,baseColor,shadowColor],
      #pokemon 3 
        [@currentTexts[4],120,128,2,baseColor,shadowColor],
        [@currentTexts[5],120,160,2,baseColor,shadowColor],
      #pokemon 4  
        [@currentTexts[6],120,192,2,baseColor,shadowColor],
        [@currentTexts[7],120,224,2,baseColor,shadowColor],
      #pokemon 5  
        [@currentTexts[8],120,256,2,baseColor,shadowColor],
        [@currentTexts[9],120,284,2,baseColor,shadowColor],
      #pokemon 6  
        [@currentTexts[10],120,320,2,baseColor,shadowColor],
        [@currentTexts[11],120,348,2,baseColor,shadowColor],
      #right side
        [@currentTexts[12],812,23,2,baseColor,shadowColor],
        [@currentTexts[13],812,218,2,baseColor,shadowColor],
        [@currentTexts[14],812,258,2,baseColor,shadowColor],
        [@currentTexts[15],812,298,2,baseColor,shadowColor],
        [@currentTexts[16],812,338,2,baseColor,shadowColor]
        ]
      end
    
    if $Trainer.party.size == 0
     else
      pbSetSystemFont(@sprites["overlay"].bitmap)
      pbDrawTextPositions(@sprites["overlay"].bitmap,textPositions)
    end
  end
    
  

    # Note that this method is called on each refresh, but the texts
    # only will be redrawed if any character change.
  def textsDefined
  ret=[]
  for i in 0...6
    if $Trainer.party.size>i
      ret[i*2] = _INTL("{1}",$Trainer.party[i].name)
      ret[i*2+1] = _INTL("LV:  {1}",$Trainer.party[i].level)
    else
      ret[i*2] = ""
      ret[i*2+1] = ""
    end
  end
  ret[12] = _INTL("Name:{1}",$Trainer.name)
  ret[13] = _INTL("Seen:{1}",$Trainer.pokedexSeen)
  ret[14] = _INTL("Owned:{1}",$Trainer.pokedexOwned)
  ret[15] = _INTL("$:{1}",$Trainer.money)
  ret[16] = _INTL("Badges:{1}",$Trainer.numbadges)
  return ret
end

    def refreshPartyIcons
      for i in 0...6
        partyMemberExists = $Trainer.party.size > i
        partySpecie = 0
        partyForm = 0
        partyIsEgg = false
        if partyMemberExists
          partySpecie = $Trainer.party[i].species
          partyForm = $Trainer.party[i].form
          partyIsEgg = $Trainer.party[i].egg?
        end
        refresh = (
          @partySpecies[i]!=partySpecie || 
          @partyForm[i]!=partyForm ||
          @partyIsEgg[i]!=partyIsEgg
        )
        if refresh
          @partySpecies[i] = partySpecie
          @partyForm[i] = partyForm
          @partyIsEgg[i] = partyIsEgg
          if partyMemberExists
            pokemonIconFile = pbPokemonIconFile($Trainer.party[i])
            @sprites["pokeicon#{i}"].setBitmap(pokemonIconFile)
            @sprites["pokeicon#{i}"].zoom_x=POKEMONICONZOOM
            @sprites["pokeicon#{i}"].zoom_y=POKEMONICONZOOM
            @sprites["pokeicon#{i}"].src_rect=Rect.new(0,0,62,62)
          end
          @sprites["pokeicon#{i}"].visible = partyMemberExists
        end
      end
    end


    def refreshHPBars
      for i in 0...6
        hp = 0
        totalhp = 0
        hasHP = i<$Trainer.party.size && !$Trainer.party[i].egg?
        if hasHP
          hp = $Trainer.party[i].hp
          totalhp = $Trainer.party[i].totalhp
        end

        lastTimeWasHP = @partyTotalHP[i] != 0
        @sprites["hpbarborder#{i}"].visible = hasHP if lastTimeWasHP != hasHP

        redrawFill = hp != @partyHP[i] || totalhp != @partyTotalHP[i]
        if redrawFill
          @partyHP[i] = hp
          @partyTotalHP[i] = totalhp
          @sprites["hpbarfill#{i}"].bitmap.clear

          width = @sprites["hpbarfill#{i}"].bitmap.width
          height = @sprites["hpbarfill#{i}"].bitmap.height
          fillAmount = (hp==0 || totalhp==0) ? 0 : hp*width/totalhp
          # Always show a bit of HP when alive
          fillAmount = 1 if fillAmount==0 && hp>0
          if fillAmount > 0
            hpColors=nil
            if hp<=(totalhp/4).floor
              hpColors = [Color.new(240,80,32),Color.new(168,48,56)] # Red
            elsif hp<=(totalhp/2).floor
              hpColors = [Color.new(248,184,0),Color.new(184,112,0)] # Orange
            else
              hpColors = [Color.new(24,192,32),Color.new(0,144,0)] # Green
            end
            shadowHeight = 2
            rect = Rect.new(0,0,fillAmount,shadowHeight)
            @sprites["hpbarfill#{i}"].bitmap.fill_rect(rect, hpColors[1])
            rect = Rect.new(0,shadowHeight,fillAmount,height-shadowHeight)
            @sprites["hpbarfill#{i}"].bitmap.fill_rect(rect, hpColors[0])
          end
        end
      end
    end

    def update
      if showHUD?
        if @sprites.empty?
          create
        else
          updateHUDContent = (
            FRAMESPERUPDATE<=1 || Graphics.frame_count%FRAMESPERUPDATE==0
          )
          if updateHUDContent
            newTexts = textsDefined
            if @currentTexts != newTexts
              @currentTexts = newTexts
              drawText
            end
            refreshPartyIcons
            refreshHPBars if SHOWHPBARS
          end
        end
        pbUpdateSpriteHash(@sprites)
      else
        dispose if !@sprites.empty?
      end
    end

    def dispose
      pbDisposeSpriteHash(@sprites)
    end
  end
  
class Spriteset_Map
  alias :initializeOldFL :initialize
  alias :disposeOldFL :dispose
  alias :updateOldFL :update

  def initialize(map=nil)
    initializeOldFL(map)
  end

  def dispose
    @hud.dispose if @hud
    disposeOldFL
  end

  def update
    updateOldFL
    @hud = HUD.new if !@hud
    @hud.update
  end
end  



class PokeBattle_Scene
  alias __hud_pbGraphicsUpdate pbGraphicsUpdate
  def pbGraphicsUpdate
    __hud_pbGraphicsUpdate
      @hud = HUD.new if !@hud
      @hud.update
  end
end