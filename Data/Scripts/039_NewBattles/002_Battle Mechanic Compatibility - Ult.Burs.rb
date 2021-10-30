#===============================================================================
#
#  Battle Mechanic Compatibility - By Lucidious89
#  For -Pokémon Essentials v18.1-
#
#===============================================================================
# This is a compatibility script that allows for functionality between the 
# following battle mechanics:
#   -Mega Evolution
#   -Primal Reversion
#   -Ultra Burst (Ultra Necrozma)
#   -Z-Moves
#   -Dynamax
#   -Zodiac Powers (Birthsigns)
#
# This script doesn't add any of the above mechanics, it simply allows for 
# compatibility if one or more of those scripts are installed. The Dynamax
# and Zodiac Powers scripts in particular *require* this script to be installed,
# even if no other game mechanics are being installed along side them.
#
#===============================================================================
#  ~Installation~
#===============================================================================
# To install, create a new section directly above Main, and paste this script
# there. This script must be below any scripts handling Mega Evolution, Primals,
# Z-Moves, Dynamax, Zodiac Powers, or battle mechanics in general.
#
#===============================================================================

################################################################################
# SECTION 1 - COMPATIBILITY CHECKS
#===============================================================================
# Checks if a particular script is installed.
#===============================================================================
def pbZMovesInstalled?  # Checks for Z-Move Script
  return true if defined?(NO_Z_MOVE)
  return false
end

def pbDynamaxInstalled? # Checks for Dynamax Script
  return true if defined?(NO_DYNAMAX)
  return false
end

def pbZodiacInstalled?  # Checks for Zodiac Powers Script
  return true if defined?(NO_ZODIAC)
  return false
end

#===============================================================================
# Compatibility checks for certain Pokemon properties.
#===============================================================================
class PokeBattle_Pokemon
  def compatUltra?      # Checks if Ultra Bursted
    if defined?(ultra?); return ultra?; end
    return false
  end
    
  def compatGmax?       # Checks if Gigantamaxed
    if defined?(gmax?); return gmax?; end
    return false
  end

  def compatDmax?       # Checks if Dynamaxed
    if defined?(dynamax?); return dynamax?; end
    return false
  end
  
  def compatSigns?      # Checks if Celestial
    if defined?(celestial?); return celestial?; end
    return false
  end
end
  
#===============================================================================
# Compatibility checks for mechanic eligibility.
#===============================================================================
class PokeBattle_Battle
  def pbCanZMoveCompat?(idxBattler)     # Checks if Z-Move usable.
    return false if !pbZMovesInstalled?
    return pbCanZMove?(idxBattler)
  end

  def pbCanUltraCompat?(idxBattler)     # Checks if Ultra Burst usable.
    return false if !pbZMovesInstalled?
    return pbCanUltraBurst?(idxBattler)
  end
  
  def pbCanDynamaxCompat?(idxBattler)   # Checks if Dynamax usable.
    return false if !pbDynamaxInstalled?
    return pbCanDynamax?(idxBattler)
  end
  
  def pbCanZodiacCompat?(idxBattler)    # Checks if Zodiac Power usable.
    return false if !pbZodiacInstalled?
    return pbCanUseZodiacPower?(idxBattler)
  end
end

#===============================================================================
# Compatibility for mechanics that affect Pokemon sprites.
#===============================================================================
def pbMakeEnlarged?
  if defined?(ENLARGE_SPRITE); return ENLARGE_SPRITE; end
  return false
end

def pbAddDynamaxColor?
  if defined?(DYNAMAX_COLOR); return DYNAMAX_COLOR; end
  return false
end

def pbAddCelestialHues?
  if defined?(CELESTIAL_HUES); return CELESTIAL_HUES; end
  return false
end


################################################################################
# SECTION 2 - BATTLE ACTIONS
#===============================================================================
# Determines battle actions taken by NPC trainers.
#===============================================================================
class PokeBattle_AI
  def pbDefaultChooseEnemyCommand(idxBattler)
    return if pbEnemyShouldUseItem?(idxBattler)
    return if pbEnemyShouldWithdraw?(idxBattler)
    return if @battle.pbAutoFightMenu(idxBattler)
    @battle.pbRegisterMegaEvolution(idxBattler) if pbEnemyShouldMegaEvolve?(idxBattler)
    #---------------------------------------------------------------------------
    # Z-Moves/Ultra Burst
    #---------------------------------------------------------------------------
    if pbZMovesInstalled?
      @battle.pbRegisterUltraBurst(idxBattler) if pbEnemyShouldUltraBurst?(idxBattler)
      pbChooseEnemyZMove(idxBattler) if pbEnemyShouldZMove?(idxBattler)
    end
    #---------------------------------------------------------------------------
    # Dynamax
    #---------------------------------------------------------------------------
    if pbDynamaxInstalled?
      @battle.pbRegisterDynamax(idxBattler) if pbEnemyShouldDynamax?(idxBattler)
    end
    #---------------------------------------------------------------------------
    # Zodiac Powers
    #---------------------------------------------------------------------------
    if pbZodiacInstalled?
      @battle.pbRegisterZodiacPower(idxBattler) if pbEnemyShouldUseZodiac?(idxBattler)
    end
    #---------------------------------------------------------------------------
    pbChooseMoves(idxBattler)
  end
end

#===============================================================================
# Determines actions that should be taken upon fainting.
#===============================================================================
class PokeBattle_Battler
  def pbFaint(showMessage=true)
    #---------------------------------------------------------------------------
    # Initiated capture sequence on Raid Boss when KO'd.
    #---------------------------------------------------------------------------
    if pbDynamaxInstalled? && @effects[PBEffects::MaxRaidBoss] && $game_switches[MAXRAID_SWITCH]
      self.hp += 1
      pbCatchRaidPokemon(self)
    #---------------------------------------------------------------------------
    else
      if !fainted?
        PBDebug.log("!!!***Can't faint with HP greater than 0")
        return
      end
      return if @fainted
      @battle.pbDisplayBrief(_INTL("{1} fainted!",pbThis)) if showMessage
      PBDebug.log("[Pokémon fainted] #{pbThis} (#{@index})") if !showMessage
      @battle.scene.pbFaintBattler(self)
      pbInitEffects(false)
      self.status      = PBStatuses::NONE
      self.statusCount = 0
      if @pokemon && @battle.internalBattle
        badLoss = false
        @battle.eachOtherSideBattler(@index) do |b|
          badLoss = true if b.level>=self.level+30
        end
        @pokemon.changeHappiness((badLoss) ? "faintbad" : "faint")
      end
      @battle.peer.pbOnLeavingBattle(@battle,@pokemon,@battle.usedInBattle[idxOwnSide][@index/2])
      @pokemon.makeUnmega if mega?
      @pokemon.makeUnprimal if primal?
      #-------------------------------------------------------------------------
      @pokemon.makeUnUltra if ultra? if pbZMovesInstalled?  # Reverts Ultra Burst upon fainting.
      @pokemon.unmax if dynamax?     if pbDynamaxInstalled? # Reverts Dynamax upon fainting.
      #-------------------------------------------------------------------------
      @battle.pbClearChoice(@index)
      pbOwnSide.effects[PBEffects::LastRoundFainted] = @battle.turnCount
      pbAbilitiesOnFainting
      #-------------------------------------------------------------------------
      # Reduces the KO counter in Max Raid battles if your Pokemon are KO'd.
      #-------------------------------------------------------------------------
      if pbDynamaxInstalled?
        pbRaidKOCounter(self.pbDirectOpposing) if $game_switches[MAXRAID_SWITCH]
      end
      #-------------------------------------------------------------------------
      @battle.pbEndPrimordialWeather
    end
  end
end

#===============================================================================
# Determines actions that should be taken upon throwing a Poke Ball.
#===============================================================================
module PokeBattle_BattleCommon
  def pbThrowPokeBall(idxBattler,ball,rareness=nil,showPlayer=false)
    battler = nil
    if opposes?(idxBattler)
      battler = @battlers[idxBattler]
    else
      battler = @battlers[idxBattler].pbDirectOpposing(true)
    end
    if battler.fainted?
      battler.eachAlly do |b|
        battler = b
        break
      end
    end
    itemName = PBItems.getName(ball)
    if battler.fainted?
      if itemName.starts_with_vowel?
        pbDisplay(_INTL("{1} threw an {2}!",pbPlayer.name,itemName))
      else
        pbDisplay(_INTL("{1} threw a {2}!",pbPlayer.name,itemName))
      end
      pbDisplay(_INTL("But there was no target..."))
      return
    end
    if itemName.starts_with_vowel?
      pbDisplayBrief(_INTL("{1} threw an {2}!",pbPlayer.name,itemName))
    else
      pbDisplayBrief(_INTL("{1} threw a {2}!",pbPlayer.name,itemName))
    end
    if @opponent && $game_switches[300]==false
      @scene.pbThrowAndDeflect(ball,1)
      pbDisplay(_INTL("Don't Try to steal my pokemon?!"))
    elsif $game_switches[300]==true || pbIsPokeBall?(ball) 
      pokemon=battler.pokemon
      species=pokemon.species
    end
    #---------------------------------------------------------------------------
    # Dynamax - Prevents capture of a Max Raid Pokemon until defeated.
    #---------------------------------------------------------------------------
    if pbDynamaxInstalled?
      if !($DEBUG && Input.press?(Input::CTRL))
        if $game_switches[MAXRAID_SWITCH] && battler.hp>1 &&
           battler.effects[PBEffects::MaxRaidBoss]
          @scene.pbThrowAndDeflect(ball,1)
          pbDisplay(_INTL("The ball was repelled by a burst of Dynamax energy!"))
          return
        end
      end
    end
    #---------------------------------------------------------------------------
    # Celestial Boss - Prevents capture of Celestial Pokemon until defeated.
    #---------------------------------------------------------------------------
    if pbZodiacInstalled?
      if !($DEBUG && Input.press?(Input::CTRL))
        if $game_switches[BOSS_SWITCH] && battler.hp>1 && battler.pokemon.celestial?
          @scene.pbThrowAndDeflect(ball,1)
          pbDisplay(_INTL("The ball was repelled by a burst of celestial energy!"))
          return
        end
      end
    end
    #---------------------------------------------------------------------------
    pkmn = battler.pokemon
    @criticalCapture = false
    numShakes = pbCaptureCalc(pkmn,battler,rareness,ball)
    PBDebug.log("[Threw Poké Ball] #{itemName}, #{numShakes} shakes (4=capture)")
    @scene.pbThrow(ball,numShakes,@criticalCapture,battler.index,showPlayer)
    case numShakes
    when 0
      pbDisplay(_INTL("Oh no! The Pokémon broke free!"))
      BallHandlers.onFailCatch(ball,self,battler)
    when 1
      pbDisplay(_INTL("Aww! It appeared to be caught!"))
      BallHandlers.onFailCatch(ball,self,battler)
    when 2
      pbDisplay(_INTL("Aargh! Almost had it!"))
      BallHandlers.onFailCatch(ball,self,battler)
    when 3
      pbDisplay(_INTL("Gah! It was so close, too!"))
      BallHandlers.onFailCatch(ball,self,battler)
    when 4
      pbDisplayBrief(_INTL("Gotcha! {1} was caught!",pkmn.name))
      @scene.pbThrowSuccess
      pbRemoveFromParty(battler.index,battler.pokemonIndex)
      if GAIN_EXP_FOR_CAPTURE
        battler.captured = true
        pbGainExp
        battler.captured = false
      end
      battler.pbReset
      if trainerBattle?
        @decision = 1 if pbAllFainted?(battler.index)
      else
        @decision = 4 if pbAllFainted?(battler.index)
      end
      if pbIsSnagBall?(ball)
        pkmn.ot        = pbPlayer.name
        pkmn.trainerID = pbPlayer.id
      end
      BallHandlers.onCatch(ball,self,pkmn)
      pkmn.ballused = pbGetBallType(ball)
      pkmn.makeUnmega if pkmn.mega?
      pkmn.makeUnprimal
      #-------------------------------------------------------------------------
      pkmn.makeUnUltra         if pbZMovesInstalled?  # Reverts Ultra Burst
      pbResetRaidPokemon(pkmn) if pbDynamaxInstalled? # Reverts Max Raid Boss
      #-------------------------------------------------------------------------
      pkmn.pbUpdateShadowMoves if pkmn.shadowPokemon?
      pkmn.pbRecordFirstMoves
      pkmn.forcedForm = nil if MultipleForms.hasFunction?(pkmn.species,"getForm")
      @peer.pbOnLeavingBattle(self,pkmn,true,true)
      @scene.pbHideCaptureBall(idxBattler)
      @caughtPokemon.push(pkmn)
    end
  end
