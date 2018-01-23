-- FUNCTION: public.vs_obtenertransversal(geometry, geometry, planet_osm_line, geometry[])

-- DROP FUNCTION public.vs_obtenertransversal(geometry, geometry, planet_osm_line, geometry[]);

CREATE OR REPLACE FUNCTION public.vs_obtenertransversal(
	pponto geometry,
	pontoosm geometry,
	pstreet planet_osm_line,
	pstreetways geometry[],
	OUT pontonorteref geometry,
	OUT pontoorienteref geometry,
	OUT st_primeratransversal character varying,
	OUT pnortereferencia integer,
	OUT porientereferencia integer,
	OUT osmidprimeratransversal bigint,
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
  dist0 numeric;
  dist1 numeric;
  otro varchar;
  msg varchar;
  TransversalAngleToWay numeric;
  Transversal1Angle numeric;
  Transversal planet_osm_line;
  Transversal1 planet_osm_line;
  ajac varchar;
  res varchar;
  norte integer;
  Transversal1Direction varchar;
  osmidtrans1 bigint;
  nametrans1 varchar; 
  distanciaEsqui1 numeric;
  algo record;
  ijk varchar;
  oriente integer;
  umbralangulo double precision;
  umbralesquina double precision;
  umbraltransversal double precision;
BEGIN
  ajac:='';
  select valor into umbralangulo from vs_parametrosgis where vs_parametrosgis.codigo=1;
  select valor into umbralesquina from vs_parametrosgis where vs_parametrosgis.codigo=2; 
  umbralesquina:=umbralesquina/111800;
  select valor into umbraltransversal from vs_parametrosgis where vs_parametrosgis.codigo=3;

  --##########################################
  --### BUSCA  TRANSVERSAIS PRIMERA
  --##########################################
  i:=0;

  ct:=vs_obtenercursorTransversal(ct,pponto,pstreetways,pstreet.osm_id); 
  --st_primeratransversal:='ggggggggg';exit;
  LOOP
    FETCH FROM ct INTO Transv;
    EXIT WHEN NOT FOUND;	
  
    dist1:=Transv.distancia2;
       
    --Carrega os dados na variavel da transversal
    select * into Transversal 		from planet_osm_line
			where osm_id = Transv.LineId;
    ajac:=ajac||transversal.name||transversal.osm_id||'zz';
    msg := 'Transversal (osm_id-name-way):'||Transversal.osm_id||'-'||Transversal.name||'-> '|| 'ST_GeomFromText('''||ST_AsText(Transversal.way)||''',900913)';
    raise notice '%',msg;

 	   
    TransversalAngleToWay:=Transv.angulorectas;
			                    
    res:= res||'<Tr:'|| Transversal.name||' ang:'|| TransversalAngleToWay||'>';   
			
    if (TransversalAngleToWay > umbralangulo) and (not TransversalAngleToWay between (180-umbralangulo) and (180+umbralangulo))
	 and (TransversalAngleToWay < (360-umbralangulo)) 
    then
	  --Caso a 1a Trasnversal não tenha sido selecionada, pega o primeiro registro
      if Transversal1 is null then
        --##########################################
	    --### BUSCA PRIMERA TRANSVERSAL 
	    --##########################################
        --Descarta transversal que no esté lo suficientemente cerca de la via principal
        if transv.distancia>umbraltransversal then   
          continue;
        end if;
        Transversal1 := Transversal;
        dist0 := dist1;
        osmidtrans1:=transversal1.osm_id;
        nametrans1:=transversal1.name;
        distanciaEsqui1 :=transv.distancia2;
	    if transv.distancia2<umbralesquina then
          nametrans1:=nametrans1||'(esquina)';
        end if;
        pontonorteref:=transv.puntocer;
	    norte:= vs_signSentido(transv.puntocer,pontonorteref,pontoOSM);
	    pnorteReferencia:=norte;
	    porientereferencia:=vs_signSentidoOriente(pontoOSM,transv.puntocer,transv.puntocersec,transv.centsec); 

      else
  	    --Caso ja tenha selecionado a 1a, entao processa as demais para a segunda
        --##########################################
        --### BUSCA OTRA POSIBLE PRIMERA TRANSVERSAL 
        --##########################################

        if transv.distancia>umbraltransversal then                                         
          continue;
        end if;                              

        --Si la primera transversal ya se encontró pero hay otra posible muy cercana se tiene en cuenta y puede ser la de interés(al otro lado via posiblemente)
        if  dist1<dist0 then
          dist0:=dist1;
	      osmidtrans1:=transversal1.osm_id;
	      nametrans1:=transversal1.name;  
          distanciaEsqui1 :=transv.distancia2;      
	      if transv.distancia2<umbralesquina then
            nametrans1:=nametrans1||'(esquina)';
	      end if;					                                        

	      --##########################################
	      --### 1a TRANSVERSAL 1
	      --##########################################

	      --Carrega os dados da rua na variavel da 1a transversal
	      Transversal1 := Transversal;
	      msg := '***Transversal1:'||Transversal1.osm_id||'-'||Transversal1.name||'-> '|| 'ST_GeomFromText('''||ST_AsText(Transversal1.way)||''',900913)';
	      raise notice '%',msg;
	      dist0 := dist1;
	      --Reemplaza el punto de referencia y su norte en caso que reemplace la transversal inicial escogida
	      pontonorteref:=transv.puntocer;
	      norte:= vs_signSentido(transv.puntocer,pontonorteref,pontoOSM);
	      pnorteReferencia:=norte;					  
	      porientereferencia:=vs_signSentidoOriente(pontoOSM,transv.puntocer,transv.puntocersec,transv.centsec); 
				  
	      continue;
        end if;
      end if;				  
    end if;	
  END LOOP;
  CLOSE ct;  
  osmidprimeratransversal:=osmidtrans1;
  st_primeratransversal:=nametrans1;
  distanciaEsquina :=distanciaEsqui1; 
  raise notice '%',msg;               
END;

$BODY$;

ALTER FUNCTION public.vs_obtenertransversal(geometry, geometry, planet_osm_line, geometry[])
    OWNER TO postgres;
