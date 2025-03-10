local M = {}

local bloc_builder_template = {
	"BlocBuilder<MyBloc, MyBlocState>(",
	"  builder: (context, state) {",
	"    return %s;",
	"  },",
	")",
}
local bloc_listener_template = {
	"BlocListener<MyBloc, MyBlocState>(",
	"  listener: (context, state) {",
	"    %s;",
	"  },",
	")",
}
local bloc_provider_template = {
	"BlocProvider<MyBloc>(",
	"  create: (context) => MyBloc(),",
	"  child: %s,",
	")",
}
local bloc_selector_template = {
	"BlocSelector<MyBloc, MyBlocState, MyType>(",
	"  selector: (state) {",
	"    return state;",
	"  },",
	"  builder: (context, state) {",
	"    return %s;",
	"  },",
	")",
}
local bloc_consumer_template = {
	"BlocConsumer<MyBloc, MyBlocState>(",
	"  listener: (context, state) {",
	"  },",
	"  builder: (context, state) {",
	"    return %s;",
	"  },",
	")",
}

local function is_valid_node(node)
	if not node then
		return false
	end

	return node:type() == "identifier" or node:type() == "type_identifier"
end

local function get_node_text(bufnr, node)
	if not node then
		return nil
	end
	local sibling = node:next_sibling()
	if not sibling then
		return nil
	end

	local start_row, start_col = node:start()
	local end_row, end_col = sibling:end_()

	return vim.api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col, {})
end

local get_widget_details = function()
	local bufnr = vim.api.nvim_get_current_buf()

	local node = vim.treesitter.get_node()
	if not node then
		return nil
	end

	local sibling = node:next_sibling()
	if not sibling then
		return nil
	end

	local start_row, start_col = node:start()
	local end_row, end_col = sibling:end_()

	return {
		widget_name = vim.api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col, {}),
		widget_text = get_node_text(bufnr, node),
		range = {
			start_row = start_row,
			start_col = start_col,
			end_row = end_row,
			end_col = end_col,
		},
		bufnr = bufnr,
	}
end

local write_widget = function(wrapped_widget, widget)
	vim.api.nvim_buf_set_text(
		widget.bufnr,
		widget.range.start_row,
		widget.range.start_col,
		widget.range.end_row,
		widget.range.end_col,
		wrapped_widget
	)
	vim.cmd("undojoin")
	vim.lsp.buf.format({ async = false, bufnr = widget.bufnr })
end

local function format_widget_content(widget_text)
	-- Is its a single line widget
	if #widget_text == 1 then
		return widget_text[1]
	end

	-- For multi line widget
	local result = {}
	for i, line in ipairs(widget_text) do
		if i == 1 then
			table.insert(result, line)
		else
			table.insert(result, "    " .. line)
		end
	end

	return table.concat(result, " ")
end

local function apply_template(template, widget_content)
	local result = {}
	for _, line in ipairs(template) do
		if line:find("%%s") then
			table.insert(result, string.format(line, widget_content))
		else
			table.insert(result, line)
		end
	end
	return result
end

local wrap_with_bloc_builder = function()
	local widget = get_widget_details()
	if not widget then
		return
	end

	local formatted_content = format_widget_content(widget.widget_text)
	local wrapped_widget = apply_template(bloc_builder_template, formatted_content)
	write_widget(wrapped_widget, widget)
end

local wrap_with_bloc_listener = function()
	local widget = get_widget_details()
	if not widget then
		return
	end

	local formatted_content = format_widget_content(widget.widget_text)
	local wrapped_widget = apply_template(bloc_listener_template, formatted_content)
	write_widget(wrapped_widget, widget)
end

local wrap_with_bloc_provider = function()
	local widget = get_widget_details()
	if not widget then
		return
	end

	local formatted_content = format_widget_content(widget.widget_text)
	local wrapped_widget = apply_template(bloc_provider_template, formatted_content)
	write_widget(wrapped_widget, widget)
end

local wrap_with_bloc_selector = function()
	local widget = get_widget_details()
	if not widget then
		return
	end

	local formatted_content = format_widget_content(widget.widget_text)
	local wrapped_widget = apply_template(bloc_selector_template, formatted_content)
	write_widget(wrapped_widget, widget)
