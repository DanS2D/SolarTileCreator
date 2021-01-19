
local solarTiled = require("solarTilesCreator")
--solarTiled:loadMap("data/tiles/largeTest.json")

local luaExt = require("lua-ext")
local mainMenuBar = require("main-menu-bar")
local floatingPanel = require("floating-panel")
local titleFont = "fonts/Jost-500-Medium.ttf"
local subTitleFont = "fonts/Jost-400-Book.ttf"
local fontAwesomeBrandsFont = "fonts/FA5-Brands-Regular.ttf"
local applicationMainMenuBar = nil
local tilePanel = nil

math.randomseed(os.time())
display.setDefault("background", 48 / 255, 87 / 255, 225 / 255)

-- create the main menu bar
applicationMainMenuBar =
	mainMenuBar:new(
	{
		font = titleFont,
		items = {
			{
				title = "File",
				subItems = {
					{
						title = "Add Music Folder",
						iconName = _G.isLinux and "" or "folder-plus",
						onClick = function()
						end
					},
					{
						title = "Add Music File(s)",
						iconName = _G.isLinux and "" or "file-music",
						onClick = function()
						end
					},
					{
						title = "Import Music Library",
						iconName = _G.isLinux and "" or "file-import",
						onClick = function()
						end
					},
					{
						title = "Export Music Library",
						iconName = _G.isLinux and "" or "file-export",
						onClick = function()
						end
					},
					{
						title = "Delete Music Library",
						iconName = _G.isLinux and "" or "trash",
						onClick = function()
						end
					},
					{
						title = "Exit",
						iconName = _G.isLinux and "" or "power-off",
						onClick = function()
							native.requestExit()
						end
					}
				}
			},
			{
				title = "Edit",
				subItems = {
					{
						title = "Preferences",
						iconName = os.isLinux and "" or "tools",
						onClick = function(event)
						end
					}
				}
			},
			{
				title = "Music",
				subItems = {
					{
						title = "Fade In Track",
						iconName = os.isLinux and "" or "turntable",
						useCheckmark = true,
						checkMarkIsOn = false,
						onClick = function(event)
						end
					},
					{
						title = "Fade Out Track",
						iconName = os.isLinux and "" or "turntable",
						useCheckmark = true,
						checkMarkIsOn = false,
						onClick = function(event)
						end
					},
					{
						title = "Crossfade",
						iconName = os.isLinux and "" or "music",
						useCheckmark = true,
						checkMarkIsOn = false,
						onClick = function(event)
						end
					}
				}
			},
			{
				title = "View",
				subItems = {
					{
						title = "Light Theme",
						iconName = os.isLinux and "" or "palette",
						onClick = function(event)
						end
					},
					{
						title = "Dark Theme",
						iconName = os.isLinux and "" or "palette",
						onClick = function(event)
						end
					},
					{
						title = "Hacker Theme",
						iconName = os.isLinux and "" or "palette",
						onClick = function(event)
						end
					},
					{
						title = "Show Tile Panel",
						iconName = os.isLinux and "" or "th-large",
						onClick = function(event)
							tilePanel:open(true)
						end
					}
				}
			},
			{
				title = "Help",
				subItems = {
					{
						title = "Support Me On Patreon",
						iconName = os.isLinux and "" or "patreon",
						font = fontAwesomeBrandsFont,
						onClick = function(event)
							system.openURL("https://www.patreon.com/dannyglover")
						end
					},
					{
						title = "Report Bug",
						iconName = os.isLinux and "" or "github",
						font = fontAwesomeBrandsFont,
						onClick = function(event)
							system.openURL("https://github.com/DannyGlover/SDC")
						end
					},
					{
						title = "Submit Feature Request",
						iconName = os.isLinux and "" or "trello",
						font = fontAwesomeBrandsFont,
						onClick = function(event)
							system.openURL("https://github.com/DannyGlover/SDC")
						end
					},
					{
						title = "Visit Website",
						iconName = os.isLinux and "" or "browser",
						onClick = function(event)
							system.openURL("https://dannyglover.uk")
						end
					},
					{
						title = "About",
						iconName = os.isLinux and "" or "info-circle",
						onClick = function(event)
						end
					}
				}
			}
		}
	}
)

