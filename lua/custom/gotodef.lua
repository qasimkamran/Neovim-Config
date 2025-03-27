function goto_definition()
    local query = vim.fn.input("Fn > ")
    if query == "" then
        return
    end

    vim.lsp.buf_request(0, "workspace/symbol", { query = query }, function(err, result, ctx, config)
        if err then
            print("Error: " .. err.message)
            return
        end
        if not result or vim.tbl_isempty(result) then
            print("No symbol found for: " .. query)
            return
        end

        if #result == 1 then
            local location = result[1].location or result[1].targetLocation
            if location then
                vim.lsp.util.jump_to_location(location, "utf-8")
            end
        else
            vim.ui.select(result, {
                prompt = "Select definition:",
                format_item = function(item)
                    local loc = item.location or item.targetLocation
                    if loc then
                        local uri = loc.uri or loc.targetUri
                        local range = loc.range or loc.targetSelectionRange
                        return string.format("%s:%d:%d", vim.uri_to_fname(uri), range.start.line + 1, range.start.character + 1)
                    end
                    return ""
                end,
            }, function(choice)
                if choice then
                    local location = choice.location or choice.targetLocation
                    if location then
                        vim.lsp.util.jump_to_location(location, "utf-8")
                    end
                end
            end)
        end
    end)
end

vim.api.nvim_create_user_command("GotoDef", goto_definition, {})

