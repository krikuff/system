{config, pkgs, ... }:

let
  # TODO: get rid of vscode?
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

  programs = {
    slock.enable = true;
    fish = {
      enable = true;
      promptInit = builtins.readFile ./fish_init.fish;
    };
  };

  users = {
    defaultUserShell = pkgs.fish;
    users.cobsea = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };
  };

  environment.variables.EDITOR = "nvim";

  environment.systemPackages = with pkgs; [
    alacritty
    calibre
    ark
    dmenu
    feh # Only for setting the wallpaper. How to set it without feh?
    firefox
    galculator
    keepassx2
    libreoffice
    ly # TODO: find out how to use
    mpv
    polybar
    spectacle
    sxiv
    tdesktop
    vscode-with-extensions
    xmobar
    zathura

    # Langs
    clang-tools
    clang_11
    cmake
    gcc10
    gdb
    ghc
    gnumake
    lldb
    ninja
    nodejs-14_x
    perl
    python3
    rust-analyzer
    rustup
    # swift

    # Utils
    bat
    binutils
    bluez
    cloc
    curl
    dash # TODO: learn how to use it as /bin/sh
    exa
    fd
    git
    gnupg
    htop
    hyperfine
    killall
    linuxPackages.perf
    neofetch
    pciutils
    pinentry # what for? gpg or something like that?..
    ripgrep
    valgrind
    wget
    xclip

    # neovim
    (neovim.override {
      vimAlias = true;
      configure = {
        packages.myPlugins = with pkgs.vimPlugins; { start = [
            NeoSolarized
            coc-markdownlint
            coc-nvim
            coc-rust-analyzer
            vim-airline
            vim-airline-themes
            vim-fish
            vim-nix
            vim-signify
            vim-toml
          ];
          opt = [];
        };
        customRC = builtins.readFile ./vimrc;
      };
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
      siji
    ];

    fontconfig.defaultFonts.monospace = [ "JetBrains Mono" ];
  };

  # Copypasted from github. Resolves shutdown and GPU issues,
  # but disables GPU
  boot.kernelPackages = pkgs.linuxPackages; # TODO: change it back to linuxPackages_latest when nvidia module gets fixed
  #services.xserver.videoDrivers = ["modesetting"];
  boot.blacklistedKernelModules = [ "nouveau" ];

  # second solution form same github issue, enables GPU:
  hardware = {
    nvidia = {
      modesetting.enable = true;

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
  services.xserver = {
    enable = true;
    layout = "us,ru";
    xkbOptions = "eurosign:e, grp:shifts_toggle";

    videoDrivers = ["nvidia"];

    # Touchpad
    libinput = {
      enable = true;
      disableWhileTyping = true;
      tappingDragLock = false;
    };

    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
    };
  };

  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    useDHCP = false;

    interfaces.eno1.useDHCP = true;
    interfaces.wlo1.useDHCP = true;

  # proxy.default = "http://user:password@proxy:port/";
  # proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  };

  console.font = "JetBrains Mono";
  console.keyMap = "us";
  i18n.defaultLocale = "en_US.UTF-8";

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
