DECLARE
  l_roles     OWA.VC_ARR;
  l_modules   OWA.VC_ARR;
  l_patterns  OWA.VC_ARR;
  l_prefix varchar2(5);
  l_username varchar2(32);
BEGIN

  select user, regexp_substr(user,'_.{3}$') into l_username,l_prefix from dual;
  
  ORDS.ENABLE_SCHEMA(
      p_enabled             => TRUE,
      p_schema              => l_username,
      p_url_mapping_type    => 'BASE_PATH',
      p_url_mapping_pattern => 'pm' || lower('_dev'),
      p_auto_rest_auth      => FALSE);    

  ORDS.DEFINE_MODULE(
      p_module_name    => 'rest-v1',
      p_base_path      => '/rest-v1/',
      p_items_per_page =>  0,
      p_status         => 'PUBLISHED',
      p_comments       => NULL);      
  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'rest-v1',
      p_pattern        => 'discovergy/',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);
  ORDS.DEFINE_HANDLER(
      p_module_name    => 'rest-v1',
      p_pattern        => 'discovergy/',
      p_method         => 'GET',
      p_source_type    => 'json/collection',
      p_items_per_page =>  0,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'SELECT * FROM discovergy_rest'
      );
  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'rest-v1',
      p_pattern        => 'discovergy/:id',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);
  ORDS.DEFINE_HANDLER(
      p_module_name    => 'rest-v1',
      p_pattern        => 'discovergy/:id',
      p_method         => 'GET',
      p_source_type    => 'json/collection',
      p_items_per_page =>  0,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'SELECT * FROM discovergy_rest WHERE id = :id'
      );

  ORDS.DEFINE_HANDLER(
      p_module_name    => 'rest-v1',
      p_pattern        => 'discovergy/',
      p_method         => 'POST',
      p_source_type    => 'plsql/block',
      p_items_per_page =>  0,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'BEGIN

INSERT INTO discovergy_rest (
    id,
    measure_time,
    energy,
    energyout,
    power,
    clientname
  ) VALUES (
    null,
    to_date(:measure_time,''YYYY-MM-DD"T"HH24:MI:SS''),
    :energy,
    :energyout,
    :power,
    :clientname
  );                       
    :status := 202;
exception when others then
    :status := 400;
    :ermesg := sqlerrm;
END;'
      );
  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'rest-v1',
      p_pattern            => 'discovergy/',
      p_method             => 'POST',
      p_name               => 'ERROR_MESSAGE',
      p_bind_variable_name => 'ermesg',
      p_source_type        => 'HEADER',
      p_param_type         => 'STRING',
      p_access_method      => 'OUT',
      p_comments           => NULL);      
  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'rest-v1',
      p_pattern            => 'discovergy/',
      p_method             => 'POST',
      p_name               => 'X-APEX-STATUS-CODE',
      p_bind_variable_name => 'status',
      p_source_type        => 'HEADER',
      p_param_type         => 'STRING',
      p_access_method      => 'OUT',
      p_comments           => NULL);    

  ORDS.CREATE_ROLE(p_role_name  => lower(l_username) ||'_role');

  l_roles(1)   := lower(l_username) ||'_role';
  l_modules(1) := 'rest-v1';
  l_patterns(1):= '/discovergy/';
  l_patterns(2):= '/discovergy/*';

  ORDS.DEFINE_PRIVILEGE(
      p_privilege_name => lower(l_username) || '_priv',
      p_roles          => l_roles,
      p_patterns       => l_patterns,
      p_modules        => l_modules,
      p_label          => 'Discovergy Data',
      p_description    => 'Allow access to the Discovergy data.',
      p_comments       => NULL);      


  OAUTH.create_client(
    p_name            => lower(l_username) || '_client',
    p_grant_type      => 'client_credentials',
    p_owner           => 'My Company Limited',
    p_description     => 'A client for Powermonitor management',
    p_support_email   => 'christian@familie-blank.de',
    p_privilege_names => lower(l_username) ||'_priv'
  );

  
  OAUTH.grant_client_role(
    p_client_name => lower(l_username) ||'_client',
    p_role_name   => lower(l_username) ||'_role'
  );

  COMMIT;
END;
/
