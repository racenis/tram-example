print("\n\nHello! This is the ping pong example.\n")
print("Here's some ideas for what you could do:")
print("- Use the arrow keys or WASD to move the paddles.")
print("- Press F1 to quit.")
print("- Press F9 to unlock view.")
print("- Press F12 to take a screenshot.")
print("- Press Tilde (~) for debug menu.")
print("- Press ESC for settings.")

-- Constants.
local paddle_size = 0.2
local draw_lines = false

-- Retitling the main window.
tram.ui.SetWindowTitle("Ping Pong v1.0")
tram.ui.SetWindowSize(640, 480)

-- Setting up the global lighting.
tram.render.SetSunColor(tram.math.vec3(0.0, 0.0, 0.0))
tram.render.SetSunDirection(tram.math.DIRECTION_FORWARD)
tram.render.SetAmbientColor(tram.math.vec3(0.1, 0.1, 0.1))
tram.render.SetScreenClearColor(tram.render.COLOR_BLACK)

-- Move the camera a bit away from the origin.
tram.render.SetViewPosition(tram.math.DIRECTION_FORWARD * -3.0, 0)
tram.render.SetViewPosition(tram.math.DIRECTION_FORWARD * -3.0, 1)
tram.render.SetViewPosition(tram.math.DIRECTION_FORWARD * -3.0, 2)

-- Setting the lighting so that you can see something.
local front_light = tram.components.Light()
front_light:SetColor(tram.render.COLOR_WHITE * 1.0)
front_light:SetLocation(tram.math.vec3(0.001, 5.0, 5.0))
front_light:Init()

local back_light = tram.components.Light()
back_light:SetColor(tram.render.COLOR_WHITE * 0.7)
back_light:SetLocation(tram.math.vec3(0.001, -3.0, 1.0))
back_light:Init()


-- Creating the ball model
local teapot = tram.components.Render()
teapot:SetModel("teapot")
teapot:SetScale(tram.math.vec3(0.4, 0.4, 0.4))
teapot:SetLayer(2)
teapot:Init()


-- Creating the paddle models.
local paddle_model_left = tram.components.Render()
paddle_model_left:SetModel("cube")
paddle_model_left:SetScale(tram.math.vec3(0.05, paddle_size, 0.01))
paddle_model_left:SetLayer(2)
paddle_model_left:Init()

local paddle_model_right = tram.components.Render()
paddle_model_right:SetModel("cube")
paddle_model_right:SetScale(tram.math.vec3(0.05, paddle_size, 0.01))
paddle_model_right:SetLayer(2)
paddle_model_right:Init()

-- Initializing the game logic.
ball = {
	position = tram.math.vec3(0.0, 0.0, 0.0),
	velocity = tram.math.vec3(0.02, 0.02, 0.0)
}

paddle_left = {
	position = tram.math.vec3(-2.0, 0.0, 0.0)
}

paddle_right = {
	position = tram.math.vec3(2.0, 0.0, 0.0)
}

local player_left_score = 0
local player_right_score = 0

local teapot_modifier = tram.math.vec3(0.0, 0.0, 0.0)

-- This function will be called every tick.
tram.event.AddListener(tram.event.TICK, function()	
	if tram.ui.PollKeyboardKey(tram.ui.KEY_UP) then
		if paddle_right.position.y + paddle_size < 1.0 then 
			paddle_right.position.y = paddle_right.position.y + 0.05
		end
	end
	
	if tram.ui.PollKeyboardKey(tram.ui.KEY_DOWN) then
		if paddle_right.position.y - paddle_size > -1.0 then 
			paddle_right.position.y = paddle_right.position.y - 0.05
		end
	end
	
	if tram.ui.PollKeyboardKey(tram.ui.KEY_W) then
		if paddle_left.position.y + paddle_size < 1.0 then 
			paddle_left.position.y = paddle_left.position.y + 0.05
		end
	end
	
	if tram.ui.PollKeyboardKey(tram.ui.KEY_S) then
		if paddle_left.position.y - paddle_size > -1.0 then 
			paddle_left.position.y = paddle_left.position.y - 0.05
		end
	end
		
	-- Updates the ball.
	ball.position = ball.position + ball.velocity
	
	-- Checks the ball collisions.
	if ball.position.y < -1.0 or ball.position.y > 1.0 then
		ball.velocity.y = -ball.velocity.y
	end
	
	if ball.position.x < -2.0 then
		local paddle_dist = math.abs(ball.position.y - paddle_left.position.y)
	
		if paddle_dist < paddle_size then
			ball.velocity.x = -ball.velocity.x
		else 
			ball.position.x = 0.0
			ball.position.y = 0.0
			
			player_right_score = player_right_score + 1
			
			print("Left lost!!")
			print("Score is", player_left_score, "|", player_right_score)
		end
	end
	
	if ball.position.x > 2.0 then
		local paddle_dist = math.abs(ball.position.y - paddle_right.position.y)
	
		if paddle_dist < paddle_size then
			ball.velocity.x = -ball.velocity.x
		else 
			ball.position.x = 0.0
			ball.position.y = 0.0
			
			player_left_score = player_left_score + 1
			
			print("Right lost!!")
			print("Score is", player_left_score, "|", player_right_score)
		end
	end
end)

tram.event.AddListener(tram.event.FRAME, function()	
	-- Field drawing.
	local corner1 = tram.math.vec3(-2.0, 1.0, 0.0)
	local corner2 = tram.math.vec3(2.0, 1.0, 0.0)
	local corner3 = tram.math.vec3(2.0, -1.0, 0.0)
	local corner4 = tram.math.vec3(-2.0, -1.0, 0.0)
	
	local midpoint1 = tram.math.vec3(0.0, 1.0, 0.0)
	local midpoint2 = tram.math.vec3(0.0, -1.0, 0.0)
	
	tram.render.AddLine(corner1, corner2, tram.render.COLOR_WHITE)
	tram.render.AddLine(corner2, corner3, tram.render.COLOR_WHITE)
	tram.render.AddLine(corner3, corner4, tram.render.COLOR_WHITE)
	tram.render.AddLine(corner4, corner1, tram.render.COLOR_WHITE)
	tram.render.AddLine(midpoint1, midpoint2, tram.render.COLOR_WHITE)
	
	-- Optional logic lines for the ball and the paddles.
	if draw_lines then
		local left_top = paddle_left.position + tram.math.vec3(0.1, paddle_size, 0.0)
		local left_btm = paddle_left.position + tram.math.vec3(0.1, -paddle_size, 0.0)

		tram.render.AddLine(left_top, left_btm, tram.render.COLOR_GREEN)
		
		local right_top = paddle_right.position + tram.math.vec3(-0.1, paddle_size, 0.0)
		local right_btm = paddle_right.position + tram.math.vec3(-0.1, -paddle_size, 0.0)
		
		tram.render.AddLine(right_top, right_btm, tram.render.COLOR_GREEN)
		
		tram.render.AddLineMarker(ball.position, tram.render.COLOR_RED)
	end
	
	-- Amusing teapot animation.
	teapot_modifier.x = teapot_modifier.x + ball.velocity.x
	teapot_modifier.y = teapot_modifier.y + ball.velocity.y
	teapot:SetRotation(tram.math.quat(teapot_modifier))
	
	-- Updating the 3D models.
	teapot:SetLocation(ball.position)
	
	paddle_model_left:SetLocation(paddle_left.position)
	paddle_model_right:SetLocation(paddle_right.position)
end)