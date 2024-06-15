require_relative "hero"
require_relative "skills"
require_relative "enemyes"
require_relative "weapons"
require_relative "loot"
require_relative "info_block"


#======================================= Методы временные решения =================================================

# Заплатка для корректного отображения навыков на которые влияют характеристики(Концентрация)
def temporary_patch_concentration
  if @name_passive_pl == "Концентрация"
    damage_passive_pl = rand(0..0.1 * (@hero.mp_max_pl * (1 + 0.05 * @lvl_passive_pl) - 100))
    @lor_passive_pl = "(#{@lvl_passive_pl}): если мана больше 100(#{@hero.mp_max_pl}) наносится случайный доп урон до #{(0.1 * (@hero.mp_max_pl * (1 + 0.05 * @lvl_passive_pl) - 100)).round(1)}"
  end
end

# Панель характеристик персонажа
def character_panel
  puts '--------------------------------------------------------------------------------------------'
  puts '--------------------------------------------------------------------------------------------'
  puts "#{@hero.name_pl}"
  puts "Уровень #{@hero.lvl_pl} (#{@hero.exp_pl}/#{@hero.exp_lvl[@hero.lvl_pl + 1]})"
  puts "Н А В Ы К И:"
  puts "[акт] #{@hero.active_skill.name} #{@hero.active_skill.description}"
  puts "[пас] #{@name_passive_pl} #{@lor_passive_pl}"
  puts "[неб] #{@hero.camp_skill.name} #{@hero.camp_skill.description}"
  puts "С Т А Т Ы:"
  puts "HP #{@hero.hp_pl.round}/#{@hero.hp_max_pl} Реген #{@hero.regen_hp_base_pl} Восстановление #{@hero.recovery_hp.round}"
  puts "MP #{@hero.mp_pl.round}/#{@hero.mp_max_pl} Реген #{@hero.regen_mp_base_pl} Восстановление #{@hero.recovery_mp.round}"
  puts "Урон #{@hero.mindam_pl}-#{@hero.maxdam_pl} (базовый #{@hero.mindam_base_pl}-#{@hero.maxdam_base_pl} + #{@hero.weapon.name} #{@hero.weapon.min_dmg}-#{@hero.weapon.max_dmg})"
  puts "Точность #{@hero.accuracy_pl} (базовая #{@hero.accuracy_base_pl} + #{@hero.arms_armor.name} #{@hero.arms_armor.accuracy})"
  puts "Броня #{@hero.armor_pl} (базовая #{@hero.armor_base_pl} + #{@hero.body_armor.name} #{@hero.body_armor.armor} + #{@hero.head_armor.name} #{@hero.head_armor.armor} + #{@hero.arms_armor.name} #{@hero.arms_armor.armor} + #{@hero.shield.name} #{@hero.shield.armor})"
  puts "Шанс блока #{0 if @hero.shield.name == "без щита"}#{@hero.block_pl if @hero.shield.name != "без щита" and @name_passive_pl != "Мастер щита"}#{@hero.block_pl + @coeff_passive_pl if @hero.shield.name != "без щита" and @name_passive_pl == "Мастер щита"} (#{@hero.shield.name} #{@hero.shield.block_chance}) блокируемый урон #{100 - (100 / (1 + @hero.hp_pl.to_f / 200)).to_i}%"
  puts '--------------------------------------------------------------------------------------------'
  puts '--------------------------------------------------------------------------------------------'
end

#==================================================================================================================

# Создание персонажа..............................................................................................
puts 'Создание персонажа'
puts '========================'

# Выбор предистории .................................................................................................
print "Выберите предисторию:
Сторож(G) + 30 жизней, Дубинка
Карманник(T) + 5 точности, Ножик
Рабочий(W) + 30 выносливости, Ржавый топорик
Умник(S) + 5 очков навыков, без оружия
"
choose_story_pl = gets.strip.upcase
case choose_story_pl
when 'G'; @hero = Hero.new('watchman')
when 'T'; @hero = Hero.new('thief')
when 'W'; @hero = Hero.new('worker')
when 'S'; @hero = Hero.new('student')
else
  @hero = Hero.new('drunk')
  puts 'Перепутал буквы, ты тупой алкаш -5 жизней -5 выносливости -10 точность'
end

