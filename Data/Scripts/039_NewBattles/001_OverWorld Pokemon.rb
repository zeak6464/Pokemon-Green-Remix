#===============================================================================
# * Visible Overworld Encounters V2.0.4 for PEv18 - by derFischae (Credits if used please) *
#===============================================================================
#
# UPDATED TO VERSION 2.0.4.
#
# As in Pokemon Let's go Pikachu/Eevee or Pokemon Shild and Sword
# random encounters pop up on the overworld,
# they move around and you can start the battle
# with them simply by moving to the pokemon.
# Clearly, you also can omit the battle by circling around them.
#
# This script is for Pokémon Essentials v18 (for short PEv18). 
#
# FEATURES INCLUDED:
#   - see the pokemon on the overworld before going into battle
#   - no forced battling against random encounters
#   - plays the pokemon cry while spawning
#   - Choose whether encounters occure on all terrains or only on 
#     the terrain of the player
#   - you can have instant wild battle and overworld spawning at the same time and set the propability of that by default
#     and change it ingame and store it with a $game_variable
#   - In caves, pokemon don't spawn on impassable Rock-Tiles, which have the Tile-ID 4 
#   - You can check during the events @@OnWildPokemonCreate, @@OnStartBattle, ... if you are battling a spawned pokemon with the global variable $PokemonGlobal.battlingSpawnedPokemon
#   - You can check during the event @@OnWildPokemonCreate if the pokemon is created for spawning on the map or created for a different reason with the Global variable $PokemonGlobal.creatingSpawningPokemon
#   - If you want to add a procedure that modifies a pokemon only for spawning but not before battling
#     then you can use the Event @@OnWildPokemonCreateForSpawning.
#
# There are various add-ons and modifications of this script for Pokemon Essentials v17.2.
# But I don't know jet, which one still work with Pokemon Essentials v18.
# And probably there are some bugs due to the update to PEv18.
# So feel free to post your bugs.

