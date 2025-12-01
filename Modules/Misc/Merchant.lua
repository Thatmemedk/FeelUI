local UI, DB, Media, Language = select(2, ...):Call()

-- Call Modules
local Merchant = UI:RegisterModule("Merchant")

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack
local floor = math.floor

-- WoW Globals
local GetContainerNumSlots = GetContainerNumSlots or (C_Container and C_Container.GetContainerNumSlots)
local GetContainerItemLink = GetContainerItemLink or (C_Container and C_Container.GetContainerItemLink)
local GetItemInfo = GetItemInfo or (C_Container and C_Container.GetItemInfo)
local GetContainerItemInfo = GetContainerItemInfo or (C_Container and C_Container.GetContainerItemInfo)
local UseContainerItem = UseContainerItem or (C_Container and C_Container.UseContainerItem)
local PickupMerchantItem = PickupMerchantItem
local GetRepairAllCost = GetRepairAllCost
local RepairAllItems = RepairAllItems
local IsInGuild = IsInGuild
local CanGuildBankRepair = CanGuildBankRepair
local GetGuildBankWithdrawMoney = GetGuildBankWithdrawMoney
local GetMoney = GetMoney

function Merchant:AutoSellJunk()
	if not (DB.Global.Merchant.AutoSellJunk) then
		return
	end

	local Profit = 0
	local TotalCount = 0

	for Bag = 0, 4 do
		local NumSlots = GetContainerNumSlots(Bag)

		if (NumSlots and NumSlots > 0) then
			for Slot = 1, NumSlots do
				local Link = GetContainerItemLink(Bag, Slot)

				if (Link) then
					local Info = GetContainerItemInfo(Bag, Slot)
					local Count = (Info and Info.stackCount) or 1
					local Name, _, Quality, _, _, _, _, _, _, _, SellPrice = GetItemInfo(Link)

					if (SellPrice and SellPrice > 0) then
						local TotalPrice = SellPrice * Count

						if (Quality and Quality <= 0 and TotalPrice > 0) then
							UseContainerItem(Bag, Slot)
							PickupMerchantItem()

							Profit = Profit + TotalPrice
							TotalCount = TotalCount + Count
						end
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
	if (not DB.Global.Merchant.AutoRepair) then
		return
	end

	if (CanMerchantRepair()) then
		local Cost, CanRepair = GetRepairAllCost()

		if (CanRepair and Cost > 0) then
			local UseGuild = DB.Global.Merchant.GuildRepair and IsInGuild() and CanGuildBankRepair() and (GetGuildBankWithdrawMoney() >= Cost)

			if (UseGuild) then
				RepairAllItems(true)

				UI:Print(Language.Merchant.RepairGuild .. UI:FormatMoney(Cost, true))
			else
				if (GetMoney() > Cost) then
					RepairAllItems()

					UI:Print(Language.Merchant.Repair .. UI:FormatMoney(Cost, true))
				else
					UI:Print(Language.Merchant.NotEnoughGold)
				end
			end
		end
	end
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
