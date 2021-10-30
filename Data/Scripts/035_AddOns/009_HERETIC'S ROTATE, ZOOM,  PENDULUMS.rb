#===============================================================================
#
#           HERETIC'S ROTATE, ZOOM, AND PENDULUMS [XP]
#           Version 1.0
#           Thursday, November 20th, 2014
#           Moded for Pokemon Essentials by Zeak6464 & Vendily
#===============================================================================
#
#
#  -----  OVERVIEW  -----
#
#  This script will allow you to Rotate Characters, both Player and Events.
#
#
#  -----  FEATURES  -----
#
#  - Allows for Continual Rotation for Wheels and Machinery
#  - Allows for One Time Rotation To Target Angle over Time
#  - Allows for Pointing at a Character or a Map Location
#  - Allows for "Camera" style Targetting of Moving Characters with Clamping
#  - Allows for Maximum Distance to a Target
#  - Allows for Physics Pendulums with rough Ideal Energy Pendulum Physics
#  - Allows for Warm Weather like in the Gulf of New Mexico
#  - Allows for Humor for those who actually read the Documentation Section
#  - Allows for Zooming Sprite Sizes for both X and Y Independently
#  - Allows for Animating Zooming of Characters over Time
#  - Allows for Looping Maps and points correctly even at Edges of Maps
#  - Compatible with Modular Passable or as a Standalone Script
#
#  -----  INSTRUCTIONS  -----
#
#  For installation, place this script above MAIN, below Modular Passable if
#  it is also used, and below any other script that replaces update in either
#  the Game_Character or Sprite_Character classes, or refresh of Game_Event.
#
#  Default Values for Events are set by putting a \comment[values] Comment on
#  each Page of an Event.  Values can be changed later with Script Calls.
#
#  Recommended to apply a generous quantity of barbeque sauce to enhance the
#  flavor of Effects.  Comedy is one way to ensure people thoroughly read
#  through the documentation of scripts.
#
#
#  -----  COMMENT CONFIGURATION OPTIONS  -----
#
#  Apply each of the following Comments to an Event for corresponding Effects:
#
#  - \rotate_angle[N]      : Static Angle in Degrees for Rotation of Character
#  - \rotate_speed[N]      : Speed of Repeating Rotation / 2.0
#  - \rotate_center[N]     : 0 Top, 1 Center (Default), 2 Bottom
#  - \rotate_point_bottom  : Points Bottom of Sprite at Target instead of Top
#  - \rotate_target[N]     : Points Top at a Map Event if > 0 or Player if 0
#  - \rotate_target[X, Y]  : Points Top at a Map Location, even Off Map
#  - \rotate_target_dist[N]: Maximum Distance of Target to Point at
#  - \rotate_target_min[N] : Minimum Angle of Rotation with a Target
#  - \rotate_target_max[N] : Maximum Angle of Rotation with a Target
#  - \sprite_zoom_x[N]     : Stretch the Sprite Width
#  - \sprite_zoom_y[N]     : Stretch the Sprite Height
#  - \pendulum             : Causes Pendulum Effect, requires any angle to work
#  - \pendulum_length[N]   : Overrides Length, 32 pixels per meter
#  - \degrees_per_frame[N] : Override Config with Rotate Angle To, nil Duration

