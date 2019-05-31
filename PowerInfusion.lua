PITarget = nil
Whisper = true 
Yell = false 
PISpellId = nil
ConfirmCast = true

local POWER_INFUSION_SPELL_NAME = "Power Infusion"
local POWER_INFUSION_SPELL_TEXTURE = "Spell_Holy_PowerInfusion"
local CHECK_MAX_WAIT = 0.2
local MINIMUM_MAGE_MANA_REQUIRED = 1000
local ShouldCheckResult = nil

local function print(text)
    DEFAULT_CHAT_FRAME:AddMessage(text)
end

local function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

local function TryToTarget(name)
    local orig = UIErrorsFrame_OnEvent
    UIErrorsFrame_OnEvent = function() end
    TargetByName(name, true)
    UIErrorsFrame_OnEvent = orig
    local target = UnitName'target'
    return target and strupper(target) == strupper(name)
end

local function IsInfused(unit) 
	for i = 1, 32 do 
		local spell = UnitBuff(unit, i)
		if spell and string.find(spell, POWER_INFUSION_SPELL_TEXTURE) then 
			return true 
		end 
	end 
	return false 
end 

local function FinishedSuccessfully() 
	print("|cFFFF8080 PowerInfusion |cFF00FFFF ∞∞∞ POWER INFUSED " .. strupper(PITarget) .. " ∞∞∞");
	if Whisper then 
		SendChatMessage("∞∞∞ YOU ARE INFUSED WITH POWER ∞∞∞", "WHISPER", nil, PITarget)
	end 
	if Yell then 
		SendChatMessage("POWER INFUSED " .. strupper(PITarget), "YELL")
	end 
	TargetLastTarget() 
	ShouldCheckResult = nil
end 

local function FinishedOutOfRange() 
	print("|cFFFF8080 PowerInfusion |cFFFFFF00Failed infusing " .. PITarget .. ", player is too far!");
	if Whisper then 
		SendChatMessage("You're not in range for PI!", "WHISPER", nil, PITarget)
	end 	
	TargetLastTarget() 
	ShouldCheckResult = nil
end 

function PowerInfusion_OnLoad()
	SLASH_PowerInfusion1 = "/pi"
    SlashCmdList["PowerInfusion"] = PowerInfusion_Main

	print("|cFFFF8080 PowerInfusion |rLoaded, write |cFF00FF00/pi h|r for help")
end 

function PowerInfusion_OnUpdate()
	if ShouldCheckResult then 
		local elapsed = GetTime() - ShouldCheckResult

		local cooldown = GetSpellCooldown(PISpellId, "spell")
		if cooldown ~= 0 then 
			FinishedSuccessfully()
		else 
			if elapsed >= CHECK_MAX_WAIT then 
				FinishedOutOfRange()
			end 
		end 

	end 
end 

