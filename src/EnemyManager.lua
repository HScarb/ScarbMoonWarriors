--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

require("Enemy")

EnemyManager = class("EnemyManager", function()
    return cc.Node:create()
end)

function EnemyManager:ctor(gamelayer)
    self.enemies = Global:getInstance():getEnemies()
    self.enemyTypes = Global:getInstance():getEnemyType()
    self.gameLayer = gamelayer
end

function EnemyManager:create(gamelayer)
    local manager = EnemyManager.new(gamelayer)

    return manager
end

-- 敌机刷新
function EnemyManager:updateEnemy(dt)
    -- 最多出现10个敌人
    -- 如果管理器内没有敌人，而且目前屏幕上敌人数量大于10则不刷出
    if nil == self.enemies or table.maxn(enemy_items) >= 10 then
        return
    end
    for i, enemy in pairs(self.enemies) do
        if enemy.showType == "Repeat" then
            -- 每隔showtime时间，第i类敌人刷新一次
            if dt % enemy.showTime == 0 then
                for j = 1, 3 do
                    self:addEnemy(enemy.types[j])
                end
            end
        end
    end
end

-- 添加敌机到管理器内列表
function EnemyManager:addEnemy(type)
    -- 按类型创建敌机
    local enemy = Enemy:create(self.enemyTypes[type])    

    -- 设置位置
    local pos = cc.p(80 + 160 * math.random(), WIN_SIZE.height)
    enemy:setPosition(pos)

    -- 敌人移动轨迹
    local offset = nil
    local action0, action1, delay = nil, nil, nil
    local callfunc = nil
    local tempseq = nil

    local function repeatFollow(sender)
        self:actionFollow(sender)
    end
    local function repeatBezier(sender)
        self:actionBezier(sender)
    end
    local function repeatHorizontal(sender)
        self:actionHorizontal(sender)
    end

    if enemy.moveType == 1 then
        -- 跟随飞机移动
        if nil ~= self.gameLayer:getShip() then
            offset = cc.p(self.gameLayer:getShip():getPosition())
        else
            offset = cc.p(WIN_SIZE.width / 2, 60)
        end
        callfunc = cc.CallFunc:create(repeatFollow)
        tempseq = cc.Sequence:create(cc.MoveTo:create(2.0, offset), func)
    elseif enemy.moveType == 2 then
        -- 圆周运动，贝塞尔曲线
        action0 = cc.MoveTo:create(1.0, cc.p(WIN_SIZE.width / 2, WIN_SIZE.height - 100))
        delay = cc.DelayTime:create(2.0)
        callfunc = cc.CallFunc:create(repeatBezier)
        tempseq = cc.Sequence:create(action0, callfunc)
    elseif enemy.moveType == 3 then
        -- 左右运动
        offset = cc.p(0, -100, -200 * math.random())
        action0 = cc.MoveBy:create(1.0, offset)
        action1 = cc.MoveBy:create(1.0, cc.p(-80 * math.random(), 0))
        callfunc = cc.CallFunc:create(repeatHorizontal)
        tempseq = cc.Sequence:create(action0, action1, callfunc)
    elseif enemy.moveType == 4 then
        -- 向下移动
        local newX = 300
        if enemy:getPositionX() > WIN_SIZE.width / 2 then
            newX = -300
        end
        action0 = cc.MoveBy:create(4, cc.p(newX, -100))
        action1 = cc.MoveBy:create(4, cc.p(-newX, -100))
        tempseq = cc.Sequence:create(action0, action1)
    end

    -- 添加到游戏层中
    table.insert(enemy_items, enemy)
    self.gameLayer:addChild(enemy, enemy.moveType + 10, 1002)
    enemy:runAction(tempseq)
end

-- 跟随动作
function EnemyManager:actionFollow(sender)
    local offset = nil
    if nil ~= self.gameLayer:getShip() then
        offset = cc.p(self.gameLayer:getShip():getPosition())
    else
        offset = cc.p(WIN_SIZE.width / 2, 60)
    end

    local function repeatFollow(sender)
        self:actionFollow(sender)
    end

    local delay = cc.DelayTime:create(1.0)
    local mv = cc.MoveTo:create(2.0, offset)
    local callfunc = cc.CallFunc:create(repeatFollow)
    sender:runAction(cc.Sequence:create(mv, delay, callfunc))
end

-- 圆周运动，贝塞尔曲线
function EnemyManager:actionBezier(sender)
    local sgn = 1
    if math.random(1, 2) == 2 then
        sgn = -1
    end

    local dt = 2.0 + 2.0 * math.random()
    local dx = 100 + 100 * math.random()
    local dy = 100 + 100 * math.random()

    local bezier = {
        cc.p(sgn * dx, 0), 
        cc.p(sgn * dx, -dy),
        cc.p(0, -dy)
    }
    local bezier2 = {
        cc.p((-sgn) * dx, 0),
        cc.p((-sgn) * dx, dy),
        cc.p(0, dy)
    }

    local b0 = cc.BezierBy:create(dt, bezier)
    local b1 = cc.BezierBy:create(dt, bezier2)
    local seq = cc.Sequence:create(b0, b1)
    sender:runAction(cc.RepeatForever:create(seq))
end

-- 左右运动
function EnemyManager:actionHorizontal(sender)
    local mv = cc.MoveBy:create(1.0, cc.p(100 + 100 * math.random(), 0))
    local delay = cc.DelayTime:create(1.0)
    local seq = cc.Sequence:create(delay, mv, delay:clone(), mv:reverse())
    local act = cc.RepeatForever:create(seq)

    sender:runAction(act)
end

--endregion
