-- QuickFocus module: Blizzard default unit frames.

QuickFocus:RegisterModule("Blizzard", function()
    local QF = QuickFocus

    -- Single unit frames
    local singleFrames = {
        "PlayerFrame", "TargetFrame", "FocusFrame", "PetFrame",
        "TargetTargetFrame", "FocusTargetFrame",
    }
    for _, name in ipairs(singleFrames) do
        QF:HookByName(name)
    end

    -- Party frames
    for i = 1, 5 do
        QF:HookByName("PartyMemberFrame" .. i)
    end

    -- Compact raid frames
    QF:HookChildrenByName("CompactRaidFrameContainer")
end)
