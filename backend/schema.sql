-- SQLite version of game_collection.sql
-- Runs on first launch to create the tables and load the starter data.

PRAGMA foreign_keys = ON;
BEGIN TRANSACTION;

-- ----------------------------------------------
-- Lookup tables
-- ----------------------------------------------

CREATE TABLE SealOrCIB (
  SealOrCIB TEXT NOT NULL DEFAULT 'Neither',
  PRIMARY KEY (SealOrCIB)
);

CREATE TABLE "Condition" (
  "Condition" TEXT NOT NULL,
  PRIMARY KEY ("Condition")
);

CREATE TABLE Regions (
  Region TEXT NOT NULL,
  PRIMARY KEY (Region)
);

CREATE TABLE ESRB_Ratings (
  Rating TEXT NOT NULL,
  PRIMARY KEY (Rating)
);

CREATE TABLE Series (
  Series TEXT NOT NULL,
  PRIMARY KEY (Series)
);

CREATE TABLE CoOp_Or_Vs (
  CoOpOrVs TEXT NOT NULL DEFAULT 'Neither',
  OfflineOrOnline INTEGER NOT NULL,
  PRIMARY KEY (CoOpOrVs, OfflineOrOnline)
);

CREATE TABLE Player_Numbers (
  MaxPlayerNumber INTEGER NOT NULL,
  PRIMARY KEY (MaxPlayerNumber)
);

CREATE TABLE Genres (
  Genre TEXT NOT NULL,
  PRIMARY KEY (Genre)
);

-- ----------------------------------------------
-- Games
-- ----------------------------------------------

CREATE TABLE Game_Names (
  GameName TEXT NOT NULL,
  UPC INTEGER DEFAULT 0,
  ReleaseDate TEXT NOT NULL,          -- stored as 'YYYY-MM-DD'
  Rating TEXT NOT NULL,
  PRIMARY KEY (GameName),
  CONSTRAINT GameRatingFK FOREIGN KEY (Rating) REFERENCES ESRB_Ratings (Rating)
);

CREATE TABLE Game_Has_a_Series (
  GameName TEXT NOT NULL,
  Series TEXT NOT NULL,
  PRIMARY KEY (GameName, Series),
  CONSTRAINT GameHasaSeriesGameNameFK FOREIGN KEY (GameName) REFERENCES Game_Names (GameName),
  CONSTRAINT GameHasaSeriesSeriesFK FOREIGN KEY (Series) REFERENCES Series (Series)
);

CREATE TABLE Game_Has_Players (
  GameName TEXT NOT NULL,
  MaxPlayerNumber INTEGER NOT NULL,
  CoOpOrVs TEXT NOT NULL DEFAULT 'Neither',
  OfflineOrOnline INTEGER NOT NULL,
  PRIMARY KEY (GameName, MaxPlayerNumber),
  CONSTRAINT GameHasPlayersGameNameFK FOREIGN KEY (GameName) REFERENCES Game_Names (GameName),
  CONSTRAINT GameHasPlayersMaxPlayerNumberFK FOREIGN KEY (MaxPlayerNumber) REFERENCES Player_Numbers (MaxPlayerNumber),
  CONSTRAINT GameHasPlayersCoOpOrVsFK FOREIGN KEY (CoOpOrVs, OfflineOrOnline) REFERENCES CoOp_Or_Vs (CoOpOrVs, OfflineOrOnline)
);

CREATE TABLE Game_Has_Genres (
  GameName TEXT NOT NULL,
  Genre TEXT NOT NULL,
  PRIMARY KEY (GameName, Genre),
  CONSTRAINT GameHasGenresGameNameFK FOREIGN KEY (GameName) REFERENCES Game_Names (GameName),
  CONSTRAINT GameHasGenresGenreFK FOREIGN KEY (Genre) REFERENCES Genres (Genre)
);

-- ----------------------------------------------
-- Consoles, peripherals, magazines, guides
-- ----------------------------------------------

CREATE TABLE Console_Publishers (
  ConsolePublisher TEXT NOT NULL,
  PRIMARY KEY (ConsolePublisher)
);

CREATE TABLE Console_Models (
  ModelName TEXT NOT NULL,
  ModelNumber TEXT,
  ConsolePublisher TEXT NOT NULL,
  PRIMARY KEY (ModelName),
  CONSTRAINT ConsolePublisherFK FOREIGN KEY (ConsolePublisher) REFERENCES Console_Publishers (ConsolePublisher)
);

