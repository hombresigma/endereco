-- FUNCTION: public.vs_obtenercursortransversal(refcursor, geometry, geometry[], bigint)

-- DROP FUNCTION public.vs_obtenercursortransversal(refcursor, geometry, geometry[], bigint);

CREATE OR REPLACE FUNCTION public.vs_obtenercursortransversal(
	refcursor,
	pponto geometry,
	pstreetways geometry[],
	pstreetosm_id bigint)
    RETURNS refcursor
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 0
AS $BODY$

 
BEGIN
       --RETURN VS_COORDENADASPUNTO(PPONTO);
       OPEN $1 FOR 
       select 
       main.osm_id,
       main.name,
       main.way mainway,
       sec.way secway,
       st_closestpoint(main.way,sec.way) puntocer, 
       st_closestpoint(sec.way,main.way) puntocersec, 
       sT_DISTANCE(MAIN.WAY,SEC.WAY) distancia,
       sT_DISTANCE(ST_TRANSFORM(SEC.WAY,4326),pPonto) as Distancia2,
       sT_DISTANCE(ST_TRANSFORM(SEC.WAY,4326),pPonto) as DistanciaPuntoAEsquinaTrans,       
       ST_CENTROID(MAIN.WAY) centmain,
       ST_CENTROID(SEC.WAY)  centsec,       
       ST_DISTANCE(ST_CENTROID(MAIN.WAY),ST_CENTROID(SEC.WAY)) AJA,
       ST_DISTANCE(st_closestpoint(main.way,sec.way),sec.way) aja3,
       SEC.NAME,
       SEC.osm_id as lineid,
       sec.name,
       vs_anglelinepointcomun( ST_CENTROID(MAIN.WAY),
	                       ST_CENTROID(sec.WAY),
	                       st_closestpoint(main.way,sec.way)
	                      ) angpuncom,
       vs_angulorectas( 
                        st_closestpoint(main.way,sec.way),vs_obtenerotropuntolinea(st_closestpoint(main.way,sec.way),main.way),      
                        st_closestpoint(sec.way,main.way),vs_obtenerotropuntolinea(st_closestpoint(sec.way,main.way),sec.way)
                       ) angulorectas	
       from planet_osm_LINE main, PLANET_OSM_LINE SEC  
	where main.OSM_id = pStreetosm_id
       and sT_DISTANCE(MAIN.WAY,SEC.WAY)<=15 --Una transversal no puede estar a más de 15 metros
	   AND MAIN.OSM_ID<>SEC.OSM_ID
	   AND   ST_DWithin( MAIN.WAY,SEC.WAY,
	                    170
	                   )
	  and sec.highway  in ('primary', 'primary_link','secondary', 'secondary_link','tertiary', 'tertiary_link','residential','service','unclassified')
	  and sec.name<>main.name
	  -- and sec.name not like '%Glorieta%'
	  and (sec.junction is null or sec.junction='roundabout')
	  --  and sec.route is null
      order by DistanciaPuntoAEsquinaTrans asc;
	  --order by sT_DISTANCE(MAIN.WAY,SEC.WAY) asc;
	RETURN $1;
END;

$BODY$;

ALTER FUNCTION public.vs_obtenercursortransversal(refcursor, geometry, geometry[], bigint)
    OWNER TO postgres;
