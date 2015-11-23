--[[
- TankBuddy 1.50
- Author: Kolthor from Doomhammer EU, Snelf, Ogrisch
- Contact: http://www.curse-gaming.com | USER NAME: Kolthor
--]]


-- Globals
local L = AceLibrary("AceLocale-2.2"):new("TankBuddy")
local BS = AceLibrary("Babble-Spell-2.2")
TankBuddy = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0")


function TankBuddy:OnEnable()
    local _, class = UnitClass("player")
	local _, race = UnitRace("player")

	if class == "WARRIOR" or class == "DRUID" then
		self:RegisterEvent("SpellStatus_SpellCastInstant")
	end	
end

function TankBuddy:SpellStatus_SpellCastInstant(sId, sName, sRank, sFullName, sCastTime)
	local TBAbility = "";
	if sName == BS["Challenging Shout"] then
		TBAbility = TB_GUI_CS;
	elseif sName == BS["Challenging Roar"] then
		TBAbility = TB_GUI_CR;
	end
	
	if (TBAbility and TBAbility ~= "") then
		TB_Announce(TBAbility);
	end
end


local player_is_warrior = false
local TB_battleshoutfound = false
local TB_intellectfound = false
local TB_intellectfound1 = false
local TB_spiritfound = false
local TB_spiritfound1 = false
local TB_spiritfound2 = false
local TB_dsfound = false
local TB_rficons = 0
local TB_Gripfound = false

TBSettingsCharRealm = UnitName("player") .. "@" .. GetCVar("realmName");
TankBuddy.Channels = {
	{ "CTRaid", TB_GUI_Channel_Ctraid, "MS " },
	{ "RaidWarning", TB_GUI_Channel_RaidWarning, "RAID_WARNING" },
	{ "Raid", TB_GUI_Channel_Raid, "RAID" },
	{ "Party", TB_GUI_Channel_Party, "PARTY" },
	{ "Yell", TB_GUI_Channel_Yell, "YELL" },
	{ "Say", TB_GUI_Channel_Say, "SAY" },
	{ "Custom", TB_GUI_Channel_Custom, "CHANNEL" }
};
TankBuddy.Modes = {
	{ "Raid", TB_GUI_Raid },
	{ "Party", TB_GUI_Party },
	{ "Alone", TB_GUI_Alone }
};

function PlayerClass(class, unit)
	if class then
		local unit = unit or "player"
		local _, c = UnitClass(unit)
		if c then
			if string.lower(c) == string.lower(class) then
				return true
			end
		end
	end
	return false
end

function isShieldEquipped()
	local player_is_warrior = PlayerClass("Warrior", "player")
	local slot = GetInventorySlotInfo("SecondaryHandSlot")
	local link = GetInventoryItemLink("player", slot)
	if(link and player_is_warrior) then
		local found, _, id, name = string.find(link, "item:(%d+):.*%[(.*)%]")
		if found then
			local _,_,_,_,_,itemType = GetItemInfo(tonumber(id))
			if(itemType == "Shields") then
				return true
			end
		end
	end
	return false
end

function Ber()
	local player_is_warrior = PlayerClass("Warrior", "player")
	local _, name, isActive = GetShapeshiftFormInfo(3);
	if(isActive and player_is_warrior and (name == "Berserker Stance")) then
		return true
	end
	return false
end

function Def()
	local player_is_warrior = PlayerClass("Warrior", "player")
	local _, name, isActive = GetShapeshiftFormInfo(2);
	if(isActive and player_is_warrior and (name == "Defensive Stance")) then
		return true
	end
	return false
end