end


################################################################################
# SECTION 3 - BATTLE PHASES
#===============================================================================
# Handles battle mechanics during the command phase.
#===============================================================================
class PokeBattle_Battle
  def pbCancelChoice(idxBattler)
    if @choices[idxBattler][0]==:UseItem
      item = @choices[idxBattler][1]
      pbReturnUnusedItemToBag(item,idxBattler) if item && item>0
    end
    pbUnregisterMegaEvolution(idxBattler)
    #---------------------------------------------------------------------------
    pbUnregisterZMove(idxBattler)       if pbZMovesInstalled?
    pbUnregisterUltraBurst(idxBattler)  if pbZMovesInstalled?
    pbUnregisterZodiacPower(idxBattler) if pbZodiacInstalled?
    if pbDynamaxInstalled? && pbRegisteredDynamax?(idxBattler)
      pbUnregisterDynamax(idxBattler)     
      @battlers[idxBattler].pbUnMaxMove
    end
    #---------------------------------------------------------------------------
    pbClearChoice(idxBattler)
  end
  
  def pbCanUseBattleMechanic?(idxBattler)
    if pbCanMegaEvolve?(idxBattler) ||
       pbCanZMoveCompat?(idxBattler) ||
       pbCanUltraCompat?(idxBattler) ||
       pbCanDynamaxCompat?(idxBattler) ||
       pbCanZodiacCompat?(idxBattler)
      return true
    else
      return false
    end
  end
  
  def pbCommandPhase
    @scene.pbBeginCommandPhase
    @battlers.each_with_index do |b,i|
      next if !b
      #-------------------------------------------------------------------------
      # Max Raid Pokemon - Toggles between base moves and Max Moves.
      #-------------------------------------------------------------------------
      if pbDynamaxInstalled?
        if $game_switches[MAXRAID_SWITCH]
          if b.effects[PBEffects::MaxRaidBoss] && rand(10)<5
            b.pbMaxMove
          end
        end
      end
      #-------------------------------------------------------------------------
      pbClearChoice(i) if pbCanShowCommands?(i)
    end
    for side in 0...2
      @megaEvolution[side].each_with_index do |megaEvo,i|
        @megaEvolution[side][i] = -1 if megaEvo>=0
      end
    end
    #---------------------------------------------------------------------------
    # Z-Moves/Ultra Burst
    #---------------------------------------------------------------------------
    if pbZMovesInstalled?
      for side in 0...2
        @ultraBurst[side].each_with_index do |uBurst,i|
          @ultraBurst[side][i] = -1 if uBurst>=0
        end
      end
      for i in 0...@zMove[0].length
        @zMove[0][i]=-1 if @zMove[0][i]>=0
      end
      for i in 0...@zMove[1].length
        @zMove[1][i]=-1 if @zMove[1][i]>=0
      end
    end
    #---------------------------------------------------------------------------
    # Dynamax
    #---------------------------------------------------------------------------
    if pbDynamaxInstalled?
      for side in 0...2
        @dynamax[side].each_with_index do |dmax,i|
          @dynamax[side][i] = -1 if dmax>=0
        end
      end
    end
    #---------------------------------------------------------------------------
    # Zodiac Powers
    #---------------------------------------------------------------------------
    if pbZodiacInstalled?
      for side in 0...2
        @zodiacPower[side].each_with_index do |zPower,i|
          @zodiacPower[side][i] = -1 if zPower>=0
        end
      end
    end
    #---------------------------------------------------------------------------
    pbCommandPhaseLoop(true)
    return if @decision!=0
    pbCommandPhaseLoop(false)
  end

#===============================================================================
# Handles battle mechanics during the attack phase.
#===============================================================================
  def pbAttackPhase
    @scene.pbBeginAttackPhase
    @battlers.each_with_index do |b,i|
      next if !b
      b.turnCount += 1 if !b.fainted?
      @successStates[i].clear
      if @choices[i][0]!=:UseMove && @choices[i][0]!=:Shift && @choices[i][0]!=:SwitchOut
        b.effects[PBEffects::DestinyBond] = false
        b.effects[PBEffects::Grudge]      = false
      end
      b.effects[PBEffects::Rage] = false if !pbChoseMoveFunctionCode?(i,"093")   # Rage
    end
    PBDebug.log("")
    # Calculate move order for this round
    pbCalculatePriority(true)
    # Perform actions
    pbAttackPhasePriorityChangeMessages
    pbAttackPhaseCall
    pbAttackPhaseSwitch
    return if @decision>0
    pbAttackPhaseItems
    return if @decision>0
    pbAttackPhaseMegaEvolution
    #---------------------------------------------------------------------------
    pbAttackPhaseUltraBurst  if pbZMovesInstalled?
    pbAttackPhaseZMoves      if pbZMovesInstalled?
    pbAttackPhaseDynamax     if pbDynamaxInstalled?
    pbAttackPhaseZodiacPower if pbZodiacInstalled?
    pbAttackPhaseRaidBoss    if (pbDynamaxInstalled? && $game_switches[MAXRAID_SWITCH])
    #---------------------------------------------------------------------------
    pbAttackPhaseMoves
  end

  
################################################################################
# SECTION 4 - FIGHT MENU
#===============================================================================
# Handles buttons for activating battle mechanics.
#===============================================================================
  def pbFightMenu(idxBattler)
    return pbAutoChooseMove(idxBattler) if !pbCanShowFightMenu?(idxBattler)
    return true if pbAutoFightMenu(idxBattler)
    ret = false
    @scene.pbFightMenu(idxBattler,pbCanMegaEvolve?(idxBattler),
                                  pbCanUltraCompat?(idxBattler),
                                  pbCanZMoveCompat?(idxBattler),
                                  pbCanDynamaxCompat?(idxBattler),
                                  pbCanZodiacCompat?(idxBattler)) { |cmd|
      case cmd
      when -1   # Cancel
      when -2   # Mega Evolution
        pbToggleRegisteredMegaEvolution(idxBattler)
        next false
      when -3   # Ultra Burst
        pbToggleRegisteredUltraBurst(idxBattler)
        next false
      when -4   # Z-Moves
        pbToggleRegisteredZMove(idxBattler)
        next false
      when -5   # Dynamax
        pbToggleRegisteredDynamax(idxBattler)
        next false
      when -6   # Zodiac Power
        pbToggleRegisteredZodiacPower(idxBattler)   
        next false
      when -7   # Shift
        pbUnregisterMegaEvolution(idxBattler)
        #-----------------------------------------------------------------------
        # Unregisters the appropriate battle mechanic.
        #-----------------------------------------------------------------------
        pbUnregisterZMove(idxBattler)       if pbZMovesInstalled?
        pbUnregisterUltraBurst(idxBattler)  if pbZMovesInstalled?
        pbUnregisterZodiacPower(idxBattler) if pbZodiacInstalled?
        if pbDynamaxInstalled? && pbRegisteredDynamax?(idxBattler)
          pbUnregisterDynamax(idxBattler)     
          @battlers[idxBattler].pbUnMaxMove
        end
        #-----------------------------------------------------------------------
        pbRegisterShift(idxBattler)
        ret = true
      else
        next false if cmd<0 || !@battlers[idxBattler].moves[cmd] ||
                                @battlers[idxBattler].moves[cmd].id<=0
        next false if !pbRegisterMove(idxBattler,cmd)
        next false if !singleBattle? &&
           !pbChooseTarget(@battlers[idxBattler],@battlers[idxBattler].moves[cmd])
        ret = true
      end
      next true
    }
    return ret
  end
end

#===============================================================================
# Effects of button inputs for battle mechanics.
#===============================================================================
class PokeBattle_Scene
  def pbFightMenu(idxBattler,megaEvoPossible=false,ultraPossible=false,
                             zMovePossible=false,dynamaxPossible=false,
                             zodiacPossible=false)
    battler = @battle.battlers[idxBattler]
    cw = @sprites["fightWindow"]
    cw.battler = battler
    moveIndex  = 0
    if battler.moves[@lastMove[idxBattler]] && battler.moves[@lastMove[idxBattler]].id>0
      moveIndex = @lastMove[idxBattler]
    end
    cw.shiftMode = (@battle.pbCanShift?(idxBattler)) ? 1 : 0
    mechanicPossible = false
    if megaEvoPossible || ultraPossible || zMovePossible || dynamaxPossible || zodiacPossible
      mechanicPossible = true
    end
    cw.setIndexAndMode(moveIndex,(mechanicPossible) ? 1 : 0)
    needFullRefresh = true
    needRefresh = false
    loop do
      if needFullRefresh
        pbShowWindow(FIGHT_BOX)
        pbSelectBattler(idxBattler)
        needFullRefresh = false
      end
      if needRefresh
        #-----------------------------------------------------------------------
        # Registers the appropriate battle mechanic.
        #-----------------------------------------------------------------------
        if megaEvoPossible
          newMode = (@battle.pbRegisteredMegaEvolution?(idxBattler)) ? 2 : 1
          cw.mode = newMode if newMode!=cw.mode
        end
        if ultraPossible
          newMode = (@battle.pbRegisteredUltraBurst?(idxBattler)) ? 2 : 1
          cw.mode = newMode if newMode!=cw.mode
        end
        if zMovePossible
          newMode = (@battle.pbRegisteredZMove?(idxBattler)) ? 2 : 1
          cw.mode = newMode if newMode!=cw.mode
        end
        if dynamaxPossible
          newMode = (@battle.pbRegisteredDynamax?(idxBattler)) ? 2 : 1
          cw.mode = newMode if newMode!=cw.mode
        end
        if zodiacPossible
          newMode = (@battle.pbRegisteredZodiacPower?(idxBattler)) ? 2 : 1
          cw.mode = newMode if newMode!=cw.mode
        end
        #-----------------------------------------------------------------------
        needRefresh = false
      end
      oldIndex = cw.index
      pbUpdate(cw)
      if Input.trigger?(Input::LEFT)
        cw.index -= 1 if (cw.index&1)==1
      elsif Input.trigger?(Input::RIGHT)
        if battler.moves[cw.index+1] && battler.moves[cw.index+1].id>0
          cw.index += 1 if (cw.index&1)==0
        end
      elsif Input.trigger?(Input::UP)
        cw.index -= 2 if (cw.index&2)==2
      elsif Input.trigger?(Input::DOWN)
        if battler.moves[cw.index+2] && battler.moves[cw.index+2].id>0
          cw.index += 2 if (cw.index&2)==0
        end
      end
      pbPlayCursorSE if cw.index!=oldIndex
#===============================================================================
# Confirm Selection
#===============================================================================
      if Input.trigger?(Input::C)
        #-----------------------------------------------------------------------
        # Z-Moves
        #-----------------------------------------------------------------------
        if zMovePossible
          if cw.mode==2 && !battler.pbCompatibleZMoveFromIndex?(cw.index)
          pbPlayCancelSE
          @battle.pbDisplay(_INTL("{1} is not compatible with {2}!",PBMoves.getName(battler.moves[cw.index]),PBItems.getName(battler.item)))   
          break if yield -1
        else 
          pbPlayDecisionSE
          break if yield cw.index
          needRefresh = true
         end
        end
        #-----------------------------------------------------------------------
        # Dynamax - Gets Max Move PP usage.
        #-----------------------------------------------------------------------
        if pbDynamaxInstalled?
          if battler.effects[PBEffects::DButton]
            battler.effects[PBEffects::MaxMovePP][cw.index] += 1
          end
        end
        #-----------------------------------------------------------------------
        pbPlayDecisionSE
        break if yield cw.index
        needFullRefresh = true
        needRefresh = true
#===============================================================================
# Cancel Selection
#===============================================================================
      elsif Input.trigger?(Input::B)
        #-----------------------------------------------------------------------
        # Dynamax - Reverts to base moves.
        #-----------------------------------------------------------------------
        if dynamaxPossible
          if !battler.dynamax? && battler.effects[PBEffects::DButton]
            battler.effects[PBEffects::DButton] = false
            battler.pbUnMaxMove
          end
        end
        #-----------------------------------------------------------------------
        pbPlayCancelSE
        break if yield -1
        needRefresh = true
