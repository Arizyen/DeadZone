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
local MapConfigs = require(ReplicatedConfigs.MapConfigs)

-- Variables -----------------------------------------------------------------------

-- Tables --------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS -----------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local function SpawnPlayer(player: Player)
	if not player or not player:IsA("Player") then
		return false
	end

	if MapConfigs.IS_LOBBY_PLACE then
		-- In lobby, load default character
		player:LoadCharacter()
		return true
	end

	local hDesc = HumanoidManager.GetPlayerHumanoidDescription(player.UserId)

	if not hDesc then
		warn("No humanoid description found for player: " .. player.Name)
		player:LoadCharacter()
	else
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

		-- Clear body parts
		hDesc.LeftArm = 0
		hDesc.RightArm = 0
		hDesc.LeftLeg = 0
		hDesc.RightLeg = 0
		hDesc.Torso = 0

		-- Add clothing
		-- hDesc.GraphicTShirt = 0
		hDesc.Shirt = 91444869191711
		hDesc.Pants = 133870134715559

		--TODO: Update humanoid description based on player data (clothing, accessories, etc.)

		-- Load character with updated humanoid description
		player:LoadCharacterWithHumanoidDescription(hDesc)
	end

	return true
end

return SpawnPlayer