# ADD-ONS OF THIS SCRIPT:
# In the post https://www.pokecommunity.com/showthread.php?t=429019 you will also find add-ons, including
#  - Vendilys Rescue Chain and JoelMatthews Add-Ons for Vendilys Rescue Chain,
#    See https://www.pokecommunity.com/showthread.php?t=415524 and
#    https://www.pokecommunity.com/showthread.php?t=422513 for original scripts
#  - Let's go chiny hunting by chaining a pokemon, inspired by Diego Mertens script
#    https://www.pokecommunity.com/showthread.php?p=10011513
#  - Automatic Spawning
#  - randomized spawning
#  - always shiny spawning
#  - instructions on how to make your own Add-On or to modify an already existing script
#    to make it work with the visible overworld wild encounter script.
#    This includes modifying a pokemon on spawning but not on battling again, 
#    by using the events OnStartBattle, OnWildPokemonCreate and OnWildPokemonCreateForSpawning
#  - Joltiks Level Balance, see https://www.pokecommunity.com/showthread.php?t=409828 for original post
#
# MODIFICATIONS OF THIS SCRIPT FOR PEv17.2:
# Read the whole thread https://www.pokecommunity.com/showthread.php?t=429019 for more features and modifications, including
#  - adding shiny sparkle animation to spawned overworld shinys, especially useful if you want to sign out the shiny encounters on the map without using overworld shiny sprites
#  - removing grass rustle animation on water and in caves
#  - forbidding pokemon to spawn on specific terrain tiles in caves
#  - adding new encounter types, eg. desert, shallow water
#  - instructions on how to have different encounters for overworld spawning and original encountering on the same map
#  - error solutions
# Feel free to test it with PEv18.
#
# NEW FEATURES FROM VERSION 2.0.4 FOR PEv18:
#   - encounters dont spawn on impassable tiles in caves
#
# NEW FEATURES FROM VERSION 2.0.3 FOR PEv18:
#   - poke radar works as usual
#
# NEW FEATURES FROM VERSION 2.0.2 FOR PEv18:
#   - added new global variable $PokemonGlobal.creatingSpawningPokemon to check during the event @@OnWildPokemonCreate if the pokemon is created for spawning on the map or created for a different reason
#
# UPSCALED FEATURES FROM VERSION 2.0.1 FOR PEv17.2:
#   - less lag
#   - supports sprites for alternative forms of pokemon
#   - supports sprites for female/male/genderless pokemon
#   - bug fixes for roaming encounter and double battles
#   - more options in settings
#   - roaming encounters working correctly
#   - more lag reduction 
#   - included automatic spawning of pokemon, i.e. spawning without having to move the player
#   - included vendilys rescue chain, i. e. if pokemon of the same species family spawn in a row and will be battled in a row, then you increase the chance of spawning
#     an evolved pokemon of that species family. Link: https://www.pokecommunity.com/showthread.php?t=415524
#   - removed bug occuring after fainting against wild overworld encounter
#   - for script-developers, shortened the spawnEvent method for better readablitiy
#   - removed bugs from version 1.9
#   - added shapes of overworld encounter for rescue chain users
#   - supports spawning of alternate forms while chaining
#   - if overworld sprites for alternative, female or shiny forms are missing,
#     then the standard sprite will be displayed instead of an invisible event
#   - bug fix for shiny encounters
#   - respecting shiny state for normal encounters when using overworld and normal encounters at the same time
#   - easier chaining concerning Vendilys Rescue chain, i.e. no more resetting of the chain when spawning of a pokemon of different family but when fighting with a pokemon of different family
#   - Added new Event @@OnPokemonCreateForSpawning which only triggers on spawning
#   - Added new global variable $PokemonGlobal.battlingSpawnedShiny to check if an active battle is against a spawned pokemon.
#   - removed bug to make the new features in version 1.11 work
#   - reorganised and thin out the code to organise code as add-ons
#   - removed Vendilys Rescue Chain, Let's Go Shiny Hunting and automatic spawning as hard coded feature and provide it as Add-Ons instead
#   - Now, using overworld and normal encounters at the same time is a standard feature
#   - autospawning will not trigger instant battles anymore
#   - removed a bug that came from reorganising the code in original code and add-ons concerning Let's go shiny hunting add-on
#
# INSTALLATION:
# Installation as simple as it can be.
# Step 1) You need sprites for the overworld pokemon in your \Graphics\Characters
# folder named by there number 001.png, 002.png, ...,
# For instance you can use Gen 1-7 OV SPrites or whatever you want for your fakemon
# If you want to use shiny overworld sprites for shiny encounters, then make sure
# to also have the corresponding shiny versions in your \Graphics\Characters
# folder named by 001s.png, 002s.png, ....
# If you want to use alternative forms as overworld sprites, then make sure that
# you also have a sprite for each alternative form, e. g. for Unown 201_1.png, 
# 201s_1.png, 201_2.png, 201s_2.png, ...
# Please note that Scatterbug has 18 alternative forms in Pokemon Essentials. 
# But you will only see one form depending on your trainerID. 
# So, you also have to include 664_1.png, ..., 664_19.png and 664s_1.png, ..., 664s_19.png. 
# Same needs to be done for Pokemon Spewpa with number 665 and Vivillon with number 666. 
# If you want to use female forms as overworld sprites, then make sure that you 
# also have a female sprite for each pokemon named 001f.png, 001fs.png, 002f.png, 
# 002fs.png, ... (excluding genderless pokemon of course)
# Step 2) Insert a new file in the script editor above main,
# name it Overworld_Random_Encounters and copy this code into it. 
# Step 3) If you want then you can also install the script always in bush and in water
# to obtain that the overworld encounter don't stand on water anymore but sink in.
# You can find it at https://www.pokecommunity.com/showthread.php?p=10109060
# 
# PROPERTIES:
# 1) If you want to have water encounters only while surfing,
# you also have to change the value of the
# upcoming parameter RESTRICTENCOUNTERSTOPLAYERMOVEMENT to
#     RESTRICTENCOUNTERSTOPLAYERMOVEMENT = true
# 2) You can choose how many steps the encounter moves before vanishing 
# in parameter
#     STEPSBEFOREVANISHING
# 3) You can choose whether the overworld sprite of an shiny encounter
# is always the standard sprite or is the corrensponding shiny overworld sprite  in parameter
#     USESHINYSPRITES
# 4) You can choose whether the sprite of your overworld encounter
# is always the standard sprite or can be an alternative form in parameter
#     USEALTFORMS
# 5) You can choose whether the sprites depend on the gender of the encounter
# or are always neutral in parameter
#     USEFEMALESPRITES
# 6) You can choose whether the overworld encounters have a stop/ step-animation
# similar to following pokemon in the parameter
#     USESTOPANIMATION
# 7) You can choose how many overworld encounters are agressive and run to the 
# player in the parameter
#     AGGRESSIVEENCOUNTERPROBABILITY
# 8) You can choose the move-speed and move-frequenzy of  normal and aggressive 
# encounters in parameters
#     ENCMOVESPEED, ENCMOVEFREQ, AGGRENCMOVESPEED, AGGRENCMOVEFREQ
# 9) You can have normal and overworld encountering at the same time.
# You can set the default propability in percentage in the parameter
#     INSTANT_WILD_BATTLE_PROPABILITY
# 10) The actual propability of normal to overworld encountering during game is stored in 
#     $game_variables[OVERWORLD_ENCOUNTER_VARIABLE]
# and you can change its value during playtime.
# 11) If you want to change the ID of the $game_variable that saves the current propability of normal to overworld encountering,
# then you can change it in parameter
#     OVERWORLD_ENCOUNTER_VARIABLE
# Make sure that no other script uses and overrides the value of the game_variable with that ID.
# 12) If you have impassable tiles in a cave, where you don't want pokemon to spawn there. Then choose the Tile-ID 4 for that tile in the tile-editor.
#
# THANKS to BulbasaurLvl5 for bringing me to pokemon essentials

#===============================================================================
#                             Settings            
#===============================================================================




# default is an ID which is not used anywhere else
# This parameter stores the ID of the $game_variable which holds the propability
# of normal to overworld encountering.
# Make sure that no other script uses the $game_variable with this ID,
# except for the visible overworld wild encounter script itself and its add-ons.
#
# The $game_variable with the ID equal to OVERWORLD_ENCOUNTER_VARIABLE is used 
# to store the propability of an instant (normal) wild battle.
# You can modify the value of that $game_variable during game or with events as usual. It is similar to use
# game switches. See the Pokemon Essentials manual for more informations.
# The propability is stored the following way
# $game_variables[OVERWORLD_ENCOUNTER_VARIABLE] = 0
#    - the propability of instant battle to spawning will be equal to the value 
# of INSTANT_WILD_BATTLE_PROPABILITY in percentage, see below
# $game_variables[OVERWORLD_ENCOUNTER_VARIABLE] < 0
#    - means only overworld encounters, no instant battles
# $game_variables[OVERWORLD_ENCOUNTER_VARIABLE] > 0 and < 100
#    - means overworld encounters and normal encounters at the same time,
#      where the value equals the propability of normal encounters in percentage
# $game_variables[OVERWORLD_ENCOUNTER_VARIABLE] >= 100 
#    - means only normal encounters and instant battles as usual, no overworld spawning

RESTRICTENCOUNTERSTOPLAYERMOVEMENT = false
#true - means that water encounters are popping up
#       if and only if player is surfing
#       (perhaps decreases encounter rate)
#false - means that all encounter types can pop up
#        close to the player (as long as there is a suitable tile)

