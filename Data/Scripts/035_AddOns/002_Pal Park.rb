  def pbPlayerPark
  #v is the veriable for the box number
  v = pbGet(301)
  #29 is the max number of speices in box
for i in 0...29
  if @temptrainer[v] && @temptrainer[v][i]
    #var is the species 
    var = @temptrainer[v][i].species.to_s
  if @temptrainer[v][i].isShiny?
    pbMoveRoute($game_map.events[i + 3], [PBMoveRoute::Graphic, var +"s", 0, 8, 0])
  elsif @temptrainer[v][i].isDeltap? 
    pbMoveRoute($game_map.events[i + 3], [PBMoveRoute::Graphic, var , 300, 8, 0])
  elsif @temptrainer[v][i].isShiny? && @temptrainer[v][i].isDeltap? 
    pbMoveRoute($game_map.events[i + 3], [PBMoveRoute::Graphic, var +"s", 300, 8, 0])
  elsif @temptrainer[v][i].form == 1 
    pbMoveRoute($game_map.events[i + 3], [PBMoveRoute::Graphic, var + "_" + form, 0, 8, 0])
  elsif @temptrainer[v][i].isShiny? &&  @temptrainer[v][i].form == 1 
    pbMoveRoute($game_map.events[i + 3], [PBMoveRoute::Graphic, var + "s" + "_" + form, 0, 8, 0])  
  elsif @temptrainer[v][i].isDeltap? && @temptrainer[v][i].form == 1
    pbMoveRoute($game_map.events[i + 3], [PBMoveRoute::Graphic, var + "_" + form , 300, 8, 0])
  elsif @temptrainer[v][i].isShiny? && @temptrainer[v][i].isDeltap? && @temptrainer[v][i].form == 1
    pbMoveRoute($game_map.events[i + 3], [PBMoveRoute::Graphic, var + "s" + "_" + form, 300, 8, 0])  
  else
    pbMoveRoute($game_map.events[i + 3], [PBMoveRoute::Graphic, var, 0, 8, 0])
   end
 end
end
end


 
  
def pbFriendPark
  @youtrainer=$PokemonStorage
  savefile="Migration/Game.rxdata"
  File.open(savefile){|f|
           14.times { Marshal.load(f) }  
           $PokemonStorage = Marshal.load(f)
    }
  @temptrainer=$PokemonStorage
  $PokemonStorage=@youtrainer
  #v is the veriable for the box number
   v = pbGet(301)
  #29 is the max number of speices in box
for i in 0...29
  if @temptrainer[v] && @temptrainer[v][i]
    #var is the species 
    var = @temptrainer[v][i].species.to_s
  if @temptrainer[v][i].isShiny?
    pbMoveRoute($game_map.events[i + 3], [PBMoveRoute::Graphic, var +"s", 0, 8, 0])
  elsif @temptrainer[v][i].isDeltap? 
    pbMoveRoute($game_map.events[i + 3], [PBMoveRoute::Graphic, var , 300, 8, 0])
  elsif @temptrainer[v][i].isShiny? && @temptrainer[v][i].isDeltap? 
    pbMoveRoute($game_map.events[i + 3], [PBMoveRoute::Graphic, var +"s", 300, 8, 0])
  elsif @temptrainer[v][i].form == 1 
    pbMoveRoute($game_map.events[i + 3], [PBMoveRoute::Graphic, var + "_" + form, 0, 8, 0])
  elsif @temptrainer[v][i].isShiny? &&  @temptrainer[v][i].form == 1  
    pbMoveRoute($game_map.events[i + 3], [PBMoveRoute::Graphic, var + "s" + "_" + form, 0, 8, 0])  
  elsif @temptrainer[v][i].isDeltap? && @temptrainer[v][i].form == 1 
    pbMoveRoute($game_map.events[i + 3], [PBMoveRoute::Graphic, var + "_" + form , 300, 8, 0])
  elsif @temptrainer[v][i].isShiny? && @temptrainer[v][i].isDeltap? && @temptrainer[v][i].form == 1 
    pbMoveRoute($game_map.events[i + 3], [PBMoveRoute::Graphic, var + "s" + "_" + form, 300, 8, 0])  
  else
    pbMoveRoute($game_map.events[i + 3], [PBMoveRoute::Graphic, var, 0, 8, 0])
   end
 end
end   
end



def pbImportPokemon
  @youtrainer=$PokemonStorage
  savefile="Migration/Game.rxdata"
  File.open(savefile){|f|
           14.times { Marshal.load(f) }  
           $PokemonStorage = Marshal.load(f)
    }
  @temptrainer=$PokemonStorage
  $PokemonStorage=@youtrainer
  #v is the veriable for the box number
  v = pbGet(301)
  i = pbGet(299)
  pkmn = @temptrainer[v][i]
  pbStorePokemon(pkmn)
  Kernel.pbMessage(_INTL("{1} obtained {2}!\1",$Trainer.name,pkmn.name))
end



def pbForceEvo(pokemon)
  for form in pbGetEvolvedFormData(pokemon.species)
    newspecies=form[2]
  end
  return if !newspecies
  if pokemon.species == 52 && pokemon.form==2
    newspecies = (pokemon.species = 863)
    evo=PokemonEvolutionScene.new
    evo.pbStartScreen(pokemon,newspecies)
    evo.pbEvolution
    evo.pbEndScreen
    pokemon.name = PBSpecies.getName(pokemon.species)
  elsif pokemon.species == 83 && pokemon.form==1
    newspecies = (pokemon.species = 865)
    evo=PokemonEvolutionScene.new
    evo.pbStartScreen(pokemon,newspecies)
    evo.pbEvolution
    evo.pbEndScreen
    pokemon.name = PBSpecies.getName(pokemon.species)
  elsif pokemon.species == 264 && pokemon.form==1
    newspecies = (pokemon.species = 862)
    evo=PokemonEvolutionScene.new
    evo.pbStartScreen(pokemon,newspecies)
    evo.pbEvolution
    evo.pbEndScreen
    pokemon.name = PBSpecies.getName(pokemon.species)
  elsif pokemon.species == 222 && pokemon.form==1
    newspecies = (pokemon.species = 864)
    evo=PokemonEvolutionScene.new
    evo.pbStartScreen(pokemon,newspecies)
    evo.pbEvolution
    evo.pbEndScreen
    pokemon.name = PBSpecies.getName(pokemon.species)
  elsif pokemon.species == 122 && pokemon.form==1
    newspecies = (pokemon.species = 866)
    evo=PokemonEvolutionScene.new
    evo.pbStartScreen(pokemon,newspecies)
    evo.pbEvolution
    evo.pbEndScreen
    pokemon.name = PBSpecies.getName(pokemon.species)
  elsif newspecies>0
    evo=PokemonEvolutionScene.new
    evo.pbStartScreen(pokemon,newspecies)
    evo.pbEvolution
    evo.pbEndScreen
  end
end