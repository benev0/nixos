# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:
let
   unstable = import
     (builtins.fetchTarball https://github.com/nixos/nixpkgs/tarball/7881fbfd2e3ed1dfa315fca889b2cfd94be39337)
     # reuse the current configuration
     { config = config.nixpkgs.config; };
in
{
  # disabledModules = [
  #   "programs/wayland/uwsm.nix"
  # ];

  imports = [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./lanzaboote.nix
      inputs.home-manager.nixosModules.default
      #"${unstable}/nixos/modules/programs/wayland/uwsm.nix"
  ];

  nixpkgs.config = {
    # Allow unfree packages
    allowUnfree = true;
    permittedInsecurePackages = [
      "electron-25.9.0"
    ];
  };
 
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Bootloader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking.hostName = "nixos"; # Define your hostname.
  networking.wireless.iwd.enable = true;
  networking.wireless.iwd.settings = {
   IPv6 = {
      Enabled = false;
    };
    Settings = {
      AutoConnect = true;
    };
  };
  networking.networkmanager.wifi.backend = "iwd";

  # Configure network proxy if nessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];
  # Set your time zone.
  time.timeZone = "America/New_York";

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

  # thunar file maniger
  programs.thunar.enable = true;
  # thunar Mount/Trash/...
  services.gvfs.enable = true;
  # image thumbnails
  services.tumbler.enable = true; 

  programs.uwsm = {
    enable = true;
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSURS = "1";
    NIXOS_OZONE_WL = "1";
  };

  hardware = {
    graphics.enable = true;
    nvidia.modesetting.enable = true;
  };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  services.supergfxd.enable = true;

  services = {
    asusd = {
      enable = true;
      enableUserService = true;
    };
  };

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

  programs.bash.loginShellInit = "
    if uwsm check may-start && uwsm select; then
      exec systemd-cat -t uwsm_start uwsm start default
    fi
  ";

  programs.direnv.enable = true;
  programs.direnv.enableBashIntegration = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ben = {
    isNormalUser = true;
    description = "ben";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "podman"];
    packages = with pkgs; [
      texliveFull
      tlaplusToolbox
      obsidian
      firefox
      discord
      vscode-fhs
      nodejs
      gimp
      inkscape
    ];
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "ben" = import ./home.nix;
    };
  };

  # containers
  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  environment.memoryAllocator.provider = "libc";
  environment.systemPackages = with pkgs; [
    glibc
    vim
    gnupg
    sbctl niv
    # podman # likley enabled elsewhere
    dive
    podman-tui
    podman-compose
    git
    # hyprland stuff
    eww
    grim
    slurp
    mako
    libnotify
    hyprpaper
    alacritty
    bemenu
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

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
  system.stateVersion = "23.11"; # Did you read the comment?
}

