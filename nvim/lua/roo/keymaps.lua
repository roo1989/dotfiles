vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "B", "^", { noremap = true, silent = true, desc = "Move to start of first word on the line" })

vim.keymap.set("n", "<leader>rr", function()
	for name, _ in pairs(package.loaded) do
		if name:match("^roo") then -- match your namespace
			package.loaded[name] = nil
		end
	end
	dofile(vim.env.MYVIMRC)
	print("Reloaded config and modules.")
end, { desc = "Reload config + modules" })

vim.keymap.set("i", "<Tab>", function()
	local cmp = require("cmp")
	local blink = require("blink.cmp")

	if cmp.visible() and blink.visible() then
		return cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert })()
	else
		return "<Tab>"
	end
end, { expr = true, silent = true })

vim.keymap.set("i", "<S-Tab>", function()
	local cmp = require("cmp")
	local blink = require("blink.cmp")

	if cmp.visible() and blink.visible() then
		return cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert })()
	else
		return "<S-Tab>"
	end
end, { expr = true, silent = true })