CREATE TABLE Peripheral_Names (
  PeripheralName TEXT NOT NULL,
  UPC INTEGER DEFAULT 0,
  PRIMARY KEY (PeripheralName)
);

CREATE TABLE Magazine_Names (
  MagazineName TEXT NOT NULL,
  MagazineVolume INTEGER NOT NULL DEFAULT 1,
  ReleaseDate TEXT NOT NULL,          -- stored as 'YYYY-MM-DD'
  PRIMARY KEY (MagazineName, MagazineVolume)
);

CREATE TABLE Strategy_Guide_Publishers (
  GuidePublisher TEXT NOT NULL,
  PRIMARY KEY (GuidePublisher)
);

CREATE TABLE Strategy_Guide_Names (
  GuideName TEXT NOT NULL,
  GuidePublisher TEXT NOT NULL,
  PRIMARY KEY (GuideName, GuidePublisher),
  CONSTRAINT StrategyGuidePublisherFK FOREIGN KEY (GuidePublisher) REFERENCES Strategy_Guide_Publishers (GuidePublisher)
);

CREATE TABLE Game_Has_a_Guide (
  GameName TEXT NOT NULL,
  GuideName TEXT NOT NULL,
  GuidePublisher TEXT NOT NULL,
  PRIMARY KEY (GameName, GuideName),
  CONSTRAINT GameHasaGuideGameNameFK FOREIGN KEY (GameName) REFERENCES Game_Names (GameName),
  CONSTRAINT GameHasaGuideGuideNameFK FOREIGN KEY (GuideName, GuidePublisher) REFERENCES Strategy_Guide_Names (GuideName, GuidePublisher)
);

CREATE TABLE Game_Has_a_Console (
  GameName TEXT NOT NULL,
  ModelName TEXT NOT NULL,
  PRIMARY KEY (GameName, ModelName),
  CONSTRAINT GameHasaConsoleGameNameFK FOREIGN KEY (GameName) REFERENCES Game_Names (GameName),
  CONSTRAINT GameHasaConsoleModelNameFK FOREIGN KEY (ModelName) REFERENCES Console_Models (ModelName)
);

CREATE TABLE Magazine_Has_a_Game (
  MagazineName TEXT NOT NULL,
  MagazineVolume INTEGER NOT NULL DEFAULT 1,
  GameName TEXT NOT NULL,
  GuideOrCheats INTEGER,
  PRIMARY KEY (MagazineName, MagazineVolume, GameName),
  CONSTRAINT MagazineHasaGameGameMagazineNameVolumeFK FOREIGN KEY (MagazineName, MagazineVolume) REFERENCES Magazine_Names (MagazineName, MagazineVolume),
  CONSTRAINT MagazineHasaGameGameNameFK FOREIGN KEY (GameName) REFERENCES Game_Names (GameName)
);

CREATE TABLE Game_Has_a_Peripheral (
  GameName TEXT NOT NULL,
  PeripheralName TEXT NOT NULL,
  PRIMARY KEY (GameName, PeripheralName),
  CONSTRAINT GameHasaPeripheralGameNameFK FOREIGN KEY (GameName) REFERENCES Game_Names (GameName),
  CONSTRAINT GameHasaPeripheralPeripheralNameFK FOREIGN KEY (PeripheralName) REFERENCES Peripheral_Names (PeripheralName)
);

CREATE TABLE Console_Has_a_Peripheral (
  ModelName TEXT NOT NULL,
  PeripheralName TEXT NOT NULL,
  PRIMARY KEY (ModelName, PeripheralName),
  CONSTRAINT ConsoleHasaPeripheralConsoleModelFK FOREIGN KEY (ModelName) REFERENCES Console_Models (ModelName),
  CONSTRAINT ConsoleHasaPeripheralPeripheralNameFK FOREIGN KEY (PeripheralName) REFERENCES Peripheral_Names (PeripheralName)
);

-- ----------------------------------------------
-- Primary entity tables
-- UID is a random UUID (version 4) generated by the default expression
-- when an INSERT leaves UID out. This replaces the MySQL UUID() triggers.
-- ----------------------------------------------

