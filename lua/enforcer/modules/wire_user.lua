Enforcer.AddToActions("EntityCreated","gmod_wire_user",function(ent)
	local TriggerInputFunction = ent.TriggerInput
	function ent:TriggerInput(iname, value)
		if value ~= 0 then
			local UserPos = self:GetPos()
			local Owner = self:CPPIGetOwner()
			if IsValid(Owner) then
				if UserPos:Distance(Owner:GetPos()) < 250 then
					TriggerInputFunction(ent, iname, value)
				else
					Enforcer.SendHint(Owner,"You are too far away from the user!",NOTIFY_ERROR)
				end
			end
		end
	end
end)