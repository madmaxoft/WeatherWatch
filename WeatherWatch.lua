
-- WeatherWatch.lua

-- Implements the WeatherWatch plugin that logs weather statistics






-- The file into which the weather changes are output; append
local g_LogFile = assert(io.open("weather.log", "a"))

-- Per-world statistics about the weather. Map of WorldName -> WeatherStats table (see createWeatherStats())
local g_Stats = {}

--- Translates the weather constant into a human-readable name
local g_WeatherName =
{
	[wSunny] = "sunny",
	[wRain]  = "rain",
	[wStorm] = "storm",
}





--- Creates a statistics table for a single weather
local function createSingleWeatherStats()
	return
	{
		TotalTicks = 0,  -- Total number of ticks this weather has been active for
		Num = 0,  -- Number of times this weather has become active
		To =  -- Number of times the specified weather has become active after this weather
		{
			[wSunny] = 0,
			[wRain] = 0,
			[wStorm] = 0,
		},
	}
end





--- Creates a statistics table for a single world
local function createWeatherStats(a_World)
	return
	{
		-- The per-weather statistics
		[wSunny] = createSingleWeatherStats(),
		[wRain]  = createSingleWeatherStats(),
		[wStorm] = createSingleWeatherStats(),
		
		-- The last weather known for this world
		LastWeather = a_World:GetWeather(),
		
		-- The tick when the weather last changed. The initial value is synthesized since there's no way to know.
		LastWeatherChange = a_World:GetWorldAge() - 1
	}
end





--- Handles the WeatherChanging hook, logging the change into the logfile
local function onWeatherChanged(a_World)
	-- Get the stats for the world; create if not known:
	local stats = g_Stats[a_World:GetName()]
	if not(stats) then
		stats = createWeatherStats(a_World)
		g_Stats[a_World:GetName()] = stats
	end
	
	-- Get the old and new weather, check if known:
	local oldWeather = stats.LastWeather
	local newWeather = a_World:GetWeather()
	if not(g_WeatherName[oldWeather]) then
		LOG("WeatherWatch: Unknown old weather: " .. tostring(oldWeather))
		return
	end
	if not(g_WeatherName[newWeather]) then
		LOG("WeatherWatch: Unknown new weather: " .. tostring(newWeather))
		return
	end
	
	-- Add statistics for the current weather:
	local curTick = a_World:GetWorldAge()
	local numTicks = curTick - stats.LastWeatherChange
	stats.LastWeatherChange = curTick
	stats.LastWeather = newWeather
	stats[oldWeather].TotalTicks = stats[oldWeather].TotalTicks + numTicks
	stats[oldWeather].To[newWeather] = stats[oldWeather].To[newWeather] + 1
	stats[newWeather].Num = stats[newWeather].Num + 1
	
	-- Write a line to the logfile:
	g_LogFile:write(
		"World \"" .. a_World:GetName() .. "\": weather changing from " .. g_WeatherName[oldWeather] ..
		" to " .. g_WeatherName[newWeather] .. " after " .. numTicks .. " ticks.\n"
	)
end





--- Writes the current statistics for all worlds
-- a_Log is anything that has a write() method
local function writeStatistics(a_Log)
	for name, stats in pairs(g_Stats) do
		a_Log:write("\tStatistics for world \"" .. name .. "\":\n")
		local SumTicks = stats[wSunny].TotalTicks + stats[wRain].TotalTicks + stats[wStorm].TotalTicks
		for _, weather in ipairs({wSunny, wRain, wStorm}) do
			local ws = stats[weather]
			local wn = g_WeatherName[weather]
			a_Log:write(string.format("\t\t%s has been active for %d ticks (%.2f %%)\n", wn, ws.TotalTicks, 100 * ws.TotalTicks / SumTicks))
			a_Log:write(string.format("\t\tIt has become %s %d times", wn, ws.Num))
			if (ws.Num > 0) then
				a_Log:write(string.format(" and the average length was %d ticks.\n", ws.TotalTicks / ws.Num))
			else
				a_Log:write("\n")
			end
			a_Log:write(string.format("\t\tThe weather has then transitioned to sunny %d times, rainy %d times and storm %d times\n", ws.To[wSunny], ws.To[wRain], ws.To[wStorm]))
		end
	end
end





function Initialize()
	cPluginManager:AddHook(cPluginManager.HOOK_WEATHER_CHANGED, onWeatherChanged)
	
	--[[
	-- DEBUG:
	cPluginManager:BindConsoleCommand("wes", 
		function()
			local res = {}
			writeStatistics({write = function(self, txt) table.insert(res, txt) end})
			return true, table.concat(res)
		end,
		"writes weather statistics"
	)
	--]]
	
	return true
end





function OnDisable()
	-- Write the statistics just before shutdown:
	writeStatistics(g_LogFile)
	g_LogFile:close()
end




