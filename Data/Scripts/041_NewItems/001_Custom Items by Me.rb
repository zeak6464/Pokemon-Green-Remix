ItemHandlers::UseOnPokemon.add(:FORCESTONE,proc{|item,pokemon,scene|
 for form in pbGetEvolvedFormData(pokemon.species)
    newspecies=form[2]
  end
  return if !newspecies
  if newspecies>0
    evo=PokemonEvolutionScene.new
    evo.pbStartScreen(pokemon,newspecies)
    evo.pbEvolution
    evo.pbEndScreen
  end
     next true
})


ItemHandlers::UseOnPokemon.add(:RANDOMSTONE,proc{|item,pokemon,scene|
    evo=PokemonEvolutionScene.new
    newspecies = rand(PBSpecies.maxValue)+1
    evo.pbStartScreen(pokemon,newspecies)
    evo.pbEvolution
    evo.pbEndScreen
     next true
})

ItemHandlers::UseOnPokemon.add(:DEFORCESTONE,proc{|item,pokemon,scene|
  newspecies=pbGetBabySpecies(pokemon.species)
  return if !newspecies
  return if newspecies==pokemon.species
  if newspecies>0
    evo=PokemonEvolutionScene.new
    evo.pbStartScreen(pokemon,newspecies)
    evo.pbEvolution
    evo.pbEndScreen
  end
     next true
})

ItemHandlers::UseOnPokemon.add(:SHINYGEM,proc{|item,pokemon,scene|
   if (pokemon.isShiny? rescue false)
     scene.pbDisplay(_INTL("It won't make this pokemon shiny."))
     next false
   end
      pokemon.makeShiny
      scene.pbRefresh
      scene.pbDisplay(_INTL("{1} is different now!",pokemon.name))
    next true
})

ItemHandlers::UseOnPokemon.add(:RAINBOWWING,proc{|item,pokemon,scene|
if isConst?(pokemon.species,PBSpecies,:JOLTEON)
 evo=PokemonEvolutionScene.new
    newspecies = (243)
    evo.pbStartScreen(pokemon,newspecies)
    evo.pbEvolution
    evo.pbEndScreen
     next true
   end
})



ItemHandlers::UseOnPokemon.add(:RAINBOWWING,proc{|item,pokemon,scene|
if isConst?(pokemon.species,PBSpecies,:FLAREON)
   evo=PokemonEvolutionScene.new
    newspecies = (244)
    evo.pbStartScreen(pokemon,newspecies)
    evo.pbEvolution
    evo.pbEndScreen
     next true
   end
})


ItemHandlers::UseOnPokemon.add(:RAINBOWWING,proc{|item,pokemon,scene|
if isConst?(pokemon.species,PBSpecies,:VAPOREON)
    evo=PokemonEvolutionScene.new
    newspecies = (245)
    evo.pbStartScreen(pokemon,newspecies)
    evo.pbEvolution
    evo.pbEndScreen
     next true
   end
})


ItemHandlers::UseOnPokemon.add(:DELTASTONE,proc{|item,pokemon,scene|
if scene.pbConfirm(_INTL("Are you sure you want to make this Pokémon Delta?"))
   if (pokemon.isDeltap? rescue false)
     scene.pbDisplay(_INTL("It won't make this pokemon delta."))
     next false
   end
      pokemon.makeDeltap
      pokemon.pbRandomMoves
      pokemon.abilityOverride = rand(PBAbilities.maxValue)
      pokemon.typeOverride1 = rand(PBTypes.maxValue)
      pokemon.typeOverride2 = rand(PBTypes.maxValue)
      scene.pbRefresh
      scene.pbDisplay(_INTL("{1} is different now!",pokemon.name))
    next true
  end
})
   
ItemHandlers::UseOnPokemon.add(:TYPESTONE,proc{|item,pokemon,scene|
   if (pokemon.hp<=0 rescue false)
     scene.pbDisplay(_INTL("{1}'s HP is too low.",pokemon.name))
     next false
   end
      pokemon.typeOverride1=rand(PBTypes.maxValue)
      pokemon.typeOverride2=rand(PBTypes.maxValue)
      scene.pbRefresh
      scene.pbDisplay(_INTL("{1}'s Type was altered to {2},{3}.",pokemon.name,PBTypes.getName(pokemon.type1),PBTypes.getName(pokemon.type2)))
    next true
})

ItemHandlers::UseOnPokemon.add(:ABILITYSTONE,proc{|item,pokemon,scene|
      pokemon.abilityOverride=rand(PBAbilities.maxValue)
      scene.pbRefresh
      scene.pbDisplay(_INTL("{1} has {2} now!",pokemon.name,PBAbilities.getName(pokemon.ability)))
})

ItemHandlers::UseOnPokemon.add(:MOVESTONE,proc{|item,pokemon,scene|
      pokemon.pbRandomMoves
      scene.pbRefresh
      scene.pbDisplay(_INTL("Your pokemon now has new moves!"))
})

ItemHandlers::UseFromBag.add(:PALPAD,proc{|item|
   pbFadeOutIn(99999){ 
        scene=PalPadScene.new
        screen=PalPad.new(scene)
        screen.pbStartScreen
   }
   next 1 # Continue
})

ItemHandlers::UseInField.add(:PALPAD,proc{|item|
   pbFadeOutIn(99999){ 
        scene=PalPadScene.new
        screen=PalPad.new(scene)
        screen.pbStartScreen
   }
   next 1 # Continue
})

ItemHandlers::UseFromBag.add(:GTS,proc{|item|
   pbFadeOutIn(99999){ 
        scene=PalPadScene.new
        screen=PalPad.new(scene)
        screen.pbStartScreen
   }
   next 1 # Continue
})

ItemHandlers::UseInField.add(:GTS,proc{|item|
   pbFadeOutIn(99999){ 
        scene=GTSScene.new
        screen=GTS.new(scene)
        screen.pbStartScreen
   }
   next 1 # Continue
})

ItemHandlers::UseFromBag.add(:CABLE,proc{|item|
   pbCableClub
   next 1 # Continue
})

ItemHandlers::UseInField.add(:CABLE,proc{|item|
 pbCableClub
   next 1 # Continue
})