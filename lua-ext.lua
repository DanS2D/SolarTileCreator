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

function table.deepCopy(orig)
    local origType = type(orig)
	local copy

    if (origType == "table") then
		copy = {}

        for key, value in next, orig, nil do
            copy[deepcopy(key)] = deepcopy(value)
		end

        setmetatable(copy, deepcopy(getmetatable(orig)))
    else
        copy = orig
	end

    return copy
end

return M
