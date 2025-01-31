/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




state PlayerDialogScene in CPlayer extends Base
{
	private var cachedPrevStateName : name;
	
	event OnEnterState( prevStateName : name )
	{
		var player : W3PlayerWitcher;
		var sign : W3SignEntity;
		var horse : CNewNPC;
		var scabbardsComp : CAnimatedComponent;				
		
		//FPS MOD - START
		// var listener	: FPHookListener;
		// var ent : CEntity;	
		
		var fpsCam : FirstPersonCamera;			
		var ent : CEntity;
		var template : CEntityTemplate;
		var attachvector : Vector;
		var attachangle : EulerAngles;	
		var l_comp : CComponent;	
		var initialrotation : EulerAngles;
		var mod_FpsEnabled, enable_in_DialogOrCutscene : bool;
		//FPS MOD - END
		
		//FPS MOD - START
		mod_FpsEnabled = FP_IsEnabled();
		enable_in_DialogOrCutscene = FP_IsEnabled_DialogOrCutscene();
		if(mod_FpsEnabled && enable_in_DialogOrCutscene){
			
			template = (CEntityTemplate)LoadResource("dlc\fpcamfix\data\gameplay\camera\firstperson.w2ent", true);
			ent = theGame.CreateEntity(template, thePlayer.GetBoneWorldPosition('Root'), thePlayer.GetWorldRotation());	
			fpsCam=(FirstPersonCamera)ent;		
		
			fpsCam.setforced(true);	
			fpsCam.AddTimer( 'NoRetreat', 0, true );
		
			attachvector = thePlayer.GetBoneWorldPosition('Root');
			attachvector.Z = attachvector.Z + 1.85;
			attachangle = thePlayer.GetWorldRotation();
			attachangle.Pitch = 0;	
			attachangle.Roll = 0;	
		
			ent.CreateAttachmentAtBoneWS( thePlayer, 'Root', attachvector, attachangle );
			ent.AddTag('FPSCAMERA');	
			initialrotation.Pitch = initialrotation.Pitch * -1;
			initialrotation.Yaw = 0;	
			initialrotation.Roll = initialrotation.Roll * -1;
		
			l_comp = ent.GetComponentByClassName('CCameraComponent');
			((CComponent)l_comp).SetPosition(Vector(0,0.05,0,1));	
			((CComponent)l_comp).SetRotation(initialrotation);	
		}		
		else{
		    myMods().VisibilityControl().ShowAll();
		}
		//FPS MOD - END
			
		
		player = (W3PlayerWitcher)parent;
		
		//theInput.SetContext( 'Scene' );
		
		//parent.EnableHardLock( false );
		
		//thePlayer.OnPlayerActionEnd();
		
		// if(player)
		// {
			// sign = (W3SignEntity)player.GetCurrentSignEntity();
			// if (sign)
			// {
				// sign.OnSignAborted();
			// }
			
			// player.BombThrowAbort();			
		// }
		//scabbardsComp = (CAnimatedComponent)( thePlayer.GetComponent( "scabbards_skeleton" ) );
		//if ( scabbardsComp )
		//	scabbardsComp.SetBehaviorVariable( 'inScene', 1.f );

		
		
		//player.GetMovingAgentComponent().ResetMoveRequests();
		
		//theTelemetry.LogWithName(TE_STATE_DIALOG);
		
		//parent.SetBehaviorMimicVariable( 'gameplayMimicsMode', (float)(int)PGMM_None );
		
		cachedPrevStateName = prevStateName;
		
		//FPS MOD - START
		// ent = theGame.GetEntityByTag( 'FPSCAMERA' );
		// if(!ent)
		// {
			// listener = new FPHookListener in thePlayer.GetInputHandler();			
			// listener.StartListener();
			// ent = theGame.GetEntityByTag( 'FPSCAMERA' );
			// fpsCam=(FirstPersonCamera)ent;
			// fpsCam.setforced(true);	
			// fpsCam.AddTimer( 'NoRetreat', 0, true );
		// }		
		// fpsCam=(FirstPersonCamera)ent;
		// fpsCam.listenerhook.OnHookToggle();
		//FPS MOD - END
		
		
	}
	
	event OnLeaveState( nextStateName : name )
	{
		var scabbardsComp : CAnimatedComponent;
		
	
		scabbardsComp = (CAnimatedComponent)( thePlayer.GetComponent( "scabbards_skeleton" ) );
		if ( scabbardsComp )
			scabbardsComp.SetBehaviorVariable( 'inScene', 0.f );
		
		parent.rawPlayerHeading = parent.GetHeading();
		
		parent.SetBehaviorMimicVariable( 'gameplayMimicsMode', (float)(int)PGMM_Default );
		
		
	}
	
	
	event OnBlockingSceneEnded( optional output : CStorySceneOutput)
	{
		var ciri : W3ReplacerCiri;
			//FPS MOD - START
		var ent : CEntity;	
		var fpsCam : FirstPersonCamera;	
		//FPS MOD - END

			
		parent.OnBlockingSceneEnded( output );
		parent.RegisterCollisionEventsListener();
		if ( output )
		{
			if ( output.action == SSOA_ReturnToPreviousState )
			{
				if ( cachedPrevStateName == 'CombatSteel' || cachedPrevStateName == 'CombatSilver' )
					parent.PopState( false );
			}
			else if ( output.action == SSOA_MountVehicle )
			{
				parent.FindAndMountVehicle( VMT_ApproachAndMount, 100.0f );	
				return true;
			}
			else if ( output.action == SSOA_MountVehicleFast )
			{
				parent.FindAndMountVehicle( VMT_ImmediateUse, 100.0f );	
				return true;
			}
			else if ( output.action == SSOA_EnterCombatSilver )
			{
				ciri = (W3ReplacerCiri)thePlayer;
				if ( ciri )
				{
					parent.GotoState( 'CombatSteel', false );
					return true;
				}
				else if ( GetWitcherPlayer().IsItemEquippedByCategoryName( 'silversword' ) )
				{
					parent.GotoState( 'CombatSilver', false );
					return true;
				}
				
			} 
			else if ( output.action == SSOA_EnterCombatSteel )
			{
				if ( GetWitcherPlayer().IsItemEquippedByCategoryName( 'steelsword' ) )
				{
					parent.GotoState( 'CombatSteel', false );
					return true;
				}
			}
			else if ( output.action == SSOA_EnterCombatFists )
			{
				parent.GotoState( 'CombatFists', false );
				return true;
			}
			
		}
		parent.PopState( true );
		
		//FPS MOD - START
		ent = theGame.GetEntityByTag( 'FPSCAMERA' );
		if(ent)
		{
			fpsCam=(FirstPersonCamera)ent;		
			fpsCam.setforced(false);	
			fpsCam.RemoveTimer( 'NoRetreat' );
			fpsCam.ExitFP();
		}		
		//FPS MOD - END
	}
}