#
#  NOTE: \rotate_target_min and \rotate_target_max must be used together or
#        any Limits imposed will be ignored.  Only affects Targets!
#
#  NOTE: To point a "Camera" UP with Limitations, simply use \rotate_target_min
#        and \rotate_target_max with inverted values!  Thus, Min would be 315
#        and Max would be 45, and this will cause a 90 degree range of
#        allowable Rotation pointing Up.  Other scenarios should be pretty
#        self explanitory hopefully.
#
#
#  -----  Page Options  -----
#
#  These Comments are applied Per Event Page!  This allows you to have
#  different configurations on each Event Page!  One Page just Rotates 
#  to the Left, then Right.  Another Page could be used to Point at
#  the Player by giving the Rotating Event a Rotate Target!
#
#  All Page Values will be cleared when an Event changes to another valid Page.
#
#
#  -----  Rotate Speed  -----
#
#  Rotate Speed will cause a Character to infinitely Rotate at the specified
#  speed.  Speed is determined by @rotate_speed / 2.0 degrees per frame.  So
#  a \rotate_speed[10] will rotate counter clockwise 5 degrees each frame.
#
#  This may be very useful for creating Wheels.  For mechanical simulations
#  you need to keep in mind that Rotations are non colliding.  Two different
#  size gears that mesh will require two different Rotation Speeds.  The
#  relation of the two numbers when gear sizes are different is beyond
#  the scope of the information in the documentation, however, with basic
#  mechanical engineering applied, is possible to simulate.
#
#  You can use Decimals for very specific control over Rotational Speed.
#
#  Rotate Speed Examples:
#  \rotate_speed[10]   - Rotates Counter-Clockwise at 5 Degrees per Frame
#  \rotate_speed[-5]   - Rotate Clockwise at 2.5 Degrees per Frame
#  \rotate_speed[-2.5] - Rotate Clockwise at 1.25 Degrees per Frame
#
#  
#  -----  Rotate Center  -----
#
#  Rotate Center will position the Vertical Center of a Sprite.  The Default
#  for Sprite Centers is at the Bottom Center of a Sprite.  When any Rotations
#  are applied to a Character, the Center is moved to the Vertical Center, but
#  can be specified using a \rotate_center[N] Comment. Rotate Center N can 
#  be one of three values to suit the needs of your situation.
#
#  Rotate Center Examples:
#  \rotate_center[0]  - Top of Sprite
#  \rotate_center[1]  - Dead Center of Sprite (Default for Rotating Characters)
#  \rotate_center[2]  - Bottom Center of Sprite (Default for Non Rotators)
#
#
#  -----  Rotate Target  -----
#
#  The \rotate_target[N,N] can accept One or Two values.  When One value
#  is used, it is treated as a Character ID, where 0 is the Player and
#  anything above 0 is a Game Event.  When Two values are used, a Map
#  Location is specified.  You can not have Two Rotation Targets at
#  the same time because the Character can only point to One of them.
#
#  Having an Event point at next Map Location you want a Player to go
#  is often a good way of telling the Player where they need to go.
#
#  Rotate Target can also be given an Option to limit the Distance by simply
#  adding a \rotate_target_dist[N] Comment where N is the Distance in Tiles
#  that the Target can be away from the Rotating Event.  For example, by
#  setting a distance of 3, the Target can be no more than 3 Tiles Away
#  before the Rotating Character no only Points.  This is useful for Cameras
#  where there would naturally occur a Distance of Viewing.  Obstructions
#  are NOT considered because this is not the Super Event Sensor script.
#
#  If you are really interested in making Cameras that behave like Metal Gear
#  where a Camera (Rotating Event) points at your character if they become
#  viewable, then use this script with Super Event Sensor and allow the
#  Super Event Sensor script do the work of detecting Viewable through
#  any Impassable Tiles.  Just make your Rotating Event a Sensor (see
#  the Super Event Sensor documentation), and on Page Change from Sensor,
#  then make your Rotating Event point at the Player.  Otherwise on your
#  default Page, give your Camera a Move Route where it just turns back
#  and forth and does not Point at the Target.  Although I have not tried
#  this yet, I am relatively certain that it is possible to do.
#
#  Example Targets:
#
#  \rotate_target[0]     - Target the Player
#  \rotate_target[15]    - Target Event ID 15
#  \rotate_target[12,34] - Target Map X 12 and Y 34, move the Event to turn
#
#  NOTE: You can add a \rotate_point_bottom to force a Character to point
#        the Bottom of a Sprite instead of the Top of the Sprite (Default).
#
#
#  -----  Rotation of Humorous  -----
#
#  The mechanical Rotation of an arm requires the Rotation of ones Humorous
#  which is also known as the "funny bone" becuase after you whack it, the
#  impact on the nerve causes a tingling sensation and isnt very funny.  Thus
#  it is often useful to rotate ones humor to produce more desirable effects.
#
#  Certain situations may warrant different types of humor.  Some people have
#  the potential to be offended by certain types of jokes, while the same
#  joke applied in a different situation is found to be quite satisfying.
#
#  Three Military Leaders were sitting around discussing Courage.  The Army
#  General stood up and proclamed that Soldiers in the Army had a higher
#  degree of Courage than other Military Branches.  The General called to
#  the nearest Army Grunt and ordered him to immediately shoot himself in
#  head.  The Grunt responded "Sir!  Yes Sir!" and immediately shot himself.
#
#  The Air Force Captain laughed and denounced the Generals example of
#  how courageous his Army Grounts were.  "That's not courage", he said, as
#  he radio'd to the nearest plane and ordered his Air Force Grunt to jump
#  from the plane without a parachute.  The Air Force Grunt quickly replied
#  to the Air Force Captain with an enthusiastic "Sir!  Yes Sir" and jumped
#  from the fully functional aircraft with no parachute and unsuprisingly
#  fell to his death.
#
#  The Navy Admiral chuckled and provoked the other two Military Leaders
#  to ponder what was so funny about watching Grunts die.  The Admiral turned
#  to the other two Military Leaders and simply said "Watch this!" as he
#  also radio'd to the nearest Sailor and issued a Direct order to the Grunt:
#  "Sailor!  Yes, you there!  Go get me a cup of coffee, now, Sailor!".  The
#  courageous Sailor sharply responded "Go get your own damn coffee, sir!".
#  At this point, the Admiral turned to the other two Military Leaders and
#  proudly stated "Now THAT'S Courage"!  The moral here being that it takes
#  more Courage to be disobedient than it does to behave obediently and 
#  without question when injury or harm is the result of obedience.
#
#  In order for the vectors of the humorous simulation to be altered depending
#  on the situation, the order of the vectors of Navy, Air Force, and Army
#  can be rearranged so that instead of the Army Captain having ordered his
#  soldier to somehow mercilessly kill himself, the vector can be replaced
#  by either the Admiral or Air Force Commander, resulting in a flavor of
#  humor that is appropriate of the situation when telling this joke to
#  real members of the Military, varying the order of the vectors to be 
#  dependant on the Branch of the Military they occupy.  Make the Army
#  Captain have the disobedient Grunt when telling this joke to real
#  members of the Army.
#
#
#  -----  Rotate Target Min and Max  ------
#
#  The \rotate_target_min and \rotate_target_max will prevent a Character
#  rotating outside the range specified by Min and Max.  A Security Camera
#  may have mechanical constraints that prevent it from turning to look
#  at a wall.  The Range of Rotation is the difference between both of
#  the Min and Max values.  For example, a Min of 0 and a Max of 90 will
#  cause a 90 degree Range of Rotation.  A Min of 225 and a Max of 45
#  will cause a 180 degree Range of Rotation pointing Down Left.  Both
#  the Min and Max will need to be filled in for any Constraints to
#  be imposed on a Character.
#
#
# -----  Cameras using Rotate Target Min and Max -----
#
#  Wall Mounted Security Cameras in real life can Rotate.  This effect can
#  be simulated In Game by giving an Event a \rotate_target[0] for Player
#  and then setting \rotate_target_min[N] and \rotate_target_max[N] to
#  put a Limit on how far these Camera Style Events are allowed to turn.
#
#  Pointing Cameras Up seems a bit tricky, but it is actually quite easy
#  to pull off.  You can have a Target Min that is greater than the 
#  assigned Target Max.  So for a Camera that points Up on a Game Map, just
#  set \rotate_target_min[315] and \rotate_target_max[45] to limit the
#  turning Rotation of the Camera to 90 Degrees Up!  Its that easy!
#
#  Example Rotate Min and Max Constraints:  (Both Min and Max are required)
#
#  - Can not turn Up (90 degree Constraint)
#  \rotate_target_min[45]
#  \rotate_target_max[315]
#
#  - Can not turn Left (180 degree Constraint)
#  \rotate_target_min[180]
#  \rotate_target_max[0]
#
#  - Can not turn Right (180 degree Constraint)
#  \rotate_target_min[0]
#  \rotate_target_max[180]
#
#  - Can not turn Down [90 degree Constraint]
#  \rotate_target_min[225]
#  \rotate_target_max[135]
#
#  It should be possible to use these two settings to fully control all 
#  possible Ranges of Rotation.  Notice that Minimum Values can be larger
#  than Maximum Values.  To understand this behavior, just keep in mind
#  that the Min and Max values are not linear, but Rotational.
#
#  Welcome to the wonderful world of RPG Metal Fantasy Maker Gear XP Deluxe!
#
#
# -----  Pendulums  ------
#
#  Pendulums are very easy to achieve.  Simply add a \pendulum Comment to
#  the event.  Pendulums will need an Angle to Oscillate.  You can give a
#  pendulum an Initial Angle with \rotate_angle, or using rotate_angle_to()
#  script call.  Once a pendulum is not at 0 degrees, it will begin to
#  swing back and forth.
#
#  These Pendulums use two factors to determine frequency, Gravity and the 
#  Length of the "string".  The string in game is Invisible; it is just a 
#  pivot point.  I recommend using \rotate_center[0] for Pendulums, then
#  if you want to adjust the frequency, adjust the "string" or Length by
#  simply adding a \pendulum_length[N] Comment.  Length treates 1 meter
#  as 32 pixels, so to set a Length of 1 meter use \penulum_length[32].
#  This gives you precise control, however you can even use decimals if
#  you so desire for even more control over Frequency.
#
#  All other Rotational Movement will prevent a Pendulum from Updating.
#
#  Pendulums are Non Colliding.  If you use a Big Sprite, I do not do any
#  Collision Checking for the Sprite.  Pendulums are intended to be mostly
#  for cosmetic purposes.  Z-Indeces are also not adjusted at all.  You
#  may have need for other scripts that allow for adjusting Z-Index
#  depending on your situation.
#
#  These pendulums are intended to swing forever.  They are Ideal Energy
#  Pendulums and do not consider Air Friction or Mass.  They are not intended
#  as mechanically perfect because Acceleration is cheated.  Acceleration
#  in true Pedulums is applied until the Pendulum reaches 0 degrees.  These
#  pendulums, althoguh appropriate for game use, cheat the acceleration by
#  causing deceleration prior to 0 degrees in order to prevent going beyond
#  the 180 degree marker.  This is because frequency does not always divide
#  perfectly to allow a frame of game animation to occur when the Pendulum
#  reaches 0 degrees.  If you are a Physics student, you may wish to ask
#  your teacher why the method of determining acceleration in this script
#  is not appropriate for true mechanical simulations.  It is a close
#  approximation and is acceptable for non collision game use.
#
#  Pendulum Comment Examples:
#
#  \pendulum
#  \pendulum_length[48]
#  \rotate_center[0] # Top
#  \rotate_angle[45] # Start at 45 Degrees
#
#  NOTE: Do not put ANY extra content in your Comment Configurations.  The
#  very last character should be the last character of the configuration
#  string.  \pendulum would have the last character as "m", while a Comment
#  of \rotate_center[0] must have the last character as the "]" brace.
#
#  Pendulum Script Examples:  (You must add a \pendulum Comment for Pendulums)
# 
#  Rotate to an Angle of -45 degrees, then Pendulum takes over
#  Script: rotate_angle_to(-45)
#  Rotate to an Angle of 90 degrees over 20 Frames, then Pendulum takes over
#  Script: rotate_angle_to(90, 20)
#
#
#  -----  Sprite Zooming  ------
#
#  Sprite Zooming is available for the Width and Height independantly.  To
#  set the Zoom Level, you'll need to either use X for Width, or Y for Height.
#
#  Example Comments:
#
#  \sprite_zoom_x[1.0] - Default
#  \sprite_zoom_y[1.0] - Default
#  \sprite_zoom_x[0.5] - Half the Width
#  \sprite_zoom_y[2]   - Twice the Height
#
#  Note: You have to leave off the trailing Comments, last character has
#        to be a ] character for Effects to be read.  If you need Comments
#        to describe, then put in another Comment on a separate line, but
#        keep in mind, there is a LIMIT to the number of Comments that
#        will be processed, and each line counts against that LIMIT.
#
#
#  To Animate a Transition of a Zoom, use Set Move Route -> Script
#
#  $>Script: zoom_x_to(0.5, 20)
#
#  The above zoom_x_to(target, duration) will take whatever the current Zoom
#  is and Transition to a Zoom X of 0.5 over 20 frames.
#
#  You can run Two Scripts at the same time to Transition both X and Y values.
#
#  $>Script:  zoom_x_to(2.0, 20)
#  $>Script:  zoom_y_to(1.5, 20)
#
#  The above will distort the size of the Sprite to twice the width and 1.5
#  times the original height over 20 frames.
#
#  
#  -----  Legal  -----
#
#  You are hereby allowed to copy and distribute this Script without my
#  express permission.  You may modify this script as needed.  
#
#  You may not sell this script.  You may not claim this script to be
#  your property in any way shape or form.  If you use this script in 
#  any Commercial products, you are required to give me credit for the 
#  use of this script, but do not need to pay me or contact me as
#  permission to use this script in commercial products is hereby
#  granted.
#
#
#  -----  SCRIPT CALLS  -----
#
#  Script Calls are intended to be run on Characters, which for new users will
#  take a second to explain.  The Script Box in Edit Event -> Script is very
#  different than the Script Box in Edit Event -> Set Move Route -> Script!
#
#  These Script Calls are intended to be run from Set Move Route -> Script.
#  You can also run these in the Edit Event -> Script Window just as long
#  as you specify a Character inside that Script Call, usually by using
#  a $global, such as $game_map.events[49].angle_fix = true or for the Player
#  by using the Player global of $game_player.angle = 45.5
#
#  angle_fix = true / false
#  - Locks the Angle of a Character so it is Unchangable, like Direction Fix
#
#  self.angle= value
#  - Checks for Angle Fix to set the Rotational Angle of a Character
#  - Use in Set Move Route -> Script ONLY
#
#  rotate_speed = value
#  - Repeating Rotation at this Speed / 2.0
#  - Repeating Rotation is not updated during Rotate Angle To, or Target
#
#  rotate_speed_to(new_speed, duration = nil)
#  - Increases Rotation over a Transition until Rotation Speed is the New Speed
#  - Repeating Rotation is updated during Rotate Speed Transition
#
#  rotate_angle_to(new_angle, duration = nil)
#  - One Time Rotation of Character to a Target Angle
#  - Duration is Optional.  Time in Frames or Degrees Per Frame if excluded
#  - Always tries to use Shortest Rotational Distance / Smallest Angle
#
#  clear_rotations
#  - Clears all Rotational Vectors and Properties, including Comments!
#
#  reset_rotations
#  - Resets Rotational Properties to use Comments Configurations
#  - Can not use on Game Player because Player doesn't have any Comments!
#
#  rotating?
#  - Returns true if any Rotations are present
#  - May be useful for Conditional Branches
#
#  ----- CONFIG OPTIONS  ----
#
#  Rotate Degrees Per Frame is used with the Script Command of
#  rotate_angle_to(angle_target, duration = nil) when the optional
#  duration argument is not used.  Basically, the farther an Event has
#  to Rotate, the longer it will take.  This setting in the Config here
#  controls the Default Value for all characters, but can be overridden
#  per each Event with a \rotate_degrees_per_frame[N] Comment where the
#  letter N is your Numeric value.
#
#  Pendulum Gravity - Two factors are used to determine the frequency of
#  a Pendulum, Gravity and Length.  Mass is not considered here.  Gravity
#  is set to a Constant so any changes will affect all Pendulums.  If you
#  want to alter the Rate of Oscillation of a Pendulum, you can adust the
#  length of the Pendulum with a \pendulum_length[N] Comment.  Pendulum
#  length is determined as 32 pixels = 1 meter.

