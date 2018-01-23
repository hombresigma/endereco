-- FUNCTION: public.vs_coordenaday(geometry)

-- DROP FUNCTION public.vs_coordenaday(geometry);

CREATE OR REPLACE FUNCTION public.vs_coordenaday(
	punto geometry)
    RETURNS numeric
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 0
AS $BODY$

declare

 
  	  
--##########################################
--### VARIAVEIS
--##########################################

  
--##########################################
--### VARIAVEIS
--########################################## 
  ret numeric;
begin
  select 
       st_y(st_transform(punto,4326))
    into ret;
  return ret;
end;

$BODY$;

ALTER FUNCTION public.vs_coordenaday(geometry)
    OWNER TO postgres;
