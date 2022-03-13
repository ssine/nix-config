{ config, pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    extensions = (with pkgs.vscode-extensions; [
      # find pre-packaged extensions at
      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/misc/vscode-extensions/default.nix
      WakaTime.vscode-wakatime
      eamodio.gitlens
      ms-python.python
      ms-azuretools.vscode-docker
      ms-vscode-remote.remote-ssh
      mechatroner.rainbow-csv
      esbenp.prettier-vscode
      pkief.material-icon-theme
      yzhang.markdown-all-in-one
      jnoortheen.nix-ide
    ]);
    userSettings = {
      "workbench.colorTheme" = "Monokai";
      "window.zoomLevel" = 2;
      "workbench.iconTheme" = "material-icon-theme";
      "editor.fontFamily" = "'Cascadia Code', 'Droid Sans Mono', 'monospace', monospace, 'Droid Sans Fallback'";
      "editor.fontLigatures" = "'ss01', 'ss02', 'ss03', 'ss04', 'ss05', 'ss06', 'zero', 'onum'";
      "window.menuBarVisibility" = "toggle";
      "terminal.integrated.fontSize" = 13;
      "security.workspace.trust.untrustedFiles" = "newWindow";
      "explorer.confirmDragAndDrop" = false;
      "window.titleBarStyle" = "custom";
      "explorer.confirmDelete" = false;
      "git.confirmSync" = false;
    };
  };
}
