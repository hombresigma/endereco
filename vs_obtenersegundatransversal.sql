-- FUNCTION: public.vs_obtenersegundatransversal(geometry, geometry, planet_osm_line, geometry[], planet_osm_line, geometry, integer, integer)

-- DROP FUNCTION public.vs_obtenersegundatransversal(geometry, geometry, planet_osm_line, geometry[], planet_osm_line, geometry, integer, integer);

CREATE OR REPLACE FUNCTION public.vs_obtenersegundatransversal(
	pponto geometry,
	pontoosm geometry,
	pstreet planet_osm_line,
	pstreetways geometry[],
	pstreetpart planet_osm_line,
	ppontotransvref geometry,
	ppendientereferencia integer,
	porientereferencia integer,
	OUT st_segundatransversal character varying,
	OUT osmidsegundatransversal bigint,
	OUT distanciaesquina numeric)
    RETURNS record
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 0
AS $BODY$

 
DECLARE
  ct refCursor;
  i integer;
  Transv record;
  distransversal double precision;
  dist0 double precision;
  dist1 double precision;
  otro varchar;
  msg varchar;
  TransversalAngleToWay float;
  TransversalOffSet float;  
  Transversal1Angle float;
  Transversal planet_osm_line;
  Transversal2 planet_osm_line;
  ajap varchar;
  res varchar;
  pendiente integer;
  PAux1 geometry;
  PAux2 geometry;  
  Transversal1Direction varchar;
  osmidtrans1 bigint;
  nametrans varchar; 
  algo record;
  pendiente1 integer;

  distanciaEsqui2 float;
  osmidtrans2 bigint;
  nametrans2 varchar;   
  oriente integer;
  ajah varchar;
  umbralangulo double precision;
  umbraltransversal double precision;
  distanciaviaatransversal double precision;
BEGIN
  ajah:='';
  ajap:='';
  --##########################################
  --### BUSCA  TRANSVERSAIS SEGUNDA
  --##########################################
  i:=0;
  dist0:=1000;
  ct:=vs_obtenercursorTransversal(ct,pponto, pstreetways,pstreet.osm_id); 
  select valor into umbralangulo from vs_parametrosgis where vs_parametrosgis.codigo=1;
  select valor into umbraltransversal from vs_parametrosgis where vs_parametrosgis.codigo=3;    

  LOOP
         
    FETCH FROM ct INTO Transv;
    EXIT WHEN NOT FOUND;

		
    --distancia a la via principal de la transversal
    dist1:=distanciaviaatransversal;
    distanciaviaatransversal:=Transv.distancia;

    --Carrega os dados na variavel da transversal
	select * into Transversal from planet_osm_line 	where osm_id = Transv.LineId;		
 	msg := 'Transversal (osm_id-name-way):'||Transversal.osm_id||'-'||Transversal.name||'-> '|| 'ST_GeomFromText('''||ST_AsText(Transversal.way)||''',900913)';
	raise notice '%',msg;
 
	--Descarta según la distancia A LA VIA PRINCIPAL LA OTRA TRANVERSAL NO RECOMENDABLE

    if dist1>umbraltransversal 
    then               
      continue;
    end if;
                        
    TransversalAngleToWay := Transv.angulorectas;

    msg := '..........(cont.): Angle to way='||TransversalAngleToWay;
	raise notice '%',msg;
			
	-- O angulo entre elas dever ser maior que 15 nao estar entre 165 e 195 e ser menor que 345, para evitar pegar acessor secundarios que sao paralelos a rua
	if (TransversalAngleToWay > umbralangulo) and (not TransversalAngleToWay between (180-umbralangulo) and (180+umbralangulo)) 
	  and (TransversalAngleToWay < (360-umbralangulo)) 
      --and 
      --                     not (
      --                            (TransversalAngleToWay between 139 and 235) and (Transv.aja > 180) 
      --                         )
			then
                    IF POSITION('ntrada' in transversal.name)>0 then
					AJAH:=AJAH||TRANSVERSAL.NAME||':'||TransversalAngleToWay;
					end if;			
                                        -- distancia entre transversales primera comparada con la segunda buscada DEBE SER GRANDE OJO
                                        select sT_DISTANCE(MAIN.WAY,SEC.WAY) into distransversal from planet_osm_LINE main, PLANET_OSM_LINE SEC  
	                                   where main.OSM_id = osmidtrans1
	                                     and sec.OSM_ID = transversal.osm_id;

                                        if distransversal<10 then
                                          --aja:=aja||'conf  ';

                                          --ajap:=ajap||transv.name||':dist<10';	
					                      --continue;
                                        end if;  
                                        pendiente1:= vs_signSentido(transv.puntocer,pPontoTransvRef,pontoOSM);
                                        
                                        --Descarta si ya encontró un punto previo más cercano en la misma dirección que el actual
	                                if pendiente1=ppendientereferencia then
                                           continue;
	                                end if;
	                                oriente:= vs_signSentidoOriente(pontoOSM,transv.puntocer,transv.puntocersec,transv.centsec); 	 
	                                if oriente=porientereferencia then
                                          --ajap:=ajap||transv.name||':orienteigual';	  
                                          --continue;
	                                end if;                               
                 if Transversal2 is null then

                                        --aja:=aja||'tranull';
					--##########################################
					--### 2a TRANSVERSAL
					--##########################################

					--Carrega os dados da rua na variavel da 2a Transversal
					Transversal2 := Transversal;
					msg := '***Transversal2:'||Transversal2.osm_id||'-'||Transversal2.name||'-> '|| 'ST_GeomFromText('''||ST_AsText(Transversal2.way)||''',900913)';
					raise notice '%',msg;

					--if (Transversal2Direction <> Transversal1Direction) and (Transversal2.Name <> Transversal1.Name) then
					--  exit;
					--end if;
                    if distanciaviaatransversal<30 then                    
					  dist0 := dist1;
                    end if;  
					osmidtrans2:=transversal2.osm_id;
					nametrans2:=transversal2.name;
                    distanciaEsqui2 := transv.distancia2;									
				  else
                     select sT_DISTANCE(MAIN.WAY,SEC.WAY) into distransversal from planet_osm_LINE main, PLANET_OSM_LINE SEC  
	                                   where main.OSM_id = osmidtrans2
	                                     and sec.OSM_ID = transversal.osm_id;

                                        --if distransversal<30 and dist1<dist0 then
            		  if distanciaviaatransversal<30 and dist1<dist0 then       
                                           dist0:=dist1;

                                       
					--##########################################
					--### 2a TRANSVERSAL
					--##########################################

					--Carrega os dados da rua na variavel da 2a Transversal
					Transversal2 := Transversal;
				    osmidtrans2:=transversal2.osm_id;					     
	                nametrans2:=transversal2.name;
                    distanciaEsqui2 := transv.distancia2;                                    
	                                
					
					msg := '***Transversal2:'||Transversal2.osm_id||'-'||Transversal2.name||'-> '|| 'ST_GeomFromText('''||ST_AsText(Transversal2.way)||''',900913)';
					raise notice '%',msg;

				  end if;  	  
				end if;		
			end if;			
  end loop;
  CLOSE ct;
  osmidsegundatransversal:=osmidtrans2;
  st_segundaTransversal:=nametrans2;   
  distanciaEsquina:=distanciaEsqui2;
END;

$BODY$;

ALTER FUNCTION public.vs_obtenersegundatransversal(geometry, geometry, planet_osm_line, geometry[], planet_osm_line, geometry, integer, integer)
    OWNER TO postgres;
