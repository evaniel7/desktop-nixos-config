# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, system, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Safety while iterating (lets you pick an older generation)
  boot.loader.timeout = 5;
  boot.loader.systemd-boot.configurationLimit = 10;

  networking.hostName = "hyprland"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

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

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # nix flakes 
  nix.settings.experimental-features = [ "nix-command" "flakes" ]; 

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.evaniel = {
    isNormalUser = true;
    description = "Evan Harnak";
    extraGroups = [ "networkmanager" "wheel" ];
  };  

  # file manager
  programs.thunar.enable = true; 

  # virtualization
   virtualisation.virtualbox.host.enable = true;
   users.extraGroups.vboxusers.members = [ "evaniel" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     	vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    # terminal emulator
    	kitty 
    # browsers
    	firefox
    	brave
	vivaldi
    # applications
	pcloud
	discord
	(vesktop.overrideAttrs (old: {
          patches = (old.patches or []) ++ [
            (fetchpatch {
              url = "https://github.com/Vencord/Vesktop/pull/1251.patch";
              hash = "sha256-WmnXRISB1vfnbvSXJlD6sGkl5HSBTHpye+ezLyidtHU=";
            })
          ];
	}))
        # discordchatexporter-desktop
    # audio
    	pavucontrol
   	spotify 
        strawberry
	reaper
    # quality of life
    	rofi
	# wineWow64Packages.stable
        wineWow64Packages.waylandFull
    # virtualization 
    	qemu
    # tool
    	wget
    	fastfetch
    	btop
    	gparted
    	git
	grimblast
	gimp
    # hyprland
	hyprpaper
        sddm-astronaut  

    	inputs.nix-index-database.packages."${system}".comma-with-db
    # nix-specific
    	comma
    # work
	rustup
	rclone
    # games
        prismlauncher
    #   tailscale
    # languages 
    # racket
    # txt editors and IDEs
    # libre office
    # hunspellDicts.en-us
    # Obsidian
    	obsidian
    # codium
    	vscodium
    # Eclipse and dependencies (C/C++)
    # eclipses.eclipse-cpp
    # gcc
    # gdb
    # gnumake
	jdk25
    # video
	vlc
	ani-cli

    # Other system-wide packages
	uv
    (python3.withPackages (python-pkgs: with python-pkgs; [
      	pandas
	requests
      # add other Python packages here
    ]))    

    (prismlauncher.override {
          jdks = [
            # javaPackages.compiler.temurin-bin.jdk-25
            javaPackages.compiler.temurin-bin.jdk-21
            javaPackages.compiler.openjdk17
            javaPackages.compiler.openjdk8
          ];
        })

  ];
  
  #enable hyprland 
  programs.hyprland.enable = true;

  services.xserver.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "sddm-astronaut-theme";
    extraPackages = [ pkgs.sddm-astronaut ];  
  }; 

  # for vesktop
  # in your configuration.nix
   xdg.portal = {
     enable = true;
     extraPortals = [
       pkgs.xdg-desktop-portal-hyprland
       pkgs.xdg-desktop-portal-gtk
     ];
   };
  environment.sessionVariables.NIXOS_OZONE_WL = "1";


  # pipewire 
  services.pipewire.enable = true;
  services.pipewire.alsa.enable = true; # For ALSA compatibility
  services.pipewire.pulse.enable = true; # For PulseAudio compatibility

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # docker
  # virtualization.docker.enable = true; 

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
  system.stateVersion = "25.05"; # Did you read the comment?

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };

  users.defaultUserShell = pkgs.zsh;

  # Enable automatic store optimization
  nix.settings.auto-optimise-store = true;

  # Run GC automatically
  nix.gc = {
    automatic = true;
    dates = "daily";           # or "weekly"
    options = "--delete-older-than 7d";
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  # programs.gamescope.enable = true;

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    open = false;

    # Enable the Nvidia settings menu,
	# accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  
  services.tailscale.enable = true;
}