local mainGroup = display.newGroup()
local mGroup = display.newGroup()
local midGroup = display.newGroup()
local tGroup = display.newGroup()
mainGroup:insert(mGroup)

-- create grid
for i = 1, math.floor(display.contentWidth / 32) do
	for j = 1, math.floor(display.contentHeight / 32) - 1 do
		local rect = display.newRect(0, 0, 31, 31)
		rect.strokeWidth = 1
		rect:setFillColor(0, 0, 0, 0)
		rect:setStrokeColor(1, 1, 1, 0.5)
		rect.x = (i * 32) - 16
		rect.y = (j * 32) + 15
		midGroup:insert(rect)
	end
end

-- create the tile panel
tilePanel = floatingPanel:new({
	width = (display.contentWidth * 0.4),
	height = (display.contentHeight * 0.5) + 10,
	title = "Tiles",
})
tilePanel.x = (display.contentWidth - (tilePanel.width * 0.5) - 5)
tilePanel.y = (display.contentHeight - (tilePanel.height * 0.5))
--

local tileSheetOptions =
{
	width = 32,
	height = 32,
	numFrames = 8640,
	sheetContentWidth = 3456, -- width of original 1x size of entire sheet
	sheetContentHeight = 2560 -- height of original 1x size of entire sheet
}

local imageSheet = graphics.newImageSheet("data/tiles/tilesheet_complete_2X.png", tileSheetOptions)
local tiles = {}
local map = {
	layers = {
		{}
	}
}
local overlayLayer = {}
local selectedTileId = 0
local mapTiles = {}

-- 
for i = 1, 1000 do
	overlayLayer[i] = 0
	map.layers[1][i] = 0
end

local function tap(event)
	local target = event.target

	for i = 1, #tiles do
		tiles[i].strokeWidth = 0
		tiles[i].stroke.effect = nil
	end

	selectedTileId = target.tileIndex
	target.strokeWidth = 1
	target:setStrokeColor(1, 0, 0)
	target.stroke.effect = "generator.marchingAnts"
	--print("tileset tile tapped")

	return true
end

local function placeTile(event)
	local target = event.target
	map.layers[1][target.tileIndex] = selectedTileId
	--print(("map layer 1, tile index: %d now has tile %d"):format(target.tileIndex, selectedTileId))
	--print("place tile tapped")

	return true
end

