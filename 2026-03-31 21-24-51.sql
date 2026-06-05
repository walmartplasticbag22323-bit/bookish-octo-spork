-- ULTIMATE MEGA Orbit Parts Script - 50 SHAPES + 26 ANIMATIONS + ULTRAKILL WINGS + RAINBOW MODE
-- Place this in StarterPlayerScripts or StarterCharacterScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

-- Variables
local selectionMode = false
local selectedPart = nil
local orbitingParts = {}
local orbitConnection = nil
local selectionBox = nil
local hideSelectionBox = false

-- Settings Variables
local orbitDistance = 10
local orbitSpeed = 1
local gapMode = "None"
local gapValue = 2
local orbitShape = "Circle"
local animationMode = "None"
local wireframeMode = false
local wireframeShape = "Cube"
local hammerMode = false
local hammerStatue = nil
local hammerParts = {}
local hammerConnection = nil
local hammerDepth = 3
local hammerCursorMode = false
local hammerColorSort = false
local fistMode = false
local fistParts = {
	thumb = {},
	index = {},
	middle = {},
	ring = {},
	pinky = {},
	palm = {}
}
local fingerStates = {
	thumb = 1,    -- 0 = closed, 1 = open
	index = 1,
	middle = 1,
	ring = 1,
	pinky = 1
}
local handControllerMode = false
local handControllerParts = {
	pivot = nil,
	palm = nil,
	thumb = {},
	index = {},
	middle = {},
	ring = {},
	pinky = {}
}
local handControllerConnection = nil
local handDistance = 15
local handFingerStates = {
	thumb = 1,
	index = 1,
	middle = 1,
	ring = 1,
	pinky = 1
}
local currentHandPose = "open"
local handPoses = {
	open = {thumb = 1, index = 1, middle = 1, ring = 1, pinky = 1},
	fist = {thumb = 0, index = 0, middle = 0, ring = 0, pinky = 0},
	grab = {thumb = 0.3, index = 0.2, middle = 0.2, ring = 0.2, pinky = 0.2},
	point = {thumb = 0.3, index = 1, middle = 0, ring = 0, pinky = 0},
	peace = {thumb = 0.3, index = 1, middle = 1, ring = 0, pinky = 0},
	thumbsUp = {thumb = 1, index = 0, middle = 0, ring = 0, pinky = 0},
	smash = {thumb = 0, index = 0.5, middle = 0.5, ring = 0.5, pinky = 0.5},
	pinch = {thumb = 0.5, index = 0.5, middle = 0, ring = 0, pinky = 0},
	rock = {thumb = 0.3, index = 1, middle = 0, ring = 0, pinky = 1},
	snap = {thumb = 0.7, index = 0.3, middle = 1, ring = 1, pinky = 1}
}
local wingsMode = false
local wingsConnection = nil
local wingParts = {left = {}, right = {}}
local rainbowMode = false
local networkOwnershipFilterMode = false -- 🎯 NEW: Only orbit parts you own!
local orbitPlayerMode = false -- 🧍 Orbit around the local player instead of a selected part

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "OrbitPartsGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 380, 0, 550)
mainFrame.Position = UDim2.new(0.5, -190, 0.5, -275)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Scroll Frame for content
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ScrollFrame"
scrollFrame.Size = UDim2.new(1, 0, 1, -30)
scrollFrame.Position = UDim2.new(0, 0, 0, 30)
scrollFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 3500)
scrollFrame.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
title.BorderSizePixel = 0
title.Text = "🌟 MEGA Orbit Controller 🌟"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.Font = Enum.Font.SourceSansBold
title.Parent = mainFrame

-- Helper function to create labeled textboxes
local function createLabeledTextbox(name, labelText, defaultValue, yPosition, parent)
	local label = Instance.new("TextLabel")
	label.Name = name .. "Label"
	label.Size = UDim2.new(0.9, 0, 0, 20)
	label.Position = UDim2.new(0.05, 0, 0, yPosition)
	label.BackgroundTransparency = 1
	label.Text = labelText
	label.TextColor3 = Color3.fromRGB(220, 220, 220)
	label.TextSize = 12
	label.Font = Enum.Font.SourceSans
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
	
	local textbox = Instance.new("TextBox")
	textbox.Name = name
	textbox.Size = UDim2.new(0.9, 0, 0, 30)
	textbox.Position = UDim2.new(0.05, 0, 0, yPosition + 22)
	textbox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	textbox.BorderSizePixel = 1
	textbox.BorderColor3 = Color3.fromRGB(100, 100, 100)
	textbox.Text = tostring(defaultValue)
	textbox.TextColor3 = Color3.fromRGB(255, 255, 255)
	textbox.TextSize = 14
	textbox.Font = Enum.Font.SourceSans
	textbox.ClearTextOnFocus = false
	textbox.Parent = parent
	
	return textbox
end

-- Helper function to create small buttons
local function createSmallButton(name, text, position)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = UDim2.new(0.28, 0, 0, 26)
	button.Position = position
	button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	button.BorderSizePixel = 1
	button.BorderColor3 = Color3.fromRGB(100, 100, 100)
	button.Text = text
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 10
	button.Font = Enum.Font.SourceSans
	button.Parent = scrollFrame
	return button
end

-- Selection Mode Button
local selectionButton = Instance.new("TextButton")
selectionButton.Name = "SelectionButton"
selectionButton.Size = UDim2.new(0.9, 0, 0, 40)
selectionButton.Position = UDim2.new(0.05, 0, 0, 5)
selectionButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
selectionButton.BorderSizePixel = 1
selectionButton.BorderColor3 = Color3.fromRGB(100, 100, 100)
selectionButton.Text = "Enable Selection Mode"
selectionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
selectionButton.TextSize = 14
selectionButton.Font = Enum.Font.SourceSans
selectionButton.Parent = scrollFrame

-- Selected Part Label
local selectedLabel = Instance.new("TextLabel")
selectedLabel.Name = "SelectedLabel"
selectedLabel.Size = UDim2.new(0.9, 0, 0, 30)
selectedLabel.Position = UDim2.new(0.05, 0, 0, 50)
selectedLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
selectedLabel.BorderSizePixel = 1
selectedLabel.BorderColor3 = Color3.fromRGB(100, 100, 100)
selectedLabel.Text = "Selected: None"
selectedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
selectedLabel.TextSize = 12
selectedLabel.Font = Enum.Font.SourceSans
selectedLabel.Parent = scrollFrame

-- Hide Selection Box Toggle
local hideSelectionToggle = Instance.new("TextButton")
hideSelectionToggle.Name = "HideSelectionToggle"
hideSelectionToggle.Size = UDim2.new(0.9, 0, 0, 30)
hideSelectionToggle.Position = UDim2.new(0.05, 0, 0, 85)
hideSelectionToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
hideSelectionToggle.BorderSizePixel = 1
hideSelectionToggle.BorderColor3 = Color3.fromRGB(100, 100, 100)
hideSelectionToggle.Text = "Hide Selection Box: OFF"
hideSelectionToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
hideSelectionToggle.TextSize = 12
hideSelectionToggle.Font = Enum.Font.SourceSans
hideSelectionToggle.Parent = scrollFrame

-- Rainbow Mode Toggle
local rainbowToggle = Instance.new("TextButton")
rainbowToggle.Name = "RainbowToggle"
rainbowToggle.Size = UDim2.new(0.9, 0, 0, 35)
rainbowToggle.Position = UDim2.new(0.05, 0, 0, 120)
rainbowToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
rainbowToggle.BorderSizePixel = 1
rainbowToggle.BorderColor3 = Color3.fromRGB(100, 100, 100)
rainbowToggle.Text = "🌈 RAINBOW COLOR SORTING: OFF"
rainbowToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
rainbowToggle.TextSize = 13
rainbowToggle.Font = Enum.Font.SourceSansBold
rainbowToggle.Parent = scrollFrame

-- Orbit Distance Input
local distanceTextbox = createLabeledTextbox("DistanceTextbox", "Orbit Distance (studs):", orbitDistance, 165, scrollFrame)

-- Orbit Speed Input
local speedTextbox = createLabeledTextbox("SpeedTextbox", "Orbit Speed (studs/second):", orbitSpeed, 230, scrollFrame)

-- Radius Limit Toggle and Input
local radiusLimitEnabled = false
local maxOrbitRadius = 50

local radiusLimitLabel = Instance.new("TextLabel")
radiusLimitLabel.Name = "RadiusLimitLabel"
radiusLimitLabel.Size = UDim2.new(0.5, -5, 0, 20)
radiusLimitLabel.Position = UDim2.new(0.05, 0, 0, 265)
radiusLimitLabel.BackgroundTransparency = 1
radiusLimitLabel.Text = "🎯 Limit Orbit Radius:"
radiusLimitLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
radiusLimitLabel.TextSize = 11
radiusLimitLabel.Font = Enum.Font.SourceSans
radiusLimitLabel.TextXAlignment = Enum.TextXAlignment.Left
radiusLimitLabel.Parent = scrollFrame

local radiusLimitToggle = Instance.new("TextButton")
radiusLimitToggle.Name = "RadiusLimitToggle"
radiusLimitToggle.Size = UDim2.new(0, 60, 0, 20)
radiusLimitToggle.Position = UDim2.new(0.5, 0, 0, 265)
radiusLimitToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
radiusLimitToggle.BorderSizePixel = 1
radiusLimitToggle.BorderColor3 = Color3.fromRGB(100, 100, 100)
radiusLimitToggle.Text = "OFF"
radiusLimitToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
radiusLimitToggle.TextSize = 11
radiusLimitToggle.Font = Enum.Font.SourceSansBold
radiusLimitToggle.Parent = scrollFrame

local maxRadiusTextbox = createLabeledTextbox("MaxRadiusTextbox", "Max Radius (studs):", maxOrbitRadius, 290, scrollFrame)

-- Gap Mode Section Label
local gapModeLabel = Instance.new("TextLabel")
gapModeLabel.Name = "GapModeLabel"
gapModeLabel.Size = UDim2.new(0.9, 0, 0, 25)
gapModeLabel.Position = UDim2.new(0.05, 0, 0, 355)
gapModeLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
gapModeLabel.BorderSizePixel = 1
gapModeLabel.BorderColor3 = Color3.fromRGB(100, 100, 100)
gapModeLabel.Text = "Gap Mode: None"
gapModeLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
gapModeLabel.TextSize = 13
gapModeLabel.Font = Enum.Font.SourceSansBold
gapModeLabel.Parent = scrollFrame

-- Gap Mode Buttons
local gapModeNone = createSmallButton("GapModeNone", "None", UDim2.new(0.05, 0, 0, 385))
gapModeNone.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
local gapModePerPart = createSmallButton("GapModePerPart", "Gap/Part", UDim2.new(0.36, 0, 0, 385))
local gapModeBetween = createSmallButton("GapModeBetween", "Gap Between", UDim2.new(0.67, 0, 0, 385))

-- Gap Value Input
local gapTextbox = createLabeledTextbox("GapTextbox", "Gap Value (studs):", gapValue, 420, scrollFrame)

-- Orbit Shape Section (50 SHAPES!)
local shapeLabel = Instance.new("TextLabel")
shapeLabel.Name = "ShapeLabel"
shapeLabel.Size = UDim2.new(0.9, 0, 0, 25)
shapeLabel.Position = UDim2.new(0.05, 0, 0, 485)
shapeLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
shapeLabel.BorderSizePixel = 1
shapeLabel.BorderColor3 = Color3.fromRGB(100, 100, 100)
shapeLabel.Text = "✨ 324 ORBIT SHAPES ✨"
shapeLabel.TextColor3 = Color3.fromRGB(100, 255, 255)
shapeLabel.TextSize = 13
shapeLabel.Font = Enum.Font.SourceSansBold
shapeLabel.Parent = scrollFrame

-- All 124 SHAPES! UNDERTALE + STAR GLITCHER + GEOMETRY DASH + ANIME + COSMIC + MYTHICAL!
local shapes = {
	-- ORIGINAL CLASSICS (64)
	"Circle", "Sphere", "Cube", "Spiral", "Wave", "Helix", "Figure8", "Star",
	"Pentagon", "Hexagon", "Octagon", "Diamond", "Heart", "Infinity", "Flower",
	"DNA", "Tornado", "Galaxy", "Rings", "Mobius", "Trefoil", "Torus", "Klein",
	"Hypercube", "Metatron", "Mandala", "Vortex", "Supernova", "Nebula", "BlackHole",
	"Atom", "Molecule", "Crystal", "Fractal", "Fibonacci", "GoldenSpiral", "Lissajous",
	"Butterfly", "Dragon", "Phoenix", "Serpent", "Crown", "Lotus", "Web", "Grid",
	"Tesseract", "Slinky", "Coil", "Chain", "Constellation", "Soul", "Determination",
	"Delta", "Gaster", "Bullet", "Chaos", "Astral", "Celestial", "Divine", "Spectrum",
	"Stellar", "Runic", "Eclipse", "Ethereal",
	
	-- MEGA SHAPES (60+)
	"Dodecagon", "Icosahedron", "Rhomboid", "Prism", "Pyramid", "Octahedron", "Tetrahedron", "Tesseract4D",
	"Kraken", "Leviathan", "Hydra", "Spider", "Jellyfish",
	"Pulsar", "Quasar", "Wormhole", "Blackhole",
	"Castle", "Sword", "Shield", "Throne", "Gate", "Portal", "Labyrinth",
	"Mech", "Satellite", "Reactor", "Circuit", "Matrix", "Hologram", "Laser",
	"Tree", "Volcano", "Ocean", "Mountain", "Aurora", "Comet",
	"Singularity", "Paradox", "Glitch", "Void",
	"BassBoost", "Equalizer", "Soundwave", "Echo", "Harmonic",
	
	-- COMBAT WEAPONS (6)
	"Shuriken", "Boomerang", "Chakram", "Glaive", "Scythe", "Lance",
	
	-- NEW ELEMENTAL SHAPES (24)
	"Fire", "Ice", "Lightning", "Earth", "Wind", "Water", "Metal", "Wood",
	"Light", "Shadow", "Thunder", "Magma", "Frost", "Storm", "Quake",
	"Tsunami", "Blaze", "Glacier", "Tempest", "Inferno", "Cyclone", "Avalanche",
	"Eruption", "Hurricane",
	
	-- 🔥 30 ADDICTIVE NEW SHAPES 🔥
	"Helix2", "DNA2", "Spiral2", "Vortex2", "Galaxy2",
	"Atom2", "Molecule2", "Quantum2", "Plasma2", "Photon2",
	"Neutron2", "Proton", "Electron", "Quark", "Gluon",
	"Higgs", "Antimatter2", "DarkMatter2", "DarkEnergy2", "Graviton2",
	"Spacetime", "Warp", "Hyperspace", "Subspace", "Multiverse2",
	"Timeline", "Paradox2", "Infinity2", "Eternity", "Oblivion",
	
	-- 💫 30 MORE EPIC SHAPES 💫
	"Celestial", "Astral", "Cosmic2", "Stellar2", "Lunar2",
	"Solar2", "Eclipse2", "Comet2", "Meteor2", "Aurora2",
	"Dimension", "Realm", "Plane", "Void2", "Abyss2",
	"Nexus", "Portal2", "Gateway", "Rift2", "Breach",
	"Titan", "Colossus", "Behemoth", "Juggernaut", "Leviathan3",
	"Omega", "Alpha", "Sigma", "Delta", "Epsilon",
	
	-- 🌊 40 MYTHICAL & LEGENDARY CREATURES 🌊
	"Chimera", "Cerberus", "Pegasus", "Unicorn", "Griffin",
	"Basilisk", "Medusa", "Minotaur", "Valkyrie", "Golem",
	"Djinn", "Ifrit", "Seraph", "Nephilim", "Demon",
	"Angel", "Wraith", "Specter", "Banshee", "Lich",
	"Vampire", "Werewolf", "Wendigo", "Skinwalker", "Yokai",
	"Kitsune", "Tengu", "Oni", "Kappa", "Naga",
	"Garuda", "Roc", "Thunderbird", "Firebird", "Icebird",
	"Sandworm", "SeaSerpent", "Skywhale", "Voidbeast", "Eldritch",
	
	-- 🎮 40 GAMING & ANIME REFERENCES 🎮
	"Kamehameha", "Rasengan", "Chidori", "Susanoo", "Amaterasu",
	"Tsukuyomi", "Izanagi", "Kagutsuchi", "Yasaka", "Totsuka",
	"Yata", "Kirin", "Rasenshuriken", "TailedBeast", "Bijuu",
	"Sharingan", "Rinnegan", "Byakugan", "Mangekyo", "EternalMS",
	"Bankai", "Shikai", "Resurreccion", "Vollstandig", "Schrift",
	"Zanpakuto", "Quincy", "Hollow", "Arrancar", "Espada",
	"Vizard", "Fullbring", "Hogyoku", "SoulKing", "ZeroSquad",
	"StandArrow", "Requiem", "GoldExperience", "StarPlatinum", "TheWorld",
	
	-- 🌌 40 COSMIC & SCIENTIFIC 🌌
	"Magnetar", "Neutron", "WhiteDwarf", "RedGiant", "BrownDwarf",
	"Protostar", "Supergiant", "Hypergiant", "WolfRayet", "Cepheid",
	"Nebula2", "Planetary", "Emission", "Reflection", "Dark",
	"Molecular", "Supernova2", "Hypernova", "Kilonova", "Gamma",
	"XRay", "Cosmic", "Microwave", "Infrared", "Ultraviolet",
	"Gravitational", "Spacetime2", "Curvature", "EventHorizon", "Accretion",
	"Ergosphere", "Photosphere", "Chromosphere", "Corona", "Prominence",
	"Flare", "Sunspot", "Coronal", "Heliosphere", "Magnetosphere",
	
	-- 🔮 40 MAGICAL & MYSTICAL 🔮
	"Arcane", "Mystic", "Occult", "Esoteric", "Hermetic",
	"Kabbalah", "Alchemy", "Transmutation", "Philosopher", "Elixir",
	"Grimoire", "Spellbook", "Enchantment", "Hex", "Curse",
	"Blessing", "Ward", "Seal", "Sigil", "Rune",
	"Glyph", "Talisman", "Amulet", "Charm", "Totem",
	"Familiar", "Summoning", "Conjuration", "Evocation", "Divination",
	"Necromancy", "Pyromancy", "Cryomancy", "Geomancy", "Aeromancy",
	"Hydromancy", "Electromancy", "Photomancy", "Umbramancy", "Chronomancy",
	
	-- ⚔️ 40 WEAPONS & COMBAT ⚔️
	"Katana", "Nodachi", "Wakizashi", "Tanto", "Naginata",
	"Yari", "Kusarigama", "Kunai", "Shuriken2", "Sai",
	"Tonfa", "Nunchaku", "Bo", "Jo", "Kama",
	"Claymore", "Longsword", "Broadsword", "Rapier", "Saber",
	"Cutlass", "Scimitar", "Falchion", "Gladius", "Spatha",
	"Halberd", "Glaive2", "Bardiche", "Partisan", "Ranseur",
	"Warhammer", "Maul", "Mace", "Flail", "Morningstar",
	"Battleaxe", "Greataxe", "Tomahawk", "Francisca", "Labrys"
}

local shapeButtons = {}
local currentY = 455
for i, shapeName in ipairs(shapes) do
	local col = (i - 1) % 3
	local row = math.floor((i - 1) / 3)
	local xPos = 0.05 + (col * 0.31)
	local yPos = currentY + (row * 30)
	
	local btn = createSmallButton("Shape"..shapeName, shapeName, UDim2.new(xPos, 0, 0, yPos))
	if shapeName == "Circle" then
		btn.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
	end
	table.insert(shapeButtons, {button = btn, shape = shapeName})
end

