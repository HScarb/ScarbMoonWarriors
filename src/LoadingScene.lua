
require("Helper")
require("Global")
require("Effect")

LoadingScene = class("LoadingScene", function()
	return cc.Scene:create()
end)


function LoadingScene:create()
	local scene = LoadingScene.new()
	scene:addChild(scene:createLayer())
	return scene
end

function LoadingScene:ctor()
	
end

function LoadingScene:createLayer()
	local layer = cc.Layer:create()

	self:loadingMusic()
    self:addBg(layer)
    self:addBtn(layer)
    self:addShip(layer)

	return layer
end

function LoadingScene:loadingMusic()
    -- preloadMusic
    if Global:getInstance():getAudioState() == true then
        -- playMusic
        cc.SimpleAudioEngine:getInstance():stopMusic()
        cc.SimpleAudioEngine:getInstance():playMusic("Music/mainMainMusic.mp3", true)
    else
        cc.SimpleAudioEngine:getInstance():stopMusic()
    end
end

function LoadingScene:addBg(layer)
    local bg = cc.Sprite:create("loading.png")
    bg:setPosition(cc.p(WIN_SIZE.width / 2, WIN_SIZE.height / 2))
    layer:addChild(bg, -1, 1)

    -- 添加logo tag = 2
    local logo = cc.Sprite:create("logo.png")
    logo:setPosition(cc.p(WIN_SIZE.width/2, WIN_SIZE.height - 130))
    layer:addChild(logo, 10, 2)
end

function LoadingScene:addBtn(layer)
    local function buttonCallback(tag, menuItem)
        if tag == 101 then
            self:newGame()
        elseif tag == 102 then
            self:turnToOptionScene()
        elseif tag == 103 then
            self:turnToAboutScene()
        elseif tag == 104 then
            self:exit()
        end
    end
    -- 添加按钮
    -- 游戏开始
    local newGameNormal = cc.Sprite:create("menu.png", cc.rect(0, 0, 126, 33))
    local newGameSelected = cc.Sprite:create("menu.png", cc.rect(0, 33, 126, 33))
    local newGameDisabled = cc.Sprite:create("menu.png", cc.rect(0, 33 * 2, 126, 33))
    
    -- 游戏设置
    local gameSettingNormal = cc.Sprite:create("menu.png", cc.rect(126, 0, 126, 33))
    local gameSettingNSelected = cc.Sprite:create("menu.png", cc.rect(126, 33, 126, 33))
    local gameSettingDesabled = cc.Sprite:create("menu.png", cc.rect(126, 33 * 2, 126, 33))
    
    -- 游戏关于
    local aboutNormal = cc.Sprite:create("menu.png", cc.rect(252, 0, 126, 33))
    local aboutSelected = cc.Sprite:create("menu.png", cc.rect(252, 33, 126, 33))
    local aboutDesabled = cc.Sprite:create("menu.png", cc.rect(252, 33 * 2, 126, 33))
    
    -- 游戏关于
    local closeNormal = cc.Sprite:create("menu.png", cc.rect(505, 1, 126, 31))
    local closeSelected = cc.Sprite:create("menu.png", cc.rect(505, 34, 126, 31))
    local closeDesabled = cc.Sprite:create("menu.png", cc.rect(505, 34 * 2, 126, 31))

    -- “游戏”tag = 101
    local newGame = cc.MenuItemSprite:create(newGameNormal, newGameSelected, newGameDisabled)
    newGame:setTag(101)
    newGame:registerScriptTapHandler(buttonCallback)
    
    -- “设置”tag = 102
    local gameSetting = cc.MenuItemSprite:create(gameSettingNormal, gameSettingNSelected, gameSettingDesabled)
    gameSetting:setTag(102)
    gameSetting:registerScriptTapHandler(buttonCallback)
    
    -- “关于”tag = 103
    local aboutBtn = cc.MenuItemSprite:create(aboutNormal, aboutSelected, aboutDesabled)
    aboutBtn:setTag(103)
    aboutBtn:registerScriptTapHandler(buttonCallback)
    
    -- “退出”tag = 104
    local close = cc.MenuItemSprite:create(closeNormal, closeSelected, closeDesabled)
    close:setTag(104)
    close:registerScriptTapHandler(buttonCallback)

    -- 创建菜单
    local pmenu = cc.Menu:create(newGame, gameSetting, aboutBtn, close)
    pmenu:setPosition(cc.p(WIN_SIZE.width / 2, WIN_SIZE.height / 2 - 80))
    layer:addChild(pmenu, 1, 3)
    pmenu:alignItemsVerticallyWithPadding(20)
    
end

function LoadingScene:addShip(layer)
    local ship = cc.Sprite:create("ship01.png", cc.rect(0, 45, 60, 38))
    ship:setPosition(cc.p(0, WIN_SIZE.height + 100))
    layer:addChild(ship, 0, 10)

    local function updateShip()
        if ship:getPositionY() > WIN_SIZE.height then
            ship:stopAllActions()
            ship:setPosition(math.random() * WIN_SIZE.width * 2, 0)
    	    local moveto = cc.MoveTo:create(
    	        math.ceil(4.0*math.random() + 1.0),
    	        cc.p(math.random() * WIN_SIZE.width*2.0, WIN_SIZE.height + 100))
            ship:runAction(moveto)
        end
    end
    schedule(self, updateShip, 0)
end

function LoadingScene:newGame()
    local function toGameScene()
        self:turnToGame()
    end
    local callback = cc.CallFunc:create(toGameScene)
    Effect:getInstance():flareEffect(self, callback)
end

function LoadingScene:turnToGame()
    local gameScene = require("GameScene"):create()
    cc.Director:getInstance():replaceScene(gameScene)
end

function LoadingScene:turnToAboutScene()
    local aboutScene = require("AboutScene"):create()
    local trans = cc.TransitionPageTurn:create(0.5, aboutScene, false)
    cc.Director:getInstance():replaceScene(trans)
end

function LoadingScene:turnToOptionScene()
    local optionScene = require("OptionScene"):create()
    local trans = cc.TransitionPageTurn:create(0.5, optionScene, false)
    cc.Director:getInstance():replaceScene(trans)
end

-- 退出程序
function LoadingScene:exit()
    cc.Director:getInstance():endToLua()
end

return LoadingScene