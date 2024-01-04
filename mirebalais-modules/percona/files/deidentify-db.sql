DELIMITER #

DROP FUNCTION IF EXISTS luhn_check_digit
#
CREATE FUNCTION luhn_check_digit(_undecoratedIdentifier varchar(20), _baseChars varchar(50)) returns CHAR DETERMINISTIC
BEGIN
    declare _factor, _sum, _mod, _i, _j, _codePoint, _addend, _remainder, _checkCodePoint int;
    declare _inputChars varchar(20);
    set _factor = 2;
    set _sum = 0;
    set _mod = length(_baseChars);
    set _inputChars = upper(trim(_undecoratedIdentifier));
    set _i = length(_inputChars) - 1;
    while _i >= 0 do
            set _codePoint = -1;
            set _j = 0;
            while _j < _mod do
                    if substring(_baseChars, _j+1, 1) = substring(_inputChars, _i+1, 1) then
                        set _codePoint = _j;
                    end if;
                    set _j = _j + 1;
                end while;
            set _addend = _factor * _codepoint;
            set _factor = if(_factor = 2, 1, 2);
            set _addend = floor(_addend / _mod) + (_addend % _mod);
            set _sum = _sum + _addend;
            set _i = _i - 1;
        end while;
    set _remainder = _sum % _mod;
    set _checkCodePoint = _mod - _remainder;
    set _checkCodePoint = _checkCodePoint % _mod;
    return substring(_baseChars, _checkCodePoint+1, 1);
END
#

DELIMITER ;

-- De-identify all free text observation values except those used to point to OpenMRS metadata (eg. location)
update obs set value_text = 'Deidentified' where value_text is not null and comments not like 'org.openmrs.%';

-- Patient identifiers

set @identifierPrefix = trim(upper(left(global_property_value('pihcore.site',''), 3)));
set @identifierPrefix = replace(@identifierPrefix, 'B', '8');
set @identifierPrefix = replace(@identifierPrefix, 'I', '1');
set @identifierPrefix = replace(@identifierPrefix, 'O', '0');
set @identifierPrefix = replace(@identifierPrefix, 'Q', '4');
set @identifierPrefix = replace(@identifierPrefix, 'S', '5');
set @identifierPrefix = replace(@identifierPrefix, 'Z', '2');

update patient_identifier set identifier = concat(@identifierPrefix, patient_identifier_id);
update patient_identifier pi
    inner join patient_identifier_type pit on pi.identifier_type = pit.patient_identifier_type_id
set
    pi.identifier = concat(pi.identifier, luhn_check_digit(pi.identifier, '0123456789ACDEFGHJKLMNPRTUVWXY'))
where
    pit.validator = 'org.openmrs.module.idgen.validator.LuhnMod30IdentifierValidator';

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
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Steven' where p.gender = 'M';
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

update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Amanda' where p.gender != 'M';
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Mary' where p.gender != 'M' and p.person_id % 2 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Ophelia' where p.gender != 'M' and p.person_id % 3 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Kathryn' where p.gender != 'M' and p.person_id % 4 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Ellen' where p.gender != 'M' and p.person_id % 5 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Naomi' where p.gender != 'M' and p.person_id % 6 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Claire' where p.gender != 'M' and p.person_id % 7 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Lucy' where p.gender != 'M' and p.person_id % 8 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Carole' where p.gender != 'M' and p.person_id % 9 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Sophia' where p.gender != 'M' and p.person_id % 10 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Alice' where p.gender != 'M' and p.person_id % 11 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Melissa' where p.gender != 'M' and p.person_id % 12 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Vanessa' where p.gender != 'M' and p.person_id % 13 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Sally' where p.gender != 'M' and p.person_id % 14 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Anne' where p.gender != 'M' and p.person_id % 15 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Katie' where p.gender != 'M' and p.person_id % 16 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Jennifer' where p.gender != 'M' and p.person_id % 17 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Jill' where p.gender != 'M' and p.person_id % 18 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Susan' where p.gender != 'M' and p.person_id % 19 = 0;
update person_name pn inner join person p on pn.person_id = p.person_id set pn.given_name = 'Megan' where p.gender != 'M' and p.person_id % 20 = 0;

update idgen_remote_source set url = 'https://humci.pih-emr.org:8080/mirebalais/module/idgen/exportIdentifiers.form?source=5&comment=MirebalaisDemo' where id = 1;
update idgen_remote_source set user = 'testidgen' where id = 1;
update idgen_remote_source set password = 'Testing123' where id = 1;