# Выбор имени .................................................................................................
print 'Введите имя персонажа: '
@hero.name_pl = gets.strip

# Выбор стартовых навыков .......................................................................................
puts 'Выберите стартовый активный навык '
print 'Сильный удар(S) Точный удар(A) '
special_choiсe = gets.strip.upcase
while special_choiсe != 'S' and special_choiсe != 'A'
  print 'Введен неверный символ. Попробуйте еще раз. Сильный удар(S) Точный удар(A) '
  special_choiсe = gets.strip.upcase
end
case special_choiсe
when 'S'; @hero.active_skill = StrongStrike.new
when 'A'; @hero.active_skill = PreciseStrike.new
end

puts 'Выберите стартовый пассивный навык '
print 'Ошеломление(D) Концентрация(C) Мастер щита(B) '
passive_choiсe = gets.strip.upcase
while passive_choiсe != 'D' and passive_choiсe != 'C' and passive_choiсe != 'B'
  print 'Неверный символ попробуйте еще раз. Ошеломление(D) Концентрация(C) Мастер щита(B) '
  passive_choiсe = gets.strip.upcase
end
@lvl_passive_pl = 0
case passive_choiсe
when 'D'
  @name_passive_pl = "Ошеломление"
  @coeff_passive_pl = 1 + 0.1 * @lvl_passive_pl
  @lor_passive_pl = "(#{@lvl_passive_pl}): если урон больше #{(100 / (2 * @coeff_passive_pl)).round}% осташихся жизней врага то он теряет 10-90(%) точности"
when 'C'
  @name_passive_pl = "Концентрация"
  damage_passive_pl = rand(0..0.1 * (@hero.mp_max_pl * (1 + 0.05 * @lvl_passive_pl) - 100))
  @lor_passive_pl = "(#{@lvl_passive_pl}): если мана больше 100(#{@hero.mp_max_pl}) наносится случайный доп урон до #{(0.1 * (@hero.mp_max_pl * (1 + 0.05 * @lvl_passive_pl) - 100)).round(1)}"
when 'B'
  @name_passive_pl = "Мастер щита"
  @coeff_passive_pl = 10 + 2 * @lvl_passive_pl
  @lor_passive_pl = "(#{@lvl_passive_pl}): шанс блока щитом увеличен на #{@coeff_passive_pl}%"
end

puts 'Выберите стартовый небоевой навык '
print 'Первая помощь(F) Кладоискатель(T) '
noncombat_choiсe = gets.strip.upcase
while noncombat_choiсe != 'F' and noncombat_choiсe != 'T'
  print 'Введен неверный символ попробуйте еще раз. Первая помощь(F) Кладоискатель(T) '
  noncombat_choiсe = gets.strip.upcase
end
case noncombat_choiсe
when 'F'; @hero.camp_skill = FirstAid.new(@hero)
when 'T'; @hero.camp_skill = TreasureHunter.new
end
#--------------------------------------------------------------------------------------------------------------------

# Стартовый шанс блока
@hero.block_pl = @hero.shield.block_chance


