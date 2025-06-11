--https://vk.com/gmodleak

SWEP.PrintName = "Inventory"
SWEP.Instructions = "Primary Fire: Pickup Item\nSecondary Fire: Open Inventory"
SWEP.Base = "weapon_base"
SWEP.Author = "sleeppyy"
SWEP.Category = "Xenin"

SWEP.WorldModel	= ""
SWEP.ViewModel	= "models/weapons/c_arms.mdl"

SWEP.UseHands = false
SWEP.Spawnable = false

SWEP.ViewModelFOV = 50
SWEP.ViewModelFlip = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

function SWEP:Initialize()
	self:SetWeaponHoldType("normal")
end

function SWEP:PrimaryAttack()
  if (CLIENT) then return end

  if (SERVER) then
    self.Owner:Inventory():Pickup(self.Owner:GetEyeTrace().Entity)
  end
end

function SWEP:SecondaryAttack()
  if (SERVER) then return end

  self.Owner:ConCommand("inventory")
end

if (CLIENT) then
  surface.CreateFont("Inventory.3DHUD", {
    font = "Lato",
    size = 20,
    weight = 800,
    shadow = true,
    outline = true
  })

  function SWEP:Deploy()
    hook.Add("PreDrawHalos", "Inventory.Halo", function()
      if (IsValid(self)) then
        self:DrawHalos()
      end
    end)
  end

  function SWEP:Holster()
    hook.Remove("PreDrawHalos", "Inventory.Halo")
  end

  function SWEP:DrawHUD()
    self.CanSee = {}
    self.Items = Inventory:GetItems()

    for k, item in pairs(self.Items) do
      for i, v in pairs(ents.FindByClass(k)) do
        local pos = v:GetPos()
        local visible = LocalPlayer():IsLineOfSightClear(pos)
        if (visible) then
          self.CanSee[v] = { pos = pos, item = item }
        end
      end
    end
  end

  function SWEP:DrawHalos()
    for i, v in pairs(self.CanSee or {}) do
      if (!IsValid(i)) then continue end
 
      local rarity = i.GetRarity and i:GetRarity() or v.item:GetRarity(i)
      local cat = Inventory.Config.Categories[rarity]
      local color = cat and cat.color or Inventory.Config.Categories[1].color

      halo.Add({ i }, color, 2, 2, 5)
    end
  end
end