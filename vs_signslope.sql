-- FUNCTION: public.vs_signslope(geometry, geometry)

-- DROP FUNCTION public.vs_signslope(geometry, geometry);

CREATE OR REPLACE FUNCTION public.vs_signslope(
	point1 geometry,
	point2 geometry)
    RETURNS double precision
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 0
AS $BODY$

declare
  resultado double precision; 
begin

	raise debug '################ INICIO vs_signSlope';

	resultado:= sign
	       (
	        (
	         round(st_Y(point1)*10000)-round(st_Y(point2)*10000)
	        )
	        *
	       (
	        round(st_X(point1)*10000)-round(st_X(point2)*10000)
	       )
	      )
	      ;
	if resultado=0 then
	  resultado:=1;
	end if;  
   return resultado;	      
 end;

$BODY$;

ALTER FUNCTION public.vs_signslope(geometry, geometry)
    OWNER TO postgres;
