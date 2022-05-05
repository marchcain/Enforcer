--[[
Enforcer
Made by https://steamcommunity.com/profiles/76561198144109434
]]--

print("================[Enforcer]================")
Enforcer = {}
if SERVER then
	util.AddNetworkString("enforcer.sendhint")
	Enforcer.Debug = false
	local function printD(...)
        if Enforcer.Debug then
            print(...)
        end
    end
	Enforcer.printD = printD
	Enforcer.SendHint = function(target,message,message_type)
        net.Start("enforcer.sendhint")
        net.WriteString(message)
        net.WriteUInt(message_type,16)
        net.Send(target)
    end
	
	Enforcer.Actions = {
		EntityCreated = {}
	}

	Enforcer.AddToActions = function(action,key,func)
		Enforcer.Actions[action][key] = {
			Func = func
		}
	end
	
	print("[Enforcer] Creating hooks...")
    
	hook.Add("OnEntityCreated","Enforce_EntityCreated",function(ent)
        if IsValid(ent) then
            local modifier = Enforcer.Actions.EntityCreated[ent:GetClass()]
            if modifier != nil then
                modifier.Func(ent)
                printD("[Enforcer] Modifier applied to Entity " .. ent:EntIndex() .. " [" .. ent:GetClass() .. "]")
            end
        end
    end)
	
	print("[Enforcer] Loading modules...")
	local files, directories = file.Find("enforcer/modules/*.lua","LUA")
	for k, v in ipairs(files) do
		include("enforcer/modules/" .. v)
	end
	
	print("[Enforcer] Loaded " .. (#files) .. " modules.")
	
	print("[Enforcer] Setup complete.")
else
	net.Receive("enforcer.sendhint",function(len)
        notification.AddLegacy(net.ReadString(),net.ReadUInt(16),5)
    end)
end