# Rotate this number of Degrees Per Frame with Rotate Angle To and no duration
ROTATE_DEGREES_PER_FRAME = 5
# Constant for Gravitational Acceleration (9.81 m/s**2 is Earth Gravity)
PENDULUM_GRAVITY = 9.81

class Game_Pendulum
  #--------------------------------------------------------------------------
  # * Public Instance Variables - Game_Pendulum
  #--------------------------------------------------------------------------
  attr_accessor     :enabled               # Checked in Game_Character Update
  attr_accessor     :length                # Length of Pendulum String
  #--------------------------------------------------------------------------
  # * Object Initialization - Game_Pendulum
  #  - Create the Pendulum Object with these default values
  #--------------------------------------------------------------------------
  def initialize(id)
    # Parent Character ID
    @id = id
    # Enable Pendulum
    @enabled = true
    # Gravity from Default Constant (normally Earth Gravity)
    @g = PENDULUM_GRAVITY
    # Pendulum Angular Velocity (Initial Velocity always starts at 0)
    @v = 0.0
    # Theta is Angle in Degrees not Radians (not available when Initialized)
    @theta_0 = nil
  end
  #--------------------------------------------------------------------------
  # * Enable - Game_Pendulum
  #  - Just returns Enabled because I forget all the time like an idiot
  #--------------------------------------------------------------------------
  def enable
    return @enabled
  end
  #--------------------------------------------------------------------------
  # * Enable= - Game_Pendulum
  #  - Just sets value to Enabled because I forget all the time like an idiot
  #--------------------------------------------------------------------------
  def enable=(value)
    @enabled = value
  end
  #--------------------------------------------------------------------------
  # * Reset - Game_Pendulum
  #  - Resets Theta 0 and Angular Velocity of Pendulum, leaves Length Comments
  #--------------------------------------------------------------------------
  def reset
    # Reset Initial Angle Theta 0
    @theta_0 = nil
    # Reset Angular Velocity
    @v = 0.0
  end
  #--------------------------------------------------------------------------
  # * Sin - Game_Pendulum
  #  - Convert Degrees into Radians using Math.sin
  #      angle : Angle in Degrees
  #--------------------------------------------------------------------------
  def sin(angle)
    return Math.sin(angle) * Math::PI / 180
  end
  #--------------------------------------------------------------------------
  # * Cos - Game_Pendulum
  #  - Convert Degrees into Radians using Math.cos
  #      angle : Angle in Degrees
  #--------------------------------------------------------------------------
  def cos(angle)
    return Math.cos(angle) * Math::PI / 180
  end  
  #--------------------------------------------------------------------------
  # * Update Angle - Game_Pendulum
  #  - Updates Pendulum Acceleration and Movement for Ideal Energy Pendulums
  #  - Easy Solution is to ignore Time and use -gCos(Theta0 / len) for Accel
  #  - Acceleration is a Magnitude and thus is always Positive (cos(T).abs)
  #  - Returns Angle in Degrees to apply to Character Sprite
  #      angle  : Angle in Degrees from Character Sprite
  #      length : Length of Pendulum Bob from Pivot Point at Top of Sprite
  #--------------------------------------------------------------------------
  def update_angle(angle, length)
    # Return if not Enabled
    return unless @enabled
    # Use a Specified Length instead of Argument length if specified
    length = (@length) ? @length : length
    # Set the Initial Values
    if not @theta_0 and length
      # Theta 0 is the Initial Angle in Degrees not Radians (-360 to 360)
      @theta_0 = ((angle < 0) ? angle % -360.0 : angle % 360.0)
    end
    # Return Unadjusted Angle if required values are not set
    return angle unless @theta_0 and length
    # Return If Stationary
    return if angle == 0 and @theta_0 == 0 and @v == 0
    # Adjust the Range of angle to be between -180 and 360
    angle = ((angle < 0 and angle > -180.0) ? angle % -360 : angle % 360)
    # Length : 32 pixels per 1 meter and value is in Meters so divide by 32.0
    length /= 32.0
    # Acceleration = -Gravity * Arc Length / Length (Framerate of 40 FPS)
    a = (@theta_0.abs != 180) ? -1 * (@g * cos(@theta_0) / length / 40).abs : 0
    # Determine Acceleration Direction based on Current Angle and Theta
    if (@theta_0 < 0 and @theta_0 > -180 and angle < 0) or
       (@theta_0 > 0 and @theta_0 < 180 and angle < 0)  or
       (@theta_0 >= 180 and angle <= 0 or angle >= 180 ) or
       (@theta_0 <= -180 and angle <= 0 and angle >= -180)
      # Negative Acceleration
      a *= -1
      # Recalculate the Angle using Negative Acceleration Value
      angle = angle + (Math.atan(@v + a) * 180 / Math::PI)      
    else
      # Recalculate the Angle using Positive Acceleration Value
      angle = angle + (Math.atan(@v + a) * 180 / Math::PI)
    end
    # Pendulum Velocity plus Acceleration Value (positive or negative)
    @v += a
    # Return the Pendulum's Angle
    return angle
  end
