local parent = SexyMap
local modName = "ZoneText"
local media = LibStub("LibSharedMedia-3.0")
local mod = SexyMap:NewModule(modName, "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("SexyMap")
local db

local hideValues = {
	["always"] = L["Always"],
	["never"] = L["Never"],
	["hover"] = L["On hover"]	
}
	
local options = {
	type = "group",
	name = modName,
	args = {
		xOffset = {
			type = "range",
			name = L["Horizontal position"],
			min = -250,
			max = 250,
			step = 1,
			bigStep = 5,
			get = function() return db.xOffset end,
			set = function(info, v) db.xOffset = v; mod:Update() end
		},
		yOffset = {
			type = "range",
			name = L["Vertical position"],
			min = -250,
			max = 250,
			step = 1,
			bigStep = 5,
			get = function() return db.yOffset end,
			set = function(info, v) db.yOffset = v; mod:Update() end
		},
		width = {
			type = "range",
			name = L["Width"],
			min = 50,
			max = 400,
			step = 1,
			bigStep = 5,
			get = function() return MinimapZoneTextButton:GetWidth() end,
			set = function(info, v) db.width = v; mod:Update() end
		},
		show = {
			type = "multiselect",
			name = ("Show %s..."):format("zone text"),
			values = hideValues,
			order = 1,
			get = function(info, v)
				return db.show == v
			end,
			set = function(info, v)
				db.show = v
				mod:SetOnHover()
			end
		},
		bgColor = {
			type = "color",
			name = L["Background color"],
			hasAlpha = true,
			get = function()
				return db.bgColor.r, db.bgColor.g, db.bgColor.b, db.bgColor.a
			end,
			set = function(info, r, g, b, a)
				db.bgColor.r, db.bgColor.g, db.bgColor.b, db.bgColor.a = r, g, b, a
				mod:Update()
			end
		},
		borderColor = {
			type = "color",
			name = L["Border color"],
			hasAlpha = true,
			get = function()
				return db.borderColor.r, db.borderColor.g, db.borderColor.b, db.borderColor.a
			end,
			set = function(info, r, g, b, a)
				db.borderColor.r, db.borderColor.g, db.borderColor.b, db.borderColor.a = r, g, b, a
				mod:Update()
			end
		},
		font = {
			type = "select",
			name = L["Font"],
			dialogControl = 'LSM30_Font',
			order = 106,
			values = AceGUIWidgetLSMlists.font,
			get = function() return db.font end,
			set = function(info, v) 
				db.font = v
				mod:Update()
			end
		},
		fontSize = {
			type = "range",
			name = L["Font Size"],
			min = 4,				
			max = 30,
			step = 1,
			bigStep = 1,
			get = function() return db.fontsize end,
			set = function(info, v) 
				db.fontsize = v
				mod:Update()
			end		
		},
		fontColor = {
			type = "color",
			name = L["Font color"],
			hasAlpha = true,
			get = function()
				return db.fontColor.r, db.fontColor.g, db.fontColor.b, db.fontColor.a
			end,
			set = function(info, r, g, b, a)
				db.fontColor.r, db.fontColor.g, db.fontColor.b, db.fontColor.a = r, g, b, a
				mod:Update()
			end		
		},	
        fontColorEnable = {
            type = "toggle",
            name = "Enable Font color",
            desc = "Enable Font coloring. Friendly, Contested and Hostile areas will not change the font color.",
            get = function()
                return db.fontColorEnable
            end,
            set = function(info, v)
                db.fontColorEnable = v
                mod:Update()
            end
        },
        texture = {
            type = "input",
            name = L["Texture"],
            order = 10,
            --width = "double",
            get = function()
                return db.backdrop.settings.bgFile
            end,
            set = function(info, v)
                db.backdrop.settings.bgFile = v
                mod:Update()
            end
        },
        textureSelect = {
            type = "select",
            name = L["SharedMedia Texture"],
            order = 11,
            --width = "full",
            dialogControl = 'LSM30_Background',
            values = AceGUIWidgetLSMlists.background,
            get = function()
                return db.backdrop.settings.bgFile
            end,
            set = function(info, v)
                db.backdrop.settings.bgFile = media:Fetch("background", v)
                mod:Update()
            end
        },
        border = {
            type = "input",
            name = L["Border texture"],
            order = 12,
            --width = "full",
            get = function()
                return db.backdrop.settings.edgeFile
            end,
            set = function(info, v)
                db.backdrop.settings.edgeFile = v
                mod:Update()
            end
        },			
        borderTextureSelect = {
            type = "select",
            name = L["SharedMedia Border"],
            order = 13,
            --width = "full",
            dialogControl = 'LSM30_Border',
            values = AceGUIWidgetLSMlists.border,
            get = function()
                return db.backdrop.settings.edgeFile
            end,
            set = function(info, v)
                db.backdrop.settings.edgeFile = media:Fetch("border", v)
                mod:Update()
            end
        },			
        openTexBrowser = {
            type = "execute",
            order = 14,
            width = "full",
            name = function()
                local n,name, title, notes, loadable, reason, security=GetAddOnInfo("TexBrowser")
                if name ~= nil then
                    return L["Open TexBrowser"]
                else
                    return L["TexBrowser Not Installed"]
                end
            end,
            func = function()
                if not IsAddOnLoaded("TexBrowser") then
                    EnableAddOn("TexBrowser")
                    LoadAddOn("TexBrowser")
                end
                TexBrowser:OnEnable()
            end,
            disabled = function()
                local n,name, title, notes, loadable, reason, security=GetAddOnInfo("TexBrowser")
                return name == nil
            end
        },
	}
}

local defaults = {
	profile = {
		xOffset = 0,
		yOffset = 0,
		bgColor = {r = 0, g = 0, b = 0, a = 1},
		borderColor = {r = 0, g = 0, b = 0, a = 1},
		fontColor = {},
        fontColorEnable=false,
		show = "always",
        backdrop = {
			scale = 1,
			show = false,
			textureColor = {},
			borderColor = {},
			settings = {
				bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
				edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
				insets = {left = 4, top = 4, right = 4, bottom = 4},
				edgeSize = 16,
				tile = false
			}
		},
	}
}
function mod:OnInitialize()
	self.db = parent.db:RegisterNamespace(modName, defaults)
	parent:RegisterModuleOptions(modName, options, "Zone Button")
	MinimapToggleButton:ClearAllPoints()
	MinimapToggleButton:SetParent(MinimapZoneTextButton)
	MinimapToggleButton:SetPoint("LEFT", MinimapZoneTextButton, "RIGHT", -3, 0)
	
	MinimapZoneText:ClearAllPoints()
	MinimapZoneText:SetAllPoints()
	MinimapZoneTextButton:SetHeight(26)
	MinimapZoneTextButton:SetBackdrop(parent.backdrop)
	MinimapZoneTextButton:SetFrameStrata("MEDIUM")
end

function mod:OnEnable()
	db = self.db.profile
	self:Update()
	self:SetOnHover()
	self:RegisterEvent("ZONE_CHANGED")
	self:RegisterEvent("ZONE_CHANGED_INDOORS", "ZONE_CHANGED")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "ZONE_CHANGED")
