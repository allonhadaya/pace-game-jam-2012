require "triangle"
require "ball"
require "wall"

initialLives = 10

lives = initialLives
points = 0

world = nil

p = love.physics
g = love.graphics

bodyRatio = 0.9
w = 400
h = 800
pitTop = h * bodyRatio
margin  = 20

local currentBall = {}

function love.load()

	g.setBackgroundColor(160, 160, 160)
	p.setMeter(64)	
	world = p.newWorld(0, 3*64, true)
	world:setCallbacks(beginContact, nil, nil, nil)
	
	objects = {
		walls = buildWalls(),
		triangles = buildTriangles(),
		balls = {}
	}
	
	startGame()
end

function beginContact(a, b, coll)
	a:getUserData():resolveCollision(b:getUserData(),winRound,loseRound)
end

function winRound()
	points = points + sameColorTriangles()
	print("Points: " .. points)
	startGame()
end

function sameColorTriangles()
	local result = 0
	for k, v in pairs(objects.triangles) do
		if v.color == currentBall.color then
			result = result + 1
		end
	end
	return result
end

function loseRound()
	lives = lives - 1
	print("Lives Left: " .. lives)
	startGame()
end

function startGame()
	if lives > 0 then
		start = true
	end
end

function buildWalls()
	
	body = p.newBody(world, 0, 0)
	
	local walls = {
		top = wall.new { type = "wall", shape = p.newEdgeShape(0, 0, w, 0) },
		topRight = wall.new { type = "wall", shape = p.newEdgeShape(w, 0, w, pitTop) },
		bottomRight = wall.new { type = "bottom", shape = p.newEdgeShape(w, pitTop, w / 2, h) },
		bottomLeft = wall.new { type = "bottom", shape = p.newEdgeShape(w / 2, h, 0, pitTop) },
		topLeft = wall.new { type = "wall", shape = p.newEdgeShape(0, pitTop, 0, 0) }
	}
	
	return walls
end

function buildTriangles()
	
	local triangles = {}
	
	local triangleOffset = 120
	local rowSpacing = 90
	
	for i = 1, 5, 2 do
		local h1 = rowSpacing * (i - 1) + triangleOffset
		local h2 = rowSpacing * i + triangleOffset
		table.insert(triangles, triangle.new { x = w / 4, y = h1 })
		table.insert(triangles, triangle.new { x = w / 2, y = h1 })
		table.insert(triangles, triangle.new { x = 3 * w / 4, y = h1 })
		table.insert(triangles, triangle.new { x = w / 8, y = h2 })
		table.insert(triangles, triangle.new { x = 3 * w / 8, y = h2 })
		table.insert(triangles, triangle.new { x = 5 * w / 8, y = h2 })
		table.insert(triangles, triangle.new { x = 7 * w / 8, y = h2 })
	end
	
	return triangles
end

function love.mousepressed(x, y, button)
	for k, v in pairs(objects.triangles) do
		if (v:isClicked(x, y)) then
			v:flipColor()
		end
	end
end

function love.update(dt)
	world:update(dt)
	
	destroyLooseBalls()
	
	if start then
		initializeRound()
	end
end

function destroyLooseBalls()
	for k, v in pairs(objects.balls) do
		if not v.destroyed and v.lost then
			v.body:destroy()
			v.destroyed = true
		end
	end
end

function initializeRound()

	currentBall = ball.new {}
	
	table.insert(objects.balls, currentBall)
	
	for k, v in pairs(objects.triangles) do
		v.color = math.random(2) - 1
	end
	
	start = false
end

function love.draw()

	g.setColor(0, 0, 0)
	g.polygon("fill", 0, pitTop, w / 2, h, 0, h)
	g.polygon("fill", w, pitTop, w / 2, h, w, h)
	
	for k, v in pairs(objects.balls) do
		v:draw()
	end
	
	for k, v in pairs(objects.triangles) do
		v:draw()
	end
	
	g.setColor(255, 255, 255)
	
	local message = "Points -- " .. tostring(points) .. "\nLives -- " .. tostring(lives) 
	
	if lives == 0 then
		message = message .. "\n\nGame Over (space to restart)"
	end
	
	g.print(message, margin, margin)
end

function love.keypressed(key)
   if key == " " then
      newGame()
   end
end

function newGame()
	for k, v in pairs(objects.balls) do
		v.lost = true
	end
	lives = initialLives
	points = 0
	startGame()
end
