{
  programs.nixvim.plugins = {
    dap.enable = true;
    dap-go.enable = true;
    dap-ui.enable = true;
    dap-python.enable = true;
    dap-lldb.enable = true;
    dap-virtual-text.enable = true;
    neotest = {
      enable = true;
      adapters.bash.enable = true;
      adapters.go.enable = true;
      adapters.python.enable = true;
      adapters.rust.enable = true;
    };
  };
}