#===============================================================================
# Toggle Battle Mechanic
#===============================================================================
       elsif Input.trigger?(Input::A)
        #-----------------------------------------------------------------------
        # Dynamax
        #-----------------------------------------------------------------------
        if dynamaxPossible
          if battler.effects[PBEffects::DButton]
            battler.effects[PBEffects::DButton] = false
            battler.pbUnMaxMove
          else
            battler.effects[PBEffects::DButton] = true
            battler.pbMaxMove
          end
          needFullRefresh = true
          pbPlayDecisionSE
          break if yield -5
          needRefresh = true
        end
        #-----------------------------------------------------------------------
        # Mega Evolution
        #-----------------------------------------------------------------------
        if megaEvoPossible
          pbPlayDecisionSE
          break if yield -2
          needRefresh = true
        end
        #-----------------------------------------------------------------------
        # Ultra Burst
        #-----------------------------------------------------------------------
        if ultraPossible
          pbPlayDecisionSE
          break if yield -3
          needRefresh = true
        end
        #-----------------------------------------------------------------------
        # Z-Moves
        #-----------------------------------------------------------------------
        if zMovePossible
          pbPlayDecisionSE
          break if yield -4
          needRefresh = true
        end      
        #-----------------------------------------------------------------------
        # Zodiac Power
        #-----------------------------------------------------------------------
        if zodiacPossible
          pbPlayDecisionSE
          break if yield -6
          needRefresh = true
        end
#===============================================================================
# Shift Command
#===============================================================================
      elsif Input.trigger?(Input::F5)
        if cw.shiftMode>0
          pbPlayDecisionSE
          break if yield -7
          needRefresh = true
        end
      end
    end
    @lastMove[idxBattler] = cw.index
  end
end

#===============================================================================
# Displays button graphics.
#===============================================================================
class FightMenuDisplay < BattleMenuBase
  def initialize(viewport,z)
    super(viewport)
    self.x = 0
    self.y = Graphics.height-96
    @battler   = nil
    @shiftMode = 0
    if USE_GRAPHICS
      @buttonBitmap  = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/cursor_fight"))
      @typeBitmap    = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
      @shiftBitmap   = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/cursor_shift"))
      background = IconSprite.new(0,Graphics.height-96,viewport)
      background.setBitmap("Graphics/Pictures/Battle/overlay_fight")
      addSprite("background",background)
      @buttons = Array.new(MAX_MOVES) do |i|
        button = SpriteWrapper.new(viewport)
        button.bitmap = @buttonBitmap.bitmap
        button.x      = self.x+4
        button.x      += (((i%2)==0) ? 0 : @buttonBitmap.width/2-4)
        button.y      = self.y+6
        button.y      += (((i/2)==0) ? 0 : BUTTON_HEIGHT-4)
        button.src_rect.width  = @buttonBitmap.width/2
        button.src_rect.height = BUTTON_HEIGHT
        addSprite("button_#{i}",button)
        next button
      end
      @overlay = BitmapSprite.new(Graphics.width,Graphics.height-self.y,viewport)
      @overlay.x = self.x
      @overlay.y = self.y
      pbSetNarrowFont(@overlay.bitmap)
      addSprite("overlay",@overlay)
      @infoOverlay = BitmapSprite.new(Graphics.width,Graphics.height-self.y,viewport)
      @infoOverlay.x = self.x
      @infoOverlay.y = self.y
      pbSetNarrowFont(@infoOverlay.bitmap)
      addSprite("infoOverlay",@infoOverlay)
      @typeIcon = SpriteWrapper.new(viewport)
      @typeIcon.bitmap = @typeBitmap.bitmap
      @typeIcon.x      = self.x+416
      @typeIcon.y      = self.y+20
      @typeIcon.src_rect.height = TYPE_ICON_HEIGHT
      addSprite("typeIcon",@typeIcon)
      #-------------------------------------------------------------------------
      # Sets battle mechanic button.
      #-------------------------------------------------------------------------
      @battleButton = SpriteWrapper.new(viewport)
      #-------------------------------------------------------------------------
      @shiftButton = SpriteWrapper.new(viewport)
      @shiftButton.bitmap = @shiftBitmap.bitmap
      @shiftButton.x      = self.x+4
      @shiftButton.y      = self.y-@shiftBitmap.height
      addSprite("shiftButton",@shiftButton)
    else
      @msgBox = Window_AdvancedTextPokemon.newWithSize("",
         self.x+320,self.y,Graphics.width-320,Graphics.height-self.y,viewport)
      @msgBox.baseColor   = Color.new(0,0,0)
      @msgBox.shadowColor = Color.new(255,255,255)
      pbSetNarrowFont(@msgBox.contents)
      addSprite("msgBox",@msgBox)
      @cmdWindow = Window_CommandPokemon.newWithSize([],
         self.x,self.y,320,Graphics.height-self.y,viewport)  
      @cmdWindow.columns       = 2
      @cmdWindow.columnSpacing = 4
      @cmdWindow.ignore_input  = true
      pbSetNarrowFont(@cmdWindow.contents)
      addSprite("cmdWindow",@cmdWindow)
    end
    self.z = z
  end
  
  def dispose
    super
    @buttonBitmap.dispose  if @buttonBitmap
    @typeBitmap.dispose    if @typeBitmap
    @shiftBitmap.dispose   if @shiftBitmap
    #---------------------------------------------------------------------------
    @battleButtonBitmap.dispose if @battleButtonBitmap
    #---------------------------------------------------------------------------
  end
  
  #-----------------------------------------------------------------------------
  # Displays appropriate button for battle mechanics.
  #-----------------------------------------------------------------------------
  def refreshBattleButton
    return if !USE_GRAPHICS
    if USE_GRAPHICS
      if @battler.battle.pbCanUseBattleMechanic?(@battler.index)
        if @battler.battle.pbCanMegaEvolve?(@battler.index)       # Mega Evolution
          @battleButtonBitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/cursor_mega"))
        elsif @battler.battle.pbCanUltraCompat?(@battler.index)   # Ultra Burst
          @battleButtonBitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/cursor_ultra"))
        elsif @battler.battle.pbCanZMoveCompat?(@battler.index)   # Z-Moves
          @battleButtonBitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/cursor_zmove"))
        elsif @battler.battle.pbCanDynamaxCompat?(@battler.index) # Dynamax
          @battleButtonBitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Dynamax/cursor_dynamax"))
          @battleButtonBitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Dynamax/cursor_dynamax_2")) if DMAX_BUTTON_2
        elsif @battler.battle.pbCanZodiacCompat?(@battler.index)  # Zodiac Powers
          @battleButtonBitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Birthsigns/Other/battlezodiac"))
        end
        @battleButton.bitmap = @battleButtonBitmap.bitmap
        @battleButton.x      = self.x+146
        @battleButton.y      = self.y-@battleButtonBitmap.height/2
        @battleButton.src_rect.height = @battleButtonBitmap.height/2
        addSprite("battleButton",@battleButton)
      end
    end
    if @battleButtonBitmap
      @battleButton.src_rect.y    = (@mode - 1) * @battleButtonBitmap.height / 2
      @battleButton.z             = self.z - 1
      @visibility["battleButton"] = (@mode > 0)
    end
  end
  
  def refresh
    return if !@battler
    refreshSelection
    refreshShiftButton
    #---------------------------------------------------------------------------
    refreshBattleButton
    refreshButtonNames
    #---------------------------------------------------------------------------
  end
end


