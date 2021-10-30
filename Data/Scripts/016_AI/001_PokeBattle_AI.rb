# AI skill levels:
#     0:     Wild Pokémon
#     1-31:  Basic trainer (young/inexperienced)
#     32-47: Some skill
#     48-99: High skill
#     100+:  Best trainers (Gym Leaders, Elite Four, Champion)
# NOTE: A trainer's skill value can range from 0-255, but by default only four
#       distinct skill levels exist. The skill value is typically the same as
#       the trainer's base money value.
module PBTrainerAI
  # Minimum skill level to be in each AI category.
  def self.minimumSkill; return 1;   end
  def self.mediumSkill;  return 32;  end
  def self.highSkill;    return 48;  end
  def self.bestSkill;    return 100; end
end



class PokeBattle_AI
  def initialize(battle)
    @battle = battle
  end

  def pbAIRandom(x); return rand(x); end

  def pbStdDev(choices)
    sum = 0
    n   = 0
    choices.each do |c|
      sum += c[1]
      n   += 1
    end
    return 0 if n<2
    mean = sum.to_f/n.to_f
    varianceTimesN = 0
    choices.each do |c|
      next if c[1]<=0
      deviation = c[1].to_f-mean
      varianceTimesN += deviation*deviation
    end
    # Using population standard deviation
    # [(n-1) makes it a sample std dev, would be 0 with only 1 sample]
    return Math.sqrt(varianceTimesN/n)
  end

  #=============================================================================
  # Decide whether the opponent should Mega Evolve their Pokémon
  #=============================================================================
  def pbEnemyShouldMegaEvolve?(idxBattler)
    battler = @battle.battlers[idxBattler]
    if @battle.pbCanMegaEvolve?(idxBattler)   # Simple "always should if possible"
      PBDebug.log("[AI] #{battler.pbThis} (#{idxBattler}) will Mega Evolve")
      return true
    end
    return false
  end

  #=============================================================================
  # Decide whether the opponent should use a Z-Move.
  #=============================================================================
  def pbEnemyShouldZMove?(index)
    # If all opposing have less than half HP, then don't Z-Move.
    return false if !@battle.pbCanZMove?(index) #Conditions based on effectiveness and type handled later  
    
    @battle.battlers[index].eachOpposing { |opp|
      return true if opp.hp>(opp.totalhp/2).round
    }
    return false 
  end    
  
  def pbChooseEnemyZMove(index)  #Put specific cases for trainers using status Z-Moves
    # Choose the move.
    chosenmove=false
    chosenindex=-1
    attacker = @battle.battlers[index]
    for i in 0..3
      move=attacker.moves[i]
      if attacker.pbCompatibleZMoveFromMove?(move)
        if !chosenmove
          chosenindex = i
          chosenmove=move
        else
          if move.baseDamage>chosenmove.baseDamage
            chosenindex=i
            chosenmove=move
          end          
        end
      end
    end   
    target_i = nil
    target_eff = 0 
    # Choose the target
    attacker.eachOpposing { |opp|
      temp_eff = chosenmove.pbCalcTypeMod(chosenmove.type,attacker,opp)        
      if temp_eff > target_eff
        target_i = opp.index
        target_eff = target_eff
      end 
    }
    @battle.pbRegisterZMove(index)
    @battle.pbRegisterMove(index,chosenindex,false)
    @battle.pbRegisterTarget(index,target_i)
  end
  
  #=============================================================================
  # Choose an action
  #=============================================================================
  def pbDefaultChooseEnemyCommand(idxBattler)
    return if pbEnemyShouldUseItem?(idxBattler)
    return if pbEnemyShouldWithdraw?(idxBattler)
    return if @battle.pbAutoFightMenu(idxBattler)
    @battle.pbRegisterMegaEvolution(idxBattler) if pbEnemyShouldMegaEvolve?(idxBattler)
    if pbEnemyShouldZMove?(idxBattler)
      pbChooseEnemyZMove(idxBattler)
      return 
    end
    pbChooseMoves(idxBattler)
  end
end