function TB_OnLoad()	
	_, englishClass = UnitClass("player");
	if (englishClass == "WARRIOR") then
		TankBuddy.Tabs = {
			{ TB_GUI_General, "Interface\\Icons\\Spell_Shadow_SoulGem"},
			{ TB_GUI_Taunt, "Interface\\Icons\\Spell_Nature_Reincarnation" },
			{ TB_GUI_MB, "Interface\\Icons\\Ability_Warrior_PunishingBlow" },
			{ TB_GUI_LS, "Interface\\Icons\\Spell_Holy_AshesToAshes" },
			{ TB_GUI_SW, "Interface\\Icons\\Ability_Warrior_ShieldWall" },
			{ TB_GUI_CS, "Interface\\Icons\\Ability_BullRush" },
			{ TB_GUI_LG, "Interface\\Icons\\INV_Misc_Gem_Pearl_05" }
		};
		TB_TankForm = 2;	--Defensive stance has Shapeshiftform number 2
		SalvDefensiveBearText:SetText(TB_GUI_SalvationDefensive);
		TB_RFCheckButton:Hide();
		SalvRFText:Hide();
		TB_BubbleCheckButton:Hide();
		BubbleText:Hide();
	elseif (englishClass == "DRUID") then
		TankBuddy.Tabs = {
			{ TB_GUI_General, "Interface\\Icons\\Spell_Shadow_SoulGem"},
			{ TB_GUI_Growl, "Interface\\Icons\\Ability_Physical_Taunt" },
			{ TB_GUI_CR, "Interface\\Icons\\Ability_Druid_ChallangingRoar" }
		};
		TB_TankForm = 1;	--Bear form has Shapeshiftform number 1
		SalvDefensiveBearText:SetText(TB_GUI_SalvationBear);
		TB_ShieldCheckButton:Hide();
		SalvShieldText:Hide();
		TB_RFCheckButton:Hide();
		SalvRFText:Hide();
		TB_BubbleCheckButton:Hide();
		BubbleText:Hide();
	elseif (englishClass == "PALADIN") then
		TankBuddy.Tabs = {
			{ TB_GUI_General, "Interface\\Icons\\Spell_Shadow_SoulGem"}
		};
		TB_TankForm = nil;
		TB_DefensiveBearCheckButton:Hide();
		SalvDefensiveBearText:Hide();
		TB_ShieldCheckButton:Hide();
		SalvShieldText:Hide();
	else
		TankBuddy.Tabs = {
			{ TB_GUI_General, "Interface\\Icons\\Spell_Shadow_SoulGem"}
		};
		TB_TankForm = nil;
		TB_DefensiveBearCheckButton:Hide();
		SalvDefensiveBearText:Hide();
		TB_ShieldCheckButton:Hide();
		SalvShieldText:Hide();
		TB_RFCheckButton:Hide();
		SalvRFText:Hide();
		TB_BubbleCheckButton:Hide();
		BubbleText:Hide();
	end
	NUM_TB_TABS = getn(TankBuddy.Tabs);
	MAX_TB_TABS = 8;
	
	TankBuddyFrame:RegisterEvent("VARIABLES_LOADED");					-- Jump to event function when variables are loaded
	
	SLASH_TBSLASH1 = "/tankbuddy";								-- /tankbuddy
	SLASH_TBSLASH2 = "/tb";									-- /tb
	SlashCmdList["TBSLASH"] = TB_SlashCommandHandler;					-- List of slash commands

	TB_SetTab(1);			--Set default tab
	
	for i = 1, NUM_TB_TABS, 1 do
		getglobal("TB_Tab" .. i).tooltiptext = TankBuddy.Tabs[i][1];
		getglobal("TB_Tab" .. i):SetNormalTexture(TankBuddy.Tabs[i][2]);
	end
	
	for i = 1, MAX_TB_TABS, 1 do
		if ( i > NUM_TB_TABS ) then
			getglobal("TB_Tab" .. i):Hide();
		else
			getglobal("TB_Tab" .. i):Show();
		end
	end

	TB_DefensiveBearCheckButton:Disable();		--The "only in Defensive Stance/Bear Form"-checkbox is disabled until "Remove salvation" is checked
	TB_ShieldCheckButton:Disable();		--The "only when shield equipped"-checkbox is disabled until "Remove salvation" is checked
	TB_RFCheckButton:Disable();		--The "only when RF is active"-checkbox is disabled until "Remove salvation" is checked
	TB_ButtonPaste:Disable();		--The paste-button is disabled until the copy-button has been clicked
end

function TB_Tab_OnClick(id)
	if ( not id ) then
		id = this:GetID();
	end
	TB_SetTab(id);
end

function TB_SetTab(id)
	if (not TankBuddyFrame.selectedTab) then
		getglobal("TB_Tab" .. id):SetChecked(1);
	else
		getglobal("TB_Tab" .. TankBuddyFrame.selectedTab):SetChecked(nil);
		if (TankBuddyFrame.selectedTab ~= 1) then
			TBSettings[TBSettingsCharRealm].Announcements[TankBuddy.Tabs[TankBuddyFrame.selectedTab][1]]["Text"] = TB_EditboxText:GetText();
		end
	end
	if (id == 1) then
		TB_OtherOptions:Hide();
		TB_GeneralOptions:Show();
	else
		TB_OtherOptions:Show();
		TB_GeneralOptions:Hide();
		
		TB_EditboxText:SetText(TBSettings[TBSettingsCharRealm].Announcements[TankBuddy.Tabs[id][1]]["Text"]);
		TB_SetTextText:SetText(TB_GUI_EnterNewText[TankBuddy.Tabs[id][1]]);
	end

	TankBuddyFrame.selectedTab = id;
	HeaderText:SetText(TankBuddy.Tabs[id][1]);
	if (TBSettings) then
		TB_SetChannels();
	end
end

function TB_SetChannels()
	if (TankBuddyFrame.selectedTab ~= 1) then
		for i = 1, getn(TankBuddy.Modes), 1 do
			for j = 1, getn(TankBuddy.Channels), 1 do
				if (getglobal("TB_" .. TankBuddy.Modes[i][1] .. TankBuddy.Channels[j][1] .. "CheckButton")) then
					local Checked = TBSettings[TBSettingsCharRealm].Announcements[TankBuddy.Tabs[TankBuddyFrame.selectedTab][1]][TankBuddy.Modes[i][2]][TankBuddy.Channels[j][2]];
					getglobal("TB_" .. TankBuddy.Modes[i][1] .. TankBuddy.Channels[j][1] .. "CheckButton"):SetChecked(Checked);
				end
			end
		end
	end
end

function TB_Channels_OnClick()
	for i = 1, getn(TankBuddy.Modes), 1 do
		for j = 1, getn(TankBuddy.Channels), 1 do
			if (this:GetName() == "TB_" .. TankBuddy.Modes[i][1] .. TankBuddy.Channels[j][1] .. "CheckButton") then
				local Checked = this:GetChecked();
				TBSettings[TBSettingsCharRealm].Announcements[TankBuddy.Tabs[TankBuddyFrame.selectedTab][1]][TankBuddy.Modes[i][2]][TankBuddy.Channels[j][2]] = Checked;
				if (TankBuddy.Channels[j][1] == "Custom") then
					if (Checked) then
						TB_SetCustomChannel(i);
					else
						TB_CustomChannelFrame:Hide();
					end
				end
			end
		end
	end
