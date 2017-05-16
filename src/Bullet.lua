--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

Bullet = class("Bullet", function()
    return cc.Sprite:create()
end)

function Bullet:ctor(speed, weapon, attackMode, type)
    self.active = true
    self.HP = 1
    self.power = 0.5
    self.vx = 0
    self.vy = -speed
    self.attackmode = attackMode

    -- 设置子弹图片
    -- 通过精灵帧设置
    local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(weapon)
    self:setSpriteFrame(frame)

    -- 混合模式
    self:setBlendFunc(cc.blendFunc(gl.SRC_ALPHA, gl.ONE))

    -- 子弹射出
    local function shoot(dt)
        self:shoot(dt)
    end

    self:scheduleUpdateWithPriorityLua(shoot, 0)

    self:setPhysicsBody(cc.PhysicsBody:createCircle(3, cc.PhysicsMaterial(0.1, 1, 0), cc.p(0, 16)))
    if type == PLANE_BULLET_TYPE then       -- 玩家子弹
        self:getPhysicsBody():setCategoryBitmask(PLANE_BULLET_CATEGORY_MASK)
        self:getPhysicsBody():setCollisionBitmask(PLANE_COLLISION_MASK)
        self:getPhysicsBody():setContactTestBitmask(PLANE_CONTACTTEST_MASK)
    else    -- 敌人子弹
        self:getPhysicsBody():setCategoryBitmask(ENEMY_BULLET_CATEGORY_MASK)
        self:getPhysicsBody():setCollisionBitmask(ENEMY_BULLET_COLLISION_MASK)
        self:getPhysicsBody():setContactTestBitmask(ENEMY_BULLET_CONTACTTEST_MASK)        
    end
end

function Bullet:create(speed, weapon, attackMode, type)
    local bullet = Bullet.new(speed, weapon, attackMode, type)
    return bullet
end

function Bullet:shoot(dt)
    if self.HP <= 0 then
        self.active = false
    end

    local pos = cc.p(self:getPosition())
    pos.x = pos.x - self.vx * dt
    pos.y = pos.y - self.vy * dt
    self:setPosition(pos)

    -- 超出屏幕太多则摧毁子弹
    if pos.y < -10 or pos.y > WIN_SIZE.height + 10 then
        self:unscheduleUpdate()
        self:destroy()
    end
end

-- 摧毁
function Bullet:destroy()
    if nil == play_bullet and nil == enemy_bullet then
        return
    end

    -- 击中飞机特效
    Effect:getInstance():hit(self:getParent(), cc.p(self:getPosition()))

    -- 移除
    for i, v in pairs(play_bullet) do
        if v == self then
            table.remove(play_bullet, i)
        end
    end
    for i, v in pairs(enemy_bullet) do
        if v == self then
            table.remove(enemy_bullet, i)
        end
    end
	self:setVisible(false)
	--self:removeFromParent()
end

-- 受伤
function Bullet:hurt(damageValue)
    self.HP = self.HP - damageValue
    if self.HP <= 0 then
        self.active = false
    end
end

-- 是否活跃
function Bullet:getIsActive()
    return self.active
end

--endregion
