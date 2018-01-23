-- FUNCTION: public.vs_obtenerotropuntolinea(geometry, geometry)

-- DROP FUNCTION public.vs_obtenerotropuntolinea(geometry, geometry);

CREATE OR REPLACE FUNCTION public.vs_obtenerotropuntolinea(
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
  resultado geometry;
  x1 double precision;
  y1 double precision;
  x2 double precision;
  y2 double precision;
  distancia double precision;
  distancia1 double precision;
begin
    distancia1:=0;
    resultado:=punto;  
    for xx in SELECT (dp).geom As wktnode
      FROM (SELECT 2 As edge_id
	, ST_DumpPoints(
	                 way
	                ) AS dp
       ) As foo 
    loop
       if (xx=punto) 
         then continue;
       end if;  
       distancia:=st_distance(st_transform(xx,4326),st_transform(punto,4326));
       if distancia>distancia1 then
         distancia1:=distancia;
         resultado:=xx;
       end if;            
    
    end loop;
  return resultado;
       
end;

$BODY$;

ALTER FUNCTION public.vs_obtenerotropuntolinea(geometry, geometry)
    OWNER TO postgres;
