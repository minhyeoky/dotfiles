local english = "com.apple.keylayout.ABC"
local escapeBind

local function setEnglish()
    local source = hs.keycodes.currentSourceID()
    if not (source == english) then
        hs.keycodes.currentSourceID(english)
    end
    escapeBind:disable()
    hs.eventtap.keyStroke({}, 'escape')
    escapeBind:enable()
end

escapeBind = hs.hotkey.new({}, 'escape', setEnglish):enable()