end

function TB_OnEvent(event)
 	local TBAbility = "";
	-- Execute this function whenever you get a string in the self damage spells section, or when variables are loaded.
	if((event == "CHAT_MSG_SPELL_SELF_DAMAGE") or (event == "CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF"))then
		if (englishClass == "WARRIOR") then
			if (string.find(arg1, TB_tauntLine)) then 									-- Checks if your taunt was resisted
				TBAbility = TB_GUI_Taunt;
			elseif (string.find(arg1, TB_mb)) then			-- Checks if the string has the words "Mocking Blow"
				local mbHit = string.find(arg1, TB_mbHitLine);					-- Checks if your mocking blow was hit
				if (not mbHit) then			-- If your mocking blow didnt hit, then do ..
					TBAbility = TB_GUI_MB;
				end
			end
		elseif (englishClass == "DRUID") then
			if (string.find(arg1, TB_growlLine)) then 									-- Checks if your taunt was resisted
				TBAbility = TB_GUI_Growl;
			end
		end

	elseif(event == "CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS") then
		if (englishClass == "WARRIOR") then
			if (string.find(arg1, TB_sw)) then
				TBAbility = TB_GUI_SW;
			elseif (string.find(arg1, TB_ls)) then
				TBAbility = TB_GUI_LS;
			elseif (string.find(arg1, TB_lg)) then
				TBAbility = TB_GUI_LG;
			end
		elseif (englishClass == "PALADIN") then
			if (string.find(arg1, TB_gc)) then
				TB_gripfound = true
			elseif (string.find(arg1, TB_ds)) then
				TB_dsfound = true
			end
		end
		if (TBSettings[TBSettingsCharRealm].Battleshoutstatus) then
			if arg1 == TB_bs then
				TB_battleshoutfound = true
			end
		end
		if (TBSettings[TBSettingsCharRealm].Stupidstatus) then
			if arg1 == TB_intel or arg1 == TB_intel1 then
				TB_intellectfound = true
			elseif arg1 == TB_intel2 then
				TB_intellectfound1 = true
			elseif arg1 == TB_spiritline then
				TB_spiritfound = true
			elseif arg1 == TB_spiritline1 then
				TB_spiritfound1 = true
			elseif arg1 == TB_spiritline2 then
				TB_spiritfound2 = true
			end
		end

	elseif (event == "PLAYER_AURAS_CHANGED" or event == "UPDATE_SHAPESHIFT_FORMS" or event == "UNIT_INVENTORY_CHANGED") then
		if (TBSettings[TBSettingsCharRealm].Salvstatus) then
			if (TB_PlayerBuff(TB_salvation)) then		--Look for a buff with "Salvation" in it
				if (TB_TankForm) then    -- if we're a warrior or a druid
					if (TBSettings[TBSettingsCharRealm].SalvDefensiveBearstatus) then   --check if we only want to remove salv in tank stances
						local _, _, active, _ = GetShapeshiftFormInfo(TB_TankForm);	--check if the stance is active
						if (active) then																					--if it is then
							if (englishClass == "WARRIOR") then												--if we're a warrior then
								if (TBSettings[TBSettingsCharRealm].Shieldstatus) then				--if we only want to remove salv when shield is also equipped
									if isShieldEquipped() then														--if it found that we do have a shield equipped
										CancelPlayerBuff(TB_PlayerBuff(TB_salvation));					--Cancel it
										TB_Sendmsg(TB_output_salvation);									--announce of removal
									end
								else																						--else we want to remove salvation in tank stance regardless of shield equipped or not
									CancelPlayerBuff(TB_PlayerBuff(TB_salvation));					--Cancel it
									TB_Sendmsg(TB_output_salvation);									--announce of removal
								end
							else																						--if we are a druid, only other option left
								CancelPlayerBuff(TB_PlayerBuff(TB_salvation));					--Cancel it
								TB_Sendmsg(TB_output_salvation);									--announce of removal
							end
						end
					else																						--else we want to remove salvation in any case, regardless of stance
						CancelPlayerBuff(TB_PlayerBuff(TB_salvation));					--Cancel it
						TB_Sendmsg(TB_output_salvation);									--announce of removal
					end
				elseif (englishClass == "PALADIN") then	  --if we're a paladin
					if (TBSettings[TBSettingsCharRealm].Rfstatus) then   --if we only want to remove salvation when we have RF
						if (TB_PlayerBuff(TB_salvation)) then		--Look for a buff with "Salvation" in it
							if ((not TB_gripfound) and (TB_PlayerBuff(TB_righteousfury)) and TB_rficons == 1) or ((TB_gripfound) and (TB_PlayerBuff(TB_righteousfury)) and TB_rficons == 2) then		--Look for a buff with "SealOfFury" in it
								CancelPlayerBuff(TB_PlayerBuff(TB_salvation));					--Cancel it
								TB_Sendmsg(TB_output_salvation);									--announce of removal
								TB_rficons = 0
								TB_gripfound = false
							end
						end
					else
						CancelPlayerBuff(TB_PlayerBuff(TB_salvation));					--Cancel it
						TB_Sendmsg(TB_output_salvation);									--announce of removal
					end
				else																	--if we're anything other than war/dru/pala
					CancelPlayerBuff(TB_PlayerBuff(TB_salvation));					--Cancel it
					TB_Sendmsg(TB_output_salvation);									--announce of removal
				end
			end
		end
		if (TBSettings[TBSettingsCharRealm].Protectionstatus) then
			if (TB_PlayerBuff(TB_protection)) then		--Look for a buff with "SealOfProtection" in it
				CancelPlayerBuff(TB_PlayerBuff(TB_protection));					--Cancel it
				TB_Sendmsg(TB_output_protection);									--announce of removal
			end
		end
		if (TBSettings[TBSettingsCharRealm].Bubblestatus) then
			if (TB_dsfound) then	--Look for a buff with "DivineIntervention" in it
				CancelPlayerBuff(TB_PlayerBuff(TB_divineshield));					--Cancel it
				TB_Sendmsg(TB_output_divineshield);									--announce of removal
				TB_dsfound = false
			end
		end
		if (TBSettings[TBSettingsCharRealm].Battleshoutstatus) then
			if (TB_battleshoutfound) then		--Look for a buff with "BattleShout" in it
				CancelPlayerBuff(TB_PlayerBuff(TB_battleshout));					--Cancel it
				TB_Sendmsg(TB_output_battleshout);									--announce of removal
				TB_battleshoutfound = false
			end
		end
		if (TBSettings[TBSettingsCharRealm].Stupidstatus) then
			if (TB_intellectfound) then
				CancelPlayerBuff(TB_PlayerBuff(TB_intellect));				
				TB_Sendmsg(TB_output_intellect);
				TB_intellectfound = false
			elseif (TB_intellectfound1) then	
				CancelPlayerBuff(TB_PlayerBuff(TB_intellect1));		
				TB_Sendmsg(TB_output_intellect);
				TB_intellectfound1 = false
			elseif (TB_spiritfound) then
				CancelPlayerBuff(TB_PlayerBuff(TB_spirit));			
				TB_Sendmsg(TB_output_spirit);
				TB_spiritfound = false
			elseif (TB_spiritfound1) then
				CancelPlayerBuff(TB_PlayerBuff(TB_spirit1));	
				TB_Sendmsg(TB_output_spirit);
				TB_spiritfound1 = false
			elseif (TB_spiritfound2) then
				CancelPlayerBuff(TB_PlayerBuff(TB_spirit2));	
				TB_Sendmsg(TB_output_spirit);
				TB_spiritfound2 = false
			end
		end

	elseif (event == "VARIABLES_LOADED") then
		-- load each option, set default if not there
		if ( not TBSettings ) then
	 		TBSettings = {};
		end
		if (not TBSettings[TBSettingsCharRealm]) then
	 		TBSettings[TBSettingsCharRealm] = {};
		end

		if (not TBSettings[TBSettingsCharRealm].Announcements) then
			TBSettings[TBSettingsCharRealm].Announcements = {};
		end

		for i = 2, NUM_TB_TABS, 1 do
			if (not TBSettings[TBSettingsCharRealm].Announcements[TankBuddy.Tabs[i][1]]) then
				TBSettings[TBSettingsCharRealm].Announcements[TankBuddy.Tabs[i][1]] = {};
			end
			if (not TBSettings[TBSettingsCharRealm].Announcements[TankBuddy.Tabs[i][1]]["Text"]) then
				TBSettings[TBSettingsCharRealm].Announcements[TankBuddy.Tabs[i][1]]["Text"] = 1;						--Used later to see if it exists
			end
			if (not TBSettings[TBSettingsCharRealm].Announcements[TankBuddy.Tabs[i][1]][TB_GUI_Raid]) then
				TBSettings[TBSettingsCharRealm].Announcements[TankBuddy.Tabs[i][1]][TB_GUI_Raid] = {};
			end
			if (not TBSettings[TBSettingsCharRealm].Announcements[TankBuddy.Tabs[i][1]][TB_GUI_Party]) then
				TBSettings[TBSettingsCharRealm].Announcements[TankBuddy.Tabs[i][1]][TB_GUI_Party] = {};
			end
			if (not TBSettings[TBSettingsCharRealm].Announcements[TankBuddy.Tabs[i][1]][TB_GUI_Alone]) then
				TBSettings[TBSettingsCharRealm].Announcements[TankBuddy.Tabs[i][1]][TB_GUI_Alone] = {};
			end
		end
		
		if (TBSettings[TBSettingsCharRealm].Announcements[TB_GUI_Taunt]) then
			if (TBSettings[TBSettingsCharRealm].Announcements[TB_GUI_Taunt]["Text"] == 1) then
				TBSettings[TBSettingsCharRealm].Announcements[TB_GUI_Taunt]["Text"] = TB_defaultText_t;			-- Default value for text_t
			end
		end
		if (TBSettings[TBSettingsCharRealm].Announcements[TB_GUI_MB]) then
			if (TBSettings[TBSettingsCharRealm].Announcements[TB_GUI_MB]["Text"] == 1) then
				TBSettings[TBSettingsCharRealm].Announcements[TB_GUI_MB]["Text"] = TB_defaultText_mb;				-- Default value for text_mb
			end
		end
		if (TBSettings[TBSettingsCharRealm].Announcements[TB_GUI_LS]) then
			if (TBSettings[TBSettingsCharRealm].Announcements[TB_GUI_LS]["Text"] == 1) then
				TBSettings[TBSettingsCharRealm].Announcements[TB_GUI_LS]["Text"] = TB_defaultText_ls;				-- Default value for text_ls
			end
		end
		if (TBSettings[TBSettingsCharRealm].Announcements[TB_GUI_SW]) then
			if (TBSettings[TBSettingsCharRealm].Announcements[TB_GUI_SW]["Text"] == 1) then
				TBSettings[TBSettingsCharRealm].Announcements[TB_GUI_SW]["Text"] = TB_defaultText_sw;				-- Default value for text_sv
			end
		end
		if (TBSettings[TBSettingsCharRealm].Announcements[TB_GUI_LG]) then
			if (TBSettings[TBSettingsCharRealm].Announcements[TB_GUI_LG]["Text"] == 1) then
				TBSettings[TBSettingsCharRealm].Announcements[TB_GUI_LG]["Text"] = TB_defaultText_lg;				-- Default value for text_lg
			end
		end
		if (TBSettings[TBSettingsCharRealm].Announcements[TB_GUI_CS]) then
			if (TBSettings[TBSettingsCharRealm].Announcements[TB_GUI_CS]["Text"] == 1) then
				TBSettings[TBSettingsCharRealm].Announcements[TB_GUI_CS]["Text"] = TB_defaultText_cs;				-- Default value for text_lg
			end
		end
		if (TBSettings[TBSettingsCharRealm].Announcements[TB_GUI_Growl]) then
			if (TBSettings[TBSettingsCharRealm].Announcements[TB_GUI_Growl]["Text"] == 1) then
				TBSettings[TBSettingsCharRealm].Announcements[TB_GUI_Growl]["Text"] = TB_defaultText_g;				-- Default value for text_g
			end
		end
		if (TBSettings[TBSettingsCharRealm].Announcements[TB_GUI_CR]) then
			if (TBSettings[TBSettingsCharRealm].Announcements[TB_GUI_CR]["Text"] == 1) then
				TBSettings[TBSettingsCharRealm].Announcements[TB_GUI_CR]["Text"] = TB_defaultText_cr;				-- Default value for text_lg
			end
		end
			
		if (not TBSettings[TBSettingsCharRealm].status) then
			TBSettings[TBSettingsCharRealm].status = 1;													-- Default value is 1 for status
		end
		
		--TB_Sendmsg("Tank Buddy " .. TB_version .. TB_output_startup);			-- Tank Buddy loading message
		if (TBSettings[TBSettingsCharRealm].status == 1) then
			TB_register();								-- Registers the event of self spell damage on startup
		else
			TB_EnableCheckButton:SetChecked(0);
		end
		
		TB_DefensiveBearCheckButton:SetChecked(TBSettings[TBSettingsCharRealm].SalvDefensiveBearstatus);
		TB_EnableSalvationCheckButton:SetChecked(TBSettings[TBSettingsCharRealm].Salvstatus);
		TB_EnableProtectionCheckButton:SetChecked(TBSettings[TBSettingsCharRealm].Protectionstatus);
		TB_BattleShoutCheckButton:SetChecked(TBSettings[TBSettingsCharRealm].Battleshoutstatus);
		TB_ShieldCheckButton:SetChecked(TBSettings[TBSettingsCharRealm].Shieldstatus);
		TB_MakeMeStupidButton:SetChecked(TBSettings[TBSettingsCharRealm].Stupidstatus);
		TB_BubbleCheckButton:SetChecked(TBSettings[TBSettingsCharRealm].Bubblestatus);
		TB_RFCheckButton:SetChecked(TBSettings[TBSettingsCharRealm].Rfstatus);
		
		if (TBSettings[TBSettingsCharRealm].Salvstatus) then
			if (TB_TankForm) then		-- and you're a druid or a warrior
				TB_DefensiveBearCheckButton:Enable();
			elseif (englishClass == "PALADIN") then
				TB_RFCheckButton:Enable()
			end
		end
		if TB_DefensiveBearCheckButton:GetButtonState() == "NORMAL" and (TBSettings[TBSettingsCharRealm].SalvDefensiveBearstatus) then
			TB_ShieldCheckButton:Enable();
		end
	end
	
	if (TBAbility and TBAbility ~= "") then
		TB_Announce(TBAbility);
	end
