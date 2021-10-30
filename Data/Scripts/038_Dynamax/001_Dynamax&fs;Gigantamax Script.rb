#===============================================================================
#
# Dynamax/Gigantamax Script - Base script by fauno. Heavily modified by Lucidious89.
# Max Raid Battles - Created by Lucidious89
#  For -Pokémon Essentials v18.1-
#
#===============================================================================
# The following adds Dynamax functionality to Essentials. Almost everything
# in the main series is replicated here except for animations and other visuals.
# You must start a new game for many of these game mechanics to properly install.
#
#===============================================================================
#  ~Installation~
#===============================================================================
# To install, create a new section below all battle scripts, but above main.
# Right above Debug_Menu is fine. Paste this script there. This requires the
# Mechanic_Compatibility script to be installed as well.
#
# Everything below is written for Pokémon Essentials v18.1
#===============================================================================

################################################################################
# SECTION 1 - CUSTOMIZATION
#===============================================================================
# Settings
#===============================================================================
# Visual Settings
#-------------------------------------------------------------------------------
ENLARGE_SPRITE = true  # Enlarges a Dynamaxed Pokemon's sprites when true.
DYNAMAX_COLOR  = true  # Applies a red overlay to Dynamax Pokemon's sprites when true.
DMAX_BUTTON_2  = false # Uses the modern (true) or classic (false) Dynamax Button style.
GMAX_XL_ICONS  = true  # Set as "true" ONLY when using the 256x128 icons for G-Max Pokemon.
#-------------------------------------------------------------------------------
# Dynamax Settings
#-------------------------------------------------------------------------------
DMAX_ANYMAP    = true # Allows Dynamaxing on any map location when true.
CAN_DMAX_WILD  = true # Allows Dynamaxing in normal wild battles when true.
DYNAMAX_TURNS  = 3     # The number of turns Dynamax lasts before expiring.
#-------------------------------------------------------------------------------
# Max Raid Settings
#-------------------------------------------------------------------------------
MAXRAID_SIZE   = 3     # The base number of Pokemon you may have out in a Max Raid.
MAXRAID_KOS    = 4     # The base number of KO's a Max Raid Pokemon needs beat you.
MAXRAID_TIMER  = 10    # The base number of turns you have in a Max Raid battle.
MAXRAID_SHIELD = 2     # The base number of hit points Max Raid shields have.
#-------------------------------------------------------------------------------
# Switch Numbers
#-------------------------------------------------------------------------------
NO_DYNAMAX     = 37    # The switch number for disabling Dynamax.
MAXRAID_SWITCH = 38    # The switch number used to toggle Max Raid battles.
HARDMODE_RAID  = 39    # The switch number used to toggle Hard Mode raids.
#-------------------------------------------------------------------------------
# Variable Numbers
#-------------------------------------------------------------------------------
# Note: MAXRAID_PKMN must not have any variable numbers after it used for 
# anything, that's why it's purposely set to a high number.
#-------------------------------------------------------------------------------
REWARD_BONUSES = 15    # The variable number used to store Raid Reward Bonuses.
MAXRAID_PKMN   = 500   # The base variable number used to store a Raid Pokemon.

#===============================================================================
# Arrays.
#===============================================================================
# Map Arrays
#-------------------------------------------------------------------------------
# Map ID's where Dynamax (POWERSPOTS) and Eternamax (ETERNASPOT) are allowed.
#-------------------------------------------------------------------------------
POWERSPOTS     = []  # Pokemon Gyms, Pokemon League, Battle Facilities
ETERNASPOT     = []                   # None by default

#-------------------------------------------------------------------------------
# Item Arrays
#-------------------------------------------------------------------------------
# List of items that allow the use of Dynamax.
#-------------------------------------------------------------------------------
DMAX_BANDS     = [:DYNAMAXBAND]

#-------------------------------------------------------------------------------
# Move Arrays
#-------------------------------------------------------------------------------
# List of Max Moves that correspond to each type number.
# Note: The second instance of Max Strike is for the "???" type.
DYNAMAX_MOVES  = [:MAXSTRIKE,:MAXKNUCKLE,:MAXAIRSTREAM,:MAXOOZE,:MAXQUAKE,
                  :MAXROCKFALL,:MAXFLUTTERBY,:MAXPHANTASM,:MAXSTEELSPIKE,
                  :MAXSTRIKE,:MAXFLARE,:MAXGEYSER,:MAXOVERGROWTH,:MAXLIGHTNING,
                  :MAXMINDSTORM,:MAXHAILSTORM,:MAXWYRMWIND,:MAXDARKNESS,:MAXSTARFALL]
                  
# List of G-Max Moves with a set base power that doesn't change.
GMAX_SET_POWER = [:GMAXDRUMSOLO,:GMAXFIREBALL,:GMAXHYDROSNIPE]

#-------------------------------------------------------------------------------
# Species Arrays
#-------------------------------------------------------------------------------
# List of species unable to Dynamax.
DMAX_BANLIST   = []

# List of species with a Gigantamax form (includes Eternamax).
GMAX_SPECIES   = [:VENUSAUR,:CHARIZARD,:BLASTOISE,:BUTTERFREE,:PIKACHU,:MEOWTH,
                  :MACHAMP,:GENGAR,:KINGLER,:LAPRAS,:EEVEE,:SNORLAX,:GARBODOR,
                  :MELMETAL,:RILLABOOM,:CINDERACE,:INTELEON,:CORVIKNIGHT,:ORBEETLE,
                  :DREDNAW,:COALOSSAL,:FLAPPLE,:APPLETUN,:SANDACONDA,:TOXTRICITY,
                  :CENTISKORCH,:HATTERENE,:GRIMMSNARL,:ALCREMIE,:COPPERAJAH,
                  :DURALUDON,:ETERNATUS,:URSHIFU]


################################################################################
# SECTION 2 - ITEM EFFECTS
#===============================================================================
# Effects for old and new items related to Dynamax, or obtained from Max Raids.
#===============================================================================
# Confusion Berries - Dynamax Pokemon restore 1/3rd of their non-Dynamax HP.
#-------------------------------------------------------------------------------
def pbBattleConfusionBerry(battler,battle,item,forced,flavor,confuseMsg)
  return false if !forced && !battler.pbCanConsumeBerry?(item,false)
  itemName = PBItems.getName(item)
  battle.pbCommonAnimation("EatBerry",battler) if !forced
  baseHP = battler.totalhp
  baseHP = (battler.totalhp/battler.pokemon.dynamaxCalc).floor if battler.dynamax?
  amt = (NEWEST_BATTLE_MECHANICS) ? battler.pbRecoverHP(baseHP/3) : battler.pbRecoverHP(baseHP/2)
  if amt>0
    if forced
      PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}")
      battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1} restored its health using its {2}!",battler.pbThis,itemName))
    end
  end
  nUp = PBNatures.getStatRaised(battler.nature)
  nDn = PBNatures.getStatLowered(battler.nature)
  if nUp!=nDn && nDn-1==flavor
    battle.pbDisplay(confuseMsg)
    battler.pbConfuse if battler.pbCanConfuseSelf?(false)
  end
  return true
end

#-------------------------------------------------------------------------------
# Choice Items - Stat bonuses are not applied while user is Dynamaxed.
#-------------------------------------------------------------------------------
BattleHandlers::DamageCalcUserItem.add(:CHOICEBAND,
  proc { |item,user,target,move,mults,baseDmg,type|
    mults[BASE_DMG_MULT] *= 1.5 if move.physicalMove? && !user.dynamax?
  }
)

BattleHandlers::DamageCalcUserItem.add(:CHOICESPECS,
  proc { |item,user,target,move,mults,baseDmg,type|
    mults[BASE_DMG_MULT] *= 1.5 if move.specialMove? && !user.dynamax?
  }
)

BattleHandlers::SpeedCalcItem.add(:CHOICESCARF,
  proc { |item,battler,mult|
    next mult*1.5 if !battler.dynamax?
  }
)

#-------------------------------------------------------------------------------
# Red Card - Item triggers, but its effects fail to activate vs Dynamax targets.
#-------------------------------------------------------------------------------
BattleHandlers::TargetItemAfterMoveUse.add(:REDCARD,
  proc { |item,battler,user,move,switched,battle|
    next if user.fainted? || switched.include?(user.index)
    newPkmn = battle.pbGetReplacementPokemonIndex(user.index,true)   # Random
    next if newPkmn<0
    battle.pbCommonAnimation("UseItem",battler)
    battle.pbDisplay(_INTL("{1} held up its {2} against {3}!",
       battler.pbThis,battler.itemName,user.pbThis(true)))
    battler.pbConsumeItem
    if user.dynamax?
      battle.pbDisplay(_INTL("But it failed!"))
    else
      battle.pbRecallAndReplace(user.index,newPkmn)
      battle.pbDisplay(_INTL("{1} was dragged out!",user.pbThis))
      battle.pbClearChoice(user.index)   # Replacement Pokémon does nothing this round
      switched.push(user.index)
    end
  }
)

#===============================================================================
# Max items
#===============================================================================
# Max Honey - Fully revives a Pokemon.
#-------------------------------------------------------------------------------
ItemHandlers::UseOnPokemon.copy(:MAXREVIVE,:MAXHONEY)

#-------------------------------------------------------------------------------
# Max Mushrooms - Increases all stats by 1 stage.
#-------------------------------------------------------------------------------
ItemHandlers::BattleUseOnBattler.add(:MAXMUSHROOMS,proc { |item,battler,scene|
  showAnim=true
  battler.pokemon.changeHappiness("battleitem")
  for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPATK,PBStats::SPDEF,PBStats::SPEED]
    if battler.pbCanRaiseStatStage?(i,battler)
      battler.pbRaiseStatStage(i,1,battler,showAnim)
      showAnim=false
    end
  end  
})

#-------------------------------------------------------------------------------
# Dynamax Candy - Increases Dynamax Level of a Pokemon.
#-------------------------------------------------------------------------------
ItemHandlers::UseOnPokemon.add(:DYNAMAXCANDY,proc { |item,pkmn,scene|
  if pkmn.dynamax_lvl>=10 || !pkmn.dynamaxAble? || pkmn.shadowPokemon?
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  if isConst?(item,PBItems,:DYNAMAXCANDY)
    pkmn.addDynamaxLvl 
    pbSEPlay("Pkmn move learnt")
    scene.pbDisplay(_INTL("{1}'s Dynamax level was increased by 1!",pkmn.name))
  elsif isConst?(item,PBItems,:DYNAMAXCANDYXL) # Custom Item
    pkmn.setDynamaxLvl(10)
    pbSEPlay("Pkmn move learnt")
    scene.pbDisplay(_INTL("{1}'s Dynamax level was increased to 10!",pkmn.name))
  end
  scene.pbHardRefresh
  next true
})

ItemHandlers::UseOnPokemon.copy(:DYNAMAXCANDY,:DYNAMAXCANDYXL)

#-------------------------------------------------------------------------------
# Max Soup - Toggles Gigantamax Factor. (Custom item)
#-------------------------------------------------------------------------------
ItemHandlers::UseOnPokemon.add(:MAXSOUP,proc { |item,pkmn,scene|
  if !pkmn.hasGmax? || !pkmn.dynamaxAble? || pkmn.shadowPokemon?
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  if pkmn.gmaxFactor?
    pkmn.removeGMaxFactor
    scene.pbDisplay(_INTL("{1} lost its Gigantamax energy.",pkmn.name))
  else
    pkmn.giveGMaxFactor
    pbSEPlay("Pkmn move learnt")
    scene.pbDisplay(_INTL("{1} is now bursting with Gigantamax energy!",pkmn.name))
  end
  scene.pbHardRefresh
  next true
})

#-------------------------------------------------------------------------------
# Max Eggs - Increases Exp. for the whole party by 20,000. (Custom item)
#-------------------------------------------------------------------------------
ItemHandlers::UseInField.add(:MAXEGGS,proc { |item|
  if $Trainer.pokemonCount==0
    pbMessage(_INTL("There is no Pokémon."))
    next 0
  end
  cangiveExp = false
  for i in $Trainer.pokemonParty
    next if i.level>=PBExperience.maxLevel
    next if i.shadowPokemon?
    cangiveExp = true; break
  end
  if !cangiveExp
    pbMessage(_INTL("It won't have any effect."))
    next 0
  end
  expplus    = 0
  experience = 20000
  pbFadeOutIn {
    scene = PokemonParty_Scene.new
    screen = PokemonPartyScreen.new(scene,$Trainer.party)
    screen.pbStartScene(_INTL("Using item..."),false)
    for i in 0...$Trainer.party.length
      pkmn = $Trainer.party[i]
      next if pkmn.level>=PBExperience.maxLevel || pkmn.shadowPokemon?
      expplus   += 1
      newexp     = PBExperience.pbAddExperience(pkmn.exp,experience,pkmn.growthrate)
      newlevel   = PBExperience.pbGetLevelFromExperience(newexp,pkmn.growthrate)
      curlevel   = pkmn.level
      leveldif   = newlevel - curlevel
      if PBExperience.pbGetMaxExperience(pkmn.growthrate) < (pkmn.exp + experience)
        screen.pbDisplay(_INTL("{1} gained {2} Exp. Points!",pkmn.name,(PBExperience.pbGetMaxExperience(pkmn.growthrate)-pkmn.exp)))
      else
        screen.pbDisplay(_INTL("{1} gained {2} Exp. Points!",pkmn.name,experience))
      end
      if newlevel==curlevel
        pkmn.exp = newexp
        pkmn.calcStats
        screen.pbRefreshSingle(i)
      else
        leveldif.times do
          pbChangeLevel(pkmn,pkmn.level+1,screen)
          screen.pbRefreshSingle(i)
        end
      end
    end
    if expplus==0
      screen.pbDisplay(_INTL("It won't have any effect."))
      screen.pbEndScene
      next 0
    else
      screen.pbEndScene
      next 3
    end
  }
})

#-------------------------------------------------------------------------------
# Max Scales - Allows a Pokemon to recall a past move. (Custom item)
#-------------------------------------------------------------------------------
ItemHandlers::UseOnPokemon.add(:MAXSCALES,proc { |item,pkmn,scene|
  if pbGetRelearnableMoves(pkmn).length<=0 || pkmn.shadowPokemon?
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  scene.pbDisplay(_INTL("What move should {1} recall?",pkmn.name))
  m = pkmn.moves
  oldmoves = [m[0],m[1],m[2],m[3]]
  pbRelearnMoveScreen(pkmn)
  newmoves = [m[0],m[1],m[2],m[3]]
  next false if newmoves==oldmoves
  next true
})

#-------------------------------------------------------------------------------
# Max Plumage - Increases each IV of a Pokemon by 1 point. (Custom item)
#-------------------------------------------------------------------------------
ItemHandlers::UseOnPokemon.add(:MAXPLUMAGE,proc { |item,pkmn,scene|
  stats = 0
  for i in 0...6
    next if pkmn.iv[i]==31
    stats += 1
    pkmn.iv[i] += 1
  end
  if stats==0
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  scene.pbDisplay(_INTL("{1}'s base stats increased by 1!",pkmn.name))
  scene.pbHardRefresh
  next true
})


