return {
	byType = {
		waitingMusic = {
			"RelaxedScene",
			"ClairDeLune",
			"GymnopedieNo1",
			"ChillJazz",
			"MorningMood",
			"LoFiChillA",
			"TownTalk",
			"NocturneOpus9C",
			"AllDropping8Beats",
			"YoungAndTender",
			"TenderChillstep",
			"Diamonds",
			"PlaygroundOfTheStars",
			"TheFourSeasons",
			"ConvenienceStore",
			"CartoonCapers",
			"BoredToBits",
			"ColouredCandles",
		},
		votingMusic = {
			"JazzyChild",
			"ThisIsAMessage",
			"CatIsland",
			"ChineseJazz",
			"JazzyScratch",
			"HardBop",
			"BonbonTwistos",
			"PlayOnTen",
			"Swagger",
			"Skipping",
			"JollyBanjo",
			"InnerCityGoat",
			"HotTrap",
			"BouncerLink1",
			"WorldsAwayStinger",
			"EnterTheChallenger",
			"DiamondsAndBands",
			"Spicy",
			"Spicy2",
			"LockAndLoad",
			"DucksReggae",
		},
		gameplayMusic = {
			"BossaMe",
			"RetroGamer",
			"FinalBossA",
			"DuckSoup",
			"ArtificialSunlight",
			"Autocue",
			"GameplayMusic1",
			"GameplayMusic2",
			"GameplayMusic3",
			"GameplayMusic4",
			"GameplayMusic5",
			"GameplayMusic6",
			"GameplayMusic7",
			"GameplayMusic8",
			"GameplayMusic9",
			"GameplayMusic10",
			"GameplayMusic11",
			"GameplayMusic12",
			"GameplayMusic13",
			"GameplayMusic14",
			"GameplayMusic15",
			"GameplayMusic16",
			"GameplayMusic17",
			"GameplayMusic18",
			"GameplayMusic19",
			"GameplayMusic20",
			"GameplayMusic21",
			"GameplayMusic22",
			"GameplayMusic23",
			"GameplayMusic24",
			"GameplayMusic25",
			"GameplayMusic26",
			"GameplayMusic27",
		},
		intermissionMusic = {
			"LobbySoiree",
			"AwkwardEncounter",
			"HangingFern",
			"PresidentialSuite",
			"TopFloor",
			"Vitruvius",
			"AutocueB",
			"YoureTheBest15",
			"FlightOfFancy",
			"AOk",
			"MoFunky",
			"DoItToIt",
			"DoItToIt2",
			"PassThePepper",
			"GuitarGambler",
			"ClassyFella",
			"GetTheFunkOut",
			"ChickenStrut",
		},
		orchestralFlourishMusic = {
			"OrchestralFlourish1",
			"OrchestralFlourish2",
			"OrchestralFlourish3",
			"OrchestralFlourish4",
			"OrchestralFlourish5",
		},
	},
	byKey = {
		-- Interface sounds
		MouseEnter = {
			SoundId = 101795256683715,
			PlaybackSpeed = math.random(90, 110) / 100,
			Volume = 0.85,
			tag = "SoundEffect",
			preloadLocal = true,
		},
		MouseButton1Down = {
			SoundId = 9118134279,
			PlaybackSpeed = math.random(90, 110) / 100,
			Volume = 0.85,
			tag = "SoundEffect",
			preloadLocal = true,
		},
		MouseButton1Click = {
			SoundId = 9117841338,
			PlaybackSpeed = math.random(100, 120) / 100,
			Volume = 0.85,
			tag = "SoundEffect",
			preloadLocal = true,
		},
		Notification1 = {
			SoundId = 122397610725397,
			Volume = 1,
			tag = "SoundEffect",
			preloadLocal = true,
		},
		Notification2 = {
			SoundId = 122397610725397,
			Volume = 1,
			tag = "SoundEffect",
			preloadLocal = true,
		},
		Notification3 = {
			SoundId = 127573162596493,
			Volume = 1,
			tag = "SoundEffect",
			preloadLocal = true,
		},
		Error1 = {
			SoundId = 121019731933715,
			Volume = 1,
			tag = "SoundEffect",
			preloadLocal = true,
		},
		Success1 = {
			SoundId = 129102565405754,
			Volume = 1,
			tag = "SoundEffect",
			preloadLocal = true,
		},
		PurchaseSuccessful = {
			SoundId = 107834496997614,
			Volume = 1,
			tag = "SoundEffect",
			preloadLocal = true,
		},
		LevelUp = {
			SoundId = 130032686890174,
			Volume = 1,
			tag = "SoundEffect",
			preloadLocal = true,
		},
		GemPurchase = {
			SoundId = 107834496997614,
			Volume = 1,
			tag = "SoundEffect",
			preloadLocal = true,
		},
		RewardClaimed = {
			SoundId = 107834496997614,
			Volume = 1,
			tag = "SoundEffect",
			preloadLocal = true,
		},
		AchievementClaimed = {
			SoundId = 107834496997614,
			Volume = 1,
			tag = "SoundEffect",
			preloadLocal = true,
		},

		-- In-Game sounds
		TileAdded = {
			SoundId = 119100882120159,
			Volume = 0.95,
			tag = "SoundEffect",
			preloadLocal = true,
		},
		TileRemoved = {
			SoundId = 129614417495542,
			Volume = 0.27,
			tag = "SoundEffect",
			preloadLocal = true,
		},
		WrongAnswer = {
			SoundId = 115124740518615,
			PlaybackSpeed = function()
				return math.random(90, 110) / 100
			end,
			Volume = 1,
			tag = "SoundEffect",
			preloadLocal = true,
		},
		RightAnswer = {
			SoundId = 123413990258305,
			PlaybackSpeed = function()
				return math.random(90, 110) / 100
			end,
			Volume = 1,
			tag = "SoundEffect",
			preloadLocal = true,
		},
		ComboIncrease = {
			SoundId = 132979575861475,
			Volume = 1.2,
			tag = "SoundEffect",
			preloadLocal = true,
		},
		Won = {
			-- SoundId = 122022642122946,
			SoundId = 107333120670841,
			Volume = 1,
			tag = "SoundEffect",
			preloadLocal = true,
		},
		Lost = {
			SoundId = 72159790759150,
			Volume = 1,
			tag = "SoundEffect",
			preloadLocal = true,
		},
		RollResult = {
			SoundId = 122387025484564,
			Volume = 1,
			tag = "SoundEffect",
			preloadLocal = true,
		},
		Gong = {
			SoundId = 84666372572856,
			PlaybackSpeed = 1,
			Volume = 0.85,
			tag = "SoundEffect",
			preloadLocal = true,
		},
		PlayerDiedSound = {
			SoundId = 133329258794504,
			Volume = 0.95,
			tag = "SoundEffect",
			preloadLocal = true,
		},
		CountdownTick = {
			SoundId = 94952134949700,
			tag = "SoundEffect",
			preloadLocal = true,
		},
		CountdownEnd = {
			SoundId = 127776688836567,
			tag = "SoundEffect",
			preloadLocal = true,
		},
		RollTick = {
			SoundId = 121089417455252,
			Volume = 0.95,
			tag = "SoundEffect",
			preloadLocal = true,
		},
		GameStart = {
			SoundId = 1843025733,
			Volume = 0.75,
			tag = "SoundEffect",
		},

		-- Cannon Fire
		CannonFire1 = {
			SoundId = 94430760874757,
			RollOffMaxDistance = 300,
			PlaybackSpeed = function()
				return math.random(90, 110) / 100
			end,
			Volume = 1,
			tag = "SoundEffect",
		},
		CannonFire2 = {
			SoundId = 109636883978489,
			RollOffMaxDistance = 300,
			PlaybackSpeed = function()
				return math.random(90, 110) / 100
			end,
			Volume = 1,
			tag = "SoundEffect",
		},
		CannonFire3 = {
			SoundId = 123778760290937,
			RollOffMaxDistance = 300,
			PlaybackSpeed = function()
				return math.random(90, 110) / 100
			end,
			Volume = 1,
			tag = "SoundEffect",
		},
		CannonFire4 = {
			SoundId = 138606760888044,
			RollOffMaxDistance = 300,
			PlaybackSpeed = function()
				return math.random(90, 110) / 100
			end,
			Volume = 1,
			tag = "SoundEffect",
		},
		CannonFire5 = {
			SoundId = 98037552195439,
			RollOffMaxDistance = 300,
			PlaybackSpeed = function()
				return math.random(90, 110) / 100
			end,
			Volume = 1,
			tag = "SoundEffect",
		},
		CannonFire6 = {
			SoundId = 116541599409557,
			RollOffMaxDistance = 300,
			PlaybackSpeed = function()
				return math.random(90, 110) / 100
			end,
			Volume = 1,
			tag = "SoundEffect",
		},
		CannonFire7 = {
			SoundId = 93893592397715,
			RollOffMaxDistance = 300,
			PlaybackSpeed = function()
				return math.random(90, 110) / 100
			end,
			Volume = 1,
			tag = "SoundEffect",
		},
		CannonFire8 = {
			SoundId = 73696314949932,
			RollOffMaxDistance = 300,
			PlaybackSpeed = function()
				return math.random(90, 110) / 100
			end,
			Volume = 1,
			tag = "SoundEffect",
		},
		CannonFire9 = {
			SoundId = 107250885896811,
			RollOffMaxDistance = 300,
			PlaybackSpeed = function()
				return math.random(90, 110) / 100
			end,
			Volume = 1,
			tag = "SoundEffect",
		},
		CannonFire10 = {
			SoundId = 137599842143409,
			RollOffMaxDistance = 300,
			PlaybackSpeed = function()
				return math.random(90, 110) / 100
			end,
			Volume = 1,
			tag = "SoundEffect",
		},

		CannonFire11 = {
			SoundId = 106342883284008,
			RollOffMaxDistance = 300,
			PlaybackSpeed = function()
				return math.random(125, 135) / 100
			end,
			Volume = 1,
			tag = "SoundEffect",
		},
		CannonFire12 = {
			SoundId = 113547425487890,
			RollOffMaxDistance = 300,
			PlaybackSpeed = function()
				return math.random(125, 135) / 100
			end,
			Volume = 1,
			tag = "SoundEffect",
		},
		CannonFire13 = {
			SoundId = 121965953086313,
			RollOffMaxDistance = 300,
			PlaybackSpeed = function()
				return math.random(125, 135) / 100
			end,
			Volume = 1,
			tag = "SoundEffect",
		},

		-- Cannon Hit
		CannonHit1 = {
			SoundId = 107745710070528,
			RollOffMaxDistance = 300,
			PlaybackSpeed = function()
				return math.random(90, 110) / 100
			end,
			Volume = 1,
			tag = "SoundEffect",
		},
		CannonHit2 = {
			SoundId = 136190888868512,
			RollOffMaxDistance = 300,
			PlaybackSpeed = function()
				return math.random(90, 110) / 100
			end,
			Volume = 1,
			tag = "SoundEffect",
		},
		CannonHit3 = {
			SoundId = 81212355332445,
			RollOffMaxDistance = 300,
			PlaybackSpeed = function()
				return math.random(90, 110) / 100
			end,
			Volume = 1,
			tag = "SoundEffect",
		},
		CannonHit4 = {
			SoundId = 117074104699943,
			RollOffMaxDistance = 300,
			PlaybackSpeed = function()
				return math.random(90, 110) / 100
			end,
			Volume = 1,
			tag = "SoundEffect",
		},
		CannonHit5 = {
			SoundId = 71898109735921,
			RollOffMaxDistance = 300,
			PlaybackSpeed = function()
				return math.random(90, 110) / 100
			end,
			Volume = 1,
			tag = "SoundEffect",
		},

		-- Waiting Music
		RelaxedScene = {
			SoundId = 1848354536,
			Volume = 1,
			tag = "Music",
		},
		ClairDeLune = {
			SoundId = 1838457617,
			Volume = 1,
			tag = "Music",
		},
		GymnopedieNo1 = {
			SoundId = 9045766377,
			Volume = 1,
			tag = "Music",
		},
		ChillJazz = {
			SoundId = 1845341094,
			Volume = 1,
			tag = "Music",
		},
		MorningMood = {
			SoundId = 1846088038,
			Volume = 1,
			tag = "Music",
		},
		LoFiChillA = {
			SoundId = 9043887091,
			Volume = 1,
			tag = "Music",
		},
		TownTalk = {
			SoundId = 1845756489,
			Volume = 1,
			tag = "Music",
		},
		NocturneOpus9C = {
			SoundId = 1848028342,
			Volume = 1,
			tag = "Music",
		},
		AllDropping8Beats = {
			SoundId = 9048375035,
			Volume = 1,
			tag = "Music",
		},
		YoungAndTender = {
			SoundId = 1842205471,
			Volume = 1,
			tag = "Music",
		},
		TenderChillstep = {
			SoundId = 1836098504,
			Volume = 1,
			tag = "Music",
		},
		Diamonds = {
			SoundId = 1846575559,
			Volume = 1,
			tag = "Music",
		},
		PlaygroundOfTheStars = {
			SoundId = 1840684208,
			Volume = 1,
			tag = "Music",
		},
		TheFourSeasons = {
			SoundId = 9045766074,
			Volume = 1,
			tag = "Music",
		},
		ConvenienceStore = {
			SoundId = 1839857296,
			Volume = 1,
			tag = "Music",
		},
		CartoonCapers = {
			SoundId = 1841647421,
			Volume = 1,
			tag = "Music",
		},
		BoredToBits = {
			SoundId = 1841646995,
			Volume = 1,
			tag = "Music",
		},
		ColouredCandles = {
			SoundId = 1837067610,
			Volume = 1,
			tag = "Music",
		},

		-- Voting Music
		JazzyChild = {
			SoundId = 1835943502,
			Volume = 1,
			tag = "Music",
		},
		ThisIsAMessage = {
			SoundId = 1835920469,
			Volume = 1,
			tag = "Music",
		},
		CatIsland = {
			SoundId = 9042446020,
			Volume = 1,
			tag = "Music",
		},
		ChineseJazz = {
			SoundId = 1835957140,
			Volume = 1,
			tag = "Music",
		},
		JazzyScratch = {
			SoundId = 1835956938,
			Volume = 1,
			tag = "Music",
		},
		HardBop = {
			SoundId = 1845262411,
			Volume = 1,
			tag = "Music",
		},
		BonbonTwistos = {
			SoundId = 1839029942,
			Volume = 1,
			tag = "Music",
		},
		PlayOnTen = {
			SoundId = 1846900297,
			Volume = 1,
			tag = "Music",
		},
		Swagger = {
			SoundId = 1837704533,
			Volume = 1,
			tag = "Music",
		},
		Skipping = {
			SoundId = 1837704553,
			Volume = 1,
			tag = "Music",
		},
		JollyBanjo = {
			SoundId = 1839049085,
			Volume = 1,
			tag = "Music",
		},
		InnerCityGoat = {
			SoundId = 1842425094,
			Volume = 1,
			tag = "Music",
		},

		HotTrap = {
			SoundId = 1835867462,
			Volume = 1,
			tag = "Music",
		},
		BouncerLink1 = {
			SoundId = 1844083639,
			Volume = 1,
			tag = "Music",
		},
		WorldsAwayStinger = {
			SoundId = 1843590969,
			Volume = 1,
			tag = "Music",
		},
		EnterTheChallenger = {
			SoundId = 9041980152,
			Volume = 1,
			tag = "Music",
		},
		DiamondsAndBands = {
			SoundId = 9040602089,
			Volume = 1,
			tag = "Music",
		},
		Spicy = {
			SoundId = 9040606047,
			Volume = 1,
			tag = "Music",
		},
		Spicy2 = {
			SoundId = 9040605435,
			Volume = 1,
			tag = "Music",
		},
		LockAndLoad = {
			SoundId = 9038803355,
			Volume = 1,
			tag = "Music",
		},

		DucksReggae = {
			SoundId = 1839030282,
			Volume = 1,
			tag = "Music",
		},

		-- Gameplay Music
		BossaMe = {
			SoundId = 1837768517,
			Volume = 0.65,
			tag = "Music",
		},
		RetroGamer = {
			SoundId = 1837768352,
			Volume = 0.65,
			tag = "Music",
		},
		FinalBossA = {
			SoundId = 1837768323,
			Volume = 0.65,
			tag = "Music",
		},
		FastAndLight = {
			SoundId = 1845927685,
			Volume = 0.65,
			tag = "Music",
		},
		YoureTheBest = {
			SoundId = 1837864351,
			Volume = 0.65,
			tag = "Music",
		},
		AhHaB = {
			SoundId = 1841168136,
			Volume = 0.65,
			tag = "Music",
		},
		DuckSoup = {
			SoundId = 1838887599,
			Volume = 0.65,
			tag = "Music",
		},
		ArtificialSunlight = {
			SoundId = 1846729856,
			Volume = 0.65,
			tag = "Music",
		},
		Autocue = {
			SoundId = 1846729624,
			Volume = 0.65,
			tag = "Music",
		},
		Shakedown = {
			SoundId = 1841067770,
			Volume = 0.65,
			tag = "Music",
		},
		PutTheRecordStraight = {
			SoundId = 1841067356,
			Volume = 0.65,
			tag = "Music",
		},

		GameplayMusic1 = {
			SoundId = 1848355321,
			Volume = 0.65,
			tag = "Music",
		},
		GameplayMusic2 = {
			SoundId = 1836888021,
			Volume = 0.65,
			tag = "Music",
		},
		GameplayMusic3 = {
			SoundId = 1837301555,
			Volume = 0.65,
			tag = "Music",
		},
		GameplayMusic4 = {
			SoundId = 1848327312,
			Volume = 0.65,
			tag = "Music",
		},
		GameplayMusic5 = {
			SoundId = 1836469813,
			Volume = 0.65,
			tag = "Music",
		},
		GameplayMusic6 = {
			SoundId = 1837039190,
			Volume = 0.65,
			tag = "Music",
		},
		GameplayMusic7 = {
			SoundId = 1839746006,
			Volume = 0.65,
			tag = "Music",
		},
		GameplayMusic8 = {
			SoundId = 1846600560,
			Volume = 0.65,
			tag = "Music",
		},
		GameplayMusic9 = {
			SoundId = 1839815155,
			Volume = 0.65,
			tag = "Music",
		},
		GameplayMusic10 = {
			SoundId = 1839355985,
			Volume = 0.65,
			tag = "Music",
		},
		GameplayMusic11 = {
			SoundId = 1839356153,
			Volume = 0.65,
			tag = "Music",
		},
		GameplayMusic12 = {
			SoundId = 1839384746,
			Volume = 0.65,
			tag = "Music",
		},
		GameplayMusic13 = {
			SoundId = 1839357822,
			Volume = 0.65,
			tag = "Music",
		},

		GameplayMusic14 = {
			SoundId = 1837640794,
			Volume = 0.65,
			tag = "Music",
		},
		GameplayMusic15 = {
			SoundId = 1845978359,
			Volume = 0.65,
			tag = "Music",
		},
		GameplayMusic16 = {
			SoundId = 1839137818,
			Volume = 0.65,
			tag = "Music",
		},
		GameplayMusic17 = {
			SoundId = 1843247351,
			Volume = 0.65,
			tag = "Music",
		},
		GameplayMusic18 = {
			SoundId = 1843247465,
			Volume = 0.65,
			tag = "Music",
		},

		GameplayMusic19 = {
			SoundId = 1842892976,
			Volume = 0.65,
			tag = "Music",
		},
		GameplayMusic20 = {
			SoundId = 1842892751,
			Volume = 0.65,
			tag = "Music",
		},
		GameplayMusic21 = {
			SoundId = 1844605071,
			Volume = 0.65,
			tag = "Music",
		},
		GameplayMusic22 = {
			SoundId = 1837444929,
			Volume = 0.65,
			tag = "Music",
		},
		GameplayMusic23 = {
			SoundId = 1842899192,
			Volume = 0.65,
			tag = "Music",
		},
		GameplayMusic24 = {
			SoundId = 1842643374,
			Volume = 0.65,
			tag = "Music",
		},
		GameplayMusic25 = {
			SoundId = 1837336312,
			Volume = 0.65,
			tag = "Music",
		},
		GameplayMusic26 = {
			SoundId = 1842497166,
			Volume = 0.65,
			tag = "Music",
		},
		GameplayMusic27 = {
			SoundId = 1837719958,
			Volume = 0.65,
			tag = "Music",
		},

		-- Intermission Music
		LobbySoiree = {
			SoundId = 1842000921,
			Volume = 1,
			tag = "Music",
		},
		AwkwardEncounter = {
			SoundId = 1842000880,
			Volume = 1,
			tag = "Music",
		},
		HangingFern = {
			SoundId = 1842000986,
			Volume = 1,
			tag = "Music",
		},
		PresidentialSuite = {
			SoundId = 1842000919,
			Volume = 1,
			tag = "Music",
		},
		TopFloor = {
			SoundId = 1842000834,
			Volume = 1,
			tag = "Music",
		},
		Vitruvius = {
			SoundId = 1842001003,
			Volume = 1,
			tag = "Music",
		},
		AutocueB = {
			SoundId = 1846729599,
			Volume = 1,
			tag = "Music",
		},
		YoureTheBest15 = {
			SoundId = 1837865756,
			Volume = 1,
			tag = "Music",
		},
		FlightOfFancy = {
			SoundId = 1847174180,
			Volume = 1,
			tag = "Music",
		},
		AOk = {
			SoundId = 1847037503,
			Volume = 1,
			tag = "Music",
		},
		MoFunky = {
			SoundId = 1842117223,
			Volume = 1,
			tag = "Music",
		},
		DoItToIt = {
			SoundId = 1847036890,
			Volume = 1,
			tag = "Music",
		},
		DoItToIt2 = {
			SoundId = 1847037140,
			Volume = 1,
			tag = "Music",
		},
		PassThePepper = {
			SoundId = 1847174360,
			Volume = 1,
			tag = "Music",
		},
		GuitarGambler = {
			SoundId = 1847174304,
			Volume = 1,
			tag = "Music",
		},
		ClassyFella = {
			SoundId = 1842117363,
			Volume = 1,
			tag = "Music",
		},
		GetTheFunkOut = {
			SoundId = 1842117364,
			Volume = 1,
			tag = "Music",
		},
		ChickenStrut = {
			SoundId = 1842117225,
			Volume = 1,
			tag = "Music",
		},

		-- Winner announcement
		OrchestralFlourish1 = {
			SoundId = 1846284221,
			Volume = 1,
			tag = "Music",
		},
		OrchestralFlourish2 = {
			SoundId = 1846284325,
			Volume = 1,
			tag = "Music",
		},
		OrchestralFlourish3 = {
			SoundId = 1846284217,
			Volume = 1,
			tag = "Music",
		},
		OrchestralFlourish4 = {
			SoundId = 1846284197,
			Volume = 1,
			tag = "Music",
		},
		OrchestralFlourish5 = {
			SoundId = 1846284188,
			Volume = 1,
			tag = "Music",
		},
	},
}
