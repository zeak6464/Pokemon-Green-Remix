#==============================================================================#
# Modular Battler Scene ~By PDM20 (For Pokemon Essentials v18.1)               #
# This entierly plug and play script allows one to add a greater number of     #
# battlers to any pokeon battle of up to 5 participants per side. simply call  #
# pbModWildBattle or pbModTrBat in a script like you would any other evented   #
# battle. the prime difference is the two variables at the begining of the def #
# those being vsT and vsO. input a number from 1 to five in these fields to set#
# the number of pokemon one side will use. if you want you can get fancy and   #
# let the player decide how many pokemon they want to use durring battle.      #
#==============================================================================#
# Please Credit derFischae and myself if you plan to use this script (some of  #
# derFischae's code ended up being put into this script)                       #
#==============================================================================#
# there are 3 things untested as of release. the Naming scene, Pokedex scene,  #
# and the move replacement scene that is used in battle, so let me know if you #
# find anything wrong with them while using the script. Thanks for using this. #
#==============================================================================#
#==============================================================================#
# for starting a trainer bettles, here is an example:                          #
#==============================================================================#
# pbModTrBat(5,3,:MYSTERY,"Enigma",:MYSTERY,"Enigma",:MYSTERY,"Enigma",)       #
#==============================================================================#
# this will begin a battle agianst 3 trainers named "Mystery Enigma" so long as#
# He is defined in the PBS of your game, while the player will send out 5 mons #
# at once. likewise, here is an example of a Wild Battle:                      #
#==============================================================================#
# pbModWildBattle($game_variables[PCV],3,:MEW,10,:CELEBI,10,:JIRACHI,10)       #
#==============================================================================#
# this depending on what PCV equals shall begin a battle agianst a Mew, Celebi,#
# and Jirachi all at level 10 agianst a number of pokemon determined by the    #
# value of PCV.
#==============================================================================#
PLAYER_COUNT_VAR = 5000
PCV              = PLAYER_COUNT_VAR 
CANT_FLEE        = 5001
RMODX            = 736-512
RMODY            = 608-384
USEFEMALESPRITES = true
USEALTFORMS      = true
#==============================================================================#
# PokemonSystem                                                                #
#==============================================================================#
class PokemonSystem
  attr_accessor :textspeed
  attr_accessor :battlescene
  attr_accessor :battlestyle
  attr_accessor :frame
  attr_writer   :textskin
  attr_accessor :font
  attr_accessor :screensize
  attr_writer   :border
  attr_writer   :language
  attr_writer   :runstyle
  attr_writer   :bgmvolume
  attr_writer   :sevolume
  attr_writer   :textinput
  attr_accessor :activebattle
  attr_accessor :trainerusing

  def initialize
    @textspeed    = 1     # Text speed (0=slow, 1=normal, 2=fast)
    @battlescene  = 0     # Battle effects (animations) (0=on, 1=off)
    @battlestyle  = 0     # Battle style (0=switch, 1=set)
    @frame        = 0     # Default window frame (see also $TextFrames)
    @textskin     = 0     # Speech frame
    @font         = 0     # Font (see also $VersionStyles)
    @screensize   = (SCREEN_ZOOM.floor).to_i   # 0=half size, 1=full size, 2=double size
    @border       = 0     # Screen border (0=off, 1=on)
    @language     = 0     # Language (see also LANGUAGES in script PokemonSystem)
    @runstyle     = 0     # Run key functionality (0=hold to run, 1=toggle auto-run)
    @bgmvolume    = 100   # Volume of background music and ME
    @sevolume     = 100   # Volume of sound effects
    @textinput    = 0     # Text input mode (0=cursor, 1=keyboard)
    @activebattle = false
    @trainerusing = 0     # Number Of Pokemon A trainer will use in battle
  end

  def textskin;  return @textskin || 0;    end
  def border;    return @border || 0;      end
  def language;  return @language || 0;    end
  def runstyle;  return @runstyle || 0;    end
  def bgmvolume; return @bgmvolume || 100; end
  def sevolume;  return @sevolume || 100;  end
  def textinput; return @textinput || 0;   end
  def tilemap;   return MAP_VIEW_MODE;     end
end
#==============================================================================#
# Win32API                                                                     #
#==============================================================================#
class Win32API
  def Win32API.restoreScreen
    setWindowLong = Win32API.new('user32','SetWindowLong','LLL','L')
    setWindowPos  = Win32API.new('user32','SetWindowPos','LLIIIII','I')
    metrics = Win32API.new('user32','GetSystemMetrics','I','I')
    hWnd = pbFindRgssWindow
    if $PokemonSystem.activebattle==true
     width  = 736*$ResizeFactor#SCREEN_WIDTH*$ResizeFactor
     height = 608*$ResizeFactor#SCREEN_HEIGHT*$ResizeFactor
      else
     width  = 512*$ResizeFactor#SCREEN_WIDTH*$ResizeFactor
     height = 384*$ResizeFactor#SCREEN_HEIGHT*$ResizeFactor
    end
    if $PokemonSystem && $PokemonSystem.border==1
      width += BORDER_WIDTH*2*$ResizeFactor
      height += BORDER_HEIGHT*2*$ResizeFactor
    end
    x = [(metrics.call(0)-width)/2,0].max
    y = [(metrics.call(1)-height)/2,0].max
    setWindowLong.call(hWnd,-16,0x14CA0000)
    setWindowPos.call(hWnd,0,x,y,width+6,height+29,0)
    Win32API.focusWindow
    return [width,height]
  end
end
module Graphics
  ## Nominal screen size
   @@actwidth  = SCREEN_WIDTH+RMODX
   @@actheight = SCREEN_HEIGHT+RMODY
  def self.actwidth
    return @@actwidth.to_i
  end
  def self.actheight
    return @@actheight.to_i
  end
  def self.width=(value)
    @@width = value
  end
  def self.height=(value)
    @@height = value
  end
end
def pbConfigureFullScreen
  params = Win32API.fillScreen
  if $PokemonSystem.activebattle==true
   fullgamew = gamew = 736#SCREEN_WIDTH
   fullgameh = gameh = 608#SCREEN_HEIGHT
    else
   fullgamew = gamew = 512#SCREEN_WIDTH
   fullgameh = gameh = 384#SCREEN_HEIGHT
  end
  if !BORDER_FULLY_SHOWS && $PokemonSystem && $PokemonSystem.border==1
    fullgamew += BORDER_WIDTH * 2
    fullgameh += BORDER_HEIGHT * 2
  end
#  factor_x = ((2*params[0])/fullgamew).floor
#  factor_y = ((2*params[1])/fullgameh).floor
#  factor = [factor_x,factor_y].min/2.0
  factor_x = (params[0]/fullgamew).floor
  factor_y = (params[1]/fullgameh).floor
  factor = [factor_x,factor_y].min
  offset_x = (params[0]-gamew*factor)/(2*factor)
  offset_y = (params[1]-gameh*factor)/(2*factor)
  $ResizeOffsetX = offset_x
  $ResizeOffsetY = offset_y
  ObjectSpace.each_object(Viewport) { |o|
    begin
      next if o.rect.nil?
      ox = o.rect.x-$ResizeOffsetX
      oy = o.rect.y-$ResizeOffsetY
      o.rect.x = ox+offset_x
      o.rect.y = oy+offset_y
    rescue RGSSError
    end
  }
  pbSetResizeFactor2(factor,true)
end
def newWindowSize
  if $PokemonSystem.activebattle==true
   Graphics.width  = 736#SCREEN_WIDTH
   Graphics.height = 608#SCREEN_HEIGHT
   Win32API.SetWindowPos(736,608)
  else
   Graphics.width  = 512#SCREEN_WIDTH
   Graphics.height = 384#SCREEN_HEIGHT
   Win32API.SetWindowPos(512,384)
  end
end
def resetWindowSize
   Graphics.width  = 512#SCREEN_WIDTH
   Graphics.height = 384#SCREEN_HEIGHT
   Win32API.SetWindowPos(512,384)
end
module PokeBattle_SceneConstants
  USE_ABILITY_SPLASH = true
  # Text colors
  MESSAGE_BASE_COLOR   = Color.new(255,255,255)
  MESSAGE_SHADOW_COLOR = Color.new(0,0,0)

  # The number of party balls to show in each side's lineup.
  NUM_BALLS = 6

  # Centre bottom of the player's side base graphic
  PLAYER_BASE_X = 128
  PLAYER_BASE_Y = Graphics.height - 80
  ACT_PLAYER_BASE_X = 236
  ACT_PLAYER_BASE_Y = Graphics.actheight - 80

  # Centre middle of the foe's side base graphic
  FOE_BASE_X    = Graphics.width - 128
  FOE_BASE_Y    = (Graphics.height * 3/4) - 112
  ACT_FOE_BASE_X    = Graphics.actwidth - 236
  ACT_FOE_BASE_Y    = (Graphics.actheight * 3/4) - 202

  # Returns where the centre bottom of a battler's sprite should be, given its
  # index and the number of battlers on its side, assuming the battler has
  # metrics of 0 (those are added later).
  def self.pbBattlerPosition(index,sideSize=1)
   # Start at the centre of the base for the appropriate side
   if $PokemonSystem.activebattle==true
    if (index&1)==0; ret = [ACT_PLAYER_BASE_X,ACT_PLAYER_BASE_Y]
    else;            ret = [ACT_FOE_BASE_X,ACT_FOE_BASE_Y]
    end
   else
    if (index&1)==0; ret = [PLAYER_BASE_X,PLAYER_BASE_Y]
    else;            ret = [FOE_BASE_X,FOE_BASE_Y]
    end
   end
    # Shift depending on index (no shifting needed for sideSize of 1)
    case sideSize
#if index.compatDmax?
#    when 2
#      ret[0] += [-50, 50, 50,-50][index]
#      ret[1] += [-30,-30,-46,-46][index]
#    when 3
#      ret[0] += [-120,120,  0,  0,120,-120][index]
#      ret[1] += [ -30,-30,-35,-35,-40, -40][index]
# when 4
#      ret[0] += [-140,140,-60, 60, 60,-60,140,-140][index]
#      ret[1] += [ -30,-30,-35,-35,-40,-40,-45, -45][index]
# when 5
#      ret[0] += [-160,160,-70, 70,  0,  0, 70,-70,160,-160][index]
#      ret[1] += [ -30,-30 -35,-35,-40,-40,-45,-45,-50, -50][index]
#    end
#  else
     when 2
       ret[0] += [-50, 50, 50,-50][index]
       ret[1] += [  0,  0, 16,-16][index]
     when 3
       ret[0] += [-120,120,  0,  0,120,-120][index]
       ret[1] += [   0,  0,  5, -5, 10, -10][index]
     when 4
       ret[0] += [-140,140,-60, 60, 60,-60,140,-140][index]
       ret[1] += [   0,  0,  5, -5, 10,-10, 15, -15][index]
     when 5
       ret[0] += [-160, 160, -70, 70,  0,  0, 70,-70,160,-160][index]
       ret[1] += [   0,   0,   5, -5, 10,-10, 15,-15, 20, -20][index]
     end
#end
    return ret
  end

  # Returns where the centre bottom of a trainer's sprite should be, given its
  # side (0/1), index and the number of trainers on its side.
  def self.pbTrainerPosition(side,index=0,sideSize=1)
    # Start at the centre of the base for the appropriate side
	if $PokemonSystem.activebattle==true
     if side==0; ret = [ACT_PLAYER_BASE_X,ACT_PLAYER_BASE_Y-16]
     else;       ret = [ACT_FOE_BASE_X,ACT_FOE_BASE_Y+6]
     end
	else
     if side==0; ret = [PLAYER_BASE_X,PLAYER_BASE_Y-16]
     else;       ret = [FOE_BASE_X,FOE_BASE_Y+6]
     end
    end
    # Shift depending on index (no shifting needed for sideSize of 1)
    case sideSize
    when 2
      ret[0] += [-48, 48, 32,-32][2*index+side]
      ret[1] += [  0,  0,  0,-16][2*index+side]
    when 3
      ret[0] += [-120,120,  0,  0,120,-120][2*index+side]
      ret[1] += [   0,  0,  0, -8,  0, -16][2*index+side]
    when 4
      ret[0] += [-140,140,-60, 60, 60,-60,140,-140][2*index+side]
      ret[1] += [   0,  0,  0, -8,  0,-16,  0, -24][2*index+side]
    when 5
      ret[0] += [-160,160,-70, 70, 0,  0, 70,-70,160,-160][2*index+side]
      ret[1] += [   0,  0,  0, -8, 0,-16,  0,-24,  0, -32][2*index+side]
    end
    return ret
  end

  # Default focal points of user and target in animations - do not change!
  # Is the centre middle of each sprite
  FOCUSUSER_X   = 128   # 144
  FOCUSUSER_Y   = 224   # 188
  FOCUSTARGET_X = 384   # 352
  FOCUSTARGET_Y = 96    # 108, 98
