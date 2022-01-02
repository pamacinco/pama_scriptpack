--Colores
--Color 1 ^1 Rojo
--Color 2 ^2 Verde
--Color 3 ^3 Amarillo

--Color 5 ^5 Azul
--Color 6 ^6 Morado
--Color 7 ^7 Gris
--Color 8 ^8 Naranja

local m = {}

-- SISTEMA DE MENSAJES EN EL CHAT

m.prefix = '[SISTEMA] ' -- PREFIJO DE LOS MENSAJES


m.messages = {   
    'El uso inadecuado del chat conlleva una expulsion del servidor.', -- MENSAJES
    'Reporta cualquier bug en nuestro discord discord.gg/PeruRP',  -- MENSAJES
    'Puedes visitar nuestras tiendas vips de la ciudad.',  -- MENSAJES
    'Recuerda despues de hacer algun delito o alguna acción ilegal mandar /entorno',  -- MENSAJES
    'Recuerda que para llamar a un ems pueder poner /auxilio',  -- MENSAJES
    'Si tienes algun problema puedes mandar /report y un administrador te ayudara.' -- MENSAJES
   --'Mensaje.'  
   --'Mensaje.'  
   --'Mensaje.'  
}

local enableMessages = true -- MANTENER EN TRUE PARA QUE MANDE LOS MENSAJES
local timeout = 1000 * 60 * 15 -- TIEMPO EN MANDARSE CADA MENSAJE

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        for i in pairs(m.messages) do
            if enableMessages then
                chat(i)
            end
            Citizen.Wait(timeout)
        end
    end
end)

function chat(i)
    TriggerEvent('chat:addMessage', { args = { m.prefix, m.messages[i] }, color = {255, 0, 0} })
end


-- LOS NPCs NO DROPEAN ARMAS
local pedindex = {}

function SetWeaponDrops() -- 
    local handle, ped = FindFirstPed()
    local finished = false -- 
    repeat 
        if not IsEntityDead(ped) then
                pedindex[ped] = {}
        end
        finished, ped = FindNextPed(handle) 
    until not finished
    EndFindPed(handle)

    for peds,_ in pairs(pedindex) do
        if peds ~= nil then 
            SetPedDropsWeaponsWhenDead(peds, false) 
        end
    end
end


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(12000)
        SetWeaponDrops()
    end
end)

--No Policias
Citizen.CreateThread(function()
	while true do
	Citizen.Wait(10)
	local playerPed = PlayerPedId()
	local playerLocalisation = GetEntityCoords(playerPed)
		ClearAreaOfCops(playerLocalisation.x, playerLocalisation.y, playerLocalisation.z, 4000.0)
	end
end)

--Rvoz Comando para que se te reinicie la voz (es necesario usar mumble-voip)
Citizen.CreateThread(function()
    while ESX == nil do
  TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
  Citizen.Wait(0)
    end
end)

RegisterCommand('rvoz', function()
  NetworkClearVoiceChannel()
  NetworkSessionVoiceLeave()
  Wait(50)
  NetworkSetVoiceActive(false)
  MumbleClearVoiceTarget(2)
  Wait(1000)
  MumbleSetVoiceTarget(2)
  NetworkSetVoiceActive(true)
  ESX.ShowNotification('Chat de voz reiniciado.')
end)

RegisterCommand('resetearvoz', function()
  NetworkClearVoiceChannel()
  NetworkSessionVoiceLeave()
  Wait(50)
  NetworkSetVoiceActive(false)
  MumbleClearVoiceTarget(2)
  Wait(1000)
  MumbleSetVoiceTarget(2)
  NetworkSetVoiceActive(true)
  ESX.ShowNotification('Chat de voz reiniciado.')
end)

--Comando /conducir para cambiar de asiento

local disableShuffle = true
function disableSeatShuffle(flag)
	disableShuffle = flag
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5000)
		if IsPedInAnyVehicle(PlayerPedId(), false) and disableShuffle then
			if GetPedInVehicleSeat(GetVehiclePedIsIn(PlayerPedId(), false), 0) == PlayerPedId() then
				if GetIsTaskActive(PlayerPedId(), 165) then
					SetPedIntoVehicle(PlayerPedId(), GetVehiclePedIsIn(PlayerPedId(), false), 0)
				end
			end
		end
	end
end)

RegisterNetEvent("SeatShuffle")
AddEventHandler("SeatShuffle", function()
	if IsPedInAnyVehicle(PlayerPedId(), false) then
		disableSeatShuffle(false)
		Citizen.Wait(5000)
		disableSeatShuffle(true)
	else
		CancelEvent()
	end
end)