end

-- Split text into a list consisting of the strings in text,
-- separated by strings matching delimiter (which may be a pattern). 
-- example: TB_strsplit(",%s*", "Anna, Bob, Charlie, Dolores")
function TB_strsplit(delimiter, text)
  local list = {}
  local pos = 1
  if string.find("", delimiter, 1) then -- this would result in endless loops
    error("delimiter matches empty string!")
  end
  while 1 do
    local first, last = string.find(text, delimiter, pos)
    if first then -- found?
      tinsert(list, strsub(text, pos, first-1))
      pos = last+1
    else
      tinsert(list, strsub(text, pos))
      break
    end
  end
  return list
end

-- SLASH COMMAND HANDLER --
function TB_SlashCommandHandler( msg )
	local command = string.lower(msg);

	-- Console command: /TB ON --
	if (command == TB_cmd_on) then
		if (TBSettings[TBSettingsCharRealm].status == 1) then						-- Checks if Tank Buddy is already enabled
			TB_Sendmsg(TB_output_alreadyOn);
		else										-- If not enabled..
			TB_Sendmsg(TB_output_on);
			TBSettings[TBSettingsCharRealm].status = 1;							-- Enables Tank Buddy
			TB_register();
			TB_EnableCheckButton:SetChecked(1);
		end

	-- Console command: /TB OFF --
	elseif (command == TB_cmd_off) then
		if (TBSettings[TBSettingsCharRealm].status == 0) then						-- Checks if Tank Buddy is already disabled
			TB_Sendmsg(TB_output_alreadyOff);			
		else										-- if not disabled..
			TB_Sendmsg(TB_output_off);		
			TBSettings[TBSettingsCharRealm].status = 0;							-- Disables Tank Buddy
			TB_unregister();
			TB_EnableCheckButton:SetChecked(0);		
		end

	-- Console Command: /TB --
	elseif (command == "") then
		TankBuddyFrame:Show();

	-- Console Command: Unknown command or syntax error --
	else
		TankBuddyFrame:Show();
	end
