# Install a new machine

```sh
curl -fsSL 'https://raw.githubusercontent.com/jcayzac/dotfiles/master/install/install.sh' | /bin/bash
```

## State dir, phases and checkpoints

The script maintains its state in the `~/INSTALL_STATE` directory, which has
permission `700` and is deleted after the install is complete.

_Phases_ are applied in sequence, e.g. `ssh-config`, `buildtools`, `homebrew` etc.
When a phase completes, the script saves a _checkpoint_. Running the script
multiple times (e.g. if a phase failed and had to be modified) skips all the
phases whose checkpoint is found.

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
