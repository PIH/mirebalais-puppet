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
update person_name set family_name = 'Allen' where person_name_id % 2 = 0;
update person_name set family_name = 'Waters' where person_name_id % 3 = 0;
update person_name set family_name = 'Ball' where person_name_id % 4 = 0;
update person_name set family_name = 'Fraser' where person_name_id % 5 = 0;
update person_name set family_name = 'Choi' where person_name_id % 6 = 0;
update person_name set family_name = 'Blaya' where person_name_id % 7 = 0;
update person_name set family_name = 'Keeton' where person_name_id % 8 = 0;
update person_name set family_name = 'Amoroso' where person_name_id % 9 = 0;
update person_name set family_name = 'Hsuing' where person_name_id % 10 = 0;
update person_name set family_name = 'Seaton' where person_name_id % 11 = 0;
update person_name set family_name = 'Montgomery' where person_name_id % 12 = 0;
update person_name set family_name = 'Forest' where person_name_id % 13 = 0;
update person_name set family_name = 'Kastenbaum' where person_name_id % 14 = 0;
update person_name set family_name = 'Gans' where person_name_id % 15 = 0;
update person_name set family_name = 'Jazayeri' where person_name_id % 16 = 0;
update person_name set family_name = 'Dahl' where person_name_id % 17 = 0;
update person_name set family_name = 'Farmer' where person_name_id % 18 = 0;
update person_name set family_name = 'Constan' where person_name_id % 19 = 0;
update person_name set family_name = 'Thomas' where person_name_id % 20 = 0;
update person_name set family_name = 'Marx' where person_name_id % 21 = 0;
update person_name set family_name = 'Zintl' where person_name_id % 22 = 0;
update person_name set family_name = 'Soucy' where person_name_id % 23 = 0;
update person_name set family_name = 'West' where person_name_id % 24 = 0;
update person_name set family_name = 'Cardoza' where person_name_id % 25 = 0;
update person_name set family_name = 'White' where person_name_id % 26 = 0;
update person_name set family_name = 'Mccormick' where person_name_id % 27 = 0;
update person_name set family_name = 'Kim' where person_name_id % 28 = 0;
update person_name set family_name = 'Kidder' where person_name_id % 29 = 0;
update person_name set family_name = 'Yatuta' where person_name_id % 30 = 0;
update person_name set family_name = 'Mbuyu' where person_name_id % 31 = 0;
update person_name set family_name = 'Mukatete' where person_name_id % 32 = 0;
update person_name set family_name = 'Kimihura' where person_name_id % 33 = 0;
update person_name set family_name = 'Kichura' where person_name_id % 34 = 0;
update person_name set family_name = 'Kibungo' where person_name_id % 35 = 0;
update person_name set family_name = 'Rwamagana' where person_name_id % 36 = 0;
update person_name set family_name = 'Ihene' where person_name_id % 37 = 0;
update person_name set family_name = 'Inka' where person_name_id % 38 = 0;
update person_name set family_name = 'Kamikazi' where person_name_id % 39 = 0;
update person_name set family_name = 'Inzira' where person_name_id % 40 = 0;
update person_name set family_name = 'Virunga' where person_name_id % 41 = 0;

--
-- Set all first names of Males to a random bunch of 20 choices
--
update person_name set given_name = 'Paul' where person_name_id % 21 = 0
                                             and exists
        (SELECT *
         FROM person
         WHERE person.person_id = person_name.person_id
           AND person.gender = 'M')

                                             and not person_id in (select user_id from users);

update person_name set given_name = 'Tom' where person_name_id % 21 = 1
                                            and exists
        (SELECT *
         FROM person
         WHERE person.person_id = person_name.person_id
           AND person.gender = 'M')

                                            and not person_id in (select user_id from users);

update person_name set given_name = 'Ted' where person_name_id % 21 = 2
                                            and exists
        (SELECT *
         FROM person
         WHERE person.person_id = person_name.person_id
           AND person.gender = 'M') and not person_id in (select user_id from users);

update person_name set given_name = 'Max' where person_name_id % 21 = 3
                                            and exists
        (SELECT *
         FROM person
         WHERE person.person_id = person_name.person_id
           AND person.gender = 'M') and not person_id in (select user_id from users);

update person_name set given_name = 'Hamish' where person_name_id % 21 = 4
                                               and exists
        (SELECT *
         FROM person
         WHERE person.person_id = person_name.person_id
           AND person.gender = 'M') and not person_id in (select user_id from users);

update person_name set given_name = 'Darius' where person_name_id % 21 = 5
                                               and exists
        (SELECT *
         FROM person
         WHERE person.person_id = person_name.person_id
           AND person.gender = 'M') and not person_id in (select user_id from users);

