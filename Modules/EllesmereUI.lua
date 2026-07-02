-- QuickFocus module: EllesmereUI UnitFrames + RaidFrames.

QuickFocus:RegisterModule("EllesmereUI", function()
    local QF = QuickFocus

    -- ── EllesmereUIUnitFrames (oUF individual frames) ──────────────────
    local ufNames = {
        "EllesmereUIUnitFrames_Player",
        "EllesmereUIUnitFrames_Target",
        "EllesmereUIUnitFrames_Focus",
        "EllesmereUIUnitFrames_Pet",
        "EllesmereUIUnitFrames_TargetTarget",
        "EllesmereUIUnitFrames_FocusTarget",
        "EllesmereUIUnitFrames_Boss1",
        "EllesmereUIUnitFrames_Boss2",
        "EllesmereUIUnitFrames_Boss3",
        "EllesmereUIUnitFrames_Boss4",
        "EllesmereUIUnitFrames_Boss5",
    }
    for _, name in ipairs(ufNames) do
        QF:HookByName(name)
    end

    -- ── EllesmereUIRaidFrames (SecureGroupHeader children) ─────────────
    -- Headers: walk children to find dynamically-created unit buttons.
    local headerNames = {
        "ERFPartyHeader",
        "ERFFlatHeader",
        "ERFGroupHeader1", "ERFGroupHeader2", "ERFGroupHeader3", "ERFGroupHeader4",
        "ERFGroupHeader5", "ERFGroupHeader6", "ERFGroupHeader7", "ERFGroupHeader8",
    }
    for _, name in ipairs(headerNames) do
        QF:HookChildrenByName(name)
    end

    -- Named unit buttons (not inside headers).
    local buttonNames = {
        "ERFPartySelfButton",
        "ERFFriendlyBoss1", "ERFFriendlyBoss2", "ERFFriendlyBoss3",
        "ERFFriendlyBoss4", "ERFFriendlyBoss5",
    }
    for i = 1, 10 do
        buttonNames[#buttonNames + 1] = "ERFExtraFrame" .. i
    end
    for _, name in ipairs(buttonNames) do
        QF:HookByName(name)
    end
end)
