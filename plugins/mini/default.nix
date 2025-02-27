{ pkgs, lib, config, ... }:

with lib;

let

  name = "mini";
  pluginUrl = "https://github.com/echasnovski/mini.nvim";

  cfg = config.programs.nixneovim.plugins.${name};
  helpers = import ../../helper { inherit pkgs lib config; };
  inherit (helpers)
    convertModuleOptions;

  # TODO: move to files and add options
  modules = {
    ai = import ./modules/ai.nix { inherit lib helpers; };
    align = { };
    animate = { };
    base16 = { };
    basics = { };
    bracketed = { };
    bufremove = { };
    comment = { };
    completion = { };
    cursorword = { };
    doc = { };
    fuzzy = { };
    indentscope = { };
    jump = { };
    jump2d = { };
    map = { };
    misc = { };
    move = { };
    pairs = { };
    sessions = { };
    splitjoin = { };
    starter = { };
    statusline = { };
    surround = { };
    tabline = import ./modules/tabline.nix { inherit lib helpers; };
    test = { };
    trailspace = { };
  };

  # convert module list to module set for cfg
  # - adds the enable option
  # - adds the extraConfig Option
  moduleOptions = mapAttrs
    (module: config:
      config // {
        enable = mkEnableOption "Enable mini.${module}";
        extraConfig = mkOption {
          type = types.attrs;
          default = { };
          description = "Place any extra config here as an attibute-set";
        };
      }
    )
    modules;

  # pluginOptions = helpers.convertModuleOptions cfg moduleOptions;

in
with helpers;
mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    mini-nvim
  ];
  extraConfigLua =
    let
      setup = mapAttrsToList
        (module: options:
          let
            # combine the lua configs with their values from the nix-module config value and add extraConfig
            setup = convertModuleOptions cfg.${module} (options // { extraConfig = { }; });
          in
          if cfg.${module}.enable then
            "require('${name}.${module}').setup(${helpers.toLuaObject setup})"
          else
            ""
        )
        modules;
    in
    toConfigString setup;
    defaultRequire = false;
}