end
-- END OF SLASH COMMAND HANDLER --

function TB_Test()
	TBSettings[TBSettingsCharRealm].Announcements[TankBuddy.Tabs[TankBuddyFrame.selectedTab][1]]["Text"] = TB_EditboxText:GetText();
	TB_Announce(TankBuddy.Tabs[TankBuddyFrame.selectedTab][1], 1);
end

function TB_Announce(TBAbility, TBTest)
	if (TBAbility) then
		local TBText = TBSettings[TBSettingsCharRealm].Announcements[TBAbility]["Text"];
		if (TBAbility == TB_GUI_Taunt or TBAbility == TB_GUI_MB or TBAbility == TB_GUI_Growl) then
			if (TBText) then
				if (string.find(TBText, "$ttn")) then
					if (UnitName("targettarget")) then
						TBText = string.gsub(TBText, "$ttn", UnitName("targettarget"));
					else
						TBText = string.gsub(TBText, "$ttn", "<no target>");
					end
				end
				if (string.find(TBText, "$ttl")) then
					if (UnitLevel("targettarget")<0) then
						TBText = string.gsub(TBText, "$ttl", "??");
					else
						TBText = string.gsub(TBText, "$ttl", UnitLevel("targettarget"));
					end
				end
				if (string.find(TBText, "$ttt")) then
					if (UnitCreatureType("targettarget")) then
						TBText = string.gsub(TBText, "$ttt", UnitCreatureType("targettarget"));
					else
						TBText = string.gsub(TBText, "$ttt", "Unknown");
					end
				end
				if (string.find(TBText, "$tn")) then
					if (UnitName("target")) then
						TBText = string.gsub(TBText, "$tn", UnitName("target"));
					else
						TBText = string.gsub(TBText, "$tn", "<no target>");
					end
				end
				if (string.find(TBText, "$tl")) then
					if (UnitLevel("target")<0) then
						TBText = string.gsub(TBText, "$tl", "??");
					else
						TBText = string.gsub(TBText, "$tl", UnitLevel("target"));
					end
				end
				if (string.find(TBText, "$tt")) then
					if (UnitCreatureType("target")) then
						TBText = string.gsub(TBText, "$tt", UnitCreatureType("target"));
					else
						TBText = string.gsub(TBText, "$tt", "Unknown");
					end
				end
			end
		elseif (TBAbility == TB_GUI_SW) then
			TBText = string.gsub(TBSettings[TBSettingsCharRealm].Announcements[TBAbility]["Text"], "$sec", TB_GetSWDuration());
		elseif (TBAbility == TB_GUI_LS) then
			TBText = string.gsub(TBSettings[TBSettingsCharRealm].Announcements[TBAbility]["Text"], "$sec", "20");
			TBText = string.gsub(TBText, "$hp", math.floor((UnitHealthMax("player")/130)*30));
		elseif (TBAbility == TB_GUI_LG) then
			TBText = string.gsub(TBSettings[TBSettingsCharRealm].Announcements[TBAbility]["Text"], "$sec", "20");
			TBText = string.gsub(TBText, "$hp", math.floor((UnitHealthMax("player")/115)*15));
		elseif (TBAbility == TB_GUI_CS or TBAbility == TB_GUI_CR) then
			TBText = string.gsub(TBSettings[TBSettingsCharRealm].Announcements[TBAbility]["Text"], "$sec", "6");
		end
		
		if (TBTest) then
			TBText = "TEST " .. TBText .. " TEST";
		end

		local TB_grp = TB_GUI_Alone;
		if  GetNumPartyMembers() > 0 then
			if (UnitInRaid("player")) then
				TB_grp = TB_GUI_Raid;
			elseif (UnitInParty("player")) then
				TB_grp = TB_GUI_Party;
			end
		end
		for i = 1, getn(TankBuddy.Channels), 1 do
			if (TBSettings[TBSettingsCharRealm].Announcements[TBAbility][TB_grp][TankBuddy.Channels[i][2]]) then
				-- Channel option: CTRAID --
				if (TankBuddy.Channels[i][3] == "MS ") then
					if (IsAddOnLoaded("CT_RaidAssist")) then
						CT_RA_AddMessage("MS " .. TBText);		-- Announcement in CT raid channel (if you can)
					end
				-- Channel option: CHANNEL --
				elseif (TankBuddy.Channels[i][3] == "CHANNEL") then
					local TB_CustChannels = TB_strsplit("%s+",TBSettings[TBSettingsCharRealm].Announcements[TBAbility][TB_grp].Channels);
					for j = 1, getn(TB_CustChannels), 1 do
						local TB_channelId, TB_channelName = GetChannelName(TB_CustChannels[j]);
						if (TB_channelId > 0) then						-- Checks if you are still in that channel
							SendChatMessage(TBText, "CHANNEL", nil, TB_channelId);
						end
					end
				-- Everything else --
				else
					SendChatMessage(TBText, TankBuddy.Channels[i][3]); -- Announcement in say, yell, party, raid or raid_warning channels
				end
			end
		end
	end
