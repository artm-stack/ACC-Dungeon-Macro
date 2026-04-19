#Requires AutoHotkey v2.0
#SingleInstance Force
#Include Lib\OCR.ahk

; ACC Modifier (modifier picker + manual team build subsystem)
; F6 = Toggle ON/OFF
; F7 = Force one pick
; F8 = Reset scores
; F9 = UPG Team Build (clear deck -> T -> Build -> Z)
; F10 = Exit
; F5 = Force stop macro/team build

global RUNNING := false
global WINDOW_TITLE := "Roblox"
global SETTINGS_DIR := A_ScriptDir "\Settings"
global SAVE_FILE := SETTINGS_DIR "\modifier_scores.ini"
global RANK_FILE := SETTINGS_DIR "\modifier_ranks.ini"
global REGION_FILE := SETTINGS_DIR "\region.ini"
global LEGACY_REGION_FILE := SETTINGS_DIR "\modifier_only_regions.ini"
global TEAM_CONFIG_FILE := SETTINGS_DIR "\team_cards.ini"
global LOG_FILE := A_ScriptDir "\ACC_mod.log"

global LAST_PICK_TICK := 0
global CLICK_COOLDOWN_MS := 2000
global PICK_REGISTER_DELAY_MS := 450
global PICK_REGISTER_RETRIES := 2
global DUPLICATE_PICK_GUARD_MS := 10000
global LAST_PICK_SIGNATURE := ""
global LAST_PICK_SIGNATURE_TICK := 0
global IS_BUSY := false
global LAST_ACTION := "Idle"
global MAIN_SCAN_INTERVAL_MS := 200
global AUTO_JUMP_ENABLED := true
global AUTO_MINIMIZE_ENABLED := false
global AUTO_JUMP_TICK := 0
global AUTO_JUMP_COOLDOWN_MS := 300000
global PICK_SHAKE_ENABLED := true
global PICK_SHAKE_PX := 5
global PICK_SHAKE_DELAY_MS := 20
global PICK_SHAKE_JITTER_PX := 3
global PICK_SHAKE_JITTER_DELAY_MS := 18
global OVERLAY_ENABLED := false
global REGION_EDITORS := []
global REGION_SYNC_TIMER_MS := 120

global LAST_Z_TICK := 0
global Z_COOLDOWN_MS := 1200
global Z_PRESS_RETRIES := 2
global Z_PRESS_GAP_MS := 90

global TEAM_OPEN_KEY := "t"
global TEAM_CLOSE_KEY := "z"
global TEAM_ACTION_DELAY_MS := 150
global TEAM_POST_PASTE_DELAY_MS := 240
global TEAM_PRE_PICK_DELAY_MS := 180
global TEAM_PICK_DELAY_MS := 280
global TEAM_ADD_DELAY_MS := 220
global TEAM_PRE_E_DELAY_MS := 110
global TEAM_POST_E_DELAY_MS := 140
global TEAM_ADD_E_PRESSES := 1
global TEAM_ADD_E_GAP_MS := 90
global TEAM_ADD_OCR_CONFIRM := true
global TEAM_ADD_OCR_RETRIES := 1
global TEAM_ADD_OCR_DELAY_MS := 120
global TEAM_UI_OPEN_RETRIES := 3
global TEAM_UI_OPEN_DELAY_MS := 220
global TEAM_UI_VERIFY_DELAY_MS := 120
global TEAM_VERIFY_SEARCH_TEXT := true
global TEAM_SEARCH_VERIFY_RETRIES := 2
global TEAM_SEARCH_VERIFY_DELAY_MS := 120
global TEAM_SEARCH_REPASTE_RETRIES := 2
global TEAM_SEARCH_REPASTE_DELAY_MS := 140
global TEAM_NO_CARDS_CHECK_ENABLED := true
global TEAM_STICKY_PICK_MAX_ATTEMPTS := 0
global TEAM_STICKY_PICK_RETRY_DELAY_MS := 140
global TEAM_PICK_SHAKE_ENABLED := true
global TEAM_PICK_SHAKE_PX := 5
global TEAM_PICK_SHAKE_DELAY_MS := 20
global TEAM_SHAKE_ALL_CLICKS := true
global TEAM_BUILD_STOP_REQUESTED := false
global LAST_TEAM_PICK_FAIL_REASON := ""
global LAST_SET_ABORT_UNAVAILABLE := false
global LAST_TEAM_UI_OCR_RAW := ""
global LAST_TEAM_UI_OCR_NORM := ""
global AUTO_CLOSE_TEAM_WITH_Z := true
global AUTO_CLOSE_Z_DELAY_MS := 120
global ADD_PARTY_KEY := "e"
global SEARCH_MATCH_DIST_SHORT := 2
global SEARCH_MATCH_DIST_LONG := 3

global Ui := 0
global UiStatus := 0
global UiAction := 0
global UiScores := 0
global UiAutoJump := 0
global UiAutoMinimize := 0
global UiSlotDetect := 0
global UiBtnToggle := 0
global UiRankEditor := 0
global UiRankInputs := Map()

global SLOT_DETECT_1 := "(none)"
global SLOT_DETECT_2 := "(none)"
global SLOT_DETECT_3 := "(none)"
global SLOT_DETECT_SELECTED := 0

global OCR_ENABLED := true
global OCR_OPTIONS_DEFAULT := Map("scale", 3.0, "grayscale", true, "invertcolors", false, "monochrome", 0)
global OCR_OPTIONS_SLOT := Map("scale", 4.0, "grayscale", true, "invertcolors", false, "monochrome", 140)
global OCR_OPTIONS_HEADER := Map("scale", 3.0, "grayscale", true, "invertcolors", false, "monochrome", 110)
global OCR_OPTIONS_ITEM := Map("scale", 4.0, "grayscale", true, "invertcolors", false, "monochrome", 120)
global MODIFIER_MATCH_MIN_SCORE := 52

global ITEM_REGION := Map("x1", 885, "y1", 619, "x2", 1055, "y2", 960)
global HIDE_REGION := Map("x1", 885, "y1", 619, "x2", 1055, "y2", 960)
global SCREEN_CHECK_REGION := Map("x1", 800, "y1", 266, "x2", 1118, "y2", 322)
global TEAM_UI_CHECK_REGION := Map("x1", 633, "y1", 145, "x2", 747, "y2", 211)
global TEAM_SEARCH_REGION := Map("x1", 1666, "y1", 155, "x2", 1719, "y2", 195)
global SEARCH_VERIFY_REGION := Map("x1", 1331, "y1", 151, "x2", 1723, "y2", 199)
global SEARCH_UNFOCUS_REGION := Map("x1", 1294, "y1", 248, "x2", 1349, "y2", 295)
global CARD_PICK_REGION := Map("x1", 624, "y1", 345, "x2", 681, "y2", 399)
global ADD_PARTY_REGION := Map("x1", 1278, "y1", 928, "x2", 1454, "y2", 1000)
global ATTACK_TAB_REGION := Map("x1", 595, "y1", 246, "x2", 715, "y2", 286)
global SUPPORT_TAB_REGION := Map("x1", 751, "y1", 246, "x2", 864, "y2", 286)
global NO_CARDS_REGION := Map("x1", 884, "y1", 583, "x2", 1464, "y2", 628)
global REMOVE_ATTACK_REGION := Map("x1", 389, "y1", 227, "x2", 446, "y2", 281)
global REMOVE_SUPPORT_REGION := Map("x1", 193, "y1", 227, "x2", 250, "y2", 281)
global SLOT_REGIONS := [
    Map("name", "Slot 1", "x1", 455, "y1", 559, "x2", 761, "y2", 662, "clickX", 608, "clickY", 611),
    Map("name", "Slot 2", "x1", 806, "y1", 559, "x2", 1113, "y2", 662, "clickX", 959, "clickY", 610),
    Map("name", "Slot 3", "x1", 1156, "y1", 559, "x2", 1466, "y2", 662, "clickX", 1311, "clickY", 610)
]

; Lower rank = higher priority
global MODIFIERS := [
    Map("name", "Defense", "score", 0, "defaultScore", 0, "max", 6,  "rank", 1, "defaultRank", 1, "aliases", ["heavy defense", "defense"]),
    Map("name", "Health", "score", 0, "defaultScore", 0, "max", 10, "rank", 2, "defaultRank", 2, "aliases", ["health buff", "health"]),
    Map("name", "Piercing", "score", 0, "defaultScore", 0, "max", "", "rank", 3, "defaultRank", 3, "aliases", ["piercing blow", "piercing"]),
    Map("name", "Healing", "score", 0, "defaultScore", 0, "max", 7, "rank", 4, "defaultRank", 4, "aliases", ["healing touch", "healing"]),
    Map("name", "Damage", "score", 0, "defaultScore", 0, "max", 10, "rank", 5, "defaultRank", 5, "aliases", ["damage buff", "damage"]),
    Map("name", "Bloodthirst", "score", 0, "defaultScore", 0, "max", 15, "rank", 6, "defaultRank", 6, "aliases", ["bloodthirst"]),
    Map("name", "Ackerman", "score", 0, "defaultScore", 0, "max", "", "rank", 7, "defaultRank", 7, "aliases", ["ackerman support", "ackerman"]),
    Map("name", "Lucky", "score", 0, "defaultScore", 0, "max", "", "rank", 8, "defaultRank", 8, "aliases", ["lucky hand", "lucky"]),
    Map("name", "High Roller", "score", 0, "defaultScore", 0, "max", "", "rank", 9, "defaultRank", 9, "aliases", ["high roller", "roller"])
]

