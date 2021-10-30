#===============================================================================
#  PokedexEntry BW Style
#  for Pokémon Essentials version 18.x
#
#===============================================================================
#
# Instructions: Put this script bellow BW_PokedexMain. Download the file BW Pokédex.rar and
# extract the files in your project main folder.
#   
#    Requires Scripting Utilities by Luka S.J. for the script works correctly.
#
#===============================================================================
#
#  Modified by DeepBlue PacificWaves
#  Special thanks to NettoHikari, that helped with the Entry Scene/Entry Page
#  code.
#
#  Graphics Ripped by Xtreme1992
#
#  If used, please give credits. For more information on how to credited, look 
#  for the original post on Relic Castle or PokéCommunity.
#
#===============================================================================

def pbFindEncounter(encounter,species)
  return false if !encounter
  for i in 0...encounter.length
    next if !encounter[i]
    for j in 0...encounter[i].length
      return true if encounter[i][j][0]==species
    end
  end
  return false
end



class PokemonPokedexInfo_Scene
  def pbStartScene(dexlist,index,region)
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @dexlist = dexlist
    @index   = index
    @region  = region
    @page = 1
    @typebitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Pokedex/icon_types"))
    @sprites = {}
# Defines the Scrolling Background, as well as the overlay on top of it    
    @sprites["background"] = IconSprite.new(0,0,@viewport)
    @sprites["background"] = ScrollingSprite.new(@viewport)
    @sprites["background"].speed = 1
    @sprites["infoverlay"] = IconSprite.new(0,0,@viewport)
    @sprites["infosprite"] = PokemonSprite.new(@viewport)
    @sprites["infosprite"].setOffset(PictureOrigin::Center)
