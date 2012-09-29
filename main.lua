p = love.physics
g = love.graphics

w = 400
h = 800

lives = 10
points = 0

currentBall = {}

function love.load()
	
	g.setBackgroundColor(160, 160, 160)
	p.setMeter(64)	
	world = p.newWorld(0, 5*64, true)
	world:setCallbacks(beginContact, nil, nil, nil)
	
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
	
	objects.walls.topFixture:setUserData({ touched = false, type = "wall", value = "top"})
	objects.walls.rightTopFixture:setUserData({ touched = false, type = "wall", value = "right-top"})
	objects.walls.rightBottomFixture:setUserData({ touched = false, type = "bottom-wall", value = "right-bottom"})
	objects.walls.leftBottomFixture:setUserData({ touched = false, type = "bottom-wall", value = "left-bottom"})
	objects.walls.leftTopFixture:setUserData({ touched = false, type = "wall", value = "left-top"})
	
	-- balls
	
	objects.balls = {}
	
	-- triangles
	
	objects.triangles = {}
	
	local triangleOffset = 120
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

function beginContact(a, b, coll)

	local aUntouched = not a:getUserData().touched
	local bUntouched = not b:getUserData().touched
	
	if a == currentBall.fixture and aUntouched then
		resolveBallContact(a, b)
	elseif b == currentBall.fixture and bUntouched then
		resolveBallContact(b, a)
	end
end

function resolveBallContact(ball, other)
	local otherData = other:getUserData()
	
	if otherData.type == "triangle" and objects.triangles[otherData.value].color ~= currentBall.color then
		loseGame()
		touchFixture(ball)
	elseif otherData.type == "bottom-wall" then
		gainPoint()
		touchFixture(ball)
	end
end

function loseGame()
	currentBall.body:destroy()
	currentBall.lost = true
	lives = lives - 1
	print("Lives Left: " .. lives)
	
	startGame()
end

function gainPoint()
	points = points + 1
	print("Points: " .. points)
end

function touchFixture(fixture)
	local newUserData = fixture:getUserData()
	newUserData.touched = true
	fixture:setUserData(newUserData)
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
	triangle.fixture:setUserData({ touched = false, type = "triangle", value = table.getn(objects.triangles) + 1 })
	
	return triangle
end

function startGame()
	
	if lives <= 0 then
		return;
	end
	
	currentBall = makeBall(math.random() * w, 50)
	
	table.insert(objects.balls, currentBall)
	
	for k, v in pairs(objects.triangles) do
		v.color = math.random(2) - 1
	end
end

function makeBall(x, y)
	local ball = {}
	
	ball.body = p.newBody(world, x, y, "dynamic")
	ball.shape = p.newCircleShape(10)
	ball.fixture = p.newFixture(ball.body, ball.shape, 1)
	ball.fixture:setUserData({ touched = false, type = "ball", value = table.getn(objects.balls) + 1 })
	ball.fixture:setRestitution(0.5)
	ball.color = math.random(2) - 1
	ball.lost = false
	
	return ball
end

function love.update(dt)
	world:update(dt)
	
	if love.keyboard.isDown("right") then
		currentBall.body:applyForce(400, 0)
	elseif love.keyboard.isDown("left") then
		currentBall.body:applyForce(-400, 0)
	elseif love.keyboard.isDown("up") then
		currentBall.body:applyForce(0, -400)
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
		if not v.lost then
			g.setColor(255 * v.color, 255 * v.color, 255 * v.color)
			g.circle("fill", v.body:getX(), v.body:getY(), v.shape:getRadius())
		end
	end
	
	for k, t in pairs(objects.triangles) do
		g.setColor(255 * t.color, 255 * t.color, 255 * t.color)
		g.polygon("fill", t.body:getWorldPoints(t.shape:getPoints()))
	end
end
