-- Remove all identifiers from patients
-- This script is used by OpenMRS 1.6, but should also work on OpenMRS 1.9
-- Ellen Ball
-- July 29, 2011
-- Partners In Health

-- Remove all free text from observations
-- CHOOSE between deleting obs or nulling text
-- delete from obs where value_text is not null;
update obs set value_text = 'Deidentified' where not value_text is NULL;

-- Patient identifiers
-- Remove validators and replace extermal id with internal id
update patient_identifier_type set validator = '';
update patient_identifier set identifier = patient_identifier_id;

-- Mother's name
-- TBD:  check person_attribute_type_id for mother's name
-- delete from person_attribute where person_attribute_type_id = 4;

-- Telephone number
-- TBD:  check person_attribute_type_id for phone number
-- delete from person_attribute where person_attribute_type_id = 10;

-- Set all identifying addresses information to NULL
UPDATE person_address SET address1 = NULL, address2 = NULL where not address1 is NULL;
UPDATE person_address SET latitude = NULL where not latitude is NULL;
UPDATE person_address SET longitude = NULL where not longitude is NULL;
UPDATE person_address SET county_district = NULL where not county_district is NULL;

-- Remove all middle names and second family names
UPDATE person_name SET family_name2 = NULL where not family_name2 is NULL;
UPDATE person_name SET middle_name = NULL where not middle_name is NULL;

-- Set all family names to a random bunch of 40 last names
update person_name set family_name = 'Miranda';
update person_name set family_name = 'Allen' where person_id % 2 = 0;
update person_name set family_name = 'Waters' where person_id % 3 = 0;
update person_name set family_name = 'Ball' where person_id % 4 = 0;
update person_name set family_name = 'Fraser' where person_id % 5 = 0;
update person_name set family_name = 'Choi' where person_id % 6 = 0;
update person_name set family_name = 'Blaya' where person_id % 7 = 0;
update person_name set family_name = 'Keeton' where person_id % 8 = 0;
update person_name set family_name = 'Amoroso' where person_id % 9 = 0;
update person_name set family_name = 'Hsuing' where person_id % 10 = 0;
update person_name set family_name = 'Seaton' where person_id % 11 = 0;
update person_name set family_name = 'Montgomery' where person_id % 12 = 0;
update person_name set family_name = 'Forest' where person_id % 13 = 0;
update person_name set family_name = 'Kastenbaum' where person_id % 14 = 0;
update person_name set family_name = 'Gans' where person_id % 15 = 0;
update person_name set family_name = 'Jazayeri' where person_id % 16 = 0;
update person_name set family_name = 'Dahl' where person_id % 17 = 0;
update person_name set family_name = 'Farmer' where person_id % 18 = 0;
update person_name set family_name = 'Constan' where person_id % 19 = 0;
update person_name set family_name = 'Thomas' where person_id % 20 = 0;
update person_name set family_name = 'Marx' where person_id % 21 = 0;
update person_name set family_name = 'Zintl' where person_id % 22 = 0;
update person_name set family_name = 'Soucy' where person_id % 23 = 0;
update person_name set family_name = 'West' where person_id % 24 = 0;
update person_name set family_name = 'Cardoza' where person_id % 25 = 0;
update person_name set family_name = 'White' where person_id % 26 = 0;
update person_name set family_name = 'Mccormick' where person_id % 27 = 0;
update person_name set family_name = 'Kim' where person_id % 28 = 0;
update person_name set family_name = 'Kidder' where person_id % 29 = 0;
update person_name set family_name = 'Yatuta' where person_id % 30 = 0;
update person_name set family_name = 'Mbuyu' where person_id % 31 = 0;
update person_name set family_name = 'Mukatete' where person_id % 32 = 0;
update person_name set family_name = 'Kimihura' where person_id % 33 = 0;
update person_name set family_name = 'Kichura' where person_id % 34 = 0;
update person_name set family_name = 'Kibungo' where person_id % 35 = 0;
update person_name set family_name = 'Rwamagana' where person_id % 36 = 0;
update person_name set family_name = 'Ihene' where person_id % 37 = 0;
update person_name set family_name = 'Inka' where person_id % 38 = 0;
update person_name set family_name = 'Kamikazi' where person_id % 39 = 0;
update person_name set family_name = 'Inzira' where person_id % 40 = 0;
update person_name set family_name = 'Virunga' where person_id % 41 = 0;

