-- Drop the database if it exists and recreate it
-- DROP DATABASE IF EXISTS game_collection;
-- CREATE DATABASE game_collection;
USE game_collection;

-- Tables

CREATE TABLE SealOrCIB (
  SealOrCIB CHAR(8) NOT NULL DEFAULT 'Neither',
  PRIMARY KEY (SealOrCIB)
);

CREATE TABLE `Condition` (
  `Condition` CHAR(16) NOT NULL,
  PRIMARY KEY (`Condition`)
);

CREATE TABLE Regions (
  Region VARCHAR(255) NOT NULL,
  PRIMARY KEY (Region)
);

CREATE TABLE ESRB_Ratings (
  Rating CHAR(8) NOT NULL,
  PRIMARY KEY (Rating)
);

CREATE TABLE Series (
  Series VARCHAR(255) NOT NULL,
  PRIMARY KEY (Series)
);

CREATE TABLE CoOp_Or_Vs (
  CoOpOrVs CHAR(16) NOT NULL DEFAULT 'Neither',
  OfflineOrOnline TINYINT(1) NOT NULL,
  PRIMARY KEY (CoOpOrVs, OfflineOrOnline)
);

CREATE TABLE Player_Numbers (
  MaxPlayerNumber INT NOT NULL,
  PRIMARY KEY (MaxPlayerNumber)
);

CREATE TABLE Genres (
  Genre VARCHAR(255) NOT NULL,
  PRIMARY KEY (Genre)
);

CREATE TABLE Game_Names (
  GameName VARCHAR(255) NOT NULL,
  UPC BIGINT DEFAULT 0,
  ReleaseDate DATE NOT NULL,
  Rating CHAR(8) NOT NULL,
  PRIMARY KEY (GameName),
  CONSTRAINT GameRatingFK FOREIGN KEY (Rating) REFERENCES ESRB_Ratings (Rating)
);

CREATE TABLE Game_Has_a_Series (
  GameName VARCHAR(255) NOT NULL,
  Series VARCHAR(255) NOT NULL,
  PRIMARY KEY (GameName, Series),
  CONSTRAINT GameHasaSeriesGameNameFK FOREIGN KEY (GameName) REFERENCES Game_Names (GameName),
  CONSTRAINT GameHasaSeriesSeriesFK FOREIGN KEY (Series) REFERENCES Series (Series)
);

CREATE TABLE Game_Has_Players (
  GameName VARCHAR(255) NOT NULL,
  MaxPlayerNumber INT NOT NULL,
  CoOpOrVs CHAR(16) NOT NULL DEFAULT 'Neither',
  OfflineOrOnline TINYINT(1) NOT NULL,
  PRIMARY KEY (GameName, MaxPlayerNumber),
  CONSTRAINT GameHasPlayersGameNameFK FOREIGN KEY (GameName) REFERENCES Game_Names (GameName),
  CONSTRAINT GameHasPlayersMaxPlayerNumberFK FOREIGN KEY (MaxPlayerNumber) REFERENCES Player_Numbers (MaxPlayerNumber),
  CONSTRAINT GameHasPlayersCoOpOrVsFK FOREIGN KEY (CoOpOrVs, OfflineOrOnline) REFERENCES CoOp_Or_Vs (CoOpOrVs, OfflineOrOnline)
);

CREATE TABLE Game_Has_Genres (
  GameName VARCHAR(255) NOT NULL,
  Genre VARCHAR(255) NOT NULL,
  PRIMARY KEY (GameName, Genre),
  CONSTRAINT GameHasGenresGameNameFK FOREIGN KEY (GameName) REFERENCES Game_Names (GameName),
  CONSTRAINT GameHasGenresGenreFK FOREIGN KEY (Genre) REFERENCES Genres (Genre)
);

CREATE TABLE Console_Publishers (
  ConsolePublisher VARCHAR(255) NOT NULL,
  PRIMARY KEY (ConsolePublisher)
);

CREATE TABLE Console_Models (
  ModelName VARCHAR(255) NOT NULL,
  ModelNumber VARCHAR(255),
  ConsolePublisher VARCHAR(255) NOT NULL,
  PRIMARY KEY (ModelName),
  CONSTRAINT ConsolePublisherFK FOREIGN KEY (ConsolePublisher) REFERENCES Console_Publishers (ConsolePublisher)
);

CREATE TABLE Peripheral_Names (
  PeripheralName VARCHAR(255) NOT NULL,
  UPC BIGINT DEFAULT 0,
  PRIMARY KEY (PeripheralName)
);

CREATE TABLE Magazine_Names (
  MagazineName VARCHAR(255) NOT NULL,
  MagazineVolume INT NOT NULL DEFAULT 1,
  ReleaseDate DATE NOT NULL,
  PRIMARY KEY (MagazineName, MagazineVolume)
);

CREATE TABLE Strategy_Guide_Publishers (
  GuidePublisher VARCHAR(255) NOT NULL,
  PRIMARY KEY (GuidePublisher)
);

CREATE TABLE Strategy_Guide_Names (
  GuideName VARCHAR(255) NOT NULL,
  GuidePublisher VARCHAR(255) NOT NULL,
  PRIMARY KEY (GuideName, GuidePublisher),
  CONSTRAINT StrategyGuidePublisherFK FOREIGN KEY (GuidePublisher) REFERENCES Strategy_Guide_Publishers (GuidePublisher)
);