# Changes the postion of the Pokémon in the Entry Page    
    @sprites["infosprite"].x = 106
    @sprites["infosprite"].y = 99
    @mapdata = pbLoadTownMapData
    mappos = ($game_map) ? pbGetMetadata($game_map.map_id,MetadataMapPosition) : nil
    if @region<0                                   # Use player's current region
      @region = (mappos) ? mappos[0] : 0                      # Region 0 default
    end
    @sprites["areamap"] = IconSprite.new(0,0,@viewport)
    @sprites["areamap"].setBitmap("Graphics/Pictures/#{@mapdata[@region][1]}")
    @sprites["areamap"].x += (Graphics.width-@sprites["areamap"].bitmap.width)/2
    @sprites["areamap"].y += (Graphics.height-48-@sprites["areamap"].bitmap.height)/2
    for hidden in REGION_MAP_EXTRAS
      if hidden[0]==@region && hidden[1]>0 && $game_switches[hidden[1]]
        pbDrawImagePositions(@sprites["areamap"].bitmap,[
           ["Graphics/Pictures/#{hidden[4]}",
              hidden[2]*PokemonRegionMap_Scene::SQUAREWIDTH,
              hidden[3]*PokemonRegionMap_Scene::SQUAREHEIGHT]
        ])
      end
    end
    @sprites["areahighlight"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["areaoverlay"] = IconSprite.new(0,0,@viewport)
    @sprites["areaoverlay"].setBitmap("Graphics/Pictures/Pokedex/overlay_area")
    @sprites["formfront"] = PokemonSprite.new(@viewport)
    @sprites["formfront"].setOffset(PictureOrigin::Center)
# Changes the X and Y position of the front sprite of the Pokémon in the 
# Forms Page    
    @sprites["formfront"].x = 382
    @sprites["formfront"].y = 226
    @sprites["formback"] = PokemonSprite.new(@viewport)
    @sprites["formback"].setOffset(PictureOrigin::Center)
# Changes the X position of the front sprite of the Pokémon in the Forms Page  
    @sprites["formback"].x = 125  
    @sprites["formicon"] = PokemonSpeciesIconSprite.new(0,@viewport)
    @sprites["formicon"].setOffset(PictureOrigin::Center)
# Changes the X and Y position of the icon sprite of the Pokémon in the 
# Forms Page  
    @sprites["formicon"].x = 64
    @sprites["formicon"].y = 102
# Changes the X and Y position of the Up Arrow sprite of the Pokémon in the 
# Forms Page  
    @sprites["uparrow"] = AnimatedSprite.new("Graphics/Pictures/uparrow",8,28,40,2,@viewport)
    @sprites["uparrow"].x = 242
    @sprites["uparrow"].y = 40
    @sprites["uparrow"].play
    @sprites["uparrow"].visible = false
# Changes the X and Y position of the Down Arrow sprite of the Pokémon in the 
# Forms Page  
    @sprites["downarrow"] = AnimatedSprite.new("Graphics/Pictures/downarrow",8,28,40,2,@viewport)
    @sprites["downarrow"].x = 242
    @sprites["downarrow"].y = 128
    @sprites["downarrow"].play
    @sprites["downarrow"].visible = false
    @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    pbUpdateDummyPokemon
    @available = pbGetAvailableForms
    drawPage(@page)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbStartSceneBrief(species)  # For standalone access, shows first page only
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
#    @region = 0
    dexnum = species
    dexnumshift = false
    if $PokemonGlobal.pokedexUnlocked[$PokemonGlobal.pokedexUnlocked.length-1]
      dexnumshift = true if DEXES_WITH_OFFSETS.include?(-1)
    else
      dexnum = 0
      for i in 0...$PokemonGlobal.pokedexUnlocked.length-1
        next if !$PokemonGlobal.pokedexUnlocked[i]
        num = pbGetRegionalNumber(i,species)
        next if num<=0
        dexnum = num
        dexnumshift = true if DEXES_WITH_OFFSETS.include?(i)
#        @region = pbDexNames[i][1] if pbDexNames[i].is_a?(Array)
        break
      end
    end
    @dexlist = [[species,"",0,0,dexnum,dexnumshift]]
    @index   = 0
    @page = 1
    @brief = true
    @typebitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Pokedex/icon_types"))
    @sprites = {}
# Defines the Scrolling Background of the Entry Scene when capturing a Wild 
# Pokémon, as well as the overlay on top of it
    @sprites["background"] = IconSprite.new(0,0,@viewport)
    @sprites["background"] = ScrollingSprite.new(@viewport)
    @sprites["background"].speed = 1
    @sprites["infoverlay"] = IconSprite.new(0,0,@viewport)
    @sprites["infosprite"] = PokemonSprite.new(@viewport)
    @sprites["infosprite"].setOffset(PictureOrigin::Center)
# Changes the X and Y position of the front sprite of the Pokémon in the  Entry 
# Scene when capturing a Wild Pokémon
    @sprites["infosprite"].x = 106
    @sprites["infosprite"].y = 136
    @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    pbUpdateDummyPokemon
    drawPage(@page)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @typebitmap.dispose
    @viewport.dispose
  end

  def pbUpdate
    if @page==2
      intensity = (Graphics.frame_count%40)*12
      intensity = 480-intensity if intensity>240
      @sprites["areahighlight"].opacity = intensity
    end
    pbUpdateSpriteHash(@sprites)
  end

  def pbUpdateDummyPokemon
    @species = @dexlist[@index][0]
    @gender  = ($Trainer.formlastseen[@species][0] rescue 0)
    @form    = ($Trainer.formlastseen[@species][1] rescue 0)
    @sprites["infosprite"].setSpeciesBitmap(@species,(@gender==1),@form)
    if @sprites["formfront"]
      @sprites["formfront"].setSpeciesBitmap(@species,(@gender==1),@form)
    end
    if @sprites["formback"]
      @sprites["formback"].setSpeciesBitmap(@species,(@gender==1),@form,false,false,true)
# This one was a bit hard to find, but it changes the Y position of the 
# backsprite of the Pokémon in the Forms Page
       @sprites["formback"].y = 226
      fSpecies = pbGetFSpeciesFromForm(@species,@form)
      @sprites["formback"].y += (pbLoadSpeciesMetrics[MetricBattlerPlayerY][fSpecies] || 0)*2
    end
    if @sprites["formicon"]
      @sprites["formicon"].pbSetParams(@species,@gender,@form)
    end
  end

  def pbGetAvailableForms
    available = []   # [name, gender, form]
    formdata = pbLoadFormToSpecies
    possibleforms = []
    multiforms = false
    if formdata[@species]
      for i in 0...formdata[@species].length
        fSpecies = pbGetFSpeciesFromForm(@species,i)
        formname = pbGetMessage(MessageTypes::FormNames,fSpecies)
        genderRate = pbGetSpeciesData(@species,i,SpeciesGenderRate)
        if i==0 || (formname && formname!="")
          multiforms = true if i>0
          case genderRate
          when PBGenderRates::AlwaysMale,
               PBGenderRates::AlwaysFemale,
               PBGenderRates::Genderless
            gendertopush = (genderRate==PBGenderRates::AlwaysFemale) ? 1 : 0
            if $Trainer.formseen[@species][gendertopush][i] || DEX_SHOWS_ALL_FORMS
              gendertopush = 2 if genderRate==PBGenderRates::Genderless
              possibleforms.push([i,gendertopush,formname])
            end
          else   # Both male and female
            for g in 0...2
              if $Trainer.formseen[@species][g][i] || DEX_SHOWS_ALL_FORMS
                possibleforms.push([i,g,formname])
                break if (formname && formname!="")
              end
            end
          end
        end
      end
    end
    for thisform in possibleforms
      if thisform[2] && thisform[2]!=""   # Has a form name
        thisformname = thisform[2]
      else   # Necessarily applies only to form 0
        case thisform[1]
        when 0; thisformname = _INTL("Male")
        when 1; thisformname = _INTL("Female")
        else
          thisformname = (multiforms) ? _INTL("One Form") : _INTL("Genderless")
        end
      end
      # Push to available array
      gendertopush = (thisform[1]==2) ? 0 : thisform[1]
      available.push([thisformname,gendertopush,thisform[0]])
    end
    return available
  end

  def drawPage(page)
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    # Make certain sprites visible
    @sprites["infosprite"].visible    = (@page==1)
    @sprites["areamap"].visible       = (@page==2) if @sprites["areamap"]
    @sprites["areahighlight"].visible = (@page==2) if @sprites["areahighlight"]
    @sprites["areaoverlay"].visible   = (@page==2) if @sprites["areaoverlay"]
    @sprites["formfront"].visible     = (@page==3) if @sprites["formfront"]
    @sprites["formback"].visible      = (@page==3) if @sprites["formback"]
    @sprites["formicon"].visible      = (@page==3) if @sprites["formicon"]
    # Draw page-specific information
    case page
    when 1; drawPageInfo
    when 2; drawPageArea
    when 3; drawPageForms
    end
  end


  def drawPageInfo
# Sets the Scrolling Background of the Entry Page, as well as the overlay on top 
# of it
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/bg_info"))
    @sprites["infoverlay"].setBitmap(_INTL("Graphics/Pictures/Pokedex/info_overlay"))
    overlay = @sprites["overlay"].bitmap
    base   = Color.new(82,82,90)
    shadow = Color.new(165,165,173)
    imagepos = []
    if @brief
# Sets the Scrolling Background of the Entry Scena when capturing a wild Pokémon,
# as well as the overlay on top of it
      imagepos.push([_INTL("Graphics/Pictures/Pokedex/overlay_info"),0,0])
      @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/bg_capture"))
      @sprites["infoverlay"].setBitmap(_INTL("Graphics/Pictures/Pokedex/capture_overlay"))
    end
    # Write various bits of text
    indexText = "???"
    if @dexlist[@index][4]>0
      indexNumber = @dexlist[@index][4]
      indexNumber -= 1 if @dexlist[@index][5]
      indexText = sprintf("%03d",indexNumber)
    end

# This bit of the code woudn't have been possible without the help of NettoHikari.
# He helped me to set the Sprites and Texts differently, depending on if the 
# Pokédex Entry Scene is playing, when the payer is capturing a Wild Pokémon, 
# or if the player is seeing the "normal" Dex Entry page on the Pokédex.
#
# Basically, this next lines changes the position of various text 
# (height, weight, the Name's Species, etc), depending on if the 
# Pokédex Entry Scene is playing, when the payer is capturing a Wild Pokémon, 
# or if the player is seeing the "normal" Dex Entry page on the Pokédex.
    
    if @brief
      textpos = [
       [_INTL("{1}{2} {3}",indexText," ",PBSpecies.getName(@species)),
          272,61,0,Color.new(82,82,90),Color.new(165,165,173)],
       [_INTL("Height"),288,176,0,base,shadow],
       [_INTL("Weight"),288,206,0,base,shadow]
    ]
    
    else
    textpos = [
       [_INTL("{1}{2} {3}",indexText," ",PBSpecies.getName(@species)),
          272,23,0,Color.new(82,82,90),Color.new(165,165,173)],
       [_INTL("Height"),288,138,0,base,shadow],
       [_INTL("Weight"),288,168,0,base,shadow]
    ]
    
    end   
    
    if $Trainer.owned[@species]
      speciesData = pbGetSpeciesData(@species,@form)
      fSpecies = pbGetFSpeciesFromForm(@species,@form)
      # Write the kind
      kind = pbGetMessage(MessageTypes::Kinds,fSpecies)
      kind = pbGetMessage(MessageTypes::Kinds,@species) if !kind || kind==""
    if @brief
      textpos.push([_INTL("{1} Pokémon",kind),275,95,0,base,shadow])
    else
      textpos.push([_INTL("{1} Pokémon",kind),275,57,0,base,shadow])
    end    
      # Write the height and weight
      height = speciesData[SpeciesHeight] || 1
      weight = speciesData[SpeciesWeight] || 1
      if pbGetCountry==0xF4   # If the user is in the United States
        inches = (height/0.254).round
        pounds = (weight/0.45359).round
      if @brief
        textpos.push([_ISPRINTF("{1:d}'{2:02d}\"",inches/12,inches%12),490,181,1,base,shadow])
            else
        textpos.push([_ISPRINTF("{1:d}'{2:02d}\"",inches/12,inches%12),490,143,1,base,shadow])
      end
      
      if @brief
        textpos.push([_ISPRINTF("{1:4.1f} lbs.",pounds/10.0),490,214,1,base,shadow])
          else
        textpos.push([_ISPRINTF("{1:4.1f} lbs.",pounds/10.0),490,176,1,base,shadow])
      end
        
      else
        
      if @brief
        textpos.push([_ISPRINTF("{1:.1f} m",height/10.0),490,176,1,base,shadow])
          else
        textpos.push([_ISPRINTF("{1:.1f} m",height/10.0),490,138,1,base,shadow])
          end
      if @brief
        textpos.push([_ISPRINTF("{1:.1f} kg",weight/10.0),490,206,1,base,shadow])
          else
        textpos.push([_ISPRINTF("{1:.1f} kg",weight/10.0),490,168,1,base,shadow])
          end
      end 
      # Draw the Pokédex entry text. Changed
      base   = Color.new(255,255,255)
      shadow = Color.new(165,165,173)
      entry = pbGetMessage(MessageTypes::Entries,fSpecies)
      entry = pbGetMessage(MessageTypes::Entries,@species) if !entry || entry==""
    if @brief
      drawTextEx(overlay,39,254,Graphics.width-(40*2),4,entry,base,shadow)
    else
      drawTextEx(overlay,39,216,Graphics.width-(40*2),4,entry,base,shadow)
    end
      # Draw the footprint. Changed
      footprintfile = pbPokemonFootprintFile(@species,@form)
      if footprintfile
        footprint = BitmapCache.load_bitmap(footprintfile)
      if @brief
        overlay.blt(224,150,footprint,footprint.rect)
      else
        overlay.blt(224,112,footprint,footprint.rect)
      end
        footprint.dispose
      end
      # Show the owned icon. Changed
      if @brief
        imagepos.push(["Graphics/Pictures/Pokedex/icon_own",211,57])
      else
        imagepos.push(["Graphics/Pictures/Pokedex/icon_own",211,19])
      end
      # Draw the type icon(s). Changed
      type1 = speciesData[SpeciesType1] || 0
      type2 = speciesData[SpeciesType2] || type1
      type1rect = Rect.new(0,type1*32,96,32)
      type2rect = Rect.new(0,type2*32,96,32)
    if @brief
      overlay.blt(287,133,@typebitmap.bitmap,type1rect)
    else
      overlay.blt(287,95,@typebitmap.bitmap,type1rect)
    end
    
    if @brief
      overlay.blt(367,133,@typebitmap.bitmap,type2rect) if type1!=type2
    else
      overlay.blt(367,95,@typebitmap.bitmap,type2rect) if type1!=type2
    end
    
  else
# This bit of the code below is simply the Entry Page when you have seen the 
# Pokémon, but did'nt capture it yet.    
      # Write the kind. Changed
      textpos.push([_INTL("????? Pokémon"),275,57,0,base,shadow])
      # Write the height and weight. Changed
      if pbGetCountry()==0xF4 # If the user is in the United States
        textpos.push([_INTL("???'??\""),490,143,1,base,shadow])
        textpos.push([_INTL("????.? lbs."),489,176,1,base,shadow])
      else
        textpos.push([_INTL("????.? m"),489,138,1,base,shadow])
        textpos.push([_INTL("????.? kg"),489,168,1,base,shadow])
      end
    end
    # Draw all text
    pbDrawTextPositions(@sprites["overlay"].bitmap,textpos)
    # Draw all images
    pbDrawImagePositions(overlay,imagepos)
  end

  def drawPageArea
# Sets the Scrolling Background of the Area Page, as well as the overlay on top of it
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/bg_area"))
    @sprites["infoverlay"].setBitmap(_INTL("Graphics/Pictures/Pokedex/map_overlay"))
    overlay = @sprites["overlay"].bitmap
    base   = Color.new(88,88,80)
    shadow = Color.new(168,184,184)
    @sprites["areahighlight"].bitmap.clear
    # Fill the array "points" with all squares of the region map in which the
    # species can be found. Unchanged.
    points = []
    mapwidth = 1+PokemonRegionMap_Scene::RIGHT-PokemonRegionMap_Scene::LEFT
    encdata = pbLoadEncountersData
    for enc in encdata.keys
      enctypes = encdata[enc][1]
      if pbFindEncounter(enctypes,@species)
        mappos = pbGetMetadata(enc,MetadataMapPosition)
        if mappos && mappos[0]==@region
          showpoint = true
          for loc in @mapdata[@region][2]
            showpoint = false if loc[0]==mappos[1] && loc[1]==mappos[2] &&
                                 loc[7] && !$game_switches[loc[7]]
          end
          if showpoint
            mapsize = pbGetMetadata(enc,MetadataMapSize)
            if mapsize && mapsize[0] && mapsize[0]>0
              sqwidth  = mapsize[0]
              sqheight = (mapsize[1].length*1.0/mapsize[0]).ceil
              for i in 0...sqwidth
                for j in 0...sqheight
                  if mapsize[1][i+j*sqwidth,1].to_i>0
                    points[mappos[1]+i+(mappos[2]+j)*mapwidth] = true
                  end
                end
              end
            else
              points[mappos[1]+mappos[2]*mapwidth] = true
            end
          end
        end
      end
    end
    # Draw coloured squares on each square of the region map with a nest
    pointcolor   = Color.new(0,248,248)
    pointcolorhl = Color.new(192,248,248)
    sqwidth = PokemonRegionMap_Scene::SQUAREWIDTH
    sqheight = PokemonRegionMap_Scene::SQUAREHEIGHT
    for j in 0...points.length
      if points[j]
        x = (j%mapwidth)*sqwidth
        x += (Graphics.width-@sprites["areamap"].bitmap.width)/2
        y = (j/mapwidth)*sqheight
        y += (Graphics.height-48-@sprites["areamap"].bitmap.height)/2
        @sprites["areahighlight"].bitmap.fill_rect(x,y,sqwidth,sqheight,pointcolor)
        if j-mapwidth<0 || !points[j-mapwidth]
          @sprites["areahighlight"].bitmap.fill_rect(x,y-2,sqwidth,2,pointcolorhl)
        end
        if j+mapwidth>=points.length || !points[j+mapwidth]
          @sprites["areahighlight"].bitmap.fill_rect(x,y+sqheight,sqwidth,2,pointcolorhl)
        end
        if j%mapwidth==0 || !points[j-1]
          @sprites["areahighlight"].bitmap.fill_rect(x-2,y,2,sqheight,pointcolorhl)
        end
        if (j+1)%mapwidth==0 || !points[j+1]
          @sprites["areahighlight"].bitmap.fill_rect(x+sqwidth,y,2,sqheight,pointcolorhl)
        end
      end
    end
    # Set the text
# Changes the color of the text, to the one used in BW
    base   = Color.new(255,255,255)
    shadow = Color.new(165,165,173)
    textpos = []
    if points.length==0
      pbDrawImagePositions(overlay,[
         [sprintf("Graphics/Pictures/Pokedex/overlay_areanone"),108,148]
      ])
# Changes the postion of the Area unknown text, as well as the color of it, 
# to the one used in BW
      textpos.push([_INTL("Area unknown"),Graphics.width/2,150,2,base,shadow])
    end
# Minor changes to the color of the text, to mimic the one used in BW
    textpos.push([pbGetMessage(MessageTypes::RegionNames,@region),88,3,2,Color.new(255,255,255),Color.new(115,115,115)])
    textpos.push([_INTL("{1}'s area",PBSpecies.getName(@species)),
       Graphics.width/1.4,3,2,Color.new(255,255,255),Color.new(115,115,115)])
    pbDrawTextPositions(overlay,textpos)
  end

  def drawPageForms
# Sets the Scrolling Background of the Forms Page, as well as the overlay on top of it
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/bg_forms"))
    @sprites["infoverlay"].setBitmap(_INTL("Graphics/Pictures/Pokedex/forms_overlay"))
    overlay = @sprites["overlay"].bitmap
# Changes the color of the text, to the one used in BW
    base   = Color.new(255,255,255)
    shadow = Color.new(165,165,173)
    # Write species and form name
    formname = ""
    for i in @available
      if i[1]==@gender && i[2]==@form
        formname = i[0]; break
      end
    end
    textpos = [
       [PBSpecies.getName(@species),Graphics.width/2,Graphics.height-312,2,base,shadow],
       [formname,Graphics.width/2,Graphics.height-280,2,base,shadow],
    ]
    # Draw all text
    pbDrawTextPositions(overlay,textpos)
  end

  def pbGoToPrevious
    newindex = @index
    while newindex>0
      newindex -= 1
      if $Trainer.seen[@dexlist[newindex][0]]
        @index = newindex
        break
      end
    end
  end

  def pbGoToNext
    newindex = @index
    while newindex<@dexlist.length-1
      newindex += 1
      if $Trainer.seen[@dexlist[newindex][0]]
        @index = newindex
        break
      end
    end
  end

  def pbChooseForm
    index = 0
    for i in 0...@available.length
      if @available[i][1]==@gender && @available[i][2]==@form
        index = i
        break
      end
    end
    oldindex = -1
    loop do
      if oldindex!=index
        $Trainer.formlastseen[@species][0] = @available[index][1]
        $Trainer.formlastseen[@species][1] = @available[index][2]
        pbUpdateDummyPokemon
        drawPage(@page)
        @sprites["uparrow"].visible   = (index>0)
        @sprites["downarrow"].visible = (index<@available.length-1)
        oldindex = index
      end
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::UP)
        pbPlayCursorSE
        index = (index+@available.length-1)%@available.length
      elsif Input.trigger?(Input::DOWN)
        pbPlayCursorSE
        index = (index+1)%@available.length
      elsif Input.trigger?(Input::B)
        pbPlayCancelSE
        break
      elsif Input.trigger?(Input::C)
        pbPlayDecisionSE
        break
      end
    end
    @sprites["uparrow"].visible   = false
    @sprites["downarrow"].visible = false
  end

  def pbScene
    pbPlayCrySpecies(@species,@form)
    loop do
      Graphics.update
      Input.update
      pbUpdate
      dorefresh = false
      if Input.trigger?(Input::A)
        pbSEStop
        pbPlayCrySpecies(@species,@form) if @page==1
      elsif Input.trigger?(Input::B)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::C)
        if @page==2   # Area
