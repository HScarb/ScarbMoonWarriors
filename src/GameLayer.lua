--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require("Fighter")
require("EnemyManager")

GameLayer = class("GameLayer", function()
    return cc.Layer:create()
end)

function GameLayer:ctor()
    self.GAMESTATE_PLAYING = 0
    self.GAMESTATE_OVER = 1

    self.gameState = nil
    self.gameTime = nil
    self.lbScore = nil
    self.lbLifeCount = nil
    self.sliderLife = nil

    self.ship = nil
    self.enemyManager = nil

    self:loadingMusic()         -- 背景音乐
    self:addBG()                -- 初始化背景
    self:moveBG()               -- 背景移动
    self:addBtn()               -- 游戏暂停按钮
    self:addSchedule()          -- 更新
    self:addTouch()             -- 触摸
    self:addContact()           -- 碰撞检测

    Global:getInstance():resetGame()        -- 初始化全局变量
    self:initGameState()                    -- 初始化游戏数据状态
    self:initShip()                         -- 初始化主机
    self:initEnemy()                        -- 初始化敌机
end

function GameScene:create()
    local layer = GameLayer.new()
    
    return layer
end

-- 播放音乐
function GameLayer:loadingMusic()
    if Global:getInstance():getAudioState() == true then
        cc.SimpleAudioEngine:getInstance():stopMusic()
        cc.SimpleAudioEngine:getInstance():playMusic("Music/bgMusic.mp3", true)
    else
        cc.SimpleAudioEngine:getInstance():stopMusic()
    end
end

-- 添加背景
function GameLayer:addBG()
    self.bg1 = cc.Sprite:create("bg01.jpg")
    self.bg2 = cc.Sprite:create("bg01.jpg")
    self.bg1:setAnchorPoint(cc.p(0, 0))
    self.bg2:setAnchorPoint(cc.p(0, 0))
    self.bg1:setPosition(0, 0)
    self.bg2:setPosition(0, self.bg1:getContentSize().height)
    self:addChild(self.bg1, -10)
    self:addChild(self.bg2, -10)
end

-- 背景滚动
function GameLayer:moveBG()
    local height = self.bg1:getContentSize().height
    local function updateBG()
        self.bg1:setPositionY(self.bg1:getPositionY() - 1)
        self.bg2:setPositionY(self.bg1:getPositionY() + height)
        if self.bg1:getPositionY() <= -height then
            self.bg1, self.bg2 = self.bg2, self.bg1
            self.bg2:setPositionY(WIN_SIZE.height)
        end
    end
    schedule(self, updateBG, 0)
end

-- 添加按钮
function GameLayer:addBtn()
    local function PauseGame()
        self:PauseGame()
    end
    local pause = cc.MenuItemImage:create("pause.png", "pause.png")
    pause:setAnchorPoint(cc.p(1, 0))
    pause:setPosition(cc.p(WIN_SIZE.width, 0))
    pause:registerScriptTapHandler(PauseGame)

    local menu = cc.Menu:create(pause)
    menu:setPosition(cc.p(0, 0))
    self:addChild(menu, 1, 10)
end

-- 更新
function GameLayer:addSchedule()
    -- 更新UI
    local function updateGame()
        self:updateGame()
    end
    schedule(self, updateGame, 0)

    -- 更新时间
    local function updateTime()
        self:updateTime()
    end
    schedule(self, updateTime, 1)
end