################################################################################
# SECTION 3 - POKEMON PROPERTIES
#===============================================================================
# Adds Dynamax and Gigantamax attributes to Pokemon.
#===============================================================================
class PokeBattle_Pokemon
  attr_accessor(:dynamax)
  attr_accessor(:reverted)
  attr_accessor(:dynamax_lvl)
  attr_accessor(:gmaxfactor)
  
  #-----------------------------------------------------------------------------
  # Dynamax
  #-----------------------------------------------------------------------------
  def dynamaxAble?
    for i in DMAX_BANLIST
      return false if isSpecies?(i)
    end
    return true
  end

  def makeDynamax
    @dynamax = true
    @reverted = false
  end
  
  def makeUndynamax
    @dynamax = false
    @reverted = true
  end

  def dynamax?
    return @dynamax
  end
  
  def pbReversion(revert=false)
    @reverted = true if revert
    @reverted = false if !revert
  end
  
  def reverted?
    return @reverted
  end
  
  #-----------------------------------------------------------------------------
  # Gigantamax
  #-----------------------------------------------------------------------------
  def hasGmax?
    return true if isSpecies?(:ALCREMIE)
    return true if isSpecies?(:PIKACHU) && self.form<2
    return true if isSpecies?(:TOXTRICITY) && self.form<2
    return true if isSpecies?(:URSHIFU) && self.form<2
    if self.form==0
      for i in GMAX_SPECIES
        return true if isSpecies?(i)
      end
    end
    return false
  end
  
  def gmax?
    return true if (self.dynamax? && self.gmaxFactor? && self.hasGmax?)
    return false
  end
  
  #-----------------------------------------------------------------------------
  # Dynamax Levels
  #-----------------------------------------------------------------------------
  def dynamax_lvl
    return @dynamax_lvl || 0
  end
  
  def setDynamaxLvl(value)
    if !egg? && dynamaxAble?
      self.dynamax_lvl = value
    end
  end
  
  def addDynamaxLvl
    if !egg? && dynamaxAble?
      self.dynamax_lvl += 1
      self.dynamax_lvl  = 10 if self.dynamax_lvl>10
    end
  end
  
  def removeDynamaxLvl
    self.dynamax_lvl -= 1
    self.dynamax_lvl  = 0 if self.dynamax_lvl<0
  end
  
  #-----------------------------------------------------------------------------
  # Gigantamax Factor
  #-----------------------------------------------------------------------------
  def giveGMaxFactor
    @gmaxfactor = true
  end
  
  def removeGMaxFactor
    @gmaxfactor = false
  end
  
  def gmaxFactor?
    return true if @gmaxfactor 
    return false
  end
  
  #-----------------------------------------------------------------------------
  # Stat Calculations
  #-----------------------------------------------------------------------------
  def dynamaxCalc
    return (1.5+(dynamax_lvl*0.05))
  end
  
  def dynamaxBoost
    return dynamaxCalc if dynamax?
    return 1
  end
  
  def calcHP(base,level,iv,ev)
    return 1 if base==1   # For Shedinja
    return ((((base*2+iv+(ev>>2))*level/100).floor+level+10)*dynamaxBoost).ceil
  end
  
  def calcStats
    bs        = self.baseStats
    usedLevel = self.level
    usedIV    = self.calcIV
    pValues   = PBNatures.getStatChanges(self.calcNature)
    stats = []
    PBStats.eachStat do |s|
      if s==PBStats::HP
        stats[s] = calcHP(bs[s],usedLevel,usedIV[s],@ev[s])
      else
        stats[s] = calcStat(bs[s],usedLevel,usedIV[s],@ev[s],pValues[s])
      end
    end
    # Dynamax HP Calcs
    if dynamax? && !reverted? && @totalhp>1
      @totalhp = stats[PBStats::HP]
      @hp      = (@hp*dynamaxCalc).ceil
    elsif reverted? && !dynamax? && @totalhp>1
      @totalhp = stats[PBStats::HP]
      @hp      = (@hp/dynamaxCalc).round
      @hp     +=1 if !fainted? && @hp<=0
    else
      hpDiff   = @totalhp-@hp
      @totalhp = stats[PBStats::HP]
      @hp      = @totalhp-hpDiff
    end
    @hp      = 0 if @hp<0
    @hp      = @totalhp if @hp>@totalhp
    @attack  = stats[PBStats::ATTACK]
    @defense = stats[PBStats::DEFENSE]
    @spatk   = stats[PBStats::SPATK]
    @spdef   = stats[PBStats::SPDEF]
    @speed   = stats[PBStats::SPEED]
  end
  
  alias dynamax_initialize initialize  
  def initialize(*args)
    dynamax_initialize(*args)
    @dynamax_lvl = 0
    @dynamax     = false
    @reverted    = false
    @gmaxfactor  = false
  end
end

#-------------------------------------------------------------------------------
# Checks for G-Max forms of a species.
#-------------------------------------------------------------------------------
def pbGmaxSpecies?(species,form)
  return true if species==getID(PBSpecies,:ALCREMIE)
  return true if species==getID(PBSpecies,:PIKACHU) && form<2
  return true if species==getID(PBSpecies,:TOXTRICITY) && form<2
  return true if species==getID(PBSpecies,:URSHIFU) && form<2
  if form==0
    for i in GMAX_SPECIES
      return true if species==getID(PBSpecies,i)
    end
  end
  return false
end

#===============================================================================
# Gets G-Max Move based on species.
#===============================================================================                 
def pbGetGMaxMoveFromSpecies(poke,type)
  gmaxmove = nil
  gmaxmove = :GMAXVINELASH   if poke.isSpecies?(:VENUSAUR)    && type==12 # Grass
  gmaxmove = :GMAXWILDFIRE   if poke.isSpecies?(:CHARIZARD)   && type==10 # Fire
  gmaxmove = :GMAXCANNONADE  if poke.isSpecies?(:BLASTOISE)   && type==11 # Water
  gmaxmove = :GMAXVOLTCRASH  if poke.isSpecies?(:PIKACHU)     && type==13 # Electric
  gmaxmove = :GMAXGOLDRUSH   if poke.isSpecies?(:MEOWTH)      && type==0  # Normal
  gmaxmove = :GMAXCHISTRIKE  if poke.isSpecies?(:MACHAMP)     && type==1  # Fighting
  gmaxmove = :GMAXTERROR     if poke.isSpecies?(:GENGAR)      && type==7  # Ghost
  gmaxmove = :GMAXFOAMBURST  if poke.isSpecies?(:KINGLER)     && type==11 # Water
  gmaxmove = :GMAXRESONANCE  if poke.isSpecies?(:LAPRAS)      && type==15 # Ice
  gmaxmove = :GMAXCUDDLE     if poke.isSpecies?(:EEVEE)       && type==0  # Normal
  gmaxmove = :GMAXREPLENISH  if poke.isSpecies?(:SNORLAX)     && type==0  # Normal
  gmaxmove = :GMAXMALODOR    if poke.isSpecies?(:GARBODOR)    && type==3  # Poison
  gmaxmove = :GMAXMELTDOWN   if poke.isSpecies?(:MELMETAL)    && type==8  # Steel
  gmaxmove = :GMAXDRUMSOLO   if poke.isSpecies?(:RILLABOOM)   && type==12 # Grass
  gmaxmove = :GMAXFIREBALL   if poke.isSpecies?(:CINDERACE)   && type==10 # Fire
  gmaxmove = :GMAXHYDROSNIPE if poke.isSpecies?(:INTELEON)    && type==11 # Water
  gmaxmove = :GMAXWINDRAGE   if poke.isSpecies?(:CORVIKNIGHT) && type==2  # Flying
  gmaxmove = :GMAXGRAVITAS   if poke.isSpecies?(:ORBEETLE)    && type==14 # Psychic
  gmaxmove = :GMAXSTONESURGE if poke.isSpecies?(:DREDNAW)     && type==11 # Water
  gmaxmove = :GMAXVOLCALITH  if poke.isSpecies?(:COALOSSAL)   && type==5  # Rock
  gmaxmove = :GMAXTARTNESS   if poke.isSpecies?(:FLAPPLE)     && type==12 # Grass
  gmaxmove = :GMAXSWEETNESS  if poke.isSpecies?(:APPLETUN)    && type==12 # Grass
  gmaxmove = :GMAXSANDBLAST  if poke.isSpecies?(:SANDACONDA)  && type==4  # Ground
  gmaxmove = :GMAXSTUNSHOCK  if poke.isSpecies?(:TOXTRICITY)  && type==13 # Electric
  gmaxmove = :GMAXCENTIFERNO if poke.isSpecies?(:CENTISKORCH) && type==10 # Fire
  gmaxmove = :GMAXSMITE      if poke.isSpecies?(:HATTERENE)   && type==18 # Fairy
  gmaxmove = :GMAXSNOOZE     if poke.isSpecies?(:GRIMMSNARL)  && type==17 # Dark
  gmaxmove = :GMAXFINALE     if poke.isSpecies?(:ALCREMIE)    && type==18 # Fairy
  gmaxmove = :GMAXSTEELSURGE if poke.isSpecies?(:COPPERAJAH)  && type==8  # Steel
  gmaxmove = :GMAXDEPLETION  if poke.isSpecies?(:DURALUDON)   && type==16 # Dragon
  gmaxmove = :GMAXONEBLOW    if poke.isSpecies?(:URSHIFU) && poke.form==0 && type==17 # Dark
  gmaxmove = :GMAXRAPIDFLOW  if poke.isSpecies?(:URSHIFU) && poke.form==1 && type==11 # Water
  return gmaxmove
end

#===============================================================================
# Gigantamax Form Data
#===============================================================================
MultipleForms.register(:VENUSAUR,{
  #-----------------------------------------------------------------------------
  # Gigantamax Form Names
  #-----------------------------------------------------------------------------
  "getFormName"=>proc{|pokemon|
    name = _INTL("Gigantamax {1}",PBSpecies.getName(pokemon.species)) 
    name = _INTL("Eternamax Eternatus") if pokemon.isSpecies?(:ETERNATUS)
    next name if pokemon.gmax?
    next
  },
  #-----------------------------------------------------------------------------
  # Base Stat changes (Eternamax Eternatus)
  #-----------------------------------------------------------------------------
  "baseStats"=>proc{|pokemon|
    next if !(pokemon.isSpecies?(:ETERNATUS) && pokemon.gmax?)
    next [255,115,250,130,125,250]
  },
  #-----------------------------------------------------------------------------
  # Gigantamax Pokedex Entries
  #-----------------------------------------------------------------------------
  "dexEntry"=>proc{|pokemon|
    if pokemon.isSpecies?(:VENUSAUR);    dex = "In battle, this Pokémon swings around two thick vines. If these vines slammed into a 10-story building, they could easily topple it."; end
    if pokemon.isSpecies?(:CHARIZARD);   dex = "This colossal, flame-winged figure of a Charizard was brought about by Gigantamax energy."; end
    if pokemon.isSpecies?(:BLASTOISE);   dex = "Water fired from this Pokémon's central main cannon has enough power to blast a hole into a mountain."; end
    if pokemon.isSpecies?(:BUTTERFREE);  dex = "Crystallized Gigantamax energy makes up this Pokémon's blindingly bright and highly toxic scales."; end
    if pokemon.isSpecies?(:PIKACHU);     dex = "Its Gigantamax power expanded, forming its supersized body and towering tail."; end
    if pokemon.isSpecies?(:MEOWTH);      dex = "Its body has grown incredibly long and the coin on its forehead has grown incredibly large—all thanks to Gigantamax power."; end
    if pokemon.isSpecies?(:MACHAMP);     dex = "The Gigantamax energy coursing through its arms makes its punches hit as hard as bomb blasts."; end
    if pokemon.isSpecies?(:GENGAR);      dex = "It lays traps, hoping to steal the lives of those it catches. If you stand in front of its mouth, you'll hear your loved ones' voices calling out to you."; end
    if pokemon.isSpecies?(:KINGLER);     dex = "The flow of Gigantamax energy has spurred this Pokémon's left pincer to grow to an enormous size. That claw can pulverize anything."; end
    if pokemon.isSpecies?(:LAPRAS);      dex = "Over 5,000 people can ride on its shell at once. And it's a very comfortable ride, without the slightest shaking or swaying."; end
    if pokemon.isSpecies?(:EEVEE);       dex = "Gigantamax energy upped the fluffiness of the fur around Eevee's neck. The fur will envelop a foe, capturing its body and captivating its mind."; end
    if pokemon.isSpecies?(:SNORLAX);     dex = "Gigantamax energy has affected stray seeds and even pebbles that got stuck to Snorlax, making them grow to a huge size."; end
    if pokemon.isSpecies?(:GARBODOR);    dex = "Due to Gigantamax energy, this Pokémon's toxic gas has become much thicker, congealing into masses shaped like discarded toys."; end
    if pokemon.isSpecies?(:MELMETAL);    dex = "In a distant land, there are legends about a cyclopean giant. In fact, the giant was a Melmetal that was flooded with Gigantamax energy."; end
    if pokemon.isSpecies?(:RILLABOOM);   dex = "Gigantamax energy has caused Rillaboom's stump to grow into a drum set that resembles a forest."; end
    if pokemon.isSpecies?(:CINDERACE);   dex = "Gigantamax energy can sometimes cause the diameter of this Pokémon's fireball to exceed 300 feet."; end
    if pokemon.isSpecies?(:INTELEON);    dex = "Gigantamax Inteleon's Water Gun move fires at Mach 7. As the Pokémon takes aim, it uses the crest on its head to gauge wind and temperature."; end
    if pokemon.isSpecies?(:CORVIKNIGHT); dex = "Imbued with Gigantamax energy, its wings can whip up winds more forceful than any a hurricane could muster. The gusts blow everything away."; end
    if pokemon.isSpecies?(:ORBEETLE);    dex = "Its brain has grown to a gargantuan size, as has the rest of its body. This Pokémon's intellect and psychic abilities are overpowering."; end
    if pokemon.isSpecies?(:DREDNAW);     dex = "It responded to Gigantamax energy by becoming bipedal. First it comes crashing down on foes, and then it finishes them off with its massive jaws."; end
    if pokemon.isSpecies?(:COALOSSAL);   dex = "Its body is a colossal stove. With Gigantamax energy stoking the fire, this Pokémon's flame burns hotter than 3,600 degrees Fahrenheit."; end
    if pokemon.isSpecies?(:FLAPPLE);     dex = "Under the influence of Gigantamax energy, it produces much more sweet nectar, and its shape has changed to resemble a giant apple."; end
    if pokemon.isSpecies?(:APPLETUN);    dex = "Due to Gigantamax energy, this Pokémon's nectar has thickened. The increased viscosity lets the nectar absorb more damage than before."; end
    if pokemon.isSpecies?(:SANDACONDA);  dex = "Sand swirls around its body with such speed and power that it could pulverize a skyscraper."; end
    if pokemon.isSpecies?(:TOXTRICITY);  dex = "Out of control after its own poison penetrated its brain, it tears across the land in a rampage, contaminating the earth with toxic sweat."; end
    if pokemon.isSpecies?(:CENTISKORCH); dex = "The heat that comes off a Gigantamax Centiskorch may destabilize air currents. Sometimes it can even cause storms."; end
    if pokemon.isSpecies?(:HATTERENE);   dex = "Beams like lightning shoot down from its tentacles. It's known to some as the Raging Goddess."; end
    if pokemon.isSpecies?(:GRIMMSNARL);  dex = "Gigantamax energy has caused more hair to sprout all over its body. With the added strength, it can jump over the world's tallest building."; end
    if pokemon.isSpecies?(:ALCREMIE);    dex = "It launches swarms of missiles, each made of cream and loaded with 100,000 kilocalories. Get hit by one of these, and your head will swim."; end
    if pokemon.isSpecies?(:COPPERAJAH);  dex = "After this Pokémon has Gigantamaxed, its massive nose can utterly demolish large structures with a single smashing blow."; end
    if pokemon.isSpecies?(:DURALUDON);   dex = "It's grown to resemble a skyscraper. Parts of its towering body glow due to a profusion of energy."; end
    if pokemon.isSpecies?(:ETERNATUS);   dex = "Infinite amounts of energy pour from this Pokémon's enlarged core, warping the surrounding space-time."; end
    if pokemon.isSpecies?(:URSHIFU)      # Urshifu forms:
      if pokemon.form==0;                dex = "The energy released by this Pokémon's fists forms shock waves that can blow away Dynamax Pokémon in just one hit."; end
      if pokemon.form==1;                dex = "As it waits for the right moment to unleash its Gigantamax power, this Pokémon maintains a perfect one-legged stance. It won't even twitch."; end
    end
    next _INTL("{1}",dex) if pokemon.gmax?
  },
  "onSetForm"=>proc{|pokemon,form,oldForm|
    pbSeenForm(pokemon)
  }
})

MultipleForms.copy(:VENUSAUR,:CHARIZARD,:BLASTOISE,:BUTTERFREE,:PIKACHU,:MEOWTH,
                   :MACHAMP,:GENGAR,:KINGLER,:LAPRAS,:EEVEE,:SNORLAX,:GARBODOR,
                   :MELMETAL,:RILLABOOM,:CINDERACE,:INTELEON,:CORVIKNIGHT,:ORBEETLE,
                   :DREDNAW,:COALOSSAL,:FLAPPLE,:APPLETUN,:SANDACONDA,:TOXTRICITY,
                   :CENTISKORCH,:HATTERENE,:GRIMMSNARL,:ALCREMIE,:COPPERAJAH,
                   :DURALUDON,:ETERNATUS,:URSHIFU)

