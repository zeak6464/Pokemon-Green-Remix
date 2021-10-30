#===============================================================================
# ■ Overworld Shadows by KleinStudio
# http://pokemonfangames.com
#
# * Making a overworld shadowless
# ** Method 1
#   - Add /noShadow/ to the event name
# ** Method 2
#   - Add the event name to Shadowless_EventNames
#     this is useful for doors for example.
# ** Method 3
#   - Create a new comment in the event and type "NoShadow"
#     If the event is a dependent event you have to put the comment
#     in the common event.
# Put this crit under Following_Pokemon script.
#==============================================================================#
#                          Overworld Shadows for v17                           #
#                                  by Marin                                    #
#==============================================================================#
#                                    Info                                      #
#                                                                              #
#   You'll have likely heard of KleinStudios' Overworld Shadows script; many   #
#    fangames use it, after all. It was not compatible with Essentials v17+    #
#    though, so after getting the suggestion I thought it would be cool if I   #
#   could make something of my own that would work with v16, as well as v17.   #
#==============================================================================#
#                                  Features:                                   #
#                - Blacklisting events from receiving shadows                  #
#                - Whitelisting events to always receive shadows               #
#                - A scaling animation when an event jumps                     #
#==============================================================================#
#                                    Usage                                     #
#                                                                              #
#     Shadow_Path is the path to the shadow graphic. You can change this       #
#   sprite, though you may need to fiddle with positioning of the sprite in    #
#  relation to the event after, though. That's done in "def position_shadow".  #
#                                                                              #
#  As the name literally says, if an event's name includes any of the strings  #
#  in "No_Shadow_If_Event_Name_Has", it won't get a shadow, UNLESS the event's #
#                 name also includes any of the strings in                     #
#   "Always_Give_Shadow_If_Event_Name_Has". This is essentially "overriding".  #
#                                                                              #
#    Case_Sensitive is either true or false. It's used when determing if an    #
# event's name includes a string in the "No_Shadow" and "Always_Give" arrays.  #
#      If true, it must match all strings with capitals exactly as well.       #
#                If false, capitals don't need to match up.                    #
#==============================================================================#
#                          Overworld Shadows for v17                           #
#                                  by WolfPP                                   #
#==============================================================================#
# Find 'Sprite_WaterReflection' script and below that script,                  #
# add a new script called "Sprite_ShadowOverworld" or whatever the name        #
#==============================================================================#
=begin
Now, find 'Sprite_Character' script. Then:

Inside 'def initialize(viewport, character = nil)', below 
'@surfbase = Sprite_SurfBase.new(self,character,viewport) if character==$game_player' add:

    @shadowoverworldbitmap = Sprite_ShadowOverworld.new(self,character,viewport)

Inside 'def visible=(value)', below '@reflection.visible = value if @reflection' add:

    @shadowoverworldbitmap.visible = value if @shadowoverworldbitmap

Inside 'def dispose', below '@reflection = nil' add:

    @shadowoverworldbitmap.dispose if @shadowoverworldbitmap
    @shadowoverworldbitmap = nil
    
Finally, inside 'def update', below '@reflection.update if @reflection', paste:

@shadowoverworldbitmap.update if @shadowoverworldbitmap   


To the event doesn't works (won't show the shadow effect) you need to put a 
Comment NoShadow inside the event, to each page. 
Example to (healing balls events, inside Poke Center Map).


JUST A P.S. DON'T COPY:
That is the code to check if event are walking into surfing base or grass tile 
or water reflection tile (to remove the shadow effect). You can add more if you want to:

    currentTag = pbGetTerrainTag(event)
    if PBTerrain.isGrass?(currentTag) || PBTerrain.hasReflections?(currentTag) ||
      PBTerrain.isSurfable?(currentTag)
      # Just-in-time disposal of sprite 
      if @sprite
        @sprite.dispose
        @sprite = nil
      end
      return
    end
    
=end 
#==============================================================================#
#                    Please give credit when using this.                       #
#==============================================================================#
# Extending so we can access some private instance variables.
class Game_Character; attr_reader :jump_count; end

class Sprite_ShadowOverworld
  attr_reader :visible; attr_accessor :event

