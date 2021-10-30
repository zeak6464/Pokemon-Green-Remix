AverageLevel = 30

def rateDifficult
  return true if rand(100)<75
  return false
end

class PokemonSystem
  attr_accessor :difficulty
  alias dif_ini initialize
  def initialize
    # Old
    dif_ini
    @difficulty = 0
  end
end

class PokeBattle_Trainer
  alias diff_skill skill
  def skill
    ret=diff_skill
    # Difficulty = 0 (Do nothing)
    case $PokemonSystem.difficulty
    when 1
      case ret
      when 0
        ret += 5
      when PBTrainerAI.minimumSkill...PBTrainerAI.mediumSkill
        ret = PBTrainerAI.mediumSkill
      when PBTrainerAI.mediumSkill...PBTrainerAI.highSkill
        ret = PBTrainerAI.highSkill
      else
        ret = PBTrainerAI.bestSkill
      end
    when 2
      case ret
      when 0
        ret = PBTrainerAI.mediumSkill
      when PBTrainerAI.minimumSkill...PBTrainerAI.mediumSkill
        ret = PBTrainerAI.highSkill
      when PBTrainerAI.mediumSkill...PBTrainerAI.highSkill
        ret = PBTrainerAI.bestSkill
      else
        ret = PBTrainerAI.bestSkill
      end
    end
    return ret
  end
end

Events.onTrainerPartyLoad += proc { |_sender, e|
   if e[0] 
     trainer=e[0][0] 
     items=e[0][1]   
     party=e[0][2]
     case $PokemonSystem.difficulty
     when 1
       levels=0
       types=[]
       stats=[]
       (0...party.length).each{|i|
       types.push(party[i].type1)
       types.push(party[i].type2)
       bst=(party[i].baseStats).dup
       bst=bst.inject{|sum,x| sum + x }
       stats.push(bst)
       levelchange=party[i].level/10.floor
       levelchange*=2 if levelchange<3
       party[i].level+=levelchange
       party[i].level+=rand(3)
       party[i].level=MAXIMUM_LEVEL  if party[i].level>MAXIMUM_LEVEL 
       party[i].level=1 if party[i].level<1
       party[i].calcStats
       levels+=party[i].level
       movelist=party[i].getMoveList
       moves=[]
       (0...movelist.length).each{|k| (0...party[i].moves.length).each{|j|
       moves.push(party[i].moves[j]) if movelist[k][1]==party[i].moves[j] }}
       moves.uniq!
       party[i].resetMoves if moves.length==3 }
       # Add another strong pokemon
       levels=levels/party.length
       if party.length<6 && levels>AverageLevel && rateDifficult
         count = Hash.new(0)
         types.each {|word| count[word] += 1}
         # Type to look for
         type=(count.sort_by {|k,v| v }.last) 
         # BST to look for (number)
         bst=(stats.inject{|sum,x| sum + x })/party.length  
         acceptable_pokes=[]
         backup_pokes=[]
         scn=PokemonPokedex_Scene.new
         # Get all pokemon in region
         dex=scn.pbGetDexList
         (0...dex.length).each{|i|
         type1 = pbGetSpeciesData(dex[i][0],dex[i][4],SpeciesType1)
         type2 = pbGetSpeciesData(dex[i][0],dex[i][4],SpeciesType2)
         curstats = pbGetSpeciesData(dex[i][0],dex[i][4],SpeciesBaseStats)
         curstats=(curstats.inject{|sum,x| sum + x })
         if (-20..20).include?(bst-curstats)
           if type1==type || type2==type
             # Pokemon's number
             acceptable_pokes.push(dex[i][0]) 
           else
             backup_pokes.push(dex[i][0])
           end
         end }
         # Remove legendaries here, has to be specified
         if acceptable_pokes.length==0
           if backup_pokes.length>0
             p=PokeBattle_Pokemon.new(backup_pokes[rand(backup_pokes.length)],levels,trainer)
             party.push(p)
           end
         else
           p=PokeBattle_Pokemon.new(acceptable_pokes[rand(acceptable_pokes.length)],levels,trainer)
           party.push(p)
         end
       end
     when 2
       levels=0
       types=[]
       stats=[]
       (0...party.length).each{|i|
       types.push(party[i].type1)
       types.push(party[i].type2)
       bst=(party[i].baseStats).dup
       bst=bst.inject{|sum,x| sum + x }
       stats.push(bst)
       levelchange=party[i].level/10.floor
       if levelchange<6
         levelchange*=2 
         levelchange+=rand(3)
       else
         levelchange+=rand(5)
       end
       party[i].level+=levelchange         
       party[i].level=MAXIMUM_LEVEL if party[i].level>MAXIMUM_LEVEL
       party[i].level=1 if party[i].level<1
       party[i].calcStats
       levels+=party[i].level
       movelist=party[i].getMoveList
       moves=[]
       (0...movelist.length).each{|k| (0...party[i].moves.length).each{|j|
       moves.push(party[i].moves[j]) if movelist[k][1]==party[i].moves[j] }}
       moves.uniq!
       party[i].resetMoves if moves.length==4 }
       # Add another strong pokemon
       levels=levels/party.length         
       if party.length<6 && rateDifficult
         count = Hash.new(0)
         types.each {|word| count[word] += 1}
         type=(count.sort_by { |k,v| v }.last) #Type to look for
         bst=(stats.inject{|sum,x| sum + x })/party.length  #BST to look for
         acceptable_pokes=[]
         backup_pokes=[]
         scn=PokemonPokedex_Scene.new
         dex=scn.pbGetDexList #Get all pokemon in region
         count = Hash.new(0)
         types.each {|word| count[word] += 1}
         # Type to look for
         type=(count.sort_by {|k,v| v }.last) 
         # BST to look for (number)
         bst=(stats.inject{|sum,x| sum + x })/party.length  
         acceptable_pokes=[]
         backup_pokes=[]
         scn=PokemonPokedex_Scene.new
         # Get all pokemon in region
         dex=scn.pbGetDexList
         (0...dex.length).each{|i|
         type1 = pbGetSpeciesData(dex[i][0],dex[i][4],SpeciesType1)
         type2 = pbGetSpeciesData(dex[i][0],dex[i][4],SpeciesType2)
         curstats = pbGetSpeciesData(dex[i][0],dex[i][4],SpeciesBaseStats)
         curstats=(curstats.inject{|sum,x| sum + x })
         if (-20..20).include?(bst-curstats)
           if type1==type || type2==type
             # Pokemon's number
             acceptable_pokes.push(dex[i][0]) 
           else
             backup_pokes.push(dex[i][0])
           end
         end }
         # Remove legendaries here, has to be specified
         if acceptable_pokes.length==0
           if backup_pokes.length>0
             p=PokeBattle_Pokemon.new(backup_pokes[rand(backup_pokes.length)],levels,trainer)
             party.push(p)
           end
         else
           p=PokeBattle_Pokemon.new(acceptable_pokes[rand(acceptable_pokes.length)],levels,trainer)
           party.push(p)
         end
         if party.length<6 && rand(100)<50
           if acceptable_pokes.length==0
             if backup_pokes.length>0
               p=PokeBattle_Pokemon.new(backup_pokes[rand(backup_pokes.length)],levels,trainer)
               party.push(p)
             end
           else
             p=PokeBattle_Pokemon.new(acceptable_pokes[rand(acceptable_pokes.length)],levels,trainer)
             party.push(p)
           end
         end
       end
     end
   end
}