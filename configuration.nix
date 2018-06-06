# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];


  # Hardware extensions
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.enable = true;

  virtualisation.docker.enable = true;
  virtualisation.virtualbox.host.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "peter-stoeptegel"; # Define your hostname.
  networking.networkmanager.enable = true;

  # Select internationalisation properties.
  i18n = {
   consoleFont = "Powerline";
   consoleKeyMap = "us";
   defaultLocale = "en_US.UTF-8";
  };
  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    # Because some people use shitty Windows
    ntfs3g
    # Command line utils
    xorg.xhost wirelesstools psmisc wget p7zip file youtube-dl unrar curl zsh oh-my-zsh htop lm_sensors
    # Themes & GUI
    adapta-gtk-theme mate.mate-icon-theme-faenza xscreensaver
    # Internet shit
    rambox firefox signal-desktop chromium #skypeforlinux
    # Dev tools
    atom sqlitebrowser git arduino zulu8 nodejs-8_x ruby python3 jetbrains.idea-community
    # Office
    libreoffice zoom-us
    # Creativity
    inkscape gimp gifsicle gimpPlugins.resynthesizer2 hugin kazam shutter blender audacity soundfont-fluid
    # GUI utils
    gnome3.file-roller transmission_gtk evince
    # Recreational stuff
    steam vlc pavucontrol
    # Android
    jmtpfs androidsdk
    # Spelling
    aspell aspellDicts.en aspellDicts.nl
    # VM stuff
    docker_compose wine virtualbox
    # Security
    veracrypt keepass pwgen openssl keybase
  ];

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.bash.enableCompletion = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";
  services.xserver.videoDrivers = [ "amdgpu-nonfree" ];
  services.xserver.displayManager.lightdm.enable = true;

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # XFCE and plugins
  services.xserver.desktopManager.xfce.enable = true;
  services.xserver.desktopManager.xfce.thunarPlugins = with pkgs; [
      xfce.thunar-archive-plugin
      xfce.thunar_volman
  ];
  #services.xserver.desktopManager.plasma5.enable = true;

  # Nice graphical effects.
  services.compton = {
    enable          = true;
    fade            = true;
    inactiveOpacity = "0.9";
    shadow          = true;
    fadeDelta       = 4;
  };

  programs.zsh.enable = true;
  programs.zsh.interactiveShellInit = ''
    # Oh My ZSH
    export ZSH=${pkgs.oh-my-zsh}/share/oh-my-zsh/

    # Customize your oh-my-zsh options here
    ZSH_THEME="agnoster"
    plugins=(git)

    source $ZSH/oh-my-zsh.sh
    # End Oh My ZSH

    # Custom Git Commands
    git config --global alias.ac '!git add -A && git commit'
    git config --global user.email "peter@codebuffet.co"
    git config --global user.name "Peter Willemsen"

    # Easy aliasses
    alias sshbot='ssh root@bot -C -L 10000:localhost:10000 -L 8081:localhost:8081'
    alias install_atom_packages='apm install language-vue markdown-pdf nix vue2-autocomplete'
    alias spawn_customp='function spawn_customp(){ docker run --privileged --device /dev/snd:/dev/snd --device /dev/dri:/dev/dri --net=host -it --hostname=127.0.0.1 -w /$(basename `pwd`) -v $(pwd):/$(basename `pwd`) -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --name $1 $2 bash };spawn_customp'
    alias spawn_custom='function spawn_custom(){ docker run --net=host -it --hostname=127.0.0.1 -w /$(basename `pwd`) -v $(pwd):/$(basename `pwd`) -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --name $1 $2 bash };spawn_custom'
    alias spawn_ubuntu='function spawn_ubuntu(){ spawn_custom $1 ubuntu:16.04 };spawn_ubuntu'
    alias pkg_search='function pkg_search(){ nix-env -qaP | grep "$1" };pkg_search'
  '';
  programs.zsh.promptInit = ""; # Clear this to avoid a conflict with oh-my-zsh

  # Set up custom hosts
  networking.hosts = {
    "51.15.68.200" = ["bot"];
    "51.15.57.177" = ["flashio"];
    "51.15.63.224" = ["pikachu"];
    "136.144.171.45" = ["xurux"];

    # Disable tracking
    "127.0.0.1" = ["lmlicenses.wip4.adobe.com" "lm.licenses.adobe.com"];
  };

  # Firewall
  networking.firewall.enable = false;
  networking.firewall.allowedTCPPorts = [ 22 ];

  # Security
  security.chromiumSuidSandbox.enable = true;
  services.udev = {
    extraRules = ''
      SUBSYSTEM=="input", GROUP="input", MODE="660"
    '';
  };

  # Dont hurt my eyes
  services.redshift = {
    enable = true;
    latitude = "52.132633";
    longitude = "5.291266";
    temperature.day = 5400;
    temperature.night = 3600;
    brightness.day = "1";
    brightness.night = "0.5";
    extraOptions = ["-m randr"];
  };

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      corefonts # Microsoft free fonts
      dejavu_fonts
      powerline-fonts
      ubuntu_font_family
    ];
  };

  # Users
  users.extraUsers.peter =
  { isNormalUser = true;
    home = "/home/peter";
    description = "Peter Willemsen";
    extraGroups = [ "video" "vboxusers" "wheel" "networkmanager" "audio" "docker" "dialout" "input" ];
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCknOdoOnP+LttM4tkdlXUb2PC9RRFUTxGTDpEu5C2sN7sfQ9+xYUtXrFMqCIOWFv3U3e0d/T0pgw3LHmLGtbvLXDLCs5QerDxNmZs9qAdp6WqKspA/l3Zp3E2nT6OGZQ4sF0bKYatNilkDtgfoOMe2Nl1I91dj6j5j76jHLYPEBx02NAEDXv7jYaeGBE3DCv+gVcVQwwLDhj3Dg/EUJmzt9lMFXumJPeKP9FFJ9diK/7973O1ZjyIF3xh/AMeu7bdNf2k681UWzttDDjeUEcRKDkgjDul5DPK/s6a3pTpSW4WcBl1+EblOA9+Mn972UsdBMWILM5YZMv+bYGHeglY+beLbhn6htBg6Mug5seow+HELYaRoT4Mwb25PqSYlba4F5uu8QIdK1kmInc71SsmosmkjNfpC1dRlsZDG9bUCgqUIzXc7kEYdutfCK/NPn/+jNUNDLEWhBiaqGwl1/yBrGYoCEEJAg2sOWwO3qvmp73KehJW94XGD+wVq5p0LMUv5d7T2IWW8GxaPJXwyuLvtwBqf1r1fG4pz+/6HOaIXyh1g754hadh+zNPdEy8bkbnb2rwYlQlVHnup7yrgJz+4JH2Q0j0p/G6CUhxPa+VKAe8URxoE71M9lKM6OBIQlU5CSVVDdLsU6pYclDQDMqcrylZZGJ66Ghi6GNR6WhYsMQ== work 2" ];
    shell = pkgs.zsh;
    hashedPassword = "$6$VeKFrngY$/4jSrGKKyY6LSpkkdCyrNMhaJ37vRbUdeYAMGhMTtox1xAmmkCHg65NHAgf1K2NyEBPqYTG1nS7WPKIr7MWWv.";
  };

  system.stateVersion = "nixos-18.03";
  nix.gc = {
    automatic = true;
  };

  nixpkgs.config = {
    allowUnfree = true;
    virtualbox = {
      enableExtensionPack = false;
    };

    firefox = {
     enableAdobeFlash = false;
    };
    chromium = {
     enablePepperFlash = true; # Chromium removed support for Mozilla (NPAPI) plugins so Adobe Flash no longer works
     enablePepperPDF = true;
    };
  };
}
