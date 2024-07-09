require 'yaml'

# engines -----------------------------
require_relative "engines/main"
require_relative "engines/attacks_round"

# renderers ---------------------------
require_relative "renderers/arts/arts"
require_relative "renderers/menues/menues"

# services ----------------------------
# saves
require_relative "services/saves/save_hero"
require_relative "services/saves/load_hero"
# loot
require_relative "services/loot/enemy_loot"
require_relative "services/loot/field_loot"
require_relative "services/loot/secret_loot"

# controllers -------------------------
# ammunition
require_relative "controllers/ammunition/ammunition_creator"
# skills
require_relative "controllers/skills/skills_creator"
# characters
require_relative "controllers/characters/enemy_creator"
require_relative "controllers/characters/hero_creator"
require_relative "controllers/characters/hero_updator"
require_relative "controllers/characters/hero_actions"
require_relative "controllers/characters/hero_use_skill"

# models ------------------------------
# ammunition
require_relative "models/ammunition/arms_armor"
require_relative "models/ammunition/body_armor"
require_relative "models/ammunition/head_armor"
require_relative "models/ammunition/shield"
require_relative "models/ammunition/weapon"
# skills
require_relative "models/skills/concentration"
require_relative "models/skills/dazed"
require_relative "models/skills/first_aid"
require_relative "models/skills/precise_strike"
require_relative "models/skills/shield_master"
require_relative "models/skills/strong_strike"
require_relative "models/skills/treasure_hunter"
# characters
require_relative "models/characters/enemy"
require_relative "models/characters/hero"




# TODO
# вынести методы навыка с выводом сообщений из модели hero в контроллер чето типм хиро_скилл_юзер, ? либо вынести сообщения в данные ?



Main.new.start_game















#