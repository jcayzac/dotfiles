cask_args appdir: '/Applications'

# Taps
tap 'caskroom/cask'
tap 'homebrew/bundle'
tap 'homebrew/completions'
tap 'homebrew/core'
tap 'homebrew/dupes'
tap 'homebrew/services'
tap 'homebrew/python'

# Basic system
brew 'pkg-config'
brew 'libtool'
brew 'autoconf'
brew 'automake'
brew 'readline'
brew 'openssl'
brew 'libssh2'
brew 'curl'
brew 'libsodium'
brew 'pcre'
brew 'homebrew/dupes/ncurses'
brew 'git', args: ['with-blk-sha1', 'with-brewed-curl', 'with-brewed-openssl', 'with-pcre', 'with-persistent-https']
brew 'bash'
brew 'bash-completion'
brew 'bash-git-prompt'
brew 'colordiff'
brew 'coreutils'
brew 'dos2unix'
brew 'findutils'
brew 'gnu-sed'
brew 'htop', args: ['with-ncurses']
brew 'source-highlight'
brew 'thefuck'
brew 'vim', args: ['without-python', 'without-ruby', 'without-perl', 'without-nls']
brew 'xz', args: ['universal']
brew 'mas'
cask 'java' #unless system '/usr/libexec/java_home --failfast'
cask 'xquartz'
cask 'iterm2'

# Niceties
mas 'Alfred', id: 405843582
mas 'The Unarchiver', id: 425424353

# Internet
brew 'httrack'
brew 'minisign'
brew 'ncftp'
brew 'wget'
brew 'gnupg'
brew 'aria2', args: ['with-libssh2']
brew 'dnscrypt-proxy', args: ['with-plugins']
cask 'google-chrome'
cask 'firefox'
cask 'transmission'
cask 'jdownloader'
cask 'skype'
mas  'Slack', id: 803453959

# Media
brew 'exiftool'
brew 'ffmpeg'
cask 'vlc'
cask 'calibre'
mas  'iMovie', id: 408981434

# Programming
mas  'Xcode', id: 497799835
brew 'ruby-build'
brew 'rbenv'
brew 'nvm'
brew 'numpy'
brew 'go'
brew 'graphviz'
brew 'doxygen'
brew 'bazel'
brew 'flow'
brew 'watchman'
brew 'hugo'
cask 'atom'

# Android SDK
brew 'ant'
brew 'maven'
brew 'gradle'
brew 'android-sdk'
brew 'android-ndk'
brew 'dex2jar'

# ex: noet ci pi sts=0 sw=4 ts=4 filetype=sh