################################################################################
# SECTION 5 - BATTLE VISUALS
#===============================================================================
# Handles battle certain databox visuals in battle.
#===============================================================================
class PokemonDataBox < SpriteWrapper
  def initializeDataBoxGraphic(sideSize)
    onPlayerSide = ((@battler.index%2)==0)
    #---------------------------------------------------------------------------
    # Sets a raid battle box for a Max Raid Pokemon.
    #---------------------------------------------------------------------------
    if pbDynamaxInstalled? && $game_switches[MAXRAID_SWITCH]
      if sideSize==1
        bgFilename = ["Graphics/Pictures/Battle/databox_normal",
                      "Graphics/Pictures/Dynamax/databox_maxraid"][@battler.index%2]
        if onPlayerSide
          @showHP  = true
          @showExp = true
        end
      else
        bgFilename = ["Graphics/Pictures/Battle/databox_thin",
                      "Graphics/Pictures/Dynamax/databox_maxraid"][@battler.index%2]
      end
    #---------------------------------------------------------------------------                
    else
      if sideSize==1
        bgFilename = ["Graphics/Pictures/Battle/databox_normal",
                      "Graphics/Pictures/Battle/databox_normal_foe"][@battler.index%2]
        if onPlayerSide
          @showHP  = true
          @showExp = true
        end
      else
        bgFilename = ["Graphics/Pictures/Battle/databox_thin",
                      "Graphics/Pictures/Battle/databox_thin_foe"][@battler.index%2]
      end
    end
    @databoxBitmap  = AnimatedBitmap.new(bgFilename)
    if onPlayerSide
      @spriteX = Graphics.width - 244
      @spriteY = Graphics.height - 192
      @spriteBaseX = 34
    else
      @spriteX = -16
      @spriteY = 36
      @spriteBaseX = 16
    end
    case sideSize
    when 2
      @spriteX += [-12,  12,  0,  0][@battler.index]
      @spriteY += [-20, -34, 34, 20][@battler.index]
    when 3
      @spriteX += [-12,  12, -6,  6,  0,  0][@battler.index]
      @spriteY += [-42, -46,  4,  0, 50, 46][@battler.index]
    end
  end
  
  def initializeOtherGraphics(viewport)
    @numbersBitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/icon_numbers"))
    @hpBarBitmap   = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/overlay_hp"))
    @expBarBitmap  = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/overlay_exp"))
    #---------------------------------------------------------------------------
    # Max Raid Displays
    #---------------------------------------------------------------------------
    if pbDynamaxInstalled?
      @raidNumbersBitmap  = AnimatedBitmap.new(_INTL("Graphics/Pictures/Dynamax/raidbattle_num"))
      @raidNumbersBitmap1 = AnimatedBitmap.new(_INTL("Graphics/Pictures/Dynamax/raidbattle_num1"))
      @raidNumbersBitmap2 = AnimatedBitmap.new(_INTL("Graphics/Pictures/Dynamax/raidbattle_num2"))
      @raidNumbersBitmap3 = AnimatedBitmap.new(_INTL("Graphics/Pictures/Dynamax/raidbattle_num3"))
      @raidBar            = AnimatedBitmap.new(_INTL("Graphics/Pictures/Dynamax/raidbattle_bar"))
      @shieldHP           = AnimatedBitmap.new(_INTL("Graphics/Pictures/Dynamax/raidbattle_shield"))
    end
    #---------------------------------------------------------------------------
    @hpNumbers = BitmapSprite.new(124,16,viewport)
    pbSetSmallFont(@hpNumbers.bitmap)
    @sprites["hpNumbers"] = @hpNumbers
    @hpBar = SpriteWrapper.new(viewport)
    @hpBar.bitmap = @hpBarBitmap.bitmap
    @hpBar.src_rect.height = @hpBarBitmap.height/3
    @sprites["hpBar"] = @hpBar
    @expBar = SpriteWrapper.new(viewport)
    @expBar.bitmap = @expBarBitmap.bitmap
    @sprites["expBar"] = @expBar
    @contents = BitmapWrapper.new(@databoxBitmap.width,@databoxBitmap.height)
    self.bitmap  = @contents
    self.visible = false
    self.z       = 150+((@battler.index)/2)*5
    pbSetSystemFont(self.bitmap)
  end
  
  def dispose
    pbDisposeSpriteHash(@sprites)
    @databoxBitmap.dispose
    @numbersBitmap.dispose
    @hpBarBitmap.dispose
    @expBarBitmap.dispose
    #---------------------------------------------------------------------------
    # Max Raid Displays
    #---------------------------------------------------------------------------
    if pbDynamaxInstalled?
      @raidNumbersBitmap.dispose
      @raidNumbersBitmap1.dispose
      @raidNumbersBitmap2.dispose
      @raidNumbersBitmap3.dispose
      @raidBar.dispose
      @shieldHP.dispose
    end
    #---------------------------------------------------------------------------
    @contents.dispose
    super
  end
  
  #=============================================================================
  # Draws the timer and ko numbers during a Max Raid battle.
  #=============================================================================
  def pbDrawRaidNumber(counter,number,btmp,startX,startY,align=0)
    n = (number==-1) ? [10] : number.to_i.digits
    if (counter==0 && number<=MAXRAID_TIMER/8) ||
       (counter==1 && number<=1)
      charWidth  = @raidNumbersBitmap3.width/11
      charHeight = @raidNumbersBitmap3.height
      numbers    = @raidNumbersBitmap3.bitmap
    elsif (counter==0 && number<=MAXRAID_TIMER/4) ||
          (counter==1 && number<=MAXRAID_KOS/4)
      charWidth  = @raidNumbersBitmap2.width/11
      charHeight = @raidNumbersBitmap2.height
      numbers    = @raidNumbersBitmap2.bitmap
    elsif (counter==0 && number<=MAXRAID_TIMER/2) ||
          (counter==1 && number<=MAXRAID_KOS/2)
      charWidth  = @raidNumbersBitmap1.width/11
      charHeight = @raidNumbersBitmap1.height
      numbers    = @raidNumbersBitmap1.bitmap
    else
      charWidth  = @raidNumbersBitmap.width/11
      charHeight = @raidNumbersBitmap.height
      numbers    = @raidNumbersBitmap.bitmap
    end
    startX -= charWidth*n.length if align==1
    n.each do |i|
      btmp.blt(startX,startY,numbers,Rect.new(i*charWidth,0,charWidth,charHeight))
      startX += charWidth
    end
  end
  
  #=============================================================================
  # Databox visuals.
  #=============================================================================
  def refresh
    self.bitmap.clear
    return if !@battler.pokemon
    textPos   = []
    imagePos  = []
    self.bitmap.blt(0,0,@databoxBitmap.bitmap,Rect.new(0,0,@databoxBitmap.width,@databoxBitmap.height))
    nameWidth = self.bitmap.text_size(@battler.name).width
    nameOffset = 0
    nameOffset = nameWidth-116 if nameWidth>116
    #---------------------------------------------------------------------------
    # Sets all battle visuals for a Max Raid Pokemon.
    #---------------------------------------------------------------------------
    if pbDynamaxInstalled? && $game_switches[MAXRAID_SWITCH] && @battler.effects[PBEffects::MaxRaidBoss]
      textPos.push([@battler.name,@spriteBaseX+8-nameOffset,6,false,Color.new(248,248,248),Color.new(248,32,32)])
      turncount = @battler.effects[PBEffects::Dynamax]-1
      pbDrawRaidNumber(0,turncount,self.bitmap,@spriteBaseX+170,20,1)
      kocount = @battler.effects[PBEffects::KnockOutCount]
      kocount = 0 if kocount<0
      pbDrawRaidNumber(1,kocount,self.bitmap,@spriteBaseX+199,20,1)
      if @battler.effects[PBEffects::RaidShield]>0
        shieldHP   =   @battler.effects[PBEffects::RaidShield]
        shieldLvl  =   MAXRAID_SHIELD
        shieldLvl += 1 if @battler.level>25
        shieldLvl += 1 if @battler.level>35
        shieldLvl += 1 if @battler.level>45
        shieldLvl += 1 if @battler.level>55
        shieldLvl += 1 if @battler.level>65
        shieldLvl += 1 if @battler.level>=70 || $game_switches[HARDMODE_RAID]
        shieldLvl  = 1 if shieldLvl<=0
        shieldLvl  = 8 if shieldLvl>8
        offset     = (121-(2+shieldLvl*30/2))
        self.bitmap.blt(@spriteBaseX+offset,59,@raidBar.bitmap,Rect.new(0,0,2+shieldLvl*30,12)) 
        self.bitmap.blt(@spriteBaseX+offset,59,@shieldHP.bitmap,Rect.new(0,0,2+shieldHP*30,12))
      end
    #---------------------------------------------------------------------------
    else
      textPos.push([@battler.name,@spriteBaseX+8-nameOffset,6,false,NAME_BASE_COLOR,NAME_SHADOW_COLOR])
      case @battler.displayGender
      when 0
        textPos.push([_INTL("♂"),@spriteBaseX+126,6,false,MALE_BASE_COLOR,MALE_SHADOW_COLOR])
      when 1
        textPos.push([_INTL("♀"),@spriteBaseX+126,6,false,FEMALE_BASE_COLOR,FEMALE_SHADOW_COLOR])
      end
      imagePos.push(["Graphics/Pictures/Battle/overlay_lv",@spriteBaseX+140,16])
      pbDrawNumber(@battler.level,self.bitmap,@spriteBaseX+162,16)
    end
    pbDrawTextPositions(self.bitmap,textPos)
    if @battler.shiny?
      shinyX = (@battler.opposes?(0)) ? 206 : -6   # Foe's/player's
      imagePos.push(["Graphics/Pictures/shiny",@spriteBaseX+shinyX,36])
    end
    if @battler.mega?
      imagePos.push(["Graphics/Pictures/Battle/icon_mega",@spriteBaseX+8,34])
    elsif @battler.primal?
      primalX = (@battler.opposes?) ? 208 : -28   # Foe's/player's
      if isConst?(@battler.pokemon.species,PBSpecies,:KYOGRE)
        imagePos.push(["Graphics/Pictures/Battle/icon_primal_Kyogre",@spriteBaseX+primalX,4])
      elsif isConst?(@battler.pokemon.species,PBSpecies,:GROUDON)
        imagePos.push(["Graphics/Pictures/Battle/icon_primal_Groudon",@spriteBaseX+primalX,4])
      end
    #---------------------------------------------------------------------------
    # Draws Ultra Burst icon.
    #---------------------------------------------------------------------------
    #elsif pbZMovesInstalled && @battler.ultra?
    #  imagePos.push(["Graphics/Pictures/Battle/icon_ultra",@spriteBaseX+8,34])
    #---------------------------------------------------------------------------
    # Draws Dynamax icon.
    #---------------------------------------------------------------------------
    elsif pbDynamaxInstalled? && @battler.dynamax?
      imagePos.push(["Graphics/Pictures/Dynamax/icon_dynamax",@spriteBaseX+8,34])
    end
    #---------------------------------------------------------------------------
    if @battler.owned? && @battler.opposes?(0) && (pbDynamaxInstalled? && !@battler.dynamax?)
      imagePos.push(["Graphics/Pictures/Battle/icon_own",@spriteBaseX+8,36])
    end
    if @battler.status>0
      s = @battler.status
      s = 6 if s==PBStatuses::POISON && @battler.statusCount>0   # Badly poisoned
      imagePos.push(["Graphics/Pictures/Battle/icon_statuses",@spriteBaseX+24,36,
         0,(s-1)*STATUS_ICON_HEIGHT,-1,STATUS_ICON_HEIGHT])
    end
    pbDrawImagePositions(self.bitmap,imagePos)
    refreshHP
    refreshExp
  end
end


################################################################################
# SECTION 6 - POKEMON BATTLER SPRITES
#===============================================================================
# Enlarges Pokémon battler sprites when Dynamaxed, if installed.
#-------------------------------------------------------------------------------
class PokemonBattlerSprite < RPG::Sprite
  def setPokemonBitmap(pkmn,back=false)
    @pkmn = pkmn
    @_iconBitmap.dispose if @_iconBitmap
    @_iconBitmap = pbLoadPokemonBitmap(@pkmn,back)
    self.bitmap = (@_iconBitmap) ? @_iconBitmap.bitmap : nil
    pbSetPosition
    #---------------------------------------------------------------------------
    # Enlarges and/or colors Dynamax sprites
    #---------------------------------------------------------------------------
    if @pkmn.compatDmax?
      if pbMakeEnlarged?
        self.zoom_x = 1.5
        self.zoom_y = 1.5
        if !back
          self.y = self.y+16
        end
      end
      if pbAddDynamaxColor?
        self.color = Color.new(217,29,71,128)
        self.color = Color.new(56,160,193,128) if @pkmn.isSpecies?(:CALYREX)
      end
    end
    #---------------------------------------------------------------------------
  end
  
  def pbPlayIntroAnimation(pictureEx=nil)
    return if !@pkmn
    cry = pbCryFile(@pkmn)
    #---------------------------------------------------------------------------
    # Deepens Dynamax cries.
    #---------------------------------------------------------------------------
    if cry
      if @pkmn.compatDmax?
        pbSEPlay(cry,100,60)
      else
        pbSEPlay(cry)
      end
    end
    #---------------------------------------------------------------------------
  end
  
  def update(frameCounter=0)
    return if !@_iconBitmap
    @updating = true
    @_iconBitmap.update
    self.bitmap = @_iconBitmap.bitmap
    @spriteYExtra = 0
    if @selected==1
      case (frameCounter/QUARTER_ANIM_PERIOD).floor
      when 1; @spriteYExtra = 2
      when 3; @spriteYExtra = -2
      end
    end
    self.x       = self.x
    self.y       = self.y
    #---------------------------------------------------------------------------
    # Enlarges and/or colors Dynamax sprites.
    #---------------------------------------------------------------------------
    if @pkmn.compatDmax?
      if pbMakeEnlarged?
        self.zoom_x = 1.5
        self.zoom_y = 1.5
      else
        self.zoom_x = 1
        self.zoom_y = 1
      end
      if pbAddDynamaxColor?
        self.color = Color.new(217,29,71,128)
        self.color = Color.new(56,160,193,128) if @pkmn.isSpecies?(:CALYREX)
      else
        self.color = Color.new(0,0,0,0)
      end
    end
    #---------------------------------------------------------------------------
    self.visible = @spriteVisible
    if @selected==2 && @spriteVisible
      case (frameCounter/SIXTH_ANIM_PERIOD).floor
      when 2, 5; self.visible = false
      else;      self.visible = true
      end
    end
    @updating = false
  end
end

class PokemonBattlerShadowSprite < RPG::Sprite
  def setPokemonBitmap(pkmn)
    @pkmn = pkmn
    @_iconBitmap.dispose if @_iconBitmap
    @_iconBitmap = pbLoadPokemonShadowBitmap(@pkmn)
    self.bitmap = (@_iconBitmap) ? @_iconBitmap.bitmap : nil
    #---------------------------------------------------------------------------
    # Enlarges Dynamax shadows.
    #---------------------------------------------------------------------------
    if pbMakeEnlarged? && @pkmn.compatDmax?
      self.zoom_x = 2
      self.zoom_y = 2
    end
    #---------------------------------------------------------------------------
    pbSetPosition
  end
end

class PokeBattle_Scene
  def pbAnimationCore(animation,user,target,oppMove=false)
    return if !animation
    @briefMessage = false
    userSprite   = (user) ? @sprites["pokemon_#{user.index}"] : nil
    targetSprite = (target) ? @sprites["pokemon_#{target.index}"] : nil
    oldUserX = (userSprite) ? userSprite.x : 0
    oldUserY = (userSprite) ? userSprite.y : 0
    oldTargetX = (targetSprite) ? targetSprite.x : oldUserX
    oldTargetY = (targetSprite) ? targetSprite.y : oldUserY
    #---------------------------------------------------------------------------
    # Used for Enlarged Dynamax sprites.
    #---------------------------------------------------------------------------
    if pbMakeEnlarged?
      oldUserZoomX = (userSprite) ? userSprite.zoom_x : 1
      oldUserZoomY = (userSprite) ? userSprite.zoom_y : 1
      oldTargetZoomX = (targetSprite) ? targetSprite.zoom_x : 1
      oldTargetZoomY = (targetSprite) ? targetSprite.zoom_y : 1
    end
    if pbAddDynamaxColor?
      newcolor  = Color.new(217,29,71,128)
      newcolor2 = Color.new(56,160,193,128) # Calyrex
      oldcolor  = Color.new(0,0,0,0)
      # Colors user's sprite.
      if userSprite && user.dynamax?
        oldUserColor = user.isSpecies?(:CALYREX) ? newcolor2 : newcolor
      else
        oldUserColor = oldcolor
      end
      # Colors target's sprite.
      if targetSprite && target.dynamax?
        oldTargetColor = target.isSpecies?(:CALYREX) ? newcolor2 : newcolor
      else
        oldTargetColor = oldcolor
      end
    end
    #---------------------------------------------------------------------------
    animPlayer = PBAnimationPlayerX.new(animation,user,target,self,oppMove)
    userHeight = (userSprite && userSprite.bitmap && !userSprite.bitmap.disposed?) ? userSprite.bitmap.height : 128
    if targetSprite
      targetHeight = (targetSprite.bitmap && !targetSprite.bitmap.disposed?) ? targetSprite.bitmap.height : 128
    else
      targetHeight = userHeight
    end
    animPlayer.setLineTransform(
       PokeBattle_SceneConstants::FOCUSUSER_X,PokeBattle_SceneConstants::FOCUSUSER_Y,
       PokeBattle_SceneConstants::FOCUSTARGET_X,PokeBattle_SceneConstants::FOCUSTARGET_Y,
       oldUserX,oldUserY-userHeight/2,
       oldTargetX,oldTargetY-targetHeight/2)
    animPlayer.start
    loop do
      animPlayer.update
      #-------------------------------------------------------------------------
      # Used for Enlarged Dynamax sprites.
      #-------------------------------------------------------------------------
      if pbMakeEnlarged?
        userSprite.zoom_x = oldUserZoomX if userSprite
        userSprite.zoom_y = oldUserZoomY if userSprite
        targetSprite.zoom_x = oldTargetZoomX if targetSprite
        targetSprite.zoom_y = oldTargetZoomY if targetSprite
      end
      if pbAddDynamaxColor?
        userSprite.color = oldUserColor if userSprite
        targetSprite.color = oldTargetColor if targetSprite
      end
      #-------------------------------------------------------------------------
      pbUpdate
      break if animPlayer.animDone?
    end
    animPlayer.dispose
    if userSprite
      userSprite.x = oldUserX
      userSprite.y = oldUserY
      userSprite.pbSetOrigin
    end
    if targetSprite
      targetSprite.x = oldTargetX
      targetSprite.y = oldTargetY
      targetSprite.pbSetOrigin
    end
  end