RegisterCommand("conducir", function(source, args, raw) --AQUI PUEDES CAMBIAR EL COMANDO
    TriggerEvent("SeatShuffle")
end, false) --DEBE ESTAR EN FALSO PARA QUE TODO EL MUNDO PUEDA HACERLO

--Señalar Con La B
local mp_pointing = false
local keyPressed = false

local function startPointing()
    local ped = PlayerPedId()
    RequestAnimDict("anim@mp_point")
    while not HasAnimDictLoaded("anim@mp_point") do
        Wait(150)
    end
    SetPedCurrentWeaponVisible(ped, 0, 1, 1, 1)
    SetPedConfigFlag(ped, 36, 1)
    Citizen.InvokeNative(0x2D537BA194896636, ped, "task_mp_pointing", 0.5, 0, "anim@mp_point", 24)
    RemoveAnimDict("anim@mp_point")
end

local function stopPointing()
    local ped = PlayerPedId()
    Citizen.InvokeNative(0xD01015C7316AE176, ped, "Stop")
    if not IsPedInjured(ped) then
        ClearPedSecondaryTask(ped)
    end
    if not IsPedInAnyVehicle(ped, 1) then
        SetPedCurrentWeaponVisible(ped, 1, 1, 1, 1)
    end
    SetPedConfigFlag(ped, 36, 0)
    ClearPedSecondaryTask(PlayerPedId())
end

local once = true
local oldval = false
local oldvalped = false

Citizen.CreateThread(function()
    while true do
        Wait(100)

        if once then
            once = false
        end

        if not keyPressed then
            if IsControlPressed(0, 29) and not mp_pointing and IsPedOnFoot(PlayerPedId()) then
                Wait(200)
                if not IsControlPressed(0, 29) then
                    keyPressed = true
                    startPointing()
                    mp_pointing = true
                else
                    keyPressed = true
                    while IsControlPressed(0, 29) do
                        Wait(200)
                    end
                end
            elseif (IsControlPressed(0, 29) and mp_pointing) or (not IsPedOnFoot(PlayerPedId()) and mp_pointing) then
                keyPressed = true
                mp_pointing = false
                stopPointing()
            end
        end

        if keyPressed then
            if not IsControlPressed(0, 29) then
                keyPressed = false
            end
        end
        if Citizen.InvokeNative(0x921CE12C489C4C41, PlayerPedId()) and not mp_pointing then
            stopPointing()
        end
        if Citizen.InvokeNative(0x921CE12C489C4C41, PlayerPedId()) then
            if not IsPedOnFoot(PlayerPedId()) then
                stopPointing()
            else
                local ped = PlayerPedId()
                local camPitch = GetGameplayCamRelativePitch()
                if camPitch < -70.0 then
                    camPitch = -70.0
                elseif camPitch > 42.0 then
                    camPitch = 42.0
                end
                camPitch = (camPitch + 70.0) / 112.0

                local camHeading = GetGameplayCamRelativeHeading()
                local cosCamHeading = Cos(camHeading)
                local sinCamHeading = Sin(camHeading)
                if camHeading < -180.0 then
                    camHeading = -180.0
                elseif camHeading > 180.0 then
                    camHeading = 180.0
                end
                camHeading = (camHeading + 180.0) / 360.0

                local blocked = 0
                local nn = 0

                local coords = GetOffsetFromEntityInWorldCoords(ped, (cosCamHeading * -0.2) - (sinCamHeading * (0.4 * camHeading + 0.3)), (sinCamHeading * -0.2) + (cosCamHeading * (0.4 * camHeading + 0.3)), 0.6)
                local ray = Cast_3dRayPointToPoint(coords.x, coords.y, coords.z - 0.2, coords.x, coords.y, coords.z + 0.2, 0.4, 95, ped, 7);
                nn,blocked,coords,coords = GetRaycastResult(ray)

                Citizen.InvokeNative(0xD5BB4025AE449A4E, ped, "Pitch", camPitch)
                Citizen.InvokeNative(0xD5BB4025AE449A4E, ped, "Heading", camHeading * -1.0 + 1.0)
                Citizen.InvokeNative(0xB0A6CFD2C69C1088, ped, "isBlocked", blocked)
                Citizen.InvokeNative(0xB0A6CFD2C69C1088, ped, "isFirstPerson", Citizen.InvokeNative(0xEE778F8C7E1142E2, Citizen.InvokeNative(0x19CAFA3C87F7C2FF)) == 4)

            end
        end
    end
end)


-- Titulo del menu del escape
function AddTextEntry(key, value)
	Citizen.InvokeNative(GetHashKey("ADD_TEXT_ENTRY"), key, value)
end

Citizen.CreateThread(function()
  AddTextEntry('FE_THDR_GTAO', 'Pama_scriptpack / discord.gg/FC6fkmrpuZ')
end)


