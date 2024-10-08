class Main
  def initialize
    @hero = nil
    @messages = MainMessage.new
  end

  def start_game
    # Создание начальных yml
    Warehouse.new
    PzdcMonolith.new
    Shop.new
    OccultLibrary.new
    Options.new
    StatisticsTotal.new
    # ход игры
    loop do
      MainRenderer.new(:start_game_screen).display
      choose = gets.strip
      if choose == '0'
        puts "\e[H\e[2J"
        exit
      elsif choose == '2' # Лагерь
        CampEngine.new.camp
      elsif choose == '3'
        OptionsEngine.new.main
      else # Забег
        load_or_start_new_run()
      end
    end
  end

  def load_or_start_new_run
    choose = nil
    until choose == 0
      @hero = nil   # чтобы после выхода из load_run() не оставался загруженный герой
      MainRenderer.new(:load_new_run_screen, arts: [ { dungeon_cave: :dungeon_enter } ] ).display
      choose = gets.to_i
      if choose == 1
        load_run()
        @hero.statistics = StatisticsRun.new(@hero.dungeon_name) if @hero
        Run.new(@hero).start if @hero
      elsif choose == 2
        start_new_run()
        @hero.statistics = StatisticsRun.new(@hero.dungeon_name, true) if @hero
        Run.new(@hero).start if @hero
      end
    end
  end

  def load_run
    load_hero = LoadHeroInRun.new
    load_hero.load
    hero = load_hero.hero
    choose = nil
    until ['Y', 'N', ''].include?(choose)
      @messages.main = 'Load game [Enter Y]            Back to menu [Enter N]'
      @messages.log = ["#{hero.dungeon_name.capitalize}"]
      MainRenderer.new(
        :hero_sl_screen,
        hero, hero,
        entity: @messages,
        arts: [ { normal: :"dungeons/_#{hero.dungeon_name}" }]
      ).display
      choose = gets.strip.upcase
      AmmunitionShow.show_weapon_buttons_actions(choose, hero)
    end
    @hero = hero if choose == 'Y'
  end

  def start_new_run
    new_dungeon_num = 9000
    until [0, 1, 2, 3].include?(new_dungeon_num)
      MainRenderer.new(
        :choose_dungeon_screen,
        arts: [ { normal: :"dungeons/_bandits" }, { normal: :"dungeons/_undeads" }, { normal: :"dungeons/_swamp" } ]
      ).display
      new_dungeon_num = gets.to_i
    end
    if [1, 2, 3].include?(new_dungeon_num)
      dungeon_name = %w[bandits undeads swamp][new_dungeon_num-1]
      # Создание нового персонажа
      @hero = HeroCreator.new(dungeon_name).create_new_hero
    end
  end

end

















#
