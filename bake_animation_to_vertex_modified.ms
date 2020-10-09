/* rollout bakeAniRollout "Bake Animation" width:162 height:76
(
	button btn_xform "PRS to Xform" width:147 height:30
	button btn_bake "Bake" width:147 height:30
	
	on btn_xform pressed do
	(
		for o in selection do 
		(
		tempmodifier = (XForm ())
		tempmodifier.name = "PRS Baker"
		suspendEditing()
		disableSceneRedraw() 	
			
		addModifier o tempmodifier
		o.modifiers["PRS Baker"].gizmo.controller = copy o.transform.controller
		deleteKeys o.transform.controller
		o.transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])
		o.modifiers["PRS Baker"].enabled = false
		o.modifiers["PRS Baker"].enabled = true

		resumeEditing()
		enableSceneRedraw() 
		)
	)
	

	on btn_bake pressed do 
	(
		for o in selection do 
		(
			setCommandPanelTaskMode #create
			suspendEditing()
			snaptarget = o
			-- naming changed : fron "_meshcached_" to "_baked"
			-- tempname = uniqueName (snaptarget.name + "_meshcached_")
			
			tempname = uniqueName (snaptarget.name + "_baked")
			forcesnapshot = snapshot o name:tempname
			convertTo forcesnapshot Editable_Mesh
			forcesnapshot.controller = snaptarget.controller
			resumeEditing()
			animateVertex forcesnapshot #all
			bakeRange = (animationRange.end - animationRange.start).frame as integer
			sourceObj = snaptarget
			targetObj = forcesnapshot

			masterCtrl = targetObj[4][1]

			for t = 0 to bakeRange do 
			(
				sliderTime = t
				for i in 1 to targetObj.numVerts do 
				(
				k = addNewKey masterCtrl[i].controller t
				k.value = at time t in coordSys sourceObj getVert sourceObj i
				)
				
			)

			InstanceMgr.MakeControllersUnique targetObj targetObj.controller #prompt 
			
		)	
		
	)
	
	
)
*/

/* function for Bake */
 -- put generated mesh into same layer
fn Bake = (
	
		for o in selection do 
		(
			-- selected Mesh is usually a Editable Poly. add modifier edit poly first
			addmodifier o (Edit_Mesh())
			
			setCommandPanelTaskMode #create
			suspendEditing()
			snaptarget = o
			-- naming changed : from "_meshcached_" to "_baked"
			-- tempname = uniqueName (snaptarget.name + "_meshcached_")
			
			tempname = uniqueName (snaptarget.name + "_baked")
			forcesnapshot = snapshot o name:tempname
			convertTo forcesnapshot Editable_Mesh
			forcesnapshot.controller = snaptarget.controller
			resumeEditing()
			animateVertex forcesnapshot #all
			bakeRange = (animationRange.end - animationRange.start).frame as integer
			sourceObj = snaptarget
			targetObj = forcesnapshot

			masterCtrl = targetObj[4][1]
			
				-- copied mesh will be added into same layer
				theLayer = LayerManager.getLayerFromName o.layer.name
				print theLayer.name
				theLayer.addnode targetObj

			for t = 0 to bakeRange do 
			(
				sliderTime = t
				for i in 1 to targetObj.numVerts do 
				(
				k = addNewKey masterCtrl[i].controller t
				k.value = at time t in coordSys sourceObj getVert sourceObj i
				)
				
			)
			
			InstanceMgr.MakeControllersUnique targetObj targetObj.controller #prompt 
			-- after baking, select baked mesh
			select forcesnapshot
		)

			
	
	)


	/* function for PRS XForm */
	fn PRStoXForm = (
		
		for o in selection do 
		(
		tempmodifier = (XForm ())
		tempmodifier.name = "PRS Baker"
		suspendEditing()
		disableSceneRedraw() 	
			
		addModifier o tempmodifier
		o.modifiers["PRS Baker"].gizmo.controller = copy o.transform.controller
		deleteKeys o.transform.controller
		o.transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])
		o.modifiers["PRS Baker"].enabled = false
		o.modifiers["PRS Baker"].enabled = true

		resumeEditing()
		enableSceneRedraw() 
		)
		
	)
	
-- CreateDialog bakeAniRollout 

