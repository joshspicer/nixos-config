

{ config, pkgs, ... }:

let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };

  tex = (pkgs.texlive.combine {
    inherit (pkgs.texlive) scheme-medium
       titlesec lastpage enumitem wrapfig amsmath ulem hyperref capt-of;
      #(setq org-latex-compiler "lualatex")
      #(setq org-preview-latex-default-process 'dvisvgm)
  });

in
{
  # Replace with a newer version of tailscaled
  # https://nixos.org/manual/nixos/unstable/#sec-replace-modules
  disabledModules = [ "services/networking/tailscale.nix"  ];

  imports =
    [
      <nixos-hardware/framework/13-inch/13th-gen-intel>
      <nixos-unstable/nixos/modules/services/networking/tailscale.nix>
      ./hardware-configuration.nix
    ];

  services.tailscale.enable = true;

  # Bootloader.
  #boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.devices = ["nodev"];
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.efiSupport = true;

  # Debug these kernel panics
  # boot.crashDump.enable = true;
  # kernel.sysctl.sysrq = 1; # NixOS default: 16, https://discourse.nixos.org/t/my-nixos-laptop-often-freezes/6381/11

  # iOS USB tethering
  services.usbmuxd.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  networking.hostName = "obsidian"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

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
  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

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
  sound.enable = true;
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
    ];
    packages = with pkgs; [
      spotify
      firefox
      thunderbird
      bitwarden
      cura
      obsidian
      unstable.tailscale
      signal-desktop
      qemu
      rpi-imager
      docker-compose
      linux-wifi-hotspot
    ];
  };

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "josh" ];

  virtualisation.docker.enable = true;
  users.extraGroups.docker.members = [ "josh" ];
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.permittedInsecurePackages = [
    "electron-24.8.6"
    "electron-25.9.0" 
  ];

  # Keep computer alive when closing laptop lid
  # Note: In this setup, also need to disable in KDE settings
  # services.logind.lidSwitch = "ignore";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    busybox
    unstable.vscode # VS Code is released monthly
    #vscode
    libqalculate
    git
    jq
    unstable.gh
    vim
    meld # diff GUI tool
    kdeconnect
    wget
    evince
    vlc
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
    # Tex
    python311Packages.pygments
    tex
    texmaker
    # iPhone USB tethering
    libimobiledevice
    # LibreOffice
    libreoffice-qt
    hunspell
    hunspellDicts.en_US
    # Math
    sage
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

#  networking.extraHosts =
#    ''
#    localhost geo.hivebedrock.network
#    localhost hivebedrock.network
#    '';

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
  system.stateVersion = "23.05"; # Did you read the comment?

}
