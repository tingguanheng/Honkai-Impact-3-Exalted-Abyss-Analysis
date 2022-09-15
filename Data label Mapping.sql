-- Updated as of 15 September 2022

use HI3_Exalted_Abyss

drop table if exists last_boss

create table last_boss
(
last_boss nvarchar(max),
boss_name nvarchar(max)
)
 
 insert into last_boss
 values
('SME' , 'Super Mecha Evoji'),
('FE' , 'Flame Emperor'),
('NMG-2' , 'Nightmare Module G-2'),
('FuHua' , 'Shadow Knight'),
('LR' , 'Lance Rider'),
('SoD' , 'Son of Dawn'),
('SH' , 'Screeching Hunter'),
('VWeb' , 'Venomous Web'),
('HuskA' , 'Husk-Agnosis')

drop table if exists final_boss

create table final_boss
(
final_boss nvarchar(max),
boss_name nvarchar(max)
)
 
 insert into final_boss
 values
('Benares' , 'Benares: Fire form'),
('Nihilius' , 'Husk-Nihilius'),
('Couatl' , 'Couatl: Revenant'),
('FuHua' , 'Shadow Knight'),
('HOTR' , 'Herrscher of the Rimestar'),
('ArK' , 'Argent Knight: Artemis'),
('Sassaka' , 'Saha: Assaka'),
('DXY' , 'Dark Xuanyuan'),
('HOS' , 'Herscherr of Sentience'),
('HOMU-M', 'HOMU-Magician'),
('NihiliusB' , 'Husk-Nihilius'),
('Ninja' , 'The Mysterious Ninja'),
('MHT3B' , 'MHT-3B Nirvana'),
('DoW' , 'Dominator of Wolves'),
('ADRL' , 'Arc DEF: Riot & Lich'),
('HoDM' , 'HoD Minion'),
('ST' , 'Storm Templar'),
('Elysia' , 'Flame Chaser: Elysia'),
('Otto' , 'Otto Apocalypse'),
('OA' , 'Otto Apocalypse'),
('LSS' , 'Li Sushang'),
('NK' , 'Nocturnal Knight'),
('TonatiuhB' , 'Tonatiuh'),
('OS' , 'Opaque Shadow')

drop table if exists main_dps

create table main_dps
(
main_dps nvarchar(max),
dps_name nvarchar(max)
)
 
 insert into main_dps
 values
('HOT' , 'Herscherr of Thunder'),
('HOR' , 'Herscherr of Reason'),
('SP' , 'Swallowtail Phantasm'),
('BR' , 'Blood Rose'),
('Nil' , 'Not used'),
('HOV' , 'Herscherr of the Void'),
('FS' , 'Flame Sakitama'),
('DJ' , 'Darkbolt Jonin'),
('SN' , 'Stygian Nymph'),
('TP' , 'Twilight Paladin'),
('VG' , 'Valkyrie Gloria'),
('NS' , 'Night Squire'),
('HOS' , 'Herscherr of Sentience'),
('VK' , 'Vermilion Knight : Eclipse'),
('HOF' , 'Herrscher of Flamescion'),
('AK' , 'Argent Knight : Artemis'),
('FR' , 'Fallen Rosemary'),
('SK' , 'Shadow Knight'),
('SA' , 'Spina Astera'),
('BK' , 'Bright Knight: Excelsis'),
('PE' , 'Platinum Equinox')

drop table if exists sub_boss

create table sub_boss
(
sub_boss nvarchar(max),
boss_name nvarchar(max)
)
 
 insert into sub_boss
 values
('FE' , 'Flame Emperor'),
('SME' , 'Super Mecha Evoji'),
('HOTR' , 'Herrscher of the Rimestar'),
('SH' , 'Screeching Hunter'),
('IBSab' , 'Immortal Blades: Saboteur'),
('Mexicatl' , 'Mexicatl: Torrent of Gluttony'),
('MexicatlB' , 'Mexicatl: Torrent of Gluttony'),
('ST' , 'Storm Templar'),
('Padrino' , 'Padrino MFG'),
('SoD' , 'Son of Dawn'),
('SR' , 'Shrapnel Rattler')
