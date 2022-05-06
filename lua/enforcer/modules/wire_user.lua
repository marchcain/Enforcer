local MODULE = Enforcer.RegisterModule(
	"Wire User Limits",
	"Limit Wiremod Users functionality",
	{
		Range = 300,
		TargetAll = true,
		TargetSeats = true
	},
	true
)
MODULE:ModifyEntityFunction("gmod_wire_user","TriggerInput",function(mod,ent,args)
	if args[2] ~= 0 then
		local UserPos = ent:GetPos()
		local Owner = ent:CPPIGetOwner()
		if IsValid(Owner) then
			local dist = UserPos:Distance(Owner:GetPos())
			local range = mod:GetParameter("Range")
			print(dist,range)
			if dist < range then
				return true
			else
				Enforcer.SendHint(Owner,"You are too far away (" .. math.Round(dist-range) .. "su) from the user!",NOTIFY_ERROR)
				return false
			end
		end
	end
end)