-- Agacharte con el control
local crouched = false

Citizen.CreateThread( function()
    while true do 
        Citizen.Wait( 2000 )

        local ped = PlayerPedId()

        if ( DoesEntityExist( ped ) and not IsEntityDead( ped ) ) then 
            DisableControlAction( 0, 36, true ) -- INPUT_DUCK  

            if ( not IsPauseMenuActive() ) then 
                if ( IsDisabledControlJustPressed( 0, 36 ) ) then 
                    RequestAnimSet( "move_ped_crouched" )

                    while ( not HasAnimSetLoaded( "move_ped_crouched" ) ) do 
                        Citizen.Wait( 2000 )
                    end 

                    if ( crouched == true ) then 
                        ResetPedMovementClipset( ped, 0 )
                        crouched = false 
                    elseif ( crouched == false ) then
                        SetPedMovementClipset( ped, "move_ped_crouched", 0.25 )
                        crouched = true 
                    end 
                end
            end 
        end 
    end
end )

--Densidad de NPCS
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0) -- prevent crashing

		-- These natives have to be called every frame.
		SetVehicleDensityMultiplierThisFrame(0.1) -- set traffic density to 0 
		SetPedDensityMultiplierThisFrame(0.4) -- set npc/ai peds density to 0
		SetRandomVehicleDensityMultiplierThisFrame(0.1) -- set random vehicles (car scenarios / cars driving off from a parking spot etc.) to 0
		SetParkedVehicleDensityMultiplierThisFrame(0.0) -- set random parked vehicles (parked car scenarios) to 0
		SetScenarioPedDensityMultiplierThisFrame(0.0, 0.0) -- set random npc/ai peds or scenario peds to 0
		SetGarbageTrucks(false) -- Stop garbage trucks from randomly spawning
		SetRandomBoats(false) -- Stop random boats from spawning in the water.
		SetCreateRandomCops(false) -- disable random cops walking/driving around.
		SetCreateRandomCopsNotOnScenarios(false) -- stop random cops (not in a scenario) from spawning.
		SetCreateRandomCopsOnScenarios(false) -- stop random cops (in a scenario) from spawning.
		
		local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
		ClearAreaOfVehicles(x, y, z, 1000, false, false, false, false, false)
		RemoveVehiclesFromGeneratorsInArea(x - 500.0, y - 500.0, z - 500.0, x + 500.0, y + 500.0, z + 500.0);
	end
end)



-- ZONAS SEGURAS


-- Localizaciones.
local zones = {
	{ ['x'] = 235.3704, ['y'] = -775.2965, ['z'] = 10.08123},
    { ['x'] = 453.9951, ['y'] = -995.6107, ['z'] = 10.15538},
    { ['x'] = 205.72,   ['y'] = -848.32,   ['z'] = 10.47},
    { ['x'] = 1642.58,  ['y'] = 2570.93,   ['z'] = 40.56},
    { ['x'] = 126.56,   ['y'] = -1071.24,  ['z'] = 20.19},
    { ['x'] = -318.7,   ['y'] = -849.3,    ['z'] = 20.07},
    { ['x'] = 1857.53,  ['y'] = 2585.82,   ['z'] = 40.67},
    { ['x'] = 190.84,   ['y'] = -893.2,    ['z'] = 10.12},
    { ['x'] = 166.26,   ['y'] = -951.92,   ['z'] = 10.09},
    { ['x'] = 155.17,   ['y'] = -1024.33,  ['z'] = 10.39},
    { ['x'] = -40.87,   ['y'] = -1099.64,  ['z'] = 10.42},
    { ['x'] = -63.15,   ['y'] = -1118.43,  ['z'] = 10.43},
    { ['x'] = 266.83,   ['y'] = -959.48,   ['z'] = 10.22},
    { ['x'] = -244.92,  ['y'] = -991.82,   ['z'] = 10.29},
    { ['x'] = 1730.84,  ['y'] =  3714.95,  ['z'] = 10.14},
    { ['x'] = 902.66,   ['y'] = -176.83,   ['z'] = 10.19},
    { ['x'] = -797.25,  ['y'] = -221.13,   ['z'] = 10.08},
    { ['x'] = -200.93,  ['y'] =  6225.11,  ['z'] = 10.49},
    { ['x'] = 296.73,   ['y'] = -583.29,   ['z'] = 1.0},
    { ['x'] = 1641,666, ['y'] = 2570.836,  ['z'] = 10.55676},
	{ ['x'] = 310.56, ['y'] = -1424.38,  ['z'] = 10.51},
	{ ['x'] = 357.53, ['y'] = -1408.83,  ['z'] = 10.51},
	{ ['x'] = -540.98, ['y'] = -210.97,  ['z'] = 10.51},
}

