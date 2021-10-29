local M = {}

function M.tabName(bufnr)
    local file = vim.fn.bufname(bufnr)
    local buftype = vim.fn.getbufvar(bufnr, '&buftype')
    local filetype = vim.fn.getbufvar(bufnr, '&filetype')
    if buftype == 'help' then
        return 'help:' .. vim.fn.fnamemodify(file, ':t:r')
    elseif buftype == 'quickfix' then
        return 'quickfix'
    elseif filetype == 'TelescopePrompt' then
        return 'Telescope'
    elseif file:sub(file:len()-2, file:len()) == 'FZF' then
        return 'FZF'
    elseif buftype == 'terminal' then
        local _, mtch = string.match(file, "term:(.*):(%a+)")
        return mtch ~= nil and mtch or vim.fn.fnamemodify(vim.env.SHELL, ':t')
    elseif file == '' then
        return '[No Name]'
    end
    return vim.fn.pathshorten(vim.fn.fnamemodify(file, ':p:~:t'))
end

function M.tabModified(bufnr)
    return vim.fn.getbufvar(bufnr, '&modified') == 1 and '[+] ' or ''
end

function M.tabWindowCount(current)
    local nwins = vim.fn.tabpagewinnr(current, '$')
    return nwins > 1 and '(' .. nwins .. ') ' or ''
end

function M.tabDevicon(bufnr, isSelected)
    local dev, devhl
    local file = vim.fn.bufname(bufnr)
    local buftype = vim.fn.getbufvar(bufnr, '&buftype')
    local filetype = vim.fn.getbufvar(bufnr, '&filetype')
    if filetype == 'TelescopePrompt' then
        dev, devhl = require'nvim-web-devicons'.get_icon('telescope')
    elseif filetype == 'fugitive' then
        dev, devhl = require'nvim-web-devicons'.get_icon('git')
    elseif filetype == 'vimwiki' then
        dev, devhl = require'nvim-web-devicons'.get_icon('markdown')
    elseif buftype == 'terminal' then
        dev, devhl = require'nvim-web-devicons'.get_icon('zsh')
    else
        dev, devhl = require'nvim-web-devicons'.get_icon(file, vim.fn.expand('#'..bufnr..':e'))
    end
    if dev then
        local hl = M.tabDeviconHl(devhl, isSelected) or ''
        return hl .. dev .. (isSelected and '%#TabLineSel#' or '%#TabLine#') .. ' '
    end
    return ''
end

function M.tabGetDeviconHlGroup(devhl)
    local h = require'luatab.highlight'
    local fg = h.extract_highlight_colors(devhl, 'fg')
    local bg = h.extract_highlight_colors('TabLineSel', 'bg')
    local hl = h.create_component_highlight_group({bg = bg, fg = fg}, devhl)
    return hl and '%#'..hl..'#'
end

function M.tabDeviconHl(devhl, isSelected)
    local hl = M.tabGetDeviconHlGroup(devhl)
    return isSelected and hl
end

function M.tabSeparator(current)
    return (current < vim.fn.tabpagenr('$') and '%#TabLine#'..'|')
end

function M.formatTab(current)
    local isSelected = vim.fn.tabpagenr() == current
    local buflist = vim.fn.tabpagebuflist(current)
    local winnr = vim.fn.tabpagewinnr(current)
    local bufnr = buflist[winnr]
    local hl = (isSelected and '%#TabLineSel#' or '%#TabLine#')

    return hl .. '%' .. current .. 'T' .. ' ' ..
        M.tabWindowCount(current) ..
        M.tabName(bufnr) .. ' ' ..
        M.tabModified(bufnr) ..
        M.tabDevicon(bufnr, isSelected) .. '%T' ..
        (M.tabSeparator(current) or '')
end

function M.tabline()
    local i = 1
    local line = ''
    while i <= vim.fn.tabpagenr('$') do
        line = line .. M.formatTab(i)
        i = i + 1
    end
    line = line .. '%#TabLineFill#%='
    if vim.fn.tabpagenr('$') > 1 then
        line = line .. '%#TabLine#%999XX'
    end
    return line
end

return M
