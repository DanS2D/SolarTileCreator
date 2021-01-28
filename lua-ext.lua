local json = require("json")
local M = {}
local oldPrint = print

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

function _G.print(msg, ...)
	oldPrint(msg:format(...))
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

function table.load(filename, location)
	local filePath = filename

	if (location) then
		filePath = system.pathForFile(filename, location)
	end

	local file, errorString = io.open(filePath, "r")

	if not file then
		print("File error: " .. errorString .. " at path: " .. path)
		return false
	else
		local contents = file:read("*a")
		local t = json.decode(contents)
		io.close(file)

		return t
	end
end

function table.save(t, filename, location)
	local filePath = filename

	if (location) then
		filePath = system.pathForFile(filename, location)
	end

	local file, errorString = io.open(filePath, "w")

	if not file then
		print("File error: " .. errorString)
		return false
	else
		file:write(json.encode(t))
		io.close(file)

		return true
	end
end

return M
