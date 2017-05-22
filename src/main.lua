
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

    local sharedFileUtils = cc.FileUtils:getInstance()
    sharedFileUtils:addSearchPath("src")
    sharedFileUtils:addSearchPath("res")
    sharedFileUtils:addSearchPath("res/Font")
    sharedFileUtils:addSearchPath("res/Music")

    local director = cc.Director:getInstance()

    cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(320, 480, cc.ResolutionPolicy.FIXED_WIDTH)

    cc.Director:getInstance():setAnimationInterval(1.0 / 60)
    cc.Director:getInstance():setDisplayStats(false)

    -- for anysdk
    require "anysdkConst"

    local agent = AgentManager:getInstance()
    --init
    local appKey = "CED525C0-8D41-F514-96D8-90092EB3899A";
    local appSecret = "a29b4f22aa63b8274f7f6e2dd5893d9b";
    local privateKey = "963C4B4DA71BC51C69EB11D24D0C7D49";

    local oauthLoginServer = "http://oauth.anysdk.com/api/OauthLoginDemo/Login.php";
    agent:init(appKey,appSecret,privateKey,oauthLoginServer)

    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if targetPlatform ~= cc.PLATFORM_OS_ANDROID then
        --load
        --Android建议在onCreate里调用PluginWrapper.loadAllPlugins();来进行插件初始化
        agent:loadAllPlugins()
    end
    -- anysdk end

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
