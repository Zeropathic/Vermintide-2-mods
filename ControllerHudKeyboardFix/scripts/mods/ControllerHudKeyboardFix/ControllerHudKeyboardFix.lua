--[[
	
	____________________________________________________________
	CONTROLLER HUD WITH MOUSE & KEYBOARD - CONSUMABLES ORDER FIX
	¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
	 v. 0.1 beta
	
	
	Author: Zeropathic
	
	
	
	By default, if you use the controller HUD with mouse & keyboard, the position of equipped potions and grenades are swapped.
	
	The default layout for mouse & keyboard looks like this:
	
	 _1___2___3___4___5_
	| M | R | H | P | G |
	 ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
	
	But if you use the controller HUD with mouse & keyboard, the consumables layout looks like this:
	
	 _3___5___4_
	| H | G | P |
	 ¯¯¯¯¯¯¯¯¯¯¯
	
	As you can see, grenades and potions are ordered incorrectly. This mod puts things back into their proper order.
	


	* M = melee
	  R = ranged
	  H = healing
	  P = potion
	  G = grenade

]]--


local mod = get_mod("ControllerHudKeyboardFix")




-- These variables are used in "gamepad_equipment_ui_definitions.lua" to determine the placement of the consumable UI elements, as far as I can tell.
-- Swapping the values around has the desired effect of making grenades appear in the rightmost slot and potions appear in the middle slot.

InventorySettings.slots[10].console_hud_index = 3	-- Default value: 4
InventorySettings.slots[11].console_hud_index = 4	-- Default value: 3

--[[
-- Not sure if this is of any use to me.
InventorySettings.slots_by_console_hud_index = {}

for index, slot in ipairs(InventorySettings.slots) do
	if slot.console_hud_index then
		InventorySettings.slots_by_console_hud_index[slot.console_hud_index] = slot
	end
end
]]--

-- However, it seems hotkey display placements aren't affected by the changes above, so a separate hacky solution has been applied to "GamePadEquipmentUI._get_input_texture_data" below.


--
mod:hook_origin(GamePadEquipmentUI, "_get_input_texture_data", function (self, input_action)
	local input_manager = self.input_manager
	local input_service = input_manager:get_service("Player")
	local gamepad_active = input_manager:is_device_active("gamepad")
	local platform = PLATFORM

	if platform == "win32" and gamepad_active then
		platform = "xb1"
	elseif platform == "xb1" and not gamepad_active then
		platform = "win32"
	end

	local keymap_binding = input_service:get_keymapping(input_action, platform)

	if not keymap_binding then
		Application.warning(string.format("[GamePadEquipmentUI] There is no keymap for %q on %q", input_action, platform))

		return nil, ""
	end

	local device_type = keymap_binding[1]
	local key_index = keymap_binding[2]
	local key_action_type = keymap_binding[3]
	local prefix_text = nil
	
	if key_action_type == "held" then
		prefix_text = "matchmaking_prefix_hold"
	end

	local is_button_unassigned = key_index == UNASSIGNED_KEY
	local button_name = ""

	if device_type == "keyboard" then
		button_name = (is_button_unassigned and "") or Keyboard.button_locale_name(key_index) or Keyboard.button_name(key_index)
		
		-- Hacky solution - swap button_name around if grenade or potion binding
		-- I couldn't figure out exactly how the code worked or why changing the InventorySettings variables didn't also correct the hotkey display, so this is what I came up with.
		if input_action == "wield_4" then
			keymap_binding = input_service:get_keymapping("wield_5", platform)
			key_index = keymap_binding[2]
			button_name = (is_button_unassigned and "") or Keyboard.button_locale_name(key_index) or Keyboard.button_name(key_index)
		elseif input_action == "wield_5" then
			keymap_binding = input_service:get_keymapping("wield_4", platform)
			key_index = keymap_binding[2]
			button_name = (is_button_unassigned and "") or Keyboard.button_locale_name(key_index) or Keyboard.button_name(key_index)
		end
		
		if PLATFORM == "xb1" then
			button_name = string.upper(button_name)
		end
		
		return nil, button_name, prefix_text
	elseif device_type == "mouse" then
		if is_button_unassigned then
			button_name = ""
		else
			button_name = Mouse.button_name(key_index)
			
		end

		return nil, button_name, prefix_text
	elseif device_type == "gamepad" then
		if is_button_unassigned then
			button_name = ""
		else
			button_name = Pad1.button_name(key_index)
		end

		local button_texture_data = ButtonTextureByName(button_name, platform)

		return button_texture_data, button_name, prefix_text
	end

	return nil, ""
end)
--

