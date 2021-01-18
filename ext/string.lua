local M = {}
local sFormat = string.format
local sGsub = string.gsub
local sByte = string.byte
local isWindows = system.getInfo("platform") == "win32"
local accentedCharacters = {
	["À"] = "A",
	["Á"] = "A",
	["Â"] = "A",
	["Ã"] = "A",
	["Ä"] = "A",
	["Å"] = "A",
	["Æ"] = "AE",
	["Ç"] = "C",
	["È"] = "E",
	["É"] = "E",
	["Ê"] = "E",
	["Ë"] = "E",
	["Ì"] = "I",
	["Í"] = "I",
	["Î"] = "I",
	["Ï"] = "I",
	["Ð"] = "D",
	["Ñ"] = "N",
	["Ò"] = "O",
	["Ó"] = "O",
	["Ô"] = "O",
	["Õ"] = "O",
	["Ö"] = "O",
	["Ø"] = "O",
	["Ù"] = "U",
	["Ú"] = "U",
	["Û"] = "U",
	["Ü"] = "U",
	["Ý"] = "Y",
	["Þ"] = "P",
	["ß"] = "s",
	["à"] = "a",
	["á"] = "a",
	["â"] = "a",
	["ã"] = "a",
	["ä"] = "a",
	["å"] = "a",
	["æ"] = "ae",
	["ç"] = "c",
	["è"] = "e",
	["é"] = "e",
	["ê"] = "e",
	["ë"] = "e",
	["ì"] = "i",
	["í"] = "i",
	["î"] = "i",
	["ï"] = "i",
	["ð"] = "eth",
	["ñ"] = "n",
	["ò"] = "o",
	["ó"] = "o",
	["ô"] = "o",
	["õ"] = "o",
	["ö"] = "o",
	["ø"] = "o",
	["ù"] = "u",
	["ú"] = "u",
	["û"] = "u",
	["ü"] = "u",
	["ý"] = "y",
	["þ"] = "p",
	["ÿ"] = "y"
}
string.pathSeparator = isWindows and "\\" or "/"

function string:urlEncode(str)
	local wString = str or self

	if (wString) then
		wString = sGsub(wString, "\n", "\r\n")
		wString =
			sGsub(
			wString,
			"([^%w ])",
			function(c)
				return sFormat("%%%02X", sByte(c))
			end
		)
		wString = sGsub(wString, " ", "+")
	end

	return wString
end

function string:stripAccents(str)
	local wString = str or self
	local strippedStr = wString:gsub("[%z\1-\127\194-\244][\128-\191]*", accentedCharacters)

	return strippedStr
end

function string:stripLeadingSpaces(str)
	local wString = str or self
	local strippedStr = wString:gsub("^%s*(.-)%s*$", "%1")

	return strippedStr
end

function string:stripTrailingSpaces(str)
	local wString = str or self
	local strippedStr = wString:gsub("[ \t]+%f[\r\n%z]", "")

	return strippedStr
end

function string:stripLeadingAndTrailingSpaces(str)
	local wString = str or self
	local strippedStr = wString:match("^%s*(.-)%s*$")

	return strippedStr
end

function string:getFileName(str)
	local wString = str or self
	local lastPathSeparatorPos = wString:match(sFormat("%s%s", "^.*()", string.pathSeparator))
	local fileName = lastPathSeparatorPos ~= nil and wString:sub(lastPathSeparatorPos + 1, wString:len()) or wString

	return fileName
end

function string:getFilePath(str)
	local wString = str or self
	local lastPathSeparatorPos = wString:match(sFormat("%s%s", "^.*()", string.pathSeparator))
	local filePath = wString:sub(1, lastPathSeparatorPos - 1)

	return filePath
end

function string:fileExtension(str)
	local wString = str or self

	if (wString:match("^.+(%..+)$") == nil) then
		return ""
	end

	wString = wString:match("^.+(%..+)$"):lower()
	wString = wString:sub(2, wString:len())

	return wString
end

function string:getFileNameAndPath(str)
	local wString = str or self
	local lastPathSeparatorPos = wString:match(sFormat("%s%s", "^.*()", string.pathSeparator))

	local fileName = wString:sub(lastPathSeparatorPos + 1, wString:len())
	local filePath = wString:sub(1, lastPathSeparatorPos - 1)

	return fileName, filePath
end

return M
