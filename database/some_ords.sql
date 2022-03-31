
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
    p_client_name => 'powermonitor_dev_client',
    p_role_name   => 'powermonitor_dev_role'
  );

  COMMIT;
END;
/

BEGIN
  OAUTH.delete_client(
    p_name => 'powermonitor_dev_client'
  );

  COMMIT;
END;
/