end
#===============================================================================
# Global metadata not specific to a map.  This class holds field state data that
# span multiple maps.
#===============================================================================
class PokemonGlobalMetadata
  # Movement
  attr_accessor :partnerA
  attr_accessor :partnerB
  attr_accessor :partnerC
  alias new_initialize initialize
  def initialize
    new_initialize
    @partnerA             = nil
    @partnerB             = nil
    @partnerC             = nil
  end
end
#===============================================================================
# Partner trainer
#===============================================================================
def pbRegisterPartnerA(trainerid,trainername,partyid=0)
  trainerid = getID(PBTrainers,trainerid)
  pbCancelVehicles
  trainer = pbLoadTrainer(trainerid,trainername,partyid)
  Events.onTrainerPartyLoad.trigger(nil,trainer)
  trainerobject = PokeBattle_Trainer.new(_INTL(trainer[0].name),trainerid)
  trainerobject.setForeignID($Trainer)
  for i in trainer[2]
    i.trainerID = trainerobject.id
    i.ot        = trainerobject.name
    i.calcStats
  end
  $PokemonGlobal.partnerA = [trainerid,trainerobject.name,trainerobject.id,trainer[2]]
end
def pbRegisterPartnerB(trainerid,trainername,partyid=0)
  trainerid = getID(PBTrainers,trainerid)
  pbCancelVehicles
  trainer = pbLoadTrainer(trainerid,trainername,partyid)
  Events.onTrainerPartyLoad.trigger(nil,trainer)
  trainerobject = PokeBattle_Trainer.new(_INTL(trainer[0].name),trainerid)
  trainerobject.setForeignID($Trainer)
  for i in trainer[2]
    i.trainerID = trainerobject.id
    i.ot        = trainerobject.name
    i.calcStats
  end
  $PokemonGlobal.partnerB = [trainerid,trainerobject.name,trainerobject.id,trainer[2]]
end
def pbRegisterPartnerC(trainerid,trainername,partyid=0)
  trainerid = getID(PBTrainers,trainerid)
  pbCancelVehicles
  trainer = pbLoadTrainer(trainerid,trainername,partyid)
  Events.onTrainerPartyLoad.trigger(nil,trainer)
  trainerobject = PokeBattle_Trainer.new(_INTL(trainer[0].name),trainerid)
  trainerobject.setForeignID($Trainer)
  for i in trainer[2]
    i.trainerID = trainerobject.id
    i.ot        = trainerobject.name
    i.calcStats
  end
  $PokemonGlobal.partnerC = [trainerid,trainerobject.name,trainerobject.id,trainer[2]]
end
def pbDeregisterPartners
  $PokemonGlobal.partner  = nil
  $PokemonGlobal.partnerA = nil
  $PokemonGlobal.partnerB = nil
  $PokemonGlobal.partnerC = nil
