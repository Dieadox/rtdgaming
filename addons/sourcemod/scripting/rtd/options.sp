#pragma semicolon 1

#include <sourcemod>
#include <tf2_stocks>
#include <rtd_rollinfo>



public Action:ShowRTDOptions(client, startAtPage)
{
	new Handle:hMenu = CreateMenuEx(GetMenuStyleHandle(MenuStyle_Radio), fn_OptionMenuHandler);
	
	SetMenuTitle(hMenu,"RTD Options");
	
	if(RTDOptions[client][0] == 0)
	{
		AddMenuItem(hMenu,"Option 0","Use +USE over +ATTACK2");
	}else{
		AddMenuItem(hMenu,"Option 0","Use +ATTACK2 over +USE, [REVERTS TO DEFAULT]");
	}
	
	if(RTDOptions[client][2] == 0)
	{
		AddMenuItem(hMenu,"Option 1","DISABLE RTD messages in chat");
	}else{
		AddMenuItem(hMenu,"Option 1","ENABLE RTD messages in chat [REVERTS TO DEFAULT]");
	}
	
	AddMenuItem(hMenu,"Option 2","Set Character Size", ITEMDRAW_DISABLED);
	
	if(RTDOptions[client][4] == 0)
	{
		AddMenuItem(hMenu,"Option 3","ENABLE, Ragdoll dissolves");
	}else{
		AddMenuItem(hMenu,"Option 3","DISABLE, Ragdoll dissolve [REVERTS TO DEFAULT]");
	}
	
	
	AddMenuItem(hMenu,"Option 4","Set Character Voice Pitch");
	
	if(ScoreEnabled[client] == 0)
	{
		AddMenuItem(hMenu,"Option 5","ENABLE Score HUD");
	}else{
		AddMenuItem(hMenu,"Option 5","DISABLE Score HUD [REVERTS TO DEFAULT]");
	}
	
	DisplayMenuAtItem(hMenu, client, startAtPage, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public fn_OptionMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
    switch (action) 
	{
		case MenuAction_Select: 
		{
			new String:name[32];
			GetClientName(param1, name, sizeof(name));
			
			switch (param2) 
			{
				case 0: {
					if(RTDOptions[param1][0] == 0)
					{
						RTDOptions[param1][0] = 1;
						SetHudTextParams(0.41, 0.82, 5.0, 250, 250, 210, 255);
						ShowHudText(param1, HudMsg3, "Remember to bind +USE!");
						
					}else{
						SetHudTextParams(0.41, 0.82, 5.0, 250, 250, 210, 255);
						ShowHudText(param1, HudMsg3, "Reverted to Default!");
						RTDOptions[param1][0] = 0;
					}
				}
				
				case 1: {
					if(RTDOptions[param1][2] == 0)
					{
						RTDOptions[param1][2] = 1;
						SetHudTextParams(0.38, 0.82, 5.0, 250, 250, 210, 255);
						ShowHudText(param1, HudMsg3, "RTD Messages in chat are DISABLED");
					}else{
						SetHudTextParams(0.38, 0.82, 5.0, 250, 250, 210, 255);
						ShowHudText(param1, HudMsg3, "RTD Messages in chat are ENABLED");
						RTDOptions[param1][2] = 0;
					}
				}
				
				case 2: {
					ShowWaistMenu(param1);
				}
				
				case 3: 
				{
					if(RTDOptions[param1][4] == 1)
					{
						RTDOptions[param1][4] = 0;
						SetHudTextParams(0.38, 0.82, 5.0, 250, 250, 210, 255);
						ShowHudText(param1, HudMsg3, "Enemy ragdolls dissolve: DISABLED");
						PrintToChat(param1, "Enemy ragdolls dissolve: DISABLED");
						
					}else{
						SetHudTextParams(0.38, 0.82, 5.0, 250, 250, 210, 255);
						ShowHudText(param1, HudMsg3, "Enemy ragdolls dissolve: ENABLED");
						RTDOptions[param1][4] = 1;
						PrintToChat(param1, "Enemy ragdolls dissolve: ENABLED");
					}
				}
				
				case 4: 
				{
					ShowVoiceOptions(param1);
				}
				
				case 5: 
				{
					if(ScoreEnabled[param1] == 0)
					{
						ScoreEnabled[param1]= 1;
						
					}else{
						ScoreEnabled[param1] = 0;
					}
				}
			}
			
			if(param2 != 4 && param2 != 2)
				ShowRTDOptions(param1, 0);
		}
		
		
		case MenuAction_Cancel: {
		}

		case MenuAction_End: {
			CloseHandle(menu);
		}
	}
}

public Action:ShowWaistMenu(client)
{
	new Handle:hMenu = CreateMenuEx(GetMenuStyleHandle(MenuStyle_Radio), fn_WaistMenuHandler);
	
	SetMenuTitle(hMenu,"Select your model size!");
	
	
	if(RTDOptions[client][3] == 0)
	{
		AddMenuItem(hMenu,"Option 1","Normal [Current Setting]" ); //10
	}else{
		AddMenuItem(hMenu,"Option 1","Normal" ); //10
	}
	
	if(RTDOptions[client][3] == 1)
	{
		AddMenuItem(hMenu,"Option 1","Small [Current Setting]"); //7
	}else{
		AddMenuItem(hMenu,"Option 1","Small"); //7
	}
	
	if(RTDOptions[client][3] == 2)
	{
		AddMenuItem(hMenu,"Option 1","Smaller [Current Setting]"); //5
	}else{
		AddMenuItem(hMenu,"Option 1","Smaller"); //5
	}
	
	if(RTDOptions[client][3] == 3)
	{
		AddMenuItem(hMenu,"Option 1","Big [Current Setting]"); //5
	}else{
		AddMenuItem(hMenu,"Option 1","Big"); //5
	}
	
	if(RTDOptions[client][3] == 4)
	{
		AddMenuItem(hMenu,"Option 1","Bigger [Current Setting]"); //2
	}else{
		AddMenuItem(hMenu,"Option 1","Bigger"); //2
	}
	
	
	DisplayMenu(hMenu,client,MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public fn_WaistMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
    switch (action) 
	{
		case MenuAction_Select: 
		{
			
			switch (param2) 
			{
				case 0: 
				{
					RTDOptions[param1][3] = 0;
				}
				
				case 1: 
				{
					RTDOptions[param1][3] = 1;
				}
				
				case 2: 
				{
					RTDOptions[param1][3] = 2;
				}
				
				case 3: 
				{
					RTDOptions[param1][3] = 3;
				}
				
				case 4: 
				{
					RTDOptions[param1][3] = 4;
				}
				
			}
			
			UpdateWaist(param1);
		}
		
		case MenuAction_Cancel: {
		}
		
		case MenuAction_End: {
			CloseHandle(menu);
		}
	}
}

public Action:UpdateWaist(client)
{
	if(client_rolls[client][AWARD_G_TINYBABYMAN][0] || client_rolls[client][AWARD_G_LUMBERINGGIANT][0])
	{
		ScaleClient(client);
		return Plugin_Handled;
	}
	
	/*
	decl Float:Scalee;
	
	
	if(RTDOptions[client][3] == 0 || RTDOptions[client][3] < 1.0)
	{
		Scalee = 1.0;
		
	}else{
		switch(RTDOptions[client][3])
		{
			case 0:
				Scalee = 1.0;
				
			case 1:
				Scalee = 0.9;
			
			case 2:
				Scalee = 0.8;
			
			case 3:
				Scalee = 1.1;
				
			case 4:
				Scalee = 1.2;
		}
		
	}
	
	//make sure player is here
	if(!IsClientInGame(client) || !IsPlayerAlive(client) || IsFakeClient(client))
		return Plugin_Handled;
	
	//disabled due to MVM
	SetEntPropFloat(client, Prop_Send, "m_flModelScale", Scalee);
	* */
	
	return Plugin_Handled;
}

public Action:ShowVoiceOptions(client)
{
	new Handle:hMenu = CreateMenuEx(GetMenuStyleHandle(MenuStyle_Radio), fn_VoiceMenuHandler);
	
	SetMenuTitle(hMenu,"RTD Options");
	
	if(VoiceOptions[client] == 0)
	{
		AddMenuItem(hMenu,"Option 1","Normal [Current Setting]");
	}else{
		AddMenuItem(hMenu,"Option 1","Normal [Revert back to Default]");
	}
	
	if(VoiceOptions[client] == 1)
	{
		AddMenuItem(hMenu,"Option 1","Low Pitch [Current Setting]");
	}else{
		AddMenuItem(hMenu,"Option 1","Low Pitch");
	}
	
	if(VoiceOptions[client] == 2)
	{
		AddMenuItem(hMenu,"Option 1","High Pitch [Current Setting]");
	}else{
		AddMenuItem(hMenu,"Option 1","High Pitch");
	}
	
	DisplayMenu(hMenu,client,MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public fn_VoiceMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
    switch (action) 
	{
		case MenuAction_Select: 
		{
			
			switch (param2) 
			{
				case 0: 
				{
					VoiceOptions[param1] = 0;
					
					SetHudTextParams(0.41, 0.82, 5.0, 250, 250, 210, 255);
					ShowHudText(param1, HudMsg3, "Reverted to Default!");
				}
				
				case 1: 
				{
					VoiceOptions[param1] = 1;
					
					SetHudTextParams(0.41, 0.82, 5.0, 250, 250, 210, 255);
					ShowHudText(param1, HudMsg3, "Low Pitch: ENABLED!");
				}
				
				case 2: 
				{
					VoiceOptions[param1] = 2;
					
					SetHudTextParams(0.41, 0.82, 5.0, 250, 250, 210, 255);
					ShowHudText(param1, HudMsg3, "High Pitch: ENABLED");
				}
				
			}
		}
		
		case MenuAction_Cancel: {
		}
		
		case MenuAction_End: {
			CloseHandle(menu);
		}
	}
}