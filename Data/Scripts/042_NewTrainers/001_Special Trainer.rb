DP_TEAM_LIST = [:DARKPLAYER]

RIVAL_TEAM_LIST = [:RIVAL,:CHAMPION]

GYME4_TEAM_LIST = [:LEADER_BROCK,:LEADER_MISTY,:LEADER_SURGE,:LEADER_ERIKA,
  :LEADER_SABRINA,:LEADER_KOGA,:LEADER_BLAINE,:LEADER_GIOVANNI,:ELITE_LORELEI,
  :ELITE_BRUNO,:ELITE_AGATHA,:ELITE_LANCE,:ELITE_ASH]
  
EVIL_TEAM_LIST = [:TEAMROCKET_Male,:TEAMROCKET_Female,:TEAMROCKET_f,:TEAMROCKET_m,
  :TEAMROCKET_JJ]
  
DELTA_TEAM_LIST = [:RainbowROCKET_Male,:RainbowROCKET_Female,:PkMnTRAINER_Wally,:TournamentTrainer_Male,
  :TournamentTrainer_Female,:PARTNER,:YOUTUBER4,:ZETA,:YOUTUBER7]  

BlackListedPokemon = [PBSpecies::ARTICUNO, PBSpecies::ZAPDOS, PBSpecies::MOLTRES,
PBSpecies::MEW, PBSpecies::MEWTWO]

WhiteListedPokemon = []
  
Events.onTrainerPartyLoad+=proc {|sender,e|
   if e[0] # Trainer data should exist to be loaded, but may not exist somehow
     trainer=e[0][0] # A PokeBattle_Trainer object of the loaded trainer
     items=e[0][1]   # An array of the trainer's items they can use
     party=e[0][2]   # An array of the trainer's Pokémon
  ids=DP_TEAM_LIST
  balance=false
  ids.each{|item|balance|=isConst?(trainer.trainertype,PBTrainers,item)}
     if balance
       party = $Trainer.party
     end
   end
}

############################################################


Events.onTrainerPartyLoad+=proc {|sender,e|
   if e[0] # Trainer data should exist to be loaded, but may not exist somehow
     trainer=e[0][0] # A PokeBattle_Trainer object of the loaded trainer
     items=e[0][1]   # An array of the trainer's items they can use
     party=e[0][2]   # An array of the trainer's Pokémon
     ids=RIVAL_TEAM_LIST
     balance=false
     ids.each{|item|balance|=isConst?(trainer.trainertype,PBTrainers,item)
     }
       # Starter Pokemon
       if balance 
        party.each{|poke| 
         mean = rand(1..5)   if $Trainer.numbadges == 0
         mean = rand(10..21) if $Trainer.numbadges == 1
         mean = rand(17..24) if $Trainer.numbadges == 2
         mean = rand(20..29) if $Trainer.numbadges == 3
         mean = rand(30..43) if $Trainer.numbadges == 4
         mean = rand(35..43) if $Trainer.numbadges == 5
         mean = rand(40..47) if $Trainer.numbadges == 6
         mean = rand(40..55) if $Trainer.numbadges == 7
         mean = rand(50..75) if $Trainer.numbadges == 8
         party[0].species = $game_variables[999]
         species = party[0].species
         newspecies = pbGetBabySpecies(species) if $Trainer.numbadges <= 3
         party[0].species = newspecies if $Trainer.numbadges <= 3
         poke.name = PBSpecies.getName(poke.species)
         level=mean
         poke.level=level
         poke.calcStats
         poke.resetMoves
         }
     end
   end
}

############################################################


Events.onTrainerPartyLoad+=proc {|sender,e|
   if e[0] # Trainer data should exist to be loaded, but may not exist somehow
     trainer=e[0][0] # A PokeBattle_Trainer object of the loaded trainer
     items=e[0][1]   # An array of the trainer's items they can use
     party=e[0][2]   # An array of the trainer's Pokémon
  # Gym Leader / E4 Battles 
  ids=GYME4_TEAM_LIST
  balance=false
  ids.each{|item|balance|=isConst?(trainer.trainertype,PBTrainers,item)
     }
     if balance
       party.each{|poke|
         mean = rand(10..15) if $Trainer.numbadges == 0
         mean = rand(16..21) if $Trainer.numbadges == 1
         mean = rand(17..24) if $Trainer.numbadges == 2
         mean = rand(20..29) if $Trainer.numbadges == 3
         mean = rand(30..40) if $Trainer.numbadges == 4
         mean = rand(35..45) if $Trainer.numbadges == 5
         mean = rand(40..55) if $Trainer.numbadges == 6
         mean = rand(40..65) if $Trainer.numbadges == 7
         mean = rand(50..75) if $Trainer.numbadges == 8
         level=mean
         poke.level=level
         poke.calcStats
         poke.resetMoves
       }
     end
   end
}


############################################################

  

