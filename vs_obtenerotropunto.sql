-- FUNCTION: public.vs_obtenerotropunto(geometry, geometry)

-- DROP FUNCTION public.vs_obtenerotropunto(geometry, geometry);

CREATE OR REPLACE FUNCTION public.vs_obtenerotropunto(
	punto geometry,
	way geometry)
    RETURNS geometry
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 0
AS $BODY$

declare

  xx geometry;
  x1 double precision;
  y1 double precision;
  x2 double precision;
  y2 double precision;
begin
 
 
    for xx in SELECT (dp).geom As wktnode
      FROM (SELECT 2 As edge_id
	, ST_DumpPoints(
	                 way
	                ) AS dp
       ) As foo 
    loop


       x1:=st_x(st_transform(xx,4326));
       y1:=st_y(st_transform(xx,4326));
       x2:=st_x(st_transform(punto,4326));
       y2:=st_y(st_transform(punto,4326));       
       if not ((x1=x2) and (y2=x2)) 
         then return xx;
       end if;  

              
    
    end loop;
  return punto;
       
end;

$BODY$;

ALTER FUNCTION public.vs_obtenerotropunto(geometry, geometry)
    OWNER TO postgres;
