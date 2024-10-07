
---- ########################################################

local input =
	{                                                       	-- Names on the input table are shown on the radio when specifying the data
		{ "Wheel", SOURCE },    			                	-- User selected source (the wheel input)
		{ "Switch", SOURCE },                               	-- User selected source (the switch to set the modes [SA] or Trim set to 3P mode.)
		{ "DeadZo", VALUE, 1, 20, 1 }                     		-- User selected value (Deadzone || minimum: 1 | maximum: 5 | default: 1)
	}

local output = { "Steer", "Mode" }                       		-- Data provided by the script to the radio (can be used in the mixer page for example // Names max. 6 chars)

local steer_pos = 0                                      	
local state = 0

local function init()
	-- Called once when the script is loaded
end

local function run(Wheel, switch, deadzo) 						-- Number of params must match number of params in the input table
	-- Called periodically
	
	-- ------------------------------------------
	-- !!! KEEP THE CODE AS SHORT AS POSSIBLE !!!
	-- ------------------------------------------
	if switch > 10 and state == -1 then						-- manual force steering lock off.					
		steer_pos = 0
		state = 0
		return 0, 0
	end
	if switch == 0 and state == 0 then								-- Are we in "neutral" mode.
		steer_pos = 0
		state = 0
		return 0, 0
	end

	local deadzone = deadzo * 10.24

	if switch < -10 and state == 0 and math.abs(Wheel) > deadzone  then				-- This Lock the steering						
		steer_pos = Wheel
		state = -1   -- set the state for unlock stage.
		time1 = getTime()	--start timer here.
	end
	
	if switch == 0 and state == -1 and ((getTime() - time1) > 150) then				--unlock mode time  -- gettime used here to cause a delay(ms) before going into unlock mode.
		if steer_pos > 0 then	-- detect locked side.
			if Wheel >= steer_pos then		--unlock when wheel matches lock position.
				state = 0
			end
		elseif steer_pos < 0 then	-- detect locked side.
			if Wheel <= steer_pos then		--unlock when wheel matches lock position.
				state = 0
			end
		end
	end
	return steer_pos, state * 1024    
	    	
end

return { input=input, output=output, run=run, init=init }
