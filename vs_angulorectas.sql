-- FUNCTION: public.vs_angulorectas(geometry, geometry, geometry, geometry)

-- DROP FUNCTION public.vs_angulorectas(geometry, geometry, geometry, geometry);

CREATE OR REPLACE FUNCTION public.vs_angulorectas(
	point1r1 geometry,
	point2r1 geometry,
	point1r2 geometry,
	point2r2 geometry)
    RETURNS numeric
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 0
AS $BODY$

declare
  resultado numeric; 
  resultado1 numeric;
  u1 numeric;
  v1 numeric;
  u2 numeric;
  v2 numeric;  
begin
   if point1R2=point2R2 then
     --return 90;
   end if;
   u1:=  st_x(point1R1)-st_x(point2R1);
   u2:=  st_y(point1R1)-st_y(point2R1);

   v1:=  st_x(point1R2)-st_x(point2R2);
   v2:=  st_y(point1R2)-st_y(point2R2);   
   resultado=(u1*v1+u2*v2);
   resultado1:=sqrt(u1*u1+u2*u2)*sqrt(v1*v1+v2*v2);
         
   resultado:=acos(resultado/resultado1)*180/pi();
   return resultado;	      
 end;

$BODY$;

ALTER FUNCTION public.vs_angulorectas(geometry, geometry, geometry, geometry)
    OWNER TO postgres;
