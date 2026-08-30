local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local Merchant = UI:RegisterModule("Merchant")

-- Lib Globals
local _G = _G
local unpack = unpack
local select = select

-- WoW Globals
local GetContainerNumSlots = C_Container and C_Container.GetContainerNumSlots or GetContainerNumSlots
local GetContainerItemLink = C_Container and C_Container.GetContainerItemLink or GetContainerItemLink
local GetContainerItemInfo = C_Container and C_Container.GetContainerItemInfo or GetContainerItemInfo
local UseContainerItem = C_Container and C_Container.UseContainerItem or UseContainerItem
local GetItemInfo = GetItemInfo
local PickupMerchantItem = PickupMerchantItem
local CanMerchantRepair = CanMerchantRepair
local GetRepairAllCost = GetRepairAllCost
local RepairAllItems = RepairAllItems
local IsInGuild = IsInGuild
local CanGuildBankRepair = CanGuildBankRepair
local GetGuildBankWithdrawMoney = GetGuildBankWithdrawMoney
local GetMoney = GetMoney

function Merchant:IsJunk(Link)
	local _, _, Quality, _, _, _, _, _, _, _, SellPrice = GetItemInfo(Link)
	return Quality == 0 and SellPrice and SellPrice > 0
end

function Merchant:SellItem(Bag, Slot)
	UseContainerItem(Bag, Slot)
	PickupMerchantItem()
end

function Merchant:AutoSellJunk()
	if (not DB.Global.Merchant.AutoSellJunk) then
		return
	end

	local Profit = 0

	for Bag = 0, 4 do
		local NumSlots = GetContainerNumSlots(Bag)

		if (NumSlots and NumSlots > 0) then
			for Slot = 1, NumSlots do
				local Link = GetContainerItemLink(Bag, Slot)

				if (Link and Merchant:IsJunk(Link)) then
					local Info = GetContainerItemInfo(Bag, Slot)
					local Count = Info and Info.stackCount or 1
					local _, _, _, _, _, _, _, _, _, _, SellPrice = GetItemInfo(Link)

					if (SellPrice and SellPrice > 0) then
						Merchant:SellItem(Bag, Slot)

						Profit = Profit + (SellPrice * Count)
					end
				end
			end
		end
	end

	if (Profit > 0) then
		UI:Print(Language.Merchant.Vendor .. UI:FormatMoney(Profit, true))
	end
end

function Merchant:AutoRepair()
	if (not DB.Global.Merchant.AutoRepair or not CanMerchantRepair()) then
		return
	end

	local Cost, CanRepair = GetRepairAllCost()

	if (not CanRepair or Cost <= 0) then
		return
	end

	local GuildRepair = DB.Global.Merchant.GuildRepair and IsInGuild and CanGuildBankRepair() and GetGuildBankWithdrawMoney() >= Cost

	if (GuildRepair) then
		RepairAllItems(true)
		UI:Print(Language.Merchant.RepairGuild .. UI:FormatMoney(Cost, true))
		return
	end

	if (GetMoney() < Cost) then
		UI:Print(Language.Merchant.NotEnoughGold)
		return
	end

	RepairAllItems()

	UI:Print(Language.Merchant.Repair .. UI:FormatMoney(Cost, true))
end

function Merchant:OnEvent()
	self:AutoSellJunk()
	self:AutoRepair()
end

function Merchant:RegisterEvents()
	self:RegisterEvent("MERCHANT_SHOW")
	self:SetScript("OnEvent", self.OnEvent)
end

function Merchant:Initialize()
	self:RegisterEvents()
end