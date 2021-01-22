local M = {}

os.isLinux = (system.getInfo("platform") == "linux")
os.isMac = (system.getInfo("platform") == "macos")

function _G.toboolean(value)
	if (type(value) == "number") then
		return (value > 0)
	end

	return value
end

function _G.printf(msg, ...)
	print(msg:format(...))
end

return M