CREATE TABLE Game_Has_a_Guide (
  GameName VARCHAR(255) NOT NULL,
  GuideName VARCHAR(255) NOT NULL,
  GuidePublisher VARCHAR(255) NOT NULL,
  PRIMARY KEY (GameName, GuideName),
  CONSTRAINT GameHasaGuideGameNameFK FOREIGN KEY (GameName) REFERENCES Game_Names (GameName),
  CONSTRAINT GameHasaGuideGuideNameFK FOREIGN KEY (GuideName, GuidePublisher) REFERENCES Strategy_Guide_Names (GuideName, GuidePublisher)
);

CREATE TABLE Game_Has_a_Console (
  GameName VARCHAR(255) NOT NULL,
  ModelName VARCHAR(255) NOT NULL,
  PRIMARY KEY (GameName, ModelName),
  CONSTRAINT GameHasaConsoleGameNameFK FOREIGN KEY (GameName) REFERENCES Game_Names (GameName),
  CONSTRAINT GameHasaConsoleModelNameFK FOREIGN KEY (ModelName) REFERENCES Console_Models (ModelName)
);

CREATE TABLE Magazine_Has_a_Game (
  MagazineName VARCHAR(255) NOT NULL,
  MagazineVolume INT NOT NULL DEFAULT 1,
  GameName VARCHAR(255) NOT NULL,
  GuideOrCheats TINYINT(1),
  PRIMARY KEY (MagazineName, MagazineVolume, GameName),
  CONSTRAINT MagazineHasaGameGameMagazineNameVolumeFK FOREIGN KEY (MagazineName, MagazineVolume) REFERENCES Magazine_Names (MagazineName, MagazineVolume),
  CONSTRAINT MagazineHasaGameGameNameFK FOREIGN KEY (GameName) REFERENCES Game_Names (GameName)
);

CREATE TABLE Game_Has_a_Peripheral (
  GameName VARCHAR(255) NOT NULL,
  PeripheralName VARCHAR(255) NOT NULL,
  PRIMARY KEY (GameName, PeripheralName),
  CONSTRAINT GameHasaPeripheralGameNameFK FOREIGN KEY (GameName) REFERENCES Game_Names (GameName),
  CONSTRAINT GameHasaPeripheralPeripheralNameFK FOREIGN KEY (PeripheralName) REFERENCES Peripheral_Names (PeripheralName)
);

CREATE TABLE Console_Has_a_Peripheral (
  ModelName VARCHAR(255) NOT NULL,
  PeripheralName VARCHAR(255) NOT NULL,
  PRIMARY KEY (ModelName, PeripheralName),
  CONSTRAINT ConsoleHasaPeripheralConsoleModelFK FOREIGN KEY (ModelName) REFERENCES Console_Models (ModelName),
  CONSTRAINT ConsoleHasaPeripheralPeripheralNameFK FOREIGN KEY (PeripheralName) REFERENCES Peripheral_Names (PeripheralName)
);

-- Primary Entities Tables with UUIDs as CHAR(36)

CREATE TABLE Games (
  UID CHAR(36) NOT NULL,
  Notes VARCHAR(255),
  GameName VARCHAR(255) NOT NULL,
  `Condition` CHAR(16) NOT NULL,
  SealOrCIB CHAR(8) NOT NULL DEFAULT 'Neither',
  Region VARCHAR(255) NOT NULL,
  PRIMARY KEY (UID),
  CONSTRAINT GameNameFK FOREIGN KEY (GameName) REFERENCES Game_Names(GameName),
  CONSTRAINT GamesConditionFK FOREIGN KEY (`Condition`) REFERENCES `Condition`(`Condition`),
  CONSTRAINT GamesSealOrCIBFK FOREIGN KEY (SealOrCIB) REFERENCES SealOrCIB(SealOrCIB),
  CONSTRAINT GameRegion FOREIGN KEY (Region) REFERENCES Regions(Region)
);

DELIMITER $$
CREATE TRIGGER before_insert_games
BEFORE INSERT ON Games
FOR EACH ROW
BEGIN
  IF NEW.UID IS NULL OR NEW.UID = '' THEN
    SET NEW.UID = UUID();
  END IF;
END$$
DELIMITER ;


CREATE TABLE Peripherals (
  UID CHAR(36) NOT NULL,
  Notes VARCHAR(255),
  PeripheralName VARCHAR(255) NOT NULL,
  `Condition` CHAR(16) NOT NULL,
  SealOrCIB CHAR(8) NOT NULL DEFAULT 'Neither',
  PRIMARY KEY (UID),
  CONSTRAINT PeripheralNameFK FOREIGN KEY (PeripheralName) REFERENCES Peripheral_Names(PeripheralName),
  CONSTRAINT PeripheralConditionFK FOREIGN KEY (`Condition`) REFERENCES `Condition`(`Condition`),
  CONSTRAINT PeripheralSealOrCIBFK FOREIGN KEY (SealOrCIB) REFERENCES SealOrCIB(SealOrCIB)
);

DELIMITER $$
CREATE TRIGGER before_insert_peripherals
BEFORE INSERT ON Peripherals
FOR EACH ROW
BEGIN
  IF NEW.UID IS NULL OR NEW.UID = '' THEN
    SET NEW.UID = UUID();
  END IF;
END$$
DELIMITER ;