#===============================================================================
# Displays Dynamax info on a Pokemon.
#===============================================================================
class PokemonSummary_Scene
  #-----------------------------------------------------------------------------
  # Displays Gigantamax Factor in the summary.
  #-----------------------------------------------------------------------------
  def pbDisplayGMaxFactor # Added to def drawPage in Summary
    if @pokemon.gmaxFactor? && @pokemon.dynamaxAble?
      overlay = @sprites["overlay"].bitmap
      imagepos=[]
      imagepos.push(["Graphics/Pictures/Dynamax/gfactor",88,95,0,0,-1,-1])
      pbDrawImagePositions(overlay,imagepos)
    end
  end
  
  #-----------------------------------------------------------------------------
  # Displays Dynamax Levels in the summary.
  #-----------------------------------------------------------------------------
  def pbDisplayDynamaxMeter # Added to def drawPage in Summary
    if @page==3 && @pokemon.dynamaxAble?
      overlay = @sprites["overlay"].bitmap
      imagepos=[]
      imagepos.push(["Graphics/Pictures/Dynamax/dynamax_meter",56,308,0,0,-1,-1])
      pbDrawImagePositions(overlay,imagepos)
      dlevel=@pokemon.dynamax_lvl
      levels=AnimatedBitmap.new(_INTL("Graphics/Pictures/Dynamax/dynamax_levels"))
      overlay.blt(69,325,levels.bitmap,Rect.new(0,0,dlevel*12,21))
    end
  end
  
  #-----------------------------------------------------------------------------
  # Displays Max Move names and type in the summary.
  #-----------------------------------------------------------------------------
  def drawDynamaxMoveSel(move,yPos,moveBase,moveShadow,moveToLearn)
    movetype = pbGetMoveData(move.id,MOVE_TYPE)
    category = pbGetMoveData(move.id,MOVE_CATEGORY)
    gmaxmove = pbGetGMaxMoveFromSpecies(@pokemon,movetype)
    if @pokemon.dynamax? && moveToLearn==0
      if category==2
        image = ["Graphics/Pictures/types",248,yPos+2,0,0,64,28]
        text  = [PBMoves.getName(:MAXGUARD),316,yPos,0,moveBase,moveShadow]
      else
        image = ["Graphics/Pictures/types",248,yPos+2,0,move.type*28,64,28]
        if @pokemon.gmaxFactor? && gmaxmove
          text = [PBMoves.getName(gmaxmove),316,yPos,0,moveBase,moveShadow]
        else  
          text = [PBMoves.getName(DYNAMAX_MOVES[movetype]),316,yPos,0,moveBase,moveShadow]
        end
      end
    else  
      image = ["Graphics/Pictures/types",248,yPos+2,0,move.type*28,64,28]
      text  = [PBMoves.getName(move.id),316,yPos,0,moveBase,moveShadow]
    end
    return [image,text]
  end
  
  #-----------------------------------------------------------------------------
  # Displays Max Move data in the summary.
  #-----------------------------------------------------------------------------
  def pbGetMaxMoveData(moveToLearn,moveid)
    if @pokemon.dynamax? && moveToLearn==0
      movetype = pbGetMoveData(moveid,MOVE_TYPE)
      category = pbGetMoveData(moveid,MOVE_CATEGORY)
      gmaxmove = pbGetGMaxMoveFromSpecies(@pokemon,movetype)
      if category==2
        maxMoveID = getID(PBMoves,:MAXGUARD)
      else
        if @pokemon.gmaxFactor? && gmaxmove
          maxMoveID = getID(PBMoves,gmaxmove)
        else
          maxMoveID = getID(PBMoves,(DYNAMAX_MOVES[movetype]))
        end
      end
      basedamage = pbGetMoveData(maxMoveID,MOVE_BASE_DAMAGE)
      basedamage = pbSetMaxMovePower(moveid,true) if !pbIsSetGmaxMove?(maxMoveID)
      basedamage = 0 if maxMoveID==getID(PBMoves,:MAXGUARD)
      accuracy   = 0
      moveid     = maxMoveID
      return [basedamage,accuracy,moveid]
    end
  end
end

#-----------------------------------------------------------------------------
# Plays the Dynamax cry of a species.
#-----------------------------------------------------------------------------
def pbGetDynamaxCry(species,form)
  pkmn = getID(PBSpecies,species)
  pbPlayCrySpecies(pkmn,form,100,60)
end


################################################################################
# SECTION 4 - DYNAMAX BATTLE EFFECTS
#===============================================================================
# New effects used for Dynamax functions in battles.
#===============================================================================
module PBEffects
  #-----------------------------------------------------------------------------
  # Effects for Dynamaxing.
  #-----------------------------------------------------------------------------
  Dynamax       = 200     # The Dynamax state.
  NoDynamax     = 201     # Prevents Dynamaxing for species on DMAX_BANLIST (Transform).
  NonGMaxForm   = 202     # Records a G-Max Pokemon's base form to revert to (Alcremie).
  UnMaxMoves    = 203     # Records a Pokemon's base moves before Dynamaxing.
  MaxMovePP     = 204     # Records the PP usage of Max Moves while Dynamaxed.
  DButton       = 205     # Used for toggling Max Moves.
  #-----------------------------------------------------------------------------
  # Specific Max Move effects.
  #-----------------------------------------------------------------------------
  MaxGuard      = 206     # The effect for Max Guard.
  VineLash      = 207     # The lingering effect of G-Max Vine Lash.
  Wildfire      = 208     # The lingering effect of G-Max Wildfire.
  Cannonade     = 209     # The lingering effect of G-Max Cannonade.
  Volcalith     = 210     # The lingering effect of G-Max Volcalith.
  Steelsurge    = 211     # The hazard effect of G-Max Steelsurge.
  #-----------------------------------------------------------------------------
  # Effects for Max Raid Battles.
  #-----------------------------------------------------------------------------
  MaxRaidBoss   = 212     # The effect that designates a Max Raid Pokemon.
  RaidShield    = 213     # The current HP for a Max Raid Pokemon's shields.
  ShieldCounter = 214     # The counter for triggering Raid Shields and other effects.
  KnockOutCount = 215     # The counter for KO's a Raid Pokemon needs to end the raid.
end

#===============================================================================
# Initializes new field effects in battle.
#===============================================================================
class PokeBattle_ActiveSide
  alias dynamax_initialize initialize  
  def initialize
    dynamax_initialize
    @effects[PBEffects::VineLash]          = 0
    @effects[PBEffects::Wildfire]          = 0
    @effects[PBEffects::Cannonade]         = 0
    @effects[PBEffects::Volcalith]         = 0
    @effects[PBEffects::Steelsurge]        = false
  end
end

#===============================================================================
# Initializes new Pokemon effects in battle.
#===============================================================================
class PokeBattle_Battler
  alias dynamax_pbInitEffects pbInitEffects  
  def pbInitEffects(batonpass)
    dynamax_pbInitEffects(batonpass)
    @effects[PBEffects::MaxGuard]      = false
    @effects[PBEffects::DButton]       = false
    @effects[PBEffects::Dynamax]       = 0
    @effects[PBEffects::UnMaxMoves]    = 0
    @effects[PBEffects::MaxMovePP]     = [0,0,0,0]
    @effects[PBEffects::NoDynamax]     = self.dynamaxAble? ? false : true
    @effects[PBEffects::NonGMaxForm]   = self.form
    pbInitMaxRaidBoss
  end
  
#===============================================================================
# Handles success checks for moves used on Dynamax Pokemon.
#===============================================================================
  def pbSuccessCheckDynamax(move,user,target) # Added to def pbSuccessCheckAgainstTarget
    #---------------------------------------------------------------------------
    # Dynamax Pokemon are immune to specified moves.
    #---------------------------------------------------------------------------
    if target.effects[PBEffects::Dynamax]>0
      if move.function=="066" || # Entrainment
         move.function=="067" || # Skill Swap
         move.function=="070" || # OHKO moves
         move.function=="09A" || # Weight-based moves
         move.function=="0B7" || # Torment
         move.function=="0B9" || # Disable
         move.function=="0BC" || # Encore
         move.function=="0E7" || # Destiny Bond
         move.function=="0EB" || # Roar/Whirlwind
         move.function=="16B"    # Instruct
        @battle.pbDisplay(_INTL("But it failed!"))
        ret = false
      end
    end
    #---------------------------------------------------------------------------
    # Gets Max Raid immunities.
    #---------------------------------------------------------------------------
    raidsuccess = pbSuccessCheckMaxRaid(move,user,target)
    ret = false if raidsuccess==false
    #---------------------------------------------------------------------------
    # Max Guard blocks all moves except specified moves.
    #---------------------------------------------------------------------------
    if target.effects[PBEffects::MaxGuard]
      if isConst?(move.id,PBMoves,:MEANLOOK) ||
         isConst?(move.id,PBMoves,:ROLEPLAY) ||
         isConst?(move.id,PBMoves,:PERISHSONG) ||
         isConst?(move.id,PBMoves,:DECORATE) ||
         # Feint damages, but doesn't remove Max Guard.
         isConst?(move.id,PBMoves,:FEINT) || 
         isConst?(move.id,PBMoves,:GMAXONEBLOW) ||
         isConst?(move.id,PBMoves,:GMAXRAPIDFLOW)
        ret = true
      else
        @battle.pbCommonAnimation("Protect",target)
        @battle.pbDisplay(_INTL("{1} protected itself!",target.pbThis))
        target.damageState.protected = true
        @battle.successStates[user.index].protected = true
        # Max Moves still reduce Raid Shield HP by 1, but only in single battle raids.
        if @battle.pbSideSize(0)==1 && move.maxMove? &&
           target.effects[PBEffects::MaxRaidBoss] &&
           target.effects[PBEffects::RaidShield]>0
          @battle.pbDisplay(_INTL("{1}'s mysterious barrier took the hit!",target.pbThis))
          target.effects[PBEffects::RaidShield]-=1
          @battle.scene.pbRefresh
        end
        ret = false
      end
    end
    return ret
  end
  
  #-----------------------------------------------------------------------------
  # Destiny Bond effect is negated on Dynamax Pokemon.
  #-----------------------------------------------------------------------------
  alias dynamax_pbEffectsOnMakingHit pbEffectsOnMakingHit
  def pbEffectsOnMakingHit(move,user,target)
    dynamax_pbEffectsOnMakingHit(move,user,target)
    if target.opposes?(user) && user.dynamax?
      user.effects[PBEffects::DestinyBondTarget] = -1
    end
  end
  
  #-----------------------------------------------------------------------------
  # Dynamax Pokemon cannot flinch.
  #-----------------------------------------------------------------------------
  def pbFlinch(user=nil)
    return if (hasActiveAbility?(:INNERFOCUS) && !@battle.moldBreaker)
    return if @effects[PBEffects::Dynamax]>0
    @effects[PBEffects::Flinch] = true
  end
  
  #-----------------------------------------------------------------------------
  # Inherits inability to Dynamax if transformed into a DMAX_BANLIST species.
  # Transformed Pokemon copy a Dynamax target's base moves.
  #-----------------------------------------------------------------------------
  def pbTransformDynamax(target) # Added to def pbTransform
    @effects[PBEffects::TransformSpecies] = target.pokemon 
    @effects[PBEffects::NoDynamax] = target.effects[PBEffects::NoDynamax]
    if target.dynamax?
      @moves.clear
      target.pokemon.moves.each_with_index do |m,i|
        @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(m.id))
        @moves[i].pp      = 5
        @moves[i].totalpp = 5
      end
    end
    if @pokemon.dynamax?
      pbMaxMove
    end
  end
  
  #-----------------------------------------------------------------------------
  # Held Choice Items don't lock move options while Dynamaxed.
  #-----------------------------------------------------------------------------
  def pbEndTurn(_choice)
    @lastRoundMoved = @battle.turnCount   # Done something this round
    if @effects[PBEffects::Dynamax]<=0
      if @effects[PBEffects::ChoiceBand]<0 &&
         hasActiveItem?([:CHOICEBAND,:CHOICESPECS,:CHOICESCARF])
        if @lastMoveUsed>=0 && pbHasMove?(@lastMoveUsed)
          @effects[PBEffects::ChoiceBand] = @lastMoveUsed
        elsif @lastRegularMoveUsed>=0 && pbHasMove?(@lastRegularMoveUsed)
          @effects[PBEffects::ChoiceBand] = @lastRegularMoveUsed
        end
      end
    else
      @effects[PBEffects::ChoiceBand] = -1
    end
    @effects[PBEffects::Charge]      = 0 if @effects[PBEffects::Charge]==1
    @effects[PBEffects::GemConsumed] = 0
    @battle.eachBattler { |b| b.pbContinualAbilityChecks }   # Trace, end primordial weathers
  end
end

