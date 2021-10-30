begin
PluginManager.register({
  :name    => "Cable Club",
  :version => "1.4",
  :link    => "https://www.pokecommunity.com/showthread.php?t=449364",
  :credits => ["mGriffin","Khaikaa","Vendily"]
})
rescue
  # not v18
end

module CableClub
  HOST = "localhost"
  PORT = 9999
end

# TODO: Automatically timeout.

# Returns false if an error occurred.
def pbCableClub
  if $Trainer.party.length == 0
    Kernel.pbMessage(_INTL("I'm sorry, you must have a Pokémon to enter the Cable Club."))
    return
  end
  msgwindow = Kernel.pbCreateMessageWindow()
  begin
    Kernel.pbMessageDisplay(msgwindow, _ISPRINTF("What's the ID of the trainer you're searching for? (Your ID: {1:05d})\\^",$Trainer.publicID($Trainer.id)))
    partner_trainer_id = ""
    loop do
      partner_trainer_id = Kernel.pbFreeText(msgwindow, partner_trainer_id, false, 5)
      return if partner_trainer_id.empty?
      break if partner_trainer_id =~ /^[0-9]{5}$/
      Kernel.pbMessageDisplay(msgwindow, _INTL("I'm sorry, {1} is not a trainer ID.", partner_trainer_id))
    end
    # HINT: Startup/Cleanup required for Khaikaa's v17 for some reason.
    begin
      wsadata = "\0" * 1024 # Hope this is big enough, I don't have a compiler to sizeof(WSADATA) on...
      res = Win32API.new("ws2_32", "WSAStartup", "IP", "I").call(0x0202, wsadata)
      case res
      when 0; CableClub::connect_to(msgwindow, partner_trainer_id)
      else; raise Connection::Disconnected.new("winsock error")
      end
    ensure
      Win32API.new("ws2_32", "WSACleanup", "", "").call()
    end
    raise Connection::Disconnected.new("disconnected")
  rescue Connection::Disconnected => e
    case e.message
    when "disconnected"
      Kernel.pbMessageDisplay(msgwindow, _INTL("Thank you for using the Cable Club. We hope to see you again soon."))
      return true
    when "invalid party"
      Kernel.pbMessageDisplay(msgwindow, _INTL("I'm sorry, your party contains Pokémon not allowed in the Cable Club."))
      return false
    when "peer disconnected"
      Kernel.pbMessageDisplay(msgwindow, _INTL("I'm sorry, the other trainer has disconnected."))
      return true
    else
      Kernel.pbMessageDisplay(msgwindow, _INTL("I'm sorry, the Cable Club server has malfunctioned!"))
      return false
    end
  rescue Errno::ECONNREFUSED
    Kernel.pbMessageDisplay(msgwindow, _INTL("I'm sorry, the Cable Club server is down at the moment."))
    return false
  rescue
    pbPrintException($!)
    Kernel.pbMessageDisplay(msgwindow, _INTL("I'm sorry, the Cable Club has malfunctioned!"))
    return false
  ensure
    Kernel.pbDisposeMessageWindow(msgwindow)
  end
end