end
#==============================================================================#
#============================= PokeBattle_Battler ==============================#
#==============================================================================#
class PokeBattle_Battle
  # Sets the number of battler slots on each side of the field independently.
  # For "1v2" names, the first number is for the player's side and the second
  # number is for the opposing side.
  def setBattleMode(mode)
    @sideSizes =
      case mode
	  # 5 On Player
      when "quin", "5v5";   [5,5]
      when "5v4";           [5,4]
      when "5v3";           [5,3]
      when "5v2";           [5,2]
      when "5v1";           [5,1]
	  # 4 On Player
      when "4v5";           [4,5]
      when "quad", "4v4";   [4,4]
      when "4v3";           [4,3]
      when "4v2";           [4,2]
      when "4v1";           [4,1]
	  # 3 On Player
      when "3v5";           [3,5]
      when "3v4";           [3,4]
      when "triple", "3v3"; [3,3]
      when "3v2";           [3,2]
      when "3v1";           [3,1]
	  # 2 On Player
      when "2v5";           [2,4]
      when "2v4";           [2,4]
      when "2v3";           [2,3]
      when "double", "2v2"; [2,2]
      when "2v1";           [2,1]
	  # 1 On Player
      when "1v5";           [1,5]
      when "1v4";           [1,4]
      when "1v3";           [1,3]
      when "1v2";           [1,2]
      else;                 [1,1]   # Single, 1v1 (default)
      end
  end

  # Given a battler index, returns the index within @player/@opponent of the
  # trainer that controls that battler index.
  # NOTE: You shouldn't ever have more trainers on a side than there are battler
  #       positions on that side. This method doesn't account for if you do.
  def pbGetOwnerIndexFromBattlerIndex(idxBattler)
    trainer = (opposes?(idxBattler)) ? @opponent : @player
    return 0 if !trainer
    case trainer.length
    when 2
      n = pbSideSize(idxBattler%2)
	 if $PokemonSystem.trainerusing<=1
      return [0,1,1][idxBattler/2] if n==3
      return [0,1,1,1][idxBattler/2] if n==4
      return [0,1,1,1,1][idxBattler/2] if n==5
	 elsif $PokemonSystem.trainerusing==2
      return [0,0,1][idxBattler/2] if n==3
      return [0,0,1,1][idxBattler/2] if n==4
      return [0,0,1,1,1][idxBattler/2] if n==5
	 elsif $PokemonSystem.trainerusing==3
      return [0,0,1][idxBattler/2] if n==3
      return [0,0,0,1][idxBattler/2] if n==4
      return [0,0,0,1,1][idxBattler/2] if n==5
	 elsif $PokemonSystem.trainerusing==4
      return [0,0,1][idxBattler/2] if n==3
      return [0,0,0,1][idxBattler/2] if n==4
      return [0,0,0,0,1][idxBattler/2] if n==5
	 elsif $PokemonSystem.trainerusing==5
      return [0,0,1][idxBattler/2] if n==3
      return [0,0,0,1][idxBattler/2] if n==4
      return [0,0,0,0,1][idxBattler/2] if n==5
	 else
      return idxBattler/2 if n==2   # Same as [0,1][idxBattler/2], i.e. 2 battler slots
      return [0,0,1][idxBattler/2] if n==3
      return [0,0,1,1][idxBattler/2] if n==4
      return [0,0,1,1,1][idxBattler/2] if n==5
     end
    when 3
      n = pbSideSize(idxBattler%2)
	 if $PokemonSystem.trainerusing<=1
      return [0,1,1][idxBattler/2] if n==3
      return [0,1,1,1][idxBattler/2] if n==4
      return [0,1,1,1,1][idxBattler/2] if n==5
	 elsif $PokemonSystem.trainerusing==2
      return [0,0,1][idxBattler/2] if n==3
      return [0,0,1,1][idxBattler/2] if n==4
      return [0,0,1,1,1][idxBattler/2] if n==5
	 elsif $PokemonSystem.trainerusing==3
      return [0,0,1][idxBattler/2] if n==3
      return [0,0,0,1][idxBattler/2] if n==4
      return [0,0,0,1,1][idxBattler/2] if n==5
	 elsif $PokemonSystem.trainerusing==4
      return [0,0,1][idxBattler/2] if n==3
      return [0,0,0,1][idxBattler/2] if n==4
      return [0,0,0,0,1][idxBattler/2] if n==5
	 elsif $PokemonSystem.trainerusing==5
      return [0,0,1][idxBattler/2] if n==3
      return [0,0,0,1][idxBattler/2] if n==4
      return [0,0,0,0,1][idxBattler/2] if n==5
	 else
      return idxBattler/2 if n==2   # Same as [0,1][idxBattler/2], i.e. 2 battler slots
      return [0,0,1][idxBattler/2] if n==3
      return [0,0,1,1][idxBattler/2] if n==4
      return [0,0,1,1,1][idxBattler/2] if n==5
     end
    when 4
      n = pbSideSize(idxBattler%2)
	 if $PokemonSystem.trainerusing<=1
      return [0,1,1][idxBattler/2] if n==3
      return [0,1,1,1][idxBattler/2] if n==4
      return [0,1,1,1,1][idxBattler/2] if n==5
	 elsif $PokemonSystem.trainerusing==2
      return [0,0,1][idxBattler/2] if n==3
      return [0,0,1,1][idxBattler/2] if n==4
      return [0,0,1,1,1][idxBattler/2] if n==5
	 elsif $PokemonSystem.trainerusing==3
      return [0,0,1][idxBattler/2] if n==3
      return [0,0,0,1][idxBattler/2] if n==4
      return [0,0,0,1,1][idxBattler/2] if n==5
	 elsif $PokemonSystem.trainerusing==4
      return [0,0,1][idxBattler/2] if n==3
      return [0,0,0,1][idxBattler/2] if n==4
      return [0,0,0,0,1][idxBattler/2] if n==5
	 elsif $PokemonSystem.trainerusing==5
      return [0,0,1][idxBattler/2] if n==3
      return [0,0,0,1][idxBattler/2] if n==4
      return [0,0,0,0,1][idxBattler/2] if n==5
	 else
      return idxBattler/2 if n==2   # Same as [0,1][idxBattler/2], i.e. 2 battler slots
      return [0,0,1][idxBattler/2] if n==3
      return [0,0,1,1][idxBattler/2] if n==4
      return [0,0,1,1,1][idxBattler/2] if n==5
     end
    when 5
      n = pbSideSize(idxBattler%2)
	 if $PokemonSystem.trainerusing<=1
      return [0,1,1][idxBattler/2] if n==3
      return [0,1,1,1][idxBattler/2] if n==4
      return [0,1,1,1,1][idxBattler/2] if n==5
	 elsif $PokemonSystem.trainerusing==2
      return [0,0,1][idxBattler/2] if n==3
      return [0,0,1,1][idxBattler/2] if n==4
      return [0,0,1,1,1][idxBattler/2] if n==5
	 elsif $PokemonSystem.trainerusing==3
      return [0,0,1][idxBattler/2] if n==3
      return [0,0,0,1][idxBattler/2] if n==4
      return [0,0,0,1,1][idxBattler/2] if n==5
	 elsif $PokemonSystem.trainerusing==4
      return [0,0,1][idxBattler/2] if n==3
      return [0,0,0,1][idxBattler/2] if n==4
      return [0,0,0,0,1][idxBattler/2] if n==5
	 elsif $PokemonSystem.trainerusing==5
      return [0,0,1][idxBattler/2] if n==3
      return [0,0,0,1][idxBattler/2] if n==4
      return [0,0,0,0,1][idxBattler/2] if n==5
	 else
      return idxBattler/2 if n==2   # Same as [0,1][idxBattler/2], i.e. 2 battler slots
      return [0,0,1][idxBattler/2] if n==3
      return [0,0,1,1][idxBattler/2] if n==4
      return [0,0,1,1,1][idxBattler/2] if n==5
     end
    end
    return 0
  end

  # Given a battler index, and using battle side sizes, returns an array of
  # battler indices from the opposing side that are in order of most "opposite".
  # Used when choosing a target and pressing up/down to move the cursor to the
  # opposite side, and also when deciding which target to select first for some
  # moves.
  def pbGetOpposingIndicesInOrder(idxBattler)
    case pbSideSize(0)
    when 1
      case pbSideSize(1)
      when 1   # 1v1 single
        return [0] if opposes?(idxBattler)
        return [1]
      when 2   # 1v2
        return [0] if opposes?(idxBattler)
        return [3,1]
      when 3   # 1v3
        return [0] if opposes?(idxBattler)
        return [3,5,1]
      when 4   # 1v4
        return [0] if opposes?(idxBattler)
        return [3,5,1,7]
      when 5   # 1v5
        return [0] if opposes?(idxBattler)
        return [3,5,1,9,7]
      end
    when 2
      case pbSideSize(1)
      when 1   # 2v1
        return [0,2] if opposes?(idxBattler)
        return [1]
      when 2   # 2v2 double
        return [[3,1],[2,0],[1,3],[0,2]][idxBattler]
      when 3   # 2v3
        return [[5,3,1],[2,0],[3,1,5]][idxBattler] if idxBattler<3
        return [0,2]
      when 4   # 2v4
        return [[5,7,3,1],[2,0],[3,1,5,7]][idxBattler] if idxBattler<3
        return [0,2]
      when 5   # 2v5
        return [[7,9,5,3,1],[2,0],[3,1,5,7,9]][idxBattler] if idxBattler<3
        return [0,2]
      end
    when 3
      case pbSideSize(1)
      when 1   # 3v1
        return [2,0,4] if opposes?(idxBattler)
        return [1]
      when 2   # 3v2
        return [[3,1],[2,4,0],[3,1],[2,0,4],[1,3]][idxBattler]
      when 3   # 3v3 triple
        return [[5,3,1],[4,2,0],[3,5,1],[2,0,4],[1,3,5],[0,2,4]][idxBattler]
	  when 4   # 3v4
        return [[7,5,3,1],[4,2,0],[3,5,1,7],[2,4,0],[1,3,5,7],[2,0,4],[1,3,5,7],[0,2,4]][idxBattler]
	  when 5   # 3v5
        return [[9,7,5,3,1],[4,2,0],[5,7,3,9,1],[2,4,0],[3,1,5,7,9],[2,0,4],[1,3,5,7,9],[0,2,4],[1,3,5,7,9],[0,2,4]][idxBattler]
      end
    when 4
      case pbSideSize(1)
      when 1   # 4v1
        return [2,0,4,6] if opposes?(idxBattler)
        return [1]
      when 2   # 4v2
        return [[3,1],[4,6,2,0],[3,1],[2,0,4,6],[1,3],[2,0,4,6],[1,3]][idxBattler]
      when 3   # 4v3
        return [[5,3,1],[6,4,2,0],[5,3,1],[2,4,0,6],[3,1,5],[0,2,4,6],[1,3,5]][idxBattler]
	  when 4   # 4v4 quad
        return [[7,5,3,1],[6,4,2,0],[5,7,3,1],[4,6,2,0],[3,1,5,7],[2,0,4,6],[1,3,5,7],[0,2,4,6]][idxBattler]
	  when 5   # 4v5
        return [[9,7,5,3,1],[6,4,2,0],[7,5,9,3,1],[4,6,2,0],[5,3,1,7,9],[2,4,0,6],[3,1,5,7,9],[2,0,4,6],[1,3,5,7,9],[0,2,4,6]][idxBattler]
      end
	when 5
      case pbSideSize(1)
      when 1 # 5v1
        return [2,0,4,6,8] if opposes?(idxBattler)
        return [1]
      when 2 # 5v2
	    return [[3,1],[6,8,4,2,0],[3,3],[2,0,4,6,8],[3,1],[0,2,4,6,8],[1,3],[8,6,4,2,0],[1,3]][idxBattler]
      when 3 # 5v3
	    return [[5,3,1],[6,8,4,2,0],[5,3,1],[4,2,6,0,8],[3,5,1],[2,0,4,6,8],[1,3,5],[0,2,4,6,8],[1,3,5]][idxBattler]
      when 4 # 5v4
	    return [[7,5,3,1],[8,6,4,2,0],[5,7,3,1],[6,4,8,2,0],[3,5,1,7],[4,2,6,0,8],[3,1,5,7],[2,0,4,6,8],[1,3,5,7]][idxBattler]
      when 5 # 5v5
	    return [[9,7,5,3,1],[8,6,4,2,0],[7,9,5,3,1],[6,8,4,2,0],[5,7,3,9,1],[4,6,2,8,0],[3,5,1,7,9],[2,4,0,6,8],[1,3,5,7,9],[0,2,4,6,8]][idxBattler]
      end
    end
    return [idxBattler]
  end

  def nearBattlers?(idxBattler1,idxBattler2)
    return false if idxBattler1==idxBattler2
    return true if pbSideSize(0)<=2 && pbSideSize(1)<=2
    # Get all pairs of battler positions that are not close to each other
    pairsArray = [[0,4],[0,6],[0,8],[2,6],[2,8],[4,8],[1,5],[1,7],[1,9],[3,7],[3,9],[5,9]]   # all same side combos
    case pbSideSize(0)
     when 5
      case pbSideSize(1)
	  when 5 #5v5
        pairsArray.push([0,1])
        pairsArray.push([0,3])
        pairsArray.push([0,5])
        pairsArray.push([2,1])
        pairsArray.push([2,3])
        pairsArray.push([4,1])
        pairsArray.push([4,9])
        pairsArray.push([6,7])
        pairsArray.push([6,9])
        pairsArray.push([8,5])
        pairsArray.push([8,7])
        pairsArray.push([8,9])
	  when 4 #5v4
        pairsArray.push([0,1])
        pairsArray.push([0,3])
        pairsArray.push([0,5])
        pairsArray.push([2,1])
        pairsArray.push([2,3])
        pairsArray.push([4,1])
        pairsArray.push([4,7])
        pairsArray.push([6,3])
        pairsArray.push([6,7])
        pairsArray.push([8,3])
        pairsArray.push([8,5])
        pairsArray.push([8,7])
	  when 3 #5v3
        pairsArray.push([0,1])
        pairsArray.push([0,3])
        pairsArray.push([2,1])
        pairsArray.push([6,5])
        pairsArray.push([8,3])
        pairsArray.push([8,5])
	  when 2 #5v2
        pairsArray.push([0,1])
        pairsArray.push([2,1])
        pairsArray.push([6,3])
        pairsArray.push([8,3])
	  end
     when 4
      case pbSideSize(1)
      when 5 #4v5
        pairsArray.push([0,1])
        pairsArray.push([0,3])
        pairsArray.push([0,7])
        pairsArray.push([2,1])
        pairsArray.push([2,3])
        pairsArray.push([2,9])
        pairsArray.push([4,1])
        pairsArray.push([4,7])
        pairsArray.push([4,9])
        pairsArray.push([6,5])
        pairsArray.push([6,7])
        pairsArray.push([6,9])
      when 4 #4v4
        pairsArray.push([0,1])
        pairsArray.push([0,3])
        pairsArray.push([2,1])
        pairsArray.push([4,7])
        pairsArray.push([6,5])
        pairsArray.push([6,7])
      when 3 #4v3
        pairsArray.push([0,3])
        pairsArray.push([0,1])
        pairsArray.push([2,1])
        pairsArray.push([4,5])
        pairsArray.push([6,5])
        pairsArray.push([6,3])
      when 2 #4v2
        pairsArray.push([0,1])
        pairsArray.push([6,3])
      end
     when 3
      case pbSideSize(1)
      when 5 #3v5
        pairsArray.push([0,1])
        pairsArray.push([0,3])
        pairsArray.push([0,5])
        pairsArray.push([2,1])
        pairsArray.push([2,9])
        pairsArray.push([4,7])
        pairsArray.push([4,9])
      when 4 #3v4
        pairsArray.push([0,1])
        pairsArray.push([0,3])
        pairsArray.push([2,1])
        pairsArray.push([2,7])
        pairsArray.push([4,5])
        pairsArray.push([4,7])
      when 3 #3v3
        pairsArray.push([0,1])
        pairsArray.push([4,5])
      when 2 #3v2
        pairsArray.push([0,1])
        pairsArray.push([3,4])
      end
     when 2
      case pbSideSize(1)
	  when 5 #2v5
        pairsArray.push([0,1])
        pairsArray.push([0,3])
        pairsArray.push([2,7])
        pairsArray.push([2,9])
      when 4 #2v4
        pairsArray.push([0,1])
        pairsArray.push([2,7])
      when 3 #2v3
        pairsArray.push([0,1])
        pairsArray.push([2,5])
      end
    end
    # See if any pair matches the two battlers being assessed
    pairsArray.each do |pair|
      return false if pair.include?(idxBattler1) && pair.include?(idxBattler2)
    end
    return true
  end

  #=============================================================================
  # Makes sure all Pokémon exist that need to. Alter the type of battle if
  # necessary. Will never try to create battler positions, only delete them
  # (except for wild Pokémon whose number of positions are fixed). Reduces the
  # size of each side by 1 and tries again. If the side sizes are uneven, only
  # the larger side's size will be reduced by 1 each time, until both sides are
  # an equal size (then both sides will be reduced equally).
  #=============================================================================
  def pbEnsureParticipants
    # Prevent battles larger than 2v2 if both sides have multiple trainers
    # NOTE: This is necessary to ensure that battlers can never become unable to
    #       hit each other due to being too far away. In such situations,
    #       battlers will move to the centre position at the end of a round, but
    #       because they cannot move into a position owned by a different
    #       trainer, it's possible that battlers will be unable to move close
    #       enough to hit each other if there are multiple trainers on each
    #       side.
    if trainerBattle? && (@sideSizes[0]>5 || @sideSizes[1]>5) &&
       @player.length>1 && @opponent.length>1
      raise _INTL("Can't have battles larger than 2v2 where both sides have multiple trainers")
    end
    # Find out how many Pokémon each trainer has
    side1counts = pbAbleTeamCounts(0)
    side2counts = pbAbleTeamCounts(1)
    # Change the size of the battle depending on how many wild Pokémon there are
    if wildBattle? && side2counts[0]!=@sideSizes[1]
      if @sideSizes[0]==@sideSizes[1]
        # Even number of battlers per side, change both equally
        @sideSizes = [side2counts[0],side2counts[0]]
      else
        # Uneven number of battlers per side, just change wild side's size
        @sideSizes[1] = side2counts[0]
      end
    end
    # Check if battle is possible, including changing the number of battlers per
    # side if necessary
    loop do
      needsChanging = false
      for side in 0...2   # Each side in turn
        next if side==1 && wildBattle?   # Wild side's size already checked above
        sideCounts = (side==0) ? side1counts : side2counts
        requireds = []
        # Find out how many Pokémon each trainer on side needs to have
        for i in 0...@sideSizes[side]
          idxTrainer = pbGetOwnerIndexFromBattlerIndex(i*2+side)
          requireds[idxTrainer] = 0 if requireds[idxTrainer].nil?
          requireds[idxTrainer] += 1
        end
        # Compare the have values with the need values
        if requireds.length>sideCounts.length
          raise _INTL("Error: def pbGetOwnerIndexFromBattlerIndex gives invalid owner index ({1} for battle type {2}v{3}, trainers {4}v{5})",
             requireds.length-1,@sideSizes[0],@sideSizes[1],side1counts.length,side2counts.length)
        end
        sideCounts.each_with_index do |_count,i|
          if !requireds[i] || requireds[i]==0
            raise _INTL("Player-side trainer {1} has no battler position for their Pokémon to go (trying {2}v{3} battle)",
               i+1,@sideSizes[0],@sideSizes[1]) if side==0
            raise _INTL("Opposing trainer {1} has no battler position for their Pokémon to go (trying {2}v{3} battle)",
               i+1,@sideSizes[0],@sideSizes[1]) if side==1
          end
          next if requireds[i]<=sideCounts[i]   # Trainer has enough Pokémon to fill their positions
          if requireds[i]==1
            raise _INTL("Player-side trainer {1} has no able Pokémon",i+1) if side==0
            raise _INTL("Opposing trainer {1} has no able Pokémon",i+1) if side==1
          end
          # Not enough Pokémon, try lowering the number of battler positions
          needsChanging = true
          break
        end
        break if needsChanging
      end
      break if !needsChanging
      # Reduce one or both side's sizes by 1 and try again
      if wildBattle?
        PBDebug.log("#{@sideSizes[0]}v#{@sideSizes[1]} battle isn't possible " +
                    "(#{side1counts} player-side teams versus #{side2counts[0]} wild Pokémon)")
        newSize = @sideSizes[0]-1
      else
        PBDebug.log("#{@sideSizes[0]}v#{@sideSizes[1]} battle isn't possible " +
                    "(#{side1counts} player-side teams versus #{side2counts} opposing teams)")
        newSize = @sideSizes.max-1
      end
      if newSize==0
        raise _INTL("Couldn't lower either side's size any further, battle isn't possible")
      end
      for side in 0...2
        next if side==1 && wildBattle?   # Wild Pokémon's side size is fixed
        next if @sideSizes[side]==1 || newSize>@sideSizes[side]
        @sideSizes[side] = newSize
      end
      PBDebug.log("Trying #{@sideSizes[0]}v#{@sideSizes[1]} battle instead")
    end
  end

  #=============================================================================
  # Send out all battlers at the start of battle
  #=============================================================================
  def pbStartBattleSendOut(sendOuts)
    # "Want to battle" messages
    if wildBattle?
      foeParty = pbParty(1)
      case foeParty.length
      when 1
      #=======================================================================
      # Dynamax - Alters encounter text (Max Raids)
      #=======================================================================
      if defined?(MAXRAID_SWITCH) && $game_switches[MAXRAID_SWITCH]
        text = "Dynamaxed"
        text = "Gigantamax" if foeParty[0].gmaxFactor?
        text = "Eternamax"  if isConst?(foeParty[0].species,PBSpecies,:ETERNATUS)
        pbDisplayPaused(_INTL("Oh! A {1} {2} lurks in the den!",text,foeParty[0].name))
      else
        pbDisplayPaused(_INTL("Oh! A wild {1} appeared!",foeParty[0].name))
      end
      #=======================================================================
      when 2
        pbDisplayPaused(_INTL("Oh! A wild {1} and {2} appeared!",foeParty[0].name,foeParty[1].name))
      when 3
        pbDisplayPaused(_INTL("Oh! A wild {1}, {2} and {3} appeared!",foeParty[0].name,foeParty[1].name,foeParty[2].name))
      when 4
        pbDisplayPaused(_INTL("Oh! A wild {1}, {2}, {3} and {4} appeared!",foeParty[0].name,foeParty[1].name,foeParty[2].name,foeParty[3].name))
      when 5
        pbDisplayPaused(_INTL("Oh! A wild {1}, {2}, {3}, {4} and {5} appeared!",foeParty[0].name,foeParty[1].name,foeParty[2].name,foeParty[3].name,foeParty[4].name))
      end
    else   # Trainer battle
      case @opponent.length
      when 1
        pbDisplayPaused(_INTL("You are challenged by {1}!",@opponent[0].fullname))
      when 2
        pbDisplayPaused(_INTL("You are challenged by {1} and {2}!",@opponent[0].fullname,@opponent[1].fullname))
      when 3
        pbDisplayPaused(_INTL("You are challenged by {1}, {2} and {3}!",
           @opponent[0].fullname,@opponent[1].fullname,@opponent[2].fullname))
      when 4
        pbDisplayPaused(_INTL("You are challenged by {1}, {2}, {3} and {4}!",
           @opponent[0].fullname,@opponent[1].fullname,@opponent[2].fullname,@opponent[3].fullname))
      when 5
        pbDisplayPaused(_INTL("You are challenged by {1}, {2}, {3}, {4} and {5}!",
           @opponent[0].fullname,@opponent[1].fullname,@opponent[2].fullname,@opponent[3].fullname,@opponent[4].fullname))
      end
    end
    # Send out Pokémon (opposing trainers first)
    for side in [1,0]
      next if side==1 && wildBattle?
      msg = ""
      toSendOut = []
      trainers = (side==0) ? @player : @opponent
      # Opposing trainers and partner trainers's messages about sending out Pokémon
      trainers.each_with_index do |t,i|
        next if side==0 && i==0   # The player's message is shown last
        msg += "\r\n" if msg.length>0
        sent = sendOuts[side][i]
        case sent.length
        when 1
          msg += _INTL("{1} sent out {2}!",t.fullname,@battlers[sent[0]].name)
        when 2
          msg += _INTL("{1} sent out {2} and {3}!",t.fullname,
             @battlers[sent[0]].name,@battlers[sent[1]].name)
        when 3
          msg += _INTL("{1} sent out {2}, {3} and {4}!",t.fullname,
             @battlers[sent[0]].name,@battlers[sent[1]].name,@battlers[sent[2]].name)
        when 4
          msg += _INTL("{1} sent out {2}, {3}, {4} and {5}!",t.fullname,
             @battlers[sent[0]].name,@battlers[sent[1]].name,@battlers[sent[2]].name,@battlers[sent[3]].name)
        when 5
          msg += _INTL("{1} sent out {2}, {3}, {4}, {5} and {6}!",t.fullname,
             @battlers[sent[0]].name,@battlers[sent[1]].name,@battlers[sent[2]].name,@battlers[sent[3]].name,@battlers[sent[4]].name)
        end
        toSendOut.concat(sent)
      end
      # The player's message about sending out Pokémon
      if side==0
        msg += "\r\n" if msg.length>0
        sent = sendOuts[side][0]
        case sent.length
        when 1
          msg += _INTL("Go! {1}!",@battlers[sent[0]].name)
        when 2
          msg += _INTL("Go! {1} and {2}!",@battlers[sent[0]].name,@battlers[sent[1]].name)
        when 3
          msg += _INTL("Go! {1}, {2} and {3}!",@battlers[sent[0]].name,
             @battlers[sent[1]].name,@battlers[sent[2]].name)
        when 3
          msg += _INTL("Go! {1}, {2}, {3} and {4}!",@battlers[sent[0]].name,
             @battlers[sent[1]].name,@battlers[sent[2]].name,@battlers[sent[3]].name)
        when 3
          msg += _INTL("Go! {1}, {2}, {3}, {4} and {5}!",@battlers[sent[0]].name,
             @battlers[sent[1]].name,@battlers[sent[2]].name,@battlers[sent[3]].name,@battlers[sent[4]].name)
        end
        toSendOut.concat(sent)
      end
      pbDisplayBrief(msg) if msg.length>0
      # The actual sending out of Pokémon
      animSendOuts = []
      toSendOut.each do |idxBattler|
        animSendOuts.push([idxBattler,@battlers[idxBattler].pokemon])
      end
      pbSendOut(animSendOuts,true)
    end
  end

  #=============================================================================
  # Start a battle
  #=============================================================================
  def pbStartBattle
    PBDebug.log("")
    PBDebug.log("******************************************")
    logMsg = "[Started battle] "
    if @sideSizes[0]==1 && @sideSizes[1]==1
      logMsg += "Single "
    elsif @sideSizes[0]==2 && @sideSizes[1]==2
      logMsg += "Double "
    elsif @sideSizes[0]==3 && @sideSizes[1]==3
      logMsg += "Triple "
    elsif @sideSizes[0]==4 && @sideSizes[1]==5
      logMsg += "Quad "
    elsif @sideSizes[0]==5 && @sideSizes[1]==5
      logMsg += "Quin "
    else
      logMsg += "#{@sideSizes[0]}v#{@sideSizes[1]} "
    end
    logMsg += "wild " if wildBattle?
    logMsg += "trainer " if trainerBattle?
    logMsg += "battle (#{@player.length} trainer(s) vs. "
    logMsg += "#{pbParty(1).length} wild Pokémon)" if wildBattle?
    logMsg += "#{@opponent.length} trainer(s))" if trainerBattle?
    PBDebug.log(logMsg)
    pbEnsureParticipants
    begin
      pbStartBattleCore
    rescue BattleAbortedException
      @decision = 0
      @scene.pbEndBattle(@decision)
    end
    return @decision
  end

  #=============================================================================
  # End of battle
  #=============================================================================
  def pbEndOfBattle
    oldDecision = @decision
    @decision = 4 if @decision==1 && wildBattle? && @caughtPokemon.length>0
    case oldDecision
    ##### WIN #####
    when 1
      PBDebug.log("")
      PBDebug.log("***Player won***")
      if trainerBattle?
        @scene.pbTrainerBattleSuccess
        case @opponent.length
        when 1
          pbDisplayPaused(_INTL("You defeated {1}!",@opponent[0].fullname))
        when 2
          pbDisplayPaused(_INTL("You defeated {1} and {2}!",@opponent[0].fullname,
             @opponent[1].fullname))
        when 3
          pbDisplayPaused(_INTL("You defeated {1}, {2} and {3}!",@opponent[0].fullname,
             @opponent[1].fullname,@opponent[2].fullname))
        when 4
          pbDisplayPaused(_INTL("You defeated {1}, {2}, {3} and {4}!",@opponent[0].fullname,
             @opponent[1].fullname,@opponent[2].fullname,@opponent[3].fullname))
        when 5
          pbDisplayPaused(_INTL("You defeated {1}, {2}, {3}, {4} and {5}!",@opponent[0].fullname,
             @opponent[1].fullname,@opponent[2].fullname,@opponent[3].fullname,@opponent[4].fullname))
        end
        @opponent.each_with_index do |_t,i|
          @scene.pbShowOpponent(i)
          msg = (@endSpeeches[i] && @endSpeeches[i]!="") ? @endSpeeches[i] : "..."
          pbDisplayPaused(msg.gsub(/\\[Pp][Nn]/,pbPlayer.name))
        end
      end
      # Gain money from winning a trainer battle, and from Pay Day
      pbGainMoney if @decision!=4
      # Trainer Pokemon in Party after a battle is changed to Opponents  
      if $PokemonSystem.switchtrainer == 1
        $Trainer.party = pbParty(1)
        pbHealAll
       end
      # Hide remaining trainer
      @scene.pbShowOpponent(@opponent.length) if trainerBattle? && @caughtPokemon.length>0
    ##### LOSE, DRAW #####
    when 2, 5
      PBDebug.log("")
      PBDebug.log("***Player lost***") if @decision==2
      PBDebug.log("***Player drew with opponent***") if @decision==5
      if @internalBattle
        pbDisplayPaused(_INTL("You have no more Pokémon that can fight!"))
        if trainerBattle?
          case @opponent.length
          when 1
            pbDisplayPaused(_INTL("You lost against {1}!",@opponent[0].fullname))
          when 2
            pbDisplayPaused(_INTL("You lost against {1} and {2}!",
               @opponent[0].fullname,@opponent[1].fullname))
          when 3
            pbDisplayPaused(_INTL("You lost against {1}, {2} and {3}!",
               @opponent[0].fullname,@opponent[1].fullname,@opponent[2].fullname))
          when 4
            pbDisplayPaused(_INTL("You lost against {1}, {2}, {3} and {4}!",
               @opponent[0].fullname,@opponent[1].fullname,@opponent[2].fullname,@opponent[3].fullname))
          when 5
            pbDisplayPaused(_INTL("You lost against {1}, {2}, {3}, {4} and {5}!",
               @opponent[0].fullname,@opponent[1].fullname,@opponent[2].fullname,@opponent[3].fullname,@opponent[4].fullname))
          end
        end
        # Lose money from losing a battle
        pbLoseMoney
        pbDisplayPaused(_INTL("You blacked out!")) if !@canLose
      elsif @decision==2
        if @opponent
          @opponent.each_with_index do |_t,i|
            @scene.pbShowOpponent(i)
            msg = (@endSpeechesWin[i] && @endSpeechesWin[i]!="") ? @endSpeechesWin[i] : "..."
            pbDisplayPaused(msg.gsub(/\\[Pp][Nn]/,pbPlayer.name))
          end
        end
      end
    ##### CAUGHT WILD POKÉMON #####
    when 4
      @scene.pbWildBattleSuccess if !GAIN_EXP_FOR_CAPTURE
    end
    # Register captured Pokémon in the Pokédex, and store them
    pbRecordAndStoreCaughtPokemon
    # Collect Pay Day money in a wild battle that ended in a capture
    pbGainMoney if @decision==4
    # Random Pokemon in Party after a battle 
    for i in 0...$Trainer.party.length
      if $PokemonSystem.randp == 1
        $Trainer.party[i].species = rand(890)+1
        $Trainer.party[i].name=PBSpecies.getName($Trainer.party[i].species)
        $Trainer.party[i].calcStats
        $Trainer.party[i].resetMoves
      end
    end
    # Pass on Pokérus within the party
    if @internalBattle
      infected = []
      $Trainer.party.each_with_index do |pkmn,i|
        infected.push(i) if pkmn.pokerusStage==1
      end
      infected.each do |idxParty|
        strain = $Trainer.party[idxParty].pokerusStrain
        if idxParty>0 && $Trainer.party[idxParty-1].pokerusStage==0
          $Trainer.party[idxParty-1].givePokerus(strain) if rand(3)==0   # 33%
        end
        if idxParty<$Trainer.party.length-1 && $Trainer.party[idxParty+1].pokerusStage==0
          $Trainer.party[idxParty+1].givePokerus(strain) if rand(3)==0   # 33%
        end
      end
    end
    # Clean up battle stuff
    @scene.pbEndBattle(@decision)
    @battlers.each do |b|
      next if !b
      pbCancelChoice(b.index)   # Restore unused items to Bag
      BattleHandlers.triggerAbilityOnSwitchOut(b.ability,b,true) if b.abilityActive?
    end
    pbParty(0).each_with_index do |pkmn,i|
      next if !pkmn
      @peer.pbOnLeavingBattle(self,pkmn,@usedInBattle[0][i],true)   # Reset form
      pkmn.setItem(@initialItems[0][i] || 0)
    end
    return @decision
  end