STEPSBEFOREVANISHING = 6 # default 10
#      STEPSBEFOREVANISHING is the number of steps a wild Encounter goes
#      before vanishing on the map.

USESHINYSPRITES = true # default true
#false - means that you don't use shiny sprites for your overworld encounter
#true - means that a shiny encounter will have a its special shiny overworld sprite
#       make sure that you have the shiny sprites named with an "s" (e.g. 001s.png) 
#       for the shiny forms in your \Graphics\Characters folder       

USEALTFORMS = true # default true
#false - means that you don't use alternative forms for your overworld sprite
#true - means that the sprite of overworld encounter varies by the form of that pokemon
#       make sure that you have the sprites with the right name
#       for your alternative forms in your \Graphics\Characters folder       

USEFEMALESPRITES = true # default true
#false - means that you use always a neutral overworld sprite
#true - means that female pokemon have there own female overworld sprite
#       make sure that you have the sprites with the right name 001f.png,
#       001fs.png, ... for the female forms in your \Graphics\Characters folder

USESTOPANIMATION = true # default true
#false - means that overworld encounters don't have a stop- animation
#true - means that overworld encounters have a stop- animation similar as  
#       following pokemon

ENCMOVESPEED = 3 # default 3
# this is the movement speed (compare to autonomous movement of events) of an overworld encounter
#1   - means lowest movement
#6   - means highest movement

ENCMOVEFREQ = 3 # default 3
# this is the movement frequenzy (compare to autonomous movement of events) of an overworld encounter
#1   - means lowest movement
#6   - means highest movement

AGGRESSIVEENCOUNTERPROBABILITY = 20 # default 20 
#this is the probability in percent of spawning of an agressive encounter
#0   - means that there are no aggressive encounters
#100 - means that all encounter are aggressive

AGGRENCMOVESPEED = 3 # default 3
# this is the movement speed (compare to autonomous movement of events) of an aggressive encounter
#1   - means lowest movement
#6   - means highest movement

AGGRENCMOVEFREQ = 5 # default 5
# this is the movement frequenzy (compare to autonomous movement of events) of an aggressive encounter
#1   - means lowest movement
#6   - means highest movement


#===============================================================================
#                              THE SCRIPT
#===============================================================================

          #########################################################
          #                                                       #
          #      1. PART: SPAWNING THE OVERWORLD ENCOUNTER        #
          #                                                       #
          #########################################################
#===============================================================================
# We override the original method "pbOnStepTaken" in Script PField_Field it was 
# originally used for random encounter battles
#===============================================================================
def pbOnStepTaken(eventTriggered)
  #Should it be possible to search for pokemon nearby?
  if $game_player.move_route_forcing || pbMapInterpreterRunning? # || !$Trainer
    Events.onStepTakenFieldMovement.trigger(nil,$game_player)
    return
  end
  $PokemonGlobal.stepcount = 0 if !$PokemonGlobal.stepcount
  $PokemonGlobal.stepcount += 1
  $PokemonGlobal.stepcount &= 0x7FFFFFFF
  # Start wild overworld/mixed encounters while turning on the spot
Events.onChangeDirection += proc {
  repel = ($PokemonGlobal.repel>0)
  if !$game_temp.in_menu
    if $PokemonSystem.OWP == 0
      if $PokemonSystem.OWP > 0 && $PokemonSystem.OWP < 100
        $PokemonSystem.OWP = $PokemonSystem.OWP
      elsif $PokemonSystem.OWP >= 100
        $PokemonSystem.OWP = 100
      else
        $PokemonSystem.OWP = -1
      end
    end
    if $PokemonSystem.OWP>0 && ($PokemonSystem.OWP>=100 || rand(100) < $PokemonSystem.OWP)
      #STANDARD WILDBATTLE
      pbBattleOnStepTaken(repel)
    else
      #OVERWORLD ENCOUNTERS
      #we choose the tile on which the pokemon appears
      pos = pbChooseTileOnStepTaken
      return if !pos
      #we choose the random encounter
      encounter,gender,form,isShiny = pbChooseEncounter(pos[0],pos[1],repel)
      return if !encounter
      #we generate an random encounter overworld event
      pbPlaceEncounter(pos[0],pos[1],encounter,gender,form,isShiny)
    end
  end
}
end
  
#===============================================================================
# new method pbChooseTileOnStepTaken to choose the tile on which the pkmn spawns 
#===============================================================================
def pbChooseTileOnStepTaken
  # Choose 1 random tile from 1 random ring around the player
  i = rand(4)
  r = rand((i+1)*8)
  x = $game_player.x
  y = $game_player.y
  if r<=(i+1)*2
    x = $game_player.x-i-1+r
    y = $game_player.y-i-1
  elsif r<=(i+1)*6-2
    x = [$game_player.x+i+1,$game_player.x-i-1][r%2]
    y = $game_player.y-i+((r-1-(i+1)*2)/2).floor
  else
    x = $game_player.x-i+r-(i+1)*6
    y = $game_player.y+i+1
  end
  #check if it is possible to encounter here
  return if x<0 || x>=$game_map.width || y<0 || y>=$game_map.height #check if the tile is on the map
  #check if it's a valid grass, water or cave etc. tile
  return if PBTerrain.isIce?($game_map.terrain_tag(x,y))
  return if PBTerrain.isLedge?($game_map.terrain_tag(x,y))
  return if PBTerrain.isWaterfall?($game_map.terrain_tag(x,y))
  return if PBTerrain.isRock?($game_map.terrain_tag(x,y))
  if RESTRICTENCOUNTERSTOPLAYERMOVEMENT
    return if !PBTerrain.isWater?($game_map.terrain_tag(x,y)) && 
              $PokemonGlobal && $PokemonGlobal.surfing
    return if PBTerrain.isWater?($game_map.terrain_tag(x,y)) && 
              !($PokemonGlobal && $PokemonGlobal.surfing)
  end
  #check if tile is passable
  for i in [2, 1, 0]
    tile_id = $game_map.data[x, y, i]
    terrain = $game_map.terrain_tags[tile_id]
    passage = $game_map.passages[tile_id]
    if terrain!=PBTerrain::Neutral
      if passage & 0x0f == 0x0f
        return
      elsif $game_map.priorities[tile_id] == 0
        break
      end
    end
  end
  return [x,y]
