vim.api.nvim_create_augroup('UserGroup', {})

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

