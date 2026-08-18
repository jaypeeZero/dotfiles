-- Show selected word count in the statusline, but ONLY while text is highlighted.
return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = function(_, opts)
    table.insert(opts.sections.lualine_x, 1, {
      function()
        local wc = vim.fn.wordcount()
        return (wc.visual_words or 0) .. " words"
      end,
      -- visual_words is nil outside visual mode, so the component only shows
      -- in charwise (v), linewise (V), and blockwise (<C-v>) visual modes.
      cond = function()
        return vim.fn.mode():find("[vV\22]") ~= nil
      end,
    })
  end,
}
