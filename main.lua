
function love.load()
	
	love.graphics.setMode(650, 650, false, true, 0)
	
	local p = love.physics
	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()
	local bodyRatio = 0.8
	local pitTop = h * bodyRatio
	local leftPitAngle = math.tan((h - pitTop) / (w / 2))
	local rightPitAnlge = -1 * leftPitAngle

	p.setMeter(64)
	world = p.newWorld(0, 9.81*64, true)
	
	objects = {}
	
	-- walls
	
	objects.walls = {}
	objects.walls.body = p.newBody(world, 0, 0)
	
	objects.walls.rightTopShape = p.newEdgeShape(w, 0, pitTop, 0)
	objects.walls.rightBottomShape = p.newEdgeShape(0,0,50,0,25,50, rightPitAngle)
	objects.walls.leftBottomShape = p.newEdgeShape(, leftPitAngle)
	objects.walls.leftTopShape = p.newEdgeShape(, 0)
	
	objects.walls.rightTopFixture = p.newFixture(objects.walls.body, objects.walls.rightTopShape)
	-- objects.walls.rightBottomFixture = p.newFixture(objects.walls.body, objects.walls.rightBottomShape)
	-- objects.walls.leftTopFixture = p.newFixture(objects.walls.body, objects.walls.leftTopShape)
	-- objects.walls.leftBottomFixture = p.newFixture(objects.walls.body, objects.walls.leftBottomShape)
	
	objects.ball = {}
	objects.ball.body = p.newBody(world, 650/2, 650/2, "dynamic")
	objects.ball.shape = p.newCircleShape(20)
	objects.ball.fixture = p.newFixture(objects.ball.body, objects.ball.shape, 1)
	
	objects.ball.fixture:setRestitution(0.9)
	
	objects.triangles = {}
	
	
	
	objects.block1 = {}
	objects.block1.body = p.newBody(world, 200, 550)
	objects.block1.shape = p.newPolygonShape(0, 0, 50, 0, 25, 25)
	objects.block1.fixture = p.newFixture(objects.block1.body, objects.block1.shape, 5)
	
	love.graphics.setBackgroundColor(104, 136, 248)
end

function love.update(dt)
	world:update(dt)
	
	if love.keyboard.isDown("right") then
		objects.ball.body:applyForce(400, 0)
		angle = angle + 0.001
	elseif love.keyboard.isDown("left") then
		objects.ball.body:applyForce(-400, 0)
		angle = angle - 0.001
	elseif love.keyboard.isDown("up") then
		objects.ball.body:setPosition(650/2, 650/2)
	end
end

function love.draw()

	local g = love.graphics
	
	g.setColor(72, 160, 14)
	
	g.polygon("fill", objects.walls.body:getWorldPoints(objects.walls.rightTopShape:getPoints()))
	-- g.polygon("fill", objects.walls.body:getWorldPoints(objects.walls.rightBottomShape:getPoints()))
	-- g.polygon("fill", objects.walls.body:getWorldPoints(objects.walls.leftTopShape:getPoints()))
	-- g.polygon("fill", objects.walls.body:getWorldPoints(objects.walls.leftBottomShape:getPoints()))
	
	g.setColor(193, 47, 14)
	g.circle("fill", objects.ball.body:getX(), objects.ball.body:getY(), objects.ball.shape:getRadius())
	
	g.setColor(50, 50, 50)
	g.polygon("fill", objects.block1.body:getWorldPoints(objects.block1.shape:getPoints()))
	
end
