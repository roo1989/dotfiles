return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2", -- very important!
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local harpoon = require("harpoon")

		harpoon:setup({
			settings = {
				save_on_toggle = true,
				sync_on_ui_close = true,
			},
		})

		vim.keymap.set("n", "<leader>hx", function()
			harpoon:list():add()
		end)
		vim.keymap.set("n", "<leader>hh", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end)
		vim.keymap.set("n", "<C-n>", function()
			harpoon:list():next()
		end)
		vim.keymap.set("n", "<C-m>", function()
			harpoon:list():prev()
		end)
	end,
}