CREATE TABLE Games (
  UID TEXT NOT NULL DEFAULT (
    lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' ||
    substr(lower(hex(randomblob(2))), 2) || '-' ||
    substr('89ab', abs(random()) % 4 + 1, 1) ||
    substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6)))
  ),
  Notes TEXT,
  GameName TEXT NOT NULL,
  "Condition" TEXT NOT NULL,
  SealOrCIB TEXT NOT NULL DEFAULT 'Neither',
  Region TEXT NOT NULL,
  PRIMARY KEY (UID),
  CONSTRAINT GameNameFK FOREIGN KEY (GameName) REFERENCES Game_Names(GameName),
  CONSTRAINT GamesConditionFK FOREIGN KEY ("Condition") REFERENCES "Condition"("Condition"),
  CONSTRAINT GamesSealOrCIBFK FOREIGN KEY (SealOrCIB) REFERENCES SealOrCIB(SealOrCIB),
  CONSTRAINT GameRegion FOREIGN KEY (Region) REFERENCES Regions(Region)
);

CREATE TABLE Peripherals (
  UID TEXT NOT NULL DEFAULT (
    lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' ||
    substr(lower(hex(randomblob(2))), 2) || '-' ||
    substr('89ab', abs(random()) % 4 + 1, 1) ||
    substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6)))
  ),
  Notes TEXT,
  PeripheralName TEXT NOT NULL,
  "Condition" TEXT NOT NULL,
  SealOrCIB TEXT NOT NULL DEFAULT 'Neither',
  PRIMARY KEY (UID),
  CONSTRAINT PeripheralNameFK FOREIGN KEY (PeripheralName) REFERENCES Peripheral_Names(PeripheralName),
  CONSTRAINT PeripheralConditionFK FOREIGN KEY ("Condition") REFERENCES "Condition"("Condition"),
  CONSTRAINT PeripheralSealOrCIBFK FOREIGN KEY (SealOrCIB) REFERENCES SealOrCIB(SealOrCIB)
);

CREATE TABLE Magazines (
  UID TEXT NOT NULL DEFAULT (
    lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' ||
    substr(lower(hex(randomblob(2))), 2) || '-' ||
    substr('89ab', abs(random()) % 4 + 1, 1) ||
    substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6)))
  ),
  Notes TEXT,
  MagazineName TEXT NOT NULL,
  MagazineVolume INTEGER NOT NULL DEFAULT 1,
  "Condition" TEXT NOT NULL,
  SealOrCIB TEXT NOT NULL DEFAULT 'Neither',
  PRIMARY KEY (UID),
  CONSTRAINT MagazineConditionFK FOREIGN KEY ("Condition") REFERENCES "Condition"("Condition"),
  CONSTRAINT MagazineSealOrCIBFK FOREIGN KEY (SealOrCIB) REFERENCES SealOrCIB(SealOrCIB),
  CONSTRAINT MagazineNameVolumeFK FOREIGN KEY (MagazineName, MagazineVolume) REFERENCES Magazine_Names(MagazineName, MagazineVolume)
);

CREATE TABLE Strategy_Guides (
  UID TEXT NOT NULL DEFAULT (
    lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' ||
    substr(lower(hex(randomblob(2))), 2) || '-' ||
    substr('89ab', abs(random()) % 4 + 1, 1) ||
    substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6)))
  ),
  Notes TEXT,
  GuideName TEXT NOT NULL,
  GuidePublisher TEXT NOT NULL,
  "Condition" TEXT NOT NULL,
  SealOrCIB TEXT NOT NULL DEFAULT 'Neither',
  PRIMARY KEY (UID),
  CONSTRAINT StrategyGuideNameFK FOREIGN KEY (GuideName, GuidePublisher) REFERENCES Strategy_Guide_Names(GuideName, GuidePublisher),
  CONSTRAINT StrategyGuideConditionFK FOREIGN KEY ("Condition") REFERENCES "Condition"("Condition"),
  CONSTRAINT StrategyGuideSealOrCIBFK FOREIGN KEY (SealOrCIB) REFERENCES SealOrCIB(SealOrCIB)
);

