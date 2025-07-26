AddCSLuaFile()

ENT.Base 			= "base_gmodentity"
ENT.PrintName			= "Proxy Ent - TF2 Cloak Effect"
ENT.Author			= ""

ENT.Spawnable			= false
ENT.AdminSpawnable		= false
ENT.RenderGroup			= RENDERGROUP_NONE

ENT.AutomaticFrameAdvance	= true




function ENT:SetupDataTables()

	self:NetworkVar("Float", 0, "CloakFactor")
	self:NetworkVar("Float", 1, "CloakRefractAmount")
	self:NetworkVar("Bool", 0, "CloakDisablesShadow")

	self:NetworkVar("Bool", 1, "CloakAnim")
	self:NetworkVar("Bool", 2, "CloakAnimState")
	self:NetworkVarNotify("CloakAnimState", self.OnCloakAnimStateChanged)
	self:NetworkVar("Float", 2, "CloakAnimTimeIn")
	self:NetworkVar("Float", 3, "CloakAnimTimeOut")

end




function ENT:Initialize()

	if SERVER then self:SetTransmitWithParent(true) end

	local ent = self:GetParent()
	if CLIENT then
		//Store color as a vector so the proxy func doesn't have to make a new one each frame
		local col = self:GetColor()
		self.Color = Vector(col.r/255, col.g/255, col.b/255)
		if IsValid(ent) then
			//Expose this value to the client so the matproxy can pick it up
			ent.ProxyentCloakEffect = self
		end
	end

	self:SetNoDraw(true)
	self:SetModel("models/props_junk/watermelon01.mdl") //dummy model to prevent addons that look for the error model from affecting this entity
	self:DrawShadow(false) //make sure the ent's shadow doesn't render, just in case RENDERGROUP_NONE/SetNoDraw don't work and we have to rely on the blank draw function

	if self:GetCloakAnim() then
		self.CloakAnimTargetTime = CurTime()
		self:OnCloakAnimStateChanged(nil, nil, self:GetCloakAnimState()) //nwvar callbacks don't run when the value is set immediately upon spawning, so run it manually
	end

	//This needs to be a CallOnRemove and not ENT:OnRemove because self:GetParent will return null
	self:CallOnRemove("RemoveProxyentCloakEffect", function(self, ent)
		if IsValid(ent) then
			if SERVER then
				//Make sure to reenable the shadow if we've gotten rid of it
				if self:GetCloakDisablesShadow() then
					ent:DrawShadow(true)
				end
			end

			if ent.ProxyentCloakEffect == self then 
				ent.ProxyentCloakEffect = nil
			end
		end
	end, ent)

end


if SERVER then

	local function CloakNumpadFunction(pl, ent, keydown, toggle, starton)

		if !IsValid(ent) then return end
		if !ent["SetCloakAnimState"] then return end  //if the function doesn't exist yet, not if the function returns false
	
		if toggle then
			if keydown then
				ent:SetCloakAnimState(!ent:GetCloakAnimState())
			end
		else
			if keydown then
				ent:SetCloakAnimState(!starton)
			else
				ent:SetCloakAnimState(starton)
			end
		end
	
	end

	numpad.Register("Proxyent_TF2CloakEffect_Numpad", CloakNumpadFunction)

end


function ENT:OnCloakAnimStateChanged(_,old,new)

	if self:GetCloakAnim() and old != new then
		//MsgN("setting cloak to ", new)

		//if the player toggles the cloak before the animation is done, then we should reverse the cloak from that point in the animation instead of the beginning
		local diff = (self.CloakAnimTargetTime or 0) - CurTime()
		if diff < 0 then diff = 0 end

		if new then
			//cloaking
			self.CloakAnimTargetTime = ( CurTime() + self:GetCloakAnimTimeIn() - ( (diff / self:GetCloakAnimTimeOut()) * self:GetCloakAnimTimeIn() ) )
		else
			//decloaking
			self.CloakAnimTargetTime = ( CurTime() + self:GetCloakAnimTimeOut() - ( (diff / self:GetCloakAnimTimeIn()) * self:GetCloakAnimTimeOut() ) )
		end
	end

end


if SERVER then

	function ENT:Think()

		if !self.DoneShadowUpdate then
			if self:GetCloakDisablesShadow() then
				local ent = self:GetParent()
				if IsValid(ent) then
					//Disable the ent's shadow if cloaked
					local factor = 0
					if self:GetCloakAnim() then
						//Duplicate code from matproxy/tf2cloakeffect.lua, argh
						local diff = (self.CloakAnimTargetTime or 0) - CurTime()
						if self:GetCloakAnimState() then
							//cloaking
							if diff < 0 then
								factor = 1
							else
								factor = 1 - (diff / self:GetCloakAnimTimeIn())
							end
						else
							//decloaking
							if diff < 0 then
								factor = 0
							else
								factor = diff / self:GetCloakAnimTimeOut()
							end
						end
					else
						factor = self:GetCloakFactor()
					end
					ent:DrawShadow(factor < 0.27) //this sets the same variable used by other things like the shadow toggle tool, so it'll clobber those - too bad!
				end
			end

			if self:GetCloakAnim() then
				//run think again every frame, so that the shadow updates on time
				self:NextThink(CurTime())
				return true
			else
				self.DoneShadowUpdate = true //static cloak only needs to do this once
			end
		end

	end

end




//Entity still renders for some users despite having RENDERGROUP_NONE and self:SetNoDraw(true) (why?), so try to get around this by having a blank draw function
function ENT:Draw()
end




//prevent the entity from being duplicated
duplicator.RegisterEntityClass("proxyent_tf2cloakeffect", function(ply, data) end, "Data")