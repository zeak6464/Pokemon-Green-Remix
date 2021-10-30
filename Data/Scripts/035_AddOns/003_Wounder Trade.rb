=begin
*** Wonder Trade Script by Black Eternity ***
This script is to mimic Wonder Trade from an offline perspective.
THERE IS NO ONLINE CAPABILITIES OF THIS SCRIPT,
ALL CALCULATIONS ARE DONE INTERNALLY.

To call the script like normal and have ALL Pokemon trade-able, use the following.
    pbWondertrade(1,[],[])

Black listed Pokemon are to be added to the Exceptions arrays.
  Except is the list of pokemon the player is forbidden to trade.
    Here the player cannot trade any of the following.
      pbWonderTrade(1,[:PIKACHU,:SQUIRTLE,:CHARMANDER,;BULBASAUR],[])
    
  Except2 is the list of pokemon the player is forbidden to receive.
    Here the player cannot receive any of the following.
      pbWonderTrade(1,[],[:MEWTWO,;MEW,;DEOXYS])



The first parameter is the minimum allowed Level of the Pokemon to be traded.
For example, you can not trade a Pokemon through Wonder Trade unless its level
is greater than or equal to specified level.

    pbWonderTrade(40,[:SQUIRTLE,:CHARMANDER,:BULBASAUR],[:MEWTWO,:MEW,:DEOXYS])
    *** Only pokemon over level 40 can be traded, you cannot trade starters.
    *** You cannot receive these legendaries.
    
The fourth parameter, which has recently replaced mej71's "hardobtain"
is called "rare", this parameter developed also by mej71, will use
the Pokemon's rareness and filter the results depending on its values.

** Rareness is turned on by default, if you wish to disable it, call the
    function accordingly.
    
    pbWonderTrade(10,[:SQUIRTLE],[:CHARMANDER,:BULBASAUR],false)
    ** Only Pokemon over level 10, cannot trade Squirtle, cannot
    ** recieve Charmander or Bulbasaur, Rareness disabled.

It is up to you to use it how you wish, credits will be appreciated.
=end

# List of Randomly selected Trainer Names
# These are just names taken from a generator, add custom or change to
# whatever you desire.
RandTrainerNames=[
"Clarence",
"James",
"Keith",
"Matthew",
"Jeremy",
"Louis",
"Albert",
"Emily",
"Aaron",
"Frances",
"Steve",
"Joan",
"Dorothy",
"Jeffrey",
"Alice",
"Sara",
"David",
"Anne",
"Shirley",
"Henry",
"Carolyn",
"Christopher",
"Christina",
"Ronald",
"Randy",
"Nancy",
"Virginia",
"Donna",
"William",
"Jacqueline",
"Catherine",
"Jesse",
"Roger",
"Denise",
"Ashley",
"Maria",
"Todd",
"Helen",
"Teresa",
"Fred",
"Annie",
"Rachel",
"Kathleen",
"Marie",
"Scott",
"Phillip",
"Craig",
"Diane",
"Beverly",
"Lisa",
"Mildred",
"Lois",
"Douglas",
"Deborah",
"Phyllis",
"Melissa",
"Laura",
"Stephanie",
"Ernest",
"Evelyn",
"Irene",
"Brandon",
"Jean",
"Sandra",
"Linda",
"Raymond",
"Kathryn",
"Harry",
"Gary",
"Katherine",
"Theresa",
"Howard",
"Stephen",
"Russell",
"Louisel",
"Bobby",
"Susan",
"Martin",
"Harold",
"Andrea",
"Sharon",
"Juan",
"Rose",
"Lori",
"Dorist",
"Joseph",
"Charles",
"Donald",
"Arthur",
"Janice",
"Jack",
"Wanda",
"Ralph",
"Christine",
"Betty",
"Julia",
"Michelle",
"Kevin",
"James",
"Michael",
"Kathy"
]

# List of randomly selected Pokemon Nicknames
# These are just names taken from a generator, add custom or change to
# whatever you desire.
RandPokeNick=[
"Delev",
"Aelask",
"Arik",
"Thach",
"Kroaal",
"Gez",
"Adaetyra",
"Aroan",
"Jaua",
"Cu",
"Kes",
"Ini",
"Rairim",
"Chior",
"Zeam",
"Kaimyn",
"Trou",
"Anaz",
"Taelah",
"Tok",
"Foalyua",
"Kransela",
"Jendal",
"Cimor",
"Birev",
"Iseaz",
"Mim",
"Arily",
"Susk",
"Naer",
"Ennn",
"Mea",
"Anaz",
"Xoken",
"Binn",
"Paed",
"Dandara",
"Cova",
"Aeran",
"Gom",
"Bancath",
"Elish",
"Lex",
"Kiz",
"Tullas",
"Idaithael",
"Nonc",
"Krairoa",
"Talanen",
"Chyar",
"Drakinoa",
"Koul",
"Cikr",
"Doukl",
"Pydae",
"Sokl",
"Galas",
"Voav",
"Ade",
"Jeal",
"Drym",
"Beary",
"Cam",
"Elyd",
"Alaev",
"Zissal",
"Neteth",
"Teaes",
"Famah",
"Jylyath",
"Dod",
"Idorroa",
"Sicha",
"Ca",
"Deal",
"Kro",
"Ziz",
"Thom",
"Dam",
"Souk",
"Sandren",
"Sytr",
"Drumri",
"Isi",
"Basri",
"Jell",
"Araphorn",
"Kaesselai",
"Resh",
"Fizarus"
]