CREATE TABLE Memorabilia (
  UID TEXT NOT NULL DEFAULT (
    lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' ||
    substr(lower(hex(randomblob(2))), 2) || '-' ||
    substr('89ab', abs(random()) % 4 + 1, 1) ||
    substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6)))
  ),
  Description TEXT,
  GameName TEXT,
  Series TEXT,
  "Condition" TEXT NOT NULL,
  SealOrCIB TEXT NOT NULL DEFAULT 'Neither',
  PRIMARY KEY (UID),
  CONSTRAINT MemorabiliaGameNameFK FOREIGN KEY (GameName) REFERENCES Game_Names(GameName),
  CONSTRAINT MemorabiliaSeriesFK FOREIGN KEY (Series) REFERENCES Series(Series),
  CONSTRAINT MemorabiliaConditionFK FOREIGN KEY ("Condition") REFERENCES "Condition"("Condition"),
  CONSTRAINT MemorabiliaSealOrCIBFK FOREIGN KEY (SealOrCIB) REFERENCES SealOrCIB(SealOrCIB),
  CONSTRAINT MemorabiliaExclusiveOR CHECK (
    (GameName IS NOT NULL AND Series IS NULL) OR
    (GameName IS NULL AND Series IS NOT NULL)
  )
);

CREATE TABLE Consoles (
  UID TEXT NOT NULL DEFAULT (
    lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' ||
    substr(lower(hex(randomblob(2))), 2) || '-' ||
    substr('89ab', abs(random()) % 4 + 1, 1) ||
    substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6)))
  ),
  isModded INTEGER NOT NULL DEFAULT 0 CHECK (isModded IN (0, 1)),
  Notes TEXT,
  ModelName TEXT NOT NULL,
  "Condition" TEXT NOT NULL,
  SealOrCIB TEXT NOT NULL DEFAULT 'Neither',
  Region TEXT NOT NULL,
  PRIMARY KEY (UID),
  CONSTRAINT ConsoleRegionFK FOREIGN KEY (Region) REFERENCES Regions(Region),
  CONSTRAINT ModelNameFK FOREIGN KEY (ModelName) REFERENCES Console_Models(ModelName),
  CONSTRAINT ConsoleConditionFK FOREIGN KEY ("Condition") REFERENCES "Condition"("Condition"),
  CONSTRAINT ConsoleSealOrCIBFK FOREIGN KEY (SealOrCIB) REFERENCES SealOrCIB(SealOrCIB)
);

-- ----------------------------------------------
-- Starter data
-- ----------------------------------------------

INSERT INTO SealOrCIB (SealOrCIB) VALUES ('Neither'), ('Sealed'), ('CIB');

INSERT INTO "Condition" ("Condition") VALUES
  ('Near Mint'), ('Very Good'), ('Good'), ('Not Very Good'), ('Damaged');

INSERT INTO ESRB_Ratings (Rating) VALUES ('E'), ('E 10+'), ('T'), ('M'), ('AO'), ('RP');

INSERT INTO Regions (Region) VALUES ('NTSC-U/C'), ('NTSC-J'), ('NTSC-C'), ('PAL');

INSERT INTO Game_Names (GameName, UPC, ReleaseDate, Rating) VALUES
  ('Rule of Rose', 730865530205, '2006-09-12', 'M'),
  ('LSD: Dream Emulator', 4988126510244, '1998-10-22', 'T'),
  ('Shenmue', 10086510591, '2000-11-08', 'T'),
  ('Gauntlet Legends', 31719198184, '1999-09-29', 'T'),
  ('Mega Man 2', 13388110117, '1989-06-01', 'E'),
  ('.hack//INFECTION Part 1', 45557180119, '2000-02-01', 'T'),
  ('Front Mission 3', 662248900056, '2003-02-28', 'T'),
  ('Parasite Eve', 662248998015, '1998-09-09', 'M'),
  ('Pokemon Red', 45496730734, '1998-09-27', 'E'),
  ('Pokemon Blue', 45496730826, '1998-09-27', 'E'),
  ('Pokemon Yellow', 45496730895, '1999-10-01', 'E');

INSERT INTO CoOp_Or_Vs (CoOpOrVs, OfflineOrOnline) VALUES
  ('Neither', 0), ('CoOp', 0), ('Versus', 0),
  ('Neither', 1), ('CoOp', 1), ('Versus', 1);

INSERT INTO Player_Numbers (MaxPlayerNumber) VALUES (1), (4), (2);

INSERT INTO Series (Series) VALUES
  ('Bomberman'), ('Fallout'), ('Gauntlet'), ('Legacy of Kain'), ('Mega Man'),
  ('Pokemon'), ('Shenmue'), ('Front Mission'), ('.hack//'), ('Parasite Eve');

INSERT INTO Genres (Genre) VALUES
  ('Adventure'), ('Fighting'), ('Hack and Slash'), ('Horror'), ('Platformer'),
  ('RPG'), ('Survival'), ('Strategy'), ('Turn Based Strategy');

