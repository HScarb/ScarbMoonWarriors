--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

Enemy = class("Enemy", function()
    return cc.Sprite:create()
end)

function Enemy:create(enemyType)
    local enemy = Enemy.new(enemyType)
    return enemy
end

function Enemy:ctor(enemyType)
    self.HP = enemyType.HP                      -- 血量
    self.power = enemyType.power                -- 战力大小
    self.moveType = enemyType.moveType          -- 移动方式
    self.scoreValue = enemyType.scoreValue      -- 获得分数
    self.bulletType = enemyType.bulletType      -- 子弹类型
    self.textureName = enemyType.textureName    -- 敌人图片资源

    self.active = true
    self.speed = 220
    self.bulletSpeed = -200
    self.bulletPowerValue = 1
    self.delayTime = 1 + 1.2 * math.random()        -- 射击延迟

    -- 加载敌机图片
    local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(self.textureName)
    self:setSpriteFrame(frame)

    self.size = self:getContentSize()

    -- 射击子弹
    local function shoot()
        self:shoot()
    end

    schedule(self, shoot, self.delayTime)

    self:setPhysicsBody(cc.PhysicsBody:createBox(self:getContentSize()))
    self:getPhysicsBody():setCategoryBitmask(ENEMY_CATEGORY_MASK)
    self:getPhysicsBody():setCollisionBitmask(ENEMY_COLLISION_MASK)
    self:getPhysicsBody():setContactTestBitmask(ENEMY_CONTACTTEST_MASK)
end

function Enemy:shoot()
--[[
    if nil == self then
        return
    end
    --]]
    print("Enemy: ", self)
    if nil == enemy_bullet then
        return
    end
    local pos = cc.p(self:getPosition())
    local bullet = Bullet:create(self.bulletSpeed, self.bulletType, 1, ENEMY_BULLET_TYPE)

    table.insert(enemy_bullet, bullet)
    self:getParent():addChild(bullet, 5, 902)
    bullet:setPosition(cc.p(pos.x, pos.y - self.size.height * 0.2))
end

-- 摧毁
function Enemy:destroy()
    -- 播放音效
    if Global:getInstance():getAudioState() == true then
        cc.SimpleAudioEngine:getInstance():playEffect("Music/explodeEffect.mp3")
    end

    -- 爆炸+闪烁特效
    Effect:getInstance():explode(self:getParent(), cc.p(self:getPosition()), self.power)
    Effect:getInstance():spark(self:getParent(), cc.p(self:getPosition()), self.power * 3.0, 0.7)

    -- 得分
    Global:getInstance():setScore(self.scoreValue)

    -- 移除
    for i, v in pairs(enemy_items) do
        if v == self then
            table.remove(enemy_items, i)
        end
    end
    self:runAction(cc.RemoveSelf:create())
end

-- 受伤
function Enemy:hurt(damageValue)
    self.HP = self.HP - damageValue
    if self.HP <= 0 then
        self.active = false
    end
end

-- 是否活跃
function Enemy:getIsActive()
    return self.active
end

--endregion
