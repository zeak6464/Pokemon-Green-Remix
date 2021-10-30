############################################
#    Simple Encounter List Window by raZ   #
#     Additions from Nuri Yuri, Vendily    #
#                  v1.2                    #
#   Icon edits + NatDex iter. by Zaffre    #
#     Updated to v18 by ThatWelshOne_      #
############################################
#    To use it, call the following         #
#    function:                             #
#                                          #
#    pbEncounterListUI                     #
############################################

PluginManager.register({
  :name => "Simple Encounter List UI",
  :version => "1.3",
  :credits => ["raZ","Nuri Yuri","Vendily","Savordez","Marin","PurpleZaffre","ThatWelshOne_"],
  :link => "https://reliccastle.com/resources/401/"
})

  # Currently known issues:
  # 1. Common crash if not starting from a new save.
  
  # Method that checks whether a specific form has been seen by the player
  def pbFormSeen?(species,form)
    return $Trainer.formseen[species][0][form] || 
      $Trainer.formseen[species][1][form]
  end
  
  # Method that checks whether a specific form is owned by the player
  def pbFormOwned?(species,form)
    return $Trainer.formowned[species][0][form] || 
      $Trainer.formowned[species][1][form]
  end
    
##############################################
### Setting up the new formowned variable  ###
##############################################

# In this class, we add a new bit of data that checks whether a specific form is owned by the player
class PokeBattle_Trainer
    attr_accessor :formowned

  # I'm not sure if this method is needed, but it's here anyway
  def numFormsOwned(species)
    species=getID(PBSpecies,species)
    return 0 if species<=0
    ret=0
    array=@formowned[species]
    for i in 0...[array[0].length,array[1].length].max
      ret+=1 if array[0][i] || array[1][i]
    end
    return ret
  end
  
  # Initiate empty arrays
  def clearPokedex
    @seen         = []
    @owned        = []
    @formseen     = []
    @formowned    = []
    @formlastseen = []
    for i in 1..PBSpecies.maxValue
      @seen[i]         = false
      @owned[i]        = false
      @formlastseen[i] = []
      @formseen[i]     = [[],[]]
      @formowned[i]     = [[],[]]
    end
  end

end

  # Need to add this method to all existing methods that updates the Pokédex
  # Being given a Pokémon, Pokémon evolving, catching a Pokémon, trading, eggs
  def pbOwnedForm(pkmn,gender=0,form=0)
  $Trainer.formowned     = [] if !$Trainer.formowned
  if pkmn.is_a?(PokeBattle_Pokemon)
    gender  = pkmn.gender
    form    = (pkmn.form rescue 0)
    species = pkmn.species
  else
    species = getID(PBSpecies,pkmn)
  end
  return if !species || species<=0
  fSpecies = pbGetFSpeciesFromForm(species,form)
  species, form = pbGetSpeciesFromFSpecies(fSpecies)
  gender = 0 if gender>1
  dexForm = pbGetSpeciesData(species,form,SpeciesPokedexForm)
  form = dexForm if dexForm>0
  fSpecies = pbGetFSpeciesFromForm(species,form)
  formName = pbGetMessage(MessageTypes::FormNames,fSpecies)
  form = 0 if !formName || formName==""
  $Trainer.formowned[species] = [[],[]] if !$Trainer.formowned[species]
  $Trainer.formowned[species][gender][form] = true
  end
  