-- Set all given names to 21 different common names for males and females
update person_name set given_name = 'Alex';
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Paul' where p.gender = 'M' and p.person_id % 2 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Tom' where p.gender = 'M' and p.person_id % 3 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Ted' where p.gender = 'M' and p.person_id % 4 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Max' where p.gender = 'M' and p.person_id % 5 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Hamish' where p.gender = 'M' and p.person_id % 6 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Darius' where p.gender = 'M' and p.person_id % 7 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Simon' where p.gender = 'M' and p.person_id % 8 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Edward' where p.gender = 'M' and p.person_id % 9 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Charles' where p.gender = 'M' and p.person_id % 10 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Luke' where p.gender = 'M' and p.person_id % 11 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Barack' where p.gender = 'M' and p.person_id % 12 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'John' where p.gender = 'M' and p.person_id % 13 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Michael' where p.gender = 'M' and p.person_id % 14 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Christopher' where p.gender = 'M' and p.person_id % 15 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Sam' where p.gender = 'M' and p.person_id % 16 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Sebastian' where p.gender = 'M' and p.person_id % 17 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Howard' where p.gender = 'M' and p.person_id % 18 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Adam' where p.gender = 'M' and p.person_id % 19 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Joshua' where p.gender = 'M' and p.person_id % 20 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Steven' where p.gender = 'M' and p.person_id % 21 = 0;

update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Mary' where (p.gender is null or p.gender != 'M') and p.person_id % 2 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Ophelia' where (p.gender is null or p.gender != 'M') and p.person_id % 3 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Kathryn' where (p.gender is null or p.gender != 'M') and p.person_id % 4 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Ellen' where (p.gender is null or p.gender != 'M') and p.person_id % 5 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Naomi' where (p.gender is null or p.gender != 'M') and p.person_id % 6 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Claire' where (p.gender is null or p.gender != 'M') and p.person_id % 7 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Lucy' where (p.gender is null or p.gender != 'M') and p.person_id % 8 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Carole' where (p.gender is null or p.gender != 'M') and p.person_id % 9 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Sophia' where (p.gender is null or p.gender != 'M') and p.person_id % 10 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Alice' where (p.gender is null or p.gender != 'M') and p.person_id % 11 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Melissa' where (p.gender is null or p.gender != 'M') and p.person_id % 12 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Vanessa' where (p.gender is null or p.gender != 'M') and p.person_id % 13 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Sally' where (p.gender is null or p.gender != 'M') and p.person_id % 14 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Anne' where (p.gender is null or p.gender != 'M') and p.person_id % 15 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Katie' where (p.gender is null or p.gender != 'M') and p.person_id % 16 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Jennifer' where (p.gender is null or p.gender != 'M') and p.person_id % 17 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Jill' where (p.gender is null or p.gender != 'M') and p.person_id % 18 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Susan' where (p.gender is null or p.gender != 'M') and p.person_id % 19 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Megan' where (p.gender is null or p.gender != 'M') and p.person_id % 20 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Amanda' where (p.gender is null or p.gender != 'M') and p.person_id % 21 = 0;

update idgen_remote_source set url = 'https://humci.pih-emr.org:8080/mirebalais/module/idgen/exportIdentifiers.form?source=5&comment=MirebalaisDemo' where id = 1;
update idgen_remote_source set user = 'testidgen' where id = 1;
update idgen_remote_source set password = 'Testing123' where id = 1;