#-------------------------------------------------------------------------------
# Cursed Body - Ability fails to trigger on Dynamax targets.
#-------------------------------------------------------------------------------
BattleHandlers::TargetAbilityOnHit.add(:CURSEDBODY,
  proc { |ability,user,target,move,battle|
    next if user.fainted? || user.dynamax?
    next if user.effects[PBEffects::Disable]>0
    regularMove = nil
    user.eachMove do |m|
      next if m.id!=user.lastRegularMoveUsed
      regularMove = m
      break
    end
    next if !regularMove || (regularMove.pp==0 && regularMove.totalpp>0)
    next if battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(target)
    if !move.pbMoveFailedAromaVeil?(target,user,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      user.effects[PBEffects::Disable]     = 3
      user.effects[PBEffects::DisableMove] = regularMove.id
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s {2} was disabled!",user.pbThis,regularMove.name))
      else
        battle.pbDisplay(_INTL("{1}'s {2} was disabled by {3}'s {4}!",
           user.pbThis,regularMove.name,target.pbThis(true),target.abilityName))
      end
      battle.pbHideAbilitySplash(target)
      user.pbItemStatusCureCheck
    end
    battle.pbHideAbilitySplash(target)
  }
)


################################################################################
# SECTION 5 - MAX RAID BATTLE EFFECTS
#===============================================================================
# Initializes effects for Max Raid battles.
#===============================================================================
class PokeBattle_Battler
  def pbInitMaxRaidBoss
    @effects[PBEffects::MaxRaidBoss]   = false
    @effects[PBEffects::RaidShield]    = -1
    @effects[PBEffects::ShieldCounter] = -1
    @effects[PBEffects::KnockOutCount] = -1
    if $game_switches[MAXRAID_SWITCH]
      if @battle.wildBattle? && opposes?
        timerbonus = 0                      if @battle.pbSideSize(0)>=3
        timerbonus = ((level+5)/20).ceil+1  if @battle.pbSideSize(0)==2
        timerbonus = ((level+5)/10).floor+1 if @battle.pbSideSize(0)==1
        @effects[PBEffects::Dynamax]       = 1+MAXRAID_TIMER
        @effects[PBEffects::Dynamax]      += timerbonus if level>20
        @effects[PBEffects::Dynamax]       = 6 if @effects[PBEffects::Dynamax]<6
        @effects[PBEffects::Dynamax]       = 26 if @effects[PBEffects::Dynamax]>26
        @effects[PBEffects::ShieldCounter] = 1
        @effects[PBEffects::ShieldCounter] = 2 if level>35
        @effects[PBEffects::KnockOutCount] = MAXRAID_KOS
        @effects[PBEffects::KnockOutCount] = MAXRAID_KOS-1 if level>55
        @effects[PBEffects::KnockOutCount] = 1 if MAXRAID_KOS<1
        @effects[PBEffects::KnockOutCount] = 6 if MAXRAID_KOS>6
        @effects[PBEffects::RaidShield]    = 0
        @effects[PBEffects::UnMaxMoves]    = [@moves[0],@moves[1],@moves[2],@moves[3]]
        @effects[PBEffects::MaxRaidBoss]   = true
      end
    end
  end
  
#===============================================================================
# Handles success checks for moves used in Max Raid Battles.
#===============================================================================
  def pbSuccessCheckMaxRaid(move,user,target)
    if $game_switches[MAXRAID_SWITCH]
      #-------------------------------------------------------------------------
      # Max Raid Boss Pokemon are immune to specified moves.
      #-------------------------------------------------------------------------
      if target.effects[PBEffects::MaxRaidBoss]
        if move.function=="0F4" || # Bug Bite/Pluck
           move.function=="0F5" || # Incinerate
           move.function=="0F0" || # Knock Off
           move.function=="06C" || # Super Fang
           (move.function=="10D" && user.pbHasType?(:GHOST)) # Curse
          @battle.pbDisplay(_INTL("But it failed!"))
          ret = false
        end
      end
      #-------------------------------------------------------------------------
      # Specified moves fail when used by Max Raid Boss Pokemon.
      #-------------------------------------------------------------------------
      if user.effects[PBEffects::MaxRaidBoss]
        if move.function=="0E1" || # Final Gambit
           move.function=="0E2" || # Memento
           move.function=="0E7" || # Destiny Bond
           move.function=="0EB" || # Roar/Whirlwind
           (move.function=="10D" && user.pbHasType?(:GHOST)) # Curse
          @battle.pbDisplay(_INTL("But it failed!"))
          ret = false
        end
      end
      #-------------------------------------------------------------------------
      # Max Raid Shields block status moves.
      #-------------------------------------------------------------------------
      if target.effects[PBEffects::RaidShield]>0 && move.statusMove?
        @battle.pbDisplay(_INTL("But it failed!"))
        ret = false
      end
      return ret
    end
  end
  
  #-----------------------------------------------------------------------------
  # Max Raid Pokemon can use Belch without consuming a berry.
  #-----------------------------------------------------------------------------
  def belched?
    return true if @effects[PBEffects::MaxRaidBoss]
    return @battle.belch[@index&1][@pokemonIndex]
  end
  
  #-----------------------------------------------------------------------------
  # Ends multi-hit moves early if Raid Pokemon is defeated mid-attack.
  #-----------------------------------------------------------------------------
  def pbBreakRaidMultiHits(targets,hits)
    breakmove = false
    if $game_switches[MAXRAID_SWITCH]
      targets.each do |t|
        breakmove = true if t.hp<=1 && hits>0
      end
    end
    return true if breakmove
  end
  
#===============================================================================
# Handles effects triggered upon using a move in Max Raid Battles.
#===============================================================================
  def pbProcessRaidEffectsOnHit(move,user,targets,hitNum) # Added to def pbProcessMoveHit
    targets.each do |b|
      if $game_switches[MAXRAID_SWITCH] && 
         b.effects[PBEffects::MaxRaidBoss] && 
         b.effects[PBEffects::KnockOutCount]>0
        shieldbreak = 1
        shieldbreak = 2 if move.maxMove?
        if hitNum>0
          shieldbreak = 0
        end
        #-----------------------------------------------------------------------
        # Initiates Max Raid capture sequence if brought down to 0 HP.
        #-----------------------------------------------------------------------
        if b.hp<=0
          b.effects[PBEffects::RaidShield] = 0
          @battle.scene.pbRefresh
          b.pbFaint if b.fainted?
        #-----------------------------------------------------------------------
        # Max Raid Boss Pokemon loses shields.
        #-----------------------------------------------------------------------
        elsif b.effects[PBEffects::RaidShield]>0
          next if !move.damagingMove?
          next if b.damageState.calcDamage==0
          next if shieldbreak==0
          if $DEBUG && Input.press?(Input::CTRL) # Instantly breaks shield.
            shieldbreak = b.effects[PBEffects::RaidShield]
          end
          b.effects[PBEffects::RaidShield] -= shieldbreak
          @battle.scene.pbRefresh
          if b.effects[PBEffects::RaidShield]<=0
            b.effects[PBEffects::RaidShield] = 0
            @battle.pbDisplay(_INTL("The mysterious barrier disappeared!"))
            oldhp = b.hp
            b.hp -= b.totalhp/8
            b.hp  =1 if b.hp<=1
            @battle.scene.pbHPChanged(b,oldhp)
            if b.hp>1
              b.pbLowerStatStage(PBStats::DEFENSE,2,false) 
              b.pbLowerStatStage(PBStats::SPDEF,2,false)
            end
          end
        #-----------------------------------------------------------------------
        # Max Raid Boss Pokemon gains shields.
        #-----------------------------------------------------------------------
        elsif b.effects[PBEffects::RaidShield]<=0
          shieldLvl  = MAXRAID_SHIELD
          shieldLvl += 1 if b.level>25
          shieldLvl += 1 if b.level>35
          shieldLvl += 1 if b.level>45
          shieldLvl += 1 if b.level>55
          shieldLvl += 1 if b.level>65
          shieldLvl += 1 if b.level>=70 || $game_switches[HARDMODE_RAID]
          shieldLvl  = 1 if shieldLvl<=0
          shieldLvl  = 8 if shieldLvl>8
          shields1   = b.hp <= b.totalhp/2            # Activates at 1/2 HP
          shields2   = b.hp <= b.totalhp-b.totalhp/5  # Activates at 4/5ths HP
          if (b.effects[PBEffects::ShieldCounter]==1 && shields1) ||
             (b.effects[PBEffects::ShieldCounter]==2 && shields2)
            @battle.pbDisplay(_INTL("{1} is getting desperate!\nIts attacks are growing more aggressive!",b.pbThis))
            b.effects[PBEffects::RaidShield] = shieldLvl
            b.effects[PBEffects::ShieldCounter]-=1
            @battle.pbAnimation(getID(PBMoves,:LIGHTSCREEN),b,b)
            @battle.scene.pbRefresh
            @battle.pbDisplay(_INTL("A mysterious barrier appeared in front of {1}!",b.pbThis(true)))
          end
        end
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Hard Mode Bonuses (Malicious Wave).
  #-----------------------------------------------------------------------------
  def pbProcessRaidEffectsOnHit2(move,user,targets) # Added to def pbProcessMoveHit
    showMsg = true
    @battle.eachOtherSideBattler(user) do |b|
      if $game_switches[HARDMODE_RAID] || user.level>=70
        if user.effects[PBEffects::MaxRaidBoss] &&
           user.effects[PBEffects::KnockOutCount]>0 &&
           user.effects[PBEffects::RaidShield]<=0 &&
           user.effects[PBEffects::TwoTurnAttack]==0 &&
           move.damagingMove?
          damage = b.totalhp/16 if user.effects[PBEffects::ShieldCounter]>=1
          damage = b.totalhp/8 if user.effects[PBEffects::ShieldCounter]<=0
          oldhp  = b.hp
          if b.hp>0 && !b.fainted?
            @battle.pbDisplay(_INTL("A malicious wave of Dynamax energy rippled from {1}'s attack!",
              user.pbThis(true))) if showMsg
            @battle.pbAnimation(getID(PBMoves,:ACIDARMOR),b,user) if showMsg
            showMsg = false
            @battle.scene.pbDamageAnimation(b)
            b.hp -= damage
            b.hp=0 if b.hp<0
            @battle.scene.pbHPChanged(b,oldhp)
            b.pbFaint if b.fainted?
          end
        end
      end
    end
  end
  
#===============================================================================
# Initiates the capture/victory sequence vs Max Raid Pokemon.
#===============================================================================
  def pbCatchRaidPokemon(target)
    @battle.pbDisplayPaused(_INTL("{1} is weak!\nThrow a Poké Ball now!",target.pbThis))
    pbWait(20)
    scene  = PokemonBag_Scene.new
    screen = PokemonBagScreen.new(scene,$PokemonBag)
    ball   = screen.pbChooseItemScreen(Proc.new{|item| pbIsPokeBall?(item) })
    if ball>0
      if pbIsPokeBall?(ball)
        $PokemonBag.pbDeleteItem(ball,1)
        target.pokemon.resetMoves
        if $game_switches[HARDMODE_RAID] || target.level>=70
          randcapture = rand(100)
          if randcapture<20 || ball==getID(PBItems,:MASTERBALL) ||
             ($DEBUG && Input.press?(Input::CTRL))
            @battle.pbThrowPokeBall(target.index,ball,255,false) # Hard Mode capture (20%)
          else
            @battle.pbThrowPokeBall(target.index,ball,0,false)   # Capture failed
            @battle.pbDisplayPaused(_INTL("{1} disappeared somewhere into the den...",target.pbThis))
            pbSEPlay("Battle flee")
            @battle.decision=1
          end
        else
          @battle.pbThrowPokeBall(target.index,ball,255,false)   # Normal Mode capture (100%)
        end
      end
    else                                                         # Choose not to capture
      @battle.pbDisplayPaused(_INTL("{1} disappeared somewhere into the den...",target.pbThis))
      pbSEPlay("Battle flee")
      @battle.decision=1
    end
  end
  
#===============================================================================
# Handles outcomes in Max Raid battles when party Pokemon are KO'd.
#===============================================================================
  def pbRaidKOCounter(target)
    if target.effects[PBEffects::MaxRaidBoss]
      kocounter = PBEffects::KnockOutCount
      target.effects[kocounter] -= 1
      $game_variables[REWARD_BONUSES][1] = false # Perfect Bonus 
      @battle.scene.pbRefresh
      if target.effects[kocounter]>=2
        @battle.pbDisplay(_INTL("The storm raging around {1} is growing stronger!",target.pbThis(true)))
        koboost=true
      elsif target.effects[kocounter]==1
        @battle.pbDisplay(_INTL("The storm around {1} is growing too strong to withstand!",target.pbThis(true)))
        koboost=true
      elsif target.effects[kocounter]==0
        @battle.pbDisplay(_INTL("The storm around {1} grew out of control!",target.pbThis(true)))
        @battle.pbDisplay(_INTL("You were blown out of the den!"))
        pbSEPlay("Battle flee")
        @battle.decision=3
      end
      #-------------------------------------------------------------------------
      # Max Raid - Hard Mode Bonuses (KO Boost).
      #-------------------------------------------------------------------------
      if koboost && ($game_switches[HARDMODE_RAID] || target.level>=70)
        showAnim=true
        if target.pbCanRaiseStatStage?(PBStats::ATTACK,target)
          target.pbRaiseStatStage(PBStats::ATTACK,1,target,showAnim)
          showAnim=false
        end
        if target.pbCanRaiseStatStage?(PBStats::SPATK,target)
          target.pbRaiseStatStage(PBStats::SPATK,1,target,showAnim)
          showAnim=false
        end
      end
      pbWait(20)
    end
  end
end

#===============================================================================
# Used to reset a Max Raid Pokemon upon capture.
#===============================================================================
module PokeBattle_BattleCommon
  def pbResetRaidPokemon(pkmn)
    if $game_switches[MAXRAID_SWITCH]
      pkmn.makeUndynamax
      pkmn.calcStats
      pkmn.pbReversion(false)
      dlvl = rand(3)
      if pkmn.level>65;    dlvl += 6
      elsif pkmn.level>55; dlvl += 5
      elsif pkmn.level>45; dlvl += 4
      elsif pkmn.level>35; dlvl += 3
      elsif pkmn.level>25; dlvl += 2
      end
      pkmn.setDynamaxLvl(dlvl)
      if pkmn.isSpecies?(:ETERNATUS)
        pkmn.removeGMaxFactor
        pkmn.setDynamaxLvl(0)
      end
      $game_switches[MAXRAID_SWITCH] = false
    end
  end
end

#===============================================================================
# Handles changes to damage taken by Max Raid Pokemon.
#===============================================================================
class PokeBattle_Move
  #-----------------------------------------------------------------------------
  # Damage thresholds for activating Max Raid shields.
  #-----------------------------------------------------------------------------
  def pbReduceMaxRaidDamage(target,damage) # Added to def pbReduceDamage
    if target.effects[PBEffects::MaxRaidBoss] && $game_switches[MAXRAID_SWITCH]
      if target.effects[PBEffects::ShieldCounter]>0
        shield = target.effects[PBEffects::ShieldCounter]
        thresh = target.totalhp/5.floor if shield==2
        thresh = target.totalhp/2.floor if shield==1
        hpstop = target.totalhp-thresh
        if target.hp==target.totalhp && damage>thresh
          damage = thresh+1
        elsif target.hp>hpstop && damage>target.hp-thresh
          damage = target.hp-thresh
        elsif target.hp<=thresh
          damage = 1
        end
      end
    end
    return damage
  end

  #-----------------------------------------------------------------------------
  # Max Raid Pokemon immune to additional effects of moves when shields are up.
  #-----------------------------------------------------------------------------
  def pbAdditionalEffectChance(user,target,effectChance=0)
    return 0 if target.effects[PBEffects::MaxRaidBoss] &&
                target.effects[PBEffects::RaidShield]>0
    return 0 if target.hasActiveAbility?(:SHIELDDUST) && !@battle.moldBreaker
    ret = (effectChance>0) ? effectChance : @addlEffect
    if NEWEST_BATTLE_MECHANICS || @function!="0A4"   # Secret Power
      ret *= 2 if user.hasActiveAbility?(:SERENEGRACE) ||
                  user.pbOwnSide.effects[PBEffects::Rainbow]>0
    end
    ret = 100 if $DEBUG && Input.press?(Input::CTRL)
    return ret
  end
end

#===============================================================================
# Handles the end of round effects of certain Max Raid conditions.
#===============================================================================
class PokeBattle_Battle
  def pbEORMaxRaidEffects(priority) # Added to def pbEndOfRoundPhase
    if $game_switches[MAXRAID_SWITCH]
      priority.each do |b|
        next if !b.effects[PBEffects::MaxRaidBoss]
        next if b.effects[PBEffects::KnockOutCount]==0
        b.pbUnMaxMove if !b.effects[PBEffects::Transform] # Resets Max Moves
        #-----------------------------------------------------------------------
        # Raid Shield thresholds for effect damage.
        #-----------------------------------------------------------------------
        if b.effects[PBEffects::RaidShield]<=0 && b.hp>1
          shieldLvl  = MAXRAID_SHIELD
          shieldLvl += 1 if b.level>25
          shieldLvl += 1 if b.level>35
          shieldLvl += 1 if b.level>45
          shieldLvl += 1 if b.level>55
          shieldLvl += 1 if b.level>65
          shieldLvl += 1 if b.level>=70 || $game_switches[HARDMODE_RAID]
          shieldLvl  = 1 if shieldLvl<=0
          shieldLvl  = 8 if shieldLvl>8
          shields1   = b.hp <= b.totalhp/2             # Activates at 1/2 HP
          shields2   = b.hp <= b.totalhp-b.totalhp/5   # Activates at 4/5ths HP
          if (b.effects[PBEffects::ShieldCounter]==1 && shields1) ||
             (b.effects[PBEffects::ShieldCounter]==2 && shields2)
            pbDisplay(_INTL("{1} is getting desperate!\nIts attacks are growing more aggressive!",b.pbThis))
            b.effects[PBEffects::RaidShield] = shieldLvl
            b.effects[PBEffects::ShieldCounter]-=1
            @scene.pbRefresh
            pbAnimation(getID(PBMoves,:LIGHTSCREEN),b,b)
            pbDisplay(_INTL("A mysterious barrier appeared in front of {1}!",b.pbThis(true)))
          end
        end
        #-----------------------------------------------------------------------
        # Hard Mode Bonuses (Invigorating Wave).
        #-----------------------------------------------------------------------
        if $game_switches[HARDMODE_RAID] || b.level>=70      
          if b.effects[PBEffects::ShieldCounter]==0 && b.hp <= b.totalhp/2
            pbDisplay(_INTL("{1} released an invigorating wave of Dynamax energy!",b.pbThis))
            pbAnimation(getID(PBMoves,:ACIDARMOR),b,b)
            pbCommonAnimation("StatUp",b)
            pbDisplay(_INTL("{1} got powered up!",b.pbThis))
            for stat in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,PBStats::SPATK,PBStats::SPDEF]
              if b.pbCanRaiseStatStage?(stat,b)
                b.pbRaiseStatStageBasic(stat,1,true)
              end
            end
            b.stages[PBStats::ACCURACY]=0 if b.stages[PBStats::ACCURACY]<0
            b.stages[PBStats::EVASION]=0 if b.stages[PBStats::EVASION]<0
            b.effects[PBEffects::ShieldCounter]-=1
          end
          #---------------------------------------------------------------------
          # Hard Mode Bonuses (HP Regeneration).
          #---------------------------------------------------------------------
          next if b.effects[PBEffects::RaidShield]<=0 || b.effects[PBEffects::HealBlock]>0
          next if b.hp == b.totalhp || b.hp==1 
          b.pbRecoverHP((b.totalhp/16).floor)
          pbDisplay(_INTL("{1} regenerated a little HP behind the mysterious barrier!",b.pbThis))
        end
      end
    end
  end
  
  