module CableClub
  def self.pokemon_order(client_id)
    case client_id
    when 0; [0, 1, 2, 3]
    when 1; [1, 0, 3, 2]
    else; raise "Unknown client_id: #{client_id}"
    end
  end

  def self.pokemon_target_order(client_id)
    case client_id
    when 0..1; [1, 0, 3, 2]
    else; raise "Unknown client_id: #{client_id}"
    end
  end

  def self.connect_to(msgwindow, partner_trainer_id)
    pbMessageDisplayDots(msgwindow, _INTL("Connecting"), 0)
    Connection.open(HOST, PORT) do |connection|
      state = :await_server
      last_state = nil
      client_id = 0
      partner_name = nil
      partner_party = nil
      frame = 0
      activity = nil
      seed = nil
      battle_type = nil
      chosen = nil
      partner_chosen = nil

      loop do
        if state != last_state
          last_state = state
          frame = 0
        else
          frame += 1
        end

        Graphics.update
        Input.update
        if Input.press?(Input::B)
          message = case state
            when :await_server; _INTL("Abort connection?\\^")
            when :await_partner; _INTL("Abort search?\\^")
            else; _INTL("Disconnect?\\^")
            end
          Kernel.pbMessageDisplay(msgwindow, message)
          return if Kernel.pbShowCommands(msgwindow, [_INTL("Yes"), _INTL("No")], 2) == 0
        end

        case state
        # Waiting to be connected to the server.
        # Note: does nothing without a non-blocking connection.
        when :await_server
          if connection.can_send?
            connection.send do |writer|
              writer.sym(:find)
              writer.int(partner_trainer_id)
              writer.str($Trainer.name)
              writer.int($Trainer.id)
              write_party(writer)
            end
            state = :await_partner
          else
            pbMessageDisplayDots(msgwindow, _ISPRINTF("Your ID: {1:05d}\\nConnecting",$Trainer.publicID($Trainer.id)), frame)
          end

        # Waiting to be connected to the partner.
        when :await_partner
          pbMessageDisplayDots(msgwindow, _ISPRINTF("Your ID: {1:05d}\\nSearching",$Trainer.publicID($Trainer.id)), frame)
          connection.update do |record|
            case (type = record.sym)
            when :found
              client_id = record.int
              partner_name = record.str
              partner_party = parse_party(record)
              Kernel.pbMessageDisplay(msgwindow, _INTL("{1} connected!", partner_name))
              if client_id == 0
                state = :choose_activity
              else
                state = :await_choose_activity
              end

            else
              raise "Unknown message: #{type}"
            end
          end

        # Choosing an activity (leader only).
        when :choose_activity
          Kernel.pbMessageDisplay(msgwindow, _INTL("Choose an activity.\\^"))
          command = Kernel.pbShowCommands(msgwindow, [_INTL("Single Battle"), _INTL("Double Battle"), _INTL("Trade")], -1)
          case command
          when 0..1 # Battle
            if command == 1 && $Trainer.party.length < 2
              Kernel.pbMessageDisplay(msgwindow, _INTL("I'm sorry, you must have at least two Pokémon to engage in a double battle."))
            elsif command == 1 && partner_party.length < 2
              Kernel.pbMessageDisplay(msgwindow, _INTL("I'm sorry, your partner must have at least two Pokémon to engage in a double battle."))
            else
              connection.send do |writer|
                writer.sym(:battle)
                seed = rand(2**31)
                writer.int(seed)
                battle_type = case command
                  when 0; :single
                  when 1; :double
                  else; raise "Unknown battle type"
                  end
                writer.sym(battle_type)
                writer.int($Trainer.trainertype)
              end
              activity = :battle
              state = :await_accept_activity
            end

            when 2 # Trade
              connection.send do |writer|
                writer.sym(:trade)
              end
              activity = :trade
              state = :await_accept_activity

            else # Cancel
              # TODO: Confirmation box?
              return
            end

        # Waiting for the partner to accept our activity (leader only).
        when :await_accept_activity
          pbMessageDisplayDots(msgwindow, _INTL("Waiting for {1} to accept", partner_name), frame)
          connection.update do |record|
            case (type = record.sym)
            when :ok
              case activity
              when :battle
                trainertype = record.int
                partner = PokeBattle_Trainer.new(partner_name, trainertype)
                (partner.partyID=0) rescue nil # EBDX compat
                do_battle(connection, client_id, seed, battle_type, partner, partner_party)
                state = :choose_activity

              when :trade
                chosen = choose_pokemon
                if chosen >= 0
                  connection.send do |writer|
                    writer.sym(:ok)
                    writer.int(chosen)
                  end
                  state = :await_trade_pokemon
                else
                  connection.send do |writer|
                    writer.sym(:cancel)
                  end
                  connection.discard(1)
                  state = :choose_activity
                end

              else
                raise "Unknown activity: #{activity}"
              end

            when :cancel
              Kernel.pbMessageDisplay(msgwindow, _INTL("I'm sorry, {1} doesn't want to #{activity.to_s}.", partner_name))
              state = :choose_activity

            else
              raise "Unknown message: #{type}"
            end
          end

        # Waiting for the partner to select an activity (follower only).
        when :await_choose_activity
          pbMessageDisplayDots(msgwindow, _INTL("Waiting for {1} to pick an activity", partner_name), frame)
          connection.update do |record|
            case (type = record.sym)
            when :battle
              seed = record.int
              battle_type = record.sym
              trainertype = record.int
              partner = PokeBattle_Trainer.new(partner_name, trainertype)
              (partner.partyID=0) rescue nil # EBDX compat
              # Auto-reject double battles that we cannot participate in.
              if battle_type == :double && $Trainer.party.length < 2
                connection.send do |writer|
                  writer.sym(:cancel)
                end
                state = :await_choose_activity
              else
                Kernel.pbMessageDisplay(msgwindow, _INTL("{1} wants to battle!\\^", partner_name))
                if Kernel.pbShowCommands(msgwindow, [_INTL("Yes"), _INTL("No")], 2) == 0
                  connection.send do |writer|
                    writer.sym(:ok)
                    writer.int($Trainer.trainertype)
                  end
                  do_battle(connection, client_id, seed, battle_type, partner, partner_party)
                else
                  connection.send do |writer|
                    writer.sym(:cancel)
                  end
                  state = :await_choose_activity
                end
              end

            when :trade
              Kernel.pbMessageDisplay(msgwindow, _INTL("{1} wants to trade!\\^", partner_name))
              if Kernel.pbShowCommands(msgwindow, [_INTL("Yes"), _INTL("No")], 2) == 0
                connection.send do |writer|
                  writer.sym(:ok)
                end
                chosen = choose_pokemon
                if chosen >= 0
                  connection.send do |writer|
                    writer.sym(:ok)
                    writer.int(chosen)
                  end
                  state = :await_trade_pokemon
                else
                  connection.send do |writer|
                    writer.sym(:cancel)
                  end
                  connection.discard(1)
                  state = :await_choose_activity
                end
              else
                connection.send do |writer|
                  writer.sym(:cancel)
                end
                state = :await_choose_activity
              end

            else
              raise "Unknown message: #{type}"
            end
          end

        # Waiting for the partner to select a Pokémon to trade.
        when :await_trade_pokemon
          if partner_chosen.nil?
            pbMessageDisplayDots(msgwindow, _INTL("Waiting for {1} to pick a Pokémon", partner_name), frame)
          else
            pbMessageDisplayDots(msgwindow, _INTL("Waiting for {1} to resynchronize", partner_name), frame)
          end

          connection.update do |record|
            case (type = record.sym)
            when :ok
              partner = PokeBattle_Trainer.new(partner_name, $Trainer.trainertype)
              partner_chosen = record.int
              pbHealAll
              partner_party.each{|pkmn| pkmn.heal}
              pkmn = partner_party[partner_chosen]
              abort=$Trainer.ablePokemonCount==1 && $Trainer.party[chosen]==$Trainer.ablePokemonParty[0] && pkmn.isEgg?
              able_party=partner_party.find_all { |p| p && !p.isEgg? && !p.fainted? }
              abort|=able_party.length==1 && pkmn==able_party[0] && $Trainer.party[chosen].isEgg?
              unless abort
                partner_party[partner_chosen] = $Trainer.party[chosen]
                do_trade(chosen, partner, pkmn)
                connection.send do |writer|
                  writer.sym(:update)
                  write_pkmn(writer, $Trainer.party[chosen])
                end
              else
                Kernel.pbMessageDisplay(msgwindow, _INTL("The trade was unable to be completed."))
                partner_chosen = nil
                if client_id == 0
                  state = :choose_activity
                else
                  state = :await_choose_activity
                end
              end

            when :update
              partner_party[partner_chosen] = parse_pkmn(record)
              partner_chosen = nil
              if client_id == 0
                state = :choose_activity
              else
                state = :await_choose_activity
              end

            when :cancel
              Kernel.pbMessageDisplay(msgwindow, _INTL("I'm sorry, {1} doesn't want to trade after all.", partner_name))
              if client_id == 0
                state = :choose_activity
              else
                state = :await_choose_activity
              end

            else
              raise "Unknown message: #{type}"
            end
          end

        else
          raise "Unknown state: #{state}"
        end
      end
    end
  end

  def self.pbMessageDisplayDots(msgwindow, message, frame)
    Kernel.pbMessageDisplay(msgwindow, message + "...".slice(0..(frame/8) % 3) + "\\^", false)
  end

  # Renamed constants, yay...
  if !defined?(ESSENTIALSVERSION) && !defined?(ESSENTIALS_VERSION)
    def self.do_battle(connection, client_id, seed, battle_type, partner, partner_party)
      pbHealAll # Avoids having to transmit damaged state.
      partner_party.each {|pkmn| pkmn.heal}
      scene = pbNewBattleScene
      battle = PokeBattle_CableClub.new(connection, client_id, scene, partner_party, partner)
      battle.fullparty1 = battle.fullparty2 = true
      battle.endspeech = ""
      battle.items = []
      battle.internalbattle = false
      case battle_type
      when :single
        battle.doublebattle = false
      when :double
        battle.doublebattle = true
      else
        raise "Unknown battle type: #{battle_type}"
      end
      trainerbgm = pbGetTrainerBattleBGM(partner)
      Events.onStartBattle.trigger(nil, nil)
      pbPrepareBattle(battle)
      exc = nil
      pbBattleAnimation(trainerbgm, partner.trainertype, partner.name) {
        pbSceneStandby {
          # XXX: Hope we call rand in the same order in both clients...
          srand(seed)
          begin
            battle.pbStartBattle(true)
          rescue Connection::Disconnected
            scene.pbEndBattle(0)
            exc = $!
          end
        }
      }
      raise exc if exc
    end

    def self.do_trade(index, you, your_pkmn)
      my_pkmn = $Trainer.party[index]
      your_pkmn.obtainMode = 2 # traded
      your_pkmn.pbRecordFirstMoves
      $Trainer.seen[your_pkmn.species] = true
      $Trainer.owned[your_pkmn.species] = true
      pbSeenForm(your_pkmn)
      pbFadeOutInWithMusic(99999) {
        scene = PokemonTradeScene.new
        scene.pbStartScreen(my_pkmn, your_pkmn, $Trainer.name, you.name)
        scene.pbTrade
        scene.pbEndScreen
      }
      $Trainer.party[index] = your_pkmn
    end

    def self.choose_pokemon
      chosen = -1
      pbFadeOutIn(99999) {
        scene = PokemonScreen_Scene.new
        screen = PokemonScreen.new(scene, $Trainer.party)
        screen.pbStartScene(_INTL("Choose a Pokémon."), false)
        chosen = screen.pbChoosePokemon
        screen.pbEndScene
      }
      return chosen
    end
  elsif defined?(ESSENTIALSVERSION) && ESSENTIALSVERSION =~ /^17/
    def self.do_battle(connection, client_id, seed, battle_type, partner, partner_party)
      pbHealAll # Avoids having to transmit damaged state.
      partner_party.each {|pkmn| pkmn.heal}
      scene = pbNewBattleScene
      battle = PokeBattle_CableClub.new(connection, client_id, scene, partner_party, partner)
      battle.fullparty1 = battle.fullparty2 = true
      battle.endspeech = ""
      battle.items = []
      battle.internalbattle = false
      case battle_type
      when :single
        battle.doublebattle = false
      when :double
        battle.doublebattle = true
      else
        raise "Unknown battle type: #{battle_type}"
      end
      trainerbgm = pbGetTrainerBattleBGM(partner)
      Events.onStartBattle.trigger(nil, nil)
      # XXX: Hope both battles take place in the same area for things like Nature Power.
      pbPrepareBattle(battle)
      exc = nil
      pbBattleAnimation(trainerbgm, battle.doublebattle ? 3 : 1, [partner]) {
        pbSceneStandby {
          # XXX: Hope we call rand in the same order in both clients...
          srand(seed)
          begin
            battle.pbStartBattle(true)
          rescue Connection::Disconnected
            scene.pbEndBattle(0)
            exc = $!
          end
        }
      }
      raise exc if exc
    end

    def self.do_trade(index, you, your_pkmn)
      my_pkmn = $Trainer.party[index]
      your_pkmn.obtainMode = 2 # traded
      your_pkmn.pbRecordFirstMoves
      $Trainer.seen[your_pkmn.species] = true
      $Trainer.owned[your_pkmn.species] = true
      pbSeenForm(your_pkmn)
      pbFadeOutInWithMusic(99999) {
        scene = PokemonTrade_Scene.new
        scene.pbStartScreen(my_pkmn, your_pkmn, $Trainer.name, you.name)
        scene.pbTrade
        scene.pbEndScreen
      }
      $Trainer.party[index] = your_pkmn
    end

    def self.choose_pokemon
      chosen = -1
      pbFadeOutIn(99999) {
        scene = PokemonParty_Scene.new
        screen = PokemonPartyScreen.new(scene, $Trainer.party)
        screen.pbStartScene(_INTL("Choose a Pokémon."), false)
        chosen = screen.pbChoosePokemon
        screen.pbEndScene
      }
      return chosen
    end
  elsif defined?(ESSENTIALS_VERSION) && ESSENTIALS_VERSION =~ /^18/
    def self.do_battle(connection, client_id, seed, battle_type, partner, partner_party)
      pbHealAll # Avoids having to transmit damaged state.
      partner_party.each{|pkmn| pkmn.heal} # back to back battles desync without it.
      scene = pbNewBattleScene
      battle = PokeBattle_CableClub.new(connection, client_id, scene, partner_party, partner)
      battle.endSpeeches = [""]
      battle.items = []
      battle.internalBattle = false
      case battle_type
      when :single
        setBattleRule("single")
      when :double
        setBattleRule("double")
      else
        raise "Unknown battle type: #{battle_type}"
      end
      trainerbgm = pbGetTrainerBattleBGM(partner)
      Events.onStartBattle.trigger(nil, nil)
      # XXX: Hope both battles take place in the same area for things like Nature Power.
      pbPrepareBattle(battle)
      $PokemonTemp.clearBattleRules
      exc = nil
      pbBattleAnimation(trainerbgm, (battle.singleBattle?) ? 1 : 3, [partner]) {
        pbSceneStandby {
          # XXX: Hope we call rand in the same order in both clients...
          srand(seed)
          begin
            battle.pbStartBattle
          rescue Connection::Disconnected
            scene.pbEndBattle(0)
            exc = $!
          end
        }
      }
      raise exc if exc
    end

    def self.do_trade(index, you, your_pkmn)
      my_pkmn = $Trainer.party[index]
      your_pkmn.obtainMode = 2 # traded
      your_pkmn.pbRecordFirstMoves
      $Trainer.seen[your_pkmn.species] = true
      $Trainer.owned[your_pkmn.species] = true
      pbSeenForm(your_pkmn)
      pbFadeOutInWithMusic(99999) {
        scene = PokemonTrade_Scene.new
        scene.pbStartScreen(my_pkmn, your_pkmn, $Trainer.name, you.name)
        scene.pbTrade
        scene.pbEndScreen
      }
      $Trainer.party[index] = your_pkmn
    end

    def self.choose_pokemon
      chosen = -1
      pbFadeOutIn(99999) {
        scene = PokemonParty_Scene.new
        screen = PokemonPartyScreen.new(scene, $Trainer.party)
        screen.pbStartScene(_INTL("Choose a Pokémon."), false)
        chosen = screen.pbChoosePokemon
        screen.pbEndScene
      }
      return chosen
    end
  end

  def self.write_party(writer)
    writer.int($Trainer.party.length)
    $Trainer.party.each do |pkmn|
      write_pkmn(writer, pkmn)
    end
  end

  def self.write_pkmn(writer, pkmn)
    writer.int(pkmn.species)
    writer.int(pkmn.level)
    writer.int(pkmn.personalID)
    writer.int(pkmn.trainerID)
    writer.str(pkmn.ot)
    writer.int(pkmn.otgender)
    writer.int(pkmn.exp)
    writer.int(pkmn.form)
    writer.int(pkmn.item)
    writer.int(pkmn.moves.length)
    pkmn.moves.each do |move|
      writer.int(move.id)
      writer.int(move.ppup)
    end
    writer.int(pkmn.ability)
    writer.int(pkmn.gender)
    writer.int(pkmn.nature)
    for i in 0...6
      writer.int(pkmn.iv[i])
      writer.int(pkmn.ev[i])
    end
    writer.int(pkmn.happiness)
    writer.str(pkmn.name)
    writer.int(pkmn.ballused)
    writer.int(pkmn.eggsteps)
    writer.nil_or(:int, pkmn.abilityflag)
    writer.nil_or(:int, pkmn.genderflag)
    writer.nil_or(:int, pkmn.natureflag)
    writer.nil_or(:bool, pkmn.shinyflag)
    if defined?(EliteBattle) # EBDX compat
      # this looks so dumb I know, but the variable can be nil, false, or an int.
      writer.bool(pkmn.shiny?)
      writer.str(pkmn.superHue.to_s)
      writer.nil_or(:bool,pkmn.superVariant)
    end
  end

  def self.parse_party(record)
    party = []
    record.int.times do
      party << parse_pkmn(record)
    end
    return party
  end

  def self.parse_pkmn(record)
    species = record.int
    level = record.int
    pkmn = PokeBattle_Pokemon.new(species, level, $Trainer)
    pkmn.personalID = record.int
    pkmn.trainerID = record.int
    pkmn.ot = record.str
    pkmn.otgender = record.int
    pkmn.exp = record.int
    form = record.int
    if defined?(ESSENTIALS_VERSION) && ESSENTIALS_VERSION =~ /^18/
      pkmn.forcedForm = form if MultipleForms.hasFunction?(pkmn.species,"getForm")
      pkmn.formSimple = form
    else
      pkmn.forcedForm = true if form != 0
      pkmn.formNoCall = form
    end
    pkmn.setItem(record.int)
    pkmn.resetMoves
    for i in 0...record.int
      pkmn.moves[i] = PBMove.new(record.int)
      pkmn.moves[i].ppup = record.int
    end
    pkmn.moves.compact!
    pkmn.setAbility(record.int)
    pkmn.setGender(record.int)
    pkmn.setNature(record.int)
    for i in 0...6
      pkmn.iv[i] = record.int
      pkmn.ev[i] = record.int
    end
    pkmn.happiness = record.int
    pkmn.name = record.str
    pkmn.ballused = record.int
    pkmn.eggsteps = record.int
    pkmn.abilityflag = record.nil_or(:int)
    pkmn.genderflag = record.nil_or(:int)
    pkmn.natureflag = record.nil_or(:int)
    pkmn.shinyflag = record.nil_or(:bool)
    if defined?(EliteBattle) # EBDX compat
      # this looks so dumb I know, but the variable can be nil, false, or an int.
      record.bool # shiny call.
      superhue = record.str
      if superhue == ""
        pkmn.superHue = nil
      elsif superhue=="false"
        pkmn.superHue = false
      else
        pkmn.superHue = superhue.to_i
      end
      pkmn.superVariant = record.nil_or(:bool)
    end
    pkmn.calcStats
    return pkmn
  end
