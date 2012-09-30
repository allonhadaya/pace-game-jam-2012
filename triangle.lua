module("triangle", package.seeall)

local triangleSide = 40
local hOffset = triangleSide / 2
local vOffset = hOffset * math.pow(3, 0.5)
local clickRadius = math.pow(math.pow(hOffset - 0, 2) + math.pow(vOffset - hOffset, 2), 0.5)

local index = 1

x = 0
y = 0

function new(arg)
	local obj = arg or {}
	setmetatable(obj, { __index = _M })
	obj:init()
	return obj
end

function init(self)
	
	self:randomizeColor()
	
	self.y = self.y + vOffset / 2
	self.touched = false
	self.type = "triangle"
	self.index = index
	
	self.body = p.newBody(world, self.x, self.y)
	self.shape = p.newPolygonShape(0, 0, hOffset, vOffset, -hOffset, vOffset)
	self.fixture = p.newFixture(self.body, self.shape)
	self.fixture:setUserData(self)
	
	index = index + 1
end

function draw(self)
	local c = 255 * self.color
	g.setColor(c, c, c)
	g.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
end

function randomizeColor(self)
	self.color = math.random(2) - 1
end

function flipColor(self)
	self.color = math.abs(self.color - 1)
end

function isClicked(self, x, y)
	return distance(x, y, self.x, self.y + hOffset) < clickRadius
end

function resolveCollision(self, other, winRound, loseRound)
	other:resolveCollision(self, winRound, loseRound)
end

function distance(x1, y1, x2, y2)
	return math.pow(math.pow(x2 - x1, 2) + math.pow(y2 - y1, 2), 0.5)
end

