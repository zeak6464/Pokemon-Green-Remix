# Every PokéRide should have MoveSheet, MoveSpeed, ActionSheet, and ActionSpeed.
# A PokéRide can also have one or more of the following options:

#  -> RockSmash: While the action button (Z) is being pressed, any rock you
#                walk up to will be smashed.
#  -> CanSurf: This Pokémon can be surfed with.
#  -> WalkOnMudsdale: With this PokéRide, you can walk over terrain with
#                     terrain tag 17.
#  -> Strength: Boulders can be moved if the action button is held down.
#  -> ShowHidden: If the action button is held down, any listed event with
#                 ".hidden" (without the quotation marks) within a 4x4 radius
#                 will cause the Pokéride to use "HiddenNearbySheet" and
#                 "HiddenNearbySpeed". Those two must also be implemented if your
#                 Pokéride has "ShowHidden"
#  -> RockClimb: If set to true, 

# You can have multiple of these options at once. They should all be compatible
# with one another.


# Rock Smash rocks still have to be called "Rock" without the quotation marks.
# Boulders still have to be called "Boulder" and their trigger method should be
#     "Player Touch" and it should have just one line of script: "pbPushThisBoulder"

# Hidden items are ".hidden" without the quotation marks for compatibility
# with my Pokétch resource.
# They work the same way as hidden items there:
# pbUnlist(event_id): The event becomes hidden from the Itemfinder (Stoutland)
# pbList(event_id): The event becomes visible for the Itemfinder (Stoutland)
#                   IF the event has ".hidden" in the name.


# If you want Surf to be the normal surf, set this to nil. Else, set it to the
# name of the PokéRide in a string (e.g. "Sharpedo")
SURF_MOUNT = "Sharpedo"

# If you want a Pokéride to be able to perform Rock Climb, set this to the
# name of the Pokéride. If you don't want Rock Climb, set this to nil.
ROCK_CLIMB_MOUNT = nil
# This is the Pokéride that is called if you press C in front of a Rock Climb tile
# while not being on a Pokéride that can already use Rock Climb, which means
# that this is essentially the same as "SURF_MOUNT".


# A Pokéride can also have an effect that is activated when you mount it.
# To implement something there, add your code in a method called "def self.mount".
# The same can be done for dismounting, but in "def self.dismount"


# pbMount(Tauros)
module Tauros
  MoveSheet = ["128","128"]
  MoveSpeed = 6.0
  ActionSheet = ["128","128"]
  ActionSpeed = 5.6
  RockSmash = true
end

# pbMount(Lapras)
module Lapras
  MoveSheet = ["131","131"]
  MoveSpeed = 5.8
  ActionSheet = ["131","131"]
  ActionSpeed = 5.4
  CanSurf = true
end


# pbMount(Machamp)
module Machamp
  MoveSheet = ["068","068"]
  MoveSpeed = 5.3
  ActionSheet = ["068","068"]
  ActionSpeed = 3.8
  Strength = true
end

# You get the idea now. pbMount(Mudsdale)
module Mudsdale
  MoveSheet = ["750","750"]
  MoveSpeed = 5.1
  ActionSheet = ["750","750"]
  ActionSpeed = 4.6
  WalkOnMudsdale = true
end

module Stoutland
  MoveSheet = ["508","508"]
  MoveSpeed = 5.6
  ActionSheet = ["508","508"]
  ActionSpeed = 3.6
  HiddenNearbySheet = ["508","508"]
  HiddenNearbySpeed = 3.6
  ShowHidden = true
end

module Rhyhorn
  MoveSheet = ["111","111"]
  MoveSpeed = 5.4
  ActionSheet = ["111","111"]
  ActionSpeed = 4.4
  RockClimb = true
end

#==============================================================================#
#  Code for the Extra Mounts.                                                  #
#==============================================================================#

LAVASURF_MOUNT = nil  #"Torkoal"

# pbMount(Torkoal)
module Torkoal
  MoveSheet = ["324","324"]
  ActionSheet = ["324","324"]
  MoveSpeed = 5.6
  ActionSpeed = 5.2
end

# pbMount(Flygon)
module Flygon
  MoveSheet = ["330","330"]
  ActionSheet = ["330","330"]
  MoveSpeed = 5.6
  ActionSpeed = 5.2
  FlyOverWater = true
  RockClimb = true
  WalkOnMudsdale = true
  IceTraction = true
  CanFly = true
end

module Sharpedo
  MoveSheet = ["319","319"]
  ActionSheet = ["319","319"]
  MoveSpeed = 6.4
  ActionSpeed = 6.0
  CanSurf = true
  CanDive = true
  RockSmash = true
end

# pbMount(Kabutops)
module Kabutops
  MoveSheet = ["141","141"]
  ActionSheet = ["141","141"]
  MoveSpeed = 5.2
  ActionSpeed = 5.0
  AttackSpeed = 5.5
  CanCut = true
end

# pbMount(Avalugg)
module Avalugg
  MoveSheet = ["713","713"]
  ActionSheet = ["713","713"]
  MoveSpeed = 5.9
  ActionSpeed = 4.5
  IceTraction = true
end

# pbMount(Gogoat)
module Gogoat
  MoveSheet = ["673","673"]
  ActionSheet = ["673","673"]
  MoveSpeed = 5.9
  ActionSpeed = 5.5
  CanHeadbutt = true
end

# pbMount(Hippowdon)
module Hippowdon
  MoveSheet = ["450","450"]
  ActionSheet = ["450",""]
  MoveSpeed = 5.5
  ActionSpeed = 4.9
  CanDig = true
 end
 
 # pbMount(Luxray)
module Luxray
  MoveSheet = ["405","405"]
  ActionSheet = ["405","405"]
  MoveSpeed = 5.8
  ActionSpeed = 5.2
  CanFlash = true
end

# pbMount(Swampert)
module Swampert
  MoveSheet = ["260","260"]
  ActionSheet = ["260","260"]
  MoveSpeed = 5.8
  ActionSpeed = 5.2
  CanSwampSurf = true
end

# pbMount(Lanturn)
module Lanturn
  MoveSheet = ["171","171"]
  ActionSheet = ["171","171"]
  MoveSpeed = 6.0
  ActionSpeed = 5.6
  CanSurf = true
  CanDive = true
  CanFlash = true
end

# pbMount(Araquanid)
module Araquanid
  MoveSheet = ["752","752"]
  ActionSheet = ["752","752"]
  MoveSpeed = 5.8
  ActionSpeed = 5.8
  CanDive = true
  WalkOnWater = true
  StayOnTransfer = true
end

# pbMount(Rampardos)
module Rampardos
  MoveSheet = ["409","409"]
  ActionSheet = ["409","409"]
  MoveSpeed = 6.0
  ActionSpeed = 5.6
  RockSmash = true
end