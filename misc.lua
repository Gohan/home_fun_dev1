-- 模块设置
local modname = 'misc'
local M = {}
_G[modname] = M
package.loaded[modname] = M


-- 导入段
local setmetatable = setmetatable
local print = print
local assert = assert
local math = require "math"
local ipairs = ipairs
local love = love
local string = string

-- 常量段
setfenv(1, M)

-- 正式模块代码

Misc = {
	
}

-- cooldown 表示冷却时间, 如果这个按键被按时间超过冷却时间, 再次返回true.
function Misc.CreateTriggerChecker(interval, is_trigger_now)
	local holdtime = 0
	if is_trigger_now then
		holdtime = dt
	end

	f = function (dt)
		if holdtime >= interval then
			holdtime = dt
			return true
		else
			holdtime = holdtime + dt
			return false
		end
	end
	return f
end

return M