-- 触摸事件
function GameLayer:addTouch()
    -- 触摸开始
    local function touchBegan(touch, event)
        print("touch began")
        return true
    end

    local function touchMoved(touch, event)
        if self.gameState == self.GAMESTATE_PLAYING then
            if nil ~= self.ship then
                local deltaPos = touch:getDelta()
                local currentPos = cc.p(self.ship:getPosition())
                currentPos = cc.pAdd(currentPos, deltaPos)
                currentPos = cc.pGetClampPoint(currentPos, cc.p(0, 0), cc.p(WIN_SIZE.width, WIN_SIZE.height))
                self.ship:setPosition(currentPos)
            end
        end
    end

    -- 注册触摸
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(touchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(touchMoved, cc.Handler.EVENT_TOUCH_MOVED)

    local dispatcher = self:getEventDispatcher()
    dispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

-- 初始化游戏数据状态
function GameLayer:initGameState()
    -- 游戏状态
    self.gameState = self.GAMESTATE_PLAYING

    -- 游戏时间
    self.gameTime = 0

    -- 分数Label
    self.lbScore = cc.Label:createWithBMFont("Font/arial-14.fnt", "Score:000000")
    self.lbScore:setAnchorPoint(cc.p(0, 0))
    self.lbScore:setPosition(WIN_SIZE.width - 100, WIN_SIZE.height - 30)
    self.lbScore:setAlignment(cc.TEXT_ALIGNMENT_RIGHT)
    self:addChild(self.lbScore, 1000)

    -- 飞机生命图片
    local life = cc.Sprite:create("ship01.png", cc.rect(0, 0, 60, 38))
    life:setScale(0.6)
    life:setPosition(cc.p(30, WIN_SIZE.height - 23))
    self:addChild(life, 1000)

    -- 飞机生命值Label
    self.lbLifeCount = cc.Label:createWithSystemFont(Global:getInstance():getLifeCount(), "Arial", 20)
    self.lbLifeCount:setPosition(cc.p(60, WIN_SIZE.height - 20))
    self.lbLifeCount:setColor(cc.c3b(255, 0, 0))
    self:addChild(self.lbLifeCount, 1000)

    -- 飞机生命条 ControlSlider
    self.sliderLife = cc.ControlSlider:create("slider_red.png", "slider_gray.png", "slider_thumb.png")
    self.sliderLife:setPosition(cc.p(30 + self.sliderLife:getContentSize().width
        , WIN_SIZE.height - 23))
    self:addChild(self.sliderLife, 1000)
    self.sliderLife:setMinimumValue(0.0)
    self.sliderLife:setMaximumValue(100.0)
end

-- 初始化飞机
function GameLayer:initShip()
    self.ship = Fighter:create()
    self:addChild(self.ship, 0, 1001)
end

function GameLayer:initEnemy()
    self.enemyManager = EnemyManager:create(self)

    -- 不加入层中，好像就调用不了enemyManager的方法
    self:addChild(self.enemyManager)
end

-- 更新时间
function GameLayer:updateTime()
    if self.gameState == self.GAMESTATE_PLAYING then
        self.gameTime = self.gameTime + 1
        self.enemyManager:updateEnemy(self.gameTime)
    end
end

-- 更新游戏
function GameLayer:updateGame()
    if self.gameState == self.GAMESTATE_PLAYING then
        self:removeInactiveUnit()       -- 移除不活跃的元素
        self:checkIsReborn()            -- 检测战机重生或者游戏结束
        self:updateUI()                 -- 刷新UI
    end
end

-- 移除不活跃的元素
function GameLayer:removeInactiveUnit()
    local children = self:getChildren()
    for i, unit in pairs(children) do
        -- 如果是子弹或者敌人
        local tag = unit:getTag()
        if tag == 901 or tag == 902 or tag == 1002 then
            if unit:getIsActive() == false then
                unit:destroy()
            end
        end
    end
    
    -- 飞机死亡
    if nil ~= self.ship then
        if self.ship:getIsActive() == false then
            self.ship:destroy()
            self.ship = nil
        end
    end
end

-- 战机重生 或者游戏结束
function GameLayer:checkIsReborn()
    if Global:getInstance():getLifeCount() >= 0 then
        if nil == self.ship then
            self.ship = Fighter:create()
            self:addChild(self.ship, 0, 1001)
        end
    else
	self.gameState = self.GAMESTATE_OVER
	self:gameOver()
    end
end

-- 刷新UI
function GameLayer:updateUI()
    -- 分数
    local score = Global:getInstance():getScore()
    local sc = string.format("Score:%06d", score)
    self.lbScore:setString(sc)

    -- 生命值
    self.lbLifeCount:setString(Global:getInstance():getLifeCount())

    -- 生命条
    if nil ~= self.ship then
        self.sliderLife:setValue(self.ship.HP * 10.0)
    else
        self.sliderLife:setValue(0.0)
    end
end


-- 游戏暂停
function GameLayer:PauseGame()
    cc.Director:getInstance():pause()
    cc.SimpleAudioEngine:getInstance():pauseMusic()
    cc.SimpleAudioEngine:getInstance():pauseAllEffects()

    local pauseLayer = require("PauseLayer"):create()
    self:addChild(pauseLayer, 9999)
end

-- 游戏继续
function GameLayer:resumeGame()
    cc.Director:getInstance():resume()
    cc.SimpleAudioEngine:getInstance():resumeMusic()
    cc.SimpleAudioEngine:getInstance():resumeAllEffects()
end

-- 游戏结束
function GameLayer:gameOver()
    Global:getInstance():ExitGame()
    -- 结束画面
    local scene = require("GameOverScene"):create()
    local trans = cc.TransitionCrossFade:create(1.0, scene)
    cc.Director:getInstance():replaceScene(trans)
end

-- 获取飞机
function GameLayer:getShip()
    return self.ship
end

-- 添加碰撞检测
function GameLayer:addContact()
    local function onContactBegin(contact)
        local a = contact:getShapeA():getBody():getNode()
        local b = contact:getShapeB():getBody():getNode()
        if nil ~= a and nil ~= b then
            a:hurt(1)
            b:hurt(1)
        end
        return true
    end
    
    local dispatcher = self:getEventDispatcher()
    local contactListener = cc.EventListenerPhysicsContact:create()
    contactListener:registerScriptHandler(onContactBegin, cc.Handler.EVENT_PHYSICS_CONTACT_BEGIN)
    dispatcher:addEventListenerWithSceneGraphPriority(contactListener, self)
end

return GameLayer

--endregion
