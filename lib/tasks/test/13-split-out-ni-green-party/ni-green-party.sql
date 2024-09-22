DELETE
FROM political_party_registrations
WHERE electoral_commission_id = 'PP305';

UPDATE political_parties SET name = 'Northern Ireland Green Party', mnis_id=1113 where id =267;