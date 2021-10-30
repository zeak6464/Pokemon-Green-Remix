#==============================================================================#
#//////////////////////////////////////////////////////////////////////////////#
#==============================================================================#
#               -------------------------------------------                    #
#               | Pokéride Ride Pager and Mount Expansion |                    #
#               |           by Ulithium_Dragon            |                    #
#               -------------------------------------------                    #
#                                 ~v1.0~                                       #
#==============================================================================#
#==============================================================================#
#                           ::::Description::::                                #
#                              -------------                                   #
#    Adds a mount selection menu for Marin's Pokéride resource and checks      #
#      whether or not if you can call the mounts, or dismount from them.       #
#                                                                              #
#  Also includes several additional mounts, and added functionalities such as  #
#    Cut support, Fly support, Lava Surf support, and Ice Traction.            # 
#                                                                              #
#==============================================================================#
#==============================================================================#
#                              ::::Notes::::                                   #
#                                 -------                                      #
#     This script is designed to support the extra mounts I created:           # 
#             Flygon, Kabutops, Avalugg, Gogoat, Hippowdon, Luxray,            #
#             Swampert, Lanturn, Araquanid, Rampardos, and Torkoal.            #
#                                                                              #
#   If you want to use and of these, set "EXTRAMOUNTS" to true in the below.   #
#                                                                              #
# *NOTE: Torkoal will only show up if "$PokemonGlobal.lavasurfing" is defined! #
#    (Implementing Lava Surfing is not something covered by this script.)      #
#                                                                              #
#==============================================================================#
#------------------------------------------------------------------------------#
#==============================================================================#
#                            ::::Options::::                                   #
#                                --------                                      #
#       Below are the options for toggling certain features on or off:         #
# ____________________________________________________________________________ #
#                                                                              #
#---------------------------#                                                  #
#  Adds all mounts to the ride pager from the start (mostly used for testing). #
    $ALLMOUNTS_PREREG = true   #Default: false
#---------------------------#                                                  #
#  If a mount Pokemon is in your party, it will be added                       #
#   to the Ride Pager automatically.                                           #
#   *This won't do anything if "ALLMOUNTS_PREREG" is set to true!              #
    $PARTY_AUTOREG = false   #Default: false
#------------------------#                                                     #
#  If "PARTY_AUTOREG" is true, toggles whether or not the Pokemon are          # 
#   deregistered from the Ride Pager when they are removed from your party.    #
#   *This won't do anything if "ALLMOUNTS_PREREG" is set to true!              #
    $PARTY_AUTODEREG = true  #Default: true
#--------------------------#                                                   #
#  Controls whether or not mounts can be summoned indoors.                     #
#   *NOTE: This affects ALL indoor maps, including caves! Currently this check #
#    is tied to the bike check. Ergo, if you can ride a bike, you can mount.   #
    $CANUSE_INDOORS = true   #Default: false
#--------------------------#                                                   #
#  If "CANUSE_INDOORS" is false, this controls whether or not to include the   #
#   surf mounts. I highly recommend leaving this on "true" unless you're       #
#   certain that you have no maps with surfable water/lava that have the       #
#   metadata flag "Bicycle=false" (cave maps usually have this set to true).   #
    $CANUSE_INDOORS_SURFMOUNTS = true   #Default: true
#------------------------------------#                                         #
#  Toggles the extra mounts I added (Flygon, Kabutops, and Torkoal).           #
#   *NOTE: Torkoal will only show up if you have Lava Surfing set up, and have #
#   the global variable "$PokemonGlobal.lavasurfing" defined.                  #
    $EXTRAMOUNTS = true   #Default: true
#----------------------#                                                       #
#  Toggles the mount animation. If you wish to use this, the animation must    #
#   be set up manually, and you need to set the animation ID below.            #
#   *See the included "Readme_AnimExampleMap.txt" for more information.        #
    $MOUNTANIMATION = false    #Default: false
#-------------------------#                                                    #
#  Controls whether the mounting/dismounting sound effect should play.          #
    $PLAYMOUNTING_SE = true   #Default: true
#-------------------------#                                                    #
#  Controls whether the Pokemon's cry sound should play when summoned.          #
    $PLAYPOKEMONCRY_SE = true   #Default: true
#-------------------------#                                                    #
#  If you want terrain tag that blocks mounting when standing on               #
#  or facing a tile, put its terrain ID as defined in PBTerrain here.          #
    $NOMOUNTING_TERRAINTAG = 27    #Default: nil
#-------------------------------#                                              #
#  If you want a terrain tag that blocks dismounting when standing on          #
#  or facing a tile, put its terrain ID as defined in PBTerrain here.          #
#  *NOTE: In most cases this should be the same as "NOMOUNTING_TERRAINTAG".    #
    $NODISMOUNTING_TERRAINTAG = nil    #Default: nil
#---------------------------------#                                            #
#  The ID of the Common Event that holds the mount/dismount animation.         #
#   *You must set "MOUNTANIMATION" to true or this will do nothing!            #
    $COMMONEVENT_ANIMID = nil   #Default: nil
#  
#---------------------------------#
# If you have pokemon following turn this to true(defualt: false)
    POKEFOLLOW = true 
#==============================================================================#
#==============================================================================#
#  Code for tweaked and added Pokeride functionality.                          #
#==============================================================================#
# *NOTE: Any code under this section not marked with #CUSTOM is an exert from
#  the "Pokéride_Main" script, and will overwrite the code from that script.
class PokemonGlobalMetadata #CUSTOM
  attr_accessor :ridingWaterfall
  attr_accessor :mount_attack

  alias ridepager_init initialize
  def initialize
      ridepager_init
    @ridingWaterfall      = false
    @mount_attack         = false
  end
end

class PokemonSystem
  attr_accessor :register_tauros
  attr_accessor :register_lapras
  attr_accessor :register_sharpedo
  attr_accessor :register_machamp
  attr_accessor :register_mudsdale
  attr_accessor :register_stoutland
  attr_accessor :register_rhyhorn
  attr_accessor :register_kabutops
  attr_accessor :register_avalugg
  attr_accessor :register_torkoal
  attr_accessor :register_flygon
  attr_accessor :register_gogoat
  attr_accessor :register_hippowdon
  attr_accessor :register_luxray
  attr_accessor :register_swampert
  attr_accessor :register_lanturn
  attr_accessor :register_araquanid
  attr_accessor :register_rampardos
  
  
  def register_tauros
    return (!@register_tauros) ? 0 : @register_tauros
  end
  def register_lapras
    return (!@register_lapras) ? 0 : @register_lapras
  end
  def register_sharpedo
    return (!@register_sharpedo) ? 0 : @register_sharpedo
  end
  def register_machamp
    return (!@register_machamp) ? 0 : @register_machamp
  end
  def register_mudsdale
    return (!@register_mudsdale) ? 0 : @register_mudsdale
  end
  def register_stoutland
    return (!@register_stoutland) ? 0 : @register_stoutland
  end
  def register_rhyhorn
    return (!@register_rhyhorn) ? 0 : @register_rhyhorn
  end
  def register_kabutops
    return (!@register_kabutops) ? 0 : @register_kabutops
  end
  def register_avalugg
    return (!@register_avalugg) ? 0 : @register_avalugg
  end
  def register_torkoal
    return (!@register_torkoal) ? 0 : @register_torkoal
  end
  def register_flygon
    return (!@register_flygon) ? 0 : @register_flygon
  end
  def register_gogoat
    return (!@register_gogoat) ? 0 : @register_gogoat
  end
  def register_hippowdon
    return (!@register_hippowdon) ? 0 : @register_hippowdon
  end
  def register_luxray
    return (!@register_luxray) ? 0 : @register_luxray
  end
  def register_swampert
    return (!@register_swampert) ? 0 : @register_swampert
  end
  def register_lanturn
    return (!@register_lanturn) ? 0 : @register_lanturn
  end
  def register_araquanid
    return (!@register_araquanid) ? 0 : @register_araquanid
  end
  def register_rampardos
    return (!@register_rampardos) ? 0 : @register_rampardos
  end
  
  
  alias ridepager_pokesystm_init initialize
  def initialize
      ridepager_pokesystm_init
    @register_tauros    = 0
    @register_lapras    = 0
    @register_sharpedo  = 0
    @register_machamp   = 0
    @register_mudsdale  = 0
    @register_stoutland = 0
    @register_rhyhorn   = 0
    @register_kabutops  = 0
    @register_torkoal   = 0
    @register_flygon    = 0
    @register_gogoat    = 0
    @register_hippowdon = 0
    @register_luxray    = 0
    @register_swampert  = 0
    @register_lanturn   = 0
    @register_araquanid = 0
    @register_rampardos = 0
  end
end


#==============================================================================#
#  Code for the Ride Pager item.                                               #
#==============================================================================#
#Item handlers
ItemHandlers::UseFromBag.add(:RIDEPAGER,proc{|item| next 2 })
ItemHandlers::UseInField.add(:RIDEPAGER,proc{|item|
  #Registers all of the mounts by default if the option is enabled.
  if $ALLMOUNTS_PREREG
    pbRegisterAllMounts(false)
  end
  #Show the menu.
  pbRidePagerMenuStart(item)
})