CREATE TABLE Magazines (
  UID CHAR(36) NOT NULL,
  Notes VARCHAR(255),
  MagazineName VARCHAR(255) NOT NULL,
  MagazineVolume INT NOT NULL DEFAULT 1,
  `Condition` CHAR(16) NOT NULL,
  SealOrCIB CHAR(8) NOT NULL DEFAULT 'Neither',
  PRIMARY KEY (UID),
  CONSTRAINT MagazineConditionFK FOREIGN KEY (`Condition`) REFERENCES `Condition`(`Condition`),
  CONSTRAINT MagazineSealOrCIBFK FOREIGN KEY (SealOrCIB) REFERENCES SealOrCIB(SealOrCIB),
  CONSTRAINT MagazineNameVolumeFK FOREIGN KEY (MagazineName, MagazineVolume) REFERENCES Magazine_Names(MagazineName, MagazineVolume)
);

DELIMITER $$
CREATE TRIGGER before_insert_magazines
BEFORE INSERT ON Magazines
FOR EACH ROW
BEGIN
  IF NEW.UID IS NULL OR NEW.UID = '' THEN
    SET NEW.UID = UUID();
  END IF;
END$$
DELIMITER ;

CREATE TABLE Strategy_Guides (
  UID CHAR(36) NOT NULL,
  Notes VARCHAR(255),
  GuideName VARCHAR(255) NOT NULL,
  GuidePublisher VARCHAR(255) NOT NULL,
  `Condition` CHAR(16) NOT NULL,
  SealOrCIB CHAR(8) NOT NULL DEFAULT 'Neither',
  PRIMARY KEY (UID),
  CONSTRAINT StrategyGuideNameFK FOREIGN KEY (GuideName, GuidePublisher) REFERENCES Strategy_Guide_Names(GuideName, GuidePublisher),
  CONSTRAINT StrategyGuideConditionFK FOREIGN KEY (`Condition`) REFERENCES `Condition`(`Condition`),
  CONSTRAINT StrategyGuideSealOrCIBFK FOREIGN KEY (SealOrCIB) REFERENCES SealOrCIB(SealOrCIB)
);

DELIMITER $$
CREATE TRIGGER before_insert_strategy_guides
BEFORE INSERT ON Strategy_Guides
FOR EACH ROW
BEGIN
  IF NEW.UID IS NULL OR NEW.UID = '' THEN
    SET NEW.UID = UUID();
  END IF;
END$$
DELIMITER ;

CREATE TABLE Memorabilia (
  UID CHAR(36) NOT NULL,
  Description VARCHAR(255),
  GameName VARCHAR(255),
  Series VARCHAR(255),
  `Condition` CHAR(16) NOT NULL,
  SealOrCIB CHAR(8) NOT NULL DEFAULT 'Neither',
  PRIMARY KEY (UID),
  CONSTRAINT MemorabiliaGameNameFK FOREIGN KEY (GameName) REFERENCES Game_Names(GameName),
  CONSTRAINT MemorabiliaSeriesFK FOREIGN KEY (Series) REFERENCES Series(Series),
  CONSTRAINT MemorabiliaConditionFK FOREIGN KEY (`Condition`) REFERENCES `Condition`(`Condition`),
  CONSTRAINT MemorabiliaSealOrCIBFK FOREIGN KEY (SealOrCIB) REFERENCES SealOrCIB(SealOrCIB),
  CONSTRAINT MemorabiliaExclusiveOR CHECK (
    (GameName IS NOT NULL AND Series IS NULL) OR
    (GameName IS NULL AND Series IS NOT NULL)
  )
);

DELIMITER $$
CREATE TRIGGER before_insert_memorabilia
BEFORE INSERT ON Memorabilia
FOR EACH ROW
BEGIN
  IF NEW.UID IS NULL OR NEW.UID = '' THEN
    SET NEW.UID = UUID();
  END IF;
END$$
DELIMITER ;


CREATE TABLE Consoles (
  UID CHAR(36) NOT NULL,
  isModded BIT NOT NULL DEFAULT 0,
  Notes VARCHAR(255),
  ModelName VARCHAR(255) NOT NULL,
  `Condition` CHAR(16) NOT NULL,
  SealOrCIB CHAR(8) NOT NULL DEFAULT 'Neither',
  Region VARCHAR(255) NOT NULL,
  PRIMARY KEY (UID),
  CONSTRAINT ConsoleRegionFK FOREIGN KEY (Region) REFERENCES Regions(Region),
  CONSTRAINT ModelNameFK FOREIGN KEY (ModelName) REFERENCES Console_Models(ModelName),
  CONSTRAINT ConsoleConditionFK FOREIGN KEY (`Condition`) REFERENCES `Condition`(`Condition`),
  CONSTRAINT ConsoleSealOrCIBFK FOREIGN KEY (SealOrCIB) REFERENCES SealOrCIB(SealOrCIB)
);

DELIMITER $$
CREATE TRIGGER before_insert_consoles
BEFORE INSERT ON Consoles
FOR EACH ROW
BEGIN
  IF NEW.UID IS NULL OR NEW.UID = '' THEN
    SET NEW.UID = UUID();
  END IF;
END$$
DELIMITER ;


-- SealOrCIB
INSERT INTO SealOrCIB (SealOrCIB) VALUES ('Neither');
INSERT INTO SealOrCIB (SealOrCIB) VALUES ('Sealed');
INSERT INTO SealOrCIB (SealOrCIB) VALUES ('CIB');