update person_name set given_name = 'Simon' where person_name_id % 21 = 6
                                              and exists
        (SELECT *
         FROM person
         WHERE person.person_id = person_name.person_id
           AND person.gender = 'M') and not person_id in (select user_id from users);

update person_name set given_name = 'Edward' where person_name_id % 21 = 7
                                               and exists
        (SELECT *
         FROM person
         WHERE person.person_id = person_name.person_id
           AND person.gender = 'M')  and not person_id in (select user_id from users);

update person_name set given_name = 'Charles' where person_name_id % 21 = 8
                                                and exists
        (SELECT *
         FROM person
         WHERE person.person_id = person_name.person_id
           AND person.gender = 'M')  and not person_id in (select user_id from users);

update person_name set given_name = 'Luke' where person_name_id % 21 = 9
                                             and exists
        (SELECT *
         FROM person
         WHERE person.person_id = person_name.person_id
           AND person.gender = 'M')  and not person_id in (select user_id from users);

update person_name set given_name = 'Barack' where person_name_id % 21 = 10
                                               and exists
        (SELECT *
         FROM person
         WHERE person.person_id = person_name.person_id
           AND person.gender = 'M')  and not person_id in (select user_id from users);

update person_name set given_name = 'John' where person_name_id % 21 = 11
                                             and exists
        (SELECT *
         FROM person
         WHERE person.person_id = person_name.person_id
           AND person.gender = 'M')  and not person_id in (select user_id from users);

update person_name set given_name = 'Michael' where person_name_id % 21 = 12
                                                and exists
        (SELECT *
         FROM person
         WHERE person.person_id = person_name.person_id
           AND person.gender = 'M')  and not person_id in (select user_id from users);

update person_name set given_name = 'Christopher' where person_name_id % 21 = 13
                                                    and exists
        (SELECT *
         FROM person
         WHERE person.person_id = person_name.person_id
           AND person.gender = 'M')  and not person_id in (select user_id from users);

update person_name set given_name = 'Zaynt' where person_name_id % 21 = 14
                                              and exists
        (SELECT *
         FROM person
         WHERE person.person_id = person_name.person_id
           AND person.gender = 'M')  and not person_id in (select user_id from users);

update person_name set given_name = 'Sebastian' where person_name_id % 21 = 15
                                                  and exists
        (SELECT *
         FROM person
         WHERE person.person_id = person_name.person_id
           AND person.gender = 'M')  and not person_id in (select user_id from users);

update person_name set given_name = 'Howard' where person_name_id % 21 = 16
                                               and exists
        (SELECT *
         FROM person
         WHERE person.person_id = person_name.person_id
           AND person.gender = 'M')  and not person_id in (select user_id from users);

update person_name set given_name = 'Adam' where person_name_id % 21 = 17
                                             and exists
        (SELECT *
         FROM person
         WHERE person.person_id = person_name.person_id
           AND person.gender = 'M')  and not person_id in (select user_id from users);

update person_name set given_name = 'Joshua' where person_name_id % 21 = 18
                                               and exists        (SELECT *
                                                                  FROM person
                                                                  WHERE person.person_id = person_name.person_id
                                                                    AND person.gender = 'M')  and not person_id in (select user_id from users);

update person_name set given_name = 'Steven' where person_name_id % 21 = 19
                                               and exists
        (SELECT *
         FROM person
         WHERE person.person_id = person_name.person_id
           AND person.gender = 'M')  and not person_id in (select user_id from users);

update person_name set given_name = 'Sam' where person_name_id % 21 = 20
                                            and exists
        (SELECT *
         FROM person
         WHERE person.person_id = person_name.person_id
           AND person.gender = 'M')  and not person_id in (select user_id from users);

--
-- Set all first names of Females to a random bunch of 20 choices
--
update person_name set given_name = 'Mary' where person_name_id % 21 = 0
                                             and exists
        (SELECT *
         FROM person
         WHERE person.person_id = person_name.person_id
           AND person.gender = 'F') and not person_id in (select user_id from users);
update person_name set given_name = 'Ophelia' where person_name_id % 21 = 1
                                                and exists
        (SELECT *
         FROM person
         WHERE person.person_id = person_name.person_id
           AND person.gender = 'F') and not person_id in (select user_id from users);
update person_name set given_name = 'Kathryn' where person_name_id % 21 = 2
                                                and exists
        (SELECT *
         FROM person
         WHERE person.person_id = person_name.person_id
           AND person.gender = 'F') and not person_id in (select user_id from users);