end
################################################################################
# Wild Battles                                                                 #
################################################################################
def pbModWildBattle(vsT, vsO, species1, level1, species2 = nil, level2 = nil,
    species3 = nil, level3 = nil, species4 = nil, level4 = nil,
    species5 = nil, level5 = nil, outcomeVar=1, gender1 = nil, 
    gender2 = nil, gender3 = nil, gender4 = nil, gender5 = nil,
    form1 = nil, form2 = nil, form3 = nil, form4 = nil, form5 = nil,
    item1 = nil, item2 = nil, item3 = nil, item4 = nil, item5 = nil,
    canRun=true, canLose=false, shinysprite1 = nil, shinysprite2 = nil, 
    shinysprite3 = nil, shinysprite4 = nil, shinysprite5 = nil,
    p1move1 = nil, p1move2 = nil, p1move3 = nil, p1move4 = nil,
    p2move1 = nil, p2move2 = nil, p2move3 = nil, p2move4 = nil,
    p3move1 = nil, p3move2 = nil, p3move3 = nil, p3move4 = nil,
    p4move1 = nil, p4move2 = nil, p4move3 = nil, p4move4 = nil,
    p5move1 = nil, p5move2 = nil, p5move3 = nil, p5move4 = nil)
  # Set some battle rules
  setBattleRule("outcomeVar",outcomeVar) if outcomeVar!=1
  if vsT>=3 || vsO>=3
   $PokemonSystem.activebattle=true
  end
  if $game_switches[CANT_FLEE]==true
  setBattleRule("cannotRun")
  else
  setBattleRule("cannotRun") if !canRun
  end
  setBattleRule("canLose") if canLose
  if vsT==1
   if vsO==1
   setBattleRule("1v1")
   elsif vsO==2
   setBattleRule("1v2")
   elsif vsO==3
   setBattleRule("1v3")
   elsif vsO==4
   setBattleRule("1v4")
   elsif vsO==5
   setBattleRule("1v5")
   end
  elsif vsT==2
   if vsO==1
   setBattleRule("2v1")
   elsif vsO==2
   setBattleRule("2v2")
   elsif vsO==3
   setBattleRule("2v3")
   elsif vsO==4
   setBattleRule("2v4")
   elsif vsO==5
   setBattleRule("2v5")
   end
  elsif vsT==3
   if vsO==1
   setBattleRule("3v1")
   elsif vsO==2
   setBattleRule("3v2")
   elsif vsO==3
   setBattleRule("3v3")
   elsif vsO==4
   setBattleRule("3v4")
   elsif vsO==5
   setBattleRule("3v5")
   end
  elsif vsT==4
   if vsO==1
   setBattleRule("4v1")
   elsif vsO==2
   setBattleRule("4v2")
   elsif vsO==3
   setBattleRule("4v3")
   elsif vsO==4
   setBattleRule("4v4")
   elsif vsO==5
   setBattleRule("4v5")
   end
  elsif vsT==5
   if vsO==1
   setBattleRule("5v1")
   elsif vsO==2
   setBattleRule("5v2")
   elsif vsO==3
   setBattleRule("5v3")
   elsif vsO==4
   setBattleRule("5v4")
   elsif vsO==5
   setBattleRule("5v5")
   end
  end
  # Perform the battle
  if vsO==1
  decision = pbWildBattleCore(
  [species1,level1,gender1,form1,shinysprite1,p1move1,p1move2,p1move3,p1move4,item1])
  elsif vsO==2
  decision = pbWildBattleCore(
  [species1,level1,gender1,form1,shinysprite1,p1move1,p1move2,p1move3,p1move4,item1],
  [species2,level2,gender2,form2,shinysprite2,p2move1,p2move2,p2move3,p2move4,item2])
  elsif vsO==3
  decision = pbWildBattleCore(
  [species1,level1,gender1,form1,shinysprite1,p1move1,p1move2,p1move3,p1move4,item1],
  [species2,level2,gender2,form2,shinysprite2,p2move1,p2move2,p2move3,p2move4,item2],
  [species3,level3,gender3,form3,shinysprite3,p3move1,p3move2,p3move3,p3move4,item3])
  elsif vsO==4
  decision = pbWildBattleCore(
  [species1,level1,gender1,form1,shinysprite1,p1move1,p1move2,p1move3,p1move4,item1],
  [species2,level2,gender2,form2,shinysprite2,p2move1,p2move2,p2move3,p2move4,item2],
  [species3,level3,gender3,form3,shinysprite3,p3move1,p3move2,p3move3,p3move4,item3],
  [species4,level4,gender4,form4,shinysprite4,p4move1,p4move2,p4move3,p4move4,item4])
  elsif vsO==5
  decision = pbWildBattleCore(
  [species1,level1,gender1,form1,shinysprite1,p1move1,p1move2,p1move3,p1move4,item1],
  [species2,level2,gender2,form2,shinysprite2,p2move1,p2move2,p2move3,p2move4,item2],
  [species3,level3,gender3,form3,shinysprite3,p3move1,p3move2,p3move3,p3move4,item3],
  [species4,level4,gender4,form4,shinysprite4,p4move1,p4move2,p4move3,p4move4,item4],
  [species5,level5,gender5,form5,shinysprite5,p5move1,p5move2,p5move3,p5move4,item5])
  end
  # Return false if the player lost or drew the battle, and true if any other result
  return (decision!=2 && decision!=5)
