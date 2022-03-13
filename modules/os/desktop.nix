{ config, pkgs, ... }:
{
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the Plasma 5 Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Configure keymap in X11
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "ctrl:swapcaps";

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  i18n.inputMethod.enabled = "ibus";
  i18n.inputMethod.ibus.engines = with pkgs.ibus-engines; [ libpinyin ];
  services.xserver.libinput.touchpad.naturalScrolling = true;

  fonts = {
    enableDefaultFonts = true;
    fonts = with pkgs; [
      pkgs.ubuntu_font_family
      pkgs.vistafonts-chs
      pkgs.cascadia-code
    ];

    fontconfig = {
      antialias = true;
      defaultFonts = {
        serif = [ "Microsoft YaHei" "Ubuntu" ];
        sansSerif = [ "Microsoft YaHei" "Ubuntu" ];
        monospace = [ "Cascadia Code" "Ubuntu" ];
      };
    };
  };
}
