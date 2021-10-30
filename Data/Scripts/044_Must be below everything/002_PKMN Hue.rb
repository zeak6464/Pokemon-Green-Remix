#===============================================================================
# * Bitmap Hue Pokémon - by Vendily / Zeak6464
#===============================================================================
def drawShadowPoke(bitmap,hue=nil)
  shadowhue=(hue ? hue : 0)
  bitmap.hue_change(shadowhue)
end

alias _shadow_pbLoadPokemonBitmapSpecies pbLoadPokemonBitmapSpecies
    def pbLoadPokemonBitmapSpecies(pokemon, species, back=false)
      ret=_shadow_pbLoadPokemonBitmapSpecies(pokemon, species, back)
      if ret
        hue=(MultipleForms.call("bitmapHue",pokemon))
        animatedBitmap=ret
        copiedBitmap=animatedBitmap.copy
        animatedBitmap.dispose
        copiedBitmap.each {|bitmap|
          drawShadowPoke(bitmap,180) if (pokemon.isShadow? rescue false)
          drawShadowPoke(bitmap,pokemon.hue) if (pokemon.isDeltap? rescue false)
          drawShadowPoke(bitmap,pokemon.hue)
        }
        ret=copiedBitmap
      end
      return ret
    end

    
class PokemonIconSprite
    alias _shadow_pokemon= pokemon=
  def pokemon=(value)
    self._shadow_pokemon=value
    if pokemon
       bitmap.hue_change(180) if (pokemon.isShadow? rescue false)
       bitmap.hue_change(pokemon.hue) if (pokemon.isDeltap? rescue false) 
       bitmap.hue_change(pokemon.hue)
    end
  end
  
end