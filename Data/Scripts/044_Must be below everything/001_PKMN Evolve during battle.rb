class PokeBattle_Battle
  alias evolution_during_battle pbGainExpOne
  def pbGainExpOne(idxParty,defeatedBattler,numPartic,expShare,expAll,showMessages=true)
    pkmn = pbParty(0)[idxParty]
    oldlevel = pkmn.level
    evolution_during_battle(idxParty,defeatedBattler,numPartic,expShare,expAll,showMessages)
    # New
    return if pkmn.level==oldlevel
    battler = pbFindBattler(idxParty)
    newSpecies = pbCheckEvolution(pkmn)
    return if newSpecies<=0
    previousBGM = $game_system.getPlayingBGM
    # Evolution
    evo = PokemonEvolutionScene.new
    evo.pbStartScreen(pkmn,newSpecies)
    evo.pbEvolution
    evo.pbEndScreen
    if battler
      @scene.pbChangePokemon(@battlers[battler.index],@battlers[battler.index].pokemon)
      battler.pbInitPokemon(pkmn,battler.pokemonIndex)
      battler.name = battler.name
      battler.pbUpdate(false)
      @scene.pbRefreshOne(battler.index)
    end
    $PokemonTemp.evolutionLevels = []
    (0...$Trainer.party.length).each { |i| $PokemonTemp.evolutionLevels[i] = $Trainer.party[i].level}
    pbBGMPlay(previousBGM)
  end
end