end

#===============================================================================
# defining new method pbChooseEncounter to choose the pokemon on the tile (x,y)
#===============================================================================
def pbChooseEncounter(x,y,repel=false)
  return if $Trainer.ablePokemonCount==0   #check if trainer has pokemon
  encounterType = $PokemonEncounters.pbEncounterTypeOnTile(x,y)
  return if encounterType<0 #check if there are encounters
  return if !$PokemonEncounters.isEncounterPossibleHereOnTile?(x,y)
  $PokemonTemp.encounterType = encounterType
  for event in $game_map.events.values
    if event.x==x && event.y==y
      return
    end
  end
  encounter = $PokemonEncounters.pbGenerateEncounter(encounterType)
  encounter = EncounterModifier.trigger(encounter)
  if !$PokemonEncounters.pbCanEncounter?(encounter,repel)
    $PokemonTemp.forceSingleBattle = false
    EncounterModifier.triggerEncounterEnd()
    return
  end
  form = nil
  gender = nil
  $PokemonGlobal.creatingSpawningPokemon = true
  pokemon = pbGenerateWildPokemon(encounter[0],encounter[1])
  # trigger event on spawning of pokemon
  Events.onWildPokemonCreateForSpawning.trigger(nil,pokemon)
  $PokemonGlobal.creatingSpawningPokemon = false
  encounter = [pokemon.species,pokemon.level]
  gender = pokemon.gender if USEFEMALESPRITES==true
  form = pokemon.form if USEALTFORMS == true  
  isShiny = pokemon.isShiny?
  return encounter,gender,form,isShiny
end

#===============================================================================
# defining new method pbPlaceEncounter to add/place and visualise the pokemon
# "encounter" on the overworld-tile (x,y)
#===============================================================================
def pbPlaceEncounter(x,y,encounter,gender = nil,form = nil,isShiny = nil)
  # place event with random movement with overworld sprite
  # We define the event, which has the sprite of the pokemon and activates the wildBattle on touch
  if !$MapFactory
    $game_map.spawnEvent(x,y,encounter,gender,form,isShiny)
  else
    mapId = $game_map.map_id
    spawnMap = $MapFactory.getMap(mapId)
    spawnMap.spawnEvent(x,y,encounter,gender,form,isShiny)
  end
  # Show grass rustling animations
  $scene.spriteset.addUserAnimation(RUSTLE_NORMAL_ANIMATION_ID,x,y,true,1)
  # Play the pokemon cry of encounter
  pbPlayCryOnOverworld(encounter[0])
  # For roaming encounters we have to do the following:
  if $PokemonTemp.roamerIndex != nil && 
     $PokemonGlobal.roamEncounter != nil
    $PokemonGlobal.roamEncounter = nil
    $PokemonGlobal.roamedAlready = true
  end
  $PokemonTemp.forceSingleBattle = false
  EncounterModifier.triggerEncounterEnd()
end

#===============================================================================
# adding new Methods pbEncounterTypeOnTile and isEncounterPossibleHereOnTile?
# in Class PokemonEncounters in Script PField_Encounters
#===============================================================================
class PokemonEncounters
  def pbEncounterTypeOnTile(x,y)
    if PBTerrain.isJustWater?($game_map.terrain_tag(x,y))
      return EncounterTypes::Water
    elsif self.isCave?
      return EncounterTypes::Cave
    elsif self.isGrass?
      time = pbGetTimeNow
      enctype = EncounterTypes::Land
      enctype = EncounterTypes::LandNight if self.hasEncounter?(EncounterTypes::LandNight) && PBDayNight.isNight?(time)
      enctype = EncounterTypes::LandDay if self.hasEncounter?(EncounterTypes::LandDay) && PBDayNight.isDay?(time)
      enctype = EncounterTypes::LandMorning if self.hasEncounter?(EncounterTypes::LandMorning) && PBDayNight.isMorning?(time)
      if pbInBugContest? && self.hasEncounter?(EncounterTypes::BugContest)
        enctype = EncounterTypes::BugContest
      end
      return enctype
    end
    return -1
  end
  
  def isEncounterPossibleHereOnTile?(x,y)
    if PBTerrain.isJustWater?($game_map.terrain_tag(x,y))
      return true
    elsif self.isCave?
      return true
    elsif self.isGrass?
      return PBTerrain.isGrass?($game_map.terrain_tag(x,y))
    end
    return false
  end
end

