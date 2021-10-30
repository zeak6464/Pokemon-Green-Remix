#==============================================================================#
#                Pokéride for Pokémon Essentials v16.X | v17.X                 #
#                                    v1.0                                      #
#                                                                              #
#                                  by Marin                                    #
#==============================================================================#
#                                    Note                                      #
# This script is merely for functionality. It does not provide a whole system, #
#    and things such as availability of certain Pokérides is not included.     #
#==============================================================================#
#                                    Usage                                     #
#  To mount a Pokéride, use "pbMount(name)". "name" is the name of the module, #
#                  which can be found in "Pokéride_Rides".                     #
#==============================================================================#

# Example:
# pbMount(Tauros)
def pbMount(_module)
  sheet = _module::MoveSheet[$Trainer.gender]
  $game_player.setDefaultCharName(sheet,$game_player.fullPattern)
  _module.mount if _module.respond_to?("mount")
  $PokemonGlobal.surfing = true if defined?(_module::CanSurf) && _module::CanSurf
  $PokemonGlobal.mount = _module
end

def pbDismount
  $PokemonGlobal.mount.dismount if $PokemonGlobal.mount &&
                                   $PokemonGlobal.mount.respond_to?("dismount")
  $PokemonGlobal.surfing = false if defined?(_module::CanSurf) && _module::CanSurf
  $PokemonGlobal.mount = nil
  $game_player.setDefaultCharName(nil,$game_player.fullPattern)
end

# $Trainer.can_rock_climb has to be true if you want to be able to use Rock Climb.
class PokeBattle_Trainer
  attr_accessor :can_rock_climb
  
  alias pokeride_init initialize
  def initialize(name, trainertype)
    pokeride_init(name, trainertype)
    @can_rock_climb = false
  end
end

unless defined?(pbList)
  # If you call this on an event, it'll be no longer listed in the Itemfinder
  # (if it even had ".hidden" in the name)
  def pbUnlist(event_id)
    $game_map.events[event_id].listed = false if $game_map.events[event_id]
  end
  
  # The Itemfinder will show this event (but still only if it has .hidden in name)
  def pbList(event_id)
    $game_map.events[event_id].listed = true if $game_map.events[event_id]
  end
end


class PokemonGlobalMetadata
  attr_accessor :mount
  attr_accessor :mount_action
end

unless defined?(Game_Event.listed)
  class Game_Event
    attr_accessor :listed
    
    alias pokeride_init initialize
    def initialize(map_id, event, map = nil)
      pokeride_init(map_id, event, map)
      @listed = true # Set to true, but whether it's actually listed or not
                     # depends on the name.
    end
  end
end

def pbHiddenItemNearby?
  x = $game_player.x
  y = $game_player.y
  for event in $game_map.events
    event = event[1]
    if event.name.include?(".hidden") && event.listed
      if event.x - x >= -4 && event.x - x <= 4
        if event.y - y >= -4 && event.y - y <= 4
          return true
        end
      end
    end
  end
  return false
end

class Game_Player
  alias pokeride_update update
  def update
    pokeride_update
    if $PokemonGlobal.mount
      if Input.press?(Input::A)
        @move_speed = $PokemonGlobal.mount::ActionSpeed
        sheet = $PokemonGlobal.mount::ActionSheet[$Trainer.gender]
        $game_player.setDefaultCharName(sheet,$game_player.fullPattern)
        $PokemonGlobal.mount_action = true
        if defined?($PokemonGlobal.mount::ShowHidden) && $PokemonGlobal.mount::ShowHidden
          if pbHiddenItemNearby?
            sheet = $PokemonGlobal.mount::HiddenNearbySheet[$Trainer.gender]
            $game_player.setDefaultCharName(sheet,$game_player.fullPattern)
            @move_speed = $PokemonGlobal.mount::HiddenNearbySpeed
          end
        end
      else
        @move_speed = $PokemonGlobal.mount::MoveSpeed
        sheet = $PokemonGlobal.mount::MoveSheet[$Trainer.gender]
        $game_player.setDefaultCharName(sheet,$game_player.fullPattern)
        $PokemonGlobal.mount_action = false
      end
    end
  end
  
  alias pokeride_trigger check_event_trigger_there
  def check_event_trigger_there(triggers)
    result = pokeride_trigger(triggers)
    return result if ROCK_CLIMB_MOUNT.nil?
    new_x = @x + (@direction == 6 ? 1 : @direction == 4 ? -1 : 0)
    new_y = @y + (@direction == 2 ? 1 : @direction == 8 ? -1 : 0)
    if result == false
      for i in [2,1,0]
        if $game_map.terrain_tags[$game_map.map.data[new_x, new_y, i]] == PBTerrain::RockClimb
          activemount = $PokemonGlobal.mount && defined?($PokemonGlobal.mount::RockClimb) &&
                        $PokemonGlobal.mount::RockClimb
          if activemount || $Trainer.can_rock_climb && Kernel.pbConfirmMessage(_INTL("Do you want to rock climb here?"))
            unless activemount
              Kernel.pbCancelVehicles
              pbMount(eval(ROCK_CLIMB_MOUNT))
              pbWait(10)
            end
            climb = true
            up = false
            for j in [2,1,0]
              if @y > 0 && (($game_map.terrain_tags[$game_map.map.data[@x+2,@y-1,j]] == PBTerrain::RockClimb rescue false) ||
                 (@x > 1 && $game_map.terrain_tags[$game_map.map.data[@x-2,@y-1,j]] == PBTerrain::RockClimb))
                up = true
                break
              end
            end
            unless @direction == 2 || direction == 8
              @x += (@direction == 6 ? 1 : @direction == 4 ? -1 : 0)
            end
            pbWait(4)
            while climb
              _x = @x + (@direction == 6 ? 1 : @direction == 4 ? -1 : 0)
              _y = @y
              if @direction == 2 || @direction == 8
                _y = @y + (@direction == 2 ? 1 : @direction == 8 ? -1 : 0)
              elsif up
                _y -= 1
              else
                _y += 1
              end
              pbWait(4)
              climb = false
              @x = _x
              for j in [2,1,0]
                if $game_map.terrain_tags[$game_map.map.data[_x, _y, j]] == PBTerrain::RockClimb
                  climb = true
                  break
                end
              end
              @y = _y if climb || @direction == 2 || @direction == 8
            end
          end
          return true
        end
      end
    end
    return result
  end
