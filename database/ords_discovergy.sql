DECLARE
  l_roles     OWA.VC_ARR;
  l_modules   OWA.VC_ARR;
  l_patterns  OWA.VC_ARR;
  
BEGIN
  --+++++++++++++++++++++++++++++ Discovergy ++++++++++++++++++++++++++++++++++++++++++++
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
    power
  ) VALUES (
    null,
    to_date(:measure_time,''YYYY-MM-DD"T"HH24:MI:SS''),
    :energy,
    :energyout,
    :power
  );                       
    :status := 201;
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

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



  l_roles(1)   := 'discovergy_role';
  l_roles(2)   := 'inverter_role';
  l_modules(1) := 'rest-v1';
  l_patterns(1):= '/inverter/*';
  l_patterns(1):= '/discovergy/*';

  ORDS.DEFINE_PRIVILEGE(
      p_privilege_name => 'inverter_priv',
      p_roles          => l_roles,
      p_patterns       => l_patterns,
      p_modules        => l_modules,
      p_label          => 'Inverter_Rest Data',
      p_description    => 'Allow access to the Inverter_Rest data.',
      p_comments       => NULL);      


  COMMIT; 

END;
/