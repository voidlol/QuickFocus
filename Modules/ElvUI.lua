-- QuickFocus module: ElvUI unit frames.

QuickFocus:RegisterModule("ElvUI", function()
    if not ElvUI or type(ElvUI) ~= "table" or not ElvUI[1] then return end

    local ok, UF = pcall(ElvUI[1].GetModule, ElvUI[1], "UnitFrames", true)
    if not ok or not UF then return end

    local QF = QuickFocus

    -- Individual unit frames (player, target, focus, pet, etc.)
    if UF.units then
        for _, frame in pairs(UF.units) do
            if frame then QF:HookFrame(frame) end
        end
    end

    -- Group unit frames
    if UF.groupunits then
        for _, frame in pairs(UF.groupunits) do
            if frame then QF:HookFrame(frame) end
        end
    end

    -- Group headers (party, raid, arena, boss)
    if UF.headers then
        for _, header in pairs(UF.headers) do
            if header then QF:HookChildren(header) end
        end
    end
end)
