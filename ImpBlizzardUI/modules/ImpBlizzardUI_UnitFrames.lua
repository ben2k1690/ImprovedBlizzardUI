--[[
    ImpBlizzardUI/modules/ImpBlizzardUI_UnitFrames
    Handles and modifies the Blizzard unit frames
    Current Features: Player Frame, Target Frame, Focus Frame, Party Frames, Boss Frames, Arena Frames, Class Icon, Class Colours, Portrait Spam Text
]]
local _, ImpBlizz = ...;

local UnitFrames = CreateFrame("Frame", nil, UIParent);

-- Helper function for moving a Blizzard frame that has a SetMoveable flag
local function ModifyFrame(frame, anchor, parent, posX, posY, scale)
    frame:SetMovable(true);
    frame:ClearAllPoints();
    if(parent == nil) then frame:SetPoint(anchor, posX, posY) else frame:SetPoint(anchor, parent, posX, posY) end
    if(scale ~= nil) then frame:SetScale(scale) end
    frame:SetUserPlaced(true);
    frame:SetMovable(false);
end

-- Helper function for moving a Blizzard frame that does NOT have a SetMoveable flag
local function ModifyBasicFrame(frame, anchor, parent, posX, posY, scale)
    frame:ClearAllPoints();
    if(parent == nil) then frame:SetPoint(anchor, posX, posY) else frame:SetPoint(anchor, parent, posX, posY) end
    if(scale ~= nil) then frame:SetScale(scale) end
end

-- Does the bulk of the tweaking to the unit frames
local function AdjustUnitFrames()
    if(InCombatLockdown() == false) then
        ModifyFrame(PlayerFrame, "CENTER", nil, -265, -150, 1.40); -- Player Frame
        ModifyFrame(TargetFrame, "CENTER", nil, 265, -150, 1.40); -- Target Frame
        TargetFrame.buffsOnTop = true;
        ModifyFrame(FocusFrame, "TOPLEFT", nil, 300, -200, 1.25); -- Focus Frame

        -- Party Frames
        ModifyFrame(PartyMemberFrame1, "LEFT", nil, 100, 125, 1.6); -- Move the first one (Others are children)
        for i = 2, 4 do _G["PartyMemberFrame"..i]:SetScale(1.6); end -- Resize the other children

        -- Boss Frames
        for i = 1, 5 do -- Scale Them
            _G["Boss"..i.."TargetFrame"]:SetParent(UIParent);
            _G["Boss"..i.."TargetFrame"]:SetScale(0.95);
            _G["Boss"..i.."TargetFrame"]:SetFrameStrata("BACKGROUND");
        end
        for i = 2, 5 do -- Adjust Positions
            _G["Boss"..i.."TargetFrame"]:SetPoint("TOPLEFT", _G["Boss"..(i-1).."TargetFrame"], "BOTTOMLEFT", 0, 15);
        end

        -- Arena Frames
        for i=1, 5 do
            _G["ArenaPrepFrame"..i]:SetScale(1.75);
        end
        ArenaEnemyFrames:SetScale(1.75);
    end
end

-- Updates the option class icon that displays near the target frame
local function UpdateClassIcon(class)
    if(Conf_ClassIcon) then
        if class == "WARRIOR" then
            UnitFrames.classIconTexture:SetTexCoord( 0, .25, 0, .25 );
        elseif class == "MAGE" then
            UnitFrames.classIconTexture:SetTexCoord( .25, .5,0, .25 );
        elseif class == "ROGUE" then
            UnitFrames.classIconTexture:SetTexCoord( .5, .74,0, .25 );
        elseif class == "DRUID" then
            UnitFrames.classIconTexture:SetTexCoord( .75, .98, 0, .25 );
        elseif class == "PALADIN" then
            UnitFrames.classIconTexture:SetTexCoord( 0, .25, .5, .75 );
        elseif class == "DEATHKNIGHT" then
            UnitFrames.classIconTexture:SetTexCoord( .25, .5, .5, .75);
        elseif class == "MONK" then
            UnitFrames.classIconTexture:SetTexCoord( .5, .74, .5,.75);
        elseif class == "HUNTER" then
            UnitFrames.classIconTexture:SetTexCoord( 0, .25, .25, .5 );
        elseif class == "SHAMAN" then
            UnitFrames.classIconTexture:SetTexCoord( .25, .5, .25, .5 );
        elseif class == "PRIEST" then
            UnitFrames.classIconTexture:SetTexCoord( .5, .74, .25, .5 );
        elseif class == "WARLOCK" then
            UnitFrames.classIconTexture:SetTexCoord( .75, .98, .25, .5 );
        end
    end
