class BridgeKeeperEvent
  PATH_ART = "events/_briedge_keeper"

  attr_reader :entity_type, :path_art
  attr_reader :name, :description1, :description2, :description3, :description4, :description5

  def initialize(hero)
    @hero = hero

    @entity_type = 'events'
    @path_art = PATH_ART

    @name = 'Bridge of death'
    @description1 = 'Bridge keeper...'
    @description2 = '...will ask questions...'
    @description3 = '...answer correctly...'
    @description4 = '...and otherwise'
    @description5 = ''

    @messages = MainMessage.new
  end

  def start
    @messages.main = "You see a stern old man, this is the keeper of the bridge, he asks questions"
    res18 = first_question()
    return unless res18
    billy_herrington = second_question()
    return unless billy_herrington
    reward()
  end

  private

  def first_question
    @messages.log << "First question: How old are you?"
    display_message_screen()
    answer = gets.to_i
    if answer >= 18
      @messages.log[-1] += " Your answer #{answer} is correct"
      true
    else
      @messages.main = 'To continue press Enter'
      @messages.log << "Get out of here, you're not old enough yet."
      display_message_screen()
      gets
      false
    end
  end

  def second_question
    @messages.log << "Second question: Who is the greatest champion Gachimuchi?"
    display_message_screen()
    answer = gets.strip.downcase
    if (answer.include?('billy') || answer.include?('william')) && answer.include?('herrington')
      @messages.log[-1] += " Your answer #{answer} is correct"
      @messages.log << "Сome with me across the bridge #{@hero.name} i'll show you something"
      @messages.main = "Press Enter to cross the bridge"
      display_message_screen()
      gets
      true
    else
      @messages.log << "Your answer #{answer} is incorrect. You shall not pass!!"
      @messages.log << "The bridge keeper uses magic to throw you into the gorge."
      @messages.log << "#{@hero.name} say AAAAAAAAAAAAAAAAAAAAAAAA!!!"
      @hero.hp -= @hero.hp_max * 0.2
      @messages.log << "#{@hero.name} fell and lost #{(@hero.hp_max * 0.2).round} HP. #{@hero.hp.round}/#{@hero.hp_max} HP left"
      if @hero.hp <= 0
        @messages.main = "Press Enter to end the game"
        @messages.log << "You you died"
        MainRenderer.new(:messages_screen, entity: @messages, arts: [{ game_over: :game_over }]).display
        gets
        MainRenderer.new(:run_end_screen, entity: @messages, arts: [{ end: :run_end_art }]).display
        gets
        DeleteHeroInRun.new(@hero).add_camp_loot_and_delete_hero_file
      end
      @messages.main = 'To continue press Enter'
      display_message_screen()
      gets
      false
    end
  end

  def reward
    @messages.main = "The bridge keeper shows your prize"
    @messages.log << "What you saw blinded you a little, but made you stronger. Accurasy -1. Max damage +1"
    @hero.accuracy_base -= 1
    @hero.max_dmg_base += 1
    display_message_screen()
    gets
  end

  private

  def display_message_screen
    MainRenderer.new(:messages_screen, entity: @messages).display #arts: [{ normal: PATH_ART }]
  end

end