-- Conditions
INSERT INTO `Condition` (`Condition`) VALUES ('Near Mint');
INSERT INTO `Condition` (`Condition`) VALUES ('Very Good');
INSERT INTO `Condition` (`Condition`) VALUES ('Good');
INSERT INTO `Condition` (`Condition`) VALUES ('Not Very Good');
INSERT INTO `Condition` (`Condition`) VALUES ('Damaged');


-- ESRB Ratings
INSERT INTO ESRB_Ratings (Rating) VALUES ('E');
INSERT INTO ESRB_Ratings (Rating) VALUES ('E 10+');
INSERT INTO ESRB_Ratings (Rating) VALUES ('T');
INSERT INTO ESRB_Ratings (Rating) VALUES ('M');
INSERT INTO ESRB_Ratings (Rating) VALUES ('AO');
INSERT INTO ESRB_Ratings (Rating) VALUES ('RP');

-- Regions
INSERT INTO Regions (Region) VALUES ('NTSC-U/C');
INSERT INTO Regions (Region) VALUES ('NTSC-J');
INSERT INTO Regions (Region) VALUES ('NTSC-C');
INSERT INTO Regions (Region) VALUES ('PAL');

-- Game Names
INSERT INTO Game_Names (GameName, UPC, ReleaseDate, Rating) VALUES ('Rule of Rose', 730865530205, '2006-09-12', 'M');
INSERT INTO Game_Names (GameName, UPC, ReleaseDate, Rating) VALUES ('LSD: Dream Emulator', 4988126510244, '1998-10-22', 'T');
INSERT INTO Game_Names (GameName, UPC, ReleaseDate, Rating) VALUES ('Shenmue', 10086510591, '2000-11-08', 'T');
INSERT INTO Game_Names (GameName, UPC, ReleaseDate, Rating) VALUES ('Gauntlet Legends', 31719198184, '1999-09-29', 'T');
INSERT INTO Game_Names (GameName, UPC, ReleaseDate, Rating) VALUES ('Mega Man 2', 13388110117, '1989-06-01', 'E');
INSERT INTO Game_Names (GameName, UPC, ReleaseDate, Rating) VALUES ('.hack//INFECTION Part 1', 45557180119, '2000-02-01', 'T');
INSERT INTO Game_Names (GameName, UPC, ReleaseDate, Rating) VALUES ('Front Mission 3', 662248900056, '2003-02-28', 'T');
INSERT INTO Game_Names (GameName, UPC, ReleaseDate, Rating) VALUES ('Parasite Eve', 662248998015, '1998-09-09', 'M');
INSERT INTO Game_Names (GameName, UPC, ReleaseDate, Rating) VALUES ('Pokemon Red', 45496730734, '1998-09-27', 'E');
INSERT INTO Game_Names (GameName, UPC, ReleaseDate, Rating) VALUES ('Pokemon Blue', 45496730826, '1998-09-27', 'E');
INSERT INTO Game_Names (GameName, UPC, ReleaseDate, Rating) VALUES ('Pokemon Yellow', 45496730895, '1999-10-01', 'E');



-- CoOpOrVs
INSERT INTO CoOp_Or_Vs (CoOpOrVs, OfflineOrOnline) VALUES ('Neither', 0);
INSERT INTO CoOp_Or_Vs (CoOpOrVs, OfflineOrOnline) VALUES ('CoOp', 0);
INSERT INTO CoOp_Or_Vs (CoOpOrVs, OfflineOrOnline) VALUES ('Versus', 0);
INSERT INTO CoOp_Or_Vs (CoOpOrVs, OfflineOrOnline) VALUES ('Neither', 1);
INSERT INTO CoOp_Or_Vs (CoOpOrVs, OfflineOrOnline) VALUES ('CoOp', 1);
INSERT INTO CoOp_Or_Vs (CoOpOrVs, OfflineOrOnline) VALUES ('Versus', 1);

-- Players
INSERT INTO Player_Numbers (MaxPlayerNumber) VALUES (1);
INSERT INTO Player_Numbers (MaxPlayerNumber) VALUES (4);
INSERT INTO Player_Numbers (MaxPlayerNumber) VALUES (2);

-- Series
INSERT INTO Series (Series) VALUES ('Bomberman');
INSERT INTO Series (Series) VALUES ('Fallout');
INSERT INTO Series (Series) VALUES ('Gauntlet');
INSERT INTO Series (Series) VALUES ('Legacy of Kain');
INSERT INTO Series (Series) VALUES ('Mega Man');
INSERT INTO Series (Series) VALUES ('Pokemon');
INSERT INTO Series (Series) VALUES ('Shenmue');
INSERT INTO Series (Series) VALUES ('Front Mission');
INSERT INTO Series (Series) VALUES ('.hack//');
INSERT INTO Series (Series) VALUES ('Parasite Eve');

-- Genres
INSERT INTO Genres (Genre) VALUES ('Adventure');
INSERT INTO Genres (Genre) VALUES ('Fighting');
INSERT INTO Genres (Genre) VALUES ('Hack and Slash');
INSERT INTO Genres (Genre) VALUES ('Horror');
INSERT INTO Genres (Genre) VALUES ('Platformer');
INSERT INTO Genres (Genre) VALUES ('RPG');
INSERT INTO Genres (Genre) VALUES ('Survival');
INSERT INTO Genres (Genre) VALUES ('Strategy');
INSERT INTO Genres (Genre) VALUES ('Turn Based Strategy');

