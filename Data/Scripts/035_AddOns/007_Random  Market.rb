#Randomize items in mart
alias random_pbPokemonMart pbPokemonMart
def pbPokemonMart(stock,speech=nil,cantsell=false)
  # Switch that turns on the Random Market 
  if $game_switches[799]==true
    for i in 0...stock.length
        stock[i]=rand(PBItems.maxValue)
        item=getID(PBItems, stock[i])
        #Last Item it randomizes from
        if pbIsKeyItem?(item) || pbIsHiddenMachine?(item) || pbIsMail?(item)
        next
        end
      end
    end
  return random_pbPokemonMart(stock,speech,cantsell)
end