end

#==============================================================================
# ** Sprite_Character
#==============================================================================
class Sprite_Character < RPG::Sprite
  #--------------------------------------------------------------------------
  # * Update - Sprite_Character (Main Upate Method)
  #  - Rotates and Recenters Character Sprites
  #  - Resets Rotated Sprites when Disabled so Screen Position is correct
  #--------------------------------------------------------------------------
  alias rotate_character_sprite_update update unless $@
  def update
    # Return if Anti Lag says to not Update
    return if @character.dont_update_sprite
    # If Character has a Rotated Sprite
    rotating = @character.rotating?
    # If Not Rotating and Sprite Center has been Altered
    if not rotating and @sprite_center_altered
      # If Tile
      if @character.tile_id > 384
        # Reset the Center of Sprite Tile to Bottom Center (Default)
        self.ox = 16
        self.oy = 32
      # If Character   
      elsif @cw and @ch
        # Reset the Center of Sprite Character to Bottom Center (Default)
        self.ox = @cw / 2
        self.oy = @ch   
      end
      # Clear the Rotate Offset Flag for Bottom Center
      @sprite_center_altered = false
      # Set the Sprite Angle to Default
      self.angle = 0
    end
    # Call Original or other Aliases
    rotate_character_sprite_update
    # If Character has a Rotated Sprite
    if rotating
      # Set Flag that Sprite Center has been altered
      @sprite_center_altered = true
      # If Tile Sprite and not Autotile
      if @character.tile_id > 384
        # If Vertical Rotation Center is Top
        if @character.rotate_center == 0
          # Set the Tile to the Top of the Sprite Tile over Bottom Center 
          self.oy = 0
          self.y -= 32
        # If Vertial Rotation Center is Center (Default)
        elsif @character.rotate_center == 1
          # Set the Tile to the Center of the Sprite Tile over Bottom Center
          self.oy = 16
          self.y -= 16
        # If Vertial Rotation Center is Bottom
        elsif @character.rotate_center == 2
          # Set the Tile to the Bottom of the Sprite Tile
          self.oy = 0          
        end
      # If Character Sprite
      elsif @cw and @ch
        # Set Horizontal Sprite Center to Center of Sprite instead of Bottom
        self.ox = self.bitmap.width / 8
        # If Vertical Rotation Center is Top
        if @character.rotate_center == 0
          # Vertical Rotation Center is Top Center of Sprite
          self.oy = 0
          self.y -= self.bitmap.height / 4
        # If Vertical Rotation Center is Center
        elsif @character.rotate_center == 1
          # Vertical Rotation Center is Center of Sprite
          self.oy = self.bitmap.height / 8
          self.y -= self.bitmap.height / 8
        # If Vertical Rotation Center is Bottom
        elsif @character.rotate_center == 2
          # Vertical Rotation Center is Bottom of Sprite
          self.oy = self.bitmap.height / 4
        end
      end
      # If Character has Point Bottom set
      bottom = (@character.rotate_point_bottom) ? 180 : 0
      # Set the Sprite Angle for Rotation
      self.angle = @character.angle + bottom
    end
    # Zoom the Sprite if Sprite is Zoomed
    self.zoom_x = @character.sprite_zoom_x if @character.sprite_zoom_x
    self.zoom_y = @character.sprite_zoom_y if @character.sprite_zoom_y    
  end
end

