local config_files = { ".oxlintrc.json", ".oxlintrc.jsonc", "oxlint.config.ts", "oxlint.config.mts" }

local function find_root(ctx)
  return vim.fs.root(ctx.dirname, config_files)
end

return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    opts.formatters = opts.formatters or {}
    opts.formatters.oxlint_fix = {
      command = function(_, ctx)
        local root = find_root(ctx)
        local local_bin = root and root .. "/node_modules/.bin/oxlint"
        return local_bin and vim.uv.fs_stat(local_bin) and local_bin or "oxlint"
      end,
      args = { "--fix", "$FILENAME" },
      stdin = false,
      -- oxlint exits 1 when unfixable violations remain; conform would discard the fixes otherwise
      exit_codes = { 0, 1 },
      -- projects without an oxlint config are left alone
      condition = function(_, ctx)
        return find_root(ctx) ~= nil
      end,
    }

    -- the timeout covers the whole chain (oxlint + prettier), and oxlint alone takes ~0.9s here
    opts.default_format_opts = vim.tbl_extend("force", opts.default_format_opts or {}, { timeout_ms = 8000 })

    opts.formatters_by_ft = opts.formatters_by_ft or {}
    for _, ft in ipairs({ "typescript", "typescriptreact", "javascript", "javascriptreact" }) do
      -- before prettier so style formatting has the last word
      opts.formatters_by_ft[ft] = vim.list_extend({ "oxlint_fix" }, opts.formatters_by_ft[ft] or {})
    end
  end,
}
