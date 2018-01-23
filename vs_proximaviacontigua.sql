-- FUNCTION: public.vs_proximaviacontigua(geometry, geometry, geometry, bigint, integer)

-- DROP FUNCTION public.vs_proximaviacontigua(geometry, geometry, geometry, bigint, integer);

CREATE OR REPLACE FUNCTION public.vs_proximaviacontigua(
	pponto geometry,
	ppontoosm geometry,
	pontotransvref geometry,
	posmidmain bigint,
	pendientereferencia integer)
    RETURNS bigint
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 0
AS $BODY$

declare
--Lista de continuaciones
  curParalelas cursor (pPonto geometry, posmid integer) for
    select 
       main.osm_id,
       main.name,
       sec.name,
       SEC.osm_id as lineid,       
       st_closestpoint(main.way,sec.way) puntocer, 
       st_closestpoint(sec.way,main.way) puntocersec, 
       sT_DISTANCE(MAIN.WAY,SEC.WAY) DISTANCIAX,
       sT_DISTANCE(ST_TRANSFORM(SEC.WAY,4326),
       pPonto
       ,true) as DISTANCIAY,
       st_length(sec.way) distanciaz,
       ST_CENTROID(MAIN.WAY) centmain,
       ST_CENTROID(SEC.WAY)  centsec,       
       ST_DISTANCE(ST_CENTROID(MAIN.WAY),ST_CENTROID(SEC.WAY)) AJA,
       ST_DISTANCE(st_closestpoint(main.way,sec.way),sec.way) aja3,
       st_distance(st_closestpoint(main.way,sec.way),st_closestpoint(sec.way,main.way)) aja4,
       SEC.NAME,
       vs_anglelinepointcomun( ST_CENTROID(MAIN.WAY),
	                       ST_CENTROID(sec.WAY),
	                       st_closestpoint(main.way,sec.way)
	                      ) angpuncom,
       vs_angulorectas( st_closestpoint(main.way,sec.way),ST_CENTROID(MAIN.WAY),      
       st_closestpoint(sec.way,main.way),ST_CENTROID(sec.WAY)) angulorectas
	                      
       from planet_osm_LINE main, PLANET_OSM_LINE SEC  
	where
	   main.OSM_id = posmid
	   and sec.highway in ('primary', 'primary_link','secondary', 'secondary_link','tertiary', 'tertiary_link','residential','service','unclassified')
	   AND MAIN.OSM_ID<>SEC.OSM_ID
	   AND   ST_DWithin( MAIN.WAY,SEC.WAY,
	                    2900
	                   )
--	  and ((sec.name=main.name               -- El mismo nombre de la vía, pues el tramo pertenece a la misma via.  
--	  and sec.junction is null) or (sec.junction='roundabout' and sec.name<>main.name))	  	  
	  and sT_DISTANCE(MAIN.WAY,SEC.WAY)=0  --Distancia es cero pues una es continuación de la otra

	  and (

	         vs_angulorectas( st_closestpoint(main.way,sec.way),ST_CENTROID(MAIN.WAY),      
                                  st_closestpoint(sec.way,main.way),ST_CENTROID(sec.WAY)) between 165 and 195
    
          or vs_angulorectas( st_closestpoint(main.way,sec.way),ST_CENTROID(MAIN.WAY),      
                                  st_closestpoint(sec.way,main.way),ST_CENTROID(sec.WAY)) between 345 and 360  
                                  ) 
          order by Distanciay asc;
          

    pendiente integer;
    resultado integer; 
    alas varchar;
  begin
   resultado:=0;
   for Transvpar in curParalelas(pPonto, posmidmain)   loop

     pendiente:= vs_signSentido(transvpar.puntocer,pontoTransvRef,pPontoOSM);
     if pendiente<>pendienteReferencia then
       resultado:=TransvPar.lineid; 

       exit;
     end if;  

   end loop;

   return resultado;	      
 end;

$BODY$;

ALTER FUNCTION public.vs_proximaviacontigua(geometry, geometry, geometry, bigint, integer)
    OWNER TO postgres;
