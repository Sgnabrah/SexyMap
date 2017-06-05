local parent = SexyMap
local modName = "Coordinates"
local mod = SexyMap:NewModule(modName, "AceTimer-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("SexyMap")
local db

local options = {
	type = "group",
	name = L["Coordinates"],
	childGroups = "tab",
	args = {
		enable = {
			type = "toggle",
			name = L["Enable Coordinates"],
			get = function()
				return db.enabled
			end,
			set = function(info, v)
				db.enabled = v
				if v then
					parent:EnableModule(modName)
				else
					parent:DisableModule(modName)
				end
			end
		},
		settings = {
			type = "group",
			name = L["Settings"],
			disabled = function()
				return not db.enabled
			end,
			args = {
				fontSize = {
					type = "range",
					name = L["Font size"],
					min = 8,
					max = 30,
					step = 1,
					bigStep = 1,
					get = function()
						return db.fontSize or 12
					end,
					set = function(info, v)
						db.fontSize = v
						mod:Update()
						mod:UpdateCoords()
					end
				},
				lock = {
					type = "toggle",
					name = L["Lock"],
					get = function()
						return db.locked
					end,
					set = function(info, v)
                        db.locked = v
                        mod:Update()
					end
				},
				fontColor = {
					type = "color",
					name = L["Font color"],
					order = 13,
					hasAlpha = true,
					get = function()
						local c = db.fontColor
						local r, g, b, a = c.r or 0, c.g or 0, c.b or 0, c.a or 1
						return r, g, b, a
					end,
					set = function(info, r, g, b, a)
						local c = db.fontColor
						c.r, c.g, c.b, c.a = r, g, b, a
						mod:Update()
					end
				},
				backgroundColor = {
					type = "color",
					name = L["Backdrop color"],
					order = 13,
					hasAlpha = true,
					get = function()
						local c = db.backgroundColor
						local r, g, b, a = c.r or 0, c.g or 0, c.b or 0, c.a or 1
						return r, g, b, a
					end,
					set = function(info, r, g, b, a)
						local c = db.backgroundColor
						c.r, c.g, c.b, c.a = r, g, b, a
						mod:Update()
					end		
				},
				borderColor = {
					type = "color",
					name = L["Border color"],
					order = 13,
					hasAlpha = true,
					get = function()
						local c = db.borderColor
						local r, g, b, a = c.r or 0, c.g or 0, c.b or 0, c.a or 1
						return r, g, b, a
					end,
					set = function(info, r, g, b, a)
						local c = db.borderColor
						c.r, c.g, c.b, c.a = r, g, b, a
						mod:Update()
					end		
				}
			}
		}
	}
}

local function start(self)
	self:StartMoving()
end
local function finish(self)
	self:StopMovingOrSizing()
	local x, y = self:GetCenter()
	local mx, my = Minimap:GetCenter()
	local dx, dy = mx - x, my - y
	self:ClearAllPoints()
	self:SetPoint("CENTER", Minimap, "CENTER", -dx, -dy)
	db.x = dx
	db.y = dy
end
local defaults = {
	profile = {
		borderColor = {},
		backgroundColor = {},
		locked = false,
		fontColor = {},
		enabled = false
	}
}
local coordFrame, xcoords, ycoords
function mod:OnInitialize()
	self.db = parent.db:RegisterNamespace(modName, defaults)
	db = self.db.profile
	
	coordFrame = CreateFrame("Frame", "SexyMapCoordFrame", Minimap)
	coordFrame:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		insets = {left = 2, top = 2, right = 2, bottom = 2},
		edgeSize = 12,
		tile = true
	})
    
    sep = coordFrame:CreateFontString(nil, nil, "GameFontNormalSmall")
    sep:SetPoint("CENTER", coordFrame, "CENTER", 0, 0)
    sep:SetText(":")
    sep:SetJustifyV("MIDDLE")
    sep:SetJustifyH("CENTER")
    
	xcoords = coordFrame:CreateFontString(nil, nil, "GameFontNormalSmall")
    xcoords:SetPoint("TOPRIGHT", sep, "TOPLEFT", 0, 0)
	--xcoords:SetPoint("TOPLEFT", coordFrame, "TOPLEFT", 5, 0)
	--xcoords:SetPoint("BOTTOM")
	--xcoords:SetPoint("TOPRIGHT", coordFrame, "TOP")
	xcoords:SetJustifyH("RIGHT")

	ycoords = coordFrame:CreateFontString(nil, nil, "GameFontNormalSmall")
    ycoords:SetPoint("TOPLEFT", sep, "TOPRIGHT", 0, 0)
	--ycoords:SetPoint("TOPLEFT", xcoords, "TOPRIGHT", 0, 0)
	--ycoords:SetPoint("BOTTOMLEFT", xcoords, "BOTTOMRIGHT")
	--ycoords:SetPoint("TOPRIGHT", coordFrame, "TOPRIGHT", 0, 0)
	--ycoords:SetPoint("BOTTOM")
	ycoords:SetJustifyH("LEFT")
	
	
	coordFrame:EnableMouse()
	coordFrame.sexyMapIgnore = true
    
    coordFrame:SetMovable(not db.locked)
    if(db.locked)then
        coordFrame:SetScript("OnMouseDown", nil)
        coordFrame:SetScript("OnMouseUp", nil)
	else
        coordFrame:SetScript("OnMouseDown", start)
        coordFrame:SetScript("OnMouseUp", finish)
    end
	self:UpdateCoords()
	self:Update()
	parent:RegisterModuleOptions(modName, options, modName)
