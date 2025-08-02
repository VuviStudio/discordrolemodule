-- DiscordRoleModule.luau

local HttpService = game:GetService("HttpService")

local DiscordRoleModule = {}

local API_BASE_URL = "https://modmpointsapoc.vercel.app"
local API_ENDPOINTS = {
	HEALTH = "/health",
	GET_ALL_ROLES = "/api/discord/roles",
	GET_MANAGEABLE_ROLES = "/api/discord/roles?type=manageable",
	GET_USER_ROLES = "/api/discord/roles?userId=%s",
	CHECK_ROLE_STATUS = "/api/discord/roles?userId=%s&roleId=%s",
	ADD_ROLE = "/api/discord/roles",
	REMOVE_ROLE = "/api/discord/roles"
}

local function makeRequest(method, url, data)
	local success, result = pcall(function()
		local request = {
			Url = url,
			Method = method,
			Headers = {
				["Content-Type"] = "application/json"
			}
		}
		
		if data then
			request.Body = HttpService:JSONEncode(data)
		end
		
		return HttpService:RequestAsync(request)
	end)
	
	if not success then
		warn("HTTP request failed:", result)
		return nil, "Request failed: " .. tostring(result)
	end
	
	if result.Success then
		local success, decoded = pcall(function()
			return HttpService:JSONDecode(result.Body)
		end)
		
		if success then
			return decoded
		else
			return nil, "Failed to decode response"
		end
	else
		return nil, "HTTP error: " .. tostring(result.StatusCode) .. " - " .. tostring(result.Body)
	end
end

function DiscordRoleModule.health()
	local response, error = makeRequest("GET", API_BASE_URL .. API_ENDPOINTS.HEALTH)
	
	if not response then
		return false, error
	end
	
	return response.status == "healthy", response
end

function DiscordRoleModule.getAllRoles()
	local response, error = makeRequest("GET", API_BASE_URL .. API_ENDPOINTS.GET_ALL_ROLES)
	
	if not response then
		return nil, error
	end
	
	return response
end

function DiscordRoleModule.getManageableRoles()
	local response, error = makeRequest("GET", API_BASE_URL .. API_ENDPOINTS.GET_MANAGEABLE_ROLES)
	
	if not response then
		return nil, error
	end
	
	return response
end

function DiscordRoleModule.getUserRoles(discordUserId)
	if not discordUserId then
		return nil, "Discord user ID is required"
	end
	
	local url = string.format(API_BASE_URL .. API_ENDPOINTS.GET_USER_ROLES, tostring(discordUserId))
	local response, error = makeRequest("GET", url)
	
	if not response then
		return nil, error
	end
	
	if response.success then
		return response.roles, response
	else
		return nil, "Failed to get user roles: " .. tostring(response.error)
	end
end

function DiscordRoleModule.checkRoleStatus(discordUserId, discordRoleId)
	if not discordUserId then
		return nil, "Discord user ID is required"
	end
	
	if not discordRoleId then
		return nil, "Discord role ID is required"
	end
	
	local url = string.format(API_BASE_URL .. API_ENDPOINTS.CHECK_ROLE_STATUS, tostring(discordUserId), tostring(discordRoleId))
	local response, error = makeRequest("GET", url)
	
	if not response then
		return nil, error
	end
	
	if response.success then
		return response.hasRole, response
	else
		return nil, "Failed to check role status: " .. tostring(response.error)
	end
end

function DiscordRoleModule.addRole(discordUserId, discordRoleId)
	if not discordUserId then
		return nil, "Discord user ID is required"
	end
	
	if not discordRoleId then
		return nil, "Discord role ID is required"
	end
	
	local data = {
		userId = tostring(discordUserId),
		roleId = tostring(discordRoleId)
	}
	
	local response, error = makeRequest("POST", API_BASE_URL .. API_ENDPOINTS.ADD_ROLE, data)
	
	if not response then
		return nil, error
	end
	
	if response.success then
		return true, response
	else
		return nil, "Failed to add role: " .. tostring(response.error)
	end
end

function DiscordRoleModule.removeRole(discordUserId, discordRoleId)
	if not discordUserId then
		return nil, "Discord user ID is required"
	end
	
	if not discordRoleId then
		return nil, "Discord role ID is required"
	end
	
	local data = {
		userId = tostring(discordUserId),
		roleId = tostring(discordRoleId)
	}
	
	local response, error = makeRequest("DELETE", API_BASE_URL .. API_ENDPOINTS.REMOVE_ROLE, data)
	
	if not response then
		return nil, error
	end
	
	if response.success then
		return true, response
	else
		return nil, "Failed to remove role: " .. tostring(response.error)
	end
end

function DiscordRoleModule.toggleRole(discordUserId, discordRoleId)
	if not discordUserId then
		return nil, "Discord user ID is required"
	end
	
	if not discordRoleId then
		return nil, "Discord role ID is required"
	end
	
	local hasRole, checkData = DiscordRoleModule.checkRoleStatus(discordUserId, discordRoleId)
	
	if hasRole == nil then
		return nil, "Failed to check role status: " .. tostring(checkData)
	end
	
	if hasRole then
		return DiscordRoleModule.removeRole(discordUserId, discordRoleId)
	else
		return DiscordRoleModule.addRole(discordUserId, discordRoleId)
	end
end

function DiscordRoleModule.getRoleInfo(discordRoleId)
	if not discordRoleId then
		return nil, "Discord role ID is required"
	end
	
	local allRoles, error = DiscordRoleModule.getAllRoles()
	
	if not allRoles then
		return nil, error
	end
	
	for _, role in pairs(allRoles.roles or {}) do
		if role.id == tostring(discordRoleId) then
			return role
		end
	end
	
	return nil, "Role not found"
end

function DiscordRoleModule.isGuildMember(discordUserId)
	if not discordUserId then
		return nil, "Discord user ID is required"
	end
	
	local userRoles, response = DiscordRoleModule.getUserRoles(discordUserId)
	
	if userRoles == nil then
		return nil, response
	end
	
	return response.guildMember or false, response
end

return DiscordRoleModule
