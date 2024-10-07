class CampFireEngine
  attr_reader :exit_to_main

  def initialize(hero, rest_messages)
    @hero = hero
    @exit_to_main = false
    @messages = messages(rest_messages)
  end

  def messages(rest_messages)
    messages = MainMessage.new
    messages.log += rest_messages.log # сообщения отдыха с пршлого раунда
    messages
  end

  def start
    choose = nil
    until ['0', ''].include?(choose)
      @messages.additional_1 = @hero.stat_points
      @messages.additional_2 = @hero.skill_points
      MainRenderer.new(:rest_menu_screen, entity: @messages, arts: [{ camp_fire_big: :rest }]).display
      choose = gets.strip.upcase
      if choose == '1'
        show_hero_stats_and_ammunition()
      elsif choose == '2'
        spend_stat_points()
      elsif choose == '3'
        spend_skill_points()
      elsif choose == '4'
        use_camp_skill()
      elsif choose == '5'
        enchance_ammunition()
      elsif choose == '6'
        save_and_exit()
        choose = '' # чтобы сразу выйти в run
      end
    end
  end

  private

  def show_hero_stats_and_ammunition
    messages2 = MainMessage.new
    choose = nil
    until ['0', ''].include?(choose)
      messages2.main = 'BACK TO CAMP FIRE OPTIONS  [Enter 0]'
      messages2.log = ["#{@hero.dungeon_name.capitalize}"]
      MainRenderer.new(
        :hero_sl_screen,
        @hero, @hero,
        entity: messages2,
        arts: [ { normal: :"dungeons/_#{@hero.dungeon_name}" }]
      ).display
      choose = gets.strip.upcase
      AmmunitionShow.show_weapon_buttons_actions(choose, @hero)
    end
  end

  def spend_stat_points
    if @hero.stat_points == 0
      @messages.log.shift if @messages.log.length > 2
      @messages.log << 'You dont have stat points'
    else
      HeroUpdator.new(@hero).spend_stat_points
    end
  end

  def spend_skill_points
    if @hero.skill_points == 0
      @messages.log.shift if @messages.log.length > 2
      @messages.log << 'You dont have skill points'
    else
      HeroUpdator.new(@hero).spend_skill_points
    end
  end

  def use_camp_skill
    messages_skill = MainMessage.new
    if @hero.camp_skill.respond_to?(:mp_cost) || @hero.camp_skill.respond_to?(:hp_cost)
      HeroUseSkill.camp_skill(@hero, messages_skill)
    else
      @messages.log << 'You dont have active camp skill'
    end
    @messages.log += messages_skill.log
    @messages.log.shift if @messages.log.length > 3
  end

  def enchance_ammunition
    OccultLibraryEnhanceController.new(@hero).recipes_list
  end

  def save_and_exit
    @hero.statistics.update       # сохранение статистики забега
    SaveHeroInRun.new(@hero).save # сохранение персонажа
    @exit_to_main = true          # exit
  end

end