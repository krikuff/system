{config, pkgs, ... }:

let
  jumpapp = let
    runtimePath = pkgs.lib.makeSearchPath "bin" (with pkgs; [ xdotool wmctrl xorg.xprop nettools perl ]);
  in
    pkgs.stdenv.mkDerivation rec {
      version = "1.1";
      name = "jumpapp-${version}";
      src = pkgs.fetchFromGitHub {
        owner = "cobsea";
        repo = "jumpapp";
        rev = "708619cb8de1f0781f481e1fcd56bdf4bf4f74b9";
        hash = "sha256:1jrk4mm42sz6ca2gkb6w3dad53d4im4shpgsq8s4vr6xpl3b43ry";
      };
      makeFlags = [ "PREFIX=$(out)" ];
      buildInputs = [ pkgs.perl pkgs.pandoc ];
      postFixup = ''
        sed -i "2 i export PATH=${runtimePath}:\$PATH" $out/bin/jumpapp
        sed -i "2 i export PATH=${runtimePath}:\$PATH" $out/bin/jumpappify-desktop-entry
      '';
    };

  extensions = (with pkgs.vscode-extensions; [
    ms-vscode.cpptools matklad.rust-analyzer
  ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    {
      name = "Nix";
      publisher = "bbenoist";
      version = "1.0.1";
      sha256 = "0zd0n9f5z1f0ckzfjr38xw2zzmcxg1gjrava7yahg5cvdcw6l35b";
    }
    {
      name = "cmake-tools";
      publisher = "ms-vscode";
      version = "1.4.1";
      sha256 = "18hj94p3003cba141smirckpsz56cg3fabb8il2mx1xzbqlx2xhk";
    }
    {
      name = "cmake";
      publisher = "twxs";
      version = "0.0.17";
      sha256 = "11hzjd0gxkq37689rrr2aszxng5l9fwpgs9nnglq3zhfa1msyn08";
    }
    {
      name = "language-haskell";
      publisher = "justusadam";
      version = "3.3.0";
      sha256 = "1285bs89d7hqn8h8jyxww7712070zw2ccrgy6aswd39arscniffs";
    }

  ]);

  vscode-with-extensions = pkgs.vscode-with-extensions.override {
    vscodeExtensions = extensions;
  };

  vim_configurable = pkgs.vim_configurable.override {
    python = pkgs.python3; # enable python3 support in vim and disable python2 support
  };
in
{
  imports =
    [
      ./hardware-configuration.nix
    ];

  nixpkgs.config.allowUnfree = true;

  boot.loader = {
    grub.useOSProber = true;
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  systemd.extraConfig = "DefaultTimeoutStopSec=10s";

  hardware.enableAllFirmware = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.blueman.enable = true;

  programs.fish = {
    enable = true;
    shellAliases = {
      e = "exa";
      ll = "exa --git -lh";
      lt = "exa --git -lhTL";
      cal = "cal --monday";
      bat = "bat -pp";
      df = "df -h";
      v = "vim";
    };
    promptInit = builtins.readFile ./fish_init.fish;
  };

  users = {
    defaultUserShell = pkgs.fish;
    users.cobsea = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };
  };

  environment.variables.EDITOR = "vim";

  environment.systemPackages = with pkgs; [
    ark
    firefox
    galculator
    keepassx2
    kitty
    libreoffice
    ly
    mpv
    plasma-browser-integration
    spectacle
    tdesktop
    vscode-with-extensions

    # Langs
    clang
    clang-tools
    cmake
    gcc9
    gcc9Stdenv
    gdb
    ghc
    glibc.dev
    glibcInfo
    glibcLocales
    glibc_memusage
    glibc_multi
    gnumake
    libcsptr
    libgcc
    lld
    lldb
    llvm
    ninja
    nodejs-12_x
    perl
    python3
    rust-analyzer
    rustup
    swift

    # Utils
    binutils
    bluez
    cloc
    curl
    feh
    git
    git-hub
    gnupg
    htop
    hyperfine
    linuxPackages.perf
    neofetch
    pciutils
    pinentry
    sxiv
    valgrind
    wget
    xbindkeys
    xclip
    zathura

    # Rust utils
    bat
    exa
    fd
    ripgrep

    # vim
    (vim_configurable.customize {
      name = "vim";
      vimrcConfig.packages.myplugins = with pkgs.vimPlugins; { start = [
        NeoSolarized
        YouCompleteMe
        syntastic
        vim-airline
        vim-airline-themes
        vim-fish
        vim-markdown
        vim-nix
      ]; };
      vimrcConfig.customRC = builtins.readFile ./vimrc;
    })
  ];

  fonts = {
    enableFontDir = true;
    enableDefaultFonts = true;
    fonts = with pkgs; [
      fira-code
      hack-font
      iosevka
      jetbrains-mono
      noto-fonts
      noto-fonts-emoji
    ];

    fontconfig = {
      defaultFonts = {
        monospace = ["JetBrains Mono"];
      };
    };
  };

  # Copypasted from github. Resolves shutdown and GPU issues,
  # but disables GPU
  boot.kernelPackages = pkgs.linuxPackages_latest;
  #services.xserver.videoDrivers = ["modesetting"];
  boot.blacklistedKernelModules = ["nouveau"];

  # second solution form same github issue, enables GPU:
  hardware = {
    nvidia = {
      modesetting = {
        enable = true;
      };

      prime = {
        sync.enable = true;
        # values are from lspci
        # try lspci | grep -P 'VGA|3D'
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };

  # The following line is moved below
  # services.xserver.videoDrivers = ["nvidia"];
  # end of the solution

  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };

  # The X11 windowing system
  services = { xserver = {
    enable = true;
    layout = "us,ru";
    xkbOptions = "eurosign:e, grp:lwin_toggle, grp:rwin_toggle";

    videoDrivers = ["nvidia"];

    # Touchpad
    libinput = {
      enable = true;
      disableWhileTyping = true;
      tappingDragLock = false;
    };

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu
        i3status
        i3lock
        i3blocks
      ];
    };
  };};

  networking = {
    hostName = "nixos"; # hostname
    networkmanager.enable = true;
    useDHCP = false;

    interfaces.eno1.useDHCP = true;
    interfaces.wlo1.useDHCP = true;

  # proxy.default = "http://user:password@proxy:port/";
  # proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  };

  console.font = "JetBrains Mono";
  console.keyMap = "us";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    # TODO: maybe i can get rid of the following option since not using plasma
    extraLocaleSettings = {
      LANG = "en_US.UTF-8";
      LC_CTYPE = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
      LC_COLLATE = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_MESSAGES = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_ADDRESS = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";
    };
  };

  time.timeZone = "Asia/Tomsk";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?
}
