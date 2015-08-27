--Settings
local showPets      = false 
local enableAddOn   = true
local showFriendly  = false
local showClassIcon = false
local healthBarWidth = 140;
local helthBarHeight = 12;
			
			
--Don't edit
local currentDebuffs = {}

local Players = {}
local Targets = {}

local Icons = {
	["Druid"] = "Interface\\AddOns\\CustomNameplates\\Class\\ClassIcon_Druid",
	["Hunter"] = "Interface\\AddOns\\CustomNameplates\\Class\\ClassIcon_Hunter",
	["Mage"] = "Interface\\AddOns\\CustomNameplates\\Class\\ClassIcon_Mage",
	["Paladin"] = "Interface\\AddOns\\CustomNameplates\\Class\\ClassIcon_Paladin",
	["Priest"] = "Interface\\AddOns\\CustomNameplates\\Class\\ClassIcon_Priest",
	["Rogue"] = "Interface\\AddOns\\CustomNameplates\\Class\\ClassIcon_Rogue",
	["Shaman"] = "Interface\\AddOns\\CustomNameplates\\Class\\ClassIcon_Shaman",
	["Warlock"] = "Interface\\AddOns\\CustomNameplates\\Class\\ClassIcon_Warlock",
	["Warrior"] = "Interface\\AddOns\\CustomNameplates\\Class\\ClassIcon_Warrior",
}

-- All names should be in full lower case. All checks against the list should be done with string.lower();
local blacklist = {
	["exactName"] = {
		["fire nova totem"] = true,
	},
	["containsName"] = {
		-- There is a space before totem so that players with "totem" in the name is not included.
		[" totem"] = true
	}
}

function cnpHandleEvent(event) --Handles wow events
	if event == "PLAYER_ENTERING_WORLD" then
		if (enableAddOn) then
			ShowNameplates()
			if (showFriendly) then
				ShowFriendNameplates()
			else
				HideFriendNameplates()
			end
		else
			HideNameplates()
			HideFriendNameplates()
		end
		deltaUpdate = GetTime()
	end
	
	if event == "PLAYER_TARGET_CHANGED" or event == "UNIT_AURA" then
		getDebuffs()
	end
end

function getDebuffs() --get debuffs on current target and store it in list
	local i = 1
	currentDebuffs = {}
	local debuff = UnitDebuff("target", i)
	while debuff do
		currentDebuffs[i] = debuff
		i = i + 1
		debuff = UnitDebuff("target", i)
	end
end

function cnpUpdate() --updates the frames ~every 20-50ms
	CustomNameplates_OnUpdate()
end


local function IsNamePlateFrame(frame)
 local overlayRegion = frame:GetRegions()
  if not overlayRegion or overlayRegion:GetObjectType() ~= "Texture" or overlayRegion:GetTexture() ~= "Interface\\Tooltips\\Nameplate-Border" then
    return false
  end
  return true
end

local function isPet(name)
	PetsRU = {"Рыжая полосатая кошка", "Серебристая полосатая кошка", "Бомбейская кошка", "Корниш-рекс",
	"Ястребиная сова", "Большая рогатая сова", "Макао", "Сенегальский попугай", "Черная королевская змейка",
	"Бурая змейка", "Багровая змейка", "Луговая собачка", "Тараканище", "Анконская курица", "Щенок ворга",
	"Паучок Дымной Паутины", "Механическая курица", "Птенец летучего хамелеона", "Зеленокрылый ара", "Гиацинтовый ара",
	"Маленький темный дракончик", "Маленький изумрудный дракончик", "Маленький багровый дракончик", "Сиамская кошка",
	"Пещерная крыса без сознания", "Механическая белка", "Крошечная ходячая бомба", "Крошка Дымок", "Механическая жаба",
	"Заяц-беляк"}
	for _, petName in pairs(PetsRU) do
		if name == petName then
			return true 
		end
	end
	PetsENG = {"Orange Tabby", "Silver Tabby", "Bombay", "Cornish Rex", "Hawk Owl", "Great Horned Owl",
	"Cockatiel", "Senegal", "Black Kingsnake", "Brown Snake", "Crimson Snake", "Prairie Dog", "Cockroach",
	"Ancona Chicken", "Worg Pup", "Smolderweb Hatchling", "Mechanical Chicken", "Sprite Darter", "Green Wing Macaw",
	"Hyacinth Macaw", "Tiny Black Whelpling", "Tiny Emerald Whelpling", "Tiny Crimson Whelpling", "Siamese",
	"Unconscious Dig Rat", "Mechanical Squirrel", "Pet Bombling", "Lil' Smokey", "Lifelike Mechanical Toad"}
	for _, petName in pairs(PetsENG) do
		if name == petName then
			return true 
		end
	end
	return false
end

local IgnoreNames = {};

