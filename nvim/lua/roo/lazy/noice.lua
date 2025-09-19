return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = {
		"MunifTanjim/nui.nvim",
		"rcarriga/nvim-notify",
	},
	config = function()
		require("noice").setup({
			cmdline = {
				enabled = true, -- enables floating cmdline
				view = "cmdline_popup", -- use popup view
			},
			views = {
				cmdline_popup = {
					position = {
						row = 5, -- distance from top
						col = "50%", -- center horizontally
					},
					size = {
						width = 60,
						height = "auto",
					},
					border = {
						style = "rounded",
						padding = { 0, 1 }, -- padding inside border
					},
					win_options = {
						winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
					},
				},
			},
		})
	end,
}
