return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`ControllerHudKeyboardFix` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("ControllerHudKeyboardFix", {
			mod_script       = "scripts/mods/ControllerHudKeyboardFix/ControllerHudKeyboardFix",
			mod_data         = "scripts/mods/ControllerHudKeyboardFix/ControllerHudKeyboardFix_data",
			mod_localization = "scripts/mods/ControllerHudKeyboardFix/ControllerHudKeyboardFix_localization",
		})
	end,
	packages = {
		"resource_packages/ControllerHudKeyboardFix/ControllerHudKeyboardFix",
	},
}
