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
  services.ntp = {
    enable = true;
    servers = [ "server.local" "0.pool.ntp.org" "1.pool.ntp.org" "2.pool.ntp.org" ];
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    # Command line utils
    xorg.xhost psmisc wget p7zip curl zsh oh-my-zsh htop lm_sensors
    # Themes & GUI
    adapta-gtk-theme mate.mate-icon-theme-faenza
    # Internet shit
    rambox firefox chromium
    # Dev tools
    atom sqlitebrowser git arduino nodejs-8_x ruby jetbrains.idea-community
    # Office
    libreoffice zoom-us
    # Creativity
    inkscape gimp hugin kazam shutter
    # GUI utils
    gnome3.file-roller transmission_gtk evince gnome3.sushi
    # Recreational stuff
    steam vlc pavucontrol
    # Android
    jmtpfs
    # Spelling
    aspell aspellDicts.en aspellDicts.nl
    # VM stuff
    docker_compose wine
    # Security
    veracrypt keepass pwgen openssl
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.bash.enableCompletion = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";
  services.xserver.videoDrivers = [ "amdgpu_nonfree" ];
  services.xserver.displayManager.lightdm.enable = true;

  # Enable touchpad support.
  services.xserver.libinput.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
  #services.xserver.desktopManager.plasma5.enable = true;

  # Nice graphical effects.
  services.compton = {
    enable          = false;
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
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 8100 ];

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
    extraGroups = [ "vboxusers" "wheel" "networkmanager" "audio" "docker" "dialout" ];
    openssh.authorizedKeys.keys = [  ];
    shell = pkgs.zsh;
    hashedPassword = "$6$VeKFrngY$/4jSrGKKyY6LSpkkdCyrNMhaJ37vRbUdeYAMGhMTtox1xAmmkCHg65NHAgf1K2NyEBPqYTG1nS7WPKIr7MWWv.";
  };

  system.stateVersion = "nixos-17.09";
  nix.gc = {
    automatic = true;
  };

  nixpkgs.config = {
    allowUnfree = true;
    virtualbox = {
      enableExtensionPack = false;
    };

    firefox = {
     enableAdobeFlash = true;
    };
    chromium = {
     enablePepperFlash = true; # Chromium removed support for Mozilla (NPAPI) plugins so Adobe Flash no longer works
     enablePepperPDF = true;
    };
  };
}