INSERT INTO Game_Has_Players (GameName, MaxPlayerNumber, CoOpOrVs, OfflineOrOnline) VALUES
  ('Gauntlet Legends', 1, 'Neither', 0),
  ('Gauntlet Legends', 4, 'CoOp', 0),
  ('LSD: Dream Emulator', 1, 'Neither', 0),
  ('Mega Man 2', 1, 'Neither', 0),
  ('Rule of Rose', 1, 'Neither', 0),
  ('Shenmue', 1, 'Neither', 0),
  ('.hack//INFECTION Part 1', 1, 'Neither', 0),
  ('Front Mission 3', 1, 'Neither', 0),
  ('Parasite Eve', 1, 'Neither', 0),
  ('Pokemon Red', 1, 'Neither', 0),
  ('Pokemon Red', 2, 'Versus', 0),
  ('Pokemon Blue', 1, 'Neither', 0),
  ('Pokemon Blue', 2, 'Versus', 0),
  ('Pokemon Yellow', 1, 'Neither', 0),
  ('Pokemon Yellow', 2, 'Versus', 0);

INSERT INTO Game_Has_a_Series (GameName, Series) VALUES
  ('Pokemon Red', 'Pokemon'),
  ('Pokemon Blue', 'Pokemon'),
  ('Pokemon Yellow', 'Pokemon'),
  ('Front Mission 3', 'Front Mission'),
  ('Shenmue', 'Shenmue'),
  ('Mega Man 2', 'Mega Man'),
  ('Gauntlet Legends', 'Gauntlet'),
  ('.hack//INFECTION Part 1', '.hack//'),
  ('Parasite Eve', 'Parasite Eve');

INSERT INTO Game_Has_Genres (GameName, Genre) VALUES
  ('Gauntlet Legends', 'Adventure'),
  ('Gauntlet Legends', 'Hack and Slash'),
  ('LSD: Dream Emulator', 'Adventure'),
  ('Mega Man 2', 'Adventure'),
  ('Mega Man 2', 'Platformer'),
  ('Rule of Rose', 'Horror'),
  ('Rule of Rose', 'Survival'),
  ('Shenmue', 'Adventure'),
  ('Shenmue', 'Fighting'),
  ('Shenmue', 'RPG'),
  ('.hack//INFECTION Part 1', 'RPG'),
  ('.hack//INFECTION Part 1', 'Hack and Slash'),
  ('Front Mission 3', 'RPG'),
  ('Front Mission 3', 'Strategy'),
  ('Front Mission 3', 'Turn Based Strategy'),
  ('Parasite Eve', 'RPG'),
  ('Parasite Eve', 'Adventure'),
  ('Parasite Eve', 'Horror'),
  ('Pokemon Red', 'RPG'),
  ('Pokemon Red', 'Turn Based Strategy'),
  ('Pokemon Red', 'Adventure'),
  ('Pokemon Blue', 'RPG'),
  ('Pokemon Blue', 'Turn Based Strategy'),
  ('Pokemon Blue', 'Adventure'),
  ('Pokemon Yellow', 'RPG'),
  ('Pokemon Yellow', 'Turn Based Strategy'),
  ('Pokemon Yellow', 'Adventure');

INSERT INTO Games (GameName, Notes, "Condition", Region) VALUES ('Gauntlet Legends', 'Loose Cart', 'Very Good', 'NTSC-U/C');
INSERT INTO Games (GameName, Notes, "Condition", Region) VALUES ('Gauntlet Legends', 'Has manual', 'Near Mint', 'NTSC-U/C');
INSERT INTO Games (GameName, "Condition", SealOrCIB, Region) VALUES ('LSD: Dream Emulator', 'Near Mint', 'CIB', 'NTSC-J');
INSERT INTO Games (GameName, Notes, "Condition", SealOrCIB, Region) VALUES ('Mega Man 2', 'Loose Cart', 'Very Good', 'CIB', 'NTSC-U/C');
INSERT INTO Games (GameName, "Condition", SealOrCIB, Region) VALUES ('Rule of Rose', 'Near Mint', 'CIB', 'NTSC-U/C');
INSERT INTO Games (GameName, "Condition", SealOrCIB, Region) VALUES ('Shenmue', 'Near Mint', 'CIB', 'NTSC-U/C');

