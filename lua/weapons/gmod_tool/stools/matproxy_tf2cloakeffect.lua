TOOL.Category = "Render"
TOOL.Name = "Color - TF2 Cloak"
TOOL.Command = nil
TOOL.ConfigName = "" 
 
TOOL.ClientConVar["r"] = "255"
TOOL.ClientConVar["g"] = "127"
TOOL.ClientConVar["b"] = "102"
TOOL.ClientConVar["factor"] = "0.85"
TOOL.ClientConVar["refractamount"] = "0.1"
TOOL.ClientConVar["disableshadow"] = "1"
TOOL.ClientConVar["anim"] = "0"
TOOL.ClientConVar["anim_numpadkey"] = "51"
TOOL.ClientConVar["anim_toggle"] = "1"
TOOL.ClientConVar["anim_starton"] = "1"
TOOL.ClientConVar["anim_timein"] = "1.0"
TOOL.ClientConVar["anim_timeout"] = "2.0"

TOOL.Information = {
	{name = "left0", stage = 0, icon = "gui/lmb.png"},
	{name = "right0", stage = 0, icon = "gui/rmb.png"},
	{name = "reload0", stage = 0, icon = "gui/r.png"},
}

if CLIENT then
	language.Add("tool.matproxy_tf2cloakeffect.name", "Color - TF2 Cloak")
	language.Add("tool.matproxy_tf2cloakeffect.desc", "Add a Spy cloak effect to TF2 characters and items")

	language.Add("tool.matproxy_tf2cloakeffect.left0", "Add cloak effect")
	language.Add("tool.matproxy_tf2cloakeffect.right0", "Copy cloak effect")
	language.Add("tool.matproxy_tf2cloakeffect.reload0", "Remove cloak effect")

	language.Add("Undone_matproxy_tf2cloakeffect", "Undone TF2 Cloak Effect")
end




function TOOL:LeftClick(trace)

	local ent = trace.Entity
	if IsValid(ent) then
		if SERVER then
			GiveMatproxyTF2CloakEffect(self:GetOwner(), ent, {
				TintR = self:GetClientNumber("r", 0), 
				TintG = self:GetClientNumber("g", 0), 
				TintB = self:GetClientNumber("b", 0), 
				Factor = self:GetClientNumber("factor", 0),
				RefractAmount = self:GetClientNumber("refractamount", 0),
				DisableShadow = self:GetClientNumber("disableshadow", 0),
				Anim = self:GetClientNumber("anim", 0),
				Anim_NumpadKey = self:GetClientNumber("anim_numpadkey", 0),
				Anim_Toggle = self:GetClientNumber("anim_toggle", 0),
				Anim_StartOn = self:GetClientNumber("anim_starton", 0),
				Anim_TimeIn = self:GetClientNumber("anim_timein", 0),
				Anim_TimeOut = self:GetClientNumber("anim_timeout", 0),
			})
		end
		return true
	end

end




