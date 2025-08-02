# DiscordRoleModule for Roblox

A Roblox module for managing Discord roles via the Apocrypha API.

[![Roblox](https://img.shields.io/badge/Roblox-Luau-blue.svg)](https://www.roblox.com/)
[![API](https://img.shields.io/badge/API-Apocrypha-green.svg)](https://modmpointsapoc.vercel.app/)

## Quick Setup

1. **Enable HTTP requests** in your game:
   - Go to Game Settings → Security
   - Enable "Allow HTTP Requests"

2. **Add DiscordRoleModule to ReplicatedStorage:**
   - In Roblox Studio, go to ReplicatedStorage
   - Create a new ModuleScript
   - Name it "DiscordRoleModule"
   - Copy the module code into it

3. **File structure should look like:**
   ```
   Game
   └── ReplicatedStorage
       └── DiscordRoleModule (ModuleScript)
   ```

## Basic Usage

```lua
local DiscordRoleModule = require(game.ReplicatedStorage.DiscordRoleModule)

-- Get all roles
local allRoles = DiscordRoleModule.getAllRoles()

-- Check if user has role
local hasRole = DiscordRoleModule.checkRoleStatus("123456789012345678", "1401188133575463045")

-- Add role to user
local success = DiscordRoleModule.addRole("123456789012345678", "1401188133575463045")

-- Remove role from user
local success = DiscordRoleModule.removeRole("123456789012345678", "1401188133575463045")
```

## API Functions

| Function | Description |
|----------|-------------|
| `getAllRoles()` | Get all Discord roles |
| `getManageableRoles()` | Get roles bot can manage |
| `getUserRoles(discordUserId)` | Get user's roles |
| `checkRoleStatus(discordUserId, discordRoleId)` | Check if user has role |
| `addRole(discordUserId, discordRoleId)` | Add role to user |
| `removeRole(discordUserId, discordRoleId)` | Remove role from user |
| `toggleRole(discordUserId, discordRoleId)` | Toggle role (add/remove) |
| `getRoleInfo(discordRoleId)` | Get role details |
| `isGuildMember(discordUserId)` | Check guild membership |
| `health()` | Check API status |

## Server Examples

### Complete Role Management Example
```lua
-- Place this in a ServerScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DiscordRoleModule = require(ReplicatedStorage.DiscordRoleModule)

game.Players.PlayerAdded:Connect(function(player)
    -- Check if player is vuvi_hub
    if player.Name == "vuvi_hub" then
        local discordUserId = "1154821885763256460" -- vuvi_hub's Discord ID
        
        -- Check if user is in Discord server
        local isMember = DiscordRoleModule.isGuildMember(discordUserId)
        if isMember then
            print(player.Name, "is in Discord server")
            
            -- Get all roles user has
            local userRoles = DiscordRoleModule.getUserRoles(discordUserId)
            print("User has", #userRoles, "roles:")
            for i, roleId in ipairs(userRoles) do
                local roleInfo = DiscordRoleModule.getRoleInfo(roleId)
                if roleInfo then
                    print("  " .. i .. ". " .. roleInfo.name .. " (ID: " .. roleId .. ")")
                else
                    print("  " .. i .. ". Role ID: " .. roleId .. " (name not found)")
                end
            end
            
            -- Check if user has specific role
            local hasRole = DiscordRoleModule.checkRoleStatus(discordUserId, "1401188133575463045")
            print("Has role:", hasRole)
            
            -- Add a role to user
            local success = DiscordRoleModule.addRole(discordUserId, "1401188133575463045")
            print("Added role:", success)
            
            -- Remove a role from user
            local removed = DiscordRoleModule.removeRole(discordUserId, "1401188133575463045")
            print("Removed role:", removed)
        else
            print(player.Name, "is not in Discord server")
        end
    end
end)
```

## Client-Server Communication

### Server Script
```lua
-- Place this in a ServerScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DiscordRoleModule = require(ReplicatedStorage.DiscordRoleModule)

-- Create RemoteFunction for client communication
local DiscordRoleRemote = Instance.new("RemoteFunction")
DiscordRoleRemote.Name = "DiscordRoleRemote"
DiscordRoleRemote.Parent = ReplicatedStorage

DiscordRoleRemote.OnServerInvoke = function(player, action, discordUserId, discordRoleId)
    if action == "checkMember" then
        return DiscordRoleModule.isGuildMember(discordUserId)
    elseif action == "getUserRoles" then
        return DiscordRoleModule.getUserRoles(discordUserId)
    elseif action == "checkRole" then
        return DiscordRoleModule.checkRoleStatus(discordUserId, discordRoleId)
    elseif action == "addRole" then
        return DiscordRoleModule.addRole(discordUserId, discordRoleId)
    elseif action == "removeRole" then
        return DiscordRoleModule.removeRole(discordUserId, discordRoleId)
    elseif action == "getRoleInfo" then
        return DiscordRoleModule.getRoleInfo(discordRoleId)
    end
end
```

### Client Script - Complete Example
```lua
-- Place this in a LocalScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DiscordRoleRemote = ReplicatedStorage:WaitForChild("DiscordRoleRemote")

local function checkUserRoles(discordUserId, discordRoleId)
    -- Check if user is in Discord server
    local isMember = DiscordRoleRemote:InvokeServer("checkMember", discordUserId)
    if isMember then
        print("User is in Discord server")
        
        -- Get all roles user has
        local userRoles = DiscordRoleRemote:InvokeServer("getUserRoles", discordUserId)
        print("User has", #userRoles, "roles:")
        for i, roleId in ipairs(userRoles) do
            local roleInfo = DiscordRoleRemote:InvokeServer("getRoleInfo", roleId)
            if roleInfo then
                print("  " .. i .. ". " .. roleInfo.name .. " (ID: " .. roleId .. ")")
            else
                print("  " .. i .. ". Role ID: " .. roleId .. " (name not found)")
            end
        end
        
        -- Check if user has specific role
        local hasRole = DiscordRoleRemote:InvokeServer("checkRole", discordUserId, discordRoleId)
        print("Has role:", hasRole)
        
        -- Add a role to user
        local success = DiscordRoleRemote:InvokeServer("addRole", discordUserId, discordRoleId)
        print("Added role:", success)
        
        -- Remove a role from user
        local removed = DiscordRoleRemote:InvokeServer("removeRole", discordUserId, discordRoleId)
        print("Removed role:", removed)
    else
        print("User is not in Discord server")
    end
end

-- Check if current player is vuvi_hub and run Discord operations
local Players = game:GetService("Players")
local player = Players.LocalPlayer

if player.Name == "vuvi_hub" then
    -- Use the function for vuvi_hub
    checkUserRoles("1154821885763256460", "1401188133575463045")
end
```

## Error Handling

```lua
local success, error = DiscordRoleModule.addRole("123456789012345678", "1401188133575463045")
if not success then
    print("Error:", error)
end
```

## API Endpoints

- `GET /health` - Health check
- `GET /api/discord/roles` - Get all roles
- `GET /api/discord/roles?type=manageable` - Get manageable roles
- `GET /api/discord/roles?userId=:userId` - Get user roles
- `GET /api/discord/roles?userId=:userId&roleId=:roleId` - Check role status
- `POST /api/discord/roles` - Add role
- `DELETE /api/discord/roles` - Remove role

**Base URL:** `https://modmpointsapoc.vercel.app`