#Gives the Ride Pager item with the appropriate sound effect.
def pbGiveRidePagerItem
  Kernel.pbReceiveItem(:RIDEPAGER)
  pbMEPlay("RidePager_ItemGet")
  pbWait(8)
end


#Checks if the mount animation should play.
def pbMountAnim
  #Play the animation if enabled.
  if $MOUNTANIMATION && $COMMONEVENT_ANIMID != nil
    pbSEPlay("PokeRide_Summon") if $PLAYMOUNTING_SE
    pbCommonEvent($COMMONEVENT_ANIMID)
  else
    #If the animation is disabled...
    #...Play the SE if it's enabled.
    pbSEPlay("PokeRide_Summon") if $PLAYMOUNTING_SE
  end
end



#==============================================================================#
#  Code for defining the "mounts" PBS file.                                    #
#==============================================================================#
#Reads mount data from the Mounts PBS file.
class MountsClass
  
  def initialize(name)
    @name = name
  end

  def mountid
    return $MountsPBS[@name]["MountID"]
  end
  def mountpokedexid
    return $MountsPBS[@name]["MountPokedexID"]
  end
  def mountname
    return $MountsPBS[@name]["MountName"]
  end
end


#==============================================================================#
#  Register Mount Code                                                         #
#==============================================================================#
#Call this to actually register a mount in the Ride Pager.
#*The first value is the mount name string.
#*The second value controls whether or not to show the mount registered message.
#**Example: pbRegisterMount("Tauros",true)


def pbRegisterMount(mountname,showmsg)
  @mountname=mountname
  @showmsg=showmsg
#----------#
  #TAUROS
  if @mountname=="Tauros"
    if $PokemonSystem.register_tauros == 0
      Kernel.pbMessage(_INTL("Tauros was registered in the Ride Pager!\\me[Pokeride Mount Registered]")) if showmsg
      $PokemonSystem.register_tauros = 1
    else
      Kernel.pbMessage(_INTL("Tauros is already registered in the Ride Pager!\\se[error_01]")) if showmsg
    end
#----------#
  #RAMPARDOS
  elsif @mountname=="Rampardos"
    if $PokemonSystem.register_rampardos == 0
      Kernel.pbMessage(_INTL("Rampardos was registered in the Ride Pager!\\me[Pokeride Mount Registered]")) if showmsg
      $PokemonSystem.register_rampardos = 1
    else
      Kernel.pbMessage(_INTL("Rampardos is already registered in the Ride Pager!\\se[error_01]")) if showmsg
    end
#----------#
  #LAPRAS
  elsif @mountname=="Lapras"
    if $PokemonSystem.register_lapras == 0
      Kernel.pbMessage(_INTL("Lapras was registered in the Ride Pager!\\me[Pokeride Mount Registered]")) if showmsg
      $PokemonSystem.register_lapras = 1
    else
      Kernel.pbMessage(_INTL("Lapras is already registered in the Ride Pager!\\se[error_01]")) if showmsg
    end
#----------#
  #LANTURN
  elsif @mountname=="Lanturn"
    if $PokemonSystem.register_lanturn == 0
      Kernel.pbMessage(_INTL("Lanturn was registered in the Ride Pager!\\me[Pokeride Mount Registered]")) if showmsg
      $PokemonSystem.register_lanturn = 1
    else
      Kernel.pbMessage(_INTL("Lanturn is already registered in the Ride Pager!\\se[error_01]")) if showmsg
    end
#----------#
  #ARAQUANID
  elsif @mountname=="Araquanid"
    if $PokemonSystem.register_araquanid == 0
      Kernel.pbMessage(_INTL("Araquanid was registered in the Ride Pager!\\me[Pokeride Mount Registered]")) if showmsg
      $PokemonSystem.register_araquanid = 1
    else
      Kernel.pbMessage(_INTL("Araquanid is already registered in the Ride Pager!\\se[error_01]")) if showmsg
    end
#----------#
  #SHARPEDO
  elsif @mountname=="Sharpedo"
    if $PokemonSystem.register_sharpedo == 0
      Kernel.pbMessage(_INTL("Sharpedo was registered in the Ride Pager!\\me[Pokeride Mount Registered]")) if showmsg
      $PokemonSystem.register_sharpedo = 1
    else
      Kernel.pbMessage(_INTL("Sharpedo is already registered in the Ride Pager!\\se[error_01]")) if showmsg
    end
#----------#
  #MACHAMP
  elsif @mountname=="Machamp"
    if $PokemonSystem.register_machamp == 0
      Kernel.pbMessage(_INTL("Machamp was registered in the Ride Pager!\\me[Pokeride Mount Registered]")) if showmsg
      $PokemonSystem.register_machamp = 1
    else
      Kernel.pbMessage(_INTL("Machamp is already registered in the Ride Pager!\\se[error_01]")) if showmsg
    end
#----------#
  #MUDSDALE
  elsif @mountname=="Mudsdale"
    if $PokemonSystem.register_mudsdale == 0
      Kernel.pbMessage(_INTL("Mudsdale was registered in the Ride Pager!\\me[Pokeride Mount Registered]")) if showmsg
      $PokemonSystem.register_mudsdale = 1
    else
      Kernel.pbMessage(_INTL("Mudsdale is already registered in the Ride Pager!\\se[error_01]")) if showmsg
    end
#----------#
  #STOUTLAND
  elsif @mountname=="Stoutland"
    if $PokemonSystem.register_stoutland == 0
      Kernel.pbMessage(_INTL("Stoutland was registered in the Ride Pager!\\me[Pokeride Mount Registered]")) if showmsg
      $PokemonSystem.register_stoutland = 1
    else
      Kernel.pbMessage(_INTL("Stoutland is already registered in the Ride Pager!\\se[error_01]")) if showmsg
    end
#----------#
  #RHYHORN
  elsif @mountname=="Rhyhorn"
    if $PokemonSystem.register_rhyhorn == 0
      Kernel.pbMessage(_INTL("Rhyhorn was registered in the Ride Pager!\\me[Pokeride Mount Registered]")) if showmsg
      $PokemonSystem.register_rhyhorn = 1
    else
      Kernel.pbMessage(_INTL("Rhyhorn is already registered in the Ride Pager!\\se[error_01]")) if showmsg
    end
#----------#
  #KABUTOPS
  elsif @mountname=="Kabutops"
    if $EXTRAMOUNTS == true
      if $PokemonSystem.register_kabutops == 0
        Kernel.pbMessage(_INTL("Kabutops was registered in the Ride Pager!\\me[Pokeride Mount Registered]")) if showmsg
        $PokemonSystem.register_kabutops = 1
      else
        Kernel.pbMessage(_INTL("Kabutops is already registered in the Ride Pager!\\se[error_01]")) if showmsg
      end
    end
#----------#
  #AVALUGG
  elsif @mountname=="Avalugg"
    if $EXTRAMOUNTS == true
      if $PokemonSystem.register_avalugg == 0
        Kernel.pbMessage(_INTL("Avalugg was registered in the Ride Pager!\\me[Pokeride Mount Registered]")) if showmsg
        $PokemonSystem.register_avalugg = 1
      else
        Kernel.pbMessage(_INTL("Avalugg is already registered in the Ride Pager!\\se[error_01]")) if showmsg
      end
    end
#----------#
  #GOGOAT
  elsif @mountname=="Gogoat"
    if $EXTRAMOUNTS == true
      if $PokemonSystem.register_gogoat == 0
        Kernel.pbMessage(_INTL("Gogoat was registered in the Ride Pager!\\me[Pokeride Mount Registered]")) if showmsg
        $PokemonSystem.register_gogoat = 1
      else
        Kernel.pbMessage(_INTL("Gogoat is already registered in the Ride Pager!\\se[error_01]")) if showmsg
      end
    end
#----------#
  #HIPPOWDON
  elsif @mountname=="Hippowdon"
    if $EXTRAMOUNTS == true
      if $PokemonSystem.register_hippowdon == 0
        Kernel.pbMessage(_INTL("Hippowdon was registered in the Ride Pager!\\me[Pokeride Mount Registered]")) if showmsg
        $PokemonSystem.register_hippowdon = 1
      else
        Kernel.pbMessage(_INTL("Hippowdon is already registered in the Ride Pager!\\se[error_01]")) if showmsg
      end
    end
#----------#
  #LUXRAY
  elsif @mountname=="Luxray"
    if $EXTRAMOUNTS == true
      if $PokemonSystem.register_luxray == 0
        Kernel.pbMessage(_INTL("Luxray was registered in the Ride Pager!\\me[Pokeride Mount Registered]")) if showmsg
        $PokemonSystem.register_luxray = 1
      else
        Kernel.pbMessage(_INTL("Luxray is already registered in the Ride Pager!\\se[error_01]")) if showmsg
      end
    end
