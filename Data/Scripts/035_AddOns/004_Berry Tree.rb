################################################################################
#                                                                              #
#                       Berry Tree From Galar Script                           #
#                            By #Not Imortant                                  #
#                          For Essentials v17.2                                #
#                                 v 1.1.0                                      #
#                           Complete plug-n-play                               #
#                                                                              #
################################################################################
# USAGE:
# Call with pbBerryTree
# Remember to credit me!
################################################################################
#                                 Scripts                                      #
################################################################################
def pbshake
  if $game_variables[800] == 0
        Kernel.pbReceiveItem(rand(389..452))
        Kernel.pbMessage("There are berries on the ground, keep shaking?")
      command=Kernel.pbShowCommands(nil,[
          _INTL("No"),
          _INTL("Yes")
          ],command)
          case command
         when -1
            Kernel.pbMessage("Left it alone...")
          when 0
            Kernel.pbMessage("Left it alone...")
          when 1
            $game_variables[800]=rand(1..3)
            pbshake
			end
      elsif $game_variables[800] == 1
        Kernel.pbMessage("Other pokemon took the berries left on the tree away...")
        $game_variables[802]= $game_variables[801] + 86400
      elsif $game_variables[800] == 2 
        Kernel.pbMessage("Looks like a Pokemon came out of the Tree!")
        pbEncounter(EncounterTypes::Land)
        $game_variables[802]= $game_variables[801] + 86400
      elsif $game_variables[800] == 3
        Kernel.pbReceiveItem(rand(389..452))
        Kernel.pbMessage("There are berries on the ground, keep shaking?")
      command=Kernel.pbShowCommands(nil,[
          _INTL("No"),
          _INTL("Yes")
          ],command)
          case command
         when -1
            Kernel.pbMessage("Left it alone...")
          when 0
            Kernel.pbMessage("Left it alone...")
          when 1
            $game_variables[800]=rand(1..3)
            pbshake
          end
        end
      end
      
    
################################################################################
#                        Script you call                                       #
################################################################################
def pbBerryTree
    $game_variables[800]=0
    pbshake
  end


def pbBerryTreeTest
  if $DEBUG
    pbEncounter(EncounterTypes::Land)
  end
end
################################################################################
#                          By #Not Important  & Zeak6464                       #
################################################################################