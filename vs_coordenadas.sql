-- FUNCTION: public.vs_coordenadas(geometry)

-- DROP FUNCTION public.vs_coordenadas(geometry);

CREATE OR REPLACE FUNCTION public.vs_coordenadas(
	punto geometry)
    RETURNS character
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
  ret varchar;
begin
  select 
       st_y(st_transform(punto,4326))||','||st_x(st_transform(punto,4326))
    into ret;
  return ret;
end;

$BODY$;

ALTER FUNCTION public.vs_coordenadas(geometry)
    OWNER TO postgres;
