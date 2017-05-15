--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

require("Bullet")

Fighter = class("Fighter", function()
    return cc.Sprite:create()
end)

function Fighter:ctor()
    -- 初始化属性
    self.active = true
    self.canBeAttack = false
    self.HP = 10
    self.power = 1.0
    self.speed = 220
    self.bulletSpeed = 900
    self.bulletPower = 1
    self.delayTime = 0.1

    -- 初始化
    -- 飞机图片
    local texture = cc.Director:getInstance():getTextureCache():addImage("ship01.png")
    local sp0 = cc.SpriteFrame:createWithTexture(texture, cc.rect(0, 0, 60, 38))
    self:setSpriteFrame(sp0)
    self:setPosition(cc.p(WIN_SIZE.width / 2, 60))
    self.size = self:getContentSize()

    -- 飞机射击动作
    local animation = cc.Animation:create()
    local sp1 = cc.SpriteFrame:createWithTexture(texture, cc.rect(0, 0, 60, 38))
    local sp2 = cc.SpriteFrame:createWithTexture(texture, cc.rect(60, 0, 60, 38))
    animation:setDelayPerUnit(0.1)
    animation:setRestoreOriginalFrame(true)
    animation:addSpriteFrame(sp1)
    animation:addSpriteFrame(sp2)
    self:runAction(cc.RepeatForever:create(cc.Animate:create(animation)))

    -- 初始闪烁不死光环
    self.canBeAttack = false
    local ghostShip = cc.Sprite:create("ship01.png", cc.rect(0, 45, 60, 38))
    ghostShip:setPosition(cc.p(self.size.width / 2, 12))
    self:addChild(ghostShip, 10, 999)

    ghostShip:setScale(8)
    ghostShip:runAction(cc.ScaleTo:create(0.5, 1))

    -- 混合模式
    ghostShip:setBlendFunc(cc.blendFunc(gl.SRC_ALPHA, gl.ONE))

    local function setCanBeAttack(node, tab)
        self.canBeAttack = true
        self:removeChildByTag(999)
    end
    local blink = cc.Blink:create(2, 6)
    local callfunc = cc.CallFunc:create(setCanBeAttack)
    self:runAction(cc.Sequence:create(blink, callfunc))

    -- 射击子弹
    local function shoot()
        self:shoot()
    end
    schedule(self, shoot, self.delayTime)

    self:setPhysicsBody(cc.PhysicsBody:createCircle(self:getContentSize().width / 2))
    self:getPhysicsBody():setCategoryBitmask(PLANE_CATEGORY_MASK)
    self:getPhysicsBody():setCollisionBitmask(PLANE_COLLISION_MASK)
    self:getPhysicsBody():setContactTestBitmask(PLANE_CONTACTTEST_MASK)
end

function Fighter:create()
    local fighter = Fighter.new()
    return fighter
end

-- 射击子弹
function Fighter:shoot()
    local pos = cc.p(self:getPosition())
    local size = self.size

    -- 左边子弹
    local bullet_l = Bullet:create(self.bulletSpeed, "W1.png", 1, PLANE_BULLET_TYPE)
    if nil ~= bullet_l then
        table.insert(player_bullet, bullet_l)
        self:getParent():addChild(bullet_l, 2, 901)
        bullet_l:setPosition(cc.p(pos.x - 13, pos.y + 5 + size.height * 0.3))
    end

    -- 右边子弹
    local bullet_r = Bullet:create(self.bulletSpeed, "W1.png", 1, PLANE_BULLET_TYPE)
    if nil ~= bullet_r then
        table.insert(player_bullet, bullet_r)
        self:getParent():addChild(bullet_r, 2, 901)
        bullet_r:setPosition(cc.p(pos.x + 13, pos.y + 5 + size.height * 0.3))
    end
end

-- 飞机被摧毁
function Fighter:destroy()
    -- 播放音效
    if Global:getInstance():getAudioState() == true then
        cc.SimpleAudioEngine:getInstance():playEffect("Music/shipDestroyEffect.mp3")
    end

    -- 爆炸特效
    Effect:getInstance():explode(self:getParent(), cc.p(self:getPosition()), self.power)

    -- 更新生命值 life = life - 1
    Global:getInstance():setLifeCount()

    -- 移除
    self:removeFromParent()
end

-- 扣血
function Fighter:hurt(damageValue)
    if true == self.canBeAttack then
        self.HP = self.HP - damageValue
        if self.HP <= 0 then
            self.action = false
        end
    end
end

-- 是否可以被攻击
function Fighter:getCanBeAttack()
    return self.canBeAttack
end

-- 是否活着
function Fighter:getIsActive()
    return self.active
end

--endregion