INSERT INTO Memorabilia (Description, Series, "Condition") VALUES ('Bomberman Plush', 'Bomberman', 'Near Mint');
INSERT INTO Memorabilia (Description, Series, "Condition", SealOrCIB) VALUES ('Magic the Gathering Fallout Collectors Booster Box', 'Fallout', 'Near Mint', 'Sealed');
INSERT INTO Memorabilia (Description, Series, "Condition") VALUES ('Legacy of Kain: Soul Reaver Comic Book', 'Legacy of Kain', 'Very Good');
INSERT INTO Memorabilia (Description, Series, "Condition", SealOrCIB) VALUES ('Mega Bloks Pokedex', 'Pokemon', 'Near Mint', 'Sealed');
INSERT INTO Memorabilia (Description, Series, "Condition") VALUES ('Complete Base Set of Pokemon Cards', 'Pokemon', 'Very Good');

INSERT INTO Console_Publishers (ConsolePublisher) VALUES
  ('Atari'), ('Microsoft'), ('Nintendo'), ('Sega'), ('Sony');

INSERT INTO Console_Models (ModelName, ModelNumber, ConsolePublisher) VALUES
  ('Playstation 2', 'SCPH-50001-N', 'Sony'),
  ('Switch', 'HAC S KABAA USZ', 'Nintendo'),
  ('Atari 2600', 'CX-2600A', 'Atari'),
  ('Xbox', 'X0061-001', 'Microsoft'),
  ('Dreamcast', 'HKT-3020', 'Sega'),
  ('Gameboy', 'DMG-01', 'Nintendo'),
  ('Super Nintendo', 'SNS-001', 'Nintendo'),
  ('Playstation', 'SCPH-5501', 'Sony'),
  ('Nintendo 64', 'NUS-001', 'Nintendo'),
  ('Nintendo Entertainment System', 'NES-001', 'Nintendo');

INSERT INTO Consoles (ModelName, Notes, "Condition", Region) VALUES ('Playstation 2', 'This is my original PS2, have manual and cables', 'Good', 'PAL');
INSERT INTO Consoles (ModelName, Notes, "Condition", Region) VALUES ('Atari 2600', 'Loose console with cables', 'Good', 'NTSC-U/C');
INSERT INTO Consoles (ModelName, "Condition", SealOrCIB, Region) VALUES ('Switch', 'Very Good', 'CIB', 'NTSC-U/C');
INSERT INTO Consoles (ModelName, isModded, Notes, "Condition", Region) VALUES ('Xbox', 1, 'Loose console with cables', 'Good', 'NTSC-U/C');
INSERT INTO Consoles (ModelName, Notes, "Condition", Region) VALUES ('Dreamcast', 'Loose console with cables', 'Good', 'NTSC-U/C');

INSERT INTO Peripheral_Names (PeripheralName, UPC) VALUES
  ('Gameboy Printer Pokemon Edition', 4902370503678),
  ('Super Multitap 2', 4988607000639),
  ('Guncon', 4907892010321),
  ('Steel Battalion Controller', 13388290024),
  ('Dualshock', 711719405900);

INSERT INTO Peripherals (PeripheralName, "Condition", SealOrCIB) VALUES ('Gameboy Printer Pokemon Edition', 'Good', 'CIB');
INSERT INTO Peripherals (PeripheralName, "Condition", SealOrCIB) VALUES ('Super Multitap 2', 'Good', 'CIB');
INSERT INTO Peripherals (PeripheralName, "Condition", SealOrCIB) VALUES ('Guncon', 'Good', 'CIB');
INSERT INTO Peripherals (PeripheralName, "Condition", SealOrCIB) VALUES ('Steel Battalion Controller', 'Good', 'Sealed');
INSERT INTO Peripherals (PeripheralName, "Condition") VALUES ('Dualshock', 'Not Very Good');

INSERT INTO Console_Has_a_Peripheral (PeripheralName, ModelName) VALUES
  ('Gameboy Printer Pokemon Edition', 'Gameboy'),
  ('Super Multitap 2', 'Super Nintendo'),
  ('Guncon', 'Playstation'),
  ('Steel Battalion Controller', 'Xbox'),
  ('Dualshock', 'Playstation');

INSERT INTO Magazine_Names (MagazineName, MagazineVolume, ReleaseDate) VALUES
  ('Tips & Tricks', 97, '2003-03-01'),
  ('Tips & Tricks', 98, '2003-04-01'),
  ('Tips & Tricks', 102, '2003-08-01'),
  ('Tips & Tricks', 103, '2003-09-01'),
  ('Tips & Tricks', 111, '2004-05-01');