-- Game Has Players
INSERT INTO Game_Has_Players (GameName, MaxPlayerNumber, CoOpOrVs, OfflineOrOnline) VALUES ('Gauntlet Legends', 1, 'Neither', 0);
INSERT INTO Game_Has_Players (GameName, MaxPlayerNumber, CoOpOrVs, OfflineOrOnline) VALUES ('Gauntlet Legends', 4, 'CoOp', 0);
INSERT INTO Game_Has_Players (GameName, MaxPlayerNumber, CoOpOrVs, OfflineOrOnline) VALUES ('LSD: Dream Emulator', 1, 'Neither', 0);
INSERT INTO Game_Has_Players (GameName, MaxPlayerNumber, CoOpOrVs, OfflineOrOnline) VALUES ('Mega Man 2', 1, 'Neither', 0);
INSERT INTO Game_Has_Players (GameName, MaxPlayerNumber, CoOpOrVs, OfflineOrOnline) VALUES ('Rule of Rose', 1, 'Neither', 0);
INSERT INTO Game_Has_Players (GameName, MaxPlayerNumber, CoOpOrVs, OfflineOrOnline) VALUES ('Shenmue', 1, 'Neither', 0);
INSERT INTO Game_Has_Players (GameName, MaxPlayerNumber, CoOpOrVs, OfflineOrOnline) VALUES ('.hack//INFECTION Part 1', 1, 'Neither', 0);
INSERT INTO Game_Has_Players (GameName, MaxPlayerNumber, CoOpOrVs, OfflineOrOnline) VALUES ('Front Mission 3', 1, 'Neither', 0);
INSERT INTO Game_Has_Players (GameName, MaxPlayerNumber, CoOpOrVs, OfflineOrOnline) VALUES ('Parasite Eve', 1, 'Neither', 0);
INSERT INTO Game_Has_Players (GameName, MaxPlayerNumber, CoOpOrVs, OfflineOrOnline) VALUES ('Pokemon Red', 1, 'Neither', 0);
INSERT INTO Game_Has_Players (GameName, MaxPlayerNumber, CoOpOrVs, OfflineOrOnline) VALUES ('Pokemon Red', 2, 'Versus', 0);
INSERT INTO Game_Has_Players (GameName, MaxPlayerNumber, CoOpOrVs, OfflineOrOnline) VALUES ('Pokemon Blue', 1, 'Neither', 0);
INSERT INTO Game_Has_Players (GameName, MaxPlayerNumber, CoOpOrVs, OfflineOrOnline) VALUES ('Pokemon Blue', 2, 'Versus', 0);
INSERT INTO Game_Has_Players (GameName, MaxPlayerNumber, CoOpOrVs, OfflineOrOnline) VALUES ('Pokemon Yellow', 1, 'Neither', 0);
INSERT INTO Game_Has_Players (GameName, MaxPlayerNumber, CoOpOrVs, OfflineOrOnline) VALUES ('Pokemon Yellow', 2, 'Versus', 0);

-- Game Has a Series
INSERT INTO Game_Has_a_Series (GameName, Series) VALUES ('Pokemon Red', 'Pokemon');
INSERT INTO Game_Has_a_Series (GameName, Series) VALUES ('Pokemon Blue', 'Pokemon');
INSERT INTO Game_Has_a_Series (GameName, Series) VALUES ('Pokemon Yellow', 'Pokemon');
INSERT INTO Game_Has_a_Series (GameName, Series) VALUES ('Front Mission 3', 'Front Mission');
INSERT INTO Game_Has_a_Series (GameName, Series) VALUES ('Shenmue', 'Shenmue');
INSERT INTO Game_Has_a_Series (GameName, Series) VALUES ('Mega Man 2', 'Mega Man');
INSERT INTO Game_Has_a_Series (GameName, Series) VALUES ('Gauntlet Legends', 'Gauntlet');
INSERT INTO Game_Has_a_Series (GameName, Series) VALUES ('.hack//INFECTION Part 1', '.hack//');
INSERT INTO Game_Has_a_Series (GameName, Series) VALUES ('Parasite Eve', 'Parasite Eve');

