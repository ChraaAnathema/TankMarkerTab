local backdrop = {
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = false,
	edgeSize = 32,
	insets = {
		left = 12,
		right = 12,
		top = 12,
		bottom = 12
	}
}

local frame = CreateFrame("Frame", "MarkerFrame", UIParent)
frame:EnableMouse(true)
frame:SetMovable(true)
frame:SetHeight(75)
frame:SetWidth(275)
frame:SetPoint("CENTER", 0, 0)
frame:SetBackdrop(backdrop)
frame:SetAlpha(1.00)
frame:SetUserPlaced(true)
frame:Hide()

local TMT_Header = CreateFrame("Frame", "TMT_Header", frame)
TMT_Header:SetPoint("TOP", frame, "TOP", 0, 12)
TMT_Header:SetWidth(256)
TMT_Header:SetHeight(64)
TMT_Header:SetBackdrop({
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Header"
})

local TMT_TitleRegion = frame:CreateTitleRegion()
TMT_TitleRegion:SetWidth(256)
TMT_TitleRegion:SetHeight(64)
TMT_TitleRegion:SetPoint("TOP", frame, "TOP", 0, 12)

local TMT_FontString = TMT_Header:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
TMT_FontString:SetPoint("CENTER", TMT_Header, "CENTER", 0, 12)
TMT_FontString:SetText("Tank Assignments")

local button = CreateFrame("Button", "Close_button", frame)
button:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
button:SetHeight(32)
button:SetWidth(32)
button:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
button:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
button:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
button:SetScript("OnLoad", 
	function()
		button:RegisterForClicks("AnyUp")
	end 
)
button:SetScript("OnClick", TMTDeactivate)

--scbTexture:SetTexCoord(0, 0.25, 0, 0.25); -- Star
--scbTexture:SetTexCoord(0.25, 0.5, 0, 0.25); -- Circle
--scbTexture:SetTexCoord(0.5, 0.75, 0, 0.25); -- Diangle
--scbTexture:SetTexCoord(0.75, 1, 0, 0.25); -- Triangle
--scbTexture:SetTexCoord(0, 0.25, 0.25, 0.5); -- Moon
--scbTexture:SetTexCoord(0.25, 0.5, 0.25, 0.5); -- Square
--scbTexture:SetTexCoord(0.5, 0.75, 0.25, 0.5); -- Cross
--scbTexture:SetTexCoord(0.75, 1, 0.25, 0.5); -- Skull

local buttonNames = {}
local marksActive = {1, 1, 1, 1, 1, 1, 1, 1}

for i=1,8 do
	buttonName = "buttonTMT"..i
	textureName = "buttonTextureTMT"..i
	buttonNames[buttonName] = i

	CreateFrame("CheckButton", buttonName, frame)
	currentButton = getglobal(buttonName)
	currentButton:SetPoint("TOPLEFT", frame, "TOPLEFT", 20 + ((i-1)*30), -30)
	currentButton:SetHeight(25)
	currentButton:SetWidth(25)
	currentButton:CreateTexture(textureName)
	getglobal(textureName):SetAllPoints()
	getglobal(textureName):SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
	if i > 4 then
		left = 0 + (i-5)*0.25
		top = 0.25
	else
		left = 0 + (i-1)*0.25
		top = 0
	end

	getglobal(textureName):SetTexCoord(left, left + 0.25, top, top + 0.25);
	currentButton:SetScript("OnLoad",
		function()
			currentButton:RegisterForClicks("AnyUp")
		end
	)
	currentButton:SetScript("OnClick", 
		function()
			btn = getglobal(this:GetName())
			btnNr = buttonNames[this:GetName()]
			
			if marksActive[btnNr] == 1 then
				btn:SetChecked(0)
				marksActive[btnNr] = 0
				btn:SetAlpha(.3)
				btn:UnlockHighlight()
			else
				btn:SetChecked(1)
				marksActive[btnNr] = 1
				btn:SetAlpha(1)
				btn:LockHighlight()
			end
		end
	)
end

local oldTabTarget = TargetNearestEnemy
local TMTActive = 0

function TMTActivate()
	TargetNearestEnemy = TMTTabTarget
	frame:Show();
	TMTActive = 1
end

function TMTDeactivate()
	TargetNearestEnemy = oldTabTarget
	frame:Hide();
	TMTActive = 0
end

--deadmans switch, never do more than this amount of tabs
maxTabs = 15

function TMTTabTarget()
	oldTabTarget()
	if UnitExists("target") then
		markNumber = GetRaidTargetIndex("target")
		hasActiveTargets = false
		for i=1,8 do
			hasActiveTargets = (hasActiveTargets or marksActive[i] == 1)
		end

		if hasActiveTargets then
			tabsDone = 0
			while ((markNumber == nil or marksActive[markNumber] ~= 1) and maxTabs > tabsDone) do
				oldTabTarget()
				markNumber = GetRaidTargetIndex("target")
				tabsDone = tabsDone + 1
			end
		end
	end
end

-- Add OnLoaded that informes the player what the slash command is.
-- Check protected function (ADDON_ACTION_BLOCKED, ADDON_ACTION_FORBIDDEN). Perhaps due to simply
--	rebinding TargestNearestEnemy, it still counts as hardware event?
-- Active-toggle in frame?
-- Button to reset assignments? Might need to make the OnClick functions non-anonymous.
-- Functionality for raid leader/assistants to broadcast marks? Perhaps its own admin frame.

SLASH_TMT1 = "/tmt";

local function HandleSlashCommands(str)
	if (str == "help" or str == "" or str == nil) then
		DEFAULT_CHAT_FRAME:AddMessage("Commands:", 1.0, 1.0, 0);
		DEFAULT_CHAT_FRAME:AddMessage("   /toggle |cff00d2d6help |r-- toggle TMT on and off", 1.0, 1.0, 0);
	elseif (str == "toggle") then
		if TMTActive == 0 then
			TMTActivate()
		else
			TMTDeactivate()
		end
	else
		DEFAULT_CHAT_FRAME:AddMessage("Command not found", 1.0, 1.0, 0);
	end
end

SlashCmdList.TMT = HandleSlashCommands;