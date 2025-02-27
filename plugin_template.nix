{ pkgs, lib, config, ... }:

with lib;

let

  name = "PLUGIN_NAME";
  pluginUrl = "PLUGIN_URL";

  helpers = import import ../../helper { inherit pkgs lib config; };
  cfg = config.programs.nixneovim.plugins.${name};

  moduleOptions = with helpers; {
    # add module options here
    #
    # autoStart = boolOption true "Enable this pugin at start"
  };

  # pluginOptions = {
  #   # manually add plugin mapping of module options here
  #   #
  #   # auto_start = cfg.autoStart
  # };

  # you can autogenerate the plugin options from the moduleOptions.
  # This essentially converts the camalCase moduleOptions to snake_case plugin options
  pluginOptions = helpers.convertModuleOptions cfg moduleOptions;

in
with helpers;
mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    # nvim-treesitter
  ];
  extraPackages = with pkgs; [
    # add dependencies here
    # tree-sitter
  ];
  extraConfigLua = "require('${name}').setup ${toLuaObject pluginOptions}";
  defaultRequire = false;
}
