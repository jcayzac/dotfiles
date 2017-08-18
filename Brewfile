cask_args appdir: '/Applications'

# Taps
tap 'caskroom/cask'
tap 'caskroom/fonts'
tap 'homebrew/bundle'
tap 'homebrew/completions'
tap 'homebrew/core'
tap 'homebrew/dupes'
tap 'homebrew/services'
tap 'homebrew/python'
tap 'homebrew/science'
tap 'buo/cask-upgrade'

# Basic system
brew 'pkg-config'
brew 'libtool'
brew 'autoconf'
brew 'automake'
brew 'readline'
brew 'ncurses'
brew 'openssl'
brew 'libssh2'
brew 'curl'
brew 'cputhrottle'
brew 'libsodium'
brew 'pcre'
brew 'git', args: ['with-blk-sha1', 'with-brewed-curl', 'with-brewed-openssl', 'with-pcre', 'with-persistent-https']
brew 'bash'
brew 'bash-completion'
brew 'bash-git-prompt'
brew 'colordiff'
brew 'coreutils'
brew 'dos2unix'
brew 'findutils'
brew 'fontconfig'
brew 'gnu-sed'
brew 'less', args: ['with-pcre']
brew 'lesspipe', args: ['with-syntax-highlighting']
brew 'htop', args: ['with-ncurses']
brew 'source-highlight'
brew 'thefuck'
brew 'vim', args: ['without-python', 'without-ruby', 'without-perl', 'without-nls']
cask 'font-inconsolata-for-powerline'
brew 'xz', args: ['universal']
brew 'mas'
cask 'java' #unless system '/usr/libexec/java_home --failfast'
cask 'xquartz'
cask 'iterm2'

# Niceties
mas  'Alfred', id: 405843582
mas  'The Unarchiver', id: 425424353
cask 'font-source-code-pro'
cask 'font-dejavu-sans'
cask 'font-open-sans'

# Internet
brew 'httrack'
brew 'minisign'
brew 'ncftp'
brew 'wget'
brew 'nmap'
brew 'rsync'
brew 'gpg-agent'
brew 'gpgme'
brew 'dirmngr'
brew 'aria2', args: ['with-libssh2']
brew 'dnscrypt-proxy', args: ['with-plugins'], restart_service: true
cask 'google-chrome'
cask 'firefox'
cask 'transmission'
cask 'jdownloader'
cask 'skype'
mas  'Slack', id: 803453959

# Media
brew 'exiftool'
brew 'imagemagick', args: ['with-webp']
brew 'eigen'
brew 'faac'
brew 'fdk-aac'
brew 'lame'
brew 'flac'
brew 'libogg'
brew 'libvorbis'
brew 'libvpx'
brew 'theora'
brew 'ffmpeg', args: ['with-x265', 'with-fdk-aac', 'with-libvpx', 'with-theora', 'with-libvorbis', 'with-webp']
brew 'mkvtoolnix', args: ['with-qt']
cask 'mkvtools'
cask 'vlc'
cask 'calibre'
mas  'iMovie', id: 408981434

# Programming
mas  'Xcode', id: 497799835
brew 'make'
brew 'cmake'
brew 'opencv'
brew 'ruby-build'
brew 'rbenv'
brew 'nvm'
brew 'numpy'
brew 'go'
brew 'graphviz'
brew 'doxygen'
brew 'bazel'
brew 'wellington'
brew 'flow'
brew 'watchman'
brew 'hugo'
cask 'sublime-text'
cask 'atom'
cask 'visual-studio-code'

# Android
brew 'ant'
brew 'maven'
brew 'gradle'
brew 'dex2jar'
brew 'google-java-format'
cask 'android-studio' # On first run, install the SDK to /usr/local/share/android-sdk

# ex: noet ci pi sts=0 sw=4 ts=4 filetype=sh