local function drawMap(startX, xCount, startY, yCount)
	for i = 1, #mapTiles do
		display.remove(mapTiles[i])
		mapTiles[i] = nil
	end

	display.remove(mGroup)
	mGroup = nil
	mGroup = display.newGroup()
	mapTiles = {}
	mapTiles = nil
	mapTiles = {}
	local iX = 0
	local jY = 0

	for i = startX, startX + (xCount - 1) do
		iX = iX + 1
	
		if (iX > xCount) then
			iX = 1
		end

		for j = startY, startY + (yCount - 1) do
			jY = jY + 1

			if (jY > yCount) then
				jY = 1
			end

			local mRows = (display.contentWidth / 32) + 2
			local index = (i + (mRows * j)) -- math: (x + (#mapRows * y))
			local tileIndex = map.layers[1][index]

			if (tileIndex > 0) then
				mapTiles[#mapTiles + 1] = display.newImageRect(imageSheet, tileIndex, 32, 32)
			else
				mapTiles[#mapTiles + 1] = display.newRect(0, 0, 32, 32)
				mapTiles[#mapTiles]:setFillColor(0, 0, 0, 0.01)
			end
			
			mapTiles[#mapTiles].x = (iX * 32) - 15
			mapTiles[#mapTiles].y = (jY * 32) + 14
			mapTiles[#mapTiles].tileIndex = index
			mapTiles[#mapTiles]:addEventListener("tap", placeTile)
			mapTiles[#mapTiles]:addEventListener("touch", placeTile)
			mGroup:insert(mapTiles[#mapTiles])
		end
	end

	mainGroup:insert(mGroup)
end

local function create(startX, xCount, startY, yCount)
	for i = 1, #tiles do
		display.remove(tiles[i])
		tiles[i] = nil
	end

	display.remove(tGroup)
	tGroup = nil
	tGroup = display.newGroup()
	tiles = {}
	tiles = nil
	tiles = {}
	local iX = 0
	local jY = 0

	for i = startX, startX + (xCount - 1) do
		iX = iX + 1
	
		if (iX > xCount) then
			iX = 1
		end

		for j = startY, startY + (yCount - 1) do
			jY = jY + 1

			if (jY > yCount) then
				jY = 1
			end

			local tileIndex = (i + (108 * j)) -- math: (x + (#mapRows * y))

			tiles[#tiles + 1] = display.newImageRect(imageSheet, tileIndex, 32, 32)
			tiles[#tiles].x = (iX * 34) - (tilePanel.width * 0.5) - 8
			tiles[#tiles].y = (jY * 34) - (tilePanel.height * 0.5)
			tiles[#tiles].tileIndex = tileIndex

			if (selectedTileId == tileIndex) then
				tiles[#tiles].strokeWidth = 1
				tiles[#tiles]:setStrokeColor(1, 0, 0)
				tiles[#tiles].stroke.effect = "generator.marchingAnts"
			end

			tiles[#tiles]:addEventListener("tap", tap)
			tGroup:insert(tiles[#tiles])
		end
	end

	tilePanel:insert(tGroup)
	display.getCurrentStage():insert(tilePanel)
end

local sX = 1
local sY = 1
local sheetRows = 7
local sheetColumns = 7
create(sX, sheetRows, sY, sheetColumns)

local function onKeyEvent(event)
	local keyName = event.keyName
	local phase = event.phase

	--print(keyName)

	--if (phase == "up") then
		if (keyName:lower() == "right") then
			sX = sX + 1

			if (sX > 102) then
				sX = 102
			end

			--tGroup.x = tGroup.x - 2
			--create(sX, sheetRows, sY, sheetColumns)
		elseif (keyName:lower() == "down") then
			sY = sY + 1

			if (sY > 73) then
				sY = 73
			end

			--create(sX, sheetRows, sY, sheetColumns)
		elseif (keyName:lower() == "left") then
			sX = sX - 1

			if (sX <= 1) then
				sX = 1
			end

			--create(sX, sheetRows, sY, sheetColumns)
		elseif (keyName:lower() == "up") then
			sY = sY - 1

			if (sY <= 1) then
				sY = 1
			end

			--create(sX, sheetRows, sY, sheetColumns)
		end
	--end

	return true
end

Runtime:addEventListener("key", onKeyEvent)


local sequenceData =
{
	name = "highlightTile",
	start = 1,
	count = 8640,
	time = 0,
	loopCount = 1, -- Optional ; default is 0 (loop indefinitely)
	loopDirection = "bounce" -- Optional ; values include "forward" or "bounce"
}

local highlightTile = display.newSprite(imageSheet, sequenceData)

local function mouse(event)
	local x = event.x
	local y = event.y

	if (selectedTileId > 0) then
		for i = 1, #mapTiles do
			local t = mapTiles[i]
			
			if (x >= t.x - (t.width * 0.5) and x <= t.x + (t.width * 0.5)) then
				if (y >= t.y - (t.height * 0.5) and y <= t.y + (t.height * 0.5)) then
					highlightTile.x = t.x
					highlightTile.y = t.y
					highlightTile:setFrame(selectedTileId)
					break
				end
			end
		end
	end

	return true
end

Runtime:addEventListener("mouse", mouse)

local function run(event)
	drawMap(1, (display.contentWidth / 32) + 2, 1, (display.contentHeight / 32) + 2)
	create(sX, sheetRows, sY, sheetColumns)
end

Runtime:addEventListener("enterFrame", run)