update person_name set given_name = 'Ellen' where person_name_id % 21 = 3
                                              and exists
        (SELECT *
         FROM person
         WHERE person.person_id = person_name.person_id
           AND person.gender = 'F') and not person_id in (select user_id from users);
update person_name set given_name = 'Naomi' where person_name_id % 21 = 4
                                              and exists
        (SELECT *
         FROM person
         WHERE person.person_id = person_name.person_id
           AND person.gender = 'F') and not person_id in (select user_id from users);
update person_name set given_name = 'Claire' where person_name_id % 21 = 5
                                               and exists
        (SELECT *
         FROM person
         WHERE person.person_id = person_name.person_id
           AND person.gender = 'F') and not person_id in (select user_id from users);
update person_name set given_name = 'Lucy' where person_name_id % 21 = 6
                                             and exists
        (SELECT *
         FROM person
         WHERE person.person_id = person_name.person_id
           AND person.gender = 'F') and not person_id in (select user_id from users);
update person_name set given_name = 'Freya' where person_name_id % 21 = 7
                                              and exists
        (SELECT *
         FROM person
         WHERE person.person_id = person_name.person_id
           AND person.gender = 'F') and not person_id in (select user_id from users);
update person_name set given_name = 'Carole' where person_name_id % 21 = 8
                                               and exists
        (SELECT *
         FROM person
         WHERE person.person_id = person_name.person_id
           AND person.gender = 'F') and not person_id in (select user_id from users);
update person_name set given_name = 'Sophia' where person_name_id % 21 = 9
                                               and exists
        (SELECT *
         FROM person
         WHERE person.person_id = person_name.person_id
           AND person.gender = 'F') and not person_id in (select user_id from users);
update person_name set given_name = 'Alice' where person_name_id % 21 = 10
                                              and exists
        (SELECT *
         FROM person
         WHERE person.person_id = person_name.person_id
           AND person.gender = 'F') and not person_id in (select user_id from users);
update person_name set given_name = 'Melissa' where person_name_id % 21 = 11
                                                and exists
        (SELECT *
         FROM person
         WHERE person.person_id = person_name.person_id
           AND person.gender = 'F') and not person_id in (select user_id from users);
update person_name set given_name = 'Vanessa' where person_name_id % 21 = 12
                                                and exists
        (SELECT *
         FROM person
         WHERE person.person_id = person_name.person_id
           AND person.gender = 'F') and not person_id in (select user_id from users);
update person_name set given_name = 'Sally' where person_name_id % 21 = 13
                                              and exists
        (SELECT *
         FROM person
         WHERE person.person_id = person_name.person_id
           AND person.gender = 'F') and not person_id in (select user_id from users);
update person_name set given_name = 'Anne' where person_name_id % 21 = 14
                                             and exists
        (SELECT *
         FROM person
         WHERE person.person_id = person_name.person_id
           AND person.gender = 'F') and not person_id in (select user_id from users);
update person_name set given_name = 'Katie' where person_name_id % 21 = 15
                                              and exists
        (SELECT *
         FROM person
         WHERE person.person_id = person_name.person_id
           AND person.gender = 'F') and not person_id in (select user_id from users);
update person_name set given_name = 'Jennifer' where person_name_id % 21 = 16
                                                 and exists
        (SELECT *
         FROM person
         WHERE person.person_id = person_name.person_id
           AND person.gender = 'F') and not person_id in (select user_id from users);
update person_name set given_name = 'Jill' where person_name_id % 21 = 17
                                             and exists
        (SELECT *
         FROM person
         WHERE person.person_id = person_name.person_id
           AND person.gender = 'F') and not person_id in (select user_id from users);
update person_name set given_name = 'Susan' where person_name_id % 21 = 18
                                              and exists
        (SELECT *
         FROM person
         WHERE person.person_id = person_name.person_id
           AND person.gender = 'F') and not person_id in (select user_id from users);
update person_name set given_name = 'Megan' where person_name_id % 21 = 19
                                              and exists
        (SELECT *
         FROM person
         WHERE person.person_id = person_name.person_id
           AND person.gender = 'F') and not person_id in (select user_id from users);
update person_name set given_name = 'Amanda' where person_name_id % 21 = 20
                                               and exists
        (SELECT *
         FROM person
         WHERE person.person_id = person_name.person_id
           AND person.gender = 'F') and not person_id in (select user_id from users);

update idgen_remote_source set url = 'https://humci.pih-emr.org:8080/mirebalais/module/idgen/exportIdentifiers.form?source=5&comment=MirebalaisDemo' where id = 1;
update idgen_remote_source set user = 'testidgen' where id = 1;
update idgen_remote_source set password = 'Testing123' where id = 1;