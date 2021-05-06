local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
feijonts = Tunnel.getInterface("feijonts_prisao",feijonts)
funcoestabela = {}
Tunnel.bindInterface('feijontscliente',funcoestabela)

ped = PlayerPedId()

IsPreso = false


funcoestabela.teleport = function()
    DoScreenFadeOut(1000)
    Wait(1000)
    SetEntityCoords(ped,1680.1,2513.0,45.5)
    DoScreenFadeIn(1000)
end

CreateThread(function()
    repeat
        Wait(60*1000)
        if IsPreso then
            feijonts.diminuirpena()
        end
    until false
end)

CreateThread(function()
    repeat
        Wait(5000)
        if IsPreso then
            distance = GetDistanceBetweenCoords(GetEntityCoords(ped,1680.1,2513.0,45.5))
            if distance > 210 then
                feijons.fuga()
                DoScreenFadeOut(1000)
                Wait(1000)
                SetEntityCoords(ped,1680.1,2513.0,45.5)
                DoScreenFadeIn(1000)
            end
            if GetEntityHealth(ped) <= 101 then
                SetEntityHealth(ped, 150)
            end
        end
    until false
end)

funcoestabela.liberdade = function()
    DoScreenFadeOut(1000)
    Wait(1000)
    SetEntityCoords(ped,1680.1,2513.0,45.5)
    DoScreenFadeIn(1000)
    IsPreso = false
end