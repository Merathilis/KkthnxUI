local _, C = unpack(select(2, ...))
if C["ActionBar"].Enable ~= true then
	return
end

local _G = _G

local ActionBar2 = CreateFrame("Frame", "Bar2Holder", ActionBarAnchor)
ActionBar2:SetAllPoints(ActionBarAnchor)
MultiBarBottomLeft:SetParent(ActionBar2)
MultiBarBottomLeft:EnableMouse(false)

for i = 1, _G.NUM_ACTIONBAR_BUTTONS do
	local b = _G["MultiBarBottomLeftButton" .. i]
	local b2 = _G["MultiBarBottomLeftButton" .. i - 1]

	b:ClearAllPoints()

	if i == 1 then
		b:SetPoint("BOTTOM", ActionButton1, "TOP", 0, C["ActionBar"].ButtonSpace)
	else
		b:SetPoint("LEFT", b2, "RIGHT", C["ActionBar"].ButtonSpace, 0)
	end
end

-- Hide bar
if (C["ActionBar"].BottomBars == 1) then
	ActionBar2:Hide()
end