-- Game Has Genres
INSERT INTO Game_Has_Genres (GameName, Genre) VALUES ('Gauntlet Legends', 'Adventure');
INSERT INTO Game_Has_Genres (GameName, Genre) VALUES ('Gauntlet Legends', 'Hack and Slash');
INSERT INTO Game_Has_Genres (GameName, Genre) VALUES ('LSD: Dream Emulator', 'Adventure');
INSERT INTO Game_Has_Genres (GameName, Genre) VALUES ('Mega Man 2', 'Adventure');
INSERT INTO Game_Has_Genres (GameName, Genre) VALUES ('Mega Man 2', 'Platformer');
INSERT INTO Game_Has_Genres (GameName, Genre) VALUES ('Rule of Rose', 'Horror');
INSERT INTO Game_Has_Genres (GameName, Genre) VALUES ('Rule of Rose', 'Survival');
INSERT INTO Game_Has_Genres (GameName, Genre) VALUES ('Shenmue', 'Adventure');
INSERT INTO Game_Has_Genres (GameName, Genre) VALUES ('Shenmue', 'Fighting');
INSERT INTO Game_Has_Genres (GameName, Genre) VALUES ('Shenmue', 'RPG');
INSERT INTO Game_Has_Genres (GameName, Genre) VALUES ('.hack//INFECTION Part 1', 'RPG');
INSERT INTO Game_Has_Genres (GameName, Genre) VALUES ('.hack//INFECTION Part 1', 'Hack and Slash');
INSERT INTO Game_Has_Genres (GameName, Genre) VALUES ('Front Mission 3', 'RPG');
INSERT INTO Game_Has_Genres (GameName, Genre) VALUES ('Front Mission 3', 'Strategy');
INSERT INTO Game_Has_Genres (GameName, Genre) VALUES ('Front Mission 3', 'Turn Based Strategy');
INSERT INTO Game_Has_Genres (GameName, Genre) VALUES ('Parasite Eve', 'RPG');
INSERT INTO Game_Has_Genres (GameName, Genre) VALUES ('Parasite Eve', 'Adventure');
INSERT INTO Game_Has_Genres (GameName, Genre) VALUES ('Parasite Eve', 'Horror');
INSERT INTO Game_Has_Genres (GameName, Genre) VALUES ('Pokemon Red', 'RPG');
INSERT INTO Game_Has_Genres (GameName, Genre) VALUES ('Pokemon Red', 'Turn Based Strategy');
INSERT INTO Game_Has_Genres (GameName, Genre) VALUES ('Pokemon Red', 'Adventure');
INSERT INTO Game_Has_Genres (GameName, Genre) VALUES ('Pokemon Blue', 'RPG');
INSERT INTO Game_Has_Genres (GameName, Genre) VALUES ('Pokemon Blue', 'Turn Based Strategy');
INSERT INTO Game_Has_Genres (GameName, Genre) VALUES ('Pokemon Blue', 'Adventure');
INSERT INTO Game_Has_Genres (GameName, Genre) VALUES ('Pokemon Yellow', 'RPG');
INSERT INTO Game_Has_Genres (GameName, Genre) VALUES ('Pokemon Yellow', 'Turn Based Strategy');
INSERT INTO Game_Has_Genres (GameName, Genre) VALUES ('Pokemon Yellow', 'Adventure');

-- Games
INSERT INTO Games (GameName, Notes, `Condition`, Region) VALUES ('Gauntlet Legends', 'Loose Cart', 'Very Good', 'NTSC-U/C');
INSERT INTO Games (GameName, Notes, `Condition`, Region) VALUES ('Gauntlet Legends', 'Has manual', 'Near Mint', 'NTSC-U/C');

INSERT INTO Games (GameName, `Condition`, SealOrCIB, Region) VALUES ('LSD: Dream Emulator', 'Near Mint', 'CIB', 'NTSC-J');
INSERT INTO Games (GameName, Notes, `Condition`, SealOrCIB, Region) VALUES ('Mega Man 2', 'Loose Cart', 'Very Good', 'CIB', 'NTSC-U/C');
INSERT INTO Games (GameName, `Condition`, SealOrCIB, Region) VALUES ('Rule of Rose', 'Near Mint', 'CIB', 'NTSC-U/C');
INSERT INTO Games (GameName, `Condition`, SealOrCIB, Region) VALUES ('Shenmue', 'Near Mint', 'CIB', 'NTSC-U/C');

-- Memorabilia
INSERT INTO Memorabilia (Description, Series, `Condition`) VALUES ('Bomberman Plush', 'Bomberman', 'Near Mint');
INSERT INTO Memorabilia (Description, Series, `Condition`, SealOrCIB) VALUES ('Magic the Gathering Fallout Collectors Booster Box', 'Fallout', 'Near Mint', 'Sealed');
INSERT INTO Memorabilia (Description, Series, `Condition`) VALUES ('Legacy of Kain: Soul Reaver Comic Book', 'Legacy of Kain', 'Very Good');
INSERT INTO Memorabilia (Description, Series, `Condition`, SealOrCIB) VALUES ('Mega Bloks Pokedex', 'Pokemon', 'Near Mint', 'Sealed');
INSERT INTO Memorabilia (Description, Series, `Condition`) VALUES ('Complete Base Set of Pokemon Cards', 'Pokemon', 'Very Good');

-- Console Publishers
INSERT INTO Console_Publishers (ConsolePublisher) VALUES ('Atari');
INSERT INTO Console_Publishers (ConsolePublisher) VALUES ('Microsoft');
INSERT INTO Console_Publishers (ConsolePublisher) VALUES ('Nintendo');
INSERT INTO Console_Publishers (ConsolePublisher) VALUES ('Sega');
INSERT INTO Console_Publishers (ConsolePublisher) VALUES ('Sony');

-- Console Models
INSERT INTO Console_Models (ModelName, ModelNumber, ConsolePublisher) VALUES ('Playstation 2', 'SCPH-50001-N', 'Sony');
INSERT INTO Console_Models (ModelName, ModelNumber, ConsolePublisher) VALUES ('Switch', 'HAC S KABAA USZ', 'Nintendo');
INSERT INTO Console_Models (ModelName, ModelNumber, ConsolePublisher) VALUES ('Atari 2600', 'CX-2600A', 'Atari');
INSERT INTO Console_Models (ModelName, ModelNumber, ConsolePublisher) VALUES ('Xbox', 'X0061-001', 'Microsoft');
INSERT INTO Console_Models (ModelName, ModelNumber, ConsolePublisher) VALUES ('Dreamcast', 'HKT-3020', 'Sega');
INSERT INTO Console_Models (ModelName, ModelNumber, ConsolePublisher) VALUES ('Gameboy', 'DMG-01', 'Nintendo');
INSERT INTO Console_Models (ModelName, ModelNumber, ConsolePublisher) VALUES ('Super Nintendo', 'SNS-001', 'Nintendo');
INSERT INTO Console_Models (ModelName, ModelNumber, ConsolePublisher) VALUES ('Playstation', 'SCPH-5501', 'Sony');
INSERT INTO Console_Models (ModelName, ModelNumber, ConsolePublisher) VALUES ('Nintendo 64', 'NUS-001', 'Nintendo');
INSERT INTO Console_Models (ModelName, ModelNumber, ConsolePublisher) VALUES ('Nintendo Entertainment System', 'NES-001', 'Nintendo');