###############################################################################
### The following methods have been edited to update the formowned variable ###
###############################################################################

  # NOTE: If you want the formowned variable to update when using debug to add 
  # Pokémon, etc., then you will need to add pbOwnedForm to the relevant methods
  # Not included here in case it breaks something
  
  # Also, if you use any third party scripts that overwrite these methods, then
  # you will need to add pbOwnedForm to those as well

  # Gift Pokémon
  def pbAddPokemon(pokemon,level=nil,seeform=true,ownform=true)
  return if !pokemon
  if pbBoxesFull?
    pbMessage(_INTL("There's no more room for Pokémon!\1"))
    pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return false
  end
  pokemon = getID(PBSpecies,pokemon)
  if pokemon.is_a?(Integer) && level.is_a?(Integer)
    pokemon = pbNewPkmn(pokemon,level)
  end
  speciesname = PBSpecies.getName(pokemon.species)
  pbMessage(_INTL("\\me[Pkmn get]{1} obtained {2}!\1",$Trainer.name,speciesname))
  pbNicknameAndStore(pokemon)
  pbSeenForm(pokemon) if seeform
  pbOwnedForm(pokemon) if ownform # Edit
  return true
  end

  # Silently gift Pokémon
  def pbAddPokemonSilent(pokemon,level=nil,seeform=true,ownform=true)
  return false if !pokemon || pbBoxesFull?
  pokemon = getID(PBSpecies,pokemon)
  if pokemon.is_a?(Integer) && level.is_a?(Integer)
    pokemon = pbNewPkmn(pokemon,level)
  end
  $Trainer.seen[pokemon.species]  = true
  $Trainer.owned[pokemon.species] = true
  pbSeenForm(pokemon) if seeform
  pbOwnedForm(pokemon) if ownform # Edit
  pokemon.pbRecordFirstMoves
  if $Trainer.party.length<6
    $Trainer.party[$Trainer.party.length] = pokemon
  else
    $PokemonStorage.pbStoreCaught(pokemon)
  end
  return true
  end
  
  # Adding Pokémon to party
  def pbAddToParty(pokemon,level=nil,seeform=true,ownform=true)
  return false if !pokemon || $Trainer.party.length>=6
  pokemon = getID(PBSpecies,pokemon)
  if pokemon.is_a?(Integer) && level.is_a?(Integer)
    pokemon = pbNewPkmn(pokemon,level)
  end
  speciesname = PBSpecies.getName(pokemon.species)
  pbMessage(_INTL("\\me[Pkmn get]{1} obtained {2}!\1",$Trainer.name,speciesname))
  pbNicknameAndStore(pokemon)
  pbSeenForm(pokemon) if seeform
  pbOwnedForm(pokemon) if ownform # Edit
  return true
  end
  
  # Silently adding Pokémon to party
  def pbAddToPartySilent(pokemon,level=nil,seeform=true,ownform=true)
  return false if !pokemon || $Trainer.party.length>=6
  pokemon = getID(PBSpecies,pokemon)
  if pokemon.is_a?(Integer) && level.is_a?(Integer)
    pokemon = pbNewPkmn(pokemon,level)
  end
  $Trainer.seen[pokemon.species]  = true
  $Trainer.owned[pokemon.species] = true
  pbSeenForm(pokemon) if seeform
  pbOwnedForm(pokemon) if ownform # Edit
  pokemon.pbRecordFirstMoves
  $Trainer.party[$Trainer.party.length] = pokemon
  return true
  end

  # Adding foreign Pokémon like Shuckie
  def pbAddForeignPokemon(pokemon,level=nil,ownerName=nil,nickname=nil,ownerGender=0,seeform=true,ownform=true)
  return false if !pokemon || $Trainer.party.length>=6
  pokemon = getID(PBSpecies,pokemon)
  if pokemon.is_a?(Integer) && level.is_a?(Integer)
    pokemon = pbNewPkmn(pokemon,level)
  end
  # Set original trainer to a foreign one (if ID isn't already foreign)
  if pokemon.trainerID==$Trainer.id
    pokemon.trainerID = $Trainer.getForeignID
    pokemon.ot        = ownerName if ownerName && ownerName!=""
    pokemon.otgender  = ownerGender
  end
  # Set nickname
  pokemon.name = nickname[0,PokeBattle_Pokemon::MAX_POKEMON_NAME_SIZE] if nickname && nickname!=""
  # Recalculate stats
  pokemon.calcStats
  if ownerName
    pbMessage(_INTL("\\me[Pkmn get]{1} received a Pokémon from {2}.\1",$Trainer.name,ownerName))
  else
    pbMessage(_INTL("\\me[Pkmn get]{1} received a Pokémon.\1",$Trainer.name))
  end
  pbStorePokemon(pokemon)
  $Trainer.seen[pokemon.species]  = true
  $Trainer.owned[pokemon.species] = true
  pbSeenForm(pokemon) if seeform
  pbOwnedForm(pokemon) if ownform # Edit
  return true
  end

  # Hatching an egg
  def pbHatch(pokemon)
  speciesname = pokemon.speciesName
  pokemon.name           = speciesname
  pokemon.trainerID      = $Trainer.id
  pokemon.ot             = $Trainer.name
  pokemon.happiness      = 120
  pokemon.timeEggHatched = pbGetTimeNow
  pokemon.obtainMode     = 1   # hatched from egg
  pokemon.hatchedMap     = $game_map.map_id
  $Trainer.seen[pokemon.species]  = true
  $Trainer.owned[pokemon.species] = true
  pbSeenForm(pokemon)
  pbOwnedForm(pokemon) # Edit
  pokemon.pbRecordFirstMoves
  if !pbHatchAnimation(pokemon)
    pbMessage(_INTL("Huh?\1"))
    pbMessage(_INTL("...\1"))
    pbMessage(_INTL("... .... .....\1"))
    pbMessage(_INTL("{1} hatched from the Egg!",speciesname))
    if pbConfirmMessage(_INTL("Would you like to nickname the newly hatched {1}?",speciesname))
      nickname = pbEnterPokemonName(_INTL("{1}'s nickname?",speciesname),
         0,PokeBattle_Pokemon::MAX_POKEMON_NAME_SIZE,"",pokemon)
      pokemon.name = nickname if nickname!=""
    end
  end
