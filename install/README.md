# Install a new machine

```sh
curl -fsSL 'https://raw.githubusercontent.com/jcayzac/dotfiles/master/install/install.sh' | /bin/bash
```

## Passwords

When it starts, the script asks for some passwords:

- The `sudo` password, which is then used to make an `askpass` program.
- The password to use to decrypt the various encrypted files (private keys and tokens).

All are stored in the state dir with permission `700`, and deleted at the end.

## Profiles

Currently two profiles are supported:

- `home` for a home machine;
- `work` for a company machine.

The detection is kind of stupid: if the user belongs to any group whose name has a `\`, it's a company machine. If not, it's a home machine.

Profiles can have additional configuration merged during the install:

- `homebrew.packages.<profile>` automatically gets merged with `homebrew.packages`.
- `mas.packages.<profile>` automatically gets merged with `mas.packages`.