Events.onTrainerPartyLoad+=proc {|sender,e|
   if e[0] # Trainer data should exist to be loaded, but may not exist somehow
     trainer=e[0][0] # A PokeBattle_Trainer object of the loaded trainer
     items=e[0][1]   # An array of the trainer's items they can use
     party=e[0][2]   # An array of the trainer's Pokémon
  # Gym Leader / E4 Battles 
  ids=EVIL_TEAM_LIST
  balance=false
  ids.each{|item|balance|=isConst?(trainer.trainertype,PBTrainers,item)
     }
     if balance
       party.each{|poke|
         mean = rand(1..5) if $Trainer.numbadges == 0
         mean = rand(10..15) if $Trainer.numbadges == 1
         mean = rand(16..24) if $Trainer.numbadges == 2
         mean = rand(20..29) if $Trainer.numbadges == 3
         mean = rand(30..43) if $Trainer.numbadges == 4
         mean = rand(35..43) if $Trainer.numbadges == 5
         mean = rand(40..47) if $Trainer.numbadges == 6
         mean = rand(40..50) if $Trainer.numbadges == 7
         mean = rand(50..75) if $Trainer.numbadges == 8
      if WhiteListedPokemon.length == 0
          poke.species = rand(151 - 1) + 1
        while BlackListedPokemon.include?(poke.species)
          poke.species = rand(151 - 1) + 1
        end
      end 
         newspecies = pbGetBabySpecies(poke.species) if $Trainer.numbadges <= 3
         poke.species = newspecies if $Trainer.numbadges <= 3
         poke.name = PBSpecies.getName(poke.species)
         level=mean
         poke.level=level
         poke.calcStats
         poke.resetMoves
       }
     end
   end
}

##########################################################


Events.onTrainerPartyLoad+=proc {|sender,e|
   if e[0] # Trainer data should exist to be loaded, but may not exist somehow
     trainer=e[0][0] # A PokeBattle_Trainer object of the loaded trainer
     items=e[0][1]   # An array of the trainer's items they can use
     party=e[0][2]   # An array of the trainer's Pokémon
     ids=DELTA_TEAM_LIST
     balance=false
     ids.each{|item|
        balance|=isConst?(trainer.trainertype,PBTrainers,item)
     }
     if balance
          party.each{|poke|
          level = rand(1..5)   if $Trainer.numbadges == 0
          level = rand(10..15) if $Trainer.numbadges == 1
          level = rand(16..24) if $Trainer.numbadges == 2
          level = rand(20..29) if $Trainer.numbadges == 3
          level = rand(30..43) if $Trainer.numbadges == 4
          level = rand(35..43) if $Trainer.numbadges == 5
          level = rand(38..47) if $Trainer.numbadges == 6
          level = rand(40..50) if $Trainer.numbadges == 7
          level = rand(1..100) if $Trainer.numbadges == 8
         poke.species = rand(PBSpecies.maxValue) +1 
         poke.level=level
         poke.makeDeltap
         poke.pbRandomMoves
         poke.abilityOverride = rand(PBAbilities.maxValue)
         poke.typeOverride1 = rand(PBTypes.maxValue)
         poke.typeOverride2 = rand(PBTypes.maxValue)
         poke.calcStats
       }
     end
   end
     }
     
##########################################################

Events.onTrainerPartyLoad+=proc {|sender,e|
   if e[0] # Trainer data should exist to be loaded, but may not exist somehow
     trainer=e[0][0] # A PokeBattle_Trainer object of the loaded trainer
     items=e[0][1]   # An array of the trainer's items they can use
     party=e[0][2]   # An array of the trainer's Pokémon
     if $PokemonSystem.delta == 1
       party.each{|poke|
          level = rand(1..9)   if $Trainer.numbadges == 0
          level = rand(10..15) if $Trainer.numbadges == 1
          level = rand(16..24) if $Trainer.numbadges == 2
          level = rand(20..29) if $Trainer.numbadges == 3
          level = rand(30..43) if $Trainer.numbadges == 4
          level = rand(35..43) if $Trainer.numbadges == 5
          level = rand(38..47) if $Trainer.numbadges == 6
          level = rand(40..50) if $Trainer.numbadges == 7
          level = rand(1..100) if $Trainer.numbadges == 8
         poke.level=level
         poke.makeDeltap
         poke.pbRandomMoves
         poke.abilityOverride = rand(PBAbilities.maxValue)
         poke.typeOverride1 = rand(PBTypes.maxValue)
         poke.typeOverride2 = rand(PBTypes.maxValue)
         poke.calcStats
       }
     end
   end
      }

Events.onTrainerPartyLoad+=proc {|sender,e|
   if e[0] # Trainer data should exist to be loaded, but may not exist somehow
     trainer=e[0][0] # A PokeBattle_Trainer object of the loaded trainer
     items=e[0][1]   # An array of the trainer's items they can use
     party=e[0][2]   # An array of the trainer's Pokémon
     if $PokemonSystem.randm == 1
       party.each{|poke|
          level = rand(1..9)   if $Trainer.numbadges == 0
          level = rand(10..15) if $Trainer.numbadges == 1
          level = rand(16..24) if $Trainer.numbadges == 2
          level = rand(20..29) if $Trainer.numbadges == 3
          level = rand(30..43) if $Trainer.numbadges == 4
          level = rand(35..43) if $Trainer.numbadges == 5
          level = rand(38..47) if $Trainer.numbadges == 6
          level = rand(40..50) if $Trainer.numbadges == 7
          level = rand(50..100) if $Trainer.numbadges == 8
         poke.level = level
         poke.species = rand(PBSpecies.maxValue) + 1
         poke.name = PBSpecies.getName(poke.species)
         poke.calcStats
         poke.resetMoves
       }
     end
   end
      } 