end

if defined?(Sprite_SurfBase)
  class Sprite_SurfBase
    alias pokeride_init initialize
    def initialize(sprite, event, viewport = nil)
      return if $PokemonGlobal.mount
      pokeride_init(sprite, event, viewport)
    end
    
    alias pokeride_update update
    def update
      return if $PokemonGlobal.mount
      pokeride_update
    end
    
    def dispose
      if !@disposed
        @sprite.dispose if @sprite
        @sprite   = nil
        @surfbitmap.dispose if @surfbitmap
        @surfbitmap = nil
        @disposed = true
      end
    end
  end
end

module Kernel
  class << Kernel
    alias pokeride_cancel_vehicles pbCancelVehicles
    alias pokeride_surf pbSurf
  end
  
  def self.pbCancelVehicles(destination = nil)
    pbDismount
    pokeride_cancel_vehicles(destination)
  end
  
  def self.pbSurf
    unless SURF_MOUNT.nil?
      Kernel.pbCancelVehicles
      $PokemonEncounters.clearStepCount
      $PokemonGlobal.surfing = true
      if defined?($PokemonTemp.surfJump)
        $PokemonTemp.surfJump = $MapFactory.getFacingCoords($game_player.x,$game_player.y,$game_player.direction)
      end
      $PokemonGlobal.mount = eval(SURF_MOUNT)
      Kernel.pbUpdateVehicle
      Kernel.pbJumpToward
      if defined?($PokemonTemp.surfJump)
        $PokemonTemp.surfJump = nil
      end
      Kernel.pbUpdateVehicle
      $game_player.check_event_trigger_here([1,2])
    else
      pokeride_surf
    end
  end
end

unless defined?(pbSmashEvent)
  def pbSmashEvent(event)
    return if !event
    if event.name=="Tree";    pbSEPlay("Cut",80)
    elsif event.name=="Rock"; pbSEPlay("Rock Smash",80)
    end
    pbMoveRoute(event,[
       PBMoveRoute::Wait,2,
       PBMoveRoute::TurnLeft,
       PBMoveRoute::Wait,2,
       PBMoveRoute::TurnRight,
       PBMoveRoute::Wait,2,
       PBMoveRoute::TurnUp,
       PBMoveRoute::Wait,2
    ])
    pbWait(2*2*4)
    event.erase
    $PokemonMap.addErasedEvent(event.id) if $PokemonMap
  end
end

class Game_Character
  alias pokeride_passableex passableEx?
  def passableEx?(x, y, d, strict = false)
    new_x = x + (d == 6 ? 1 : d == 4 ? -1 : 0)
    new_y = y + (d == 2 ? 1 : d == 8 ? -1 : 0)
    return false unless self.map.valid?(new_x, new_y)
    return true if @through
    # Pokéride Rock Smash
    if $PokemonGlobal.mount && $PokemonGlobal.mount_action &&
       defined?($PokemonGlobal.mount::RockSmash) &&
       $PokemonGlobal.mount::RockSmash
      for event in self.map.events
        if event[1].name == "Rock" && event[1].x == new_x && event[1].y == new_y
          facingEvent = $game_player.pbFacingEvent
          if facingEvent
            pbSmashEvent(facingEvent)
            return true
          end
        end
      end
    end
    return pokeride_passableex(x, y, d, strict)
  end
end

class Spriteset_Map
  alias pokeride_update update
  def update
    pokeride_update
    if $PokemonGlobal.mount && defined?($PokemonGlobal.mount::Strength) &&
       $PokemonGlobal.mount::Strength
      $PokemonMap.strengthUsed = $PokemonGlobal.mount_action
    end
  end
end

module PBTerrain
  Mudsdale = 17 # Only passable if on a Mudsdale
  RockClimb = 18 # Can only be traversed on a Pokéride with RockClimb capabilities
end

class Game_Map
  attr_reader :map
  
  alias pokeride_playerpassable playerPassable?
  def playerPassable?(x, y, d, self_event = nil)
    for i in [2, 1, 0]
      if @terrain_tags[data[x, y, i]] == PBTerrain::Mudsdale
        return $PokemonGlobal.mount && defined?($PokemonGlobal.mount::WalkOnMudsdale) &&
               $PokemonGlobal.mount::WalkOnMudsdale
      end
    end
    pokeride_playerpassable(x, y, d, self_event)
  end
end

def pbStartSurfing
  Kernel.pbCancelVehicles
  $PokemonEncounters.clearStepCount
  $PokemonGlobal.surfing = true
  if defined?($PokemonTemp.surfJump)
    $PokemonTemp.surfJump = $MapFactory.getFacingCoords($game_player.x,$game_player.y,$game_player.direction)
  end
  Kernel.pbUpdateVehicle
  Kernel.pbJumpToward
  if defined?($PokemonTemp.surfJump)
    $PokemonTemp.surfJump = nil
  end
  Kernel.pbUpdateVehicle
end