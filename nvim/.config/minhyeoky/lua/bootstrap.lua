local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  -- bootstrap lazy.nvim
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

-- https://lazy.folke.io/usage/structuring#%EF%B8%8F-importing-specs-config--opts
-- opts, dependencies, cmd, event, ft and keys are always merged with the parent spec.
require("lazy").setup({
  { import = "plugins" },
  { import = "plugins.lang" },
})
