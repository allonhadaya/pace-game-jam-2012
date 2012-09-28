w = 400
h = 800
p = love.physics
g = love.graphics
points = 0

function love.load()
	
	g.setBackgroundColor(160, 160, 160)
	p.setMeter(64)	
	world = p.newWorld(0, 9.815*64, true)
	world:setCallbacks(beginContact, endContact, preSolve, postSolve)
	
	local bodyRatio = 0.9
	pitTop = h * bodyRatio
	
	objects = {}
	
	-- walls
	
	objects.walls = {}
	objects.walls.body = p.newBody(world, 0, 0)
	
	objects.walls.topShape = p.newEdgeShape(0, 0, w, 0)
	objects.walls.rightTopShape = p.newEdgeShape(w, 0, w, pitTop)
	objects.walls.rightBottomShape = p.newEdgeShape(w, pitTop, w / 2, h)
	objects.walls.leftBottomShape = p.newEdgeShape(w / 2, h, 0, pitTop)
	objects.walls.leftTopShape = p.newEdgeShape(0, pitTop, 0, 0)
	
	objects.walls.topFixture = p.newFixture(objects.walls.body, objects.walls.topShape)
	objects.walls.rightTopFixture = p.newFixture(objects.walls.body, objects.walls.rightTopShape)
	objects.walls.rightBottomFixture = p.newFixture(objects.walls.body, objects.walls.rightBottomShape)
	objects.walls.leftTopFixture = p.newFixture(objects.walls.body, objects.walls.leftTopShape)
	objects.walls.leftBottomFixture = p.newFixture(objects.walls.body, objects.walls.leftBottomShape)
	
	objects.walls.topFixture:setUserData({ type = "wall", value = "top"})
	objects.walls.rightTopFixture:setUserData({ type = "wall", value = "right-top"})
	objects.walls.rightBottomFixture:setUserData({ type = "bottom-wall", value = "right-bottom"})
	objects.walls.leftBottomFixture:setUserData({ type = "bottom-wall", value = "left-bottom"})
	objects.walls.leftTopFixture:setUserData({ type = "wall", value = "left-top"})
	
	-- balls
	
	objects.balls = {}
	
	-- triangles
	
	objects.triangles = {}
	
	local triangleOffset = 60
	local rowSpacing = 90
	for i = 1, 5, 2 do
		local h1 = rowSpacing * (i - 1) + triangleOffset
		local h2 = rowSpacing * i + triangleOffset
		table.insert(objects.triangles, makeTriangle(w / 4, h1))
		table.insert(objects.triangles, makeTriangle(w / 2, h1))
		table.insert(objects.triangles, makeTriangle(3 * w / 4, h1))
		table.insert(objects.triangles, makeTriangle(w / 8, h2))
		table.insert(objects.triangles, makeTriangle(3 * w / 8, h2))
		table.insert(objects.triangles, makeTriangle(5 * w / 8, h2))
		table.insert(objects.triangles, makeTriangle(7 * w / 8, h2))
	end
	
	-- start game
	
	startGame()
end

function makeBall(x, y)
	local ball = {}
	
	ball.body = p.newBody(world, x, y, "dynamic")
	ball.shape = p.newCircleShape(10)
	ball.fixture = p.newFixture(ball.body, ball.shape, 1)
	ball.fixture:setUserData({ type = "ball", value = table.getn(objects.balls) + 1 })
	ball.fixture:setRestitution(0.5)
	
	return ball
end

function makeTriangle(x, y)
	local triangle = {}
	
	local side = 40
	local horizontalOffset = side / 2
	local verticalOffset = horizontalOffset * math.pow(3, 0.5)
	
	triangle.body = p.newBody(world, x, y)
	x, y = 0, 0
	triangle.shape = p.newPolygonShape(
		x, y,
		x + horizontalOffset, y + verticalOffset,
		x - horizontalOffset, y + verticalOffset)
		
	triangle.fixture = p.newFixture(triangle.body, triangle.shape)
	triangle.fixture:setUserData({ type = "triangle", value = table.getn(objects.triangles) + 1 })
	
	return triangle
end

function beginContact(a, b, coll)
	d = a:getUserData()
	if d.type == "triangle" then
		if (objects.triangles[d.value].color ~= ballColor) then
			loseGame()
		end
	elseif d.type == "bottom-wall" then
		gainPoint()
	end
end

function endContact(a, b, coll)
    
end

function preSolve(a, b, coll)
    
end

function postSolve(a, b, coll)
    
end

function love.update(dt)
	world:update(dt)
	
	if love.keyboard.isDown("right") then
		objects.ball.body:applyForce(400, 0)
	elseif love.keyboard.isDown("left") then
		objects.ball.body:applyForce(-400, 0)
	elseif love.keyboard.isDown("up") then
		objects.ball.body:applyForce(0, -400)
	end
end

function love.keypressed(key)
	if (key == "down") then
		startGame()
	end
end

function love.draw()

	local g = love.graphics
	
	-- draw bottom
	
	g.setColor(0, 0, 0)
	g.polygon("fill", 0, pitTop, w / 2, h, 0, h)
	g.polygon("fill", w, pitTop, w / 2, h, w, h)
	
	-- draw ball
	
	for k, v in pairs(objects.balls) do
		g.setColor(255 * v.color, 255 * v.color, 255 * v.color)
		g.circle("fill", v.body:getX(), v.body:getY(), v.shape:getRadius())
	end
	
	for k, t in pairs(objects.triangles) do
		g.setColor(255 * t.color, 255 * t.color, 255 * t.color)
		g.polygon("fill", t.body:getWorldPoints(t.shape:getPoints()))
	end
end

function startGame()
	local ball = makeBall(math.random() * w, 50)
	ball.color = math.random(2) - 1
	
	table.insert(objects.balls, ball)
	
	for k, v in pairs(objects.triangles) do
		v.color = math.random(2) - 1
	end
end

function loseGame()
	print("YOU LOOSE")
end

function gainPoint()
	points = points + 1
	print(points)
end