# Основной игровой блок ===============================================================================================
leveling = 0
while true

  zombie_knight = 0

  # распределение очков характеристик --------------------------------------------------------------------------
  while @hero.stat_points != 0

    temporary_patch_concentration # Заплатка для корректного отображения навыков на которые влияют характеристики(Концентрация) (Временные решения)
    character_panel # Панель характеристик персонажа (Основные)

    distribution = ''
    until %w[H M X A].include?(distribution)
      puts "Распределите очки характеристик. У вас осталось #{@hero.stat_points} очков"
      print '+5 жизней(H). +5 выносливости(M). +1 мин/макс случайно урон(X). +1 точность(A)  '
      distribution = gets.strip.upcase
      case distribution
      when 'H'
        @hero.hp_max_pl += 5
        @hero.hp_pl += 5
      when 'M'
        @hero.mp_max_pl += 5
        @hero.mp_pl += 5
      when 'X'
        @hero.mindam_base_pl < @hero.maxdam_base_pl && rand(0..1) == 0 ? @hero.mindam_base_pl += 1 : @hero.maxdam_base_pl += 1
      when 'A'
        @hero.accuracy_base_pl += 1
      else
        puts 'Вы ввели неверный символ, попробуйте еще раз'
      end
    end
    @hero.stat_points -= 1
  end

  # распределение очков навыков --------------------------------------------------------------------------
  while @hero.skill_points != 0

    temporary_patch_concentration # Заплатка для корректного отображения навыков на которые влияют характеристики(Концентрация) (Временные решения)
    character_panel # Панель характеристик персонажа (Основные)

    # распределение очков навыков ------------------------------------------------------------------------------
    distribution = ''
    while distribution != 'S' and distribution != 'P' and distribution != 'N'
      puts "Распределите очки навыков. У вас осталось #{@hero.skill_points} очков"
      print "+1 #{@hero.active_skill.name}(S). +1 #{@name_passive_pl}(P). +1 #{@hero.camp_skill.name}(N) "
      distribution = gets.strip.upcase
      case distribution
      when 'S' # активные
        @hero.active_skill.lvl += 1
      when 'P' # пассивные
        @lvl_passive_pl += 1
        if @name_passive_pl == "Ошеломление"
          @coeff_passive_pl = 1 + 0.1 * @lvl_passive_pl
          @lor_passive_pl = "(#{@lvl_passive_pl}): если урон больше #{(100 / (2 * @coeff_passive_pl)).round}% осташихся жизней врага то он теряет 10-90(%) точности"
        elsif @name_passive_pl == "Концентрация"
          damage_passive_pl = rand(0..0.1 * (@hero.mp_max_pl * (1 + 0.05 * @lvl_passive_pl) - 100))
          @lor_passive_pl = "(#{@lvl_passive_pl}): если мана больше 100(#{@hero.mp_max_pl}) наносится случайный доп урон до #{(0.1 * (@hero.mp_max_pl * (1 + 0.05 * @lvl_passive_pl) - 100)).round(1)}"
        elsif @name_passive_pl == "Мастер щита"
          @coeff_passive_pl = 10 + 2 * @lvl_passive_pl
          @lor_passive_pl = "(#{@lvl_passive_pl}): шанс блока щитом увеличен на #{@coeff_passive_pl}%"
        end
      when 'N' # небоевые
        @hero.camp_skill.lvl += 1
      else
        puts 'Вы ввели неверный символ, попробуйте еще раз'
        @hero.skill_points += 1
      end
      @hero.skill_points -= 1
    end
  end

  temporary_patch_concentration # Заплатка для корректного отображения навыков на которые влияют характеристики(Концентрация) (Временные решения)

  character_panel # Панель характеристик персонажа (Основные)

  #---------------------------------------------------------------------------------

  @hero.use_camp_skill # Навык Первая помощь

  @hero.rest # пассивное восстановления жизней и маны между боями

  #--------------------------------------------------------------------------------------------------------------

  print 'Чтобы начать следующий бой нажмите Enter'
  gets
  puts "++++++++++++++++++++++++++++++++++++++ Бой #{leveling + 1} +++++++++++++++++++++++++++++++++++++++++++++++++"

  # Назначение противника ---------------------------------------------------------------------------------

  # Проверка шанса уникальных противников
  enemy_event_rand = rand(1..100)
  if enemy_event_rand > (99 - leveling) and zombie_knight != 1
    print 'Вы заметили с одной стороны развилки фигуру рыцаря, идем туда(Y) или свернем в другую сторону? '
    r_choose = gets.strip.upcase
    case r_choose
    when 'Y'
      zombie_knight = 1
      puts 'Это рыцарь-зомби, приготовься к сложному бою'
      @enemy = Enemy.new("Рыцарь-зомби")
    else
      puts 'Правильный выбор, выглядело опасно'
      puts '-' * 40
      enemy_rand = rand(1..12) + rand(0..leveling)
    end
  else
    enemy_rand = rand(1..12) + rand(0..leveling)
  end

  # Выбор стандартного противника
  if zombie_knight != 1
    if enemy_rand > 0 and enemy_rand <= 5
      @enemy = Enemy.new("Оборванец")
    elsif enemy_rand > 5 and enemy_rand <= 10
      @enemy = Enemy.new("Бешеный пес")
    elsif enemy_rand > 10 and enemy_rand <= 15
      @enemy = Enemy.new("Гоблин")
    elsif enemy_rand > 15 and enemy_rand <= 20
      @enemy = Enemy.new("Бандит")
    elsif enemy_rand > 20 and enemy_rand <= 25
      @enemy = Enemy.new("Дезертир")
    elsif enemy_rand > 25 #and enemy_rand <= 30
      @enemy = Enemy.new("Орк")
    end
  end

  #--------------------------------------------------------------------------------------------------------------------

  InfoBlock.enemy_start_stats_info(@enemy)

  # Ход боя ===============================================================================================
  run = false
  lap = 1 # номер хода

  while @enemy.hp > 0 and run == false

    puts "====================================== ХОД #{lap} ============================================"

    # Расчет базового урона----------------------------------------------------------------------------------------
    damage_pl = rand(@hero.mindam_pl..@hero.maxdam_pl)

    damage_en = rand(@enemy.min_dmg..@enemy.max_dmg)
    #----------------------------------------------------------------------------------------------------------

    # Выбор вида атаки ------------------------------------------------------------------------------------
    cant_do = 0
    while cant_do == 0
      cant_do += 1
      print 'Атакуйте! 1.По телу(B) 2.По голове(H) 3.По ногам(L) 4.Навык(S) '
      target_pl = gets.strip.upcase
      target_name_pl = "по телу"
      case target_pl
      when 'H'
        damage_pl *= 1.5
        accuracy_action_pl = @hero.accuracy_pl * 0.7
        target_name_pl = "по голове"
      when 'L'
        damage_pl *= 0.7
        accuracy_action_pl = @hero.accuracy_pl * 1.5
        target_name_pl = "по ногам"
      when 'S'
        if @hero.mp_pl >= @hero.active_skill.mp_cost
          damage_pl *= @hero.active_skill.damage_mod
          accuracy_action_pl = @hero.accuracy_pl * @hero.active_skill.accuracy_mod
          target_name_pl = @hero.active_skill.name
          @hero.mp_pl -= @hero.active_skill.mp_cost
        else
          puts "Недостаточно маны на #{@hero.active_skill.name}"
          cant_do -= 1
        end
      else
        accuracy_action_pl = @hero.accuracy_pl
      end
    end
    # -----------------------------------------------------------------------------------------------------

    # Направление атаки бота ----------------------------------------------------------------------------
    target_en = rand(1..10)
    name_target_en = "по телу"
    if target_en >= 1 and target_en <= 3
      damage_en *= 1.5
      accurasy_action_en = @enemy.accuracy * 0.7
      name_target_en = "по голове"
    elsif target_en >= 4 and target_en <= 6
      damage_en *= 0.7
      accurasy_action_en = @enemy.accuracy * 1.5
      name_target_en = "по ногам"
    else
      accurasy_action_en = @enemy.accuracy
    end
    #-----------------------------------------------------------------------------------------------------------
    puts '-----------------------------------------------------------------------------------------'

    # Расчет блока щитом --------------------------------------------------------------------------------------------
    if @name_passive_pl == "Мастер щита" and @hero.shield.name != "без щита"
      @hero.block_pl = @hero.shield.block_chance + @coeff_passive_pl
    end

    chanse_block_pl = rand(1..100)
    if @hero.block_pl >= chanse_block_pl
      damage_en /= 1 + @hero.hp_pl.to_f / 200
    end

    chanse_block_en = rand(1..100)
    if @enemy.block_chance >= chanse_block_en
      damage_pl /= 1 + @enemy.hp.to_f / 200
    end
    # ---------------------------------------------------------------------------------------------------------------

    # Расчет итогового урона-----------------------------------------------------------------------------------------
    damage_pl -= @enemy.armor
    if damage_pl < 0
      damage_pl = 0
    end

    damage_en -= @hero.armor_pl
    if damage_en < 0
      damage_en = 0
    end
    #----------------------------------------------------------------------------------------------------------------

    # Расчет попадания/промаха и проведения атак и навыков -----------------------------------------------------
    if accuracy_action_pl >= rand(1..100)
      puts "#{@enemy.name} заблокировал #{100 - (100 / (1 + @enemy.hp.to_f / 200)).to_i}% урона" if @enemy.block_chance >= chanse_block_en
      @enemy.hp -= damage_pl
      puts "Вы нанесли #{damage_pl.round} урона #{target_name_pl}"
      hit_miss_pl = 1
    else
      puts "Вы промахнулись #{target_name_pl}"
      hit_miss_pl = 0
    end

    case @name_passive_pl
    when "Ошеломление"
      if hit_miss_pl == 1 and damage_pl * @coeff_passive_pl > (@enemy.hp + damage_pl) / 2
        accurasy_action_en *= 0.1*rand(1..9)
        puts "атака ошеломила врага, уменьшив его точность до #{(@enemy.accuracy * 0.1 * rand(1..9)).round}"
      end
    when "Концентрация"
      if hit_miss_pl == 1 and damage_passive_pl > 0
        damage_passive_pl = rand(0..0.1 * (@hero.mp_max_pl * (1 + 0.05 * @lvl_passive_pl) - 100))
        @enemy.hp -= damage_passive_pl
        puts "дополнительный урон от концентрации #{damage_passive_pl.round(1)}"
      end
    end

    if accurasy_action_en >= rand(1..100)
      puts "Вы заблокировали #{100 - (100 / (1 + @hero.hp_pl.to_f / 200)).to_i}% урона" if @hero.block_pl >= chanse_block_pl
      @hero.hp_pl -= damage_en
      puts "#{@enemy.name} нанес #{damage_en.round} урона #{name_target_en}"
      hit_miss_en = 1
    else
      puts "#{@enemy.name} промахнулся #{name_target_en}"
      hit_miss_en = 0
    end
    #------------------------------------------------------------------------------------------------------------------

    # Доп эффекты(регенерация)------------------------------------------------------------------------------
    @hero.regeneration_hp_mp
    #---------------------------------------------------------------------------------------------------------------

    # Результат обмена ударами --------------------------------------------------------------------------------
    if @hero.hp_pl > 0 and @enemy.hp > 0
      puts "У вас осталось #{@hero.hp_pl.round}/#{@hero.hp_max_pl} жизней и #{@hero.mp_pl.round}/#{@hero.mp_max_pl} выносливости, у #{@enemy.name}а осталось #{@enemy.hp.round} жизней."
    elsif @hero.hp_pl > 0 and @enemy.hp <= 0
      puts "У вас осталось #{@hero.hp_pl.round}/#{@hero.hp_max_pl} жизней и #{@hero.mp_pl.round}/#{@hero.mp_max_pl} выносливости, у #{@enemy.name}а осталось #{@enemy.hp.round} жизней."
      puts "#{@enemy.name} убит, победа!!!"
    elsif @hero.hp_pl <= 0
      puts "Ты убит - слабак!"
      exit
    end
    #------------------------------------------------------------------------------------------------------------------

    # Побег ---------------------------------------------------------------------------------------------------
    if @hero.hp_pl < (@hero.hp_max_pl * 0.15) and @hero.hp_pl > 0 and @enemy.hp > 0
      print 'Ты на пороге смерти. Чтобы убежать введи Y : '
      run_select = gets.strip.upcase
      if run_select == 'Y'
        run_chance = rand(0..2)
        if run_chance >= 1
          puts "Сбежал ссыкло, штраф 5 опыта"
          @hero.exp_pl -= 5
          run = true
        else
          @hero.hp_pl -= damage_en
          puts "Не удалось убежать #{@enemy.name} нанес #{damage_en.round} урона"
          if @hero.hp_pl <= 0
            puts "Ты убит - трусливая псина!"
            exit
          end
          run = false
        end
      end
    end
    #-----------------------------------------------------------------------------------------------------------------

    lap += 1 # номер хода

  end
  #===================================================================================================================

  puts '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'

  # Сбор лута-----------------------------------------------------------------------------------------------------
  if run == false
    EnemyLoot.new(@hero, @enemy).looting
    FieldLoot.new(@hero).looting
    SecretLoot.new(@hero).looting

    @hero.block_pl = @hero.shield.block_chance
  end
  #-------------------------------------------------------------------------------------------------------------
  puts
  # Получение опыта и очков -------------------------------------------------------------------------------------
  @hero.add_exp_and_hero_level_up(@enemy.exp_gived)
  #-----------------------------------------------------------------------------------------------------------------

  puts '-------------------------------------------------------------------------------------------------'
  leveling += 1
end
#====================================================================================================================












#
