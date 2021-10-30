#===============================================================================
# * PokeMartPoints Points by BroskiPlays
#===============================================================================
# * Global Metadata
#===============================================================================
class PokemonGlobalMetadata
  attr_writer :martpoints

  def martpoints
      @martpoints ||= 0
    return @martpoints
  end
end

#===============================================================================
# * Point Card Item
#===============================================================================
ItemHandlers::UseFromBag.add(:POINTCARD,proc{|item|
   Kernel.pbMessage(_INTL("PokeMart Points:\n{1}",$PokemonGlobal.martpoints))
   next 1 # Continue
})

ItemHandlers::UseInField.add(:POINTCARD,proc{|item|
   Kernel.pbMessage(_INTL("PokeMart Points:\n{1}",$PokemonGlobal.martpoints))
   next 1 # Continue
})