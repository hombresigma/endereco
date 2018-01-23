-- FUNCTION: public.vs_obtenerotropunto(geometry, geometry[])

-- DROP FUNCTION public.vs_obtenerotropunto(geometry, geometry[]);

CREATE OR REPLACE FUNCTION public.vs_obtenerotropunto(
	punto geometry,
	way geometry[])
    RETURNS geometry
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 0
AS $BODY$

declare

  xx geometry;


begin
 
 
    for xx in SELECT (dp).geom As wktnode
      FROM (SELECT 2 As edge_id
	, ST_DumpPoints(
	                 way
	                ) AS dp
       ) As foo 
    loop
       if (xx<>punto) 
         then return xx;
       end if;  

              
    
    end loop;
  return punto;
       
end;

$BODY$;

ALTER FUNCTION public.vs_obtenerotropunto(geometry, geometry[])
    OWNER TO postgres;
