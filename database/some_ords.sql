
COLUMN name FORMAT A20

SELECT id, name, client_id, client_secret
FROM   user_ords_clients;


SELECT privilege_id, name, pattern
FROM   user_ords_privilege_mappings;

update discovergy_rest set clientname='TESTTEST' where id=50472;
commit;


-- Display the role.
COLUMN name FORMAT A20

SELECT id, name
FROM   user_ords_roles;


-- Display the privilege information.
COLUMN name FORMAT A20

SELECT id, name
FROM   user_ords_privileges;


SELECT client_name, role_name
FROM   user_ords_client_roles;

-- Display client details.

SELECT name, client_name
FROM   user_ords_client_privileges;


--revoke 
BEGIN
  OAUTH.revoke_client_role(
    p_client_name => 'powermonitor_client',
    p_role_name   => 'powermonitor_role'
  );

  COMMIT;
END;
/

BEGIN
  OAUTH.delete_client(
    p_name => 'powermonitor_client'
  );

  COMMIT;
END;
/
curl -i -k --user qy-Hl2w-dZB7bcrAltc5cQ..:a0LeMyE72CVc3VhZt3aRCg.. --data "grant_type=client_credentials"  https://h4de06bp7uxfolh-db202110152122.adb.eu-frankfurt-1.oraclecloudapps.com/ords/pm/oauth/token