#----------#
  #SWAMPERT
  elsif @mountname=="Swampert"
    if $EXTRAMOUNTS == true
      if $PokemonSystem.register_swampert == 0
        Kernel.pbMessage(_INTL("Swampert was registered in the Ride Pager!\\me[Pokeride Mount Registered]")) if showmsg
        $PokemonSystem.register_swampert = 1
      else
        Kernel.pbMessage(_INTL("Swampert is already registered in the Ride Pager!\\se[error_01]")) if showmsg
      end
    end
#----------#
  #TORKOAL
  elsif @mountname=="Torkoal"
    if $EXTRAMOUNTS == true && defined?($PokemonGlobal.lavasurfing)
      if $PokemonSystem.register_torkoal == 0
        Kernel.pbMessage(_INTL("Torkoal was registered in the Ride Pager!\\me[Pokeride Mount Registered]")) if showmsg
        $PokemonSystem.register_torkoal = 1
      else
        Kernel.pbMessage(_INTL("Torkoal is already registered in the Ride Pager!\\se[error_01]")) if showmsg
      end
    end
#----------#
  #FLYGON
  elsif @mountname=="Flygon"
    if $EXTRAMOUNTS == true
      if $PokemonSystem.register_flygon == 0
        Kernel.pbMessage(_INTL("Flygon was registered in the Ride Pager!\\me[Pokeride Mount Registered]")) if showmsg
        $PokemonSystem.register_flygon = 1
      else
        Kernel.pbMessage(_INTL("Flygon is already registered in the Ride Pager!\\se[error_01]")) if showmsg
      end
    end
#----------#
  #Not a mountable Pokemon!
  else
    Kernel.pbMessage(_INTL("{1} is not a mount!\\se[error_01]",mountname))
  end
end


#==============================================================================#
#  Mount Code                                                                  #
#==============================================================================#
#Call this to register all mount in the Ride Pager at once.
#*Set the variable to "false" to not display the register message.
#**Example: pbRegisterAllMounts(false) #NoMsg
#**Example: pbRegisterAllMounts(true)  #WithMsg
#**Example: pbRegisterAllMounts        #WithMsg
#***This would probably mostly be used for debugging, unless you really want the player to have all the mounts at once.
def pbRegisterAllMounts(msg=true)
  @msg=msg
  if @msg == true
    Kernel.pbMessage(_INTL("All Pokémon were registered in the Ride Pager!\\me[Pokeride Mount Registered]"))
  end
  $PokemonSystem.register_tauros = 1
  $PokemonSystem.register_rampardos = 1 if $EXTRAMOUNTS == true
  $PokemonSystem.register_lapras = 1
  $PokemonSystem.register_lanturn = 1 if $EXTRAMOUNTS == true
  $PokemonSystem.register_araquanid = 1 if $EXTRAMOUNTS == true
  $PokemonSystem.register_sharpedo = 1
  $PokemonSystem.register_machamp = 1
  $PokemonSystem.register_mudsdale = 1
  $PokemonSystem.register_stoutland = 1
  $PokemonSystem.register_rhyhorn = 1
  $PokemonSystem.register_kabutops = 1 if $EXTRAMOUNTS == true
  $PokemonSystem.register_avalugg = 1 if $EXTRAMOUNTS == true
  $PokemonSystem.register_gogoat = 1 if $EXTRAMOUNTS == true
  $PokemonSystem.register_hippowdon = 1 if $EXTRAMOUNTS == true
  $PokemonSystem.register_luxray = 1 if $EXTRAMOUNTS == true
  $PokemonSystem.register_swampert = 1 if $EXTRAMOUNTS == true
  $PokemonSystem.register_torkoal = 1 if $EXTRAMOUNTS == true && defined?($PokemonGlobal.lavasurfing)
  $PokemonSystem.register_flygon = 1 if $EXTRAMOUNTS == true
end


#Checks if you are surfing and are facing a "no surfing" tile.
def pbSurfingChecker
  #Needed for Terrain Tag checks.
  x=$game_player.x
  y=$game_player.y
  currentTag=$game_map.terrain_tag(x,y)
  facingTag=Kernel.pbFacingTerrainTag
  notCliff=$game_map.passable?($game_player.x,$game_player.y,$game_player.direction)
  if $PokemonGlobal.surfing == true
    if PBTerrain.isSurfable?(currentTag) && !PBTerrain.isSurfable?(facingTag) && !PBTerrain.isBridge?(currentTag) && !PBTerrain.isBridge?(facingTag) && notCliff
      surfingchecker = true
    end
  end
  #Checks if you are lava surfing and are facing a "no lava surfing" tile.
  if defined?($PokemonGlobal.lavasurfing)
    if $PokemonGlobal.lavasurfing == true
      if PBTerrain.isLavaSurfable?(currentTag) && !PBTerrain.isLavaSurfable?(facingTag) && notCliff
        surfingchecker = true
      else
      end
    end
  end
end


def pbCurrentlySurfingChecker
  #Is the player surfing?
  if $PokemonGlobal.surfing == true
    currentlysurfingchecker = true
  end
  #Is the player lava surfing?
  if defined?($PokemonGlobal.lavasurfing)
    if $PokemonGlobal.lavasurfing == true
      currentlysurfingchecker = true
    end
  end
end


def pbBikesChecker
  if $PokemonGlobal.bicycle == true
    bikeschecker = true
  end
  if defined?($PokemonGlobal.acrobike)
    if $PokemonGlobal.acrobike == true
      bikeschecker = true
    end
  end
  if defined?($PokemonGlobal.machbike)
    if $PokemonGlobal.machbike == true
      bikeschecker = true
    end
  end
end
#Overwrites the function located in PItem_Items.
def pbBikeCheck
  if $PokemonGlobal.surfing ||
     (defined?($PokemonGlobal.lavasurfing) && $PokemonGlobal.lavasurfing) ||
     (!$PokemonGlobal.bicycle && PBTerrain.onlyWalk?(pbGetTerrainTag)) ||
     $PokemonGlobal.mount
    if $PokemonGlobal.mount
      Kernel.pbMessage(_INTL("You can't ride your bike while on Pokémon!"))
      return false
    else
      Kernel.pbMessage(_INTL("Can't use that here."))
      return false
    end
  end
  if $PokemonGlobal.bicycle
    if pbGetMetadata($game_map.map_id,MetadataBicycleAlways)
      Kernel.pbMessage(_INTL("You can't dismount your Bike here."))
      return false
    end
    return true
  else
    val=pbGetMetadata($game_map.map_id,MetadataBicycle)
    val=pbGetMetadata($game_map.map_id,MetadataOutdoor) if val==nil
    if !val
      Kernel.pbMessage(_INTL("Can't use that here."))
      return false
    end
    return true
  end
end


def pbStopAllBikes
  $PokemonGlobal.bicycle = false
  if defined?($PokemonGlobal.acrobike)
    $PokemonGlobal.acrobike = false
  end
  if defined?($PokemonGlobal.machbike)
    $PokemonGlobal.machbike = false
  end
end




##(There delay was too long when I used the normal surfing function,
##so I use a stripped-down version here instead.)
#------------------#
#Jump effect used for mounting and dismounting surf mounts.
def pbMountJumpTowards
  dist=1
  x=$game_player.x
  y=$game_player.y
  case $game_player.direction
  when 2 # down
    $game_player.jump(0,dist)
  when 4 # left
    $game_player.jump(-dist,0)
  when 6 # right
    $game_player.jump(dist,0)
  when 8 # up
    $game_player.jump(0,-dist)
  end
end


#Item code forwarder (probably redundant).
def pbRidePagerMenuStart(item)
  pbRidePagerMenu(item)
end