local notifIn = false
local notifOut = false
local closestZone = 1

-- Es Necesario Usar pNotify si no quieres modificar el script

Citizen.CreateThread(function()
	while not NetworkIsPlayerActive(PlayerId()) do
		Citizen.Wait(4000)
	end
	
	while true do
		local playerPed = PlayerPedId()
		local x, y, z = table.unpack(GetEntityCoords(playerPed, true))
		local minDistance = 100000
		for i = 1, #zones, 1 do
			dist = Vdist(zones[i].x, zones[i].y, zones[i].z, x, y, z)
			if dist < minDistance then
				minDistance = dist
				closestZone = i
			end
		end
		Citizen.Wait(15000)
	end
end)


Citizen.CreateThread(function()
	while not NetworkIsPlayerActive(PlayerId()) do
		Citizen.Wait(0)
	end
	
	while true do
		Citizen.Wait(4000)
		local player = PlayerPedId()
		local x,y,z = table.unpack(GetEntityCoords(player, true))
		local dist = Vdist(zones[closestZone].x, zones[closestZone].y, zones[closestZone].z, x, y, z)
	
		if dist <= 50.0 then  
			if not notifIn then																			 
				NetworkSetFriendlyFireOption(false)
				ClearPlayerWantedLevel(PlayerId())
				SetCurrentPedWeapon(player,GetHashKey("WEAPON_UNARMED"),true)
				TriggerEvent("pNotify:SendNotification",{
					text = "<b style='color:#1E90FF'>Estás en zona segura</b>", -- NOTIFICACCIÓN
					type = "success",
					timeout = (3000),
					layout = "bottomright",
					queue = "global"
				})
				notifIn = true
				notifOut = false
			end
		else
			if not notifOut then
				NetworkSetFriendlyFireOption(true)
				TriggerEvent("pNotify:SendNotification",{
					text = "<b style='color:#1E90FF'>Ya no estás en zona segura</b>", -- NOTIFICACCIÓN
					type = "error",
					timeout = (3000),
					layout = "bottomright",
					queue = "global"
				})
				notifOut = true
				notifIn = false
			end
		end
		if notifIn then
		DisableControlAction(2, 37, true) 
		DisablePlayerFiring(player,true) 
      	DisableControlAction(0, 106, true) 
			if IsDisabledControlJustPressed(2, 37) then 
				SetCurrentPedWeapon(player,GetHashKey("WEAPON_UNARMED"),true) 
				TriggerEvent("pNotify:SendNotification",{
					text = "<b style='color:#1E90FF'>No puedes usar armas en una zona segura</b>", -- NOTIFICACCIÓN
					type = "error",
					timeout = (3000),
					layout = "bottomright",
					queue = "global"
				})
			end
			if IsDisabledControlJustPressed(0, 106) then 
				SetCurrentPedWeapon(player,GetHashKey("WEAPON_UNARMED"),true) 
				TriggerEvent("pNotify:SendNotification",{
					text = "<b style='color:#1E90FF'>No puedes hacer eso en una zona segura</b>", -- NOTIFICACCIÓN
					type = "error",
					timeout = (3000),
					layout = "bottomright",
					queue = "global"
				})
			end
		end

	 	if DoesEntityExist(player) then	     
	 		DrawMarker(1, zones[closestZone].x, zones[closestZone].y, zones[closestZone].z-1.0001, 0, 0, 0, 0, 0, 0, 100.0, 100.0, 2.0, 13, 232, 255, 155, 0, 0, 2, 0, 0, 0, 0) 
	 	end
	end
end)


--/Limpiar comando que limpia el coche

RegisterCommand('limpiar',function(source,args,rawCommand,text)
    --Mensajes
    TriggerEvent("chatMessage", "[Limpieza]", {131, 0, 255}, 'Limpiandose tu coche') --Mensaje Chat
    print("Limpiando la suciedad") --Print en el F8 (lo puedes quitar)
        --Funciones
        WashDecalsFromVehicle(GetVehiclePedIsUsing(PlayerPedId()), 0.0)
        SetVehicleDirtLevel(GetVehiclePedIsUsing(PlayerPedId()))
end) 


-- Cuando te subas a una moto no se te ponga casco automáticamente 

Citizen.CreateThread( function()
    SetPedHelmet(PlayerPedId(), false)
    
        while true do
            Citizen.Wait(900000)        
            local playerPed = PlayerPedId()
            local playerVeh = GetVehiclePedIsUsing(playerPed)
    
            if gPlayerVeh ~= 30000 then RemovePedHelmet(playerPed,true) end
        end
        
    end)