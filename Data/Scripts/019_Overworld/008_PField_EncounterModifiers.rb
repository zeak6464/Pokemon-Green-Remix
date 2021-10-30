################################################################################
# This section was created solely for you to put various bits of code that
# modify various wild Pokémon and trainers immediately prior to battling them.
# Be sure that any code you use here ONLY applies to the Pokémon/trainers you
# want it to apply to!
################################################################################

# Make all wild Pokémon shiny while a certain Switch is ON (see Settings).
Events.onWildPokemonCreate += proc { |_sender, e|
  pokemon = e[0]
  if $game_switches[SHINY_WILD_POKEMON_SWITCH]
    pokemon.makeShiny
  end
}

#Wild Pokemon in Delta Mode 
Events.onWildPokemonCreate+=proc {|sender,e|
   pokemon=e[0]
   if $PokemonSystem.delta == 1
     pokemon.makeDeltap
     pokemon.pbRandomMoves
     pokemon.abilityOverride = rand(PBAbilities.maxValue)
     pokemon.typeOverride1 = rand(PBTypes.maxValue)
     pokemon.typeOverride2 = rand(PBTypes.maxValue)
         mean = rand(1..5)   if $Trainer.numbadges == 0
         mean = rand(10..15) if $Trainer.numbadges == 1
         mean = rand(16..24) if $Trainer.numbadges == 2
         mean = rand(20..29) if $Trainer.numbadges == 3
         mean = rand(30..43) if $Trainer.numbadges == 4
         mean = rand(35..43) if $Trainer.numbadges == 5
         mean = rand(40..47) if $Trainer.numbadges == 6
         mean = rand(40..50) if $Trainer.numbadges == 7
         mean = rand(50..75) if $Trainer.numbadges == 8
         level=mean
    pokemon.level=level
    pokemon.calcStats
   end
}

#Wild Pokemon in Delta Mode 
Events.onWildPokemonCreate+=proc {|sender,e|
   pokemon=e[0]
         mean = rand(1..5)   if $Trainer.numbadges == 0
         mean = rand(10..15) if $Trainer.numbadges == 1
         mean = rand(16..24) if $Trainer.numbadges == 2
         mean = rand(20..29) if $Trainer.numbadges == 3
         mean = rand(30..43) if $Trainer.numbadges == 4
         mean = rand(35..43) if $Trainer.numbadges == 5
         mean = rand(40..47) if $Trainer.numbadges == 6
         mean = rand(40..50) if $Trainer.numbadges == 7
         mean = rand(50..75) if $Trainer.numbadges == 8
         level=mean
    pokemon.level=level
    pokemon.calcStats
    pokemon.resetMoves
}
