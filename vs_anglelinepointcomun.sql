-- FUNCTION: public.vs_anglelinepointcomun(geometry, geometry, geometry)

-- DROP FUNCTION public.vs_anglelinepointcomun(geometry, geometry, geometry);

CREATE OR REPLACE FUNCTION public.vs_anglelinepointcomun(
	punto1 geometry,
	punto2 geometry,
	puntocomun geometry)
    RETURNS double precision
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 0
AS $BODY$

declare
  angle1 float;
  angle2 float;
  resultado float;
  algo float;
begin
  SELECT ST_Azimuth(puntocomun, 
                    punto1)/(2*pi())*360  into angle1;
  SELECT ST_Azimuth(puntocomun, 
                    punto2)/(2*pi())*360  into angle2;   
  resultado:= round(abs(angle1-angle2));           
  if resultado>180 then
     resultado:=360-resultado;
  end if;
  return resultado;
 end;

$BODY$;

ALTER FUNCTION public.vs_anglelinepointcomun(geometry, geometry, geometry)
    OWNER TO postgres;
