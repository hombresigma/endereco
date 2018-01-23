-- FUNCTION: public.vs_signsentido(geometry, geometry, geometry)

-- DROP FUNCTION public.vs_signsentido(geometry, geometry, geometry);

CREATE OR REPLACE FUNCTION public.vs_signsentido(
	point1 geometry,
	point2 geometry,
	pointref geometry)
    RETURNS double precision
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 0
AS $BODY$

declare
  resultado integer; 
begin

	raise debug '################ INICIO vs_signSlope';
        if vs_anglelinepointcomun(point1,point2,pointref)>90 then
          resultado:=1;
        else   
	  resultado:= -1;
	end if;  
   return resultado;	      
 end;

$BODY$;

ALTER FUNCTION public.vs_signsentido(geometry, geometry, geometry)
    OWNER TO postgres;
