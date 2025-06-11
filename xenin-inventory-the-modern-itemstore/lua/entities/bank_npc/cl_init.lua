--https://vk.com/gmodleak

include("shared.lua")

function ENT:Draw()
  self:DrawModel()

  local ply = LocalPlayer()
  local pos = self:GetPos()
  local eyePos = ply:GetPos()
  local dist = pos:Distance(eyePos)
  local alpha = math.Clamp(2500 - dist * 2.7, 0, 255)

  if (alpha <= 0) then return end

  local angle = self:GetAngles()
  local eyeAngle = ply:EyeAngles()

  angle:RotateAroundAxis(angle:Forward(), 90)
  angle:RotateAroundAxis(angle:Right(), - 90)

  cam.Start3D2D(pos + self:GetUp() * 90, Angle(0, eyeAngle.y - 90, 90), 0.04)
    XeninUI:DrawNPCOverhead(self, {
      alpha = alpha,
      text = Inventory.Config.NPCText,
      icon = Inventory.Config.NPCIcon,
      sin = true,
      textOffset = -20,
      iconMargin = 50,
      color = Inventory.Config.NPCColor
    })
  cam.End3D2D()
end

net.Receive("Inventory.Bank.Open", function(len)
  if (IsValid(Inventory.Bank)) then return end

  local frame = vgui.Create("Inventory.Bank.Frame")
  frame:SetSize(ScrW(), ScrH())
  frame:Center()
  frame:MakePopup()
end)