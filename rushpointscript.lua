local UserInputService = game:GetService("UserInputService")
while game.GameId == 0 do task.wait() end
if game.GameId ~= 2162282815 then return end
local MAX_FOV = 200
local function RejoinSameInstance()
    game:GetService("TeleportService")
        :TeleportToPlaceInstance(game.PlaceId, game.JobId, game:GetService("Players").LocalPlayer)
end
local err_conn = game:GetService("ScriptContext").Error:Connect(function(message, stackTrace, source)
    if source == script and not __AHLOADED then
        (messagebox or warn)("IF YOU ARE NOT USING SYN, DO NOT REPORT THIS ERROR.\nIF YOU ARE NOT USING SYN I DO NOT CARE!\n"
            .. tostring(message) .. "\n" .. tostring(stackTrace), "LISTEN UP", 0)
    end
end)
--// On-screen logging
local ScreenLog, LogType do
    local activelabels = 0
    local function drawLabel(text, pos, color)
        local txt = Drawing.new("Text")
        txt.Visible = false
        local txtstart = pos
        txt.Position = txtstart
        txt.Text = text
        txt.Center = true
        txt.Size = 20
        txt.Color = color or Color3.new(1, 1, 1)
        txt.ZIndex = 6
        txt.Font = Drawing.Fonts.Monospace
        local bounds = txt.TextBounds
        local bg = Drawing.new("Square")
        bg.Visible = false
        bg.Filled = true
        local bgstart = pos - Vector2.new(bounds.X / 2 + 5, 0)
        bg.Position = bgstart
        bg.Size = bounds + Vector2.new(10, 0)
        bg.Transparency = 0.15
        bg.Color = Color3.new(0.1, 0.1, 0.1)
        txt.ZIndex = 2
        local idx = activelabels
        activelabels = activelabels + 1
        local conn = game:GetService("RunService").Heartbeat:Connect(function()
            txt.Visible = true
            bg.Visible = true
            local offset = Vector2.new(0, math.clamp(20 * (activelabels - idx), 20, 10000))
            txt.Position = txtstart - offset
            bg.Position = bgstart - offset
        end)
        task.delay(5, function()
            for i=1,0,-0.01 do
                txt.Transparency = i
                bg.Transparency = i * 0.15
                task.wait()
            end
            conn:Disconnect()
            activelabels = activelabels - 1
            txt:Remove()
            bg:Remove()
        end)
    end
    LogType = { ["Output"] = Color3.new(1, 1, 1), ["Info"] = Color3.new(0, 0.5, 1), ["Warn"] = Color3.new(1, 0.5, 0),
                ["Error"] = Color3.new(1, 0.1, 0.1), ["Ok"] = Color3.new(0.4, 0.7, 0.4), ["Debug"] = Color3.new(0.7, 0, 0.7) }
    function ScreenLog(color, ...)
        local viewport = workspace.CurrentCamera.ViewportSize
        local startpos = (viewport / 2) - Vector2.new(0, viewport.Y / 3)
        local m = ""
        for _, msg in ipairs({...}) do
            m = m .. " " .. tostring(msg)
        end
        drawLabel(string.sub(m, 2), startpos, color or Color3.new(1, 1, 1))
    end
end
----------------------- ANTICHEAT BYPASSSSSSSSSSSSSSSSS
local OldSpawn
local nilfunc = function()
    task.wait(10e3 ^ 2)
end
local function SpawnHook(f, ...)
    local caller = tostring((getcallingscript() or {}).Name)
    local finfo = debug.getinfo(4)
    if string.match(finfo.source, "AntiCheat_Local$")
    or string.match(caller, "^[%s+]*$")
    or string.match(caller, "^_$")
    or string.match(caller, "LocalScript$")
    then
        pcall(debug, "thread blocked:", f)
        hookfunction(finfo.func, nilfunc)
        return OldSpawn(nilfunc)
    end
    return OldSpawn(f, ...)
end
OldSpawn = hookfunction(getrenv().spawn, function(...)
    return SpawnHook(...)
end)
local acbp do
    local function scrape_gc_for_blacklist(blacklist)
        local bad_funcs = {}
        for _, func in pairs(getgc(true)) do
            if type(func) == "function"
            and islclosure(func)
            and not is_synapse_function(func)
            then
                for _, const in pairs(debug.getconstants(func)) do
                    for _, b in pairs(blacklist) do
                        if string.match(tostring(const), b) then
                            table.insert(bad_funcs, func)
                        end
                    end
                end
            end
        end
        return bad_funcs
    end
    local already_scraped = {}
    local function scrape(func)
        if already_scraped[func] then return end
        for i, const in pairs(debug.getconstants(func)) do
            if const == "spawn" then
                debug.setconstant(func, i, "getfenv")
                pcall(debug, "hook upv#" .. tostring(i), "on", func)
            end
        end
        for i, up in pairs(debug.getupvalues(func)) do
            if type(up) == "function" then
                pcall(scrape, up)
            end
        end
        for i, proto in pairs(debug.getprotos(func)) do
            pcall(scrape, proto)
        end
        already_scraped[func] = true
    end
    function acbp()
        local did_a_success = false
        for _, fuck_bye in pairs(scrape_gc_for_blacklist({ "Funny little blue man :zzz:",
            "Bye...#0001 was here", "rconsoleprint", "rconsoleclear", "rconsolename", "loadstring" }))
        do
            local realTable
            for _, up in pairs(debug.getupvalues(fuck_bye)) do
                if type(up) == "table"
                and rawget(up, "FireBullet")
                then
                    -- goodBYE anticheat :3
                    realTable = up
                    did_a_success = true
                    break
                end
            end
            if realTable then
                hookfunction(fuck_bye, function(...)
                    local _, idx = ...
                    return realTable[idx]
                end)
            end
        end
        --for _, func in pairs(getgc(true)) do
        --    if type(func) == "function"
        --    and islclosure(func)
        --    and not is_synapse_function(func)
        --    then
        --        local finfo = debug.getinfo(func)
        --        local source = finfo and finfo.source
        --        local name = finfo and finfo.name
        --        if finfo
        --            and name
        --            and (string.match(source, "_$")
        --            or string.match(source, "AntiCheat_Local$"))
        --        then
        --            scrape(func)
        --        end
        --    end
        --end
        return did_a_success
    end