#==============================================================================
# ** Game_Character
#==============================================================================
class Game_Character
  #--------------------------------------------------------------------------
  # * Public Instance Variables - Game_Character
  #  - Non Accessor Items have Getter and Setter Methods
  #  - for angle, please use self.angle instead as it checks for @angle_fix
  #--------------------------------------------------------------------------
  attr_writer   :degrees_per_frame       # Overrides Value from Config
  attr_writer   :rotate_center           # 0 - Top, 1 - Center, 2 - Bottom  
  attr_reader   :rot_bitmap_height       # Stored Value from Sprite Character
  attr_reader   :pendulum                # Pendulum Controller Object  
  attr_accessor :angle_fix               # Works like Direction Fix
  attr_accessor :rotate_point_bottom     # Points Top unless this is True
  attr_accessor :rotate_speed            # Degrees Per Frame / 2.0
  attr_accessor :rotate_speed_target     # Transition Rotation Speed
  attr_accessor :rotate_speed_duration   # Duration of Transition of Speed
  attr_accessor :rotate_target           # Character or Map Location
  attr_accessor :rotate_target_min       # Min Angle of Rotation allowed
  attr_accessor :rotate_target_max       # Max Angle of Rotation allowed
  attr_accessor :sprite_zoom_x           # Zoom the Sprite Width
  attr_accessor :sprite_zoom_y           # Zoom the Sprite Height
  attr_accessor :sprite_zoom_target_x    # Zoom the Sprite Width to Target
  attr_accessor :sprite_zoom_dur_x       # Zoom the Sprite Width Duration
  attr_accessor :sprite_zoom_target_y    # Zoom the Sprite Height to Target
  attr_accessor :sprite_zoom_dur_y       # Zoom the Sprite Height Duration
  attr_accessor :dont_update_sprite      # Anti Lag Property for other scripts  
  #--------------------------------------------------------------------------
  # * Initialize - Game_Character (Main Initialize Method)
  #  - Adds these Properties to every Character prior to Update in Alias
  #--------------------------------------------------------------------------  
  alias rotate_character_initialize initialize unless $@
  def initialize(map=nil)
    @character_height = nil
    @angle = 0
    @angle_fix = false
    @rotate_center = 1
    @rotate_speed = nil    
    @rotate_point_bottom = false
    @rotate_target = nil
    @rotate_target_min = nil
    @rotate_target_max = nil
    @rotate_target_dist = nil
    @rotate_angle_target = nil
    @rotate_angle_duration = 0
    @rotate_speed_target = nil
    @rotate_speed_duration = nil    
    @sprite_zoom_x = 1
    @sprite_zoom_y = 1
    @sprite_zoom_target_x = @sprite_zoom_x
    @sprite_zoom_target_y = @sprite_zoom_y
    @sprite_zoom_dur_x = 0
    @sprite_zoom_dur_y = 0
    @rotate_degrees_per_frame = ROTATE_DEGREES_PER_FRAME
    # Call Original or other Aliases
    rotate_character_initialize(map)
  end
  #--------------------------------------------------------------------------
  # * Clear Rotations - Game_Character
  #  - Clears All Properties, even ones set by Comments
  #  - Also clears Zoom Levels and Zoom Transitions
  #--------------------------------------------------------------------------
  def clear_rotations
    @angle = 0
    @angle_fix = false
    @rotate_center = 1    
    @rotate_speed = nil
    @rotate_point_bottom = false    
    @rotate_target = nil
    @rotate_target_min = nil
    @rotate_target_max = nil
    @rotate_target_dist = nil
    @rotate_angle_target = nil
    @rotate_angle_duration = 0
    @rotate_speed_target = nil
    @rotate_speed_duration = nil
    @sprite_zoom_x = 1
    @sprite_zoom_y = 1
    @sprite_zoom_target_x = @sprite_zoom_x
    @sprite_zoom_target_y = @sprite_zoom_y
    @sprite_zoom_dur_x = 0
    @sprite_zoom_dur_y = 0    
    @pendulum = nil
    @rotate_degrees_per_frame = ROTATE_DEGREES_PER_FRAME
  end
  #--------------------------------------------------------------------------
  # * Angle - Game_Character (Getter Method)
  #  - Getter Method because value may not initialized from Save Games
  #  - Determines the Angle of this Character's Sprite
  #--------------------------------------------------------------------------  
  def angle
    # Return or Initialize the property for Save Games
    return @angle ||= 0
  end
  #--------------------------------------------------------------------------
  # * Angle= - Game_Character (Setter Method)
  #  - Setter Method checks for Angle Fix before assigning value to property
  #  - Override the check made here by just using @angle = value
  #--------------------------------------------------------------------------  
  def angle=(value)
    # Prevent Changing Angle if Angle Fix is ON (like Direction Fix)
    return if @angle_fix
    # Assign the value to the property and convert to Float
    @angle = (value != 0) ? value.to_f : 0
  end
  #--------------------------------------------------------------------------
  # * Rotate Center - Game_Character (Getter Method)
  #  - Determines Vertical Center of Sprite Rotation
  #  - 0 is Top, 1 is Center (Default), 2 is Bottom
  #--------------------------------------------------------------------------  
  def rotate_center
    return @rotate_center ||= 1
  end
  #--------------------------------------------------------------------------
  # * Rotate Angle Duration - Game_Character (Getter Method)
  #  - Called by Sprite_Character to rotate the Charater's Sprite over Time
  #--------------------------------------------------------------------------  
  def rotate_angle_duration
    # Return or Initialize the property for Save Games    
    return @rotate_angle_duration ||= 0
  end
  #--------------------------------------------------------------------------
  # * Rotate Degrees Per Frame - Game_Character (Getter Method)
  #  - Getter Method because value may not initialized from Save Games
  #  - Used with Rotate Angle To when a Duration is not specified
  #  - Allows Unspecified Duration to determine Duration by this value
  #--------------------------------------------------------------------------
  def rotate_degrees_per_frame
    # Return or Initialize value from Config for Save Games    
    @rotate_degrees_per_frame ||= ROTATE_DEGREES_PER_FRAME
  end
  #--------------------------------------------------------------------------
  # * Rotating? - Game_Character
  #  - Called by Sprite_Character to rotate the Charater's Sprite
  #  - Determines if this Character is Rotating or not
  #--------------------------------------------------------------------------
  def rotating?
    # Character is Rotating if any of the following conditions are met
    if @angle.is_a?(Float) or not @rotate_target.nil? or @pendulum or
       not @rotate_speed.nil? or not @rotate_angle_target.nil?
      # Rotating
      return true
    end
    # Default for Evaluations
    return false
  end
  #--------------------------------------------------------------------------
  # * Rotate Angle To - Game_Character
  #  - Rotates Sprite using Shortest Rotation
  #  - If a Duration is not set, Rotate Degrees Per Frame determines Speed
  #      target   : Angle in Degrees
  #      duration : [Optional] Time in Frames
  #--------------------------------------------------------------------------
  def rotate_angle_to(target, duration = nil)
    # If Target does not include a Full Rotation
    if target >= 0 and target <= 360
      # Determine Shortest Rotation
      if self.angle - target > 180
        target += 360.0
      elsif target - self.angle > 180
        target -= 360.0
      end
    end
    # If Duration Argument is not called
    if duration.nil?
      # Use Total Difference of Degrees
      duration = (target.to_f - self.angle) / self.rotate_degrees_per_frame
      # Make it always a Positive Number for Counting Down
      duration = duration.abs.ceil
    end
    # If no Duration
    if duration < 1
      # Set the Angle of the Sprite
      self.angle = target.to_f
      # No Transition
      return
    end
    # Assign Values to Angle Target and Angle Duration
    @rotate_angle_target = target.to_f
    @rotate_angle_duration = duration
  end
  #--------------------------------------------------------------------------
  # * Zoom X To - Game_Character
  #  - Zooms the Width of a Character over Frames
  #      target   : New Zoom (1.0 is default)
  #      duration : Time in Frames (use whole numbers)
  #--------------------------------------------------------------------------
  def zoom_x_to(target, duration = nil)
    # If no Duration
    if duration.nil? or duration < 1
      # Just assign the Target as the Zoom X Value
      @sprite_zoom_x = target.to_f
      # Prevent Animating a Zoom X Transition
      return
    end
    # Check for Null Values
    @sprite_zoom_x = 1.0 if @sprite_zoom_x.nil?
    # Assign the Target and Duration Values
    @sprite_zoom_target_x = target.to_f
    @sprite_zoom_dur_x = duration.ceil
  end
  #--------------------------------------------------------------------------
  # * Zoom Y To - Game_Character
  #  - Zooms the Height of a Character over Frames
  #      target   : New Zoom (1.0 is default)
  #      duration : Time in Frames (use whole numbers)
  #--------------------------------------------------------------------------
  def zoom_y_to(target, duration = nil)
    # If no Duration
    if duration.nil? or duration < 1
      # Just assign the Target as the Zoom Y Value
      @sprite_zoom_y = target.to_f
      # Prevent Animating a Zoom Y Transition
      return
    end
    # Check for Null Values
    @sprite_zoom_y = 1.0 if @sprite_zoom_y.nil?    
    # Assign the Target and Duration Values
    @sprite_zoom_target_y = target.to_f
    @sprite_zoom_dur_y = duration.ceil
  end
  #--------------------------------------------------------------------------
  # * Rotate Speed To - Game_Character
  #  - Changes the Rotation Speed of a Character over Frames
  #      target   : New Speed (0 is default)
  #      duration : Time in Frames (use whole numbers)
  #--------------------------------------------------------------------------
  def rotate_speed_to(target, duration = nil)
    # If no Duration
    if duration.nil? or duration < 1
      # Just assign the Target as the Zoom Y Value
      @rotate_speed = target.to_f
      # Prevent Animating a Rotate Speed Transition
      return
    end
    # Check for Null Values
    @rotate_speed = 0 if @rotate_speed.nil?    
    # Assign the Target and Duration Values
    @rotate_speed_target = target.to_f
    @rotate_speed_duration = duration
  end
  #--------------------------------------------------------------------------
  # * Correct Angle Range - Game_Character
  #  - Corrects the Range of Angle Argument to be between 0 and 360 Degrees
  #      angle : Angle in Degrees to correct
  #--------------------------------------------------------------------------
  def correct_angle_range(angle)
    # If Angle is not between 0 and 360
    if angle < 0 or angle > 360
      # While Angle is not between 0 and 360
      while angle < 0 or angle > 360
        # Increment by 360 so it is In Range
        angle += (angle < 360 ? 360 : -360)
      end
      # Adjust Angle to between 0 and 360 Degrees by using Remainer          
      angle %= 360
    end
    # Return the corrected Angle
    return angle
  end
  #--------------------------------------------------------------------------
  # * Rotate Target Distance - Game_Character
  #  - Returns Array of Distances between Character and Target Coordinates
  #  - Required by Trig function to determine Radian Tangent value
  #     target_x : Map Target Real X Coordinate
  #     target_y : Map Target Real Y Coordinate
  #--------------------------------------------------------------------------  
  def rotate_target_distance(target_x, target_y)
    # Distance in Real Values between Player and Target
    x_dist = (target_x - @real_x) * 1.0
    y_dist = (target_y - @real_y) * 1.0
    # Return the X and Y Distances as an Array
    return [x_dist, y_dist]
  end
  # If Heretic's Loop Maps is installed
  if Game_Map.method_defined?(:map_loop_passable?)  
    #--------------------------------------------------------------------------
    # * Rotate Target Distance - Game_Character (for Looping Maps)
    #  - Returns Array of Distances between Character and Target Coordinates
    #  - Required by Trig function to determine Radian Tangent value for Angle
    #  - Checks for Maps that Loop either Horizontal or Vertical
    #     target_x : Map Target Real X Coordinate
    #     target_y : Map Target Real Y Coordinate
    #--------------------------------------------------------------------------
    alias loop_map_rotate_target_distance rotate_target_distance unless $@
    def rotate_target_distance(target_x, target_y)
      # Get difference in target coordinates from original method      
      dx, dy = loop_map_rotate_target_distance(target_x, target_y)
      # If Map Loops Horizontal and Distance is more than Half the Map (128 / 2)
      if $game_map.loop_horizontal? and dx.abs > $game_map.width * 64
        # Adjust X Distance for Horizontal Looping Map
        dx += (dx < 0) ? $game_map.width * 128 : -$game_map.width * 128
      end
      # If Map Loops Vertical and Distance is more than Half the Map (128 / 2)
      if $game_map.loop_vertical? and dy.abs > $game_map.height * 64
        # Adjust X Distance for Vertical Looping Map
        dy += (dy < 0) ? $game_map.height * 128 : -$game_map.height * 128
      end
      # Return Adjusted Difference X and Y values as Array for Looping Maps
      return [dx, dy]
    end
  end
  #--------------------------------------------------------------------------
  # * Character Update Rotations - Game_Character
  #  - Handles all Rotation Effects applied to Characters
  #--------------------------------------------------------------------------   
  def character_update_rotations
    # If a Rotate Speed Transition is taking place
    if @rotate_speed_duration and @rotate_speed_duration > 0
      # Shorthand
      st = @rotate_speed_target.to_f
      sd = @rotate_speed_duration
      # Calculate New Angle over Time
      @rotate_speed = (@rotate_speed * (sd - 1) + st) / sd
      # Decrease Duration of Transitional Rotation
      @rotate_speed_duration -= 1
      # If End of Rotation
      if @rotate_speed_duration == 0
        # Reset any Pendulums to this value
        @rotate_speed = @rotate_speed_target.to_f
      end
    end
    # If Rotating to point at a Target
    if not @rotate_target.nil?
      # Default Values
      target_x = nil
      target_y = nil
      # If Target is a Number for Characters (0 for Player, 1 > for Event ID)
      if @rotate_target.is_a?(Numeric)
        # Get the Character
        if @rotate_target == 0
          # Character is Player
          character = $game_player
        elsif $game_map.events[@rotate_target].rotate_target_valid?
          # Character is a Map Event
          character = $game_map.events[@rotate_target]
        end
        # If Rotation Target Character is Valid
        if character
          # Check for Tile Zoomed Sprite
          if character.tile_id > 0 and character.sprite_zoom_y != 1.0
            # Set Center of Zoomed Tile
            h = character.sprite_zoom_y * 32.0
          else
            # Get Height of Target Character or 16 for Center of Tile
            h = (character.rot_bitmap_height) ? character.rot_bitmap_height : 16
            # Accomodate for a Zoomed Sprite to middle of Sprite
            h *= character.sprite_zoom_y            
          end
          # Character's Coordinates are the Target Coordinates
          target_x = character.real_x
          target_y = character.real_y - h
        end
      # If Target is an Array for Map Coordinates
      elsif @rotate_target.is_a?(Array)
        # Multiply by 128 for Real X and Y values
        target_x = @rotate_target[0] * 128
        target_y = @rotate_target[1] * 128
      end
      # If Target X and Target Y and a Target Distance are all set
      if target_x and target_y and @rotate_target_dist
        # Determine Geometry Real C Squared Distance value
        d = (@rotate_target_dist * 128) ** 2
        # X and Y Distance between the Rotating Character and Target
        x, y = rotate_target_distance(target_x, target_y)
        # If Geometry A Squared + B Squared = C squared then Target is In Range
        target_in_range = (x.abs ** 2 + y.abs ** 2 < d) ? true : false
      # If just Target X and Target Y are set
      elsif target_x and target_y
        # No Target Distance specified so it is within Range
        target_in_range = true
      end
      # If Target is In Range and Target X and Target Y are set
      if target_in_range and target_x and target_y
        # X and Y Distance between the Rotating Character and Target if not set
        x, y = rotate_target_distance(target_x, target_y) if not x or not y
        # Trig to determine Angle and covert Radians into Degrees
        angle = (Math::atan2(x,y) * 180.0 / Math::PI).round - 180
        # Correct the Range of the Angle to be between 0 and 360 Degrees
        angle = correct_angle_range(angle)
        # If Rotate Min and Max are set to limit Rotation
        if @rotate_target_min and @rotate_target_max
          # If Angle is Out of Ranges defined by Rotate Min and Rotate Max
          if (@rotate_target_min < @rotate_target_max and
             (angle <= @rotate_target_min or angle >= @rotate_target_max)) or
             (@rotate_target_min > @rotate_target_max and
             (angle <= @rotate_target_min and angle >= @rotate_target_max))
            # If Top of Circle, use Inverse Values
            if @rotate_target_min > @rotate_target_max
              # Clamp the Angle to Min or Max Values if allowed by Angle Fix
              angle = @rotate_target_min.to_f if angle > @rotate_target_min
              angle = @rotate_target_max.to_f if angle < @rotate_target_max
            # Use Standard Values to Clamp Angle
            else
              # Clamp the Angle to Min or Max Values if allowed by Angle Fix
              angle = @rotate_target_min.to_f if angle < @rotate_target_min
              angle = @rotate_target_max.to_f if angle > @rotate_target_max
            end
            # Enable Angle Fix to prevent changes to Angle until In Range
            @angle_fix = true
          # If Angle Fix is ON to prevent changes to Angle in self.angle
          elsif @angle_fix
            # Clear the Angle Fix
            @angle_fix = false
          end
        end
        # Attempt to assign the new Angle to property and check Angle Fix
        self.angle = angle
      end
    # If Rotating to a specific Angle with a Duration
    elsif self.rotate_angle_duration > 0
      # Shorthand
      t = @rotate_angle_target.to_f
      d = @rotate_angle_duration
      # Calculate New Angle over Time
      self.angle = (self.angle * (d - 1) + t) / d
      # Decrease Duration of Transitional Rotation
      @rotate_angle_duration -= 1
      # If End of Rotation
      if @rotate_angle_duration == 0
        # Reset any Pendulums to this value
        @pendulum.reset if @pendulum
      end
    # If Character is repeatedly Rotating
    elsif not @rotate_speed.nil?
      # Update the Angle
      if @rotate_speed != 0
        # Add Rotation Speed to the Angle
        self.angle += @rotate_speed / 2.0
      end
      # Correct the Range of the Angle to be between 0 and 360 Degrees
      self.angle = correct_angle_range(self.angle)
    # If Pendulum Enabled
    elsif @pendulum and @pendulum.enabled and not @angle_fix
      # Update Pendulum Movment
      self.angle = @pendulum.update_angle(self.angle, @rot_bitmap_height)      
    end
  end
  #--------------------------------------------------------------------------
  # * Character Update Zoom - Game_Character
  #  - Updates any Animated Zooms with a Duration
  #--------------------------------------------------------------------------
  def character_update_zoom
    # If Zoom X or Y have a Duration and Target
    @sprite_zoom_dur_x ||= 0
    @sprite_zoom_dur_y ||= 0
    # If a Zoom X Transition
    if @sprite_zoom_dur_x > 0
      # Shorthand
      t = @sprite_zoom_target_x.to_f
      d = @sprite_zoom_dur_x
      # Adjust the Zoom X over Duration Frames
      @sprite_zoom_x = (@sprite_zoom_x * (d - 1) + t) / d
      @sprite_zoom_dur_x -= 1
      # If End of Duration
      @sprite_zoom_x = @sprite_zoom_target_x if @sprite_zoom_dur_x == 0
    end
    # If a Zoom Y Transition
    if @sprite_zoom_dur_y > 0
      # Shorthand
      t = @sprite_zoom_target_y.to_f
      d = @sprite_zoom_dur_y
      # Adjust the Zoom Y over Duration Frames
      @sprite_zoom_y = (@sprite_zoom_y * (d - 1) + t) / d
      @sprite_zoom_dur_y -= 1
      # If End of Duration
      @sprite_zoom_y = @sprite_zoom_target_y if @sprite_zoom_dur_y == 0
    end    
  end
  #--------------------------------------------------------------------------
  # * Update - Game_Character (Main Update Method for Game_Character)
  #  - Main Update Method just calls update_character_rotations on Update
  #--------------------------------------------------------------------------
  alias rotate_zoom_character_update update unless $@
  def update
    # Call Original or other Aliases of Main Update Method
    rotate_zoom_character_update
    # Update Character Zoom Animations
    character_update_zoom
    # Update Character Rotations and Pendulums
    character_update_rotations
  end
  #--------------------------------------------------------------------------
  # * Screen Z - Game_Character
  #  - Simply stores the Height of a Character's Sprite when the value is
  #    passed to this class by Sprite_Character in the height Argument.
  #  - Does not affect the functionality of Screen Z in any way
  #--------------------------------------------------------------------------
  alias rotate_character_screen_z screen_z unless $@
  def screen_z(height = 0)
    # Store Bitmap Height after BLT in Sprite Character
    @rot_bitmap_height = (height and not height == 0) ? height : 16
    # Call Original or other Aliases
    rotate_character_screen_z(height)
  end
