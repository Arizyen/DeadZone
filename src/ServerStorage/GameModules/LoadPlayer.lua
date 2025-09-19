-- Services ------------------------------------------------------------------------
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders -------------------------------------------------------------------------
local Packages = ReplicatedStorage.Packages
local ReplicatedSource = ReplicatedStorage.Source
local ServerSource = ServerStorage.Source
local ReplicatedPlaywooEngine = ReplicatedSource.PlaywooEngine
local PlaywooEngine = ServerSource.PlaywooEngine
local ReplicatedBaseModules = ReplicatedPlaywooEngine.BaseModules
local ReplicatedConfigs = ReplicatedSource.Configs
local ReplicatedInfo = ReplicatedSource.Info
local ReplicatedTypes = ReplicatedSource.Types
local BaseModules = PlaywooEngine.BaseModules
local GameModules = ServerSource.GameModules
local BaseHandlers = PlaywooEngine.BaseHandlers
local GameHandlers = ServerSource.GameHandlers

-- Modules -------------------------------------------------------------------
local HumanoidManager = require(BaseModules.HumanoidManager)

-- Handlers --------------------------------------------------------------------

-- Types ---------------------------------------------------------------------------

-- Instances -----------------------------------------------------------------------

-- Info ---------------------------------------------------------------------------

-- Configs -------------------------------------------------------------------------

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS -----------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local function LoadPlayer(player: Player)
	if not player or not player:IsA("Player") then
		return false
	end

	local hDesc = HumanoidManager.GetPlayerHumanoidDescription(player.UserId)

	-- Clear ALL classic accessory categories
	hDesc.BackAccessory = ""
	hDesc.FaceAccessory = ""
	hDesc.FrontAccessory = ""
	-- hDesc.HairAccessory = ""
	hDesc.HatAccessory = ""
	hDesc.NeckAccessory = ""
	hDesc.ShouldersAccessory = ""
	hDesc.WaistAccessory = ""

	-- Clear ALL emotes
	hDesc:SetEmotes({})
	hDesc:SetEquippedEmotes({})

	-- Clear clothing
	hDesc.GraphicTShirt = 0
	hDesc.Shirt = 0
	hDesc.Pants = 0

	-- Clear body parts
	hDesc.LeftArm = 0
	hDesc.RightArm = 0
	hDesc.LeftLeg = 0
	hDesc.RightLeg = 0
	hDesc.Torso = 0

	--TODO: Update humanoid description based on player data (clothing, accessories, etc.)

	if not hDesc then
		warn("No humanoid description found for player: " .. player.Name)
		player:LoadCharacter()
	else
		player:LoadCharacterWithHumanoidDescription(hDesc)
	end

	return true
end

return LoadPlayer