-- Consoles
INSERT INTO Consoles (ModelName, Notes, `Condition`, Region) VALUES ('Playstation 2', 'This is my original PS2, have manual and cables', 'Good', 'PAL');
INSERT INTO Consoles (ModelName, Notes, `Condition`, Region) VALUES ('Atari 2600', 'Loose console with cables', 'Good', 'NTSC-U/C');
INSERT INTO Consoles (ModelName, `Condition`, SealOrCIB, Region) VALUES ('Switch', 'Very Good', 'CIB', 'NTSC-U/C');
INSERT INTO Consoles (ModelName, isModded, Notes, `Condition`, Region) VALUES ('Xbox', 1, 'Loose console with cables', 'Good', 'NTSC-U/C');
INSERT INTO Consoles (ModelName, Notes, `Condition`, Region) VALUES ('Dreamcast', 'Loose console with cables', 'Good', 'NTSC-U/C');

-- Peripherals
INSERT INTO Peripheral_Names (PeripheralName, UPC) VALUES ('Gameboy Printer Pokemon Edition', '4902370503678');
INSERT INTO Peripheral_Names (PeripheralName, UPC) VALUES ('Super Multitap 2', '4988607000639');
INSERT INTO Peripheral_Names (PeripheralName, UPC) VALUES ('Guncon', '4907892010321');
INSERT INTO Peripheral_Names (PeripheralName, UPC) VALUES ('Steel Battalion Controller', '013388290024');
INSERT INTO Peripheral_Names (PeripheralName, UPC) VALUES ('Dualshock', '711719405900');

-- Peripherals proper
INSERT INTO Peripherals (PeripheralName, `Condition`, SealOrCIB) VALUES ('Gameboy Printer Pokemon Edition', 'Good', 'CIB');
INSERT INTO Peripherals (PeripheralName, `Condition`, SealOrCIB) VALUES ('Super Multitap 2', 'Good', 'CIB');
INSERT INTO Peripherals (PeripheralName, `Condition`, SealOrCIB) VALUES ('Guncon', 'Good', 'CIB');
INSERT INTO Peripherals (PeripheralName, `Condition`, SealOrCIB) VALUES ('Steel Battalion Controller', 'Good', 'Sealed');
INSERT INTO Peripherals (PeripheralName, `Condition`) VALUES ('Dualshock', 'Not Very Good');

-- Peripheral Bridges
INSERT INTO Console_Has_a_Peripheral (PeripheralName, ModelName) VALUES ('Gameboy Printer Pokemon Edition', 'Gameboy');
INSERT INTO Console_Has_a_Peripheral (PeripheralName, ModelName) VALUES ('Super Multitap 2', 'Super Nintendo');
INSERT INTO Console_Has_a_Peripheral (PeripheralName, ModelName) VALUES ('Guncon', 'Playstation');
INSERT INTO Console_Has_a_Peripheral (PeripheralName, ModelName) VALUES ('Steel Battalion Controller', 'Xbox');
INSERT INTO Console_Has_a_Peripheral (PeripheralName, ModelName) VALUES ('Dualshock', 'Playstation');

-- Magazines
INSERT INTO Magazine_Names (MagazineName, MagazineVolume, ReleaseDate) VALUES ('Tips & Tricks', '97', '2003-03-01');
INSERT INTO Magazine_Names (MagazineName, MagazineVolume, ReleaseDate) VALUES ('Tips & Tricks', '98', '2003-04-01');
INSERT INTO Magazine_Names (MagazineName, MagazineVolume, ReleaseDate) VALUES ('Tips & Tricks', '102', '2003-08-01');
INSERT INTO Magazine_Names (MagazineName, MagazineVolume, ReleaseDate) VALUES ('Tips & Tricks', '103', '2003-09-01');
INSERT INTO Magazine_Names (MagazineName, MagazineVolume, ReleaseDate) VALUES ('Tips & Tricks', '111', '2004-05-01');

INSERT INTO Magazines (MagazineName, MagazineVolume, `Condition`) VALUES ('Tips & Tricks', '97', 'Not Very Good');
INSERT INTO Magazines (MagazineName, MagazineVolume, `Condition`) VALUES ('Tips & Tricks', '98', 'Not Very Good');
INSERT INTO Magazines (MagazineName, MagazineVolume, `Condition`) VALUES ('Tips & Tricks', '102', 'Not Very Good');
INSERT INTO Magazines (MagazineName, MagazineVolume, `Condition`) VALUES ('Tips & Tricks', '103', 'Not Very Good');
INSERT INTO Magazines (MagazineName, MagazineVolume, `Condition`) VALUES ('Tips & Tricks', '111', 'Not Very Good');

