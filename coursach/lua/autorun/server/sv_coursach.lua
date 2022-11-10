include("autorun/sh_coursach.lua")
include("cfg_server.lua")
print("sv coursach podgruzilsa")

require("tmysql4")
local Database, error = tmysql.Connect("localhost", "root", "", "coursach", 3306, nil, CLIENT_MULTI_STATEMENTS)

if error then
print([[+----------------------------------+
| Ошибка Coursach Mysql не подключен! |
+----------------------------------+
]])
end
print("BD oKEY")
util.AddNetworkString("coursach_getrestaurantsdishes")
util.AddNetworkString("coursach_gethallstable")
util.AddNetworkString("coursach_gethalls")
util.AddNetworkString("coursach_getrestaurants")
util.AddNetworkString("coursach_getdishes")
util.AddNetworkString("coursach_addorder")
util.AddNetworkString("coursach_removeorder")
util.AddNetworkString("coursach_sendorder")
util.AddNetworkString("coursachnopen")

util.AddNetworkString("coursachp_getrestaurants")
local orderid = 0
local halltableid = 0


net.Receive("coursachp_getrestaurants",function(len,ply)
    Database:Query( "SELECT * FROM `restaurant`;", function(tbl12)
                net.Start("coursachp_getrestaurants")
                net.WriteTable(tbl12[1].data)
                net.Send(ply)
    end)
end)


net.Receive("coursach_sendorder",function(len,ply)
    if orderid == 0 then return end
local price = 0

Database:Query( "SELECT * FROM `dishorder` WHERE MainOrderID = '".. orderid .."';",function(tbl) 
         Database:Query( "SELECT * FROM `dish`;", function(tbl12)
            for d,g in pairs (tbl12[1].data) do
                for k,v in pairs(tbl[1].data) do
                    if g.DishID == v.DishID then
                        price = price + (v.Amount * g.Price)
                    end
                end
            end
            print(orderid, price)
                Database:Query( "UPDATE `mainorder` SET `Sum` = '"..price.."' WHERE OrderID = '"..orderid.."'",function(tblaa)end)
        end)
        
    end) 

end)


function sendorderdsihes(ply)
    Database:Query( "SELECT * FROM `dishorder` WHERE MainOrderID = '".. orderid .."';",function(tbl) 
            net.Start("coursach_addorder")
            net.WriteTable(tbl[1].data)
            net.Send(ply)
    end)
end

net.Receive("coursach_removeorder",function(len,ply)
local dishorderid = net.ReadInt(32)
    Database:Query( "SELECT * FROM `dishorder` WHERE DishOrderID = '".. dishorderid .."';",function(tbl) 
        if tbl[1].affected == 1 then
            if tbl[1].data[1].Amount == 1 then
                Database:Query( "DELETE FROM dishorder WHERE `dishorder`.`DishOrderID` = '".. dishorderid .."';",function(tbl) 
                    sendorderdsihes(ply)
                end) 
            else
                Database:Query( "UPDATE `dishorder` SET `Amount` = `Amount` - 1 WHERE DishOrderID = '"..dishorderid.."'",function(tblaa)  
                    sendorderdsihes(ply)
                end)
            end
        end
    end)
end)


net.Receive("coursach_addorder", function(len, ply)
    local dishid = net.ReadInt(3)
        if orderid == 0 then
            Database:Query( "INSERT INTO `mainorder` (`OrderID`, `Date`, `Sum`, `HallTableID`, `WorkerID`) VALUES (NULL, CURDATE(), '0', '"..halltableid.."', NULL);",function(tbld) 
                Database:Query( "SELECT max(`OrderID`) AS ordid FROM `mainorder`;", function(tbl12)
                    sendorderdsihes(ply)
                    orderid = tbl12[1].data[1].ordid
                end)
            end)
        end
        Database:Query( "SELECT * FROM `dishorder` WHERE MainOrderID = '".. orderid .."' AND DishID = '"..dishid.."';",function(tbl) 
            if tbl[1].affected == 0 then
                    Database:Query( "INSERT INTO `dishorder` (`DishOrderID`, `Amount`, `DishID`, `MainOrderID`) VALUES (NULL, '1', '"..dishid.."', '"..orderid.."');",function(tbla) 
sendorderdsihes(ply)
                     end) 
            else
                Database:Query( "UPDATE `dishorder` SET `Amount` = `Amount` + 1 WHERE MainOrderID = '".. orderid .."' AND DishID = '"..dishid.."'",function(tblaa)  
sendorderdsihes(ply)
            end)
            end


         end)
end)

net.Receive('coursach_getrestaurants', function(len, ply)
    Database:Query( "SELECT * FROM `restaurant`;", function(tbl12)
        net.Start("coursach_getrestaurants")
        net.WriteTable(tbl12[1].data)
        net.Send(ply)
    end)
end)

net.Receive('coursach_gethalls', function(len, ply)
    local restid = net.ReadInt(3)
    Database:Query( "SELECT * FROM `hall` WHERE RestaurantID = ".. restid ..";", function(tbl12)
        net.Start("coursach_gethalls")
        net.WriteTable(tbl12[1].data)
        net.Send(ply)
    end)
end)

net.Receive('coursach_gethallstable', function(len, ply)
    local hallid = net.ReadInt(3)
    Database:Query( "SELECT * FROM `halltable` WHERE HallID = ".. hallid ..";", function(tbl12)
        net.Start("coursach_gethallstable")
        net.WriteTable(tbl12[1].data)
        net.Send(ply)
    end)
end)

net.Receive('coursach_getrestaurantsdishes', function(len, ply)
    local tableid = net.ReadInt(3)
    halltableid = tableid
    Database:Query( "SELECT * FROM `dish`;", function(tbl12)
        Database:Query( "SELECT * FROM `dishtype`;", function(tbl11)
                net.Start("coursach_getrestaurantsdishes")
                net.WriteTable(tbl12[1].data)
                net.WriteTable(tbl11[1].data)
                net.Send(ply)
            end)
       
    end)
end)




hook.Add( "PlayerButtonDown", "OpencoursachMenu", function( ply, button )

    if button == KEY_F6 then
        net.Start("coursachnopen")
        net.Send(ply)
    end

end)

concommand.Add("coursach", function( ply, cmd, args )
    orderid = 0
    halltableid = 0
net.Start("coursachnopen")
        net.Send(ply)
end)