end
################################################################################
# Trainer Battles                                                              #
################################################################################
def pbModTrBat(vsT,vsO,trainerID1,trainerName1,trainerID2=nil,trainerName2=nil,
               trainerID3=nil,trainerName3=nil,trainerID4=nil,trainerName4=nil,
			   trainerID5=nil,trainerName5=nil,
              trainerPartyID1=0,trainerPartyID2=0,trainerPartyID3=0,trainerPartyID4=0,trainerPartyID5=0,
              endSpeech1=nil,endSpeech2=nil,endSpeech3=nil,endSpeech4=nil,endSpeech5=nil,
              canLose=false, outcomeVar=1)
  # Set some battle rules
  if vsT>=3 || vsO>=3
   $PokemonSystem.activebattle=true
  end
  setBattleRule("outcomeVar",outcomeVar) if outcomeVar!=1
  setBattleRule("canLose") if canLose
  if vsT==1
   if vsO==1
    setBattleRule("1v1")
   elsif vsO==2
    setBattleRule("1v2")
   elsif vsO==3
    setBattleRule("1v3")
   elsif vsO==4
    setBattleRule("1v4")
   elsif vsO==5
    setBattleRule("1v5")
   end
  elsif vsT==2
   if vsO==1
    setBattleRule("2v1")
   elsif vsO==2
    setBattleRule("2v2")
   elsif vsO==3
    setBattleRule("2v3")
   elsif vsO==4
    setBattleRule("2v4")
   elsif vsO==5
    setBattleRule("2v5")
   end
  elsif vsT==3
   if vsO==1
    setBattleRule("3v1")
   elsif vsO==2
    setBattleRule("3v2")
   elsif vsO==3
    setBattleRule("3v3")
   elsif vsO==4
    setBattleRule("3v4")
   elsif vsO==5
    setBattleRule("3v5")
   end
  elsif vsT==4
   if vsO==1
    setBattleRule("4v1")
   elsif vsO==2
    setBattleRule("4v2")
   elsif vsO==3
    setBattleRule("4v3")
   elsif vsO==4
    setBattleRule("4v4")
   elsif vsO==5
    setBattleRule("4v5")
   end
  elsif vsT==5
   if vsO==1
    setBattleRule("5v1")
   elsif vsO==2
    setBattleRule("5v2")
   elsif vsO==3
    setBattleRule("5v3")
   elsif vsO==4
    setBattleRule("5v4")
   elsif vsO==5
    setBattleRule("5v5")
   end
  end
  # Perform the battle
  if vsO==1
  decision = pbTrainerBattleCore([trainerID1,trainerName1,trainerPartyID1,endSpeech1])
  elsif vsO==2
  decision = pbTrainerBattleCore([trainerID1,trainerName1,trainerPartyID1,endSpeech1],[trainerID2,trainerName2,trainerPartyID2,endSpeech2])
  elsif vsO==3
  decision = pbTrainerBattleCore([trainerID1,trainerName1,trainerPartyID1,endSpeech1],[trainerID2,trainerName2,trainerPartyID2,endSpeech2],[trainerID3,trainerName3,trainerPartyID3,endSpeech3])
  elsif vsO==4
  decision = pbTrainerBattleCore([trainerID1,trainerName1,trainerPartyID1,endSpeech1],[trainerID2,trainerName2,trainerPartyID2,endSpeech2],[trainerID3,trainerName3,trainerPartyID3,endSpeech3],[trainerID4,trainerName4,trainerPartyID4,endSpeech4])
  elsif vsO==5
  decision = pbTrainerBattleCore([trainerID1,trainerName1,trainerPartyID1,endSpeech1],[trainerID2,trainerName2,trainerPartyID2,endSpeech2],[trainerID3,trainerName3,trainerPartyID3,endSpeech3],[trainerID4,trainerName4,trainerPartyID4,endSpeech4],[trainerID5,trainerName5,trainerPartyID5,endSpeech5])
  end
  # Return true if the player won the battle, and false if any other result
  return (decision==1)
end
class PokemonTemp
  def recordBattleRule(rule,var=nil)
    rules = self.battleRules
    case rule.to_s.downcase
    when "1v1", "1v2", "1v3", "1v4", "1v5", "single",
         "2v1", "2v2", "2v3", "2v4", "2v5", "double",
         "3v1", "3v2", "3v3", "3v4", "3v5", "triple",
         "4v1", "4v2", "4v3", "4v4", "5v5", "quad",
         "5v1", "5v2", "5v3", "5v4", "4v5", "quin"
      rules["size"] = rule.to_s.downcase
    when "canlose";                rules["canLose"]        = true
    when "cannotlose";             rules["canLose"]        = false
    when "canrun";                 rules["canRun"]         = true
    when "cannotrun";              rules["canRun"]         = false
    when "roamerflees";            rules["roamerFlees"]    = true
    when "noExp";                  rules["expGain"]        = false
    when "noMoney";                rules["moneyGain"]      = false
    when "switchstyle";            rules["switchStyle"]    = true
    when "setstyle";               rules["switchStyle"]    = false
    when "anims";                  rules["battleAnims"]    = true
    when "noanims";                rules["battleAnims"]    = false
    when "terrain";                rules["defaultTerrain"] = getID(PBBattleTerrains,var)
    when "weather";                rules["defaultWeather"] = getID(PBWeather,var)
    when "environment", "environ"; rules["environment"]    = getID(PBEnvironment,var)
    when "backdrop", "battleback"; rules["backdrop"]       = var
    when "base";                   rules["base"]           = var
    when "outcomevar", "outcome";  rules["outcomeVar"]     = var
    when "nopartner";              rules["noPartner"]      = true
    else
      raise _INTL("Battle rule \"{1}\" does not exist.",rule)
    end
  end
end
def pbCanQuadBattle?
  return true if $Trainer.ablePokemonCount>=4
  return $PokemonGlobal.partner && $Trainer.ablePokemonCount>=4
end
def pbCanQuinBattle?
  return true if $Trainer.ablePokemonCount>=5
  return $PokemonGlobal.partner && $Trainer.ablePokemonCount>=5