#Menu code for choosing a mount.
def pbRidePagerMenu(item)
  #Needed for Terrain Tag checks.
  x=$game_player.x
  y=$game_player.y
  currentTag=$game_map.terrain_tag(x,y)
  facingTag=Kernel.pbFacingTerrainTag
  notCliff=$game_map.passable?($game_player.x,$game_player.y,$game_player.direction)

  #Resets back to "false" each time so the check can be run again.
  surfingchecker = false
  currentlysurfingchecker = false
  bikeschecker = false



  #Map Metadata checks.
  bikeval=pbGetMetadata($game_map.map_id,MetadataBicycle)
  bikeval=pbGetMetadata($game_map.map_id,MetadataOutdoor) if bikeval==nil

  if !$PokemonGlobal.mount  #If already mounted, skip to dismounting.
    commands=[]
    cmdMountTauros  	  = -1
    cmdMountRampardos  	= -1
    cmdMountLapras  	  = -1
    cmdMountSharpedo    = -1
    cmdMountLanturn     = -1
    cmdMountAraquanid   = -1
    cmdMountMachamp  	  = -1
    cmdMountMudsdale    = -1
    cmdMountStoutland   = -1
    cmdMountRhyhorn     = -1
    cmdMountKabutops    = -1
    cmdMountAvalugg     = -1
    cmdMountGogoat      = -1
    cmdMountHippowdon   = -1
    cmdMountLuxray      = -1
    cmdMountSwampert    = -1
    cmdMountTorkoal 	  = -1
    cmdMountFlygon      = -1
    cmdQUIT             = -1

    #==========#
    ##(Text from official game. Unused until I make a custom mount selection menu.)
      #Kernel.pbMessage(_INTL("Which Ride Pokémon would you like to ride?"))
      #Kernel.pbMessage(_INTL("Press X to check what the Pokémon can do."))
    #==========#

    #Tauros
    commands[cmdMountTauros=commands.length]=_INTL("Tauros") if $PokemonSystem.register_tauros == 1

    #Rampardos
    commands[cmdMountRampardos=commands.length]=_INTL("Rampardos") if $PokemonSystem.register_rampardos == 1 && $EXTRAMOUNTS == true

    #Lapras
    commands[cmdMountLapras=commands.length]=_INTL("Lapras") if $PokemonSystem.register_lapras == 1

    #Sharpedo
    commands[cmdMountSharpedo=commands.length]=_INTL("Sharpedo") if $PokemonSystem.register_sharpedo == 1
    
    #Lanturn
    commands[cmdMountLanturn=commands.length]=_INTL("Lanturn") if $PokemonSystem.register_lanturn == 1

    #Araquanid
    commands[cmdMountAraquanid=commands.length]=_INTL("Araquanid") if $PokemonSystem.register_araquanid == 1

    #Machamp
    commands[cmdMountMachamp=commands.length]=_INTL("Machamp") if $PokemonSystem.register_machamp == 1

    #Mudsdale
    commands[cmdMountMudsdale=commands.length]=_INTL("Mudsdale") if $PokemonSystem.register_mudsdale == 1

    #Stoutland
    commands[cmdMountStoutland=commands.length]=_INTL("Stoutland") if $PokemonSystem.register_stoutland == 1

    #Rhyhorn
    commands[cmdMountRhyhorn=commands.length]=_INTL("Rhyhorn") if $PokemonSystem.register_rhyhorn == 1

    #Kabutops
    commands[cmdMountKabutops=commands.length]=_INTL("Kabutops") if $PokemonSystem.register_kabutops == 1 && $EXTRAMOUNTS == true

    #Avalugg
    commands[cmdMountAvalugg=commands.length]=_INTL("Avalugg") if $PokemonSystem.register_avalugg == 1 && $EXTRAMOUNTS == true

    #Gogoat
    commands[cmdMountGogoat=commands.length]=_INTL("Gogoat") if $PokemonSystem.register_gogoat == 1 && $EXTRAMOUNTS == true

    #Hippowdon
    commands[cmdMountHippowdon=commands.length]=_INTL("Hippowdon") if $PokemonSystem.register_hippowdon == 1 && $EXTRAMOUNTS == true

    #Luxray
    commands[cmdMountLuxray=commands.length]=_INTL("Luxray") if $PokemonSystem.register_luxray == 1 && $EXTRAMOUNTS == true
    
    #Swampert
    commands[cmdMountSwampert=commands.length]=_INTL("Swampert") if $PokemonSystem.register_swampert == 1 && $EXTRAMOUNTS == true

    #Torkoal
    commands[cmdMountTorkoal=commands.length]=_INTL("Torkoal") if $PokemonSystem.register_torkoal == 1 && $EXTRAMOUNTS == true && defined?($PokemonGlobal.lavasurfing)

    #Flygon
    commands[cmdMountFlygon=commands.length]=_INTL("Flygon") if $PokemonSystem.register_flygon == 1 && $EXTRAMOUNTS == true

    #QUIT
    commands[cmdQUIT=commands.length]=_INTL("QUIT")

    pbBikesChecker #If the player is on a bike, no do not show the menu.
	
    #Do not show the menu if no mounts are registered.
    if cmdMountTauros == -1 && cmdMountLapras == -1 && cmdMountSharpedo == -1 &&
    cmdMountLanturn == -1 && cmdMountAraquanid == -1 && cmdMountMachamp == -1 &&
    cmdMountMudsdale == -1 && cmdMountStoutland == -1 && cmdMountRhyhorn == -1 &&
    cmdMountKabutops == -1 && cmdMountAvalugg == -1 && cmdMountGogoat == -1 &&
    cmdMountHippowdon == -1 && cmdMountLuxray == -1 && cmdMountSwampert == -1 &&
    cmdMountTorkoal == -1 && cmdMountFlygon == -1 && cmdMountRampardos == -1
      Kernel.pbMessage(_INTL("No mounts registered."))
      pbWait(10)

    #Checks the Bicycle map metadata to see if the player can mount on the current map.
    elsif !bikeval && !$CANUSE_INDOORS && !$CANUSE_INDOORS_SURFMOUNTS
      Kernel.pbMessage(_INTL("You can't call a mount in here!"))

    #Checks if the player is on their bike.
    elsif $PokemonGlobal.bicycle == true
      Kernel.pbMessage(_INTL("You can't call a mount while riding your bike!"))

    #Is Diving?
    elsif $PokemonGlobal.diving == true
      Kernel.pbMessage(_INTL("You can't call a mount here!"))
    #Is Surfing?
    elsif $PokemonGlobal.surfing == true && $PokemonGlobal.mount == nil
      Kernel.pbMessage(_INTL("You can't call a mount here!"))
    #Is Rock Climbing?
    elsif defined?($PokemonGlobal.rockclimbing) && $PokemonGlobal.rockclimbing == true && $PokemonGlobal.mount == nil
      Kernel.pbMessage(_INTL("You can't call a mount here!"))

    #Is Sliding?
    elsif $PokemonGlobal.sliding == true
      #Do nothing.

    #Checks if the player is on or facing custom "no-mounting" terrain tag.
    elsif $NOMOUNTING_TERRAINTAG && (facingTag==$NOMOUNTING_TERRAINTAG ||
          facingTag==$NOMOUNTING_TERRAINTAG || currentTag==$NOMOUNTING_TERRAINTAG)
            Kernel.pbMessage(_INTL("You can't mount here."))

    else  #Show the menu.

#  Builds an array of description text to display with the hovered over mount. Then passes
#  the array to pbShowCommandsWithHelp, which manages which text to show by itself.

    #Create new array to hold our Mount description text
    descArray = Array.new
    
    #Loop through the names that are currently selectable...
    for name in commands
      #If the command name isn't "Quit"...
      if name != "QUIT"
        #Set a new instance of the MountsClass that handles the PBS data for the
        #Mount name passed.
        mountPBS = MountsClass.new(name.upcase) 
      #If the command name IS "Quit"...
      else
        #Pass this string for the Quit command.
        descArray.push("Exit the Ride Pager.")
      end
    end
    
    loop do
      pbSurfingChecker
      pbBikesChecker
      
      #Create a new window for the help text, using the menu frame style
      msgwindow = Kernel.pbCreateMessageWindow(nil,MessageConfig.pbDefaultSystemFrame) 
      
      #Call our commands list with our descArray and help text message box
      command=Kernel.pbShowRidePagerCmds(msgwindow,commands,nil)
      
      #Dispose our messagebox when an option is selected
      Kernel.pbDisposeMessageWindow(msgwindow)
#------------------#
      #Exit the menu if the B or C buttons are pressed.
      if command==-1
        break
      end
#------------------#
      #Tauros
      if cmdMountTauros>=0 && command==cmdMountTauros
        #Checks if you are surfing and are facing a "no surfing" tile.
        if surfingchecker == true
          Kernel.pbMessage(_INTL("You can't dismount here."))
          break
        end
        #Checks if you can use mounts indoors.
        if !$CANUSE_INDOORS && !bikeval
          Kernel.pbMessage(_INTL("You can't call Tauros here."))

        else  #Mount up!
          $PokemonGlobal.bicycle = false
          if POKEFOLLOW == true
          $PokemonTemp.dependentEvents.remove_sprite(true)
          end
          pbMountAnim
          pbMount(Tauros)
          pbWait(8)
          if $PLAYPOKEMONCRY_SE == true
            pbSEPlay("Cries/128Cry")
          end
          pbWait(16)
        end
        break
#------------------#
      #Rampardos
      elsif cmdMountRampardos>=0 && command==cmdMountRampardos
        #Checks if you are surfing and are facing a "no surfing" tile.
        if surfingchecker == true
          Kernel.pbMessage(_INTL("You can't dismount here."))
          break
        end
        #Checks if you can use mounts indoors.
        if !$CANUSE_INDOORS && !bikeval
          Kernel.pbMessage(_INTL("You can't call Rampardos here."))

        else  #Mount up!
          $PokemonGlobal.bicycle = false
          if POKEFOLLOW == true
          $PokemonTemp.dependentEvents.remove_sprite(true)
          end
          pbMountAnim
          pbMount(Rampardos)
          pbWait(8)
          if $PLAYPOKEMONCRY_SE == true
            pbSEPlay("Cries/409Cry")
          end
          pbWait(16)
        end
        break
