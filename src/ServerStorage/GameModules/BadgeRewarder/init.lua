local BadgeRewarder = {}

for _, child in pairs(script:GetChildren()) do
	if child:IsA("ModuleScript") then
		BadgeRewarder[child.Name] = require(child)
	end
end

return BadgeRewarder