end

function TB_register()
	TankBuddyFrame:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE");
	TankBuddyFrame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS");
	TankBuddyFrame:RegisterEvent("CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF");
	TankBuddyFrame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE");
	if (TBSettings[TBSettingsCharRealm].Salvstatus or
	TBSettings[TBSettingsCharRealm].Protectionstatus or
	TBSettings[TBSettingsCharRealm].Battleshoutstatus or
	TBSettings[TBSettingsCharRealm].Bubblestatus or
	TBSettings[TBSettingsCharRealm].Stupidstatus) then
		TankBuddyFrame:RegisterEvent("PLAYER_AURAS_CHANGED");
	end
	if (TBSettings[TBSettingsCharRealm].Salvstatus and TBSettings[TBSettingsCharRealm].SalvDefensiveBearstatus) then
		TankBuddyFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORMS");
	elseif (TBSettings[TBSettingsCharRealm].Salvstatus and TBSettings[TBSettingsCharRealm].SalvDefensiveBearstatus and TBSettings[TBSettingsCharRealm].Shieldstatus) then
		TankBuddyFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORMS");
		TankBuddyFrame:RegisterEvent("UNIT_INVENTORY_CHANGED");
	end
end

function TB_unregister()
	TankBuddyFrame:UnregisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE");
	TankBuddyFrame:UnregisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS");
	TankBuddyFrame:UnregisterEvent("CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF");
	TankBuddyFrame:UnregisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE");
	if (TBSettings[TBSettingsCharRealm].Salvstatus or
	TBSettings[TBSettingsCharRealm].Protectionstatus or
	TBSettings[TBSettingsCharRealm].Battleshoutstatus or
	TBSettings[TBSettingsCharRealm].Bubblestatus or
	TBSettings[TBSettingsCharRealm].Stupidstatus) then
		TankBuddyFrame:UnregisterEvent("PLAYER_AURAS_CHANGED");
	end
	if (TBSettings[TBSettingsCharRealm].SalvDefensiveBearstatus) then
		TankBuddyFrame:UnregisterEvent("UPDATE_SHAPESHIFT_FORMS");
	end
	if (TBSettings[TBSettingsCharRealm].Shieldstatus) then
		TankBuddyFrame:UnregisterEvent("UNIT_INVENTORY_CHANGED");
	end