end

class PokemonEvolutionScene

  # Evolution
  def pbEvolutionSuccess
    # Play cry of evolved species
    frames = pbCryFrameLength(@newspecies,@pokemon.form)
    pbBGMStop
    pbPlayCrySpecies(@newspecies,@pokemon.form)
    frames.times do
      Graphics.update
      pbUpdate
    end
    # Success jingle/message
    pbMEPlay("Evolution success")
    newspeciesname = PBSpecies.getName(@newspecies)
    oldspeciesname = PBSpecies.getName(@pokemon.species)
    pbMessageDisplay(@sprites["msgwindow"],
       _INTL("\\se[]Congratulations! Your {1} evolved into {2}!\\wt[80]",
       @pokemon.name,newspeciesname)) { pbUpdate }
    @sprites["msgwindow"].text = ""
    # Check for consumed item and check if Pokémon should be duplicated
    pbEvolutionMethodAfterEvolution
    # Modify Pokémon to make it evolved
    @pokemon.species = @newspecies
    @pokemon.name    = newspeciesname if @pokemon.name==oldspeciesname
    @pokemon.form    = 0 if @pokemon.isSpecies?(:MOTHIM)
    @pokemon.calcStats
    # See and own evolved species
    $Trainer.seen[@newspecies]  = true
    $Trainer.owned[@newspecies] = true
    pbSeenForm(@pokemon)
    pbOwnedForm(@pokemon) # Edit
    # Learn moves upon evolution for evolved species
    movelist = @pokemon.getMoveList
    for i in movelist
      next if i[0]!=0 && i[0]!=@pokemon.level   # 0 is "learn upon evolution"
      pbLearnMove(@pokemon,i[1],true) { pbUpdate }
    end
  end
  
  # I think this is for Pokémon like Shedinja?
  def self.pbDuplicatePokemon(pkmn, new_species)
    new_pkmn = pkmn.clone
    new_pkmn.species  = new_species
    new_pkmn.name     = PBSpecies.getName(new_species)
    new_pkmn.markings = 0
    new_pkmn.ballused = 0
    new_pkmn.setItem(0)
    new_pkmn.clearAllRibbons
    new_pkmn.calcStats
    new_pkmn.heal
    # Add duplicate Pokémon to party
    $Trainer.party.push(new_pkmn)
    # See and own duplicate Pokémon
    $Trainer.seen[new_species]  = true
    $Trainer.owned[new_species] = true
    pbSeenForm(new_pkmn)
    pbOwnedForm(new_pkmn) # Edit
  end
  
end

  # Trading
  def pbStartTrade(pokemonIndex,newpoke,nickname,trainerName,trainerGender=0)
  myPokemon = $Trainer.party[pokemonIndex]
  opponent = PokeBattle_Trainer.new(trainerName,trainerGender)
  opponent.setForeignID($Trainer)
  yourPokemon = nil; resetmoves = true
  if newpoke.is_a?(PokeBattle_Pokemon)
    newpoke.trainerID = opponent.id
    newpoke.ot        = opponent.name
    newpoke.otgender  = opponent.gender
    newpoke.language  = opponent.language
    yourPokemon = newpoke
    resetmoves = false
  else
    if newpoke.is_a?(String) || newpoke.is_a?(Symbol)
      raise _INTL("Species does not exist ({1}).",newpoke) if !hasConst?(PBSpecies,newpoke)
      newpoke = getID(PBSpecies,newpoke)
    end
    yourPokemon = pbNewPkmn(newpoke,myPokemon.level,opponent)
  end
  yourPokemon.name       = nickname
  yourPokemon.obtainMode = 2   # traded
  yourPokemon.resetMoves if resetmoves
  yourPokemon.pbRecordFirstMoves
  $Trainer.seen[yourPokemon.species]  = true
  $Trainer.owned[yourPokemon.species] = true
  pbSeenForm(yourPokemon)
  pbOwnedForm(yourPokemon) # Edit
  pbFadeOutInWithMusic {
    evo = PokemonTrade_Scene.new
    evo.pbStartScreen(myPokemon,yourPokemon,$Trainer.name,opponent.name)
    evo.pbTrade
    evo.pbEndScreen
  }
  $Trainer.party[pokemonIndex] = yourPokemon
  end

