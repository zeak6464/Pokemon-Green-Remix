################################################################################
# Specific effects of Z-Moves
################################################################################


class PokeBattle_Move_Z000 < PokeBattle_ZMove
end



#===============================================================================
# Inflicts paralysis. (Stoked Sparksurfer)
#===============================================================================
class PokeBattle_Move_Z001 < PokeBattle_ZMove
  def initialize(battle,move,pbmove)
    super
  end

  def pbFailsAgainstTarget?(user,target)
    return false if damagingMove?
    return !target.pbCanParalyze?(user,true,self)
  end

  def pbEffectAgainstTarget(user,target)
    return if damagingMove?
    target.pbParalyze(user)
  end

  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    target.pbParalyze(user) if target.pbCanParalyze?(user,false,self)
  end
end 




#===============================================================================
# Doubles damage on minimized Pokémons. (Malicious Moonsault)
#===============================================================================
class PokeBattle_Move_Z002 < PokeBattle_ZMove
  def tramplesMinimize?(param=1)
    # Perfect accuracy and double damage if minimized
    return NEWEST_BATTLE_MECHANICS
  end
end




#===============================================================================
# Base class of Z-Moves that increase all stats. 
#===============================================================================
class PokeBattle_ZMove_AllStatsUp < PokeBattle_ZMove
  def initialize(battle,move,pbmove)
    super
    @statUp = []
  end
  
  def pbMoveFailed?(user,targets)
    return false if damagingMove?
    failed = true
    for i in 0...@statUp.length/2
      next if !user.pbCanRaiseStatStage?(@statUp[i*2],user,self)
      failed = false
      break
    end
    if failed
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",user.pbThis))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    return if damagingMove?
    showAnim = true
    for i in 0...@statUp.length/2
      next if !user.pbCanRaiseStatStage?(@statUp[i*2],user,self)
      if user.pbRaiseStatStage(@statUp[i*2],@statUp[i*2+1],user,showAnim)
        showAnim = false
      end
    end
  end

  def pbAdditionalEffect(user,target)
    showAnim = true
    for i in 0...@statUp.length/2
      next if !user.pbCanRaiseStatStage?(@statUp[i*2],user,self)
      if user.pbRaiseStatStage(@statUp[i*2],@statUp[i*2+1],user,showAnim)
        showAnim = false
      end
    end
  end
end 


#===============================================================================
# Raises all stats by 2 stages. (Extreme Evoboost)
#===============================================================================

class PokeBattle_Move_Z003 < PokeBattle_ZMove_AllStatsUp
  def initialize(battle,move,pbmove)
    super
    @statUp = [PBStats::ATTACK,2,PBStats::DEFENSE,2,
               PBStats::SPATK,2,PBStats::SPDEF,2,
               PBStats::SPEED,2]
  end
end 




#===============================================================================
# Sets Psychic Terrain. (Genesis Supernova)
#===============================================================================
class PokeBattle_Move_Z004 < PokeBattle_ZMove
  def pbAdditionalEffect(user,target)
    @battle.pbStartTerrain(user,PBBattleTerrains::Electric)
  end
end 



#===============================================================================
# Inflicts 75% of the target's current HP. (Guardian of Alola)
#===============================================================================
class PokeBattle_Move_Z005 < PokeBattle_ZMove
  def pbFixedDamage(user,target)
    return (target.hp*0.75).round
  end
  
  def pbCalcDamage(user,target,numTargets=1)
    target.damageState.critical   = false
    target.damageState.calcDamage = pbFixedDamage(user,target)
    target.damageState.calcDamage = 1 if target.damageState.calcDamage<1
  end
end



#===============================================================================
# Boosts all stats. (Clangorous Soulblaze)
#===============================================================================
class PokeBattle_Move_Z006 < PokeBattle_ZMove_AllStatsUp
  def initialize(battle,move,pbmove)
    super
    @statUp = [PBStats::ATTACK,1,PBStats::DEFENSE,1,
               PBStats::SPATK,1,PBStats::SPDEF,1,
               PBStats::SPEED,1]
  end
end 



#===============================================================================
# Ignores ability. (Menacing Moonraze Maelstrom, Searing Sunraze Smash)
#===============================================================================
class PokeBattle_Move_Z007 < PokeBattle_ZMove
  def pbChangeUsageCounters(user,specialUsage)
    super
    @battle.moldBreaker = true if !specialUsage
  end
end 



#===============================================================================
# Removes terrains. (Splintered Stormshards)
#===============================================================================
class PokeBattle_Move_Z008 < PokeBattle_ZMove
  def pbAdditionalEffect(user,target)
    case @battle.field.terrain
    when PBBattleTerrains::Electric
      @battle.pbDisplay(_INTL("The electric current disappeared from the battlefield!"))
    when PBBattleTerrains::Grassy
      @battle.pbDisplay(_INTL("The grass disappeared from the battlefield!"))
    when PBBattleTerrains::Misty
      @battle.pbDisplay(_INTL("The mist disappeared from the battlefield!"))
    when PBBattleTerrains::Psychic
      @battle.pbDisplay(_INTL("The weirdness disappeared from the battlefield!"))
    end
    @battle.pbStartTerrain(user,PBBattleTerrains::None,true)
  end
end 



#===============================================================================
# Ignores ability + is physical or special depending on what's best. 
# (Light That Burns the Sky)
#===============================================================================
class PokeBattle_Move_Z009 < PokeBattle_Move_Z007
  def initialize(battle,move,pbmove)
    super
    @calcCategory = 1
  end

  def physicalMove?(thisType=nil); return (@calcCategory==0); end
  def specialMove?(thisType=nil);  return (@calcCategory==1); end

  def pbOnStartUse(user,targets)
    # Calculate user's effective attacking value
    stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
    stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
    atk        = user.attack
    atkStage   = user.stages[PBStats::ATTACK]+6
    realAtk    = (atk.to_f*stageMul[atkStage]/stageDiv[atkStage]).floor
    spAtk      = user.spatk
    spAtkStage = user.stages[PBStats::SPATK]+6
    realSpAtk  = (spAtk.to_f*stageMul[spAtkStage]/stageDiv[spAtkStage]).floor
    # Determine move's category
    @calcCategory = (realAtk>realSpAtk) ? 0 : 1
  end
end 

