local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- feijonts
-----------------------------------------------------------------------------------------------------------------------------------------
feijonts = {}
Tunnel.bindInterface("feijonts_prisao",feijonts)
funcaodocliente = Tunnel.getInterface('feijontscliente')
-----------------------------------------------------------------------------------------------------------------------------------------
-- WEBHOOK
-----------------------------------------------------------------------------------------------------------------------------------------
local webhookprisao = ""

function SendWebhookMessage(webhook,message)
	if webhook ~= nil and webhook ~= "" then
		PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({content = message}), { ['Content-Type'] = 'application/json' })
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PREPARE
-----------------------------------------------------------------------------------------------------------------------------------------
vRP.prepare('feijonts/inserir/pena','INSERT INTO feijonts_prisao (user_id, tempo) VALUES (@user_id, @tempo)')
vRP.prepare('feijons/select','SELECT * FROM feijonts_prisao WHERE user_id = @user_id')
vRP.prepare('feijons/update/tempo','UPDATE `feijonts_prisao SET tempo = @tempo WHERE  user_id = @user_id;')
vRP.prepare('feijonts/delete','DELETE FROM feijonts_prisao WHERE  user_id = @user_id')
-----------------------------------------------------------------------------------------------------------------------------------------
-- COMANDO
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('prisao', function(source,args)
    user_id = vRP.getUserId(source)
    local identity = vRP.getUserIdentity(user_id)
    if vRP.hasPermission(user_id,"policia.permissao") then
        texto1 = vRP.prompt(source, 'Insira o passaporte do bandido:', '')
        num = tonumber(texto1)
        if num then
            texto2 = vRP.prompt(source, 'Insira o tempo que bandido passará na cadeia:', '')
            num2 = tonumber(texto2)
            if num2 then
                texto3 = vRP.prompt(source, 'Insira o motivo da prisão do bandido:', '')
                if texto3 ~= '' then
                    texto4 = vRP.prompt(source, 'Insira um link da foto do bandido:', '')
                    if texto4 ~= '' and string.find( texto4,'http' ) then
                        nuser_id = num -- id do bandido
                        tempo = num2
                        motivo = texto3
                        foto = texto4
                        nsource = vRP.getUserSource(nuser_id)
                        dado = vRP.query('feijons/select',{user_id = nuser_id})
                        if #dado == 0 then
		                    vRPclient.setHandcuffed(player,false)
                            funcaodocliente.teleport(source)
                            vRP.execute('feijonts/inserir/pena'{user_id = nuser_id, tempo = tempo})
                            SendWebhookMessage(webhookprisao,"```prolog\n[POLICIAL]: "..user_id.." "..identity.name.." "..identity.firstname.." \n[PRENDEU:] "..nuser_id.." \n[TEMPO:] "..tempo.." \n[FOTO:] "..foto.." \n[HORARIO:] "..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r```")
                        else
                            TriggerClientEvent('Notify', source, 'negado','Negado','Esta pessoa já está presa!')
                        end
                        TriggerClientEvent('Notify', source, 'importante','Importante','Você prendeu o passaporte '..nuser_id..' por '..tempo..' meses!')
                        TriggerClientEvent('Notify', nsource, 'importante','Importante','Você foi preso por '..tempo..' meses!')
                    else
                        TriggerClientEvent('Notify', source, 'negado','Negado','Você não digitou corretamente!')
                    end
                else
                    TriggerClientEvent('Notify', source, 'negado','Negado','Você não digitou corretamente!')
                end
            else
                TriggerClientEvent('Notify', source, 'negado','Negado','Você não digitou corretamente!')
            end
        else
            TriggerClientEvent('Notify', source, 'negado','Negado','Você não digitou corretamente!')
        end
    else
        TriggerClientEvent('Notify', source, 'negado','Negado','Você não é um policial!')
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNÇÃO
-----------------------------------------------------------------------------------------------------------------------------------------
feijonts.diminuirpena = function()
    local source = source
    local user_id = vRP.getUserId(source)
    local dado = vRP.query('feijons/select',{user_id = user_id})
    tempoatual = dado[1].tempo
    if tempoatual == 1 then
        vRP.execute('feijonts/delete',{user_id = user_id})
        TriggerClientEvent('Notify',source,'aviso','Aviso','Sua pena acabou e voce foi liberado!')
        funcaodocliente.liberdade(source)
    else
        vRP.execute('feijons/update/tempo',{tempo = tonumber(tempoatual)-1, user_id = user_id})
        TriggerClientEvent('Notify',source,'aviso','Aviso','Sua pena foi redusida em 1 mês! Sua pena atual é de '..tempoatual..'')
    end
end

function feijonts.fuga()
    local source = source
    local user_id = vRP.getUserId(source)
    tempoatual = dado[1].tempo
    vRP.execute('feijons/update/tempo',{tempo = tonumber(tempoatual)+5, user_id = user_id})
    TriggerClientEvent('Notify',source,'aviso','Aviso','Sua pena foi aumentada em 5 meses por fuga! Sua pena atual é de '..tempoatual..'')
end

AddEventHandler('vRP:playerSpwan', function(user_id,source)
    dado = vRP.query('feijons/select',{user_id = nuser_id})
    if #dado == 0 then
        funcaodocliente.teleport(source)
        TriggerClientEvent('Notify',source,'Você saiu do servidor sem terminar sua pena! Então você voltará para a prisão para termina-la!')
    end
end)