local function updateDB(name)
	
	if IgnoreNames[name] == nil or IgnoreNames[name] + 5 < GetTime()
	then
		TargetByName(name, true)		
		if UnitIsPlayer("target") then
			local class 		  = UnitClass("target")
			local powerType       = UnitPowerType("target") --0=mana,1=rage,2=energy
			local powerpercentage = UnitMana("target")/UnitManaMax("target")
			table.insert(Players, name)
			Players[name] = {
								["class"] 			= class,
								["powertype"]   	= powerType,
								["powerpercentage"] = powerpercentage,
							}
		else
			IgnoreNames[name] = GetTime();
		end		
	end
end



function CustomNameplates_OnUpdate()
	local frames = {WorldFrame:GetChildren()}
	for _, namePlate in ipairs(frames) do
		if IsNamePlateFrame(namePlate) and namePlate:IsVisible() then
			local HealthBar = namePlate:GetChildren()
			local Border, Glow, Name, Level, _, RaidTargetIcon = namePlate:GetRegions()

			--Healthbar
			HealthBar:SetStatusBarTexture("Interface\\AddOns\\CustomNameplates\\barSmall")
			HealthBar:ClearAllPoints()
			HealthBar:SetPoint("CENTER", namePlate, "CENTER", 0, -10)
			HealthBar:SetWidth(healthBarWidth) --Edit this for width of the healthbar
			HealthBar:SetHeight(helthBarHeight) --Edit this for height of the healthbar
			
			--HealthbarBackground
			if HealthBar.bg == nil then
				HealthBar.bg = HealthBar:CreateTexture(nil, "BORDER")
				HealthBar.bg:SetTexture(0.2,0.2,0.2,0.8)
				HealthBar.bg:ClearAllPoints()
				HealthBar.bg:SetPoint("CENTER", namePlate, "CENTER", 0, -10)
				HealthBar.bg:SetWidth(HealthBar:GetWidth() + 1.5)
				HealthBar.bg:SetHeight(HealthBar:GetHeight() + 1.5)
			end
									
			--RaidTarget
			RaidTargetIcon:ClearAllPoints()
			RaidTargetIcon:SetWidth(32) --Edit this for width of the raidicon
			RaidTargetIcon:SetHeight(32) --Edit this for height of the raidicon
			RaidTargetIcon:SetPoint("CENTER", HealthBar, "CENTER", 0, 40) --Last two parameters are x,y coords for position relative to Healthbar 
			
			
			if namePlate.debuffIcons == nil then
				namePlate.debuffIcons = {}
			end
		 	
			--DebuffIcons on TargetPlates 
			for j=1,16,1 do
				if namePlate.debuffIcons[j] == nil and j<=8 then --first row
					namePlate.debuffIcons[j] = namePlate:CreateTexture(nil, "BORDER")
					namePlate.debuffIcons[j]:SetTexture(0,0,0,0)
					namePlate.debuffIcons[j]:ClearAllPoints()
					namePlate.debuffIcons[j]:SetPoint("BOTTOMLEFT", HealthBar, "BOTTOMLEFT", (j-1) * 12, -13) --Edit this for position of the debufficons, change 12 to the width of the icon in this case
					namePlate.debuffIcons[j]:SetWidth(12) --Edit this for width of the debufficons
					namePlate.debuffIcons[j]:SetHeight(12) --Edit this for height of the debufficons
				elseif namePlate.debuffIcons[j] == nil and j>8 then --second row
					namePlate.debuffIcons[j] = namePlate:CreateTexture(nil, "BORDER")
					namePlate.debuffIcons[j]:SetTexture(0,0,0,0)
					namePlate.debuffIcons[j]:ClearAllPoints()
					namePlate.debuffIcons[j]:SetPoint("BOTTOMLEFT", HealthBar, "BOTTOMLEFT", (j-9) * 12, -25) --as in first row
					namePlate.debuffIcons[j]:SetWidth(12)
					namePlate.debuffIcons[j]:SetHeight(12)
				end
			end
			
			if UnitExists("target") and HealthBar:GetAlpha() == 1 then --Sets the texture of debuffs to debufficons
				local j = 1
				local k = 1
				for j, e in ipairs(currentDebuffs) do
					namePlate.debuffIcons[j]:SetTexture(currentDebuffs[j])
					namePlate.debuffIcons[j]:SetTexCoord(.078, .92, .079, .937)
					namePlate.debuffIcons[j]:SetAlpha(0.9)
					k = k + 1
				end
				for j=k,16,1 do
					namePlate.debuffIcons[j]:SetTexture(nil)
				end
			else
				for j=1,16,1 do
					namePlate.debuffIcons[j]:SetTexture(nil)
				end
			end
			
			if showClassIcon then
				if namePlate.classIcon == nil then --ClassIcon
					namePlate.classIcon = namePlate:CreateTexture(nil, "BORDER")
					namePlate.classIcon:SetTexture(0,0,0,0)
					namePlate.classIcon:ClearAllPoints()
					namePlate.classIcon:SetPoint("RIGHT", Name, "LEFT", -3, -1)
					namePlate.classIcon:SetWidth(12)
					namePlate.classIcon:SetHeight(12)
				end		

				if namePlate.classIconBorder == nil then --ClassIconBackground
					namePlate.classIconBorder = namePlate:CreateTexture(nil, "BACKGROUND")
					namePlate.classIconBorder:SetTexture(0,0,0,0.9)
					namePlate.classIconBorder:SetPoint("CENTER", namePlate.classIcon, "CENTER", 0, 0)
					namePlate.classIconBorder:SetWidth(13.5)
					namePlate.classIconBorder:SetHeight(13.5)
				end
				
				namePlate.classIconBorder:Hide()
				-- namePlate.classIconBorder:SetTexture(0,0,0,0)
				namePlate.classIcon:SetTexture(0,0,0,0)	
			end
			
			Border:Hide()
			Glow:Hide()
			
			Name:SetFontObject(GameFontNormal)
			Name:SetFont("Interface\\AddOns\\CustomNameplates\\Fonts\\Ubuntu-C.ttf",20)
			Name:SetPoint("BOTTOM", namePlate, "CENTER", 0, -4)
			
			Level:SetFontObject(GameFontNormal)
			Level:SetFont("Interface\\AddOns\\CustomNameplates\\Fonts\\Helvetica_Neue_LT_Com_77_Bold_Condensed.ttf",12) --
			Level:SetPoint("TOPLEFT", Name, "RIGHT", 3, 4)

			HealthBar:Show()
			Name:Show()
			Level:Show()

			if showPets ~= true then
				if isPet(Name:GetText()) then
					HealthBar:Hide()
					Name:Hide()
					Level:Hide()
				end
			end
			
			
			-- Check if blacklisted by exact name.
			if blacklist["exactName"][string.lower(Name:GetText())] == true
			then
				HealthBar:Hide()
				Name:Hide()
				Level:Hide()
			end
			
			for cName, ____ in ipairs(blacklist["containsName"])
			do
				if string.find(string.lower(Name:GetText()), cName)
				then
					HealthBar:Hide()
					Name:Hide()
					Level:Hide()
				end
			end
			
			
			
			local blacklist = {
				["exactName"] = {
					["fire nova totem"] = true
				},
				["containsName"] = {
					-- There is a space before totem so that players with "totem" in the name is not included.
					[" totem"] = true
				}
			}
			

			local red, green, blue, _ = Name:GetTextColor() --Set Color of Namelabel
			-- Print(red.." "..green.." "..blue)
			if red > 0.99 and green == 0 and blue == 0 then
				Name:SetTextColor(1,0.4,0.2,0.85)
			elseif red > 0.99 and green > 0.81 and green < 0.82 and blue == 0 then
				Name:SetTextColor(1,1,1,0.85)
			end
			

			local red, green, blue, _ = HealthBar:GetStatusBarColor() --Set Color of Healthbar
			if blue > 0.99 and red == 0 and green == 0 then
				HealthBar:SetStatusBarColor(0.2,0.6,1,0.85)
			elseif red == 0 and green > 0.99 and blue == 0 then
				HealthBar:SetStatusBarColor(0.6,1,0,0.85)
			end

			local red, green, blue, _ = Level:GetTextColor() --Set Color of Level
			
			if red > 0.99 and green == 0 and blue == 0 then
				Level:SetTextColor(1,0.4,0.2,0.85)
			elseif red > 0.99 and green > 0.81 and green < 0.82 and blue == 0 then
				Level:SetTextColor(1,1,1,0.85)
			end

			local name = Name:GetText() --Set Name text and saves it in a list
			if Players[name] == nil and UnitName("target") == nil and string.find(name, "%s") == nil and string.len(name) <= 12 then--and Targets[name] == nil then
				updateDB(name)
				ClearTarget()
			end
			
			if Players[name] ~= nil then
				HealthBar:SetStatusBarColor(RAID_CLASS_COLORS[string.upper(Players[name]["class"])].r,RAID_CLASS_COLORS[string.upper(Players[name]["class"])].g,RAID_CLASS_COLORS[string.upper(Players[name]["class"])].b,1)
			end
			
			--if currently one of the nameplates is an actual player, draw classicon
			if showClassIcon then
				if  Players[name] ~= nil and namePlate.classIcon:GetTexture() == "Solid Texture" and string.find(namePlate.classIcon:GetTexture(), "Interface") == nil then
					namePlate.classIcon:SetTexture(Icons[Players[name]["class"]])
					namePlate.classIcon:SetTexCoord(.078, .92, .079, .937)
					namePlate.classIcon:SetAlpha(0.9)
					namePlate.classIconBorder:Show()
				end
			end
		end
	end
end


