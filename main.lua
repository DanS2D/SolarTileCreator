
local solarTiled = require("solarTilesCreator")
--solarTiled:loadMap("data/tiles/largeTest.json")
local luaExt = require("lua-ext")
local mainMenuBar = require("main-menu-bar")
local editor = require("editor")
local toolPanelWidget = require("tool-panel")
local layerPanelWidget = require("layer-panel")
local tilesheetPanelWidget = require("tilesheet-panel")
local mapPanelWidget = require("map-panel")
local titleFont = "fonts/Jost-500-Medium.ttf"
local subTitleFont = "fonts/Jost-400-Book.ttf"
local fontAwesomeBrandsFont = "fonts/FA5-Brands-Regular.ttf"
local applicationMainMenuBar = nil
local toolPanel = nil
local layerPanel = nil
local tilePanel = nil
local mapPanel = nil

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

local bottomGroup = display.newGroup()
local topGroup = display.newGroup()

-- create the panels
toolPanel = toolPanelWidget:new()
layerPanel = layerPanelWidget:new()
mapPanel = mapPanelWidget:new(topGroup, 100, 100)
tilePanel = tilesheetPanelWidget:new()

local function onKeyEvent(event)
	tilePanel:onKeyEvent(event)
	mapPanel:onKeyEvent(event)

	return true
end

local function mainLoop(event)
	mapPanel:render()
	tilePanel:render()
end

Runtime:addEventListener("enterFrame", mainLoop)
Runtime:addEventListener("key", onKeyEvent)
