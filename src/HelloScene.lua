
HelloScene = class("HelloScene", function()
	return cc.Scene:create()
end)

function HelloScene:create()
	local scene = HelloScene.new()
	scene:addChild(scene:createLayer())
	return scene
end

function HelloScene:ctor()

end

function HelloScene:createLayer()
	local layer = cc.Layer:create()

	local function toLoadingScene()
        -- local scene = require("LoadingScene")
		local loadingScene = require("LoadingScene"):create()
		local tf = cc.TransitionFade:create(0.1, loadingScene)
		cc.Director:getInstance():replaceScene(loadingScene)
	end

	local sp = cc.Sprite:create("HelloWorld.png")
	sp:setPosition(cc.p(WIN_SIZE.width / 2, WIN_SIZE.height / 2))
	layer:addChild(sp)
	--layer:setVisible(false)

	local fadein = cc.FadeIn:create(1)
	local fadeout = cc.FadeOut:create(1)
	local changeScene = cc.CallFunc:create(toLoadingScene, {x = 1, y = 1})
	local seq = cc.Sequence:create(fadein, fadeout, changeScene)
	sp:runAction(seq)

	return layer
end

return HelloScene