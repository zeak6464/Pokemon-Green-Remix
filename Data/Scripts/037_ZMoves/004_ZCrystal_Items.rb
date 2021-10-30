##################################################################################
# Z Crystals                                                                     #
##################################################################################

ItemHandlers::UseOnPokemon.add(:BUGINIUMZ,proc{|item,pokemon,scene|
  # Find the corresponding compatibility conditions 
  zcomp = pbGetZMoveDataIfCompatible(pokemon, item)
  
  if zcomp
    scene.pbDisplay(_INTL("The {1} will be given to {2} so that it can use its Z-Power!",PBItems.getName(item),pokemon.name))
    if pokemon.item!=0
      itemname=PBItems.getName(pokemon.item)
      scene.pbDisplay(_INTL("{1} is already holding one {2}.\1",pokemon.name,itemname))
      if scene.pbConfirm(_INTL("Would you like to switch the two items?"))   
        if !$PokemonBag.pbStoreItem(pokemon.item)
          scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
        else
          pokemon.setItem(zcomp[PBZMove::HELD_ZCRYSTAL])
          scene.pbDisplay(_INTL("The {1} was taken and replaced with the {2}.",itemname,PBItems.getName(item)))
          next true
        end
      end
    else
      pokemon.setItem(zcomp[PBZMove::HELD_ZCRYSTAL])
      scene.pbDisplay(_INTL("{1} was given the {2} to hold.",pokemon.name,PBItems.getName(item)))
      next true      
    end
  else       
    scene.pbDisplay(_INTL("It had no effect."))
    next false
  end
})

ItemHandlers::UseOnPokemon.copy(:BUGINIUMZ, :DARKINIUMZ, :DRAGONIUMZ, :ELECTRIUMZ, :FAIRIUMZ, :FIGHTINIUMZ, :FIRIUMZ, :FLYINIUMZ, :GHOSTIUMZ, :GRASSIUMZ, :GROUNDIUMZ, :ICIUMZ, :NORMALIUMZ, :POISONIUMZ, :PSYCHIUMZ, :ROCKIUMZ, :STEELIUMZ, :WATERIUMZ, :ALORAICHIUMZ, :DECIDIUMZ, :INCINIUMZ, :PRIMARIUMZ, :EEVIUMZ, :PIKANIUMZ, :SNORLIUMZ, :MEWNIUMZ, :TAPUNIUMZ, :MARSHADIUMZ, :PIKASHUNIUMZ, :KOMMONIUMZ, :LYCANIUMZ, :MIMIKIUMZ, :LUNALIUMZ, :SOLGANIUMZ, :ULTRANECROZIUMZ)