end

#===============================================================================
# Adds Dynamax/Celestial values to Pokemon battler sprites.
#===============================================================================
class PokemonSprite < SpriteWrapper
  def setSpeciesBitmap(species,female=false,form=0,shiny=false,shadow=false,
                       back=false,egg=false,gmax=false,celestial=false)
    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap = pbLoadSpeciesBitmap(species,female,form,shiny,shadow,back,egg,gmax,celestial)
    self.bitmap = (@_iconbitmap) ? @_iconbitmap.bitmap : nil
    changeOrigin
  end
end

#-------------------------------------------------------------------------------
# Used for defined Pokemon.
#-------------------------------------------------------------------------------
def pbLoadPokemonBitmapSpecies(pokemon,species,back=false)
  ret = nil
  if pokemon.egg?
    bitmapFileName = sprintf("Graphics/Battlers/%segg_%d",getConstantName(PBSpecies,species),pokemon.form) rescue nil
    if !pbResolveBitmap(bitmapFileName)
      bitmapFileName = sprintf("Graphics/Battlers/%03degg_%d",species,pokemon.form)
      if !pbResolveBitmap(bitmapFileName)
        bitmapFileName = sprintf("Graphics/Battlers/%segg",getConstantName(PBSpecies,species)) rescue nil
        if !pbResolveBitmap(bitmapFileName)
          bitmapFileName = sprintf("Graphics/Battlers/%03degg",species)
          if !pbResolveBitmap(bitmapFileName)
            bitmapFileName = sprintf("Graphics/Battlers/egg")
          end
        end
      end
    end
    bitmapFileName = pbResolveBitmap(bitmapFileName)
  else
    bitmapFileName = pbCheckPokemonBitmapFiles([species,back,(pokemon.female?),
       pokemon.shiny?,(pokemon.form rescue 0),pokemon.shadowPokemon?,
       pokemon.compatGmax?,pokemon.compatSigns?])
    alterBitmap = (MultipleForms.getFunction(species,"alterBitmap") rescue nil)
  end
  #-----------------------------------------------------------------------------
  # Changes hues for Celestial Pokemon.
  #-----------------------------------------------------------------------------
  hue = 0
  if pbAddCelestialHues? && pokemon.compatSigns?
    hue = pbGetCelestialHues(pokemon.species,pokemon.form)
  end
  #-----------------------------------------------------------------------------
  if bitmapFileName && alterBitmap
    animatedBitmap = AnimatedBitmap.new(bitmapFileName,hue)
    copiedBitmap = animatedBitmap.copy
    animatedBitmap.dispose
    copiedBitmap.each { |bitmap| alterBitmap.call(pokemon,bitmap) }
    ret = copiedBitmap
  elsif bitmapFileName
    ret = AnimatedBitmap.new(bitmapFileName,hue)
  end
  return ret
end

#-------------------------------------------------------------------------------
# Used for Pokemon species.
#-------------------------------------------------------------------------------
def pbLoadSpeciesBitmap(species,female=false,form=0,shiny=false,shadow=false,
                        back=false,egg=false,gmax=false,celestial=false)
  ret = nil
  if egg
    bitmapFileName = sprintf("Graphics/Battlers/%segg_%d",getConstantName(PBSpecies,species),form) rescue nil
    if !pbResolveBitmap(bitmapFileName)
      bitmapFileName = sprintf("Graphics/Battlers/%03degg_%d",species,form)
      if !pbResolveBitmap(bitmapFileName)
        bitmapFileName = sprintf("Graphics/Battlers/%segg",getConstantName(PBSpecies,species)) rescue nil
        if !pbResolveBitmap(bitmapFileName)
          bitmapFileName = sprintf("Graphics/Battlers/%03degg",species)
          if !pbResolveBitmap(bitmapFileName)
            bitmapFileName = sprintf("Graphics/Battlers/egg")
          end
        end
      end
    end
    bitmapFileName = pbResolveBitmap(bitmapFileName)
  else
    bitmapFileName = pbCheckPokemonBitmapFiles([species,back,female,shiny,form,shadow,gmax,celestial])
  end
  if bitmapFileName
    #---------------------------------------------------------------------------
    # Changes hues for Celestial Pokemon.
    #---------------------------------------------------------------------------
    hue = 0
    if pbAddCelestialHues? && celestial
      hue = pbGetCelestialHues(species,form)
    end
    #---------------------------------------------------------------------------
    ret = AnimatedBitmap.new(bitmapFileName,hue)
  end
  return ret
end

#-------------------------------------------------------------------------------
# Checks file pathways for battler sprites.
#-------------------------------------------------------------------------------
def pbCheckPokemonBitmapFiles(params)
  factors = []
  factors.push([7,params[7],false]) if params[7] && params[7]!=false   # celestial
  factors.push([6,params[6],false]) if params[6] && params[6]!=false   # gigantamax
  factors.push([5,params[5],false]) if params[5] && params[5]!=false   # shadow
  factors.push([2,params[2],false]) if params[2] && params[2]!=false   # gender
  factors.push([3,params[3],false]) if params[3] && params[3]!=false   # shiny
  factors.push([4,params[4],0]) if params[4] && params[4]!=0           # form
  factors.push([0,params[0],0])                                        # species
  trySpecies   = 0
  tryGender    = false
  tryShiny     = false
  tryBack      = params[1]
  tryForm      = 0
  tryShadow    = false
  tryGmax      = false
  tryCelestial = false
  for i in 0...2**factors.length
    factors.each_with_index do |factor,index|
      newVal = ((i/(2**index))%2==0) ? factor[1] : factor[2]
      case factor[0]
      when 0; trySpecies    = newVal
      when 2; tryGender     = newVal
      when 3; tryShiny      = newVal
      when 4; tryForm       = newVal
      when 5; tryShadow     = newVal
      when 6; tryGmax       = newVal
      when 7; tryCelestial  = newVal
      end
    end
    for j in 0...2
      next if trySpecies==0 && j==0
      trySpeciesText = (j==0) ? getConstantName(PBSpecies,trySpecies) : sprintf("%03d",trySpecies)
      bitmapFileName = sprintf("Graphics/Battlers/%s%s%s%s%s%s%s%s",
         trySpeciesText,
         (tryGender) ? "f" : "",
         (tryShiny) ? "s" : "",
         (tryBack) ? "b" : "",
         (tryForm!=0) ? "_"+tryForm.to_s : "",
         (tryShadow) ? "_shadow" : "",
         (tryGmax) ? "_gmax" : "",
         (tryCelestial) ? "_celestial" : "") rescue nil
      ret = pbResolveBitmap(bitmapFileName)
      return ret if ret
    end
  end
  return nil
end


################################################################################
# SECTION 7 - POKEMON ICON SPRITES
#===============================================================================
# Enlarges Pokemon icon sprites in the party menu when Dynamaxed.
#-------------------------------------------------------------------------------
class PokemonPartyPanel < SpriteWrapper
  def pbDynamaxSize
    if pbMakeEnlarged?
      largeicons = true if @pokemon.compatGmax? && GMAX_XL_ICONS
      if @pokemon.compatDmax? && !largeicons
        @pkmnsprite.zoom_x = 1.5 
        @pkmnsprite.zoom_y = 1.5
      else
        @pkmnsprite.zoom_x = 1
        @pkmnsprite.zoom_y = 1
      end
    end
  end
  def pbDynamaxColor
    if pbAddDynamaxColor?
      if @pokemon.compatDmax?
        @pkmnsprite.color = Color.new(217,29,71,128)
        @pkmnsprite.color = Color.new(56,160,193,128) if @pokemon.isSpecies?(:CALYREX)
      else
        @pkmnsprite.color = self.color
      end
    end
  end
end

#-------------------------------------------------------------------------------
# Used for defined Pokemon.
#-------------------------------------------------------------------------------
class PokemonIconSprite < SpriteWrapper
  def pokemon=(value)
    @pokemon = value
    @animBitmap.dispose if @animBitmap
    @animBitmap = nil
    if !@pokemon
      self.bitmap = nil
      @currentFrame = 0
      @counter = 0
      return
    end
    #---------------------------------------------------------------------------
    # Changes hues for Celestial Pokemon.
    #---------------------------------------------------------------------------
    hue = 0
    if pbAddCelestialHues? && @pokemon.compatSigns?
      hue = pbGetCelestialHues(@pokemon.species,@pokemon.form)
    end
    #---------------------------------------------------------------------------
    @animBitmap = AnimatedBitmap.new(pbPokemonIconFile(value),hue)
    self.bitmap = @animBitmap.bitmap
    self.src_rect.width  = @animBitmap.height
    self.src_rect.height = @animBitmap.height
    @numFrames    = @animBitmap.width/@animBitmap.height
    @currentFrame = 0 if @currentFrame>=@numFrames
    changeOrigin
  end
end

#-------------------------------------------------------------------------------
# Used for Pokemon species.
#-------------------------------------------------------------------------------
class PokemonSpeciesIconSprite < SpriteWrapper
  attr_reader :gmax
  attr_reader :celestial

  def initialize(species,viewport=nil)
    super(viewport)
    @species      = species
    @gender       = 0
    @form         = 0
    @shiny        = 0
    @gmax         = 0
    @celestial    = 0
    @numFrames    = 0
    @currentFrame = 0
    @counter      = 0
    refresh
  end
  
  # Gigantamax value for icon sprites.
  def gmax=(value)
    @gmax = value
    refresh
  end
  
  # Celestial value for icon sprites.
  def celestial=(value)
    @celestial = value
    refresh
  end
  
  # Set Dynamax/Celestial icon sprites with true/false parameters.
  def pbSetParams(species,gender,form,shiny=false,gmax=false,celestial=false)
    @species   = species
    @gender    = gender
    @form      = form
    @shiny     = shiny
    @gmax      = gmax
    @celestial = celestial
    refresh
  end
  
  def refresh
    @animBitmap.dispose if @animBitmap
    @animBitmap = nil
    bitmapFileName = pbCheckPokemonIconFiles([@species,(@gender==1),@shiny,@form,false,@gmax,@celestial])
    #---------------------------------------------------------------------------
    # Changes hues for Celestial Pokemon.
    #---------------------------------------------------------------------------
    hue = 0
    if pbAddCelestialHues? && @celestial
      hue = pbGetCelestialHues(species,form)
    end
    #---------------------------------------------------------------------------
    @animBitmap = AnimatedBitmap.new(bitmapFileName,hue)
    self.bitmap = @animBitmap.bitmap
    self.src_rect.width  = @animBitmap.height
    self.src_rect.height = @animBitmap.height
    @numFrames = @animBitmap.width/@animBitmap.height
    @currentFrame = 0 if @currentFrame>=@numFrames
    changeOrigin
  end
end  
   
#-------------------------------------------------------------------------------
# Checks file pathways for icon sprites.
#-------------------------------------------------------------------------------
def pbPokemonIconFile(pokemon)
  return pbCheckPokemonIconFiles([pokemon.species,pokemon.female?,              # Species, Gender
                                  pokemon.shiny?,(pokemon.form rescue 0),       # Shiny, Form
                                  pokemon.shadowPokemon?,pokemon.compatGmax?,   # Shadow, G-Max
                                  pokemon.compatSigns?],pokemon.egg?)           # Celestial, Egg
end

