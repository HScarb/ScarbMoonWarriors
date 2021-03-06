--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

GameScene = class("GameScene", function()
    local scene = cc.Scene:createWithPhysics()

    -- 不受重力影响
    scene:getPhysicsWorld():setGravity(cc.p(0, 0))
    return scene
end)

function GameScene:create()
    local scene = GameScene.new()
    local gameLayer = require("GameLayer"):create()

    scene:addChild(gameLayer)
    return scene
end

return GameScene

--endregion
