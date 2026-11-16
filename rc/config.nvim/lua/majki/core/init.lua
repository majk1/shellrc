vim.api.nvim_create_augroup('UserGroup', {})

-- From vim defaults.vim
-- ---
-- When editing a file, always jump to the last known cursor position.
-- Don't do it when the position is invalid, when inside an event handler
-- (happens when dropping a file on gvim) and for a commit message (it's
-- likely a different one than last time).
vim.api.nvim_create_autocmd('BufReadPost', {
  group = 'UserGroup',
  callback = function(args)
    local valid_line = vim.fn.line([['"]]) >= 1 and vim.fn.line([['"]]) < vim.fn.line('$')
    local not_commit = vim.b[args.buf].filetype ~= 'commit'

    if valid_line and not_commit then
      vim.cmd([[normal! g`"]])
    end
  end,
})

-- Compose files get their own filetype so the compose LSP (docker_language_server) attaches;
-- the compound 'yaml.docker-compose' keeps the yaml syntax highlighting.
-- Systemd units are NOT detected by extension on purpose: use `:set ft=systemd`
-- or a `# vim: ft=systemd` modeline (files under .../systemd/ are detected by nvim itself).
vim.filetype.add({
  pattern = {
    ['.*/docker%-compose%.ya?ml'] = 'yaml.docker-compose',
    ['.*/docker%-compose%..+%.ya?ml'] = 'yaml.docker-compose', -- docker-compose.prod.yml
    ['.*/compose%.ya?ml'] = 'yaml.docker-compose',
    ['.*/compose%..+%.ya?ml'] = 'yaml.docker-compose',          -- compose.override.yaml
  },
})