-- Magazine has a game
-- These games are not the correct games in the magazines it just requires alot of extra work to put the real ones in
INSERT INTO Magazine_Has_a_Game (MagazineName, MagazineVolume, GameName, GuideOrCheats) VALUES ('Tips & Tricks', '97', '.hack//INFECTION Part 1', 0);
INSERT INTO Magazine_Has_a_Game (MagazineName, MagazineVolume, GameName, GuideOrCheats) VALUES ('Tips & Tricks', '98', 'Rule of Rose', 0);
INSERT INTO Magazine_Has_a_Game (MagazineName, MagazineVolume, GameName, GuideOrCheats) VALUES ('Tips & Tricks', '102', 'Pokemon Blue', 0);
INSERT INTO Magazine_Has_a_Game (MagazineName, MagazineVolume, GameName, GuideOrCheats) VALUES ('Tips & Tricks', '103', 'Gauntlet Legends', 1);
INSERT INTO Magazine_Has_a_Game (MagazineName, MagazineVolume, GameName, GuideOrCheats) VALUES ('Tips & Tricks', '97', 'Mega Man 2', 1);

-- Game Has a Console
INSERT INTO Game_Has_a_Console (GameName, ModelName) VALUES ('Rule of Rose', 'Playstation 2');
INSERT INTO Game_Has_a_Console (GameName, ModelName) VALUES ('.hack//INFECTION PART 1', 'Playstation 2');
INSERT INTO Game_Has_a_Console (GameName, ModelName) VALUES ('LSD: Dream Emulator', 'Playstation');
INSERT INTO Game_Has_a_Console (GameName, ModelName) VALUES ('Front Mission 3', 'Playstation');
INSERT INTO Game_Has_a_Console (GameName, ModelName) VALUES ('Parasite Eve', 'Playstation');
INSERT INTO Game_Has_a_Console (GameName, ModelName) VALUES ('Shenmue', 'Dreamcast');
INSERT INTO Game_Has_a_Console (GameName, ModelName) VALUES ('Gauntlet Legends', 'Nintendo 64');
INSERT INTO Game_Has_a_Console (GameName, ModelName) VALUES ('Mega Man 2', 'Nintendo Entertainment System');
INSERT INTO Game_Has_a_Console (GameName, ModelName) VALUES ('Pokemon Red', 'Gameboy');
INSERT INTO Game_Has_a_Console (GameName, ModelName) VALUES ('Pokemon Blue', 'Gameboy');
INSERT INTO Game_Has_a_Console (GameName, ModelName) VALUES ('Pokemon Yellow', 'Gameboy');

-- Strategy Guides
INSERT INTO Strategy_Guide_Publishers (GuidePublisher) VALUES ('Brady Games');
INSERT INTO Strategy_Guide_Publishers (GuidePublisher) VALUES ('Prima Games');
INSERT INTO Strategy_Guide_Publishers (GuidePublisher) VALUES ('Nintendo');

INSERT INTO Strategy_Guide_Names (GuideName, GuidePublisher) VALUES ('.hack//INFECTION Part 1', 'Brady Games');
INSERT INTO Strategy_Guide_Names (GuideName, GuidePublisher) VALUES ('Front Mission 3', 'Brady Games');
INSERT INTO Strategy_Guide_Names (GuideName, GuidePublisher) VALUES ('Parasite Eve', 'Brady Games');
INSERT INTO Strategy_Guide_Names (GuideName, GuidePublisher) VALUES ('Pokemon Special Edition for Yellow, Red and Blue', 'Nintendo');
INSERT INTO Strategy_Guide_Names (GuideName, GuidePublisher) VALUES ('Pokemon Trading Card Game', 'Prima Games');

INSERT INTO Strategy_Guides (GuideName, GuidePublisher, `Condition`) VALUES ('.hack//INFECTION Part 1', 'Brady Games', 'Good');
INSERT INTO Strategy_Guides (GuideName, GuidePublisher, `Condition`) VALUES ('Front Mission 3', 'Brady Games', 'Good');
INSERT INTO Strategy_Guides (GuideName, GuidePublisher, `Condition`) VALUES ('Parasite Eve', 'Brady Games', 'Good');
INSERT INTO Strategy_Guides (GuideName, GuidePublisher, `Condition`) VALUES ('Pokemon Special Edition for Yellow, Red and Blue', 'Nintendo', 'Good');
INSERT INTO Strategy_Guides (GuideName, GuidePublisher, `Condition`) VALUES ('Pokemon Trading Card Game', 'Prima Games', 'Good');

INSERT INTO Game_Has_a_Guide (GameName, GuideName, GuidePublisher) VALUES ('.hack//INFECTION Part 1', '.hack//INFECTION Part 1', 'Brady Games');
INSERT INTO Game_Has_a_Guide (GameName, GuideName, GuidePublisher) VALUES ('Front Mission 3', 'Front Mission 3', 'Brady Games');
INSERT INTO Game_Has_a_Guide (GameName, GuideName, GuidePublisher) VALUES ('Parasite Eve', 'Parasite Eve', 'Brady Games');
INSERT INTO Game_Has_a_Guide (GameName, GuideName, GuidePublisher) VALUES ('Pokemon Red', 'Pokemon Special Edition for Yellow, Red and Blue', 'Nintendo');
INSERT INTO Game_Has_a_Guide (GameName, GuideName, GuidePublisher) VALUES ('Pokemon Blue', 'Pokemon Special Edition for Yellow, Red and Blue', 'Nintendo');
INSERT INTO Game_Has_a_Guide (GameName, GuideName, GuidePublisher) VALUES ('Pokemon Yellow', 'Pokemon Special Edition for Yellow, Red and Blue', 'Nintendo');

