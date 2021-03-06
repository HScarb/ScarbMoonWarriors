--region *.lua
--Date 5/13/2017
--此文件由[BabeLua]插件自动生成

AboutScene = class("AboutScene", function()
    return cc.Scene:create()
end)

function AboutScene:ctor()
end

function AboutScene:create()
    local scene = AboutScene.new()
    scene:addChild(AboutScene:createLayer())
    return scene
end

function AboutScene:createLayer()
    local layer = cc.Layer:create()

    -- 背景
    local bg = cc.Sprite:create("loading.png")
    bg:setPosition(cc.p(WIN_SIZE.width / 2, WIN_SIZE.height / 2))
    layer:addChild(bg, 0, 1)

    -- 标题
    local title = cc.Sprite:create("menuTitle.png", cc.rect(0, 36, 100, 34))
    title:setPosition(cc.p(WIN_SIZE.width / 2, WIN_SIZE.height - 60))
    layer:addChild(title)

    -- 内容
    local aboutLabel = cc.Label:createWithSystemFont(
        "游戏名:\tMoon Warriors\n\n\n开发者:\t金甲虫\n\n\n杭州电子科技大学",
        "Arial", 18, cc.size(WIN_SIZE.width / 2, WIN_SIZE.height / 2)
    )
    aboutLabel:setPosition(cc.p(WIN_SIZE.width / 2, WIN_SIZE.height / 2))
    layer:addChild(aboutLabel)

    -- 返回菜单
    local function turnToLoadingScene()
        self:turnToLoadingScene()
    end

    local backlb = cc.Label:createWithBMFont("Font/bitmapFontTest.fnt", "Go Back")
    local pback = cc.MenuItemLabel:create(backlb)
    pback:setScale(0.6)
    pback:registerScriptTapHandler(turnToLoadingScene)

    local pmenu = cc.Menu:create(pback)
    pmenu:setPosition(WIN_SIZE.width / 2, 50)
    layer:addChild(pmenu)

    -- 按钮闪动动画
    -- 按钮闪动Action
    local fadeIn = cc.FadeTo:create(1.0, 255)
    local delay = cc.DelayTime:create(0.5)
    local fadeOut = cc.FadeTo:create(1.0, 50)
    local seq = cc.Sequence:create(fadeIn, delay, fadeOut)
    local act = cc.RepeatForever:create(seq)
    pback:runAction(act)

    return layer
end

function AboutScene:turnToLoadingScene()
    local loadingScene = LoadingScene:create()
    local trans = cc.TransitionPageTurn:create(0.5, loadingScene, true)
    cc.Director:getInstance():replaceScene(trans)
end

return AboutScene

--endregion
