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
-- Ansible files get 'yaml.ansible' so the Ansible LSP (ansiblels) attaches: by path (role dirs,
-- playbooks/, group_vars/, host_vars/, *playbook*.yml, site.yml) or by content (see below).
-- Anything else: `:set ft=yaml.ansible` or a `# vim: ft=yaml.ansible` modeline.

-- Content check for the remaining YAML files: a play at the top level (`- hosts:`,
-- `- import_playbook:`, or `hosts:` of a play starting with `- name:`) or an FQCN module
-- (`ansible.builtin.copy:`) in the first 30 lines. nil = not Ansible, detection goes on (yaml).
local function detect_ansible(path, bufnr)
  local name = vim.fs.basename(path)
  if not bufnr or name:match('compose') then
    return nil
  end
  for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, 30, false)) do
    if line:match('^%- hosts:') or line:match('^  hosts:') or line:match('^%- import_playbook:')
        or line:match('ansible%.builtin%.') then
      return 'yaml.ansible'
    end
  end
  return nil
end

-- compose rules get a higher priority, so a compose file under e.g. playbooks/ stays compose
local compose = { 'yaml.docker-compose', { priority = 10 } }

vim.filetype.add({
  pattern = {
    ['.*/docker%-compose%.ya?ml'] = compose,
    ['.*/docker%-compose%..+%.ya?ml'] = compose, -- docker-compose.prod.yml
    ['.*/compose%.ya?ml'] = compose,
    ['.*/compose%..+%.ya?ml'] = compose,          -- compose.override.yaml

    ['.*/roles/[^/]+/tasks/.*%.ya?ml'] = 'yaml.ansible',
    ['.*/roles/[^/]+/handlers/.*%.ya?ml'] = 'yaml.ansible',
    ['.*/roles/[^/]+/defaults/.*%.ya?ml'] = 'yaml.ansible',
    ['.*/roles/[^/]+/vars/.*%.ya?ml'] = 'yaml.ansible',
    ['.*/roles/[^/]+/meta/.*%.ya?ml'] = 'yaml.ansible',
    ['.*/playbooks/[^/]+%.ya?ml'] = 'yaml.ansible',
    ['.*/group_vars/.*%.ya?ml'] = 'yaml.ansible',
    ['.*/host_vars/.*%.ya?ml'] = 'yaml.ansible',
    ['.*/[^/]*playbook[^/]*%.ya?ml'] = 'yaml.ansible',           -- playbook.yml, deploy-playbook.yaml
    ['.*/site%.ya?ml'] = 'yaml.ansible',
    ['.*%.ya?ml'] = detect_ansible,
  },
})

