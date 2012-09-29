module("ball", package.seeall)

local initialY
local radius = 10
local restitution = 0.6

local index = 0

function new(arg)
	local obj = arg or {}
	setmetatable(obj, { __index = _M })
	obj:init()
	return obj
end

function init(self)
	
	index = index + 1

	self.body = p.newBody(world, math.random() * w, initialY, "dynamic")
	self.shape = p.newCircleShape(radius)
	self.color = math.random(2) - 1
	self.lost = false
	self.destroyed = false
	self.touched = false
	self.index = index
	self.explodeSound = love.audio.newSource("ball_explode.wav")

	self.fixture = p.newFixture(self.body, self.shape, 1)
	self.fixture:setUserData(self)
	self.fixture:setRestitution(restitution)
	
	return self
end

function draw(self)
	if not self.lost then
		local c = 255 * self.color
		g.setColor(c, c, c)
		g.circle("fill", self.body:getX(), self.body:getY(), self.shape:getRadius())
	end
end

function resolveCollision(self, other, winRound, loseRound)
	if not self.touched and self.index == index then
		if other.type == "triangle" and self.color ~= other.color then
			loseRound()
			self.touched = true
			self.lost = true
			love.audio.play(self.explodeSound)
		elseif other.type == "bottom" then
			winRound()
			self.touched = true
		end
	end
end