def pbCheckPokemonIconFiles(params,egg=false)
  species = params[0]
  if egg
    bitmapFileName = sprintf("Graphics/Icons/icon%segg_%d",getConstantName(PBSpecies,species),params[3]) rescue nil
    if !pbResolveBitmap(bitmapFileName)
      bitmapFileName = sprintf("Graphics/Icons/icon%03degg_%d",species,params[3])
      if !pbResolveBitmap(bitmapFileName)
        bitmapFileName = sprintf("Graphics/Icons/icon%segg",getConstantName(PBSpecies,species)) rescue nil
        if !pbResolveBitmap(bitmapFileName)
          bitmapFileName = sprintf("Graphics/Icons/icon%03degg",species)
          if !pbResolveBitmap(bitmapFileName)
            bitmapFileName = sprintf("Graphics/Icons/iconEgg")
          end
        end
      end
    end
    return pbResolveBitmap(bitmapFileName)
  end
  factors = []
  factors.push([6,params[6],false]) if params[6] && params[6]!=false   # celestial
  factors.push([5,params[5],false]) if params[5] && params[5]!=false   # gmax
  factors.push([4,params[4],false]) if params[4] && params[4]!=false   # shadow
  factors.push([1,params[1],false]) if params[1] && params[1]!=false   # gender
  factors.push([2,params[2],false]) if params[2] && params[2]!=false   # shiny
  factors.push([3,params[3],0]) if params[3] && params[3]!=0           # form
  factors.push([0,params[0],0])                                        # species
  trySpecies    = 0
  tryGender     = false
  tryShiny      = false
  tryForm       = 0
  tryShadow     = false
  tryGmax       = false
  tryCelestial  = false
  for i in 0...2**factors.length
    factors.each_with_index do |factor,index|
      newVal = ((i/(2**index))%2==0) ? factor[1] : factor[2]
      case factor[0]
      when 0; trySpecies    = newVal
      when 1; tryGender     = newVal
      when 2; tryShiny      = newVal
      when 3; tryForm       = newVal
      when 4; tryShadow     = newVal
      when 5; tryGmax       = newVal
      when 6; tryCelestial  = newVal
      end
    end
    for j in 0...2
      next if trySpecies==0 && j==0
      trySpeciesText = (j==0) ? getConstantName(PBSpecies,trySpecies) : sprintf("%03d",trySpecies)
      bitmapFileName = sprintf("Graphics/Icons/icon%s%s%s%s%s%s%s",
         trySpeciesText,
         (tryGender) ? "f" : "",
         (tryShiny) ? "s" : "",
         (tryForm!=0) ? "_"+tryForm.to_s : "",
         (tryShadow) ? "_shadow" : "",
         (tryGmax) ? "_gmax" : "",
         (tryCelestial) ? "_celestial" : "") rescue nil
      ret = pbResolveBitmap(bitmapFileName)
      return ret if ret
    end
  end
  return nil
end


################################################################################
# SECTION 8 - FORM COMPATIBILITY
#===============================================================================
# Gets attributes for Gigantamax/Celestial forms.
#-------------------------------------------------------------------------------
class PokeBattle_Pokemon
  #-----------------------------------------------------------------------------
  # Form Name
  #-----------------------------------------------------------------------------
  def formName
    return pbGetMessage(MessageTypes::FormNames,self.fSpecies)
  end
  
  alias __mf_formName formName
  def formName
    v=MultipleForms.call("getFormName",self)
    return v if v!=nil
    return self.__mf_formName
  end
  #-----------------------------------------------------------------------------
  # Form Color
  #-----------------------------------------------------------------------------
  def formColor
    pbGetSpeciesData(self.fSpecies,formSimple,SpeciesColor)
  end
  
  alias __mf_formColor formColor
  def formColor
    v=MultipleForms.call("formColor",self)
    return v if v!=nil
    return self.__mf_formColor
  end
  #-----------------------------------------------------------------------------
  # Pokemon Kind
  #-----------------------------------------------------------------------------
  def kind
    return pbGetMessage(MessageTypes::Kinds,self.fSpecies)
  end
  
  alias __mf_kind kind
  def kind
    v=MultipleForms.call("kind",self)
    return v if v!=nil
    return self.__mf_kind
  end
  #-----------------------------------------------------------------------------
  # Habitat
  #-----------------------------------------------------------------------------
  def habitat
    return pbGetSpeciesData(self.fSpecies,formSimple,SpeciesHabitat)
  end
  
  alias __mf_habitat habitat
  def habitat
    v=MultipleForms.call("habitat",self)
    return v if v!=nil
    return self.__mf_habitat
  end
  #-----------------------------------------------------------------------------
  # Dex Entry
  #-----------------------------------------------------------------------------
  def dexEntry
    return pbGetMessage(MessageTypes::Entries,self.fSpecies)
  end
  
  alias __mf_dexEntry dexEntry
  def dexEntry
    v=MultipleForms.call("dexEntry",self)
    return v if v!=nil
    return self.__mf_dexEntry
  end
  #-----------------------------------------------------------------------------
  # Type 1
  #-----------------------------------------------------------------------------
  alias __mf_type1 type1
  def type1
    v=MultipleForms.call("type1",self)
    return v if v!=nil
    return self.__mf_type1
  end
  #-----------------------------------------------------------------------------
  # Type 2
  #-----------------------------------------------------------------------------
  alias __mf_type2 type2
  def type2
    v=MultipleForms.call("type2",self)
    return v if v!=nil
    return self.__mf_type2
  end
  #-----------------------------------------------------------------------------
  # Gender Rate
  #-----------------------------------------------------------------------------
  def genderRate
    pbGetSpeciesData(self.fSpecies,formSimple,SpeciesGenderRate)
  end
  
  alias __mf_genderRate genderRate
  def genderRate
    v=MultipleForms.call("genderRate",self)
    return v if v!=nil
    return self.__mf_genderRate
  end
  #-----------------------------------------------------------------------------
  # Egg Group
  #-----------------------------------------------------------------------------
  def eggGroup
    pbGetSpeciesData(self.fSpecies,formSimple,SpeciesCompatibility)
  end
  
  alias __mf_eggGroup eggGroup
  def eggGroup
    v=MultipleForms.call("eggGroup",self)
    return v if v!=nil
    return self.__mf_eggGroup
  end
  #-----------------------------------------------------------------------------
  # Ability List
  #-----------------------------------------------------------------------------
  alias __mf_getAbilityList getAbilityList
  def getAbilityList
    v=MultipleForms.call("getAbilityList",self)
    return v if v!=nil
    return self.__mf_getAbilityList
  end
  #-----------------------------------------------------------------------------
  # Move List
  #-----------------------------------------------------------------------------
  alias __mf_getMoveList getMoveList
  def getMoveList
    v=MultipleForms.call("getMoveList",self)
    return v if v!=nil
    return self.__mf_getMoveList
  end
  #-----------------------------------------------------------------------------
  # Base Stats
  #-----------------------------------------------------------------------------
  alias __mf_baseStats baseStats
  def baseStats
    v=MultipleForms.call("baseStats",self)
    return v if v!=nil
    return self.__mf_baseStats
  end
  #-----------------------------------------------------------------------------
  # Base Exp
  #-----------------------------------------------------------------------------
  alias __mf_baseExp baseExp
  def baseExp
    v=MultipleForms.call("baseExp",self)
    return v if v!=nil
    return self.__mf_baseExp
  end
  #-----------------------------------------------------------------------------
  # EV Yield
  #-----------------------------------------------------------------------------
  alias __mf_evYield evYield
  def evYield
    v=MultipleForms.call("evYield",self)
    return v if v!=nil
    return self.__mf_evYield
  end
  #-----------------------------------------------------------------------------
  # Growth Rate
  #-----------------------------------------------------------------------------
  alias __mf_growthrate growthrate
  def growthrate
    v=MultipleForms.call("growthrate",self)
    return v if v!=nil
    return self.__mf_growthrate
  end
  #-----------------------------------------------------------------------------
  # Rareness
  #-----------------------------------------------------------------------------
  def rareness
    pbGetSpeciesData(self.fSpecies,formSimple,SpeciesRareness)
  end
  
  alias __mf_rareness rareness
  def rareness
    v=MultipleForms.call("rareness",self)
    return v if v!=nil
    return self.__mf_rareness
  end
end


################################################################################
# SECTION 9 - NPC TRAINER COMPATIBILITY
#===============================================================================
# Allows Dynamax/Birthsign settings for NPC Trainer's Pokemon.
#-------------------------------------------------------------------------------
TPACEPKMN   = 15
TPDYNAMAX   = 16
TPGMAX      = 17
TPBIRTHSIGN = 18
TPLOSETEXT  = 19

TPMAXLENGTH = 18  # Ignores Lose Text parameter.

module TrainersMetadata
  InfoTypes = {
    "Items"     => [0,           "eEEEEEEE", :PBItems, :PBItems, :PBItems, :PBItems,
                                             :PBItems, :PBItems, :PBItems, :PBItems],
    "Pokemon"   => [TPSPECIES,   "ev", :PBSpecies,nil],   # Species, level
    "Item"      => [TPITEM,      "e", :PBItems],
    "Moves"     => [TPMOVES,     "eEEE", :PBMoves, :PBMoves, :PBMoves, :PBMoves],
    "Ability"   => [TPABILITY,   "u"],
    "Gender"    => [TPGENDER,    "e", { "M" => 0, "m" => 0, "Male" => 0, "male" => 0, "0" => 0,
                                        "F" => 1, "f" => 1, "Female" => 1, "female" => 1, "1" => 1 }],
    "Form"      => [TPFORM,      "u"],
    "Shiny"     => [TPSHINY,     "b"],
    "Nature"    => [TPNATURE,    "e", :PBNatures],
    "IV"        => [TPIV,        "uUUUUU"],
    "Happiness" => [TPHAPPINESS, "u"],
    "Name"      => [TPNAME,      "s"],
    "Shadow"    => [TPSHADOW,    "b"],
    "Ball"      => [TPBALL,      "u"],
    "EV"        => [TPEV,        "uUUUUU"],
    #---------------------------------------------------------------------------
    "TrainerAce"=> [TPACEPKMN,   "b"],                 # Trainer's Ace Pokemon (True/False) 
    "DynamaxLvl"=> [TPDYNAMAX,   "u"],                 # Dynamax levels (0-10)
    "Gigantamax"=> [TPGMAX,      "b"],                 # G-Max Factor (True/False)
    "Birthsign" => [TPBIRTHSIGN, "e", :PBBirthsigns],  # Birthsign
    #---------------------------------------------------------------------------
    "LoseText"  => [TPLOSETEXT,  "s"]
  }
end

