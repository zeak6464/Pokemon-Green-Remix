# ========================================================================
# Item Find
# v1.0
# By Boonzeet
# ========================================================================
# A script to show a helpful message with item name, icon and description
# when an item is found for the first time.
# ========================================================================

WINDOWSKIN_NAME = "" # set for custom windowskin

# Base Class

class PokemonItemFind_Scene
  def pbStartScene
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}

    @sprites["background"] = Window_UnformattedTextPokemon.newWithSize("", 0, 0, Graphics.width, 0, @viewport)
    @sprites["background"].z = @viewport.z - 1
    @sprites["background"].visible = false
    if WINDOWSKIN_NAME != ""
      @sprites["background"].setSkin("Graphics/Windowskins/" + WINDOWSKIN_NAME)
    end

    @sprites["itemicon"] = ItemIconSprite.new(42, Graphics.height - 48, -1, @viewport)
    @sprites["itemicon"].visible = false
    @sprites["itemicon"].z = @viewport.z + 2

    @sprites["descwindow"] = Window_UnformattedTextPokemon.newWithSize("", 64, 0, Graphics.width - 64, 64, @viewport)
    @sprites["descwindow"].windowskin = nil
    @sprites["descwindow"].z = @viewport.z
    @sprites["descwindow"].visible = false

    @sprites["titlewindow"] = Window_UnformattedTextPokemon.newWithSize("", 0, 0, 128, 16, @viewport)
    @sprites["titlewindow"].visible = false
    @sprites["titlewindow"].z = @viewport.z + 1
    if WINDOWSKIN_NAME != ""
      @sprites["titlewindow"].setSkin("Graphics/Windowskins/" + WINDOWSKIN_NAME)
    end
  end

  def pbShow(item)
    name = PBItems.getName(item)
    description = pbGetMessage(MessageTypes::ItemDescriptions, item)

    descwindow = @sprites["descwindow"]
    # descwindow.baseColor = Color.new(255, 255, 255) # set if dark windowskin
    descwindow.resizeToFit(description, Graphics.width - 64)
    descwindow.text = description
    descwindow.y = Graphics.height - descwindow.height
    descwindow.visible = true

    titlewindow = @sprites["titlewindow"]
    # titlewindow.baseColor = Color.new(255, 255, 255) # set if dark windowskin
    titlewindow.resizeToFit(name, Graphics.height)
    titlewindow.text = name
    titlewindow.y = Graphics.height - descwindow.height - 46#32
    titlewindow.visible = true

    background = @sprites["background"]
    background.height = descwindow.height# + 32
    background.y = Graphics.height - background.height
    background.visible = true

    itemicon = @sprites["itemicon"]
    itemicon.item = item
    itemicon.y = Graphics.height - (descwindow.height / 2).floor
    itemicon.visible = true

    loop do
      background.update
      itemicon.update
      descwindow.update
      titlewindow.update
      Graphics.update
      Input.update
      pbUpdateSceneMap
      if Input.trigger?(Input::B) || Input.trigger?(Input::C)
        pbEndScene
        break
      end
    end
  end

  def pbEndScene
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

# Game Player changes
# ---
# Adds a list of found items to the Game Player which is maintained over saves

class Game_Player
  alias initialize_itemfind initialize
  def initialize(*args)
    @found_items = []
    initialize_itemfind(*args)
  end

  def addFoundItem(item)
    if !defined?(@found_items)
      @found_items = []
    end
    if !@found_items.include?(item)
      @found_items.push(item)
      scene = PokemonItemFind_Scene.new
      scene.pbStartScene
      scene.pbShow(item)
    end
  end
end

# Overrides of pbItemBall and pbReceiveItem

#===============================================================================
# Picking up an item found on the ground
#===============================================================================
def Kernel.pbItemBall(item, quantity = 1)
  if item.is_a?(String) || item.is_a?(Symbol)
    item = getID(PBItems, item)
  end
  return false if !item || item <= 0 || quantity < 1
  itemname = (quantity > 1) ? PBItems.getNamePlural(item) : PBItems.getName(item)
  pocket = pbGetPocket(item)
  Kernel.pbMessage(_INTL("\\me[Item get]You obtained a \\c[1]{1}\\c[0]!\\wtnp[30]", itemname))
  if $PokemonBag.pbStoreItem(item, quantity) # If item can be picked up
    Kernel.pbMessage(_INTL("You put the {1} away\\nin the <icon=bagPocket{2}>\\c[1]{3} Pocket\\c[0].",
                           itemname, pocket, PokemonBag.pocketNames()[pocket]))
    $game_player.addFoundItem(item)
    return true
  else
    Kernel.pbMessage(_INTL("But your Bag is full..."))
    return false
  end
end

#===============================================================================
# Being given an item
#===============================================================================
def Kernel.pbReceiveItem(item, quantity = 1)
  if item.is_a?(String) || item.is_a?(Symbol)
    item = getID(PBItems, item)
  end
  return false if !item || item <= 0 || quantity < 1
  itemname = (quantity > 1) ? PBItems.getNamePlural(item) : PBItems.getName(item)
  pocket = pbGetPocket(item)
  Kernel.pbMessage(_INTL("\\me[Item get]You obtained a \\c[1]{1}\\c[0]!\\wtnp[30]", itemname))
  if $PokemonBag.pbStoreItem(item, quantity) # If item can be added
    Kernel.pbMessage(_INTL("You put the {1} away\\nin the <icon=bagPocket{2}>\\c[1]{3} Pocket\\c[0].",
                           itemname, pocket, PokemonBag.pocketNames()[pocket]))
    $game_player.addFoundItem(item)
    return true
  end
  return false   # Can't add the item
end