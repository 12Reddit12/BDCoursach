include("autorun/sh_coursach.lua")
print("cl coursach podgruzilsa")

local coursach = coursach or {}
local restaurants = restaurants or {}
local halls = halls or {}
local dishes = dishes or {}
local dishestype = dishestype or {}
local hallstable = hallstable or {}
local dishesinorder = dishesinorder or {}
local currentidorder
for i=1,50 do
	surface.CreateFont( "coursach_"..i, {
	font = "Montserrat",
	extended = true,
	size = i,
	weight = 100,
	antialias = true,
} )
end

local selcategory = 1
local blur = Material("pp/blurscreen")
function draw.Blur(panel, amount)
        local x, y = panel:LocalToScreen(0, 0)
        local scrW, scrH = ScrW(), ScrH()
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(blur)
        for i = 1, 3 do
            blur:SetFloat("$blur", (i / 3) * (amount or 6))
            blur:Recompute()
            render.UpdateScreenEffectTexture()
            surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
        end
end
local scrw,scrh = ScrW(),ScrH()

function getsizetext(text,font)
	surface.SetFont( font )
	return surface.GetTextSize(text)
end

net.Receive("coursachnopen", function()
	if IsValid(coursach.menu) then
		coursach.menu:Remove()
		return
	end

	coursach.menu = vgui.Create( "EditablePanel" )
	coursach.menu:SetSize( scrw, scrh)
	local menux,menuy = coursach.menu:GetWide(),coursach.menu:GetTall()


	coursach.menu:MakePopup()
	
	coursach.menu.Paint = function(self,w,h)
	surface.SetDrawColor( 30, 30, 30, 255 )
	    surface.DrawRect(0,0,w,h)
	    

	end
	

	
	function makeglavmenu()

		if IsValid(coursach.menu.glav) then coursach.menu.glav:Remove() end
		if IsValid(coursach.menu.tovari) then coursach.menu.tovari:Remove() end
		if IsValid(coursach.menu.pracivnik) then coursach.menu.pracivnik:Remove() end
		coursach.menu.glav = vgui.Create( "EditablePanel", coursach.menu )
		coursach.menu.glav:SetSize( menux, menuy )
		coursach.menu.glav:SetPos( 0, 0 )
		coursach.menu.glav.Paint = function(self,w,h)
		surface.SetMaterial(Material( "materials/coursach/restaurant.png", "noclamp smooth mips" ))
        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.DrawTexturedRect(w/2-500, h/2-500, 1000, 1000)
		draw.SimpleText( "Система мережі ресторану", "coursach_25", w/2, h*.015, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
		end

		coursach.menu.glav.bclose = vgui.Create("DButton", coursach.menu.glav)
		coursach.menu.glav.bclose:SetText( "" )
		coursach.menu.glav.bclose:SetPos( menux-25, -3 )
		coursach.menu.glav.bclose:SetSize( 25, 25 )
		coursach.menu.glav.bclose.Paint = function(self,w,h)
			draw.SimpleText( "x", "coursach_25", w/2, h/2, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
		end
		coursach.menu.glav.bclose.DoClick = function()
			coursach.menu:Remove()
		end
		coursach.menu.glav.vidvidyvach = vgui.Create("DButton", coursach.menu.glav)
		coursach.menu.glav.vidvidyvach:SetText( "" )
		coursach.menu.glav.vidvidyvach:SetPos( menux*.015, menuy*.5 )
		coursach.menu.glav.vidvidyvach:SetSize( menux*.25, menuy*.06 )
		coursach.menu.glav.vidvidyvach.Paint = function(self,w,h)
			surface.SetDrawColor( 0, 0, 0, 150 )
		    surface.DrawRect(0,0,w,h)
		draw.Blur(coursach.menu.glav.vidvidyvach,1)
			draw.SimpleText( "Відвідувачу", "coursach_25", w/2, h/2, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
		end
		coursach.menu.glav.vidvidyvach.DoClick = function()
			//coursach.menu.glav:Remove()
			net.Start( "coursach_getrestaurants" )
    		net.SendToServer()
			//makevidvidyvachmenu()
			//coursach.menu:MoveTo(scrw*.5 - menux*.5,scrh*.5-menuy*.5 ,0.1,0,-1,function()end)
		end

		coursach.menu.glav.pracivnik = vgui.Create("DButton", coursach.menu.glav)
		coursach.menu.glav.pracivnik:SetText( "" )
		coursach.menu.glav.pracivnik:SetPos( menux*.75, menuy*.5 )
		coursach.menu.glav.pracivnik:SetSize( menux*.25, menuy*.06 )
		coursach.menu.glav.pracivnik.Paint = function(self,w,h)
			surface.SetDrawColor( 0, 0, 0, 150 )
		    surface.DrawRect(0,0,w,h)
		draw.Blur(coursach.menu.glav.pracivnik,1)
			draw.SimpleText( "Працівнику", "coursach_25", w/2, h/2, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
		end
		coursach.menu.glav.pracivnik.DoClick = function()
			//coursach.menu.glav:Remove()
			makepracivnikmenu()
			//coursach.menu:MoveTo(scrw*.5 - menux*.5,scrh*.5-menuy*.5 ,0.1,0,-1,function()end)

		end

end


function makerestaurantgetmenu()
if IsValid(coursach.menu.glav.rightsettingsrestaurant) then coursach.menu.glav.rightsettingsrestaurant:Remove() end
	coursach.menu.pracivnikrestaurants = vgui.Create( "EditablePanel", coursach.menu.glav )
	coursach.menu.pracivnikrestaurants:SetSize( menux*.4, menuy*.8 )
	coursach.menu.pracivnikrestaurants:SetPos( menux*.25, menuy*.15  )
	coursach.menu.pracivnikrestaurants.Paint = function(self,w,h)
		surface.SetFont( "coursach_20" )
		surface.SetDrawColor( 100, 30, 30, 255 )
	    surface.DrawRect(0,0,w,h)
	end

	coursach.menu.pracivnikrestaurants.list = vgui.Create( "DListView", coursach.menu.pracivnikrestaurants )
	coursach.menu.pracivnikrestaurants.list:Dock( FILL )
	coursach.menu.pracivnikrestaurants.list:SetMultiSelect( false )
	coursach.menu.pracivnikrestaurants.list:AddColumn( "RestaurantID" )
	coursach.menu.pracivnikrestaurants.list:AddColumn( "Adress" )
	coursach.menu.pracivnikrestaurants.list:AddColumn( "Open" )
	coursach.menu.pracivnikrestaurants.list:AddColumn( "State" )
	coursach.menu.pracivnikrestaurants.list:AddColumn( "Rating" )
	for k,v in pairs(restaurants) do
		coursach.menu.pracivnikrestaurants.list:AddLine(v.RestaurantID,v.Adress,v.Open,v.State,v.Rating)
	end


	coursach.menu.pracivnikrestaurants.list.OnRowSelected = function( lst, index, pnl )
	if IsValid(coursach.menu.glav.rightsettingsrestaurant) then coursach.menu.glav.rightsettingsrestaurant:Remove() end

	coursach.menu.glav.rightsettingsrestaurant = vgui.Create( "EditablePanel", coursach.menu.glav )
		coursach.menu.glav.rightsettingsrestaurant:SetSize( menux*.35, menuy*.8 )
		coursach.menu.glav.rightsettingsrestaurant:SetPos( menux*.65, menuy*.15 )
		coursach.menu.glav.rightsettingsrestaurant.Paint = function(self,w,h)

		draw.SimpleText( "RestaurantID", "coursach_25", w*.5, h*.015, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
		draw.SimpleText( "Adress", "coursach_25", w*.5, h*.115, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
		draw.SimpleText( "Open", "coursach_25", w*.5, h*.215, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
		draw.SimpleText( "State", "coursach_25", w*.5, h*.315, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
		draw.SimpleText( "Rating", "coursach_25", w*.5, h*.415, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
		end
		local menuxx,menuyy = coursach.menu.glav.rightsettingsrestaurant:GetWide(),coursach.menu.glav.rightsettingsrestaurant:GetTall()
		coursach.menu.glav.rightsettingsrestaurant.RestaurantID = vgui.Create( "DTextEntry", coursach.menu.glav.rightsettingsrestaurant ) 
				coursach.menu.glav.rightsettingsrestaurant.RestaurantID:SetPos(menuxx*.1, menuyy*.035)
				coursach.menu.glav.rightsettingsrestaurant.RestaurantID:SetSize(menuxx*.8, menuyy*.025)
				coursach.menu.glav.rightsettingsrestaurant.RestaurantID:SetValue( pnl:GetColumnText( 1 ) )
				coursach.menu.glav.rightsettingsrestaurant.RestaurantID.OnEnter = function( self )
				chat.AddText( self:GetValue() )
		end

		coursach.menu.glav.rightsettingsrestaurant.Adress = vgui.Create( "DTextEntry", coursach.menu.glav.rightsettingsrestaurant ) 
				coursach.menu.glav.rightsettingsrestaurant.Adress:SetPos(menuxx*.1, menuyy*.135)
				coursach.menu.glav.rightsettingsrestaurant.Adress:SetSize(menuxx*.8, menuyy*.025)
				coursach.menu.glav.rightsettingsrestaurant.Adress:SetValue( pnl:GetColumnText( 2 ) )
				coursach.menu.glav.rightsettingsrestaurant.Adress.OnEnter = function( self )
				chat.AddText( self:GetValue() )
		end

		coursach.menu.glav.rightsettingsrestaurant.Open = vgui.Create( "DTextEntry", coursach.menu.glav.rightsettingsrestaurant ) 
				coursach.menu.glav.rightsettingsrestaurant.Open:SetPos(menuxx*.1, menuyy*.235)
				coursach.menu.glav.rightsettingsrestaurant.Open:SetSize(menuxx*.8, menuyy*.025)
				coursach.menu.glav.rightsettingsrestaurant.Open:SetValue(pnl:GetColumnText( 3 ) )
				coursach.menu.glav.rightsettingsrestaurant.Open.OnEnter = function( self )
				chat.AddText( self:GetValue() )
		end

		coursach.menu.glav.rightsettingsrestaurant.State = vgui.Create( "DTextEntry", coursach.menu.glav.rightsettingsrestaurant) 
				coursach.menu.glav.rightsettingsrestaurant.State:SetPos(menuxx*.1, menuyy*.345)
				coursach.menu.glav.rightsettingsrestaurant.State:SetSize(menuxx*.8, menuyy*.025)
				coursach.menu.glav.rightsettingsrestaurant.State:SetValue( pnl:GetColumnText( 4 ) )
				coursach.menu.glav.rightsettingsrestaurant.State.OnEnter = function( self )
				chat.AddText( self:GetValue() )
		end

		coursach.menu.glav.rightsettingsrestaurant.Rating = vgui.Create( "DTextEntry", coursach.menu.glav.rightsettingsrestaurant ) 
				coursach.menu.glav.rightsettingsrestaurant.Rating:SetPos(menuxx*.1, menuyy*.455)
				coursach.menu.glav.rightsettingsrestaurant.Rating:SetSize(menuxx*.8, menuyy*.025)
				coursach.menu.glav.rightsettingsrestaurant.Rating:SetValue( pnl:GetColumnText( 5 ) )
				coursach.menu.glav.rightsettingsrestaurant.Rating.OnEnter = function( self )
				chat.AddText( self:GetValue() )
		end

	


	coursach.menu.glav.rightsettingsrestaurant.change = vgui.Create("DButton", coursach.menu.glav.rightsettingsrestaurant)
	coursach.menu.glav.rightsettingsrestaurant.change:SetText( "" )
	coursach.menu.glav.rightsettingsrestaurant.change:SetPos(menuxx*.25, menuyy*.8 )
	coursach.menu.glav.rightsettingsrestaurant.change:SetSize( menuxx*.5, menuyy*.1 )
	coursach.menu.glav.rightsettingsrestaurant.change.Paint = function(self,w,h)
	draw.RoundedBox(0, 0, 0, w, h, Color(255,0,0,10))
		draw.SimpleText( "Save Change", "coursach_25", w/2, h/2, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
	end
	coursach.menu.glav.rightsettingsrestaurant.change.DoClick = function()
		if IsValid(coursach.menu.glav.rightsettingsrestaurant) then coursach.menu.glav.rightsettingsrestaurant:Remove() end
	end
		print( "Selected " .. pnl:GetColumnText( 1 ) .. " ( " .. pnl:GetColumnText( 2 ) .. " ) at index " .. index )
	end

end


function makepracivnikmenu()
	coursach.menu.pracivnik = vgui.Create( "EditablePanel", coursach.menu.glav )
	coursach.menu.pracivnik:SetSize( menux, menuy )
	coursach.menu.pracivnik:SetPos( 0,0 )
	coursach.menu.pracivnik.Paint = function(self,w,h)
		surface.SetFont( "coursach_20" )
	
		surface.SetDrawColor( 30, 30, 30, 255 )
	    surface.DrawRect(0,0,w,h)

		draw.SimpleText( "Меню працівника", "coursach_30", w*.05, h*.05, color_white, TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER )

	end
	
	coursach.menu.pracivnik.she = vgui.Create( "EditablePanel", coursach.menu.pracivnik)
	coursach.menu.pracivnik.she:SetSize(menux*.2, menuy*.85)
	coursach.menu.pracivnik.she:SetPos(menux*.01, menuy*.1 )
	coursach.menu.pracivnik.she.Paint = function(self,w,h)
		draw.RoundedBox(0, 0, 0, w, h, Color(255,0,0,10))
	end

	coursach.menu.pracivnik.she.restaurants = vgui.Create( "DScrollPanel", coursach.menu.pracivnik.she)
	coursach.menu.pracivnik.she.restaurants:Dock(FILL)
	coursach.menu.pracivnik.she.restaurants.Paint = function(self,w,h)
		
	end
	coursach.menu.pracivnik.she.restaurants.btnrests = vgui.Create("DButton", coursach.menu.pracivnik.she.restaurants)
	coursach.menu.pracivnik.she.restaurants.btnrests:SetText( "" )
	coursach.menu.pracivnik.she.restaurants.btnrests:Dock(TOP)
	coursach.menu.pracivnik.she.restaurants.btnrests:SetTall(menuy*.05)
		coursach.menu.pracivnik.she.restaurants.btnrests:DockMargin(5,5,5,0)
	coursach.menu.pracivnik.she.restaurants.btnrests.Paint = function(self,w,h)
	draw.RoundedBox(0, 0, 0, w, h, Color(0,255,0,10))
		draw.SimpleText( "Ресторани", "coursach_25", w/2, h/2, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
	end
	coursach.menu.pracivnik.she.restaurants.btnrests.DoClick = function()
		net.Start("coursachp_getrestaurants")
		net.SendToServer()

	end
	coursach.menu.pracivnik.she.restaurants.btnworkers = vgui.Create("DButton", coursach.menu.pracivnik.she.restaurants)
	coursach.menu.pracivnik.she.restaurants.btnworkers:SetText( "" )
	coursach.menu.pracivnik.she.restaurants.btnworkers:Dock(TOP)
	coursach.menu.pracivnik.she.restaurants.btnworkers:SetTall(menuy*.05)
		coursach.menu.pracivnik.she.restaurants.btnworkers:DockMargin(5,5,5,0)
	coursach.menu.pracivnik.she.restaurants.btnworkers.Paint = function(self,w,h)
	draw.RoundedBox(0, 0, 0, w, h, Color(0,255,0,10))
		draw.SimpleText( "Працівники", "coursach_25", w/2, h/2, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
	end
	coursach.menu.pracivnik.she.restaurants.btnworkers.DoClick = function()
		
	end

	coursach.menu.pracivnik.she.restaurants.btnpersons = vgui.Create("DButton", coursach.menu.pracivnik.she.restaurants)
	coursach.menu.pracivnik.she.restaurants.btnpersons:SetText( "" )
	coursach.menu.pracivnik.she.restaurants.btnpersons:Dock(TOP)
	coursach.menu.pracivnik.she.restaurants.btnpersons:SetTall(menuy*.05)
		coursach.menu.pracivnik.she.restaurants.btnpersons:DockMargin(5,5,5,0)
	coursach.menu.pracivnik.she.restaurants.btnpersons.Paint = function(self,w,h)
	draw.RoundedBox(0, 0, 0, w, h, Color(0,255,0,10))
		draw.SimpleText( "Люди", "coursach_25", w/2, h/2, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
	end
	coursach.menu.pracivnik.she.restaurants.btnpersons.DoClick = function()
		
	end

	coursach.menu.pracivnik.she.restaurants.btndishes = vgui.Create("DButton", coursach.menu.pracivnik.she.restaurants)
	coursach.menu.pracivnik.she.restaurants.btndishes:SetText( "" )
	coursach.menu.pracivnik.she.restaurants.btndishes:Dock(TOP)
	coursach.menu.pracivnik.she.restaurants.btndishes:SetTall(menuy*.05)
		coursach.menu.pracivnik.she.restaurants.btndishes:DockMargin(5,5,5,0)
	coursach.menu.pracivnik.she.restaurants.btndishes.Paint = function(self,w,h)
	draw.RoundedBox(0, 0, 0, w, h, Color(0,255,0,10))
		draw.SimpleText( "Страви", "coursach_25", w/2, h/2, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
	end
	coursach.menu.pracivnik.she.restaurants.btndishes.DoClick = function()
		
	end

	coursach.menu.pracivnik.she.restaurants.btndishestype = vgui.Create("DButton", coursach.menu.pracivnik.she.restaurants)
	coursach.menu.pracivnik.she.restaurants.btndishestype:SetText( "" )
	coursach.menu.pracivnik.she.restaurants.btndishestype:Dock(TOP)
	coursach.menu.pracivnik.she.restaurants.btndishestype:SetTall(menuy*.05)
		coursach.menu.pracivnik.she.restaurants.btndishestype:DockMargin(5,5,5,0)
	coursach.menu.pracivnik.she.restaurants.btndishestype.Paint = function(self,w,h)
	draw.RoundedBox(0, 0, 0, w, h, Color(0,255,0,10))
		draw.SimpleText( "Типи Страви", "coursach_25", w/2, h/2, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
	end
	coursach.menu.pracivnik.she.restaurants.btndishestype.DoClick = function()
		
	end

	coursach.menu.pracivnik.she.restaurants.btndelivery = vgui.Create("DButton", coursach.menu.pracivnik.she.restaurants)
	coursach.menu.pracivnik.she.restaurants.btndelivery:SetText( "" )
	coursach.menu.pracivnik.she.restaurants.btndelivery:Dock(TOP)
	coursach.menu.pracivnik.she.restaurants.btndelivery:SetTall(menuy*.05)
		coursach.menu.pracivnik.she.restaurants.btndelivery:DockMargin(5,5,5,0)
	coursach.menu.pracivnik.she.restaurants.btndelivery.Paint = function(self,w,h)
	draw.RoundedBox(0, 0, 0, w, h, Color(0,255,0,10))
		draw.SimpleText( "Поставка", "coursach_25", w/2, h/2, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
	end
	coursach.menu.pracivnik.she.restaurants.btndelivery.DoClick = function()
		
	end

	coursach.menu.pracivnik.she.restaurants.btndeliverytype = vgui.Create("DButton", coursach.menu.pracivnik.she.restaurants)
	coursach.menu.pracivnik.she.restaurants.btndeliverytype:SetText( "" )
	coursach.menu.pracivnik.she.restaurants.btndeliverytype:Dock(TOP)
	coursach.menu.pracivnik.she.restaurants.btndeliverytype:SetTall(menuy*.05)
		coursach.menu.pracivnik.she.restaurants.btndeliverytype:DockMargin(5,5,5,0)
	coursach.menu.pracivnik.she.restaurants.btndeliverytype.Paint = function(self,w,h)
	draw.RoundedBox(0, 0, 0, w, h, Color(0,255,0,10))
		draw.SimpleText( "Типи поставки", "coursach_25", w/2, h/2, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
	end
	coursach.menu.pracivnik.she.restaurants.btndeliverytype.DoClick = function()
		
	end

	coursach.menu.pracivnik.she.restaurants.btnprovider = vgui.Create("DButton", coursach.menu.pracivnik.she.restaurants)
	coursach.menu.pracivnik.she.restaurants.btnprovider:SetText( "" )
	coursach.menu.pracivnik.she.restaurants.btnprovider:Dock(TOP)
	coursach.menu.pracivnik.she.restaurants.btnprovider:SetTall(menuy*.05)
		coursach.menu.pracivnik.she.restaurants.btnprovider:DockMargin(5,5,5,0)
	coursach.menu.pracivnik.she.restaurants.btnprovider.Paint = function(self,w,h)
	draw.RoundedBox(0, 0, 0, w, h, Color(0,255,0,10))
		draw.SimpleText( "Постачальники", "coursach_25", w/2, h/2, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
	end
	coursach.menu.pracivnik.she.restaurants.btnprovider.DoClick = function()
		
	end

	coursach.menu.pracivnik.bclose = vgui.Create("DButton", coursach.menu.pracivnik)
	coursach.menu.pracivnik.bclose:SetText( "" )
	coursach.menu.pracivnik.bclose:SetPos( menux-25, -3 )
	coursach.menu.pracivnik.bclose:SetSize( 25, 25 )
	coursach.menu.pracivnik.bclose.Paint = function(self,w,h)
		draw.SimpleText( "x", "coursach_25", w/2, h/2, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
	end
	coursach.menu.pracivnik.bclose.DoClick = function()
		coursach.menu:Remove()
	end

	coursach.menu.pracivnik.nazad = vgui.Create("DButton", coursach.menu.pracivnik)
	coursach.menu.pracivnik.nazad:SetText( "" )
	coursach.menu.pracivnik.nazad:SetPos( menux-55, -3 )
	coursach.menu.pracivnik.nazad:SetSize( 25, 25 )
	coursach.menu.pracivnik.nazad.Paint = function(self,w,h)
		draw.SimpleText( "<<", "coursach_25", w/2, h/2, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
	end
	coursach.menu.pracivnik.nazad.DoClick = function()
		if IsValid(coursach.menu.pracivnik) then coursach.menu.pracivnik:Remove() end
		makeglavmenu()
	end

end
net.Receive("coursach_addorder",function()
local orderdishes = net.ReadTable()
	coursach.menu.selectdishes.shes.dishes:Clear()
	for k,v in pairs(orderdishes) do
		local categorybtn =	vgui.Create("DButton", coursach.menu.selectdishes.shes.dishes)
		categorybtn:SetText("")
		categorybtn:Dock(TOP)
		categorybtn:DockMargin(5,5,5,0)
		categorybtn:SetTall(menuy*.15)
		categorybtn:SetWide(menux*.5)
		categorybtn.Paint = function(self,w,h)
			
			draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,125))
			for d,g in pairs(dishes) do
				if g.DishID != v.DishID then continue end
				draw.SimpleText("Назва страви: " .. g.Name, "coursach_20", w*.5, h*.35, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
				draw.SimpleText(" Ціна: ".. g.Price * v.Amount, "coursach_20", w*.5, h*.45, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
				draw.SimpleText(" Кількість: ".. v.Amount, "coursach_20", w*.5, h*.55, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
				draw.SimpleText("-", "coursach_50", w*.9, h*.45, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
			end

			
			end
		categorybtn.DoClick = function()
		print(v.DishOrderID .. "test")
			net.Start("coursach_removeorder")
			net.WriteInt(v.DishOrderID,32)
			net.SendToServer()
		end
	end
end)
function openmenuseldishes()
	coursach.menu.selectdishes = vgui.Create( "EditablePanel", coursach.menu.glav )
	coursach.menu.selectdishes:SetSize( menux, menuy )
	coursach.menu.selectdishes:SetPos( 0, 0 )
	coursach.menu.selectdishes.Paint = function(self,w,h)
		surface.SetFont( "coursach_20" )
		
		surface.SetDrawColor( 30, 30, 30, 255 )
	    surface.DrawRect(0,0,w,h)

		draw.SimpleText( "Страви", "coursach_30", w*.15, h*.05, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
		draw.SimpleText( "Замовлення", "coursach_30", w*.85, h*.05, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
	end

	coursach.menu.selectdishes.shes = vgui.Create( "EditablePanel", coursach.menu.selectdishes)
	coursach.menu.selectdishes.shes:SetSize(menux*.3, menuy*.8)
	coursach.menu.selectdishes.shes:SetPos(menux*.69, menuy*.08 )
	coursach.menu.selectdishes.shes.Paint = function(self,w,h)
		draw.RoundedBox(0, 0, 0, w, h, Color(255,0,0,10))
	end

	coursach.menu.selectdishes.shes.dishes = vgui.Create( "DScrollPanel", coursach.menu.selectdishes.shes)
	coursach.menu.selectdishes.shes.dishes:Dock(FILL)
	coursach.menu.selectdishes.shes.dishes.Paint = function(self,w,h)
		
	end


	coursach.menu.selectdishes.she = vgui.Create( "EditablePanel", coursach.menu.selectdishes)
	coursach.menu.selectdishes.she:SetSize(menux*.3, menuy*.8)
	coursach.menu.selectdishes.she:SetPos(menux*.015, menuy*.08 )
	coursach.menu.selectdishes.she.Paint = function(self,w,h)
		draw.RoundedBox(0, 0, 0, w, h, Color(255,0,0,10))
	end

	coursach.menu.selectdishes.she.dishes = vgui.Create( "DScrollPanel", coursach.menu.selectdishes.she)
	coursach.menu.selectdishes.she.dishes:Dock(FILL)
	coursach.menu.selectdishes.she.dishes.Paint = function(self,w,h)
		
	end
		for k,d in pairs(dishestype)do
			local categorybtn =	vgui.Create("DButton", coursach.menu.selectdishes.she.dishes)
							categorybtn:SetText("")
							categorybtn:Dock(TOP)
							categorybtn:DockMargin(5,5,5,0)
							categorybtn:SetTall(menuy*.05)
							categorybtn:SetWide(menux*.5)
							categorybtn.Paint = function(self,w,h)
								
								draw.RoundedBox(0, 0, 0, w, h, Color(0,0,200,125))
								draw.SimpleText(d.Name, "coursach_20", w*.5, h*.5, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
								end
					for k,v in pairs(dishes) do
						if d.DishTypeID != v.DishTypeID then continue end
							local categorybtn =	vgui.Create("DButton", coursach.menu.selectdishes.she.dishes)
							categorybtn:SetText("")
							categorybtn:Dock(TOP)
							categorybtn:DockMargin(5,5,5,0)
							categorybtn:SetTall(menuy*.15)
							categorybtn:SetWide(menux*.5)
							categorybtn.Paint = function(self,w,h)
								
								draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,125))
								draw.SimpleText("Назва страви: " .. v.Name, "coursach_20", w*.5, h*.35, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
								draw.SimpleText(" Ціна: ".. v.Price, "coursach_20", w*.5, h*.45, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
								draw.SimpleText("+", "coursach_50", w*.9, h*.45, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
									
								end
							categorybtn.DoClick = function()
								net.Start("coursach_addorder")
								net.WriteInt(v.DishID,3)
								net.SendToServer()
							end
						end
				end
	


coursach.menu.selectdishes.zamoviti = vgui.Create("DButton", coursach.menu.selectdishes)
	coursach.menu.selectdishes.zamoviti:SetText( "" )
	coursach.menu.selectdishes.zamoviti:SetPos( menux*.25, menuy*.92 )
	coursach.menu.selectdishes.zamoviti:SetSize( menux*.5, menuy*.06 )
	coursach.menu.selectdishes.zamoviti.Paint = function(self,w,h)
	draw.RoundedBox(0, 0, 0, w, h, Color(0,150,0,125))
		draw.SimpleText( "Замовити", "coursach_25", w/2, h/2, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
	end
	coursach.menu.selectdishes.zamoviti.DoClick = function()
		net.Start("coursach_sendorder")
		net.SendToServer()
		makeglavmenu()
	end

	coursach.menu.selectdishes.bclose = vgui.Create("DButton", coursach.menu.selectdishes)
	coursach.menu.selectdishes.bclose:SetText( "" )
	coursach.menu.selectdishes.bclose:SetPos( menux-25, -3 )
	coursach.menu.selectdishes.bclose:SetSize( 25, 25 )
	coursach.menu.selectdishes.bclose.Paint = function(self,w,h)
		draw.SimpleText( "x", "coursach_25", w/2, h/2, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
	end
	coursach.menu.selectdishes.bclose.DoClick = function()
		coursach.menu:Remove()
	end

	coursach.menu.selectdishes.nazad = vgui.Create("DButton", coursach.menu.selectdishes)
	coursach.menu.selectdishes.nazad:SetText( "" )
	coursach.menu.selectdishes.nazad:SetPos( menux-55, -3 )
	coursach.menu.selectdishes.nazad:SetSize( 25, 25 )
	coursach.menu.selectdishes.nazad.Paint = function(self,w,h)
		draw.SimpleText( "<<", "coursach_25", w/2, h/2, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
	end
	coursach.menu.selectdishes.nazad.DoClick = function()
		if IsValid(coursach.menu.selectdishes) then coursach.menu.selectdishes:Remove() end
		openmenuselhalltable()
	end
end

function openmenuselhalltable()
coursach.menu.selecthalltable = vgui.Create( "EditablePanel", coursach.menu.glav )
	coursach.menu.selecthalltable:SetSize( menux, menuy )
	coursach.menu.selecthalltable:SetPos( 0, 0 )
	coursach.menu.selecthalltable.Paint = function(self,w,h)
		surface.SetFont( "coursach_20" )
		
		surface.SetDrawColor( 30, 30, 30, 255 )
	    surface.DrawRect(0,0,w,h)
		draw.SimpleText( "Виберіть столик", "coursach_30", w*.5, h*.05, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
	end

	coursach.menu.selecthalltable.she = vgui.Create( "EditablePanel", coursach.menu.selecthalltable)
	coursach.menu.selecthalltable.she:SetSize(menux*.5, menuy*.5)
	coursach.menu.selecthalltable.she:SetPos(menux*.25, menuy*.3 )
	coursach.menu.selecthalltable.she.Paint = function(self,w,h)
		draw.RoundedBox(0, 0, 0, w, h, Color(255,0,0,10))
	end

	coursach.menu.selecthalltable.she.halls = vgui.Create( "DScrollPanel", coursach.menu.selecthalltable.she)
	coursach.menu.selecthalltable.she.halls:Dock(FILL)
	coursach.menu.selecthalltable.she.halls.Paint = function(self,w,h)
		
	end

	for k,v in pairs(hallstable) do
		local categorybtn =	vgui.Create("DButton", coursach.menu.selecthalltable.she.halls)
		categorybtn:SetText("")
		categorybtn:Dock(TOP)
		categorybtn:DockMargin(5,5,5,0)
		categorybtn:SetTall(menuy*.15)
		categorybtn:SetWide(menux*.5)
		categorybtn.Paint = function(self,w,h)
			
			draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,125))
			draw.SimpleText("Макс. кількість осіб: " .. v.PersonMax, "coursach_20", w*.5, h*.35, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
			draw.SimpleText(" Стан стола: ".. v.State, "coursach_20", w*.5, h*.45, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
		end
		categorybtn.DoClick = function()
			selcategory = k

			net.Start("coursach_getrestaurantsdishes")
			net.WriteInt(v.TableID,3)
			net.SendToServer()
			
		end
	end

	coursach.menu.selecthalltable.bclose = vgui.Create("DButton", coursach.menu.selecthalltable)
	coursach.menu.selecthalltable.bclose:SetText( "" )
	coursach.menu.selecthalltable.bclose:SetPos( menux-25, -3 )
	coursach.menu.selecthalltable.bclose:SetSize( 25, 25 )
	coursach.menu.selecthalltable.bclose.Paint = function(self,w,h)
		draw.SimpleText( "x", "coursach_25", w/2, h/2, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
	end
	coursach.menu.selecthalltable.bclose.DoClick = function()
		coursach.menu:Remove()
	end

	coursach.menu.selecthalltable.nazad = vgui.Create("DButton", coursach.menu.selecthalltable)
	coursach.menu.selecthalltable.nazad:SetText( "" )
	coursach.menu.selecthalltable.nazad:SetPos( menux-55, -3 )
	coursach.menu.selecthalltable.nazad:SetSize( 25, 25 )
	coursach.menu.selecthalltable.nazad.Paint = function(self,w,h)
		draw.SimpleText( "<<", "coursach_25", w/2, h/2, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
	end
	coursach.menu.selecthalltable.nazad.DoClick = function()
		if IsValid(coursach.menu.selecthalltable) then coursach.menu.selecthalltable:Remove() end
		openmenuselhall()
	end
end

function openmenuselhall()
	coursach.menu.selecthall = vgui.Create( "EditablePanel", coursach.menu.glav )
	coursach.menu.selecthall:SetSize( menux, menuy )
	coursach.menu.selecthall:SetPos( 0, 0 )
	coursach.menu.selecthall.Paint = function(self,w,h)
		surface.SetFont( "coursach_20" )
		
		surface.SetDrawColor( 30, 30, 30, 255 )
	    surface.DrawRect(0,0,w,h)
		
		draw.SimpleText( "Виберіть зал", "coursach_30", w*.5, h*.05, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
	end

	coursach.menu.selecthall.she = vgui.Create( "EditablePanel", coursach.menu.selecthall)
	coursach.menu.selecthall.she:SetSize(menux*.5, menuy*.5)
	coursach.menu.selecthall.she:SetPos(menux*.25, menuy*.3 )
	coursach.menu.selecthall.she.Paint = function(self,w,h)
		draw.RoundedBox(0, 0, 0, w, h, Color(255,0,0,10))
	end

	coursach.menu.selecthall.she.halls = vgui.Create( "DScrollPanel", coursach.menu.selecthall.she)
	coursach.menu.selecthall.she.halls:Dock(FILL)
	coursach.menu.selecthall.she.halls.Paint = function(self,w,h)
		
	end

	for k,v in pairs(halls) do
		local categorybtn =	vgui.Create("DButton", coursach.menu.selecthall.she.halls)
		categorybtn:SetText("")
		categorybtn:Dock(TOP)
		categorybtn:DockMargin(5,5,5,0)
		categorybtn:SetTall(menuy*.15)
		categorybtn:SetWide(menux*.5)
		categorybtn.Paint = function(self,w,h)
			
			draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,125))
			draw.SimpleText("Місце знаходження: " .. v.Place, "coursach_20", w*.5, h*.35, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
			draw.SimpleText("Тип залу: " .. v.Type .. " Стан залу: ".. v.State, "coursach_20", w*.5, h*.45, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
		end
		categorybtn.DoClick = function()
			selcategory = k
			net.Start("coursach_gethallstable")
			net.WriteInt(v.HallID,3)
			net.SendToServer()
		end
	end

	coursach.menu.selecthall.bclose = vgui.Create("DButton", coursach.menu.selecthall)
	coursach.menu.selecthall.bclose:SetText( "" )
	coursach.menu.selecthall.bclose:SetPos( menux-25, -3 )
	coursach.menu.selecthall.bclose:SetSize( 25, 25 )
	coursach.menu.selecthall.bclose.Paint = function(self,w,h)
		draw.SimpleText( "x", "coursach_25", w/2, h/2, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
	end
	coursach.menu.selecthall.bclose.DoClick = function()
		coursach.menu:Remove()
	end

	coursach.menu.selecthall.nazad = vgui.Create("DButton", coursach.menu.selecthall)
	coursach.menu.selecthall.nazad:SetText( "" )
	coursach.menu.selecthall.nazad:SetPos( menux-55, -3 )
	coursach.menu.selecthall.nazad:SetSize( 25, 25 )
	coursach.menu.selecthall.nazad.Paint = function(self,w,h)
		draw.SimpleText( "<<", "coursach_25", w/2, h/2, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
	end
	coursach.menu.selecthall.nazad.DoClick = function()
		if IsValid(coursach.menu.selecthall) then coursach.menu.selecthall:Remove() end
		makevidvidyvachmenu()
	end

end

function makevidvidyvachmenu()
	coursach.menu.vidvidyvach = vgui.Create( "EditablePanel", coursach.menu.glav )
	coursach.menu.vidvidyvach:SetSize( menux, menuy )
	coursach.menu.vidvidyvach:SetPos( 0, 0 )
	coursach.menu.vidvidyvach.Paint = function(self,w,h)
		surface.SetFont( "coursach_20" )
		
		surface.SetDrawColor( 30, 30, 30, 255 )
	    surface.DrawRect(0,0,w,h)
		draw.Blur(coursach.menu.vidvidyvach,2)
		draw.SimpleText( "Виберіть ресторан", "coursach_30", w*.5, h*.05, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
	end
	
	coursach.menu.vidvidyvach.she = vgui.Create( "EditablePanel", coursach.menu.vidvidyvach)
	coursach.menu.vidvidyvach.she:SetSize(menux*.5, menuy*.5)
	coursach.menu.vidvidyvach.she:SetPos(menux*.25, menuy*.3 )
	coursach.menu.vidvidyvach.she.Paint = function(self,w,h)
		draw.RoundedBox(0, 0, 0, w, h, Color(255,0,0,10))
	end

	coursach.menu.vidvidyvach.she.restaurants = vgui.Create( "DScrollPanel", coursach.menu.vidvidyvach.she)
	coursach.menu.vidvidyvach.she.restaurants:Dock(FILL)
	coursach.menu.vidvidyvach.she.restaurants.Paint = function(self,w,h)
		
	end

	for k,v in pairs(restaurants) do
		local categorybtn =	vgui.Create("DButton", coursach.menu.vidvidyvach.she.restaurants)
		categorybtn:SetText("")
		categorybtn:Dock(TOP)
		categorybtn:DockMargin(5,5,5,0)
		categorybtn:SetTall(menuy*.15)
		surface.SetFont("coursach_20")
		local size = surface.GetTextSize(v.Adress)
		categorybtn:SetWide(menux*.5)
		categorybtn.Paint = function(self,w,h)
			
			draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,125))
			-- if k == selcategory then
			-- 	draw.RoundedBox(0, 0, h*.9, w, h*.1, color_white)
			-- end
			draw.SimpleText("Місце знаходження: " .. v.Adress, "coursach_20", w*.5, h*.35, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
			draw.SimpleText("Дата: " .. v.Open .. " Рейтинг: ".. v.Rating .." Статус: " .. v.State, "coursach_20", w*.5, h*.45, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
		end
		categorybtn.DoClick = function()
		if v.State == "Close" then return end
			selcategory = k
net.Start("coursach_gethalls")
			net.WriteInt(v.RestaurantID,3)
			net.SendToServer()
		end
	end


	coursach.menu.vidvidyvach.bclose = vgui.Create("DButton", coursach.menu.vidvidyvach)
	coursach.menu.vidvidyvach.bclose:SetText( "" )
	coursach.menu.vidvidyvach.bclose:SetPos( menux-25, -3 )
	coursach.menu.vidvidyvach.bclose:SetSize( 25, 25 )
	coursach.menu.vidvidyvach.bclose.Paint = function(self,w,h)
		draw.SimpleText( "x", "coursach_25", w/2, h/2, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
	end
	coursach.menu.vidvidyvach.bclose.DoClick = function()
		coursach.menu:Remove()
	end

	coursach.menu.vidvidyvach.nazad = vgui.Create("DButton", coursach.menu.vidvidyvach)
	coursach.menu.vidvidyvach.nazad:SetText( "" )
	coursach.menu.vidvidyvach.nazad:SetPos( menux-55, -3 )
	coursach.menu.vidvidyvach.nazad:SetSize( 25, 25 )
	coursach.menu.vidvidyvach.nazad.Paint = function(self,w,h)
		draw.SimpleText( "<<", "coursach_25", w/2, h/2, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
	end
	coursach.menu.vidvidyvach.nazad.DoClick = function()
		if IsValid(coursach.menu.vidvidyvach) then coursach.menu.vidvidyvach:Remove() end
		makeglavmenu()
	end

end

makeglavmenu()

	coursach.menu.bclose = vgui.Create("DButton", coursach.menu)
	coursach.menu.bclose:SetText( "" )
	coursach.menu.bclose:SetPos( menux-25, -3)
	coursach.menu.bclose:SetSize( 25, 25 )
	coursach.menu.bclose.Paint = function(self,w,h)
		draw.SimpleText( "x", "coursach_25", w/2, h/2, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
	end
	coursach.menu.bclose.DoClick = function()
		coursach.menu:Remove()
	end

	

end)





function NotifyCustom(str)
    local NotifyPanel = vgui.Create("DNotify")
    surface.SetFont("coursach_25")
    local a, b = surface.GetTextSize(str)
    NotifyPanel:SetPos((ScrW()/2)-((a+20)/2), 15)
    NotifyPanel:SetSize(a+20, 40)

    notyfypanel = vgui.Create("DFrame", NotifyPanel)
    notyfypanel:SetSize(NotifyPanel:GetWide(),NotifyPanel:GetTall())
    notyfypanel:SetTitle("")
    notyfypanel:ShowCloseButton(false)
    notyfypanel:SetDraggable(false)
    notyfypanel:SetMouseInputEnabled(false)
    notyfypanel:SetKeyboardInputEnabled(false)

    notyfypanel.Paint = function(self, w, h)
    surface.SetDrawColor(100,119,247)
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(95,104,201)
    surface.DrawOutlinedRect(0, 0, w, h,2)
    draw.SimpleTextOutlined(str, 'coursach_25',w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
    end
    local tabnot = NotifyPanel:GetItems()
    NotifyPanel:AddItem(notyfypanel) 

    
    

end

net.Receive("coursachnotify", function()
    NotifyCustom(net.ReadString())
end)

net.Receive("coursach_getlogs", function()
	history = net.ReadTable()
   makehistorymenu()

end)

net.Receive("coursach_getinv", function()
inventory = net.ReadTable()
makeinventorymenu()

end)

net.Receive("coursach_getrestaurants", function()
	restaurants = net.ReadTable()
makevidvidyvachmenu()
end)

net.Receive("coursach_gethalls", function()
	halls = net.ReadTable()
openmenuselhall()
end)

net.Receive("coursach_gethallstable", function()
	hallstable = net.ReadTable()
openmenuselhalltable()
end)

net.Receive("coursach_getrestaurantsdishes", function()
	dishes = net.ReadTable()
	dishestype = net.ReadTable()
openmenuseldishes()
end)


net.Receive("coursachp_getrestaurants", function()
	restaurants = net.ReadTable()
	makerestaurantgetmenu()
end)
