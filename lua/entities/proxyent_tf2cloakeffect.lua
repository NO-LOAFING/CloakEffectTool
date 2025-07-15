AddCSLuaFile()

ENT.Base 			= "base_gmodentity"
ENT.PrintName			= "Proxy Ent - TF2 Cloak Effect"
ENT.Author			= ""

ENT.Spawnable			= false
ENT.AdminSpawnable		= false
ENT.RenderGroup			= RENDERGROUP_NONE

ENT.AutomaticFrameAdvance	= true




function ENT:SetupDataTables()

	self:NetworkVar("Entity", 0, "TargetEnt")
	self:NetworkVar("Vector", 0, "CloakTintVector")
	self:NetworkVar("Float", 0, "CloakFactor")
	self:NetworkVar("Float", 1, "CloakRefractAmount")
	self:NetworkVar("Bool", 0, "CloakDisablesShadow")

	self:NetworkVar("Bool", 1, "CloakAnim")
	self:NetworkVar("Bool", 2, "CloakAnimToggle")
	self:NetworkVar("Bool", 3, "CloakAnimActive")
	self:NetworkVar("Float", 2, "CloakAnimTimeIn")
	self:NetworkVar("Float", 3, "CloakAnimTimeOut")

	self:NetworkVar("Bool", 4, "CloakAnimNumpadUpdate")

end




function ENT:Initialize()

	local targetent = self:GetTargetEnt()

	if !IsValid(targetent) then MsgN("Cloak effect entity has no target!") self:Remove() return end
	if !self:GetCloakTintVector() then MsgN("Cloak effect entity has no cloak tint set!") self:Remove() return end
	if !self:GetCloakFactor() then MsgN("Cloak effect entity has no cloak factor set!") self:Remove() return end

	targetent.ProxyentCloakEffect = self

	self:SetPos(targetent:GetPos())
	self:SetParent(targetent)
	self:SetNoDraw(true)
	self:SetModel("models/props_junk/watermelon01.mdl") //dummy model to prevent addons that look for the error model from affecting this entity
	self:DrawShadow(false) //make sure the ent's shadow doesn't render, just in case RENDERGROUP_NONE/SetNoDraw don't work and we have to rely on the blank draw function

	if self:GetCloakAnim() then
		if CLIENT then 
			self.CloakAnimTargetTime = CurTime()
			self:SetCloakAnimActive(!self:GetCloakAnimActive())
			self:SetCloakAnimNumpadUpdate(true)
		end
	end

end




if CLIENT then

	function ENT:Think()

		//We don't want the server to set CloakAnimNumpadUpdate to false on the client because this can mess up the cloak animation. Instead, use a separate var so the client only 
		//cares about the server ENABLING the update, and let the client disable the update on its own instead of having the networked var from the server disable it prematurely.
		if self:GetCloakAnimNumpadUpdate() then self.CloakAnimNumpadUpdateNonNW = true end

		if self:GetCloakAnim() and self.CloakAnimNumpadUpdateNonNW then
			self:SetCloakAnimActive(!self:GetCloakAnimActive())

			//if the player toggles the cloak before the animation is done, then we should reverse the cloak from that point in the animation instead of the beginning
			local diff = (self.CloakAnimTargetTime or 0) - CurTime()
			if diff < 0 then diff = 0 end

			if self:GetCloakAnimActive() then
				self.CloakAnimTargetTime = ( CurTime() + self:GetCloakAnimTimeIn() - ( (diff / self:GetCloakAnimTimeOut()) * self:GetCloakAnimTimeIn() ) )
			else
				self.CloakAnimTargetTime = ( CurTime() + self:GetCloakAnimTimeOut() - ( (diff / self:GetCloakAnimTimeIn()) * self:GetCloakAnimTimeOut() ) )
			end

			self:SetCloakAnimNumpadUpdate(false)
			self.CloakAnimNumpadUpdateNonNW = false
		end

		if self:GetCloakDisablesShadow() then
			local targetent = self:GetTargetEnt()
			if IsValid(targetent) then
				if self.ShouldDisableShadow then
					targetent:DestroyShadow()
				else
					targetent:CreateShadow()
					targetent:MarkShadowAsDirty()
				end
			end
		end

	end

end


function ENT:OnRemove()

	local targetent = self:GetTargetEnt()
	if IsValid(targetent) then
		if CLIENT then
			//Make sure to reenable the shadow if we've gotten rid of it
			if self:GetCloakDisablesShadow() then
				targetent:CreateShadow()
				targetent:MarkShadowAsDirty()
			end
		end

		if targetent.ProxyentCloakEffect == self then 
			targetent.ProxyentCloakEffect = nil
		end
	end

end




//numpad functions
if SERVER then

	local function NumpadPress(pl, ent)

		if !IsValid(ent) or ent:GetClass() != "proxyent_tf2cloakeffect" or !ent:GetCloakAnim() then return end

		ent:SetCloakAnimNumpadUpdate(false) //this value never gets set back to false serverside, so we have to alternate it to get it to network the "true" value to the client again.
		ent:SetCloakAnimNumpadUpdate(true)  //otherwise, it'll detect that the value hasn't changed serverside and it won't bother sending it.

	end

	local function NumpadRelease(pl, ent)

		if !IsValid(ent) or ent:GetClass() != "proxyent_tf2cloakeffect" or !ent:GetCloakAnim() then return end
	
		if ent:GetCloakAnimToggle() then return end

		ent:SetCloakAnimNumpadUpdate(false) //this value never gets set back to false serverside, so we have to alternate it to get it to network the "true" value to the client again.
		ent:SetCloakAnimNumpadUpdate(true)  //otherwise, it'll detect that the value hasn't changed serverside and it won't bother sending it.
	
	end

	numpad.Register("Proxyent_TF2CloakEffect_Press", NumpadPress)
	numpad.Register("Proxyent_TF2CloakEffect_Release", NumpadRelease)

end




//Entity still renders for some users despite having RENDERGROUP_NONE and self:SetNoDraw(true) (why?), so try to get around this by having a blank draw function
function ENT:Draw()
end




//prevent the entity from being duplicated
duplicator.RegisterEntityClass("proxyent_tf2cloakeffect", function(ply, data) end, "Data")