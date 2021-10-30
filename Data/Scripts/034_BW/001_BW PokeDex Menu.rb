#===============================================================================
#  PokedexMenu BW Style
#  for Pokémon Essentials version 18.x
#
#===============================================================================
#
# Instructions: Put this script above Main. Download the file BW Pokédex.rar and
# extract the files in your project main folder.
#   
#    Requires Scripting Utilities by Luka S.J. for the script works correctly.
#
#===============================================================================
#
#  Modified by DeepBlue PacificWaves
#  Special thanks to NettoHikari, that helped with the Entry Scene/Entry Page
#  code.
#
#  Graphics Ripped by Xtreme1992
#
#  If used, please give credits. For more information on how to credited, look 
#  for the original post on Relic Castle or PokéCommunity.
#
#===============================================================================
# Pokédex Regional Dexes list menu screen
# * For choosing which region list to view. Only appears when there is more
#   than one viable region list to choose from, and if USE_CURRENT_REGION_DEX is
#   false.
#===============================================================================
class Window_DexesList < Window_CommandPokemon
  def initialize(commands,commands2,width)
    @commands2 = commands2
    super(commands,width)
    @selarrow = AnimatedBitmap.new("Graphics/Pictures/selarrow_white")
# Changes the color of the text, to the one used in BW
    self.baseColor   = Color.new(255,255,255)
    self.shadowColor = Color.new(165,165,173)
    self.windowskin  = nil
  end

  def drawItem(index,count,rect)
    super(index,count,rect)
    if index>=0 && index<@commands2.length
      pbDrawShadowText(self.contents,rect.x+254,rect.y,64,rect.height,
         sprintf("%d",@commands2[index][0]),self.baseColor,self.shadowColor,1)
      pbDrawShadowText(self.contents,rect.x+350,rect.y,64,rect.height,
         sprintf("%d",@commands2[index][1]),self.baseColor,self.shadowColor,1)
      allseen = (@commands2[index][0]>=@commands2[index][2])
      allown  = (@commands2[index][1]>=@commands2[index][2])
      pbDrawImagePositions(self.contents,[
        ["Graphics/Pictures/Pokedex/icon_menuseenown",rect.x+236,rect.y+4,(allseen) ? 26 : 0,0,26,26],
        ["Graphics/Pictures/Pokedex/icon_menuseenown",rect.x+332,rect.y+4,(allown) ? 26 : 0,26,26,26]
      ])
    end
  end
end


class PokemonPokedexMenu_Scene
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(commands,commands2)
    @commands = commands
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["background"] = IconSprite.new(0,0,@viewport)
# Defines the Scrolling Background, as well as the overlay on top of it
    @sprites["background"] = ScrollingSprite.new(@viewport)    
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/bg_menu"))
    @sprites["background"].speed = 1
    @sprites["menuoverlay"] = IconSprite.new(0,0,@viewport) 
    @sprites["menuoverlay"].setBitmap(_INTL("Graphics/Pictures/Pokedex/menu_overlay"))
    @sprites["headings"]=Window_AdvancedTextPokemon.newWithSize(
       _INTL("<c3=FFFFFF,A5A5AD>SEEN<r>OBTAINED</c3>"),286,136,208,64,@viewport)
    @sprites["headings"].windowskin  = nil
    @sprites["commands"] = Window_DexesList.new(commands,commands2,Graphics.width-84)
    @sprites["commands"].x      = 40
    @sprites["commands"].y      = 192
    @sprites["commands"].height = 192
    @sprites["commands"].viewport = @viewport
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbScene
    ret = -1
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::B)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::C)
        ret = @sprites["commands"].index
        (ret==@commands.length-1) ? pbPlayCloseMenuSE : pbPlayDecisionSE
        break
      end
    end
    return ret
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end



class PokemonPokedexMenuScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    commands  = []
    commands2 = []
    dexnames = pbDexNames
    for i in 0...$PokemonGlobal.pokedexViable.length
      index = $PokemonGlobal.pokedexViable[i]
      if dexnames[index]==nil
        commands[i] = _INTL("Pokédex")
      else
        if dexnames[index].is_a?(Array)
          commands[i] = dexnames[index][0]
        else
          commands[i] = dexnames[index]
        end
      end
      index = -1 if index>=$PokemonGlobal.pokedexUnlocked.length-1
      commands2[i] = [$Trainer.pokedexSeen(index),
                      $Trainer.pokedexOwned(index),
                      pbGetRegionalDexLength(index)]
    end
    commands.push(_INTL("Exit"))
    @scene.pbStartScene(commands,commands2)
    loop do
      cmd = @scene.pbScene
      break if cmd<0 || cmd>=commands2.length   # Cancel/Exit
      $PokemonGlobal.pokedexDex = $PokemonGlobal.pokedexViable[cmd]
      $PokemonGlobal.pokedexDex = -1 if $PokemonGlobal.pokedexDex==$PokemonGlobal.pokedexUnlocked.length-1
      pbFadeOutIn {
        scene = PokemonPokedex_Scene.new
        screen = PokemonPokedexScreen.new(scene)
        screen.pbStartScreen
      }
    end
    @scene.pbEndScene
  end
end
