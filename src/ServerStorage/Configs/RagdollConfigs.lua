local PlayerConfigs = require(script.Parent.PlayerConfigs)

return {
	RAGDOLL_ON_DEATH_ENABLED = true,
	DEFAULT_UNRAGDOLL_WAIT_TIME = 3,
	RAGDOLL_JOINTS_FOLDER_NAME = "_RagdollJoints",
	RIG_TYPE = PlayerConfigs.RIG_TYPE, -- "R6" or "R15"
}
