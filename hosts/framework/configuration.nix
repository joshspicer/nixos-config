# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:


#with pkgs;
#let vscode-insiders =
#    (pkgs.vscode.override { isInsiders = true; }).overrideAttrs (oldAttrs: rec {
#      src = (builtins.fetchTarball {
#        url = "https://vscode.download.prss.microsoft.com/dbazure/download/insider/804f450ca900d24db25e7174e8b6dfb3fb2a318c/code-insider-x64-1729606376.tar.gz";
#        sha256 = "sha256:1g1hqgnmiprz3ca97jxdh74kqlf89hznb40bhi32zkszjd2309v3";
#      });
#      version = "latest";
#    });
#in
{
  imports =
    [ # Include the results of the hardware scan.
      <nixos-hardware/framework/13-inch/13th-gen-intel>
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "framework"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  services.tailscale.enable = true;
  services.usbmuxd.enable = true;

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  hardware.hackrf.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;
  
  programs.hyprland.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";


  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [
    pkgs.gutenprint
    pkgs.cnijfilter2
    pkgs.canon-cups-ufr2
  ];

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.josh = {
    isNormalUser = true;
    description = "josh";
    extraGroups = [
      # Access devices over serial (ie Arduino/ESP devices)
      "tty"
      "dialout"
      # Misc 
      "networkmanager" 
      "wheel"
      # HackRf/SDR
      "plugdev" 
    ];
    packages = with pkgs; [
      kitty
      kdePackages.kate
      vim
      spotify
      firefox
      thunderbird
      zoom-us
      bitwarden
      bambu-studio
      obsidian
      tailscale
      signal-desktop
      qemu
      rpi-imager
      docker-compose
      linux-wifi-hotspot
      devcontainer
      motion
      nodejs_22
      esphome
      ytcast
    ];
  };

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "josh" ];
  virtualisation.docker.enable = true;
  users.extraGroups.docker.members = [ "josh" ];
 # virtualisation.docker.rootless = {
 #   enable = true;
 #   setSocketVariable = true;
 # };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    busybox
    #vscode-insiders
    vscode
    libqalculate
    git
    jq
    gh
    vim
    realvnc-vnc-viewer
    meld # diff GUI tool
    wget
    evince
    vlc
    mitmproxy
    # -- hackrf/SDR --
    gnuradio
    gnuradioPackages.osmosdr
    hackrf
    # ----------------
    dig
    htop
    file
    gparted
    gcc
    chromium
    # Arduino / Pimoroni
    arduino-cli
    python3
    esptool
    thonny
    # iPhone USB tethering
    libimobiledevice
    # LibreOffice
    libreoffice-qt
    hunspell
    hunspellDicts.en_US
    # Math
    sage
    # hyprland WM
    waybar
    hyprpaper
    rofi 
];

  environment.variables = {
    EDITOR = "vim";
  };


  programs.kdeconnect.enable = true;

  nix.gc = {
    automatic = true;
    randomizedDelaySec = "14m";
    options = "--delete-older-than 30d";
  };


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # https://github.com/tailscale/tailscale/issues/4432#issuecomment-1112819111
  networking.firewall.checkReversePath = "loose";

  # Expose privileged ports with docker, etc...
  #boot.kernel.sysctl = {
  #  "net.ipv4.ip_unprivileged_port_start" = 53;
  #};

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 3000 ];
    allowedTCPPortRanges = [
      {
        from = 1714;  to = 1764;  # KDE Connect
      }
    ];
    # allowedUDPPorts = [ 53 19132 ];
    allowedUDPPortRanges = [
      {
        from = 1714; to = 1764;  # KDE Connect
      }
    ];
  };
 

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