global PRIMARY_ATTACK_CARDS := ["Cosmic Villain", "Awakened Eclipseborn Hawk", "King of Helheim | The Almighty", "Divine Emperor | Lion of Justice | Wrathful Sin"]
global SECONDARY_ATTACK_CARDS := ["Cosmic Villain", "Awakened Eclipseborn Hawk", "Divine Emperor | Lion of Justice | Wrathful Sin", "Herald of Fate | Sacred Arch Priestess"]
global PRIMARY_SUPPORT_CARDS := ["Binding Vow", "Binding Vow", "Demonic Gift", "Binding Vow"]
global SECONDARY_SUPPORT_CARDS := ["Binding Vow", "Binding Light", "Binding Vow", "Binding Vow"]
global SUPPORT_FALLBACK_CARDS := ["Binding Vow", "Binding Light", "Demonic Gift"]
global ATTACK_CARD_SETS := []
global SUPPORT_CARD_SETS := []

CoordMode("Pixel", "Client")
CoordMode("Mouse", "Client")
InitOCR()
LoadRegions()
LoadScores()
LoadRanks()
LoadTeamCardConfig()
InitGui()
UpdateGui()
Log("Modifier-only script started")

F4::ToggleOverlay()
F6::ToggleMacro()
F7::ManualPick()
F8::ResetScores()
F9::ManualTeamBuild()
F10::ExitScript()
F5::ForceStopMacro()

ToggleMacro(*) {
    global RUNNING, LAST_ACTION, TEAM_BUILD_STOP_REQUESTED
    TEAM_BUILD_STOP_REQUESTED := false
    RUNNING := !RUNNING
    if RUNNING
        SetTimer(WatchModifierScreen, MAIN_SCAN_INTERVAL_MS)
    else
        SetTimer(WatchModifierScreen, 0)

    msg := RUNNING ? "Modifier-only macro ON" : "Modifier-only macro OFF"
    LAST_ACTION := msg
    Log(msg)
    ShowTip(msg)
    UpdateGui()
    if RUNNING
        MaybeAutoMinimizeUi()
}

ForceStopMacro(*) {
    global RUNNING, LAST_ACTION, TEAM_BUILD_STOP_REQUESTED
    RUNNING := false
    TEAM_BUILD_STOP_REQUESTED := true
    SetTimer(WatchModifierScreen, 0)
    LAST_ACTION := "FORCE STOP triggered"
    Log(LAST_ACTION)
    ShowTip(LAST_ACTION)
    UpdateGui()
}

MinimizeMainUi(*) {
    global Ui
    if IsObject(Ui) {
        try Ui.Minimize()
    }
}

MaybeAutoMinimizeUi() {
    global AUTO_MINIMIZE_ENABLED
    if AUTO_MINIMIZE_ENABLED
        MinimizeMainUi()
}

ManualPick(*) {
    global LAST_ACTION
    if !EnsureRoblox() {
        LAST_ACTION := "Roblox window not found"
        ShowTip("Roblox window not found")
        UpdateGui()
        return
    }
    if !IsModifierScreenOpen() {
        LAST_ACTION := "Modifier screen not detected"
        ShowTip("Modifier screen not detected")
        UpdateGui()
        return
    }
    PickBestSlot()
    UpdateGui()
    MaybeAutoMinimizeUi()
}

ManualTeamBuild(*) {
    global LAST_ACTION, TEAM_BUILD_STOP_REQUESTED
    pickedAttack := 0
    pickedSupport := 0
    if !EnsureRoblox() {
        LAST_ACTION := "Build Team failed: Roblox window not found"
        Log(LAST_ACTION)
        ShowTip(LAST_ACTION)
        UpdateGui()
        return
    }

    TEAM_BUILD_STOP_REQUESTED := false
    MaybeAutoMinimizeUi()
    ok := BuildTeamFromConfig(&pickedAttack, &pickedSupport, true)
    if ok
        LAST_ACTION := "Build Team done (ATK=" pickedAttack ", SUP=" pickedSupport ")"
    else
        LAST_ACTION := "Build Team failed: Team UI Deck OCR not detected"
    Log(LAST_ACTION)
    ShowTip(LAST_ACTION)
    UpdateGui()
}

BuildTeamFromConfig(&pickedAttack, &pickedSupport, clearDeck := false) {
    global ATTACK_CARD_SETS, SUPPORT_CARD_SETS, SUPPORT_FALLBACK_CARDS
    global AUTO_CLOSE_TEAM_WITH_Z
    global LAST_SET_ABORT_UNAVAILABLE

    pickedAttack := 0
    pickedSupport := 0
    chosenAttackSetIdx := 0

    if TeamBuildShouldStop()
        return false

    if !OpenTeamProgress()
        return false
    if TeamBuildShouldStop()
        return false

    if clearDeck
        ClearDeckForUpgrade()

    SelectAttackTab()
    if TeamBuildShouldStop()
        return false

    for idx, setCards in ATTACK_CARD_SETS {
        if (pickedAttack >= 4)
            break
        pickedAttack += SelectCardSetBySearch(setCards, "Attack Team #" idx, pickedAttack, true)
        if (pickedAttack >= 4) {
            chosenAttackSetIdx := idx
            break
        }
        if (pickedAttack < 4 && LAST_SET_ABORT_UNAVAILABLE) {
            Log("Attack Team #" idx " unavailable -> clearing attack picks before next set")
            RemoveAttackCardsForReteam()
            pickedAttack := 0
        }
    }

    if (chosenAttackSetIdx = 0) {
        Log("Build Team failed: no attack set completed")
        if AUTO_CLOSE_TEAM_WITH_Z && !TeamBuildShouldStop()
            CloseUiWithZ("Team UI")
        return false
    }

    SelectSupportTab()
    if TeamBuildShouldStop()
        return false

    supportStartIdx := (chosenAttackSetIdx > 0) ? chosenAttackSetIdx : 1
    for idx, setCards in SUPPORT_CARD_SETS {
        if (idx < supportStartIdx)
            continue
        if (pickedSupport >= 4)
            break
        pickedSupport += SelectCardSetBySearch(setCards, "Support Team #" idx, pickedSupport, true)
        if (pickedSupport < 4 && LAST_SET_ABORT_UNAVAILABLE) {
            Log("Support Team #" idx " unavailable -> clearing support picks before next set")
            RemoveSupportCardsForReteam()
            pickedSupport := 0
        }
    }

    if (pickedSupport < 4)
        pickedSupport += FillRemainingByFallbackCards(4 - pickedSupport, SUPPORT_FALLBACK_CARDS)

    if AUTO_CLOSE_TEAM_WITH_Z && !TeamBuildShouldStop()
        CloseUiWithZ("Team UI")

    return true
}

TeamBuildShouldStop() {
    global TEAM_BUILD_STOP_REQUESTED
    return TEAM_BUILD_STOP_REQUESTED
}