end

#==============================================================================
# ** Game_Event
#==============================================================================
class Game_Event
  #--------------------------------------------------------------------------
  # * Rotate Target Valid? - Game_Event
  #  - Valid Rotation Targets should have an Active Page and are not Erased
  #--------------------------------------------------------------------------
  def rotate_target_valid?
    return (not @erased and not @page.nil?)
  end  
  # DO NOT DEFINE THIS METHOD IF MODULAR PASSABLE IS INSTALLED
  if not $Modular_Passable
    #------------------------------------------------------------------------
    # * Refresh - Game_Event
    #  - This Method version is not used if Modular Passable is available
    #  - Reads Comments for Rotational Configurations
    #------------------------------------------------------------------------
    alias rotate_events_refresh refresh unless $@
    def refresh
      # Current Page
      page = @page
      # Call Original or other Aliases
      rotate_events_refresh
      # If Event Not Erased
      unless @erased
        # If Page is not Nil (Page Conditions) and Page Change is occuring
        if not @page.nil? and @page != page
          # Reset to set again by Comment Conditions (@option = nil)
          reset_page_comment_config
          # For Performance on checking each Command in Page List when Refreshed
          count = 0
          # For each Event Command as 'command' in Page List of Event Commands
          @page.list.each {|command|
            # If Command Code is a Comment (Code 108, 408 is Next Line Code)
            if command.code == 108
              # Check Comment for Configuration Values and adjust Counter
              count = check_page_comment_config(command.parameters[0], count)
            end
            # Increment Counter
            count += 1
            # Stop Iterating after Limit reached
            break if comment_limit?(count)
          }  # End |command| loop (Event Command List)
        end
      end
    end
    #------------------------------------------------------------------------
    # * Comment Limit? - Game_Event
    #  - This Method version is not used if Modular Passable is available
    #  - Uses a Default Limit of 10 Lines (each Line counts against value)
    #------------------------------------------------------------------------
    def comment_limit?(count)
      return true if count > 10
    end
  end # End Modular Passable Optional Method
  #------------------------------------------------------------------------
  # * Reset Rotations - Game_Event
  #  - Clears and Rescans Page Comments for Comment Configurations
  #------------------------------------------------------------------------
  def reset_rotations
    # If an Active Event Page and not Erased
    if not @page.nil? and not @erased
      # Resets All Angle related properties to their intial values
      reset_page_comment_config
      # Iterator allows Reading up to 10 Comments
      count = 0
      # For each Event Command as 'command' in Page List of Event Commands
      @page.list.each {|command|
        # If Command Code is a Comment (Code 108, 408 is Next Line Code)
        if command.code == 108
          # Check Comment for Configuration Values and adjust Counter
          count = check_page_comment_config(command.parameters[0], count)
        end
        # Increment Counter
        count += 1
        # Stop Iterating after Limit reached
        break if comment_limit?(count)
      }  # End |command| loop (Event Command List)
    end
  end
  #--------------------------------------------------------------------------
  # * Reset Page Comment Config - Game_Event
  #  - Aliasing Requires Modular Passable, otherwise this is unique
  #  - Resets Rotation Options set by Comment Config during a Page Change
  #--------------------------------------------------------------------------
  # Alias only if the Method already exists
  if $Modular_Passable and not $@
    alias rotate_ev_reset_page_comment_config reset_page_comment_config
  end
  def reset_page_comment_config
    # Reset to set again by Comment Conditions
    @angle = 0
    @angle_fix = false
    @pendulum = nil
    @pendulum_length = nil
    @rotate_center = 1
    @rotate_speed = nil
    @rotate_point_bottom = false
    @rotate_target = nil
    @rotate_target_min = nil
    @rotate_target_max = nil
    @rotate_target_dist = nil
    @rotate_angle_target = nil
    @rotate_angle_duration = 0
    @rotate_speed_target = nil
    @rotate_speed_duration = 0
    @sprite_zoom_x = 1.0
    @sprite_zoom_y = 1.0
    @sprite_zoom_target_x = @sprite_zoom_x
    @sprite_zoom_target_y = @sprite_zoom_y
    @sprite_zoom_dur_x = 0
    @sprite_zoom_dur_y = 0
    @degrees_per_frame = ROTATE_DEGREES_PER_FRAME
    # Runs Original or Other Aliases
    rotate_ev_reset_page_comment_config if $Modular_Passable
  end  
  #--------------------------------------------------------------------------
  # * Check Page Comment Config - Game_Event
  #  - Checks each Event Page in Comment Limit for Rotation Comments
  #--------------------------------------------------------------------------
  # Alias only if the Method already exists
  if $Modular_Passable and not $@  
    alias rotate_ev_check_page_comment_config check_page_comment_config
  end
  def check_page_comment_config(comment, count)
    # Looks for "\angle[-90]" Comments with Regular Expressions
    comment.gsub(/^\\rotate_angle\[([-0-9]+)\]\z/i){@angle = $1.to_f;
      return count; }
    # Looks for "\rotate_center[0 or 2]" Comments with Regular Expressions
    comment.gsub(/^\\rotate_center\[([0-2]+)\]\z/i){@rotate_center = $1.to_i;
      return count; }
    # Looks for "\rotate_speed[25]" Comments with Regular Expressions
    comment.gsub(/^\\rotate_speed\[([-0-9.]+)\]\z/i){@rotate_speed = $1.to_f;
      return count; }
    # Looks for "\rotate_target[N, N]" in the Comments with Regular Expressions
    comment.gsub(/^\\rotate_target\[([0-9, ]+)\]\z/i){@rotate_target = $1;
      @rotate_target = @rotate_target.split(",").map { |s| s.to_i };
      @rotate_target = @rotate_target[0] if @rotate_target.size == 1;
      return count; }
    # Looks for "\rotate_target_min[N]" Comments with Regular Expressions
    comment.gsub(/^\\rotate_target_min\[([0-9.]+)\]\z/i){
      @rotate_target_min = $1.to_f; return count; }
    # Looks for "\rotate_target_max[N]" Comments with Regular Expressions
    comment.gsub(/^\\rotate_target_max\[([0-9.]+)\]\z/i){
      @rotate_target_max = $1.to_f; return count; }
    # Looks for "\rotate_target_dist[N]" Comments with Regular Expressions
    comment.gsub(/^\\rotate_target_dist\[([0-9.]+)\]\z/i){
      @rotate_target_dist = $1.to_f; return count; }      
    # Looks for "\rotate_point_bottom" Comments with Regular Expressions
    comment.gsub(/^\\rotate_point_bottom\z/i){@rotate_point_bottom = true;
      return count; }
    # Looks for "\sprite_zoom_x[N.N]" Comments with Regular Expressions
    comment.gsub(/^\\sprite_zoom_x\[([0-9.]+)\]\z/i){@sprite_zoom_x = $1.to_f;
      return count; }
    # Looks for "\sprite_zoom_y[N.N]" Comments with Regular Expressions
    comment.gsub(/^\\sprite_zoom_y\[([0-9.]+)\]\z/i){@sprite_zoom_y = $1.to_f;
      return count; }
    # Looks for "\pendulum" Comments with Regular Expressions
    comment.gsub(/^\\pendulum\z/i){@pendulum = Game_Pendulum.new(@id);
      return count; }
    # Looks for "\pendulum_length[N]" Comments with Regular Expressions
    comment.gsub(/^\\pendulum_length\[([0-9.]+)\]\z/i){
      @pendulum.length = $1.to_f if @pendulum; return count; }      
    # Looks for "\degrees_per_frame[-N]" Comments with Regular Expressions
    comment.gsub(/^\\degrees_per_frame\[([-0-9.]+)\]\z/i){
      @degrees_per_frame = $1.to_f; return count; }
    # If Modular Passable is installed
    if $Modular_Passable
      # Return counter for other Aliases when no Comments are found
      return rotate_ev_check_page_comment_config(comment, count)
    else
      # Return the Counter for Standalone Applications of this script
      return count
    end
  end
end