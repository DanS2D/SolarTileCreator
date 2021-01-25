local M = {}

os.isLinux = (system.getInfo("platform") == "linux")
os.isMac = (system.getInfo("platform") == "macos")
os.isWindows = (system.getInfo("platform") == "windows")
os.homePath = (isWindows and "%HOMEPATH%\\") or os.getenv("HOME") .. "/"

function _G.toboolean(value)
	if (type(value) == "number") then
		return (value > 0)
	end

	return value
end

function _G.printf(msg, ...)
	print(msg:format(...))
end

function table.deepCopy(original)
	local copy = {}
	
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = table.deepCopy(v)
		end
		copy[k] = v
	end
	
	return copy
end

return M