end

class PokeBattle_Battle
  attr_reader :client_id
end

class PokeBattle_CableClub < PokeBattle_Battle
  attr_reader :connection
  def initialize(connection, client_id, scene, opponent_party, opponent)
    @connection = connection
    @client_id = client_id
    player = PokeBattle_Trainer.new($Trainer.name, $Trainer.trainertype)
    super(scene, $Trainer.party, opponent_party, player, opponent)
    @battleAI  = PokeBattle_CableClub_AI.new(self) if defined?(ESSENTIALS_VERSION) && ESSENTIALS_VERSION =~ /^18/
  end

  # Added optional args to not make v18 break.
  def pbSwitchInBetween(index, lax=false, cancancel=false)
    if pbOwnedByPlayer?(index)
      choice = super(index, lax, cancancel)
      @connection.send do |writer|
        writer.sym(:switch)
        writer.int(choice)
      end
      return choice
    else
      frame = 0
      # So much renamed stuff...
      if defined?(ESSENTIALS_VERSION) && ESSENTIALS_VERSION =~ /^18/
        cbox = PokeBattle_Scene::MESSAGE_BOX
        hbox = "messageWindow"
        opponent = @opponent[0]
      else
        cbox = PokeBattle_Scene::MESSAGEBOX
        hbox = "messagewindow"
        opponent = @opponent
      end
      @scene.pbShowWindow(cbox)
      cw = @scene.sprites[hbox]
      cw.letterbyletter = false
      begin
        loop do
          frame += 1
          cw.text = _INTL("Waiting" + "." * (1 + ((frame / 8) % 3)))
          @scene.pbFrameUpdate(cw)
          Graphics.update
          Input.update
          raise Connection::Disconnected.new("disconnected") if Input.press?(Input::B) && Kernel.pbConfirmMessage("Would you like to disconnect?")
          @connection.update do |record|
            case (type = record.sym)
            when :forfeit
              pbSEPlay("Battle flee")
              pbDisplay(_INTL("{1} forfeited the match!", opponent.fullname))
              @decision = 1
              pbAbort

            when :switch
              return record.int

            else
              raise "Unknown message: #{type}"
            end
          end
        end
      ensure
        cw.letterbyletter = false
      end
    end
  end

  def pbRun(idxPokemon, duringBattle=false)
    ret = super(idxPokemon, duringBattle)
    if ret == 1
      @connection.send do |writer|
        writer.sym(:forfeit)
      end
      @connection.discard(1)
    end
    return ret
  end

  # Rearrange the battlers into a consistent order, do the function, then restore the order.
  if defined?(ESSENTIALS_VERSION) && ESSENTIALS_VERSION =~ /^18/
    def pbCalculatePriority(*args)
      begin
        battlers = @battlers.dup
        order = CableClub::pokemon_order(@client_id)
        for i in 0..3
          @battlers[i] = battlers[order[i]]
        end
        return super(*args)
      ensure
        @battlers = battlers
      end
    end
    
    def pbCanShowCommands?(idxBattler)
      last_index = pbGetOpposingIndicesInOrder(0).reverse.last
      return true if last_index==idxBattler
      return super(idxBattler)
    end
  else
    def pbPriority(*args)
      begin
        battlers = @battlers.dup
        order = CableClub::pokemon_order(@client_id)
        for i in 0..3
          @battlers[i] = battlers[order[i]]
        end
        return super(*args)
      ensure
        @battlers = battlers
      end
    end
    
    # This is horrific. Basically, we need to force Essentials to look for
    # the RHS foe's move in all circumstances, otherwise we won't transmit
    # any moves for this turn and the battle will hang.
    def pbCanShowCommands?(index)
      super(index) || (index == 3 && Kernel.caller(1) =~ /pbCanShowCommands/)
    end
    
     def pbDefaultChooseEnemyCommand(index)
      our_indices = @doublebattle ? [0, 2] : [0]
      their_indices = @doublebattle ? [1, 3] : [1]
      # Sends our choices after they have all been locked in.
      if index == their_indices.last
        target_order = CableClub::pokemon_target_order(@client_id)
        for our_index in our_indices
          @connection.send do |writer|
            pkmn = @battlers[our_index]
            writer.sym(:choice)
            writer.int(@choices[our_index][0])
            writer.int(@choices[our_index][1])
            move = @choices[our_index][2] && pkmn.moves.index(@choices[our_index][2])
            writer.nil_or(:int, move)
            # -1 invokes the RNG, out of order (somehow?!) which causes desync.
            # But this is a single battle, so the only possible choice is the foe.
            if !@doublebattle && @choices[our_index][3] == -1
              @choices[our_index][3] = their_indices[0]
            end
            # Target from their POV.
            our_target = @choices[our_index][3]
            their_target = target_order[our_target] rescue our_target
            writer.int(their_target)
            mega=@megaEvolution[0][0]
            mega^=1 if mega>=0
            writer.int(mega) # mega fix?
          end
        end
        frame = 0
        @scene.pbShowWindow(PokeBattle_Scene::MESSAGEBOX)
        cw = @scene.sprites["messagewindow"]
        cw.letterbyletter = false
        begin
          loop do
            frame += 1
            cw.text = _INTL("Waiting" + "." * (1 + ((frame / 8) % 3)))
            @scene.pbFrameUpdate(cw)
            Graphics.update
            Input.update
            raise Connection::Disconnected.new("disconnected") if Input.press?(Input::B) && Kernel.pbConfirmMessage("Would you like to disconnect?")
            @connection.update do |record|
              case (type = record.sym)
              when :forfeit
                pbSEPlay("Battle flee")
                pbDisplay(_INTL("{1} forfeited the match!", @opponent.fullname))
                @decision = 1
                pbAbort

              when :choice
                their_index = their_indices.shift
                partner_pkmn = @battlers[their_index]
                @choices[their_index][0] = record.int
                @choices[their_index][1] = record.int
                move = record.nil_or(:int)
                @choices[their_index][2] = move && partner_pkmn.moves[move]
                @choices[their_index][3] = record.int
                @megaEvolution[1][0] = record.int # mega fix?
                return if their_indices.empty?

              else
                raise "Unknown message: #{type}"
              end
            end
          end
        ensure
          cw.letterbyletter = true
        end
      end
    end

    def pbDefaultChooseNewEnemy(index, party)
      raise "Expected this to be unused."
    end
  end
