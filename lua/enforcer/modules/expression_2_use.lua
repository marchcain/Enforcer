local MODULE = Enforcer.RegisterModule(
	"Expression 2 use() Limits",
	"Limit Expression 2's 'e:use()' functions",
	{
		Range = 300,
		TargetAll = true,
		TargetSeats = true
	},
	true
)

MODULE:ModifyExpression2Function("use(e:)",function(mod, e2data, args)
	local op = args[2]
    local ent = op[1](e2data, op)

	if IsValid(ent) then
		local EntPos = ent:GetPos()
		local Owner = ent:CPPIGetOwner()
		if IsValid(Owner) then
			local dist = EntPos:Distance(Owner:GetPos())
			local range = mod:GetParameter("Range")
			print(dist,range)
			if dist < range then
				return true
			else
				Enforcer.SendHint(Owner,"You're too far away (" .. math.Round(dist-range) .. "su) from the entity to use it!",NOTIFY_ERROR)
				return false
			end
		end
	end
end)
