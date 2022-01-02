--Colores
--Color 1 ^1 Rojo
--Color 2 ^2 Verde
--Color 3 ^3 Amarillo

--Color 5 ^5 Azul
--Color 6 ^6 Morado
--Color 7 ^7 Gris
--Color 8 ^8 Naranja

--Mensajes Automaticos
local m = {}

m.prefix = '[SISTEMA] '


m.messages = {   
    'El uso inadecuado del chat conlleva una expulsion del servidor.',
    'Reporta cualquier bug en nuestro discord discord.gg/PeruRP',
    'Puedes visitar nuestras tiendas vips de la ciudad.',
    'Recuerda despues de hacer algun delito o alguna acción ilegal mandar /entorno',
    'Recuerda que para llamar a un ems pueder poner /auxilio',
    'Si tienes algun problema puedes mandar /report y un administrador te ayudara.'
}

local enableMessages = true
local timeout = 1000 * 60 * 15

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


--NoNPCDrop
local pedindex = {}

function SetWeaponDrops() -- This function will set the closest entity to you as the variable entity.
    local handle, ped = FindFirstPed()
    local finished = false -- FindNextPed will turn the first variable to false when it fails to find another ped in the index
    repeat 
        if not IsEntityDead(ped) then
                pedindex[ped] = {}
        end
        finished, ped = FindNextPed(handle) -- first param returns true while entities are found
    until not finished
    EndFindPed(handle)

    for peds,_ in pairs(pedindex) do
        if peds ~= nil then -- set all peds to not drop weapons on death.
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

--No Cops
Citizen.CreateThread(function()
	while true do
	Citizen.Wait(10)
	local playerPed = GetPlayerPed(-1)
	local playerLocalisation = GetEntityCoords(playerPed)
		ClearAreaOfCops(playerLocalisation.x, playerLocalisation.y, playerLocalisation.z, 4000.0)
	end
end)

--Rvoz
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

--NoWeaponDrop
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        DisablePlayerVehicleRewards(PlayerId())
    end
end)

Citizen.CreateThread(function()
    local minimap = RequestScaleformMovie("minimap")
    SetRadarBigmapEnabled(true, false)
    Wait(0)
    SetRadarBigmapEnabled(false, false)
    while true do
        Wait(0)
        BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
        ScaleformMovieMethodAddParamInt(3)
        EndScaleformMovieMethod()
    end
end)

--/conducir

local disableShuffle = true
function disableSeatShuffle(flag)
	disableShuffle = flag
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(250)
		if IsPedInAnyVehicle(GetPlayerPed(-1), false) and disableShuffle then
			if GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0) == GetPlayerPed(-1) then
				if GetIsTaskActive(GetPlayerPed(-1), 165) then
					SetPedIntoVehicle(GetPlayerPed(-1), GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
				end
			end
		end
	end
end)

RegisterNetEvent("SeatShuffle")
AddEventHandler("SeatShuffle", function()
	if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
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

--Señalar
local mp_pointing = false
local keyPressed = false

local function startPointing()
    local ped = GetPlayerPed(-1)
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
    local ped = GetPlayerPed(-1)
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
                local ped = GetPlayerPed(-1)
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


--Pause Title
function AddTextEntry(key, value)
	Citizen.InvokeNative(GetHashKey("ADD_TEXT_ENTRY"), key, value)
end

Citizen.CreateThread(function()
  AddTextEntry('FE_THDR_GTAO', 'PeruRP / discord.gg/PeruRP')
end)


--Agachate conoselo
local crouched = false

Citizen.CreateThread( function()
    while true do 
        Citizen.Wait( 1 )

        local ped = PlayerPedId()

        if ( DoesEntityExist( ped ) and not IsEntityDead( ped ) ) then 
            DisableControlAction( 0, 36, true ) -- INPUT_DUCK  

            if ( not IsPauseMenuActive() ) then 
                if ( IsDisabledControlJustPressed( 0, 36 ) ) then 
                    RequestAnimSet( "move_ped_crouched" )

                    while ( not HasAnimSetLoaded( "move_ped_crouched" ) ) do 
                        Citizen.Wait( 100 )
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
    --Comisaria { ['x'] = 453.9951, ['y'] = -995.6107, ['z'] = 10.15538},
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
-- Inem antiguo    { ['x'] = -244.92,  ['y'] = -991.82,   ['z'] = 10.29},
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

--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
----------------   Obtener su distancia de cualquiera de las ubicaciones --------------------------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

Citizen.CreateThread(function()
	while not NetworkIsPlayerActive(PlayerId()) do
		Citizen.Wait(0)
	end
	
	while true do
		local playerPed = GetPlayerPed(-1)
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
		Citizen.Wait(0)
		local player = GetPlayerPed(-1)
		local x,y,z = table.unpack(GetEntityCoords(player, true))
		local dist = Vdist(zones[closestZone].x, zones[closestZone].y, zones[closestZone].z, x, y, z)
	
		if dist <= 50.0 then  
			if not notifIn then																			 
				NetworkSetFriendlyFireOption(false)
				ClearPlayerWantedLevel(PlayerId())
				SetCurrentPedWeapon(player,GetHashKey("WEAPON_UNARMED"),true)
				TriggerEvent("pNotify:SendNotification",{
					text = "<b style='color:#1E90FF'>Estás en zona segura</b>",
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
					text = "<b style='color:#1E90FF'>Ya no estás en zona segura</b>",
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
					text = "<b style='color:#1E90FF'>No puedes usar armas en una zona segura</b>",
					type = "error",
					timeout = (3000),
					layout = "bottomright",
					queue = "global"
				})
			end
			if IsDisabledControlJustPressed(0, 106) then 
				SetCurrentPedWeapon(player,GetHashKey("WEAPON_UNARMED"),true) 
				TriggerEvent("pNotify:SendNotification",{
					text = "<b style='color:#1E90FF'>No puedes hacer eso en una zona segura</b>",
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
