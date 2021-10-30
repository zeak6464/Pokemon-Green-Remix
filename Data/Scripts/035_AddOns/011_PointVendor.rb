def pbSpecialMart
        Kernel.pbMessage(_INTL("Welcome to the PokeMartPoints Shop , you gain points by buying items from my co-workers."))
  loop do
    command=Kernel.pbShowCommandsWithHelp(nil,
       [_INTL(" 10 Rare Candy"),
       _INTL(" 20 REVIVE"),
       _INTL(" 30 EXPSHARE ALL"),
       _INTL("Exit")],
       [_INTL("A item that helps level up."),
       _INTL("Revives one pokemon."),
       _INTL("EXP Share ALL."),
       _INTL("Are you finished shopping?")],-1
    )
    if command==0 # Buy a thing
      if  $PokemonGlobal.martpoints>=10
        $PokemonGlobal.martpoints-=10
        Kernel.pbReceiveItem(:RARECANDY)
      else
        Kernel.pbMessage(_INTL("I'm sorry but you don't have enough special money."))
      end
      end
    if command==1 # Buy Another thing
      if  $PokemonGlobal.martpoints>=20
        $PokemonGlobal.martpoints-=20
        Kernel.pbReceiveItem(:REVIVE)
      else
        Kernel.pbMessage(_INTL("I'm sorry but you don't have enough special money."))
      end
      end
    if command==2 # Buy A better thing
      if  $PokemonGlobal.martpoints>=20
        $PokemonGlobal.martpoints-=20
        Kernel.pbReceiveItem(:EXPALL)
      else
        Kernel.pbMessage(_INTL("I'm sorry but you don't have enough special money."))
      end
    end
        Kernel.pbMessage(_INTL("Please come again!"))
      break
    end
  end
  