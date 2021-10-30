#==============================================================================#
#                         Better Fast-forward Mode                             #
#                                   v1.0                                       #
#                                                                              #
#                                 by Marin                                     #
#==============================================================================#
#                                   Usage                                      #
#                                                                              #
# SPEEDUP_STAGES are the speed stages the game will pick from. If you click L, #
# it'll choose the next number in that array. It goes back to the first number #
#                                 afterward.                                   #
#                                                                              #
#             $GameSpeed is the current index in the speed up array.           #
#   Should you want to change that manually, you can do, say, $GameSpeed = 0   #
#                                                                              #
# If you don't want the user to be able to speed up at certain points, you can #
#                use "pbDisallowSpeedup" and "pbAllowSpeedup".                 #
#==============================================================================#

# When the user clicks L, it'll pick the next number in this array.
SPEEDUP_STAGES = [1,2,3]


def pbAllowSpeedup
  $CanToggle = true
end

def pbDisallowSpeedup
  $CanToggle = false
end

# Default game speed.
$GameSpeed = 0

$frame = 0
$CanToggle = true
module Graphics
  class << Graphics
    alias fast_forward_update update
  end
  
  def self.update
    if $CanToggle && Input.trigger?(Input::F8)
      $GameSpeed += 1
      $GameSpeed = 0 if $GameSpeed >= SPEEDUP_STAGES.size
    end
    $frame += 1
    return unless $frame % SPEEDUP_STAGES[$GameSpeed] == 0
    fast_forward_update
    $frame = 0
  end
end

module Input
  class << Input
    alias fast_forward_button_to_key buttonToKey
  end
  
  L = 50
  
  def self.buttonToKey(btn)
    return [0x77] if btn == Input::F8
    fast_forward_button_to_key(btn)
  end
end