#------------------#
      #Lapras
      elsif cmdMountLapras>=0 && command==cmdMountLapras
        #Checks if you are surfing and are facing a "no surfing" tile.
        if surfingchecker == true
          Kernel.pbMessage(_INTL("You can't dismount here."))
          break
        end
        #Checks if you can use mounts indoors.
        if !$CANUSE_INDOORS && !$CANUSE_INDOORS_SURFMOUNTS && !bikeval
          Kernel.pbMessage(_INTL("You can't call Lapras here."))

        #Checks for surfable tiles.
        elsif PBTerrain.isSurfable?(facingTag) &&
              !$PokemonGlobal.surfing && 
              !pbGetMetadata($game_map.map_id,MetadataBicycleAlways) && notCliff
          $PokemonGlobal.bicycle = false
          pbMount(Lapras)  #Mount up!
          if POKEFOLLOW == true
          $PokemonTemp.dependentEvents.remove_sprite(true)
          end
          pbMountJumpTowards
          pbWait(2)
          pbMountAnim
          pbWait(8)
          if $PLAYPOKEMONCRY_SE == true
            pbSEPlay("Cries/131Cry")
          end
          surfbgm=pbGetMetadata(0,MetadataSurfBGM)
          if defined?(pbGetSurfTheme)
            surfbgm=pbGetSurfTheme
            pbCueBGM(surfbgm,0.5) if surfbgm
          elsif surfbgm
            pbBGMPlay(surfbgm)
          else
            $game_map.autoplayAsCue
          end

        else  #No surfable tiles.
          Kernel.pbMessage(_INTL("You can't call Lapras here."))
        end
        break
#------------------#
      #Sharpedo
      elsif cmdMountSharpedo>=0 && command==cmdMountSharpedo
        #Checks if you are surfing and are facing a "no surfing" tile.
        if surfingchecker == true
          Kernel.pbMessage(_INTL("You can't dismount here."))
          break
        end
        #Checks if you can use mounts indoors.
        if !$CANUSE_INDOORS && !$CANUSE_INDOORS_SURFMOUNTS && !bikeval
          Kernel.pbMessage(_INTL("You can't call Sharpedo here."))

        #Checks for surfable tiles.
        elsif PBTerrain.isSurfable?(facingTag) &&
              !$PokemonGlobal.surfing && 
              !pbGetMetadata($game_map.map_id,MetadataBicycleAlways) && notCliff
          $PokemonGlobal.bicycle = false
          pbMount(Sharpedo)  #Mount up!
          if POKEFOLLOW == true
          $PokemonTemp.dependentEvents.remove_sprite(true)
          end
          pbMountJumpTowards
          pbWait(2)
          pbMountAnim
          pbWait(8)
          if $PLAYPOKEMONCRY_SE == true
            pbSEPlay("Cries/319Cry")
          end
          surfbgm=pbGetMetadata(0,MetadataSurfBGM)
          if defined?(pbGetSurfTheme)
            surfbgm=pbGetSurfTheme
            pbCueBGM(surfbgm,0.5) if surfbgm
          elsif surfbgm
            pbBGMPlay(surfbgm)
          else
            $game_map.autoplayAsCue
          end

        else  #No surfable tiles.
          Kernel.pbMessage(_INTL("You can't call Sharpedo here."))
        end
        break
#------------------#
      #Lanturn
      elsif cmdMountLanturn>=0 && command==cmdMountLanturn
        #Checks if you are surfing and are facing a "no surfing" tile.
        if surfingchecker == true
          Kernel.pbMessage(_INTL("You can't dismount here."))
          break
        end
        #Checks if you can use mounts indoors.
        if !$CANUSE_INDOORS && !$CANUSE_INDOORS_SURFMOUNTS && !bikeval
          Kernel.pbMessage(_INTL("You can't call Lanturn here."))

        #Checks for surfable tiles.
        elsif PBTerrain.isSurfable?(facingTag) &&
              !$PokemonGlobal.surfing && 
              !pbGetMetadata($game_map.map_id,MetadataBicycleAlways) && notCliff
          $PokemonGlobal.bicycle = false
          pbMount(Lanturn)  #Mount up!
          if POKEFOLLOW == true
          $PokemonTemp.dependentEvents.remove_sprite(true)
          end
          pbMountJumpTowards
          pbWait(2)
          pbMountAnim
          pbWait(8)
          if $PLAYPOKEMONCRY_SE == true
            pbSEPlay("Cries/171Cry")
          end
          surfbgm=pbGetMetadata(0,MetadataSurfBGM)
          if defined?(pbGetSurfTheme)
            surfbgm=pbGetSurfTheme
            pbCueBGM(surfbgm,0.5) if surfbgm
          elsif surfbgm
            pbBGMPlay(surfbgm)
          else
            $game_map.autoplayAsCue
          end

        else  #No surfable tiles.
          Kernel.pbMessage(_INTL("You can't call Lanturn here."))
        end
        break
#------------------#
      #Araquanid
      elsif cmdMountAraquanid>=0 && command==cmdMountAraquanid
        #Checks if you are surfing and are facing a "no surfing" tile.
        if surfingchecker == true
          Kernel.pbMessage(_INTL("You can't dismount here."))
          break
        end
        #Checks if you can use mounts indoors.
        if !$CANUSE_INDOORS && !bikeval
          Kernel.pbMessage(_INTL("You can't call Machamp here."))

        else  #Mount up!
          $PokemonGlobal.bicycle = false
          pbMountAnim
          if POKEFOLLOW == true
          $PokemonTemp.dependentEvents.remove_sprite(true)
          end
          pbMount(Araquanid)
          pbWait(8)
          if $PLAYPOKEMONCRY_SE == true
            pbSEPlay("Cries/752Cry")
          end
          pbWait(10)
        end
        break
#------------------#
      #Machamp
      elsif cmdMountMachamp>=0 && command==cmdMountMachamp
        #Checks if you are surfing and are facing a "no surfing" tile.
        if surfingchecker == true
          Kernel.pbMessage(_INTL("You can't dismount here."))
          break
        end
        #Checks if you can use mounts indoors.
        if !$CANUSE_INDOORS && !bikeval
          Kernel.pbMessage(_INTL("You can't call Machamp here."))

        else  #Mount up!
          $PokemonGlobal.bicycle = false
          pbMountAnim
          if POKEFOLLOW == true
          $PokemonTemp.dependentEvents.remove_sprite(true)
          end
          pbMount(Machamp)
          pbWait(8)
          if $PLAYPOKEMONCRY_SE == true
            pbSEPlay("Cries/068Cry")
          end
          pbWait(10)
        end
        break
#------------------#
      #Mudsdale
      elsif cmdMountMudsdale>=0 && command==cmdMountMudsdale
        #Checks if you are surfing and are facing a "no surfing" tile.
        if surfingchecker == true
          Kernel.pbMessage(_INTL("You can't dismount here."))
          break
        end
        #Checks if you can use mounts indoors.
        if !$CANUSE_INDOORS && !bikeval
          Kernel.pbMessage(_INTL("You can't call Mudsdale here."))

        else  #Mount up!
          $PokemonGlobal.bicycle = false
          pbMountAnim
          if POKEFOLLOW == true
          $PokemonTemp.dependentEvents.remove_sprite(true)
          end
          pbMount(Mudsdale)
          pbWait(8)
          if $PLAYPOKEMONCRY_SE == true
            pbSEPlay("Cries/750Cry")
          end
          pbWait(10)
        end
        break
#------------------#
      #Stoutland
      elsif cmdMountStoutland>=0 && command==cmdMountStoutland
        #Checks if you are surfing and are facing a "no surfing" tile.
        if surfingchecker == true
          Kernel.pbMessage(_INTL("You can't dismount here."))
          break
        end
        #Checks if you can use mounts indoors.
        if !$CANUSE_INDOORS && !bikeval
          Kernel.pbMessage(_INTL("You can't call Stoutland here."))

        else  #Mount up!
          $PokemonGlobal.bicycle = false
          pbMountAnim
          if POKEFOLLOW == true
          $PokemonTemp.dependentEvents.remove_sprite(true)
          end
          pbMount(Stoutland)
          pbWait(8)
          if $PLAYPOKEMONCRY_SE == true
            pbSEPlay("Cries/508Cry")
          end
          pbWait(10)
        end
        break
#------------------#
      #Rhyhorn
      elsif cmdMountRhyhorn>=0 && command==cmdMountRhyhorn
        #Checks if you are surfing and are facing a "no surfing" tile.
        if surfingchecker == true
          Kernel.pbMessage(_INTL("You can't dismount here."))
          break
        end
        #Checks if you can use mounts indoors.
        if !$CANUSE_INDOORS && !bikeval
          Kernel.pbMessage(_INTL("You can't call Rhyhorn here."))

        else  #Mount up!
          $PokemonGlobal.bicycle = false
          pbMountAnim
          if POKEFOLLOW == true
          $PokemonTemp.dependentEvents.remove_sprite(true)
          end
          pbMount(Rhyhorn)
          pbWait(8)
          if $PLAYPOKEMONCRY_SE == true
            pbSEPlay("Cries/111Cry")
          end
          pbWait(10)
        end
        break