function TOOL:RightClick(trace)

	if IsValid(trace.Entity) then
		if SERVER then
			if IsValid(trace.Entity.AttachedEntity) then
				trace.Entity = trace.Entity.AttachedEntity
			end

			if trace.Entity.EntityMods and trace.Entity.EntityMods.MatproxyTF2CloakEffect then
				self:GetOwner():ConCommand("matproxy_tf2cloakeffect_r " .. trace.Entity.EntityMods.MatproxyTF2CloakEffect.TintR)
				self:GetOwner():ConCommand("matproxy_tf2cloakeffect_g " .. trace.Entity.EntityMods.MatproxyTF2CloakEffect.TintG)
				self:GetOwner():ConCommand("matproxy_tf2cloakeffect_b " .. trace.Entity.EntityMods.MatproxyTF2CloakEffect.TintB)
				self:GetOwner():ConCommand("matproxy_tf2cloakeffect_factor " .. trace.Entity.EntityMods.MatproxyTF2CloakEffect.Factor)
				self:GetOwner():ConCommand("matproxy_tf2cloakeffect_refractamount " .. trace.Entity.EntityMods.MatproxyTF2CloakEffect.RefractAmount)
				self:GetOwner():ConCommand("matproxy_tf2cloakeffect_disableshadow " .. trace.Entity.EntityMods.MatproxyTF2CloakEffect.DisableShadow)
				self:GetOwner():ConCommand("matproxy_tf2cloakeffect_anim " .. trace.Entity.EntityMods.MatproxyTF2CloakEffect.Anim)
				self:GetOwner():ConCommand("matproxy_tf2cloakeffect_anim_numpadkey " .. trace.Entity.EntityMods.MatproxyTF2CloakEffect.Anim_NumpadKey)
				self:GetOwner():ConCommand("matproxy_tf2cloakeffect_anim_toggle " .. trace.Entity.EntityMods.MatproxyTF2CloakEffect.Anim_Toggle)
				self:GetOwner():ConCommand("matproxy_tf2cloakeffect_anim_starton " .. trace.Entity.EntityMods.MatproxyTF2CloakEffect.Anim_StartOn)
				self:GetOwner():ConCommand("matproxy_tf2cloakeffect_anim_timein " .. trace.Entity.EntityMods.MatproxyTF2CloakEffect.Anim_TimeIn)
				self:GetOwner():ConCommand("matproxy_tf2cloakeffect_anim_timeout " .. trace.Entity.EntityMods.MatproxyTF2CloakEffect.Anim_TimeOut)
			end
		end
		return true
	end

end




function TOOL:Reload(trace)

	if IsValid(trace.Entity) then
		if SERVER then
			if IsValid(trace.Entity.AttachedEntity) then
				trace.Entity = trace.Entity.AttachedEntity
			end

			local old = trace.Entity.ProxyentCloakEffect
			if IsValid(old) then
				old:Remove()
				trace.Entity.ProxyentCloakEffect = nil
				duplicator.ClearEntityModifier(trace.Entity, "MatproxyTF2CloakEffect")
			end
		end
		return true
	end

end




if SERVER then

	function GiveMatproxyTF2CloakEffect(ply, ent, Data)
		if !IsValid(ent) then return end
		if IsValid(ent.AttachedEntity) then
			ent = ent.AttachedEntity
		end

		local old = ent.ProxyentCloakEffect
		if IsValid(old) and old:GetParent() == ent then //NOTE: Entities pasted using GenericDuplicatorFunction (i.e. anything without custom dupe functionality) will still have the original entity's Proxyent value saved into their table because GenericDuplicatorFunction uses table.Merge(). In most cases this won't matter because the saved Proxyent is NULL, but if the original entity still exists, then the value will point to THAT entity's Proxyent instead, which we don't want to delete by mistake.
			old:Remove()
		end

		local pent = ents.Create("proxyent_tf2cloakeffect")
		if IsValid(pent) then
			pent:SetPos(ent:GetPos())
			pent:SetParent(ent)
			pent:SetColor(Color(Data.TintR, Data.TintG, Data.TintB))
			pent:SetCloakAnim(Data.Anim == 1)
			if Data.Anim == 1 then
				numpad.OnDown(ply, Data.Anim_NumpadKey, "Proxyent_TF2CloakEffect_Numpad", pent, true, Data.Anim_Toggle == 1, Data.Anim_StartOn == 1)
				numpad.OnUp(ply, Data.Anim_NumpadKey, "Proxyent_TF2CloakEffect_Numpad", pent, false, Data.Anim_Toggle == 1, Data.Anim_StartOn == 1)
				pent:SetCloakAnimState(Data.Anim_StartOn == 1)
				pent:SetCloakAnimTimeIn(Data.Anim_TimeIn)
				pent:SetCloakAnimTimeOut(Data.Anim_TimeOut)
			else
				pent:SetCloakFactor(Data.Factor)
			end
			pent:SetCloakRefractAmount(Data.RefractAmount)
			pent:SetCloakDisablesShadow(Data.DisableShadow == 1)
			ent.ProxyentCloakEffect = pent
			pent:Spawn()
		end
		duplicator.StoreEntityModifier(ent, "MatproxyTF2CloakEffect", Data)
	end

	duplicator.RegisterEntityModifier("MatproxyTF2CloakEffect", GiveMatproxyTF2CloakEffect)