#===============================================================================
# Handles the attack phase effects of certain Max Raid conditions.
#===============================================================================
  def pbAttackPhaseRaidBoss
    pbPriority.each do |b|
      next unless b.effects[PBEffects::MaxRaidBoss]
      #-------------------------------------------------------------------------
      # Neutralizing Wave
      #-------------------------------------------------------------------------
      randnull=pbRandom(10)
      neutralize=true if randnull<10
      neutralize=true if b.status>0 && randnull<6 
      neutralize=true if b.effects[PBEffects::RaidShield]>0 && randnull<3 
      if neutralize && b.hp < b.totalhp-b.totalhp/5
        pbDisplay(_INTL("{1} released a neutralizing wave of Dynamax energy!",b.pbThis))
        pbAnimation(getID(PBMoves,:ACIDARMOR),b,b)
        pbDisplay(_INTL("All stat increases and Abilities of your Pokémon were nullified!"))
        if b.status>0
          b.pbCureStatus(false)
          pbDisplay(_INTL("{1}'s status returned to normal!",b.pbThis))
        end
        b.effects[PBEffects::Attract]=-1
        b.effects[PBEffects::LeechSeed]=-1
        b.eachOpposing do |p|
          p.effects[PBEffects::GastroAcid] = true
          for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,PBStats::SPATK,
                    PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
            p.stages[i]=0 if p.stages[i]>0
          end
        end
      end
      #-------------------------------------------------------------------------
      # Hard Mode Bonuses (Immobilizing Wave)
      #-------------------------------------------------------------------------
      if $game_switches[HARDMODE_RAID] || b.level>=70
        if b.effects[PBEffects::ShieldCounter]==-1 &&
           b.effects[PBEffects::RaidShield]<=0
          pbDisplay(_INTL("{1} released an immense wave of Dynamax energy!",b.pbThis))
          pbAnimation(getID(PBMoves,:ACIDARMOR),b,b)
          b.eachOpposing do |p|  
            if p.effects[PBEffects::Dynamax]>0
              pbDisplay(_INTL("{1} is unaffected!",p.pbThis))
            else
              pbDisplay(_INTL("The oppressive force immobilized {1}!",p.pbThis))
              p.lastRoundMoved = @turnCount
            end
          end
          b.effects[PBEffects::ShieldCounter]-=1
        end
      end
    end
  end
end


################################################################################
# SECTION 6 - DYNAMAXING
#===============================================================================
# Various battler calls used for Dynamax.
#-------------------------------------------------------------------------------
class PokeBattle_Battler
  # Dynamax Levels/G-Factor
  def dynamaxBoost;   return @pokemon && @pokemon.dynamaxBoost;    end
  def dynamaxAble?;   return @pokemon && @pokemon.dynamaxAble?;    end
  def gmaxFactor?;    return @pokemon && @pokemon.gmaxFactor?;     end
  
  # Checks if the Pokemon is currently Dynamaxed/Gigantamaxed.
  def dynamax?;       return @pokemon && @pokemon.dynamax?;        end
  def gmax?;          return @pokemon && @pokemon.gmax?;           end
  
  # Checks the Pokemon for Dynamax eligibility.
  def hasDynamax?
    powerspot  = $game_map && POWERSPOTS.include?($game_map.map_id)
    eternaspot = $game_map && ETERNASPOT.include?($game_map.map_id)
    return true if isConst?(species,PBSpecies,:ETERNATUS) && eternaspot
    return false if !@pokemon.dynamaxAble?
    return false if @effects[PBEffects::NoDynamax]
    return false if !powerspot && !DMAX_ANYMAP
    return false if mega? || hasMega?
    return false if primal? || hasPrimal?
    return false if shadowPokemon?
    return true
  end
  
  # Checks the Pokemon for Gigantamax eligibility.
  def hasGmax?
    return false if @effects[PBEffects::Transform]
    return @pokemon && @pokemon.hasGmax?
  end
  
  # Un-Dynamaxes a Pokemon.
  def unmax          
    return pbUndynamax                 
  end
end

#===============================================================================
# Allows NPC's to Dynamax. They will only Dynamax their Ace Pokemon.
#===============================================================================
class PokeBattle_AI
  def pbEnemyShouldDynamax?(idxBattler)
    battler = @battle.battlers[idxBattler]
    if @battle.pbCanDynamax?(idxBattler) && battler.pokemon.trainerAce?
      battler.pbMaxMove if !@battle.pbOwnedByPlayer?(idxBattler)
      PBDebug.log("[AI] #{battler.pbThis} (#{idxBattler}) will Dynamax")
      return true
    end
    return false
  end
end

#===============================================================================
# Dynamaxing a Pokemon in battle.
#===============================================================================
class PokeBattle_Battle
  attr_accessor(:dynamax)
  
  alias dynamax_initialize initialize
  def initialize(scene,p1,p2,player,opponent)
    dynamax_initialize(scene,p1,p2,player,opponent)
    @dynamax         = [
       [-1] * (@player ? @player.length : 1),
       [-1] * (@opponent ? @opponent.length : 1)
    ]
    if $game_switches[MAXRAID_SWITCH]
      @canRun            = false
      @canLose           = true
      @expGain           = false
      @moneyGain         = false
    end
  end
  
  #-----------------------------------------------------------------------------
  # Checks if the user is currently capable of Dynamaxing during a battle.
  #-----------------------------------------------------------------------------
  def pbCanDynamax?(idxBattler)
    battler = @battlers[idxBattler]
    side  = battler.idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    return false if $game_switches[NO_DYNAMAX]                             # No Dynamax if switch enabled.
    return false if !battler.hasDynamax?                                   # No Dynamax if ineligible.
    return false if pbCanUltraCompat?(idxBattler)                          # No Dynamax if Ultra Burst usable.
    return false if pbCanZMoveCompat?(idxBattler)                          # No Dynamax if Z-Move usable.
    return false if pbCanZodiacCompat?(idxBattler)                         # No Dynamax if Zodiac Power usable.
    return false if wildBattle? && opposes?(idxBattler)                    # No Dynamax for wild Pokemon.
    return true if $DEBUG && Input.press?(Input::CTRL)                     # Allows Dynamax with CTRL in Debug.
    return false if battler.effects[PBEffects::SkyDrop]>=0                 # No Dynamax if in Sky Drop.
    return false if !pbHasDynamaxBand?(idxBattler)                         # No Dynamax if no Dynamax Band.
    return false if @dynamax[side][owner]!=-1                              # No Dynamax if used this battle.
    return true if $game_switches[MAXRAID_SWITCH]                          # Allows Dynamax in Max Raids.
    return false if wildBattle? && !CAN_DMAX_WILD                          # No Dynamax in normal wild battles.
    return @dynamax[side][owner]==-1
  end
  
  #-----------------------------------------------------------------------------
  # Registering Dynamax
  #-----------------------------------------------------------------------------
  def pbRegisterDynamax(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @dynamax[side][owner] = idxBattler
  end

  def pbUnregisterDynamax(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @dynamax[side][owner] = -1 if @dynamax[side][owner]==idxBattler
  end

  def pbToggleRegisteredDynamax(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    if @dynamax[side][owner]==idxBattler
      @dynamax[side][owner] = -1
    else
      @dynamax[side][owner] = idxBattler
    end
  end

  def pbRegisteredDynamax?(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    return @dynamax[side][owner]==idxBattler
  end
  
  #-----------------------------------------------------------------------------
  # Checks for Dynamax Bands.
  #-----------------------------------------------------------------------------
  def pbHasDynamaxBand?(idxBattler)
    return true if !pbOwnedByPlayer?(idxBattler)
    DMAX_BANDS.each do |item|
      return true if $PokemonBag.pbHasItem?(item)
    end
    return false
  end
  
  #-----------------------------------------------------------------------------
  # Dynamaxes an eligible Pokemon.
  #-----------------------------------------------------------------------------
  def pbDynamax(idxBattler)
    battler = @battlers[idxBattler]
    return if !battler || !battler.pokemon
    return if !battler.hasDynamax? || battler.dynamax? 
    trainerName = pbGetOwnerName(idxBattler)
    pbDisplay(_INTL("{1} recalled {2}!",trainerName,battler.pbThis(true)))
    battler.effects[PBEffects::Dynamax] = DYNAMAX_TURNS
    battler.effects[PBEffects::Encore]  = 0
    battler.effects[PBEffects::Disable] = 0
    battler.effects[PBEffects::Torment] = false
    @scene.pbRecall(idxBattler)
    # Alcremie reverts to form 0 only for the duration of Gigantamax.
    if battler.isSpecies?(:ALCREMIE) && battler.gmaxFactor?
      battler.pokemon.form = 0 
    end
    battler.pokemon.makeDynamax
    text = "Dynamax"
    text = "Gigantamax" if battler.hasGmax? && battler.gmaxFactor?
    text = "Eternamax"  if isConst?(battler.species,PBSpecies,:ETERNATUS)
    pbDisplay(_INTL("{1}'s ball surges with {2} energy!",battler.pbThis,text))
    party = pbParty(idxBattler)
    idxPartyStart, idxPartyEnd = pbTeamIndexRangeFromBattlerIndex(idxBattler)
    for i in idxPartyStart...idxPartyEnd
      if party[i] == battler.pokemon
        pbSendOut([[idxBattler,party[i]]])
      end
    end
    # Gets appropriate battler sprite if user was transformed prior to Dynamaxing.
    if battler.effects[PBEffects::Transform]
      back = !opposes?(idxBattler)
      pkmn = battler.effects[PBEffects::TransformSpecies]
      @scene.sprites["pokemon_#{idxBattler}"].setPokemonBitmap(pkmn,back)
    end
    side  = battler.idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @dynamax[side][owner] = -2
    oldhp = battler.hp
    battler.pbUpdate(false)
    @scene.pbHPChanged(battler,oldhp)
    battler.pokemon.pbReversion(true)
  end
  
  def pbAttackPhaseDynamax
    pbPriority.each do |b|
      next if wildBattle? && b.opposes?
      next unless @choices[b.index][0]==:UseMove && !b.fainted?
      owner = pbGetOwnerIndexFromBattlerIndex(b.index)
      next if @dynamax[b.idxOwnSide][owner]!= b.index
      pbDynamax(b.index)
    end
  end
  
#===============================================================================
# Reverting the effects of Dynamax.
#===============================================================================
# Counts down Dynamax turns and reverts the user once it expires.
#-------------------------------------------------------------------------------
  def pbDynamaxTimer # Added to def pbEndOfRoundPhase
    eachBattler do |b|
      next if b.effects[PBEffects::Dynamax]<=0
      b.effects[PBEffects::Dynamax]-=1
      b.unmax if b.effects[PBEffects::Dynamax]==0
      # Checks for Max Raid reward bonuses and timer.
      if $game_switches[MAXRAID_SWITCH]
        @scene.pbRefresh
        next if !b.effects[PBEffects::MaxRaidBoss]
        $game_variables[REWARD_BONUSES][0] = b.effects[PBEffects::Dynamax] # Timer Bonus
        b.eachOpposing do |opp|
          $game_variables[REWARD_BONUSES][2] = false if opp.level >= b.level+5  # Fairness Bonus
        end
        if b.effects[PBEffects::Dynamax]<=1 && b.effects[PBEffects::KnockOutCount]>0
          pbDisplayPaused(_INTL("The storm around {1} grew out of control!",b.pbThis(true)))
          pbDisplay(_INTL("You were blown out of the den!"))
          pbSEPlay("Battle flee")
          @decision=3
        end
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Reverts Dynamax upon switching.
  #-----------------------------------------------------------------------------
  def pbRecallAndReplace(idxBattler,idxParty,batonPass=false)
    @battlers[idxBattler].unmax if @battlers[idxBattler].dynamax?
    @scene.pbRecall(idxBattler) if !@battlers[idxBattler].fainted?
    @battlers[idxBattler].pbAbilitiesOnSwitchOut
    @scene.pbShowPartyLineup(idxBattler&1) if pbSideSize(idxBattler)==1
    pbMessagesOnReplace(idxBattler,idxParty)
    pbReplace(idxBattler,idxParty,batonPass)
  end
  
  def pbSwitchInBetween(idxBattler,checkLaxOnly=false,canCancel=false)
    @battlers[idxBattler].unmax if @battlers[idxBattler].dynamax?
    return pbPartyScreen(idxBattler,checkLaxOnly,canCancel) if pbOwnedByPlayer?(idxBattler)
    return @battleAI.pbDefaultChooseNewEnemy(idxBattler,pbParty(idxBattler))
  end
  
  #-----------------------------------------------------------------------------
  # Reverts Dynamax at the end of battle.
  #-----------------------------------------------------------------------------
  alias dynamax_pbEndOfBattle pbEndOfBattle
  def pbEndOfBattle
    @battlers.each do |b|
      next if !b || !b.dynamax?
      next if b.effects[PBEffects::MaxRaidBoss]
      b.unmax
    end
    dynamax_pbEndOfBattle
  end
end

class PokeBattle_Scene
  #-----------------------------------------------------------------------------
  # Reverts Dynamax upon fainting.
  #-----------------------------------------------------------------------------
  alias dynamax_pbFaintBattler pbFaintBattler
  def pbFaintBattler(battler)
    if @battle.battlers[battler.index].dynamax?
      @battle.battlers[battler.index].unmax
    end
    dynamax_pbFaintBattler(battler)
  end

  #-----------------------------------------------------------------------------
  # Reverts enlarged Pokemon sprites to normal size.
  #-----------------------------------------------------------------------------
  def pbChangePokemon(idxBattler,pkmn)
    idxBattler = idxBattler.index if idxBattler.respond_to?("index")
    battler    = @battle.battlers[idxBattler]
    pkmnSprite   = @sprites["pokemon_#{idxBattler}"]
    shadowSprite = @sprites["shadow_#{idxBattler}"]
    back = !@battle.opposes?(idxBattler)
    pkmnSprite.setPokemonBitmap(pkmn,back)
    shadowSprite.setPokemonBitmap(pkmn)
    if shadowSprite && !back
      shadowSprite.visible = showShadow?(pkmn.fSpecies)
    end
    # Reverts to initial sprite once Dynamax ends.
    if !battler.dynamax?
      if battler.effects[PBEffects::Transform]
        pkmn = battler.effects[PBEffects::TransformSpecies]
        @sprites["pokemon_#{idxBattler}"].setPokemonBitmap(pkmn,back)
      end
      if ENLARGE_SPRITE
        pkmnSprite.zoom_x   = 1
        pkmnSprite.zoom_y   = 1
        shadowSprite.zoom_x = 1
        shadowSprite.zoom_y = 1
      end
      if DYNAMAX_COLOR
        pkmnSprite.color = Color.new(0,0,0,0)
      end
    end
  end
end

#-------------------------------------------------------------------------------
# Reverts a Dynamaxed Pokemon.
#-------------------------------------------------------------------------------
class PokeBattle_Battler
  def pbUndynamax
    text = "Dynamax"
    text = "Gigantamax" if gmax?
    text = "Eternamax"  if isConst?(species,PBSpecies,:ETERNATUS)
    pbUnMaxMove(true)
    @pokemon.makeUndynamax
    pbUpdate(false)
    @pokemon.pbReversion(false)
    if !@effects[PBEffects::MaxRaidBoss]
      @effects[PBEffects::Dynamax]   = 0
      @effects[PBEffects::DButton]   = false
      self.form = @effects[PBEffects::NonGMaxForm] if self.isSpecies?(:ALCREMIE)
      @battle.scene.pbChangePokemon(self,@pokemon)
      @battle.scene.pbHPChanged(self,totalhp) if !fainted?
      @battle.pbDisplay(_INTL("{1}'s {2} energy left its body!",pbThis,text))
      @battle.scene.pbRefresh
    end
  end

  
################################################################################
# SECTION 7 - SETTING UP MAX MOVES
#===============================================================================
# Converts base moves into Max Moves.
#===============================================================================
  def pbMaxMove
    oldmoves = [@moves[0],@moves[1],@moves[2],@moves[3]]
    if !@effects[PBEffects::MaxRaidBoss]
      @effects[PBEffects::UnMaxMoves] = oldmoves
    end
    for i in 0...4
      if @moves[i].id>0
        #-----------------------------------------------------------------------
        # Status moves become Max Guard.
        #-----------------------------------------------------------------------
        if @moves[i].statusMove?
          # Transform doesn't become Max Guard, but only when used by Ditto.
          if !(@moves[i].id==getID(PBMoves,:TRANSFORM) && isSpecies?(:DITTO))
            @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:MAXGUARD)))
          end
        else
          #---------------------------------------------------------------------
          # Normal-type Max Moves.
          #---------------------------------------------------------------------
          if @moves[i].type==0 # Normal
            if isSpecies?(:MEOWTH) && gmaxFactor?
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:GMAXGOLDRUSH)))
            elsif isSpecies?(:EEVEE) && gmaxFactor?
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:GMAXCUDDLE)))
            elsif isSpecies?(:SNORLAX) && gmaxFactor?
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:GMAXREPLENISH)))
            else
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:MAXSTRIKE)))
            end
          #---------------------------------------------------------------------
          # Fighting-type Max Moves.
          #---------------------------------------------------------------------
          elsif @moves[i].type==1 # Fighting
            if isSpecies?(:MACHAMP) && gmaxFactor?
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:GMAXCHISTRIKE)))
            else
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:MAXKNUCKLE)))
            end
          #---------------------------------------------------------------------
          # Flying-type Max Moves.
          #---------------------------------------------------------------------
          elsif @moves[i].type==2 # Flying
            if isSpecies?(:CORVIKNIGHT) && gmaxFactor?
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:GMAXWINDRAGE)))
            else
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:MAXAIRSTREAM)))
            end
          #---------------------------------------------------------------------
          # Poison-type Max Moves.
          #---------------------------------------------------------------------
          elsif @moves[i].type==3 # Poison
            if isSpecies?(:GARBODOR) && gmaxFactor?
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:GMAXMALODOR)))
            else
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:MAXOOZE)))
            end
          #---------------------------------------------------------------------
          # Ground-type Max Moves.
          #---------------------------------------------------------------------
          elsif @moves[i].type==4 # Ground
            if isSpecies?(:SANDACONDA) && gmaxFactor?
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:GMAXSANDBLAST)))
            else
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:MAXQUAKE)))
            end
          #---------------------------------------------------------------------
          # Rock-type Max Moves.
          #---------------------------------------------------------------------
          elsif @moves[i].type==5 # Rock
            if isSpecies?(:COALOSSAL) && gmaxFactor?
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:GMAXVOLCALITH)))
            else
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:MAXROCKFALL)))
            end
          #---------------------------------------------------------------------
          # Bug-type Max Moves.
          #---------------------------------------------------------------------
          elsif @moves[i].type==6 # Bug
            if isSpecies?(:BUTTERFREE) && gmaxFactor?
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:GMAXBEFUDDLE)))
            else
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:MAXFLUTTERBY)))
            end
          #---------------------------------------------------------------------
          # Ghost-type Max Moves.
          #---------------------------------------------------------------------
          elsif @moves[i].type==7 # Ghost
            if isSpecies?(:GENGAR) && gmaxFactor?
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:GMAXTERROR)))
            else
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:MAXPHANTASM)))
            end
          #---------------------------------------------------------------------
          # Steel-type Max Moves.
          #---------------------------------------------------------------------
          elsif @moves[i].type==8 # Steel
            if isSpecies?(:MELMETAL) && gmaxFactor?
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:GMAXMELTDOWN)))
            elsif isSpecies?(:COPPERAJAH)
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:GMAXSTEELSURGE)))
            else
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:MAXSTEELSPIKE)))
            end
          #---------------------------------------------------------------------
          # Fire-type Max Moves.
          #---------------------------------------------------------------------
          elsif @moves[i].type==10 # Fire
            if isSpecies?(:CHARIZARD) && gmaxFactor?
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:GMAXWILDFIRE)))
            elsif isSpecies?(:CINDERACE) && gmaxFactor?
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:GMAXFIREBALL)))
            elsif isSpecies?(:CENTISCORCH) && gmaxFactor?
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:GMAXCENTIFERNO)))
            else
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:MAXFLARE)))
            end
          #---------------------------------------------------------------------
          # Water-type Max Moves.
          #---------------------------------------------------------------------
          elsif @moves[i].type==11 # Water
            if isSpecies?(:BLASTOISE) && gmaxFactor?
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:GMAXCANNONADE)))
            elsif isSpecies?(:KINGLER) && gmaxFactor?
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:GMAXFOAMBURST)))
            elsif isSpecies?(:INTELEON) && gmaxFactor?
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:GMAXHYDROSNIPE)))
            elsif isSpecies?(:DREADNAW) && gmaxFactor?
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:GMAXSTONESURGE)))
            elsif isSpecies?(:URSHIFU) && gmaxFactor? && form==1
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:GMAXRAPIDFLOW)))
            else
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:MAXGEYSER)))
            end
          #---------------------------------------------------------------------
          # Grass-type Max Moves.
          #---------------------------------------------------------------------
          elsif @moves[i].type==12 # Grass
            if isSpecies?(:VENUSAUR) && gmaxFactor?
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:GMAXVINELASH)))
            elsif isSpecies?(:RILLABOOM) && gmaxFactor?
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:GMAXDRUMSOLO)))
            elsif isSpecies?(:FLAPPLE) && gmaxFactor?
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:GMAXTARTNESS)))
            elsif isSpecies?(:APPLETUN) && gmaxFactor?
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:GMAXSWEETNESS)))
            else
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:MAXOVERGROWTH)))
            end
          #---------------------------------------------------------------------
          # Electric-type Max Moves.
          #---------------------------------------------------------------------
          elsif @moves[i].type==13 # Electric
            if isSpecies?(:PIKACHU) && gmaxFactor?
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:GMAXVOLTCRASH)))
            elsif isSpecies?(:TOXTRICITY) && gmaxFactor?
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:GMAXSTUNSHOCK)))
            else
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:MAXLIGHTNING)))
            end
          #---------------------------------------------------------------------
          # Psychic-type Max Moves.
          #---------------------------------------------------------------------
          elsif @moves[i].type==14 # Psychic
            if isSpecies?(:ORBEETLE) && gmaxFactor?
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:GMAXGRAVITAS)))
            else
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:MAXMINDSTORM)))
            end
          #---------------------------------------------------------------------
          # Ice-type Max Moves.
          #---------------------------------------------------------------------
          elsif @moves[i].type==15 # Ice
            if isSpecies?(:LAPRAS) && gmaxFactor?
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:GMAXRESONANCE)))
            else
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:MAXHAILSTORM)))
            end
          #---------------------------------------------------------------------
          # Dragon-type Max Moves.
          #---------------------------------------------------------------------
          elsif @moves[i].type==16 # Dragon
            if isSpecies?(:DURALUDON) && gmaxFactor?
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:GMAXDEPLETION)))
            else
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:MAXWYRMWIND)))
            end
          #---------------------------------------------------------------------
          # Dark-type Max Moves.
          #---------------------------------------------------------------------
          elsif @moves[i].type==17 # Dark
            if isSpecies?(:GRIMMSNARL) && gmaxFactor?
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:GMAXSNOOZE)))
            elsif isSpecies?(:URSHIFU) && gmaxFactor? && form==0
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:GMAXONEBLOW)))
            else
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:MAXDARKNESS)))
            end
          #---------------------------------------------------------------------
          # Fairy-type Max Moves.
          #---------------------------------------------------------------------
          elsif @moves[i].type==18 # Fairy
            if isSpecies?(:HATTERENE) && gmaxFactor?
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:GMAXSMITE)))
            elsif isSpecies?(:ALCREMIE) && gmaxFactor?
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:GMAXFINALE)))
            else
              @moves[i] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(getConst(PBMoves,:MAXSTARFALL)))
            end
          end
          #---------------------------------------------------------------------
          # Converts Max Move Base Power to scale with base move's power.
          #---------------------------------------------------------------------
          @moves[i].pbSetMaxMovePower(oldmoves[i]) if !pbIsSetGmaxMove?(@moves[i])   # Base Damage
        end
      end
      #-------------------------------------------------------------------------
      # Converts base move's properties into equivalent Max Move properties.
      #-------------------------------------------------------------------------
      @moves[i].pp      = PokeBattle_Move.pbFromPBMove(@battle,oldmoves[i]).pp       # PP
      @moves[i].totalpp = PokeBattle_Move.pbFromPBMove(@battle,oldmoves[i]).totalpp  # Total PP
      @moves[i].makeSpecial if oldmoves[i].specialMove?(type)                        # Damage Category
    end
    return false
  end
  
  #-----------------------------------------------------------------------------
  # Reverts Max Moves into base moves.
  #-----------------------------------------------------------------------------
  def pbUnMaxMove(unmax=false)
    oldmoves = @pokemon.moves
    # Gets a transformed Pokemon's copied moves from before they Dynamaxed.
    oldmoves = @effects[PBEffects::UnMaxMoves] if @effects[PBEffects::Transform] 
    @moves  = [
     PokeBattle_Move.pbFromPBMove(@battle,oldmoves[0]),
     PokeBattle_Move.pbFromPBMove(@battle,oldmoves[1]),
     PokeBattle_Move.pbFromPBMove(@battle,oldmoves[2]),
     PokeBattle_Move.pbFromPBMove(@battle,oldmoves[3])
    ]
    if unmax
      for i in 0...4
        oldmoves[i].pp   -= @effects[PBEffects::MaxMovePP][i]
        @moves[i].pp      = oldmoves[i].pp
        @moves[i].totalpp = oldmoves[i].totalpp
        @effects[PBEffects::MaxMovePP][i] = 0
      end
    end
  end
