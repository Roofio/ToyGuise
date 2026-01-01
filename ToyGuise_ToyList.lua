-- ToyGuise_Toys.lua
-- Hardcoded list of appearance-changing toy item IDs
-- Add/edit IDs here.
-- Make sure these are ordered by Item ID for easier maintenance.

TRANSFORMATION_TOYS = {
    { id = 1973,   name = "Orb of Deception" },
    { id = 17712,  name = "Winter Veil Disguise Kit" },          -- Remove? requires snowball, 
    { id = 18258,  name = "Gordok Ogre Suit" },
    { id = 31337,  name = "Orb of the Blackwhelp" },
    { id = 32782,  name = "Time-Lost Figurine" },                -- Arakkoa
    { id = 33079,  name = "Murloc Costume" },
    { id = 35275,  name = "Orb of the Sin'dorei" },               -- old version, same name
    { id = 37254,  name = "Super Simian Sphere" },               -- Monkey
    { id = 43499,  name = "Iron Boot Flask" },                   -- Iron Dwarf
    { id = 44719,  name = "Frenzyheart Brew" },
    { id = 49704,  name = "Carved Ogre Idol" },
    { id = 53057,  name = "Faded Wizard Hat" },
    { id = 54651,  name = "Gnomeregan Pride" },                  -- Alliance Only   
    { id = 54653,  name = "Darkspear Pride" },
    { id = 64481,  name = "Blessing of the Old God" },           -- Silithid
    { id = 64646,  name = "Bones of Transformation" },           -- Naga
    { id = 64651,  name = "Wisp Amulet" },
    { id = 66888,  name = "Stave of Fur and Claw" },             -- Furbolg
    { id = 68806,  name = "Kalytha's Haunted Locket" },
    { id = 69775,  name = "Vrykul Drinking Horn" },
    { id = 72159,  name = "Magical Ogre Idol" },
    { id = 79769,  name = "Demon Hunter's Aspect" },
    { id = 86568,  name = "Mr. Smite's Brass Compass" },
    { id = 86589,  name = "Ai-Li's Skymirror" },
    { id = 88417,  name = "Gokk'lok's Shell" },                  -- Turtle
    { id = 88580,  name = "Ken-Ken's Mask" },
    { id = 97919,  name = "Whole-Body Shrinka'" },
    { id = 113570, name = "Ancient's Bloom" },                  -- unable to move
    { id = 115506, name = "Treessassin's Guise" },
    { id = 116067, name = "Ring of Broken Promises" },
    { id = 116115, name = "Blazing Wings" },
    { id = 116856, name = "Blooming Rose Contender's Costume" },
    { id = 116888, name = "Night Demon Contender's Costume" },
    { id = 116889, name = "Purple Phantom Contender's Costume" },
    { id = 116890, name = "Santo's Sun Contender's Costume" },
    { id = 116891, name = "Snowy Owl Contender's Costume" },
    { id = 118716, name = "Goren Garb" },
    { id = 118937, name = "Gamon's Braid" },
    { id = 118938, name = "Manastorm's Duplicator" },
    { id = 119134, name = "Sargerei Disguise" },
    { id = 119215, name = "Robo-Gnomebulator" },
    { id = 119432, name = "Botani Camouflage" },
    { id = 120857, name = "Barrel of Bandanas" },
    { id = 127394, name = "Podling Camouflage" },
    { id = 127659, name = "Ghostly Iron Buccaneer's Hat" },
    { id = 127696, name = "Magic Pet Mirror" },
    { id = 128471, name = "Frostwolf Grunt's Battlegear" },
    { id = 128807, name = "Coin of Many Faces" },
    { id = 129093, name = "Ravenbear Disguise" },
    { id = 129149, name = "Death's Door Charm" },
    { id = 129165, name = "Barnacle-Encrusted Gem" },
    { id = 129926, name = "Mark of the Ashtongue" },
    { id = 130171, name = "Cursed Orb" },                       -- REMOVE?: Just petrifies you, 
    { id = 134021, name = "X-52 Rocket Helmet" },               -- Launches you as a rocket first!
    { id = 134026, name = "Honorable Pennant" },
    { id = 134831, name = "Doomsayer's Robes" },
    { id = 138873, name = "Mystical Frosh Hat" },
    { id = 139337, name = "Disposable Winter Veil Suit" },
    { id = 139587, name = "Suspicious Crate" },
    { id = 140160, name = "Stormforged Vrykul Horn" },
    { id = 140780, name = "Fal'dorei Egg" },                     -- Spider
    { id = 143544, name = "Skull of Corruption" },
    { id = 143827, name = "Red Dragon Body Costume" },
    { id = 143828, name = "Red Dragon Tail Costume" },
    { id = 143829, name = "Red Dragon Head Costume" },
    { id = 147843, name = "Sira's Extra Cloak" },
    { id = 151270, name = "Horse Tail Costume" },
    { id = 151271, name = "Horse Head Costume" },
    { id = 151348, name = "Toy Weapon Set" },
    { id = 151349, name = "Toy Weapon Set" },
    { id = 151877, name = "Barrel of Eyepatches" },
    { id = 153179, name = "Blue Conservatory Scroll" },
    { id = 162642, name = "Toy Armor Set" },
    { id = 162643, name = "Toy Armor Set" },
    { id = 163736, name = "Spectral Visage" },
    { id = 163738, name = "Syndicate Mask" },
    { id = 163750, name = "Kovork Kostume" },
    { id = 163775, name = "Molok Morion" },
    { id = 165671, name = "Blue Dragon Body costume" },
    { id = 165672, name = "Blue Dragon Tail Costume" },
    { id = 165673, name = "Blue Dragon Head Costume" },
    { id = 165674, name = "Green Dragon Body Costume" },
    { id = 165675, name = "Green Dragon Tail Costume" },
    { id = 165676, name = "Green Dragon Head Costume" },
    { id = 166544, name = "Dark Ranger's Spare Cowl" },
    { id = 166779, name = "Transmorpher Beacon" },
    { id = 168014, name = "Banner of the Burning Blade" },
    { id = 198173, name = "Atomic Recalibrator" },               -- random race change
    { id = 205418, name = "Blazing Shadowflame Cinder" },
    { id = 228914, name = "Arachnoserum" }, 
    { id = 234950, name = "Atomic Regoblinator" }, 
    -- Add more entries here as needed
}