module PokeBattle_BattleCommon
  # Catching
  def pbRecordAndStoreCaughtPokemon
    @caughtPokemon.each do |pkmn|
      pbSeenForm(pkmn)   # In case the form changed upon leaving battle
      pbOwnedForm(pkmn) # Edit
      # Record the Pokémon's species as owned in the Pokédex
      if !pbPlayer.hasOwned?(pkmn.species)
        pbPlayer.setOwned(pkmn.species)
        if $Trainer.pokedex
          pbDisplayPaused(_INTL("{1}'s data was added to the Pokédex.",pkmn.name))
          @scene.pbShowPokedex(pkmn.species)
        end
      end
      # Record a Shadow Pokémon's species as having been caught
      if pkmn.shadowPokemon?
        pbPlayer.shadowcaught = [] if !pbPlayer.shadowcaught
        pbPlayer.shadowcaught[pkmn.species] = true
      end
      # Store caught Pokémon
      pbStorePokemon(pkmn)
    end
    @caughtPokemon.clear
  end
end

##########################
### Encounter list UI  ###
##########################

# This is the name of a graphic in your Graphics/Pictures folder that changes the look of the UI
# If the graphic does not exist, you will get an error
WINDOWSKIN = "encounters.png"

# This array allows you to overwrite the names of your encounter types if you want them to be more logical
# E.g. "Surfing" instead of "Water"
# By default, the method uses the encounter type names in the EncounterTypes module
#NAMES = ["Grass", "Cave", "Surfing", "Rock Smash", "Fishing (Old Rod)",
#      "Fishing (Good Rod)", "Fishing (Super Rod)", "Headbutt (Low)",
#      "Headbutt (High)", "Grass (morning)", "Grass (day)", "Grass (night)",
#      "Bug Contest"]
NAMES = nil

# Controls whether Deerling's seasonal form is used for the UI
DEERLING = true