end
  
#===============================================================================
# Converts move's base power into Max Move power.
#===============================================================================
def pbSetMaxMovePower(oldmove,displayOnly=false)
  #-----------------------------------------------------------------------------
  # Becomes Max Move with 70 BP.
  #-----------------------------------------------------------------------------
  if oldmove==getID(PBMoves,:ARMTHRUST)
    basedamage = 70
  #-----------------------------------------------------------------------------
  # Becomes Max Move with 75 BP.
  #-----------------------------------------------------------------------------
  elsif oldmove==getID(PBMoves,:SEISMICTOSS) ||
        oldmove==getID(PBMoves,:COUNTER)
    basedamage = 75
  #-----------------------------------------------------------------------------
  # Becomes Max Move with 80 BP.
  #-----------------------------------------------------------------------------
  elsif oldmove==getID(PBMoves,:DOUBLEKICK) ||
        oldmove==getID(PBMoves,:TRIPLEKICK)
    basedamage = 80
  #-----------------------------------------------------------------------------
  # Becomes Max Move with 100 BP.
  #-----------------------------------------------------------------------------
  elsif oldmove==getID(PBMoves,:FURYSWIPES) ||
        oldmove==getID(PBMoves,:NIGHTSHADE) ||
        oldmove==getID(PBMoves,:FINALGAMBIT) ||
        oldmove==getID(PBMoves,:METALBURST) ||
        oldmove==getID(PBMoves,:MIRRORCOAT) ||
        oldmove==getID(PBMoves,:SUPERFANG) ||
        oldmove==getID(PBMoves,:BEATUP) ||
        oldmove==getID(PBMoves,:FLING) ||
        oldmove==getID(PBMoves,:LOWKICK) ||
        oldmove==getID(PBMoves,:PRESENT) ||
        oldmove==getID(PBMoves,:REVERSAL) ||
        oldmove==getID(PBMoves,:SPITUP)
    basedamage = 100
  #-----------------------------------------------------------------------------
  # Becomes Max Move with 120 BP.
  #-----------------------------------------------------------------------------
  elsif oldmove==getID(PBMoves,:DOUBLEHIT)
    basedamage = 120
  #-----------------------------------------------------------------------------
  # Becomes Max Move with 130 BP.
  #-----------------------------------------------------------------------------
  elsif oldmove==getID(PBMoves,:BULLETSEED) ||
        oldmove==getID(PBMoves,:BONERUSH) ||
        oldmove==getID(PBMoves,:ICICLESPEAR) ||
        oldmove==getID(PBMoves,:PINMISSILE) ||
        oldmove==getID(PBMoves,:ROCKBLAST) ||
        oldmove==getID(PBMoves,:TAILSLAP) ||
        oldmove==getID(PBMoves,:BONEMERANG) ||
        oldmove==getID(PBMoves,:DRAGONDARTS) ||
        oldmove==getID(PBMoves,:GEARGRIND) ||
        oldmove==getID(PBMoves,:SURGINGSTRIKES) ||
        oldmove==getID(PBMoves,:ENDEAVOR) ||
        oldmove==getID(PBMoves,:ELECTROBALL) ||
        oldmove==getID(PBMoves,:FLAIL) ||
        oldmove==getID(PBMoves,:GRASSKNOT) ||
        oldmove==getID(PBMoves,:GYROBALL) ||
        oldmove==getID(PBMoves,:HEATCRASH) ||
        oldmove==getID(PBMoves,:HEAVYSLAM) ||
        oldmove==getID(PBMoves,:POWERTRIP) ||
        oldmove==getID(PBMoves,:STOREDPOWER)
    basedamage = 130
  #-----------------------------------------------------------------------------
  # Becomes Max Move with 140 BP.
  #-----------------------------------------------------------------------------
  elsif oldmove==getID(PBMoves,:DOUBLEIRONBASH) ||
        oldmove==getID(PBMoves,:CRUSHGRIP)
    basedamage = 140
  #-----------------------------------------------------------------------------
  # Becomes Max Move with 150 BP.
  #-----------------------------------------------------------------------------
  elsif oldmove==getID(PBMoves,:ERUPTION) ||
        oldmove==getID(PBMoves,:WATERSPOUT)
    basedamage = 150
  #-----------------------------------------------------------------------------
  # All other moves scale based on their BP.
  #-----------------------------------------------------------------------------
  else  
    moveType      = pbGetMoveData(oldmove,MOVE_TYPE)
    moveBasePower = pbGetMoveData(oldmove,MOVE_BASE_DAMAGE)
    if moveBasePower<45
      basedamage = 90
      reduce = 20
    elsif moveBasePower<55
      basedamage = 100
      reduce = 25
    elsif moveBasePower<65
      basedamage = 110
      reduce = 30
    elsif moveBasePower<75
      basedamage = 120
      reduce = 35
    elsif moveBasePower<110
      basedamage = 130
      reduce = 40
    elsif moveBasePower<150
      basedamage = 140
      reduce = 45
    elsif moveBasePower>=150
      basedamage = 150
      reduce = 50
    end
    #-------------------------------------------------------------------------
    # Fighting/Poison moves have reduced BP.
    #-------------------------------------------------------------------------
    if moveType==1 || moveType==3
      basedamage = (basedamage-reduce)
    end
  end
  if displayOnly
    return basedamage
  else
    @baseDamage = basedamage
  end
end

#-------------------------------------------------------------------------------
# Checks if a G-Max move has a set base power or not.
#-------------------------------------------------------------------------------
def pbIsSetGmaxMove?(move)
  gmaxmoves = []
  move = getID(PBMoves,move)
  for i in GMAX_SET_POWER; gmaxmoves.push(getID(PBMoves,i)); end
  for i in gmaxmoves; return true if move==i; end
  return false
end

#===============================================================================
# Max Move properties.
#===============================================================================
class PokeBattle_Move
  # Used to convert a Max Move's damage category to special.
  def makeSpecial
    @category=1
  end
  
  # Max Moves use flag "x".
  def maxMove?; return @flags[/x/]; end 
  
  # Effect for Ability-ignoring G-Max Moves.
  def pbIgnoreAbilities?; return false; end
    
  def pbImmunityByAbility(user,target)
    return false if @battle.moldBreaker
    return false if pbIgnoreAbilities?
    ret = false
    if target.abilityActive?
      ret = BattleHandlers.triggerMoveImmunityTargetAbility(target.ability,
         user,target,self,@calcType,@battle)
    end
    return ret
  end  
    
#===============================================================================
# Calculates final damage dealt under certain Dynamax conditions.
#===============================================================================
  def pbCalcDynamaxDamage(target,multipliers) # Added to def pbCalcDamageMultipliers
    #---------------------------------------------------------------------------
    # Reduces damage from Max Moves while protected.
    #---------------------------------------------------------------------------
    if (target.effects[PBEffects::Protect] || 
        target.effects[PBEffects::KingsShield] ||
        target.effects[PBEffects::SpikyShield] ||
        target.effects[PBEffects::BanefulBunker] ||
        target.pbOwnSide.effects[PBEffects::MatBlock]) && maxMove?
      if !isConst?(@id,PBMoves,:GMAXONEBLOW) &&
         !isConst?(@id,PBMoves,:GMAXRAPIDFLOW)
        multipliers[FINAL_DMG_MULT] /= 0.75
      end
    end
    #---------------------------------------------------------------------------
    # Doubles damage vs Dynamax targets with specified moves.
    #---------------------------------------------------------------------------
    if target.effects[PBEffects::Dynamax]>0 && !target.isSpecies?(:ETERNATUS)
      antiDynamax = [:BEHEMOTHBLADE,:BEHEMOTHBASH,:DYNAMAXCANNON]
      for i in antiDynamax
        multipliers[FINAL_DMG_MULT] *= 2 if isConst?(@id,PBMoves,i)
      end
    end
    #---------------------------------------------------------------------------
    # Greatly reduces damage taken while behind a Raid Shield.
    #---------------------------------------------------------------------------
    if target.effects[PBEffects::RaidShield]>0
      multipliers[FINAL_DMG_MULT] /= 24
    end
  end
end
 
