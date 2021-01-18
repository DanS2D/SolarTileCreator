
local M = {}
local oldOpen = io.open

function io.open(...)
	local baseDir = arg[3] or system.ResourceDirectory
	local mode = arg[2] or "r"
	local path = system.pathForFile(arg[1], fBaseDir)

	return oldOpen(path, mode)
end

return M
