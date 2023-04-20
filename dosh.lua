local config_dir = "~/.config/emacs/"

cmd.add_task{
   name="install",
   description="setup my emacs.",
   command=function()
      cmd.run("mkdir -p " .. config_dir)
      cmd.copy("*init.el", config_dir)
      cmd.copy("copilot.el/", config_dir)
   end
}