end
acbp()
----------------------------------------------------------------
--local success, msg = xpcall(function()
    local doGhosting = false
    local rainbow_color = Color3.new(1, 1, 1)
    local tracers = {}
    local esp_names = {}
    local tryingToKill, killfeed = {}, {}

    local DbgTxt = Drawing.new("Text")
    DbgTxt.Visible = false
    DbgTxt.ZIndex = 999999
    DbgTxt.Size = 32
    DbgTxt.Outline = true
    DbgTxt.Color = Color3.new(1, 1, 1)

    if __AHLOADED then return end
    if not syn then (messagebox or print)("Your exploit is not supported", "Exploit not supported", 0) end

    local o = {} -- options
    loadstring(game:HttpGet("https://hub.afo.xyz/include/logging.lua"))()
    clear()
    title("AfoHub - Loading")
    printwelcome()
    info("Loading AfoHub...")

    local function WaitForService(serv)
        repeat task.wait() until game:GetService(serv)
        return game:GetService(serv)
    end
    local function WaitForProp(self, prop)
        repeat task.wait() until self[prop] ~= nil
        return self[prop]
    end

    info("Getting ui library")
    local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/enklareW/cuteware.shit/main/rushpointlibrary", true))()
    repeat task.wait() until WaitForProp(WaitForService("Players"), "LocalPlayer")
    info("Getting replicatedstorage")
    local replicatedstorage = WaitForService("ReplicatedStorage")
    info("Getting httpservice")
    local httpservice = WaitForService("HttpService")
    info("Getting players")
    local players = WaitForService("Players")
    info("Getting runservice")
    local runservice = WaitForService("RunService")
    info("Getting lighting")
    local lighting = WaitForService("Lighting")
    info("Getting localplayer")
    local localplayer = WaitForProp(players, "LocalPlayer")

    repeat task.wait() until WaitForProp(players, "MaxPlayers") ~= 0
    local isInLobby = WaitForProp(players, "MaxPlayers") == 1 or game.PlaceId == 5993942214
    if isInLobby then
        title("AfoHub - In the lobby")
        info("You are in the lobby :D")
        --// lobby script
        warn("TODO: menu support")
        coroutine.wrap(function()
            local menu = localplayer:WaitForChild("PlayerGui"):WaitForChild("Menu")
            while task.wait(.5) do
                menu:WaitForChild("TransitionScreen").Visible = false
                menu:WaitForChild("MainMenu").Visible = true
            end
        end)()
        return
    end

    --local oldDbgInfo
    --oldDbgInfo = hookfunction(getrenv().debug.info, function(...)
    --    return newcclosure(function(...)
    --        warn(debug.getinfo(5).short_src)
    --        return oldDbgInfo(...)
    --    end)(...)
    --end)

    info("Getting characters")
    local mapFolder = workspace:WaitForChild("MapFolder")
    local characters = mapFolder:WaitForChild("Players")
    local gameStats = mapFolder:WaitForChild("GameStats")
    local gameMode = gameStats:WaitForChild("GameMode")
    local isDeathmatch = function()
        return gameMode.Value == "Deathmatch"
    end
    local function IsTeamMate(player)
        if not isDeathmatch() and player:FindFirstChild("SelectedTeam") and localplayer:FindFirstChild("SelectedTeam") then
            return (player.SelectedTeam.Value == localplayer.SelectedTeam.Value)
        end
        return false
    end
    --info("Getting camera")
    --local camera = WaitForProp(workspace, "CurrentCamera")
    --info("Getting player mouse")
    --local mouse = WaitForProp(localplayer, "GetMouse")(localplayer)
    title("AfoHub - In a game")
    info("You are in a game :3")
    

    local function WaitForModule(name)
        while true do
            for _, m in pairs(getloadedmodules()) do
                if typeof(m) == "Instance" and m.Name == name then
                    return m
                end
            end
            task.wait()
        end
    end

    local function ShallowCopy(orig)
        local copy
        if type(orig) == "table" then
            copy = {}
            for orig_key, orig_value in pairs(orig) do
                copy[orig_key] = orig_value
            end
        else
            copy = orig
        end
        return copy
    end

    local function XZCompare(v3_1, v3_2)
        return Vector3.new(v3_1.X, 0, v3_1.Z) - Vector3.new(v3_2.X, 0, v3_2.Z)
    end

    local function get_ray_ignore()
        return workspace.CurrentCamera, localplayer.Character,
            workspace:FindFirstChild("RaycastIgnore"),
            mapFolder:FindFirstChild("MapCallouts"),
            mapFolder.Map:FindFirstChild("Ramps"),
            mapFolder.Map:FindFirstChild("SecondaryObjects"),
            mapFolder.Map:FindFirstChild("Forces"),
            mapFolder.Map:FindFirstChild("Sites"),
            mapFolder.Map:FindFirstChild("Walls"),
            mapFolder.Map:FindFirstChild("Parts")
    end

    local ray_params = RaycastParams.new()
    ray_params.IgnoreWater = true
    ray_params.FilterType = Enum.RaycastFilterType.Blacklist
    local function will_be_blocked(target, origin)
        local whitelist = RaycastParams.new()
        whitelist.FilterType = Enum.RaycastFilterType.Whitelist
        whitelist.FilterDescendantsInstances = { mapFolder.Map:FindFirstChild("BAC"),
            --[[workspace:FindFirstChildWhichIsA("Terrain")]] }
        local direction = CFrame.new(origin, target)
        local ray = workspace:Raycast(direction.Position, direction.LookVector * 5e3, whitelist)
        return ray
            and ray.Instance
            and (
                ray.Instance:IsDescendantOf(mapFolder)
                --or ray.Instance:IsA("Terrain")
            )
    end
    local function _vis_check(target, origin, ignore)
        origin = origin or workspace.CurrentCamera.CFrame.Position
        ray_params.FilterDescendantsInstances = { get_ray_ignore(),
            type(ignore) == "table" and table.unpack(ignore) }
        local direction = CFrame.new(origin, target)
        local ray = workspace:Raycast(direction.Position, direction.LookVector * 5e3, ray_params)
        return ray and ray.Instance and ray.Position and (target - ray.Position).Magnitude < 6, ray.Position, ray.Instance
    end
    local function corner_distance(part, pos)
        local cf = part.CFrame
        local size = part.Size
        local frontFaceCenter = (cf + cf.LookVector * size.Z/2)
        local backFaceCenter = (cf - cf.LookVector * size.Z/2)
        local topFrontEdgeCenter = frontFaceCenter + frontFaceCenter.UpVector * size.Y/2
        local bottomFrontEdgeCenter = frontFaceCenter - frontFaceCenter.UpVector * size.Y/2
        local topBackEdgeCenter = backFaceCenter + backFaceCenter.UpVector * size.Y/2
        local bottomBackEdgeCenter = backFaceCenter - backFaceCenter.UpVector * size.Y/2
        local corners = {
            (topFrontEdgeCenter + topFrontEdgeCenter.RightVector * size.X/2).Position,
            (topFrontEdgeCenter - topFrontEdgeCenter.RightVector * size.X/2).Position,
            (bottomFrontEdgeCenter + bottomFrontEdgeCenter.RightVector * size.X/2).Position,
            (bottomFrontEdgeCenter - bottomFrontEdgeCenter.RightVector * size.X/2).Position,
            (topBackEdgeCenter + topBackEdgeCenter.RightVector * size.X/2).Position,
            (topBackEdgeCenter - topBackEdgeCenter.RightVector * size.X/2).Position,
            (bottomBackEdgeCenter + bottomBackEdgeCenter.RightVector * size.X/2).Position,
            (bottomBackEdgeCenter - bottomBackEdgeCenter.RightVector * size.X/2).Position
        }
        local closest_dist = math.huge
        local closest_corner
        for _, corner in pairs(corners) do
            local corner_dist = ((corner - pos) * Vector3.new(1, 0, 1)).Magnitude
            if corner_dist > closest_dist then
                closest_corner = corner
                closest_dist = corner_dist
            end
        end
        return closest_corner and ((closest_corner - pos) * Vector3.new(1, 0, 1)).Magnitude or math.huge
    end
    local PEN_MODIFIERS = { ["Low"] = 8, ["Medium"] = 2, ["High"] = 1, ["Players"] = 3 }
    local function get_penetration(part)
        local classifyMaterial = (LoadedModules or {}).ClassifyMaterial
        if not classifyMaterial then
            return
        end
        local material = classifyMaterial(part)
        local penetrationInfo = (LoadedModules or {}).PenetrationInfo
        if not penetrationInfo then
            return
        end
        local pen_material = material and penetrationInfo[material]
        return pen_material and PEN_MODIFIERS[pen_material], pen_material
    end
    local function vis_check(target, origin)
        local bac = mapFolder.Map:FindFirstChild("BAC")
        local success, isVis, hitPos, hitPart = pcall(_vis_check, target, origin, { bac })
        if not success then
            return false
        end
        local pensLeft = { ["Low"] = 8, ["Medium"] = 2, ["High"] = 1, ["Players"] = 3 }
        local i = 0
        if o.do_autowall then
            repeat
                i += 1
                local penAmt, penMaterial = get_penetration(hitPart)
                if penAmt and penMaterial then
                    pensLeft[penMaterial] -= penAmt
                end
                for _, penTypeLeft in pairs(pensLeft) do
                    if tonumber(penTypeLeft or 99) <= 0 then
                        break
                    end
                end
                if not isVis and typeof(hitPos) == "Vector3" then
                    success, isVis, hitPos, hitPart = pcall(_vis_check, target, hitPos, { bac })
                    if hitPart:IsDescendantOf(bac) then
                        isVis = false
                        break
                    end
                else
                    break
                end
            until isVis or i > 1 or not success
        end
        local isCornerHit = hitPart and hitPos and corner_distance(hitPart, hitPos) < 16
        local isBlocked = not isCornerHit and hitPart and bac and hitPart:IsDescendantOf(bac)
        local canShoot = (isVis and (not isBlocked))
        return canShoot, isCornerHit, i
    end
    local function create_debug_part(pos, color)
        local part = Instance.new("Part")
        game.Debris:AddItem(part, 3)
        part.Anchored = true
        part.Transparency = 1
        part.Size = Vector3.zero
        part.Position = pos
        part.Parent = workspace
        local bha = Instance.new("SphereHandleAdornment")
        bha.ZIndex = 12
        bha.Visible = true
        bha.Radius = 0.25
        bha.Color3 = color or Color3.new(0, 1, 0)
        bha.Transparency = 0.35
        bha.AlwaysOnTop = true
        bha.Adornee = part
        bha.Parent = part
    end
    --local function vis_check(target, origin)
    --    local map = mapFolder:FindFirstChild("Map")
    --    if not map then
    --        return
    --    end
    --    local whitelist = RaycastParams.new()
    --    whitelist.FilterType = Enum.RaycastFilterType.Whitelist
    --    local bac = map:FindFirstChild("BAC")
    --    whitelist.FilterDescendantsInstances = { map:FindFirstChild("Walls"),
    --        map:FindFirstChild("Players"), bac }
    --    local ray, isVis
    --    local i = 0
    --    repeat
    --        i += 1
    --        local direction = CFrame.new(origin, target)
    --        ray = workspace:Raycast(direction.Position, direction.LookVector * 15e3, whitelist)
    --        if ray and ray.Position then
    --            if bac and ray.Instance and ray.Instance:IsDescendantOf(bac) then
    --                isVis = false
    --                create_debug_part(ray.Position, Color3.new(1, 0, 0))
    --                break
    --            end
    --            create_debug_part(ray.Position, Color3.new(1, 0, 1))
    --            isVis = (target - ray.Position).Magnitude <= 8
    --            origin = ray.Position
    --        end
    --    until not ray or i > 1
    --    return isVis, false, i
    --end
    local function corner_cast(corner_dist_z, corner_dist_y, target, ignore, origin)
        ray_params.FilterDescendantsInstances = { get_ray_ignore(), unpack(ignore) }
        origin = origin or workspace.CurrentCamera.CFrame
        local adjusted = origin + Vector3.new(0, corner_dist_y, corner_dist_z)
        local direction = CFrame.lookAt(adjusted.Position, target)
        local ray = workspace:Raycast(adjusted.Position, direction.LookVector * 1e3)
        return ray and ray.Instance, ray and adjusted
    end
    local corner_offset_amt = 8
    local function get_corner_offset(target, ignore)
        local origin = target and target.CFrame or workspace.CurrentCamera.CFrame
        local base, basec = corner_cast(0, 0, target.Position, ignore, origin)
        if base and base:IsDescendantOf(target.Parent) then
            return basec, base
        end
        local c1, ac1 = corner_cast(-corner_offset_amt, 0, target.Position, ignore, origin)
        if c1 and c1:IsDescendantOf(target.Parent) then
            return ac1, c1
        end
        local c2, ac2 = corner_cast(corner_offset_amt, 0, target.Position, ignore, origin)
        if c2 and c2:IsDescendantOf(target.Parent) then
            return ac2, c2
        end
        local c3, ac3 = corner_cast(0, corner_offset_amt, target.Position, ignore, origin)
        if c3 and c3:IsDescendantOf(target.Parent) then
            return ac3, c3
        end
        local c4, ac4 = corner_cast(0, -corner_offset_amt, target.Position, ignore, origin)
        if c4 and c4:IsDescendantOf(target.Parent) then
            return ac4, c4
        end
        return nil
    end

    --local boneDefs = {
    --    Head = { "Head" },
    --    Chest = { "UpperTorso", "LowerTorso" },
    --    Limb = {
    --        "RightUpperArm", "LeftUpperArm",
    --        "RightLowerLeg", "LeftLowerLeg"
    --    },
    --    Random = {
    --        "LeftHand", "LeftLowerArm", "LeftUpperArm",
    --        "RightHand", "RightLowerArm", "RightUpperArm",
    --        "UpperTorso", "LowerTorso", "Head",
    --        "LeftFoot", "LeftLowerLeg", "LeftUpperLeg",
    --        "RightFoot", "RightLowerLeg", "RightUpperLeg"
    --    }
    --}
    local head_bones = {
        "Head",
        "UpperTorso",
        "LowerTorso",
        "LeftLowerArm",
        "RightLowerArm",
        "LeftLowerLeg",
        "RightLowerLeg"
    }
    local body_bones = {
        "UpperTorso",
        "LowerTorso",
        "LeftLowerArm",
        "RightLowerArm",
        "LeftLowerLeg",
        "RightLowerLeg",
        "Head"
    }
    local function GetBone(char)
        for _, bone in ipairs(body_bones or head_bones) do
            local foundBone = char:FindFirstChild(bone)
            if foundBone then
                local success, is_vis = pcall(vis_check, foundBone.Position)
                if success and is_vis then
                    return foundBone, true
                end
            end
        end
        return char:FindFirstChild("Head"), false
    end

    local function GetPlayerCharacter(plr)
        if not plr then
            return nil
        end
        return characters:FindFirstChild(plr.Name)
    end

    local function __internal_kill_registered(plr)
        local registeredData = killfeed[plr]
        local internalData = tryingToKill[plr]
        if registeredData and internalData then
            --debug("Player was killed! Data:", httpservice:JSONEncode(internalData), httpservice:JSONEncode(registeredData))
        end
    end

    --// Proxy functions/shims
    local engine, gun_src, oldFireBullet do
        info("Loading shims...")
        local current_identity = syn.get_thread_identity()
        syn.set_thread_identity(2) -- localscript
        task.wait()
        -- shim thread
        info("Loading engine")
        local loader_src = replicatedstorage:WaitForChild("Modules"):WaitForChild("Shared"):WaitForChild("ModuleLoader")
        local moduleLoader = getrenv().require(loader_src)
        engine = moduleLoader
        getgenv(0).__engine = moduleLoader
        ok("Engine loaded")
        info("Loading network")
        local function _engine_load_module(name)
            local mod
            repeat task.wait()
                pcall(function()
                    mod = rawget(moduleLoader, "LoadModule")(moduleLoader, name)
                end)
            until type(mod) == "table"
            return mod
        end
        local network = _engine_load_module("Network")
        getgenv(0).__network = network
        ok("Network loaded")
        info("Bypassing anticheat")
        repeat task.wait() until acbp()
        ok("Bypassed")
        info("Hooking network events")
        local netCachedFuncs
        repeat task.wait()
            netCachedFuncs = rawget(network, "CachedFunctions")
        until type(netCachedFuncs) == "table"
        while task.wait() do
            local flashEvent = rawget(netCachedFuncs, "Flash")
            if type(flashEvent) == "function" then
                local oldFlashEvent
                local function FlashEventHook(...)
                    return o.do_noflash or oldFlashEvent(...)
                end
                oldFlashEvent = hookfunction(flashEvent, function(...)
                    return FlashEventHook(...)
                end)
                break
            end
        end
        ok("Hooked")
        info("Hooking killfeed")
        local killFeed = engine.LoadedModules.KillFeedManager
        local oldCreateKillFeedUI
        local function CreateKillFeedUIHook(...)
            local _, weapon, killer, killed, isHeadshot, isWallbang, streak = ...
            if killer == localplayer then
                killfeed[killed] = {
                    plr = killed.Name,
                    tick = tick(),
                    weapon = weapon,
                    isHeadshot = isHeadshot,
                    isWallbang = isWallbang,
                    streak = streak
                }
                pcall(__internal_kill_registered, killed)
                task.delay(0.25, pcall, function()
                    killfeed[killed] = nil
                end)
            end
            return oldCreateKillFeedUI(...)
        end
        oldCreateKillFeedUI = hookfunction(killFeed.CreateKillFeedUI, function(...)
            return CreateKillFeedUIHook(...)
        end)
        ok("Hooked")
        info("Hooking fire")
        gun_src = WaitForModule("WeaponManagerClient")
        local gunEngine = engine.LoadedModules.WeaponManagerClient
        local function FireBulletHook(self, bullet, ...)
            if o.do_silentaim and type(bullet) == "table" and bullet.Owner == localplayer then
                local target = bullet.SilentTarget or target
                if o.do_silentaim and target then
                    local char = target and GetPlayerCharacter(target)
                    local bone = char and GetBone(char)
                    if char and bone then
                        local origincf = bullet.BulletCFrame
                        local silentOffset = bullet.SilentOffsetZ
                        local targetcf = CFrame.new()
                        if o.do_cornershoot then
                            origincf = get_corner_offset(bone, bullet.Ignore) or origincf
                        elseif type(silentOffset) == "number" and silentOffset > 0 then
                            origincf = origincf + (origincf.LookVector * silentOffset)
                        end
                        targetcf = CFrame.new(origincf.Position, bone.Position)
                        bullet.BulletCFrame = targetcf
                        bullet.OriginCFrame = targetcf
                        bullet.RotationMatrix = (targetcf - targetcf.Position)
                    end
                end
                if o.bullet_caliber ~= "Default" then
                    bullet.BulletType = o.bullet_caliber .. "Bullet"
                end
                if o.bullet_multiplier > 1 then
                    for _ = 1, o.bullet_multiplier - 1 do
                        local dupe = ShallowCopy(bullet)
                        dupe.BulletId = self:GenerateGUID()
                        coroutine.wrap(oldFireBullet)(self, dupe, ...)
                    end
                end
                if o.do_infwallbang or bullet.SilentTarget then
                    bullet.Ignore = { mapFolder.Map }
                end
                bullet.SilentOffsetZ = nil
                bullet.SilentOffsetX = nil
                bullet.SilentTarget = nil
            end
            return oldFireBullet(self, bullet, ...)
        end
        oldFireBullet = hookfunction(gunEngine.FireBullet, function(...)
            return FireBulletHook(...)
        end)
        ok("Hooked")
        info("Hooking melee")
        local oldMeleeAttack
        local function MeleeAttackHook(self, slashType, ...)
            if o.do_silentaim and target then
                local char = target and GetPlayerCharacter(target)
                local bone = char and char:FindFirstChild("UpperTorso")
                if char and bone then
                    task.delay(0.15, __network.FireServer, network, "MeleeHit", bone, slashType)
                end
            end
            return oldMeleeAttack(self, slashType, ...)
        end
        oldMeleeAttack = hookfunction(gunEngine.MeleeAttack, function(...)
            return MeleeAttackHook(...)
        end)
        ok("Hooked")
        info("Hooking weapon equip")
        local sharedMemory = rawget(engine.LoadedModules, "SharedMemory")
        local oldWeaponEquip
        local function EquipGunHook(...)
            local Inventory = (sharedMemory.WeaponData or {}).Inventory
            if type(Inventory) == "table" and #Inventory > 0 then
                for _, WeaponSlot in pairs(Inventory) do
                    local Weapon = type(WeaponSlot) == "table" and WeaponSlot[1]
                    if Weapon then
                        local WeaponName = Weapon.Weapon
                        local SkinOverride = WeaponName and o.skin_overrides[WeaponName]
                        if SkinOverride and SkinOverride ~= "Default" then
                            Weapon.Skin = SkinOverride
                        end
                    end
                end
            end
            return oldWeaponEquip(...)
        end
        oldWeaponEquip = hookfunction(gunEngine.Equip, function(...)
            return EquipGunHook(...)
        end)
        ok("Hooked")
        info("Hooking entity")
        local entityManager = engine.LoadedModules.EntitiesManager
        local oldNewItem
        ok("Hooked")
        syn.set_thread_identity(current_identity) -- core script
        task.wait()
        ok("Shims loaded")
    end
    LoadedModules = engine.LoadedModules
    local gunEngine = LoadedModules.WeaponManagerClient
    local sharedMemory = LoadedModules.SharedMemory
    local weaponInfo = LoadedModules.WeaponInfo
    local gun_engine_shoot = gunEngine.Shoot
    local gun_engine_firebullet = gunEngine.FireBullet

    local function find_first_viable_char()
        for _, plr in pairs(players:GetPlayers()) do
            local char = GetPlayerCharacter(plr)
            if not IsTeamMate(plr) and char then
                return char, plr
            end
        end
    end
    local function get_weapon()
        local inventory = sharedMemory.WeaponData.Inventory
        for i, gun in pairs(inventory) do
            if gun and gun[1] then
                local data = gun[1]
                if data and type(data) == "table" and data.Bullets and data.Weapon then
                    if data.Bullets >= 1 then
                        return data, i
                    end
                end
            end
        end
        if inventory[1] and inventory[1][1] then
            return inventory[1][1], 1
        elseif inventory[2] and inventory[2][1] then
            return inventory[2][1], 2
        end
        local currentWeapon = sharedMemory.CurrentWeaponData
        if currentWeapon and currentWeapon.Bullets then
            return currentWeapon, nil
        end
    end
    local is_reloading = false
    local function force_shoot(plr, offsetZ)
        if is_reloading then return end
        if o.autoshoot_mode == "Forced" then
            local currentWeapon, currentSlot = get_weapon()
            local weapon = currentWeapon and currentWeapon.Weapon
            local currentInfo = currentWeapon and weaponInfo[weapon]
            if currentWeapon then
                if currentSlot and not is_reloading then
                    __network:FireServer("EquipWeapon", { Slot = currentSlot, Index = 1 })
                    if currentWeapon.Bullets <= 4 and o.do_autoreload then
                        if not is_reloading then
                            is_reloading = true
                            task.spawn(function()
                                __network:FireServer("ReloadStart")
                                if currentInfo.ShellReload then
                                    for _ = 1, math.min(currentInfo.MaxBullets - currentWeapon.Bullets, currentWeapon.ReserveAmmo) do
                                        task.wait(0.25)
                                        __network:FireServer("ReloadShellEnd")
                                        task.wait(0.5)
                                        __network:FireServer("ReloadStart")
                                    end
                                end
                                task.delay(0.75, pcall, function()
                                    sharedMemory.WeaponData = __network:InvokeServer("ReloadEnd")
                                    is_reloading = false
                                end)
                            end)
                        end
                    else
                        __network:FireServer("ReloadStart")
                        task.delay(0.15, __network.FireServer, __network, "ReloadShellEnd")
                        task.delay(0.2, __network.InvokeServer, __network, "ReloadEnd")
                    end
                end
                local camcf = workspace.CurrentCamera.CFrame
                local bullet = {}
                bullet.BulletID = httpservice:GenerateGUID(true)
                bullet.Owner = localplayer
                bullet.CreatedTick = tick()
                bullet.BulletType = currentInfo.BulletType
                bullet.Weapon = weapon
                bullet.SilentOffsetZ = offsetZ or 0
                bullet.SilentTarget = plr or target
                bullet.BulletCFrame = camcf
                bullet.OriginCFrame = camcf * CFrame.Angles(0, 0, 0)
                bullet.RotationMatrix = (bullet.BulletCFrame - bullet.BulletCFrame.Position)
                bullet.Ignore = { localplayer.Character, workspace.CurrentCamera }
                currentWeapon.Bullets = currentWeapon.Bullets - 1
                __network:FireServer("FireBullet", { bullet }, camcf)
                syn.secure_call(gun_engine_firebullet, gun_src, gunEngine, bullet)
                __network:FireServer("EquipWeapon", sharedMemory.WeaponData.EquippedWeaponIndex)
            end
        elseif o.autoshoot_mode == "Regular" then
            syn.secure_call(gun_engine_shoot, gun_src, gunEngine)
        end
    end

    o.do_outlines = false
    o.esp_3dbox = false
    o.esp_skeleton = false
    o.esp_names = false
    o.esp_bomb = false
    o.esp_bombcolor = Color3.new(1, 0, 1)
    o.esp_highlighttarget = false
    o.esp_highlightcolor = Color3.new(1, 1, 0)
    o.esp_teamcolor = Color3.new(0, 1, 0)
    o.esp_enemycolor = Color3.new(1, 0, 0)
    o.esp_droppedweapons = false
    o.esp_droppedweaponscolor = Color3.new(0, 0.4, 1)
    o.esp_bulletimpacts = false
    o.esp_impactcolors = Color3.new(0, 0.25, 0.75)
    o.do_thirdperson = false
    o.do_noarms = false
    o.do_rainbowgun = false
    o.do_glow = false
    o.glow_teamcolor = Color3.new(0, 1, 0)
    o.glow_enemycolor = Color3.new(1, 0, 0)

    o.do_silentaim = false
    o.silentfov = 70
    o.fovcolor = Color3.new(1, 1, 1)
    o.usefov = false
    o.visibleonly = false
    o.do_cornershoot = false
    o.do_autoshoot = false
    o.do_autoknife = false
    o.autoshoot_mode = "Regular"
    o.autoshoot_delay = 250
    o.do_autoreload = false

    o.do_antiaim = false
    o.antiaim_pitch = "Default"
    o.antiaim_yaw = "Default"
    o.antiaim_target = "View Angle"

    o.boost_distance = 2
    o.do_soundspam = false
    o.do_commspam = false
    o.do_chatspam = false
    o.chatspam_msg = "AfoHub winning!"
    o.speed_modifier = 1 -- max = 6x / set MovementSpeedMultiplier of currentWeapon
    --o.jumppower = 30
    o.do_lagserver = false

    o.viewmodel_offset = 0
    o.viewmodel_fov = 0
    o.fov = 0

    o.do_infiniteammo = false -- set Bullets, MaxBullets, ReserveAmmo = math.huge
    o.fire_rate = 0 -- set FireRate
    o.fire_mode = "Default" -- set FireType (Default, Automatic, Burst, Single)
    o.bullet_caliber = "Default"
    o.bullet_multiplier = 1 -- set Pellets = X
    o.spread_reducer = 0 -- opposite of value / min = 0 / max = 1000 / set FirstShotSpread, Spread, MovementSpreadPenalty
    o.do_norecoil = false -- set RecoilResetTime to 0 / set Kickback = {} / set Recoil - {}
    o.do_rainbowsky = false
    o.do_alwaysbackstab = false
    o.do_noflash = false

    o.override_animation = "Disabled"
    o.spectator_equippedindex = "Default"
    o.spectator_fov = 0
    o.spectator_camera_roll = 0 -- min 0 max 360
    o.spectator_inf_ammo = false
    o.spectator_viewmodel_fov = 0
    o.spectator_camera_height = 0
    o.spectator_atmosphere = 0
    o.spoofed_name = ""
    o.hip_height = 0
    o.do_autowall = false
    o.do_bhop = false
    o.spambuy_weapon = "Off"

    o.skin_overrides = {}

    local defaults = o

    info("Getting config")

    local fn = "afohub_settings.rpoint.json"
    function saveOptions()
        local str = httpservice:JSONEncode(o)
        local suc, err = pcall(writefile, fn, str)
        if not suc then
            messagebox(tostring(err), "An error ocurred", 0)
        end
    end
    do -- load settings
        local suc, err = pcall(function()
            local _o = httpservice:JSONDecode(readfile(fn))
            o = _o
            for key, value in pairs(defaults) do
                if o[key] == nil then
                    o[key] = value
                end
            end
        end)
        if not suc then
            --messagebox(tostring(err), "Failed to load config", 0)
        end
    end

    -- silent target
    local onCircleStateUpdated do
        local circle = Drawing.new('Circle') do
            circle.Visible = o.usefov
            circle.Color = o.fovcolor
            circle.Thickness = 1
            circle.Transparency = 1
        end

        function onCircleStateUpdated(state)
            --if type(state) == 'boolean' then
            --    circle.Visible = o.usefov
            --elseif type(state) == 'number' then
            --    circle.Radius = state
            --elseif typeof(state) == 'Color3' then
            --    circle.Color = state
            --end
        end

        local lastAutoShoot, lastAutoKnife = tick(), tick()
        task.spawn(function()
            while runservice.Heartbeat:Wait() do
                local vps = workspace.CurrentCamera.ViewportSize
                local origin = Vector2.new(vps.X / 2, vps.Y / 2)

                DbgTxt.Position = origin + Vector2.new(-400, -200)
                DbgTxt.Visible = UserInputService:IsKeyDown(Enum.KeyCode.Backquote)

                circle.Radius = o.silentfov
                circle.Color = o.fovcolor
                circle.Position = origin
                circle.Visible = o.usefov

                local targets = {}
                local cCharacter = localplayer.Character

                if (not cCharacter) then
                    continue
                end

                local camcf = workspace.CurrentCamera.CFrame

                for _, character in pairs(characters:GetChildren()) do
                    local plr = character:IsA("Model") and players:FindFirstChild(character.Name)
                    if not plr or plr == localplayer then
                        continue
                    end
                    
                    local tracer = tracers[plr]

                    local humanoid = (character and character:FindFirstChildWhichIsA('Humanoid'))
                    local head = (character and character:FindFirstChild('Head'))

                    local closest_part = { dist = math.huge, inst = nil }
                    for _, part in pairs(character:GetChildren()) do
                        if part:IsA("BasePart") then
                            local dist = (workspace.CurrentCamera.CFrame.Position - part.Position).Magnitude
                            if dist < closest_part.dist then
                                closest_part.inst = part
                                closest_part.dist = dist
                            end
                        end
                    end

                    if not head or head and head.Position.Y < camcf.Position.Y - 20 then
                        continue
                    end

                    if (not humanoid) or (humanoid.Health <= 0) or IsTeamMate(plr) then
                        continue
                    end

                    if o.do_autoknife and tick() - lastAutoKnife >= 0.05 and closest_part.dist <= 16 and closest_part.inst then
                        __network:FireServer("EquipWeapon", { Slot = 3, Index = 1 })
                        for _=1,4 do
                            __network:FireServer("MeleeHit", closest_part.inst, "Heavy")
                        end
                        if sharedMemory.WeaponData and sharedMemory.WeaponData.EquippedWeaponIndex then
                            __network:FireServer("EquipWeapon", sharedMemory.WeaponData.EquippedWeaponIndex)
                        end
                        lastAutoKnife = tick()
                    elseif o.do_autoshoot and tick() - lastAutoShoot >= o.autoshoot_delay / 1000 then
                        if head then
                            local target = head.Position
                            local origincf = CFrame.lookAt(camcf.Position, target)
                            local can_shoot = false
                            local silentOffsetZ = 0
                            local success, isVis, isCornerHit, wallAmount = pcall(vis_check, target, origincf.Position)
                            DbgTxt.Text = tostring(success) .. " \"" .. tostring(isVis) .. "\""
                            if success and isVis then
                                can_shoot = true
                                local attempt = {
                                    plr = plr.Name,
                                    tick = tick(),
                                    isWallbang = wallAmount > 0,
                                    wallAmount = wallAmount,
                                    isCornerHit = isCornerHit
                                }
                                tryingToKill[plr] = attempt
                                --info("TRYING TO KILL:", httpservice:JSONEncode(attempt))
                            --elseif vis_check(target, (origincf + (origincf.LookVector * 10)).Position) then
                            --    can_shoot = true
                            --    silentOffsetZ = 10
                            end
                            if can_shoot then
                                if sharedMemory.WeaponData and sharedMemory.WeaponData.EquippedWeaponIndex then
                                    __network:FireServer("EquipWeapon", sharedMemory.WeaponData.EquippedWeaponIndex)
                                end
                                pcall(force_shoot, plr, silentOffsetZ)
                                lastAutoShoot = tick()
                            end
                        end
                    end

                    local vector, visible = workspace.CurrentCamera:WorldToViewportPoint(head.Position)
                    if o.usefov and (not visible) then
                        continue
                    end

                    vector = Vector2.new(vector.X, vector.Y)
                    local distance = math.floor((vector - origin).Magnitude)

                    if o.usefov then
                        if distance > o.silentfov then
                            continue
                        end
                    end

                    if o.visibleonly then
                        local suc, is_vis = pcall(vis_check, head.Position)
                        if not suc or not is_vis then
                            continue
                        end
                    end

                    targets[#targets + 1] = { plr, distance }
                end

                table.sort(targets, function(a, b) return a[2] < b[2] end)

                local _target = targets[1]
                if _target then
                    target = _target[1]
                else
                    target = nil
                end
            end
        end)
    end

    local function GetESPColor(char)
        if char then
            local plr = players:FindFirstChild(char.Name)
            if (o.esp_highlighttarget and plr == target) then
                return o.esp_highlightcolor
            end
            local team = char:FindFirstChild("Team") or (plr and plr:FindFirstChild("SelectedTeam"))
            local localteam = localplayer:FindFirstChild("SelectedTeam")
            local isSameTeam = not isDeathmatch() and team and localteam and team.Value == localteam.Value
            return (isSameTeam and o.esp_teamcolor or o.esp_enemycolor)
        end
        return o.esp_enemycolor
    end
    local function GetGlowColor(char)
        if char then
            local plr = players:FindFirstChild(char.Name)
            local team = char:FindFirstChild("Team") or (plr and plr:FindFirstChild("SelectedTeam"))
            local localteam = localplayer:FindFirstChild("SelectedTeam")
            local isSameTeam = not isDeathmatch() and team and localteam and team.Value == localteam.Value
            return (isSameTeam and o.glow_teamcolor or o.glow_enemycolor)
        end
        return o.glow_enemycolor
    end

    local droppedWeapons = {}
    local function ShowDroppedWeapons(show)
        for _, v in ipairs(droppedWeapons) do
            pcall(function() v.Visibile = not not show end)
        end
    end

    local update_chams do
        local coregui_parent = game:GetService("CoreGui"):WaitForChild("RobloxGui")
        local boundsMaxInt = 16
        local function getModelBounds3d(model)
            local cf, size = model:GetBoundingBox()
            if size.X > boundsMaxInt then size = Vector3.new(boundsMaxInt, size.Y, size.Z) end
            if size.Y > boundsMaxInt then size = Vector3.new(size.X, boundsMaxInt, size.Z) end
            if size.Z > boundsMaxInt then size = Vector3.new(size.X, size.Y, boundsMaxInt) end
            local corners               = {}
            local frontFaceCenter       = cf                     + cf.LookVector                      * size.Z / 2
            local backFaceCenter        = cf                     - cf.LookVector                      * size.Z / 2
            local topFrontEdgeCenter    = frontFaceCenter        + frontFaceCenter.UpVector           * size.Y / 2
            local bottomFrontEdgeCenter = frontFaceCenter        - frontFaceCenter.UpVector           * size.Y / 2
            local topBackEdgeCenter     = backFaceCenter         + backFaceCenter.UpVector            * size.Y / 2
            local bottomBackEdgeCenter  = backFaceCenter         - backFaceCenter.UpVector            * size.Y / 2
            corners.topFrontRight       = (topFrontEdgeCenter    + topFrontEdgeCenter.RightVector     * size.X / 2).Position
            corners.topFrontLeft        = (topFrontEdgeCenter    - topFrontEdgeCenter.RightVector     * size.X / 2).Position
            corners.bottomFrontRight    = (bottomFrontEdgeCenter + bottomFrontEdgeCenter.RightVector  * size.X / 2).Position
            corners.bottomFrontLeft     = (bottomFrontEdgeCenter - bottomFrontEdgeCenter.RightVector  * size.X / 2).Position
            corners.topBackRight        = (topBackEdgeCenter     + topBackEdgeCenter.RightVector      * size.X / 2).Position
            corners.topBackLeft         = (topBackEdgeCenter     - topBackEdgeCenter.RightVector      * size.X / 2).Position
            corners.bottomBackRight     = (bottomBackEdgeCenter  + bottomBackEdgeCenter.RightVector   * size.X / 2).Position
            corners.bottomBackLeft      = (bottomBackEdgeCenter  - bottomBackEdgeCenter.RightVector   * size.X / 2).Position
            corners.rawSize             = size
            return corners
        end
        local function drawLineFrom3d(v3_1, v3_2, line, color, visible)
            local camera = workspace.CurrentCamera
            if camera then
                if (camera.CFrame.Position - v3_1).Magnitude > 8 then
                    local a = camera:WorldToViewportPoint(v3_1)
                    local b = camera:WorldToViewportPoint(v3_2)
                    line.From = Vector2.new(a.X, a.Y)
                    line.To = Vector2.new(b.X, b.Y)
                    line.Color = color
                    line.Visible = visible == true
                end
            end
        end
        -----------

        -- CHAMS!!!!! (glow)
        players.PlayerAdded:Connect(function(plr)
            local tracer = Drawing.new("Line")
            tracer.Visible = false
            tracer.Thickness = 1
            tracers[plr] = tracer
        end)
        players.PlayerRemoving:Connect(function(plr)
            if tracers[plr] then
                tracers[plr]:Remove()
            end
            tracers[plr] = nil
        end)
        local function update_cham(char)
            local glow_color = GetGlowColor(char)
            for _, texture in pairs(char:GetDescendants()) do
                if texture:IsA("Texture") then
                    texture.Color3 = glow_color
                    texture.Transparency = o.do_glow and ((100 - (o.glow_intensity or 100)) / 100) or 1
                    texture.ZIndex = 8
                end
            end
        end
        local bone_connections = {
            -- Left leg
            ["LeftFoot"] = "LeftLowerLeg",
            ["LeftLowerLeg"] = "LeftUpperLeg",
            ["LeftUpperLeg"] = "LowerTorso",
            -- Right leg
            ["RightFoot"] = "RightLowerLeg",
            ["RightLowerLeg"] = "RightUpperLeg",
            ["RightUpperLeg"] = "LowerTorso",
            -- Left arm
            ["LeftHand"] = "LeftLowerArm",
            ["LeftLowerArm"] = "LeftUpperArm",
            ["LeftUpperArm"] = "UpperTorso",
            -- Right arm
            ["RighttHand"] = "RightLowerArm",
            ["RightLowerArm"] = "RightUpperArm",
            ["RightUpperArm"] = "UpperTorso",
            -- Spine
            ["LowerTorso"] = "UpperTorso",
            ["UpperTorso"] = "Head"
        }
        function update_chams()
            for _, char in pairs(characters:GetChildren()) do
                update_cham(char)
            end
        end
        local function char_descendant_added(part)
            if part:IsA("MeshPart")
            then
                if part.Name:match("Arm") or part.Name:match("Hand") then
                    if not part.Parent.Name:match("^[Left]*[Right]*$") then
                        return
                    end
                end
                for _, face in pairs(Enum.NormalId:GetEnumItems()) do
                    local texture = Instance.new("Texture")
                    texture.Texture = "rbxassetid://6888586040"
                    texture.Transparency = 1
                    texture.Face = face
                    texture.Parent = part
                end
            end
        end
        local function character_added(char)
            if char == localplayer.Character then
                return
            end
            if char:FindFirstChild("Team") then
                for _, mesh in pairs(char:GetDescendants()) do
                    char_descendant_added(mesh)
                end
                char.DescendantAdded:Connect(char_descendant_added)
                if not char:FindFirstChildWhichIsA("Highlight") then
                    local outline = Instance.new("Highlight", char)
                    outline.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    outline.OutlineColor = GetESPColor(char)
                    outline.OutlineTransparency = o.do_outlines and 0 or 1
                    outline.FillTransparency = 1
                    outline.Parent = char
                end
                local name_text = Drawing.new("Text")
                name_text.Color = Color3.new(1, 1, 1)
                name_text.Visible = false
                name_text.Size = 16
                name_text.Font = Drawing.Fonts.Monospace
                esp_names[char] = name_text
            end
            update_cham(char)
        end
        characters.ChildAdded:Connect(character_added)
        characters.ChildRemoved:Connect(function(char)
            local name = esp_names[char]
            if name then
                pcall(name.Remove, name)
            end
            rawset(esp_names, char, nil)
        end)
        for _, char in pairs(characters:GetChildren()) do
            character_added(char)
        end
        ---
        local dropped_weapons = workspace:WaitForChild("DroppedWeapons")
        local weapon_outlines = {}
        local function add_weapon_outline(wep)
            local outline = Instance.new("Highlight")
            outline.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            outline.OutlineColor = o.esp_droppedweaponscolor
            outline.OutlineTransparency = o.esp_droppedweapons and 0 or 1
            outline.Adornee = wep
            outline.FillTransparency = 1
            outline.Parent = coregui_parent
            weapon_outlines[wep] = outline
        end
        dropped_weapons.ChildAdded:Connect(add_weapon_outline)
        dropped_weapons.ChildRemoved:Connect(function(wep)
            pcall(game.Destroy, weapon_outlines[wep])
            weapon_outlines[wep] = nil
        end)
        local bomb_outline
        local bomb = workspace:WaitForChild("MapFolder"):WaitForChild("Bomb")
        bomb.ChildAdded:Connect(function(b)
            bomb_outline = Instance.new("Highlight")
            bomb_outline.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            bomb_outline.OutlineColor = o.esp_bombcolor
            bomb_outline.FillTransparency = 1
            bomb_outline.OutlineTransparency = 0
            bomb_outline.Adornee = b
            bomb_outline.Parent = coregui_parent
        end)
        bomb.ChildRemoved:Connect(function()
            pcall(game.Destroy, bomb_outline)
            bomb_outline = nil
        end)
        task.spawn(function()
            while task.wait() do
                for _, char in pairs(characters:GetChildren()) do
                    -- outlines
                    local outline = char:FindFirstChildWhichIsA("Highlight")
                    if outline then
                        outline.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        outline.OutlineColor = GetESPColor(char)
                        outline.OutlineTransparency = o.do_outlines and 0 or 1
                        outline.FillTransparency = 1
                        outline.Enabled = true
                    end
                end
                for _, outline in pairs(weapon_outlines) do
                    if typeof(outline) == "Instance" then
                        outline.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        outline.OutlineTransparency = o.esp_droppedweapons and 0 or 1
                        outline.OutlineColor = o.esp_droppedweaponscolor
                    end
                end
                if typeof(bomb_outline) == "Instance" then
                    bomb_outline.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    bomb_outline.OutlineTransparency = o.esp_bomb and 0 or 1
                    bomb_outline.OutlineColor = o.esp_bombcolor
                end
            end
        end)

        local function handleBulletImpact(hitPos)
            if not o.esp_bulletimpacts then return end
            if typeof(hitPos) == "Vector3" then
                local part = Instance.new("Part")
                part.Size = Vector3.new(0, 0, 0)
                part.Transparency = 1
                part.CanCollide = false
                part.Anchored = true
                part.Position = hitPos
                part.Parent = workspace.CurrentCamera
                local marker = Instance.new("SphereHandleAdornment")
                marker.ZIndex = 9
                marker.Radius = 0.15
                marker.Color3 = o.esp_impactcolors
                marker.Parent = part
                marker.AlwaysOnTop = true
                marker.Adornee = part
                task.delay(5, function()
                    for i=0,1,0.01 do
                        marker.Transparency = i
                        task.wait()
                    end
                    part:Destroy()
                end)
            end
        end
        workspace:WaitForChild("RaycastIgnore").ChildAdded:Connect(function(child)
            if child:IsA("BasePart") and string.match(child.Name, "[%w+]*BulletHole") then
                handleBulletImpact(child.Position)
            end
        end)
    end

    local RemoteEventOverrides = {}
    --// RemoteEvent overrides
    RemoteEventOverrides.AnimationUpdate = function(AnimName, ...)
        if o.override_animation ~= "Disabled" then
            return o.override_animation
        end
        return AnimName, ...
    end
    RemoteEventOverrides.CameraUpdate = function(SpectatorInfo, ...)
        if type(SpectatorInfo) == "table" then
            -- Spectate override/spoofing
            if o.spectator_camera_roll > 0 then
                SpectatorInfo.CameraOffset = SpectatorInfo.CameraOffset
                    * CFrame.fromEulerAnglesXYZ(0, 0, math.rad(o.spectator_camera_roll))
            end
            if o.spectator_fov ~= 0 then
                SpectatorInfo.FOV = o.spectator_fov
            end
            if o.spectator_viewmodel_fov ~= 0 then
                SpectatorInfo.ViewModelCFrame = CFrame.new(0, 0, o.spectator_viewmodel_fov) + SpectatorInfo.ViewModelCFrame
            end
            if o.spectator_equippedindex ~= "Default" then
                SpectatorInfo.EquippedWeapon = o.spectator_equippedindex == "None"
                                            or { Index = 1, Slot = (o.spectator_equippedindex == "Primary" and 1
                                                                or  o.spectator_equippedindex == "Secondary" and 2
                                                                or  o.spectator_equippedindex == "Melee" and 3)
                                                                or  0 }
            end
            if o.spectator_inf_ammo then
                SpectatorInfo.ReserveAmmo = math.huge
                SpectatorInfo.Bullets = math.huge
                SpectatorInfo.AbilityUses = -math.huge
                SpectatorInfo.CurrentWeaponData.ReserveAmmo = math.huge
                SpectatorInfo.CurrentWeaponData.Bullets = math.huge
            end
            if o.spectator_camera_height > 0 then
                SpectatorInfo.CrouchAmount = o.spectator_camera_height
            end
            if o.spectator_atmosphere > 0 then
                SpectatorInfo.Atmosphere = o.spectator_atmosphere
            end
        end
        return SpectatorInfo, ...
    end
    RemoteEventOverrides.Running = function(IsRunning, ...)
        if o.force_running == "Force On" then
            IsRunning = true
        elseif o.force_running == "Force Off" then
            IsRunning = false
        end
        return IsRunning, ...
    end
    RemoteEventOverrides.MeleeHit = function(Part, HitType, ...)
        if o.do_alwaysbackstab then
            HitType = "Heavy"
        end
        return Part, HitType, ...
    end
    info("Hooking global __namecall")
    local IsA = game.IsA
    OldNameCall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        if not checkcaller() then
            local Args = { ... }
            local EventName = Args[1]
            local Method = getnamecallmethod()
            --info(tostring(self) .. ":" .. Method .. "(" .. string.sub(table.concat(Args, ", "), 1, -1) .. ")")
            if IsA(self, "RemoteEvent") and Method == "FireServer" then
                local Handler = RemoteEventOverrides[EventName]
                if type(Handler) == "function" then
                    return OldNameCall(self, Handler(...))
                end
            elseif self == localplayer and Method == "Destroy" then--ac
                return nil
            elseif IsA(self, "AnimationTrack") and o.antiaim_noleg then
                local isIdle = string.match(self.Name, "Idle")
                if string.match(self.Name, "Walk")
                or string.match(self.Name, "Crouch") then
                    if (Method == "Play" and (not isIdle))
                    or (Method == "Stop" and isIdle)
                    then
                        return nil
                    end
                end
            end
        end
        return OldNameCall(self, ...)
    end))
    ok("Hooked")

    
    local last_boost = tick()
    local function boost_char(isHeld)
        local char = localplayer.Character
        local hrp = char and char.HumanoidRootPart
        local targetpos = (workspace.CurrentCamera.CFrame.LookVector * (o.boost_distance + 10))
                        + Vector3.new(0, 20, 0)
        if hrp then
            hrp.Velocity = targetpos
        end
        last_boost = tick()
    end
    WaitForService("UserInputService").InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Space then
            if tick() - last_boost < 0.5 and localplayer.Character then
                local hrp = localplayer.Character.HumanoidRootPart
                hrp.Velocity = hrp.Velocity + Vector3.new(0, 15, 0)
            end
        end
    end)


    info("Initializing ui")
    do --// ui
        local ui = library:CreateWindow("cuteware.shit")

        local skin_changer = ui:AddFolder("Skin Changer")
        local aim = ui:AddFolder("Aim")
        local anti_aim = ui:AddFolder("Anti Aim")
        local gun = ui:AddFolder("Gun")
        local spectator = ui:AddFolder("Spectator")
        local esp = ui:AddFolder("ESP")
        local visuals = ui:AddFolder("Other Visuals")
        local misc = ui:AddFolder("Misc")

        aim:AddToggle({
            text = "Silent Aim",
            state = o.do_silentaim,
            callback = function(v) o.do_silentaim = v end
        })
        
        aim:AddToggle({
            text = "Use FOV",
            state = o.usefov,
            callback = function(v) o.usefov = v onCircleStateUpdated(v) end
        }) onCircleStateUpdated(o.usefov)
        aim:AddSlider({
            text = "FOV",
            value = o.silentfov,
            min = 0,
            max = 300,
            callback = function(v) o.silentfov = v onCircleStateUpdated(v) end
        }) onCircleStateUpdated(o.silentfov)
        aim:AddToggle({
            text = "Visible Only",
            state = o.visibleonly,
            callback = function(v) o.visibleonly = v end
        })
        aim:AddToggle({
            text = "Shoot \"Around Corners\"",
            state = o.do_cornershoot,
            callback = function(v) o.do_cornershoot = v end
        })
        aim:AddToggle({
            text = "Infinite Wallbang",
            state = o.do_infwallbang,
            callback = function(v) o.do_infwallbang = v end
        })
        aim:AddToggle({
            text = "Always Backstab",
            state = o.do_alwaysbackstab,
            callback = function(v) o.do_alwaysbackstab = v end
        })
        aim:AddToggle({
            text = "Auto Knife",
            state = o.do_autoknife,
            callback = function(v) o.do_autoknife = v end
        })
        aim:AddToggle({
            text = "Auto Shoot",
            state = o.do_autoshoot,
            callback = function(v) o.do_autoshoot = v end
        })
        aim:AddToggle({
            text = "Auto Wallbang",
            state = o.do_autowall,
            callback = function(v) o.do_autowall = v end
        })
        aim:AddToggle({
            text = "Auto Reload",
            state = o.do_autoreload,
            callback = function(v) o.do_autoreload = v end
        })
        aim:AddSlider({
            text = "Auto Shoot Delay",
            value = o.autoshoot_delay,
            min = 0,
            max = 1000,
            callback = function(v) o.autoshoot_delay = v end
        })
        aim:AddBind({
            text = "Force Shoot",
            key = "Z",
            hold = true,
            callback = force_shoot
        })
        aim:AddList({
            text = "Auto Shoot Mode",
            value = o.autoshoot_mode,
            values = { "Forced", "Regular" },
            callback = function(v) o.autoshoot_mode = v end
        })

        anti_aim:AddToggle({
            text = "Enable",
            state = o.do_antiaim,
            callback = function(v) o.do_antiaim = v end
        })
        anti_aim:AddList({
            text = "Pitch",
            value = o.antiaim_pitch,
            values = { "Default", "Up", "Down", "Random" },
            callback = function(v) o.antiaim_pitch = v end
        })
        anti_aim:AddList({
            text = "Yaw",
            value = o.antiaim_yaw,
            values = { "Default", "Spin", "Backwards", "Backwards Jitter" },
            callback = function(v) o.antiaim_yaw = v end
        })
        anti_aim:AddList({
            text = "Face Towards",
            value = o.antiaim_target,
            values = { "View Angle", "Target" },
            callback = function(v) o.antiaim_target = v end
        })
        anti_aim:AddToggle({
            text = "No Leg Movement",
            state = o.antiaim_noleg,
            callback = function(v) o.antiaim_noleg = v end
        })

        gun:AddLabel({ text = "Gun mods are not reversible" })
        gun:AddList({
            text = "Bullet Caliber",
            values = { "Default", "Pistol", "Shotgun", "Sniper", "Rifle" },
            value = o.bullet_caliber,
            callback = function(v) o.bullet_caliber = v end
        })
        gun:AddSlider({
            text = "Bullet Multiplier",
            value = o.bullet_multiplier,
            min = 1,
            max = 100,
            callback = function(v) o.bullet_multiplier = v end
        })
        gun:AddSlider({
            text = "Spread Reducer",
            value = o.spread_reducer,
            min = 0,
            max = 100,
            callback = function(v) o.spread_reducer = v end
        })
        gun:AddToggle({
            text = "No Recoil",
            state = o.do_norecoil,
            callback = function(v) o.do_norecoil = v end
        })
        gun:AddList({
            text = "Fire Mode",
            values = { "Default", "Automatic", "Burst", "Single" },
            value = o.fire_mode,
            callback = function(v) o.fire_mode = v end
        })
        gun:AddSlider({
            text = "Fire Rate",
            value = o.fire_rate,
            min = 0,
            max = 2000,
            callback = function(v) o.fire_rate = v end
        })

        spectator:AddToggle({
            text = "Infinite Ammo",
            state = o.spectator_inf_ammo,
            callback = function(v) o.spectator_inf_ammo = v end
        })
        spectator:AddSlider({
            text = "Viewmodel FOV",
            value = o.spectator_viewmodel_fov,
            min = 0,
            max = 200,
            callback = function(v) o.spectator_viewmodel_fov = v end
        })
        spectator:AddSlider({
            text = "Camera FOV",
            value = o.spectator_fov,
            min = 0,
            max = 120,
            callback = function(v) o.spectator_fov = v end
        })
        spectator:AddSlider({
            text = "Camera Roll",
            value = o.spectator_camera_roll,
            min = 0,
            max = 360,
            callback = function(v) o.spectator_camera_roll = v end
        })
        spectator:AddSlider({
            text = "Atmospheric Density",
            value = o.spectator_atmosphere * 10,
            min = 0,
            max = 3,
            callback = function(v) o.spectator_atmosphere = v / 10 end
        })
        spectator:AddSlider({
            text = "Camera Height",
            value = o.spectator_camera_height,
            min = -100,
            max = 100,
            callback = function(v) o.spectator_camera_height = v end
        })
        spectator:AddList({
            text = "Equipped Weapon",
            values = { "Default", "Primary", "Secondary", "Melee", "None" },
            value = o.spectator_equippedindex,
            callback = function(v) o.spectator_equippedindex = v end
        })

        esp:AddToggle({
            text = "Outlines",
            state = o.do_outlines,
            callback = function(v) o.do_outlines = v end
        })
        --esp:AddToggle({
        --    text = "Player 3D Box",
        --    state = o.esp_3dbox,
        --    callback = function(v) o.esp_3dbox = v end
        --})
        --esp:AddToggle({
        --    text = "Player Skeletons",
        --    state = o.esp_skeleton,
        --    callback = function(v) o.esp_skeleton = v end
        --})
        esp:AddToggle({
            text = "Show Names",
            state = o.esp_names,
            callback = function(v) o.esp_names = v end
        })
        esp:AddColor({
            text = "Enemy Outline Color",
            color = { o.esp_enemycolor.r, o.esp_enemycolor.g, o.esp_enemycolor.b },
            callback = function(v) o.esp_enemycolor = v end
        })
        esp:AddColor({
            text = "Team Outline Color",
            color = { o.esp_teamcolor.r, o.esp_teamcolor.g, o.esp_teamcolor.b },
            callback = function(v) o.esp_teamcolor = v end
        })
        esp:AddToggle({
            text = "Highlight Target",
            state = o.esp_highlighttarget,
            callback = function(v) o.esp_highlighttarget = v end
        })
        esp:AddColor({
            text = "Highlight Color",
            color = {  o.esp_highlightcolor.r, o.esp_highlightcolor.g, o.esp_highlightcolor.b },
            callback = function(v) o.esp_highlightcolor = v end
        })
        esp:AddToggle({
            text = "Outline Dropped Weapons",
            state = o.esp_droppedweapons,
            callback = function(v) o.esp_droppedweapons = v end
        })
        esp:AddColor({
            text = "Dropped Weapons Color",
            color = { o.esp_droppedweaponscolor.r, o.esp_droppedweaponscolor.g, o.esp_droppedweaponscolor.b },
            callback = function(v) o.esp_droppedweaponscolor = v ShowDroppedWeapons(v) end
        })
        esp:AddToggle({
            text = "Outline Bomb",
            state = o.esp_bomb,
            callback = function(v) o.esp_bomb = v end
        })
        esp:AddColor({
            text = "Bomb Color",
            color = { o.esp_bombcolor.r, o.esp_bombcolor.g, o.esp_bombcolor.b },
            callback = function(v) o.esp_bombcolor = v end
        })

        visuals:AddToggle({
            text = "Player Glow",
            state = o.do_glow,
            callback = function(v) o.do_glow = v end
        })
        visuals:AddSlider({
            text = "Glow Intensity",
            min = 0,
            max = 100,
            value = o.glow_intensity,
            callback = function(v) o.glow_intensity = v update_chams() end
        }) update_chams()
        visuals:AddColor({
            text = "Enemy Glow Color",
            color = { o.glow_enemycolor.r, o.glow_enemycolor.g, o.glow_enemycolor.b },
            callback = function(v) o.glow_enemycolor = v update_chams() end
        })
        visuals:AddColor({
            text = "Team Glow Color",
            color = { o.glow_teamcolor.r, o.glow_teamcolor.g, o.glow_teamcolor.b },
            callback = function(v) o.glow_teamcolor = v update_chams() end
        })
        visuals:AddToggle({
            text = "Bullet Impacts",
            state = o.esp_bulletimpacts,
            callback = function(v) o.esp_bulletimpacts = v end
        })
        visuals:AddColor({
            text = "Impact Colors",
            color = {  o.esp_impactcolors.r, o.esp_impactcolors.g, o.esp_impactcolors.b },
            callback = function(v) o.esp_impactcolors = v end
        })
        visuals:AddColor({
            text = "FOV Circle Color",
            color = o.fovcolor,
            callback = function(v) o.fovcolor = v end
        })
        visuals:AddSlider({
            text = "Camera FOV Modifier",
            value = o.fov,
            min = 0,
            max = MAX_FOV * 2,
            callback = function(v) o.fov = v end
        })
        visuals:AddToggle({
            text = "Rainbow Environment",
            state = o.do_rainbowsky,
            callback = function(v) o.do_rainbowsky = v end
        })
        visuals:AddToggle({
            text = "Rainbow Viewmodel",
            state = o.do_rainbowgun,
            callback = function(v) o.do_rainbowgun = v end
        })
        visuals:AddSlider({
            text = "Viewmodel Roll",
            value = o.viewmodel_offset,
            min = 0,
            max = 360,
            callback = function(v) o.viewmodel_offset = v end
        })
        visuals:AddSlider({
            text = "Viewmodel FOV",
            value = o.viewmodel_fov,
            min = 0,
            max = 200,
            callback = function(v) o.viewmodel_fov = v end
        })
        visuals:AddToggle({
            text = "Hide Arms",
            state = o.do_noarms,
            callback = function(v) o.do_noarms = v end
        })
        visuals:AddToggle({
            text = "Third Person",
            state = o.do_thirdperson,
            callback = function(v) o.do_thirdperson = v end
        })
        visuals:AddToggle({
            text = "No Flash",
            state = o.do_noflash,
            callback = function(v) o.do_noflash = v end
        })

        do
            local weapons = { "Off" }
            for weapon, _ in pairs(weaponInfo) do
                table.insert(weapons, weapon)
            end
            misc:AddList({
                text = "Spam Buy Weapon",
                value = o.spambuy_weapon,
                values = weapons,
                callback = function(v) o.spambuy_weapon = v end
            })
        end
        misc:AddBind({
            text = "Ghosting",
            key = "X",
            hold = true,
            callback = function(letGo)
                doGhosting = not letGo
            end
        })
        misc:AddSlider({
            text = "TempY Height",
            value = o.hip_height,
            min = 0,
            max = 120,
            callback = function(v) o.hip_height = v end
        })
        misc:AddBind({
            text = "TempY",
            key = "LeftAlt",
            hold = true,
            callback = function(letGo)
                doTempY = not letGo
            end
        })
        misc:AddList({
            text = "Force Running",
            value = o.force_running,
            values = { "Disabled", "Force On", "Force Off" },
            callback = function(v) o.force_running = v end
        })
        misc:AddList({
            text = "Override Animation",
            value = o.override_animation,
            values = { "Disabled", "Equip", "Defuse", "Powerup", "Reload", "Idle" },
            callback = function(v) o.override_animation = v end
        })
        misc:AddSlider({
            text = "Speed Modifier",
            value = o.speed_modifier,
            min = 1,
            max = 60,
            callback = function(v) o.speed_modifier = v end
        })
        misc:AddToggle({
            text = "Bunny Hop",
            state = o.do_bhop,
            callback = function(v) o.do_bhop = v end
        })
        misc:AddToggle({
            text = "Comms Spam",
            state = o.do_commspam,
            callback = function(v) o.do_commspam = v end
        })
        misc:AddToggle({
            text = "Sound Spam",
            state = o.do_soundspam,
            callback = function(v) o.do_soundspam = v end
        })
        misc:AddToggle({
            text = "Chat Spam",
            state = o.do_chatspam,
            callback = function(v) o.do_chatspam = v end
        })
        misc:AddBox({
            text = "Chat Spam Message",
            value = o.chatspam_msg,
            callback = function(v) o.chatspam_msg = v end
        })
        misc:AddBind({
            text = "Boost Forwards",
            key = "F",
            hold = false,
            callback = boost_char
        })
        misc:AddSlider({
            text = "Boost Distance",
            value = o.boost_distance,
            min = 2,
            max = 50,
            callback = function(v) o.boost_distance = v end
        })
        misc:AddToggle({
            text = "Lag Server",
            state = o.do_lagserver,
            callback = function(v) o.do_lagserver = v end
        })
        misc:AddBox({
            text = "Name Spoofer (local)",
            value = o.spoofed_name,
            callback = function(v) o.spoofed_name = v end
        })
        --#region skin changer
        do
            local weapons = replicatedstorage:WaitForChild("Assets"):WaitForChild("Weapons")
            local ignore_weapons = {
                "Zyla Brain", "Combat Turret", "Flashbang",
                "Humbug", "Zyla Powerup", "Medic Gun",
                "Bomb", "Molotov", "Grenade", "Smoke Grenade",
                "Edira Powerup"
            }
            local skins = {}
            for _, weapon in pairs(weapons:GetChildren()) do
                if table.find(ignore_weapons, weapon.Name) then continue end
                local weapon_skins = {}
                for _, skin in pairs(weapon:GetChildren()) do
                    table.insert(weapon_skins, skin.Name)
                end
                skins[weapon.Name] = weapon_skins
            end
            --
            for weapon_name, available_skins in pairs(skins) do
                skin_changer:AddList({
                    text = weapon_name,
                    values = available_skins,
                    value = o.skin_overrides[weapon_name] or "Default",
                    callback = function(v)
                        o.skin_overrides[weapon_name] = v
                    end
                })
            end
        end
        --#endregion

        ui:AddButton({
            text = "Save Options",
            callback = saveOptions
        })
        ui:AddButton({
            text = "Join Discord",
            callback = loadstring(game:HttpGet("https://hub.afo.xyz/include/discord.lua"))()
        })
        --ui:AddButton({
        --    text = "Rejoin",
        --    callback = RejoinSameInstance
        --})
    end

    task.spawn(function()
        while true do
            for i=0,1,0.001 do
                rainbow_color = Color3.fromHSV(i, 1, 1)
                task.wait()
                if o.do_rainbowsky then
                    for _, sky in ipairs(lighting:GetChildren()) do
                        if sky:IsA("Sky") then
                            sky.SkyboxBk = "rbxassetid://8694485972"
                            sky.SkyboxDn = "rbxassetid://8694485972"
                            sky.SkyboxFt = "rbxassetid://8694485972"
                            sky.SkyboxLf = "rbxassetid://8694485972"
                            sky.SkyboxRt = "rbxassetid://8694485972"
                            sky.SkyboxUp = "rbxassetid://8694485972"
                            sky.CelestialBodiesShown = false
                            sky.StarCount = 0
                        end
                    end
                    lighting.Ambient = rainbow_color
                    lighting.ColorShift_Top = rainbow_color
                end
            end
        end
    end)
    task.spawn(function()
        while task.wait(.25) do
            --local customSkins = o.skin_overrides or {}
            local currentWeaponData = sharedMemory and rawget(sharedMemory, "CurrentWeaponData")
            local currentGun = currentWeaponData and currentWeaponData.Weapon
            local currentGunData = currentGun and currentGun ~= "" and weaponInfo and weaponInfo[currentGun]
            if currentGunData and type(currentGunData) == "table" then
                --if o.fov > 0 then
                --    currentGunData.FOV = o.fov
                --end
                if o.do_norecoil then
                    currentGunData.Recoil = { { X = 0, Y = 0 } }
                end
                --if o.speed_modifier > 1 then
                --    currentGunData.MovementSpeedMultiplier = o.speed_modifier / 10
                --end
                if o.fire_rate > 0 then
                    currentGunData.FireRate = (2000 - o.fire_rate) / 10
                end
                if o.fire_mode ~= "Default" then
                    currentGunData.FireType = o.fire_mode
                end
                if o.bullet_caliber ~= "Default" then
                    currentGunData.BulletType = o.bullet_caliber .. "Bullet"
                end
                if o.spread_reducer > 0 then
                    local spread = (100 - o.spread_reducer) / 10
                    currentGunData.FirstShotSpread = spread
                    currentGunData.Spread = spread
                    currentGunData.MovementSpreadPenalty = spread
                end
                --local customSkin = customSkins[currentGun]
                --if customSkin and customSkin ~= "Default" then
                --    currentWeaponData.Skin = customSkin
                --end
            end
        end
    end)--]]
    --// Frame cycle
    local commtypes = { "Enemy", "Help", "Caution", "Watch" }
    workspace.CurrentCamera.DescendantAdded:Connect(function(descendant)
        if descendant.Parent.Name == "Object" and descendant.Parent:IsA("Model") and descendant:IsA("MeshPart") then
            for _, face in pairs(Enum.NormalId:GetEnumItems()) do
                local texture = Instance.new("Texture")
                texture.ZIndex = 0
                texture.Transparency = 1
                texture.Texture = "rbxassetid://6888586040"
                texture.Face = face
                texture.Parent = descendant
            end
        end
    end)
    local viewmodel
    task.spawn(function()
        while runservice.RenderStepped:Wait() do
            if localplayer.Character then
                if o.spambuy_weapon ~= "Off" then
                    pcall(__network.InvokeServer, __network, "BuyItem", o.spambuy_weapon)
                end
                local humanoid = localplayer.Character:FindFirstChildWhichIsA("Humanoid")
                local hrp = localplayer.Character.PrimaryPart
                if humanoid then
                    if doTempY and hrp then
                        humanoid.HipHeight = o.hip_height
                        task.wait(0.1)
                        hrp.Anchored = true
                    else
                        humanoid.HipHeight = 2.63
                        hrp.Anchored = false
                    end
                    if o.do_bhop then
                        humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
                    end
                end
                viewmodel = workspace.CurrentCamera:FindFirstChild("Weapon")
                if viewmodel then
                    local fov_rot = viewmodel:FindFirstChild("RotationOffset")
                    local gun_fov = viewmodel:FindFirstChild("Offset")
                    local aim_fov = viewmodel:FindFirstChild("AimOffset")
                    if not o.do_thirdperson then
                        if o.viewmodel_offset ~= 0 and fov_rot then
                            local fov = Vector3.new(fov_rot.Value.X, fov_rot.Value.Y, o.viewmodel_offset)
                            fov_rot.Value = fov
                        end
                        if o.viewmodel_fov ~= 0 and aim_fov and gun_fov then
                            local fov = -(o.viewmodel_fov / 100)
                            gun_fov.Value = Vector3.new(gun_fov.Value.X, gun_fov.Value.Y, fov)
                            aim_fov.Value = Vector3.new(aim_fov.Value.X, aim_fov.Value.Y, fov - 1)
                        end
                    elseif gun_fov and aim_fov then
                        gun_fov.Value = Vector3.new(0, 0, -100)
                        aim_fov.Value = Vector3.new(0, 0, -100)
                    end
                    local arms = viewmodel:FindFirstChild("Arms")
                    if arms then
                        for _, part in pairs(arms:GetDescendants()) do
                            if part:IsA("MeshPart") or part:IsA("BasePart") then
                                part.Transparency = (o.do_noarms or o.do_thirdperson) and 1 or 0
                            end
                        end
                    end
                    local gun_parts = viewmodel:FindFirstChild("Object")
                    if gun_parts then
                        for _, texture in pairs(gun_parts:GetDescendants()) do
                            if texture:IsA("Texture") then
                                if o.do_rainbowgun then
                                    texture.Color3 = rainbow_color
                                    texture.ZIndex = 9
                                    texture.Transparency = 0
                                else
                                    texture.ZIndex = 0
                                    texture.Transparency = 1
                                end
                            end
                        end
                    end
                    if o.do_commspam then
                        -- Enemy, Help, Caution, Watch
                        for _, plr in pairs(players:GetPlayers()) do
                            if plr and not IsTeamMate(plr) and plr ~= localplayer and plr.Character and plr.Character.PrimaryPart then
                                __network:FireServer("Comm", commtypes[math.random(1, #commtypes)], plr.Character.PrimaryPart.Position)
                            end
                        end
                    end
                end
                if o.do_soundspam then
                    __network:FireServer("PlaySound", math.random(0, 1) == 0 and "Jump" or "JumpLand")
                end
                if o.do_chatspam then
                    __network:FireServer("ChatMessage", "Global", o.chatspam_msg)
                end
            end
        end
    end)
    runservice:BindToRenderStep("nameesptext", Enum.RenderPriority.Camera.Value + 5, function()
        for char, txt in pairs(esp_names) do
            local head = char:FindFirstChild("Head", true)
            if txt then
                if head and o.esp_names then
                    local pos = head.Position
                    txt.Color = Color3.new(1, 1, 1)
                    local w2s_point, isOnScreen = workspace.CurrentCamera:WorldToViewportPoint(pos)
                    if isOnScreen then
                        txt.Position = Vector2.new(w2s_point.X, w2s_point.Y)
                        txt.Text = char.Name
                        txt.Center = true
                        txt.Color = GetESPColor(char)
                        txt.Visible = true
                        continue
                    end
                end
                txt.Visible = false
            end
        end
    end)
    runservice.RenderStepped:Connect(function()
        if o.do_lagserver then
            local _, plr = find_first_viable_char()
            pcall(force_shoot, plr, 10000)
        end
    end)
    local IsDescendantOf = game.IsDescendantOf
    OldNewIndex = hookmetamethod(game, "__newindex", newcclosure(function(self, idx, val)
        if not checkcaller() then
            if IsA(self, "Highlight")
            and o.do_outlines
            and IsDescendantOf(self, characters)
            then
                if idx == "OutlineColor" then
                    val = GetESPColor(self.Parent)
                elseif idx == "DepthMode" then
                    val = Enum.HighlightDepthMode.AlwaysOnTop
                elseif idx == "Enabled" then
                    val = true
                elseif idx == "OutlineTransparency" then
                    val = 0
                end
            elseif IsA(self, "Humanoid")
            and o.speed_modifier > 1
            and IsDescendantOf(self, localplayer.Character)
            and idx == "WalkSpeed"
            and type(val) == "number"
            then
                val *= (o.speed_modifier / 10)
            end
        end
        return OldNewIndex(self, idx, val)
    end))--]]
    local current_camera = workspace.CurrentCamera
    workspace.Changed:Connect(function()
        current_camera = workspace.CurrentCamera
    end)
    OldIndex = hookmetamethod(game, "__index", newcclosure(function(self, idx)
        if not checkcaller() then
            if self == localplayer then
                if o.do_thirdperson then
                    if idx == "CameraMode" then
                        return Enum.CameraMode.Classic
                    elseif idx == "CameraMaxZoomDistance" or idx == "CameraMinZoomDistance" then
                        return 16
                    end
                else
                    if idx == "CameraMode" then
                        return Enum.CameraMode.LockFirstPerson
                    elseif idx == "CameraMaxZoomDistance" or idx == "CameraMinZoomDistance" then
                        return 0.5
                    end
                end
                if idx == "Name" or idx == "DisplayName" then
                    local f = debug.getinfo(3)
                    if o.spoofed_name ~= ""
                    and not string.match(f.source, "SpectateManager$")
                    then
                        return o.spoofed_name
                    end
                end
            elseif self == current_camera then
                if idx == "CFrame" and o.fov > 0 then
                    local R = 0.1 / (o.fov / MAX_FOV)
                    return OldIndex(self, idx) * CFrame.new(0, 0, 0, R, 0, 0, 0, R, 0, 0, 0, 1)
                end
            elseif IsA(self, "LocalScript") then
                if idx == "Disabled" then
                    return false
                end
            end
        end
        return OldIndex(self, idx)
    end))--]]
    local userinputservice = WaitForService("UserInputService")
    local lastPrimaryPosition = Vector3.zero
    local lastPrimaryRotOffset = Vector3.zero
    local prevDoGhosting = false
    local aa_spin_value = 0
    local aa_jitter_value = 1
    local aa_neck_value = 1
    runservice:BindToRenderStep("MouseLock", Enum.RenderPriority.Character.Value + 5, function()
        local char = localplayer.Character
        local camera = workspace.CurrentCamera
        local cameraCFrame = camera.CFrame
        local cameraLookVector = cameraCFrame.LookVector.Unit
        local primaryPart = char.PrimaryPart
        local head = char:FindFirstChild("Head")
        local lowerTorso = char:FindFirstChild("LowerTorso")
        local neck = head and head:FindFirstChild("Neck")
        local root = lowerTorso and lowerTorso:FindFirstChild("Root")
        local t_char = target and GetPlayerCharacter(target)
        local t_primaryPart = t_char and t_char.PrimaryPart
        if o.do_antiaim and neck and root then
            if o.antiaim_pitch == "Down" then
                neck.C0 = CFrame.new(neck.C0.Position) * CFrame.fromEulerAnglesXYZ(math.rad(-55), 0, 0)
            elseif o.antiaim_pitch == "Up" then
                neck.C0 = CFrame.new(neck.C0.Position) * CFrame.fromEulerAnglesXYZ(math.rad(55), 0, 0)
            elseif o.antiaim_pitch == "Random" then
                aa_neck_value = (aa_neck_value + 1) % 2
                neck.C0 = CFrame.new(neck.C0.Position) * CFrame.fromEulerAnglesXYZ(math.rad(aa_neck_value == 0 and -55 or 55), 0, 0)
            else
                neck.C0 = CFrame.new(neck.C0.Position)
            end
            local root_initial = CFrame.new(root.C0.Position)
            local root_offset = CFrame.identity
            if o.antiaim_yaw == "Backwards" then
                root_offset = CFrame.fromEulerAnglesXYZ(0, math.rad(180), 0)
            elseif o.antiaim_yaw == "Backwards Jitter" then
                aa_jitter_value = (aa_jitter_value + 1) % 2
                root_offset = CFrame.fromEulerAnglesXYZ(0, math.rad(aa_jitter_value == 0 and 175 or 185), 0)
            elseif o.antiaim_yaw == "Spin" then
                aa_spin_value = (aa_spin_value + 47) % 360
                root_offset = CFrame.fromEulerAnglesXYZ(0, math.rad(aa_spin_value), 0)
            end
            if o.antiaim_target == "Target" and target then
                if t_char and t_primaryPart then
                    root_initial = CFrame.lookAt(
                        root.C0.Position,
                        Vector3.new(t_primaryPart.Position.X,
                            root.C0.Position.Y,
                            t_primaryPart.Position.Z
                        )
                    )
                end
            end
            root.C0 = root_initial * root_offset
        elseif root and neck then
            neck.C0 = CFrame.new(neck.C0.Position)
            root.C0 = CFrame.new(root.C0.Position)
        end
        if char and primaryPart then
            local primaryPosition = primaryPart.Position
            local primaryRotOffset = primaryPosition + Vector3.new(cameraLookVector.X, 0, cameraLookVector.Z)
            if o.do_thirdperson then
                userinputservice.MouseBehavior = Enum.MouseBehavior.LockCenter
                char:PivotTo(CFrame.lookAt(primaryPosition, primaryRotOffset))
            end
            if doGhosting then
                if not prevDoGhosting then
                    lastPrimaryPosition = primaryPosition
                    lastPrimaryRotOffset = primaryRotOffset
                end
                local primaryPositionDelta = XZCompare(lastPrimaryPosition, primaryPosition).Magnitude
                if primaryPositionDelta > 2.5 then
                    char:PivotTo(CFrame.lookAt(lastPrimaryPosition, lastPrimaryRotOffset))
                end
            end
        end
        prevDoGhosting = doGhosting
    end)--]]

    library:Init()
    getgenv(0).__AHLOADED = true
    ok("AfoHub ready :D")
    WaitForService("StarterGui"):SetCore("SendNotification", { Title = "Welcome to AfoHub", Text = "Made by Afoxie on V3rm", Image = "rbxassetid://7091101767" })
    err_conn:Disconnect()
    --
--[[end, debug.traceback)
if not success then
    local genv = getgenv(0)
    local tb = string.split(msg, "\n")
    msg = tb[1]
    tb = select(2, tb)
    --genv.rconsoleclear()
    genv.rconsoleprint("@@YELLOW@@")
    genv.rconsoleprint("AfoHub did not initialize properly\n")
    genv.rconsoleprint("@@LIGHT_RED@@")
    genv.rconsoleprint(tostring(msg) .. "\n")
    genv.rconsoleprint("@@LIGHT_BLUE@@")
    genv.rconsoleprint("  Stack Begin\n")
    if type(tb) == "table" and #tb >= 1 then
        for _, c in ipairs(tb) do
            genv.rconsoleprint("  " .. tostring(c) .. "\n")
        end
    end
    genv.rconsoleprint("  Stack End\n")
    genv.messagebox(tostring(msg):gsub("^%w+%:", "Line "), "Uncaught Exception", 0)
    game:GetService("TeleportService"):Teleport(game.GameId, game:GetService("Players").LocalPlayer)
    error
    while task.wait() do genv.rconsoleinput() end
end--]]
