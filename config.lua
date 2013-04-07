if string.sub(system.getInfo("model"),1,4) == "iPad" then
	application = 
	{
		content =
		{
			width = 384,
			height = 512,
			scale = "letterBox",
			fps = 60,
			xAlign = "center",
			yAlign = "center",
			imageSuffix = 
			{
				["@2x"] = 1.5,
				["@4x"] = 3.0,
			},
			antialias = true,
		},
		notification = 
		{
			iphone = {
				types = {
					"badge", "sound", "alert"
				}
			}
		}
	}

elseif string.sub(system.getInfo("model"),1,2) == "iP" and display.pixelHeight > 960 then
	application = 
	{
		content =
		{
			width = 320,
			height = 568,
			scale = "letterBox",
			fps = 60,
			xAlign = "center",
			yAlign = "center",
			imageSuffix = 
			{
				["@2x"] = 1.5,
				["@4x"] = 3.0,
			},
			antialias = true,
		},
		notification = 
		{
			iphone = {
				types = {
					"badge", "sound", "alert"
				}
			}
		}
	}

elseif string.sub(system.getInfo("model"),1,2) == "iP" then
	application = 
	{
		content =
		{
			width = 320,
			height = 480,
			scale = "letterBox",
			fps = 60,
			xAlign = "center",
			yAlign = "center",
			imageSuffix = 
			{
				["@2x"] = 1.5,
				["@4x"] = 3.0,
			},
			antialias = true,
		},
		notification = 
		{
			iphone = {
				types = {
					"badge", "sound", "alert"
				}
			}
		}
	}
elseif display.pixelHeight / display.pixelWidth > 1.72 then
	application = 
	{
		content =
		{
			width = 320,
			height = 570,
			scale = "letterBox",
			fps = 60,
			xAlign = "center",
			yAlign = "center",
			imageSuffix = 
			{
				["@2x"] = 1.5,
				["@4x"] = 3.0,
			},
			antialias = true,
		},
	}
else
	application = 
	{
		content =
		{
			width = 320,
			height = 512,
			scale = "letterBox",
			fps = 60,
			xAlign = "center",
			yAlign = "center",
			imageSuffix = 
			{
				["@2x"] = 1.5,
				["@4x"] = 3.0,
			},
			antialias = true,
		},
		notification = 
		{
			iphone = {
				types = {
					"badge", "sound", "alert"
				}
			}
		}
	}
end
