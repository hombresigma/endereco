-- FUNCTION: public.vs_touchway(geometry, geometry[])

-- DROP FUNCTION public.vs_touchway(geometry, geometry[]);

CREATE OR REPLACE FUNCTION public.vs_touchway(
	line geometry,
	way geometry[])
    RETURNS boolean
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 0
AS $BODY$

declare
  wayPart geometry;
begin  
	--raise debug '################ INICIO vs_TouchWay';
	--Line := ST_Transform(Line,4326);
	foreach wayPart in array way
	loop
	        --wayPart := ST_Transform(wayPart,4326);
		--raise debug 'wayPart=%',ST_AsText(wayPart);
		--raise debug 'Line=%',ST_AsText(Line);
		if ST_Touches(line, wayPart) or ST_Intersects(line, wayPart) then --or (line && wayPart) then
			--raise debug '################ FIM vs_TouchWay - TRUE';		
			return True;	
		end if;
	end loop;
	--raise debug '################ FIM vs_TouchWay - FALSE';		
	return False;
end;

$BODY$;

ALTER FUNCTION public.vs_touchway(geometry, geometry[])
    OWNER TO postgres;
