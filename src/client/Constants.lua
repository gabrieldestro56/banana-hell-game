local Constants = {

    Subscriptions = {},

    Game = {
        CURRENT_BOSS = "None",
        STAGE = 1,
        PAUSE = false,
        MONKEYS_KILLED = 0,
        FARMERS_KILLED = 0,
        HAS_DEFEATED_MONKEY_KING = false,
        IS_VICTORY = false,
    },

    Player = {
        
        Banana = game.Workspace:WaitForChild("Banana"),

        MOVE_SPEED = 50,
        STUDS_ABOVE = 20,

        Level = 1,
        EXP = 0,
        Health = 3,

        Score = 0,

        IS_INVULNERABLE = false,
        Skill = "None",
        SkillTimestamp = os.clock(),

        IN_GAME = false,
    },

    LevelCaps = {
        500,
        1000,
        2000,
    },

    Weapon = {
        BULLET_SPEED = 200,
        BULLET_DAMAGE = 10,
        BULLET_PENETRATION = 1,
        BULLET_LIFETIME = 5,
        BULLET_NAME = "Bullet",
        BULLET_KNOCKBACK = 50,
        BULLET_INTERVAL = 0.25,
        BULLET_COUNT = 1,

        LAST_SHOT = os.clock(),
    },

    Enemy = {
        Monkey = {
            HEALTH = 50,
            MOVE_SPEED = 10,
            SCORE = 10,
        },
        Farmer = {
            HEALTH = 75,
            MOVE_SPEED = 15,
            SCORE = 20,
        }
    },

    EXP = {
        Monkey = 50,
        Farmer = 75,
        KingMonkey = 500,
        FarmLeader = 750,
    }, 

    Boss = {
        KingMonkey = {
            HEALTH = 1000,
            LEAP_INTERVAL = 2,
            LEAP_DURATION = 2,
            LEAP_ATTACK_SIZE = 20,
            SCORE = 20,
        },
        FarmLeader = {
            HEALTH = 2000,
            SHOOT_INTERVAL = 1,
            BOMB_INTERVAL = 2,
            LEAP_ATTACK_SIZE = 20,
            SCORE = 50,
            MOVE_SPEED = 20,
            BULLET_SIZE = 2,
        },
    },

    Spawn = {
        CAN_SPAWN = false,
        SPAWN_RADIUS = 50,  
        SPAWN_INTERVAL = 1,     
        MAX_ENEMIES = 30, 

        CURRENT_ENEMY = "Monkey",
    },
}

function Constants:ChangeValue(value: string)

    if not self.Subscriptions[value] then
        return false
    end

    for _ , callback in self.Subscriptions[value] do
        callback()
    end

    return
end

function Constants:SubscribeToValue(value: string, callback)
    self.Subscriptions[value] = self.Subscriptions[value] or {}
    table.insert(self.Subscriptions[value], callback)
end

return Constants