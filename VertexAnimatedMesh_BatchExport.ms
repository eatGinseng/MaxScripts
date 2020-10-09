
/*****************************************************

	Written by Yujin Han
	Bake animations into vertices in given animation range
	Export 2 textures and 1 static meshes from each selected mesh with max file name on it. folders are optional

*****************************************************/

filein "VertexAnimationTools_modified.ms"
filein "bake_animation_to_vertex_modified.ms"

	-- default saveDir is export directory.
	saveDir = getDir #export
	
	-- Empty Array for collecting selected objects
	selectedObjArr = #()
	
	-- Meshes' original name
	global Meshname = " "

rollout initial_rollout "VAT Batch Exporter" (
	

	
	group "Basics" (
	spinner StartFrame_Spinner "Animation Start " type:#integer range:[0,1000000,animationRange.start]
	spinner EndFrame_Spinner "Anim End" type:#integer range:[0,1000000,animationRange.end] 	
	spinner FrameSkip_Spinner "Frame Skip" type:#integer range:[0,1000000,0] 
	dropdownlist TextureCoordinate_dropdown "Texture Coordinate:" items:#("2","3","4","5","6","7","8") tooltip:"By default, the Unreal material functions expect the morph target uvs to exist in uv 2 (UV 1 in the Unreal Editor)."

	-- save directory
	edittext SaveDirectory_text "DIrectory : " text:(getDir #export)
	button Browse_btn "Browse.." across:2
		
	button processAnimatedMeshes_Btn "Process Animated Meshes"
	
	checkbox collectinfolder_checkbox "Collect in folder" 
	
	)
	
	/* UI Functions */ 
	function processAnimatedMeshes = (
		
		setAnimationValues StartFrame_spinner.value EndFrame_spinner.value FrameSkip_Spinner.value (TextureCoordinate_dropdown.selection + 1)
		TexMorphRollout.processSelfAnimatedMeshesPressed()
		
	)
	
	function browse = (
		
		
		SaveDir = getSavePath caption:"Select Folder" initialDir:"c:\""
		if SaveDir == undefined then ( messagebox ("Enter Save DIrectory !!") )
		else (

				SaveDirectory_text.text = SaveDir				
		)
		
	)
	
		global trimmedMaxFileName = (trimright MaxFileName ".max") + "_"
	
	-- export selected object to fbx file
	function exportCurrentObj = (
		
		if collectinfolder_checkbox.enabled == true then (
			
			makedir (saveDir + "\\" + "Meshes\\")
			exportFile_name = saveDIr + "\\" + "Meshes\\" + "SM_" + trimmedMaxFileName + MeshName + ".fbx" 
			
			) else (
			
			-- Exported meshes' name should be stored before processing them
			-- exportFile_name = saveDIr + "\\" + "SM_" + trimmedMaxFileName + selection[1].name + ".fbx"
			exportFile_name = saveDIr + "\\" + "SM_" + trimmedMaxFileName + selection[1].name + ".fbx"
						
			)
		
		print exportFile_name
		exportFile exportFile_name #noPrompt selectedOnly:true
		
		)
	
	-- Browse button pressed : fill textbox with selected path
	on Browse_btn pressed do -- when button Pressed
	(
		browse()
	)
	
	on processAnimatedMeshes_btn pressed do (
		
		SaveDir = SaveDirectory_text.text
		
		-- populate array with selection
		for i = 1 to selection.count do selectedObjArr[i] = selection[i]		
		-- should repeat these for each selected objects..		
		for i = 1 to selectedObjArr.count do (

			 MeshName = selectedObjArr[i].name

			
			-- set if meshes and textures should collect in folder or not
			if collectinfolder_checkbox.enabled == true then (
				
				
				-- make a folder to this directory if it doesn't exist		
				makedir (saveDir + "\\" + "Textures")
				setTextureName (SaveDIr + "\\" + "Textures") (trimmedMaxFileName + MeshName) 				
			
				) else (
				
				setTextureName SaveDIr (trimmedMaxFileName + MeshName) 
				
			)
			
			select selectedObjArr[i]
			
			-- bake this meshs' animation to vertex
			PRStoXForm()
			-- bake function will generate copied mesh with vertex animation and will be finished with selecting that mesh.
			bake()
			
			-- this function will finished with new vertex animation cached mesh remain selected. 		
			processAnimatedMeshes()	
			-- selected object will be exported.
			exportCurrentObj()
		
		)
		
		-- restore initial selection
		select selectedObjArr			
		-- empty array
		free selectedObjArr
		
	)
	
	
)

createDialog initial_rollout 350 250