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
    self.HP = enemyType.HP
    self.power = enemyType.power
    self.moveType = enemyType.moveType
    self.scoreValue = enemyType.scoreValue
    self.bulletType = enemyType.bulletType
    self.textureName = enemyType.textureName

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
        self.shoot()
    end

    schedule(self, shoot, self.delayTime)

    self:setPhysicsBody(cc.PhysicsBody:createBox(self:getContentSize()))
    self:getPhysicsBody():setCategoryBitmask(ENEMY_CATEGORY_MASK)
    self:getPhysicsBody():setCollisionBitmask(ENEMY_COLLISION_MASK)
    self:getPhysicsBody():setContactTestBitmask(ENEMY_CONTACTTEST_MASK)
end

function Enemy:shoot()
    if nil == self then
        return
    end
    if nil == enemy_bullet then
        return
    end

    local pos = cc.p(self:getPosition())
    local bullet = Bullet:create(self.bulletSpeed, self.bulletType, 1, ENEMY_BULLET_TYPE)

    table.insert(enemy_bullet, bullet)
    self:getParent():addChild(bullet, 5, 902)
    bullet:setPosition(cc.p(pos.x, pox.y - self.size.height * 0.2))
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
    self:removeFromParent()
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