end

-- Builds the optional class icon that displays near the target frame
local function BuildClassIcon()
    if(Conf_ClassIcon) then
        UnitFrames.classIcon = CreateFrame("Frame", "ClassIconFrame", TargetFrame);
        UnitFrames.classIcon:SetPoint( "CENTER", 110, 40);
        UnitFrames.classIcon:SetSize( 40, 40 );
        UnitFrames.classIconTexture = UnitFrames.classIcon:CreateTexture( "ClassIconTexture" );
        UnitFrames.classIconTexture:SetPoint( "CENTER" );
        UnitFrames.classIconTexture:SetSize( 40, 40 );
        UnitFrames.classIconTexture:SetTexture( "Interface\\TARGETINGFRAME\\UI-CLASSES-CIRCLES.BLP" );
        UnitFrames.classIconBorder = UnitFrames.classIcon:CreateTexture( "ClassIconBorder", "ARTWORK", nil, 1 );
        UnitFrames.classIconBorder:SetPoint( "CENTER" , UnitFrames.classIconTexture );
        UnitFrames.classIconBorder:SetSize( 40 * 2, 40 * 2 );
        UnitFrames.classIconBorder:SetTexture( "Interface\\UNITPOWERBARALT\\WowUI_Circular_Frame.blp" )
    end
end

-- Updates the class colours on the Target and Focus frames
local function UpdateClassColours()
    if(Conf_ClassColours) then
        local class = RAID_CLASS_COLORS[select(2, UnitClass("target"))];
        if(class ~= nil) then
            TargetFrameNameBackground:SetVertexColor(class.r, class.g, class.b);
        end

        local class = RAID_CLASS_COLORS[select(2, UnitClass("focus"))];
        if(class ~= nil) then
            FocusFrameNameBackground:SetVertexColor(class.r, class.g, class.b);
        end
    end
end

local function HandleEvents(self, event, ...)
    if(event == "ADDON_LOADED" and ... == "ImpBlizzardUI") then
        BuildClassIcon();
    end

    if(event == "PLAYER_ENTERING_WORLD") then
        AdjustUnitFrames();
    end

    if(event == "UNIT_EXITED_VEHICLE" or event == "UNIT_ENTERED_VEHICLE") then
        if(UnitControllingVehicle("player") or UnitHasVehiclePlayerFrameUI("player")) then
            AdjustUnitFrames();
        end
    end

    if(event == "PLAYER_TARGET_CHANGED") then
        UpdateClassColours();
        UpdateClassIcon(select( 2, UnitClass("target")));
    end

    if(event == "UNIT_FACTION" or event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_FOCUS_CHANGED") then
        UpdateClassColours();
    end
end

-- Remove Portrait Damage Spam
-- Reimplimentation of CombatFeedback_OnCombatEvent from CombatFeedback.lua
function CombatFeedback_OnCombatEvent_Hook(self, event, flags, amount, type)
    if(Conf_HideSpam) then
        self.feedbackText:SetText(" ");
    end
end

-- Sets up Event Handlers etc
local function Init()
    UnitFrames:SetScript("OnEvent", HandleEvents);
    LoadAddOn("Blizzard_ArenaUI");

    UnitFrames:RegisterEvent("PLAYER_ENTERING_WORLD");
    UnitFrames:RegisterEvent("ADDON_LOADED");
    UnitFrames:RegisterEvent("UNIT_EXITED_VEHICLE");
    UnitFrames:RegisterEvent("UNIT_ENTERED_VEHICLE");
    UnitFrames:RegisterEvent("PLAYER_TARGET_CHANGED");
    UnitFrames:RegisterEvent("UNIT_FACTION");
    UnitFrames:RegisterEvent("GROUP_ROSTER_UPDATE");
    UnitFrames:RegisterEvent("PLAYER_FOCUS_CHANGED");
end

hooksecurefunc("CombatFeedback_OnCombatEvent", CombatFeedback_OnCombatEvent_Hook);

-- End of file, call Init
Init();