function PowerInfusion_Cast() 
	if not PITarget then 
		print("|cFFFF8080 PowerInfusion |cFFFF0000PI target wasn't set, use /pi PLAYERNAME first.");
		return 
	end 

	-- make sure priest has learnt PI
	if not PISpellId or GetSpellName(PISpellId, "spell") ~= POWER_INFUSION_SPELL_NAME then
	
		-- get spell number of spells
		local spelltabs = GetNumSpellTabs()
		local numspells = 0
		local i
		local temp
	
		for i = 1, spelltabs do
			_, _, _, temp = GetSpellTabInfo(i)
			numspells = numspells + temp
		end
	
		-- 2) locate PI in the spell book
		for i = 1, numspells do
			if GetSpellName(i, "spell") == POWER_INFUSION_SPELL_NAME then
				PISpellId = i
				break
				
			elseif i == numspells then
				print("|cFFFF8080 PowerInfusion |cFFFF0000Can't find " .. POWER_INFUSION_SPELL_NAME .. " in your spellbook!");
				return -- can't find PI
			end
		end
	end
	
	-- Now we've found PI. Check the cooldown		
	local cdStart, cdDuration = GetSpellCooldown(PISpellId, "spell")
	if cdStart ~= 0 then 
		local sec = cdDuration - (GetTime() - cdStart)
		local msg = POWER_INFUSION_SPELL_NAME .. " on cooldown, ready in " .. round(sec) .. " seconds "
		print("|cFFFF8080 PowerInfusion |cFFFFFF00" .. msg);
		if Whisper then 
			SendChatMessage(msg, "WHISPER", nil, PITarget)
		end 
		return
	end
	
	-- Make sure target is in range
	local cooldown = GetSpellCooldown(PISpellId, "spell")
	if cooldown ~= 0 then 
		local msg = POWER_INFUSION_SPELL_NAME .. " on cooldown, ready in " .. round(cooldown) .. " seconds "
		print("|cFFFF8080 PowerInfusion |cFFFFFF00" .. msg);
		if Whisper then 
			SendChatMessage(msg, "WHISPER", nil, PITarget)
		end 
		return
	end

	if not TryToTarget(PITarget) then 
		print("|cFFFF8080 PowerInfusion |cFFFFFF00" .. PITarget .. " is not in range!");
		if Whisper then 
			SendChatMessage("You're not around, can't PI!", "WHISPER", nil, PITarget)
		end 
		return
	end 

	local mana = UnitMana("target");
	if mana < MINIMUM_MAGE_MANA_REQUIRED then 
		print("|cFFFF8080 PowerInfusion |cFFFFFF00" .. PITarget .. " does not have enough mana!");
		if Whisper then 
			SendChatMessage("You don't have enough mana!", "WHISPER", nil, PITarget)
		end 
		TargetLastTarget()
		return
	end 

	if IsInfused("target") then 
		print("|cFFFF8080 PowerInfusion |cFFFFFF00Target already has Power Infusion!");
		TargetLastTarget()
	else 
		-- SpellStopTargeting()
		CastSpell(PISpellId, "spell")

		if ConfirmCast then 
			ShouldCheckResult = GetTime()
		else
			FinishedSuccessfully()
		end 
	end 
end 

function PowerInfusion_Main(msg) 
	local _, _, cmd, arg1 = string.find(string.upper(msg), "([%w]+)%s*(.*)$");
    -- print("|cFFFF8080 RaidLogger |rcmd " .. cmd .. " / arg1 " .. arg1)
    if not cmd then
        PowerInfusion_Cast()
	elseif  "W" == cmd then
		Whisper = not Whisper
		if Whisper then 
			print("|cFFFF8080 PowerInfusion |rWhisper is now |cFF44FF44enabled|r.")
		else 
			print("|cFFFF8080 PowerInfusion |rWhisper is now |cFFFF4444disabled|r.")
		end 
	elseif  "Y" == cmd then
		Yell = not Yell
		if Yell then 
			print("|cFFFF8080 PowerInfusion |rYelling is now |cFF44FF44enabled|r.")
		else 
			print("|cFFFF8080 PowerInfusion |rYelling is now |cFFFF4444disabled|r.")
		end 
	elseif  "H" == cmd then
		if PITarget then 
			print("|cFFFF8080 PowerInfusion |r • Current power infusion target: |cFFFF00FF" .. PITarget)
		else 
			print("|cFFFF8080 PowerInfusion |r • No PI target set.")
		end 
		if Whisper then 
			print("|cFFFF8080 PowerInfusion |r • Whisper upon PI is |cFF44FF44enabled|r.")
		else 
			print("|cFFFF8080 PowerInfusion |r • Whisper upon PI is |cFFFF4444disabled|r.")
		end 
		if Yell then 
			print("|cFFFF8080 PowerInfusion |r • Yelling upon PI is |cFF44FF44enabled|r.")
		else 
			print("|cFFFF8080 PowerInfusion |r • Yelling upon PI is |cFFFF4444disabled|r.")
		end 
        print("|cFFFF8080 PowerInfusion |rCommands: ")
        print("|cFFFF8080 PowerInfusion |r  |cFF00FF00/pi|r - cast PI on caster player, if possible.")
		print("|cFFFF8080 PowerInfusion |r  |cFF00FF00/pi <CASTER_NAME>|r - set player to infuse. Example: |cFF00FF00/pi elila|r")
		print("|cFFFF8080 PowerInfusion |r  |cFF00FF00/pi w|r - enable / disable whispering when PI is performed.|r")
		print("|cFFFF8080 PowerInfusion |r  |cFF00FF00/pi y|r - enable / disable yelling when PI is performed.|r")
	else
		PITarget = cmd
		print("|cFFFF8080 PowerInfusion |rPI target has been set to |cFF00FFFF" .. strupper(PITarget))
	end
end 