def pbWondertrade(lvl,except=[],except2=[],rare=true)
        for i in 0...except.length # Gets ID of pokemon in exception array
                except[i]=getID(PBSpecies,except[i]) if !except[i].is_a?(Integer)
        end
        for i in 0...except2.length # Gets ID of pokemon in exception array
                except2[i]=getID(PBSpecies,except2[i]) if !except2[i].is_a?(Integer)
        end
        except+=[]
        chosen=pbChoosePokemon(1,2, # Choose eligable pokemon
        proc {
        |poke| !poke.isEgg? && !(poke.isShadow?) && # No Eggs, No Shadow Pokemon
        (poke.level>=lvl) && !(except.include?(poke.species)) # None under "lvl", no exceptions.
        })
        # The following excecption fields are for hardcoding the blacklisted pokemon
        # without adding them in the events.
        #except+=[]
        except2+=[]
        if pbGet(1)>=0
                species=0
                while (species==0) # Loop Start
                        species=rand(PBSpecies.maxValue)+1
                        # Redo the loop if the species is an exception.
                        species=0 if except2.include?(species)
                        # species=0 if (except.include?(species) && except2.include?(species))
                        # use this above line instead if you wish to neither receive pokemon that YOU
                        # cannot trade.
                end
                tname=RandTrainerNames[rand(RandTrainerNames.size)] # Randomizes Trainer Names
                pname=RandPokeNick[rand(RandPokeNick.size)] # Randomizes Pokemon Nicknames
                pbStartTrade(pbGet(1),species,pname,tname) # Starts the trade
        else
                return -1
        end
      end
      
      RandTrainerNames=[
"Clarence"
]

# List of randomly selected Pokemon Nicknames
# These are just names taken from a generator, add custom or change to
# whatever you desire.
RandPokeNick=[
"Delev",
"Aelask",
"Arik",
"Thach",
"Kroaal",
"Gez",
"Adaetyra",
"Aroan",
"Jaua",
"Cu",
"Kes",
"Ini",
"Rairim",
"Chior",
"Zeam",
"Kaimyn",
"Trou",
"Anaz",
"Taelah",
"Tok",
"Foalyua",
"Kransela",
"Jendal",
"Cimor",
"Birev",
"Iseaz",
"Mim",
"Arily",
"Susk",
"Naer",
"Ennn",
"Mea",
"Anaz",
"Xoken",
"Binn",
"Paed",
"Dandara",
"Cova",
"Aeran",
"Gom",
"Bancath",
"Elish",
"Lex",
"Kiz",
"Tullas",
"Idaithael",
"Nonc",
"Krairoa",
"Talanen",
"Chyar",
"Drakinoa",
"Koul",
"Cikr",
"Doukl",
"Pydae",
"Sokl",
"Galas",
"Voav",
"Ade",
"Jeal",
"Drym",
"Beary",
"Cam",
"Elyd",
"Alaev",
"Zissal",
"Neteth",
"Teaes",
"Famah",
"Jylyath",
"Dod",
"Idorroa",
"Sicha",
"Ca",
"Deal",
"Kro",
"Ziz",
"Thom",
"Dam",
"Souk",
"Sandren",
"Sytr",
"Drumri",
"Isi",
"Basri",
"Jell",
"Araphorn",
"Kaesselai",
"Resh",
"Fizarus"
]


def pbWondertrader(lvl,except=[],except2=[],rare=true)
        for i in 0...except.length # Gets ID of pokemon in exception array
                except[i]=getID(PBSpecies,except[i]) if !except[i].is_a?(Integer)
        end
        for i in 0...except2.length # Gets ID of pokemon in exception array
                except2[i]=getID(PBSpecies,except2[i]) if !except2[i].is_a?(Integer)
        end
        except+=[]
        chosen=pbChoosePokemon(1,2, # Choose eligable pokemon
        proc {
        |poke| !poke.isEgg? && !(poke.isShadow?) && # No Eggs, No Shadow Pokemon
        (poke.level>=lvl) && !(except.include?(poke.species)) # None under "lvl", no exceptions.
        })
        # The following excecption fields are for hardcoding the blacklisted pokemon
        # without adding them in the events.
        #except+=[]
        except2+=[]
        if pbGet(1)>=0
                species=0
                while (species==0) # Loop Start
                        species=rand(PBSpecies.maxValue)+1
                        # Redo the loop if the species is an exception.
                        species=0 if except2.include?(species)
                        # species=0 if (except.include?(species) && except2.include?(species))
                        # use this above line instead if you wish to neither receive pokemon that YOU
                        # cannot trade.
                end
                tname=RandTrainerNames[rand(RandTrainerNames.size)] # Randomizes Trainer Names
                pname=RandPokeNick[rand(RandPokeNick.size)] # Randomizes Pokemon Nicknames
                pbStartTrade(pbGet(1),species,pname,tname) # Starts the trade
        else
                return -1
        end
end