INSERT INTO Magazines (MagazineName, MagazineVolume, "Condition") VALUES ('Tips & Tricks', 97, 'Not Very Good');
INSERT INTO Magazines (MagazineName, MagazineVolume, "Condition") VALUES ('Tips & Tricks', 98, 'Not Very Good');
INSERT INTO Magazines (MagazineName, MagazineVolume, "Condition") VALUES ('Tips & Tricks', 102, 'Not Very Good');
INSERT INTO Magazines (MagazineName, MagazineVolume, "Condition") VALUES ('Tips & Tricks', 103, 'Not Very Good');
INSERT INTO Magazines (MagazineName, MagazineVolume, "Condition") VALUES ('Tips & Tricks', 111, 'Not Very Good');

-- These games are not the correct games in the magazines; it just requires a lot of extra work to put the real ones in
INSERT INTO Magazine_Has_a_Game (MagazineName, MagazineVolume, GameName, GuideOrCheats) VALUES
  ('Tips & Tricks', 97, '.hack//INFECTION Part 1', 0),
  ('Tips & Tricks', 98, 'Rule of Rose', 0),
  ('Tips & Tricks', 102, 'Pokemon Blue', 0),
  ('Tips & Tricks', 103, 'Gauntlet Legends', 1),
  ('Tips & Tricks', 97, 'Mega Man 2', 1);

INSERT INTO Game_Has_a_Console (GameName, ModelName) VALUES
  ('Rule of Rose', 'Playstation 2'),
  ('.hack//INFECTION Part 1', 'Playstation 2'),
  ('LSD: Dream Emulator', 'Playstation'),
  ('Front Mission 3', 'Playstation'),
  ('Parasite Eve', 'Playstation'),
  ('Shenmue', 'Dreamcast'),
  ('Gauntlet Legends', 'Nintendo 64'),
  ('Mega Man 2', 'Nintendo Entertainment System'),
  ('Pokemon Red', 'Gameboy'),
  ('Pokemon Blue', 'Gameboy'),
  ('Pokemon Yellow', 'Gameboy');

INSERT INTO Strategy_Guide_Publishers (GuidePublisher) VALUES
  ('Brady Games'), ('Prima Games'), ('Nintendo');

INSERT INTO Strategy_Guide_Names (GuideName, GuidePublisher) VALUES
  ('.hack//INFECTION Part 1', 'Brady Games'),
  ('Front Mission 3', 'Brady Games'),
  ('Parasite Eve', 'Brady Games'),
  ('Pokemon Special Edition for Yellow, Red and Blue', 'Nintendo'),
  ('Pokemon Trading Card Game', 'Prima Games');

INSERT INTO Strategy_Guides (GuideName, GuidePublisher, "Condition") VALUES ('.hack//INFECTION Part 1', 'Brady Games', 'Good');
INSERT INTO Strategy_Guides (GuideName, GuidePublisher, "Condition") VALUES ('Front Mission 3', 'Brady Games', 'Good');
INSERT INTO Strategy_Guides (GuideName, GuidePublisher, "Condition") VALUES ('Parasite Eve', 'Brady Games', 'Good');
INSERT INTO Strategy_Guides (GuideName, GuidePublisher, "Condition") VALUES ('Pokemon Special Edition for Yellow, Red and Blue', 'Nintendo', 'Good');
INSERT INTO Strategy_Guides (GuideName, GuidePublisher, "Condition") VALUES ('Pokemon Trading Card Game', 'Prima Games', 'Good');

INSERT INTO Game_Has_a_Guide (GameName, GuideName, GuidePublisher) VALUES
  ('.hack//INFECTION Part 1', '.hack//INFECTION Part 1', 'Brady Games'),
  ('Front Mission 3', 'Front Mission 3', 'Brady Games'),
  ('Parasite Eve', 'Parasite Eve', 'Brady Games'),
  ('Pokemon Red', 'Pokemon Special Edition for Yellow, Red and Blue', 'Nintendo'),
  ('Pokemon Blue', 'Pokemon Special Edition for Yellow, Red and Blue', 'Nintendo'),
  ('Pokemon Yellow', 'Pokemon Special Edition for Yellow, Red and Blue', 'Nintendo');

COMMIT;