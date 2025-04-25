# Contributing guide

Thank you for considering contributing to `screenkey.nvim`! We welcome all
contributions, whether it's fixing bugs, adding new features, improving
documentation, or adding examples of usage.

## Table of contents

- [Table of contents](#table-of-contents)
- [Getting started](#getting-started)
- [Commit messages / PR title](#commit-messages--pr-title)
- [CI](#ci)
- [Development](#development)
  - [Formatting](#formatting)
  - [Linting](#linting)
  - [Static type checking](#static-type-checking)
  - [Running tests](#running-tests)
  - [Manual testing](#manual-testing)
- [Adding examples of usage](#adding-examples-of-usage)
- [General tips when writing code](#general-tips-when-writing-code)
- [Thank you](#thank-you)

## Getting started

If you want to contribute to `screenkey.nvim`, and you don't have a specific idea in mind, you can check the
[TODO](TODO.md) list for some ideas.

## Commit messages / PR title

Please ensure your pull request title conforms to [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/).

## CI

GitHub Actions will run the following checks on your PR:

- `busted` tests
- `luacheck` linting for lua files
- `markdownlint` linting for markdown files
- `stylua` formatting - checks if the lua files are formatted correctly

If any CI check fails, review the logs, correct any issues in your code, and
push the changes. If you're unsure, feel free to ask for assistance in the
discussions or open an issue for guidance.

## Development

We use the following tools:

### Formatting

- [`.editorconfig`](https://editorconfig.org/)
- [`stylua`](https://github.com/JohnnyMorganz/StyLua)

### Linting

- [`luacheck`](https://github.com/mpeterv/luacheck) for lua files
- [`markdownlint`](https://github.com/DavidAnson/markdownlint) for markdown files

### Static type checking

- [`lua-language-server`](https://luals.github.io/wiki/)

### Running tests

We use [`busted`](https://lunarmodules.github.io/busted/) for testing,
but with Neovim as the Lua interpreter.

You can run the test suite using `luarocks test` or `busted`. For more
information on how to set up Neovim as a Lua interpreter, see
[`nlua`](https://github.com/mfussenegger/nlua).

### Manual testing

If you want to test your contributions to `screenkey.nvim` manually,
we recommend you set [`NVIM_APPNAME`](https://neovim.io/doc/user/starting.html#%24NVIM_APPNAME)
to something other than `nvim`, so that your test environment
doesn't interfere with your regular Neovim installation or the plugins you use.

## Adding examples of usage

If you have an interesting use case for `screenkey.nvim`, or an unique
configuration, please consider opening a issue with your example. Include
screenshots or GIFs if possible, and

## General tips when writing code

- try to keep the code you add consistent with the existing code base
- use `---@param`, `---@return`, `---@type`, etc. annotations for functions/variables
- keep functions small and focused on a single task
- write comments for complex code
- write tests for your code (if you don't know how, or if it's too complex, ask for help)

## Thank you

We appreciate your time and effort in contributing to `screenkey.nvim`! Thank you!
