

MM_CHARACTER_TYPE_MAIN = 100
MM_CHARACTER_TYPE_MULE = 101

MM_ITEMS_FILTER_ALL    = 200
MM_ITEMS_FILTER_CRAFT  = 201
MM_ITEMS_FILTER_OTHERS = 202


langage = {
	
	["English"] = {
		--Option Translation
		title							= "Mules Management",
		reloadWarning					= "The UI will reload",
		dropDownLangageText				= "Langage",
		dropDownLangageTooltip			= "Select your langage",
		dropDownCharacterTypeText		= "Character Type",
		dropDownCharacterTypeTooltip	= "Select the role of your character",
		dropDownItemsFilterText			= "Items Filter",
		dropDownItemsFilterTooltip		= "Select the categories of items",
		craftCheckBoxTooltipMain		= "Send to Bank",
		craftCheckBoxTooltipMule		= "Send to Inventory",
		itemsMoved						= "item(s) moved",

		--Types of charaters
		[MM_CHARACTER_TYPE_MAIN]		= "Main",
		[MM_CHARACTER_TYPE_MULE]		= "My Mule",
		
		--Types of filters
		[MM_ITEMS_FILTER_ALL]  			= "All Items",
		[MM_ITEMS_FILTER_CRAFT]			= "Craft Items",
		[MM_ITEMS_FILTER_OTHERS]		= "Others Items",

		--Types of filter : craft
		[CRAFTING_TYPE_BLACKSMITHING]	= "Blacksmithing",
		[CRAFTING_TYPE_CLOTHIER]		= "Clothier",
		[CRAFTING_TYPE_ENCHANTING]		= "Enchanting",
		[CRAFTING_TYPE_ALCHEMY]			= "Alchemy",
		[CRAFTING_TYPE_PROVISIONING]	= "Provisioning",
		[CRAFTING_TYPE_WOODWORKING]		= "Woodworking"
	},
	["Francais"] = {
		--Traduction dans les options
		title							= "Management de Mules",
		reloadWarning					= "L'affichage va recharger",
		dropDownLangageText				= "Langue",
		dropDownLangageTooltip			= "Selectionnez votre langue",
		dropDownCharacterTypeText		= "Type de Personnage",
		dropDownCharacterTypeTooltip	= "Selectionnez le rôle de votre Personnage",
		dropDownItemsFilterText			= "Filtre sur les objets",
		dropDownItemsFilterTooltip		= "Selectionnez la catégorie d'objets à filter",
		craftCheckBoxTooltipMain		= "Envoyer à la banque",
		craftCheckBoxTooltipMule		= "Envoyer dans l'inventaire",
		itemsMoved						= "objet(s) deplacé(s)",

		--Types de personnages
		[MM_CHARACTER_TYPE_MAIN]		= "Main - Principal",
		[MM_CHARACTER_TYPE_MULE]		= "Ma Mule",
		[MM_ITEMS_FILTER_OTHERS]		= "Divers",

		--Types de filtres
		[MM_ITEMS_FILTER_ALL]  			= "Tous les objets",
		[MM_ITEMS_FILTER_CRAFT]			= "Objets de Craft",

		--Types de filtres : craft
		[CRAFTING_TYPE_BLACKSMITHING]	= "Forge",
		[CRAFTING_TYPE_CLOTHIER]		= "Couture",
		[CRAFTING_TYPE_ENCHANTING]		= "Enchantement",
		[CRAFTING_TYPE_ALCHEMY]			= "Alchimie",
		[CRAFTING_TYPE_PROVISIONING]	= "Cuisine",
		[CRAFTING_TYPE_WOODWORKING]		= "Travail du bois"
	}
}