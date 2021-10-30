#===============================================================================                           
#  Ultimate Title Screen Resource (settings)
#===============================================================================                           
# Config value for selecting title screen style
SCREENSTYLE = 3
# 0 - A custom-styled screen (moves dynamically with the mouse [if present])
# 1 - FR/LG
# 2 - HG/SS
# 3 - R/S/E
# 4 - D/P/PT
# 5 - B/W
# 6 - X/Y    <- Definitely the best one
# 7 - S/M
#-------------------------------------------------------------------------------
# BGM configurations
#-------------------------------------------------------------------------------
# BGM names for the different styles
GEN_ONE_BGM = "title_frlg.ogg"
GEN_TWO_BGM = "title_hgss.ogg"
GEN_THREE_BGM = "Pokmon_Battle_Frontier.ogg"
GEN_FOUR_BGM = "Pokmon_Battle_Frontier.ogg"
GEN_FIVE_BGM = "title_origin.ogg"
GEN_SIX_BGM = "Pokmon_Battle_Frontier.ogg"
GEN_SEVEN_BGM = "title_hgss.ogg"
GEN_CUSTOM_BGM = "002 - Title Screen.mp3"
# BGM names for the FR/LG intro scene (left one is for style 1, right is for 0)
CLASSIC_INTRO_BGM = "002 - Title Screen.mp3"
# BGM name for the credits scene
CREDITS_BGM = "credits.ogg"
#-------------------------------------------------------------------------------
# Turns on the option for the game to restart after music has done playing
RESTART_TITLE = true
# Decides whether or not to play the title screen even if $DEBUG is on
PLAY_ON_DEBUG = false
#-------------------------------------------------------------------------------
# More detailed configurations:
#-------------------------------------------------------------------------------
# Decides whether or not, or which Intro scene to play
#   1 - FR/LG
PLAY_INTRO_SCENE = true
# Decides between the use of OR/AS or R/S/E styled opening for style 3
NEW_GENERATION = true
# Toggle EXPAND_STYLE to:
#   - colour the background in style 5
#   - show the Pokemon panorama in style 6
#   - give motion to style 7
EXPAND_STYLE = true
# Applies a form to the Pokemon sprite for style 5
SPECIES_FORM = 0
#-------------------------------------------------------------------------------
# The Following only applies if you're using the Gen 6 style + Elite Battle.
#------------------------------------------------------------------------------- 
# Battle backgrounds for different species
EB_BG = ["City","Field","Water"]
# Battle bases for different species
EB_BASE = ["Cave","FieldDirt","CityConcrete"]
# BGM name
EB_DEMO_BGM = "global_opening.ogg"
#===============================================================================                           
#  Fancy Badges (settings)
#===============================================================================                           
# Names for your gym badges
FANCY_BADGE_NAMES = [
#Kanto
    "Boulder Badge",
    "Cascade Badge",
    "Thunder Badge",
    "Rainbow Badge",
    "Soul Badge",
    "Marsh Badge",
    "Volcano Badge",
    "Earth Badge",
#Johto
    "Zephyr Badge",
    "Hive Badge",
    "Plain Badge",
    "Fog Badge",
    "Storm Badge",
    "Mineral Badge",
    "Glacier Badge",
    "Rising Badge",
#Hoenn
    "Stone Badge",
    "Knuckle Badge",
    "Dynamo Badge",
    "Heat Badge",
    "Balance Badge",
    "Feather Badge",
    "Mind Badge",
    "Rain Badge",
#Sinnoh
    "Coal Badge",
    "Forest Badge",
    "Cobble Badge",
    "Fen Badge",
    "Relic Badge",
    "Mine Badge",
    "Icicle Badge",
    "Beacon Badge",
#Unova
    "Trio Badge",
    "Basic Badge",
    "Insect Badge",
    "Bolt Badge",
    "Quake Badge",
    "Jet Badge",
    "Freeze Badge",
    "Legend Badge",
    "Toxic Badge",
    "Wave Badge",
#Kalos
    "Bug Badge",
    "Cliff Badge",
    "Rumble Badge",
    "Plant Badge",
    "Voltage Badge",
    "Fairy Badge",
    "Psychic Badge",
    "Iceberg Badge",
]    
#===============================================================================                           
#  Pokemon World Tournament (settings)
#===============================================================================                           
# This is a list of the Pokemon that cannot be used in the PWT                
BAN_LIST = []
# To edit Tournament branches please see below:

# Information pertining to the start position on the PWT stage
# Format is as following: [map_id, map_x, map_y]
PWT_MAP_DATA = [240,21,14]
# ID for the event used to move the player and opponents on the map
PWT_MOVE_EVENT = 37
# ID of the opponent event
PWT_OPP_EVENT = 35
# ID of the scoreboard event
PWT_SCORE_BOARD_EVENT = 34
# ID of the lobby trainer event
PWT_LOBBY_EVENT = 11
# ID of the event used to display an optional even if the player wins the PWT
PWT_FANFARE_EVENT = 38
#===============================================================================                           