end




local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel(panel)

	panel:AddControl("Header", {
		Text = "Color - TF2 Cloak",
		Description = "Add a Spy cloak effect to TF2 characters and items"
	})

	//Presets
	panel:AddControl("ComboBox", {
		MenuButton = 1,
		Folder = "matproxy_tf2cloakeffect",
		//Options = {
			//["#preset.default"] = ConVarsDefault
		//},
		CVars = table.GetKeys(ConVarsDefault)
	})

	local colorpanel = panel:AddControl("ListBox", {
		Label = "Color", 
		Height = 68, 
		Options = {
			["Cloak, RED"] = {
				matproxy_tf2cloakeffect_r = "255",
				matproxy_tf2cloakeffect_g = "127",
				matproxy_tf2cloakeffect_b = "102",
				matproxy_tf2cloakeffect_factor = "0.85",
				matproxy_tf2cloakeffect_refractamount = "0.1",
				matproxy_tf2cloakeffect_disableshadow = "1",
				matproxy_tf2cloakeffect_anim = "0",
				matproxy_tf2cloakeffect_anim_numpadkey = "51",
				matproxy_tf2cloakeffect_anim_toggle = "1",
				matproxy_tf2cloakeffect_anim_starton = "1",
				matproxy_tf2cloakeffect_anim_timein = "1.0",
				matproxy_tf2cloakeffect_anim_timeout = "2.0",
			},
			["Cloak, BLU"] = {
				matproxy_tf2cloakeffect_r = "102",
				matproxy_tf2cloakeffect_g = "127",
				matproxy_tf2cloakeffect_b = "255",
				matproxy_tf2cloakeffect_factor = "0.85",
				matproxy_tf2cloakeffect_refractamount = "0.1",
				matproxy_tf2cloakeffect_disableshadow = "1",
				matproxy_tf2cloakeffect_anim = "0",
				matproxy_tf2cloakeffect_anim_numpadkey = "51",
				matproxy_tf2cloakeffect_anim_toggle = "1",
				matproxy_tf2cloakeffect_anim_starton = "1",
				matproxy_tf2cloakeffect_anim_timein = "1.0",
				matproxy_tf2cloakeffect_anim_timeout = "2.0",
			},
			["Cloak, transparent"] = {
				matproxy_tf2cloakeffect_r = "255",
				matproxy_tf2cloakeffect_g = "255",
				matproxy_tf2cloakeffect_b = "255",
				matproxy_tf2cloakeffect_factor = "0.85",
				matproxy_tf2cloakeffect_refractamount = "0.1",
				matproxy_tf2cloakeffect_disableshadow = "1",
				matproxy_tf2cloakeffect_anim = "0",
				matproxy_tf2cloakeffect_anim_numpadkey = "51",
				matproxy_tf2cloakeffect_anim_toggle = "1",
				matproxy_tf2cloakeffect_anim_starton = "1",
				matproxy_tf2cloakeffect_anim_timein = "1.0",
				matproxy_tf2cloakeffect_anim_timeout = "2.0",
			},
		},
	})
	colorpanel:ClearSelection()  //the default highlighting method is bad and starts off by highlighting ALL of the lines that have ANY matching convars - meaning, if we have any of 
				     //these selected, all of them will be highlighted by default since they all have factor = "0.85". not having anything selected by default isn't as bad.

	panel:AddControl("Color", {
		Label = "Cloak Tint Color",
		Red = "matproxy_tf2cloakeffect_r",
		Green = "matproxy_tf2cloakeffect_g",
		Blue = "matproxy_tf2cloakeffect_b",
		ShowHSV = 1,
		ShowRGB = 1,
		Multiplier = 255
	})

	panel:AddControl("Label", {Text = "", Description = ""})

	panel.anim = panel:AddControl("ComboBox", {
		Label = "Cloak Type",
		MenuButton = 0,
		Options = {
			["Static (set cloak level with tool)"] = {matproxy_tf2cloakeffect_anim = "0"},
			["Animated (play cloak animation with a key)"] = {matproxy_tf2cloakeffect_anim = "1"},
		}
	})

	panel.anim.OldThink = panel.anim.Think
	panel.anim.Think = function(self, ...)
		if panel.IsDoneBuilding then
			local cloaktype = GetConVar("matproxy_tf2cloakeffect_anim"):GetInt()
			if cloaktype != self.CurCloakType then
				self.CurCloakType = cloaktype

				if cloaktype == 0 then
					//Show static cloak options
					panel.static_cloakfactor_slider:SetHeight(32)
					panel.static_cloakfactor_helptext:SetAutoStretchVertical(true)
					//Hide animated cloak options
					panel.anim_effectkey.PerformLayoutOld = panel.anim_effectkey.PerformLayoutOld or panel.anim_effectkey.PerformLayout
					panel.anim_effectkey.PerformLayout = function() end //this performlayout function automatically resizes it back to full, so redirect it until we need it again
					panel.anim_effectkey:SetHeight(0)
					panel.anim_toggle_checkbox:SetHeight(0)
					panel.anim_starton_checkbox:SetHeight(0)
					panel.anim_timein_slider:SetHeight(0)
					panel.anim_timeout_slider:SetHeight(0)
				else
					//Hide static cloak options
					panel.static_cloakfactor_slider:SetHeight(0)
					panel.static_cloakfactor_helptext:SetAutoStretchVertical(false)
					panel.static_cloakfactor_helptext:SetHeight(0)
					//Show animated cloak options
					panel.anim_effectkey.PerformLayout = panel.anim_effectkey.PerformLayoutOld or panel.anim_effectkey.PerformLayout
					panel.anim_effectkey:SetHeight(70)
					panel.anim_toggle_checkbox:SetHeight(16)
					panel.anim_starton_checkbox:SetHeight(16)
					panel.anim_timein_slider:SetHeight(16)
					panel.anim_timeout_slider:SetHeight(16)
				end
			end
		end
		if panel.anim.OldThink then
			return panel.anim.OldThink(self, ...)
		end
	end



	//Static cloak options
	panel.static_cloakfactor_slider = panel:AddControl("Slider", {
		Label = "Cloak Factor",
	 	Type = "Float",
		Min = "0",
		Max = "1",
		Command = "matproxy_tf2cloakeffect_factor",
	})
	panel.static_cloakfactor_helptext = panel:ControlHelp("Level of the cloak effect (0 = fully visible, 1 = fully cloaked)")



	//Animated cloak options
	panel.anim_effectkey = panel:AddControl("Numpad", {
		Label = "Effect Key",
		Command = "matproxy_tf2cloakeffect_anim_numpadkey",
	})

	panel.anim_toggle_checkbox = panel:AddControl("CheckBox", {Label = "Toggle", Command = "matproxy_tf2cloakeffect_anim_toggle"})

	panel.anim_starton_checkbox = panel:AddControl("CheckBox", {Label = "Start on?", Command = "matproxy_tf2cloakeffect_anim_starton"})

	panel.anim_timein_slider = panel:AddControl("Slider", {
		Label = "Cloak fade time",
	 	Type = "Float",
		Min = "0.1",
		Max = "5",
		Command = "matproxy_tf2cloakeffect_anim_timein",
	})

	panel.anim_timeout_slider = panel:AddControl("Slider", {
		Label = "Decloak fade time",
	 	Type = "Float",
		Min = "0.1",
		Max = "5",
		Command = "matproxy_tf2cloakeffect_anim_timeout",
	})



	panel:AddControl("Label", {Text = "", Description = ""})
	
	panel:AddControl("Slider", {
		Label = "Refract Amount",
		Type = "Float",
		Min = "0",
		Max = "1",
		Command = "matproxy_tf2cloakeffect_refractamount",
	})
	panel:ControlHelp("Add an extra refraction effect to the cloak (default = 0.10)")

	panel:AddControl("CheckBox", {Label = "Cloak disables shadow", Command = "matproxy_tf2cloakeffect_disableshadow"})



	panel.IsDoneBuilding = true

end