end

function TB_Sendmsg(msg)
	if(DEFAULT_CHAT_FRAME) then
		DEFAULT_CHAT_FRAME:AddMessage(msg);
	end	
end

function TB_GetSWDuration()
	--nameTalent, iconPath, tier, column, currentRank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tabIndex, talentIndex);
	local SW_dur = 10; --Default duration
	local _, _, _, _, currRank, _ = GetTalentInfo(3,13); --Get rank of Improved Shield Wall
	if (currRank == 1) then
		SW_dur = SW_dur + 3;						--Rank 1 gives 3 seconds extra
	elseif (currRank == 2) then
		SW_dur = SW_dur + 5;						--Rank 2 gives 5 seconds extra (total)
	end
	_, _, _, _, currRank, _ = GetTalentInfo(1,18);			--Get rank of Improved Disciplines (New in 2.0)
	if (currRank > 0) then
		SW_dur = SW_dur + (2*currRank);			--Each rank gives 2 seconds extra
	end
	return SW_dur;
end

function TB_toggleStatus()
	if (TBSettings[TBSettingsCharRealm].status == 0) then
		TBSettings[TBSettingsCharRealm].status = 1;
		TB_register();
	else
		TBSettings[TBSettingsCharRealm].status = 0;
		TB_unregister();
	end
end

function TB_SetCustomChannel(i)
	TB_CustomChannelFrame:Show();
	TB_ButtonCloseCustom:SetID(i);
	if (TBSettings[TBSettingsCharRealm].Announcements[TankBuddy.Tabs[TankBuddyFrame.selectedTab][1]][TankBuddy.Modes[i][2]].Channels) then
		TB_EditboxCustom:SetText(TBSettings[TBSettingsCharRealm].Announcements[TankBuddy.Tabs[TankBuddyFrame.selectedTab][1]][TankBuddy.Modes[i][2]].Channels);
	else
		TB_EditboxCustom:SetText("");
	end
end

function TB_CloseCustomChannel()
	TB_CustomChannelFrame:Hide();
	if (string.find(TB_EditboxCustom:GetText(), "(%w+)")) then
		TBSettings[TBSettingsCharRealm].Announcements[TankBuddy.Tabs[TankBuddyFrame.selectedTab][1]][TankBuddy.Modes[this:GetID()][2]].Channels = TB_EditboxCustom:GetText();
	end