#------------------#
      #Kabutops
      elsif cmdMountKabutops>=0 && command==cmdMountKabutops
        #Checks if you are surfing and are facing a "no surfing" tile.
        if surfingchecker == true
          Kernel.pbMessage(_INTL("You can't dismount here."))
          break
        end
        #Checks if you can use mounts indoors.
        if !$CANUSE_INDOORS && !bikeval
          Kernel.pbMessage(_INTL("You can't call Kabutops here."))

        else  #Mount up!
          $PokemonGlobal.bicycle = false
          pbMountAnim
          if POKEFOLLOW == true
          $PokemonTemp.dependentEvents.remove_sprite(true)
          end
          pbMount(Kabutops)
          pbWait(8)
          if $PLAYPOKEMONCRY_SE == true
            pbSEPlay("Cries/141Cry")
          end
          pbWait(10)
        end
        break
#------------------#
      #Avalugg
      elsif cmdMountAvalugg>=0 && command==cmdMountAvalugg
        #Checks if you are surfing and are facing a "no surfing" tile.
        if surfingchecker == true
          Kernel.pbMessage(_INTL("You can't dismount here."))
          break
        end
        #Checks if you can use mounts indoors.
        if !$CANUSE_INDOORS && !bikeval
          Kernel.pbMessage(_INTL("You can't call Avalugg here."))

        else  #Mount up!
          $PokemonGlobal.bicycle = false
          pbMountAnim
          if POKEFOLLOW == true
          $PokemonTemp.dependentEvents.remove_sprite(true)
          end
          pbMount(Avalugg)
          pbWait(8)
          if $PLAYPOKEMONCRY_SE == true
            pbSEPlay("Cries/713Cry")
          end
          pbWait(10)
        end
        break
#------------------#
      #Gogoat
      elsif cmdMountGogoat>=0 && command==cmdMountGogoat
        #Checks if you are surfing and are facing a "no surfing" tile.
        if surfingchecker == true
          Kernel.pbMessage(_INTL("You can't dismount here."))
          break
        end
        #Checks if you can use mounts indoors.
        if !$CANUSE_INDOORS && !bikeval
          Kernel.pbMessage(_INTL("You can't call Gogoat here."))

        else  #Mount up!
          $PokemonGlobal.bicycle = false
          pbMountAnim
         if POKEFOLLOW == true
          $PokemonTemp.dependentEvents.remove_sprite(true)
          end
          pbMount(Gogoat)
          pbWait(8)
          if $PLAYPOKEMONCRY_SE == true
            pbSEPlay("Cries/673Cry")
          end
          pbWait(10)
        end
        break
#------------------#
      #Hippowdon
      elsif cmdMountHippowdon>=0 && command==cmdMountHippowdon
        #Checks if you are surfing and are facing a "no surfing" tile.
        if surfingchecker == true
          Kernel.pbMessage(_INTL("You can't dismount here."))
          break
        end
        #Checks if you can use mounts indoors.
        if !$CANUSE_INDOORS && !bikeval
          Kernel.pbMessage(_INTL("You can't call Hippowdon here."))

        else  #Mount up!
          $PokemonGlobal.bicycle = false
          pbMountAnim
          if POKEFOLLOW == true
          $PokemonTemp.dependentEvents.remove_sprite(true)
          end
          pbMount(Hippowdon)
          pbWait(8)
          if $PLAYPOKEMONCRY_SE == true
            pbSEPlay("Cries/450Cry")
          end
          pbWait(10)
        end
        break
#------------------#
      #Luxray
      elsif cmdMountLuxray>=0 && command==cmdMountLuxray
        #Checks if you are surfing and are facing a "no surfing" tile.
        if surfingchecker == true
          Kernel.pbMessage(_INTL("You can't dismount here."))
          break
        end
        #Checks if you can use mounts indoors.
        if !$CANUSE_INDOORS && !bikeval
          Kernel.pbMessage(_INTL("You can't call Luxray here."))

        else  #Mount up!
          $PokemonGlobal.bicycle = false
          pbMountAnim
          if POKEFOLLOW == true
          $PokemonTemp.dependentEvents.remove_sprite(true)
          end
          pbMount(Luxray)
          pbWait(8)
          if $PLAYPOKEMONCRY_SE == true
            pbSEPlay("Cries/405Cry")
          end
          pbWait(10)
        end
        break
#------------------#
      #Swampert
      elsif cmdMountSwampert>=0 && command==cmdMountSwampert
        #Checks if you are surfing and are facing a "no surfing" tile.
        if surfingchecker == true
          Kernel.pbMessage(_INTL("You can't dismount here."))
          break
        end
        #Checks if you can use mounts indoors.
        if !$CANUSE_INDOORS && !bikeval
          Kernel.pbMessage(_INTL("You can't call Luxray here."))

        else  #Mount up!
          $PokemonGlobal.bicycle = false
          pbMountAnim
          if POKEFOLLOW == true
          $PokemonTemp.dependentEvents.remove_sprite(true)
          end
          pbMount(Swampert)
          pbWait(8)
          if $PLAYPOKEMONCRY_SE == true
            pbSEPlay("Cries/260Cry")
          end
          pbWait(10)
        end
        break
#------------------#
      #Torkoal
      elsif cmdMountTorkoal>=0 && command==cmdMountTorkoal && $EXTRAMOUNTS == true && defined?($PokemonGlobal.lavasurfing)
        #Checks if you are lava surfing and are facing a "no lava surfing" tile.
        if surfingchecker == true
          Kernel.pbMessage(_INTL("You can't dismount here."))
          break
        end
        #Checks if you can use mounts indoors.
        if !$CANUSE_INDOORS && !$CANUSE_INDOORS_SURFMOUNTS && !bikeval
          Kernel.pbMessage(_INTL("You can't call Torkoal here."))

        #Checks for lava surfable tiles.
        elsif PBTerrain.isLavaSurfable?(facingTag) && defined?(!$PokemonGlobal.lavasurfing) &&
          !pbGetMetadata($game_map.map_id,MetadataBicycleAlways) && notCliff
          $PokemonGlobal.bicycle = false
          pbMount(Torkoal)  #Mount up!
          if POKEFOLLOW == true
          $PokemonTemp.dependentEvents.remove_sprite(true)
          end
          pbMountJumpTowards
          pbWait(2)
          pbMountAnim
          pbWait(8)
          if $PLAYPOKEMONCRY_SE == true
            pbSEPlay("Cries/324Cry")
          end
          lavasurfbgm=pbGetLavaSurfTheme
          pbCueBGM(lavasurfbgm,0.5) if lavasurfbgm

        else  #No lava surfable tiles.
          Kernel.pbMessage(_INTL("You can't call Torkoal here."))
        end
        break
#------------------#
      #Flygon
      elsif cmdMountFlygon>=0 && command==cmdMountFlygon && $EXTRAMOUNTS == true
        #Checks if you are surfing and are facing a "no surfing" tile.
        if surfingchecker == true
          Kernel.pbMessage(_INTL("You can't dismount here."))
          break
        end
        #Checks if you can use mounts indoors.
        if !$CANUSE_INDOORS && !bikeval
          Kernel.pbMessage(_INTL("You can't call Flygon here."))

        else  #Mount up!
          pbMountAnim
          if POKEFOLLOW == true
          $PokemonTemp.dependentEvents.remove_sprite(true)
          end
          pbMount(Flygon)
          pbWait(8)
          if $PLAYPOKEMONCRY_SE == true
            pbSEPlay("Cries/330Cry")
          end
          pbWait(10)
        end
        break