#===============================================================================
# Changes Max Moves to a different type under certain conditions.
#===============================================================================
class PokeBattle_Battle
  def pbChangeMaxMove(idxBattler,idxMove)
    battler  = @battlers[idxBattler]
    thismove = battler.moves[idxMove]
    basemove = battler.pokemon.moves[idxMove].id
    if thismove.type==0 && thismove.maxMove?
      #-------------------------------------------------------------------------
      # Abilities that change move type.
      #-------------------------------------------------------------------------
      newmove = :ICE      if isConst?(battler.ability,PBAbilities,:REFRIGERATE)
      newtype = :FAIRY    if isConst?(battler.ability,PBAbilities,:PIXILATE)
      newtype = :FLYING   if isConst?(battler.ability,PBAbilities,:AERILATE)
      newtype = :ELECTRIC if isConst?(battler.ability,PBAbilities,:GALVANIZE)
      #-------------------------------------------------------------------------
      # Base move is Weather Ball.
      #-------------------------------------------------------------------------
      if basemove==getID(PBMoves,:WEATHERBALL)
        case pbWeather
        when PBWeather::Sun, PBWeather::HarshSun;   newtype = :FIRE
        when PBWeather::Rain, PBWeather::HeavyRain; newtype = :WATER
        when PBWeather::Sandstorm;                  newtype = :ROCK
        when PBWeather::Hail;                       newtype = :ICE
        end
      #-------------------------------------------------------------------------
      # Base move is Terrain Pulse.
      #-------------------------------------------------------------------------
      elsif basemove==getID(PBMoves,:TERRAINPULSE)
        case @field.terrain
        when PBBattleTerrains::Electric;            newtype = :ELECTRIC
        when PBBattleTerrains::Grassy;              newtype = :GRASS
        when PBBattleTerrains::Misty;               newtype = :FAIRY
        when PBBattleTerrains::Psychic;             newtype = :PSYCHIC
        end
      #-------------------------------------------------------------------------
      # Base move is Revelation Dance.
      #-------------------------------------------------------------------------
      elsif basemove==getID(PBMoves,:REVELATIONDANCE)
        userTypes = battler.pbTypes(true)
        newtype   = userTypes[0]
      #-------------------------------------------------------------------------
      # Base move is Techno Blast.
      #-------------------------------------------------------------------------
      elsif basemove==getID(PBMoves,:TECHNOBLAST) && battler.isSpecies?(:GENESECT)
        itemtype  = true
        itemTypes = {
           :SHOCKDRIVE => :ELECTRIC,
           :BURNDRIVE  => :FIRE,
           :CHILLDRIVE => :ICE,
           :DOUSEDRIVE => :WATER
        }
      #-------------------------------------------------------------------------
      # Base move is Judgment.
      #------------------------------------------------------------------------- 
      elsif basemove==getID(PBMoves,:JUDGMENT) && 
            isConst?(battler.ability,PBAbilities,:MULTITYPE)
        itemtype  = true
        itemTypes = {
           :FISTPLATE   => :FIGHTING,
           :SKYPLATE    => :FLYING,
           :TOXICPLATE  => :POISON,
           :EARTHPLATE  => :GROUND,
           :STONEPLATE  => :ROCK,
           :INSECTPLATE => :BUG,
           :SPOOKYPLATE => :GHOST,
           :IRONPLATE   => :STEEL,
           :FLAMEPLATE  => :FIRE,
           :SPLASHPLATE => :WATER,
           :MEADOWPLATE => :GRASS,
           :ZAPPLATE    => :ELECTRIC,
           :MINDPLATE   => :PSYCHIC,
           :ICICLEPLATE => :ICE,
           :DRACOPLATE  => :DRAGON,
           :DREADPLATE  => :DARK,
           :PIXIEPLATE  => :FAIRY
        }
      #-------------------------------------------------------------------------
      # Base move is Multi-Attack.
      #-------------------------------------------------------------------------
      elsif basemove==getID(PBMoves,:MULTIATTACK) && 
            isConst?(battler.ability,PBAbilities,:RKSSYSTEM)
        itemtype  = true
        itemTypes = {
           :FIGHTINGMEMORY => :FIGHTING,
           :SLYINGMEMORY   => :FLYING,
           :POISONMEMORY   => :POISON,
           :GROUNDMEMORY   => :GROUND,
           :ROCKMEMORY     => :ROCK,
           :BUGMEMORY      => :BUG,
           :GHOSTMEMORY    => :GHOST,
           :STEELMEMORY    => :STEEL,
           :FIREMEMORY     => :FIRE,
           :WATERMEMORY    => :WATER,
           :GRASSMEMORY    => :GRASS,
           :ELECTRICMEMORY => :ELECTRIC,
           :PSYCHICMEMORY  => :PSYCHIC,
           :ICEMEMORY      => :ICE,
           :DRAGONMEMORY   => :DRAGON,
           :DARKMEMORY     => :DARK,
           :FAIRYMEMORY    => :FAIRY
        }
      end
      if battler.itemActive? && itemtype
        itemTypes.each do |item, itemType|
          next if !isConst?(battler.item,PBItems,item)
          newtype = itemType
          break
        end
      end
      #-------------------------------------------------------------------------
      # Converts Max Move into a Max Move of a new type.
      #-------------------------------------------------------------------------
      if newtype
        newtype  = getID(PBTypes,newtype)
        gmaxmove = pbGetGMaxMoveFromSpecies(battler,newtype)
        if battler.gmaxFactor? && gmaxmove
          maxMove = gmaxmove
        else
          maxMove = DYNAMAX_MOVES[newtype]
        end
        newMove = getConst(PBMoves,maxMove)
        @choices[idxBattler][2] = PokeBattle_Move.pbFromPBMove(self,PBMove.new(newMove))
        @choices[idxBattler][2].makeSpecial if thismove.specialMove?(type)
        if !pbIsSetGmaxMove?(maxMove)
          @choices[idxBattler][2].pbSetMaxMovePower(PokeBattle_Move.pbFromPBMove(self,PBMove.new(basemove)))
        end
      end
    end
  end
  
  def pbRegisterMove(idxBattler,idxMove,showMessages=true)
    battler = @battlers[idxBattler]
    move = battler.moves[idxMove]
    return false if !pbCanChooseMove?(idxBattler,idxMove,showMessages)
    @choices[idxBattler][0] = :UseMove   # "Use move"
    @choices[idxBattler][1] = idxMove    # Index of move to be used
    @choices[idxBattler][2] = move       # PokeBattle_Move object
    #---------------------------------------------------------------------------
    pbChangeMaxMove(idxBattler,idxMove)  # Changes Max Move if needed
    #---------------------------------------------------------------------------
    @choices[idxBattler][3] = -1         # No target chosen yet
    return true
  end
  
#===============================================================================
# Handles the end of round effects of certain G-Max Moves.
#===============================================================================
  def pbEORMaxMoveEffects(priority) # Added to def pbEndOfRoundPhase
    priority.each do |b|
      b.effects[PBEffects::MaxGuard] = false
    end
    for side in 0...2
      #-------------------------------------------------------------------------
      # G-Max Vine Lash
      #-------------------------------------------------------------------------
      if sides[side].effects[PBEffects::VineLash]>0
      	#@battle.pbCommonAnimation("VineLash") if side==0
      	#@battle.pbCommonAnimation("VineLashOpp") if side==1
      	priority.each do |b|
          next if b.opposes?(side)
          next if !b.takesIndirectDamage? || b.pbHasType?(:GRASS)
          oldHP = b.hp
          @scene.pbDamageAnimation(b)
          b.pbReduceHP(b.totalhp/8,false)
          pbDisplay(_INTL("{1} is hurt by G-Max Vine Lash's ferocious beating!",b.pbThis))
          b.pbItemHPHealCheck
          b.pbAbilitiesOnDamageTaken(oldHP)
          b.pbFaint if b.fainted?
        end
        pbEORCountDownSideEffect(side,PBEffects::VineLash,
          _INTL("{1} was released from G-Max Vinelash's beating!",@battlers[side].pbTeam))
      end
      #-------------------------------------------------------------------------
      # G-Max Wildfire
      #-------------------------------------------------------------------------
      if sides[side].effects[PBEffects::Wildfire]>0
      	#@battle.pbCommonAnimation("Wildfire") if side==0
      	#@battle.pbCommonAnimation("WildfireOpp") if side==1
      	priority.each do |b|
          next if b.opposes?(side)
          next if !b.takesIndirectDamage? || b.pbHasType?(:FIRE)
          oldHP = b.hp
          @scene.pbDamageAnimation(b)
          b.pbReduceHP(b.totalhp/8,false)
          pbDisplay(_INTL("{1} is burning up within G-Max Wildfire's flames!",b.pbThis))
          b.pbItemHPHealCheck
          b.pbAbilitiesOnDamageTaken(oldHP)
          b.pbFaint if b.fainted?
        end
        pbEORCountDownSideEffect(side,PBEffects::Wildfire,
          _INTL("{1} was released from G-Max Wildfire's flames!",@battlers[side].pbTeam))
      end
      #-------------------------------------------------------------------------
      # G-Max Cannonade
      #-------------------------------------------------------------------------
      if sides[side].effects[PBEffects::Cannonade]>0
      	#@battle.pbCommonAnimation("Cannonade") if side==0
      	#@battle.pbCommonAnimation("CannonadeOpp") if side==1
      	priority.each do |b|
          next if b.opposes?(side)
          next if !b.takesIndirectDamage? || b.pbHasType?(:WATER)
          oldHP = b.hp
          @scene.pbDamageAnimation(b)
          b.pbReduceHP(b.totalhp/8,false)
          pbDisplay(_INTL("{1} is hurt by G-Max Cannonade's vortex!",b.pbThis))
          b.pbItemHPHealCheck
          b.pbAbilitiesOnDamageTaken(oldHP)
          b.pbFaint if b.fainted?
        end
        pbEORCountDownSideEffect(side,PBEffects::Cannonade,
          _INTL("{1} was released from G-Max Cannonade's vortex!",@battlers[side].pbTeam))
      end
      #-------------------------------------------------------------------------
      # G-Max Volcalith
      #-------------------------------------------------------------------------
      if sides[side].effects[PBEffects::Volcalith]>0
      	#@battle.pbCommonAnimation("Volcalith") if side==0
      	#@battle.pbCommonAnimation("VolcalithOpp") if side==1
      	priority.each do |b|
          next if b.opposes?(side)
          next if !b.takesIndirectDamage? || b.pbHasType?(:ROCK)
          oldHP = b.hp
          @scene.pbDamageAnimation(b)
          b.pbReduceHP(b.totalhp/8,false)
          pbDisplay(_INTL("{1} is hurt by the rocks thrown out by G-Max Volcalith!",b.pbThis))
          b.pbItemHPHealCheck
          b.pbAbilitiesOnDamageTaken(oldHP)
          b.pbFaint if b.fainted?
        end
        pbEORCountDownSideEffect(side,PBEffects::Volcalith,
          _INTL("Rocks stopped being thrown out by G-Max Volcalith on {1}!",@battlers[side].pbTeam))
      end
    end
  end
  
#===============================================================================
# Hazard effect for G-Max Steelsurge.
#===============================================================================
  def pbSteelsurgeEffect(battler) # Added to def pbOnActiveOne
    if battler.pbOwnSide.effects[PBEffects::Steelsurge] && battler.takesIndirectDamage?
      aType = getConst(PBTypes,:STEEL) || 0
      bTypes = battler.pbTypes(true)
      eff = PBTypes.getCombinedEffectiveness(aType,bTypes[0],bTypes[1],bTypes[2])
      if !PBTypes.ineffective?(eff)
        eff = eff.to_f/PBTypeEffectiveness::NORMAL_EFFECTIVE
        oldHP = battler.hp
        battler.pbReduceHP(battler.totalhp*eff/8,false)
        pbDisplay(_INTL("The sharp steel bit into {1}!",battler.pbThis))
        battler.pbItemHPHealCheck
        if battler.pbAbilitiesOnDamageTaken(oldHP)
          return pbOnActiveOne(battler) 
        end
      end
    end
  end
end


################################################################################
# SECTION 8 - MAX MOVE EFFECTS
#===============================================================================
# Generic move classes. 
#===============================================================================
# Raise stat of all ally Pokemon.
#-------------------------------------------------------------------------------
class PokeBattle_StatUpMaxMove < PokeBattle_Move
  def pbEffectGeneral(user)
    @battle.eachBattler do |b|
      next if b.opposes?(user)
      b.pbRaiseStatStage(@statUp[0],@statUp[1],b)
    end
  end
end

#-------------------------------------------------------------------------------
# Lower stat of all opposing Pokemon.
#-------------------------------------------------------------------------------
class PokeBattle_TargetStatDownMaxMove < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    user.eachOpposing do |b|
      b.pbLowerStatStage(@statDown[0],@statDown[1],b)
    end
  end
end

#-------------------------------------------------------------------------------
# Sets up weather on use.
#-------------------------------------------------------------------------------
class PokeBattle_WeatherMaxMove < PokeBattle_Move
  def initialize(battle,move)
    super
    @weatherType = PBWeather::None
  end
  
  def pbEffectGeneral(user)
    if @battle.field.weather!=PBWeather::HarshSun &&
       @battle.field.weather!=PBWeather::HeavyRain &&
       @battle.field.weather!=PBWeather::StrongWinds &&
       @battle.field.weather!=@weatherType
      @battle.pbStartWeather(user,@weatherType,true,false)
    end
  end
end

#-------------------------------------------------------------------------------
# Sets up battle terrain on use.
#-------------------------------------------------------------------------------
class PokeBattle_TerrainMaxMove < PokeBattle_Move
  def initialize(battle,move)
    super
    @terrainType = PBBattleTerrains::None
  end

  def pbEffectGeneral(user)
    if @battle.field.terrain!=@terrainType
      @battle.pbStartTerrain(user,@terrainType)
    end
  end
end

#-------------------------------------------------------------------------------
# Applies one of multiple statuses on all opposing Pokemon.
#-------------------------------------------------------------------------------
class PokeBattle_StatusMaxMove < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    user.eachOpposing do |b|
      randstatus = @statuses[@battle.pbRandom(@statuses.length)]
      if b.pbCanInflictStatus?(randstatus,b,false)
        b.pbInflictStatus(randstatus)
      end
    end
  end
end

#-------------------------------------------------------------------------------
# Confuses all opposing Pokemon.
#-------------------------------------------------------------------------------
class PokeBattle_ConfusionMaxMove < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    user.eachOpposing do |b|
      b.pbConfuse if b.pbCanConfuse?(user,false)
    end
  end
end

#===============================================================================
# Max Guard.
#===============================================================================
# Guards the user from all attacks, including Max Moves.
#-------------------------------------------------------------------------------
class PokeBattle_Move_200 < PokeBattle_ProtectMove
  def initialize(battle,move)
    super
    @effect = PBEffects::MaxGuard
  end
end

#===============================================================================
# Max Knuckle, Max Steelspike, Max Ooze, Max Quake, Max Airstream.
#===============================================================================
# Increases a stat of all ally Pokemon.
#-------------------------------------------------------------------------------
class PokeBattle_Move_201 < PokeBattle_StatUpMaxMove
  def initialize(battle,move)
    super
    @statUp = [PBStats::ATTACK,1]  if isConst?(@id,PBMoves,:MAXKNUCKLE)
    @statUp = [PBStats::DEFENSE,1] if isConst?(@id,PBMoves,:MAXSTEELSPIKE)
    @statUp = [PBStats::SPATK,1]   if isConst?(@id,PBMoves,:MAXOOZE)
    @statUp = [PBStats::SPDEF,1]   if isConst?(@id,PBMoves,:MAXQUAKE)
    @statUp = [PBStats::SPEED,1]   if isConst?(@id,PBMoves,:MAXAIRSTREAM)
  end
end


#===============================================================================
# Max Wyrmwind, Max Phantasm, Max Flutterby, Max Darkness, Max Strike.
# G-Max Foamburst, G-Max Tartness.
#===============================================================================
# Decreases a stat of all opposing Pokemon.
#-------------------------------------------------------------------------------
class PokeBattle_Move_202 < PokeBattle_TargetStatDownMaxMove
  def initialize(battle,move)
    super
    @statDown = [PBStats::ATTACK,1]  if isConst?(@id,PBMoves,:MAXWYRMWIND)
    @statDown = [PBStats::DEFENSE,1] if isConst?(@id,PBMoves,:MAXPHANTASM)
    @statDown = [PBStats::SPATK,1]   if isConst?(@id,PBMoves,:MAXFLUTTERBY)
    @statDown = [PBStats::SPDEF,1]   if isConst?(@id,PBMoves,:MAXDARKNESS)
    @statDown = [PBStats::SPEED,1]   if isConst?(@id,PBMoves,:MAXSTRIKE)
    @statDown = [PBStats::SPEED,2]   if isConst?(@id,PBMoves,:GMAXFOAMBURST)
    @statDown = [PBStats::EVASION,1] if isConst?(@id,PBMoves,:GMAXTARTNESS)
  end
