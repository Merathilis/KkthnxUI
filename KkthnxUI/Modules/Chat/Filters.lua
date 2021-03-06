local K, C = unpack(select(2, ...))

local _G = _G
local ipairs = ipairs
local string_match = string.match

local ChatFrame1 = _G.ChatFrame1
local ChatFrame_AddMessageEventFilter = _G.ChatFrame_AddMessageEventFilter
local GetTime = _G.GetTime
local UnitIsInMyGuild = _G.UnitIsInMyGuild

local function CreateGeneralFilterList()
	-- This is to clear away startup messages that has no events connected to them
	local AddMessage = ChatFrame1.AddMessage
	ChatFrame1.AddMessage = function(self, msg, ...)
		if msg then
			for _, filter in ipairs(K.GeneralChatSpam) do
				if string_match(msg, filter) then
					return
				end
			end
		end

		return AddMessage(self, msg, ...)
	end
end

if C["Chat"].Filter then
	CreateGeneralFilterList() -- Load it as soon as possible.
end

if C["Chat"].Filter then
	-- RepeatFilter Credits: Goldpaw
	local function CreateRepeatFilter(self, _, text, sender)
		if not text or sender == K.Name or UnitIsInMyGuild(sender) then
			return
		end

		-- Initialize the repeat cache
		if not self.repeatThrottle then
			self.repeatThrottle = {}
		end

		-- We use this in all conditionals, let's avoid double function calls!
		local now = GetTime()

		-- Prune away messages that has timed out without repetitions.
		-- This iteration shouldn't cost much when called on every new message,
		-- the database simply won't have time to accumulate very many entries.
		for msg,when in pairs(self.repeatThrottle) do
			if when > now and msg ~= text then
				self.repeatThrottle[msg] = nil
			end
		end

		-- If the timer for this message hasn't been set, or if 10 seconds have passed,
		-- we set the timer to 10 new seconds, show the message once, and return.
		if not self.repeatThrottle[text] or self.repeatThrottle[text] > now then
			self.repeatThrottle[text] = now + 10
			return
		end

		-- If we got here the timer has been set, but it's still too early.
		if self.repeatThrottle[text] < now then
			return true
		end
	end

	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", CreateRepeatFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_EMOTE", CreateRepeatFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_MESSAGE", CreateRepeatFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_EMOTE", CreateRepeatFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_SAY", CreateRepeatFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", CreateRepeatFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_TEXT_EMOTE", CreateRepeatFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", CreateRepeatFilter)

	local function CreateTalentFilter(_, _, msg, ...)
		if msg then
			for _, filter in ipairs(K.TalentChatSpam) do
				if string_match(msg, filter) then
					return true
				end
			end
		end

		return false, msg, ...
	end

	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", CreateTalentFilter)
end