#          dorefresh = true
        elsif @page==3   # Forms
          if @available.length>1
            pbPlayDecisionSE
            pbChooseForm
            dorefresh = true
          end
        end
      elsif Input.trigger?(Input::UP)
        oldindex = @index
        pbGoToPrevious
        if @index!=oldindex
          pbUpdateDummyPokemon
          @available = pbGetAvailableForms
          pbSEStop
          (@page==1) ? pbPlayCrySpecies(@species,@form) : pbPlayCursorSE
          dorefresh = true
        end
      elsif Input.trigger?(Input::DOWN)
        oldindex = @index
        pbGoToNext
        if @index!=oldindex
          pbUpdateDummyPokemon
          @available = pbGetAvailableForms
          pbSEStop
          (@page==1) ? pbPlayCrySpecies(@species,@form) : pbPlayCursorSE
          dorefresh = true
        end
      elsif Input.trigger?(Input::LEFT)
        oldpage = @page
        @page -= 1
        @page = 1 if @page<1
        @page = 3 if @page>3
        if @page!=oldpage
          pbPlayCursorSE
          dorefresh = true
        end
      elsif Input.trigger?(Input::RIGHT)
        oldpage = @page
        @page += 1
        @page = 1 if @page<1
        @page = 3 if @page>3
        if @page!=oldpage
          pbPlayCursorSE
          dorefresh = true
        end
      end
      if dorefresh
        drawPage(@page)
      end
    end
    return @index
  end

  def pbSceneBrief
    pbPlayCrySpecies(@species,@form)
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::A)
        pbSEStop
        pbPlayCrySpecies(@species,@form)
      elsif Input.trigger?(Input::B)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::C)
        pbPlayDecisionSE
        break
      end
    end
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