#===============================================================================
# new Method spawnEvent in Class Game_Map in Script Game_Map
#===============================================================================
class Game_Map
  def spawnEvent(x,y,encounter,gender = nil,form = nil, isShiny = nil)
    #------------------------------------------------------------------
    # generating a new event
    event = RPG::Event.new(x,y)
    # naming the event "vanishingEncounter" for PART 3 
    event.name = "vanishingEncounter"
    #setting the nessassary properties
    key_id = (@events.keys.max || -1) + 1
    event.id = key_id
    event.x = x
    event.y = y
    #event.pages[0].graphic.tile_id = 0
    encounter[0] = rand(PBSpecies.maxValue)+1 if $PokemonSystem.randm == 1
    if encounter[0] < 10
      character_name = "00"+encounter[0].to_s
    elsif encounter[0] < 100
      character_name = "0"+encounter[0].to_s
    else
      character_name = encounter[0].to_s
    end
    # use sprite of female pokemon
    character_name = character_name+"f" if USEFEMALESPRITES == true and gender==1 and pbResolveBitmap("Graphics/Characters/"+character_name+"f")
    # use shiny-sprite if probability & killcombo is high or shiny-switch is on
    shinysprite = nil
    if isShiny==true
      character_name = character_name+"s" if USESHINYSPRITES == true and pbResolveBitmap("Graphics/Characters/"+character_name+"s")
      shinysprite = true
    end
    # use sprite of alternative form
    if USEALTFORMS==true and form!=nil and form!=0
      character_name = character_name+"_"+form.to_s if pbResolveBitmap("Graphics/Characters/"+character_name+"_"+form.to_s)
    end
    event.pages[0].graphic.character_name = character_name
    event.pages[0].graphic.character_hue = 300 if $PokemonSystem.delta == 1
    # we configure the movement of the overworld encounter
    if rand(100) < AGGRESSIVEENCOUNTERPROBABILITY
      event.pages[0].move_type = 3
      event.pages[0].move_speed = AGGRENCMOVESPEED
      event.pages[0].move_frequency = AGGRENCMOVEFREQ
      event.pages[0].move_route.list[0].code = 10
      event.pages[0].move_route.list[1] = RPG::MoveCommand.new
    else
      event.pages[0].move_type = 1
      event.pages[0].move_speed = ENCMOVESPEED
      event.pages[0].move_frequency = ENCMOVEFREQ
    end
    event.pages[0].step_anime = true if USESTOPANIMATION
    event.pages[0].trigger = 2
    #------------------------------------------------------------------
    # we add the event commands to the event of the overworld encounter
    # set roamer
    if $PokemonGlobal.roamEncounter!=nil
      #[i,species,poke[1],poke[4]]
      parameter1 = $PokemonGlobal.roamEncounter[0].to_s
      parameter2 = $PokemonGlobal.roamEncounter[1].to_s
      parameter3 = $PokemonGlobal.roamEncounter[2].to_s
      $PokemonGlobal.roamEncounter[3] != nil ? (parameter4 = '"'+$PokemonGlobal.roamEncounter[3].to_s+'"') : (parameter4 = "nil")
      parameter = " $PokemonGlobal.roamEncounter = ["+parameter1+","+parameter2+","+parameter3+","+parameter4+"] "
    else
      parameter = " $PokemonGlobal.roamEncounter = nil "
    end
    pbPushScript(event.pages[0].list,sprintf(parameter))
    parameter = ($PokemonTemp.roamerIndex!=nil) ? " $PokemonTemp.roamerIndex = "+$PokemonTemp.roamerIndex.to_s : " $PokemonTemp.roamerIndex = nil "
    pbPushScript(event.pages[0].list,sprintf(parameter))
    #parameter = ($PokemonGlobal.nextBattleBGM!=nil) ? " $PokemonGlobal.nextBattleBGM = '"+$PokemonGlobal.nextBattleBGM.to_s+"'" : " $PokemonGlobal.nextBattleBGM = nil "
    #pbPushScript(event.pages[0].list,sprintf(parameter))
    parameter = ($PokemonTemp.forceSingleBattle!=nil) ? " $PokemonTemp.forceSingleBattle = "+$PokemonTemp.forceSingleBattle.to_s : " $PokemonTemp.forceSingleBattle = nil "
    pbPushScript(event.pages[0].list,sprintf(parameter))
    parameter = ($PokemonTemp.encounterType!=nil) ? " $PokemonTemp.encounterType = "+$PokemonTemp.encounterType.to_s : " $PokemonTemp.encounterType = nil "
    pbPushScript(event.pages[0].list,sprintf(parameter))
    # setting $PokemonGlobal.battlingSpawnedPokemon = true
    pbPushScript(event.pages[0].list,sprintf(" $PokemonGlobal.battlingSpawnedPokemon = true"))    
    #pbSingleOrDoubleWildBattle(encounter[0],encounter[1])
    gender = "nil" if gender==nil
    form = "nil" if form==nil
    shinysprite = "nil" if shinysprite==nil
    pbPushScript(event.pages[0].list,sprintf(" pbSingleOrDoubleWildBattle("+encounter[0].to_s+","+encounter[1].to_s+", $game_map.events["+key_id.to_s+"].map.map_id, $game_map.events["+key_id.to_s+"].x, $game_map.events["+key_id.to_s+"].y,"+gender.to_s+","+form.to_s+","+shinysprite.to_s+")"))
    # setting $PokemonGlobal.battlingSpawnedPokemon = false
    pbPushScript(event.pages[0].list,sprintf(" $PokemonGlobal.battlingSpawnedPokemon = false"))        
    if !$MapFactory
      parameter = "$game_map.removeThisEventfromMap(#{key_id})"
    else
      mapId = $game_map.map_id
      parameter = "$MapFactory.getMap("+mapId.to_s+").removeThisEventfromMap(#{key_id})"
    end
    pbPushScript(event.pages[0].list,sprintf(parameter))
    pbPushEnd(event.pages[0].list)
    #------------------------------------------------------------------
    # creating and adding the Game_Event
    gameEvent = Game_Event.new(@map_id, event, self)
    key_id = (@events.keys.max || -1) + 1
    gameEvent.id = key_id
    gameEvent.moveto(x,y)
    @events[key_id] = gameEvent
    #-------------------------------------------------------------------------
    #updating the sprites
    sprite = Sprite_Character.new(Spriteset_Map.viewport,@events[key_id])
    $scene.spritesets[self.map_id].character_sprites.push(sprite)
  end
