local MAJOR, MINOR = "LibBetterBlizzOptions-1.0", 1
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

local function makeMovable(frame)
    if(frame==nil)then
        return
    end
	local mover = _G[frame:GetName() .. "Mover"] or CreateFrame("Frame", frame:GetName() .. "Mover", frame)
	mover:EnableMouse(true)
	mover:SetPoint("TOP", frame, "TOP", 0, 10)
	mover:SetWidth(160)
	mover:SetHeight(40)
    mover:SetFrameStrata(frame:GetFrameStrata())
	mover:SetScript("OnMouseDown", function(self)
		self:GetParent():StartMoving()
	end)
	mover:SetScript("OnMouseUp", function(self)
		self:GetParent():StopMovingOrSizing()
	end)
    --mover:SetClampedToScreen(true)-- doesn't work?
	frame:SetClampedToScreen(true)-- It does but you have to clamp the frame not the mover!
	frame:SetMovable(true)
end

local freeButtons = {
    [InterfaceOptionsFrameCategories] = {},
    [InterfaceOptionsFrameAddOns] = {},
}
local function updateScrollHeight(categoryFrame)
    local buttons = categoryFrame.buttons
    local numButtons = #buttons
    local maxButtons = (categoryFrame:GetTop() - categoryFrame:GetBottom() - 8) / categoryFrame.buttonHeight
    local name = categoryFrame:GetName()
    if numButtons < maxButtons then
        for i = numButtons + 1, maxButtons do --the frame get resized with more height, i can show more entries
            if freeButtons[categoryFrame][i] then --if the button i want to show is not nil
                local button
                button = freeButtons[categoryFrame][i]
                
                local listwidth = InterfaceOptionsFrameAddOnsList:GetWidth()
                if InterfaceOptionsFrameAddOnsList:IsShown() then
                    button:SetWidth(button:GetWidth() - listwidth)
                end
                
                tinsert(buttons, button)
            end
        end
    else--the frame get resizen with small height i have to hide overflowing entries
        for i = numButtons, maxButtons, -1 do
            local button = tremove(buttons, i)
            button:Hide()
            
            local listwidth = InterfaceOptionsFrameAddOnsList:GetWidth()
            if InterfaceOptionsFrameAddOnsList:IsShown() then
                button:SetWidth(button:GetWidth() + listwidth)
            end
            freeButtons[categoryFrame][i] = button
        end
    end
    categoryFrame.update()
end
---
local grip = _G.BetterBlizzOptionsResizeGrip or CreateFrame("Frame", "BetterBlizzOptionsResizeGrip", InterfaceOptionsFrame)
grip:EnableMouse(true)
local tex = grip.tex or grip:CreateTexture(grip:GetName() .. "Grip")
grip.tex = tex
tex:SetTexture([[Interface\BUTTONS\UI-AutoCastableOverlay]])
tex:SetTexCoord(0.619, 0.760, 0.612, 0.762)
tex:SetDesaturated(true)
tex:ClearAllPoints()
tex:SetPoint("TOPLEFT")
tex:SetPoint("BOTTOMRIGHT", grip, "TOPLEFT", 12, -12)

-- Deal with BBO base installs
if grip.SetNormalTexture then
	grip:SetNormalTexture(nil)
	grip:SetHighlightTexture(nil)
end
-- tex:SetAllPoints()

grip:SetWidth(22)
grip:SetHeight(21)
grip:SetScript("OnMouseDown", function(self)
	self:GetParent():StartSizing()
end)
grip:SetScript("OnMouseUp", function(self)
	self:GetParent():StopMovingOrSizing()
	updateScrollHeight(InterfaceOptionsFrameCategories)
	updateScrollHeight(InterfaceOptionsFrameAddOns)
end)
grip:SetScript("OnEvent", function(self)
	updateScrollHeight(InterfaceOptionsFrameCategories)
	updateScrollHeight(InterfaceOptionsFrameAddOns)
end)
if not grip:IsEventRegistered("PLAYER_LOGIN") then
	grip:RegisterEvent("PLAYER_LOGIN")
end

grip:ClearAllPoints()
grip:SetPoint("BOTTOMRIGHT")
grip:SetScript("OnEnter", function(self)
	self.tex:SetDesaturated(false)
end)
grip:SetScript("OnLeave", function(self)
	self.tex:SetDesaturated(true)
end)

InterfaceOptionsFrame:SetPoint("CENTER", UIParent, "CENTER")

InterfaceOptionsFrameCategories:SetPoint("BOTTOMLEFT", InterfaceOptionsFrame, "BOTTOMLEFT", 22, 50)
InterfaceOptionsFrameAddOns:SetPoint("BOTTOMLEFT", InterfaceOptionsFrame, "BOTTOMLEFT", 22, 50)



InterfaceOptionsFrameAddOns:EnableMouseWheel(true)
InterfaceOptionsFrameCategories:EnableMouseWheel(true)

InterfaceOptionsFrameCategories:HookScript("OnMouseWheel", function(self, dir)
    self.update()
end)
InterfaceOptionsFrameAddOns:HookScript("OnMouseWheel", function(self, dir)
    self.update()
end)

--InterfaceOptionsFrame:SetFrameStrata("FULLSCREEN_DIALOG")
InterfaceOptionsFrame:SetResizable(true)
--InterfaceOptionsFrame:SetWidth(900)
--default size is 620x500
InterfaceOptionsFrame:SetMinResize(620, 500)
InterfaceOptionsFrame:SetToplevel(true)

makeMovable(InterfaceOptionsFrame)
makeMovable(ChatConfigFrame)
makeMovable(AudioOptionsFrame)
makeMovable(GameMenuFrame)
makeMovable(OptionsFrame)


--fix for the KeyBindingFrame that is nil until you open it
function fixkeybframe(self, button, down)
    local mov=_G[KeyBindingFrame:GetName() .. "Mover"]
    if(mov==nil)then
        makeMovable(KeyBindingFrame)
    end
end
local keyb=_G["GameMenuButtonKeybindings"]
keyb:HookScript("OnClick", fixkeybframe)
--

--if MacOptionsFrame then
--   makeMovable(MacOptionsFrame)
--end