end
if defined?(ESSENTIALS_VERSION) && ESSENTIALS_VERSION =~ /^18/
  class PokeBattle_CableClub_AI < PokeBattle_AI
    def pbDefaultChooseEnemyCommand(index)
      # Hurray for default methods. have to reverse it to show the expected order.
      our_indices = @battle.pbGetOpposingIndicesInOrder(1).reverse
      their_indices = @battle.pbGetOpposingIndicesInOrder(0).reverse
      # Sends our choices after they have all been locked in.
      if index == their_indices.last
        # TODO: patch this up to be index agnostic.
        # Would work fine if restricted to single/double battles
        target_order = CableClub::pokemon_target_order(@battle.client_id)
        for our_index in our_indices
          @battle.connection.send do |writer|
            pkmn = @battle.battlers[our_index]
            writer.sym(:choice)
            # choice picked was changed to be a symbol now.
            writer.sym(@battle.choices[our_index][0])
            writer.int(@battle.choices[our_index][1])
            move = @battle.choices[our_index][2] && pkmn.moves.index(@battle.choices[our_index][2])
            writer.nil_or(:int, move)
            # -1 invokes the RNG, out of order (somehow?!) which causes desync.
            # But this is a single battle, so the only possible choice is the foe.
            if @battle.singleBattle? && @battle.choices[our_index][3] == -1
              @battle.choices[our_index][3] = their_indices[0]
            end
            # Target from their POV.
            our_target = @battle.choices[our_index][3]
            their_target = target_order[our_target] rescue our_target
            writer.int(their_target)
            mega=@battle.megaEvolution[0][0]
            mega^=1 if mega>=0
            writer.int(mega) # mega fix?
          end
        end
        frame = 0
        @battle.scene.pbShowWindow(PokeBattle_Scene::MESSAGE_BOX)
        cw = @battle.scene.sprites["messageWindow"]
        cw.letterbyletter = false
        begin
          loop do
            frame += 1
            cw.text = _INTL("Waiting" + "." * (1 + ((frame / 8) % 3)))
            @battle.scene.pbFrameUpdate(cw)
            Graphics.update
            Input.update
            raise Connection::Disconnected.new("disconnected") if Input.press?(Input::B) && Kernel.pbConfirmMessage("Would you like to disconnect?")
            @battle.connection.update do |record|
              case (type = record.sym)
              when :forfeit
                pbSEPlay("Battle flee")
                @battle.pbDisplay(_INTL("{1} forfeited the match!", @battle.opponent[0].fullname))
                @battle.decision = 1
                @battle.pbAbort

              when :choice
                their_index = their_indices.shift
                partner_pkmn = @battle.battlers[their_index]
                @battle.choices[their_index][0] = record.sym
                @battle.choices[their_index][1] = record.int
                move = record.nil_or(:int)
                @battle.choices[their_index][2] = move && partner_pkmn.moves[move]
                @battle.choices[their_index][3] = record.int
                @battle.megaEvolution[1][0] = record.int # mega fix?
                return if their_indices.empty?

              else
                raise "Unknown message: #{type}"
              end
            end
          end
        ensure
          cw.letterbyletter = true
        end
      end
    end

    def pbDefaultChooseNewEnemy(index, party)
      raise "Expected this to be unused."
    end
  end  
