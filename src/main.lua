
cc.FileUtils:getInstance():setPopupNotify(false)

require "config"
require "cocos.init"

cclog = function(...)
    print(string.format(...))
end

local function main()
    collectgarbage("collect")
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)

    local director = cc.Director:getInstance()

    cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(320, 480, cc.ResolutionPolicy.FIXED_WIDTH)

    cc.Director:getInstance():setAnimationInterval(1.0 / 60)
    cc.Director:getInstance():setDisplayStats(false)

    ORIGIN = cc.Director:getInstance():getVisibleOrigin()
    VISIBLE_SIZE = cc.Director:getInstance():getVisibleSize()
    WIN_SIZE = cc.Director:getInstance():getWinSize()

    local scene = require("HelloScene")
    local helloScene = scene.create()

    if director:getRunningScene() then
    	director:replaceScene(helloScene)
    else
    	director:runWithScene(helloScene)
    end
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
