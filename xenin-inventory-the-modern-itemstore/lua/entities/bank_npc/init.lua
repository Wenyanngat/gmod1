--https://vk.com/gmodleak

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("Inventory.Bank.Open")

function ENT:Initialize()
	self:SetModel(Inventory.Config.NPCModel)
	self:SetHullType(HULL_HUMAN)
	self:SetHullSizeNormal()
	self:SetNPCState(NPC_STATE_SCRIPT)
	self:SetSolid(SOLID_BBOX)
	self:CapabilitiesAdd(bit.bor(CAP_ANIMATEDFACE, CAP_TURN_HEAD))
	self:SetUseType(SIMPLE_USE)
	self:DropToFloor()
	self:SetMaxYawSpeed(90)
	self:DropToFloor()
end

function ENT:AcceptInput(name, activator, ply, data)
	if (name != "Use" && !IsValid(ply) && !ply:IsPlayer()) then return end

	net.Start("Inventory.Bank.Open")
	net.Send(ply)
end