end
#===============================================================================
# Start a wild battle
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
      if arg.length()==10
        gender = arg[2]
        pkmn.setGender(gender) if USEFEMALESPRITES==true and gender!=nil and gender>=0 and gender<3
        form = arg[3]
        pkmn.form = form if USEALTFORMS==true and form!=nil and form>0
        shinyflag = arg[4]
        pkmn.shinyflag = shinyflag if shinyflag!=nil
        move1 = arg[5]
        pkmn.pbLearnMove(move1) if move1!=nil
        move2 = arg[6]
        pkmn.pbLearnMove(move2) if move2!=nil
        move3 = arg[7]
        pkmn.pbLearnMove(move3) if move3!=nil
        move4 = arg[8]
        pkmn.pbLearnMove(move4) if move4!=nil
        item = arg[9]
        pkmn.setItem(item) if item!=nil
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
    if $PokemonSystem.activebattle==true
     newWindowSize
     Win32API.restoreScreen
    end
    pbSceneStandby {
      decision = battle.pbStartBattle
    }
    pbAfterBattle(decision,canLose)
    if $PokemonSystem.activebattle==true
	   $PokemonSystem.activebattle=false
     newWindowSize
     Win32API.restoreScreen
    end
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
# Start a trainer battle
#===============================================================================
def pbTrainerBattleCore(*args)
  outcomeVar = $PokemonTemp.battleRules["outcomeVar"] || 1
  canLose    = $PokemonTemp.battleRules["canLose"] || false
  # Skip battle if the player has no able Pokémon, or if holding Ctrl in Debug mode
  if $Trainer.ablePokemonCount==0 || ($DEBUG && Input.press?(Input::CTRL))
    pbMessage(_INTL("SKIPPING BATTLE...")) if $DEBUG
    pbMessage(_INTL("AFTER WINNING...")) if $DEBUG && $Trainer.ablePokemonCount>0
    pbSet(outcomeVar,($Trainer.ablePokemonCount==0) ? 0 : 1)   # Treat it as undecided/a win
    $PokemonTemp.clearBattleRules
    $PokemonGlobal.nextBattleBGM       = nil
    $PokemonGlobal.nextBattleME        = nil
    $PokemonGlobal.nextBattleCaptureME = nil
    $PokemonGlobal.nextBattleBack      = nil
    return ($Trainer.ablePokemonCount==0) ? 0 : 1   # Treat it as undecided/a win
  end
  # Record information about party Pokémon to be used at the end of battle (e.g.
  # comparing levels for an evolution check)
  Events.onStartBattle.trigger(nil)
  # Generate trainers and their parties based on the arguments given
  foeTrainers    = []
  foeItems       = []
  foeEndSpeeches = []
  foeParty       = []
  foePartyStarts = []
  for arg in args
    raise _INTL("Expected an array of trainer data, got {1}.",arg) if !arg.is_a?(Array)
    if arg[0].is_a?(PokeBattle_Trainer)
      # [trainer object, party, end speech, items]
      foeTrainers.push(arg[0])
      foePartyStarts.push(foeParty.length)
      arg[1].each { |pkmn| foeParty.push(pkmn) }
      foeEndSpeeches.push(arg[2])
      foeItems.push(arg[3])
    else
      # [trainer type, trainer name, ID, speech (optional)]
      trainer = pbLoadTrainer(arg[0],arg[1],arg[2])
      pbMissingTrainer(arg[0],arg[1],arg[2]) if !trainer
      return 0 if !trainer
      Events.onTrainerPartyLoad.trigger(nil,trainer)
      foeTrainers.push(trainer[0])
      foePartyStarts.push(foeParty.length)
      trainer[2].each { |pkmn| foeParty.push(pkmn) }
      foeEndSpeeches.push(arg[3] || trainer[3])
      foeItems.push(trainer[1])
    end
  end
  # Calculate who the player trainer(s) and their party are
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
  battle = PokeBattle_Battle.new(scene,playerParty,foeParty,playerTrainers,foeTrainers)
  battle.party1starts = playerPartyStarts
  battle.party2starts = foePartyStarts
  battle.items        = foeItems
  battle.endSpeeches  = foeEndSpeeches
  # Set various other properties in the battle class
  pbPrepareBattle(battle)
  $PokemonTemp.clearBattleRules
  # End the trainer intro music
  Audio.me_stop
  # Perform the battle itself
  decision = 0
  pbBattleAnimation(pbGetTrainerBattleBGM(foeTrainers),(battle.singleBattle?) ? 1 : 3,foeTrainers) {
    newWindowSize
    Win32API.restoreScreen
    pbSceneStandby {
      decision = battle.pbStartBattle
    }
    pbAfterBattle(decision,canLose)
	$PokemonSystem.activebattle=false
    newWindowSize
    Win32API.restoreScreen
  }
  Input.update
  # Save the result of the battle in a Game Variable (1 by default)
  #    0 - Undecided or aborted
  #    1 - Player won
  #    2 - Player lost
  #    3 - Player or wild Pokémon ran from battle, or player forfeited the match
  #    5 - Draw
  pbSet(outcomeVar,decision)
  return decision
end
#===============================================================================
# Target menu (choose a move's target)
# NOTE: Unlike the command and fight menus, this one doesn't have a textbox-only
#       version.
#===============================================================================
class TargetMenuDisplay < BattleMenuBase
  attr_accessor :mode

  # Lists of which button graphics to use in different situations/types of battle.
  MODES = [
     [0,2,1,3],  # 0 = Regular battle
     [0,2,1,9],  # 1 = Regular battle with "Cancel" instead of "Run"
     [0,2,1,4],  # 2 = Regular battle with "Call" instead of "Run"
     [5,7,6,3],  # 3 = Safari Zone
     [0,8,1,3]    # 4 = Bug Catching Contest
  ]
  CMD_BUTTON_WIDTH_SMALL = 170
  ACT_CMD_BUTTON_WIDTH_SMALL = 128
  TEXT_BASE_COLOR   = Color.new(0,0,0)
  TEXT_SHADOW_COLOR = Color.new(255,255,255)

  def initialize(viewport,z,sideSizes)
    super(viewport)
    @sideSizes = sideSizes
    maxIndex = (@sideSizes[0]>@sideSizes[1]) ? (@sideSizes[0]-1)*2 : @sideSizes[1]*2-1
    @smallButtons = @sideSizes.max
    self.x = 0
    self.y = Graphics.height-96
    @texts = []
    # NOTE: @mode is for which buttons are shown as selected.
    #       0=select 1 button (@index), 1=select all buttons with text
    # Create bitmaps
	if $PokemonSystem.activebattle==true
    @buttonBitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/ActiveBattle/Battle/cursor_target"))
	else
    @buttonBitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/cursor_target"))
	end
    # Create target buttons
    @buttons = Array.new(maxIndex+1) do |i|
      numButtons = @sideSizes[i%2]
      next if numButtons<=i/2
      # NOTE: Battler indexes go from left to right from the perspective of
      #       that side's trainer, so inc is different for each side for the
      #       same value of i/2.
      inc = ((i%2)==0) ? i/2 : numButtons-1-i/2
      button = SpriteWrapper.new(viewport)
      button.bitmap = @buttonBitmap.bitmap
	  if $PokemonSystem.activebattle==true
      button.src_rect.width  = (@smallButtons) ? ACT_CMD_BUTTON_WIDTH_SMALL : @buttonBitmap.width/2
	  else
      button.src_rect.width  = (@smallButtons) ? CMD_BUTTON_WIDTH_SMALL : @buttonBitmap.width/2
	  end
      button.src_rect.height = BUTTON_HEIGHT
      if @smallButtons==5
        button.x    = self.x+388-[0,82,166,248,332][numButtons-1]
      elsif @smallButtons==4
        button.x    = self.x+180-[0,82,166,248][numButtons-1]
      elsif @smallButtons==3
        button.x    = self.x+170-[0,82,166][numButtons-1]
      else
        button.x    = self.x+138-[0,116][numButtons-1]
      end
      button.x      += (button.src_rect.width-4)*inc
      button.y      = self.y+6
      button.y      += (BUTTON_HEIGHT-4)*((i+1)%2)
      addSprite("button_#{i}",button)
      next button
    end
    # Create overlay (shows target names)
    @overlay = BitmapSprite.new(Graphics.width,Graphics.height-self.y,viewport)
    @overlay.x = self.x
    @overlay.y = self.y
    pbSetNarrowFont(@overlay.bitmap)
    addSprite("overlay",@overlay)
    self.z = z
    refresh
  end

  def dispose
    super
    @buttonBitmap.dispose if @buttonBitmap
  end

  def z=(value)
    super
    @overlay.z += 5 if @overlay
  end

  def setDetails(texts,mode)
    @texts = texts
    @mode  = mode
    refresh
  end

  def refreshButtons
    # Choose appropriate button graphics and z positions
    @buttons.each_with_index do |button,i|
      next if !button
      sel = false
      buttonType = 0
      if @texts[i]
        sel ||= (@mode==0 && i==@index)
        sel ||= (@mode==1)
        buttonType = ((i%2)==0) ? 1 : 2
      end
      buttonType = 2*buttonType + ((@smallButtons) ? 1 : 0)
      button.src_rect.x = (sel) ? @buttonBitmap.width/2 : 0
      button.src_rect.y = buttonType*BUTTON_HEIGHT
      button.z          = self.z + ((sel) ? 3 : 2)
    end
    # Draw target names onto overlay
    @overlay.bitmap.clear
    textpos = []
    @buttons.each_with_index do |button,i|
      next if !button || @texts[i].nil? || @texts[i]==""
      x = button.x-self.x+button.src_rect.width/2
      y = button.y-self.y+8
      textpos.push([@texts[i],x,y,2,TEXT_BASE_COLOR,TEXT_SHADOW_COLOR])
    end
    pbDrawTextPositions(@overlay.bitmap,textpos)
  end

  def refresh
    refreshButtons
  end
end
module RPG
  module Cache
    def self.battleback(filename)
     if $PokemonSysteml.activebattle==true
      self.load_bitmap("Graphics/Battlebacks/Active", filename)
     else
      self.load_bitmap("Graphics/Battlebacks/", filename)
     end
    end
  end