else
  class PokeBattle_Battler
    alias old_pbFindUser pbFindUser if !defined?(old_pbFindUser)

    # This ensures the targets are processed in the same order.
    def pbFindUser(choice, targets)
      ret = old_pbFindUser(choice, targets)
      if !@battle.client_id.nil?
        order = CableClub::pokemon_order(@battle.client_id)
        targets.sort! {|a, b| order[a.index] <=> order[b.index]}
      end
      return ret
    end
  end
end

class Socket
  def recv_up_to(maxlen, flags = 0)
    retString=""
    buf = "\0" * maxlen
    retval=Winsock.recv(@fd, buf, buf.size, flags)
    SocketError.check if retval == -1
    retString+=buf[0,retval]
    return retString
  end

  def write_ready?
    SocketError.check if (ret = Winsock.select(1, 0, [1, @fd].pack("ll"), 0, [0, 0].pack("ll"))) == -1
    return ret != 0
  end
end

class Connection
  class Disconnected < Exception; end
  class ProtocolError < StandardError; end

  def self.open(host, port)
    # XXX: Non-blocking connect.
    TCPSocket.open(host, port) do |socket|
      connection = Connection.new(socket)
      yield connection
    end
  end

  def initialize(socket)
    @socket = socket
    @recv_parser = Parser.new
    @recv_records = []
    @discard_records = 0
  end

  def update
    if @socket.ready?
      recvd = @socket.recv_up_to(4096, 0)
      raise Disconnected.new("server disconnected") if recvd.empty?
      @recv_parser.parse(recvd) {|record| @recv_records << record}
    end
    # Process at most one record so that any control flow in the block doesn't cause us to lose records.
    if !@recv_records.empty?
      record = @recv_records.shift
      if record.disconnect?
        reason = record.str() rescue "unknown error"
        raise Disconnected.new(reason)
      end
      if @discard_records == 0
        begin
          yield record
        else
          raise ProtocolError.new("Unconsumed input: #{record}") if !record.empty?
        end
      else
        @discard_records -= 1
      end
    end
  end

  def can_send?
    return @socket.write_ready?
  end

  def send
    # XXX: Non-blocking send.
    # but note we don't update often so we need some sort of drained?
    # for the send buffer so that we can delay starting the battle.
    writer = RecordWriter.new
    yield writer
    @socket.send(writer.line!)
  end

  def discard(n)
    raise "Cannot discard #{n} messages." if n < 0
    @discard_records += n
  end
