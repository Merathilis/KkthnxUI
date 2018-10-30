local K, C, L = unpack(select(2, ...))
if C["Misc"].ImprovedStats ~= true then
	return
end

local Module = K:GetModule("Miscellaneous")

-- Add extra data to the role stats panel while enabling scrolling to prevent stats overflow.
function Module:MissingStats()
	--if not NDuiDB["Misc"]["MissingStats"] then return end
	if IsAddOnLoaded("DejaCharacterStats") then
		return
	end

	local statPanel = CreateFrame("Frame", nil, CharacterFrameInsetRight)
	statPanel:SetSize(200, 350)
	statPanel:SetPoint("TOP", 0, -5)

	local scrollFrame = CreateFrame("ScrollFrame", nil, statPanel, "UIPanelScrollFrameTemplate")
	scrollFrame:SetAllPoints()
	scrollFrame.ScrollBar:Hide()
	scrollFrame.ScrollBar.Show = K.Noop

	local stat = CreateFrame("Frame", nil, scrollFrame)
	stat:SetSize(200, 1)
	scrollFrame:SetScrollChild(stat)
	CharacterStatsPane:ClearAllPoints()
	CharacterStatsPane:SetParent(stat)
	CharacterStatsPane:SetAllPoints(stat)

	hooksecurefunc("PaperDollFrame_UpdateSidebarTabs", function()
		if (not _G[PAPERDOLL_SIDEBARS[1].frame]:IsShown()) then
			statPanel:Hide()
		else
			statPanel:Show()
		end
	end)

	-- Change default data
	PAPERDOLL_STATCATEGORIES = {
		[1] = {
			categoryFrame = "AttributesCategory",
			stats = {
				[1] = { stat = "STRENGTH", primary = LE_UNIT_STAT_STRENGTH },
				[2] = { stat = "AGILITY", primary = LE_UNIT_STAT_AGILITY },
				[3] = { stat = "INTELLECT", primary = LE_UNIT_STAT_INTELLECT },
				[4] = { stat = "STAMINA" },
				[5] = { stat = "ARMOR" },
				[6] = { stat = "STAGGER", hideAt = 0, roles = { "TANK" }},
				[7] = { stat = "ATTACK_DAMAGE", primary = LE_UNIT_STAT_STRENGTH, roles = { "TANK", "DAMAGER" } },
				[8] = { stat = "ATTACK_AP", hideAt = 0, primary = LE_UNIT_STAT_STRENGTH, roles = { "TANK", "DAMAGER" } },
				[9] = { stat = "ATTACK_ATTACKSPEED", primary = LE_UNIT_STAT_STRENGTH, roles = { "TANK", "DAMAGER" } },
				[10] = { stat = "ATTACK_DAMAGE", primary = LE_UNIT_STAT_AGILITY, roles = { "TANK", "DAMAGER" } },
				[11] = { stat = "ATTACK_AP", hideAt = 0, primary = LE_UNIT_STAT_AGILITY, roles = { "TANK", "DAMAGER" } },
				[12] = { stat = "ATTACK_ATTACKSPEED", primary = LE_UNIT_STAT_AGILITY, roles = { "TANK", "DAMAGER" } },
				[13] = { stat = "SPELLPOWER", hideAt = 0, primary = LE_UNIT_STAT_INTELLECT },
				[14] = { stat = "MANAREGEN", hideAt = 0, primary = LE_UNIT_STAT_INTELLECT },
				[15] = { stat = "ENERGY_REGEN", hideAt = 0, primary = LE_UNIT_STAT_AGILITY },
				[16] = { stat = "RUNE_REGEN", hideAt = 0, primary = LE_UNIT_STAT_STRENGTH },
				[17] = { stat = "FOCUS_REGEN", hideAt = 0, primary = LE_UNIT_STAT_AGILITY },
				[18] = { stat = "MOVESPEED" },
			},
		},
		[2] = {
			categoryFrame = "EnhancementsCategory",
			stats = {
				{ stat = "CRITCHANCE", hideAt = 0 },
				{ stat = "HASTE", hideAt = 0 },
				{ stat = "MASTERY", hideAt = 0 },
				{ stat = "VERSATILITY", hideAt = 0 },
				{ stat = "LIFESTEAL", hideAt = 0 },
				{ stat = "AVOIDANCE", hideAt = 0 },
				{ stat = "SPEED", hideAt = 0 },
				{ stat = "DODGE", roles = { "TANK" } },
				{ stat = "PARRY", hideAt = 0, roles = { "TANK" } },
				{ stat = "BLOCK", hideAt = 0, showFunc = C_PaperDollInfo.OffhandHasShield },
			},
		},
	}

	PAPERDOLL_STATINFO["ENERGY_REGEN"].updateFunc = function(statFrame, unit)
		statFrame.numericValue = 0
		PaperDollFrame_SetEnergyRegen(statFrame, unit)
	end

	PAPERDOLL_STATINFO["RUNE_REGEN"].updateFunc = function(statFrame, unit)
		statFrame.numericValue = 0
		PaperDollFrame_SetRuneRegen(statFrame, unit)
	end

	PAPERDOLL_STATINFO["FOCUS_REGEN"].updateFunc = function(statFrame, unit)
		statFrame.numericValue = 0
		PaperDollFrame_SetFocusRegen(statFrame, unit)
	end

	if K.Client == "deDE" then
		function PaperDollFrame_SetAttackSpeed(statFrame, unit)
			local meleeHaste = GetMeleeHaste()
			local speed, offhandSpeed = UnitAttackSpeed(unit)
			local displaySpeed = format("%.2f", speed)
			if offhandSpeed then
				offhandSpeed = format("%.2f", offhandSpeed)
			end
			if offhandSpeed then
				displaySpeed = K.ShortValue(displaySpeed).." / "..offhandSpeed
			else
				displaySpeed = K.ShortValue(displaySpeed)
			end
			PaperDollFrame_SetLabelAndText(statFrame, WEAPON_SPEED, displaySpeed, false, speed)

			statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, ATTACK_SPEED).." "..displaySpeed..FONT_COLOR_CODE_CLOSE
			statFrame.tooltip2 = format(STAT_ATTACK_SPEED_BASE_TOOLTIP, K.ShortValue(meleeHaste))
			statFrame:Show()
		end
	end
end

function Module:OnEnable()
	if C["Misc"].ImprovedStats ~= true then
		return
	end

	self:MissingStats()
end