#------------------#
      #QUIT
      elsif cmdQUIT>=0 && command==cmdQUIT
        #Exit the menu.
        break
      end
    end
  end
  
  else
    #Checks if you are surfing (or lava surfing) and facing a "no surfing" tile.
    pbSurfingChecker
    #Checks if you are surfing (or lava surfing).
    pbCurrentlySurfingChecker

    #Checks if the player is on or facing custom "no-dismounting" terrain tag.
    if $NODISMOUNTING_TERRAINTAG && (facingTag==$NODISMOUNTING_TERRAINTAG ||
      facingTag==$NODISMOUNTING_TERRAINTAG || currentTag==$NODISMOUNTING_TERRAINTAG)
      Kernel.pbMessage(_INTL("You can't dismount right now."))

    #Is Diving?
    elsif $PokemonGlobal.diving == true
      Kernel.pbMessage(_INTL("You can't dismount right now."))
      
    #Is Sliding?
    elsif $PokemonGlobal.sliding == true
      #Do nothing.

    #On a bike?
    elsif $PokemonGlobal.bicycle == true
      Kernel.pbMessage(_INTL("You can't use your bike while riding a Pokémon!"))


    ##Flying Dismount
    #Riding Flygon?
    elsif $PokemonGlobal.mount == Flygon
      if (PBTerrain.isSurfable?(currentTag))
        Kernel.pbMessage(_INTL("You can't dismount right now."))
      else
        pbMountAnim
        pbDismount
      end


      #Riding Rhyhorn?
      if $PokemonGlobal.mount == Rhyhorn
        Kernel.pbMessage(_INTL("You can't dismount right now."))
      else
        pbMountAnim
        pbDismount
      end

    ##Surf Dismount
    elsif $PokemonGlobal.surfing == true
      if PBTerrain.isSurfable?(currentTag) && PBTerrain.isSurfable?(facingTag) #&& !notCliff
        #Riding Lapras?
        if $PokemonGlobal.mount == Lapras
          if $PokemonSystem.register_sharpedo == 1
            if Kernel.pbConfirmMessage(_INTL("Switch to Sharpedo?"))
              pbMount(Sharpedo)  #Mount swap!
              pbMountAnim
              if $PLAYPOKEMONCRY_SE == true
                pbSEPlay("Cries/319Cry")
              end
            elsif $PokemonSystem.register_lanturn == 1
              if Kernel.pbConfirmMessage(_INTL("Switch to Lanturn?"))
                pbMount(Sharpedo)  #Mount swap!
                pbMountAnim
                if $PLAYPOKEMONCRY_SE == true
                  pbSEPlay("Cries/171Cry")
                end
              else
                Kernel.pbMessage(_INTL("You can't dismount right now."))
              end
            else
              Kernel.pbMessage(_INTL("You can't dismount right now."))
            end
          elsif $PokemonSystem.register_lanturn == 1
            if Kernel.pbConfirmMessage(_INTL("Switch to Lanturn?"))
              pbMount(Lanturn)  #Mount swap!
              pbMountAnim
              if $PLAYPOKEMONCRY_SE == true
                pbSEPlay("Cries/171Cry")
              end
            else
              Kernel.pbMessage(_INTL("You can't dismount right now."))
            end
          end
        #Riding Sharpedo?
        elsif $PokemonGlobal.mount == Sharpedo
          if $PokemonSystem.register_lanturn == 1
            if Kernel.pbConfirmMessage(_INTL("Switch to Lanturn?"))
              pbMount(Lanturn)  #Mount swap!
              pbMountAnim
              if $PLAYPOKEMONCRY_SE == true
                pbSEPlay("Cries/171Cry")
              end
            elsif $PokemonSystem.register_lapras == 1
              if Kernel.pbConfirmMessage(_INTL("Switch to Lapras?"))
                pbMount(Lapras)  #Mount swap!
                pbMountAnim
                if $PLAYPOKEMONCRY_SE == true
                  pbSEPlay("Cries/131Cry")
                end
              else
                Kernel.pbMessage(_INTL("You can't dismount right now."))
              end
            else
              Kernel.pbMessage(_INTL("You can't dismount right now."))
            end
          elsif $PokemonSystem.register_lapras == 1
            if Kernel.pbConfirmMessage(_INTL("Switch to Lapras?"))
              pbMount(Lapras)  #Mount swap!
              pbMountAnim
              if $PLAYPOKEMONCRY_SE == true
                pbSEPlay("Cries/131Cry")
              end
            else
              Kernel.pbMessage(_INTL("You can't dismount right now."))
            end
          end
        #Riding Lanturn?
        elsif $PokemonGlobal.mount == Lanturn
          if $PokemonSystem.register_lapras == 1
            if Kernel.pbConfirmMessage(_INTL("Switch to Lapras?"))
              pbMount(Lapras)  #Mount swap!
              pbMountAnim
              if $PLAYPOKEMONCRY_SE == true
                pbSEPlay("Cries/131Cry")
              end
            elsif $PokemonSystem.register_sharpedo == 1
              if Kernel.pbConfirmMessage(_INTL("Switch to Sharpedo?"))
                pbMount(Sharpedo)  #Mount swap!
                pbMountAnim
                if $PLAYPOKEMONCRY_SE == true
                  pbSEPlay("Cries/319Cry")
                end
              else
                Kernel.pbMessage(_INTL("You can't dismount right now."))
              end
            else
              Kernel.pbMessage(_INTL("You can't dismount right now."))
            end
          elsif $PokemonSystem.register_sharpedo == 1
            if Kernel.pbConfirmMessage(_INTL("Switch to Sharpedo?"))
              pbMount(Sharpedo)  #Mount swap!
              pbMountAnim
              if $PLAYPOKEMONCRY_SE == true
                pbSEPlay("Cries/319Cry")
              end
            else
              Kernel.pbMessage(_INTL("You can't dismount right now."))
            end
          end
        end
      #If surfing, jump to land first.
      elsif pbSurfingChecker == true
        #p "SURFING DISMOUNT!"  #Debug
        $PokemonGlobal.surfing = false
        pbDismount  #Dismount!
        pbMountJumpTowards
        pbWait(2)
        pbMountAnim
        pbWait(8)
        $game_map.autoplayAsCue
        $game_player.increase_steps
        result=$game_player.check_event_trigger_here([1,2])
        Kernel.pbOnStepTaken(result)
      end

    else  #Dismount normally.
      pbMountAnim
      pbDismount

    end

  end

end


