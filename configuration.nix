{ config, pkgs, ... }:

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

  # TODO: add rust-analyzer as nix-packaged instead of from marketplace
  extensions = (with pkgs.vscode-extensions; [
    ms-vscode.cpptools
  ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    {
      name = "rust-analyzer";
      publisher = "matklad";
      version = "0.2.297";
      sha256 = "0pj29k5pm1p7f987x9rjd0pks552fxvjv72dscxsk84svl132s0f";
    }
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

  hardware.enableAllFirmware = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  systemd.extraConfig = "DefaultTimeoutStopSec=10s";
  
  programs.fish = {
    enable = true;
    shellAliases = {
      e = "exa";
      el = "exa --git -lh";
      et = "exa --git -lhTL";
      cal = "cal --monday";
      bat = "bat -pp";
    };
    promptInit = import ./fish_init.nix;
  };

 environment.variables.EDITOR = "vim"; 

  users = {
    defaultUserShell = pkgs.fish;
    users.cobsea = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };
  };

  environment.systemPackages = with pkgs; [
    ark
    emacs
    firefox
    plasma-browser-integration
    galculator
    gwenview
    keepassx2
    kitty
    libreoffice
    mpv
    spectacle
    tdesktop
    vscode-with-extensions
    
    # Langs
    gcc9
    gdb
    glibc.dev
    gcc9Stdenv
    ghc
    libgcc
    glibc_multi
    glibc_memusage
    glibcInfo
    glibcLocales
    libcsptr
    clang
    clang-tools
    cmake
    gnumake
    nodejs-12_x
    lld
    lldb
    llvm
    ninja
    rustup
    python3
    perl
    swift

    libpulseaudio

    # Utils
    atool
    binutils
    bluez
    curl
    cloc
    feh
    ffmpegthumbnailer
    git
    git-hub
    gnupg
    graphviz
    hyperfine
    htop
    jumpapp
    linuxPackages.perf
    neofetch
    wget
    pciutils
    pinentry
    xclip
    xbindkeys
    valgrind

    # Rust utils
    bat
    exa
    fd
    ripgrep

    #vim
    (vim_configurable.customize {
      name = "vim";
      vimrcConfig.packages.myplugins = with pkgs.vimPlugins; { start = [
        syntastic
        vim-nix
        youcompleteme
      ]; };
      vimrcConfig.customRC = import ./vimrc.nix;
    })
  ];

  nixpkgs.config.firefox.enablePlasmaBrowserIntegration = true;
  services.blueman.enable = true;

  fonts = {
    enableFontDir = true;
    enableDefaultFonts = true;
    fonts = with pkgs; [
      hack-font
      fira-code
      noto-fonts
      noto-fonts-emoji
      iosevka
      jetbrains-mono
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

      optimus_prime = {
        enable = true;
        # values are from lspci
        # try lspci | grep -P 'VGA|3D'
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };

  # Moved below
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
    layout = "us";
    xkbOptions = "eurosign:e";

    videoDrivers = ["nvidia"];

    # Touchpad
    libinput = {
      enable = true;
      disableWhileTyping = true;
      tappingDragLock = false;
    };

    displayManager.sddm = {
      enable = true;
      autoNumlock = true;
    };

    desktopManager.plasma5.enable = true; 
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