################################################################################
#Alteracoes Para o Jogo Pokemon Chronicles, Codigo Original nos Comentarios a Verde
#Estas alteracoes requerem outras scripts:
#Sprite_OverworldShadows
#Sprite_Character
################################################################################ 
# NO_SHADOW_EVENT=["door","nurse","healing balls","Mart","boulder","tree","HeadbuttTree","BerryPlant"]
  NO_SHADOW_EVENT=[
  "NoShadow",
  "BerryPlant",
  "OutdoorLight",
  "Light",
  "Fog",
  "HeadbuttTree",
  "HiddenItem",
  "Healing balls left",
  "Healing balls right",
  "Ballons",
  "Intro",
  "Event",
  "Door",
  "Gate",
  "Machine",
  "Truck",
  "PC",
  "Nurse",
  "Nurse Joy",
  "Nurse Chansey",
  "Mart Person",
  "TV Broadcast"
]
################################################################################   

  def initialize(sprite,event,viewport=nil)
    @rsprite  = sprite
    @sprite   = nil
    @event    = event
    @viewport = viewport
    @disposed = false
################################################################################
#Alteracoes Para o Jogo Pokemon Chronicles, Codigo Original nos Comentarios a Verde
#Estas alteracoes requerem outras scripts:
#Sprite_OverworldShadows
#Sprite_Character
################################################################################ 
#   @shadowoverworldbitmap = AnimatedBitmap.new("Graphics/Characters/shadow")
    @shadowoverworldbitmap = AnimatedBitmap.new("Graphics/Pictures/OverworldShadows/shadow")
################################################################################     
    @cws = @shadowoverworldbitmap.height*2
    @chs = @shadowoverworldbitmap.height*2
    update
  end

  def dispose; if !@disposed; @sprite.dispose if @sprite; @sprite = nil; @disposed = true; end; end

  def disposed?; @disposed; end

  def jump_sprite
    return unless @sprite
    x = (@event.real_x - @event.map.display_x + 3) / 4 + (Game_Map::TILE_WIDTH / 2)
    y = (@event.real_y - @event.map.display_y + 3) / 4 + (Game_Map::TILE_HEIGHT)
    @totaljump = @event.jump_count if !@totaljump
    case @event.jump_count
    when 1..(@totaljump / 3); @sprite.zoom_x += 0.1; @sprite.zoom_y += 0.1
    when (@totaljump / 3 + 1)..(@totaljump / 3 + 2); @sprite.zoom_x += 0.05; @sprite.zoom_y += 0.05
    when (@totaljump / 3 * 2 - 1)..(@totaljump / 3 * 2); @sprite.zoom_x -= 0.05; @sprite.zoom_y -= 0.05
    when (@totaljump / 3 * 2 + 1)..(@totaljump); @sprite.zoom_x -= 0.1; @sprite.zoom_y -= 0.1
    end
    if @event.jump_count == 1; @sprite.zoom_x = 1.0; @sprite.zoom_y = 1.0; @totaljump = nil; end
    @sprite.x = x; @sprite.y = y; @sprite.z = @rsprite.z - 1
  end

  def visible=(value); @visible = value; @sprite.visible = value if @sprite && !@sprite.disposed?; end
    
  def update
    return if disposed? || !$scene || !$scene.is_a?(Scene_Map)
    return jump_sprite if event.jumping?
    if event.character_name =="" || event.character_name == "nil" ||
    (PBTerrain.isGrass?(pbGetTerrainTag(event)) || PBTerrain.hasReflections?(pbGetTerrainTag(event)) || 
     PBTerrain.isSurfable?(pbGetTerrainTag(event)) || PBTerrain.isIce?(pbGetTerrainTag(event))) ||
    (event!=$game_player && pbEventCommentInput(event,0,"NoShadow")) ||
     NO_SHADOW_EVENT.include?(event.character_name)
      # Just-in-time disposal of sprite 
      if @sprite; @sprite.dispose; @sprite = nil; end; return; end
    # Just-in-time creation of sprite
    @sprite = Sprite.new(@viewport) if !@sprite
    if @sprite
      @sprite.bitmap = @shadowoverworldbitmap.bitmap; cw = @cws; ch = @chs
      @sprite.x       = @rsprite.x
      @sprite.y       = @rsprite.y
      @sprite.ox      = cw/2 -1
      @sprite.oy      = ch -18
      @sprite.z       = @rsprite.z-1
      @sprite.zoom_x  = @rsprite.zoom_x
      @sprite.zoom_y  = @rsprite.zoom_y
      @sprite.tone    = @rsprite.tone
      @sprite.color   = @rsprite.color
      @sprite.opacity = @rsprite.opacity
    end
  end
end