end

#===============================================================================
# Max Flare, Max Gyser, Max Hailstorm, Max Rockfall.
#===============================================================================
# Sets up weather effect on the field.
#-------------------------------------------------------------------------------
class PokeBattle_Move_203 < PokeBattle_WeatherMaxMove
  def initialize(battle,move)
    super
    @weatherType = PBWeather::Sun       if isConst?(@id,PBMoves,:MAXFLARE)
    @weatherType = PBWeather::Rain      if isConst?(@id,PBMoves,:MAXGEYSER)
    @weatherType = PBWeather::Hail      if isConst?(@id,PBMoves,:MAXHAILSTORM)
    @weatherType = PBWeather::Sandstorm if isConst?(@id,PBMoves,:MAXROCKFALL)
  end
end

#===============================================================================
# Max Overgrowth, Max Lightning, Max Starfall, Max Mindstorm.
#===============================================================================
# Sets up battle terrain on the field.
#-------------------------------------------------------------------------------
class PokeBattle_Move_204 < PokeBattle_TerrainMaxMove
  def initialize(battle,move)
    super
    @terrainType = PBBattleTerrains::Electric if isConst?(@id,PBMoves,:MAXLIGHTNING)
    @terrainType = PBBattleTerrains::Grassy   if isConst?(@id,PBMoves,:MAXOVERGROWTH)
    @terrainType = PBBattleTerrains::Misty    if isConst?(@id,PBMoves,:MAXSTARFALL)
    @terrainType = PBBattleTerrains::Psychic  if isConst?(@id,PBMoves,:MAXMINDSTORM)
  end
end

#===============================================================================
# G-Max Vine Lash, G-Max Wildfire, G-Max Cannonade, G-Max Volcalith.
#===============================================================================
# Damages all Pokemon on the opposing field for 4 turns.
#-------------------------------------------------------------------------------
class PokeBattle_Move_205 < PokeBattle_Move
  def pbEffectGeneral(user)
    if isConst?(@id,PBMoves,:GMAXVINELASH) &&
       user.pbOpposingSide.effects[PBEffects::VineLash]==0
      user.pbOpposingSide.effects[PBEffects::VineLash]=4
      @battle.pbDisplay(_INTL("{1} got trapped with vines!",user.pbOpposingTeam))
    end
    if isConst?(@id,PBMoves,:GMAXWILDFIRE) &&
       user.pbOpposingSide.effects[PBEffects::Wildfire]==0
      user.pbOpposingSide.effects[PBEffects::Wildfire]=4
      @battle.pbDisplay(_INTL("{1} were surrounded by fire!",user.pbOpposingTeam))
    end
    if isConst?(@id,PBMoves,:GMAXCANNONADE) &&
       user.pbOpposingSide.effects[PBEffects::Cannonade]==0
      user.pbOpposingSide.effects[PBEffects::Cannonade]=4
      @battle.pbDisplay(_INTL("{1} got caught in a vortex of water!",user.pbOpposingTeam))
    end
    if isConst?(@id,PBMoves,:GMAXVOLCALITH) &&
       user.pbOpposingSide.effects[PBEffects::Volcalith]==0
      user.pbOpposingSide.effects[PBEffects::Volcalith]=4
      @battle.pbDisplay(_INTL("{1} became surrounded by rocks!",user.pbOpposingTeam))
    end
  end
end

#===============================================================================
# G-Max Drum Solo, G-Max Fireball, G-Max Hydrosnipe.
#===============================================================================
# Bypasses target's abilities that would reduce or ignore damage.
#-------------------------------------------------------------------------------
class PokeBattle_Move_206 < PokeBattle_Move
  def pbIgnoreAbilities?; return true; end
end

#===============================================================================
# G-Max Malador, G-Max Volt Crash, G-Max Stun Shock, G-Max Befuddle.
#===============================================================================
# Applies status effects on all opposing Pokemon.
#-------------------------------------------------------------------------------
class PokeBattle_Move_207 < PokeBattle_StatusMaxMove
  def initialize(battle,move)
    super
    if isConst?(@id,PBMoves,:GMAXMALODOR)
      @statuses = [PBStatuses::POISON]
    end
    if isConst?(@id,PBMoves,:GMAXVOLTCRASH)
      @statuses = [PBStatuses::PARALYSIS]
    end
    if isConst?(@id,PBMoves,:GMAXSTUNSHOCK)
      @statuses = [PBStatuses::POISON,PBStatuses::PARALYSIS]
    end
    if isConst?(@id,PBMoves,:GMAXBEFUDDLE)
      @statuses = [PBStatuses::POISON,PBStatuses::PARALYSIS,PBStatuses::SLEEP]
    end
  end
end

#===============================================================================
# G-Max Smite, G-Max Gold Rush.
#===============================================================================
# Confuses all opposing Pokemon.
#-------------------------------------------------------------------------------
class PokeBattle_Move_208 < PokeBattle_ConfusionMaxMove
  def pbEffectGeneral(user)
    if isConst?(@id,PBMoves,:GMAXGOLDRUSH) && user.pbOwnedByPlayer?
      @battle.field.effects[PBEffects::PayDay] += 100*user.level
      @battle.pbDisplay(_INTL("Coins were scattered everywhere!"))
    end
  end
end

#===============================================================================
# G-Max Stonesurge, G-Max Steelsurge.
#===============================================================================
# Sets up entry hazard on the opposing side's field.
#-------------------------------------------------------------------------------
class PokeBattle_Move_209 < PokeBattle_Move
  def pbEffectGeneral(user)
    if isConst?(@id,PBMoves,:GMAXSTONESURGE) &&
       !user.pbOpposingSide.effects[PBEffects::StealthRock]
      user.pbOpposingSide.effects[PBEffects::StealthRock] = true
      @battle.pbDisplay(_INTL("Pointed stones float in the air around {1}!",
         user.pbOpposingTeam(true)))
    end
    if isConst?(@id,PBMoves,:GMAXSTEELSURGE) &&
       !user.pbOpposingSide.effects[PBEffects::Steelsurge]
      user.pbOpposingSide.effects[PBEffects::Steelsurge] = true
      @battle.pbDisplay(_INTL("Sharp-pointed pieces of steel started floating around {1}!",
         user.pbOpposingTeam(true)))
    end   
  end
end

#===============================================================================
# G-Max Centiferno, G-Max Sand Blast.
#===============================================================================
# Traps all opposing Pokemon in a vortex for multiple turns.
#-------------------------------------------------------------------------------
class PokeBattle_Move_20A < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    moveid = getID(PBMoves,:FIRESPIN) if isConst?(@id,PBMoves,:GMAXCENTIFERNO)
    moveid = getID(PBMoves,:SANDTOMB) if isConst?(@id,PBMoves,:GMAXSANDBLAST)
    user.eachOpposing do |b|    
      next if b.damageState.substitute
      next if b.effects[PBEffects::Trapping]>0
      if user.hasActiveItem?(:GRIPCLAW)
        b.effects[PBEffects::Trapping] = (NEWEST_BATTLE_MECHANICS) ? 8 : 6
      else
        b.effects[PBEffects::Trapping] = 5+@battle.pbRandom(2)
      end
      b.effects[PBEffects::TrappingMove] = moveid
      b.effects[PBEffects::TrappingUser] = user.index
      msg = _INTL("{1} was trapped in the vortex!",b.pbThis)
      if isConst?(@id,PBMoves,:GMAXCENTIFERNO)
        msg = _INTL("{1} was trapped in the fiery vortex!",b.pbThis)
      elsif isConst?(@id,PBMoves,:GMAXSANDBLAST)
        msg = _INTL("{1} became trapped by Sand Tomb!",b.pbThis)
      end
      @battle.pbDisplay(msg)
    end
  end
end

#===============================================================================
# G-Max Wind Rage.
#===============================================================================
# Blows away effects hazards and opponent side's effects.
#-------------------------------------------------------------------------------
class PokeBattle_Move_20B < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    @battle.field.terrain = PBBattleTerrains::None
    target.pbOwnSide.effects[PBEffects::AuroraVeil]    = 0
    target.pbOwnSide.effects[PBEffects::LightScreen]   = 0
    target.pbOwnSide.effects[PBEffects::Reflect]       = 0
    target.pbOwnSide.effects[PBEffects::Mist]          = 0
    target.pbOwnSide.effects[PBEffects::Safeguard]     = 0
    target.pbOwnSide.effects[PBEffects::Spikes]        = 0
    target.pbOwnSide.effects[PBEffects::ToxicSpikes]   = 0
    target.pbOwnSide.effects[PBEffects::StickyWeb]     = false
    target.pbOwnSide.effects[PBEffects::StealthRock]   = false
    target.pbOwnSide.effects[PBEffects::Steelsurge]    = false
    user.pbOwnSide.effects[PBEffects::Spikes]          = 0
    user.pbOwnSide.effects[PBEffects::ToxicSpikes]     = 0
    user.pbOwnSide.effects[PBEffects::StickyWeb]       = false
    user.pbOwnSide.effects[PBEffects::StealthRock]     = false
    user.pbOwnSide.effects[PBEffects::Steelsurge]      = false
  end
end

#===============================================================================
# G-Max Gravitas.
#===============================================================================
# Increases gravity on the field for 5 rounds.
#-------------------------------------------------------------------------------
class PokeBattle_Move_20C < PokeBattle_Move
  def pbEffectGeneral(user)
    if @battle.field.effects[PBEffects::Gravity]==0
      @battle.field.effects[PBEffects::Gravity] = 5
      @battle.pbDisplay(_INTL("Gravity intensified!"))
      @battle.eachBattler do |b|
        showMessage = false
        if b.inTwoTurnAttack?("0C9","0CC","0CE")
          b.effects[PBEffects::TwoTurnAttack] = 0
          @battle.pbClearChoice(b.index) if !b.movedThisRound?
          showMessage = true
        end
        if b.effects[PBEffects::MagnetRise]>0 ||
           b.effects[PBEffects::Telekinesis]>0 ||
           b.effects[PBEffects::SkyDrop]>=0
          b.effects[PBEffects::MagnetRise]  = 0
          b.effects[PBEffects::Telekinesis] = 0
          b.effects[PBEffects::SkyDrop]     = -1
          showMessage = true
        end
        @battle.pbDisplay(_INTL("{1} couldn't stay airborne because of gravity!",
           b.pbThis)) if showMessage
      end
    end
  end
end

#===============================================================================
# G-Max Finale.
#===============================================================================
# Heals all ally Pokemon by 1/6th their max HP.
#-------------------------------------------------------------------------------
class PokeBattle_Move_20D < PokeBattle_Move
  def healingMove?; return true; end

  def pbEffectGeneral(user)
    @battle.eachBattler do |b|
      next if b.opposes?(user)
      next if b.hp == b.totalhp
      next if b.effects[PBEffects::HealBlock]>0
      hpGain = (b.totalhp/6.0).round
      b.pbRecoverHP(hpGain)
    end
  end
end

#===============================================================================
# G-Max Sweetness.
#===============================================================================
# Cures any status conditions of all ally Pokemon.
#-------------------------------------------------------------------------------
class PokeBattle_Move_20E < PokeBattle_Move
  def pbEffectGeneral(user)
    @battle.eachBattler do |b|
      next if b.opposes?(user)
      t = b.status
      b.pbCureStatus(false)
      case t
      when PBStatuses::BURN
        @battle.pbDisplay(_INTL("{1} was healed of its burn!",b.pbThis))  
      when PBStatuses::POISON
        @battle.pbDisplay(_INTL("{1} was cured of its poison!",b.pbThis))  
      when PBStatuses::PARALYSIS
        @battle.pbDisplay(_INTL("{1} was cured of its paralysis!",b.pbThis))
      when PBStatuses::SLEEP
        @battle.pbDisplay(_INTL("{1} woke up!",b.pbThis)) 
      when PBStatuses::FROZEN
        @battle.pbDisplay(_INTL("{1} thawed out!",b.pbThis)) 
      end
    end
  end
end

#===============================================================================
# G-Max Replenish.
#===============================================================================
# User has a 50% chance to recover its last consumed item.
#-------------------------------------------------------------------------------
class PokeBattle_Move_20F < PokeBattle_Move
  def pbEffectGeneral(user)
    if @battle.pbRandom(10)<5
      item = user.recycleItem
      user.item = item
      user.setInitialItem(item) if @battle.wildBattle? && user.initialItem==0
      user.setRecycleItem(0)
      user.effects[PBEffects::PickupItem] = 0
      user.effects[PBEffects::PickupUse]  = 0
      itemName = PBItems.getName(item)
      if itemName.starts_with_vowel?
        @battle.pbDisplay(_INTL("{1} found an {2}!",user.pbThis,itemName))
      else
        @battle.pbDisplay(_INTL("{1} found a {2}!",user.pbThis,itemName))
      end
      user.pbHeldItemTriggerCheck
    end
  end
end

#===============================================================================
# G-Max Depletion.
#===============================================================================
# The target's last used move loses 2 PP.
#-------------------------------------------------------------------------------
class PokeBattle_Move_210 < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    target.eachMove do |m|
      next if m.id!=target.lastRegularMoveUsed
      reduction = [2,m.pp].min
      target.pbSetPP(m,m.pp-reduction)
      break
    end
  end
end

#===============================================================================
# G-Max Resonance.
#===============================================================================
# Sets up Aurora Veil for the party for 5 turns.
#-------------------------------------------------------------------------------
class PokeBattle_Move_211 < PokeBattle_Move
  def pbEffectGeneral(user)
    user.pbOwnSide.effects[PBEffects::AuroraVeil] = 5
    user.pbOwnSide.effects[PBEffects::AuroraVeil] = 8 if user.hasActiveItem?(:LIGHTCLAY)
    @battle.pbDisplay(_INTL("{1} made {2} stronger against physical and special moves!",
       @name,user.pbTeam(true)))
  end
end

#===============================================================================
# G-Max Chi Strike.
#===============================================================================
# Increases the critical hit rate of all ally Pokemon.
#-------------------------------------------------------------------------------
class PokeBattle_Move_212 < PokeBattle_Move
  def pbEffectGeneral(user)
    @battle.eachBattler do |b|
      next if b.opposes?(user)
      next if b.effects[PBEffects::FocusEnergy] > 2
      b.effects[PBEffects::FocusEnergy] = 2
      @battle.pbDisplay(_INTL("{1} is getting pumped!",b.pbThis))
    end
  end
end

#===============================================================================
# G-Max Terror.
#===============================================================================
# Prevents all opposing Pokemon from switching.
#-------------------------------------------------------------------------------
class PokeBattle_Move_213 < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    user.eachOpposing do |b|
      b.effects[PBEffects::MeanLook] = user.index
    end
  end
end

#===============================================================================
# G-Max Snooze.
#===============================================================================
# Has a 50% chance of making the target drowsy.
#-------------------------------------------------------------------------------
class PokeBattle_Move_214 < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    if target.effects[PBEffects::Yawn]==0 && @battle.pbRandom(10)<5
      target.effects[PBEffects::Yawn] = 2
      @battle.pbDisplay(_INTL("{1} made {2} drowsy!",user.pbThis,target.pbThis(true)))
    end
  end
end

#===============================================================================
# G-Max Cuddle.
#===============================================================================
# Infatuates all opposing Pokemon.
#-------------------------------------------------------------------------------
class PokeBattle_Move_215 < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    user.eachOpposing do |b|
      b.pbAttract(user) if b.pbCanAttract?(user)
    end
  end
end

#===============================================================================
# G-Max Meltdown.
#===============================================================================
# Torments all opposing Pokemon.
#-------------------------------------------------------------------------------
class PokeBattle_Move_216 < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    user.eachOpposing do |b|
      b.effects[PBEffects::Torment] = true
      b.pbItemStatusCureCheck
    end
  end
end

#===============================================================================
# G-Max One Blow, G-Max Rapid Flow.
#===============================================================================
# Ignores the effects of the opponent's protect moves, including Max Guard.
#-------------------------------------------------------------------------------
# These moves use function code 000. Effects are handled elsewhere.
#-------------------------------------------------------------------------------