end

#===============================================================================
# adding new Method pbSingleOrDoubleWildBattle to reduce the code in spawnEvent
#===============================================================================
def pbSingleOrDoubleWildBattle(species,level,map_id,x,y,gender = nil,form = nil,shinysprite = nil)
  if $MapFactory
    terrainTag = $MapFactory.getTerrainTag(map_id,x,y)
  else
    terrainTag = $game_map.terrain_tag(x,y)
  end
  if !$PokemonTemp.forceSingleBattle && !pbInSafari? && ($PokemonGlobal.partner ||
       ($Trainer.ablePokemonCount>1 && PBTerrain.isDoubleWildBattle?(pbGetTerrainTag) && rand(100)<30))
      encounter2 = $PokemonEncounters.pbEncounteredPokemon($PokemonTemp.encounterType)
      encounter2 = EncounterModifier.trigger(encounter2)
      pbDoubleWildBattle(species,level,encounter2[0],encounter2[1],nil,true,false,gender,form,shinysprite,nil,nil,nil)
  else
    pbWildBattle(species,level,nil,true,false,gender,form,shinysprite)
  end
  $PokemonTemp.encounterType = -1
  $PokemonTemp.forceSingleBattle = false
  EncounterModifier.triggerEncounterEnd
end

#===============================================================================
# overriding Method pbWildBattleCore in Script PField_Battles
# to include alternate forms of the wild pokemon
#===============================================================================
def pbWildBattleCore(*args)
  outcomeVar = $PokemonTemp.battleRules["outcomeVar"] || 1
  canLose    = $PokemonTemp.battleRules["canLose"] || false
  # Skip battle if the player has no able Pokémon, or if holding Ctrl in Debug mode
  if $Trainer.ablePokemonCount==0 || ($DEBUG && Input.press?(Input::CTRL))
    pbMessage(_INTL("SKIPPING BATTLE...")) if $Trainer.pokemonCount>0
    pbSet(outcomeVar,1)   # Treat it as a win
    $PokemonTemp.clearBattleRules
    $PokemonGlobal.nextBattleBGM       = nil
    $PokemonGlobal.nextBattleME        = nil
    $PokemonGlobal.nextBattleCaptureME = nil
    $PokemonGlobal.nextBattleBack      = nil
    return 1   # Treat it as a win
  end
  # Record information about party Pokémon to be used at the end of battle (e.g.
  # comparing levels for an evolution check)
  Events.onStartBattle.trigger(nil)
  # Generate wild Pokémon based on the species and level
  foeParty = []
  sp = nil
  for arg in args
    if arg.is_a?(PokeBattle_Pokemon)
      foeParty.push(arg)
    elsif arg.is_a?(Array)
      species = getID(PBSpecies,arg[0])
      pkmn = pbGenerateWildPokemon(species,arg[1])
      #-----------------------------------------------------------------------------
      #added by derFischae to set the gender, form and shinyflag
      if arg.length()==5
        gender = arg[2]
        pkmn.setGender(gender) if USEFEMALESPRITES==true and gender!=nil and gender>=0 and gender<3
        form = arg[3]
        pkmn.form = form if USEALTFORMS==true and form!=nil and form>0
        shinyflag = arg[4]
        pkmn.shinyflag = shinyflag if shinyflag!=nil
      end
      # well actually it is not okay to test if form>0, we should also test if form 
      # is smaller than the maximal form, but for now I keep it that way. 
      #-----------------------------------------------------------------------------
      foeParty.push(pkmn)
    elsif sp
      species = getID(PBSpecies,sp)
      pkmn = pbGenerateWildPokemon(species,arg)
      foeParty.push(pkmn)
      sp = nil
    else
      sp = arg
    end
  end
  raise _INTL("Expected a level after being given {1}, but one wasn't found.",sp) if sp
  # Calculate who the trainers and their party are
  playerTrainers    = [$Trainer]
  playerParty       = $Trainer.party
  playerPartyStarts = [0]
  if $PokemonGlobal.partner && !$PokemonTemp.battleRules["noPartner"] && foeParty.length>1
    ally = PokeBattle_Trainer.new($PokemonGlobal.partner[1],$PokemonGlobal.partner[0])
    ally.id    = $PokemonGlobal.partner[2]
    ally.party = $PokemonGlobal.partner[3]
    playerTrainers.push(ally)
    playerParty = []
    $Trainer.party.each { |pkmn| playerParty.push(pkmn) }
    playerPartyStarts.push(playerParty.length)
    ally.party.each { |pkmn| playerParty.push(pkmn) }
  end
  # Create the battle scene (the visual side of it)
  scene = pbNewBattleScene
  # Create the battle class (the mechanics side of it)
  battle = PokeBattle_Battle.new(scene,playerParty,foeParty,playerTrainers,nil)
  battle.party1starts = playerPartyStarts
  # Set various other properties in the battle class
  pbPrepareBattle(battle)
  $PokemonTemp.clearBattleRules
  # Perform the battle itself
  decision = 0
  pbBattleAnimation(pbGetWildBattleBGM(foeParty),(foeParty.length==1) ? 0 : 2,foeParty) {
    pbSceneStandby {
      decision = battle.pbStartBattle
    }
    pbAfterBattle(decision,canLose)
  }
  Input.update
  # Save the result of the battle in a Game Variable (1 by default)
  #    0 - Undecided or aborted
  #    1 - Player won
  #    2 - Player lost
  #    3 - Player or wild Pokémon ran from battle, or player forfeited the match
  #    4 - Wild Pokémon was caught
  #    5 - Draw
  pbSet(outcomeVar,decision)
  return decision
end