end

local wrap_with_bloc_consumer = function()
	local widget = get_widget_details()
	if not widget then
		return
	end

	local formatted_content = format_widget_content(widget.widget_text)
	local wrapped_widget = apply_template(bloc_consumer_template, formatted_content)
	write_widget(wrapped_widget, widget)
end

-- This function handles the code action request
local handle_code_actions = function(_, _, params, _, _, _)
	local bufnr = vim.uri_to_bufnr(params.textDocument.uri)

	-- Check if the buffer is a Dart file
	local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
	if ft ~= "dart" then
		return {}
	end

	-- Position cursor at the requested position to get the correct node
	local row = params.range.start.line
	local col = params.range.start.character

	-- Save the current cursor position
	local current_win = vim.api.nvim_get_current_win()
	local current_pos = vim.api.nvim_win_get_cursor(current_win)

	-- Set cursor to the requested position
	vim.api.nvim_win_set_cursor(current_win, { row + 1, col })

	-- Get the node at cursor
	local node = vim.treesitter.get_node()

	-- Restore cursor position
	vim.api.nvim_win_set_cursor(current_win, current_pos)

	-- Check if the node is valid for our code actions
	if not is_valid_node(node) then
		return {}
	end

	-- Return the available code actions
	return {
		{
			title = "Wrap with BlocBuilder",
			kind = "refactor.rewrite",
			command = {
				command = "flutter-bloc.wrap-with-bloc-builder",
				title = "Wrap with BlocBuilder",
			},
		},
		{
			title = "Wrap with BlocListener",
			kind = "refactor.rewrite",
			command = {
				command = "flutter-bloc.wrap-with-bloc-listener",
				title = "Wrap with BlocListener",
			},
		},
		{
			title = "Wrap with BlocProvider",
			kind = "refactor.rewrite",
			command = {
				command = "flutter-bloc.wrap-with-bloc-provider",
				title = "Wrap with BlocProvider",
			},
		},
		{
			title = "Wrap with BlocSelector",
			kind = "refactor.rewrite",
			command = {
				command = "flutter-bloc.wrap-with-bloc-selector",
				title = "Wrap with BlocSelector",
			},
		},
		{
			title = "Wrap with BlocConsumer",
			kind = "refactor.rewrite",
			command = {
				command = "flutter-bloc.wrap-with-bloc-consumer",
				title = "Wrap with BlocConsumer",
			},
		},
	}
end

function M.setup()
	-- Register commands for each code action
	vim.api.nvim_create_user_command("FlutterBlocBuilder", wrap_with_bloc_builder, {})
	vim.api.nvim_create_user_command("FlutterBlocListener", wrap_with_bloc_listener, {})
	vim.api.nvim_create_user_command("FlutterBlocProvider", wrap_with_bloc_provider, {})
	vim.api.nvim_create_user_command("FlutterBlocSelector", wrap_with_bloc_selector, {})
	vim.api.nvim_create_user_command("FlutterBlocConsumer", wrap_with_bloc_consumer, {})

	-- Register command handlers for our code actions
	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(args)
			local client = vim.lsp.get_client_by_id(args.data.client_id)

			-- Check if client supports code actions
			if client and client.server_capabilities.codeActionProvider then
				-- Register command handlers
				vim.lsp.commands["flutter-bloc.wrap-with-bloc-builder"] = wrap_with_bloc_builder
				vim.lsp.commands["flutter-bloc.wrap-with-bloc-listener"] = wrap_with_bloc_listener
				vim.lsp.commands["flutter-bloc.wrap-with-bloc-provider"] = wrap_with_bloc_provider
				vim.lsp.commands["flutter-bloc.wrap-with-bloc-selector"] = wrap_with_bloc_selector
				vim.lsp.commands["flutter-bloc.wrap-with-bloc-consumer"] = wrap_with_bloc_consumer

				-- Register the custom source for code actions
				client.handlers = client.handlers or {}
				client.handlers["textDocument/codeAction"] = handle_code_actions
			end
		end,
	})
end

return M
