-- FUNCTION: public.vs_signsentidooriente(geometry, geometry, geometry, geometry)

-- DROP FUNCTION public.vs_signsentidooriente(geometry, geometry, geometry, geometry);

CREATE OR REPLACE FUNCTION public.vs_signsentidooriente(
	point1linea1 geometry,
	point2linea1 geometry,
	point1linea2 geometry,
	point2linea2 geometry)
    RETURNS integer
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 0
AS $BODY$

declare
  resultado double precision;
  x11 double precision;
  x12 double precision;
  y11 double precision;
  y12 double precision; 
begin
  x11:=st_X(point2linea1)-st_X(point1linea1);
  y11:=st_Y(point2linea1)-st_Y(point1linea1);  
  x12:=st_X(point2linea2)-st_X(point1linea2);
  y12:=st_Y(point2linea2)-st_Y(point1linea2);    

  --Producto cruz
  resultado:=x11*y12-Y11*x12;
  if resultado>0 then
    return 1;   --Occidente
  end if;
  return -1; --Oriente    	      
 end;

$BODY$;

ALTER FUNCTION public.vs_signsentidooriente(geometry, geometry, geometry, geometry)
    OWNER TO postgres;
