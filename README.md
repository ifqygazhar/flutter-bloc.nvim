# flutter-bloc.nvim

A Neovim plugin for generating bloc and cubit boilerplate code with support for code actions.

Note : This is plugin fork from wa11breaker/flutter-bloc.nvim, just remove the none-ls requirement depedencies.

[![Preview](https://i.imgur.com/4GtjuPW.gif)](https://github.com/wa11breaker/flutter-bloc.nvim/assets/28669642/de135918-93ce-4157-95ab-9ad5971c45b4)

#### Features

- [x] Generate bloc boiler plate code
- [x] Generate cubit boiler plate code
- [x] Code actions

#### Installation

- With [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'ifqygazhar/flutter-bloc.nvim',
  opts = {
    bloc_type = 'default', -- Choose from: 'default', 'equatable', 'freezed'
    use_sealed_classes = false,
    enable_code_actions = true,
  }
}
```

- With [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'ifqygazhar/flutter-bloc.nvim',
  config = function()
    require('flutter-bloc').setup({
      bloc_type = 'default', -- Choose from: 'default', 'equatable', 'freezed'
      use_sealed_classes = false,
      enable_code_actions = true,
    })
  end
}
```

## Configuration Options

> [!NOTE]
> Currently doesn't support plugin invocation from tree explorer to generate bloc inside a folder. You will get 'attempt to concatenate local 'buf_directory' (a nil value)' as the buf_direcotry will be nil.

- `bloc_type`: Specifies the type of BLoC generation

  - `'default'`: Standard BLoC generation
  - `'equatable'`: Uses Equatable for equality comparisons
  - `'freezed'`: Generates code with Freezed immutable classes

- `use_sealed_classes`: Enables or disables sealed classes generation

## Usage

### Built-in Commands

Commands

- `:FlutterCreateBloc` - Create a new Bloc
- `:FlutterCreateCubit` - Create a new Cubit

Code Actions

- Wrap with `BlocBuilder`
- Wrap with `BlocSelector`
- Wrap with `BlocListener`
- Wrap with `BlocConsumer`
- Wrap with `BlocProvider`
- Wrap with `RepositoryProvider`

### Custom Key Mappings

You can add custom key mappings to streamline your workflow:

```lua
-- Create BLoC quickly
vim.keymap.set("n", "<Leader>cfb", "<cmd>lua require('flutter-bloc').create_bloc()<cr>", {
  desc = '[C]reate [F]lutter [B]loc'
})

-- Create Cubit quickly
vim.keymap.set("n", "<Leader>cfc", "<cmd>lua require('flutter-bloc').create_cubit()<cr>", {
  desc = '[C]reate [F]lutter [C]ubit'
})
```

## Documentation

For detailed documentation and advanced usage, refer to the help file:

- `:help flutter-bloc.nvim`