#===============================================================================
# Adds Dynamax/Birthsign properties to load data for NPC Trainers.
#===============================================================================
def pbLoadTrainer(trainerid,trainername,partyid=0)
  if trainerid.is_a?(String) || trainerid.is_a?(Symbol)
    if !hasConst?(PBTrainers,trainerid)
      raise _INTL("Trainer type does not exist ({1}, {2}, ID {3})",trainerid,trainername,partyid)
    end
    trainerid = getID(PBTrainers,trainerid)
  end
  success = false
  items = []
  party = []
  opponent = nil
  trainers = pbLoadTrainersData
  for trainer in trainers
    thistrainerid = trainer[0]
    name          = trainer[1]
    thispartyid   = trainer[4]
    next if thistrainerid!=trainerid || name!=trainername || thispartyid!=partyid
    items = trainer[2].clone
    name = pbGetMessageFromHash(MessageTypes::TrainerNames,name)
    for i in RIVAL_NAMES
      next if !isConst?(trainerid,PBTrainers,i[0]) || !$game_variables[i[1]].is_a?(String)
      name = $game_variables[i[1]]
      break
    end
    loseText = pbGetMessageFromHash(MessageTypes::TrainerLoseText,trainer[5])
    opponent = PokeBattle_Trainer.new(name,thistrainerid)
    opponent.setForeignID($Trainer)
    # Load up each Pokémon in the trainer's party
    for poke in trainer[3]
      species = pbGetSpeciesFromFSpecies(poke[TPSPECIES])[0]
      level = poke[TPLEVEL]
      pokemon = pbNewPkmn(species,level,opponent,false)
      if poke[TPFORM]
        pokemon.forcedForm = poke[TPFORM] if MultipleForms.hasFunction?(pokemon.species,"getForm")
        pokemon.formSimple = poke[TPFORM]
      end
      pokemon.setItem(poke[TPITEM]) if poke[TPITEM]
      if poke[TPMOVES] && poke[TPMOVES].length>0
        for move in poke[TPMOVES]
          pokemon.pbLearnMove(move)
        end
      else
        pokemon.resetMoves
      end
      pokemon.setAbility(poke[TPABILITY] || 0)
      g = (poke[TPGENDER]) ? poke[TPGENDER] : (opponent.female?) ? 1 : 0
      pokemon.setGender(g)
      (poke[TPSHINY]) ? pokemon.makeShiny : pokemon.makeNotShiny
      n = (poke[TPNATURE]) ? poke[TPNATURE] : (pokemon.species+opponent.trainertype)%(PBNatures.maxValue+1)
      pokemon.setNature(n)
      for i in 0...6
        if poke[TPIV] && poke[TPIV].length>0
          pokemon.iv[i] = (i<poke[TPIV].length) ? poke[TPIV][i] : poke[TPIV][0]
        else
          pokemon.iv[i] = [level/2,PokeBattle_Pokemon::IV_STAT_LIMIT].min
        end
        if poke[TPEV] && poke[TPEV].length>0
          pokemon.ev[i] = (i<poke[TPEV].length) ? poke[TPEV][i] : poke[TPEV][0]
        else
          pokemon.ev[i] = [level*3/2,PokeBattle_Pokemon::EV_LIMIT/6].min
        end
      end
      pokemon.happiness = poke[TPHAPPINESS] if poke[TPHAPPINESS]
      pokemon.name = poke[TPNAME] if poke[TPNAME] && poke[TPNAME]!=""
      if poke[TPSHADOW]   # if this is a Shadow Pokémon
        pokemon.makeShadow rescue nil
        pokemon.pbUpdateShadowMoves(true) rescue nil
        pokemon.makeNotShiny
      end
      pokemon.ballused = poke[TPBALL] if poke[TPBALL]
      #-------------------------------------------------------------------------
      # Dynamax/Birthsign properties.
      #-------------------------------------------------------------------------
      # Trainer Ace
      (poke[TPACEPKMN]) ? pokemon.makeAcePkmn : pokemon.notAcePkmn
      # Dynamax
      if pbDynamaxInstalled?
        pokemon.setDynamaxLvl(poke[TPDYNAMAX] || 0)
        (poke[TPGMAX]) ? pokemon.giveGMaxFactor : pokemon.removeGMaxFactor
      end
      # Birthsigns
      if pbZodiacInstalled?
        pokemon.setBirthsign(poke[TPBIRTHSIGN] || 0)
      end
      #-------------------------------------------------------------------------
      pokemon.calcStats
      pokemon.hp = pokemon.totalhp
      party.push(pokemon)
    end
    success = true
    break
  end
  return success ? [opponent,items,party,loseText] : nil
end

#===============================================================================
# Gets the list of birthsigns to apply to NPC Trainer's data.
#===============================================================================
module BirthsignProperty
  def self.set(_settingname,_oldsetting)
    commands = []
    (PBBirthsigns.getCount).times do |i|
      commands.push(PBBirthsigns.getName(i))
    end
    ret = pbShowCommands(nil,commands,-1)
    return (ret>=0) ? ret : nil
  end

  def self.defaultValue
    return nil
  end

  def self.format(value)
    return (value) ? getConstantName(PBBirthsigns,value) : "-"
  end
end

#===============================================================================
# Defines Ace Pokemon for NPC Trainers.
#===============================================================================
class PokeBattle_Pokemon
  attr_accessor(:acepkmn)
  
  def trainerAce?
    return @acepkmn
  end
  
  def makeAcePkmn
    @acepkmn = true
  end
  
  def notAcePkmn  
    @acepkmn = false
  end
  
  alias ace_initialize initialize  
  def initialize(*args)
    ace_initialize(*args)
    @acepkmn = false
  end
end

#===============================================================================
# Assigns Dynamax/Birthsign properties to NPC Trainers through in-game editor.
#===============================================================================
module TrainerPokemonProperty
  def self.set(settingname,initsetting)
    initsetting = [0,10] if !initsetting
    oldsetting = []
    for i in 0...TPMAXLENGTH
      if i==TPMOVES
        for j in 0...4
          oldsetting.push((initsetting[TPMOVES]) ? initsetting[TPMOVES][j] : nil)
        end
      else
        oldsetting.push(initsetting[i])
      end
    end
    mLevel = PBExperience.maxLevel
    properties = [
       [_INTL("Species"),SpeciesProperty,_INTL("Species of the Pokémon.")],
       [_INTL("Level"),NonzeroLimitProperty.new(mLevel),_INTL("Level of the Pokémon (1-{1}).",mLevel)],
       [_INTL("Held item"),ItemProperty,_INTL("Item held by the Pokémon.")],
       [_INTL("Move 1"),MoveProperty2.new(oldsetting),_INTL("First move. Leave all moves blank (use Z key) to give it a wild moveset.")],
       [_INTL("Move 2"),MoveProperty2.new(oldsetting),_INTL("Second move. Leave all moves blank (use Z key) to give it a wild moveset.")],
       [_INTL("Move 3"),MoveProperty2.new(oldsetting),_INTL("Third move. Leave all moves blank (use Z key) to give it a wild moveset.")],
       [_INTL("Move 4"),MoveProperty2.new(oldsetting),_INTL("Fourth move. Leave all moves blank (use Z key) to give it a wild moveset.")],
       [_INTL("Ability"),LimitProperty2.new(5),_INTL("Ability flag. 0=first ability, 1=second ability, 2-5=hidden ability.")],
       [_INTL("Gender"),GenderProperty.new,_INTL("Gender of the Pokémon.")],
       [_INTL("Form"),LimitProperty2.new(999),_INTL("Form of the Pokémon.")],
       [_INTL("Shiny"),BooleanProperty2,_INTL("If set to true, the Pokémon is a different-colored Pokémon.")],
       [_INTL("Nature"),NatureProperty,_INTL("Nature of the Pokémon.")],
       [_INTL("IVs"),IVsProperty.new(PokeBattle_Pokemon::IV_STAT_LIMIT),_INTL("Individual values for each of the Pokémon's stats.")],
       [_INTL("Happiness"),LimitProperty2.new(255),_INTL("Happiness of the Pokémon (0-255).")],
       [_INTL("Nickname"),StringProperty,_INTL("Name of the Pokémon.")],
       [_INTL("Shadow"),BooleanProperty2,_INTL("If set to true, the Pokémon is a Shadow Pokémon.")],
       [_INTL("Ball"),BallProperty.new(oldsetting),_INTL("The kind of Poké Ball the Pokémon is kept in.")],
       [_INTL("EVs"),EVsProperty.new(PokeBattle_Pokemon::EV_STAT_LIMIT),_INTL("Effort values for each of the Pokémon's stats.")],
       # Trainer Ace
       [_INTL("Trainer Ace"),BooleanProperty2,_INTL("If set to true, this is the trainer's ace Pokémon.")]
    ]
    #---------------------------------------------------------------------------
    # Dynamax/Birthsign properties.
    #---------------------------------------------------------------------------
    # Dynamax
    if pbDynamaxInstalled?
      properties.push([_INTL("Dynamax Lv."),LimitProperty2.new(10),_INTL("Dynamax level of the Pokémon (1-10).")],
                      [_INTL("Gigantamax"),BooleanProperty2,_INTL("If set to true, the Pokémon has Gigantamax Factor.")])
    end
    # Birthsigns
    if pbZodiacInstalled?
      properties.push([_INTL("Birthsign"),BirthsignProperty,_INTL("Birthsign of the Pokémon.")])
    end
    #---------------------------------------------------------------------------
    pbPropertyList(settingname,oldsetting,properties,false)
    return nil if !oldsetting[TPSPECIES] || oldsetting[TPSPECIES]==0
    ret = []
    moves = []
    for i in 0...oldsetting.length
      if i>=TPMOVES && i<TPMOVES+4
        ret.push(nil) if i==TPMOVES
        moves.push(oldsetting[i])
      else
        ret.push(oldsetting[i])
      end
    end
    moves.compact!
    ret[TPMOVES] = moves if moves.length>0
    ret.pop while ret.last.nil? && ret.size>0
    return ret
  end
end

#===============================================================================
# Saves Birthsign/Dynamax properties for NPC Trainer's Pokemon.
#===============================================================================
def pbSaveTrainerBattles
  data = pbLoadTrainersData
  return if !data
  File.open("PBS/trainers.txt","wb") { |f|
    f.write(0xEF.chr)
    f.write(0xBB.chr)
    f.write(0xBF.chr)
    f.write("\# "+_INTL("See the documentation on the wiki to learn how to edit this file."))
    f.write("\r\n")
    for trainer in data
      trtypename = getConstantName(PBTrainers,trainer[0]) rescue pbGetTrainerConst(trainer[0]) rescue nil
      next if !trtypename
      f.write("\#-------------------------------\r\n")
      # Section
      trainername = trainer[1] ? trainer[1].gsub(/,/,";") : "???"
      if trainer[4]==0
        f.write(sprintf("[%s,%s]\r\n",trtypename,trainername))
      else
        f.write(sprintf("[%s,%s,%d]\r\n",trtypename,trainername,trainer[4]))
      end
      # Trainer's items
      if trainer[2] && trainer[2].length>0
        itemstring = ""
        for i in 0...trainer[2].length
          itemname = getConstantName(PBItems,trainer[2][i]) rescue pbGetItemConst(trainer[2][i]) rescue nil
          next if !itemname
          itemstring.concat(",") if i>0
          itemstring.concat(itemname)
        end
        f.write(sprintf("Items = %s\r\n",itemstring)) if itemstring!=""
      end
      # Lose texts
      if trainer[5] && trainer[5]!=""
        f.write(sprintf("LoseText = %s\r\n",csvQuoteAlways(trainer[5])))
      end
      # Pokémon
      for poke in trainer[3]
        species = getConstantName(PBSpecies,poke[TPSPECIES]) rescue pbGetSpeciesConst(poke[TPSPECIES]) rescue ""
        f.write(sprintf("Pokemon = %s,%d\r\n",species,poke[TPLEVEL]))
        if poke[TPNAME] && poke[TPNAME]!=""
          f.write(sprintf("    Name = %s\r\n",poke[TPNAME]))
        end
        if poke[TPFORM]
          f.write(sprintf("    Form = %d\r\n",poke[TPFORM]))
        end
        if poke[TPGENDER]
          f.write(sprintf("    Gender = %s\r\n",(poke[TPGENDER]==1) ? "female" : "male"))
        end
        if poke[TPSHINY]
          f.write("    Shiny = yes\r\n")
        end
        if poke[TPSHADOW]
          f.write("    Shadow = yes\r\n")
        end
        if poke[TPMOVES] && poke[TPMOVES].length>0
          movestring = ""
          for i in 0...poke[TPMOVES].length
            movename = getConstantName(PBMoves,poke[TPMOVES][i]) rescue pbGetMoveConst(poke[TPMOVES][i]) rescue nil
            next if !movename
            movestring.concat(",") if i>0
            movestring.concat(movename)
          end
          f.write(sprintf("    Moves = %s\r\n",movestring)) if movestring!=""
        end
        if poke[TPABILITY]
          f.write(sprintf("    Ability = %d\r\n",poke[TPABILITY]))
        end
        if poke[TPITEM] && poke[TPITEM]>0
          item = getConstantName(PBItems,poke[TPITEM]) rescue pbGetItemConst(poke[TPITEM]) rescue nil
          f.write(sprintf("    Item = %s\r\n",item)) if item
        end
        if poke[TPNATURE]
          nature = getConstantName(PBNatures,poke[TPNATURE]) rescue nil
          f.write(sprintf("    Nature = %s\r\n",nature)) if nature
        end
        if poke[TPIV] && poke[TPIV].length>0
          f.write(sprintf("    IV = %d",poke[TPIV][0]))
          if poke[TPIV].length>1
            for i in 1...6
              f.write(sprintf(",%d",(i<poke[TPIV].length) ? poke[TPIV][i] : poke[TPIV][0]))
            end
          end
          f.write("\r\n")
        end
        if poke[TPEV] && poke[TPEV].length>0
          f.write(sprintf("    EV = %d",poke[TPEV][0]))
          if poke[TPEV].length>1
            for i in 1...6
              f.write(sprintf(",%d",(i<poke[TPEV].length) ? poke[TPEV][i] : poke[TPEV][0]))
            end
          end
          f.write("\r\n")
        end
        if poke[TPHAPPINESS]
          f.write(sprintf("    Happiness = %d\r\n",poke[TPHAPPINESS]))
        end
        if poke[TPBALL]
          f.write(sprintf("    Ball = %d\r\n",poke[TPBALL]))
        end
        #-----------------------------------------------------------------------
        # Dynamax/Birthsign properties.
        #-----------------------------------------------------------------------
        # Trainer Ace
        if poke[TPACEPKMN]
          f.write("    TrainerAce = yes\r\n")
        end
        # Dynamax
        if pbDynamaxInstalled?
          if poke[TPDYNAMAX]
            f.write(sprintf("    DynamaxLvl = %d\r\n",poke[TPDYNAMAX]))
          end
          if poke[TPGMAX]
            f.write("    Gigantamax = yes\r\n")
          end
        end
        # Birthsigns
        if pbZodiacInstalled?
          if poke[TPBIRTHSIGN]
            sign = getConstantName(PBBirthsigns,poke[TPBIRTHSIGN]) rescue nil
            f.write(sprintf("    Birthsign = %s\r\n",sign)) if sign
          end
        end
        #-----------------------------------------------------------------------
      end
    end
  }