#==============================================================================#
#  Code for Pokemon party auto registering.                                    #
#==============================================================================#
class Game_Map
  alias mounts_check_party_pokemon update

  def update
    mounts_check_party_pokemon
    #Register Check
    if !$ALLMOUNTS_PREREG && $PARTY_AUTOREG
      #Tauros
      if pbHasSpecies?(:TAUROS) && $PokemonSystem.register_tauros == 0
        $PokemonSystem.register_tauros = 1  #If the player has a Tauros in their party, register it in the Ride Pager.
      end
      #Rampardos
      if $EXTRAMOUNTS
        if pbHasSpecies?(:RAMPARDOS) && $PokemonSystem.register_rampardos == 0
          $PokemonSystem.register_rampardos = 1  #If the player has a Rampardos in their party, register it in the Ride Pager.
        end
      end
      #Lapras
      if pbHasSpecies?(:LAPRAS) && $PokemonSystem.register_lapras == 0
        $PokemonSystem.register_lapras = 1  #If the player has a Lapras in their party, register it in the Ride Pager.
      end
      #Sharpedo
      if pbHasSpecies?(:SHARPEDO) && $PokemonSystem.register_sharpedo == 0
        $PokemonSystem.register_sharpedo = 1  #If the player has a Sharpedo in their party, register it in the Ride Pager.
      end
      #Lanturn
      if $EXTRAMOUNTS
        if pbHasSpecies?(:LANTURN) && $PokemonSystem.register_lanturn == 0
          $PokemonSystem.register_lanturn = 1  #If the player has a Lanturn in their party, register it in the Ride Pager.
        end
      end
      #Araquanid
      if $EXTRAMOUNTS
        if pbHasSpecies?(:ARAQUANID) && $PokemonSystem.register_araquanid == 0
          $PokemonSystem.register_araquanid = 1  #If the player has a Araquanid in their party, register it in the Ride Pager.
        end
      end
      #Machamp
      if pbHasSpecies?(:MACHAMP) && $PokemonSystem.register_machamp == 0
        $PokemonSystem.register_machamp = 1  #If the player has a Machamp in their party, register it in the Ride Pager.
      end
      #Mudsdale
      if pbHasSpecies?(:MUDSDALE) && $PokemonSystem.register_mudsdale == 0
        $PokemonSystem.register_mudsdale = 1  #If the player has a Mudsdale in their party, register it in the Ride Pager.
      end
      #Stoutland
      if pbHasSpecies?(:STOUTLAND) && $PokemonSystem.register_stoutland == 0
        $PokemonSystem.register_stoutland = 1  #If the player has a Stoutland in their party, register it in the Ride Pager.
      end
      #Rhyhorn
      if pbHasSpecies?(:RHYHORN) && $PokemonSystem.register_rhyhorn == 0
        $PokemonSystem.register_rhyhorn = 1  #If the player has a Rhyhorn in their party, register it in the Ride Pager.
      end
      #Kabutops
      if $EXTRAMOUNTS
        if pbHasSpecies?(:KABUTOPS) && $PokemonSystem.register_kabutops == 0
          $PokemonSystem.register_kabutops = 1  #If the player has a Kabutops in their party, register it in the Ride Pager.
        end
      end
      #Avalugg
      if $EXTRAMOUNTS
        if pbHasSpecies?(:AVALUGG) && $PokemonSystem.register_avalugg == 0
          $PokemonSystem.register_avalugg = 1  #If the player has an Avalugg in their party, register it in the Ride Pager.
        end
      end
      #Gogoat
      if $EXTRAMOUNTS
        if pbHasSpecies?(:GOGOAT) && $PokemonSystem.register_gogoat == 0
          $PokemonSystem.register_gogoat = 1  #If the player has a Gogoat in their party, register it in the Ride Pager.
        end
      end
      #Hippowdon
      if $EXTRAMOUNTS
        if pbHasSpecies?(:HIPPOWDON) && $PokemonSystem.register_hippowdon == 0
          $PokemonSystem.register_hippowdon = 1  #If the player has a Hippowdon in their party, register it in the Ride Pager.
        end
      end
      #Luxray
      if $EXTRAMOUNTS
        if pbHasSpecies?(:LUXRAY) && $PokemonSystem.register_luxray == 0
          $PokemonSystem.register_luxray = 1  #If the player has a Luxray in their party, register it in the Ride Pager.
        end
      end
      #Swampert
      if $EXTRAMOUNTS
        if pbHasSpecies?(:SWAMPERT) && $PokemonSystem.register_swampert == 0
          $PokemonSystem.register_swampert = 1  #If the player has a Swampert in their party, register it in the Ride Pager.
        end
      end
      #Torkoal
      if $EXTRAMOUNTS && defined?($PokemonGlobal.lavasurfing)
        if pbHasSpecies?(:TORKOAL) && $PokemonSystem.register_torkoal == 0
          $PokemonSystem.register_torkoal = 1  #If the player has a Torkoal in their party, register it in the Ride Pager.
        end
      end
      #Flygon
      if $EXTRAMOUNTS
        if pbHasSpecies?(:FLYGON) && $PokemonSystem.register_flygon == 0
          $PokemonSystem.register_flygon = 1  #If the player has a Flygon in their party, register it in the Ride Pager.
        end
      end
    end
  

    #:::Deregister Check:::
    if !$ALLMOUNTS_PREREG && $PARTY_AUTOREG && $PARTY_AUTODEREG
      #Tauros
      if !pbHasSpecies?(:TAUROS) && $PokemonSystem.register_tauros == 1
        $PokemonSystem.register_tauros = 0  #If the player had Tauros registered, but it was removed from the part, deregister it.
        #If already mounted on Tauros, force a dismount (if allowed).
        if $PokemonGlobal.mount == Tauros
          pbDismount
        end
      end
      #Rampardos
      if $EXTRAMOUNTS == true
        if !pbHasSpecies?(:RAMPARDOS) && $PokemonSystem.register_rampardos == 1
          $PokemonSystem.register_rampardos = 0  #If the player had Rampardos registered, but it was removed from the part, deregister it.
          #If already mounted on Rampardos, force a dismount (if allowed).
          if $PokemonGlobal.mount == Rampardos
            pbDismount
          end
        end
      end
      #Lapras
      if !pbHasSpecies?(:LAPRAS) && $PokemonSystem.register_lapras == 1
        $PokemonSystem.register_lapras = 0  #If the player had Lapras registered, but it was removed from the part, deregister it.
        #If already mounted on Lapras, force a dismount (if allowed).
        if $PokemonGlobal.mount == Lapras
          if $PokemonGlobal.surfing == true
            #Do nothing.
          else
            pbDismount
          end
        end
      end
      #Sharpedo
      if !pbHasSpecies?(:SHARPEDO) && $PokemonSystem.register_sharpedo == 1
        $PokemonSystem.register_sharpedo = 0  #If the player had Sharpedo registered, but it was removed from the part, deregister it.
        #If already mounted on Sharpedo, force a dismount (if allowed).
        if $PokemonGlobal.mount == Sharpedo
          if $PokemonGlobal.surfing == true
            #Do nothing.
          else
            pbDismount
          end
        end
      end
      #Lanturn
      if $EXTRAMOUNTS == true
        if !pbHasSpecies?(:LANTURN) && $PokemonSystem.register_lanturn == 1
          $PokemonSystem.register_lanturn = 0  #If the player had Lanturn registered, but it was removed from the part, deregister it.
          #If already mounted on Lanturn, force a dismount (if allowed).
          if $PokemonGlobal.mount == Lanturn
            pbDismount
          end
        end
      end
      #Araquanid
      if $EXTRAMOUNTS == true
        if !pbHasSpecies?(:ARAQUANID) && $PokemonSystem.register_araquanid == 1
          $PokemonSystem.register_araquanid = 0  #If the player had Araquanid registered, but it was removed from the part, deregister it.
          #If already mounted on Araquanid, force a dismount (if allowed).
          if $PokemonGlobal.mount == Araquanid
            pbDismount
          end
        end
      end
      #Machamp
      if !pbHasSpecies?(:MACHAMP) && $PokemonSystem.register_machamp == 1
        $PokemonSystem.register_machamp = 0  #If the player had Machamp registered, but it was removed from the part, deregister it.
        #If already mounted on Machamp, force a dismount (if allowed).
        if $PokemonGlobal.mount == Machamp
          pbDismount
        end
      end
      #Mudsdale
      if !pbHasSpecies?(:MUDSDALE) && $PokemonSystem.register_mudsdale == 1
        $PokemonSystem.register_mudsdale = 0  #If the player had Mudsdale registered, but it was removed from the part, deregister it.
        #If already mounted on Mudsdale, force a dismount (if allowed).
        if $PokemonGlobal.mount == Mudsdale
          pbDismount
        end
      end
      #Stoutland
      if !pbHasSpecies?(:STOUTLAND) && $PokemonSystem.register_stoutland == 1
        $PokemonSystem.register_stoutland = 0  #If the player had Stoutland registered, but it was removed from the part, deregister it.
        #If already mounted on Stoutland, force a dismount (if allowed).
        if $PokemonGlobal.mount == Stoutland
          pbDismount
        end
      end
      #Rhyhorn
      if !pbHasSpecies?(:RHYHORN) && $PokemonSystem.register_rhyhorn == 1
        $PokemonSystem.register_rhyhorn = 0  #If the player had Rhyhorn registered, but it was removed from the part, deregister it.
        #If already mounted on Rhyhorn, force a dismount (if allowed).
        if $PokemonGlobal.mount == Rhyhorn
          pbDismount
        end
      end
      #Kabutops
      if $EXTRAMOUNTS == true
        if !pbHasSpecies?(:KABUTOPS) && $PokemonSystem.register_kabutops == 1
          $PokemonSystem.register_kabutops = 0  #If the player had Kabutops registered, but it was removed from the part, deregister it.
          #If already mounted on Kabutops, force a dismount (if allowed).
          if $PokemonGlobal.mount == Kabutops
            pbDismount
          end
        end
      end
      #Avalugg
      if $EXTRAMOUNTS == true
        if !pbHasSpecies?(:AVALUGG) && $PokemonSystem.register_avalugg == 1
          $PokemonSystem.register_avalugg = 0  #If the player had Avalugg registered, but it was removed from the part, deregister it.
          #If already mounted on Avalugg, force a dismount (if allowed).
          if $PokemonGlobal.mount == Avalugg
            pbDismount
          end
        end
      end
      #Gogoat
      if $EXTRAMOUNTS == true
        if !pbHasSpecies?(:GOGOAT) && $PokemonSystem.register_gogoat == 1
          $PokemonSystem.register_gogoat = 0  #If the player had Gogoat registered, but it was removed from the part, deregister it.
          #If already mounted on Gogoat, force a dismount (if allowed).
          if $PokemonGlobal.mount == Gogoat
            pbDismount
          end
        end
      end
      #Hippowdon
      if $EXTRAMOUNTS == true
        if !pbHasSpecies?(:HIPPOWDON) && $PokemonSystem.register_hippowdon == 1
          $PokemonSystem.register_hippowdon = 0  #If the player had Hippowdon registered, but it was removed from the part, deregister it.
          #If already mounted on Hippowdon, force a dismount (if allowed).
          if $PokemonGlobal.mount == Hippowdon
            pbDismount
          end
        end
      end
      #Luxray
      if $EXTRAMOUNTS == true
        if !pbHasSpecies?(:LUXRAY) && $PokemonSystem.register_luxray == 1
          $PokemonSystem.register_luxray = 0  #If the player had Luxray registered, but it was removed from the part, deregister it.
          #If already mounted on Luxray, force a dismount (if allowed).
          if $PokemonGlobal.mount == Luxray
            pbDismount
          end
        end
      end
      #Swampert
      if $EXTRAMOUNTS == true
        if !pbHasSpecies?(:SWAMPERT) && $PokemonSystem.register_swampert == 1
          $PokemonSystem.register_swampert = 0  #If the player had Swampert registered, but it was removed from the part, deregister it.
          #If already mounted on Swampert, force a dismount (if allowed).
          if $PokemonGlobal.mount == Swampert
            pbDismount
          end
        end
      end
      #Torkoal
      if $EXTRAMOUNTS == true #&& defined?($PokemonGlobal.lavasurfing)
        if !pbHasSpecies?(:TORKOAL) && $PokemonSystem.register_torkoal == 1
          $PokemonSystem.register_torkoal = 0  #If the player had Torkoal registered, but it was removed from the part, deregister it.
          #If already mounted on Torkoal, force a dismount (if allowed).
          if $PokemonGlobal.mount == Torkoal
            pbDismount
          end
        end
      end
      #Flygon
      if $EXTRAMOUNTS == true
        if !pbHasSpecies?(:FLYGON) && $PokemonSystem.register_flygon == 1
          $PokemonSystem.register_flygon = 0  #If the player had Flygon registered, but it was removed from the part, deregister it.
          #If already mounted on Flygon, force a dismount (if allowed).
          if $PokemonGlobal.mount == Flygon
            pbDismount
          end
        end
      end
    end
  end
end


module Input
  class << Input
    alias fly_key buttonToKey
  end
  
  G = 30
  
  def self.buttonToKey(btn)
    return [0x47] if btn == Input::G
    fly_key(btn)
  end
end