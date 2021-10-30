class PokeBattle_ZMove < PokeBattle_Move
  attr_reader(:thismove)
  attr_reader(:oldmove)
  attr_reader(:status)
  attr_reader(:oldname)
################################################################################
# Creating a z move
################################################################################
  def initialize(battle,move,pbmove)
    # move is the old move; instance of PokeBattle_Move
    # pbmove is the PBMove of the new move.
    super(battle, pbmove)
    
    @status     = !(move.physicalMove?(move.type) || move.specialMove?(move.type))
    @oldmove    = move
    @oldname    = move.name
    @is_zmove   = true 
    
    if @status 
      # @id         = move.id
      @name       = "Z-" + move.name
      # @function   = move.function
      # @flags      = move.flags
    end 
    
    @baseDamage = pbZMoveBaseDamage(move)
    @thismove   = self
  end
  
  def pbZMoveBaseDamage(oldmove)
    if @status
      # Status moves remain status. 
      return 0
    elsif @baseDamage != 1
      # Then the base damage is given in the moves.txt PBS file. 
      return @baseDamage
    end 
    
    # Specific values for specific moves: 
    case @oldmove.id
    when getID(PBMoves,:MEGADRAIN)
      return 120
    when getID(PBMoves,:WEATHERBALL)  
      return 160
    when getID(PBMoves,:HEX)
      return 160
    when getID(PBMoves,:GEARGRIND)  
      return 180
    when getID(PBMoves,:VCREATE)  
      return 220
    when getID(PBMoves,:FLYINGPRESS)
      return 170
    when getID(PBMoves,:COREENFORCER)
      return 140
    end 
    
    # This is for non-specific moves. 
    check=@oldmove.baseDamage
    if check<56
      return 100
    elsif check<66
      return 120
    elsif check<76
      return 140
    elsif check<86
      return 160
    elsif check<96
      return 175
    elsif check<101
      return 180
    elsif check<111
      return 185
    elsif check<126
      return 190
    elsif check<131
      return 195
    elsif check>139
      return 200
    end
  end
  
  
  def pbUse(battler, simplechoice=false)
    battler.pbBeginTurn(self)
    if !@status
      @battle.pbDisplayBrief(_INTL("{1} unleashed its full force Z-Move!",battler.pbThis))
    end    
    zchoice=@battle.choices[battler.index] #[0,0,move,move.target]
    if simplechoice!=false
      zchoice=simplechoice
    end    
    ztargets=battler.pbFindTargets(zchoice,self,battler)
    if ztargets.length==0
      if @target==PBTargets::NearOther ||
         @target==PBTargets::RandomNearFoe ||
         @target==PBTargets::AllNearFoes ||
         @target==PBTargets::AllNearOthers ||
         @target==PBTargets::NearAlly ||
         @target==PBTargets::UserOrNearAlly ||
         @target==PBTargets::NearFoe ||
         @target==PBTargets::UserAndAllies 
        @battle.pbDisplay(_INTL("But there was no target..."))
      else
        #selftarget status moves here
        pbZStatus(@oldmove.id,battler)        
        zchoice[2].name = @name
        battler.pbUseMove(zchoice)
        @oldmove.name = @oldname
      end      
    else
      if @status
        #targeted status Z's here
        pbZStatus(@oldmove.id,battler)
        zchoice[2].name = @name
        battler.pbUseMove(zchoice)
        @oldmove.name = @oldname
      else
        zchoice[2] = self
        battler.pbUseMove(zchoice)
        battler.pbReducePPOther(@oldmove)
      end
    end
  end 
  
  
  def PokeBattle_ZMove.pbFromOldMoveAndCrystal(battle,battler,move,crystal)
    # Load the Z-move data
    zmovedata = pbGetZMoveDataIfCompatible(battler.pokemon, crystal, move)
    pbmove = nil
    if !zmovedata
      # We assume that the Z-Move is called only if it is valid. 
      # If zmovedata is empty, then it is a status move.
      # Z-status move keep the same effect. 
      pbmove = PBMove.new(move.id)
      pbmove.pp = 1 
      return PokeBattle_ZMove.new(battle,move,pbmove)
    end 
    
    pbmove = PBMove.new(zmovedata[PBZMove::ZMOVE])
    moveFunction = pbGetMoveData(pbmove.id,MOVE_FUNCTION_CODE) || "Z000"
    className = sprintf("PokeBattle_Move_%s",moveFunction)
    
    if Object.const_defined?(className)
      return Object.const_get(className).new(battle,move,pbmove)
    end
    return PokeBattle_ZMove.new(battle,move,pbmove)
  end
  