end

#===============================================================================
# Compile individual trainers
#===============================================================================
def pbCompileTrainers
  trainer_info_types = TrainersMetadata::InfoTypes
  mLevel = PBExperience.maxLevel
  trainerindex    = -1
  trainers        = []
  trainernames    = []
  trainerlosetext = []
  pokemonindex    = -2
  oldcompilerline   = 0
  oldcompilerlength = 0
  pbCompilerEachCommentedLine("PBS/trainers.txt") { |line,lineno|
    if line[/^\s*\[\s*(.+)\s*\]\s*$/]
      # Section [trainertype,trainername] or [trainertype,trainername,partyid]
      if oldcompilerline>0
        raise _INTL("Previous trainer not defined with as many Pokémon as expected.\r\n{1}",FileLineData.linereport)
      end
      if pokemonindex==-1
        raise _INTL("Started new trainer while previous trainer has no Pokémon.\r\n{1}",FileLineData.linereport)
      end
      section = pbGetCsvRecord($~[1],lineno,[0,"esU",PBTrainers])
      trainerindex += 1
      trainertype = section[0]
      trainername = section[1]
      partyid     = section[2] || 0
      trainers[trainerindex] = [trainertype,trainername,[],[],partyid,nil]
      trainernames[trainerindex] = trainername
      pokemonindex = -1
    elsif line[/^\s*(\w+)\s*=\s*(.*)$/]
      # XXX=YYY lines
      if trainerindex<0
        raise _INTL("Expected a section at the beginning of the file.\r\n{1}",FileLineData.linereport)
      end
      if oldcompilerline>0
        raise _INTL("Previous trainer not defined with as many Pokémon as expected.\r\n{1}",FileLineData.linereport)
      end
      settingname = $~[1]
      schema = trainer_info_types[settingname]
      next if !schema
      record = pbGetCsvRecord($~[2],lineno,schema)
      # Error checking in XXX=YYY lines
      case settingname
      when "Pokemon"
        if record[1]>mLevel
          raise _INTL("Bad level: {1} (must be 1-{2})\r\n{3}",record[1],mLevel,FileLineData.linereport)
        end
      when "Moves"
        record = [record] if record.is_a?(Integer)
        record.compact!
      when "Ability"
        if record>5
          raise _INTL("Bad ability flag: {1} (must be 0 or 1 or 2-5).\r\n{2}",record,FileLineData.linereport)
        end
      when "IV"
        record = [record] if record.is_a?(Integer)
        record.compact!
        for i in record
          next if i<=PokeBattle_Pokemon::IV_STAT_LIMIT
          raise _INTL("Bad IV: {1} (must be 0-{2})\r\n{3}",i,PokeBattle_Pokemon::IV_STAT_LIMIT,FileLineData.linereport)
        end
      when "EV"
        record = [record] if record.is_a?(Integer)
        record.compact!
        for i in record
          next if i<=PokeBattle_Pokemon::EV_STAT_LIMIT
          raise _INTL("Bad EV: {1} (must be 0-{2})\r\n{3}",i,PokeBattle_Pokemon::EV_STAT_LIMIT,FileLineData.linereport)
        end
        evtotal = 0
        for i in 0...6
          evtotal += (i<record.length) ? record[i] : record[0]
        end
        if evtotal>PokeBattle_Pokemon::EV_LIMIT
          raise _INTL("Total EVs are greater than allowed ({1})\r\n{2}",PokeBattle_Pokemon::EV_LIMIT,FileLineData.linereport)
        end
      when "Happiness"
        if record>255
          raise _INTL("Bad happiness: {1} (must be 0-255)\r\n{2}",record,FileLineData.linereport)
        end
      when "Name"
        if record.length>PokeBattle_Pokemon::MAX_POKEMON_NAME_SIZE
          raise _INTL("Bad nickname: {1} (must be 1-{2} characters)\r\n{3}",record,PokeBattle_Pokemon::MAX_POKEMON_NAME_SIZE,FileLineData.linereport)
        end
      #-------------------------------------------------------------------------
      when "DynamaxLvl"
        if record>10
          raise _INTL("Bad Dynamax Level: {1} (must be 0-10).\r\n{2}",record,FileLineData.linereport)
        end
      end
      #-------------------------------------------------------------------------
      # Record XXX=YYY setting
      case settingname
      when "Items"   # Items in the trainer's Bag, not the held item
        record = [record] if record.is_a?(Integer)
        record.compact!
        trainers[trainerindex][2] = record
      when "LoseText"
        trainerlosetext[trainerindex] = record
        trainers[trainerindex][5] = record
      when "Pokemon"
        pokemonindex += 1
        trainers[trainerindex][3][pokemonindex] = []
        trainers[trainerindex][3][pokemonindex][TPSPECIES] = record[0]
        trainers[trainerindex][3][pokemonindex][TPLEVEL]   = record[1]
      else
        if pokemonindex<0
          raise _INTL("Pokémon hasn't been defined yet!\r\n{1}",FileLineData.linereport)
        end
        trainers[trainerindex][3][pokemonindex][schema[0]] = record
      end
    else
      # Old compiler - backwards compatibility is SUCH fun!
      if pokemonindex==-1 && oldcompilerline==0
        raise _INTL("Unexpected line format, started new trainer while previous trainer has no Pokémon\r\n{1}",FileLineData.linereport)
      end
      if oldcompilerline==0   # Started an old trainer section
        oldcompilerlength = 3
        oldcompilerline   = 0
        trainerindex += 1
        trainers[trainerindex] = [0,"",[],[],0]
        pokemonindex = -1
      end
      oldcompilerline += 1
      case oldcompilerline
      when 1   # Trainer type
        record = pbGetCsvRecord(line,lineno,[0,"e",PBTrainers])
        trainers[trainerindex][0] = record
      when 2   # Trainer name, version number
        record = pbGetCsvRecord(line,lineno,[0,"sU"])
        record = [record] if record.is_a?(Integer)
        trainers[trainerindex][1] = record[0]
        trainernames[trainerindex] = record[0]
        trainers[trainerindex][4] = record[1] if record[1]
      when 3   # Number of Pokémon, items
        record = pbGetCsvRecord(line,lineno,[0,"vEEEEEEEE",nil,PBItems,PBItems,
                                PBItems,PBItems,PBItems,PBItems,PBItems,PBItems])
        record = [record] if record.is_a?(Integer)
        record.compact!
        oldcompilerlength += record[0]
        record.shift
        trainers[trainerindex][2] = record if record
      else   # Pokémon lines
        pokemonindex += 1
        trainers[trainerindex][3][pokemonindex] = []
        record = pbGetCsvRecord(line,lineno,
           [0,"evEEEEEUEUBEUUSBUBUBU",PBSpecies,nil, PBItems,PBMoves,PBMoves,PBMoves,
                                  PBMoves,nil,{"M"=>0,"m"=>0,"Male"=>0,"male"=>0,
                                  "0"=>0,"F"=>1,"f"=>1,"Female"=>1,"female"=>1,
                                  "1"=>1},nil,nil,PBNatures,nil,nil,nil,nil,nil,
                                  nil,nil,nil,nil]) # TrainerAce, DynamaxLvl, G-Max, Birthsigns
        # Error checking (the +3 is for properties after the four moves)
        for i in 0...record.length
          next if record[i]==nil
          case i
          when TPLEVEL
            if record[i]>mLevel
              raise _INTL("Bad level: {1} (must be 1-{2})\r\n{3}",record[i],mLevel,FileLineData.linereport)
            end
          when TPABILITY+3
            if record[i]>5
              raise _INTL("Bad ability flag: {1} (must be 0 or 1 or 2-5)\r\n{2}",record[i],FileLineData.linereport)
            end
          when TPIV+3
            if record[i]>31
              raise _INTL("Bad IV: {1} (must be 0-31)\r\n{2}",record[i],FileLineData.linereport)
            end
            record[i] = [record[i]]
          when TPEV+3
            if record[i]>PokeBattle_Pokemon::EV_STAT_LIMIT
              raise _INTL("Bad EV: {1} (must be 0-{2})\r\n{3}",record[i],PokeBattle_Pokemon::EV_STAT_LIMIT,FileLineData.linereport)
            end
            record[i] = [record[i]]
          when TPHAPPINESS+3
            if record[i]>255
              raise _INTL("Bad happiness: {1} (must be 0-255)\r\n{2}",record[i],FileLineData.linereport)
            end
          when TPNAME+3
            if record[i].length>PokeBattle_Pokemon::MAX_POKEMON_NAME_SIZE
              raise _INTL("Bad nickname: {1} (must be 1-{2} characters)\r\n{3}",record[i],PokeBattle_Pokemon::MAX_POKEMON_NAME_SIZE,FileLineData.linereport)
            end
          #---------------------------------------------------------------------
          when TPDYNAMAX+3
            if record[i]>10
              raise _INTL("Bad Dynamax Level: {1} (must be 0-10)\r\n{2}",record[i],FileLineData.linereport)
            end
          end
          #---------------------------------------------------------------------
        end
        # Write data to trainer array
        for i in 0...record.length
          next if record[i]==nil
          if i>=TPMOVES && i<TPMOVES+4
            if !trainers[trainerindex][3][pokemonindex][TPMOVES]
              trainers[trainerindex][3][pokemonindex][TPMOVES] = []
            end
            trainers[trainerindex][3][pokemonindex][TPMOVES].push(record[i])
          else
            d = (i>=TPMOVES+4) ? i-3 : i
            trainers[trainerindex][3][pokemonindex][d] = record[i]
          end
        end
      end
      oldcompilerline = 0 if oldcompilerline>=oldcompilerlength
    end
  }
  save_data(trainers,"Data/trainers.dat")
  MessageTypes.setMessagesAsHash(MessageTypes::TrainerNames,trainernames)
  MessageTypes.setMessagesAsHash(MessageTypes::TrainerLoseText,trainerlosetext)
end

################################################################################
# SECTION 10 - Ultra Burst compatibility
#===============================================================================
# Defines empty functions for Ultra Burst. 
#-------------------------------------------------------------------------------
class PokeBattle_AI
  def pbEnemyShouldUltraBurst?(idxBattler)
    return false 
  end 
end 
class PokeBattle_Battle
  alias _ub_initialize initialize  
  def initialize(*args)
    _ub_initialize(*args)
    @ultraBurst        = [
     [-1] * (@player ? @player.length : 1),
     [-1] * (@opponent ? @opponent.length : 1)
    ]
  end 
  def pbCanUltraBurst?(idxBattler)
    return false
  end 
  
  def pbRegisterUltraBurst(idxBattler)
    return 
  end 
  def pbUnregisterUltraBurst(idxBattler)
    return 
  end 
  def pbToggleRegisteredUltraBurst(idxBattler)
    return 
  end 
  def pbRegisteredUltraBurst?(idxBattler)
    return false 
  end 
  
  def pbAttackPhaseZMoves
     # Prepare for Z Moves
    @battlers.each_with_index do |b,i|
      next if !b || b.fainted?
      next if @choices[i][0]!=:UseMove
      side=(opposes?(i)) ? 1 : 0
      owner=pbGetOwnerIndexFromBattlerIndex(i)
      @choices[i][2].zmove=(@zMove[side][owner]==i)
    end
  end 
  
  def pbAttackPhaseUltraBurst
  end 
end 
class PokeBattle_Pokemon
  def makeUnUltra
  end 
end 

class PokeBattle_Battler
  def ultra?
    return false 
  end 
end