end
class PokeBattle_Scene
  def pbInitSprites
    @sprites = {}
    # The background image and each side's base graphic
    pbCreateBackdropSprites
    # Create message box graphic
	if $PokemonSystem.activebattle==true
    messageBox = pbAddSprite("messageBox",0,Graphics.height-96,
       "Graphics/Pictures/ActiveBattle/Battle/overlay_message",@viewport)
	else
    messageBox = pbAddSprite("messageBox",0,Graphics.height-96,
       "Graphics/Pictures/Battle/overlay_message",@viewport)
    end
    messageBox.z = 195
    # Create message window (displays the message)
    msgWindow = Window_AdvancedTextPokemon.newWithSize("",
       16,Graphics.height-96+2,Graphics.width-32,96,@viewport)
    msgWindow.z              = 200
    msgWindow.opacity        = 0
    msgWindow.baseColor      = PokeBattle_SceneConstants::MESSAGE_BASE_COLOR
    msgWindow.shadowColor    = PokeBattle_SceneConstants::MESSAGE_SHADOW_COLOR
    msgWindow.letterbyletter = true
    @sprites["messageWindow"] = msgWindow
    # Create command window
    @sprites["commandWindow"] = CommandMenuDisplay.new(@viewport,200)
    # Create fight window
    @sprites["fightWindow"] = FightMenuDisplay.new(@viewport,200)
    # Create targeting window
    @sprites["targetWindow"] = TargetMenuDisplay.new(@viewport,200,@battle.sideSizes)
    pbShowWindow(MESSAGE_BOX)
    # The party lineup graphics (bar and balls) for both sides
    for side in 0...2
      partyBar = pbAddSprite("partyBar_#{side}",0,0,
         "Graphics/Pictures/Battle/overlay_lineup",@viewport)
      partyBar.z       = 120
      partyBar.mirror  = true if side==0   # Player's lineup bar only
      partyBar.visible = false
      for i in 0...PokeBattle_SceneConstants::NUM_BALLS
        ball = pbAddSprite("partyBall_#{side}_#{i}",0,0,nil,@viewport)
        ball.z       = 121
        ball.visible = false
      end
      # Ability splash bars
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        @sprites["abilityBar_#{side}"] = AbilitySplashBar.new(side,@viewport)
      end
    end
    # Player's and partner trainer's back sprite
    @battle.player.each_with_index do |p,i|
      pbCreateTrainerBackSprite(i,p.trainertype,@battle.player.length)
    end
    # Opposing trainer(s) sprites
    if @battle.trainerBattle?
      @battle.opponent.each_with_index do |p,i|
        pbCreateTrainerFrontSprite(i,p.trainertype,@battle.opponent.length)
      end
    end
    # Data boxes and Pokémon sprites
    @battle.battlers.each_with_index do |b,i|
      next if !b
      @sprites["dataBox_#{i}"] = PokemonDataBox.new(b,@battle.pbSideSize(i),@viewport)
      pbCreatePokemonSprite(i)
    end
    # Wild battle, so set up the Pokémon sprite(s) accordingly
    if @battle.wildBattle?
      @battle.pbParty(1).each_with_index do |pkmn,i|
        index = i*2+1
        pbChangePokemon(index,pkmn)
        pkmnSprite = @sprites["pokemon_#{index}"]
        pkmnSprite.tone    = Tone.new(-80,-80,-80)
        pkmnSprite.visible = true
      end
    end
  end
  def pbCreateBackdropSprites
    case @battle.time
    when 1; time = "eve"
    when 2; time = "night"
    end
    # Put everything together into backdrop, bases and message bar filenames
    backdropFilename = @battle.backdrop
    baseFilename = @battle.backdrop
    baseFilename = sprintf("%s_%s",baseFilename,@battle.backdropBase) if @battle.backdropBase
    messageFilename = @battle.backdrop
    if time && $PokemonSystem.activebattle==true
      trialName = sprintf("%s_%s",backdropFilename,time)
      if pbResolveBitmap(sprintf("Graphics/Battlebacks/Active/"+trialName+"_bg"))
        backdropFilename = trialName
      end
      trialName = sprintf("%s_%s",baseFilename,time)
      if pbResolveBitmap(sprintf("Graphics/Battlebacks/Active/"+trialName+"_base0"))
        baseFilename = trialName
      end
      trialName = sprintf("%s_%s",messageFilename,time)
      if pbResolveBitmap(sprintf("Graphics/Battlebacks/Active/"+trialName+"_message"))
        messageFilename = trialName
      end
	elsif time && $PokemonSystem.activebattle==false
      trialName = sprintf("%s_%s",backdropFilename,time)
      if pbResolveBitmap(sprintf("Graphics/Battlebacks/"+trialName+"_bg"))
        backdropFilename = trialName
      end
      trialName = sprintf("%s_%s",baseFilename,time)
      if pbResolveBitmap(sprintf("Graphics/Battlebacks/"+trialName+"_base0"))
        baseFilename = trialName
      end
      trialName = sprintf("%s_%s",messageFilename,time)
      if pbResolveBitmap(sprintf("Graphics/Battlebacks/"+trialName+"_message"))
        messageFilename = trialName
      end
    end
	if $PokemonSystem.activebattle==true
    if !pbResolveBitmap(sprintf("Graphics/Battlebacks/Active/"+baseFilename+"_base0")) &&
       @battle.backdropBase
      baseFilename = @battle.backdropBase
      if time
        trialName = sprintf("%s_%s",baseFilename,time)
        if pbResolveBitmap(sprintf("Graphics/Battlebacks/Active/"+trialName+"_base0"))
          baseFilename = trialName
        end
      end
    end
	else
    if !pbResolveBitmap(sprintf("Graphics/Battlebacks/"+baseFilename+"_base0")) &&
       @battle.backdropBase
      baseFilename = @battle.backdropBase
      if time
        trialName = sprintf("%s_%s",baseFilename,time)
        if pbResolveBitmap(sprintf("Graphics/Battlebacks/"+trialName+"_base0"))
          baseFilename = trialName
        end
      end
    end
	end
    # Finalise filenames
	if $PokemonSystem.activebattle==true
     battleBG   = "Graphics/Battlebacks/Active/"+backdropFilename+"_bg"
     playerBase = "Graphics/Battlebacks/Active/"+baseFilename+"_base0"
     enemyBase  = "Graphics/Battlebacks/Active/"+baseFilename+"_base1"
     messageBG  = "Graphics/Battlebacks/Active/"+messageFilename+"_message"
	else
     battleBG   = "Graphics/Battlebacks/"+backdropFilename+"_bg"
     playerBase = "Graphics/Battlebacks/"+baseFilename+"_base0"
     enemyBase  = "Graphics/Battlebacks/"+baseFilename+"_base1"
     messageBG  = "Graphics/Battlebacks/"+messageFilename+"_message"
	end
    # Apply graphics
    bg = pbAddSprite("battle_bg",0,0,battleBG,@viewport)
    bg.z = 0
    bg = pbAddSprite("battle_bg2",-Graphics.width,0,battleBG,@viewport)
    bg.z      = 0
    bg.mirror = true
    for side in 0...2
      baseX, baseY = PokeBattle_SceneConstants.pbBattlerPosition(side)
      base = pbAddSprite("base_#{side}",baseX,baseY,
         (side==0) ? playerBase : enemyBase,@viewport)
      base.z    = 1
      if base.bitmap
        base.ox = base.bitmap.width/2
        base.oy = (side==0) ? base.bitmap.height : base.bitmap.height/2
      end
    end
    cmdBarBG = pbAddSprite("cmdBar_bg",0,Graphics.height-96,messageBG,@viewport)
    cmdBarBG.z = 180
  end
  #=============================================================================
  # Opens the party screen to choose a Pokémon to switch in (or just view its
  # summary screens)
  #=============================================================================
  def pbPartyScreen(idxBattler,canCancel=false)
    if $PokemonSystem.activebattle==true
	resetWindowSize
	end
    # Fade out and hide all sprites
    visibleSprites = pbFadeOutAndHide(@sprites)
    # Get player's party
    partyPos = @battle.pbPartyOrder(idxBattler)
    partyStart, _partyEnd = @battle.pbTeamIndexRangeFromBattlerIndex(idxBattler)
    modParty = @battle.pbPlayerDisplayParty(idxBattler)
    # Start party screen
    scene = PokemonParty_Scene.new
    switchScreen = PokemonPartyScreen.new(scene,modParty)
    switchScreen.pbStartScene(_INTL("Choose a Pokémon."),@battle.pbNumPositions(0,0))
    # Loop while in party screen
    loop do
      # Select a Pokémon
      scene.pbSetHelpText(_INTL("Choose a Pokémon."))
      idxParty = switchScreen.pbChoosePokemon
      if idxParty<0
        next if !canCancel
        break
      end
      # Choose a command for the selected Pokémon
      cmdSwitch  = -1
      cmdSummary = -1
      commands = []
      commands[cmdSwitch  = commands.length] = _INTL("Switch In") if modParty[idxParty].able?
      commands[cmdSummary = commands.length] = _INTL("Summary")
      commands[commands.length]              = _INTL("Cancel")
      command = scene.pbShowCommands(_INTL("Do what with {1}?",modParty[idxParty].name),commands)
      if cmdSwitch>=0 && command==cmdSwitch        # Switch In
        idxPartyRet = -1
        partyPos.each_with_index do |pos,i|
          next if pos!=idxParty+partyStart
          idxPartyRet = i
          break
        end
        break if yield idxPartyRet, switchScreen
      elsif cmdSummary>=0 && command==cmdSummary   # Summary
        scene.pbSummary(idxParty,true)
      end
    end
    # Close party screen
    switchScreen.pbEndScene
    if $PokemonSystem.activebattle==true
	newWindowSize
	end
    # Fade back into battle screen
    pbFadeInAndShow(@sprites,visibleSprites)
  end
  #=============================================================================
  # Opens the Bag screen and chooses an item to use
  #=============================================================================
  def pbItemMenu(idxBattler,_firstAction)
    if $PokemonSystem.activebattle==true
     resetWindowSize
    end
    # Fade out and hide all sprites
    visibleSprites = pbFadeOutAndHide(@sprites)
    # Set Bag starting positions
    oldLastPocket = $PokemonBag.lastpocket
    oldChoices    = $PokemonBag.getAllChoices
    $PokemonBag.lastpocket = @bagLastPocket if @bagLastPocket!=nil
    $PokemonBag.setAllChoices(@bagChoices) if @bagChoices!=nil
    # Start Bag screen
    itemScene = PokemonBag_Scene.new
    itemScene.pbStartScene($PokemonBag,true,Proc.new { |item|
      useType = pbGetItemData(item,ITEM_BATTLE_USE)
      next useType && useType>0
      },false)
    # Loop while in Bag screen
    wasTargeting = false
    loop do
      # Select an item
      item = itemScene.pbChooseItem
      break if item==0
      # Choose a command for the selected item
      itemName = PBItems.getName(item)
      useType = pbGetItemData(item,ITEM_BATTLE_USE)
      cmdUse = -1
      commands = []
      commands[cmdUse = commands.length] = _INTL("Use") if useType && useType!=0
      commands[commands.length]          = _INTL("Cancel")
      command = itemScene.pbShowCommands(_INTL("{1} is selected.",itemName),commands)
      next unless cmdUse>=0 && command==cmdUse   # Use
      # Use types:
      # 0 = not usable in battle
      # 1 = use on Pokémon (lots of items), consumed
      # 2 = use on Pokémon's move (Ethers), consumed
      # 3 = use on battler (X items, Persim Berry), consumed
      # 4 = use on opposing battler (Poké Balls), consumed
      # 5 = use no target (Poké Doll, Guard Spec., Launcher items), consumed
      # 6 = use on Pokémon (Blue Flute), not consumed
      # 7 = use on Pokémon's move, not consumed
      # 8 = use on battler (Red/Yellow Flutes), not consumed
      # 9 = use on opposing battler, not consumed
      # 10 = use no target (Poké Flute), not consumed
      case useType
      when 1, 2, 3, 6, 7, 8   # Use on Pokémon/Pokémon's move/battler
        # Auto-choose the Pokémon/battler whose action is being decided if they
        # are the only available Pokémon/battler to use the item on
        case useType
        when 1, 6   # Use on Pokémon
          if @battle.pbTeamLengthFromBattlerIndex(idxBattler)==1
            break if yield item, useType, @battle.battlers[idxBattler].pokemonIndex, -1, itemScene
          end
        when 3, 8   # Use on battler
          if @battle.pbPlayerBattlerCount==1
            break if yield item, useType, @battle.battlers[idxBattler].pokemonIndex, -1, itemScene
          end
        end
        # Fade out and hide Bag screen
        itemScene.pbFadeOutScene
        # Get player's party
        party    = @battle.pbParty(idxBattler)
        partyPos = @battle.pbPartyOrder(idxBattler)
        partyStart, _partyEnd = @battle.pbTeamIndexRangeFromBattlerIndex(idxBattler)
        modParty = @battle.pbPlayerDisplayParty(idxBattler)
        # Start party screen
        pkmnScene = PokemonParty_Scene.new
        pkmnScreen = PokemonPartyScreen.new(pkmnScene,modParty)
        pkmnScreen.pbStartScene(_INTL("Use on which Pokémon?"),@battle.pbNumPositions(0,0))
        idxParty = -1
        # Loop while in party screen
        loop do
          # Select a Pokémon
          pkmnScene.pbSetHelpText(_INTL("Use on which Pokémon?"))
          idxParty = pkmnScreen.pbChoosePokemon
          break if idxParty<0
          idxPartyRet = -1
          partyPos.each_with_index do |pos,i|
            next if pos!=idxParty+partyStart
            idxPartyRet = i
            break
          end
          next if idxPartyRet<0
          pkmn = party[idxPartyRet]
          next if !pkmn || pkmn.egg?
          idxMove = -1
          if useType==2 || useType==7   # Use on Pokémon's move
            idxMove = pkmnScreen.pbChooseMove(pkmn,_INTL("Restore which move?"))
            next if idxMove<0
          end
          break if yield item, useType, idxPartyRet, idxMove, pkmnScene
        end
        pkmnScene.pbEndScene
        break if idxParty>=0
         if $PokemonSystem.activebattle==true
          newWindowSize
         end
        # Cancelled choosing a Pokémon; show the Bag screen again
        itemScene.pbFadeInScene
      when 4, 9   # Use on opposing battler (Poké Balls)
	    if $PokemonSystem.activebattle==true
         resetWindowSize
        end
        idxTarget = -1
        if @battle.pbOpposingBattlerCount(idxBattler)==1
          @battle.eachOtherSideBattler(idxBattler) { |b| idxTarget = b.index }
          break if yield item, useType, idxTarget, -1, itemScene
        else
          wasTargeting = true
          # Fade out and hide Bag screen
          itemScene.pbFadeOutScene
	        if $PokemonSystem.activebattle==true
           newWindowSize
          end
          # Fade in and show the battle screen, choosing a target
          tempVisibleSprites = visibleSprites.clone
          tempVisibleSprites["commandWindow"] = false
          tempVisibleSprites["targetWindow"]  = true
          idxTarget = pbChooseTarget(idxBattler,PBTargets::Foe,tempVisibleSprites)
          if idxTarget>=0
            break if yield item, useType, idxTarget, -1, self
          end
          # Target invalid/cancelled choosing a target; show the Bag screen again
          wasTargeting = false
          pbFadeOutAndHide(@sprites)
          if $PokemonSystem.activebattle==true
           resetWindowSize
          end
          itemScene.pbFadeInScene
        end
      when 5, 10   # Use with no target
        break if yield item, useType, idxBattler, -1, itemScene
      end
    end
    @bagLastPocket = $PokemonBag.lastpocket
    @bagChoices    = $PokemonBag.getAllChoices
    $PokemonBag.lastpocket = oldLastPocket
    $PokemonBag.setAllChoices(oldChoices)
    # Close Bag screen
    itemScene.pbEndScene
    if $PokemonSystem.activebattle==true
	 newWindowSize
	end
    # Fade back into battle screen (if not already showing it)
    pbFadeInAndShow(@sprites,visibleSprites) if !wasTargeting
  end
  #=============================================================================
  # Opens a Pokémon's summary screen to try to learn a new move
  #=============================================================================
  # Called whenever a Pokémon should forget a move. It should return -1 if the
  # selection is canceled, or 0 to 3 to indicate the move to forget. It should
  # not allow HM moves to be forgotten.
  def pbForgetMove(pkmn,moveToLearn)
    ret = -1
    pbFadeOutIn {
      if $PokemonSystem.activebattle==true
       resetWindowSize
      end
      scene = PokemonSummary_Scene.new
      screen = PokemonSummaryScreen.new(scene)
      ret = screen.pbStartForgetScreen([pkmn],0,moveToLearn)
    }
    return ret
  end
  #=============================================================================
  # Opens the nicknaming screen for a newly caught Pokémon
  #=============================================================================
  def pbNameEntry(helpText,pkmn)
   if $PokemonSystem.activebattle==true
    resetWindowSize
   end
    return pbEnterPokemonName(helpText,0,PokeBattle_Pokemon::MAX_POKEMON_NAME_SIZE,"",pkmn)
   if $PokemonSystem.activebattle==true
    newWindowSize
   end
  end
  #=============================================================================
  # Shows the Pokédex entry screen for a newly caught Pokémon
  #=============================================================================
  def pbShowPokedex(species)
    pbFadeOutIn {
      if $PokemonSystem.activebattle==true
       resetWindowSize
      end
      scene = PokemonPokedexInfo_Scene.new
      screen = PokemonPokedexInfoScreen.new(scene)
      screen.pbDexEntry(species)
    }
  end