################################################################################
# PokeBattle_Move Features needed for move use
################################################################################  
  def specialMove?(type=nil)
    return @oldmove.specialMove?(type)
  end
  
  def physicalMove?(type=nil)  
    return @oldmove.physicalMove?(type)
  end  
  
  def pbModifyDamage(damagemult,attacker,opponent)
    if opponent.pbOwnSide.effects[PBEffects::QuickGuard] || 
        opponent.effects[PBEffects::Protect] || 
        opponent.effects[PBEffects::KingsShield] ||
        opponent.effects[PBEffects::SpikyShield] ||
        opponent.effects[PBEffects::BanefulBunker] ||
        opponent.effects[PBEffects::MatBlock]
      @battle.pbDisplay(_INTL("{1} couldn't fully protected itself!",opponent.pbThis))
      return damagemult/4
    else      
      return damagemult
    end    
  end    
  
################################################################################
# PokeBattle_ActualScene Feature for playing animation (based on common anims)
################################################################################    
  
  # def pbShowAnimation(movename,user,target,hitnum=0,alltargets=nil,showanimation=true)
    # animname=movename.delete(" ").delete("-").upcase
    # animations=load_data("Data/PkmnAnimations.rxdata")
    # for i in 0...animations.length
      # if @battle.pbOwnedByPlayer?(user.index)
        # if animations[i] && animations[i].name=="ZMove:"+animname && showanimation
          # @battle.scene.pbAnimationCore(animations[i],user,(target!=nil) ? target : user)
          # return
        # end
      # else
        # if animations[i] && animations[i].name=="OppZMove:"+animname && showanimation
          # @battle.scene.pbAnimationCore(animations[i],target,(user!=nil) ? user : target)
          # return
        # elsif animations[i] && animations[i].name=="ZMove:"+animname && showanimation
          # @battle.scene.pbAnimationCore(animations[i],user,(target!=nil) ? target : user)
          # return        
        # end   
      # end 
    # end
  # end  
  