-- Animation Mode Section (26 ANIMATIONS!)
currentY = currentY + (math.ceil(#shapes / 3) * 30) + 20
local animLabel = Instance.new("TextLabel")
animLabel.Name = "AnimLabel"
animLabel.Size = UDim2.new(0.9, 0, 0, 25)
animLabel.Position = UDim2.new(0.05, 0, 0, currentY)
animLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
animLabel.BorderSizePixel = 1
animLabel.BorderColor3 = Color3.fromRGB(100, 100, 100)
animLabel.Text = "🎭 334 ANIMATIONS 🎭"
animLabel.TextColor3 = Color3.fromRGB(255, 150, 255)
animLabel.TextSize = 13
animLabel.Font = Enum.Font.SourceSansBold
animLabel.Parent = scrollFrame

-- All 94 ANIMATIONS! STAR GLITCHER + UNDERTALE + ANIME + ELEMENTAL + REALITY-BENDING!
local animations = {
	-- ORIGINAL CLASSICS (34)
	"None", "Pulse", "Expand", "Wobble", "Spin", "Shake", "Bounce", "Twist",
	"Orbit", "Flip", "Stretch", "Swirl", "Jitter", "Wave", "Breathe", "Flicker",
	"Rainbow", "Chaos", "Magnetic", "Repel", "Graviton", "Quantum", "Teleport",
	"Phasing", "Morph", "Kaleidoscope", "AstralBeam", "CelestialBurst", "DivinePillars",
	"SpectrumShift", "StellarOrbit", "RunicPulse", "EclipseSpin", "EtherealFloat",
	
	-- NEW ELEMENTAL ANIMATIONS (20)
	"Inferno", "Blizzard", "Thunder", "Earthquake", "Tsunami", "Cyclone",
	"Avalanche", "Eruption", "Lightning", "Meteor", "Comet", "Aurora",
	"Eclipse", "Supernova", "Implosion", "Explosion", "Shockwave", "Ripple",
	"Vortex", "Maelstrom",
	
	-- NEW ANIME/GAMING INSPIRED (20)
	"Kamehameha", "Rasengan", "Chidori", "Bankai", "Susanoo", "Sharingan",
	"Byakugan", "Zanpakuto", "Nen", "Haki", "Quirk", "StandPower",
	"DevilFruit", "Chakra", "Jutsu", "Zangetsu", "Hollow", "Arrancar",
	"Espada", "Vizard",
	
	-- NEW REALITY-BENDING ANIMATIONS (20)
	"TimeStop", "TimeReverse", "TimeSlow", "TimeFast", "SpaceWarp", "SpaceFold",
	"DimensionShift", "RealityBreak", "MatrixGlitch", "Pixelate", "Digitize",
	"Corruption", "Distortion", "Fragmentation", "Reconstruction", "Disintegrate",
	"Materialize", "Crystallize", "Liquify", "Vaporize",
	
	-- 🔥 30 FIRE & DESTRUCTION ANIMATIONS 🔥
	"Hellfire", "Wildfire", "Dragonfire", "Soulfire", "Frostfire",
	"Shadowfire", "Holyfire", "Demonfire", "Phoenixfire", "Starfire",
	"Meltdown", "Incinerate", "Combust", "Ignite", "Scorch",
	"Sear", "Char", "Smolder", "Kindle", "Blaze2",
	"Pyre", "Conflagration", "Immolation", "Cremation", "Cauterize",
	"Oxidize", "Deflagrate", "Detonate", "Annihilate", "Obliterate",
	
	-- ❄️ 30 ICE & COLD ANIMATIONS ❄️
	"Permafrost", "DeepFreeze", "Cryostasis", "Cryogenic", "Subzero",
	"Absolute", "Frostbite", "Icicle", "Hailstorm", "Snowstorm",
	"Whiteout", "Freeze", "Chill", "Numb", "Shiver",
	"Glaciate", "Crystallize2", "Solidify", "Petrify", "Harden",
	"Brittle", "Shatter", "Splinter", "Crack", "Break",
	"Fragment", "Crumble", "Disintegrate2", "Pulverize", "Atomize",
	
	-- ⚡ 30 ELECTRIC & ENERGY ANIMATIONS ⚡
	"Voltage", "Amperage", "Wattage", "Charge", "Discharge",
	"Static", "Plasma", "Ion", "Electron2", "Proton2",
	"Neutron3", "Photon3", "Tachyon", "Neutrino", "Muon",
	"Spark", "Arc", "Bolt", "Strike", "Flash",
	"Zap", "Shock", "Jolt", "Surge", "Overload",
	"Shortcircuit", "Electrocute", "Paralyze", "Stun", "Numb2",
	
	-- 🌪️ 30 WIND & STORM ANIMATIONS 🌪️
	"Gale", "Squall", "Tempest2", "Hurricane2", "Typhoon",
	"Monsoon", "Tornado2", "Twister", "Whirlwind", "Dust",
	"Sandstorm", "Haboob", "Simoom", "Khamsin", "Mistral",
	"Chinook", "Foehn", "Sirocco", "Zephyr", "Breeze",
	"Gust", "Draft", "Current", "Jet", "Stream",
	"Pressure", "Vacuum", "Suction", "Pull", "Push",
	
	-- 🌊 30 WATER & OCEAN ANIMATIONS 🌊
	"Tidal", "Riptide", "Undertow", "Whirlpool", "Maelstrom2",
	"Deluge", "Flood", "Torrent", "Rapids", "Cascade",
	"Waterfall", "Geyser", "Fountain", "Spray", "Mist",
	"Fog", "Steam", "Vapor", "Condensation", "Precipitation",
	"Rain", "Drizzle", "Downpour", "Monsoon2", "Squall2",
	"Splash", "Ripple2", "Wave2", "Swell", "Surge2",
	
	-- 🪨 30 EARTH & GROUND ANIMATIONS 🪨
	"Landslide", "Rockslide", "Mudslide", "Sinkhole", "Fissure",
	"Crevasse", "Chasm", "Canyon", "Gorge", "Ravine",
	"Cliff", "Boulder", "Stone", "Rock", "Pebble",
	"Sand", "Dust2", "Dirt", "Soil", "Clay",
	"Mud", "Quicksand", "Tar", "Lava", "Magma2",
	"Volcanic", "Tectonic", "Seismic", "Tremor", "Aftershock",
	
	-- 🌟 30 LIGHT & HOLY ANIMATIONS 🌟
	"Radiance", "Brilliance", "Luminance", "Incandescence", "Fluorescence",
	"Phosphorescence", "Bioluminescence", "Iridescence", "Opalescence", "Pearlescence",
	"Shimmer", "Glimmer", "Gleam", "Glow", "Shine",
	"Sparkle", "Twinkle", "Glitter", "Dazzle", "Blind",
	"Flash2", "Flare2", "Beacon", "Halo", "Aura",
	"Nimbus", "Glory", "Divine2", "Sacred", "Holy",
	
	-- 🌑 30 DARK & SHADOW ANIMATIONS 🌑
	"Umbra", "Penumbra", "Silhouette", "Shade", "Darkness",
	"Blackout", "Eclipse3", "Occultation", "Obscuration", "Obfuscation",
	"Shroud", "Veil", "Cloak", "Mask", "Hide",
	"Conceal", "Camouflage", "Stealth", "Invisible", "Transparent",
	"Fade", "Vanish", "Disappear", "Evaporate", "Dissolve",
	"Melt", "Decay", "Rot", "Wither", "Corrode"
}

local animButtons = {}
currentY = currentY + 30
for i, animName in ipairs(animations) do
	local col = (i - 1) % 3
	local row = math.floor((i - 1) / 3)
	local xPos = 0.05 + (col * 0.31)
	local yPos = currentY + (row * 30)
	
	local btn = createSmallButton("Anim"..animName, animName, UDim2.new(xPos, 0, 0, yPos))
	if animName == "None" then
		btn.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
	end
	table.insert(animButtons, {button = btn, anim = animName})
end

-- Wireframe Section
currentY = currentY + (math.ceil(#animations / 3) * 30) + 20
local wireframeLabel = Instance.new("TextLabel")
wireframeLabel.Name = "WireframeLabel"
wireframeLabel.Size = UDim2.new(0.9, 0, 0, 25)
wireframeLabel.Position = UDim2.new(0.05, 0, 0, currentY)
wireframeLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
wireframeLabel.BorderSizePixel = 1
wireframeLabel.BorderColor3 = Color3.fromRGB(100, 100, 100)
wireframeLabel.Text = "Wireframe Mode: OFF"
wireframeLabel.TextColor3 = Color3.fromRGB(255, 100, 255)
wireframeLabel.TextSize = 13
wireframeLabel.Font = Enum.Font.SourceSansBold
wireframeLabel.Parent = scrollFrame

-- Wireframe Toggle
currentY = currentY + 30
local wireframeToggle = Instance.new("TextButton")
wireframeToggle.Name = "WireframeToggle"
wireframeToggle.Size = UDim2.new(0.9, 0, 0, 35)
wireframeToggle.Position = UDim2.new(0.05, 0, 0, currentY)
wireframeToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
wireframeToggle.BorderSizePixel = 1
wireframeToggle.BorderColor3 = Color3.fromRGB(100, 100, 100)
wireframeToggle.Text = "Toggle Wireframe 3D Shapes"
wireframeToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
wireframeToggle.TextSize = 13
wireframeToggle.Font = Enum.Font.SourceSansBold
wireframeToggle.Parent = scrollFrame

-- ULTRAKILL Wings Section
currentY = currentY + 45
local wingsLabel = Instance.new("TextLabel")
wingsLabel.Name = "WingsLabel"
wingsLabel.Size = UDim2.new(0.9, 0, 0, 25)
wingsLabel.Position = UDim2.new(0.05, 0, 0, currentY)
wingsLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
wingsLabel.BorderSizePixel = 1
wingsLabel.BorderColor3 = Color3.fromRGB(100, 100, 100)
wingsLabel.Text = "👼 ULTRAKILL WINGS: OFF"
wingsLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
wingsLabel.TextSize = 13
wingsLabel.Font = Enum.Font.SourceSansBold
wingsLabel.Parent = scrollFrame

-- Wings Toggle Button
currentY = currentY + 30
local wingsToggle = Instance.new("TextButton")
wingsToggle.Name = "WingsToggle"
wingsToggle.Size = UDim2.new(0.9, 0, 0, 40)
wingsToggle.Position = UDim2.new(0.05, 0, 0, currentY)
wingsToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
wingsToggle.BorderSizePixel = 1
wingsToggle.BorderColor3 = Color3.fromRGB(100, 100, 100)
wingsToggle.Text = "Create ULTRAKILL Wings"
wingsToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
wingsToggle.TextSize = 13
wingsToggle.Font = Enum.Font.SourceSansBold
wingsToggle.Parent = scrollFrame

-- Hammer Mode Section
currentY = currentY + 50
local hammerLabel = Instance.new("TextLabel")
hammerLabel.Name = "HammerLabel"
hammerLabel.Size = UDim2.new(0.9, 0, 0, 25)
hammerLabel.Position = UDim2.new(0.05, 0, 0, currentY)
hammerLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
hammerLabel.BorderSizePixel = 1
hammerLabel.BorderColor3 = Color3.fromRGB(100, 100, 100)
hammerLabel.Text = "⚔️ GERSON'S HAMMER: OFF"
hammerLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
hammerLabel.TextSize = 13
hammerLabel.Font = Enum.Font.SourceSansBold
hammerLabel.Parent = scrollFrame

-- Hammer Toggle Button
currentY = currentY + 30
local hammerToggle = Instance.new("TextButton")
hammerToggle.Name = "HammerToggle"
hammerToggle.Size = UDim2.new(0.9, 0, 0, 40)
hammerToggle.Position = UDim2.new(0.05, 0, 0, currentY)
hammerToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
hammerToggle.BorderSizePixel = 1
hammerToggle.BorderColor3 = Color3.fromRGB(100, 100, 100)
hammerToggle.Text = "Create GERSON'S HAMMER"
hammerToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
hammerToggle.TextSize = 13
hammerToggle.Font = Enum.Font.SourceSansBold
hammerToggle.Parent = scrollFrame

-- Hammer Cursor Mode Toggle
currentY = currentY + 45
local hammerCursorToggle = Instance.new("TextButton")
hammerCursorToggle.Name = "HammerCursorToggle"
hammerCursorToggle.Size = UDim2.new(0.9, 0, 0, 35)
hammerCursorToggle.Position = UDim2.new(0.05, 0, 0, currentY)
hammerCursorToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
hammerCursorToggle.BorderSizePixel = 1
hammerCursorToggle.BorderColor3 = Color3.fromRGB(100, 100, 100)
hammerCursorToggle.Text = "Cursor Follow Mode: OFF"
hammerCursorToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
hammerCursorToggle.TextSize = 12
hammerCursorToggle.Font = Enum.Font.SourceSans
hammerCursorToggle.Parent = scrollFrame

-- Hammer Color Sort Toggle
currentY = currentY + 40
local hammerColorToggle = Instance.new("TextButton")
hammerColorToggle.Name = "HammerColorToggle"
hammerColorToggle.Size = UDim2.new(0.9, 0, 0, 35)
hammerColorToggle.Position = UDim2.new(0.05, 0, 0, currentY)
hammerColorToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
hammerColorToggle.BorderSizePixel = 1
hammerColorToggle.BorderColor3 = Color3.fromRGB(100, 100, 100)
hammerColorToggle.Text = "🌈 Hammer Color Sort: OFF"
hammerColorToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
hammerColorToggle.TextSize = 12
hammerColorToggle.Font = Enum.Font.SourceSans
hammerColorToggle.Parent = scrollFrame

-- Hammer Smash Button
currentY = currentY + 40
local hammerSmash = Instance.new("TextButton")
hammerSmash.Name = "HammerSmash"
hammerSmash.Size = UDim2.new(0.9, 0, 0, 40)
hammerSmash.Position = UDim2.new(0.05, 0, 0, currentY)
hammerSmash.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
hammerSmash.BorderSizePixel = 1
hammerSmash.BorderColor3 = Color3.fromRGB(100, 100, 100)
hammerSmash.Text = "SMASH (Click anywhere or press M)"
hammerSmash.TextColor3 = Color3.fromRGB(255, 255, 255)
hammerSmash.TextSize = 13
hammerSmash.Font = Enum.Font.SourceSansBold
hammerSmash.Parent = scrollFrame

-- FIST MODE Section
currentY = currentY + 50
local fistLabel = Instance.new("TextLabel")
fistLabel.Name = "FistLabel"
fistLabel.Size = UDim2.new(0.9, 0, 0, 25)
fistLabel.Position = UDim2.new(0.05, 0, 0, currentY)
fistLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
fistLabel.BorderSizePixel = 1
fistLabel.BorderColor3 = Color3.fromRGB(100, 100, 100)
fistLabel.Text = "✊ GIANT FIST MODE: OFF"
fistLabel.TextColor3 = Color3.fromRGB(255, 150, 100)
fistLabel.TextSize = 13
fistLabel.Font = Enum.Font.SourceSansBold
fistLabel.Parent = scrollFrame

-- Fist Toggle Button
currentY = currentY + 30
local fistToggle = Instance.new("TextButton")
fistToggle.Name = "FistToggle"
fistToggle.Size = UDim2.new(0.9, 0, 0, 40)
fistToggle.Position = UDim2.new(0.05, 0, 0, currentY)
fistToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
fistToggle.BorderSizePixel = 1
fistToggle.BorderColor3 = Color3.fromRGB(100, 100, 100)
fistToggle.Text = "Create GIANT FIST"
fistToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
fistToggle.TextSize = 13
fistToggle.Font = Enum.Font.SourceSansBold
fistToggle.Parent = scrollFrame

-- Fist Controls Info
currentY = currentY + 50
local fistControls = Instance.new("TextLabel")
fistControls.Name = "FistControls"
fistControls.Size = UDim2.new(0.9, 0, 0, 80)
fistControls.Position = UDim2.new(0.05, 0, 0, currentY)
fistControls.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
fistControls.BorderSizePixel = 1
fistControls.BorderColor3 = Color3.fromRGB(80, 80, 100)
fistControls.Text = [[✊ FIST CONTROLS:
O - Make Full Fist
G - Thumb | H - Index Finger
J - Middle | K - Ring | L - Pinky
M - PUNCH GROUND!]]
fistControls.TextColor3 = Color3.fromRGB(200, 200, 200)
fistControls.TextSize = 11
fistControls.Font = Enum.Font.SourceSans
fistControls.TextWrapped = true
fistControls.TextYAlignment = Enum.TextYAlignment.Top
fistControls.Parent = scrollFrame

-- HAND CONTROLLER Section
currentY = currentY + 90
local handLabel = Instance.new("TextLabel")
handLabel.Name = "HandLabel"
handLabel.Size = UDim2.new(0.9, 0, 0, 25)
handLabel.Position = UDim2.new(0.05, 0, 0, currentY)
handLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
handLabel.BorderSizePixel = 1
handLabel.BorderColor3 = Color3.fromRGB(100, 100, 100)
handLabel.Text = "🖐️ HAND CONTROLLER: OFF | Pose: Open"
handLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
handLabel.TextSize = 13
handLabel.Font = Enum.Font.SourceSansBold
handLabel.Parent = scrollFrame

-- Hand Toggle Button
currentY = currentY + 30
local handToggle = Instance.new("TextButton")
handToggle.Name = "HandToggle"
handToggle.Size = UDim2.new(0.9, 0, 0, 40)
handToggle.Position = UDim2.new(0.05, 0, 0, currentY)
handToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
handToggle.BorderSizePixel = 1
handToggle.BorderColor3 = Color3.fromRGB(100, 100, 100)
handToggle.Text = "Create HAND CONTROLLER"
handToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
handToggle.TextSize = 13
handToggle.Font = Enum.Font.SourceSansBold
handToggle.Parent = scrollFrame

-- Hand Controls Info
currentY = currentY + 50
local handControls = Instance.new("TextLabel")
handControls.Name = "HandControls"
handControls.Size = UDim2.new(0.9, 0, 0, 100)
handControls.Position = UDim2.new(0.05, 0, 0, currentY)
handControls.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
handControls.BorderSizePixel = 1
handControls.BorderColor3 = Color3.fromRGB(80, 80, 100)
handControls.Text = [[🖐️ HAND CONTROLS:
1 - Open | 2 - Fist | 3 - Grab
4 - Point | 5 - Peace | 6 - Thumbs Up
7 - Smash | 8 - Pinch | 9 - Rock
0 - Snap | Y - Toggle Hand Mode
Mouse Wheel - Adjust Distance]]
handControls.TextColor3 = Color3.fromRGB(200, 200, 200)
handControls.TextSize = 11
handControls.Font = Enum.Font.SourceSans
handControls.TextWrapped = true
handControls.TextYAlignment = Enum.TextYAlignment.Top
handControls.Parent = scrollFrame

-- Network Ownership Filter Section
currentY = currentY + 90
local ownershipLabel = Instance.new("TextLabel")
ownershipLabel.Name = "OwnershipLabel"
ownershipLabel.Size = UDim2.new(0.9, 0, 0, 25)
ownershipLabel.Position = UDim2.new(0.05, 0, 0, currentY)
ownershipLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ownershipLabel.BorderSizePixel = 1
ownershipLabel.BorderColor3 = Color3.fromRGB(100, 100, 100)
ownershipLabel.Text = "🎯 OWNERSHIP FILTER: OFF"
ownershipLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
ownershipLabel.TextSize = 13
ownershipLabel.Font = Enum.Font.SourceSansBold
ownershipLabel.Parent = scrollFrame

-- Ownership Filter Toggle Button
currentY = currentY + 30
local ownershipToggle = Instance.new("TextButton")
ownershipToggle.Name = "OwnershipToggle"
ownershipToggle.Size = UDim2.new(0.9, 0, 0, 35)
ownershipToggle.Position = UDim2.new(0.05, 0, 0, currentY)
ownershipToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ownershipToggle.BorderSizePixel = 1
ownershipToggle.BorderColor3 = Color3.fromRGB(100, 100, 100)
ownershipToggle.Text = "Only Orbit Parts You Own"
ownershipToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ownershipToggle.TextSize = 12
ownershipToggle.Font = Enum.Font.SourceSans
ownershipToggle.Parent = scrollFrame

-- Orbit Button
currentY = currentY + 45
local orbitButton = Instance.new("TextButton")
orbitButton.Name = "OrbitButton"
orbitButton.Size = UDim2.new(0.9, 0, 0, 45)
orbitButton.Position = UDim2.new(0.05, 0, 0, currentY)
orbitButton.BackgroundColor3 = Color3.fromRGB(50, 120, 50)
orbitButton.BorderSizePixel = 1
orbitButton.BorderColor3 = Color3.fromRGB(100, 100, 100)
orbitButton.Text = "START ORBITING"
orbitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
orbitButton.TextSize = 14
orbitButton.Font = Enum.Font.SourceSansBold
orbitButton.Parent = scrollFrame

-- Orbit Player Button
currentY = currentY + 55
local orbitPlayerButton = Instance.new("TextButton")
orbitPlayerButton.Name = "OrbitPlayerButton"
orbitPlayerButton.Size = UDim2.new(0.9, 0, 0, 45)
orbitPlayerButton.Position = UDim2.new(0.05, 0, 0, currentY)
orbitPlayerButton.BackgroundColor3 = Color3.fromRGB(50, 80, 150)
orbitPlayerButton.BorderSizePixel = 1
orbitPlayerButton.BorderColor3 = Color3.fromRGB(100, 100, 100)
orbitPlayerButton.Text = "🧍 ORBIT PLAYER"
orbitPlayerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
orbitPlayerButton.TextSize = 14
orbitPlayerButton.Font = Enum.Font.SourceSansBold
orbitPlayerButton.Parent = scrollFrame

-- Info Label
currentY = currentY + 55
local infoLabel = Instance.new("TextLabel")
infoLabel.Name = "InfoLabel"
infoLabel.Size = UDim2.new(0.9, 0, 0, 650)
infoLabel.Position = UDim2.new(0.05, 0, 0, currentY)
infoLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
infoLabel.BorderSizePixel = 1
infoLabel.BorderColor3 = Color3.fromRGB(80, 80, 100)
infoLabel.Text = [[🌟 MEGA ULTIMATE FEATURES 🌟

✨ 324 ORBIT SHAPES - ABSOLUTELY INSANE VARIETY! ✨
Including UNDERTALE + STAR GLITCHER + GEOMETRY DASH + MYTHICAL + ANIME + WEAPONS + COSMIC + MAGICAL!

🌌 COSMIC (40+): Quasar, Pulsar, Magnetar, Wormhole, Singularity, Antimatter, DarkMatter, DarkEnergy, Multiverse, Dimension, Rift, Void, Paradox, Neutron, WhiteDwarf, RedGiant, Supergiant, Hypergiant, Nebula, Supernova, Hypernova, Kilonova, Gamma, XRay, Gravitational, Spacetime, EventHorizon, Accretion, Photosphere, Corona, Prominence, Flare, Heliosphere, Magnetosphere

🐉 MYTHICAL (40+): Kraken, Leviathan, Behemoth, Hydra, Chimera, Cerberus, Pegasus, Unicorn, Griffin, Basilisk, Medusa, Minotaur, Valkyrie, Titan, Colossus, Golem, Djinn, Ifrit, Seraph, Nephilim, Demon, Angel, Wraith, Specter, Banshee, Lich, Vampire, Werewolf, Wendigo, Yokai, Kitsune, Tengu, Oni, Kappa, Naga, Garuda, Roc, Thunderbird, Firebird, Eldritch

🎮 ANIME (40+): Kamehameha, Rasengan, Chidori, Susanoo, Amaterasu, Tsukuyomi, Izanagi, Sharingan, Rinnegan, Byakugan, Mangekyo, Bankai, Shikai, Resurreccion, Zanpakuto, Quincy, Hollow, Arrancar, Espada, Vizard, Fullbring, Hogyoku, StandArrow, Requiem, GoldExperience, StarPlatinum, TheWorld, TailedBeast, Bijuu

⚔️ WEAPONS (40+): Katana, Nodachi, Wakizashi, Tanto, Naginata, Kusarigama, Kunai, Shuriken, Claymore, Longsword, Rapier, Saber, Cutlass, Scimitar, Halberd, Glaive, Bardiche, Warhammer, Maul, Mace, Flail, Morningstar, Battleaxe, Greataxe, Tomahawk, Lance, Spear, Trident

🔮 MAGICAL (40+): Arcane, Mystic, Occult, Esoteric, Hermetic, Kabbalah, Alchemy, Transmutation, Philosopher, Elixir, Grimoire, Spellbook, Enchantment, Hex, Curse, Blessing, Ward, Seal, Sigil, Rune, Glyph, Talisman, Amulet, Charm, Totem, Familiar, Summoning, Conjuration, Necromancy, Pyromancy, Cryomancy, Geomancy, Aeromancy, Hydromancy, Electromancy, Photomancy, Umbramancy, Chronomancy

Plus all classics: Circle, Sphere, Cube, Spiral, Wave, Helix, Figure8, Star, Pentagon, Hexagon, Octagon, Diamond, Heart, Infinity, Flower, DNA, Tornado, Galaxy, Rings, Mobius, Trefoil, Torus, Klein, Hypercube, Metatron, Mandala, Vortex, BlackHole, Atom, Molecule, Crystal, Fractal, Fibonacci, GoldenSpiral, Lissajous, Butterfly, Dragon, Phoenix, Serpent, Crown, Lotus, Web, Grid, Tesseract

🎭 334 ANIMATIONS - LEGENDARY VARIETY! 🎭

🔥 FIRE (30): Hellfire, Wildfire, Dragonfire, Soulfire, Frostfire, Shadowfire, Holyfire, Demonfire, Phoenixfire, Starfire, Meltdown, Incinerate, Combust, Ignite, Scorch, Sear, Char, Smolder, Kindle, Blaze, Pyre, Conflagration, Immolation, Cremation, Cauterize, Oxidize, Deflagrate, Detonate, Annihilate, Obliterate

❄️ ICE (30): Permafrost, DeepFreeze, Cryostasis, Cryogenic, Subzero, Absolute, Frostbite, Icicle, Hailstorm, Snowstorm, Whiteout, Freeze, Chill, Numb, Shiver, Glaciate, Crystallize, Solidify, Petrify, Harden, Brittle, Shatter, Splinter, Crack, Break, Fragment, Crumble, Disintegrate, Pulverize, Atomize

⚡ ELECTRIC (30): Voltage, Amperage, Wattage, Charge, Discharge, Static, Plasma, Ion, Electron, Proton, Neutron, Photon, Tachyon, Neutrino, Muon, Spark, Arc, Bolt, Strike, Flash, Zap, Shock, Jolt, Surge, Overload, Shortcircuit, Electrocute, Paralyze, Stun, Numb

🌪️ WIND (30): Gale, Squall, Tempest, Hurricane, Typhoon, Monsoon, Tornado, Twister, Whirlwind, Dust, Sandstorm, Haboob, Simoom, Khamsin, Mistral, Chinook, Foehn, Sirocco, Zephyr, Breeze, Gust, Draft, Current, Jet, Stream, Pressure, Vacuum, Suction, Pull, Push

🌊 WATER (30): Tidal, Riptide, Undertow, Whirlpool, Maelstrom, Deluge, Flood, Torrent, Rapids, Cascade, Waterfall, Geyser, Fountain, Spray, Mist, Fog, Steam, Vapor, Condensation, Precipitation, Rain, Drizzle, Downpour, Monsoon, Squall, Splash, Ripple, Wave, Swell, Surge

🪨 EARTH (30): Landslide, Rockslide, Mudslide, Sinkhole, Fissure, Crevasse, Chasm, Canyon, Gorge, Ravine, Cliff, Boulder, Stone, Rock, Pebble, Sand, Dust, Dirt, Soil, Clay, Mud, Quicksand, Tar, Lava, Magma, Volcanic, Tectonic, Seismic, Tremor, Aftershock

🌟 LIGHT (30): Radiance, Brilliance, Luminance, Incandescence, Fluorescence, Phosphorescence, Bioluminescence, Iridescence, Opalescence, Pearlescence, Shimmer, Glimmer, Gleam, Glow, Shine, Sparkle, Twinkle, Glitter, Dazzle, Blind, Flash, Flare, Beacon, Halo, Aura, Nimbus, Glory, Divine, Sacred, Holy

🌑 DARK (30): Umbra, Penumbra, Silhouette, Shade, Darkness, Blackout, Eclipse, Occultation, Obscuration, Obfuscation, Shroud, Veil, Cloak, Mask, Hide, Conceal, Camouflage, Stealth, Invisible, Transparent, Fade, Vanish, Disappear, Evaporate, Dissolve, Melt, Decay, Rot, Wither, Corrode

Plus classics: Pulse, Expand, Wobble, Spin, Shake, Bounce, Twist, Orbit, Flip, Stretch, Swirl, Jitter, Wave, Breathe, Flicker, Rainbow, Chaos, Magnetic, Repel, Graviton, Quantum, Teleport, Phasing, Morph, Kaleidoscope, TimeStop, TimeReverse, SpaceWarp, DimensionShift, RealityBreak, MatrixGlitch, Pixelate, Kamehameha, Rasengan, Chidori, Bankai, Susanoo

👼 ULTRAKILL WINGS - Epic angel wings!
Wings follow you and animate smoothly

🌈 RAINBOW COLOR SORTING - Experimental!
Auto-arranges parts by hue (keeps original colors!)
Creates natural rainbow spectrum order

🔨 GERSON'S HAMMER - The legendary turtle merchant's weapon!
Chunky war hammer that SPINS during smash!
🌈 Color sort option - arrange hammer parts by color
🎯 Cursor mode - hammer follows your mouse with directional tilt!
💥 Click anywhere to smash at that location!
Press M to smash at your character's position
Hammer uses raycasting to find ground - no more clipping!

✊ GIANT FIST MODE - Control a massive hand!
Individual finger control with realistic curling
Make a fist, point, or customize each finger
Press M to PUNCH the ground with devastating force!

🎯 NETWORK OWNERSHIP FILTER - Multiplayer-ready!
Toggle to only orbit parts YOU own (network ownership)
Perfect for public servers - no conflicts with other players!
When OFF: orbits all unlocked parts (default)
When ON: only orbits parts you control

THIS IS THE MOST INSANE ORBIT SCRIPT EVER CREATED! 🔥💀🚀]]
infoLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
infoLabel.TextSize = 9
infoLabel.Font = Enum.Font.SourceSans
infoLabel.TextWrapped = true
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.Parent = scrollFrame

-- Update canvas size
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, currentY + 740)

-- Functions
local function isPartUnlocked(part)
	if not part:IsA("BasePart") then return false end
	if part.Locked then return false end
	return true
end

local function canSetNetworkOwnership(part)
	local success = pcall(function()
		part:GetNetworkOwner()
	end)
	return success
end

local function setNetworkOwnership(part)
	if canSetNetworkOwnership(part) then
		local success = pcall(function()
			part:SetNetworkOwner(player)
		end)
		return success
	end
	return false
end

-- 🎯 NEW: Check if player owns this part's network ownership (AFTER trying to claim it)
local function isOwnedByPlayer(part)
	if not networkOwnershipFilterMode then
		return true -- Filter disabled, allow all parts
	end
	
	-- When filter is ON, verify we own it after claiming
	local success, owner = pcall(function()
		return part:GetNetworkOwner()
	end)
	
	if not success then
		-- Can't check ownership - allow it (might be special part type)
		return true
	end
	
	-- If owner is nil, the server owns it (we can claim it)
	if owner == nil then
		return true
	end
	
	-- If owner is the player, we own it
	if owner == player then
		return true
	end
	
	-- Someone else owns it - reject it
	print("⚠️ Rejected part owned by:", owner.Name)
	return false
end

local function createSelectionBox(part)
	if selectionBox then
		selectionBox:Destroy()
	end
	
	if not hideSelectionBox then
		selectionBox = Instance.new("SelectionBox")
		selectionBox.Adornee = part
		selectionBox.Color3 = Color3.fromRGB(0, 255, 0)
		selectionBox.LineThickness = 0.05
		selectionBox.SurfaceTransparency = 0.7
		selectionBox.Parent = workspace
	end
end

local function clearSelection()
	if selectionBox then
		selectionBox:Destroy()
		selectionBox = nil
	end
	selectedPart = nil
	selectedLabel.Text = "Selected: None"
end

local function selectPart(part)
	if not isPartUnlocked(part) then
		warn("Cannot select locked part!")
		return
	end
	
	selectedPart = part
	createSelectionBox(part)
	selectedLabel.Text = "Selected: " .. part.Name
	selectionMode = false
	selectionButton.Text = "Enable Selection Mode"
	selectionButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
end

local function stopOrbiting()
	if orbitConnection then
		orbitConnection:Disconnect()
		orbitConnection = nil
	end
	
	for _, part in ipairs(orbitingParts) do
		if part and part.Parent then
			pcall(function()
				part:SetNetworkOwnershipAuto()
			end)
		end
	end
	
	orbitingParts = {}
	orbitButton.Text = "START ORBITING"
	orbitButton.BackgroundColor3 = Color3.fromRGB(50, 120, 50)
	orbitPlayerMode = false
	orbitPlayerButton.Text = "🧍 ORBIT PLAYER"
	orbitPlayerButton.BackgroundColor3 = Color3.fromRGB(50, 80, 150)
end

local function destroyWings()
	if wingsConnection then
		wingsConnection:Disconnect()
		wingsConnection = nil
	end
	
	for _, part in ipairs(wingParts.left) do
		if part and part.Parent then
			pcall(function()
				part:SetNetworkOwnershipAuto()
			end)
		end
	end
	
	for _, part in ipairs(wingParts.right) do
		if part and part.Parent then
			pcall(function()
				part:SetNetworkOwnershipAuto()
			end)
		end
	end
	
	wingParts = {left = {}, right = {}}
	wingsMode = false
	wingsLabel.Text = "👼 ULTRAKILL WINGS: OFF"
	wingsToggle.Text = "Create ULTRAKILL Wings"
	wingsToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
end

local function createWings()
	if not selectedPart or not selectedPart.Parent then
		warn("No valid part selected!")
		return
	end
	
	destroyWings()
	
	-- Collect all unlocked unanchored parts
	local allParts = {}
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") and obj ~= selectedPart then
			if isPartUnlocked(obj) and not obj.Anchored then
				-- Try to claim ownership first
				setNetworkOwnership(obj)
				-- Then check if we own it (if filter is enabled)
				if isOwnedByPlayer(obj) then
					table.insert(allParts, obj)
				end
			end
		end
	end
	
	if #allParts < 20 then
		warn("Not enough parts for wings! Need at least 20 unlocked unanchored parts.")
		if networkOwnershipFilterMode then
			warn("🎯 Ownership filter is ON - only using parts you own. Try disabling it if needed.")
		end
		return
	end
	
	-- Split parts between left and right wings
	local partsPerWing = math.floor(#allParts / 2)
	for i = 1, partsPerWing do
		table.insert(wingParts.left, allParts[i])
	end
	for i = partsPerWing + 1, #allParts do
		table.insert(wingParts.right, allParts[i])
	end
	
	wingsMode = true
	wingsLabel.Text = "👼 ULTRAKILL WINGS: ON (" .. #allParts .. " parts)"
	wingsToggle.Text = "Destroy Wings"
	wingsToggle.BackgroundColor3 = Color3.fromRGB(120, 50, 50)
	
	print("✨ ULTRAKILL Wings created with " .. #allParts .. " parts!")
	
	-- Wing animation loop
	local startTime = tick()
	wingsConnection = RunService.Heartbeat:Connect(function()
		if not selectedPart or not selectedPart.Parent then
			destroyWings()
			return
		end
		
		local time = tick() - startTime
		local basePos = selectedPart.Position
		local blockCFrame = selectedPart.CFrame
		
		-- Animate left wing
		for i, part in ipairs(wingParts.left) do
			if part and part.Parent then
				local progress = (i - 1) / #wingParts.left
				
				-- Wing shape: layered feathers extending outward and back
				local wingSpan = 8 + progress * 12
				local wingHeight = -2 + math.sin(progress * math.pi) * 5
				local wingDepth = -3 - progress * 4
				
				-- Flapping animation
				local flapAngle = math.sin(time * 3 + progress * 2) * 0.6
				local flapHeight = math.sin(time * 3 + progress * 2) * 2
				
				local offset = Vector3.new(
					-wingSpan * math.cos(flapAngle),
					wingHeight + flapHeight,
					wingDepth
				)
				
				local targetPos = basePos + offset
				
				-- Smooth movement
				local direction = (targetPos - part.Position)
				local distance = direction.Magnitude
				
				if distance > 0.5 then
					part.AssemblyLinearVelocity = direction.Unit * math.min(distance * 8, 40)
				else
					part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				end
				
				-- Gentle rotation
				part.AssemblyAngularVelocity = Vector3.new(
					math.sin(time + i) * 1,
					math.cos(time + i) * 1,
					0
				)
			end
		end
		
		-- Animate right wing (mirrored)
		for i, part in ipairs(wingParts.right) do
			if part and part.Parent then
				local progress = (i - 1) / #wingParts.right
				
				local wingSpan = 8 + progress * 12
				local wingHeight = -2 + math.sin(progress * math.pi) * 5
				local wingDepth = -3 - progress * 4
				
				local flapAngle = math.sin(time * 3 + progress * 2) * 0.6
				local flapHeight = math.sin(time * 3 + progress * 2) * 2
				
				local offset = Vector3.new(
					wingSpan * math.cos(flapAngle),
					wingHeight + flapHeight,
					wingDepth
				)
				
				local targetPos = basePos + offset
				
				local direction = (targetPos - part.Position)
				local distance = direction.Magnitude
				
				if distance > 0.5 then
					part.AssemblyLinearVelocity = direction.Unit * math.min(distance * 8, 40)
				else
					part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				end
				
				part.AssemblyAngularVelocity = Vector3.new(
					math.sin(time + i) * 1,
					math.cos(time + i) * 1,
					0
				)
			end
		end
	end)
end

local function destroyFist()
	if wingsConnection then
		wingsConnection:Disconnect()
		wingsConnection = nil
	end
	
	for finger, parts in pairs(fistParts) do
		for _, part in ipairs(parts) do
			if part and part.Parent then
				pcall(function()
					part:SetNetworkOwnershipAuto()
				end)
			end
		end
	end
	
	fistParts = {
		thumb = {},
		index = {},
		middle = {},
		ring = {},
		pinky = {},
		palm = {}
	}
	fingerStates = {
		thumb = 1,
		index = 1,
		middle = 1,
		ring = 1,
		pinky = 1
	}
	fistMode = false
	fistLabel.Text = "✊ GIANT FIST MODE: OFF"
	fistToggle.Text = "Create GIANT FIST"
	fistToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
end

local function createFist()
	if not selectedPart or not selectedPart.Parent then
		warn("No valid part selected!")
		return
	end
	
	destroyFist()
	
	local allParts = {}
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") and obj ~= selectedPart then
			if isPartUnlocked(obj) and not obj.Anchored then
				-- Try to claim ownership first
				setNetworkOwnership(obj)
				-- Then check if we own it (if filter is enabled)
				if isOwnedByPlayer(obj) then
					table.insert(allParts, obj)
				end
			end
		end
	end
	
	if #allParts < 30 then
		warn("Not enough parts for fist! Need at least 30.")
		if networkOwnershipFilterMode then
			warn("🎯 Ownership filter is ON - only using parts you own. Try disabling it if needed.")
		end
		return
	end
	
	-- Distribute parts: larger palm, equal finger lengths
	local partsPerFinger = math.floor(#allParts * 0.12) -- 12% per finger = 60% for fingers
	local palmParts = #allParts - (partsPerFinger * 5) -- 40% for palm
	local idx = 1
	
	-- Palm gets the most parts (forms the base)
	for i = 1, palmParts do
		table.insert(fistParts.palm, allParts[idx])
		idx = idx + 1
	end
	
	-- All fingers get equal parts
	for i = 1, partsPerFinger do
		table.insert(fistParts.thumb, allParts[idx])
		idx = idx + 1
	end
	for i = 1, partsPerFinger do
		table.insert(fistParts.index, allParts[idx])
		idx = idx + 1
	end
	for i = 1, partsPerFinger do
		table.insert(fistParts.middle, allParts[idx])
		idx = idx + 1
	end
	for i = 1, partsPerFinger do
		table.insert(fistParts.ring, allParts[idx])
		idx = idx + 1
	end
	while idx <= #allParts do
		table.insert(fistParts.pinky, allParts[idx])
		idx = idx + 1
	end
	
	fistMode = true
	fistLabel.Text = "✊ GIANT FIST MODE: ON (" .. #allParts .. " parts)"
	fistToggle.Text = "Destroy Fist"
	fistToggle.BackgroundColor3 = Color3.fromRGB(120, 50, 50)
	
	print("✊ Giant Fist created with " .. #allParts .. " parts!")
	print("   Palm: " .. #fistParts.palm .. " | Fingers: " .. partsPerFinger .. " each")
	
	local startTime = tick()
	wingsConnection = RunService.Heartbeat:Connect(function()
		if not selectedPart or not selectedPart.Parent then
			destroyFist()
			return
		end
		
		local time = tick() - startTime
		local basePos = selectedPart.Position
		local blockCFrame = selectedPart.CFrame
		local blockRotation = blockCFrame - blockCFrame.Position
		
		-- Position hand in front and to the right
		local handOffset = Vector3.new(6, 3, 5)
		local handBase = basePos + blockRotation * handOffset
		
		-- PALM - form a flat rectangular base (hand back)
		local palmRows = math.ceil(math.sqrt(#fistParts.palm))
		local palmCols = math.ceil(#fistParts.palm / palmRows)
		
		for i, part in ipairs(fistParts.palm) do
			if part and part.Parent then
				local row = math.floor((i - 1) / palmCols)
				local col = (i - 1) % palmCols
				
				-- Create a flat palm surface
				local palmOffset = Vector3.new(
					(col - palmCols / 2) * 1.2,  -- Spread horizontally
					0,  -- Flat base
					(row - palmRows / 2) * 1.2   -- Depth
				)
				local targetPos = handBase + blockRotation * palmOffset
				
				local direction = (targetPos - part.Position)
				if direction.Magnitude > 0.5 then
					part.AssemblyLinearVelocity = direction.Unit * math.min(direction.Magnitude * 10, 50)
				else
					part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				end
				part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
			end
		end
		
		-- THUMB - extends from left side at 45 degree angle
		for i, part in ipairs(fistParts.thumb) do
			if part and part.Parent then
				local progress = i / #fistParts.thumb
				local curl = fingerStates.thumb
				
				-- Thumb starts from side of palm and points diagonally
				local thumbOffset = Vector3.new(
					-palmCols * 0.6 - progress * 3 * (1 - curl),  -- Side position
					progress * 3 * (1 - curl),  -- Height when open
					-progress * 2 * curl  -- Curl inward
				)
				local targetPos = handBase + blockRotation * thumbOffset
				
				local direction = (targetPos - part.Position)
				if direction.Magnitude > 0.5 then
					part.AssemblyLinearVelocity = direction.Unit * math.min(direction.Magnitude * 10, 50)
				else
					part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				end
				part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
			end
		end
		
		-- INDEX FINGER - extends straight up from palm (leftmost of 4 fingers)
		for i, part in ipairs(fistParts.index) do
			if part and part.Parent then
				local progress = i / #fistParts.index
				local curl = fingerStates.index
				
				local fingerOffset = Vector3.new(
					-palmCols * 0.3,  -- Position on palm
					progress * 6 * (1 - curl),  -- Extend upward when open
					palmRows * 0.6 - progress * 3 * curl  -- Curl forward when closed
				)
				local targetPos = handBase + blockRotation * fingerOffset
				
				local direction = (targetPos - part.Position)
				if direction.Magnitude > 0.5 then
					part.AssemblyLinearVelocity = direction.Unit * math.min(direction.Magnitude * 10, 50)
				else
					part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				end
				part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
			end
		end
		
		-- MIDDLE FINGER - tallest, center position
		for i, part in ipairs(fistParts.middle) do
			if part and part.Parent then
				local progress = i / #fistParts.middle
				local curl = fingerStates.middle
				
				local fingerOffset = Vector3.new(
					-palmCols * 0.1,  -- Slightly left of center
					progress * 7 * (1 - curl),  -- Tallest finger
					palmRows * 0.6 - progress * 3 * curl
				)
				local targetPos = handBase + blockRotation * fingerOffset
				
				local direction = (targetPos - part.Position)
				if direction.Magnitude > 0.5 then
					part.AssemblyLinearVelocity = direction.Unit * math.min(direction.Magnitude * 10, 50)
				else
					part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				end
				part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
			end
		end
		
		-- RING FINGER - right of middle
		for i, part in ipairs(fistParts.ring) do
			if part and part.Parent then
				local progress = i / #fistParts.ring
				local curl = fingerStates.ring
				
				local fingerOffset = Vector3.new(
					palmCols * 0.1,  -- Slightly right of center
					progress * 6.5 * (1 - curl),
					palmRows * 0.6 - progress * 3 * curl
				)
				local targetPos = handBase + blockRotation * fingerOffset
				
				local direction = (targetPos - part.Position)
				if direction.Magnitude > 0.5 then
					part.AssemblyLinearVelocity = direction.Unit * math.min(direction.Magnitude * 10, 50)
				else
					part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				end
				part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
			end
		end
		
		-- PINKY FINGER - shortest, rightmost
		for i, part in ipairs(fistParts.pinky) do
			if part and part.Parent then
				local progress = i / #fistParts.pinky
				local curl = fingerStates.pinky
				
				local fingerOffset = Vector3.new(
					palmCols * 0.3,  -- Rightmost position
					progress * 5 * (1 - curl),  -- Shortest finger
					palmRows * 0.6 - progress * 3 * curl
				)
				local targetPos = handBase + blockRotation * fingerOffset
				
				local direction = (targetPos - part.Position)
				if direction.Magnitude > 0.5 then
					part.AssemblyLinearVelocity = direction.Unit * math.min(direction.Magnitude * 10, 50)
				else
					part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				end
				part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
			end
		end
	end)
end

local function punchGround()
	if not fistMode then
		warn("Fist not created!")
		return
	end
	
	if not selectedPart or not selectedPart.Parent then
		warn("Selected part no longer exists!")
		return
	end
	
	print("👊 FIST PUNCH! 💥")
	
	if wingsConnection then
		wingsConnection:Disconnect()
		wingsConnection = nil
	end
	
	local punchStartTime = tick()
	local punchDuration = 1.2
	local hasExploded = false
	
	local blockCFrame = selectedPart.CFrame
	local blockRotation = blockCFrame - blockCFrame.Position
	local basePos = selectedPart.Position
	local groundPos = selectedPart.Position + Vector3.new(0, -2, 0)
	
	wingsConnection = RunService.Heartbeat:Connect(function()
		if not selectedPart or not selectedPart.Parent then
			destroyFist()
			return
		end
		
		blockCFrame = selectedPart.CFrame
		blockRotation = blockCFrame - blockCFrame.Position
		basePos = selectedPart.Position
		groundPos = selectedPart.Position + Vector3.new(0, -2, 0)
		
		local elapsed = tick() - punchStartTime
		local progress = math.min(elapsed / punchDuration, 1)
		
		if progress < 0.3 then
			-- Windup: lift fist up
			local liftProgress = progress / 0.3
			local liftHeight = liftProgress * 15
			
			-- Move all parts up
			for finger, parts in pairs(fistParts) do
				for i, part in ipairs(parts) do
					if part and part.Parent then
						local targetPos = part.Position + Vector3.new(0, liftHeight * 0.5, 0)
						part.AssemblyLinearVelocity = (targetPos - part.Position) * 10
						part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
					end
				end
			end
			
		elseif progress < 0.7 then
			-- Punch down!
			local punchProgress = (progress - 0.3) / 0.4
			local punchHeight = 15 - (punchProgress * 25)
			
			for finger, parts in pairs(fistParts) do
				for i, part in ipairs(parts) do
					if part and part.Parent then
						local targetPos = basePos + Vector3.new(0, punchHeight, 0)
						part.AssemblyLinearVelocity = (targetPos - part.Position) * 20
						part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
					end
				end
			end
			
			-- Explode at impact
			if punchProgress > 0.7 and not hasExploded then
				hasExploded = true
				print("💥 GROUND PUNCH IMPACT!")
				
				-- Get all parts
				local allFistParts = {}
				for _, parts in pairs(fistParts) do
					for _, part in ipairs(parts) do
						table.insert(allFistParts, part)
					end
				end
				
				for _, part in ipairs(allFistParts) do
					if part and part.Parent then
						local directionFromImpact = (part.Position - groundPos).Unit
						local explosionForce = 150
						
						part.AssemblyLinearVelocity = directionFromImpact * explosionForce + Vector3.new(
							math.random(-30, 30),
							math.random(60, 120),
							math.random(-30, 30)
						)
						
						part.AssemblyAngularVelocity = Vector3.new(
							math.random(-20, 20),
							math.random(-20, 20),
							math.random(-20, 20)
						)
					end
				end
			end
		else
			if wingsConnection then
				wingsConnection:Disconnect()
			end
			createFist()
		end
	end)
end

-- ==================== HAND CONTROLLER MODE ====================
local function colorMatch(color, r, g, b, tolerance)
	tolerance = tolerance or 0.05
	return math.abs(color.R - r) < tolerance and
	       math.abs(color.G - g) < tolerance and
	       math.abs(color.B - b) < tolerance
end

local function findHandParts()
	print("🔍 Searching for hand parts by color...")
	
	for _, part in ipairs(workspace:GetDescendants()) do
		if part:IsA("BasePart") then
			local c = part.Color
			
			-- Pivot (Gray - 0.639, 0.635, 0.647)
			if colorMatch(c, 0.639, 0.635, 0.647) then
				handControllerParts.pivot = part
				setNetworkOwnership(part)
				print("✅ Found Pivot")
			
			-- Palm (Yellow/White - 1, 1, 0.8)
			elseif colorMatch(c, 1, 1, 0.8) then
				handControllerParts.palm = part
				setNetworkOwnership(part)
				print("✅ Found Palm")
			
			-- Thumb (Purple/Magenta - 0.667, 0, 0.667)
			elseif colorMatch(c, 0.667, 0, 0.667) then
				table.insert(handControllerParts.thumb, part)
				setNetworkOwnership(part)
			
			-- Pinky (Pink - 1, 0, 0.749)
			elseif colorMatch(c, 1, 0, 0.749) then
				table.insert(handControllerParts.pinky, part)
				setNetworkOwnership(part)
			
			-- Ring (Green - 0, 1, 0)
			elseif colorMatch(c, 0, 1, 0) then
				table.insert(handControllerParts.ring, part)
				setNetworkOwnership(part)
			
			-- Blue (Index or Middle - 0, 0, 1)
			elseif colorMatch(c, 0, 0, 1) then
				if part.Position.X < 13 then
					table.insert(handControllerParts.index, part)
				else
					table.insert(handControllerParts.middle, part)
				end
				setNetworkOwnership(part)
			end
		end
	end
	
	-- Sort by distance from palm
	if handControllerParts.palm then
		local palmPos = handControllerParts.palm.Position
		for _, segs in pairs({handControllerParts.thumb, handControllerParts.index, handControllerParts.middle, handControllerParts.ring, handControllerParts.pinky}) do
			table.sort(segs, function(a, b)
				return (a.Position - palmPos).Magnitude < (b.Position - palmPos).Magnitude
			end)
		end
	end
	
	local total = #handControllerParts.thumb + #handControllerParts.index + #handControllerParts.middle + #handControllerParts.ring + #handControllerParts.pinky
	print("✅ Found " .. total .. " finger segments")
	
	return handControllerParts.pivot ~= nil and handControllerParts.palm ~= nil
end

local function destroyHandController()
	if handControllerConnection then
		handControllerConnection:Disconnect()
		handControllerConnection = nil
	end
	
	-- Reset network ownership
	if handControllerParts.pivot then
		pcall(function() handControllerParts.pivot:SetNetworkOwnershipAuto() end)
	end
	if handControllerParts.palm then
		pcall(function() handControllerParts.palm:SetNetworkOwnershipAuto() end)
	end
	for _, segs in pairs({handControllerParts.thumb, handControllerParts.index, handControllerParts.middle, handControllerParts.ring, handControllerParts.pinky}) do
		for _, part in ipairs(segs) do
			pcall(function() part:SetNetworkOwnershipAuto() end)
		end
	end
	
	handControllerParts = {
		pivot = nil,
		palm = nil,
		thumb = {},
		index = {},
		middle = {},
		ring = {},
		pinky = {}
	}
	
	handFingerStates = {
		thumb = 1,
		index = 1,
		middle = 1,
		ring = 1,
		pinky = 1
	}
	
	handControllerMode = false
	handLabel.Text = "🖐️ HAND CONTROLLER: OFF | Pose: Open"
	handToggle.Text = "Create HAND CONTROLLER"
	handToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	print("❌ Hand controller destroyed")
end

local function createHandController()
	destroyHandController()
	
	if not findHandParts() then
		warn("❌ Could not find hand parts in workspace!")
		return
	end
	
	handControllerMode = true
	handLabel.Text = "🖐️ HAND CONTROLLER: ON | Pose: Open"
	handToggle.Text = "Destroy HAND CONTROLLER"
	handToggle.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
	print("✅ Hand controller created!")
	
	handControllerConnection = RunService.Heartbeat:Connect(function()
		if not handControllerParts.palm then
			destroyHandController()
			return
		end
		
		-- Get mouse position
		local mouseRay = camera:ScreenPointToRay(mouse.X, mouse.Y)
		local targetPos = camera.CFrame.Position + mouseRay.Direction * handDistance
		
		-- Move palm to target using physics
		if handControllerParts.palm and handControllerParts.palm.Parent then
			local direction = (targetPos - handControllerParts.palm.Position)
			handControllerParts.palm.AssemblyLinearVelocity = direction * 10
			handControllerParts.palm.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
		end
		
		-- Move pivot (if exists) to stay with palm
		if handControllerParts.pivot and handControllerParts.pivot.Parent and handControllerParts.palm then
			local pivotOffset = Vector3.new(0, 0, 0) -- Adjust if needed
			local pivotTarget = handControllerParts.palm.Position + pivotOffset
			local direction = (pivotTarget - handControllerParts.pivot.Position)
			handControllerParts.pivot.AssemblyLinearVelocity = direction * 10
			handControllerParts.pivot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
		end
		
		-- Move finger segments to follow palm
		local palmPos = handControllerParts.palm.Position
		for fingerName, segs in pairs({
			thumb = handControllerParts.thumb,
			index = handControllerParts.index,
			middle = handControllerParts.middle,
			ring = handControllerParts.ring,
			pinky = handControllerParts.pinky
		}) do
			for i, seg in ipairs(segs) do
				if seg and seg.Parent then
					-- Calculate finger position relative to palm
					local fingerProgress = i / #segs
					local baseOffset = Vector3.new(0, 0, 0)
					
					-- Different base positions for each finger
					if fingerName == "thumb" then
						baseOffset = Vector3.new(-2, 0, 0)
					elseif fingerName == "index" then
						baseOffset = Vector3.new(-1, 0, 1)
					elseif fingerName == "middle" then
						baseOffset = Vector3.new(0, 0, 1)
					elseif fingerName == "ring" then
						baseOffset = Vector3.new(1, 0, 1)
					elseif fingerName == "pinky" then
						baseOffset = Vector3.new(2, 0, 0.5)
					end
					
					-- Extend finger from base
					local extensionOffset = Vector3.new(0, fingerProgress * 3, 0)
					local targetSegPos = palmPos + baseOffset + extensionOffset
					
					local direction = (targetSegPos - seg.Position)
					seg.AssemblyLinearVelocity = direction * 10
					seg.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
				end
			end
		end
		
		-- Rotate to face camera
		local lookDir = (camera.CFrame.Position - handControllerParts.palm.Position).Unit
		local targetCF = CFrame.lookAt(handControllerParts.palm.Position, handControllerParts.palm.Position + lookDir)
		handControllerParts.palm.CFrame = targetCF * CFrame.Angles(math.rad(45), 0, 0)
		
		-- Apply current pose
		local pose = handPoses[currentHandPose]
		if pose then
			handFingerStates.thumb = pose.thumb
			handFingerStates.index = pose.index
			handFingerStates.middle = pose.middle
			handFingerStates.ring = pose.ring
			handFingerStates.pinky = pose.pinky
		end
		
		-- Apply finger curls
		local function applyCurl(segments, curl, fingerType)
			for i, seg in ipairs(segments) do
				if seg then
					local angle = (1 - curl) * 90
					local baseCF = seg.CFrame - seg.Position
					local rotCF
					
					if fingerType == "thumb" then
						rotCF = CFrame.Angles(0, 0, math.rad(angle))
					else
						rotCF = CFrame.Angles(math.rad(angle), 0, 0)
					end
					
					seg.CFrame = CFrame.new(seg.Position) * baseCF * rotCF
				end
			end
		end
		
		applyCurl(handControllerParts.thumb, handFingerStates.thumb, "thumb")
		applyCurl(handControllerParts.index, handFingerStates.index, "index")
		applyCurl(handControllerParts.middle, handFingerStates.middle, "middle")
		applyCurl(handControllerParts.ring, handFingerStates.ring, "ring")
		applyCurl(handControllerParts.pinky, handFingerStates.pinky, "pinky")
	end)
	
	print("✅ Hand controller active!")
end

local function destroyHammer()
	if hammerConnection then
		hammerConnection:Disconnect()
		hammerConnection = nil
	end
	
	for _, part in ipairs(hammerParts) do
		if part and part.Parent then
			pcall(function()
				part:SetNetworkOwnershipAuto()
			end)
		end
	end
	
	hammerParts = {}
	hammerMode = false
	hammerLabel.Text = "⚔️ HAMMER OF JUSTICE: OFF"
	hammerToggle.Text = "Create HAMMER OF JUSTICE"
	hammerToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
end

local function createHammer()
	if not selectedPart or not selectedPart.Parent then
		warn("No valid part selected!")
		return
	end
	
	destroyHammer()
	
	local allParts = {}
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") and obj ~= selectedPart then
			if isPartUnlocked(obj) and not obj.Anchored then
				-- Try to claim ownership first
				setNetworkOwnership(obj)
				-- Then check if we own it (if filter is enabled)
				if isOwnedByPlayer(obj) then
					table.insert(allParts, obj)
				end
			end
		end
	end
	
	if #allParts < 20 then
		warn("Not enough parts!")
		if networkOwnershipFilterMode then
			warn("🎯 Ownership filter is ON - only using parts you own. Try disabling it if needed.")
		end
		return
	end
	
	-- Sort by color if hammer color sort is enabled
	if hammerColorSort then
		table.sort(allParts, function(a, b)
			local function colorToHue(color)
				local r, g, b = color.R, color.G, color.B
				local max = math.max(r, g, b)
				local min = math.min(r, g, b)
				local h = 0
				
				if max == min then
					h = 0
				elseif max == r then
					h = (60 * ((g - b) / (max - min)) + 360) % 360
				elseif max == g then
					h = (60 * ((b - r) / (max - min)) + 120) % 360
				else
					h = (60 * ((r - g) / (max - min)) + 240) % 360
				end
				
				return h
			end
			
			return colorToHue(a.Color) < colorToHue(b.Color)
		end)
		print("🌈 Hammer color sorted!")
	end
	
	-- GERSON'S HAMMER design - chunkier, more detailed
	local hammerPositions = {}
	
	-- Handle: wooden shaft (thicker at bottom)
	for y = 0, 10 do
		local handleThickness = 0.6 + (y / 10) * 0.2 -- Gets slightly thicker toward head
		for x = -handleThickness, handleThickness, 1 do
			for z = -handleThickness, handleThickness, 1 do
				table.insert(hammerPositions, Vector3.new(x, y, z))
			end
		end
	end
	
	-- Hammer head base (thick rectangular block)
	for y = 11, 13 do
		for x = -6, 5, 1 do
			for z = -3, 2, 1 do
				table.insert(hammerPositions, Vector3.new(x, y, z))
			end
		end
	end
	
	-- Top striking surface (slightly wider)
	for y = 14, 16 do
		for x = -7, 6, 1 do
			for z = -3.5, 2.5, 1 do
				-- Create beveled edges
				if math.abs(x) > 5 or math.abs(z) > 2 then
					if y == 14 or y == 16 then
						table.insert(hammerPositions, Vector3.new(x, y, z))
					end
				else
					table.insert(hammerPositions, Vector3.new(x, y, z))
				end
			end
		end
	end
	
	-- Decorative spikes on top (Gerson style!)
	for i = -5, 4, 3 do
		table.insert(hammerPositions, Vector3.new(i, 17, 0))
		table.insert(hammerPositions, Vector3.new(i, 18, 0))
	end
	
	-- Side flanges (wings on the hammer head)
	for y = 12, 15 do
		for x = -8, -7, 1 do
			table.insert(hammerPositions, Vector3.new(x, y, 0))
		end
		for x = 6, 7, 1 do
			table.insert(hammerPositions, Vector3.new(x, y, 0))
		end
	end
	
	for i = 1, math.min(#hammerPositions, #allParts) do
		hammerParts[i] = allParts[i]
	end
	
	hammerMode = true
	hammerLabel.Text = "⚔️ GERSON'S HAMMER: ON (" .. #hammerParts .. " parts)"
	hammerToggle.Text = "Destroy Hammer"
	hammerToggle.BackgroundColor3 = Color3.fromRGB(120, 50, 50)
	
	local unusedParts = {}
	for i = #hammerParts + 1, #allParts do
		table.insert(unusedParts, allParts[i])
	end
	hammerStatue = {unusedParts = unusedParts, positions = hammerPositions}
	
	local startTime = tick()
	hammerConnection = RunService.Heartbeat:Connect(function()
		if not selectedPart or not selectedPart.Parent then
			destroyHammer()
			return
		end
		
		local time = tick() - startTime
		local floatHeight = math.sin(time * 1.5) * 1.5
		local rotationAngle = math.sin(time * 0.8) * 0.15
		
		local blockCFrame = selectedPart.CFrame
		local blockRotation = blockCFrame - blockCFrame.Position
		local basePos
		local cursorTilt = 0
		local cursorTiltZ = 0
		
		if hammerCursorMode then
			-- Follow cursor in 3D space
			local mouseRay = camera:ScreenPointToRay(mouse.X, mouse.Y)
			local targetPos = mouseRay.Origin + mouseRay.Direction * 30
			
			-- Calculate tilt toward cursor
			local directionToCursor = (targetPos - selectedPart.Position).Unit
			cursorTilt = math.atan2(directionToCursor.X, directionToCursor.Z)
			cursorTiltZ = -math.asin(directionToCursor.Y) * 0.5 -- Tilt forward/back
			
			basePos = targetPos + Vector3.new(0, 0, 0)
		else
			basePos = selectedPart.Position + blockCFrame.RightVector * 4 + Vector3.new(0, 8, 0)
		end
		
		for i, part in ipairs(hammerParts) do
			if part and part.Parent and hammerPositions[i] then
				local offset = hammerPositions[i]
				
				-- Apply 90 degree Y-axis rotation first
				local rotated90 = Vector3.new(-offset.Z, offset.Y, offset.X)
				
				-- Apply gentle rotation
				local rotatedX = rotated90.X * math.cos(rotationAngle) - rotated90.Z * math.sin(rotationAngle)
				local rotatedZ = rotated90.X * math.sin(rotationAngle) + rotated90.Z * math.cos(rotationAngle)
				local rotatedOffset = Vector3.new(rotatedX, rotated90.Y + floatHeight, rotatedZ)
				
				-- Apply cursor tilt if in cursor mode
				if hammerCursorMode then
					-- Tilt around Y axis (left/right)
					local tiltedX = rotatedOffset.X * math.cos(cursorTilt) - rotatedOffset.Z * math.sin(cursorTilt)
					local tiltedZ = rotatedOffset.X * math.sin(cursorTilt) + rotatedOffset.Z * math.cos(cursorTilt)
					
					-- Tilt around X axis (forward/back)
					local tiltedY = rotatedOffset.Y * math.cos(cursorTiltZ) - tiltedZ * math.sin(cursorTiltZ)
					local finalZ = rotatedOffset.Y * math.sin(cursorTiltZ) + tiltedZ * math.cos(cursorTiltZ)
					
					rotatedOffset = Vector3.new(tiltedX, tiltedY, finalZ)
				end
				
				local worldOffset = hammerCursorMode and rotatedOffset or (blockRotation * rotatedOffset)
				local targetPos = basePos + worldOffset
				
				local direction = (targetPos - part.Position)
				local distance = direction.Magnitude
				
				if distance > 0.1 then
					part.AssemblyLinearVelocity = direction.Unit * math.min(distance * 15, 60)
				else
					part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				end
				
				part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
			end
		end
		
		-- Unused parts orbit around hammer
		for i, part in ipairs(unusedParts) do
			if part and part.Parent then
				local angle = (i / #unusedParts) * math.pi * 2 + time * 0.5
				local radius = 12
				local orbitOffset = Vector3.new(
					math.cos(angle) * radius,
					math.sin(time * 2 + i) * 3,
					math.sin(angle) * radius
				)
				local unusedPos = basePos + (hammerCursorMode and orbitOffset or (blockRotation * orbitOffset))
				
				local direction = (unusedPos - part.Position)
				local distance = direction.Magnitude
				
				if distance > 0.5 then
					part.AssemblyLinearVelocity = direction.Unit * math.min(distance * 5, 30)
				else
					part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				end
				
				part.AssemblyAngularVelocity = Vector3.new(
					math.sin(time + i) * 2,
					math.cos(time + i) * 2,
					0
				)
			end
		end
	end)
end

local function smashHammer()
	if not hammerMode or #hammerParts == 0 then
		warn("Hammer not created!")
		return
	end
	
	if not selectedPart or not selectedPart.Parent then
		warn("Selected part no longer exists!")
		return
	end
	
	-- Find ground position at target location
	local targetWorldPos
	if hammerSmashTarget then
		targetWorldPos = hammerSmashTarget
		hammerSmashTarget = nil
	else
		-- Use character position if no target set
		targetWorldPos = selectedPart.Position
	end
	
	-- Raycast down to find actual ground
	local rayOrigin = targetWorldPos + Vector3.new(0, 50, 0)
	local rayDirection = Vector3.new(0, -200, 0)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {player.Character}
	
	local rayResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
	local groundPos = rayResult and rayResult.Position or (targetWorldPos + Vector3.new(0, -2, 0))
	
	print("🔨 GERSON'S HAMMER SMASH at " .. tostring(groundPos) .. "! 💥")
	
	if hammerConnection then
		hammerConnection:Disconnect()
		hammerConnection = nil
	end
	
	local smashStartTime = tick()
	local smashDuration = 1.5
	local hammerPositions = hammerStatue.positions
	local unusedParts = hammerStatue.unusedParts
	local hasExploded = false
	
	-- Calculate hammer starting position (above target)
	local hammerStartPos = groundPos + Vector3.new(0, 25, 0)
	
	hammerConnection = RunService.Heartbeat:Connect(function()
		if not selectedPart or not selectedPart.Parent then
			destroyHammer()
			return
		end
		
		local elapsed = tick() - smashStartTime
		local progress = math.min(elapsed / smashDuration, 1)
		
		if progress < 0.35 then
			-- Phase 1: WINDUP - Lift hammer up with slight tilt back
			local windupProgress = progress / 0.35
			local currentPos = hammerStartPos + Vector3.new(0, windupProgress * 10, 0)
			local windupBack = windupProgress * -5
			local tiltRotation = windupProgress * math.pi * 0.3 -- Small tilt back instead of spin
			
			for i, part in ipairs(hammerParts) do
				if part and part.Parent and hammerPositions[i] then
					local offset = hammerPositions[i]
					
					-- Apply 90 degree Y-axis rotation first
					local rotated90 = Vector3.new(-offset.Z, offset.Y, offset.X)
					
					-- Apply slight TILT rotation (not spin)
					local tiltX = rotated90.X * math.cos(tiltRotation) - rotated90.Y * math.sin(tiltRotation)
					local tiltY = rotated90.X * math.sin(tiltRotation) + rotated90.Y * math.cos(tiltRotation)
					
					local rotatedOffset = Vector3.new(
						tiltX, 
						tiltY, 
						rotated90.Z + windupBack
					)
					
					local partTargetPos = currentPos + rotatedOffset
					
					local direction = (partTargetPos - part.Position)
					part.AssemblyLinearVelocity = direction * 15
					
					-- Minimal angular velocity for stability
					part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
				end
			end
			
			-- Keep unused parts orbiting during windup
			for i, part in ipairs(unusedParts) do
				if part and part.Parent then
					local angle = (i / #unusedParts) * math.pi * 2 + elapsed * 2
					local radius = 12
					local orbitOffset = Vector3.new(
						math.cos(angle) * radius,
						math.sin(elapsed * 3 + i) * 4,
						math.sin(angle) * radius
					)
					local unusedPos = currentPos + orbitOffset
					
					local direction = (unusedPos - part.Position)
					part.AssemblyLinearVelocity = direction * 8
					part.AssemblyAngularVelocity = Vector3.new(
						math.sin(elapsed + i) * 4,
						math.cos(elapsed + i) * 4,
						0
					)
				end
			end
			
		elseif progress < 0.75 then
			-- Phase 2: SMASH DOWN - NO ROTATION, STRAIGHT SLAM!
			local smashProgress = (progress - 0.35) / 0.4
			
			-- Height goes from top to STOPPING AT GROUND
			local startHeight = 35
			local currentHeight = startHeight - (smashProgress * startHeight)
			
			-- Stop at ground level (add small offset so hammer head sits ON ground)
			local hammerHeadHeight = 8 -- approximate height of hammer head
			if currentHeight < hammerHeadHeight then
				currentHeight = hammerHeadHeight
			end
			
			local currentPos = groundPos + Vector3.new(0, currentHeight, 0)
			-- NO ROTATION - Keep hammer upright for slam!
			
			for i, part in ipairs(hammerParts) do
				if part and part.Parent and hammerPositions[i] then
					local offset = hammerPositions[i]
					
					-- Apply 90 degree Y-axis rotation ONLY (keep hammer upright)
					local rotated90 = Vector3.new(-offset.Z, offset.Y, offset.X)
					
					local partTargetPos = currentPos + rotated90
					
					local direction = (partTargetPos - part.Position)
					
					-- Fast slam down
					local speed = currentHeight > hammerHeadHeight and 50 or 20
					part.AssemblyLinearVelocity = direction * speed
					
					-- NO spinning - keep parts stable
					part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
				end
			end
			
			-- Pull unused parts toward impact zone
			if smashProgress > 0.3 then
				for i, part in ipairs(unusedParts) do
					if part and part.Parent then
						local direction = (groundPos - part.Position)
						part.AssemblyLinearVelocity = direction.Unit * 40
					end
				end
			end
			
			-- EXPLODE at impact (when hammer reaches ground)
			if currentHeight <= hammerHeadHeight + 0.5 and not hasExploded then
				hasExploded = true
				print("💥 GROUND IMPACT! " .. #unusedParts .. " parts exploding!")
				
				for _, part in ipairs(unusedParts) do
					if part and part.Parent then
						local directionFromImpact = (part.Position - groundPos).Unit
						local distance = (part.Position - groundPos).Magnitude
						local explosionForce = math.max(15, 1 - (distance / 100)) * 200
						
						part.AssemblyLinearVelocity = directionFromImpact * explosionForce + Vector3.new(
							math.random(-40, 40),
							math.random(80, 150),
							math.random(-40, 40)
						)
						
						part.AssemblyAngularVelocity = Vector3.new(
							math.random(-25, 25),
							math.random(-25, 25),
							math.random(-25, 25)
						)
					end
				end
			end
		else
			-- Phase 3: Hold at ground briefly, then return to normal
			if progress < 0.85 then
				-- Keep hammer at ground position
				local currentPos = groundPos + Vector3.new(0, 8, 0)
				
				for i, part in ipairs(hammerParts) do
					if part and part.Parent and hammerPositions[i] then
						local offset = hammerPositions[i]
						local rotated90 = Vector3.new(-offset.Z, offset.Y, offset.X)
						local partTargetPos = currentPos + rotated90
						
						local direction = (partTargetPos - part.Position)
						if direction.Magnitude > 0.1 then
							part.AssemblyLinearVelocity = direction * 5
						else
							part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
						end
						part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
					end
				end
			else
				-- Return to normal mode
				if hammerConnection then
					hammerConnection:Disconnect()
				end
				createHammer()
			end
		end
	end)
end

-- Position calculation for 50 shapes
local function calculatePosition(centerPos, angle, radius, height, time, index, total)
	local x, y, z = 0, 0, 0
	
	if orbitShape == "Circle" then
		x = math.cos(angle) * radius
		z = math.sin(angle) * radius
		y = height
		
	elseif orbitShape == "Sphere" then
		-- Use golden ratio for uniform sphere distribution
		local goldenRatio = (1 + math.sqrt(5)) / 2
		local theta = 2 * math.pi * index / goldenRatio
		local phi = math.acos(1 - 2 * (index / total))
		x = radius * math.sin(phi) * math.cos(theta)
		y = radius * math.cos(phi)
		z = radius * math.sin(phi) * math.sin(theta)
		
	elseif orbitShape == "Cube" then
		local side = math.floor((index - 1) / math.max(1, total / 6)) % 6
		local t = ((index - 1) % math.max(1, total / 6)) / math.max(1, total / 6)
		local size = radius
		
		if side == 0 then x, y, z = size, (t - 0.5) * 2 * size, math.sin(angle) * size
		elseif side == 1 then x, y, z = -size, (t - 0.5) * 2 * size, math.sin(angle) * size
		elseif side == 2 then x, y, z = (t - 0.5) * 2 * size, size, math.sin(angle) * size
		elseif side == 3 then x, y, z = (t - 0.5) * 2 * size, -size, math.sin(angle) * size
		elseif side == 4 then x, y, z = math.cos(angle) * size, (t - 0.5) * 2 * size, size
		else x, y, z = math.cos(angle) * size, (t - 0.5) * 2 * size, -size
		end
		
	elseif orbitShape == "Spiral" then
		x = math.cos(angle) * radius
		z = math.sin(angle) * radius
		y = (angle / (math.pi * 2)) * 10 + height
		
	elseif orbitShape == "Wave" then
		x = math.cos(angle) * radius
		z = math.sin(angle) * radius
		y = height + math.sin(angle * 3 + time * 2) * 5
		
	elseif orbitShape == "Helix" then
		x = math.cos(angle) * radius * 0.7
		z = math.sin(angle) * radius * 0.7
		y = (angle / (math.pi * 2)) * 15 - 7.5
		
	elseif orbitShape == "Figure8" then
		local scale = radius / 10
		x = math.sin(angle) * 10 * scale
		z = math.sin(angle * 2) * 10 * scale
		y = height
		
	elseif orbitShape == "Star" then
		local points = 5
		local r = (math.floor(angle * points / math.pi) % 2 == 0) and radius or radius * 0.5
		x = math.cos(angle) * r
		z = math.sin(angle) * r
		y = height
		
	elseif orbitShape == "Pentagon" then
		local perfectAngle = (math.floor(index % 5) / 5) * math.pi * 2
		x = math.cos(perfectAngle) * radius
		z = math.sin(perfectAngle) * radius
		y = height
		
	elseif orbitShape == "Hexagon" then
		local perfectAngle = (math.floor(index % 6) / 6) * math.pi * 2
		x = math.cos(perfectAngle) * radius
		z = math.sin(perfectAngle) * radius
		y = height
		
	elseif orbitShape == "Octagon" then
		local perfectAngle = (math.floor(index % 8) / 8) * math.pi * 2
		x = math.cos(perfectAngle) * radius
		z = math.sin(perfectAngle) * radius
		y = height
		
	elseif orbitShape == "Diamond" then
		local t = (index / total) * 4
		local section = math.floor(t)
		local progress = t - section
		
		if section == 0 then x, y = progress * radius, (1 - progress) * radius * 1.5
		elseif section == 1 then x, y = (1 - progress) * radius, -progress * radius * 1.5
		elseif section == 2 then x, y = -progress * radius, -(1 - progress) * radius * 1.5
		else x, y = -(1 - progress) * radius, progress * radius * 1.5
		end
		z = 0
		y = y + height
		
	elseif orbitShape == "Heart" then
		x = 16 * math.sin(angle)^3 * (radius / 20)
		z = (13 * math.cos(angle) - 5 * math.cos(2*angle) - 2 * math.cos(3*angle) - math.cos(4*angle)) * (radius / 20)
		y = height
		
	elseif orbitShape == "Infinity" then
		local scale = radius / 3
		x = scale * math.cos(angle) / (1 + math.sin(angle)^2)
		z = scale * math.cos(angle) * math.sin(angle) / (1 + math.sin(angle)^2)
		y = height
		
	elseif orbitShape == "Flower" then
		local r = radius * math.cos(6 * angle)
		x = r * math.cos(angle)
		z = r * math.sin(angle)
		y = height
		
	elseif orbitShape == "DNA" then
		local strand = (index % 2 == 0) and 1 or -1
		x = math.cos(angle + strand * math.pi) * radius * 0.5
		z = math.sin(angle + strand * math.pi) * radius * 0.5
		y = (angle / (math.pi * 2)) * 20 - 10
		
	elseif orbitShape == "Tornado" then
		local heightPos = (index / total) * 15 - 7.5
		local radiusAtHeight = radius * (1 - math.abs(heightPos) / 10)
		x = math.cos(angle + heightPos * 0.5) * radiusAtHeight
		z = math.sin(angle + heightPos * 0.5) * radiusAtHeight
		y = heightPos + height
		
	elseif orbitShape == "Galaxy" then
		local spiralAngle = angle + (index / total) * math.pi * 8
		local spiralRadius = radius * (0.3 + (index / total) * 0.7)
		x = math.cos(spiralAngle) * spiralRadius
		z = math.sin(spiralAngle) * spiralRadius
		y = height + math.sin(spiralAngle * 2) * 2
		
	elseif orbitShape == "Rings" then
		local ringIndex = math.floor((index - 1) / (total / 3))
		local ringRadius = radius * (0.5 + ringIndex * 0.3)
		x = math.cos(angle) * ringRadius
		z = math.sin(angle) * ringRadius
		y = height + ringIndex * 3
		
	elseif orbitShape == "Mobius" then
		local u = angle
		local v = ((index / total) - 0.5) * 0.4
		x = (radius * 0.8 + v * math.cos(u / 2)) * math.cos(u)
		y = v * math.sin(u / 2) + height
		z = (radius * 0.8 + v * math.cos(u / 2)) * math.sin(u)
		
	-- NEW 30 SHAPES START HERE!
	elseif orbitShape == "Trefoil" then
		-- Trefoil knot
		x = (math.sin(angle) + 2 * math.sin(2 * angle)) * radius * 0.3
		y = (math.cos(angle) - 2 * math.cos(2 * angle)) * radius * 0.3 + height
		z = -math.sin(3 * angle) * radius * 0.3
		
	elseif orbitShape == "Torus" then
		local majorR = radius * 0.7
		local minorR = radius * 0.3
		local u = angle
		local v = (index / total) * math.pi * 2
		x = (majorR + minorR * math.cos(v)) * math.cos(u)
		y = minorR * math.sin(v) + height
		z = (majorR + minorR * math.cos(v)) * math.sin(u)
		
	elseif orbitShape == "Klein" then
		-- Klein bottle
		local u = angle
		local v = (index / total) * math.pi * 2
		local r = 4 * (1 - math.cos(u) / 2)
		x = (6 * math.cos(u) * (1 + math.sin(u)) + r * math.cos(v + math.pi)) * radius * 0.1
		y = (16 * math.sin(u) + r * math.sin(v)) * radius * 0.1 + height
		z = r * math.cos(v) * radius * 0.1
		
	elseif orbitShape == "Hypercube" then
		-- 4D hypercube projected to 3D
		local w = math.sin(time * 0.5)
		local corners = {
			Vector3.new(1,1,1), Vector3.new(1,1,-1), Vector3.new(1,-1,1), Vector3.new(1,-1,-1),
			Vector3.new(-1,1,1), Vector3.new(-1,1,-1), Vector3.new(-1,-1,1), Vector3.new(-1,-1,-1)
		}
		local corner = corners[(index % 8) + 1]
		x = corner.X * radius * (1 + w * 0.3)
		y = corner.Y * radius * (1 + w * 0.3) + height
		z = corner.Z * radius * (1 + w * 0.3)
		
	elseif orbitShape == "Metatron" then
		-- Metatron's cube pattern
		local layer = math.floor((index - 1) / 6) % 3
		local pos = (index - 1) % 6
		local layerRadius = radius * (0.3 + layer * 0.3)
		local layerAngle = pos / 6 * math.pi * 2
		x = math.cos(layerAngle) * layerRadius
		z = math.sin(layerAngle) * layerRadius
		y = height + layer * 2 - 2
		
	elseif orbitShape == "Mandala" then
		-- Sacred mandala pattern
		local rings = 5
		local ring = math.floor((index - 1) / (total / rings)) % rings
		local ringRadius = radius * ((ring + 1) / rings)
		local petalAngle = angle + math.sin(ring * angle) * 0.5
		x = math.cos(petalAngle) * ringRadius
		z = math.sin(petalAngle) * ringRadius
		y = height + math.sin(ring + time) * 2
		
	elseif orbitShape == "Vortex" then
		-- Swirling vortex
		local depth = (index / total) * 15
		local swirl = angle + depth * 0.3
		local vortexRadius = radius * (1 - depth / 20)
		x = math.cos(swirl) * vortexRadius
		z = math.sin(swirl) * vortexRadius
		y = -depth + height
		
	elseif orbitShape == "Supernova" then
		-- Exploding supernova pattern
		local burst = math.sin(time * 2) * 0.5 + 1
		local rays = 12
		local rayAngle = math.floor(angle * rays / (math.pi * 2)) * (math.pi * 2 / rays)
		local rayDist = radius * burst * (0.5 + (index / total) * 0.5)
		x = math.cos(rayAngle) * rayDist
		z = math.sin(rayAngle) * rayDist
		y = height + math.random(-3, 3)
		
	elseif orbitShape == "Nebula" then
		-- Nebula cloud formation
		local cloudAngle = angle + math.sin(angle * 3) * 0.8
		local cloudRadius = radius * (0.7 + math.random() * 0.6)
		x = math.cos(cloudAngle) * cloudRadius
		z = math.sin(cloudAngle) * cloudRadius
		y = height + math.sin(angle * 5) * 4
		
	elseif orbitShape == "BlackHole" then
		-- Black hole gravitational lens effect
		local eventHorizon = radius * 0.2
		local distance = eventHorizon + (index / total) * radius * 0.8
		local distortAngle = angle + (1 / distance) * 2
		x = math.cos(distortAngle) * distance
		z = math.sin(distortAngle) * distance
		y = height + math.sin(angle * 10) * (distance / radius) * 2
		
	elseif orbitShape == "Atom" then
		-- Atomic orbital patterns
		local orbital = (index % 3)
		local orbitAngle = angle + orbital * (math.pi * 2 / 3)
		local tilt = orbital * math.pi / 3
		x = math.cos(orbitAngle) * radius
		y = math.sin(orbitAngle) * radius * math.sin(tilt) + height
		z = math.sin(orbitAngle) * radius * math.cos(tilt)
		
	elseif orbitShape == "Molecule" then
		-- Molecular structure
		local nodes = 6
		local node = math.floor((index - 1) / math.max(1, total / nodes)) % nodes
		local nodeAngle = node / nodes * math.pi * 2
		local bond = (index % math.max(1, total / nodes)) / math.max(1, total / nodes)
		x = math.cos(nodeAngle) * radius * (0.5 + bond * 0.5)
		z = math.sin(nodeAngle) * radius * (0.5 + bond * 0.5)
		y = height + math.sin(bond * math.pi) * 3
		
	elseif orbitShape == "Crystal" then
		-- Crystal lattice structure
		local layers = 5
		local layer = math.floor((index - 1) / (total / layers)) % layers
		local sides = 6
		local side = (index - 1) % sides
		x = math.cos(side / sides * math.pi * 2) * radius * (0.5 + layer * 0.1)
		z = math.sin(side / sides * math.pi * 2) * radius * (0.5 + layer * 0.1)
		y = layer * 2 + height - 4
		
	elseif orbitShape == "Fractal" then
		-- Sierpinski-inspired fractal
		local iterations = 4
		local iter = (index % iterations)
		local scale = math.pow(0.5, iter)
		x = math.cos(angle + iter) * radius * scale
		z = math.sin(angle + iter) * radius * scale
		y = height + iter * 3
		
	elseif orbitShape == "Fibonacci" then
		-- Fibonacci spiral
		local golden = (1 + math.sqrt(5)) / 2
		local fibAngle = index * golden * math.pi * 2
		local fibRadius = math.sqrt(index) * radius * 0.3
		x = math.cos(fibAngle) * fibRadius
		z = math.sin(fibAngle) * fibRadius
		y = height
		
	elseif orbitShape == "GoldenSpiral" then
		-- Golden ratio spiral
		local golden = (1 + math.sqrt(5)) / 2
		local progress = angle / (math.pi * 2)
		local spiralRadius = radius * math.pow(golden, progress * 2 - 1)
		x = math.cos(angle) * spiralRadius
		z = math.sin(angle) * spiralRadius
		y = height + progress * 5
		
	elseif orbitShape == "Lissajous" then
		-- Lissajous curve
		local a, b = 3, 4
		x = math.sin(a * angle + time) * radius
		y = math.cos(b * angle) * radius + height
		z = math.sin((a + b) * angle * 0.5) * radius * 0.5
		
	elseif orbitShape == "Butterfly" then
		-- Butterfly curve
		local t = angle
		local scale = radius * 0.1
		x = scale * math.sin(t) * (math.exp(math.cos(t)) - 2 * math.cos(4*t) - math.sin(t/12)^5)
		z = scale * math.cos(t) * (math.exp(math.cos(t)) - 2 * math.cos(4*t) - math.sin(t/12)^5)
		y = height
		
	elseif orbitShape == "Dragon" then
		-- Dragon curve approximation
		local segments = 8
		local seg = math.floor((index - 1) / (total / segments)) % segments
		local turn = (seg % 2 == 0) and 1 or -1
		local dragonAngle = angle + seg * math.pi / 4 * turn
		x = math.cos(dragonAngle) * radius * (seg / segments)
		z = math.sin(dragonAngle) * radius * (seg / segments)
		y = height + seg * 1.5
		
	elseif orbitShape == "Phoenix" then
		-- Phoenix wings rising
		local wing = (index % 2 == 0) and 1 or -1
		local wingSpread = (index / total) * radius
		local rise = math.sin((index / total) * math.pi) * radius * 0.8
		x = wing * wingSpread * math.cos(angle * 0.5)
		z = wingSpread * math.sin(angle)
		y = height + rise
		
	elseif orbitShape == "Serpent" then
		-- Serpentine wave
		local segments = 10
		local progress = (index / total)
		local serpentAngle = progress * math.pi * 4
		x = math.cos(angle) * radius
		z = math.sin(angle) * radius
		y = height + math.sin(serpentAngle + time * 2) * 5
		
	elseif orbitShape == "Crown" then
		-- Royal crown with peaks
		local peaks = 8
		local peak = math.floor(angle / (math.pi * 2 / peaks))
		local peakHeight = (peak % 2 == 0) and radius * 0.3 or 0
		x = math.cos(angle) * radius
		z = math.sin(angle) * radius
		y = height + peakHeight + 3
		
	elseif orbitShape == "Lotus" then
		-- Lotus flower petals
		local petals = 8
		local petal = (index % petals)
		local petalAngle = petal / petals * math.pi * 2
		local petalRadius = radius * (0.5 + math.sin(angle * 3 + petal) * 0.5)
		x = math.cos(petalAngle) * petalRadius
		z = math.sin(petalAngle) * petalRadius
		y = height + math.sin((index / total) * math.pi) * 3
		
	elseif orbitShape == "Web" then
		-- Spider web pattern
		local rings = 6
		local ring = math.floor((index - 1) / (total / rings)) % rings
		local spokes = 8
		local spoke = angle * spokes / (math.pi * 2)
		local webRadius = radius * ((ring + 1) / rings)
		x = math.cos(angle) * webRadius
		z = math.sin(angle) * webRadius
		y = height + math.sin(spoke) * 1
		
	elseif orbitShape == "Grid" then
		-- 3D Grid formation
		local gridSize = math.ceil(math.pow(total, 1/3))
		local ix = (index - 1) % gridSize
		local iy = math.floor((index - 1) / gridSize) % gridSize
		local iz = math.floor((index - 1) / (gridSize * gridSize))
		local spacing = (radius * 2) / gridSize
		x = (ix - gridSize/2) * spacing
		y = (iy - gridSize/2) * spacing + height
		z = (iz - gridSize/2) * spacing
		
	elseif orbitShape == "Tesseract" then
		-- 4D tesseract rotation
		local w1 = math.sin(time * 0.5)
		local w2 = math.cos(time * 0.5)
		local corners = 16
		local corner = (index - 1) % corners
		local ix = (corner % 2) * 2 - 1
		local iy = (math.floor(corner / 2) % 2) * 2 - 1
		local iz = (math.floor(corner / 4) % 2) * 2 - 1
		local iw = (math.floor(corner / 8) % 2) * 2 - 1
		x = ix * radius * (1 + iw * w1 * 0.3)
		y = iy * radius * (1 + iw * w2 * 0.3) + height
		z = iz * radius * (1 + iw * w1 * 0.3)
		
	elseif orbitShape == "Slinky" then
		-- Slinky coil
		local coils = 5
		local coilProgress = (index / total) * coils
		local coilAngle = coilProgress * math.pi * 2
		x = math.cos(coilAngle) * radius * 0.6
		z = math.sin(coilAngle) * radius * 0.6
		y = height + coilProgress * 3 - 7.5
		
	elseif orbitShape == "Coil" then
		-- Tight electromagnetic coil
		local turns = 20
		local turnProgress = (index / total) * turns
		x = math.cos(turnProgress * math.pi * 2) * radius * 0.5
		z = math.sin(turnProgress * math.pi * 2) * radius * 0.5
		y = height + (turnProgress / turns) * 15 - 7.5
		
	elseif orbitShape == "Chain" then
		-- Chain link pattern
		local links = 8
		local link = math.floor((index - 1) / math.max(1, total / links)) % links
		local linkAngle = link / links * math.pi * 2
		local linkPos = (index % math.max(1, total / links)) / math.max(1, total / links)
		local linkRadius = radius * (0.8 + math.sin(linkPos * math.pi * 2) * 0.2)
		x = math.cos(linkAngle) * linkRadius
		z = math.sin(linkAngle) * linkRadius
		y = height + math.sin(linkPos * math.pi) * 2
		
	elseif orbitShape == "Constellation" then
		-- Star constellation pattern
		local clusters = 5
		local cluster = math.floor((index - 1) / (total / clusters)) % clusters
		local clusterAngle = cluster / clusters * math.pi * 2
		local starDist = radius * (0.3 + math.random() * 0.7)
		local starAngle = angle + math.random() * math.pi * 0.5
		x = math.cos(clusterAngle + starAngle) * starDist
		z = math.sin(clusterAngle + starAngle) * starDist
		y = height + math.random(-3, 3)
		
	-- UNDERTALE/DELTARUNE SHAPES! 💙
	elseif orbitShape == "Soul" then
		-- Heart-shaped SOUL (like the player's SOUL)
		local t = angle
		local soulScale = radius * 0.08
		x = soulScale * 16 * math.sin(t)^3
		z = soulScale * (13 * math.cos(t) - 5 * math.cos(2*t) - 2 * math.cos(3*t) - math.cos(4*t))
		y = height + math.sin(time * 2) * 1.5 -- Gentle floating
		
	elseif orbitShape == "Determination" then
		-- Striped barrier pattern (like the SAVE point barriers)
		local stripes = 8
		local stripe = math.floor((index - 1) / (total / stripes)) % stripes
		local stripeHeight = stripe * 2 - 7
		local stripeRadius = radius * (0.7 + (stripe % 2) * 0.3)
		x = math.cos(angle + stripe * 0.3) * stripeRadius
		z = math.sin(angle + stripe * 0.3) * stripeRadius
		y = height + stripeHeight + math.sin(time * 3 + stripe) * 0.5
		
	elseif orbitShape == "Delta" then
		-- Delta Rune triangle formation
		local triangles = 3
		local tri = math.floor((index - 1) / math.max(1, total / triangles)) % triangles
		local triAngle = tri / triangles * math.pi * 2 - math.pi / 2
		local triProgress = ((index - 1) % math.max(1, total / triangles)) / math.max(1, total / triangles)
		
		-- Create triangle edges
		local corner = math.floor(triProgress * 3)
		local edgeProgress = (triProgress * 3) % 1
		
		local corners = {
			Vector3.new(0, radius, 0),
			Vector3.new(radius * math.cos(math.pi / 6), -radius * 0.5, radius * math.sin(math.pi / 6)),
			Vector3.new(radius * math.cos(math.pi * 7 / 6), -radius * 0.5, radius * math.sin(math.pi * 7 / 6))
		}
		
		local nextCorner = (corner + 1) % 3 + 1
		local pos = corners[corner + 1]:Lerp(corners[nextCorner], edgeProgress)
		
		x = pos.X * math.cos(time * 0.5) - pos.Z * math.sin(time * 0.5)
		y = pos.Y + height
		z = pos.X * math.sin(time * 0.5) + pos.Z * math.cos(time * 0.5)
		
	elseif orbitShape == "Gaster" then
		-- Mysterious scattered pattern (Gaster/Wingdings style)
		local scatter = math.random() * radius * 1.5
		local scatterAngle = angle + math.random() * math.pi * 2
		local flicker = (math.sin(time * 10 + index) > 0.3) and 1 or 0
		x = math.cos(scatterAngle) * scatter * flicker
		z = math.sin(scatterAngle) * scatter * flicker
		y = height + math.random(-5, 5) * flicker
		
	elseif orbitShape == "Bullet" then
		-- Bullet hell danmaku patterns
		local waves = 4
		local wave = math.floor((index - 1) / (total / waves)) % waves
		local waveAngle = angle + wave * (math.pi * 2 / waves)
		local bulletSpeed = time * 3
		local bulletRadius = radius * (0.5 + (bulletSpeed % 1) * 0.5)
		x = math.cos(waveAngle + bulletSpeed) * bulletRadius
		z = math.sin(waveAngle + bulletSpeed) * bulletRadius
		y = height + math.sin(waveAngle * 3 + bulletSpeed) * 4
		
	elseif orbitShape == "Chaos" then
		-- Chaos King / Spade King chaotic spider pattern
		local legs = 6
		local leg = math.floor((index - 1) / math.max(1, total / legs)) % legs
		local legAngle = leg / legs * math.pi * 2
		local legProgress = ((index - 1) % math.max(1, total / legs)) / math.max(1, total / legs)
		
		-- Spider leg curve
		local legReach = radius * (0.3 + legProgress * 0.7)
		local legCurve = math.sin(legProgress * math.pi) * radius * 0.3
		local chaosWave = math.sin(time * 4 + leg) * 2
		
		x = math.cos(legAngle) * legReach + math.sin(legProgress * math.pi * 2) * legCurve
		z = math.sin(legAngle) * legReach + math.cos(legProgress * math.pi * 2) * legCurve
		y = height + legProgress * 5 - 2.5 + chaosWave
		
	-- STAR GLITCHER REVITALIZED SHAPES! ✨🌟💫
	elseif orbitShape == "Astral" then
		-- Green magic circles with upward energy beam
		local rings = 4
		local ring = math.floor((index - 1) / (total / rings)) % rings
		local ringRadius = radius * (0.3 + ring * 0.2)
		local ringAngle = angle + ring * 0.5 + time * (1 + ring * 0.3)
		
		x = math.cos(ringAngle) * ringRadius
		z = math.sin(ringAngle) * ringRadius
		y = height - 3 + ring * 0.5 + math.sin(time * 3 + ring) * 0.3
		
	elseif orbitShape == "Celestial" then
		-- Purple/pink cosmic circles with star burst
		local layers = 5
		local layer = math.floor((index - 1) / (total / layers)) % layers
		
		if layer < 3 then
			-- Inner rotating circles
			local circleRadius = radius * (0.2 + layer * 0.25)
			local circleAngle = angle * (1 + layer * 0.3) + time * 2
			x = math.cos(circleAngle) * circleRadius
			z = math.sin(circleAngle) * circleRadius
			y = height - 2 + layer * 0.5
		else
			-- Outer star burst rays
			local rayAngle = angle + (layer - 3) * (math.pi * 2 / 8)
			local rayDist = radius * (0.5 + math.sin(time * 4) * 0.3)
			x = math.cos(rayAngle) * rayDist
			z = math.sin(rayAngle) * rayDist
			y = height + math.sin(time * 3 + layer) * 2
		end
		
	elseif orbitShape == "Divine" then
		-- Holy light pillars reaching skyward
		local pillars = 8
		local pillar = math.floor((index - 1) / math.max(1, total / pillars)) % pillars
		local pillarAngle = pillar / pillars * math.pi * 2
		local pillarHeight = ((index - 1) % math.max(1, total / pillars)) / math.max(1, total / pillars)
		
		local pillarRadius = radius * (0.6 + math.sin(time * 2 + pillar) * 0.2)
		x = math.cos(pillarAngle) * pillarRadius
		z = math.sin(pillarAngle) * pillarRadius
		y = height + pillarHeight * 15 + math.sin(time * 3 + pillar + pillarHeight * 5) * 2
		
	elseif orbitShape == "Spectrum" then
		-- Rainbow shifting magic circles (works great with color sorting!)
		local waves = 6
		local wave = math.floor((index - 1) / (total / waves)) % waves
		local waveAngle = angle + wave * (math.pi / 3) + time
		local waveRadius = radius * (0.4 + wave * 0.1)
		
		x = math.cos(waveAngle) * waveRadius
		z = math.sin(waveAngle) * waveRadius
		y = height - 2 + math.sin(waveAngle * 3 + time * 2) * 3
		
	elseif orbitShape == "Stellar" then
		-- Orbiting stars around magic circles
		local orbits = 3
		local orbit = math.floor((index - 1) / (total / orbits)) % orbits
		local orbitAngle = angle * (2 + orbit) + time * (1 + orbit * 0.5)
		local orbitRadius = radius * (0.4 + orbit * 0.25)
		
		-- Add secondary rotation for star effect
		local starAngle = time * 5 + index
		local starOffset = 1.5
		x = math.cos(orbitAngle) * orbitRadius + math.cos(starAngle) * starOffset
		z = math.sin(orbitAngle) * orbitRadius + math.sin(starAngle) * starOffset
		y = height + math.sin(orbitAngle * 2) * 2
		
	elseif orbitShape == "Runic" then
		-- Ancient rune circle patterns
		local runes = 12
		local rune = math.floor((index - 1) / math.max(1, total / runes)) % runes
		local runeAngle = rune / runes * math.pi * 2 + time * 0.5
		local runeRadius = radius * (0.7 + math.sin(time * 2 + rune) * 0.15)
		
		-- Create runic symbols in circular pattern
		local symbolOffset = ((index - 1) % math.max(1, total / runes)) / math.max(1, total / runes) * 2 - 1
		x = math.cos(runeAngle) * runeRadius + math.sin(runeAngle) * symbolOffset * 0.5
		z = math.sin(runeAngle) * runeRadius - math.cos(runeAngle) * symbolOffset * 0.5
		y = height - 1 + math.abs(symbolOffset) * 2
		
	elseif orbitShape == "Eclipse" then
		-- Eclipse shadow and light effect
		local crescents = 2
		local crescent = (index % crescents)
		local crescentAngle = angle + crescent * math.pi + time
		
		-- Create crescent moon shapes
		local innerRadius = radius * 0.5
		local outerRadius = radius * 0.8
		local blend = (math.sin(angle * 8) + 1) / 2
		local eclipseRadius = innerRadius + (outerRadius - innerRadius) * blend
		
		x = math.cos(crescentAngle) * eclipseRadius
		z = math.sin(crescentAngle) * eclipseRadius
		y = height + math.sin(crescentAngle * 3 + time * 2) * 2
		
	elseif orbitShape == "Ethereal" then
		-- Floating ethereal wisps and particles
		local wisps = 5
		local wisp = math.floor((index - 1) / (total / wisps)) % wisps
		local wispAngle = angle + wisp * (math.pi * 2 / wisps) + math.sin(time + wisp) * 0.5
		local wispRadius = radius * (0.3 + math.sin(time * 2 + wisp) * 0.4)
		
		-- Floating motion
		x = math.cos(wispAngle) * wispRadius + math.sin(time * 3 + wisp) * 2
		z = math.sin(wispAngle) * wispRadius + math.cos(time * 2.5 + wisp) * 2
		y = height + math.sin(time * 1.5 + wisp + index * 0.1) * 4
		
	-- 🔥 60 NEW MEGA SHAPES START HERE! 🔥
	
	-- GEOMETRY SHAPES
	elseif orbitShape == "Dodecagon" then
		-- 12-sided polygon
		local sides = 12
		local sideAngle = angle + time * 0.5
		local dodecRadius = radius * 0.8
		x = math.cos(sideAngle) * dodecRadius
		z = math.sin(sideAngle) * dodecRadius
		y = height + math.sin(time * 2 + angle) * 1
		
	elseif orbitShape == "Icosahedron" then
		-- 20-faced polyhedron
		local phi = (1 + math.sqrt(5)) / 2
		local icoAngle = angle * 2 + time
		x = math.cos(icoAngle) * radius * 0.8
		z = math.sin(icoAngle) * radius * 0.8
		y = height + math.sin(icoAngle * 2) * radius * 0.5 + math.cos(time * 3) * 2
		
	elseif orbitShape == "Rhomboid" then
		-- Diamond-shaped 3D lattice
		local layer = math.floor(angle / (math.pi / 2)) % 4
		local layerAngle = angle * 1.5 + time
		local rhombRadius = radius * 0.7
		x = math.cos(layerAngle) * rhombRadius + math.sin(time * 2) * 2
		z = math.sin(layerAngle) * rhombRadius + math.cos(time * 2) * 2
		y = height + (layer - 2) * 3 + math.sin(time * 3 + layer) * 1.5
		
	elseif orbitShape == "Prism" then
		-- Triangular prism formation
		local prismAngle = angle + time * 0.5
		local prismRadius = radius * 0.7
		local prismSide = math.floor(angle / (math.pi * 2 / 3)) % 3
		x = math.cos(prismAngle) * prismRadius
		z = math.sin(prismAngle) * prismRadius
		y = height + math.sin(angle * 3) * 2
		
	elseif orbitShape == "Pyramid" then
		-- Egyptian pyramid layers
		local pyramidAngle = angle + time * 0.3
		local pyramidHeight = (index - 1) / math.max(total, 1)
		local levelRadius = radius * (1 - pyramidHeight) * 0.9
		x = math.cos(pyramidAngle) * levelRadius
		z = math.sin(pyramidAngle) * levelRadius
		y = height - 5 + pyramidHeight * 10
		
	elseif orbitShape == "Octahedron" then
		-- 8-faced diamond shape
		local octaAngle = angle + time
		local octaRadius = radius * 0.7
		local hemisphere = (math.sin(angle * 4) > 0) and 1 or -1
		x = math.cos(octaAngle) * octaRadius
		z = math.sin(octaAngle) * octaRadius
		y = height + hemisphere * (3 + math.sin(time * 2) * 1)
		
	elseif orbitShape == "Tetrahedron" then
		-- 4-faced triangular pyramid
		local tetraAngle = angle + time * 0.5
		local tetraRadius = radius * 0.8
		local vertex = math.floor(angle / (math.pi / 2)) % 4
		if vertex < 3 then
			x = math.cos(tetraAngle) * tetraRadius
			z = math.sin(tetraAngle) * tetraRadius
			y = height - 2
		else
			x = math.sin(time * 3) * 2
			z = math.cos(time * 3) * 2
			y = height + 4 + math.sin(time * 3) * 1
		end
		
	elseif orbitShape == "Tesseract4D" then
		-- 4D hypercube projection
		local cubes = 2
		local cube = (index - 1) % cubes
		local cubeAngle = angle + cube * math.pi + time
		local innerRadius = radius * 0.5
		local outerRadius = radius * 0.9
		local cubeRadius = (cube == 0) and innerRadius or outerRadius
		local w = math.sin(time * 2 + index * 0.1) -- 4th dimension
		x = math.cos(cubeAngle) * cubeRadius * (1 + w * 0.3)
		z = math.sin(cubeAngle) * cubeRadius * (1 + w * 0.3)
		y = height + math.sin(cubeAngle * 2 + time) * 3 * (1 + w * 0.2)
		
	-- ORGANIC CREATURES
	elseif orbitShape == "Dragon" then
		-- Serpentine dragon body with wings
		local segments = 20
		local segment = (index - 1) % segments
		local dragonTime = time * 2 + segment * 0.3
		local spineRadius = radius * 0.3
		-- Serpentine body
		x = math.cos(dragonTime) * spineRadius + math.sin(segment * 0.5) * 3
		z = math.sin(dragonTime) * spineRadius + math.cos(segment * 0.5) * 3
		y = height + math.sin(segment * 0.4 + time * 3) * 4 + segment * 0.2
		-- Wing extensions
		if segment % 5 == 0 then
			local wingSpread = math.sin(time * 5) * 5
			x = x + wingSpread
		end
		
	elseif orbitShape == "Phoenix" then
		-- Rising phoenix with flame trail
		local tailLength = 15
		local tailSegment = (index - 1) % tailLength
		local phoenixAngle = time * 3 + tailSegment * 0.2
		local phoenixRadius = radius * (0.4 + math.sin(time * 2) * 0.3)
		-- Spiral upward motion
		x = math.cos(phoenixAngle) * phoenixRadius
		z = math.sin(phoenixAngle) * phoenixRadius
		y = height + tailSegment * 0.8 + math.sin(time * 4 + tailSegment) * 2
		-- Wing flaps
		if tailSegment < 3 then
			local wingFlap = math.sin(time * 6) * 4
			x = x + wingFlap * math.cos(phoenixAngle)
			z = z + wingFlap * math.sin(phoenixAngle)
		end
		
	elseif orbitShape == "Kraken" then
		-- Tentacle monster with 8 arms
		local tentacles = 8
		local segments = 12
		local tentacle = math.floor((index - 1) / math.max(1, segments)) % tentacles
		local segment = (index - 1) % segments
		local tentacleAngle = tentacle / tentacles * math.pi * 2 + time * 0.5
		local tentacleRadius = radius * 0.4 + segment * 0.3
		-- Writhing tentacle motion
		local writhe = math.sin(time * 3 + segment * 0.5 + tentacle) * 2
		x = math.cos(tentacleAngle) * tentacleRadius + writhe
		z = math.sin(tentacleAngle) * tentacleRadius + writhe * 0.7
		y = height - 3 + math.sin(segment * 0.4 + time * 2) * 3
		
	elseif orbitShape == "Leviathan" then
		-- Massive sea serpent coils
		local coils = 8
		local coil = math.floor((index - 1) / math.max(1, total / coils)) % coils
		local coilAngle = angle + coil * (math.pi / 4) + time * 1.5
		local coilRadius = radius * (0.6 + math.sin(time + coil) * 0.3)
		-- Undulating sea motion
		x = math.cos(coilAngle) * coilRadius
		z = math.sin(coilAngle) * coilRadius
		y = height + math.sin(coilAngle * 3 + time * 2) * 5 + math.cos(time * 1.5 + coil) * 2
		
	elseif orbitShape == "Hydra" then
		-- Multi-headed serpent (7 heads)
		local heads = 7
		local head = math.floor((index - 1) / math.max(1, total / heads)) % heads
		local headAngle = head / heads * math.pi * 2 + time * 0.8
		local headRadius = radius * 0.7
		local neckLength = ((index - 1) % math.max(1, total / heads)) / math.max(1, total / heads)
		-- Each head sways independently
		local sway = math.sin(time * 3 + head * 0.7) * 3
		x = math.cos(headAngle) * (headRadius + neckLength * 3) + sway
		z = math.sin(headAngle) * (headRadius + neckLength * 3) + sway * 0.5
		y = height + neckLength * 6 + math.sin(time * 2 + head) * 2
		
	elseif orbitShape == "Butterfly" then
		-- Butterfly with flapping wings
		local wingBeats = math.sin(time * 8) * 0.5 + 0.5
		local bodySegments = 8
		local segment = (index - 1) % bodySegments
		local side = math.floor((index - 1) / bodySegments) % 2
		local butterflyAngle = time * 2 + segment * 0.2
		-- Body center
		x = math.sin(butterflyAngle) * radius * 0.3
		z = math.cos(butterflyAngle) * radius * 0.3
		-- Wings
		if side == 0 then
			x = x + (3 + segment * 0.5) * wingBeats
		else
			x = x - (3 + segment * 0.5) * wingBeats
		end
		y = height + math.sin(time * 3 + segment) * 2 + segment * 0.3
		
	elseif orbitShape == "Spider" then
		-- 8-legged spider with body
		local legs = 8
		local leg = math.floor((index - 1) / math.max(1, total / legs)) % legs
		local legAngle = leg / legs * math.pi * 2 + time * 0.3
		local legSegment = ((index - 1) % math.max(1, total / legs)) / math.max(1, total / legs)
		local legRadius = radius * (0.3 + legSegment * 0.6)
		-- Crawling motion
		local crawl = math.sin(time * 4 + leg * 0.5) * 0.5
		x = math.cos(legAngle) * legRadius
		z = math.sin(legAngle) * legRadius
		y = height - 2 + math.abs(math.sin(time * 4 + leg)) * 2 + crawl
		
	elseif orbitShape == "Jellyfish" then
		-- Pulsing jellyfish bell with tentacles
		local tentacles = 12
		local tentacle = math.floor((index - 1) / math.max(1, total / tentacles)) % tentacles
		local tentacleAngle = tentacle / tentacles * math.pi * 2 + time * 0.5
		local tentacleLength = ((index - 1) % math.max(1, total / tentacles)) / math.max(1, total / tentacles)
		local pulse = math.sin(time * 3) * 0.3 + 0.7
		-- Bell pulsing
		if tentacleLength < 0.3 then
			local bellRadius = radius * 0.5 * pulse
			x = math.cos(tentacleAngle) * bellRadius
			z = math.sin(tentacleAngle) * bellRadius
			y = height + 3
		else
			-- Trailing tentacles
			local tentacleRadius = radius * 0.3 + math.sin(time * 2 + tentacle) * 0.2
			x = math.cos(tentacleAngle) * tentacleRadius
			z = math.sin(tentacleAngle) * tentacleRadius
			y = height + 3 - tentacleLength * 8 + math.sin(time * 4 + tentacle + tentacleLength * 5) * 2
		end
		
	-- COSMIC PHENOMENA
	elseif orbitShape == "Nebula" then
		-- Swirling gas cloud
		local clouds = 6
		local cloud = math.floor((index - 1) / math.max(1, total / clouds)) % clouds
		local cloudAngle = angle + cloud * 0.8 + time * 0.3
		local cloudRadius = radius * (0.4 + math.random() * 0.5)
		-- Chaotic swirl
		x = math.cos(cloudAngle) * cloudRadius + math.sin(time * 2 + cloud) * 3
		z = math.sin(cloudAngle) * cloudRadius + math.cos(time * 1.5 + cloud) * 3
		y = height + math.sin(cloudAngle * 2 + time) * 4 + math.random(-2, 2)
		
	elseif orbitShape == "Supernova" then
		-- Explosive expanding shell
		local shells = 5
		local shell = math.floor((index - 1) / math.max(1, total / shells)) % shells
		local expansion = 1 + shell * 0.3 + math.sin(time * 2) * 0.4
		local supernovaAngle = angle + time * (1 + shell * 0.2)
		local supernovaRadius = radius * expansion
		x = math.cos(supernovaAngle) * supernovaRadius
		z = math.sin(supernovaAngle) * supernovaRadius
		y = height + math.sin(supernovaAngle * 3 + time * 2) * 3 * expansion
		
	elseif orbitShape == "Pulsar" then
		-- Rotating beam lighthouse effect
		local beams = 4
		local beam = math.floor((index - 1) / math.max(1, total / beams)) % beams
		local beamAngle = beam / beams * math.pi * 2 + time * 5
		local beamLength = ((index - 1) % math.max(1, total / beams)) / math.max(1, total / beams)
		local pulsarRadius = radius * (0.2 + beamLength * 0.9)
		-- Rotating beams
		x = math.cos(beamAngle) * pulsarRadius
		z = math.sin(beamAngle) * pulsarRadius
		y = height + math.sin(time * 10 + beam) * 2
		
	elseif orbitShape == "Quasar" then
		-- Energetic jets from center
		local jets = 2
		local jet = (index - 1) % jets
		local jetAngle = jet * math.pi + time * 0.5
		local jetDistance = ((index - 1) / total) * radius * 1.5
		-- Opposing jets
		x = math.cos(jetAngle) * radius * 0.3 + math.sin(time * 3 + index * 0.1) * 2
		z = math.sin(jetAngle) * radius * 0.3 + math.cos(time * 2.5 + index * 0.1) * 2
		y = height + (jet == 0 and jetDistance or -jetDistance) + math.sin(time * 4) * 1
		
	elseif orbitShape == "Wormhole" then
		-- Spiraling tunnel effect
		local spirals = 8
		local spiral = math.floor((index - 1) / math.max(1, total / spirals)) % spirals
		local spiralProgress = ((index - 1) % math.max(1, total / spirals)) / math.max(1, total / spirals)
		local wormholeAngle = spiral / spirals * math.pi * 2 + spiralProgress * math.pi * 4 + time * 2
		local wormholeRadius = radius * (0.3 + spiralProgress * 0.6) * (1 + math.sin(time * 3) * 0.2)
		x = math.cos(wormholeAngle) * wormholeRadius
		z = math.sin(wormholeAngle) * wormholeRadius
		y = height + (spiralProgress - 0.5) * 10
		
	elseif orbitShape == "Blackhole" then
		-- Accretion disk with gravitational lensing
		local rings = 6
		local ring = math.floor((index - 1) / math.max(1, total / rings)) % rings
		local ringAngle = angle * (1 + ring * 0.4) + time * (2 - ring * 0.2)
		local ringRadius = radius * (0.3 + ring * 0.15)
		-- Gravitational distortion
		local distortion = math.sin(time * 3 + ring) * 0.3
		x = math.cos(ringAngle) * ringRadius * (1 + distortion)
		z = math.sin(ringAngle) * ringRadius * (1 + distortion)
		y = height + math.sin(ringAngle * 4) * (1 - ring * 0.15) + math.cos(time * 2) * ring * 0.5
		
	elseif orbitShape == "Constellation" then
		-- Star pattern connections
		local stars = 12
		local star = (index - 1) % stars
		local constellationAngle = star / stars * math.pi * 2 + time * 0.2
		local constellationRadius = radius * (0.6 + math.sin(star * 0.7) * 0.3)
		-- Twinkling stars
		local twinkle = math.sin(time * 5 + star) * 0.5
		x = math.cos(constellationAngle) * constellationRadius + twinkle
		z = math.sin(constellationAngle) * constellationRadius + twinkle * 0.7
		y = height + math.sin(star * 0.5) * 4 + math.cos(time * 2 + star) * 1
		
	-- FANTASY STRUCTURES
	elseif orbitShape == "Castle" then
		-- Medieval castle with towers
		local towers = 4
		local tower = math.floor((index - 1) / math.max(1, total / towers)) % towers
		local towerAngle = tower / towers * math.pi * 2
		local towerHeight = ((index - 1) % math.max(1, total / towers)) / math.max(1, total / towers)
		local castleRadius = radius * 0.7
		-- Corner towers
		x = math.cos(towerAngle) * castleRadius
		z = math.sin(towerAngle) * castleRadius
		y = height - 3 + towerHeight * 10
		-- Walls between towers
		if towerHeight < 0.6 then
			local wallProgress = (index % 3) / 3
			x = x + (math.cos(towerAngle + math.pi / 2) * castleRadius * 0.5) * wallProgress
			z = z + (math.sin(towerAngle + math.pi / 2) * castleRadius * 0.5) * wallProgress
		end
		
	elseif orbitShape == "Sword" then
		-- Legendary blade formation
		local bladeLength = 15
		local bladeSegment = (index - 1) % bladeLength
		local swordAngle = time * 2
		-- Blade pointing upward
		x = math.sin(swordAngle) * 0.5 + math.sin(time * 3 + bladeSegment * 0.2) * 0.3
		z = math.cos(swordAngle) * 0.5
		y = height - 5 + bladeSegment * 0.8
		-- Crossguard
		if bladeSegment == 5 then
			x = x + math.cos(swordAngle) * 3
		end
		-- Pommel
		if bladeSegment == 0 then
			x = x + math.sin(time * 4) * 0.5
		end
		
	elseif orbitShape == "Shield" then
		-- Protective barrier formation
		local layers = 5
		local layer = math.floor((index - 1) / math.max(1, total / layers)) % layers
		local shieldAngle = angle + layer * 0.3 + time * 0.5
		local shieldRadius = radius * (0.5 + layer * 0.1)
		-- Hexagonal shield pattern
		local hexSides = 6
		local hexAngle = math.floor(shieldAngle / (math.pi * 2 / hexSides)) * (math.pi * 2 / hexSides)
		x = math.cos(hexAngle) * shieldRadius
		z = math.sin(hexAngle) * shieldRadius
		y = height + math.sin(time * 2 + layer) * 1
		
	elseif orbitShape == "Crown" then
		-- Royal crown with jewels
		local points = 8
		local point = math.floor((index - 1) / math.max(1, total / points)) % points
		local pointAngle = point / points * math.pi * 2 + time * 0.3
		local pointHeight = ((index - 1) % math.max(1, total / points)) / math.max(1, total / points)
		local crownRadius = radius * 0.6
		-- Crown points
		x = math.cos(pointAngle) * crownRadius
		z = math.sin(pointAngle) * crownRadius
		if pointHeight > 0.7 then
			-- Jewels at tips
			y = height + 3 + math.sin(time * 4 + point) * 0.5
		else
			-- Crown band
			y = height + pointHeight * 3
		end
		
	elseif orbitShape == "Throne" then
		-- Majestic throne structure
		local parts = 4 -- back, seat, arms
		local part = math.floor((index - 1) / math.max(1, total / parts)) % parts
		local partProgress = ((index - 1) % math.max(1, total / parts)) / math.max(1, total / parts)
		if part == 0 then
			-- Throne back
			x = 0
			z = -radius * 0.5
			y = height + partProgress * 8
		elseif part == 1 then
			-- Seat
			x = (partProgress - 0.5) * 4
			z = 0
			y = height
		else
			-- Armrests
			local side = (part == 2) and 1 or -1
			x = side * 2
			z = (partProgress - 0.5) * 2
			y = height + 2
		end
		
	elseif orbitShape == "Gate" then
		-- Portal gate pillars
		local pillars = 2
		local pillar = (index - 1) % pillars
		local pillarHeight = math.floor((index - 1) / pillars) / math.max(1, total / pillars)
		local gateRadius = radius * 0.8
		-- Two pillars
		x = (pillar == 0 and -gateRadius or gateRadius)
		z = 0
		y = height - 4 + pillarHeight * 12
		-- Archway
		if pillarHeight > 0.8 then
			local archProgress = ((index - 1) % 10) / 10
			local archAngle = archProgress * math.pi
			x = math.cos(archAngle) * gateRadius - gateRadius
			z = 0
			y = height + 8 + math.sin(archAngle) * 3
		end
		
	elseif orbitShape == "Portal" then
		-- Swirling dimensional gateway
		local spirals = 8
		local spiral = math.floor((index - 1) / math.max(1, total / spirals)) % spirals
		local spiralProgress = ((index - 1) % math.max(1, total / spirals)) / math.max(1, total / spirals)
		local portalAngle = spiral / spirals * math.pi * 2 + spiralProgress * math.pi * 3 + time * 3
		local portalRadius = radius * (0.7 - spiralProgress * 0.4)
		-- Swirling inward
		x = math.cos(portalAngle) * portalRadius
		z = math.sin(portalAngle) * portalRadius
		y = height + math.sin(portalAngle * 2 + time * 2) * 2
		
	elseif orbitShape == "Labyrinth" then
		-- Maze-like pattern
		local walls = 8
		local wall = math.floor((index - 1) / math.max(1, total / walls)) % walls
		local wallAngle = wall / walls * math.pi * 2
		local wallProgress = ((index - 1) % math.max(1, total / walls)) / math.max(1, total / walls)
		local wallRadius = radius * (0.4 + (wall % 2) * 0.3)
		-- Concentric maze walls
		x = math.cos(wallAngle) * wallRadius + math.sin(wallProgress * math.pi * 4) * 1
		z = math.sin(wallAngle) * wallRadius + math.cos(wallProgress * math.pi * 4) * 1
		y = height + math.sin(time * 2 + wall) * 0.5
		
	-- TECH & SCI-FI
	elseif orbitShape == "Mech" then
		-- Robot mech formation
		local limbs = 4 -- arms and legs
		local limb = math.floor((index - 1) / math.max(1, total / limbs)) % limbs
		local limbSegment = ((index - 1) % math.max(1, total / limbs)) / math.max(1, total / limbs)
		local mechAngle = limb / limbs * math.pi * 2
		local mechRadius = radius * 0.5
		-- Mechanical limbs
		x = math.cos(mechAngle) * (mechRadius + limbSegment * 2)
		z = math.sin(mechAngle) * (mechRadius + limbSegment * 2)
		y = height + math.sin(time * 3 + limb + limbSegment * 2) * 3
		-- Joint articulation
		if limbSegment > 0.5 then
			x = x + math.sin(time * 4 + limb) * 1.5
		end
		
	elseif orbitShape == "Satellite" then
		-- Orbiting satellite with solar panels
		local satellites = 3
		local satellite = math.floor((index - 1) / math.max(1, total / satellites)) % satellites
		local satelliteAngle = satellite / satellites * math.pi * 2 + time * 1.5
		local orbitRadius = radius * 0.9
		-- Orbital path
		x = math.cos(satelliteAngle) * orbitRadius
		z = math.sin(satelliteAngle) * orbitRadius
		y = height + math.sin(satelliteAngle * 2) * 3
		-- Solar panels
		local panel = ((index - 1) % math.max(1, total / satellites)) / math.max(1, total / satellites)
		if panel < 0.3 or panel > 0.7 then
			x = x + (panel < 0.5 and -3 or 3)
		end
		
	elseif orbitShape == "Reactor" then
		-- Nuclear reactor core
		local rings = 6
		local ring = math.floor((index - 1) / math.max(1, total / rings)) % rings
		local ringAngle = angle * (1 + ring * 0.3) + time * (2 + ring * 0.5)
		local reactorRadius = radius * (0.3 + ring * 0.12)
		-- Pulsing energy rings
		local energyPulse = math.sin(time * 5 + ring) * 0.2 + 1
		x = math.cos(ringAngle) * reactorRadius * energyPulse
		z = math.sin(ringAngle) * reactorRadius * energyPulse
		y = height + (ring - 3) * 1.5 + math.sin(time * 4 + ring) * 1
		
	elseif orbitShape == "Circuit" then
		-- Electronic circuit board pattern
		local traces = 8
		local trace = math.floor((index - 1) / math.max(1, total / traces)) % traces
		local traceAngle = trace / traces * math.pi * 2
		local traceProgress = ((index - 1) % math.max(1, total / traces)) / math.max(1, total / traces)
		local circuitRadius = radius * 0.7
		-- Circuit traces
		x = math.cos(traceAngle) * circuitRadius * traceProgress
		z = math.sin(traceAngle) * circuitRadius * traceProgress
		y = height + math.sin(time * 6 + trace) * 0.3
		-- Connection nodes
		if traceProgress > 0.9 or traceProgress < 0.1 then
			y = y + 0.5
		end
		
	elseif orbitShape == "Matrix" then
		-- Digital matrix rain effect
		local columns = 10
		local column = math.floor((index - 1) / math.max(1, total / columns)) % columns
		local columnAngle = column / columns * math.pi * 2
		local fallProgress = ((index - 1) % math.max(1, total / columns)) / math.max(1, total / columns)
		local matrixRadius = radius * 0.6
		-- Falling code
		x = math.cos(columnAngle) * matrixRadius
		z = math.sin(columnAngle) * matrixRadius
		y = height + 10 - (fallProgress + time * 2) % 12
		
	elseif orbitShape == "Hologram" then
		-- Flickering holographic projection
		local scanlines = 8
		local scanline = math.floor((index - 1) / math.max(1, total / scanlines)) % scanlines
		local scanProgress = ((index - 1) % math.max(1, total / scanlines)) / math.max(1, total / scanlines)
		local holoAngle = angle + time * 2
		local holoRadius = radius * 0.7
		-- Rotating hologram with scan lines
		x = math.cos(holoAngle) * holoRadius * scanProgress
		z = math.sin(holoAngle) * holoRadius * scanProgress
		y = height - 3 + scanline * 1.5 + math.sin(time * 8 + scanline) * 0.2
		
	elseif orbitShape == "Laser" then
		-- Laser grid security system
		local beams = 6
		local beam = math.floor((index - 1) / math.max(1, total / beams)) % beams
		local beamAngle = beam / beams * math.pi * 2 + time * 0.5
		local beamLength = ((index - 1) % math.max(1, total / beams)) / math.max(1, total / beams)
		local laserRadius = radius * 0.8
		-- Crisscrossing laser beams
		if beam % 2 == 0 then
			x = math.cos(beamAngle) * laserRadius * beamLength
			z = math.sin(beamAngle) * laserRadius * beamLength
			y = height
		else
			x = math.cos(beamAngle) * laserRadius
			z = math.sin(beamAngle) * laserRadius
			y = height - 3 + beamLength * 6
		end
		
	-- NATURE ELEMENTS
	elseif orbitShape == "Tree" then
		-- Growing tree with branches
		local trunk = 8
		local branches = 12
		local segment = (index - 1) % (trunk + branches)
		if segment < trunk then
			-- Trunk
			x = math.sin(time * 2 + segment * 0.1) * 0.5
			z = math.cos(time * 2 + segment * 0.1) * 0.5
			y = height - 4 + segment * 1.2
		else
			-- Branches
			local branch = segment - trunk
			local branchAngle = branch / branches * math.pi * 2 + time * 0.3
			local branchLength = 0.6
			x = math.cos(branchAngle) * radius * branchLength
			z = math.sin(branchAngle) * radius * branchLength
			y = height + 4 + math.sin(branchAngle * 3) * 2
		end
		
	elseif orbitShape == "Volcano" then
		-- Erupting volcano with lava
		local crater = 8
		local lava = 12
		local segment = (index - 1) % (crater + lava)
		if segment < crater then
			-- Crater rim
			local craterAngle = segment / crater * math.pi * 2 + time * 0.2
			local craterRadius = radius * 0.6
			x = math.cos(craterAngle) * craterRadius
			z = math.sin(craterAngle) * craterRadius
			y = height + 2 + math.sin(craterAngle * 4) * 1
		else
			-- Lava eruption
			local lavaSegment = segment - crater
			local lavaAngle = lavaSegment / lava * math.pi * 2 + time * 3
			x = math.sin(lavaAngle) * 2
			z = math.cos(lavaAngle) * 2
			y = height + 3 + (lavaSegment / lava) * 8 + math.sin(time * 5 + lavaSegment) * 2
		end
		
	elseif orbitShape == "Ocean" then
		-- Ocean waves
		local waves = 8
		local wave = math.floor((index - 1) / math.max(1, total / waves)) % waves
		local waveProgress = ((index - 1) % math.max(1, total / waves)) / math.max(1, total / waves)
		local oceanAngle = wave / waves * math.pi * 2 + time
		local oceanRadius = radius * 0.8
		-- Wave motion
		x = math.cos(oceanAngle) * oceanRadius * waveProgress
		z = math.sin(oceanAngle) * oceanRadius * waveProgress
		y = height + math.sin(waveProgress * math.pi * 4 + time * 3) * 3
		
	elseif orbitShape == "Mountain" then
		-- Mountain peaks
		local peaks = 5
		local peak = math.floor((index - 1) / math.max(1, total / peaks)) % peaks
		local peakAngle = peak / peaks * math.pi * 2
		local peakHeight = ((index - 1) % math.max(1, total / peaks)) / math.max(1, total / peaks)
		local mountainRadius = radius * (1 - peakHeight * 0.5)
		-- Triangular peaks
		x = math.cos(peakAngle) * mountainRadius
		z = math.sin(peakAngle) * mountainRadius
		y = height - 5 + peakHeight * 12 * (1 - peakHeight)
		
	elseif orbitShape == "Lightning" then
		-- Lightning bolt strikes
		local bolts = 4
		local bolt = math.floor((index - 1) / math.max(1, total / bolts)) % bolts
		local boltAngle = bolt / bolts * math.pi * 2 + time * 2
		local boltSegment = ((index - 1) % math.max(1, total / bolts)) / math.max(1, total / bolts)
		-- Jagged lightning path
		x = math.cos(boltAngle) * radius * 0.3 + math.random(-2, 2) * boltSegment
		z = math.sin(boltAngle) * radius * 0.3 + math.random(-2, 2) * boltSegment
		y = height + 10 - boltSegment * 15
		
	elseif orbitShape == "Aurora" then
		-- Northern lights waves
		local curtains = 6
		local curtain = math.floor((index - 1) / math.max(1, total / curtains)) % curtains
		local curtainProgress = ((index - 1) % math.max(1, total / curtains)) / math.max(1, total / curtains)
		local auroraAngle = curtain / curtains * math.pi * 2 + time * 0.5
		local auroraRadius = radius * 0.8
		-- Flowing curtain effect
		x = math.cos(auroraAngle) * auroraRadius
		z = math.sin(auroraAngle) * auroraRadius
		y = height + curtainProgress * 8 + math.sin(time * 2 + curtain + curtainProgress * 3) * 3
		
	elseif orbitShape == "Comet" then
		-- Comet with tail
		local tailLength = 20
		local tailSegment = (index - 1) % tailLength
		local cometAngle = time * 2
		local cometRadius = radius * 0.5
		-- Head and tail
		x = math.cos(cometAngle) * cometRadius - tailSegment * 0.5
		z = math.sin(cometAngle) * cometRadius
		y = height + 5 - tailSegment * 0.3 + math.sin(time * 4 + tailSegment * 0.2) * 1
		
	-- ABSTRACT CONCEPTS
	elseif orbitShape == "Tesseract" then
		-- 4D cube (different from Tesseract4D)
		local vertices = 16
		local vertex = (index - 1) % vertices
		local w = math.floor(vertex / 8)
		local v = vertex % 8
		local tesseractAngle = v / 8 * math.pi * 2 + time
		local tesseractRadius = radius * (0.5 + w * 0.4)
		x = math.cos(tesseractAngle) * tesseractRadius
		z = math.sin(tesseractAngle) * tesseractRadius
		y = height + (w - 0.5) * 6 + math.sin(time * 3 + v) * 2
		
	elseif orbitShape == "Fractal" then
		-- Fractal branching pattern
		local iterations = 4
		local iteration = math.floor((index - 1) / math.max(1, total / iterations)) % iterations
		local fractalAngle = angle * math.pow(2, iteration) + time * (1 + iteration * 0.5)
		local fractalRadius = radius * math.pow(0.6, iteration)
		x = math.cos(fractalAngle) * fractalRadius
		z = math.sin(fractalAngle) * fractalRadius
		y = height + math.sin(fractalAngle * 3) * 2 * math.pow(0.8, iteration)
		
	elseif orbitShape == "Chaos" then
		-- Chaotic attractor
		local chaosX = math.sin(time * 2.7 + index * 0.1) * radius
		local chaosY = math.sin(time * 3.1 + index * 0.15) * radius
		local chaosZ = math.sin(time * 2.3 + index * 0.12) * radius
		x = chaosX + math.cos(time * 5 + index * 0.2) * 2
		z = chaosZ + math.sin(time * 4.5 + index * 0.18) * 2
		y = height + chaosY + math.sin(time * 6 + index * 0.25) * 3
		
	elseif orbitShape == "Singularity" then
		-- Gravitational singularity collapse
		local collapse = math.sin(time * 2) * 0.5 + 0.5
		local singularityAngle = angle + time * 3
		local singularityRadius = radius * (1 - collapse * 0.7)
		-- Spiraling inward
		x = math.cos(singularityAngle) * singularityRadius
		z = math.sin(singularityAngle) * singularityRadius
		y = height + math.sin(singularityAngle * 4) * (3 * (1 - collapse))
		
	elseif orbitShape == "Paradox" then
		-- Impossible geometry (Penrose triangle style)
		local sides = 3
		local side = math.floor((index - 1) / math.max(1, total / sides)) % sides
		local sideProgress = ((index - 1) % math.max(1, total / sides)) / math.max(1, total / sides)
		local paradoxAngle = side / sides * math.pi * 2 + time * 0.5
		local paradoxRadius = radius * 0.7
		-- Twisted triangle
		local twist = sideProgress * math.pi * 2
		x = math.cos(paradoxAngle) * paradoxRadius + math.cos(twist) * 2
		z = math.sin(paradoxAngle) * paradoxRadius + math.sin(twist) * 2
		y = height + math.sin(paradoxAngle * 3 + twist) * 3
		
	elseif orbitShape == "Glitch" then
		-- Digital glitch effect
		local glitchChance = math.random()
		if glitchChance > 0.7 then
			x = math.random(-radius, radius)
			z = math.random(-radius, radius)
			y = height + math.random(-5, 5)
		else
			local glitchAngle = angle + time * 2
			local glitchRadius = radius * 0.6
			x = math.cos(glitchAngle) * glitchRadius + math.random(-1, 1)
			z = math.sin(glitchAngle) * glitchRadius + math.random(-1, 1)
			y = height + math.sin(time * 8 + index) * 3
		end
		
	elseif orbitShape == "Void" then
		-- Empty void with occasional particles
		local voidDensity = 0.3
		if math.random() < voidDensity then
			local voidAngle = angle + time * 0.5
			local voidRadius = radius * (0.2 + math.random() * 0.7)
			x = math.cos(voidAngle) * voidRadius
			z = math.sin(voidAngle) * voidRadius
			y = height + math.random(-5, 5)
		else
			-- Most particles in void
			x = 0
			z = 0
			y = height - 1000 -- Hide most particles
		end
		
	-- MUSIC & SOUND
	elseif orbitShape == "BassBoost" then
		-- Bass frequency visualization
		local bassWave = math.sin(time * 2) * 0.5 + 0.5
		local rings = 6
		local ring = math.floor((index - 1) / math.max(1, total / rings)) % rings
		local bassAngle = angle + time * (1 + ring * 0.2)
		local bassRadius = radius * (0.4 + ring * 0.1) * (1 + bassWave * 0.5)
		x = math.cos(bassAngle) * bassRadius
		z = math.sin(bassAngle) * bassRadius
		y = height + math.sin(bassAngle * 2) * bassWave * 4
		
	elseif orbitShape == "Equalizer" then
		-- Audio equalizer bars
		local bars = 12
		local bar = math.floor((index - 1) / math.max(1, total / bars)) % bars
		local barAngle = bar / bars * math.pi * 2
		local barHeight = math.abs(math.sin(time * 4 + bar * 0.5)) * 8
		local eqRadius = radius * 0.7
		-- Vertical bars
		x = math.cos(barAngle) * eqRadius
		z = math.sin(barAngle) * eqRadius
		y = height - 4 + (((index - 1) % math.max(1, total / bars)) / math.max(1, total / bars)) * barHeight
		
	elseif orbitShape == "Soundwave" then
		-- Sound wave propagation
		local waves = 8
		local wave = math.floor((index - 1) / math.max(1, total / waves)) % waves
		local waveProgress = ((index - 1) % math.max(1, total / waves)) / math.max(1, total / waves)
		local soundAngle = wave / waves * math.pi * 2 + time * 2
		local soundRadius = radius * waveProgress
		-- Expanding waves
		x = math.cos(soundAngle) * soundRadius
		z = math.sin(soundAngle) * soundRadius
		y = height + math.sin(waveProgress * math.pi * 4 + time * 5) * 2
		
	elseif orbitShape == "Echo" then
		-- Echo delay effect
		local echoes = 5
		local echo = math.floor((index - 1) / math.max(1, total / echoes)) % echoes
		local echoDelay = echo * 0.5
		local echoAngle = angle + time * 2 - echoDelay
		local echoRadius = radius * (1 - echo * 0.15)
		-- Delayed repetitions
		x = math.cos(echoAngle) * echoRadius
		z = math.sin(echoAngle) * echoRadius
		y = height + math.sin(echoAngle * 3) * (3 - echo * 0.5)
		
	elseif orbitShape == "Harmonic" then
		-- Harmonic resonance
		local harmonics = 6
		local harmonic = math.floor((index - 1) / math.max(1, total / harmonics)) % harmonics
		local harmonicFreq = 1 + harmonic * 0.5
		local harmonicAngle = angle * harmonicFreq + time * harmonicFreq
		local harmonicRadius = radius * (0.3 + harmonic * 0.1)
		-- Multiple frequencies
		x = math.cos(harmonicAngle) * harmonicRadius
		z = math.sin(harmonicAngle) * harmonicRadius
		y = height + math.sin(harmonicAngle * 2) * 2
		
	-- COMBAT WEAPONS
	elseif orbitShape == "Shuriken" then
		-- Throwing star rotation
		local blades = 4
		local blade = math.floor((index - 1) / math.max(1, total / blades)) % blades
		local bladeAngle = blade / blades * math.pi * 2 + time * 8
		local bladeLength = ((index - 1) % math.max(1, total / blades)) / math.max(1, total / blades)
		local shurikenRadius = radius * 0.6 * bladeLength
		-- Spinning blades
		x = math.cos(bladeAngle) * shurikenRadius
		z = math.sin(bladeAngle) * shurikenRadius
		y = height + math.sin(time * 10) * 0.5
		
	elseif orbitShape == "Boomerang" then
		-- Curved boomerang path
		local boomerangAngle = time * 3
		local boomerangRadius = radius * (0.5 + math.sin(time * 2) * 0.4)
		local curve = math.sin(angle * 2 + time * 4) * 3
		x = math.cos(boomerangAngle + angle) * boomerangRadius + curve
		z = math.sin(boomerangAngle + angle) * boomerangRadius
		y = height + math.sin(boomerangAngle * 2) * 4
		
	elseif orbitShape == "Chakram" then
		-- Circular blade ring
		local rings = 3
		local ring = math.floor((index - 1) / math.max(1, total / rings)) % rings
		local chakramAngle = angle + time * (3 + ring)
		local chakramRadius = radius * (0.5 + ring * 0.2)
		-- Spinning rings
		x = math.cos(chakramAngle) * chakramRadius
		z = math.sin(chakramAngle) * chakramRadius
		y = height + ring * 1.5 + math.sin(time * 5 + ring) * 1
		
	elseif orbitShape == "Glaive" then
		-- Polearm sweep
		local sweepAngle = time * 2
		local glaiveLength = 10
		local glaiveSegment = (index - 1) % glaiveLength
		local glaiveRadius = radius * 0.7
		-- Sweeping arc
		x = math.cos(sweepAngle) * glaiveRadius + (glaiveSegment / glaiveLength - 0.5) * 5
		z = math.sin(sweepAngle) * glaiveRadius
		y = height + math.sin(sweepAngle + glaiveSegment * 0.2) * 3
		
	elseif orbitShape == "Scythe" then
		-- Reaper's scythe swing
		local scytheAngle = time * 1.5
		local scytheArc = math.sin(scytheAngle) * math.pi
		local scytheRadius = radius * 0.8
		local scytheSegment = ((index - 1) % 15) / 15
		-- Curved blade
		x = math.cos(scytheArc + scytheSegment * math.pi) * scytheRadius * scytheSegment
		z = math.sin(scytheAngle * 2) * 2
		y = height + math.sin(scytheArc + scytheSegment * math.pi) * 4 + scytheSegment * 3
		
	elseif orbitShape == "Lance" then
		-- Jousting lance charge
		local lanceAngle = time * 2
		local lanceLength = 12
		local lanceSegment = (index - 1) % lanceLength
		-- Forward thrust
		x = math.cos(lanceAngle) * radius * 0.3
		z = math.sin(lanceAngle) * radius * 0.3 + lanceSegment * 0.8
		y = height + math.sin(time * 3) * 1 + lanceSegment * 0.1
		
	-- NEW ELEMENTAL SHAPES (25)
	elseif orbitShape == "Fire" then
		-- Flickering flames rising
		local flicker = math.random() * 0.5 + 0.5
		local flameHeight = (index / total) * 8
		x = math.cos(angle + math.sin(time * 5 + index) * 0.5) * radius * flicker
		z = math.sin(angle + math.cos(time * 5 + index) * 0.5) * radius * flicker
		y = height + flameHeight + math.sin(time * 8 + index) * 2
		
	elseif orbitShape == "Ice" then
		-- Crystalline ice shards
		local crystal = math.floor((index - 1) / 6) % 6
		local crystalAngle = crystal / 6 * math.pi * 2
		local shard = ((index - 1) % 6) / 6
		x = math.cos(crystalAngle) * radius * (0.5 + shard * 0.5)
		z = math.sin(crystalAngle) * radius * (0.5 + shard * 0.5)
		y = height + shard * 6 - 3
		
	elseif orbitShape == "Lightning" then
		-- Jagged lightning bolts
		local boltSegment = (index - 1) % 10
		local boltAngle = angle + boltSegment * 0.3
		local jag = (boltSegment % 2 == 0) and 1 or -1
		x = math.cos(boltAngle) * radius + jag * math.random() * 2
		z = math.sin(boltAngle) * radius + jag * math.random() * 2
		y = height + boltSegment - 5
		
	elseif orbitShape == "Earth" then
		-- Floating earth chunks
		local chunk = math.floor((index - 1) / 8) % 5
		local chunkAngle = chunk / 5 * math.pi * 2 + time * 0.3
		local chunkRadius = radius * (0.6 + chunk * 0.1)
		x = math.cos(chunkAngle) * chunkRadius
		z = math.sin(chunkAngle) * chunkRadius
		y = height + math.sin(time + chunk) * 2
		
	elseif orbitShape == "Wind" then
		-- Swirling wind currents
		local swirl = angle + time * 2 + (index / total) * math.pi * 4
		local windRadius = radius * (0.5 + math.sin(swirl) * 0.5)
		x = math.cos(swirl) * windRadius
		z = math.sin(swirl) * windRadius
		y = height + math.sin(time * 3 + index) * 4
		
	elseif orbitShape == "Water" then
		-- Flowing water streams
		local stream = math.floor((index - 1) / 10) % 4
		local streamAngle = stream / 4 * math.pi * 2
		local flow = ((index - 1) % 10) / 10
		local wave = math.sin(time * 2 + flow * math.pi * 2) * 2
		x = math.cos(streamAngle + flow * 0.5) * radius
		z = math.sin(streamAngle + flow * 0.5) * radius
		y = height + wave
		
	elseif orbitShape == "Metal" then
		-- Metallic orbital rings
		local ring = math.floor((index - 1) / (total / 3)) % 3
		local ringAngle = angle + ring * (math.pi * 2 / 3)
		local ringRadius = radius * (0.7 + ring * 0.15)
		x = math.cos(ringAngle) * ringRadius
		z = math.sin(ringAngle) * ringRadius
		y = height + math.sin(ringAngle * 2) * 1.5
		
	elseif orbitShape == "Wood" then
		-- Growing tree branches
		local branches = 5
		local branch = math.floor((index - 1) / (total / branches)) % branches
		local branchAngle = branch / branches * math.pi * 2
		local growth = ((index - 1) % (total / branches)) / (total / branches)
		x = math.cos(branchAngle) * radius * growth
		z = math.sin(branchAngle) * radius * growth
		y = height + growth * 5
		
	elseif orbitShape == "Light" then
		-- Radiant light rays
		local rays = 12
		local ray = math.floor((index - 1) / (total / rays)) % rays
		local rayAngle = ray / rays * math.pi * 2
		local rayLength = ((index - 1) % (total / rays)) / (total / rays)
		local pulse = 1 + math.sin(time * 4) * 0.3
		x = math.cos(rayAngle) * radius * rayLength * pulse
		z = math.sin(rayAngle) * radius * rayLength * pulse
		y = height
		
	elseif orbitShape == "Shadow" then
		-- Dark shadow tendrils
		local tendrils = 6
		local tendril = math.floor((index - 1) / (total / tendrils)) % tendrils
		local tendrilAngle = tendril / tendrils * math.pi * 2 + time * 0.5
		local reach = ((index - 1) % (total / tendrils)) / (total / tendrils)
		local writhe = math.sin(time * 3 + reach * math.pi) * 2
		x = math.cos(tendrilAngle) * radius * reach + writhe
		z = math.sin(tendrilAngle) * radius * reach + writhe * 0.7
		y = height - reach * 3
		
	elseif orbitShape == "Thunder" then
		-- Thunder storm pattern
		local strike = math.floor(time * 3) % 2
		if strike == 1 then
			local thunderOffset = Vector3.new(math.random(-3, 3), math.random(-3, 3), math.random(-3, 3))
			x = math.cos(angle) * radius + thunderOffset.X
			z = math.sin(angle) * radius + thunderOffset.Z
			y = height + thunderOffset.Y
		else
			x = math.cos(angle) * radius
			z = math.sin(angle) * radius
			y = height
		end
		
	elseif orbitShape == "Magma" then
		-- Bubbling magma eruptions
		local bubble = math.sin(time * 2 + index * 0.5)
		local erupt = (bubble > 0.7) and (bubble - 0.7) * 10 or 0
		x = math.cos(angle) * radius * (1 + bubble * 0.2)
		z = math.sin(angle) * radius * (1 + bubble * 0.2)
		y = height + erupt + math.sin(angle * 5) * 1
		
	elseif orbitShape == "Frost" then
		-- Frost crystal formation
		local crystals = 8
		local crystal = math.floor((index - 1) / (total / crystals)) % crystals
		local crystalAngle = crystal / crystals * math.pi * 2
		local branch = ((index - 1) % (total / crystals)) / (total / crystals)
		x = math.cos(crystalAngle + branch * 0.5) * radius * (0.3 + branch * 0.7)
		z = math.sin(crystalAngle + branch * 0.5) * radius * (0.3 + branch * 0.7)
		y = height + math.sin(branch * math.pi) * 2
		
	elseif orbitShape == "Storm" then
		-- Chaotic storm rotation
		local chaos = math.sin(time * 4 + index) * 0.5
		local stormAngle = angle + time * 2 + chaos
		local stormRadius = radius * (0.7 + math.abs(chaos))
		x = math.cos(stormAngle) * stormRadius
		z = math.sin(stormAngle) * stormRadius
		y = height + math.sin(time * 5 + index) * 3
		
	elseif orbitShape == "Quake" then
		-- Earthquake shockwaves
		local wave = math.floor((index - 1) / (total / 5)) % 5
		local waveAngle = angle + wave * 0.5
		local waveRadius = radius * (0.5 + wave * 0.15) * (1 + math.sin(time * 3 - wave) * 0.3)
		x = math.cos(waveAngle) * waveRadius
		z = math.sin(waveAngle) * waveRadius
		y = height + math.sin(time * 4 - wave) * 2
		
	elseif orbitShape == "Tsunami" then
		-- Massive tidal wave
		local waveProgress = (index / total + time * 0.5) % 1
		local waveHeight = math.sin(waveProgress * math.pi) * 8
		x = math.cos(angle) * radius
		z = math.sin(angle) * radius + waveProgress * 10 - 5
		y = height + waveHeight
		
	elseif orbitShape == "Blaze" then
		-- Intense fire spiral
		local blazeAngle = angle + (index / total) * math.pi * 6 + time * 3
		local blazeRadius = radius * (0.5 + (index / total) * 0.5)
		local flare = math.sin(time * 8 + index) * 0.3 + 1
		x = math.cos(blazeAngle) * blazeRadius * flare
		z = math.sin(blazeAngle) * blazeRadius * flare
		y = height + (index / total) * 6
		
	elseif orbitShape == "Glacier" then
		-- Slow moving ice formation
		local layers = 4
		local layer = math.floor((index - 1) / (total / layers)) % layers
		local layerAngle = angle + layer * 0.2
		local layerRadius = radius * (0.8 - layer * 0.1)
		x = math.cos(layerAngle) * layerRadius
		z = math.sin(layerAngle) * layerRadius
		y = height + layer * 2.5
		
	elseif orbitShape == "Tempest" then
		-- Violent wind vortex
		local vortexAngle = angle + time * 4 + (index / total) * math.pi * 8
		local vortexRadius = radius * (1 - (index / total) * 0.5)
		local turbulence = math.sin(time * 6 + index) * 2
		x = math.cos(vortexAngle) * vortexRadius + turbulence
		z = math.sin(vortexAngle) * vortexRadius + turbulence * 0.7
		y = height + (index / total) * 8 - 4
		
	elseif orbitShape == "Inferno" then
		-- Hellfire tornado
		local hellAngle = angle + (index / total) * math.pi * 10 + time * 5
		local hellRadius = radius * (1 - (index / total) * 0.3)
		local heat = math.sin(time * 10 + index) * 1.5
		x = math.cos(hellAngle) * hellRadius + heat
		z = math.sin(hellAngle) * hellRadius + heat * 0.8
		y = height + (index / total) * 10 - 5
		
	elseif orbitShape == "Cyclone" then
		-- Spinning cyclone funnel
		local funnelAngle = angle + time * 3
		local funnelHeight = (index / total) * 12 - 6
		local funnelRadius = radius * (0.3 + math.abs(funnelHeight) / 12 * 0.7)
		x = math.cos(funnelAngle + funnelHeight * 0.2) * funnelRadius
		z = math.sin(funnelAngle + funnelHeight * 0.2) * funnelRadius
		y = height + funnelHeight
		
	elseif orbitShape == "Avalanche" then
		-- Cascading snow and ice
		local cascade = (index / total + time * 0.8) % 1
		local cascadeAngle = angle + cascade * math.pi * 2
		local tumble = math.sin(cascade * math.pi * 4) * 3
		x = math.cos(cascadeAngle) * radius + tumble
		z = math.sin(cascadeAngle) * radius
		y = height + 8 - cascade * 16
		
	elseif orbitShape == "Eruption" then
		-- Volcanic eruption spray
		local eruptAngle = angle + (index / total) * math.pi * 0.5
		local eruptPower = math.sin((index / total) * math.pi)
		local arc = eruptPower * 12
		x = math.cos(eruptAngle) * radius * (0.5 + (index / total) * 0.5)
		z = math.sin(eruptAngle) * radius * (0.5 + (index / total) * 0.5)
		y = height + arc - (index / total) * 3
		
	elseif orbitShape == "Tornado" then
		-- Classic tornado funnel (fixed duplicate)
		local tornadoHeight = (index / total) * 15 - 7.5
		local tornadoRadius = radius * (0.3 + math.abs(tornadoHeight) / 15 * 0.7)
		local spin = angle + tornadoHeight * 0.5 + time * 2
		x = math.cos(spin) * tornadoRadius
		z = math.sin(spin) * tornadoRadius
		y = height + tornadoHeight
		
	elseif orbitShape == "Hurricane" then
		-- Massive hurricane spiral
		local eyewall = 3
		local bands = math.floor((index - 1) / (total / eyewall)) % eyewall
		local bandAngle = angle + bands * (math.pi * 2 / eyewall) + time * (1 + bands * 0.5)
		local bandRadius = radius * (0.4 + bands * 0.3)
		x = math.cos(bandAngle) * bandRadius
		z = math.sin(bandAngle) * bandRadius
		y = height + math.sin(bandAngle * 3) * 2
		
	-- 🔥 30 ADDICTIVE NEW SHAPES 🔥
	elseif orbitShape == "Helix2" then
		-- Double helix with color trails
		local strand = (index % 2)
		local helixAngle = angle + strand * math.pi + time * 2
		local helixRadius = radius * 0.6
		x = math.cos(helixAngle) * helixRadius
		z = math.sin(helixAngle) * helixRadius
		y = (angle / (math.pi * 2)) * 20 - 10 + math.sin(time * 3 + strand) * 2
		
	elseif orbitShape == "DNA2" then
		-- Triple helix DNA mutation
		local strand = (index % 3)
		local dnaAngle = angle + strand * (math.pi * 2 / 3) + time
		local dnaRadius = radius * 0.5
		x = math.cos(dnaAngle) * dnaRadius
		z = math.sin(dnaAngle) * dnaRadius
		y = (angle / (math.pi * 2)) * 25 - 12.5 + math.sin(time * 4 + strand) * 3
		
	elseif orbitShape == "Spiral2" then
		-- Logarithmic spiral with pulse
		local pulse = math.sin(time * 3) * 0.3 + 1
		local spiralRadius = radius * math.exp(angle * 0.1) * 0.1 * pulse
		x = math.cos(angle + time) * spiralRadius
		z = math.sin(angle + time) * spiralRadius
		y = height + (angle / (math.pi * 2)) * 8
		
	elseif orbitShape == "Vortex2" then
		-- Dual vortex tornado
		local vortex = (index % 2)
		local vortexAngle = angle + vortex * math.pi + time * 3
		local depth = (index / total) * 20 - 10
		local vortexRadius = radius * (1 - math.abs(depth) / 15) * (0.7 + vortex * 0.3)
		x = math.cos(vortexAngle) * vortexRadius
		z = math.sin(vortexAngle) * vortexRadius
		y = depth + height + math.sin(time * 5 + vortex) * 2
		
	elseif orbitShape == "Galaxy2" then
		-- Spiral galaxy with arms
		local arms = 4
		local arm = math.floor((index - 1) / (total / arms)) % arms
		local armAngle = angle + arm * (math.pi * 2 / arms) + (index / total) * math.pi * 6
		local armRadius = radius * (0.3 + (index / total) * 0.7)
		x = math.cos(armAngle + time * 0.5) * armRadius
		z = math.sin(armAngle + time * 0.5) * armRadius
		y = height + math.sin(armAngle * 3) * 3
		
	elseif orbitShape == "Atom2" then
		-- Multi-electron orbital
		local electrons = 5
		local electron = (index % electrons)
		local orbitAngle = angle + electron * (math.pi * 2 / electrons) + time * (2 + electron)
		local orbitRadius = radius * (0.5 + electron * 0.1)
		local tilt = electron * math.pi / electrons
		x = math.cos(orbitAngle) * orbitRadius
		y = math.sin(orbitAngle) * orbitRadius * math.sin(tilt) + height
		z = math.sin(orbitAngle) * orbitRadius * math.cos(tilt)
		
	elseif orbitShape == "Molecule2" then
		-- Complex molecular structure
		local nodes = 8
		local node = math.floor((index - 1) / math.max(1, total / nodes)) % nodes
		local nodeAngle = node / nodes * math.pi * 2 + time * 0.5
		local bond = (index % math.max(1, total / nodes)) / math.max(1, total / nodes)
		local molRadius = radius * (0.4 + node * 0.08)
		x = math.cos(nodeAngle) * molRadius * (0.5 + bond * 0.5)
		z = math.sin(nodeAngle) * molRadius * (0.5 + bond * 0.5)
		y = height + math.sin(bond * math.pi * 2) * 4 + math.cos(time * 2 + node) * 1
		
	elseif orbitShape == "Quantum2" then
		-- Quantum superposition effect
		local states = 3
		local state = math.floor((index - 1) / (total / states)) % states
		local quantumAngle = angle + state * (math.pi * 2 / states) + time * 4
		local superposition = math.sin(time * 6 + state) * 0.5 + 0.5
		local quantumRadius = radius * (0.4 + state * 0.2) * superposition
		x = math.cos(quantumAngle) * quantumRadius + math.random(-1, 1) * 0.5
		z = math.sin(quantumAngle) * quantumRadius + math.random(-1, 1) * 0.5
		y = height + math.sin(quantumAngle * 2) * 3 * superposition
		
	elseif orbitShape == "Plasma2" then
		-- Plasma ball with arcs
		local arcs = 8
		local arc = math.floor((index - 1) / (total / arcs)) % arcs
		local arcAngle = arc / arcs * math.pi * 2 + time * 2
		local arcProgress = ((index - 1) % (total / arcs)) / (total / arcs)
		local plasmaRadius = radius * arcProgress
		local discharge = math.sin(time * 8 + arc) * 2
		x = math.cos(arcAngle) * plasmaRadius + discharge
		z = math.sin(arcAngle) * plasmaRadius + discharge * 0.7
		y = height + math.sin(arcProgress * math.pi) * 4
		
	elseif orbitShape == "Photon2" then
		-- Light particle wave-particle duality
		local wave = math.sin(angle * 10 + time * 5) * 3
		x = math.cos(angle + time * 3) * radius * 0.7
		z = math.sin(angle + time * 3) * radius * 0.7
		y = height + wave
		
	elseif orbitShape == "Neutron2" then
		-- Neutron star rotation
		local beams = 2
		local beam = (index % beams)
		local neutronAngle = beam * math.pi + time * 10
		local neutronRadius = radius * (0.3 + (index / total) * 0.7)
		x = math.cos(neutronAngle) * neutronRadius
		z = math.sin(neutronAngle) * neutronRadius
		y = height + math.sin(time * 15 + beam) * 2
		
	elseif orbitShape == "Proton" then
		-- Proton with quarks
		local quarks = 3
		local quark = (index % quarks)
		local protonAngle = quark / quarks * math.pi * 2 + time * 3
		local protonRadius = radius * 0.4
		x = math.cos(protonAngle) * protonRadius + math.sin(time * 5 + quark) * 1
		z = math.sin(protonAngle) * protonRadius + math.cos(time * 5 + quark) * 1
		y = height + math.sin(time * 4 + quark) * 2
		
	elseif orbitShape == "Electron" then
		-- Electron cloud probability
		local cloud = math.random() * radius
		local electronAngle = angle + time * 8
		x = math.cos(electronAngle) * cloud
		z = math.sin(electronAngle) * cloud
		y = height + math.random(-3, 3)
		
	elseif orbitShape == "Quark" then
		-- Quark confinement
		local colors = 3
		local color = (index % colors)
		local quarkAngle = color / colors * math.pi * 2 + time * 6
		local confinement = radius * 0.3 * (1 + math.sin(time * 4 + color) * 0.5)
		x = math.cos(quarkAngle) * confinement
		z = math.sin(quarkAngle) * confinement
		y = height + math.sin(quarkAngle * 2) * 2
		
	elseif orbitShape == "Gluon" then
		-- Gluon force carriers
		local gluons = 8
		local gluon = math.floor((index - 1) / (total / gluons)) % gluons
		local gluonAngle = gluon / gluons * math.pi * 2 + time * 5
		local exchange = ((index - 1) % (total / gluons)) / (total / gluons)
		x = math.cos(gluonAngle) * radius * exchange
		z = math.sin(gluonAngle) * radius * exchange
		y = height + math.sin(exchange * math.pi * 4 + time * 6) * 3
		
	elseif orbitShape == "Higgs" then
		-- Higgs field fluctuations
		local field = math.sin(time * 2) * 0.5 + 0.5
		local higgsAngle = angle + time * 1.5
		local higgsRadius = radius * (0.5 + field * 0.5)
		x = math.cos(higgsAngle) * higgsRadius + math.sin(time * 7 + index * 0.1) * 2
		z = math.sin(higgsAngle) * higgsRadius + math.cos(time * 7 + index * 0.1) * 2
		y = height + math.sin(higgsAngle * 3) * 4 * field
		
	elseif orbitShape == "Antimatter2" then
		-- Antimatter annihilation
		local matter = (index % 2)
		local antiAngle = angle + matter * math.pi + time * 3
		local antiRadius = radius * 0.7
		local annihilation = math.sin(time * 5) * 0.3 + 0.7
		x = math.cos(antiAngle) * antiRadius * annihilation
		z = math.sin(antiAngle) * antiRadius * annihilation
		y = height + math.sin(antiAngle * 2) * 3 * annihilation
		
	elseif orbitShape == "DarkMatter2" then
		-- Invisible dark matter halo
		local halo = math.floor((index - 1) / (total / 5)) % 5
		local haloAngle = angle + halo * 0.7 + time * 0.3
		local haloRadius = radius * (0.8 + halo * 0.15)
		local invisible = math.sin(time * 2 + halo) * 0.5 + 0.5
		x = math.cos(haloAngle) * haloRadius
		z = math.sin(haloAngle) * haloRadius
		y = height + math.sin(haloAngle * 2) * 4 * invisible
		
	elseif orbitShape == "DarkEnergy2" then
		-- Expanding dark energy
		local expansion = 1 + math.sin(time * 1.5) * 0.5
		local darkAngle = angle + time * 2
		local darkRadius = radius * expansion
		x = math.cos(darkAngle) * darkRadius
		z = math.sin(darkAngle) * darkRadius
		y = height + math.sin(darkAngle * 3) * 5 * expansion
		
	elseif orbitShape == "Graviton2" then
		-- Gravitational wave propagation
		local waves = 6
		local wave = math.floor((index - 1) / (total / waves)) % waves
		local waveAngle = angle + wave * (math.pi * 2 / waves) + time * 2
		local waveRadius = radius * (0.5 + wave * 0.1)
		local ripple = math.sin(time * 4 - wave) * 0.3 + 1
		x = math.cos(waveAngle) * waveRadius * ripple
		z = math.sin(waveAngle) * waveRadius * ripple
		y = height + math.sin(waveAngle * 2 + time * 3) * 3
		
	elseif orbitShape == "Spacetime" then
		-- Curved spacetime fabric
		local grid = 10
		local gridX = ((index - 1) % grid) / grid
		local gridZ = math.floor((index - 1) / grid) / grid
		local curvature = math.sin(time * 2) * 3
		x = (gridX - 0.5) * radius * 2
		z = (gridZ - 0.5) * radius * 2
		y = height + math.sin(gridX * math.pi * 2 + time) * curvature + math.sin(gridZ * math.pi * 2 + time) * curvature
		
	elseif orbitShape == "Warp" then
		-- Warp drive bubble
		local bubble = math.sin(time * 3) * 0.3 + 0.7
		local warpAngle = angle + time * 4
		local warpRadius = radius * bubble
		local distortion = math.sin(angle * 8 + time * 6) * 2
		x = math.cos(warpAngle) * warpRadius + distortion
		z = math.sin(warpAngle) * warpRadius + distortion * 0.7
		y = height + math.sin(warpAngle * 3) * 4 * bubble
		
	elseif orbitShape == "Hyperspace" then
		-- Hyperspace jump streaks
		local streaks = 12
		local streak = math.floor((index - 1) / (total / streaks)) % streaks
		local streakAngle = streak / streaks * math.pi * 2
		local streakProgress = ((index - 1) % (total / streaks)) / (total / streaks)
		local hyperRadius = radius * 0.8
		x = math.cos(streakAngle) * hyperRadius + streakProgress * 5
		z = math.sin(streakAngle) * hyperRadius
		y = height + math.sin(streakProgress * math.pi) * 3
		
	elseif orbitShape == "Subspace" then
		-- Subspace distortion
		local layers = 5
		local layer = math.floor((index - 1) / (total / layers)) % layers
		local subAngle = angle + layer * 0.5 + time * (1 + layer * 0.3)
		local subRadius = radius * (0.4 + layer * 0.15)
		local distort = math.sin(time * 5 + layer) * 1.5
		x = math.cos(subAngle) * subRadius + distort
		z = math.sin(subAngle) * subRadius + distort * 0.8
		y = height + layer * 2 - 4 + math.sin(time * 3 + layer) * 2
		
	elseif orbitShape == "Multiverse2" then
		-- Multiple universe bubbles
		local universes = 7
		local universe = math.floor((index - 1) / (total / universes)) % universes
		local uniAngle = universe / universes * math.pi * 2 + time * 0.5
		local uniRadius = radius * (0.6 + universe * 0.08)
		local bubble = math.sin(time * 2 + universe) * 0.3 + 1
		x = math.cos(uniAngle) * uniRadius * bubble
		z = math.sin(uniAngle) * uniRadius * bubble
		y = height + math.sin(time * 3 + universe) * 4
		
	elseif orbitShape == "Timeline" then
		-- Branching timelines
		local branches = 5
		local branch = math.floor((index - 1) / (total / branches)) % branches
		local branchAngle = branch / branches * math.pi * 2
		local branchProgress = ((index - 1) % (total / branches)) / (total / branches)
		local timeRadius = radius * (0.3 + branchProgress * 0.7)
		local diverge = branchProgress * 3 * math.sin(time * 2 + branch)
		x = math.cos(branchAngle) * timeRadius + diverge
		z = math.sin(branchAngle) * timeRadius + diverge * 0.7
		y = height + branchProgress * 10 - 5
		
	elseif orbitShape == "Paradox2" then
		-- Time paradox loop
		local loop = math.sin(time * 2) * 0.5 + 0.5
		local paradoxAngle = angle + time * 3
		local paradoxRadius = radius * (0.5 + loop * 0.5)
		local impossible = math.sin(angle * 5 + time * 4) * 3
		x = math.cos(paradoxAngle) * paradoxRadius + impossible
		z = math.sin(paradoxAngle) * paradoxRadius - impossible * 0.5
		y = height + math.sin(paradoxAngle * 2 + time * 2) * 4 * loop
		
	elseif orbitShape == "Infinity2" then
		-- Infinite loop with twist
		local t = angle + time
		local scale = radius * 0.15
		local twist = math.sin(time * 2) * math.pi * 0.5
		x = scale * math.sin(t) / (1 + math.cos(t)^2)
		z = scale * math.sin(t) * math.cos(t) / (1 + math.cos(t)^2)
		y = height + math.sin(t * 3 + twist) * 3
		
	elseif orbitShape == "Eternity" then
		-- Eternal spiral outward
		local eternityAngle = angle + (index / total) * math.pi * 10 + time * 0.5
		local eternityRadius = radius * (0.3 + (index / total) * 0.7)
		local eternal = math.sin(time * 1.5) * 0.3 + 1
		x = math.cos(eternityAngle) * eternityRadius * eternal
		z = math.sin(eternityAngle) * eternityRadius * eternal
		y = height + (index / total) * 12 - 6 + math.sin(time * 2 + index * 0.1) * 2
		
	elseif orbitShape == "Oblivion" then
		-- Void consumption
		local consume = math.sin(time * 2) * 0.5 + 0.5
		local oblivionAngle = angle + time * 4
		local oblivionRadius = radius * (1 - consume * 0.7)
		local fade = math.sin(time * 6 + index * 0.1) * 0.5 + 0.5
		x = math.cos(oblivionAngle) * oblivionRadius * fade
		z = math.sin(oblivionAngle) * oblivionRadius * fade
		y = height + math.sin(oblivionAngle * 3) * 3 * (1 - consume)
		
	-- 💫 30 MORE EPIC SHAPES 💫
	elseif orbitShape == "Celestial" then
		-- Heavenly divine orbit
		local divine = math.sin(time * 1.5) * 0.3 + 1
		local celestAngle = angle + math.sin(time * 2 + index * 0.2) * 0.5
		x = math.cos(celestAngle) * radius * divine
		z = math.sin(celestAngle) * radius * divine
		y = height + math.sin(time * 3 + index * 0.3) * 5 + math.cos(time * 2) * 2
		
	elseif orbitShape == "Astral" then
		-- Spirit plane projection
		local astralShift = math.sin(time + index * 0.3) * 3
		local phase = angle + time * 1.5
		x = math.cos(phase) * (radius + astralShift)
		z = math.sin(phase) * (radius + astralShift)
		y = height + math.sin(phase * 2) * 4 + math.cos(time * 3) * 2
		
	elseif orbitShape == "Cosmic2" then
		-- Advanced cosmic dance
		local cosmicWave = math.sin(time * 2 + index * 0.4) * 0.4 + 1
		local rotation = angle + time * 1.8
		x = math.cos(rotation) * radius * cosmicWave
		z = math.sin(rotation) * radius * cosmicWave
		y = height + math.sin(rotation * 3) * 6 + math.sin(time * 4) * 2
		
	elseif orbitShape == "Stellar2" then
		-- Star formation pattern
		local stellarPulse = math.sin(time * 3 + index * 0.2) * 0.3 + 1
		local starAngle = angle + math.cos(time * 2) * 0.8
		x = math.cos(starAngle) * radius * stellarPulse
		z = math.sin(starAngle) * radius * stellarPulse
		y = height + math.sin(starAngle * 4) * 3 + math.cos(time * 2.5) * 3
		
	elseif orbitShape == "Lunar2" then
		-- Moon phases orbit
		local phase = (math.sin(time) + 1) / 2
		local lunarAngle = angle + time * 1.2
		x = math.cos(lunarAngle) * radius * (0.7 + phase * 0.3)
		z = math.sin(lunarAngle) * radius * (0.7 + phase * 0.3)
		y = height + math.sin(time * 2 + index * 0.2) * 4
		
	elseif orbitShape == "Solar2" then
		-- Sun flare eruptions
		local flare = math.abs(math.sin(time * 4 + index * 0.5)) * 0.5
		local solarAngle = angle + time * 2
		x = math.cos(solarAngle) * (radius + flare * 5)
		z = math.sin(solarAngle) * (radius + flare * 5)
		y = height + math.sin(solarAngle * 2) * 3 + flare * 4
		
	elseif orbitShape == "Eclipse2" then
		-- Total eclipse alignment
		local alignment = math.sin(time * 1.5) * 0.5 + 0.5
		local eclipseAngle = angle + time * 1.3
		x = math.cos(eclipseAngle) * radius * (1 - alignment * 0.5)
		z = math.sin(eclipseAngle) * radius * (1 - alignment * 0.5)
		y = height + math.sin(eclipseAngle * 3) * (5 - alignment * 3)
		
	elseif orbitShape == "Comet2" then
		-- Comet tail trajectory
		local cometSpeed = time * 3 + index * 0.4
		local trail = math.sin(cometSpeed) * 0.4
		x = math.cos(angle + cometSpeed) * (radius + trail * 3)
		z = math.sin(angle + cometSpeed) * (radius + trail * 3)
		y = height + math.sin(cometSpeed * 2) * 6 + trail * 5
		
	elseif orbitShape == "Meteor2" then
		-- Meteor shower pattern
		local meteorFall = math.sin(time * 4 + index * 0.6) * 0.5 + 0.5
		local meteorAngle = angle + time * 2.5
		x = math.cos(meteorAngle) * radius
		z = math.sin(meteorAngle) * radius
		y = height + 10 - meteorFall * 15 + math.sin(time * 3) * 2
		
	elseif orbitShape == "Aurora2" then
		-- Northern lights wave
		local auroraWave = math.sin(time * 2 + index * 0.3) * 4
		local shimmer = math.cos(time * 4 + index * 0.5) * 2
		x = math.cos(angle) * radius + auroraWave
		z = math.sin(angle) * radius + shimmer
		y = height + math.sin(angle * 3 + time * 2) * 5
		
	elseif orbitShape == "Dimension" then
		-- Dimensional shift
		local dimShift = math.sin(time * 1.5 + index * 0.4) * 0.3
		local dimAngle = angle + time + dimShift * math.pi
		x = math.cos(dimAngle) * radius * (1 + dimShift)
		z = math.sin(dimAngle) * radius * (1 + dimShift)
		y = height + math.sin(dimAngle * 2) * 4 + dimShift * 6
		
	elseif orbitShape == "Realm" then
		-- Realm boundary
		local realmPulse = math.sin(time * 2) * 0.4 + 1
		local realmAngle = angle + math.sin(time * 1.5 + index * 0.3) * 0.6
		x = math.cos(realmAngle) * radius * realmPulse
		z = math.sin(realmAngle) * radius * realmPulse
		y = height + math.sin(realmAngle * 3) * 5
		
	elseif orbitShape == "Plane" then
		-- Planar existence
		local planeShift = math.sin(time + index * 0.2) * 2
		x = math.cos(angle + time * 1.5) * radius
		z = math.sin(angle + time * 1.5) * radius
		y = height + planeShift + math.sin(angle * 4) * 1
		
	elseif orbitShape == "Void2" then
		-- Advanced void
		local voidPull = math.sin(time * 2) * 0.6 + 0.4
		local voidAngle = angle + time * 1.8
		x = math.cos(voidAngle) * radius * voidPull
		z = math.sin(voidAngle) * radius * voidPull
		y = height + math.sin(voidAngle * 4) * 3 * voidPull
		
	elseif orbitShape == "Abyss2" then
		-- Deep abyss descent
		local descent = math.sin(time * 1.5) * 0.5 + 0.5
		local abyssAngle = angle + time * 2
		x = math.cos(abyssAngle) * radius * (1 - descent * 0.4)
		z = math.sin(abyssAngle) * radius * (1 - descent * 0.4)
		y = height - descent * 8 + math.sin(abyssAngle * 2) * 2
		
	elseif orbitShape == "Nexus" then
		-- Connection point
		local nexusConnect = math.sin(time * 3 + index * 0.5) * 0.3 + 1
		local nexusAngle = angle + time * 1.5
		x = math.cos(nexusAngle) * radius * nexusConnect
		z = math.sin(nexusAngle) * radius * nexusConnect
		y = height + math.sin(nexusAngle * 5) * 4
		
	elseif orbitShape == "Portal2" then
		-- Advanced portal vortex
		local portalSpin = time * 4 + index * 0.4
		local portalRadius = radius * (0.5 + math.sin(time * 2) * 0.5)
		x = math.cos(angle + portalSpin) * portalRadius
		z = math.sin(angle + portalSpin) * portalRadius
		y = height + math.sin(portalSpin * 2) * 5
		
	elseif orbitShape == "Gateway" then
		-- Gateway passage
		local passage = math.sin(time * 1.5) * 0.5 + 0.5
		local gateAngle = angle + time * 1.2
		x = math.cos(gateAngle) * (radius * (0.6 + passage * 0.4))
		z = math.sin(gateAngle) * (radius * (0.6 + passage * 0.4))
		y = height + passage * 6 + math.sin(gateAngle * 3) * 3
		
	elseif orbitShape == "Rift2" then
		-- Advanced reality rift
		local riftTear = math.sin(time * 3 + index * 0.4) * 0.4
		local riftAngle = angle + time * 2 + riftTear * 2
		x = math.cos(riftAngle) * (radius + riftTear * 4)
		z = math.sin(riftAngle) * (radius + riftTear * 4)
		y = height + math.sin(riftAngle * 4) * 5 + riftTear * 3
		
	elseif orbitShape == "Breach" then
		-- Dimensional breach
		local breachExpand = math.abs(math.sin(time * 2)) * 0.6
		local breachAngle = angle + time * 1.8
		x = math.cos(breachAngle) * radius * (1 + breachExpand)
		z = math.sin(breachAngle) * radius * (1 + breachExpand)
		y = height + math.sin(breachAngle * 3) * 4 + breachExpand * 5
		
	elseif orbitShape == "Titan" then
		-- Colossal titan march
		local titanStep = math.floor(time * 1.5) % 4
		local titanAngle = angle + (titanStep * math.pi / 2)
		x = math.cos(titanAngle) * radius * 1.2
		z = math.sin(titanAngle) * radius * 1.2
		y = height + math.abs(math.sin(time * 3)) * 4
		
	elseif orbitShape == "Colossus" then
		-- Massive colossus
		local colossalWeight = math.sin(time * 1.2) * 0.2 + 1
		local colossusAngle = angle + time * 0.8
		x = math.cos(colossusAngle) * radius * colossalWeight
		z = math.sin(colossusAngle) * radius * colossalWeight
		y = height + math.sin(colossusAngle * 2) * 3 - math.abs(math.sin(time * 2)) * 2
		
	elseif orbitShape == "Behemoth" then
		-- Behemoth stomp
		local stomp = math.abs(math.sin(time * 2.5)) * 0.5
		local behemothAngle = angle + time * 1.1
		x = math.cos(behemothAngle) * radius * (1.1 + stomp * 0.2)
		z = math.sin(behemothAngle) * radius * (1.1 + stomp * 0.2)
		y = height + math.sin(behemothAngle * 3) * 4 - stomp * 3
		
	elseif orbitShape == "Juggernaut" then
		-- Unstoppable force
		local juggerForce = time * 2
		local juggerAngle = angle + juggerForce
		x = math.cos(juggerAngle) * radius
		z = math.sin(juggerAngle) * radius
		y = height + math.sin(juggerForce * 1.5) * 3
		
	elseif orbitShape == "Leviathan3" then
		-- Ultimate leviathan
		local leviWave = math.sin(time * 1.5 + index * 0.3) * 6
		local leviAngle = angle + time * 1.3
		x = math.cos(leviAngle) * radius
		z = math.sin(leviAngle) * radius
		y = height + leviWave + math.sin(leviAngle * 4) * 3
		
	elseif orbitShape == "Omega" then
		-- The end
		local omegaEnd = math.sin(time * 1.5) * 0.3 + 1
		local omegaAngle = angle - time * 1.5
		x = math.cos(omegaAngle) * radius * omegaEnd
		z = math.sin(omegaAngle) * radius * omegaEnd
		y = height + math.sin(omegaAngle * 8) * 4
		
	elseif orbitShape == "Alpha" then
		-- The beginning
		local alphaStart = math.sin(time * 2) * 0.3 + 1
		local alphaAngle = angle + time * 2
		x = math.cos(alphaAngle) * radius * alphaStart
		z = math.sin(alphaAngle) * radius * alphaStart
		y = height + math.sin(alphaAngle * 6) * 5
		
	elseif orbitShape == "Sigma" then
		-- Sum of all
		local sigmaSum = 0
		for i = 1, 5 do
			sigmaSum = sigmaSum + math.sin(time * i + index * 0.2) * (1 / i)
		end
		x = math.cos(angle + time * 1.5) * radius
		z = math.sin(angle + time * 1.5) * radius
		y = height + sigmaSum * 3
		
	elseif orbitShape == "Delta" then
		-- Change pattern
		local deltaChange = math.sin(time * 2.5) * 0.4
		local deltaAngle = angle + time * 1.7 + deltaChange * math.pi
		x = math.cos(deltaAngle) * (radius + deltaChange * 3)
		z = math.sin(deltaAngle) * (radius + deltaChange * 3)
		y = height + math.sin(deltaAngle * 3) * 4
		
	elseif orbitShape == "Epsilon" then
		-- Small but mighty
		local epsilonPower = math.sin(time * 4 + index * 0.6) * 0.5 + 1
		local epsilonAngle = angle + time * 2.5
		x = math.cos(epsilonAngle) * radius * 0.8 * epsilonPower
		z = math.sin(epsilonAngle) * radius * 0.8 * epsilonPower
		y = height + math.sin(epsilonAngle * 7) * 6
		
	-- 🌊 MYTHICAL & LEGENDARY CREATURES 🌊
	elseif orbitShape == "Chimera" then
		local heads = 3
		local headAngle = angle + (index % heads) * (math.pi * 2 / heads)
		x = math.cos(headAngle) * radius * (1 + math.sin(time * 2) * 0.3)
		z = math.sin(headAngle) * radius * (1 + math.sin(time * 2) * 0.3)
		y = height + math.sin(time * 3 + index) * 4
		
	elseif orbitShape == "Cerberus" then
		local heads = 3
		local headRing = math.floor(index / heads)
		local headAngle = angle + (index % heads) * (math.pi * 2 / heads) + time
		x = math.cos(headAngle) * (radius + headRing * 3)
		z = math.sin(headAngle) * (radius + headRing * 3)
		y = height + math.sin(headAngle * 2) * 3
		
	elseif orbitShape == "Pegasus" then
		local wingBeat = math.sin(time * 4) * 0.5 + 0.5
		local flyAngle = angle + math.sin(time * 2) * 0.5
		x = math.cos(flyAngle) * radius
		z = math.sin(flyAngle) * radius
		y = height + math.sin(time * 3 + index * 0.5) * 8 * wingBeat
		
	elseif orbitShape == "Unicorn" then
		local hornSpiral = index / total * math.pi * 4
		x = math.cos(angle + hornSpiral * 0.2) * radius
		z = math.sin(angle + hornSpiral * 0.2) * radius
		y = height + hornSpiral * 2 + math.sin(time * 2) * 2
		
	elseif orbitShape == "Griffin" then
		local dive = math.sin(time * 2 + index * 0.3)
		x = math.cos(angle + time) * radius * (1 + dive * 0.4)
		z = math.sin(angle + time) * radius * (1 + dive * 0.4)
		y = height + dive * 10
		
	elseif orbitShape == "Basilisk" then
		local serpentine = math.sin(time * 3 + index * 0.8) * 3
		x = math.cos(angle) * (radius + serpentine)
		z = math.sin(angle) * (radius + serpentine)
		y = height + math.sin(index * 0.5) * 2
		
	elseif orbitShape == "Medusa" then
		local snakeHair = index % 8
		local snakeAngle = angle + snakeHair * (math.pi / 4) + time * 2
		x = math.cos(snakeAngle) * radius
		z = math.sin(snakeAngle) * radius
		y = height + math.sin(time * 4 + snakeHair) * 5
		
	elseif orbitShape == "Minotaur" then
		local charge = math.abs(math.sin(time * 1.5))
		x = math.cos(angle) * radius * (1 + charge * 0.5)
		z = math.sin(angle) * radius * (1 + charge * 0.5)
		y = height + math.sin(angle * 2) * 2
		
	elseif orbitShape == "Valkyrie" then
		local wings = math.sin(time * 3 + index * 0.4) * 6
		x = math.cos(angle + time * 0.5) * radius + wings
		z = math.sin(angle + time * 0.5) * radius
		y = height + math.abs(math.sin(time * 2)) * 10
		
	elseif orbitShape == "Golem" then
		local stomp = math.floor(time * 2) % 2 == 0 and 1 or 0.8
		x = math.cos(angle) * radius
		z = math.sin(angle) * radius
		y = height + math.sin(angle * 4) * 1 * stomp
		
	elseif orbitShape == "Djinn" then
		local smoke = math.sin(time * 2 + index * 0.6) * 4
		x = math.cos(angle + time) * (radius + smoke)
		z = math.sin(angle + time) * (radius + smoke)
		y = height + math.sin(time * 3) * 8
		
	elseif orbitShape == "Ifrit" then
		local flames = math.sin(time * 5 + index) * 3
		x = math.cos(angle + time * 2) * radius + flames
		z = math.sin(angle + time * 2) * radius + flames
		y = height + math.abs(math.sin(time * 4 + index)) * 12
		
	elseif orbitShape == "Seraph" then
		local wings = 6
		local wingLayer = math.floor(index / (total / wings))
		local wingAngle = angle + wingLayer * (math.pi * 2 / wings) + time
		x = math.cos(wingAngle) * (radius + wingLayer * 2)
		z = math.sin(wingAngle) * (radius + wingLayer * 2)
		y = height + math.sin(time * 2 + wingLayer) * 5
		
	elseif orbitShape == "Nephilim" then
		local divine = math.sin(time * 2) * 0.5 + 0.5
		x = math.cos(angle + time * 0.8) * radius * (1 + divine * 0.3)
		z = math.sin(angle + time * 0.8) * radius * (1 + divine * 0.3)
		y = height + math.sin(angle * 3) * 6 + divine * 4
		
	elseif orbitShape == "Demon" then
		local chaos = math.sin(time * 6 + index * 1.2) * 5
		x = math.cos(angle + chaos * 0.2) * radius
		z = math.sin(angle + chaos * 0.2) * radius
		y = height + math.sin(time * 4) * 8 + chaos
		
	elseif orbitShape == "Angel" then
		local halo = math.sin(time * 2) * 2
		x = math.cos(angle) * radius
		z = math.sin(angle) * radius
		y = height + 10 + halo + math.sin(angle * 2) * 3
		
	elseif orbitShape == "Wraith" then
		local fade = math.sin(time * 3 + index * 0.7) * 4
		x = math.cos(angle + time * 1.5) * (radius + fade)
		z = math.sin(angle + time * 1.5) * (radius + fade)
		y = height + math.sin(time * 2) * 6
		
	elseif orbitShape == "Specter" then
		local phase = math.sin(time * 4 + index) * 3
		x = math.cos(angle) * radius + phase
		z = math.sin(angle) * radius + phase
		y = height + math.sin(time * 3 + index * 0.5) * 7
		
	elseif orbitShape == "Banshee" then
		local wail = math.sin(time * 8 + index * 0.3) * 6
		x = math.cos(angle + time * 2) * radius
		z = math.sin(angle + time * 2) * radius
		y = height + wail
		
	elseif orbitShape == "Lich" then
		local necro = math.floor(time) % 3
		x = math.cos(angle + necro * 2) * radius
		z = math.sin(angle + necro * 2) * radius
		y = height + math.sin(angle * 3) * 4
		
	elseif orbitShape == "Vampire" then
		local bat = math.sin(time * 4 + index * 0.6) * 5
		x = math.cos(angle + time) * (radius + bat)
		z = math.sin(angle + time) * (radius + bat)
		y = height + math.abs(math.sin(time * 3)) * 8
		
	elseif orbitShape == "Werewolf" then
		local howl = math.sin(time * 2) * 4
		x = math.cos(angle + time * 1.5) * radius
		z = math.sin(angle + time * 1.5) * radius
		y = height + howl + math.sin(angle * 2) * 2
		
	elseif orbitShape == "Wendigo" then
		local hunt = math.sin(time * 3 + index * 0.8) * 6
		x = math.cos(angle) * (radius + hunt)
		z = math.sin(angle) * (radius + hunt)
		y = height + math.sin(time * 2) * 5
		
	elseif orbitShape == "Skinwalker" then
		local shift = math.floor(time * 2) % 4
		x = math.cos(angle + shift) * radius
		z = math.sin(angle + shift) * radius
		y = height + math.sin(angle * 3 + shift) * 4
		
	elseif orbitShape == "Yokai" then
		local spirit = math.sin(time * 3 + index * 0.5) * 4
		x = math.cos(angle + time) * radius
		z = math.sin(angle + time) * radius
		y = height + spirit + math.sin(angle * 2) * 3
		
	elseif orbitShape == "Kitsune" then
		local tails = 9
		local tailAngle = angle + (index % tails) * (math.pi * 2 / tails) + time * 0.5
		x = math.cos(tailAngle) * radius
		z = math.sin(tailAngle) * radius
		y = height + math.sin(tailAngle * 2) * 4
		
	elseif orbitShape == "Tengu" then
		local wind = math.sin(time * 4 + index * 0.4) * 5
		x = math.cos(angle + time * 1.5) * radius + wind
		z = math.sin(angle + time * 1.5) * radius
		y = height + math.abs(math.sin(time * 3)) * 10
		
	elseif orbitShape == "Oni" then
		local rage = math.sin(time * 2) * 3
		x = math.cos(angle) * (radius + rage)
		z = math.sin(angle) * (radius + rage)
		y = height + math.sin(angle * 4) * 2
		
	elseif orbitShape == "Kappa" then
		local water = math.sin(time * 2 + index * 0.6) * 3
		x = math.cos(angle + time) * radius
		z = math.sin(angle + time) * radius
		y = height - 2 + water
		
	elseif orbitShape == "Naga" then
		local coil = index / total * math.pi * 6
		x = math.cos(angle + coil * 0.3) * (radius + math.sin(coil) * 3)
		z = math.sin(angle + coil * 0.3) * (radius + math.sin(coil) * 3)
		y = height + coil * 0.5
		
	elseif orbitShape == "Garuda" then
		local swoop = math.sin(time * 2 + index * 0.4) * 8
		x = math.cos(angle + time) * radius
		z = math.sin(angle + time) * radius
		y = height + 12 + swoop
		
	elseif orbitShape == "Roc" then
		local giant = math.sin(time * 1.5) * 6
		x = math.cos(angle + time * 0.5) * (radius * 1.5)
		z = math.sin(angle + time * 0.5) * (radius * 1.5)
		y = height + 15 + giant
		
	elseif orbitShape == "Thunderbird" then
		local lightning = math.sin(time * 6 + index) * 4
		x = math.cos(angle + time * 2) * radius + lightning
		z = math.sin(angle + time * 2) * radius
		y = height + math.abs(math.sin(time * 3)) * 12
		
	elseif orbitShape == "Firebird" then
		local blaze = math.sin(time * 5 + index * 0.8) * 5
		x = math.cos(angle + time * 1.5) * (radius + blaze)
		z = math.sin(angle + time * 1.5) * (radius + blaze)
		y = height + math.sin(time * 4) * 10
		
	elseif orbitShape == "Icebird" then
		local frost = math.sin(time * 2 + index * 0.5) * 3
		x = math.cos(angle + time * 0.8) * radius
		z = math.sin(angle + time * 0.8) * radius
		y = height + frost + math.sin(angle * 3) * 6
		
	elseif orbitShape == "Sandworm" then
		local burrow = math.sin(time * 2 + index * 0.7)
		x = math.cos(angle + time) * radius
		z = math.sin(angle + time) * radius
		y = height + burrow * 8
		
	elseif orbitShape == "SeaSerpent" then
		local wave = math.sin(time * 3 + index * 0.6) * 4
		x = math.cos(angle + time * 0.8) * (radius + wave)
		z = math.sin(angle + time * 0.8) * (radius + wave)
		y = height + math.sin(angle * 4) * 3
		
	elseif orbitShape == "Skywhale" then
		local float = math.sin(time * 1.5 + index * 0.3) * 6
		x = math.cos(angle + time * 0.3) * radius
		z = math.sin(angle + time * 0.3) * radius
		y = height + 10 + float
		
	elseif orbitShape == "Voidbeast" then
		local distort = math.sin(time * 4 + index) * 5
		x = math.cos(angle + distort * 0.3) * (radius + distort)
		z = math.sin(angle + distort * 0.3) * (radius + distort)
		y = height + math.sin(time * 3) * 8
		
	elseif orbitShape == "Eldritch" then
		local madness = math.sin(time * 7 + index * 1.3) * 6
		x = math.cos(angle + madness * 0.4) * radius
		z = math.sin(angle + madness * 0.4) * radius
		y = height + madness + math.sin(time * 5) * 7
		
	-- 🎮 GAMING & ANIME REFERENCES 🎮
	elseif orbitShape == "Kamehameha" then
		local beam = index / total
		x = math.cos(angle) * radius * (1 - beam * 0.5)
		z = math.sin(angle) * radius * (1 - beam * 0.5)
		y = height + math.sin(time * 4 + beam * 10) * 2
		
	elseif orbitShape == "Rasengan" then
		local spiral = time * 8 + index * 0.8
		x = math.cos(angle + spiral) * (radius - index / total * radius * 0.7)
		z = math.sin(angle + spiral) * (radius - index / total * radius * 0.7)
		y = height + math.sin(spiral * 2) * 3
		
	elseif orbitShape == "Chidori" then
		local lightning = math.sin(time * 10 + index * 1.5) * 4
		x = math.cos(angle + time * 3) * radius + lightning
		z = math.sin(angle + time * 3) * radius + lightning
		y = height + math.sin(time * 8) * 5
		
	elseif orbitShape == "Susanoo" then
		local armor = math.floor(index / (total / 3))
		local layer = angle + armor * (math.pi * 2 / 3)
		x = math.cos(layer) * (radius + armor * 4)
		z = math.sin(layer) * (radius + armor * 4)
		y = height + armor * 3 + math.sin(time * 2) * 2
		
	elseif orbitShape == "Amaterasu" then
		local blackFlame = math.sin(time * 6 + index) * 5
		x = math.cos(angle + time * 2) * (radius + blackFlame)
		z = math.sin(angle + time * 2) * (radius + blackFlame)
		y = height + math.abs(math.sin(time * 4)) * 10
		
	elseif orbitShape == "Tsukuyomi" then
		local illusion = math.sin(time * 3 + index * 0.9) * 6
		x = math.cos(angle + illusion * 0.3) * radius
		z = math.sin(angle + illusion * 0.3) * radius
		y = height + illusion
		
	elseif orbitShape == "Izanagi" then
		local reality = math.floor(time * 2) % 2 == 0 and 1 or -1
		x = math.cos(angle + time) * radius * reality
		z = math.sin(angle + time) * radius * reality
		y = height + math.sin(angle * 3) * 4
		
	elseif orbitShape == "Kagutsuchi" then
		local inferno = math.sin(time * 5 + index * 0.7) * 6
		x = math.cos(angle + time * 2.5) * (radius + inferno)
		z = math.sin(angle + time * 2.5) * (radius + inferno)
		y = height + math.sin(time * 6) * 8
		
	elseif orbitShape == "Yasaka" then
		local magatama = index % 3
		local beadAngle = angle + magatama * (math.pi * 2 / 3) + time * 2
		x = math.cos(beadAngle) * radius
		z = math.sin(beadAngle) * radius
		y = height + math.sin(beadAngle * 2) * 4
		
	elseif orbitShape == "Totsuka" then
		local seal = index / total * math.pi * 4
		x = math.cos(angle + seal * 0.2) * radius
		z = math.sin(angle + seal * 0.2) * radius
		y = height + seal * 2
		
	elseif orbitShape == "Yata" then
		local mirror = math.sin(time * 2 + index * 0.5)
		x = math.cos(angle) * radius * (1 + mirror * 0.3)
		z = math.sin(angle) * radius * (1 + mirror * 0.3)
		y = height + math.abs(mirror) * 5
		
	elseif orbitShape == "Kirin" then
		local thunder = math.sin(time * 8 + index * 1.2) * 8
		x = math.cos(angle + time * 3) * radius
		z = math.sin(angle + time * 3) * radius
		y = height + 15 + thunder
		
	elseif orbitShape == "Rasenshuriken" then
		local blade = index % 4
		local bladeAngle = angle + blade * (math.pi / 2) + time * 6
		x = math.cos(bladeAngle) * (radius + math.sin(time * 4) * 3)
		z = math.sin(bladeAngle) * (radius + math.sin(time * 4) * 3)
		y = height + math.sin(bladeAngle * 3) * 4
		
	elseif orbitShape == "TailedBeast" then
		local tails = 9
		local tailAngle = angle + (index % tails) * (math.pi * 2 / tails)
		x = math.cos(tailAngle + time) * (radius + math.sin(time * 2) * 4)
		z = math.sin(tailAngle + time) * (radius + math.sin(time * 2) * 4)
		y = height + math.sin(tailAngle * 2) * 5
		
	elseif orbitShape == "Bijuu" then
		local chakra = math.sin(time * 4 + index * 0.8) * 6
		x = math.cos(angle + time * 1.5) * (radius + chakra)
		z = math.sin(angle + time * 1.5) * (radius + chakra)
		y = height + math.sin(time * 3) * 8
		
	elseif orbitShape == "Sharingan" then
		local tomoe = index % 3
		local eyeAngle = angle + tomoe * (math.pi * 2 / 3) + time * 2
		x = math.cos(eyeAngle) * radius
		z = math.sin(eyeAngle) * radius
		y = height + math.sin(time * 3) * 3
		
	elseif orbitShape == "Rinnegan" then
		local ripple = math.floor(index / (total / 6))
		x = math.cos(angle + time) * (radius - ripple * 2)
		z = math.sin(angle + time) * (radius - ripple * 2)
		y = height + math.sin(time * 2 + ripple) * 4
		
	elseif orbitShape == "Byakugan" then
		local veins = math.sin(time * 3 + index * 0.6) * 3
		x = math.cos(angle + time * 2) * (radius + veins)
		z = math.sin(angle + time * 2) * (radius + veins)
		y = height + math.sin(angle * 4) * 2
		
	elseif orbitShape == "Mangekyo" then
		local pattern = math.sin(time * 4 + index) * 4
		x = math.cos(angle + time * 3) * radius
		z = math.sin(angle + time * 3) * radius
		y = height + pattern
		
	elseif orbitShape == "EternalMS" then
		local eternal = math.sin(time * 2) * 5
		x = math.cos(angle + time) * (radius + eternal)
		z = math.sin(angle + time) * (radius + eternal)
		y = height + math.sin(angle * 3) * 6
		
	elseif orbitShape == "Bankai" then
		local release = math.sin(time * 3) * 0.5 + 1
		x = math.cos(angle + time * 2) * radius * release
		z = math.sin(angle + time * 2) * radius * release
		y = height + math.sin(time * 4 + index) * 10
		
	elseif orbitShape == "Shikai" then
		local awaken = math.sin(time * 2 + index * 0.5) * 4
		x = math.cos(angle + time) * (radius + awaken)
		z = math.sin(angle + time) * (radius + awaken)
		y = height + math.sin(angle * 3) * 5
		
	elseif orbitShape == "Resurreccion" then
		local hollow = math.sin(time * 4 + index * 0.8) * 6
		x = math.cos(angle + time * 2.5) * radius
		z = math.sin(angle + time * 2.5) * radius
		y = height + hollow
		
	elseif orbitShape == "Vollstandig" then
		local quincy = math.sin(time * 3) * 0.4 + 1
		x = math.cos(angle) * radius * quincy
		z = math.sin(angle) * radius * quincy
		y = height + math.sin(time * 5 + index) * 8
		
	elseif orbitShape == "Schrift" then
		local letter = math.sin(time * 4 + index * 0.7) * 5
		x = math.cos(angle + time * 1.5) * (radius + letter)
		z = math.sin(angle + time * 1.5) * (radius + letter)
		y = height + math.sin(angle * 2) * 4
		
	elseif orbitShape == "Zanpakuto" then
		local blade = index / total * math.pi * 3
		x = math.cos(angle + blade * 0.3 + time) * radius
		z = math.sin(angle + blade * 0.3 + time) * radius
		y = height + blade * 1.5
		
	elseif orbitShape == "Quincy" then
		local arrow = index / total
		x = math.cos(angle) * (radius + arrow * 5)
		z = math.sin(angle) * (radius + arrow * 5)
		y = height + math.sin(time * 3) * 3
		
	elseif orbitShape == "Hollow" then
		local mask = math.sin(time * 3 + index * 0.6) * 4
		x = math.cos(angle + time * 2) * (radius + mask)
		z = math.sin(angle + time * 2) * (radius + mask)
		y = height + math.sin(time * 4) * 6
		
	elseif orbitShape == "Arrancar" then
		local hierro = math.sin(time * 2) * 3
		x = math.cos(angle + time) * (radius + hierro)
		z = math.sin(angle + time) * (radius + hierro)
		y = height + math.sin(angle * 3) * 4
		
	elseif orbitShape == "Espada" then
		local number = index % 10
		x = math.cos(angle + number * (math.pi / 5) + time) * radius
		z = math.sin(angle + number * (math.pi / 5) + time) * radius
		y = height + number * 2
		
	elseif orbitShape == "Vizard" then
		local hybrid = math.sin(time * 3) * 0.5 + 0.5
		x = math.cos(angle + time * 2) * radius * (1 + hybrid * 0.4)
		z = math.sin(angle + time * 2) * radius * (1 + hybrid * 0.4)
		y = height + math.sin(time * 4 + index) * 7
		
	elseif orbitShape == "Fullbring" then
		local object = math.sin(time * 4 + index * 0.8) * 5
		x = math.cos(angle + time * 1.5) * (radius + object)
		z = math.sin(angle + time * 1.5) * (radius + object)
		y = height + math.sin(angle * 2) * 4
		
	elseif orbitShape == "Hogyoku" then
		local transcend = math.sin(time * 2) * 6
		x = math.cos(angle + time * 3) * (radius + transcend)
		z = math.sin(angle + time * 3) * (radius + transcend)
		y = height + math.sin(time * 5) * 10
		
	elseif orbitShape == "SoulKing" then
		local divine = math.sin(time * 1.5) * 8
		x = math.cos(angle + time * 0.5) * (radius + divine)
		z = math.sin(angle + time * 0.5) * (radius + divine)
		y = height + 12 + math.sin(time * 3) * 6
		
	elseif orbitShape == "ZeroSquad" then
		local royal = math.floor(index / (total / 5))
		x = math.cos(angle + royal * (math.pi * 2 / 5) + time) * (radius + royal * 3)
		z = math.sin(angle + royal * (math.pi * 2 / 5) + time) * (radius + royal * 3)
		y = height + royal * 4 + math.sin(time * 2) * 3
		
	elseif orbitShape == "StandArrow" then
		local pierce = index / total * 10
		x = math.cos(angle) * radius
		z = math.sin(angle) * radius
		y = height + pierce
		
	elseif orbitShape == "Requiem" then
		local truth = math.sin(time * 2 + index * 0.7) * 8
		x = math.cos(angle + time) * (radius + truth)
		z = math.sin(angle + time) * (radius + truth)
		y = height + math.sin(time * 3) * 10
		
	elseif orbitShape == "GoldExperience" then
		local life = math.sin(time * 4 + index * 0.6) * 5
		x = math.cos(angle + time * 2) * (radius + life)
		z = math.sin(angle + time * 2) * (radius + life)
		y = height + math.sin(time * 5) * 7
		
	elseif orbitShape == "StarPlatinum" then
		local ora = math.floor(time * 8) % 2 == 0 and 1 or 0.8
		x = math.cos(angle + time * 3) * radius * ora
		z = math.sin(angle + time * 3) * radius * ora
		y = height + math.sin(angle * 4) * 3
		
	elseif orbitShape == "TheWorld" then
		local stopped = math.sin(time * 0.5) * 10
		x = math.cos(angle + stopped * 0.1) * radius
		z = math.sin(angle + stopped * 0.1) * radius
		y = height + math.sin(time * 2) * 6
		
	-- 🌌 COSMIC & SCIENTIFIC 🌌
	elseif orbitShape == "Magnetar" then
		local magnetic = math.sin(time * 6 + index * 1.2) * 6
		x = math.cos(angle + time * 4) * (radius + magnetic)
		z = math.sin(angle + time * 4) * (radius + magnetic)
		y = height + math.sin(time * 8) * 8
		
	elseif orbitShape == "Neutron" then
		local dense = math.sin(time * 5) * 0.3 + 1
		x = math.cos(angle + time * 3) * radius * dense
		z = math.sin(angle + time * 3) * radius * dense
		y = height + math.sin(angle * 6) * 2
		
	elseif orbitShape == "WhiteDwarf" then
		local compact = math.sin(time * 2) * 2
		x = math.cos(angle + time) * (radius * 0.7 + compact)
		z = math.sin(angle + time) * (radius * 0.7 + compact)
		y = height + math.sin(angle * 3) * 3
		
	elseif orbitShape == "RedGiant" then
		local expand = math.sin(time * 1.5) * 0.5 + 1.5
		x = math.cos(angle + time * 0.5) * radius * expand
		z = math.sin(angle + time * 0.5) * radius * expand
		y = height + math.sin(time * 2) * 8
		
	elseif orbitShape == "BrownDwarf" then
		local dim = math.sin(time * 2 + index * 0.5) * 3
		x = math.cos(angle + time) * (radius * 0.8 + dim)
		z = math.sin(angle + time) * (radius * 0.8 + dim)
		y = height + math.sin(angle * 2) * 4
		
	elseif orbitShape == "Protostar" then
		local forming = math.sin(time * 3 + index * 0.7) * 5
		x = math.cos(angle + time * 2) * (radius + forming)
		z = math.sin(angle + time * 2) * (radius + forming)
		y = height + math.sin(time * 4) * 6
		
	elseif orbitShape == "Supergiant" then
		local massive = math.sin(time) * 0.6 + 2
		x = math.cos(angle + time * 0.3) * radius * massive
		z = math.sin(angle + time * 0.3) * radius * massive
		y = height + math.sin(time * 2) * 12
		
	elseif orbitShape == "Hypergiant" then
		local enormous = math.sin(time * 0.8) * 0.8 + 2.5
		x = math.cos(angle + time * 0.2) * radius * enormous
		z = math.sin(angle + time * 0.2) * radius * enormous
		y = height + math.sin(time * 1.5) * 15
		
	elseif orbitShape == "WolfRayet" then
		local wind = math.sin(time * 5 + index) * 7
		x = math.cos(angle + time * 3) * (radius + wind)
		z = math.sin(angle + time * 3) * (radius + wind)
		y = height + math.sin(time * 6) * 9
		
	elseif orbitShape == "Cepheid" then
		local pulse = math.sin(time * 2) * 0.4 + 1
		x = math.cos(angle + time) * radius * pulse
		z = math.sin(angle + time) * radius * pulse
		y = height + math.sin(time * 3) * 5
		
	elseif orbitShape == "Nebula2" then
		local cloud = math.sin(time * 2 + index * 0.6) * 6
		x = math.cos(angle + time * 0.5) * (radius + cloud)
		z = math.sin(angle + time * 0.5) * (radius + cloud)
		y = height + math.sin(time * 1.5 + index * 0.4) * 8
		
	elseif orbitShape == "Planetary" then
		local shell = math.sin(time * 3) * 4
		x = math.cos(angle + time * 2) * (radius + shell)
		z = math.sin(angle + time * 2) * (radius + shell)
		y = height + math.sin(angle * 3) * 5
		
	elseif orbitShape == "Emission" then
		local glow = math.sin(time * 4 + index * 0.8) * 5
		x = math.cos(angle + time * 2) * (radius + glow)
		z = math.sin(angle + time * 2) * (radius + glow)
		y = height + math.sin(time * 5) * 7
		
	elseif orbitShape == "Reflection" then
		local mirror = math.sin(time * 2 + index * 0.5)
		x = math.cos(angle + time) * radius * (1 + mirror * 0.4)
		z = math.sin(angle + time) * radius * (1 + mirror * 0.4)
		y = height + math.abs(mirror) * 6
		
	elseif orbitShape == "Dark" then
		local obscure = math.sin(time * 3 + index * 0.7) * 4
		x = math.cos(angle + time * 1.5) * (radius + obscure)
		z = math.sin(angle + time * 1.5) * (radius + obscure)
		y = height + math.sin(time * 2) * 5
		
	elseif orbitShape == "Molecular" then
		local bond = math.sin(time * 4 + index * 0.9) * 3
		x = math.cos(angle + time * 2) * (radius + bond)
		z = math.sin(angle + time * 2) * (radius + bond)
		y = height + math.sin(angle * 4) * 4
		
	elseif orbitShape == "Supernova2" then
		local explode = math.sin(time * 2) * 0.8 + 1.5
		x = math.cos(angle + time * 4) * radius * explode
		z = math.sin(angle + time * 4) * radius * explode
		y = height + math.sin(time * 6 + index) * 12
		
	elseif orbitShape == "Hypernova" then
		local massive = math.sin(time * 1.5) * 1 + 2
		x = math.cos(angle + time * 5) * radius * massive
		z = math.sin(angle + time * 5) * radius * massive
		y = height + math.sin(time * 7 + index) * 15
		
	elseif orbitShape == "Kilonova" then
		local merge = math.sin(time * 3) * 0.6 + 1.2
		x = math.cos(angle + time * 3) * radius * merge
		z = math.sin(angle + time * 3) * radius * merge
		y = height + math.sin(time * 5) * 10
		
	elseif orbitShape == "Gamma" then
		local burst = math.sin(time * 8 + index * 1.5) * 8
		x = math.cos(angle + time * 4) * (radius + burst)
		z = math.sin(angle + time * 4) * (radius + burst)
		y = height + math.sin(time * 10) * 12
		
	elseif orbitShape == "XRay" then
		local penetrate = math.sin(time * 6 + index) * 5
		x = math.cos(angle + time * 3) * (radius + penetrate)
		z = math.sin(angle + time * 3) * (radius + penetrate)
		y = height + math.sin(time * 7) * 8
		
	elseif orbitShape == "Cosmic" then
		local ray = math.sin(time * 5 + index * 0.8) * 7
		x = math.cos(angle + time * 2.5) * (radius + ray)
		z = math.sin(angle + time * 2.5) * (radius + ray)
		y = height + math.sin(time * 6) * 10
		
	elseif orbitShape == "Microwave" then
		local wave = math.sin(time * 4 + index * 1.2) * 4
		x = math.cos(angle + time * 2) * (radius + wave)
		z = math.sin(angle + time * 2) * (radius + wave)
		y = height + math.sin(angle * 5) * 5
		
	elseif orbitShape == "Infrared" then
		local heat = math.sin(time * 3 + index * 0.6) * 4
		x = math.cos(angle + time * 1.5) * (radius + heat)
		z = math.sin(angle + time * 1.5) * (radius + heat)
		y = height + math.sin(time * 4) * 6
		
	elseif orbitShape == "Ultraviolet" then
		local uv = math.sin(time * 5 + index * 0.9) * 5
		x = math.cos(angle + time * 2.5) * (radius + uv)
		z = math.sin(angle + time * 2.5) * (radius + uv)
		y = height + math.sin(time * 6) * 7
		
	elseif orbitShape == "Gravitational" then
		local wave = math.sin(time * 2 + index * 0.4) * 6
		x = math.cos(angle + time) * (radius + wave)
		z = math.sin(angle + time) * (radius + wave)
		y = height + math.sin(time * 3) * 8
		
	elseif orbitShape == "Spacetime2" then
		local warp = math.sin(time * 3 + index * 0.7) * 5
		x = math.cos(angle + warp * 0.3) * (radius + warp)
		z = math.sin(angle + warp * 0.3) * (radius + warp)
		y = height + math.sin(time * 4) * 7
		
	elseif orbitShape == "Curvature" then
		local bend = math.sin(time * 2 + index * 0.5) * 4
		x = math.cos(angle + bend * 0.4) * radius
		z = math.sin(angle + bend * 0.4) * radius
		y = height + bend
		
	elseif orbitShape == "EventHorizon" then
		local edge = math.sin(time * 3) * 0.3 + 1
		x = math.cos(angle + time * 4) * radius * edge
		z = math.sin(angle + time * 4) * radius * edge
		y = height + math.sin(time * 5 + index) * 6
		
	elseif orbitShape == "Accretion" then
		local disk = math.sin(time * 4 + index * 0.8) * 3
		x = math.cos(angle + time * 3) * (radius + disk)
		z = math.sin(angle + time * 3) * (radius + disk)
		y = height + math.sin(angle * 6) * 2
		
	elseif orbitShape == "Ergosphere" then
		local drag = math.sin(time * 3 + index * 0.6) * 5
		x = math.cos(angle + time * 2 + drag * 0.2) * radius
		z = math.sin(angle + time * 2 + drag * 0.2) * radius
		y = height + drag
		
	elseif orbitShape == "Photosphere" then
		local surface = math.sin(time * 2 + index * 0.5) * 3
		x = math.cos(angle + time) * (radius + surface)
		z = math.sin(angle + time) * (radius + surface)
		y = height + math.sin(angle * 3) * 4
		
	elseif orbitShape == "Chromosphere" then
		local layer = math.sin(time * 3 + index * 0.7) * 4
		x = math.cos(angle + time * 1.5) * (radius + layer)
		z = math.sin(angle + time * 1.5) * (radius + layer)
		y = height + math.sin(time * 4) * 5
		
	elseif orbitShape == "Corona" then
		local plasma = math.sin(time * 4 + index) * 8
		x = math.cos(angle + time * 2) * (radius + plasma)
		z = math.sin(angle + time * 2) * (radius + plasma)
		y = height + math.sin(time * 5) * 10
		
	elseif orbitShape == "Prominence" then
		local loop = math.sin(time * 2 + index * 0.6) * 10
		x = math.cos(angle + time) * radius
		z = math.sin(angle + time) * radius
		y = height + loop
		
	elseif orbitShape == "Flare" then
		local burst = math.sin(time * 6 + index * 1.2) * 12
		x = math.cos(angle + time * 3) * radius
		z = math.sin(angle + time * 3) * radius
		y = height + burst
		
	elseif orbitShape == "Sunspot" then
		local spot = math.sin(time * 2 + index * 0.5) * 2
		x = math.cos(angle + time * 0.5) * (radius - spot)
		z = math.sin(angle + time * 0.5) * (radius - spot)
		y = height + math.sin(angle * 4) * 3
		
	elseif orbitShape == "Coronal" then
		local mass = math.sin(time * 3 + index * 0.8) * 9
		x = math.cos(angle + time * 2) * (radius + mass)
		z = math.sin(angle + time * 2) * (radius + mass)
		y = height + math.sin(time * 4) * 8
		
	elseif orbitShape == "Heliosphere" then
		local bubble = math.sin(time * 1.5) * 0.5 + 1.5
		x = math.cos(angle + time * 0.5) * radius * bubble
		z = math.sin(angle + time * 0.5) * radius * bubble
		y = height + math.sin(time * 2 + index * 0.4) * 7
		
	elseif orbitShape == "Magnetosphere" then
		local field = math.sin(time * 3 + index * 0.7) * 6
		x = math.cos(angle + time * 1.5) * (radius + field)
		z = math.sin(angle + time * 1.5) * (radius + field)
		y = height + math.sin(time * 4) * 8
		
	-- 🔮 MAGICAL & MYSTICAL 🔮
	elseif orbitShape == "Arcane" then
		local magic = math.sin(time * 3 + index * 0.8) * 5
		x = math.cos(angle + time * 2) * (radius + magic)
		z = math.sin(angle + time * 2) * (radius + magic)
		y = height + math.sin(time * 4 + index) * 7
		
	elseif orbitShape == "Mystic" then
		local mystery = math.sin(time * 2 + index * 0.6) * 6
		x = math.cos(angle + time * 1.5) * (radius + mystery)
		z = math.sin(angle + time * 1.5) * (radius + mystery)
		y = height + math.sin(time * 3) * 8
		
	elseif orbitShape == "Occult" then
		local hidden = math.sin(time * 4 + index) * 4
		x = math.cos(angle + time * 2.5) * (radius + hidden)
		z = math.sin(angle + time * 2.5) * (radius + hidden)
		y = height + math.sin(time * 5) * 6
		
	elseif orbitShape == "Esoteric" then
		local secret = math.sin(time * 3 + index * 0.7) * 5
		x = math.cos(angle + time * 2) * (radius + secret)
		z = math.sin(angle + time * 2) * (radius + secret)
		y = height + math.sin(time * 4) * 7
		
	elseif orbitShape == "Hermetic" then
		local alchemy = math.sin(time * 2 + index * 0.5) * 4
		x = math.cos(angle + time) * (radius + alchemy)
		z = math.sin(angle + time) * (radius + alchemy)
		y = height + math.sin(angle * 3) * 5
		
	elseif orbitShape == "Kabbalah" then
		local tree = math.floor(index / (total / 10))
		x = math.cos(angle + tree * (math.pi / 5)) * (radius + tree * 2)
		z = math.sin(angle + tree * (math.pi / 5)) * (radius + tree * 2)
		y = height + tree * 3
		
	elseif orbitShape == "Alchemy" then
		local transmute = math.sin(time * 3 + index * 0.8) * 5
		x = math.cos(angle + time * 2) * (radius + transmute)
		z = math.sin(angle + time * 2) * (radius + transmute)
		y = height + math.sin(time * 4) * 6
		
	elseif orbitShape == "Transmutation" then
		local change = math.sin(time * 4 + index) * 6
		x = math.cos(angle + time * 2.5) * (radius + change)
		z = math.sin(angle + time * 2.5) * (radius + change)
		y = height + math.sin(time * 5) * 8
		
	elseif orbitShape == "Philosopher" then
		local stone = math.sin(time * 2) * 0.4 + 1
		x = math.cos(angle + time) * radius * stone
		z = math.sin(angle + time) * radius * stone
		y = height + math.sin(time * 3 + index) * 7
		
	elseif orbitShape == "Elixir" then
		local potion = math.sin(time * 3 + index * 0.6) * 5
		x = math.cos(angle + time * 1.5) * (radius + potion)
		z = math.sin(angle + time * 1.5) * (radius + potion)
		y = height + math.sin(time * 4) * 6
		
	elseif orbitShape == "Grimoire" then
		local pages = math.sin(time * 4 + index * 0.9) * 4
		x = math.cos(angle + time * 2) * (radius + pages)
		z = math.sin(angle + time * 2) * (radius + pages)
		y = height + math.sin(angle * 3) * 5
		
	elseif orbitShape == "Spellbook" then
		local spell = math.sin(time * 3 + index * 0.7) * 5
		x = math.cos(angle + time * 1.5) * (radius + spell)
		z = math.sin(angle + time * 1.5) * (radius + spell)
		y = height + math.sin(time * 4) * 6
		
	elseif orbitShape == "Enchantment" then
		local enchant = math.sin(time * 2 + index * 0.5) * 4
		x = math.cos(angle + time) * (radius + enchant)
		z = math.sin(angle + time) * (radius + enchant)
		y = height + math.sin(time * 3) * 7
		
	elseif orbitShape == "Hex" then
		local curse = math.sin(time * 5 + index) * 6
		x = math.cos(angle + time * 3) * (radius + curse)
		z = math.sin(angle + time * 3) * (radius + curse)
		y = height + math.sin(time * 6) * 8
		
	elseif orbitShape == "Curse" then
		local dark = math.sin(time * 4 + index * 0.8) * 5
		x = math.cos(angle + time * 2) * (radius + dark)
		z = math.sin(angle + time * 2) * (radius + dark)
		y = height + math.sin(time * 5) * 7
		
	elseif orbitShape == "Blessing" then
		local holy = math.sin(time * 2 + index * 0.4) * 4
		x = math.cos(angle + time) * (radius + holy)
		z = math.sin(angle + time) * (radius + holy)
		y = height + 8 + math.sin(time * 3) * 5
		
	elseif orbitShape == "Ward" then
		local protect = math.sin(time * 3) * 0.3 + 1
		x = math.cos(angle + time * 2) * radius * protect
		z = math.sin(angle + time * 2) * radius * protect
		y = height + math.sin(angle * 4) * 4
		
	elseif orbitShape == "Seal" then
		local bind = math.sin(time * 2 + index * 0.6) * 3
		x = math.cos(angle + time) * (radius - bind)
		z = math.sin(angle + time) * (radius - bind)
		y = height + math.sin(angle * 3) * 4
		
	elseif orbitShape == "Sigil" then
		local mark = math.sin(time * 4 + index * 0.9) * 5
		x = math.cos(angle + time * 2) * (radius + mark)
		z = math.sin(angle + time * 2) * (radius + mark)
		y = height + math.sin(time * 5) * 6
		
	elseif orbitShape == "Rune" then
		local ancient = math.sin(time * 3 + index * 0.7) * 4
		x = math.cos(angle + time * 1.5) * (radius + ancient)
		z = math.sin(angle + time * 1.5) * (radius + ancient)
		y = height + math.sin(angle * 4) * 5
		
	elseif orbitShape == "Glyph" then
		local symbol = math.sin(time * 4 + index * 0.8) * 5
		x = math.cos(angle + time * 2) * (radius + symbol)
		z = math.sin(angle + time * 2) * (radius + symbol)
		y = height + math.sin(time * 5) * 6
		
	elseif orbitShape == "Talisman" then
		local charm = math.sin(time * 2 + index * 0.5) * 4
		x = math.cos(angle + time) * (radius + charm)
		z = math.sin(angle + time) * (radius + charm)
		y = height + math.sin(time * 3) * 5
		
	elseif orbitShape == "Amulet" then
		local pendant = math.sin(time * 3 + index * 0.6) * 4
		x = math.cos(angle + time * 1.5) * (radius + pendant)
		z = math.sin(angle + time * 1.5) * (radius + pendant)
		y = height + math.sin(time * 4) * 6
		
	elseif orbitShape == "Charm" then
		local lucky = math.sin(time * 4 + index * 0.8) * 5
		x = math.cos(angle + time * 2) * (radius + lucky)
		z = math.sin(angle + time * 2) * (radius + lucky)
		y = height + math.sin(time * 5) * 7
		
	elseif orbitShape == "Totem" then
		local spirit = math.sin(time * 2 + index * 0.5) * 4
		x = math.cos(angle + time) * (radius + spirit)
		z = math.sin(angle + time) * (radius + spirit)
		y = height + index / total * 10
		
	elseif orbitShape == "Familiar" then
		local companion = math.sin(time * 3 + index * 0.7) * 5
		x = math.cos(angle + time * 2) * (radius + companion)
		z = math.sin(angle + time * 2) * (radius + companion)
		y = height + math.sin(time * 4) * 6
		
	elseif orbitShape == "Summoning" then
		local circle = math.sin(time * 2) * 0.4 + 1
		x = math.cos(angle + time * 3) * radius * circle
		z = math.sin(angle + time * 3) * radius * circle
		y = height + math.sin(time * 4 + index) * 8
		
	elseif orbitShape == "Conjuration" then
		local manifest = math.sin(time * 3 + index * 0.8) * 6
		x = math.cos(angle + time * 2) * (radius + manifest)
		z = math.sin(angle + time * 2) * (radius + manifest)
		y = height + math.sin(time * 5) * 7
		
	elseif orbitShape == "Evocation" then
		local call = math.sin(time * 4 + index) * 7
		x = math.cos(angle + time * 2.5) * (radius + call)
		z = math.sin(angle + time * 2.5) * (radius + call)
		y = height + math.sin(time * 6) * 9
		
	elseif orbitShape == "Divination" then
		local foresee = math.sin(time * 2 + index * 0.6) * 5
		x = math.cos(angle + time * 1.5) * (radius + foresee)
		z = math.sin(angle + time * 1.5) * (radius + foresee)
		y = height + math.sin(time * 3) * 6
		
	elseif orbitShape == "Necromancy" then
		local undead = math.sin(time * 3 + index * 0.7) * 5
		x = math.cos(angle + time * 2) * (radius + undead)
		z = math.sin(angle + time * 2) * (radius + undead)
		y = height + math.sin(time * 4) * 6
		
	elseif orbitShape == "Pyromancy" then
		local fire = math.sin(time * 5 + index) * 7
		x = math.cos(angle + time * 3) * (radius + fire)
		z = math.sin(angle + time * 3) * (radius + fire)
		y = height + math.abs(math.sin(time * 6)) * 10
		
	elseif orbitShape == "Cryomancy" then
		local ice = math.sin(time * 2 + index * 0.5) * 4
		x = math.cos(angle + time) * (radius + ice)
		z = math.sin(angle + time) * (radius + ice)
		y = height + math.sin(time * 3) * 5
		
	elseif orbitShape == "Geomancy" then
		local earth = math.sin(time * 1.5 + index * 0.4) * 3
		x = math.cos(angle + time * 0.5) * (radius + earth)
		z = math.sin(angle + time * 0.5) * (radius + earth)
		y = height + math.sin(angle * 3) * 4
		
	elseif orbitShape == "Aeromancy" then
		local wind = math.sin(time * 4 + index * 0.8) * 6
		x = math.cos(angle + time * 2.5) * (radius + wind)
		z = math.sin(angle + time * 2.5) * (radius + wind)
		y = height + math.sin(time * 5) * 8
		
	elseif orbitShape == "Hydromancy" then
		local water = math.sin(time * 3 + index * 0.6) * 5
		x = math.cos(angle + time * 1.5) * (radius + water)
		z = math.sin(angle + time * 1.5) * (radius + water)
		y = height + math.sin(time * 4) * 6
		
	elseif orbitShape == "Electromancy" then
		local lightning = math.sin(time * 8 + index * 1.2) * 7
		x = math.cos(angle + time * 4) * (radius + lightning)
		z = math.sin(angle + time * 4) * (radius + lightning)
		y = height + math.sin(time * 10) * 9
		
	elseif orbitShape == "Photomancy" then
		local light = math.sin(time * 4 + index * 0.8) * 6
		x = math.cos(angle + time * 2) * (radius + light)
		z = math.sin(angle + time * 2) * (radius + light)
		y = height + math.sin(time * 5) * 8
		
	elseif orbitShape == "Umbramancy" then
		local shadow = math.sin(time * 3 + index * 0.7) * 5
		x = math.cos(angle + time * 1.5) * (radius + shadow)
		z = math.sin(angle + time * 1.5) * (radius + shadow)
		y = height + math.sin(time * 4) * 6
		
	elseif orbitShape == "Chronomancy" then
		local time_warp = math.sin(time * 2 + index * 0.5) * 6
		x = math.cos(angle + time_warp * 0.3) * (radius + time_warp)
		z = math.sin(angle + time_warp * 0.3) * (radius + time_warp)
		y = height + math.sin(time * 3) * 7
		
	-- ⚔️ WEAPONS & COMBAT ⚔️
	elseif orbitShape == "Katana" then
		local slash = index / total * math.pi * 2
		x = math.cos(angle + slash + time) * radius
		z = math.sin(angle + slash + time) * radius
		y = height + slash * 1.5
		
	elseif orbitShape == "Nodachi" then
		local long = index / total * math.pi * 3
		x = math.cos(angle + long * 0.3 + time) * radius
		z = math.sin(angle + long * 0.3 + time) * radius
		y = height + long * 2
		
	elseif orbitShape == "Wakizashi" then
		local short = index / total * math.pi * 1.5
		x = math.cos(angle + short + time * 2) * radius
		z = math.sin(angle + short + time * 2) * radius
		y = height + short
		
	elseif orbitShape == "Tanto" then
		local dagger = math.sin(time * 4 + index) * 3
		x = math.cos(angle + time * 3) * (radius + dagger)
		z = math.sin(angle + time * 3) * (radius + dagger)
		y = height + math.sin(angle * 5) * 2
		
	elseif orbitShape == "Naginata" then
		local pole = index / total * 12
		x = math.cos(angle + time) * radius
		z = math.sin(angle + time) * radius
		y = height + pole
		
	elseif orbitShape == "Yari" then
		local spear = index / total * 10
		x = math.cos(angle + time * 1.5) * radius
		z = math.sin(angle + time * 1.5) * radius
		y = height + spear
		
	elseif orbitShape == "Kusarigama" then
		local chain = math.sin(time * 3 + index * 0.7) * 5
		x = math.cos(angle + time * 2) * (radius + chain)
		z = math.sin(angle + time * 2) * (radius + chain)
		y = height + math.sin(time * 4) * 6
		
	elseif orbitShape == "Kunai" then
		local throw = index / total * 8
		x = math.cos(angle + time * 3) * (radius + throw * 0.5)
		z = math.sin(angle + time * 3) * (radius + throw * 0.5)
		y = height + throw
		
	elseif orbitShape == "Shuriken2" then
		local star = index % 4
		local starAngle = angle + star * (math.pi / 2) + time * 5
		x = math.cos(starAngle) * radius
		z = math.sin(starAngle) * radius
		y = height + math.sin(starAngle * 2) * 3
		
	elseif orbitShape == "Sai" then
		local prong = index % 3
		local prongAngle = angle + prong * (math.pi * 2 / 3) + time * 2
		x = math.cos(prongAngle) * radius
		z = math.sin(prongAngle) * radius
		y = height + math.sin(prongAngle * 2) * 4
		
	elseif orbitShape == "Tonfa" then
		local spin = time * 6 + index * 0.8
		x = math.cos(angle + spin) * radius
		z = math.sin(angle + spin) * radius
		y = height + math.sin(spin * 2) * 3
		
	elseif orbitShape == "Nunchaku" then
		local swing = math.sin(time * 4 + index * 0.6) * 5
		x = math.cos(angle + time * 2) * (radius + swing)
		z = math.sin(angle + time * 2) * (radius + swing)
		y = height + math.sin(time * 5) * 6
		
	elseif orbitShape == "Bo" then
		local staff = index / total * 10
		x = math.cos(angle + time) * radius
		z = math.sin(angle + time) * radius
		y = height + staff
		
	elseif orbitShape == "Jo" then
		local stick = index / total * 8
		x = math.cos(angle + time * 1.5) * radius
		z = math.sin(angle + time * 1.5) * radius
		y = height + stick
		
	elseif orbitShape == "Kama" then
		local sickle = math.sin(time * 3 + index * 0.7) * 4
		x = math.cos(angle + time * 2) * (radius + sickle)
		z = math.sin(angle + time * 2) * (radius + sickle)
		y = height + math.sin(angle * 4) * 3
		
	elseif orbitShape == "Claymore" then
		local great = index / total * math.pi * 2.5
		x = math.cos(angle + great * 0.4 + time) * radius
		z = math.sin(angle + great * 0.4 + time) * radius
		y = height + great * 2.5
		
	elseif orbitShape == "Longsword" then
		local blade = index / total * math.pi * 2
		x = math.cos(angle + blade * 0.5 + time) * radius
		z = math.sin(angle + blade * 0.5 + time) * radius
		y = height + blade * 2
		
	elseif orbitShape == "Broadsword" then
		local wide = index / total * math.pi * 2
		x = math.cos(angle + wide * 0.5 + time) * (radius * 1.2)
		z = math.sin(angle + wide * 0.5 + time) * (radius * 1.2)
		y = height + wide * 1.8
		
	elseif orbitShape == "Rapier" then
		local thrust = index / total * 12
		x = math.cos(angle + time * 2) * radius
		z = math.sin(angle + time * 2) * radius
		y = height + thrust
		
	elseif orbitShape == "Saber" then
		local curve = index / total * math.pi * 2
		x = math.cos(angle + curve * 0.6 + time) * radius
		z = math.sin(angle + curve * 0.6 + time) * radius
		y = height + curve * 1.5
		
	elseif orbitShape == "Cutlass" then
		local pirate = math.sin(time * 3 + index * 0.7) * 4
		x = math.cos(angle + time * 2) * (radius + pirate)
		z = math.sin(angle + time * 2) * (radius + pirate)
		y = height + math.sin(angle * 3) * 5
		
	elseif orbitShape == "Scimitar" then
		local curved = index / total * math.pi * 2
		x = math.cos(angle + curved * 0.7 + time) * radius
		z = math.sin(angle + curved * 0.7 + time) * radius
		y = height + curved * 1.6
		
	elseif orbitShape == "Falchion" then
		local heavy = index / total * math.pi * 2
		x = math.cos(angle + heavy * 0.5 + time) * (radius * 1.1)
		z = math.sin(angle + heavy * 0.5 + time) * (radius * 1.1)
		y = height + heavy * 1.7
		
	elseif orbitShape == "Gladius" then
		local roman = index / total * math.pi * 1.5
		x = math.cos(angle + roman * 0.6 + time) * radius
		z = math.sin(angle + roman * 0.6 + time) * radius
		y = height + roman * 1.5
		
	elseif orbitShape == "Spatha" then
		local cavalry = index / total * math.pi * 2
		x = math.cos(angle + cavalry * 0.5 + time) * radius
		z = math.sin(angle + cavalry * 0.5 + time) * radius
		y = height + cavalry * 2
		
	elseif orbitShape == "Halberd" then
		local pole = index / total * 12
		x = math.cos(angle + time * 0.8) * radius
		z = math.sin(angle + time * 0.8) * radius
		y = height + pole
		
	elseif orbitShape == "Glaive2" then
		local pole_blade = index / total * 11
		x = math.cos(angle + time) * radius
		z = math.sin(angle + time) * radius
		y = height + pole_blade
		
	elseif orbitShape == "Bardiche" then
		local axe_pole = index / total * 10
		x = math.cos(angle + time * 0.9) * radius
		z = math.sin(angle + time * 0.9) * radius
		y = height + axe_pole
		
	elseif orbitShape == "Partisan" then
		local trident = index / total * 11
		x = math.cos(angle + time) * radius
		z = math.sin(angle + time) * radius
		y = height + trident
		
	elseif orbitShape == "Ranseur" then
		local fork = index / total * 10
		x = math.cos(angle + time * 1.1) * radius
		z = math.sin(angle + time * 1.1) * radius
		y = height + fork
		
	elseif orbitShape == "Warhammer" then
		local smash = math.sin(time * 2 + index * 0.5) * 4
		x = math.cos(angle + time) * (radius + smash)
		z = math.sin(angle + time) * (radius + smash)
		y = height + math.abs(math.sin(time * 3)) * 6
		
	elseif orbitShape == "Maul" then
		local crush = math.sin(time * 1.5 + index * 0.4) * 5
		x = math.cos(angle + time * 0.8) * (radius + crush)
		z = math.sin(angle + time * 0.8) * (radius + crush)
		y = height + math.abs(math.sin(time * 2.5)) * 7
		
	elseif orbitShape == "Mace" then
		local bash = math.sin(time * 3 + index * 0.6) * 4
		x = math.cos(angle + time * 1.5) * (radius + bash)
		z = math.sin(angle + time * 1.5) * (radius + bash)
		y = height + math.sin(angle * 3) * 5
		
	elseif orbitShape == "Flail" then
		local chain = math.sin(time * 4 + index * 0.8) * 6
		x = math.cos(angle + time * 2) * (radius + chain)
		z = math.sin(angle + time * 2) * (radius + chain)
		y = height + math.sin(time * 5) * 7
		
	elseif orbitShape == "Morningstar" then
		local spike = math.sin(time * 3 + index * 0.7) * 5
		x = math.cos(angle + time * 1.5) * (radius + spike)
		z = math.sin(angle + time * 1.5) * (radius + spike)
		y = height + math.sin(time * 4) * 6
		
	elseif orbitShape == "Battleaxe" then
		local cleave = index / total * math.pi * 2
		x = math.cos(angle + cleave * 0.5 + time) * (radius * 1.2)
		z = math.sin(angle + cleave * 0.5 + time) * (radius * 1.2)
		y = height + cleave * 2
		
	elseif orbitShape == "Greataxe" then
		local massive = index / total * math.pi * 2.5
		x = math.cos(angle + massive * 0.4 + time) * (radius * 1.3)
		z = math.sin(angle + massive * 0.4 + time) * (radius * 1.3)
		y = height + massive * 2.5
		
	elseif orbitShape == "Tomahawk" then
		local throw = math.sin(time * 5 + index) * 6
		x = math.cos(angle + time * 3) * (radius + throw)
		z = math.sin(angle + time * 3) * (radius + throw)
		y = height + math.sin(time * 6) * 5
		
	elseif orbitShape == "Francisca" then
		local throwing = math.sin(time * 4 + index * 0.8) * 5
		x = math.cos(angle + time * 2.5) * (radius + throwing)
		z = math.sin(angle + time * 2.5) * (radius + throwing)
		y = height + math.sin(time * 5) * 6
		
	elseif orbitShape == "Labrys" then
		local double = index / total * math.pi * 2
		x = math.cos(angle + double * 0.5 + time) * (radius * 1.25)
		z = math.sin(angle + double * 0.5 + time) * (radius * 1.25)
		y = height + double * 2.2
	end
	
	return centerPos + Vector3.new(x, y, z)
end

-- Apply animations (87 MEGA ANIMATIONS total!)
local function applyAnimation(part, targetPos, centerPos, time, index, total, phaseOffset)
	if animationMode == "None" then
		return targetPos
		
	elseif animationMode == "Pulse" then
		local pulse = 1 + math.sin(time * 3 + phaseOffset) * 0.3
		local direction = (targetPos - centerPos).Unit
		return centerPos + direction * (targetPos - centerPos).Magnitude * pulse
		
	elseif animationMode == "Expand" then
		local expand = 1 + math.sin(time * 1.5) * 0.5
		local direction = (targetPos - centerPos).Unit
		return centerPos + direction * (targetPos - centerPos).Magnitude * expand
		
	elseif animationMode == "Wobble" then
		local wobble = Vector3.new(
			math.sin(time * 4 + phaseOffset) * 2,
			math.cos(time * 3 + phaseOffset) * 2,
			math.sin(time * 3.5 + phaseOffset) * 2
		)
		return targetPos + wobble
		
	elseif animationMode == "Spin" then
		part.AssemblyAngularVelocity = Vector3.new(
			math.sin(time * 2) * 5,
			10,
			math.cos(time * 2) * 5
		)
		return targetPos
		
	elseif animationMode == "Shake" then
		local shake = Vector3.new(
			math.random(-1, 1) * 0.5,
			math.random(-1, 1) * 0.5,
			math.random(-1, 1) * 0.5
		)
		return targetPos + shake
		
	elseif animationMode == "Bounce" then
		local bounce = math.abs(math.sin(time * 5 + phaseOffset)) * 5
		return targetPos + Vector3.new(0, bounce, 0)
		
	elseif animationMode == "Twist" then
		local twistAngle = math.sin(time * 2) * 0.5
		local direction = (targetPos - centerPos)
		local distance = direction.Magnitude
		local currentAngle = math.atan2(direction.Z, direction.X)
		local newAngle = currentAngle + twistAngle
		return centerPos + Vector3.new(
			math.cos(newAngle) * distance,
			direction.Y,
			math.sin(newAngle) * distance
		)
		
	elseif animationMode == "Orbit" then
		local orbitRadius = 2
		local orbitAngle = time * 3 + phaseOffset
		local orbitOffset = Vector3.new(
			math.cos(orbitAngle) * orbitRadius,
			math.sin(orbitAngle * 1.5) * orbitRadius,
			math.sin(orbitAngle) * orbitRadius
		)
		return targetPos + orbitOffset
		
	elseif animationMode == "Flip" then
		part.AssemblyAngularVelocity = Vector3.new(
			15 * math.sin(time + phaseOffset),
			5,
			15 * math.cos(time + phaseOffset)
		)
		return targetPos
		
	elseif animationMode == "Stretch" then
		local stretch = 1 + math.sin(time * 2 + phaseOffset) * 0.6
		local direction = (targetPos - centerPos).Unit
		local baseDistance = (targetPos - centerPos).Magnitude
		return centerPos + direction * baseDistance * stretch
		
	elseif animationMode == "Swirl" then
		local swirlAngle = time * 2
		local direction = (targetPos - centerPos)
		local distance = direction.Magnitude
		local currentAngle = math.atan2(direction.Z, direction.X)
		local newAngle = currentAngle + swirlAngle * 0.3
		return centerPos + Vector3.new(
			math.cos(newAngle) * distance,
			direction.Y + math.sin(time * 3 + phaseOffset) * 4,
			math.sin(newAngle) * distance
		)
		
	elseif animationMode == "Jitter" then
		local jitter = 1.5
		local jitterSpeed = 15
		local jitterOffset = Vector3.new(
			math.sin(time * jitterSpeed + phaseOffset) * jitter,
			math.cos(time * jitterSpeed * 1.3 + phaseOffset) * jitter,
			math.sin(time * jitterSpeed * 0.8 + phaseOffset) * jitter
		)
		return targetPos + jitterOffset
		
	elseif animationMode == "Wave" then
		local waveOffset = math.sin(time * 3 - (index / total) * math.pi * 2) * 5
		return targetPos + Vector3.new(0, waveOffset, 0)
		
	-- NEW 12 ANIMATIONS START HERE!
	elseif animationMode == "Breathe" then
		local breathe = 1 + math.sin(time * 1.2 + phaseOffset) * 0.4
		local breath = math.sin(time * 1.2) * 0.2
		local direction = (targetPos - centerPos).Unit
		return centerPos + direction * (targetPos - centerPos).Magnitude * breathe + Vector3.new(0, breath * 3, 0)
		
	elseif animationMode == "Flicker" then
		local flicker = (math.sin(time * 20 + phaseOffset) > 0.5) and 1 or 0.5
		local direction = (targetPos - centerPos).Unit
		return centerPos + direction * (targetPos - centerPos).Magnitude * flicker
		
	elseif animationMode == "Rainbow" then
		-- Rainbow color cycling (handled separately in color sorting)
		local rainbowWave = math.sin(time * 2 - (index / total) * math.pi * 4) * 2
		return targetPos + Vector3.new(0, rainbowWave, 0)
		
	elseif animationMode == "Chaos" then
		local chaos = Vector3.new(
			math.sin(time * 7 + phaseOffset * 3) * 4,
			math.cos(time * 5 + phaseOffset * 2) * 4,
			math.sin(time * 9 + phaseOffset * 4) * 4
		)
		part.AssemblyAngularVelocity = Vector3.new(
			math.random(-10, 10),
			math.random(-10, 10),
			math.random(-10, 10)
		)
		return targetPos + chaos
		
	elseif animationMode == "Magnetic" then
		-- Pull towards center then push away
		local magnetic = math.sin(time * 2) * 0.7
		local direction = (targetPos - centerPos).Unit
		return centerPos + direction * (targetPos - centerPos).Magnitude * (1 + magnetic)
		
	elseif animationMode == "Repel" then
		-- Push away from center
		local repel = 1 + math.abs(math.sin(time * 2 + phaseOffset)) * 0.8
		local direction = (targetPos - centerPos).Unit
		return centerPos + direction * (targetPos - centerPos).Magnitude * repel
		
	elseif animationMode == "Graviton" then
		-- Gravitational wave effect
		local wave1 = math.sin(time * 2 + (index / total) * math.pi * 8) * 3
		local wave2 = math.cos(time * 2 + (index / total) * math.pi * 8) * 3
		return targetPos + Vector3.new(wave1, wave2, 0)
		
	elseif animationMode == "Quantum" then
		-- Quantum tunneling effect (random teleportation)
		if math.random() > 0.95 then
			local randomOffset = Vector3.new(
				math.random(-5, 5),
				math.random(-5, 5),
				math.random(-5, 5)
			)
			return targetPos + randomOffset
		end
		return targetPos
		
	elseif animationMode == "Teleport" then
		-- Periodic teleportation
		local teleportCycle = math.floor(time * 2) % 2
		if teleportCycle == 1 then
			local teleportOffset = Vector3.new(
				math.sin(index + time * 10) * 3,
				math.cos(index + time * 10) * 3,
				math.sin(index * 2 + time * 10) * 3
			)
			return targetPos + teleportOffset
		end
		return targetPos
		
	elseif animationMode == "Phasing" then
		-- Phase in and out of existence
		local phase = math.abs(math.sin(time * 3 + phaseOffset))
		local direction = (targetPos - centerPos).Unit
		return centerPos + direction * (targetPos - centerPos).Magnitude * (0.3 + phase * 0.7)
		
	elseif animationMode == "Morph" then
		-- Morph between different patterns
		local morphCycle = math.floor(time / 3) % 3
		local morphProgress = (time % 3) / 3
		
		if morphCycle == 0 then
			-- Circular
			local blend = math.sin(morphProgress * math.pi)
			return targetPos * (1 - blend) + (centerPos + Vector3.new(
				math.cos(index / total * math.pi * 2) * 10,
				0,
				math.sin(index / total * math.pi * 2) * 10
			)) * blend
		elseif morphCycle == 1 then
			-- Spherical
			return targetPos
		else
			-- Cubic
			return targetPos
		end
		
	elseif animationMode == "Kaleidoscope" then
		-- Kaleidoscope mirror effect
		local sectors = 6
		local sector = math.floor((index - 1) / (total / sectors)) % sectors
		local mirror = (sector % 2 == 0) and 1 or -1
		local kaleidoAngle = time * 2
		local direction = (targetPos - centerPos)
		local rotated = Vector3.new(
			direction.X * math.cos(kaleidoAngle) - direction.Z * math.sin(kaleidoAngle),
			direction.Y + math.sin(time * 4 + phaseOffset) * 2,
			direction.X * math.sin(kaleidoAngle) + direction.Z * math.cos(kaleidoAngle)
		)
		return centerPos + rotated * mirror
		
	-- STAR GLITCHER REVITALIZED ANIMATIONS! ✨🌟💫
	elseif animationMode == "AstralBeam" then
		-- Upward energy beam effect
		local beamPulse = 1 + math.sin(time * 5 + phaseOffset) * 0.2
		local beamLift = math.sin(time * 2 + (index / total) * math.pi * 2) * 3
		return targetPos + Vector3.new(0, beamLift * beamPulse, 0)
		
	elseif animationMode == "CelestialBurst" then
		-- Star burst expansion and contraction
		local burst = 1 + math.sin(time * 3) * 0.5
		local burstSpin = time * 4 + (index / total) * math.pi * 2
		local direction = (targetPos - centerPos)
		local distance = direction.Magnitude
		
		-- Rotate and expand
		local newAngle = math.atan2(direction.Z, direction.X) + burstSpin * 0.3
		return centerPos + Vector3.new(
			math.cos(newAngle) * distance * burst,
			direction.Y + math.sin(time * 4 + phaseOffset) * 3,
			math.sin(newAngle) * distance * burst
		)
		
	elseif animationMode == "DivinePillars" then
		-- Rising pillar effect with holy light
		local pillarRise = math.abs(math.sin(time * 2 + (index / total) * math.pi)) * 8
		local pillarSway = math.sin(time * 3 + phaseOffset) * 1.5
		return targetPos + Vector3.new(pillarSway, pillarRise, pillarSway * 0.5)
		
	elseif animationMode == "SpectrumShift" then
		-- Rainbow wave motion (perfect with color sorting!)
		local spectrumWave = math.sin(time * 3 - (index / total) * math.pi * 4) * 4
		local spectrumSpin = time * 2
		local direction = (targetPos - centerPos)
		local distance = direction.Magnitude
		local currentAngle = math.atan2(direction.Z, direction.X)
		
		return centerPos + Vector3.new(
			math.cos(currentAngle + spectrumSpin * 0.2) * distance,
			direction.Y + spectrumWave,
			math.sin(currentAngle + spectrumSpin * 0.2) * distance
		)
		
	elseif animationMode == "StellarOrbit" then
		-- Double orbit (orbit within orbit)
		local innerOrbit = 2
		local orbitAngle1 = time * 3 + phaseOffset
		local orbitAngle2 = time * 5 + index
		local orbit1 = Vector3.new(
			math.cos(orbitAngle1) * innerOrbit,
			math.sin(orbitAngle1 * 1.5) * innerOrbit,
			math.sin(orbitAngle1) * innerOrbit
		)
		local orbit2 = Vector3.new(
			math.cos(orbitAngle2) * 1,
			math.sin(orbitAngle2 * 2) * 1,
			math.sin(orbitAngle2) * 1
		)
		return targetPos + orbit1 + orbit2
		
	elseif animationMode == "RunicPulse" then
		-- Pulsing rune energy
		local runePulse = math.abs(math.sin(time * 4 + phaseOffset)) 
		local runeGlow = 1 + runePulse * 0.4
		local runeFloat = math.sin(time * 2 + (index / total) * math.pi * 2) * 2
		local direction = (targetPos - centerPos).Unit
		return centerPos + direction * (targetPos - centerPos).Magnitude * runeGlow + Vector3.new(0, runeFloat, 0)
		
	elseif animationMode == "EclipseSpin" then
		-- Eclipse rotation effect
		local eclipseAngle = time * 3
		local eclipseRadius = 2 + math.sin(time * 2) * 1
		local direction = (targetPos - centerPos)
		local distance = direction.Magnitude
		local baseAngle = math.atan2(direction.Z, direction.X)
		
		-- Create eclipse shadow motion
		local shadowAngle = baseAngle + eclipseAngle
		return centerPos + Vector3.new(
			math.cos(shadowAngle) * distance,
			direction.Y + math.sin(eclipseAngle * 2 + phaseOffset) * 3,
			math.sin(shadowAngle) * distance
		) + Vector3.new(
			math.cos(time * 5 + index) * eclipseRadius,
			0,
			math.sin(time * 5 + index) * eclipseRadius
		)
		
	elseif animationMode == "EtherealFloat" then
		-- Ghostly floating wisps
		local floatX = math.sin(time * 1.5 + phaseOffset) * 3
		local floatY = math.sin(time * 2 + phaseOffset * 1.3) * 4
		local floatZ = math.cos(time * 1.7 + phaseOffset) * 3
		local fadePhase = (math.sin(time * 3 + phaseOffset) + 1) / 2
		
		-- Fade in and out motion
		local fadeAmount = fadePhase * 0.5 + 0.5
		return targetPos + Vector3.new(floatX, floatY, floatZ) * fadeAmount
		
	-- 🔥 60 NEW MEGA ANIMATIONS START HERE! 🔥
	
	-- MOTION ANIMATIONS
	elseif animationMode == "Dash" then
		-- Quick dash movement
		local dashCycle = math.floor(time * 3) % 4
		local dashDirection = dashCycle / 4 * math.pi * 2
		local dashSpeed = math.sin(time * 10) * 5
		return targetPos + Vector3.new(
			math.cos(dashDirection) * dashSpeed,
			0,
			math.sin(dashDirection) * dashSpeed
		)
		
	elseif animationMode == "Slide" then
		-- Sliding motion
		local slideAngle = time * 2
		local slideDistance = math.sin(time * 3) * 4
		return targetPos + Vector3.new(
			math.cos(slideAngle) * slideDistance,
			-1,
			math.sin(slideAngle) * slideDistance
		)
		
	elseif animationMode == "Drift" then
		-- Drifting float
		local driftX = math.sin(time * 0.8 + phaseOffset) * 3
		local driftZ = math.cos(time * 0.6 + phaseOffset) * 3
		return targetPos + Vector3.new(driftX, 0, driftZ)
		
	elseif animationMode == "Glide" then
		-- Smooth gliding
		local glideAngle = time * 1.5
		local glideRadius = 3
		return targetPos + Vector3.new(
			math.cos(glideAngle) * glideRadius,
			math.sin(time * 2) * 1,
			math.sin(glideAngle) * glideRadius
		)
		
	elseif animationMode == "Soar" then
		-- Soaring upward
		local soarHeight = math.sin(time * 1.5 + phaseOffset) * 6 + 3
		local soarSway = math.sin(time * 2 + phaseOffset) * 2
		return targetPos + Vector3.new(soarSway, soarHeight, soarSway * 0.5)
		
	elseif animationMode == "Dive" then
		-- Diving downward
		local diveCycle = (time % 4) / 4
		local diveHeight = -diveCycle * 10 + 5
		return targetPos + Vector3.new(0, diveHeight, 0)
		
	elseif animationMode == "Leap" then
		-- Jumping leaps
		local leapCycle = math.sin(time * 3 + phaseOffset)
		local leapHeight = math.max(0, leapCycle) * 8
		return targetPos + Vector3.new(0, leapHeight, 0)
		
	elseif animationMode == "Bounce2" then
		-- Different bounce pattern
		local bounceHeight = math.abs(math.sin(time * 6 + phaseOffset)) * 6
		local bounceX = math.sin(time * 4 + phaseOffset) * 1.5
		return targetPos + Vector3.new(bounceX, bounceHeight, bounceX * 0.5)
		
	-- EFFECT ANIMATIONS
	elseif animationMode == "Flicker2" then
		-- Rapid flickering
		local flicker = (math.sin(time * 30 + phaseOffset) > 0) and 1 or 0.3
		local direction = (targetPos - centerPos).Unit
		return centerPos + direction * (targetPos - centerPos).Magnitude * flicker
		
	elseif animationMode == "Shimmer" then
		-- Shimmering effect
		local shimmer = math.sin(time * 8 + phaseOffset) * 0.3 + 1
		local shimmerOffset = Vector3.new(
			math.sin(time * 12 + phaseOffset) * 0.5,
			math.cos(time * 10 + phaseOffset) * 0.5,
			math.sin(time * 14 + phaseOffset) * 0.5
		)
		local direction = (targetPos - centerPos).Unit
		return centerPos + direction * (targetPos - centerPos).Magnitude * shimmer + shimmerOffset
		
	elseif animationMode == "Glow" then
		-- Pulsing glow
		local glow = math.sin(time * 2 + phaseOffset) * 0.4 + 1.2
		local direction = (targetPos - centerPos).Unit
		return centerPos + direction * (targetPos - centerPos).Magnitude * glow
		
	elseif animationMode == "Fade" then
		-- Fading in and out
		local fade = (math.sin(time * 2 + phaseOffset) + 1) / 2
		local direction = (targetPos - centerPos).Unit
		return centerPos + direction * (targetPos - centerPos).Magnitude * (0.3 + fade * 0.7)
		
	elseif animationMode == "Flash" then
		-- Quick flashes
		local flash = (math.floor(time * 4 + phaseOffset) % 2 == 0) and 1.3 or 0.7
		local direction = (targetPos - centerPos).Unit
		return centerPos + direction * (targetPos - centerPos).Magnitude * flash
		
	elseif animationMode == "Bloom" then
		-- Blooming expansion
		local bloom = math.sin(time * 1.5) * 0.5 + 1
		local bloomPulse = math.sin(time * 5 + phaseOffset) * 0.2
		local direction = (targetPos - centerPos).Unit
		return centerPos + direction * (targetPos - centerPos).Magnitude * (bloom + bloomPulse)
		
	elseif animationMode == "Aura" then
		-- Aura emanation
		local auraWave = math.sin(time * 3 - (index / total) * math.pi * 2) * 2
		local auraPulse = math.sin(time * 2) * 0.3 + 1
		local direction = (targetPos - centerPos).Unit
		return centerPos + direction * (targetPos - centerPos).Magnitude * auraPulse + Vector3.new(0, auraWave, 0)
		
	elseif animationMode == "Halo" then
		-- Halo ring effect
		local haloAngle = time * 3 + phaseOffset
		local haloRadius = 2
		local haloOffset = Vector3.new(
			math.cos(haloAngle) * haloRadius,
			3 + math.sin(time * 2) * 1,
			math.sin(haloAngle) * haloRadius
		)
		return targetPos + haloOffset
		
	-- PATTERN ANIMATIONS
	elseif animationMode == "Zigzag2" then
		-- Different zigzag pattern
		local zigzagAngle = math.floor(time * 4 + phaseOffset) % 4 * (math.pi / 2)
		local zigzagDist = 3
		return targetPos + Vector3.new(
			math.cos(zigzagAngle) * zigzagDist,
			math.sin(time * 6 + phaseOffset) * 2,
			math.sin(zigzagAngle) * zigzagDist
		)
		
	elseif animationMode == "Corkscrew" then
		-- Corkscrew spiral
		local corkscrewAngle = time * 5 + phaseOffset
		local corkscrewRadius = 2
		return targetPos + Vector3.new(
			math.cos(corkscrewAngle) * corkscrewRadius,
			math.sin(time * 2) * 5,
			math.sin(corkscrewAngle) * corkscrewRadius
		)
		
	elseif animationMode == "Pendulum" then
		-- Pendulum swing
		local pendulumAngle = math.sin(time * 2 + phaseOffset) * math.pi / 3
		local pendulumLength = 5
		return targetPos + Vector3.new(
			math.sin(pendulumAngle) * pendulumLength,
			-math.cos(pendulumAngle) * pendulumLength + pendulumLength,
			0
		)
		
	elseif animationMode == "Orbit2" then
		-- Different orbit pattern
		local orbit2Angle = time * 4 + phaseOffset
		local orbit2Radius = 3
		local orbit2Height = math.sin(time * 2 + phaseOffset) * 2
		return targetPos + Vector3.new(
			math.cos(orbit2Angle) * orbit2Radius,
			orbit2Height,
			math.sin(orbit2Angle) * orbit2Radius
		)
		
	elseif animationMode == "Revolve" then
		-- Revolution around center
		local revolveAngle = time * 2
		local direction = (targetPos - centerPos)
		local distance = direction.Magnitude
		local currentAngle = math.atan2(direction.Z, direction.X)
		local newAngle = currentAngle + revolveAngle * 0.5
		return centerPos + Vector3.new(
			math.cos(newAngle) * distance,
			direction.Y + math.sin(time * 3) * 2,
			math.sin(newAngle) * distance
		)
		
	elseif animationMode == "Rotate" then
		-- Simple rotation
		part.AssemblyAngularVelocity = Vector3.new(
			5,
			10 + math.sin(time * 2) * 5,
			5
		)
		return targetPos
		
	-- TRANSFORMATION ANIMATIONS
	elseif animationMode == "Morph2" then
		-- Morphing transformation
		local morphPhase = (math.sin(time * 1.5) + 1) / 2
		local morphScale = 0.5 + morphPhase * 1
		local direction = (targetPos - centerPos).Unit
		return centerPos + direction * (targetPos - centerPos).Magnitude * morphScale
		
	elseif animationMode == "Stretch2" then
		-- Vertical stretching
		local stretchY = 1 + math.sin(time * 3 + phaseOffset) * 0.8
		return targetPos + Vector3.new(0, (targetPos.Y - centerPos.Y) * stretchY * 0.3, 0)
		
	elseif animationMode == "Squash" then
		-- Squash and stretch
		local squash = math.sin(time * 4 + phaseOffset)
		local direction = (targetPos - centerPos).Unit
		local squashAmount = 1 + squash * 0.4
		return centerPos + direction * (targetPos - centerPos).Magnitude * squashAmount + Vector3.new(0, -squash * 2, 0)
		
	elseif animationMode == "Twist2" then
		-- Enhanced twist
		local twist2Angle = math.sin(time * 3 + phaseOffset) * math.pi
		local direction = (targetPos - centerPos)
		local distance = direction.Magnitude
		local currentAngle = math.atan2(direction.Z, direction.X)
		local height = direction.Y
		local heightFactor = math.abs(height) / 10
		local newAngle = currentAngle + twist2Angle * heightFactor
		return centerPos + Vector3.new(
			math.cos(newAngle) * distance,
			height,
			math.sin(newAngle) * distance
		)
		
	elseif animationMode == "Bend" then
		-- Bending effect
		local bendAngle = math.sin(time * 2) * 0.5
		local direction = (targetPos - centerPos)
		local distance = direction.Magnitude
		local bendOffset = distance * 0.3 * math.sin(bendAngle)
		return targetPos + Vector3.new(bendOffset, 0, bendOffset * 0.5)
		
	elseif animationMode == "Warp" then
		-- Space warping
		local warpFactor = math.sin(time * 2 + phaseOffset) * 0.5
		local direction = (targetPos - centerPos)
		local distance = direction.Magnitude
		local warpedDistance = distance * (1 + warpFactor * math.sin(distance * 0.5))
		return centerPos + direction.Unit * warpedDistance
		
	-- ENERGY ANIMATIONS
	elseif animationMode == "Charge" then
		-- Charging energy
		local chargeCycle = (time % 3) / 3
		local chargeIntensity = chargeCycle * chargeCycle
		local direction = (targetPos - centerPos).Unit
		return centerPos + direction * (targetPos - centerPos).Magnitude * (1 - chargeIntensity * 0.5) + Vector3.new(
			math.sin(time * 10 + phaseOffset) * chargeIntensity * 2,
			math.cos(time * 12 + phaseOffset) * chargeIntensity * 2,
			math.sin(time * 14 + phaseOffset) * chargeIntensity * 2
		)
		
	elseif animationMode == "Discharge" then
		-- Energy discharge
		local dischargeCycle = 1 - ((time % 2) / 2)
		local dischargeIntensity = dischargeCycle * dischargeCycle
		local direction = (targetPos - centerPos).Unit
		return centerPos + direction * (targetPos - centerPos).Magnitude * (1 + dischargeIntensity * 0.8)
		
	elseif animationMode == "Surge" then
		-- Power surge
		local surge = math.abs(math.sin(time * 4 + phaseOffset))
		local surgeDirection = (targetPos - centerPos).Unit
		return centerPos + surgeDirection * (targetPos - centerPos).Magnitude * (1 + surge * 0.6) + Vector3.new(0, surge * 3, 0)
		
	elseif animationMode == "Shock" then
		-- Electric shock
		local shockJitter = Vector3.new(
			math.random(-2, 2) * 0.5,
			math.random(-2, 2) * 0.5,
			math.random(-2, 2) * 0.5
		)
		local shockPulse = math.sin(time * 10 + phaseOffset)
		if shockPulse > 0.7 then
			return targetPos + shockJitter * 2
		end
		return targetPos + shockJitter * 0.3
		
	elseif animationMode == "Spark" then
		-- Sparking effect
		if math.random() > 0.9 then
			local sparkOffset = Vector3.new(
				math.random(-3, 3),
				math.random(-3, 3),
				math.random(-3, 3)
			)
			return targetPos + sparkOffset
		end
		return targetPos
		
	elseif animationMode == "Bolt" then
		-- Lightning bolt
		local boltCycle = math.floor(time * 5) % 2
		if boltCycle == 1 then
			local boltOffset = Vector3.new(
				math.sin(time * 20 + index) * 2,
				math.cos(time * 25 + index) * 2,
				math.sin(time * 22 + index) * 2
			)
			return targetPos + boltOffset
		end
		return targetPos
		
	elseif animationMode == "Arc" then
		-- Electric arc
		local arcAngle = time * 3 + phaseOffset
		local arcHeight = math.sin(arcAngle) * 4
		local arcSway = math.cos(arcAngle * 2) * 2
		return targetPos + Vector3.new(arcSway, arcHeight, arcSway * 0.5)
		
	-- ORGANIC ANIMATIONS
	elseif animationMode == "Breathe2" then
		-- Different breathing pattern
		local breathe2 = math.sin(time * 0.8 + phaseOffset) * 0.5 + 1
		local breathe2Height = math.sin(time * 0.8) * 1.5
		local direction = (targetPos - centerPos).Unit
		return centerPos + direction * (targetPos - centerPos).Magnitude * breathe2 + Vector3.new(0, breathe2Height, 0)
		
	elseif animationMode == "Heartbeat" then
		-- Heartbeat pulse
		local beat = math.floor(time * 2) % 2
		local beatIntensity = math.sin((time % 0.5) * math.pi * 2)
		if beat == 0 and beatIntensity > 0 then
			local pulse = beatIntensity * 0.4
			local direction = (targetPos - centerPos).Unit
			return centerPos + direction * (targetPos - centerPos).Magnitude * (1 + pulse)
		end
		return targetPos
		
	elseif animationMode == "Pulse2" then
		-- Different pulse pattern
		local pulse2 = math.sin(time * 4 + phaseOffset) * 0.4 + 1
		local pulse2Wave = math.sin(time * 2 - (index / total) * math.pi) * 2
		local direction = (targetPos - centerPos).Unit
		return centerPos + direction * (targetPos - centerPos).Magnitude * pulse2 + Vector3.new(0, pulse2Wave, 0)
		
	elseif animationMode == "Ripple2" then
		-- Water ripple
		local ripple2 = math.sin(time * 3 - (index / total) * math.pi * 4) * 3
		return targetPos + Vector3.new(0, ripple2, 0)
		
	elseif animationMode == "Flow" then
		-- Flowing motion
		local flowAngle = time * 2 + (index / total) * math.pi * 2
		local flowRadius = 2
		return targetPos + Vector3.new(
			math.cos(flowAngle) * flowRadius,
			math.sin(flowAngle * 1.5) * 2,
			math.sin(flowAngle) * flowRadius
		)
		
	elseif animationMode == "Stream" then
		-- Streaming effect
		local streamOffset = (time * 5 + (index / total) * 10) % 10 - 5
		return targetPos + Vector3.new(0, streamOffset, 0)
		
	-- CHAOS ANIMATIONS
	elseif animationMode == "Jitter2" then
		-- Intense jitter
		local jitter2 = 2.5
		local jitter2Speed = 20
		local jitter2Offset = Vector3.new(
			math.sin(time * jitter2Speed + phaseOffset * 2) * jitter2,
			math.cos(time * jitter2Speed * 1.5 + phaseOffset * 2) * jitter2,
			math.sin(time * jitter2Speed * 1.2 + phaseOffset * 2) * jitter2
		)
		return targetPos + jitter2Offset
		
	elseif animationMode == "Shake2" then
		-- Violent shaking
		local shake2 = Vector3.new(
			math.random(-2, 2),
			math.random(-2, 2),
			math.random(-2, 2)
		)
		return targetPos + shake2
		
	elseif animationMode == "Vibrate" then
		-- High frequency vibration
		local vibrate = Vector3.new(
			math.sin(time * 50 + phaseOffset) * 0.8,
			math.cos(time * 50 + phaseOffset) * 0.8,
			math.sin(time * 50 + phaseOffset * 1.5) * 0.8
		)
		return targetPos + vibrate
		
	elseif animationMode == "Quake" then
		-- Earthquake effect
		local quakeIntensity = math.sin(time * 3) * 0.5 + 0.5
		local quake = Vector3.new(
			math.sin(time * 15 + phaseOffset) * 3 * quakeIntensity,
			math.random(-1, 1) * quakeIntensity,
			math.cos(time * 15 + phaseOffset) * 3 * quakeIntensity
		)
		return targetPos + quake
		
	elseif animationMode == "Tremor" then
		-- Ground tremor
		local tremorWave = math.sin(time * 5 - (index / total) * math.pi * 2) * 2
		local tremorShake = Vector3.new(
			math.sin(time * 10 + phaseOffset) * 1,
			tremorWave,
			math.cos(time * 10 + phaseOffset) * 1
		)
		return targetPos + tremorShake
		
	elseif animationMode == "Shudder" then
		-- Shuddering motion
		local shudderCycle = math.floor(time * 3) % 3
		if shudderCycle == 0 then
			local shudder = Vector3.new(
				math.sin(time * 30 + phaseOffset) * 1.5,
				math.cos(time * 30 + phaseOffset) * 1.5,
				math.sin(time * 30 + phaseOffset * 1.3) * 1.5
			)
			return targetPos + shudder
		end
		return targetPos
		
	-- ADVANCED ANIMATIONS
	elseif animationMode == "Teleport2" then
		-- Different teleport pattern
		local teleport2Cycle = math.floor(time * 1.5) % 3
		if teleport2Cycle == 1 then
			local teleport2Offset = Vector3.new(
				math.sin(index * 2) * 5,
				math.cos(index * 3) * 5,
				math.sin(index * 4) * 5
			)
			return targetPos + teleport2Offset
		end
		return targetPos
		
	elseif animationMode == "Phase" then
		-- Phasing through dimensions
		local phaseCycle = (time % 4) / 4
		if phaseCycle < 0.25 or phaseCycle > 0.75 then
			local phaseAmount = (phaseCycle < 0.25) and (phaseCycle / 0.25) or ((1 - phaseCycle) / 0.25)
			local direction = (targetPos - centerPos).Unit
			return centerPos + direction * (targetPos - centerPos).Magnitude * phaseAmount
		end
		return targetPos
		
	elseif animationMode == "Blink" then
		-- Blinking in and out
		local blinkCycle = math.floor(time * 4) % 4
		if blinkCycle == 0 or blinkCycle == 2 then
			return targetPos
		else
			local blinkOffset = Vector3.new(
				math.sin(index + time * 5) * 4,
				math.cos(index + time * 5) * 4,
				math.sin(index * 2 + time * 5) * 4
			)
			return targetPos + blinkOffset
		end
		
	elseif animationMode == "Warp2" then
		-- Space-time warp
		local warp2Factor = math.sin(time * 2) * 0.6
		local direction = (targetPos - centerPos)
		local distance = direction.Magnitude
		local angle = math.atan2(direction.Z, direction.X)
		local warp2Angle = angle + warp2Factor * math.sin(distance * 0.3 + time * 3)
		local warp2Distance = distance * (1 + warp2Factor * 0.3)
		return centerPos + Vector3.new(
			math.cos(warp2Angle) * warp2Distance,
			direction.Y + math.sin(time * 4 + phaseOffset) * 2,
			math.sin(warp2Angle) * warp2Distance
		)
		
	elseif animationMode == "Portal2" then
		-- Portal travel
		local portal2Cycle = (time % 5) / 5
		if portal2Cycle < 0.2 then
			-- Entering portal
			local shrink = 1 - (portal2Cycle / 0.2)
			local direction = (targetPos - centerPos).Unit
			return centerPos + direction * (targetPos - centerPos).Magnitude * shrink
		elseif portal2Cycle > 0.8 then
			-- Exiting portal
			local grow = (portal2Cycle - 0.8) / 0.2
			local direction = (targetPos - centerPos).Unit
			local exitOffset = Vector3.new(
				math.sin(index) * 10,
				math.cos(index * 1.5) * 10,
				math.sin(index * 2) * 10
			)
			return centerPos + direction * (targetPos - centerPos).Magnitude * grow + exitOffset * (1 - grow)
		else
			-- In transit
			return centerPos + Vector3.new(0, -1000, 0)
		end
		
	elseif animationMode == "Rift" then
		-- Dimensional rift
		local riftTear = math.sin(time * 5 + phaseOffset) * 3
		local riftDistortion = Vector3.new(
			math.sin(time * 8 + index * 0.2) * 2,
			riftTear,
			math.cos(time * 8 + index * 0.2) * 2
		)
		return targetPos + riftDistortion
		
	elseif animationMode == "Dimension" then
		-- Dimension shifting
		local dimShift = math.sin(time * 1.5) * 0.5 + 0.5
		local dim1 = targetPos
		local dim2 = centerPos + Vector3.new(
			math.sin(index / total * math.pi * 2) * 15,
			math.cos(index / total * math.pi * 4) * 8,
			math.cos(index / total * math.pi * 2) * 15
		)
		return dim1 * (1 - dimShift) + dim2 * dimShift
	end
	
	return targetPos
end

local function startOrbiting()
	if not orbitPlayerMode and (not selectedPart or not selectedPart.Parent) then
		warn("No valid part selected! Select a part first, or use 'Orbit Player'.")
		return
	end
	
	stopOrbiting()
	
	orbitDistance = tonumber(distanceTextbox.Text) or 10
	orbitSpeed = tonumber(speedTextbox.Text) or 1
	gapValue = tonumber(gapTextbox.Text) or 2
	maxOrbitRadius = tonumber(maxRadiusTextbox.Text) or 50
	
	-- Determine the center reference for gathering/orbiting
	local function getOrbitCenter()
		if orbitPlayerMode then
			local char = player.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			return hrp and hrp.Position or Vector3.new(0, 0, 0)
		else
			return selectedPart.Position
		end
	end
	
	local totalParts = 0
	local acceptedParts = 0
	local rejectedByRadius = 0
	local centerForGather = getOrbitCenter()
	
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") then
			-- Skip the selected part (if any) and skip character parts
			local char = player.Character
			if obj == selectedPart then continue end
			if char and obj:IsDescendantOf(char) then continue end
			if isPartUnlocked(obj) and not obj.Anchored then
				totalParts = totalParts + 1
				
				-- Check radius limit if enabled
				local distanceFromCenter = (obj.Position - centerForGather).Magnitude
				if radiusLimitEnabled and distanceFromCenter > maxOrbitRadius then
					rejectedByRadius = rejectedByRadius + 1
					continue
				end
				
				-- Try to claim ownership first
				setNetworkOwnership(obj)
				-- Then check if we own it (if filter is enabled)
				if isOwnedByPlayer(obj) then
					table.insert(orbitingParts, obj)
					acceptedParts = acceptedParts + 1
				end
			end
		end
	end
	
	if radiusLimitEnabled then
		print(string.format("🎯 Radius Limit: Rejected %d parts outside %d studs", rejectedByRadius, maxOrbitRadius))
	end
	
	if networkOwnershipFilterMode then
		print(string.format("🎯 Ownership Filter: Accepted %d/%d parts", acceptedParts, totalParts))
	end
	
	if #orbitingParts == 0 then
		warn("No unlocked unanchored parts found!")
		if networkOwnershipFilterMode then
			warn("🎯 Try disabling the ownership filter if you can't find any parts!")
		end
		return
	end
	
	-- Sort parts by color if rainbow mode is on (keeps original colors, just arranges them!)
	if rainbowMode then
		table.sort(orbitingParts, function(a, b)
			local function colorToHue(color)
				local r, g, b = color.R, color.G, color.B
				local max = math.max(r, g, b)
				local min = math.min(r, g, b)
				local h = 0
				
				if max == min then
					h = 0
				elseif max == r then
					h = (60 * ((g - b) / (max - min)) + 360) % 360
				elseif max == g then
					h = (60 * ((b - r) / (max - min)) + 120) % 360
				else
					h = (60 * ((r - g) / (max - min)) + 240) % 360
				end
				
				return h
			end
			
			return colorToHue(a.Color) < colorToHue(b.Color)
		end)
		print("🌈 Rainbow mode: Parts arranged by color spectrum (Red→Orange→Yellow→Green→Blue→Purple)!")
	end
	
	print("🌟 Orbiting " .. #orbitingParts .. " parts!")
	print("Shape: " .. orbitShape .. " | Animation: " .. animationMode)
	print("Rainbow Mode: " .. tostring(rainbowMode))
	
	local orbitData = {}
	local totalParts = #orbitingParts  -- Use actual filtered count for spacing
	
	for i, part in ipairs(orbitingParts) do
		local radius = orbitDistance
		local speed = orbitSpeed / orbitDistance
		local baseAngle
		
		if gapMode == "None" then
			baseAngle = (i / totalParts) * math.pi * 2
		elseif gapMode == "GapPerPart" then
			radius = orbitDistance + ((i - 1) * gapValue)
			baseAngle = (i / totalParts) * math.pi * 2
		elseif gapMode == "GapBetweenParts" then
			local arcLengthPerPart = gapValue
			local totalArcLength = arcLengthPerPart * totalParts
			radius = totalArcLength / (2 * math.pi)
			baseAngle = (i / totalParts) * math.pi * 2
		end
		
		orbitData[part] = {
			baseAngle = baseAngle,
			radius = radius,
			speed = speed,
			index = i,
			phaseOffset = math.random() * math.pi * 2
		}
	end
	
	local startTime = tick()
	orbitConnection = RunService.Heartbeat:Connect(function()
		if not orbitPlayerMode and (not selectedPart or not selectedPart.Parent) then
			stopOrbiting()
			return
		end
		
		local centerPos
		if orbitPlayerMode then
			local char = player.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if not hrp then stopOrbiting() return end
			centerPos = hrp.Position
		else
			centerPos = selectedPart.Position
		end
		local time = tick() - startTime
		
		for part, data in pairs(orbitData) do
			if part and part.Parent then
				local currentAngle = data.baseAngle + (time * data.speed)
				local basePos = calculatePosition(
					centerPos,
					currentAngle,
					data.radius,
					0,
					time,
					data.index,
					#orbitingParts
				)
				
				local targetPos = applyAnimation(
					part,
					basePos,
					centerPos,
					time,
					data.index,
					#orbitingParts,
					data.phaseOffset
				)
				
				-- Rainbow mode doesn't change colors, just arranges them in spectrum order!
				
				local direction = (targetPos - part.Position)
				local distance = direction.Magnitude
				
				if distance > 0.1 then
					part.AssemblyLinearVelocity = direction.Unit * math.min(distance * 5, 50)
				else
					part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				end
				
				if animationMode ~= "Spin" and animationMode ~= "Flip" and animationMode ~= "Chaos" then
					part.AssemblyAngularVelocity = Vector3.new(
						math.sin(time) * 0.5,
						data.speed * 2,
						math.cos(time) * 0.5
					)
				end
			end
		end
	end)
	
	orbitButton.Text = "STOP ORBITING"
	orbitButton.BackgroundColor3 = Color3.fromRGB(120, 50, 50)
	if orbitPlayerMode then
		orbitPlayerButton.Text = "🧍 STOP PLAYER ORBIT"
		orbitPlayerButton.BackgroundColor3 = Color3.fromRGB(120, 50, 50)
	end
end

-- Button Events
selectionButton.MouseButton1Click:Connect(function()
	selectionMode = not selectionMode
	selectionButton.Text = selectionMode and "Selection Mode: ON" or "Enable Selection Mode"
	selectionButton.BackgroundColor3 = selectionMode and Color3.fromRGB(50, 100, 150) or Color3.fromRGB(60, 60, 60)
end)

hideSelectionToggle.MouseButton1Click:Connect(function()
	hideSelectionBox = not hideSelectionBox
	hideSelectionToggle.Text = hideSelectionBox and "Hide Selection Box: ON" or "Hide Selection Box: OFF"
	hideSelectionToggle.BackgroundColor3 = hideSelectionBox and Color3.fromRGB(50, 100, 150) or Color3.fromRGB(60, 60, 60)
	
	if hideSelectionBox and selectionBox then
		selectionBox:Destroy()
		selectionBox = nil
	elseif not hideSelectionBox and selectedPart then
		createSelectionBox(selectedPart)
	end
end)

rainbowToggle.MouseButton1Click:Connect(function()
	rainbowMode = not rainbowMode
	rainbowToggle.Text = rainbowMode and "🌈 RAINBOW COLOR SORTING: ON" or "🌈 RAINBOW COLOR SORTING: OFF"
	rainbowToggle.BackgroundColor3 = rainbowMode and Color3.fromRGB(100, 50, 150) or Color3.fromRGB(60, 60, 60)
end)

ownershipToggle.MouseButton1Click:Connect(function()
	networkOwnershipFilterMode = not networkOwnershipFilterMode
	ownershipLabel.Text = networkOwnershipFilterMode and "🎯 OWNERSHIP FILTER: ON" or "🎯 OWNERSHIP FILTER: OFF"
	ownershipToggle.BackgroundColor3 = networkOwnershipFilterMode and Color3.fromRGB(50, 100, 200) or Color3.fromRGB(60, 60, 60)
	if networkOwnershipFilterMode then
		print("🎯 Network ownership filter ENABLED! Only orbiting parts you own.")
		print("   - Parts owned by server (nil owner) will be claimed")
		print("   - Parts owned by other players will be rejected")
	else
		print("🎯 Network ownership filter DISABLED! Orbiting all unlocked parts.")
	end
end)

radiusLimitToggle.MouseButton1Click:Connect(function()
	radiusLimitEnabled = not radiusLimitEnabled
	radiusLimitToggle.Text = radiusLimitEnabled and "ON" or "OFF"
	radiusLimitToggle.BackgroundColor3 = radiusLimitEnabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(60, 60, 60)
	if radiusLimitEnabled then
		print("🎯 Radius limit ENABLED! Only orbiting parts within " .. (tonumber(maxRadiusTextbox.Text) or 50) .. " studs.")
	else
		print("🎯 Radius limit DISABLED! Orbiting all parts regardless of distance.")
	end
end)

local function updateGapMode(mode)
	gapMode = mode
	gapModeLabel.Text = "Gap Mode: " .. mode
	for _, btn in ipairs({gapModeNone, gapModePerPart, gapModeBetween}) do
		btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	end
	if mode == "None" then gapModeNone.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
	elseif mode == "GapPerPart" then gapModePerPart.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
	else gapModeBetween.BackgroundColor3 = Color3.fromRGB(50, 100, 50) end
end

gapModeNone.MouseButton1Click:Connect(function() updateGapMode("None") end)
gapModePerPart.MouseButton1Click:Connect(function() updateGapMode("GapPerPart") end)
gapModeBetween.MouseButton1Click:Connect(function() updateGapMode("GapBetweenParts") end)

for _, data in ipairs(shapeButtons) do
	data.button.MouseButton1Click:Connect(function()
		orbitShape = data.shape
		shapeLabel.Text = "✨ Shape: " .. orbitShape
		for _, btnData in ipairs(shapeButtons) do
			btnData.button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		end
		data.button.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
	end)
end

for _, data in ipairs(animButtons) do
	data.button.MouseButton1Click:Connect(function()
		animationMode = data.anim
		animLabel.Text = "🎭 Animation: " .. animationMode
		for _, btnData in ipairs(animButtons) do
			btnData.button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		end
		data.button.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
	end)
end

wireframeToggle.MouseButton1Click:Connect(function()
	wireframeMode = not wireframeMode
	wireframeLabel.Text = wireframeMode and "Wireframe Mode: ON" or "Wireframe Mode: OFF"
	wireframeToggle.BackgroundColor3 = wireframeMode and Color3.fromRGB(100, 50, 150) or Color3.fromRGB(60, 60, 60)
end)

wingsToggle.MouseButton1Click:Connect(function()
	if wingsMode then destroyWings() else createWings() end
end)

hammerToggle.MouseButton1Click:Connect(function()
	if hammerMode then destroyHammer() else createHammer() end
end)

hammerCursorToggle.MouseButton1Click:Connect(function()
	hammerCursorMode = not hammerCursorMode
	hammerCursorToggle.Text = hammerCursorMode and "Cursor Follow Mode: ON" or "Cursor Follow Mode: OFF"
	hammerCursorToggle.BackgroundColor3 = hammerCursorMode and Color3.fromRGB(50, 150, 100) or Color3.fromRGB(60, 60, 60)
	print(hammerCursorMode and "🎯 Hammer now follows cursor with tilt!" or "⚔️ Hammer back to normal mode")
end)

hammerColorToggle.MouseButton1Click:Connect(function()
	hammerColorSort = not hammerColorSort
	hammerColorToggle.Text = hammerColorSort and "🌈 Hammer Color Sort: ON" or "🌈 Hammer Color Sort: OFF"
	hammerColorToggle.BackgroundColor3 = hammerColorSort and Color3.fromRGB(100, 50, 150) or Color3.fromRGB(60, 60, 60)
	print(hammerColorSort and "🌈 Hammer will be color sorted on next creation!" or "Hammer color sort disabled")
end)

hammerSmash.MouseButton1Click:Connect(smashHammer)

fistToggle.MouseButton1Click:Connect(function()
	if fistMode then destroyFist() else createFist() end
end)

handToggle.MouseButton1Click:Connect(function()
	if handControllerMode then destroyHandController() else createHandController() end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	-- Y key - Toggle Hand Mode
	if input.KeyCode == Enum.KeyCode.Y then
		if handControllerMode then
			destroyHandController()
		else
			-- Disable other modes first
			if fistMode then destroyFist() end
			if hammerMode then destroyHammer() end
			if wingsMode then destroyWings() end
			createHandController()
		end
	-- M key - Smash/Punch actions
	elseif input.KeyCode == Enum.KeyCode.M then
		if hammerMode then
			smashHammer()
		elseif fistMode then
			punchGround()
		end
	-- Hand Mode Pose Controls (1-0 keys)
	elseif handControllerMode then
		local poseNames = {"open", "fist", "grab", "point", "peace", "thumbsUp", "smash", "pinch", "rock", "snap"}
		local keyNum = nil
		
		if input.KeyCode == Enum.KeyCode.One then keyNum = 1
		elseif input.KeyCode == Enum.KeyCode.Two then keyNum = 2
		elseif input.KeyCode == Enum.KeyCode.Three then keyNum = 3
		elseif input.KeyCode == Enum.KeyCode.Four then keyNum = 4
		elseif input.KeyCode == Enum.KeyCode.Five then keyNum = 5
		elseif input.KeyCode == Enum.KeyCode.Six then keyNum = 6
		elseif input.KeyCode == Enum.KeyCode.Seven then keyNum = 7
		elseif input.KeyCode == Enum.KeyCode.Eight then keyNum = 8
		elseif input.KeyCode == Enum.KeyCode.Nine then keyNum = 9
		elseif input.KeyCode == Enum.KeyCode.Zero then keyNum = 10
		end
		
		if keyNum then
			currentHandPose = poseNames[keyNum]
			handLabel.Text = "🖐️ HAND CONTROLLER: ON | Pose: " .. currentHandPose:sub(1,1):upper() .. currentHandPose:sub(2)
			print("🖐️ Hand pose changed to: " .. currentHandPose)
		end
	-- Fist Mode Individual Finger Controls
	elseif fistMode then
		if input.KeyCode == Enum.KeyCode.O then
			-- Make full fist
			fingerStates.thumb = 0
			fingerStates.index = 0
			fingerStates.middle = 0
			fingerStates.ring = 0
			fingerStates.pinky = 0
			print("✊ Full fist!")
		elseif input.KeyCode == Enum.KeyCode.G then
			-- Toggle thumb
			fingerStates.thumb = 1 - fingerStates.thumb
			print("👍 Thumb " .. (fingerStates.thumb == 1 and "open" or "closed"))
		elseif input.KeyCode == Enum.KeyCode.H then
			-- Toggle index
			fingerStates.index = 1 - fingerStates.index
			print("☝️ Index finger " .. (fingerStates.index == 1 and "open" or "closed"))
		elseif input.KeyCode == Enum.KeyCode.J then
			-- Toggle middle
			fingerStates.middle = 1 - fingerStates.middle
			print("🖕 Middle finger " .. (fingerStates.middle == 1 and "open" or "closed"))
		elseif input.KeyCode == Enum.KeyCode.K then
			-- Toggle ring
			fingerStates.ring = 1 - fingerStates.ring
			print("💍 Ring finger " .. (fingerStates.ring == 1 and "open" or "closed"))
		elseif input.KeyCode == Enum.KeyCode.L then
			-- Toggle pinky
			fingerStates.pinky = 1 - fingerStates.pinky
			print("🤙 Pinky " .. (fingerStates.pinky == 1 and "open" or "closed"))
		end
	end
end)

orbitButton.MouseButton1Click:Connect(function()
	if orbitConnection then
		stopOrbiting()
	else
		orbitPlayerMode = false  -- Ensure we orbit the selected part, not the player
		startOrbiting()
	end
end)

orbitPlayerButton.MouseButton1Click:Connect(function()
	if orbitConnection and orbitPlayerMode then
		-- Already orbiting player — stop
		stopOrbiting()
	else
		-- Start orbiting around the local player
		stopOrbiting()
		orbitPlayerMode = true
		startOrbiting()
	end
end)

mouse.Button1Down:Connect(function()
	if selectionMode then
		local target = mouse.Target
		if target and isPartUnlocked(target) then
			selectPart(target)
		end
	elseif hammerMode then
		-- Click to smash at location!
		local mouseRay = camera:ScreenPointToRay(mouse.X, mouse.Y)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = {player.Character}
		
		local rayResult = workspace:Raycast(mouseRay.Origin, mouseRay.Direction * 500, raycastParams)
		
		if rayResult then
			hammerSmashTarget = rayResult.Position
			smashHammer()
			print("🎯 Hammer targeting: " .. tostring(rayResult.Position))
		else
			-- If no hit, use point in space
			hammerSmashTarget = mouseRay.Origin + mouseRay.Direction * 50
			smashHammer()
		end
	end
end)

-- Mouse wheel for hand distance adjustment
mouse.WheelForward:Connect(function()
	if handControllerMode then
		handDistance = math.min(handDistance + 2, 50)
		print("🖐️ Hand distance: " .. handDistance)
	end
end)

mouse.WheelBackward:Connect(function()
	if handControllerMode then
		handDistance = math.max(handDistance - 2, 5)
		print("🖐️ Hand distance: " .. handDistance)
	end
end)

player.CharacterAdded:Connect(function()
	stopOrbiting()
	clearSelection()
	destroyHammer()
	destroyWings()
	destroyFist()
	destroyHandController()
end)

print("🌟🌟🌟 MEGA ULTIMATE ORBIT SCRIPT LOADED! 🌟🌟🌟")
print("✨ 64 ORBIT SHAPES (UNDERTALE + STAR GLITCHER!)!")
print("   💙 Undertale: Soul, Determination, Delta, Gaster, Bullet, Chaos!")
print("   🌟 Star Glitcher: Astral, Celestial, Divine, Spectrum, Stellar, Runic, Eclipse, Ethereal!")
print("🎭 34 ANIMATIONS (Including Star Glitcher effects!)!")
print("   ✨ Astral Beam, Celestial Burst, Divine Pillars, Spectrum Shift, Stellar Orbit, Runic Pulse, Eclipse Spin, Ethereal Float!")
print("👼 ULTRAKILL WINGS!")
print("🌈 RAINBOW COLOR SORTING (works perfectly with Star Glitcher modes!)!")
print("⚔️ HAMMER OF JUSTICE - The old man's legendary weapon! (Press M to smash)")
print("✊ GIANT FIST MODE - Control individual fingers!")
print("   O = Full Fist | G = Thumb | H = Index | J = Middle | K = Ring | L = Pinky")
print("   M = PUNCH GROUND!")
print("🖐️ HAND CONTROLLER MODE - 10 different hand poses!")
print("   Y = Toggle Hand Mode | 1-0 = Switch Poses | Mouse Wheel = Distance")
print("   Poses: Open, Fist, Grab, Point, Peace, Thumbs Up, Smash, Pinch, Rock, Snap")
print("")
print("Your friends are gonna be SO IMPRESSED! uwu")