end

function mod:OnEnable()
	db = self.db.profile
	if not db.enabled then
		parent:DisableModule(modName)
		return
	end
	if db.x then
		coordFrame:ClearAllPoints()
		coordFrame:SetPoint("CENTER", Minimap, "CENTER", -db.x, -db.y)
	else
		coordFrame:SetPoint("CENTER", Minimap, "BOTTOM")
	end
	
	coordFrame:Show()
	self.updateTimer = self:ScheduleRepeatingTimer("UpdateCoords", 0.05)
	-- parent:GetModule("Buttons"):MakeMovable(coordFrame)
end

function mod:OnDisable()
	self:CancelTimer(self.updateTimer, true)
	coordFrame:Hide()
end

function mod:UpdateCoords()
	local x, y = GetPlayerMapPosition("player")
	xcoords:SetText(("%2.1f"):format(x*100))
	ycoords:SetText(("%2.1f"):format(y*100))
	-- , %2.1f"):format(x*100,y*100))
end

function mod:Update()
	if db.borderColor then
		local c = db.borderColor
		coordFrame:SetBackdropBorderColor(c.r or 0, c.g or 0, c.b or 0, c.a or 1)
	end

	if db.backgroundColor then
		local c = db.backgroundColor
		coordFrame:SetBackdropColor(c.r or 0, c.g or 0, c.b or 0, c.a or 1)
	end

	if db.fontColor then
		local c = db.fontColor
		xcoords:SetTextColor(c.r or 1, c.g or 1, c.b or 1, c.a or 1)
		ycoords:SetTextColor(c.r or 1, c.g or 1, c.b or 1, c.a or 1)
        sep:SetTextColor(c.r or 1, c.g or 1, c.b or 1, c.a or 1)
	end
	
	if db.fontSize then
		local f, s, flags = xcoords:GetFont()
		xcoords:SetFont(f, db.fontSize, "OUTLINE")
		ycoords:SetFont(f, db.fontSize, "OUTLINE")
        sep:SetFont(f, db.fontSize, "OUTLINE")
	end
    
    coordFrame:SetMovable(not db.locked)
    if(db.locked)then
        coordFrame:SetScript("OnMouseDown", nil)
        coordFrame:SetScript("OnMouseUp", nil)
	else
        coordFrame:SetScript("OnMouseDown", start)
        coordFrame:SetScript("OnMouseUp", finish)
    end
    
	local pt = xcoords:GetText()
	xcoords:SetText(("%2.1f:%2.1f"):format(22.222,22.222))
	coordFrame:SetWidth(xcoords:GetStringWidth()+ycoords:GetStringWidth())
	coordFrame:SetHeight(xcoords:GetStringHeight() + 10)
	xcoords:SetText(pt)
end
