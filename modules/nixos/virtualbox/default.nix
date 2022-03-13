{ config, pkgs, ... }:
{
  users.extraGroups.vboxusers.members = [ "sine" ];
  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;
}
