local f = CreateFrame("Frame")
local mailerArgs={}
local invToSend={}
local dbg=false

f:RegisterEvent("MAIL_FAILED")
f:RegisterEvent("MAIL_SHOW")
f:RegisterEvent("MAIL_CLOSED")

f:SetScript("OnEvent", function(self,event, ...)
    if (event == "BAG_UPDATE_DELAYED") then
		debugPrint("message handler after mail send success")
		SendItems()
	end
	if (event == "MAIL_FAILED") then
		debugPrint("Mail failed")
	end
	if (event == "MAIL_CLOSED") then
		debugPrint("mail frame closed, removing event listener")
		f:UnregisterEvent("BAG_UPDATE_DELAYED")
	end
	if (event == "MAIL_SHOW") then
		debugPrint("mail frame opened, listening for MAIL_SEND_SUCCESS event")
		f:RegisterEvent("BAG_UPDATE_DELAYED")
	end
end)

local function LaunchMailer(msg)
	
	mailerArgs={}
	for str in string.gmatch(msg, "([^%s]+)") do
		table.insert(mailerArgs, str)
    end

	if (#mailerArgs == 0 or mailerArgs[1] == "help") then
		print("To send something, type /mailer recipientName itemId itemRarity")
		print("Example: /mailer Leeroy 171267 1")
		print("Common=1 Uncommon=2 Rare=3 Epic=4 Legendary=5")
		return
	end

	debugPrint("Mailing target is " .. mailerArgs[1]);
	debugPrint("ItemID target is " .. mailerArgs[2]);
	debugPrint("Rarity target is " .. mailerArgs[3]);
	
	GetItemsToSend()
	
	SendItems()
	
end

function GetItemsToSend() 

	invToSend={}
	
	for i=0,4 do 
		for j=1,C_Container.GetContainerNumSlots(i) do 
			local item = C_Container.GetContainerItemInfo(i,j);
			if (item ~= nil and item.isLocked == false and item.quality == tonumber(mailerArgs[3]) and item.itemID == tonumber(mailerArgs[2])) then
				debugPrint({i,j})
				table.insert(invToSend, {i,j})
			end
		end
	end
	
end

function SendItems()

	if next(invToSend) then
		local count=0;
		for k, v in pairs(invToSend) do
			count = count + 1;
			C_Container.PickupContainerItem(v[1],v[2]);
			ClickSendMailItemButton(count);
			invToSend[k] = nil
			if (count == 12) then
				debugPrint("sending full mail")
				SendMail(mailerArgs[1], "Mailer sending stuff", "");
				break;
			end
		end
		
		if (count ~= 12) and (count ~= 0) then
			debugPrint("sending partial mail")
			SendMail(mailerArgs[1], "Mailer sending stuff", "");
		end
		
	end

end

function debugPrint(msg)

	if (dbg==true) then
		print(msg)
	end

end

SLASH_MAILER1, SLASH_MAILER2 = "/mailer", "/am"

SlashCmdList["MAILER"] = LaunchMailer
