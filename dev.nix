{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    nixfmt
    neovim
    git
    zellij
    fish
    fishPlugins.bass
  ];
  programs.fish.enable = true;

  environment.sessionVariables = { EDITOR = "nvim"; };
  environment.shellAliases = {
    jfu = "journalctl --output cat -fu";
    ctl = "sudo systemctl";
    wfb_drone = "cd ~/wfb; wfb-server udp_drone wfb0";
    wfb_gs = "cd ~/wfb; wfb-server udp_gs wfb0";
    rbs = "sudo nixos-rebuild switch --flake";
  };
}