end

function mod:SetOnHover()
	parent:UnregisterHoverButton(MinimapZoneTextButton)
	MinimapZoneTextButton:Show()
	MinimapZoneTextButton:SetAlpha(1)
	if db.show == "never" then
		MinimapZoneTextButton:Hide()
	elseif db.show == "hover" then
		parent:RegisterHoverButton(MinimapZoneTextButton)
	end
end

function mod:Update()
	MinimapZoneTextButton:ClearAllPoints()
	MinimapZoneTextButton:SetPoint("BOTTOM", Minimap, "TOP", db.xOffset, db.yOffset)
    MinimapZoneTextButton:SetBackdrop(db.backdrop.settings)
    MinimapZoneTextButton:SetBackdropColor(db.bgColor.r, db.bgColor.g, db.bgColor.b, db.bgColor.a)
	MinimapZoneTextButton:SetBackdropBorderColor(db.borderColor.r, db.borderColor.g, db.borderColor.b, db.borderColor.a)
    
	local a, b, c = MinimapZoneText:GetFont()
	MinimapZoneText:SetFont(db.font and media:Fetch("font", db.font) or a, db.fontsize or b, c)
	self:ZONE_CHANGED()
end

function mod:ZONE_CHANGED()
	local width = max(MinimapZoneText:GetStringWidth() * 1.3, db.width or 0)
	MinimapZoneTextButton:SetHeight(MinimapZoneText:GetStringHeight() + 10)
	MinimapZoneTextButton:SetWidth(width)
	if db.fontColorEnable then
		MinimapZoneText:SetTextColor(db.fontColor.r, db.fontColor.g, db.fontColor.b, db.fontColor.a)
	end
end