end

class Parser
  def initialize
    @buffer = ""
  end

  def parse(data)
    return if data.empty?
    lines = data.split("\n", -1)
    lines[0].insert(0, @buffer)
    @buffer = lines.pop
    lines.each do |line|
      yield RecordParser.new(line) if !line.empty?
    end
  end
end

class RecordParser
  def initialize(data)
    @fields = []
    field = ""
    escape = false
    # each_char and chars don't exist.
    for i in (0...data.length)
      char = data[i].chr
      if char == "," && !escape
        @fields << field
        field = ""
      elsif char == "\\" && !escape
        escape = true
      else
        field += char
        escape = false
      end
    end
    @fields << field
    @fields.reverse!
  end

  def empty?; return @fields.empty? end

  def disconnect?
    if @fields.last == "disconnect"
      @fields.pop
      return true
    else
      return false
    end
  end

  def nil_or(t)
    raise Connection::ProtocolError.new("Expected nil or #{t}, got EOL") if @fields.empty?
    if @fields.last.empty?
      @fields.pop
      return nil
    else
      return self.send(t)
    end
  end

  def bool
    raise Connection::ProtocolError.new("Expected bool, got EOL") if @fields.empty?
    field = @fields.pop
    if field == "true"
      return true
    elsif field == "false"
      return false
    else
      raise Connection::ProtocolError.new("Expected bool, got #{field}")
    end
  end

  def int
    raise Connection::ProtocolError.new("Expected int, got EOL") if @fields.empty?
    field = @fields.pop
    begin
      return Integer(field)
    rescue
      raise Connection::ProtocolError.new("Expected int, got #{field}")
    end
  end

  def str
    raise Connection::ProtocolError.new("Expected str, got EOL") if @fields.empty?
    @fields.pop
  end

  def sym
    raise Connection::ProtocolError.new("Expected sym, got EOL") if @fields.empty?
    @fields.pop.to_sym
  end

  def to_s; @fields.reverse.join(", ") end
end

class RecordWriter
  def initialize
    @fields = []
  end

  def line!
    line = @fields.map {|field| escape!(field)}.join(",")
    line += "\n"
    @fields = []
    return line
  end

  def escape!(s)
    s.gsub!("\\", "\\\\")
    s.gsub!(",", "\,")
    return s
  end

  def nil_or(t, o)
    if o.nil?
      @fields << ""
    else
      self.send(t, o)
    end
  end

  def bool(b); @fields << b.to_s end
  def int(i); @fields << i.to_s end
  def str(s) @fields << s end
  def sym(s); @fields << s.to_s end
end