end

function TB_Copy()
	TB_Clipboard = {};
	for i = 1, getn(TankBuddy.Modes), 1 do
		TB_Clipboard[TankBuddy.Modes[i][1]] = {};
		for j = 1, getn(TankBuddy.Channels), 1 do
			TB_Clipboard[TankBuddy.Modes[i][1]][TankBuddy.Channels[j][1]] = TBSettings[TBSettingsCharRealm].Announcements[TankBuddy.Tabs[TankBuddyFrame.selectedTab][1]][TankBuddy.Modes[i][2]][TankBuddy.Channels[j][2]];
		end
		TB_Clipboard[TankBuddy.Modes[i][1]]["Channels"] = TBSettings[TBSettingsCharRealm].Announcements[TankBuddy.Tabs[TankBuddyFrame.selectedTab][1]][TankBuddy.Modes[i][2]].Channels;
	end
	TB_ButtonPaste:Enable();
end

function TB_Paste()
	if(TB_Clipboard) then
		for i = 1, getn(TankBuddy.Modes), 1 do
			for j = 1, getn(TankBuddy.Channels), 1 do
				if (getglobal("TB_" .. TankBuddy.Modes[i][1] .. TankBuddy.Channels[j][1] .. "CheckButton")) then
					TBSettings[TBSettingsCharRealm].Announcements[TankBuddy.Tabs[TankBuddyFrame.selectedTab][1]][TankBuddy.Modes[i][2]][TankBuddy.Channels[j][2]] = TB_Clipboard[TankBuddy.Modes[i][1]][TankBuddy.Channels[j][1]];
				end
			end
			TBSettings[TBSettingsCharRealm].Announcements[TankBuddy.Tabs[TankBuddyFrame.selectedTab][1]][TankBuddy.Modes[i][2]].Channels = TB_Clipboard[TankBuddy.Modes[i][1]]["Channels"];
		end
	end
	TB_SetChannels();
end

function TB_Close()
	TankBuddyFrame:Hide();
	TB_Clipboard = nil;				--Empty clipboard to save memory
	TB_ButtonPaste:Disable();		--Disable paste-button since clipboard is empty
	if (TankBuddyFrame.selectedTab ~= 1) then
		TBSettings[TBSettingsCharRealm].Announcements[TankBuddy.Tabs[TankBuddyFrame.selectedTab][1]]["Text"] = TB_EditboxText:GetText();
	end
end

function TB_PlayerBuff(buff)
	local i, j = 0;
	if (not GetPlayerBuffTexture(i)) then
		i = 1;
	end
	while (GetPlayerBuffTexture(i)) do
		if (string.find(GetPlayerBuffTexture(i), buff)) then
			j = i;
			if buff == "SealOfFury" then
				TB_rficons = TB_rficons + 1
			end
		end
		i = i + 1;
	end
	if j then return j end
end

function TB_toggleSalvStatus()
	if (this:GetName() == "TB_EnableSalvationCheckButton") then
		TBSettings[TBSettingsCharRealm].Salvstatus = this:GetChecked();
		if (TBSettings[TBSettingsCharRealm].Salvstatus) then	--If you want salvation removed
			if (TB_TankForm) then		-- and you're a druid or a warrior
				TB_DefensiveBearCheckButton:Enable()
				if (TBSettings[TBSettingsCharRealm].SalvDefensiveBearstatus) then		-- if you want salv only removed in those stances
					TB_ShieldCheckButton:Enable()
				end
			elseif (englishClass == "PALADIN") then    -- and if you're a paladin
				TB_RFCheckButton:Enable()
			end
		else
			TB_DefensiveBearCheckButton:Disable()
			TB_ShieldCheckButton:Disable()
			TB_RFCheckButton:Disable()
		end
	elseif (this:GetName() == "TB_DefensiveBearCheckButton") then
		TBSettings[TBSettingsCharRealm].SalvDefensiveBearstatus = this:GetChecked();
		if (TBSettings[TBSettingsCharRealm].SalvDefensiveBearstatus) then		-- if you want salv only removed in those stances
			TB_ShieldCheckButton:Enable()
		else
			TB_ShieldCheckButton:Disable()
		end
	elseif (this:GetName() == "TB_ShieldCheckButton") then
		TBSettings[TBSettingsCharRealm].Shieldstatus = this:GetChecked();
	elseif (this:GetName() == "TB_EnableProtectionCheckButton") then
		TBSettings[TBSettingsCharRealm].Protectionstatus = this:GetChecked();
	elseif (this:GetName() == "TB_BattleShoutCheckButton") then
		TBSettings[TBSettingsCharRealm].Battleshoutstatus = this:GetChecked();
	elseif (this:GetName() == "TB_MakeMeStupidButton") then
		TBSettings[TBSettingsCharRealm].Stupidstatus = this:GetChecked();
	elseif (this:GetName() == "TB_RFCheckButton") then
		TBSettings[TBSettingsCharRealm].Rfstatus = this:GetChecked();
	elseif (this:GetName() == "TB_BubbleCheckButton") then
		TBSettings[TBSettingsCharRealm].Bubblestatus = this:GetChecked();
	end
end
