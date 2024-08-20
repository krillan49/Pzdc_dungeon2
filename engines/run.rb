class Run
  def initialize(hero, leveling)
    @hero = hero
    @leveling = leveling

    @enemy = nil
    @hero_run_from_battle = false
    @messages = MainMessage.new

    @exit_to_main = false
  end

  def start
    while true
      hero_update()
      save_and_exit()
      break if @exit_to_main
      camp_actions()
      event_or_enemy_choose()
      battle()
      break if @exit_to_main
      after_battle()
      break if @exit_to_main
    end
  end

  def hero_update
    HeroUpdator.new(@hero).spend_stat_points # распределение очков характеристик
    HeroUpdator.new(@hero).spend_skill_points # распределение очков навыков  (тут вызывается старое меню, потом доделать)
  end

  def save_and_exit
    choose = nil
    until %w[Y N 0].include?(choose)
      @messages.main = 'Save this run and exit game? [y/N]'
      MainRenderer.new(:hero_update_screen, @hero, @hero, entity: @messages).display
      choose = gets.strip.upcase
      if choose == 'Y'
        # сохранение персонажа
        SaveHeroInRun.new(@hero, @leveling).save
        @exit_to_main = true # exit
      end
      show_weapon_buttons_actions(choose)
    end
  end

  def camp_actions
    HeroUseSkill.camp_skill(@hero, @messages) # Навык Первая помощь
    HeroActions.rest(@hero, @messages) # пассивное восстановления жизней и маны между боями
    @messages.main = 'To continue press Enter'
    MainRenderer.new(:messages_screen, entity: @messages, arts: [{ camp_fire: :rest }]).display
    @messages.clear_log
    gets
  end

  def event_or_enemy_choose
    # Выбор противника
    enemy1 = EnemyCreator.new(@leveling, @hero.dungeon_name).create_new_enemy
    enemy2 = EnemyCreator.new(@leveling, @hero.dungeon_name).create_new_enemy
    enemy3 = EnemyCreator.new(@leveling, @hero.dungeon_name).create_new_enemy
    n = 50
    @messages.main = 'Which way will you go?'
    until n >= 0 && n <= 2
      MainRenderer.new(
        :event_choose_screen, enemy1, enemy2, enemy3,
        entity: @messages, arts: [{ mini: enemy1 }, { mini: enemy2 }, { mini: enemy3 }]
      ).display
      n = gets.to_i - 1
      if n >= 0 && n <= 2
        @enemy = [enemy1, enemy2, enemy3][n]
      else
        @messages.main = 'There is no such way. Which way will you go?'
      end
    end
    # Характеристики противника
    @attacks_round_messages = AttacksRoundMessage.new
    @attacks_round_messages.main = 'To continue press Enter'
    @attacks_round_messages.actions = "++++++++++++ Battle #{@leveling + 1} ++++++++++++"
    MainRenderer.new(:enemy_start_screen, @enemy, entity: @attacks_round_messages, arts: [{ normal: @enemy }]).display
    gets
  end

  def battle
    @hero_run_from_battle = false
    # lap = 1 # номер хода
    while @enemy.hp > 0 && @hero_run_from_battle == false
      round = AttacksRound.new(@hero, @enemy, @attacks_round_messages)
      round.action
      @hero_run_from_battle = round.hero_run?
      if round.hero_dead?
        @exit_to_main = true
        break
      end
      # lap += 1
    end
  end

  def after_battle
    # Сбор лута
    loot = LootRound.new(@hero, @enemy, @hero_run_from_battle)
    loot.action
    if loot.hero_dead?
      @exit_to_main = true
      return
    end
    if @enemy.code == 'boss'
      @exit_to_main = true
      @messages.main = 'Boss killed. To continue press Enter'
      MainRenderer.new(:run_win_screen, entity: @messages).display
      gets
      DeleteHeroInRun.new(@hero).add_camp_loot_and_delete_hero_file
      return
    end
    # Получение опыта и очков
    HeroActions.add_exp_and_hero_level_up(@hero, @enemy.exp_gived, @messages) if !@hero_run_from_battle
    # display_message_screen_with_confirm_and_change_screen()
    @messages.main = 'To continue press Enter'
    MainRenderer.new(:messages_screen, entity: @messages, arts: [{ exp_gained: :exp_gained }]).display
    @messages.clear_log
    gets
    @leveling += 1
  end

  private

  # def display_message_screen_with_confirm_and_change_screen
  #   @messages.main = 'To continue press Enter'
  #   MainRenderer.new(:messages_screen, entity: @messages).display
  #   @messages.clear_log
  #   gets
  # end

  def show_weapon_buttons_actions(distribution)
    if distribution == 'A' # show all ammunition
    elsif %w[B C D E F].include?(distribution) # show chosen ammunition
      ammunition_type = {B: 'weapon', C: 'head_armor', D: 'body_armor', E: 'arms_armor', F: 'shield'}[distribution.to_sym]
      ammunition_code = @hero.send(ammunition_type).code
      AmmunitionShow.show(ammunition_type, ammunition_code) if ammunition_code != 'without'
    end
  end

end

















#