#===============================================================================
# overriding Method pbWildBattle in Script PField_Battles
# to include alternate forms of the wild pokemon
#===============================================================================
  #-----------------------------------------------------------------------------
  #added by derFischae to set the gender, form and shinyflag
  #genwildpoke.setGender(gender) if USEFEMALESPRITES==true and gender!=nil and gender>=0 and gender<3
  #genwildpoke.form = form if USEALTFORMS==true and form!=nil and form>0
  #genwildpoke.shinyflag = shinysprite if shinysprite!=nil
  # well actually it is not okay to test if form>0, we should also test if form 
  # is smaller than the maximal form, but for now I keep it that way. 
  #-----------------------------------------------------------------------------

#===============================================================================
# Standard methods that start a wild battle of various sizes
#===============================================================================
# Used when walking in tall grass, hence the additional code.
def pbWildBattle(species, level, outcomeVar=1, canRun=true, canLose=false,gender = nil,form = nil,shinysprite = nil)
  species = getID(PBSpecies,species)
  # Potentially call a different pbWildBattle-type method instead (for roaming
  # Pokémon, Safari battles, Bug Contest battles)
  handled = [nil]
  Events.onWildBattleOverride.trigger(nil,species,level,handled)
  return handled[0] if handled[0]!=nil
  # Set some battle rules
  setBattleRule("outcomeVar",outcomeVar) if outcomeVar!=1
  setBattleRule("cannotRun") if !canRun
  setBattleRule("canLose") if canLose
  # Perform the battle
  decision = pbWildBattleCore([species,level,gender,form,shinysprite])
  # Used by the Poké Radar to update/break the chain
  Events.onWildBattleEnd.trigger(nil,species,level,decision)
  # Return false if the player lost or drew the battle, and true if any other result
  return (decision!=2 && decision!=5)
end

#===============================================================================
# overriding Method pbDoubleWildBattle in Script PField_Battles
# to include alternate forms of the wild pokemon in double battles
#===============================================================================
  #-----------------------------------------------------------------------------
  #added by derFischae to set the gender, form and shinyflag
  # well actually it is not okay to test if form>0, we should also test if form 
  # is smaller than the maximal form, but for now I keep it that way. 
  #genwildpoke.setGender(gender1) if USEFEMALESPRITES==true and gender1!=nil and gender1>=0 and gender1<3
  #if USEALTFORMS==true and form1!=nil and form1>0
  #  genwildpoke.form = form1   
  #  genwildpoke.shinyflag = shinysprite1 if shinysprite1!=nil
  #  genwildpoke.resetMoves
  #end
  #genwildpoke2.setGender(gender) if USEFEMALESPRITES==true and gender2!=nil and gender2>=0 and gender2<3
  #if USEALTFORMS==true and form2!=nil and form2>0
  #  genwildpoke2.form = form2 if USEALTFORMS==true and form2!=nil and form2>0  
  #  genwildpoke2.shinyflag = shinysprite2 if shinysprite2!=nil
  #  genwildpoke2.resetMoves
  #end
  #-----------------------------------------------------------------------------

def pbDoubleWildBattle(species1, level1, species2, level2,
                       outcomeVar=1, canRun=true, canLose=false,
                       gender1 = nil,form1 = nil,shinysprite1 = nil,gender2 = nil,form2 = nil,shinysprite2 = nil)
  # Set some battle rules
  setBattleRule("outcomeVar",outcomeVar) if outcomeVar!=1
  setBattleRule("cannotRun") if !canRun
  setBattleRule("canLose") if canLose
  setBattleRule("double")
  # Perform the battle
  decision = pbWildBattleCore([species1,level1,gender1,form1,shinysprite1], [species2,level2,gender2,form2,shinysprite2])
  # Return false if the player lost or drew the battle, and true if any other result
  return (decision!=2 && decision!=5)
end

#===============================================================================
# adding new method PBTerrain.isRock? to module PBTerrain in script PBTerrain
# to check if the terrainTag "tag" is rock
#===============================================================================
module PBTerrain
  def PBTerrain.isRock?(tag)
    return tag==PBTerrain::Rock
  end
end

#===============================================================================
# adding new method pbPlayCryOnOverworld to load/play Pokémon cry files 
# SPECIAL THANKS TO "Ambient Pokémon Cries" - by Vendily
# actually it's not used, but that code helped to include the pkmn cries faster
#===============================================================================
def pbPlayCryOnOverworld(pokemon,volume=90,pitch=nil)
  return if !pokemon
  if pokemon.is_a?(Numeric)
    pbPlayCrySpecies(pokemon,0,volume,pitch)
  elsif !pokemon.egg?
    if pokemon.respond_to?("chatter") && pokemon.chatter
      pokemon.chatter.play
    else
      pkmnwav = pbCryFile(pokemon)
      if pkmnwav
        pbBGSPlay(RPG::AudioFile.new(pkmnwav,volume,
           (pitch) ? pitch : (pokemon.hp*25/pokemon.totalhp)+75)) rescue nil
      end
    end
  end
end

#===============================================================================
# adding a new method attr_reader to the Class Spriteset_Map in Script
# Spriteset_Map to get access to the variable @character_sprites of a
# Spriteset_Map
#===============================================================================
class Spriteset_Map
  attr_reader :character_sprites
end

#===============================================================================
# adding a new method attr_reader to the Class Scene_Map in Script
# Scene_Map to get access to the Spriteset_Maps listed in the variable 
# @spritesets of a Scene_Map
#===============================================================================
class Scene_Map
  attr_reader :spritesets
end

          #########################################################
          #                                                       #
          #      2. PART: VANISHING OF OVERWORLD ENCOUNTER        #
          #                                                       #
          #########################################################
