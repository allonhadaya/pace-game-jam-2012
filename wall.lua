module("wall", package.seeall)

function new(arg)
	local obj = arg or {}
	setmetatable(obj, { __index = _M })
	obj:init()
	return obj
end

function init(self)
	self.fixture = p.newFixture(body, self.shape)
	self.fixture:setUserData(self)
	self.touched = false
end

function resolveCollision(self, other, winRound, loseRound)
	other:resolveCollision(self, winRound, loseRound)
end