################################################################################
# Z Status Effect check
################################################################################  
  
  def pbZStatus(move,attacker)
    atk1 =   [getID(PBMoves,:BULKUP),getID(PBMoves,:HONECLAWS),getID(PBMoves,:HOWL),getID(PBMoves,:LASERFOCUS),getID(PBMoves,:LEER),getID(PBMoves,:MEDITATE),getID(PBMoves,:ODORSLEUTH),getID(PBMoves,:POWERTRICK),getID(PBMoves,:ROTOTILLER),getID(PBMoves,:SCREECH),getID(PBMoves,:SHARPEN),getID(PBMoves,:TAILWHIP),getID(PBMoves,:TAUNT),getID(PBMoves,:TOPSYTURVY),getID(PBMoves,:WILLOWISP),getID(PBMoves,:WORKUP)]
    atk2 =   [getID(PBMoves,:MIRRORMOVE)]
    atk3 =   [getID(PBMoves,:SPLASH)]
    def1 =   [getID(PBMoves,:AQUARING),getID(PBMoves,:BABYDOLLEYES),getID(PBMoves,:BANEFULBUNKER),getID(PBMoves,:BLOCK),getID(PBMoves,:CHARM),getID(PBMoves,:DEFENDORDER),getID(PBMoves,:FAIRYLOCK),getID(PBMoves,:FEATHERDANCE),getID(PBMoves,:FLOWERSHIELD),getID(PBMoves,:GRASSYTERRAIN),getID(PBMoves,:GROWL),getID(PBMoves,:HARDEN),getID(PBMoves,:MATBLOCK),getID(PBMoves,:NOBLEROAR),getID(PBMoves,:PAINSPLIT),getID(PBMoves,:PLAYNICE),getID(PBMoves,:POISONGAS),getID(PBMoves,:POISONPOWDER),getID(PBMoves,:QUICKGUARD),getID(PBMoves,:REFLECT),getID(PBMoves,:ROAR),getID(PBMoves,:SPIDERWEB),getID(PBMoves,:SPIKES),getID(PBMoves,:SPIKYSHIELD),getID(PBMoves,:STEALTHROCK),getID(PBMoves,:STRENGTHSAP),getID(PBMoves,:TEARFULLOOK),getID(PBMoves,:TICKLE),getID(PBMoves,:TORMENT),getID(PBMoves,:TOXIC),getID(PBMoves,:TOXICSPIKES),getID(PBMoves,:VENOMDRENCH),getID(PBMoves,:WIDEGUARD),getID(PBMoves,:WITHDRAW)]
    def2 =   []
    def3 =   []
    spatk1 = [getID(PBMoves,:CONFUSERAY),getID(PBMoves,:ELECTRIFY),getID(PBMoves,:EMBARGO),getID(PBMoves,:FAKETEARS),getID(PBMoves,:GEARUP),getID(PBMoves,:GRAVITY),getID(PBMoves,:GROWTH),getID(PBMoves,:INSTRUCT),getID(PBMoves,:IONDELUGE),getID(PBMoves,:METALSOUND),getID(PBMoves,:MINDREADER),getID(PBMoves,:MIRACLEEYE),getID(PBMoves,:NIGHTMARE),getID(PBMoves,:PSYCHICTERRAIN),getID(PBMoves,:REFLECTTYPE),getID(PBMoves,:SIMPLEBEAM),getID(PBMoves,:SOAK),getID(PBMoves,:SWEETKISS),getID(PBMoves,:TEETERDANCE),getID(PBMoves,:TELEKINESIS)]
    spatk2 = [getID(PBMoves,:HEALBLOCK),getID(PBMoves,:PSYCHOSHIFT)]
    spatk3 = []
    spdef1 = [getID(PBMoves,:CHARGE),getID(PBMoves,:CONFIDE),getID(PBMoves,:COSMICPOWER),getID(PBMoves,:CRAFTYSHIELD),getID(PBMoves,:EERIEIMPULSE),getID(PBMoves,:ENTRAINMENT),getID(PBMoves,:FLATTER),getID(PBMoves,:GLARE),getID(PBMoves,:INGRAIN),getID(PBMoves,:LIGHTSCREEN),getID(PBMoves,:MAGICROOM),getID(PBMoves,:MAGNETICFLUX),getID(PBMoves,:MEANLOOK),getID(PBMoves,:MISTYTERRAIN),getID(PBMoves,:MUDSPORT),getID(PBMoves,:SPOTLIGHT),getID(PBMoves,:STUNSPORE),getID(PBMoves,:THUNDERWAVE),getID(PBMoves,:WATERSPORT),getID(PBMoves,:WHIRLWIND),getID(PBMoves,:WISH),getID(PBMoves,:WONDERROOM)]
    spdef2 = [getID(PBMoves,:AROMATICMIST),getID(PBMoves,:CAPTIVATE),getID(PBMoves,:IMPRISON),getID(PBMoves,:MAGICCOAT),getID(PBMoves,:POWDER)]
    spdef3 = []
    speed1 = [getID(PBMoves,:AFTERYOU),getID(PBMoves,:AURORAVEIL),getID(PBMoves,:ELECTRICTERRAIN),getID(PBMoves,:ENCORE),getID(PBMoves,:GASTROACID),getID(PBMoves,:GRASSWHISTLE),getID(PBMoves,:GUARDSPLIT),getID(PBMoves,:GUARDSWAP),getID(PBMoves,:HAIL),getID(PBMoves,:HYPNOSIS),getID(PBMoves,:LOCKON),getID(PBMoves,:LOVELYKISS),getID(PBMoves,:POWERSPLIT),getID(PBMoves,:POWERSWAP),getID(PBMoves,:QUASH),getID(PBMoves,:RAINDANCE),getID(PBMoves,:ROLEPLAY),getID(PBMoves,:SAFEGUARD),getID(PBMoves,:SANDSTORM),getID(PBMoves,:SCARYFACE),getID(PBMoves,:SING),getID(PBMoves,:SKILLSWAP),getID(PBMoves,:SLEEPPOWDER),getID(PBMoves,:SPEEDSWAP),getID(PBMoves,:STICKYWEB),getID(PBMoves,:STRINGSHOT),getID(PBMoves,:SUNNYDAY),getID(PBMoves,:SUPERSONIC),getID(PBMoves,:TOXICTHREAD),getID(PBMoves,:WORRYSEED),getID(PBMoves,:YAWN)]
    speed2 = [getID(PBMoves,:ALLYSWITCH),getID(PBMoves,:BESTOW),getID(PBMoves,:MEFIRST),getID(PBMoves,:RECYCLE),getID(PBMoves,:SNATCH),getID(PBMoves,:SWITCHEROO),getID(PBMoves,:TRICK)]
    speed3 = []
    acc1   = [getID(PBMoves,:COPYCAT),getID(PBMoves,:DEFENSECURL),getID(PBMoves,:DEFOG),getID(PBMoves,:FOCUSENERGY),getID(PBMoves,:MIMIC),getID(PBMoves,:SWEETSCENT),getID(PBMoves,:TRICKROOM)]
    acc2   = []
    acc3   = []
    eva1   = [getID(PBMoves,:CAMOFLAUGE),getID(PBMoves,:DETECT),getID(PBMoves,:FLASH),getID(PBMoves,:KINESIS),getID(PBMoves,:LUCKYCHANT),getID(PBMoves,:MAGNETRISE),getID(PBMoves,:SANDATTACK),getID(PBMoves,:SMOKESCREEN)]
    eva2   = []
    eva3   = []
    stat1  = [getID(PBMoves,:CELEBRATE),getID(PBMoves,:CONVERSION),getID(PBMoves,:FORESTSCURSE),getID(PBMoves,:GEOMANCY),getID(PBMoves,:HAPPYHOUR),getID(PBMoves,:HOLDHANDS),getID(PBMoves,:PURIFY),getID(PBMoves,:SKETCH),getID(PBMoves,:TRICKORTREAT)]
    stat2  = []
    stat3  = []
    crit1  = [getID(PBMoves,:ACUPRESSIRE),getID(PBMoves,:FORESIGHT),getID(PBMoves,:HEARTSWAP),getID(PBMoves,:SLEEPTALK),getID(PBMoves,:TAILWIND)]
    reset  = [getID(PBMoves,:ACIDARMOR),getID(PBMoves,:AGILITY),getID(PBMoves,:AMNESIA),getID(PBMoves,:ATTRACT),getID(PBMoves,:AUTOTOMIZE),getID(PBMoves,:BARRIER),getID(PBMoves,:BATONPASS),getID(PBMoves,:CALMMIND),getID(PBMoves,:COIL),getID(PBMoves,:COTTONGUARD),getID(PBMoves,:COTTONSPORE),getID(PBMoves,:DARKVOID),getID(PBMoves,:DISABLE),getID(PBMoves,:DOUBLETEAM),getID(PBMoves,:DRAGONDANCE),getID(PBMoves,:ENDURE),getID(PBMoves,:FLORALHEALING),getID(PBMoves,:FOLLOWME),getID(PBMoves,:HEALORDER),getID(PBMoves,:HEALPULSE),getID(PBMoves,:HELPINGHAND),getID(PBMoves,:IRONDEFENSE),getID(PBMoves,:KINGSSHIELD),getID(PBMoves,:LEECHSEED),getID(PBMoves,:MILKDRINK),getID(PBMoves,:MINIMIZE),getID(PBMoves,:MOONLIGHT),getID(PBMoves,:MORNINGSUN),getID(PBMoves,:NASTYPLOT),getID(PBMoves,:PERISHSONG),getID(PBMoves,:PROTECT),getID(PBMoves,:QUIVERDANCE),getID(PBMoves,:RAGEPOWDER),getID(PBMoves,:RECOVER),getID(PBMoves,:REST),getID(PBMoves,:ROCKPOLISH),getID(PBMoves,:ROOST),getID(PBMoves,:SHELLSMASH),getID(PBMoves,:SHIFTGEAR),getID(PBMoves,:SHOREUP),getID(PBMoves,:SHELLSMASH),getID(PBMoves,:SHIFTGEAR),getID(PBMoves,:SHOREUP),getID(PBMoves,:SLACKOFF),getID(PBMoves,:SOFTBOILED),getID(PBMoves,:SPORE),getID(PBMoves,:SUBSTITUTE),getID(PBMoves,:SWAGGER),getID(PBMoves,:SWALLOW),getID(PBMoves,:SWORDSDANCE),getID(PBMoves,:SYNTHESIS),getID(PBMoves,:TAILGLOW)]
    heal   = [getID(PBMoves,:AROMATHERAPY),getID(PBMoves,:BELLYDRUM),getID(PBMoves,:CONVERSION2),getID(PBMoves,:HAZE),getID(PBMoves,:HEALBELL),getID(PBMoves,:MIST),getID(PBMoves,:PSYCHUP),getID(PBMoves,:REFRESH),getID(PBMoves,:SPITE),getID(PBMoves,:STOCKPILE),getID(PBMoves,:TELEPORT),getID(PBMoves,:TRANSFORM)]
    heal2  = [getID(PBMoves,:MEMENTO),getID(PBMoves,:PARTINGSHOT)]
    centre = [getID(PBMoves,:DESTINYBOND),getID(PBMoves,:GRUDGE)]
    if atk1.include?(move)
      if attacker.pbCanRaiseStatStage?(PBStats::ATTACK,attacker,self)
        attacker.pbRaiseStatStage(PBStats::ATTACK,1,nil,false)         
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power boosted its attack!",attacker.pbThis))
      end
    elsif atk2.include?(move)
      if attacker.pbCanRaiseStatStage?(PBStats::ATTACK,attacker,self)
        attacker.pbRaiseStatStage(PBStats::ATTACK,2,nil,false)         
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power sharply boosted its attack!",attacker.pbThis))
      end
    elsif atk3.include?(move)
      if attacker.pbCanRaiseStatStage?(PBStats::ATTACK,attacker,self)
        attacker.pbRaiseStatStage(PBStats::ATTACK,3,nil,false)         
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power drastically boosted its attack!",attacker.pbThis))
      end
    elsif def1.include?(move)
      if attacker.pbCanRaiseStatStage?(PBStats::DEFENSE,attacker,self)
        attacker.pbRaiseStatStage(PBStats::DEFENSE,1,nil,false)         
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power boosted its defense!",attacker.pbThis))
      end
    elsif def2.include?(move)
      if attacker.pbCanRaiseStatStage?(PBStats::DEFENSE,attacker,self)
        attacker.pbRaiseStatStage(PBStats::DEFENSE,2,nil,false)         
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power sharply boosted its defense!",attacker.pbThis))
      end
    elsif def3.include?(move)
      if attacker.pbCanRaiseStatStage?(PBStats::DEFENSE,attacker,self)
        attacker.pbRaiseStatStage(PBStats::DEFENSE,3,nil,false)         
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power drastically boosted its defense!",attacker.pbThis))
      end
    elsif spatk1.include?(move)
      if attacker.pbCanRaiseStatStage?(PBStats::SPATK,attacker,self)
        attacker.pbRaiseStatStage(PBStats::SPATK,1,nil,false)         
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power boosted its special attack!",attacker.pbThis))
      end
    elsif spatk2.include?(move)
      if attacker.pbCanRaiseStatStage?(PBStats::SPATK,attacker,self)
        attacker.pbRaiseStatStage(PBStats::SPATK,2,nil,false)         
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power sharply boosted its special attack!",attacker.pbThis))
      end
    elsif spatk3.include?(move)
      if attacker.pbCanRaiseStatStage?(PBStats::SPATK,attacker,self)
        attacker.pbRaiseStatStage(PBStats::SPATK,3,nil,false)         
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power drastically boosted its special attack!",attacker.pbThis))
      end
    elsif spdef1.include?(move)
      if attacker.pbCanRaiseStatStage?(PBStats::SPDEF,attacker,self)
        attacker.pbRaiseStatStage(PBStats::SPDEF,1,nil,false)         
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power boosted its special defense!",attacker.pbThis))
      end
    elsif spdef2.include?(move)
      if attacker.pbCanRaiseStatStage?(PBStats::SPDEF,attacker,self)
        attacker.pbRaiseStatStage(PBStats::SPDEF,2,nil,false)         
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power sharply boosted its special defense!",attacker.pbThis))
      end
    elsif spdef3.include?(move)
      if attacker.pbCanRaiseStatStage?(PBStats::SPDEF,attacker,self)
        attacker.pbRaiseStatStage(PBStats::SPDEF,3,nil,false)         
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power drastically boosted its special defense!",attacker.pbThis))
      end
    elsif speed1.include?(move)
      if attacker.pbCanRaiseStatStage?(PBStats::SPEED,attacker,self)
        attacker.pbRaiseStatStage(PBStats::SPEED,1,nil,false)         
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power boosted its speed!",attacker.pbThis))
      end
    elsif speed2.include?(move)
      if attacker.pbCanRaiseStatStage?(PBStats::SPEED,attacker,self)
        attacker.pbRaiseStatStage(PBStats::SPEED,2,nil,false)         
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power sharply boosted its speed!",attacker.pbThis))
      end
    elsif speed3.include?(move)
      if attacker.pbCanRaiseStatStage?(PBStats::SPEED,attacker,self)
        attacker.pbRaiseStatStage(PBStats::SPEED,3,nil,false)         
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power drastically boosted its speed!",attacker.pbThis))
      end
    elsif acc1.include?(move)
      if attacker.pbCanRaiseStatStage?(PBStats::ACCURACY,attacker,self)
        attacker.pbRaiseStatStage(PBStats::ACCURACY,1,nil,false)         
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power boosted its accuracy!",attacker.pbThis))
      end
    elsif acc2.include?(move)
      if attacker.pbCanRaiseStatStage?(PBStats::ACCURACY,attacker,self)
        attacker.pbRaiseStatStage(PBStats::ACCURACY,2,nil,false)         
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power sharply boosted its accuracy!",attacker.pbThis))
      end
    elsif acc3.include?(move)
      if attacker.pbCanRaiseStatStage?(PBStats::ACCURACY,attacker,self)
        attacker.pbRaiseStatStage(PBStats::ACCURACY,3,nil,false)         
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power drastically boosted its accuracy!",attacker.pbThis))
      end
    elsif eva1.include?(move)
      if attacker.pbCanRaiseStatStage?(PBStats::EVASION,attacker,self)
        attacker.pbRaiseStatStage(PBStats::EVASION,1,nil,false)         
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power boosted its evasion!",attacker.pbThis))
      end
    elsif eva2.include?(move)
      if attacker.pbCanRaiseStatStage?(PBStats::EVASION,attacker,self)
        attacker.pbRaiseStatStage(PBStats::EVASION,2,nil,false)         
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power sharply boosted its evasion!",attacker.pbThis))
      end
    elsif eva3.include?(move)
      if attacker.pbCanRaiseStatStage?(PBStats::EVASION,attacker,self)
        attacker.pbRaiseStatStage(PBStats::EVASION,3,nil,false)         
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power drastically boosted its evasion!",attacker.pbThis))
      end
    elsif stat1.include?(move)
      if attacker.pbCanRaiseStatStage?(PBStats::ATTACK,attacker,self)
        attacker.pbRaiseStatStage(PBStats::ATTACK,1,nil,false)                 
      end
      if attacker.pbCanRaiseStatStage?(PBStats::DEFENSE,attacker,self)
        attacker.pbRaiseStatStage(PBStats::DEFENSE,1,nil,false)                 
      end      
      if attacker.pbCanRaiseStatStage?(PBStats::SPATK,attacker,self)
        attacker.pbRaiseStatStage(PBStats::SPATK,1,nil,false)                 
      end      
      if attacker.pbCanRaiseStatStage?(PBStats::SPDEF,attacker,self)
        attacker.pbRaiseStatStage(PBStats::SPDEF,1,nil,false)                 
      end      
      if attacker.pbCanRaiseStatStage?(PBStats::SPEED,attacker,self)
        attacker.pbRaiseStatStage(PBStats::SPEED,1,nil,false)                 
      end      
      @battle.pbDisplayBrief(_INTL("{1}'s Z-Power boosted its stats!",attacker.pbThis))
    elsif stat2.include?(move)
      if attacker.pbCanRaiseStatStage?(PBStats::ATTACK,attacker,self)
        attacker.pbRaiseStatStage(PBStats::ATTACK,2,nil,false)                 
      end
      if attacker.pbCanRaiseStatStage?(PBStats::DEFENSE,attacker,self)
        attacker.pbRaiseStatStage(PBStats::DEFENSE,2,nil,false)                 
      end      
      if attacker.pbCanRaiseStatStage?(PBStats::SPATK,attacker,self)
        attacker.pbRaiseStatStage(PBStats::SPATK,2,nil,false)                 
      end      
      if attacker.pbCanRaiseStatStage?(PBStats::SPDEF,attacker,self)
        attacker.pbRaiseStatStage(PBStats::SPDEF,2,nil,false)                 
      end      
      if attacker.pbCanRaiseStatStage?(PBStats::SPEED,attacker,self)
        attacker.pbRaiseStatStage(PBStats::SPEED,2,nil,false)                 
      end      
      @battle.pbDisplayBrief(_INTL("{1}'s Z-Power sharply boosted its stats!",attacker.pbThis))
    elsif stat3.include?(move)
      if attacker.pbCanRaiseStatStage?(PBStats::ATTACK,attacker,self)
        attacker.pbRaiseStatStage(PBStats::ATTACK,3,nil,false)                 
      end
      if attacker.pbCanRaiseStatStage?(PBStats::DEFENSE,attacker,self)
        attacker.pbRaiseStatStage(PBStats::DEFENSE,3,nil,false)                 
      end      
      if attacker.pbCanRaiseStatStage?(PBStats::SPATK,attacker,self)
        attacker.pbRaiseStatStage(PBStats::SPATK,3,nil,false)                 
      end      
      if attacker.pbCanRaiseStatStage?(PBStats::SPDEF,attacker,self)
        attacker.pbRaiseStatStage(PBStats::SPDEF,3,nil,false)                 
      end      
      if attacker.pbCanRaiseStatStage?(PBStats::SPEED,attacker,self)
        attacker.pbRaiseStatStage(PBStats::SPEED,3,nil,false)                 
      end      
      @battle.pbDisplayBrief(_INTL("{1}'s Z-Power drastically boosted its stats!",attacker.pbThis))
    elsif crit1.include?(move)
      if attacker.effects[PBEffects::FocusEnergy]<3
        attacker.effects[PBEffects::FocusEnergy]+=1
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power is getting it pumped!",attacker.pbThis))
      end      
    elsif reset.include?(move)
      for i in [PBStats::ATTACK,PBStats::DEFENSE,
                PBStats::SPEED,PBStats::SPATK,PBStats::SPDEF,
                PBStats::EVASION,PBStats::ACCURACY]
        if attacker.stages[i]<0
          attacker.stages[i]=0
        end
      end
      @battle.pbDisplayBrief(_INTL("{1}'s Z-Power returned its decreased stats to normal!",attacker.pbThis))
    elsif heal.include?(move)
      attacker.pbRecoverHP(attacker.totalhp,false)
      @battle.pbDisplayBrief(_INTL("{1}'s Z-Power restored its health!",attacker.pbThis))
    elsif heal2.include?(move)
      attacker.effects[PBEffects::ZHeal]=true
    elsif centre.include?(move)
      attacker.effects[PBEffects::FollowMe]=true
      if !attacker.pbPartner.isFainted?
        attacker.pbPartner.effects[PBEffects::FollowMe]=false
        attacker.pbPartner.effects[PBEffects::RagePowder]=false  
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power made it the centre of attention!",attacker.pbThis))
      end
    end
  end
  
end
