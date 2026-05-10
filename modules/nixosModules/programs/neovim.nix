{
  flake.nixosModules.neovim = {
    config,
    pkgs,
    ...
  }: {
    users.users.${config.preferences.user.name}.packages = with pkgs; [
      fd
      ripgrep
    ];
    home-manager.users.${config.preferences.user.name} = {
      programs.neovim = {
        enable = true;
        defaultEditor = false;
        viAlias = true;
        vimAlias = true;
        plugins = with pkgs.vimPlugins; [
          neo-tree-nvim
          telescope-nvim
          nvim-web-devicons
          nvim-treesitter
        ];
        extraConfig = ''
          set shiftwidth=2 smarttab
          set expandtab
          set tabstop=8 softtabstop=0
        '';
        extraLuaConfig = ''

          require("telescope").setup()
        '';
      };
    };
  };
}
