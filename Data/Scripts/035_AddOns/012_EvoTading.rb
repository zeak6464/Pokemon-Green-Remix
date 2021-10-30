def pbEvolveTrading()
choices=[
  _INTL("Yes"),
  _INTL("No")
]
choice=Kernel.pbMessage("Would you like me to evolve one of your pokemon?",choices,0)
if choice == 0
  pbChoosePokemon(1,2)
    pokemon = $Trainer.pokemonParty[pbGet(1)]
    pbStartTrade(pbGet(1), PBSpecies::RATTATA, "Rattata","Melvin")
    Kernel.pbMessage("Thanks, now to trade back")
    pbStartTradeEvo(pbGet(1), pokemon, "Melvin")
  end
end


  

def pbStartTradeEvo(pokemonIndex,newpoke,name)

myPokemon=$Trainer.party[pokemonIndex]

opponent=PokeBattle_Trainer.new($Trainer.name,$Trainer.gender)

yourPokemon=nil; resetmoves=true

if newpoke.is_a?(PokeBattle_Pokemon)

  yourPokemon=newpoke

else

  if newpoke.is_a?(String) || newpoke.is_a?(Symbol)

    raise _INTL("Species does not exist ({1}).",newpoke) if !hasConst?(PBSpecies,newpoke)

    newpoke=getID(PBSpecies,newpoke)

  end

  yourPokemon=PokeBattle_Pokemon.new(newpoke,myPokemon.level,opponent)

end

yourPokemon.pbRecordFirstMoves

$Trainer.seen[yourPokemon.species]=true

$Trainer.owned[yourPokemon.species]=true

pbSeenForm(yourPokemon)

pbFadeOutInWithMusic(99999){

  evo=PokemonTrade_Scene.new

  evo.pbStartScreen(myPokemon,yourPokemon,$Trainer.name,name)

  evo.pbTrade

  evo.pbEndScreen

}

$Trainer.party[pokemonIndex]=yourPokemon

end