#===============================================================================
# adding a new variable stepCount and replacing the method increase_steps
# in class Game_Event in script Game_Event to count the steps of
# overworld encounter and to make them disappear after taking more then
# STEPSBEFOREVANISHING steps
#===============================================================================
class Game_Event < Game_Character
  attr_accessor :event
  attr_accessor :stepCount #counts the steps of an overworld encounter
  
  alias original_increase_steps increase_steps
  def increase_steps
    if self.name=="vanishingEncounter" && @stepCount && @stepCount>=STEPSBEFOREVANISHING
      removeThisEventfromMap
    else
      @stepCount=0 if (!@stepCount || @stepCount<0)
      @stepCount+=1
      original_increase_steps
    end
  end
  
  def removeThisEventfromMap
    if $game_map.events.has_key?(@id) and $game_map.events[@id]==self
      for sprite in $scene.spritesets[$game_map.map_id].character_sprites
        if sprite.character==self
          $scene.spritesets[$game_map.map_id].character_sprites.delete(sprite)
          sprite.dispose
          break
        end
      end
      $game_map.events.delete(@id)        
    else
      if $MapFactory
        for map in $MapFactory.maps
          if map.events.has_key?(@id) and map.events[@id]==self
            for sprite in $scene.spritesets[self.map_id].character_sprites
              if sprite.character==self
                $scene.spritesets[map.map_id].character_sprites.delete(sprite)
                sprite.dispose
                break
              end
            end
            map.events.delete(@id)
            break
          end
        end
      else
        Kernel.pbMessage("Actually, this should not be possible")
      end
    end
  end
end

class Game_Map
  def removeThisEventfromMap(id)
    if @events.has_key?(id)
      for sprite in $scene.spritesets[@map_id].character_sprites
        if sprite.character == @events[id]
          $scene.spritesets[@map_id].character_sprites.delete(sprite)
          sprite.dispose
          break
        end
      end
      @events.delete(id)        
    end
  end  
end

          #########################################################
          #                                                       #
          #             3. PART: ADDITIONAL FEATURES              #
          #                                                       #
          #########################################################

#===============================================================================
# Adding Event OnWildPokemonCreateForSpawning to Module Events in Script PField_Field.
# This Event is triggered  when a new pokemon spawns. Use this Event instead of OnWildPokemonCreate
# if you want to add a new procedure that modifies a pokemon on spawning 
# but not on creation while going into battle with an already spawned pokemon.
#Note that OnPokemonCreate is also triggered when a pokemon is created for spawning,
#But OnPokemonCreateForSpawning is not triggered when a pokemon is created in other situations than for spawning
#===============================================================================
module Events
  @@OnWildPokemonCreateForSpawning          = Event.new

  # Triggers whenever a wild Pokémon is created for spawning
  # Parameters: 
  # e[0] - Pokémon being created for spawning
  def self.onWildPokemonCreateForSpawning; @@OnWildPokemonCreateForSpawning; end
  def self.onWildPokemonCreateForSpawning=(v); @@OnWildPokemonCreateForSpawning = v; end

end

#===============================================================================
# adds new parameter battlingSpawnedPokemon to the class PokemonGlobalMetadata
# defined in script section PField_Metadata. Also overrides initialize include that parameter there.
#===============================================================================

class PokemonGlobalMetadata
  attr_accessor :battlingSpawnedPokemon
  attr_accessor :creatingSpawningPokemon

  alias original_initialize initialize
  def initialize
    battlingSpawnedPokemon = false
    creatingSpawningPokemon = false
    original_initialize
  end
end

#===============================================================================
# Add-On for automatic spawning without making a step * by derFischae
#===============================================================================

# This is an add-on for the visible overworld wild encounter script.
# It adds automatic pokemon spawning to the script.

# FEATURES INCLUDED:
# Choose whether pokemon spawn automatically or only while moving the player

# INSTALLATION:
# Copy this code and
# Paste it at the bottom of your visible wild overworld encounter script

# PROPERTIES:
# You can choose whether pokemon can spawn automatically or only while the 
# player is moving and you can set the spawning frequency in the parameter
#     AUTOSPAWNSPEED
# in the settings below

#===============================================================================
# Settings
#===============================================================================
AUTOSPAWNSPEED = 10 # default 60
#You can set the speed of automatic pokemon spawning, i.e. the ability of pokemon
# to spawn automatically even without even moving the player.
#0   - means that pokemon only spawn while the player is moving
#>0  - means automatic spawning is activated, the closer to 0 the faster the spawning

#===============================================================================
# Overriding the update method of the class Game_Map in script section Game_Map
#===============================================================================

class Game_Map
  
  alias original_update update
  def update
    original_update
    return unless $Trainer
    return if $PokemonGlobal.repel>0
    repel = ($PokemonGlobal.repel>0)
    $framecounter = 0 if !$framecounter 
    $framecounter = $framecounter + 1
    return unless $framecounter == AUTOSPAWNSPEED
    $framecounter = 0
    if $PokemonSystem.OWP == 0
      if $PokemonSystem.OWP > 0 && $PokemonSystem.OWP < 100
        $PokemonSystem.OWP = $PokemonSystem.OWP
      elsif $PokemonSystem.OWP >= 100
        $PokemonSystem.OWP = 100
      else
        $PokemonSystem.OWP = -1
      end
    end
    return if $PokemonSystem.OWP>0 && ($PokemonSystem.OWP>=100 || rand(100) < $PokemonSystem.OWP)
    #OVERWORLD ENCOUNTERS
    #we choose the tile on which the pokemon appears
    pos = pbChooseTileOnStepTaken
    return if !pos
    #we choose the random encounter
    encounter,gender,form,isShiny = pbChooseEncounter(pos[0],pos[1],repel)
    return if !encounter
    #we generate an random encounter overworld event
    pbPlaceEncounter(pos[0],pos[1],encounter,gender,form,isShiny)
  end
end