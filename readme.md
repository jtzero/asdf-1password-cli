<div align="center">

# asdf-1password-cli [![Build](https://github.com/jtzero/asdf-1password-cli/actions/workflows/build.yml/badge.svg)](https://github.com/jtzero/asdf-1password-cli/actions/workflows/build.yml) [![Lint](https://github.com/jtzero/asdf-1password-cli/actions/workflows/lint.yml/badge.svg)](https://github.com/jtzero/asdf-1password-cli/actions/workflows/lint.yml)


[1password-cli](https://github.com/1password-cli/1password-cli.git) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Install

Plugin:

```shell
asdf plugin add 1password-cli
# or
asdf plugin add 1password-cli https://github.com/jtzero/asdf-1password-cli.git
```

1password-cli:

```shell
# Show all installable versions
asdf list-all 1password-cli

# Install specific version
asdf install 1password-cli latest

# Set a version globally (on your ~/.tool-versions file)
asdf global 1password-cli latest

# Now 1password-cli commands are available
1password-cli --version
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/jtzero/asdf-1password-cli/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [jtzero ?](https://github.com/jtzero/)
