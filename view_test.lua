

-- testsuite
describe("view test", function()
    it("GamePlayView:SetBoardAndDraw", function()
        local mod = require "logic"
        local b = mod.Board:new()
        b:SetWidth(8)
        b:SetHeight(8)

        local modView = require "view"
        local view = modView.GamePlayView:new()

        view:SetBoard(b)
        assert.is_true(true)
    end)
end)