module PBZMove
  # Z Moves compatibility
  
  KEY_ZCRYSTAL = 0
  HELD_ZCRYSTAL = 1
  REQ_TYPE = 2
  REQ_MOVE = 3
  REQ_SPECIES = 4
  ZMOVE = 5
end 


def pbCompileZMoveCompatibility
  records   = []
  
  pbCompilerEachPreppedLine("PBS/zmovescomp.txt") { |line,lineno|
    record = []
    lineRecord = pbGetCsvRecord(line,lineno,[0,"eeEEEe",
       PBItems, # Z-Crystal in the bag
       PBItems, # Z-Crystal held by the Pokémon
       PBTypes, # Move type required for the Z-Move 
       PBMoves, # Specific move required for the Z-Move 
       PBSpecies, # Specific species required for the Z-Move
       PBMoves]) # The Z-Move
    if !lineRecord[PBZMove::REQ_TYPE] && !lineRecord[PBZMove::REQ_MOVE] && !lineRecord[PBZMove::REQ_SPECIES]
      raise _INTL("Z-Moves are specific to either a type of moves, or a pair of a required move and species (you need to specify a type, or a move + species).\r\n{1}",FileLineData.linereport)
    end
    if lineRecord[PBZMove::REQ_TYPE] && lineRecord[PBZMove::REQ_MOVE] && lineRecord[PBZMove::REQ_SPECIES]
      raise _INTL("Z-Moves are specific to either a type of moves, or a pair of a required move and species (do not specifiy a type + a move + a species).\r\n{1}",FileLineData.linereport)
    end
    records.push(lineRecord)
  }
  
  save_data(records,"Data/zmovescomp.dat")
end 


def pbSaveZMoveCompatibility
  zmovecomps = pbLoadZMoveCompatibility
  
  return if !zmovecomps
  File.open("PBS/zmovescomp.txt","wb") { |f|
    f.write("\# "+_INTL("See the documentation on the wiki to learn how to edit this file."))
    f.write("\r\n")
    zmovecomps.each { |comp| 
      f.write(sprintf("%s,%s,%s,%s,%s,%s",
         getConstantName(PBItems,comp[PBZMove::KEY_ZCRYSTAL]),
         getConstantName(PBItems,comp[PBZMove::HELD_ZCRYSTAL]),
         (comp[PBZMove::REQ_TYPE] ? getConstantName(PBTypes,comp[PBZMove::REQ_TYPE]) : ""),
         (comp[PBZMove::REQ_MOVE] ? getConstantName(PBMoves,comp[PBZMove::REQ_MOVE]) : ""),
         (comp[PBZMove::REQ_SPECIES] ? getConstantName(PBSpecies,comp[PBZMove::REQ_SPECIES]) : ""),
         getConstantName(PBMoves,comp[PBZMove::ZMOVE])
      ))
      f.write("\r\n")
    }
  }
end 


def pbLoadZMoveCompatibility
  return load_data("Data/zmovescomp.dat")
end 


# This is for ItemHandlers + the use of PokeBattle_ZMove.  
def pbGetZMoveDataIfCompatible(pokemon, zcrystal, basemove = nil)
  # basemove = the base move to be transformed. For use in battle.
  # zcrystal is either a Key-item crystal (returns true to pbIsZCrystal2?) 
  # or a held crystal (returns true to pbIsZCrystal?) 
  return nil if !pbIsZCrystal?(zcrystal) && !pbIsZCrystal2?(zcrystal)
  
  zmovecomps = pbLoadZMoveCompatibility
  
  zmovecomps.each { |comp|
    next if comp[PBZMove::KEY_ZCRYSTAL] != zcrystal && comp[PBZMove::HELD_ZCRYSTAL] != zcrystal
    
    reqmove = false
    reqtype = false
    reqspecies = false
    
    if comp[PBZMove::REQ_TYPE]
      # If a type is required, then check if it has that type.
      if basemove
        reqtype=true if basemove.type==comp[PBZMove::REQ_TYPE]
      else 
        for move in pokemon.moves
          reqtype=true if move.type==comp[PBZMove::REQ_TYPE]
        end 
      end
    else 
      # If no type is required, then it's ok.
      reqtype = true 
    end 
    
    if comp[PBZMove::REQ_MOVE]
      # If a move is required, then check if the Pokémon has that move.
      if basemove
        reqmove=true if basemove.id==comp[PBZMove::REQ_MOVE]
      else 
        for move in pokemon.moves
          reqmove=true if move.id==comp[PBZMove::REQ_MOVE]
        end
      end 
    else 
      # If no move is required, then it's ok.
      reqmove = true
    end 
    
    if comp[PBZMove::REQ_SPECIES]
      # If a species is required, then check if the Pokémon has the right species.
      reqspecies = true if comp[PBZMove::REQ_SPECIES] == pokemon.fSpecies
    else 
      reqspecies = true 
    end 
    
    return comp if reqtype && reqmove && reqspecies
  }
  return nil 
end 