OpenTeamProgress() {
    global LAST_TEAM_UI_OCR_RAW, LAST_TEAM_UI_OCR_NORM
    if EnsureTeamUiOpen()
        return true
    Log("Team UI OCR not detected after open retries | raw=`"" LAST_TEAM_UI_OCR_RAW "`" norm=`"" LAST_TEAM_UI_OCR_NORM "`"")
    return false
}

EnsureTeamUiOpen() {
    global TEAM_OPEN_KEY, TEAM_UI_OPEN_RETRIES, TEAM_UI_OPEN_DELAY_MS, TEAM_UI_VERIFY_DELAY_MS
    if IsTeamUiOpen(true, "precheck")
        return true

    attempts := Max(1, TEAM_UI_OPEN_RETRIES + 1)
    Loop attempts {
        SendEvent("{" TEAM_OPEN_KEY "}")
        Sleep TEAM_UI_OPEN_DELAY_MS
        if IsTeamUiOpen(true, "attempt " A_Index " sendevent")
            return true

        SendGameKey(TEAM_OPEN_KEY, 1, 0)
        Sleep TEAM_UI_OPEN_DELAY_MS
        if IsTeamUiOpen(true, "attempt " A_Index " sendgamekey")
            return true

        Sleep TEAM_UI_VERIFY_DELAY_MS
        if IsTeamUiOpen(true, "attempt " A_Index " verify")
            return true
    }
    return false
}

IsTeamUiOpen(logSeen := false, source := "") {
    global TEAM_UI_CHECK_REGION, SEARCH_VERIFY_REGION, OCR_OPTIONS_HEADER, OCR_OPTIONS_DEFAULT, OCR_OPTIONS_SLOT
    global LAST_TEAM_UI_OCR_RAW, LAST_TEAM_UI_OCR_NORM
    LAST_TEAM_UI_OCR_RAW := ""
    LAST_TEAM_UI_OCR_NORM := ""

    checks := [
        Map("label", "TeamUiCheck", "region", TEAM_UI_CHECK_REGION, "opt", OCR_OPTIONS_HEADER),
        Map("label", "TeamUiCheck", "region", TEAM_UI_CHECK_REGION, "opt", OCR_OPTIONS_DEFAULT),
        Map("label", "TeamUiCheck", "region", TEAM_UI_CHECK_REGION, "opt", OCR_OPTIONS_SLOT),
        Map("label", "SearchVerify", "region", SEARCH_VERIFY_REGION, "opt", OCR_OPTIONS_HEADER),
        Map("label", "SearchVerify", "region", SEARCH_VERIFY_REGION, "opt", OCR_OPTIONS_DEFAULT)
    ]

    for check in checks {
        text := OCRTextFromRegion(check["region"], check["opt"])
        norm := NormalizeText(text)
        if (norm != "") {
            LAST_TEAM_UI_OCR_RAW := text
            LAST_TEAM_UI_OCR_NORM := norm
        }
        if logSeen {
            tag := (source != "") ? " [" source "]" : ""
            Log("Team UI OCR" tag " " check["label"] " raw=`"" text "`" norm=`"" norm "`"")
        }
        if TextLooksLikeDeck(norm) || InStr(norm, "search")
            return true
    }
    return false
}

TextLooksLikeDeck(norm) {
    if (norm = "")
        return false
    if InStr(norm, "deck")
        return true
    if RegExMatch(norm, "d[3e]?[ck]{1,2}")
        return true
    if RegExMatch(norm, "^dck")
        return true
    if RegExMatch(norm, "d[a-z0-9]{0,2}c?k")
        return true
    return false
}

IsNoCardsMessageVisible(logSeen := false, source := "") {
    global NO_CARDS_REGION, OCR_OPTIONS_DEFAULT, OCR_OPTIONS_SLOT
    text := OCRTextFromRegion(NO_CARDS_REGION, OCR_OPTIONS_DEFAULT)
    if (text = "")
        text := OCRTextFromRegion(NO_CARDS_REGION, OCR_OPTIONS_SLOT)
    norm := NormalizeText(text)
    if logSeen {
        tag := (source != "") ? " [" source "]" : ""
        Log("No Cards OCR" tag " raw=`"" text "`" norm=`"" norm "`"")
    }
    if (norm = "")
        return false
    hasNoCards := InStr(norm, "nocards")
    hasDeck := InStr(norm, "deck")
    hasFilter := InStr(norm, "filter")
    hasMeet := InStr(norm, "meet")
    return ((hasNoCards && hasDeck && hasFilter) || (hasNoCards && hasMeet && hasFilter))
}

SelectAttackTab() {
    global ATTACK_TAB_REGION
    ClickTabReliable(ATTACK_TAB_REGION, "Attack Tab")
}

SelectSupportTab() {
    global SUPPORT_TAB_REGION
    ClickTabReliable(SUPPORT_TAB_REGION, "Support Tab")
}

ClickTabReliable(tabRegion, label := "Tab") {
    Loop 3 {
        ClickRegionCenter(tabRegion, label)
        Sleep 140
    }
}

SelectCardSetBySearch(cards, setLabel := "Team", startCount := 0, abortSetOnUnavailable := false) {
    global TEAM_STICKY_PICK_MAX_ATTEMPTS, TEAM_STICKY_PICK_RETRY_DELAY_MS
    global LAST_TEAM_PICK_FAIL_REASON, LAST_SET_ABORT_UNAVAILABLE
    picked := startCount
    LAST_SET_ABORT_UNAVAILABLE := false

    for card in cards {
        if (picked >= 4)
            break

        attempts := 0
        while true {
            if TeamBuildShouldStop()
                return picked - startCount

            if SearchAndPickCard(card, picked + 1) {
                picked += 1
                break
            }

            if (abortSetOnUnavailable && LAST_TEAM_PICK_FAIL_REASON = "no_cards") {
                LAST_SET_ABORT_UNAVAILABLE := true
                Log(setLabel ": card unavailable, aborting set -> " card)
                return picked - startCount
            }

            attempts += 1
            if (TEAM_STICKY_PICK_MAX_ATTEMPTS > 0 && attempts >= TEAM_STICKY_PICK_MAX_ATTEMPTS)
                break
            Sleep TEAM_STICKY_PICK_RETRY_DELAY_MS
        }
    }
    return picked - startCount
}

SearchAndPickCard(cardName, pickIndex := 1) {
    global TEAM_SEARCH_REGION, SEARCH_UNFOCUS_REGION
    global TEAM_POST_PASTE_DELAY_MS, TEAM_PRE_PICK_DELAY_MS, TEAM_PICK_DELAY_MS, TEAM_ADD_DELAY_MS
    global TEAM_VERIFY_SEARCH_TEXT, TEAM_SEARCH_REPASTE_RETRIES, TEAM_SEARCH_REPASTE_DELAY_MS
    global TEAM_NO_CARDS_CHECK_ENABLED, LAST_TEAM_PICK_FAIL_REASON

    alternatives := ParseCardAlternatives(cardName)
    if (alternatives.Length = 0)
        alternatives.Push(cardName)

    for _, candidate in alternatives {
        LAST_TEAM_PICK_FAIL_REASON := ""
        if !FocusRegion(TEAM_SEARCH_REGION, "Team Search")
        {
            LAST_TEAM_PICK_FAIL_REASON := "focus_failed"
            return false
        }
        Sleep 40
        ClickRegionCenter(TEAM_SEARCH_REGION, "Search Confirm")
        Sleep 70

        if TEAM_VERIFY_SEARCH_TEXT {
            verified := false
            attempts := Max(1, TEAM_SEARCH_REPASTE_RETRIES + 1)
            Loop attempts {
                if TeamBuildShouldStop()
                {
                    LAST_TEAM_PICK_FAIL_REASON := "stopped"
                    return false
                }
                if !PasteCardNameIntoSearch(candidate) {
                    LAST_TEAM_PICK_FAIL_REASON := "clipboard_failed"
                    return false
                }
                Sleep TEAM_POST_PASTE_DELAY_MS
                ClickRegionCenter(SEARCH_UNFOCUS_REGION, "Search Unfocus")
                Sleep 120
                if VerifySearchTextInput(candidate) {
                    verified := true
                    break
                }
                if (A_Index < attempts) {
                    ClickRegionCenter(TEAM_SEARCH_REGION, "Team Search Retry")
                    Sleep TEAM_SEARCH_REPASTE_DELAY_MS
                }
            }
            if !verified {
                LAST_TEAM_PICK_FAIL_REASON := "search_verify_failed"
                continue
            }
        } else {
            if TeamBuildShouldStop()
            {
                LAST_TEAM_PICK_FAIL_REASON := "stopped"
                return false
            }
            if !PasteCardNameIntoSearch(candidate) {
                LAST_TEAM_PICK_FAIL_REASON := "clipboard_failed"
                return false
            }
            Sleep TEAM_POST_PASTE_DELAY_MS
            ClickRegionCenter(SEARCH_UNFOCUS_REGION, "Search Unfocus")
            Sleep 120
        }

        if TEAM_NO_CARDS_CHECK_ENABLED && IsNoCardsMessageVisible(true, "search " candidate) {
            LAST_TEAM_PICK_FAIL_REASON := "no_cards"
            continue
        }

        Sleep TEAM_PRE_PICK_DELAY_MS
        PerformCardPickClick()
        Sleep TEAM_PICK_DELAY_MS
        if !TriggerAddParty() {
            LAST_TEAM_PICK_FAIL_REASON := "add_confirm_failed"
            return false
        }
        Sleep TEAM_ADD_DELAY_MS
        LAST_TEAM_PICK_FAIL_REASON := ""
        return true
    }

    if (LAST_TEAM_PICK_FAIL_REASON = "")
        LAST_TEAM_PICK_FAIL_REASON := "no_cards"
    return false
}

ParseCardAlternatives(cardSpec) {
    out := []
    for part in StrSplit(cardSpec, "|") {
        candidate := Trim(part)
        if (candidate != "")
            out.Push(candidate)
    }
    return out
}

PasteCardNameIntoSearch(cardName) {
    try {
        SendEvent("^a")
        Sleep 40
        SendText(cardName)
        return true
    } catch Error as e {
        Log("PasteCardNameIntoSearch failed: " e.Message)
        return false
    }
}

VerifySearchTextInput(expectedCardName) {
    global SEARCH_VERIFY_REGION, OCR_OPTIONS_DEFAULT, OCR_OPTIONS_SLOT
    global TEAM_SEARCH_VERIFY_RETRIES, TEAM_SEARCH_VERIFY_DELAY_MS
    expectedNorm := NormalizeText(expectedCardName)
    if (expectedNorm = "")
        return false

    attempts := Max(1, TEAM_SEARCH_VERIFY_RETRIES + 1)
    Loop attempts {
        raw := OCRTextFromRegion(SEARCH_VERIFY_REGION, OCR_OPTIONS_DEFAULT)
        if (raw = "")
            raw := OCRTextFromRegion(SEARCH_VERIFY_REGION, OCR_OPTIONS_SLOT)
        gotNorm := NormalizeText(raw)
        if InStr(gotNorm, "search")
            gotNorm := RegExReplace(gotNorm, "^search")
        if IsCardNameOcrMatch(expectedNorm, gotNorm)
            return true
        if (A_Index < attempts)
            Sleep TEAM_SEARCH_VERIFY_DELAY_MS
    }
    return false
}

IsCardNameOcrMatch(expectedNorm, gotNorm) {
    global SEARCH_MATCH_DIST_SHORT, SEARCH_MATCH_DIST_LONG
    if (expectedNorm = "" || gotNorm = "")
        return false
    if (gotNorm = expectedNorm)
        return true
    dist := LevenshteinDistance(expectedNorm, gotNorm)
    maxLen := Max(StrLen(expectedNorm), StrLen(gotNorm))
    if (maxLen >= 14)
        return dist <= SEARCH_MATCH_DIST_LONG
    return dist <= SEARCH_MATCH_DIST_SHORT
}

LevenshteinDistance(a, b) {
    lenA := StrLen(a)
    lenB := StrLen(b)
    if (lenA = 0)
        return lenB
    if (lenB = 0)
        return lenA
    prev := []
    Loop lenB + 1
        prev.Push(A_Index - 1)

    Loop lenA {
        i := A_Index
        curr := [i]
        chA := SubStr(a, i, 1)
        Loop lenB {
            j := A_Index
            chB := SubStr(b, j, 1)
            cost := (chA = chB) ? 0 : 1
            del := prev[j + 1] + 1
            ins := curr[j] + 1
            sub := prev[j] + cost
            curr.Push(Min(del, ins, sub))
        }
        prev := curr
    }
    return prev[lenB + 1]
}

FillRemainingByFallbackCards(needed, fallbackCards) {
    picked := 0
    if (needed <= 0)
        return 0
    for card in fallbackCards {
        if (picked >= needed)
            break
        if TeamBuildShouldStop()
            break
        if SearchAndPickCard(card, picked + 1)
            picked += 1
    }
    return picked
}

TriggerAddParty() {
    global ADD_PARTY_KEY, TEAM_PRE_E_DELAY_MS, TEAM_POST_E_DELAY_MS, TEAM_ADD_E_PRESSES, TEAM_ADD_E_GAP_MS
    global TEAM_ADD_OCR_CONFIRM, TEAM_ADD_OCR_RETRIES, TEAM_ADD_OCR_DELAY_MS
    attempts := Max(1, TEAM_ADD_OCR_RETRIES + 1)
    Loop attempts {
        if TeamBuildShouldStop()
            return false
        Sleep TEAM_PRE_E_DELAY_MS
        SendGameKey(ADD_PARTY_KEY, TEAM_ADD_E_PRESSES, TEAM_ADD_E_GAP_MS)
        Sleep TEAM_POST_E_DELAY_MS
        if !TEAM_ADD_OCR_CONFIRM
            return true
        if IsTeamUiOpen()
            return true
        if (A_Index < attempts)
            Sleep TEAM_ADD_OCR_DELAY_MS
    }
    return false
}

PerformCardPickClick(label := "Card Pick") {
    global SEARCH_UNFOCUS_REGION, CARD_PICK_REGION, TEAM_PICK_SHAKE_ENABLED
    ClickRegionCenter(SEARCH_UNFOCUS_REGION, "Search Defocus")
    Sleep 120
    if TEAM_PICK_SHAKE_ENABLED
        ShakeClickRegion(CARD_PICK_REGION, label)
    else
        ClickRegionCenter(CARD_PICK_REGION, label)
    Sleep 90
    if TEAM_PICK_SHAKE_ENABLED
        ShakeClickRegion(CARD_PICK_REGION, label " Confirm")
    else
        ClickRegionCenter(CARD_PICK_REGION, label " Confirm")
}

ShakeClickRegion(region, label := "") {
    global TEAM_PICK_SHAKE_PX, TEAM_PICK_SHAKE_DELAY_MS
    if !EnsureRoblox()
        return false
    cx := RegionCenterX(region)
    cy := RegionCenterY(region)
    s := Max(1, TEAM_PICK_SHAKE_PX)
    d := Max(1, TEAM_PICK_SHAKE_DELAY_MS)
    MouseMove(cx - s, cy, 0)
    Sleep d
    MouseMove(cx + s, cy, 0)
    Sleep d
    MouseMove(cx, cy - s, 0)
    Sleep d
    MouseMove(cx, cy + s, 0)
    Sleep d
    MouseMove(cx, cy, 0)
    Sleep d
    Click(cx, cy)
    return true
}

CloseUiWithZ(label := "UI") {
    global TEAM_CLOSE_KEY, AUTO_CLOSE_Z_DELAY_MS
    SendGameKey(TEAM_CLOSE_KEY, 1, 0)
    Sleep AUTO_CLOSE_Z_DELAY_MS
    Log(label " closed with " StrUpper(TEAM_CLOSE_KEY))
}

RemoveAttackCardsForReteam() {
    global REMOVE_ATTACK_REGION
    RemoveCardsByRegion(REMOVE_ATTACK_REGION, "Remove Attack", 6)
}

RemoveSupportCardsForReteam() {
    global REMOVE_SUPPORT_REGION
    RemoveCardsByRegion(REMOVE_SUPPORT_REGION, "Remove Support", 6)
}

ClearDeckForUpgrade() {
    RemoveAttackCardsForReteam()
    RemoveSupportCardsForReteam()
}

RemoveCardsByRegion(region, label, passes := 6) {
    global TEAM_ACTION_DELAY_MS
    Loop passes {
        if TeamBuildShouldStop()
            break
        ClickRegionCenter(region, label)
        Sleep TEAM_ACTION_DELAY_MS
    }
}

WatchModifierScreen() {
    global RUNNING, IS_BUSY, LAST_PICK_TICK, CLICK_COOLDOWN_MS
    if !RUNNING
        return
    if IS_BUSY
        return

    IS_BUSY := true
    try {
        if !EnsureRoblox()
            return

        if AUTO_JUMP_ENABLED
            MaybeAutoJump()

        if HandleItemPrompt()
            return

        if (A_TickCount - LAST_PICK_TICK < CLICK_COOLDOWN_MS)
            return

        if !IsModifierScreenOpen()
            return

        if PickBestSlot()
            LAST_PICK_TICK := A_TickCount
    } finally {
        IS_BUSY := false
    }
}

MaybeAutoJump() {
    global AUTO_JUMP_TICK, AUTO_JUMP_COOLDOWN_MS, LAST_ACTION
    if (A_TickCount - AUTO_JUMP_TICK < AUTO_JUMP_COOLDOWN_MS)
        return false
    if !EnsureRoblox()
        return false

    SendEvent("{Space}")
    AUTO_JUMP_TICK := A_TickCount
    LAST_ACTION := "Auto Jump executed (Space)"
    Log(LAST_ACTION)
    UpdateGui()
    return true
}

EnsureRoblox() {
    hwnd := WinExist(WINDOW_TITLE)
    if !hwnd
        return 0
    if !WinActive("ahk_id " hwnd) {
        WinActivate("ahk_id " hwnd)
        try WinWaitActive("ahk_id " hwnd, , 1)
    }
    return WinActive("ahk_id " hwnd) ? hwnd : 0
}

HandleItemPrompt() {
    global ITEM_REGION, HIDE_REGION, LAST_Z_TICK, Z_COOLDOWN_MS
    if (A_TickCount - LAST_Z_TICK < Z_COOLDOWN_MS)
        return false

    textDismiss := OCRTextFromRegion(ITEM_REGION, OCR_OPTIONS_ITEM)
    if (textDismiss = "")
        textDismiss := OCRTextFromRegion(ITEM_REGION, OCR_OPTIONS_DEFAULT)
    if LooksLikePromptText(NormalizeText(textDismiss), "dismiss")
        return HandlePromptPressZ("Detected dismiss -> pressed Z", textDismiss)

    textHide := OCRTextFromRegion(HIDE_REGION, OCR_OPTIONS_ITEM)
    if (textHide = "")
        textHide := OCRTextFromRegion(HIDE_REGION, OCR_OPTIONS_DEFAULT)
    if LooksLikePromptText(NormalizeText(textHide), "hide")
        return HandlePromptPressZ("Detected hide -> pressed Z", textHide)

    return false
}

LooksLikePromptText(norm, kind := "dismiss") {
    if (norm = "")
        return false
    if (kind = "hide")
        return InStr(norm, "tohide") || InStr(norm, "hide")
    return InStr(norm, "todismiss") || InStr(norm, "dismiss")
}

HandlePromptPressZ(actionText, ocrText := "") {
    global LAST_Z_TICK, LAST_ACTION
    if !EnsureRoblox()
        return false

    attempts := Max(1, Z_PRESS_RETRIES)
    Loop attempts {
        SendGameKey("z", 1, 0)
        Sleep Z_PRESS_GAP_MS
        if (A_Index < attempts)
            SendEvent("{z}")
    }
    LAST_Z_TICK := A_TickCount
    LAST_ACTION := actionText
    Log(actionText (ocrText != "" ? " | OCR=`"" ocrText "`"" : ""))
    UpdateGui()
    return true
}

IsModifierScreenOpen() {
    headerText := OCRTextFromRegion(SCREEN_CHECK_REGION, OCR_OPTIONS_HEADER)
    headerNorm := NormalizeText(headerText)
    looks := InStr(headerNorm, "chooseamodifier")
        || (InStr(headerNorm, "choose") && InStr(headerNorm, "modifier"))
        || RegExMatch(headerNorm, "choose[a-z0-9]*mod")
        || RegExMatch(headerNorm, "modif[a-z0-9]*")
    if !looks
        return false

    detections := []
    detected := 0
    for slot in SLOT_REGIONS {
        d := DetectModifierInSlotDetailed(slot)
        detections.Push(d)
        if IsObject(d["mod"])
            detected += 1
    }
    UpdateSlotDetectionState(detections, true)
    return detected >= 1
}

PickBestSlot() {
    global LAST_ACTION, LAST_PICK_TICK, DUPLICATE_PICK_GUARD_MS, LAST_PICK_SIGNATURE, LAST_PICK_SIGNATURE_TICK
    global SLOT_DETECT_SELECTED
    global PICK_REGISTER_DELAY_MS, PICK_REGISTER_RETRIES
    detectedSlots := []
    detections := []
    for slot in SLOT_REGIONS {
        d := DetectModifierInSlotDetailed(slot)
        detections.Push(d)
        if IsObject(d["mod"]) {
            e := Map("slot", slot, "mod", d["mod"], "rank", GetModifierRank(d["mod"]))
            detectedSlots.Push(e)
        }
    }
    UpdateSlotDetectionState(detections, true)

    if (detectedSlots.Length < 1) {
        LAST_ACTION := "No valid modifier slots"
        Log("No valid modifier slots detected")
        UpdateGui()
        return false
    }

    best := detectedSlots[1]
    for e in detectedSlots {
        if (e["rank"] < best["rank"])
            best := e
    }

    pickSig := best["slot"]["name"] "|" best["mod"]["name"]
    if (pickSig = LAST_PICK_SIGNATURE && (A_TickCount - LAST_PICK_SIGNATURE_TICK < DUPLICATE_PICK_GUARD_MS)) {
        LAST_ACTION := "Guard skip: duplicate " pickSig
        Log(LAST_ACTION)
        UpdateGui()
        return false
    }

    if !ClickSlot(best["slot"])
        return false

    clickRegistered := false
    attempts := Max(1, PICK_REGISTER_RETRIES)
    Loop attempts {
        Sleep PICK_REGISTER_DELAY_MS
        if !IsModifierScreenOpen() {
            clickRegistered := true
            break
        }
        if (A_Index < attempts) {
            Log("Pick verify retry " A_Index "/" attempts " -> " best["slot"]["name"])
            ClickSlot(best["slot"])
        }
    }
    if !clickRegistered {
        LAST_ACTION := "Pick not registered (screen still open)"
        Log(LAST_ACTION)
        UpdateGui()
        return false
    }

    best["mod"]["score"] += 1
    SLOT_DETECT_SELECTED := GetSlotIndexFromName(best["slot"]["name"])
    LAST_PICK_TICK := A_TickCount
    LAST_PICK_SIGNATURE := pickSig
    LAST_PICK_SIGNATURE_TICK := LAST_PICK_TICK
    SaveScores()
    msg := "Picked " best["slot"]["name"] " -> " best["mod"]["name"] " -> C" best["mod"]["score"]
    LAST_ACTION := msg
    Log(msg)
    ShowTip(msg)
    UpdateGui()
    return true
}

DetectModifierInSlotDetailed(slot) {
    text := OCRTextFromRegion(slot, OCR_OPTIONS_SLOT)
    if (text = "")
        text := OCRTextFromRegion(slot, OCR_OPTIONS_DEFAULT)
    mod := MatchModifierFromText(text)
    return Map("slot", slot, "text", text, "mod", mod)
}

MatchModifierFromText(text) {
    global MODIFIERS, MODIFIER_MATCH_MIN_SCORE
    textNorm := NormalizeText(text)
    if (textNorm = "")
        return 0

    bestMod := 0
    bestScore := 0
    for mod in MODIFIERS {
        if !CanPickModifier(mod)
            continue
        for alias in mod["aliases"] {
            score := ScoreAliasAgainstText(alias, textNorm)
            if (score > bestScore) {
                bestScore := score
                bestMod := mod
            }
        }
    }
    return (bestScore >= MODIFIER_MATCH_MIN_SCORE) ? bestMod : 0
}

ScoreAliasAgainstText(alias, textNorm) {
    aliasNorm := NormalizeText(alias)
    if (aliasNorm = "" || textNorm = "")
        return 0
    if (textNorm = aliasNorm)
        return 100
    if InStr(textNorm, aliasNorm)
        return 95
    if InStr(aliasNorm, textNorm) && StrLen(textNorm) >= 5
        return 80
    return 0
}

CanPickModifier(mod) {
    return true
}

GetModifierRank(mod) {
    try {
        return mod["rank"]
    } catch {
        return 9999
    }
}

ClickSlot(slot) {
    global PICK_SHAKE_ENABLED, PICK_SHAKE_PX, PICK_SHAKE_DELAY_MS, PICK_SHAKE_JITTER_PX, PICK_SHAKE_JITTER_DELAY_MS
    if !EnsureRoblox()
        return false
    if PICK_SHAKE_ENABLED {
        baseS := Max(1, PICK_SHAKE_PX)
        baseD := Max(1, PICK_SHAKE_DELAY_MS)
        jitS := Max(0, PICK_SHAKE_JITTER_PX)
        jitD := Max(0, PICK_SHAKE_JITTER_DELAY_MS)
        cx := slot["clickX"]
        cy := slot["clickY"]

        ; Randomized shake path to avoid identical mouse motion patterns.
        Loop 5 {
            dx := Random(-baseS - jitS, baseS + jitS)
            dy := Random(-baseS - jitS, baseS + jitS)
            MouseMove(cx + dx, cy + dy, 0)
            sleepMs := Random(Max(1, baseD - jitD), baseD + jitD)
            Sleep sleepMs
        }
        MouseMove(cx, cy, 0)
        settleMs := Random(8, 28)
        Sleep settleMs
    }
    Click(slot["clickX"], slot["clickY"])
    return true
}

ClickRegionCenter(region, label := "") {
    global TEAM_SHAKE_ALL_CLICKS, TEAM_PICK_SHAKE_PX, TEAM_PICK_SHAKE_DELAY_MS
    if !EnsureRoblox()
        return false
    cx := RegionCenterX(region)
    cy := RegionCenterY(region)
    if TEAM_SHAKE_ALL_CLICKS {
        s := Max(1, TEAM_PICK_SHAKE_PX)
        d := Max(1, TEAM_PICK_SHAKE_DELAY_MS)
        MouseMove(cx - s, cy, 0)
        Sleep d
        MouseMove(cx + s, cy, 0)
        Sleep d
        MouseMove(cx, cy - s, 0)
        Sleep d
        MouseMove(cx, cy + s, 0)
        Sleep d
        MouseMove(cx, cy, 0)
        Sleep d
    } else {
        MouseMove(cx, cy, 0)
        Sleep 35
    }
    Click(cx, cy)
    return true
}

FocusRegion(region, label := "") {
    if !ClickRegionCenter(region, label)
        return false
    Sleep 70
    return true
}

SendGameKey(keyName, presses := 1, gapMs := 80) {
    if !EnsureRoblox()
        return false
    presses := Max(1, presses)
    Loop presses {
        SendEvent("{" keyName " down}")
        Sleep 25
        SendEvent("{" keyName " up}")
        if (A_Index < presses)
            Sleep gapMs
    }
    return true
}

OCRTextFromRegion(region, options := 0) {
    if !OCR_ENABLED
        return ""
    x := region["x1"], y := region["y1"]
    w := Max(1, region["x2"] - region["x1"])
    h := Max(1, region["y2"] - region["y1"])
    try {
        result := OCR.FromRect(x, y, w, h, options)
        if !IsObject(result)
            return ""
        text := StrReplace(result.Text, "`r", " ")
        text := StrReplace(text, "`n", " ")
        return Trim(RegExReplace(text, "\s+", " "))
    } catch Error {
        return ""
    }
}

NormalizeText(text) {
    text := StrLower(text)
    text := RegExReplace(text, "[^a-z0-9]+")
    return text
}

InitOCR() {
    global OCR_ENABLED
    try OCR.PerformanceMode := 1
    catch {
        OCR_ENABLED := false
        MsgBox "OCR failed to initialize.", "OCR Error"
    }
}

ResetScores(*) {
    global LAST_ACTION
    for mod in MODIFIERS
        mod["score"] := mod["defaultScore"]
    SaveScores()
    LAST_ACTION := "Scores reset"
    Log(LAST_ACTION)
    ShowTip("Scores reset")
    UpdateGui()
}

LoadScores() {
    if !FileExist(SAVE_FILE)
        return
    for mod in MODIFIERS {
        try mod["score"] := Integer(IniRead(SAVE_FILE, "Scores", mod["name"], mod["defaultScore"]))
    }
}

SaveScores() {
    EnsureDirectory(SETTINGS_DIR)
    for mod in MODIFIERS
        IniWrite(mod["score"], SAVE_FILE, "Scores", mod["name"])
}

LoadRanks() {
    EnsureDirectory(SETTINGS_DIR)
    if !FileExist(RANK_FILE) {
        SaveRanks()
        return
    }
    for mod in MODIFIERS {
        defaultRank := mod["defaultRank"]
        loadedRank := Integer(IniRead(RANK_FILE, "Ranks", mod["name"], defaultRank))
        if (loadedRank < 1)
            loadedRank := defaultRank
        mod["rank"] := loadedRank
    }
}

SaveRanks() {
    EnsureDirectory(SETTINGS_DIR)
    for mod in MODIFIERS {
        rank := Integer(mod["rank"])
        if (rank < 1)
            rank := mod["defaultRank"]
        IniWrite(rank, RANK_FILE, "Ranks", mod["name"])
    }
}

ResetRanksToDefault(*) {
    global LAST_ACTION, UiRankEditor
    for mod in MODIFIERS
        mod["rank"] := mod["defaultRank"]
    SaveRanks()
    LAST_ACTION := "Ranks reset to default"
    Log(LAST_ACTION)
    UpdateGui()
    if IsObject(UiRankEditor)
        RefreshRankEditorInputs()
}

LoadTeamCardConfig() {
    global TEAM_CONFIG_FILE, PRIMARY_ATTACK_CARDS, SECONDARY_ATTACK_CARDS
    global PRIMARY_SUPPORT_CARDS, SECONDARY_SUPPORT_CARDS, SUPPORT_FALLBACK_CARDS
    global ATTACK_CARD_SETS, SUPPORT_CARD_SETS

    defaultPrimary := JoinCsv(PRIMARY_ATTACK_CARDS)
    defaultSecondary := JoinCsv(SECONDARY_ATTACK_CARDS)
    defaultPrimarySupport := JoinCsv(PRIMARY_SUPPORT_CARDS)
    defaultSecondarySupport := JoinCsv(SECONDARY_SUPPORT_CARDS)
    defaultFallback := JoinCsv(SUPPORT_FALLBACK_CARDS)

    EnsureDirectory(SETTINGS_DIR)
    if !FileExist(TEAM_CONFIG_FILE) {
        IniWrite(defaultPrimary, TEAM_CONFIG_FILE, "Cards", "AttTeam1")
        IniWrite(defaultSecondary, TEAM_CONFIG_FILE, "Cards", "AttTeam2")
        IniWrite(defaultPrimarySupport, TEAM_CONFIG_FILE, "Cards", "SuppTeam1")
        IniWrite(defaultSecondarySupport, TEAM_CONFIG_FILE, "Cards", "SuppTeam2")
        ; Backward-compatible aliases.
        IniWrite(defaultPrimary, TEAM_CONFIG_FILE, "Cards", "PrimaryAttack")
        IniWrite(defaultSecondary, TEAM_CONFIG_FILE, "Cards", "SecondaryAttack")
        IniWrite(defaultPrimarySupport, TEAM_CONFIG_FILE, "Cards", "PrimarySupport")
        IniWrite(defaultSecondarySupport, TEAM_CONFIG_FILE, "Cards", "SecondarySupport")
        IniWrite(defaultPrimary, TEAM_CONFIG_FILE, "Cards", "Attack1")
        IniWrite(defaultSecondary, TEAM_CONFIG_FILE, "Cards", "Attack2")
        IniWrite(defaultPrimarySupport, TEAM_CONFIG_FILE, "Cards", "Support1")
        IniWrite(defaultSecondarySupport, TEAM_CONFIG_FILE, "Cards", "Support2")
        IniWrite(defaultFallback, TEAM_CONFIG_FILE, "Cards", "SupportFallback")
        Log("Created team card config: " TEAM_CONFIG_FILE)
    }

    cardsCfg := ReadCardsSectionValues(TEAM_CONFIG_FILE)
    primaryCsv := GetCardConfigValue(cardsCfg, ["AttTeam1", "PrimaryAttack"], defaultPrimary)
    secondaryCsv := GetCardConfigValue(cardsCfg, ["AttTeam2", "SecondaryAttack"], defaultSecondary)
    primarySupportCsv := GetCardConfigValue(cardsCfg, ["SuppTeam1", "PrimarySupport", "Support"], "")
    secondarySupportCsv := GetCardConfigValue(cardsCfg, ["SuppTeam2", "SecondarySupport"], "")
    legacySupportCsv := GetCardConfigValue(cardsCfg, ["Support"], defaultPrimarySupport)
    fallbackCsv := GetCardConfigValue(cardsCfg, ["SupportFallback"], defaultFallback)

    if (Trim(primarySupportCsv) = "")
        primarySupportCsv := legacySupportCsv
    if (Trim(secondarySupportCsv) = "")
        secondarySupportCsv := defaultSecondarySupport

    loadedPrimary := ParseCsvCards(primaryCsv)
    loadedSecondary := ParseCsvCards(secondaryCsv)
    loadedPrimarySupport := ParseCsvCards(primarySupportCsv)
    loadedSecondarySupport := ParseCsvCards(secondarySupportCsv)
    loadedFallback := ParseCsvCards(fallbackCsv)

    if (loadedPrimary.Length > 0)
        PRIMARY_ATTACK_CARDS := loadedPrimary
    if (loadedSecondary.Length > 0)
        SECONDARY_ATTACK_CARDS := loadedSecondary
    if (loadedPrimarySupport.Length > 0)
        PRIMARY_SUPPORT_CARDS := loadedPrimarySupport
    if (loadedSecondarySupport.Length > 0)
        SECONDARY_SUPPORT_CARDS := loadedSecondarySupport
    if (loadedFallback.Length > 0)
        SUPPORT_FALLBACK_CARDS := loadedFallback

    legacyAttackSets := []
    legacyAttackSets.Push(PRIMARY_ATTACK_CARDS)
    legacyAttackSets.Push(SECONDARY_ATTACK_CARDS)
    legacySupportSets := []
    legacySupportSets.Push(PRIMARY_SUPPORT_CARDS)
    legacySupportSets.Push(SECONDARY_SUPPORT_CARDS)

    ATTACK_CARD_SETS := LoadIndexedCardSets("Attack", legacyAttackSets)
    SUPPORT_CARD_SETS := LoadIndexedCardSets("Support", legacySupportSets)
}

GetCardConfigValue(valuesMap, keys, defaultValue := "") {
    for _, key in keys {
        if valuesMap.Has(key) {
            val := Trim(valuesMap[key])
            if (val != "")
                return val
        }
    }
    return defaultValue
}

ReadCardsSectionValues(file) {
    values := Map()
    if !FileExist(file)
        return values

    inCards := false
    currentKey := ""
    currentValue := ""
    text := FileRead(file, "UTF-8")

    for rawLine in StrSplit(text, "`n", "`r") {
        line := Trim(rawLine)
        if RegExMatch(line, "^\[(.+)\]$", &sec) {
            if (inCards && currentKey != "")
                values[currentKey] := Trim(currentValue, " ,`t")
            inCards := (StrLower(Trim(sec[1])) = "cards")
            currentKey := ""
            currentValue := ""
            continue
        }
        if !inCards
            continue
        if (line = "")
            continue
        if (SubStr(line, 1, 1) = ";")
            continue

        if RegExMatch(line, "i)^([a-z0-9_]+)\s*=\s*(.*)$", &m) {
            if (currentKey != "")
                values[currentKey] := Trim(currentValue, " ,`t")
            currentKey := m[1]
            currentValue := Trim(m[2])
            continue
        }

        if (currentKey = "")
            continue

        continuation := Trim(line, " `t,")
        if (continuation = "")
            continue
        if (currentValue != "")
            currentValue .= ", "
        currentValue .= continuation
    }

    if (inCards && currentKey != "")
        values[currentKey] := Trim(currentValue, " ,`t")

    return values
}

LoadIndexedCardSets(prefix, fallbackSets) {
    global TEAM_CONFIG_FILE
    setsMap := Map()
    if FileExist(TEAM_CONFIG_FILE) {
        inCards := false
        text := FileRead(TEAM_CONFIG_FILE, "UTF-8")
        for rawLine in StrSplit(text, "`n", "`r") {
            line := Trim(rawLine)
            if (line = "")
                continue
            if RegExMatch(line, "^\[(.+)\]$", &sec) {
                inCards := (StrLower(Trim(sec[1])) = "cards")
                continue
            }
            if !inCards
                continue
            if (SubStr(line, 1, 1) = ";")
                continue
            pat := "i)^" prefix "(\d+)\s*=\s*(.*)$"
            if RegExMatch(line, pat, &m) {
                idx := Integer(m[1])
                cards := ParseCsvCards(m[2])
                if (cards.Length > 0)
                    setsMap[idx] := cards
            }
        }
    }

    out := []
    if (setsMap.Count > 0) {
        keys := []
        for k, _ in setsMap
            keys.Push(Integer(k))
        ; AHK v2.0 compatibility: no Array.Sort method.
        Loop keys.Length {
            i := A_Index
            minPos := i
            j := i + 1
            while (j <= keys.Length) {
                if (keys[j] < keys[minPos])
                    minPos := j
                j += 1
            }
            if (minPos != i) {
                tmp := keys[i]
                keys[i] := keys[minPos]
                keys[minPos] := tmp
            }
        }
        for _, k in keys
            out.Push(setsMap[k])
        return out
    }

    for _, setCards in fallbackSets {
        if (setCards.Length > 0)
            out.Push(setCards)
    }
    return out
}

ParseCsvCards(csv) {
    cards := []
    csv := StrReplace(csv, "`r", ",")
    csv := StrReplace(csv, "`n", ",")
    csv := StrReplace(csv, ";", ",")
    for part in StrSplit(csv, ",") {
        name := Trim(part)
        if (name != "")
            cards.Push(name)
    }
    return cards
}

JoinCsv(arr) {
    out := ""
    for i, item in arr {
        if (i > 1)
            out .= ", "
        out .= item
    }
    return out
}

EnsureDirectory(path) {
    if !InStr(FileExist(path), "D")
        DirCreate(path)
}

Log(msg) {
    global LOG_FILE
    timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
    FileAppend("[" timestamp "] " msg "`n", LOG_FILE, "UTF-8")
}

ShowTip(msg) {
    ToolTip(msg)
    SetTimer(() => ToolTip(), -1500)
}

InitGui() {
    global Ui, UiStatus, UiAction, UiScores, UiAutoJump, UiAutoMinimize
    global UiSlotDetect, UiBtnToggle
    global AUTO_JUMP_ENABLED, AUTO_MINIMIZE_ENABLED
    Ui := Gui("+AlwaysOnTop +Border -MinimizeBox -MaximizeBox", "ACC Dungeon Macro")
    Ui.SetFont("s9", "Consolas")

    UiStatus := Ui.AddText("xm ym w240", "Status: OFF")
    UiAction := Ui.AddText("xm w240", "Last: Idle")
    UiScores := Ui.AddEdit("xm w240 r12 ReadOnly -Wrap -VScroll -HScroll")
    UiSlotDetect := Ui.AddEdit("xm w240 r4 ReadOnly -Wrap -VScroll -HScroll")

    UiBtnToggle := Ui.AddButton("xm w110", "Start")
    btnForceStop := Ui.AddButton("x+10 w110", "FORCE STOP")
    btnPick := Ui.AddButton("xm w110", "Pick Now")
    btnReset := Ui.AddButton("x+10 w110", "Reset Count")
    btnTeamBuild := Ui.AddButton("xm w110", "Build Team")
    btnRanks := Ui.AddButton("x+10 w110", "Ranks")
    btnOverlay := Ui.AddButton("xm w240", "Edit Regions")
    autoJumpOpts := "xm w240 vAutoJumpChk"
    if AUTO_JUMP_ENABLED
        autoJumpOpts .= " Checked"
    UiAutoJump := Ui.AddCheckBox(autoJumpOpts, "Auto Jump")
    autoMinOpts := "xm w240 vAutoMinChk"
    if AUTO_MINIMIZE_ENABLED
        autoMinOpts .= " Checked"
    UiAutoMinimize := Ui.AddCheckBox(autoMinOpts, "Auto Minimize")

    UiBtnToggle.OnEvent("Click", ToggleMacro)
    btnForceStop.OnEvent("Click", ForceStopMacro)
    btnPick.OnEvent("Click", ManualPick)
    btnReset.OnEvent("Click", ResetScores)
    btnTeamBuild.OnEvent("Click", ManualTeamBuild)
    btnRanks.OnEvent("Click", OpenRankEditor)
    btnOverlay.OnEvent("Click", ToggleOverlay)
    UiAutoJump.OnEvent("Click", ToggleAutoJumpFromGui)
    UiAutoMinimize.OnEvent("Click", ToggleAutoMinimizeFromGui)
    Ui.OnEvent("Close", ExitScript)

    winW := 266
    winH := 500
    winX := A_ScreenWidth - winW - 30
    winY := 120
    Ui.Show("x" winX " y" winY " w" winW " h" winH)
}

UpdateGui() {
    global UiStatus, UiAction, UiScores, UiAutoJump, UiAutoMinimize
    global UiSlotDetect, UiBtnToggle
    global RUNNING, LAST_ACTION, AUTO_JUMP_ENABLED, AUTO_MINIMIZE_ENABLED
    if !IsObject(UiStatus)
        return
    UiStatus.Text := "Status: " (RUNNING ? "ON" : "OFF")
    UiStatus.Opt(RUNNING ? "cGreen" : "cRed")
    UiAction.Text := "Last: " LAST_ACTION
    if IsObject(UiBtnToggle)
        UiBtnToggle.Text := RUNNING ? "Stop" : "Start"
    if IsObject(UiAutoJump)
        UiAutoJump.Value := AUTO_JUMP_ENABLED ? 1 : 0
    if IsObject(UiAutoMinimize)
        UiAutoMinimize.Value := AUTO_MINIMIZE_ENABLED ? 1 : 0
    UiScores.Value := BuildScoresText()
    if IsObject(UiSlotDetect)
        UiSlotDetect.Value := BuildSlotDetectText()
}

ToggleAutoJumpFromGui(ctrl, *) {
    global AUTO_JUMP_ENABLED, AUTO_JUMP_TICK, LAST_ACTION
    AUTO_JUMP_ENABLED := (ctrl.Value = 1)
    if AUTO_JUMP_ENABLED
        AUTO_JUMP_TICK := 0
    LAST_ACTION := "Auto Jump " (AUTO_JUMP_ENABLED ? "ON" : "OFF")
    Log(LAST_ACTION)
    UpdateGui()
}

ToggleAutoMinimizeFromGui(ctrl, *) {
    global AUTO_MINIMIZE_ENABLED, LAST_ACTION
    AUTO_MINIMIZE_ENABLED := (ctrl.Value = 1)
    LAST_ACTION := "Auto Minimize " (AUTO_MINIMIZE_ENABLED ? "ON" : "OFF")
    Log(LAST_ACTION)
    UpdateGui()
}

OpenRankEditor(*) {
    global UiRankEditor, UiRankInputs
    if IsObject(UiRankEditor) {
        try UiRankEditor.Show()
        return
    }

    UiRankInputs := Map()
    UiRankEditor := Gui("+AlwaysOnTop +Border -MinimizeBox", "Modifier Rank Editor")
    UiRankEditor.SetFont("s9", "Consolas")
    UiRankEditor.AddText("xm ym w300", "Lower rank = higher priority")

    yOpts := "xm y+8"
    for mod in MODIFIERS {
        UiRankEditor.AddText(yOpts " w185", mod["name"])
        input := UiRankEditor.AddEdit("x+8 w70 Number", mod["rank"])
        UiRankInputs[mod["name"]] := input
        yOpts := "xm y+8"
    }

    btnSave := UiRankEditor.AddButton("xm y+12 w95", "Save")
    btnDefaults := UiRankEditor.AddButton("x+8 w120", "Reset Default")
    btnClose := UiRankEditor.AddButton("x+8 w77", "Close")
    btnSave.OnEvent("Click", SaveRanksFromUi)
    btnDefaults.OnEvent("Click", ResetRanksFromEditor)
    btnClose.OnEvent("Click", CloseRankEditor)
    UiRankEditor.OnEvent("Close", CloseRankEditor)
    UiRankEditor.Show("w330 h430")
}

CloseRankEditor(*) {
    global UiRankEditor, UiRankInputs
    if IsObject(UiRankEditor) {
        try UiRankEditor.Destroy()
    }
    UiRankEditor := 0
    UiRankInputs := Map()
}

RefreshRankEditorInputs() {
    global UiRankInputs
    for mod in MODIFIERS {
        if UiRankInputs.Has(mod["name"])
            UiRankInputs[mod["name"]].Value := mod["rank"]
    }
}

ResetRanksFromEditor(*) {
    ResetRanksToDefault()
    ShowTip("Ranks reset to default")
}

SaveRanksFromUi(*) {
    global UiRankInputs, LAST_ACTION
    changed := false
    for mod in MODIFIERS {
        if !UiRankInputs.Has(mod["name"])
            continue
        raw := Trim(UiRankInputs[mod["name"]].Value)
        if (raw = "") {
            newRank := mod["rank"]
        } else if RegExMatch(raw, "^\d+$") {
            newRank := Integer(raw)
        } else {
            newRank := mod["rank"]
        }
        if (newRank < 1)
            newRank := 1
        if (newRank != mod["rank"]) {
            mod["rank"] := newRank
            changed := true
        }
        UiRankInputs[mod["name"]].Value := mod["rank"]
    }

    if changed {
        SaveRanks()
        LAST_ACTION := "Modifier ranks updated"
        Log(LAST_ACTION)
        UpdateGui()
        ShowTip("Ranks saved")
    } else {
        ShowTip("No rank changes")
    }
}

ExitScript(*) {
    global OVERLAY_ENABLED
    if OVERLAY_ENABLED {
        SyncRegionsFromEditors()
        SaveRegions()
        SetTimer(SyncRegionsFromEditors, 0)
        DestroyRegionEditors()
    }
    ExitApp()
}

ToggleOverlay(*) {
    global OVERLAY_ENABLED, REGION_SYNC_TIMER_MS
    OVERLAY_ENABLED := !OVERLAY_ENABLED
    if OVERLAY_ENABLED {
        CreateRegionEditors()
        SetTimer(SyncRegionsFromEditors, REGION_SYNC_TIMER_MS)
        Log("Region editor ON")
        ShowTip("Region editor ON")
    } else {
        SyncRegionsFromEditors()
        SaveRegions()
        SetTimer(SyncRegionsFromEditors, 0)
        DestroyRegionEditors()
        Log("Region editor OFF (saved)")
        ShowTip("Region editor OFF")
    }
}

CreateRegionEditors() {
    global ITEM_REGION, HIDE_REGION, SCREEN_CHECK_REGION, SLOT_REGIONS
    global TEAM_UI_CHECK_REGION, TEAM_SEARCH_REGION, SEARCH_VERIFY_REGION, SEARCH_UNFOCUS_REGION
    global CARD_PICK_REGION, ADD_PARTY_REGION, ATTACK_TAB_REGION, SUPPORT_TAB_REGION, NO_CARDS_REGION
    global REMOVE_ATTACK_REGION, REMOVE_SUPPORT_REGION
    DestroyRegionEditors()
    AddRegionEditor("Modifier Header", SCREEN_CHECK_REGION, false, "77AAFF")
    AddRegionEditor("Dismiss", ITEM_REGION, false, "77AAFF")
    AddRegionEditor("Hide", HIDE_REGION, false, "77AAFF")
    AddRegionEditor("Team UI OCR", TEAM_UI_CHECK_REGION, false, "77AAFF")
    AddRegionEditor("Team Search", TEAM_SEARCH_REGION, false, "77AAFF")
    AddRegionEditor("Search Verify", SEARCH_VERIFY_REGION, false, "77AAFF")
    AddRegionEditor("Search Unfocus", SEARCH_UNFOCUS_REGION, false, "77AAFF")
    AddRegionEditor("No Cards OCR", NO_CARDS_REGION, false, "77AAFF")
    AddRegionEditor("Card Pick", CARD_PICK_REGION, false, "FFFFFF")
    AddRegionEditor("Add Party", ADD_PARTY_REGION, false, "FFFFFF")
    AddRegionEditor("Attack Tab", ATTACK_TAB_REGION, false, "FFFFFF")
    AddRegionEditor("Support Tab", SUPPORT_TAB_REGION, false, "FFFFFF")
    AddRegionEditor("Remove Attack", REMOVE_ATTACK_REGION, false, "FFFFFF")
    AddRegionEditor("Remove Support", REMOVE_SUPPORT_REGION, false, "FFFFFF")
    for slot in SLOT_REGIONS
        AddRegionEditor(slot["name"], slot, true, "FFFFFF")
}

DestroyRegionEditors() {
    global REGION_EDITORS
    for editor in REGION_EDITORS {
        try editor["gui"].Destroy()
    }
    REGION_EDITORS := []
}

AddRegionEditor(label, region, hasClickPoint := false, color := "77AAFF") {
    global REGION_EDITORS
    w := Max(40, region["x2"] - region["x1"])
    h := Max(40, region["y2"] - region["y1"])

    g := Gui("+AlwaysOnTop -Caption +ToolWindow +Border")
    g.SetFont("s9 Bold", "Consolas")
    g.BackColor := color
    WinSetTransparent(140, g.Hwnd)

    fill := g.AddText("x0 y0 w" w " h" h " BackgroundTrans")
    title := g.AddText("x6 y6 cBlack BackgroundTrans", label)
    marker := 0
    if hasClickPoint && region.Has("clickX") && region.Has("clickY") {
        relX := region["clickX"] - region["x1"] - 4
        relY := region["clickY"] - region["y1"] - 4
        marker := g.AddText("x" relX " y" relY " w8 h8 BackgroundFF0000")
    }

    fill.OnEvent("Click", (*) => StartBoxMove(g.Hwnd))
    title.OnEvent("Click", (*) => StartBoxMove(g.Hwnd))
    g.Show("x" region["x1"] " y" region["y1"] " w" w " h" h " NA")

    REGION_EDITORS.Push(Map(
        "gui", g,
        "region", region,
        "w", w,
        "h", h,
        "hasClickPoint", hasClickPoint,
        "marker", marker
    ))
}

StartBoxMove(hwnd) {
    PostMessage(0xA1, 2,,, "ahk_id " hwnd)
}

SyncRegionsFromEditors() {
    global REGION_EDITORS
    for editor in REGION_EDITORS {
        hwnd := editor["gui"].Hwnd
        if !WinExist("ahk_id " hwnd)
            continue
        try WinGetPos(&x, &y, &w, &h, "ahk_id " hwnd)
        catch
            continue
        if (w <= 0 || h <= 0)
            continue

        region := editor["region"]
        region["x1"] := x
        region["y1"] := y
        region["x2"] := x + w
        region["y2"] := y + h

        if editor["hasClickPoint"] && region.Has("clickX") && region.Has("clickY") {
            region["clickX"] := x + Floor(w / 2)
            region["clickY"] := y + Floor(h / 2)
            if IsObject(editor["marker"]) {
                relX := region["clickX"] - region["x1"] - 4
                relY := region["clickY"] - region["y1"] - 4
                editor["marker"].Move(relX, relY, 8, 8)
            }
        }
    }
}

LoadRegions() {
    global REGION_FILE, LEGACY_REGION_FILE, ITEM_REGION, HIDE_REGION, SCREEN_CHECK_REGION, SLOT_REGIONS
    global TEAM_UI_CHECK_REGION, TEAM_SEARCH_REGION, SEARCH_VERIFY_REGION, SEARCH_UNFOCUS_REGION
    global CARD_PICK_REGION, ADD_PARTY_REGION, ATTACK_TAB_REGION, SUPPORT_TAB_REGION, NO_CARDS_REGION
    global REMOVE_ATTACK_REGION, REMOVE_SUPPORT_REGION
    if !FileExist(REGION_FILE) && FileExist(LEGACY_REGION_FILE) {
        FileCopy(LEGACY_REGION_FILE, REGION_FILE, true)
        Log("Migrated region config to: " REGION_FILE)
    }
    if !FileExist(REGION_FILE) {
        SaveRegions()
        return
    }

    ITEM_REGION := ReadRegionFromIni(REGION_FILE, "ItemRegion", ITEM_REGION)
    HIDE_REGION := ReadRegionFromIni(REGION_FILE, "HideRegion", HIDE_REGION)
    SCREEN_CHECK_REGION := ReadRegionFromIni(REGION_FILE, "ScreenCheckRegion", SCREEN_CHECK_REGION)
    TEAM_UI_CHECK_REGION := ReadRegionFromIni(REGION_FILE, "TeamUiCheckRegion", TEAM_UI_CHECK_REGION)
    TEAM_SEARCH_REGION := ReadRegionFromIni(REGION_FILE, "TeamSearchRegion", TEAM_SEARCH_REGION)
    SEARCH_VERIFY_REGION := ReadRegionFromIni(REGION_FILE, "SearchVerifyRegion", SEARCH_VERIFY_REGION)
    SEARCH_UNFOCUS_REGION := ReadRegionFromIni(REGION_FILE, "SearchUnfocusRegion", SEARCH_UNFOCUS_REGION)
    CARD_PICK_REGION := ReadRegionFromIni(REGION_FILE, "CardPickRegion", CARD_PICK_REGION)
    ADD_PARTY_REGION := ReadRegionFromIni(REGION_FILE, "AddPartyRegion", ADD_PARTY_REGION)
    ATTACK_TAB_REGION := ReadRegionFromIni(REGION_FILE, "AttackTabRegion", ATTACK_TAB_REGION)
    SUPPORT_TAB_REGION := ReadRegionFromIni(REGION_FILE, "SupportTabRegion", SUPPORT_TAB_REGION)
    NO_CARDS_REGION := ReadRegionFromIni(REGION_FILE, "NoCardsRegion", NO_CARDS_REGION)
    REMOVE_ATTACK_REGION := ReadRegionFromIni(REGION_FILE, "RemoveAttackRegion", REMOVE_ATTACK_REGION)
    REMOVE_SUPPORT_REGION := ReadRegionFromIni(REGION_FILE, "RemoveSupportRegion", REMOVE_SUPPORT_REGION)

    for i, slot in SLOT_REGIONS {
        sec := "SlotRegion" i
        SLOT_REGIONS[i] := ReadRegionFromIni(REGION_FILE, sec, slot)
        SLOT_REGIONS[i]["name"] := slot["name"]
        SLOT_REGIONS[i]["clickX"] := Integer(IniRead(REGION_FILE, sec, "clickX", slot["clickX"]))
        SLOT_REGIONS[i]["clickY"] := Integer(IniRead(REGION_FILE, sec, "clickY", slot["clickY"]))
    }
}

SaveRegions() {
    global SETTINGS_DIR, REGION_FILE, ITEM_REGION, HIDE_REGION, SCREEN_CHECK_REGION, SLOT_REGIONS
    global TEAM_UI_CHECK_REGION, TEAM_SEARCH_REGION, SEARCH_VERIFY_REGION, SEARCH_UNFOCUS_REGION
    global CARD_PICK_REGION, ADD_PARTY_REGION, ATTACK_TAB_REGION, SUPPORT_TAB_REGION, NO_CARDS_REGION
    global REMOVE_ATTACK_REGION, REMOVE_SUPPORT_REGION
    EnsureDirectory(SETTINGS_DIR)
    WriteRegionToIni(REGION_FILE, "ItemRegion", ITEM_REGION)
    WriteRegionToIni(REGION_FILE, "HideRegion", HIDE_REGION)
    WriteRegionToIni(REGION_FILE, "ScreenCheckRegion", SCREEN_CHECK_REGION)
    WriteRegionToIni(REGION_FILE, "TeamUiCheckRegion", TEAM_UI_CHECK_REGION)
    WriteRegionToIni(REGION_FILE, "TeamSearchRegion", TEAM_SEARCH_REGION)
    WriteRegionToIni(REGION_FILE, "SearchVerifyRegion", SEARCH_VERIFY_REGION)
    WriteRegionToIni(REGION_FILE, "SearchUnfocusRegion", SEARCH_UNFOCUS_REGION)
    WriteRegionToIni(REGION_FILE, "CardPickRegion", CARD_PICK_REGION)
    WriteRegionToIni(REGION_FILE, "AddPartyRegion", ADD_PARTY_REGION)
    WriteRegionToIni(REGION_FILE, "AttackTabRegion", ATTACK_TAB_REGION)
    WriteRegionToIni(REGION_FILE, "SupportTabRegion", SUPPORT_TAB_REGION)
    WriteRegionToIni(REGION_FILE, "NoCardsRegion", NO_CARDS_REGION)
    WriteRegionToIni(REGION_FILE, "RemoveAttackRegion", REMOVE_ATTACK_REGION)
    WriteRegionToIni(REGION_FILE, "RemoveSupportRegion", REMOVE_SUPPORT_REGION)
    for i, slot in SLOT_REGIONS
        WriteRegionToIni(REGION_FILE, "SlotRegion" i, slot)
}

WriteRegionToIni(file, section, region) {
    IniWrite(region["x1"], file, section, "x1")
    IniWrite(region["y1"], file, section, "y1")
    IniWrite(region["x2"], file, section, "x2")
    IniWrite(region["y2"], file, section, "y2")
    if region.Has("clickX")
        IniWrite(region["clickX"], file, section, "clickX")
    if region.Has("clickY")
        IniWrite(region["clickY"], file, section, "clickY")
}

ReadRegionFromIni(file, section, defaults) {
    r := Map()
    r["x1"] := Integer(IniRead(file, section, "x1", defaults["x1"]))
    r["y1"] := Integer(IniRead(file, section, "y1", defaults["y1"]))
    r["x2"] := Integer(IniRead(file, section, "x2", defaults["x2"]))
    r["y2"] := Integer(IniRead(file, section, "y2", defaults["y2"]))
    if defaults.Has("clickX")
        r["clickX"] := Integer(IniRead(file, section, "clickX", defaults["clickX"]))
    if defaults.Has("clickY")
        r["clickY"] := Integer(IniRead(file, section, "clickY", defaults["clickY"]))
    return r
}

RegionCenterX(region) {
    return region["x1"] + Floor((region["x2"] - region["x1"]) / 2)
}

RegionCenterY(region) {
    return region["y1"] + Floor((region["y2"] - region["y1"]) / 2)
}

BuildScoresText() {
    text := "Modifier       Count  Rank`r`n"
    text .= "-------------------------`r`n"
    for mod in MODIFIERS {
        name := mod["name"]
        while (StrLen(name) < 13)
            name .= " "
        count := mod["score"] ""
        while (StrLen(count) < 5)
            count := " " count
        text .= name count "   " mod["rank"] "`r`n"
    }
    return text
}

BuildSlotDetectText() {
    global SLOT_DETECT_1, SLOT_DETECT_2, SLOT_DETECT_3, SLOT_DETECT_SELECTED
    s1 := "S1: " SLOT_DETECT_1
    s2 := "S2: " SLOT_DETECT_2
    s3 := "S3: " SLOT_DETECT_3
    if (SLOT_DETECT_SELECTED = 1)
        s1 .= " <--"
    if (SLOT_DETECT_SELECTED = 2)
        s2 .= " <--"
    if (SLOT_DETECT_SELECTED = 3)
        s3 .= " <--"
    text := "Slot Detection`r`n"
    text .= s1 "`r`n"
    text .= s2 "`r`n"
    text .= s3
    return text
}

UpdateSlotDetectionState(detections, logChanges := true) {
    global SLOT_DETECT_1, SLOT_DETECT_2, SLOT_DETECT_3
    changed := false

    new1 := BuildSlotDetectValue(detections, 1)
    new2 := BuildSlotDetectValue(detections, 2)
    new3 := BuildSlotDetectValue(detections, 3)

    if (new1 != SLOT_DETECT_1) {
        SLOT_DETECT_1 := new1
        changed := true
        if logChanges
            Log("Detect Slot 1 => " new1)
    }
    if (new2 != SLOT_DETECT_2) {
        SLOT_DETECT_2 := new2
        changed := true
        if logChanges
            Log("Detect Slot 2 => " new2)
    }
    if (new3 != SLOT_DETECT_3) {
        SLOT_DETECT_3 := new3
        changed := true
        if logChanges
            Log("Detect Slot 3 => " new3)
    }

    if changed
        UpdateGui()
}

BuildSlotDetectValue(detections, index) {
    if !IsObject(detections) || (detections.Length < index)
        return "(none)"

    d := detections[index]
    raw := Trim(d["text"])
    if IsObject(d["mod"])
        return d["mod"]["name"]
    if (raw = "")
        return "(none)"
    return "Unknown"
}

GetSlotIndexFromName(slotName) {
    if RegExMatch(slotName, "i)slot\s*(\d+)", &m)
        return Integer(m[1])
    return 0
}