end
class SpritePositioner
  def pbOpen
    @sprites = {}
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
	if $PokemonSystem.activebattle==true
     battlebg   = "Graphics/Battlebacks/Active/indoor1_bg"
     playerbase = "Graphics/Battlebacks/Active/indoor1_base0"
     enemybase  = "Graphics/Battlebacks/Active/indoor1_base1"
	else
     battlebg   = "Graphics/Battlebacks/indoor1_bg"
     playerbase = "Graphics/Battlebacks/indoor1_base0"
     enemybase  = "Graphics/Battlebacks/indoor1_base1"
	end
    @sprites["battle_bg"] = AnimatedPlane.new(@viewport)
    @sprites["battle_bg"].setBitmap(battlebg)
    @sprites["battle_bg"].z = 0
    baseX, baseY = PokeBattle_SceneConstants.pbBattlerPosition(0)
    @sprites["base_0"] = IconSprite.new(baseX,baseY,@viewport)
    @sprites["base_0"].setBitmap(playerbase)
    @sprites["base_0"].x -= @sprites["base_0"].bitmap.width/2 if @sprites["base_0"].bitmap
    @sprites["base_0"].y -= @sprites["base_0"].bitmap.height if @sprites["base_0"].bitmap
    @sprites["base_0"].z = 1
    baseX, baseY = PokeBattle_SceneConstants.pbBattlerPosition(1)
    @sprites["base_1"] = IconSprite.new(baseX,baseY,@viewport)
    @sprites["base_1"].setBitmap(enemybase)
    @sprites["base_1"].x -= @sprites["base_1"].bitmap.width/2 if @sprites["base_1"].bitmap
    @sprites["base_1"].y -= @sprites["base_1"].bitmap.height/2 if @sprites["base_1"].bitmap
    @sprites["base_1"].z = 1
    @sprites["messageBox"] = IconSprite.new(0,Graphics.height-96,@viewport)
    @sprites["messageBox"].setBitmap("Graphics/Pictures/Battle/debug_message")
    @sprites["messageBox"].z = 2
    @sprites["shadow_1"] = IconSprite.new(0,0,@viewport)
    @sprites["shadow_1"].z = 3
    @sprites["pokemon_0"] = PokemonSprite.new(@viewport)
    @sprites["pokemon_0"].setOffset(PictureOrigin::Bottom)
    @sprites["pokemon_0"].z = 4
    @sprites["pokemon_1"] = PokemonSprite.new(@viewport)
    @sprites["pokemon_1"].setOffset(PictureOrigin::Bottom)
    @sprites["pokemon_1"].z = 4
    @sprites["info"] = Window_UnformattedTextPokemon.new("")
    @sprites["info"].viewport = @viewport
    @sprites["info"].visible  = false
    @oldSpeciesIndex = 0
    @species = 0
    @metrics = pbLoadSpeciesMetrics
    @metricsChanged = false
    refresh
    @starting = true
  end
end
class PokemonPokedexInfoScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen(dexlist,index,region)
    @scene.pbStartScene(dexlist,index,region)
    ret = @scene.pbScene
    @scene.pbEndScene
    return ret   # Index of last species viewed in dexlist
  end

  def pbStartSceneSingle(species)   # For use from a Pokémon's summary screen
    region = -1
    if USE_CURRENT_REGION_DEX
      region = pbGetCurrentRegion
      region = -1 if region>=$PokemonGlobal.pokedexUnlocked.length-1
    else
      region = $PokemonGlobal.pokedexDex # National Dex -1, regional dexes 0 etc.
    end
    dexnum = pbGetRegionalNumber(region,species)
    dexnumshift = DEXES_WITH_OFFSETS.include?(region)
    dexlist = [[species,PBSpecies.getName(species),0,0,dexnum,dexnumshift]]
    if $PokemonSystem.activebattle==true
     newWindowSize
    end
    @scene.pbStartScene(dexlist,0,region)
    @scene.pbScene
    @scene.pbEndScene
  end

  def pbDexEntry(species)   # For use when capturing a new species
    @scene.pbStartSceneBrief(species)
    @scene.pbSceneBrief
    @scene.pbEndScene
  end
end
def pbEnterText(helptext,minlength,maxlength,initialText="",mode=0,pokemon=nil,nofadeout=false)
  ret=""
  if ($PokemonSystem.textinput==1 rescue false)   # Keyboard
    pbFadeOutIn(99999,nofadeout) {
       sscene=PokemonEntryScene.new
       sscreen=PokemonEntry.new(sscene)
       ret=sscreen.pbStartScreen(helptext,minlength,maxlength,initialText,mode,pokemon)
    }
  else   # Cursor
    pbFadeOutIn(99999,nofadeout) {
       sscene=PokemonEntryScene2.new
       sscreen=PokemonEntry.new(sscene)
       ret=sscreen.pbStartScreen(helptext,minlength,maxlength,initialText,mode,pokemon)
    }
  end
  return ret
end
class PokemonSummaryScreen
  def pbStartForgetScreen(party,partyindex,moveToLearn)
    ret = -1
    @scene.pbStartForgetScene(party,partyindex,moveToLearn)
    loop do
      ret = @scene.pbChooseMoveToForget(moveToLearn)
      if ret>=0 && moveToLearn!=0 && pbIsHiddenMove?(party[partyindex].moves[ret].id) && !$DEBUG
        pbMessage(_INTL("HM moves can't be forgotten now.")) { @scene.pbUpdate }
      else
        break
      end
    end
      if $PokemonSystem.activebattle==true
       newWindowSize
      end
    @scene.pbEndScene
    return ret
  end
end
#===============================================================================
# Splash bar to announce a triggered ability
#===============================================================================
class AbilitySplashBar < SpriteWrapper
  attr_reader :battler

  TEXT_BASE_COLOR   = Color.new(255,255,255)
  TEXT_SHADOW_COLOR = Color.new(0,0,0)

  def initialize(side,viewport=nil)
    super(viewport)
    @side    = side
    @battler = nil
    # Create sprite wrapper that displays background graphic
    @bgBitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/ability_bar"))
    @bgSprite = SpriteWrapper.new(viewport)
    @bgSprite.bitmap = @bgBitmap.bitmap
    @bgSprite.src_rect.y      = (side==0) ? 0 : @bgBitmap.height/2
    @bgSprite.src_rect.height = @bgBitmap.height/2
    # Create bitmap that displays the text
    @contents = BitmapWrapper.new(@bgBitmap.width,@bgBitmap.height/2)
    self.bitmap = @contents
    pbSetSystemFont(self.bitmap)
    # Position the bar
	if $PokemonSystem.activebattle==true
    self.x       = (side==0) ? -Graphics.actwidth/2 : Graphics.actwidth+112
    self.y       = (side==0) ? 250 : 220
	else
    self.x       = (side==0) ? -Graphics.width/2 : Graphics.width
    self.y       = (side==0) ? 180 : 80
	end
    self.z       = 120
    self.visible = false
  end

  def dispose
    @bgSprite.dispose
    @bgBitmap.dispose
    @contents.dispose
    super
  end

  def x=(value)
    super
    @bgSprite.x = value
  end

  def y=(value)
    super
    @bgSprite.y = value
  end

  def z=(value)
    super
    @bgSprite.z = value-1
  end

  def opacity=(value)
    super
    @bgSprite.opacity = value
  end

  def visible=(value)
    super
    @bgSprite.visible = value
  end

  def color=(value)
    super
    @bgSprite.color = value
  end

  def battler=(value)
    @battler = value
    refresh
  end

  def refresh
    self.bitmap.clear
    return if !@battler
    textPos = []
    textX = (@side==0) ? 10 : self.bitmap.width-8
    # Draw Pokémon's name
    textPos.push([_INTL("{1}'s",@battler.name),textX,2,@side==1,
       TEXT_BASE_COLOR,TEXT_SHADOW_COLOR,true])
    # Draw Pokémon's ability
    textPos.push([@battler.abilityName,textX,32,@side==1,
       TEXT_BASE_COLOR,TEXT_SHADOW_COLOR,true])
    pbDrawTextPositions(self.bitmap,textPos)
  end

  def update
    super
    @bgSprite.update
  end
end
#===============================================================================
# Data box for regular battles
#===============================================================================
class PokemonDataBox < SpriteWrapper
  def initializeDataBoxGraphic(sideSize)
    onPlayerSide = ((@battler.index%2)==0)
    # Get the data box graphic and set whether the HP numbers/Exp bar are shown
    if sideSize==1   # One Pokémon on side, use the regular dara box BG
      bgFilename = ["Graphics/Pictures/Battle/databox_normal",
                    "Graphics/Pictures/Battle/databox_normal_foe"][@battler.index%2]
      if onPlayerSide
        @showHP  = true
        @showExp = true
      end
    else   # Multiple Pokémon on side, use the thin dara box BG
      bgFilename = ["Graphics/Pictures/Battle/databox_thin",
                    "Graphics/Pictures/Battle/databox_thin_foe"][@battler.index%2]
    end
    @databoxBitmap  = AnimatedBitmap.new(bgFilename)
    # Determine the co-ordinates of the data box and the left edge padding width
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
      @spriteX += [  0,   0,  0,  0][@battler.index]
      @spriteY += [-20, -34, 34, 20][@battler.index]
    when 3
      @spriteX += [  0,   0,  0,  0,  0,  0][@battler.index]
      @spriteY += [-42, -46,  4,  0, 50, 46][@battler.index]
    when 4
      @spriteX += [  0,  0,  0,  0,  0,   0,  0,  0][@battler.index]
      @spriteY += [-88,-46,-42,  0,  4,  46, 50, 92][@battler.index]
    when 5
      @spriteX += [   0,  0,  0,  0,  0,  0,  0,  0,  0,  0][@battler.index]
      @spriteY += [-134,-46,-88,  0,-42, 46,  4, 92, 50,138][@battler.index]
    end
  end
end
