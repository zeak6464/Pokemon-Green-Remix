class PokeBattle_Battler
  
  def isDeltap?; return false; end 
    
  def isDeltap?
    if @pokemon
      return (@pokemon.isDeltap? rescue false)
    end
    return false
  end
end

class PokeBattle_FakeBattler
  def isDeltap?; return @pokemon.isDeltap?; end
 end

class PokeBattle_Pokemon
  attr_accessor(:deltap)
  attr_accessor(:typeOverride1)  # Type Override
  attr_accessor(:typeOverride2)  # Type Override2
  attr_accessor(:abilityOverride) # Ability Override
  attr_accessor(:hue)
   
  # Returns a random Move but replaces current moves 
  def pbRandomMoves
    @moves[0]=PBMove.new(rand(PBMoves.maxValue)+1)
    @moves[1]=PBMove.new(rand(PBMoves.maxValue)+1)
    @moves[2]=PBMove.new(rand(PBMoves.maxValue)+1)
    @moves[3]=PBMove.new(rand(PBMoves.maxValue)+1)
  end
  
  # Returns whether this Pokemon is @delta  
  def isDeltap?
    return @deltap
  end
  
  # Makes this Pokemon @delta.
  def makeDeltap
    @deltap=true
    @hue=rand(360)
  end

# Makes this Pokemon not @delta.
  def makeNotDeltap
    @deltap=false
  end
   
  alias _deltap_type1 type1
  alias _deltap_type2 type2
  alias _deltap_ability ability
  
  

   def type1
    if @typeOverride1==nil
      return pbGetSpeciesData(@species,formSimple,SpeciesType1)
    else
      return getConst(PBTypes,@typeOverride1)
    end
  end

    def type2
     if @typeOverride2==nil
      return pbGetSpeciesData(@species,formSimple,SpeciesType2)
      return ret
    else
      return getConst(PBTypes,@typeOverride2)
    end
  end

  
  # typeOverride1. When == 0:Normal 1:Fighting 2:Flying 3:Poison 4:Ground 5:Rock
# 6:Bug 7:Ghost 8:Steel 9:??? 10:Fire 11:Water 12:Grass 13:Electric 14:Psychic
# 15:Ice 16:Dragon 17:Dark 18:Shadow 19:Fairy
  def typeOverride1=(value)
    case value
    when 0
      @typeOverride1=:NORMAL
    when 1
      @typeOverride1=:FIGHTING
    when 2
      @typeOverride1=:FLYING
    when 3
      @typeOverride1=:POISON
    when 4
      @typeOverride1=:GROUND
    when 5
      @typeOverride1=:ROCK
    when 6
      @typeOverride1=:BUG
    when 7
      @typeOverride1=:GHOST
    when 8
      @typeOverride1=:STEEL
    when 9
      @typeOverride1=:QMARKS
    when 10
      @typeOverride1=:FIRE
    when 11
      @typeOverride1=:WATER
    when 12
      @typeOverride1=:GRASS
    when 13
      @typeOverride1=:ELECTRIC
    when 14
      @typeOverride1=:PSYCHIC
    when 15
      @typeOverride1=:ICE
    when 16
      @typeOverride1=:DRAGON
    when 17
      @typeOverride1=:DARK
    when 18
      @typeOverride1=:SHADOW
    when 19
      @typeOverride1=:FAIRY
    when 20
      @typeOverride1=:FULL
    else @typeOverride1=nil
    end
  end

# typeOverride2.
   def typeOverride2=(value)
    case value
    when 0
      @typeOverride2=:NORMAL
    when 1
      @typeOverride2=:FIGHTING
    when 2
      @typeOverride2=:FLYING
    when 3
      @typeOverride2=:POISON
    when 4
      @typeOverride2=:GROUND
    when 5
      @typeOverride2=:ROCK
    when 6
      @typeOverride2=:BUG
    when 7
      @typeOverride2=:GHOST
    when 8
      @typeOverride2=:STEEL
    when 9
      @typeOverride2=:QMARKS
    when 10
      @typeOverride2=:FIRE
    when 11
      @typeOverride2=:WATER
    when 12
      @typeOverride2=:GRASS
    when 13
      @typeOverride2=:ELECTRIC
    when 14
      @typeOverride2=:PSYCHIC
    when 15
      @typeOverride2=:ICE
    when 16
      @typeOverride2=:DRAGON
    when 17
      @typeOverride2=:DARK
    when 18
      @typeOverride2=:SHADOW
    when 19
      @typeOverride2=:FAIRY
    when 20
      @typeOverride2=:FULL
    else @typeOverride1=nil
    end
  end
    
  # Returns the ID of this Pokemon's ability.
  def ability
    if @abilityOverride==nil
    abil=abilityIndex
    abils=getAbilityList
    ret1=0; ret2=0
    for i in 0...abils.length
      next if !abils[i][0] || abils[i][0]<=0
      return abils[i][0] if abils[i][1]==abil
      ret1=abils[i][0] if abils[i][1]==0
      ret2=abils[i][0] if abils[i][1]==1
    end
    abil=(@personalID&1) if abil>=2
    return ret2 if abil==1 && ret2>0
    return ret1
  else
    return(@abilityOverride)
  end
  
    def abilityOverride=(value)
    if value==0
      return self.ability>0
    else
        value=getID(PBAbilities,value)
      end
      return self.ability==value
    end
    return false
  end
end

