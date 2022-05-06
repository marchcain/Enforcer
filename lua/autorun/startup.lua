--[[
Enforcer
Made by https://steamcommunity.com/profiles/76561198144109434
]]--

print("================[Enforcer]================")
if !Enforcer then
	Enforcer = {}
end
if SERVER then
	Enforcer.Actions = {
		EntityCreated = {}
	}
	Enforcer.Modules = {
		
	}
	
	util.AddNetworkString("enforcer.sendhint")
	Enforcer.Debug = true
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
	Enforcer.HasPermission = function(ply,perm)
		if ULX and ucl then
			return ucl.query(ply,perm)
		end
	end
	
	if !Enforcer.Old then
		Enforcer.Old = {}
	end
	
	Enforcer.AddOldFunction = function(name,func)
		if Enforcer.Old[name] == nil then --basically just only run this if we need to, makes it easier to debug
			Enforcer.Old[name] = func
		end
	end
	
	Enforcer.AddToActions = function(action,key,func)
		Enforcer.Actions[action][key] = {
			Func = func
		}
	end
	
	Enforcer.RegisterModule = function(module_name,desc,parameters,default_enable_state)
		local Module = {
			Name = module_name,
			Description = desc,
			Enable = nil,
			Disable = nil,
			State = default_enable_state,
			Parameters = parameters,
			
			IsEnabled = function(mod)
				return mod.State
			end,
			GetParameter = function(mod,param)
				return mod.Parameters[param]
			end,
			ModifyEntityFunction = Enforcer.ModifyEntityFunction,
			ModifyExpression2Function = Enforcer.ModifyExpression2Function
		}
		Enforcer.Modules[module_name] = Module
		printD("[Enforcer] Module '" .. module_name .. "' created")
		return Module
	end
	
	Enforcer.ModifyEntityFunction = function(mod,entity_class_name,function_name,logic)
		local ENTTABLE = scripted_ents.GetStored(entity_class_name)
		if ENTTABLE == nil then
			print("[Enforcer] Module '" .. mod.Name .. "' experienced an issue; " .. entity_class_name .. " was not a valid scripted entity. It's likely that an add-on that this module needs is not installed or is corrupted.")
		else
			local func_key = entity_class_name .. "/" .. function_name
			local T = ENTTABLE.t
			Enforcer.AddOldFunction(func_key,T[function_name])
			
			T[function_name] = function(self,...)
				if mod.State == true and logic(mod,self,{...}) then
					Enforcer.Old[func_key](self,...)
				end
			end
			printD("[Enforcer] Module '" .. mod.Name .. "' added an entity modification '" .. func_key)
		end
	end
	
	Enforcer.ModifyExpression2Function = function(mod,search,logic)
		local e2functiontable = wire_expression2_funcs[search]
		if e2functiontable == nil then
			print("[Enforcer] Module '" .. mod.Name .. "' experienced an issue; " .. search .. " was not a valid Expression 2 function. It's likely that either an add-on that this module needs is not installed or is corrupted, or the Expression 2 extension that implements this function is disabled.")
		else
			local func_key = "Expression 2" .. "/" .. search
			local F = e2functiontable[3]
			Enforcer.AddOldFunction(func_key,F)
			e2functiontable[3] = function(self, args)
				if mod.State == true and logic(mod,self,args) then
					Enforcer.Old[func_key](self, args)
				end
			end
		end
	end
	
	print("[Enforcer] Creating hooks...")
    
	
	--[[
	hook.Add("OnEntityCreated","Enforce_EntityCreated",function(ent)
        if IsValid(ent) then
            local modifier = Enforcer.Actions.EntityCreated[ent:GetClass()]
            if modifier != nil then
                modifier.Func(ent)
                printD("[Enforcer] Modifier applied to Entity " .. ent:EntIndex() .. " [" .. ent:GetClass() .. "]")
            end
        end
    end)]]--
	print("[Enforcer] Delaying module creation...")
	--We delay it just in case of the scenario where Enforcer's code is called before an entity is actually created.
	 timer.Create("Enforcer_ModuleLoad",0.5,1,function()
		print("[Enforcer] Loading modules...")
		local files, directories = file.Find("enforcer/modules/*.lua","LUA")
		for k, v in ipairs(files) do
			include("enforcer/modules/" .. v)
		end
		print("[Enforcer] Loaded " .. (#files) .. " modules.")
	
		print("[Enforcer] Setup complete.")
	end)
else
	net.Receive("enforcer.sendhint",function(len)
        notification.AddLegacy(net.ReadString(),net.ReadUInt(16),5)
    end)
end