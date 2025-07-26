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
		if CLIENT then 
			self.CloakAnimTargetTime = CurTime()
			self:OnCloakAnimStateChanged(nil, nil, self:GetCloakAnimState()) //nwvar callbacks don't run when the value is set immediately upon spawning, so run it manually
		end
	end

	//This needs to be a CallOnRemove and not ENT:OnRemove because self:GetParent will return null
	self:CallOnRemove("RemoveProxyentCloakEffect", function(self, ent)
		if IsValid(ent) then
			if CLIENT then
				//Make sure to reenable the shadow if we've gotten rid of it
				if self:GetCloakDisablesShadow() then
					ent:CreateShadow()
					ent:MarkShadowAsDirty()
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

	if CLIENT then
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

end


if CLIENT then

	function ENT:Think()

		if self:GetCloakDisablesShadow() then
			local ent = self:GetParent()
			if IsValid(ent) then
				if self.ShouldDisableShadow then
					ent:DestroyShadow()
				else
					ent:CreateShadow()
					ent:MarkShadowAsDirty()
				end
			end
		end

	end

end




//Entity still renders for some users despite having RENDERGROUP_NONE and self:SetNoDraw(true) (why?), so try to get around this by having a blank draw function
function ENT:Draw()
end




//prevent the entity from being duplicated
duplicator.RegisterEntityClass("proxyent_tf2cloakeffect", function(ply, data) end, "Data")