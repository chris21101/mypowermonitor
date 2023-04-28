select * from inverter_rest where measure_time>to_date('14.04.2023 13:00:06', 'DD.MM.YYYY HH24:MI:SS') 
and measure_time<to_date('14.04.2023 14:00:00', 'DD.MM.YYYY HH24:MI:SS')
order by measure_time;

--update inverter_rest set daily_energie=daily_energie+7.22 where measure_time> to_date('14.04.2023 13:03:06', 'DD.MM.YYYY HH24:MI:SS')
--and measure_time< to_date('15.04.2023 00:00:00', 'DD.MM.YYYY HH24:MI:SS');