class EncounterListUI_withforms
  def initialize
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @encarray1 = []
    @encarray2 = []
    @index = 0
    @encdata = load_data("Data/encounters.dat")
    @mapid = $game_map.map_id
  end
 
  def pbStartMenu
    getEncData
    if !File.file?("Graphics/Pictures/"+WINDOWSKIN)
      raise _INTL("You are missing the graphic for this UI. Make sure the image is in your Graphics/Pictures folder and that it is named appropriately.")
    end
    @sprites["background"] = IconSprite.new(0,0,@viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/"+WINDOWSKIN)
    @sprites["background"].ox = @sprites["background"].bitmap.width/2
    @sprites["background"].oy = @sprites["background"].bitmap.height/2
    @sprites["background"].x = Graphics.width/2; @sprites["background"].y = Graphics.height/2
    @sprites["background"].opacity = 200
    @sprites["locwindow"] = Window_AdvancedTextPokemon.new("")
    @sprites["locwindow"].viewport = @viewport
    @sprites["locwindow"].width = 512
    @sprites["locwindow"].height = 344
    @sprites["locwindow"].x = (Graphics.width - @sprites["locwindow"].width)/2
    @sprites["locwindow"].y = (Graphics.height - @sprites["locwindow"].height)/2
    @sprites["locwindow"].windowskin = nil
    @h = (Graphics.height - @sprites["background"].bitmap.height)/2
    @w = (Graphics.width - @sprites["background"].bitmap.width)/2
    if !@num_enc
      loctext = _INTL("<ac><c2=43F022E8>{1}</c2></ac>", $game_map.name)
      loctext += sprintf("<al><c2=7FF05EE8>This area has no encounters!</c2></al>")
      loctext += sprintf("<c2=63184210>-----------------------------------------</c2>")
      @sprites["locwindow"].setText(loctext)
      main3
    else
      if !NAMES.nil? # If NAMES is not nil
        @name = NAMES[@type[@index]] # Pull string from NAMES array
      else
        @name = [EncounterTypes::Names].flatten[@type[@index]] # Otherwise, use default names
      end
      loctext = _INTL("<ac><c2=43F022E8>{1}: {2}</c2></ac>", $game_map.name,@name)
      i = 0
      @encarray2.each do |specie| # Loops over internal IDs of encounters on current map     
        fSpecies = pbGetSpeciesFromFSpecies(specie) # Array of internal ID of base form and form ID of specie
        if !pbFormSeen?(fSpecies[0],fSpecies[1]) && !pbFormOwned?(fSpecies[0],fSpecies[1])
          @sprites["icon_#{i}"] = PokemonSpeciesIconSprite.new(0,@viewport)
        elsif !pbFormOwned?(fSpecies[0],fSpecies[1])
          @sprites["icon_#{i}"] = PokemonSpeciesIconSprite.new(fSpecies[0],@viewport)
          @sprites["icon_#{i}"].pbSetParams(fSpecies[0],0,fSpecies[1],false)
          @sprites["icon_#{i}"].tone = Tone.new(0,0,0,255)
        else
          @sprites["icon_#{i}"] = PokemonSpeciesIconSprite.new(fSpecies[0],@viewport)
          @sprites["icon_#{i}"].pbSetParams(fSpecies[0],0,fSpecies[1],false)
        end
        if i > 6 && i < 14
          @sprites["icon_#{i}"].y = @h + 100 + 64
          @sprites["icon_#{i}"].x = @w + 28 + (64*(i-7))
        elsif i > 13
          @sprites["icon_#{i}"].y = @h + 100 + 128
          @sprites["icon_#{i}"].x = @w + 28 + (64*(i-14))
        else
          @sprites["icon_#{i}"].y = @h + 100
          @sprites["icon_#{i}"].x = @w + 28 + 64*i
        end
        i +=1         
      end
      loctext += sprintf("<al><c2=7FF05EE8>Total encounters for area: %s</c2></al>",@encarray2.length)
      loctext += sprintf("<c2=63184210>-----------------------------------------</c2>")
      @sprites["locwindow"].setText(loctext)
      @sprites["rightarrow"] = AnimatedSprite.new("Graphics/Pictures/rightarrow",8,40,28,2,@viewport)
      @sprites["rightarrow"].x = Graphics.width - @sprites["rightarrow"].bitmap.width
      @sprites["rightarrow"].y = Graphics.height/2 - @sprites["rightarrow"].bitmap.height/16
      @sprites["rightarrow"].visible = false
      @sprites["rightarrow"].play
      @sprites["leftarrow"] = AnimatedSprite.new("Graphics/Pictures/leftarrow",8,40,28,2,@viewport)
      @sprites["leftarrow"].x = 0
      @sprites["leftarrow"].y = Graphics.height/2 - @sprites["rightarrow"].bitmap.height/16
      @sprites["leftarrow"].visible = false
      @sprites["leftarrow"].play
      main1
    end
  end
 
  def pbListOfEncounters(encounter) # This method is from Nuri Yuri
    return [] unless encounter
   
    encable = encounter.compact # Remove nils
    #encable.map! { |enc_list| enc_list.map { |enc| enc[0] } }
    encable.map! {|enc| enc[0]} # Pull first element from each array
    encable.flatten! # Transform array of arrays into array
    encable.uniq! # Prevent duplication
   
    return encable
  end
 
  def getEncData
    if @encdata.is_a?(Hash) && @encdata[@mapid]
      enc = @encdata[@mapid][1]
      @num_enc = enc.compact.length # Number of defined encounter types on current map
      @type = (0...enc.length).reject {|i| enc[i].nil? } # Array indices of non-nil array elements
      @first = enc.index(enc.find { |i| !i.nil? } || false) # From Yuri to get index of first non-nil array element
      enctypes = enc[@type[@index]]
      @encarray1 = pbListOfEncounters(enctypes)
      temp = []
      @encarray1.each_with_index do |s,i| # Funky method for grouping forms with their base forms
        if (isConst?(s,PBSpecies,:DEERLING) || 
          isConst?(s,PBSpecies,:SAWSBUCK)) && DEERLING
          @encarray1[i] = pbGetFSpeciesFromForm(s,pbGetSeason)
        end
        fSpecies = pbGetSpeciesFromFSpecies(s)
        temp.push(fSpecies[0] + fSpecies[1]*0.001)
      end
      temp_sort = temp.sort
      id = temp_sort.map{|s| temp.index(s)}
      @encarray2 = []
      for i in 0..@encarray1.length-1
        @encarray2[i] = @encarray1[id[i]]
      end
    else
      @encarray2 = [7]
    end
  end
  
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end
  
  def pbShift
    for i in 0...@encarray2.length
      @sprites["icon_#{i}"].dispose
    end
  end
  
  def main1
    loop do
      Graphics.update
      Input.update
      pbUpdate
        if @first == @type[@index] && @num_enc >1 # If first page and there are more pages
          @sprites["leftarrow"].visible=false
          @sprites["rightarrow"].visible=true
        elsif @index == @type.length-1 && @num_enc >1 # If last page and there is more than one page
          @sprites["leftarrow"].visible=true
          @sprites["rightarrow"].visible=false
        end
        if Input.trigger?(Input::RIGHT) && @num_enc >1 && @index< @num_enc-1
          pbPlayCursorSE
          @index += 1
          pbShift # Dispose sprites
          main2
          @sprites["leftarrow"].visible=true
          @sprites["rightarrow"].visible=true
        elsif Input.trigger?(Input::LEFT) && @num_enc >1 && @index !=0
          pbPlayCursorSE
          @index -= 1
          pbShift # Dispose sprites
          main2
          @sprites["leftarrow"].visible=true
          @sprites["rightarrow"].visible=true
        elsif Input.trigger?(Input::C) || Input.trigger?(Input::B)
          pbPlayCloseMenuSE
          break
        end
      end
    dispose
  end
 
  def main2
    getEncData
    if !NAMES.nil?
      @name = NAMES[@type[@index]]
    else
      @name = [EncounterTypes::Names].flatten[@type[@index]]
    end
    loctext = _INTL("<ac><c2=43F022E8>{1}: {2}</c2></ac>", $game_map.name,@name)
    i = 0
    @encarray2.each do |specie| # Loops over internal IDs of encounters on current map     
      fSpecies = pbGetSpeciesFromFSpecies(specie) # Array of internal ID of base form and form ID of specie
      if !pbFormSeen?(fSpecies[0],fSpecies[1]) && !pbFormOwned?(fSpecies[0],fSpecies[1])
        @sprites["icon_#{i}"] = PokemonSpeciesIconSprite.new(0,@viewport)
      elsif !pbFormOwned?(fSpecies[0],fSpecies[1])
        @sprites["icon_#{i}"] = PokemonSpeciesIconSprite.new(fSpecies[0],@viewport)
        @sprites["icon_#{i}"].pbSetParams(fSpecies[0],0,fSpecies[1],false)
        @sprites["icon_#{i}"].tone = Tone.new(0, 0, 0, 255)
      else
        @sprites["icon_#{i}"] = PokemonSpeciesIconSprite.new(fSpecies[0],@viewport)
        @sprites["icon_#{i}"].pbSetParams(fSpecies[0],0,fSpecies[1],false)
      end
      if i > 6 && i < 14
        @sprites["icon_#{i}"].y = @h + 100 + 64
        @sprites["icon_#{i}"].x = @w + 28 + (64*(i-7))
      elsif i > 13
        @sprites["icon_#{i}"].y = @h + 100 + 128
        @sprites["icon_#{i}"].x = @w + 28 + (64*(i-14))
      else
        @sprites["icon_#{i}"].y = @h + 100
        @sprites["icon_#{i}"].x = @w + 28 + 64*i
      end
      i +=1         
    end
    loctext += sprintf("<al><c2=7FF05EE8>Total encounters for area: %s</c2></al>",@encarray2.length)
    loctext += sprintf("<c2=63184210>-----------------------------------------</c2>")
    @sprites["locwindow"].setText(loctext)
  end
  
  def main3
    loop do
      Graphics.update
      Input.update
      if Input.trigger?(Input::C) || Input.trigger?(Input::B)
        pbPlayCloseMenuSE
        break
      end
    end
    dispose
  end
  
  def dispose
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

###############################################
### Cleaner way of calling the class method ###
###############################################

  def pbEncounterListUI
    EncounterListUI_withforms.new.pbStartMenu
  end