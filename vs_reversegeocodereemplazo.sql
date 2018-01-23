-- FUNCTION: public.vs_reversegeocodereemplazo(double precision, double precision, boolean, character, character)

-- DROP FUNCTION public.vs_reversegeocodereemplazo(double precision, double precision, boolean, character, character);

CREATE OR REPLACE FUNCTION public.vs_reversegeocodereemplazo(
	lat double precision,
	lon double precision,
	recalculo boolean,
	enderecoanterior character,
	direccioncorregida character)
    RETURNS character
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 0
AS $BODY$

declare

  ct refcursor;
--##########################################
--### CURSORES
--##########################################
--Partes que compoe a rua principal
  curStreetParts cursor (street_id bigint, street_name varchar) for
	select line.*
	from planet_osm_line line
	where line.osm_id in (select sec.id
				from planet_osm_ways main,
				     planet_osm_ways sec
				where main.id = street_id
				  and sec.nodes && main.nodes
				  and main.id <> sec.id)
	  and line.name = street_name
	  and Line.highway in ('primary', 'primary_link','secondary', 'secondary_link','tertiary','tertiary_link', 'residential','unclassified')
	  and Line.route is null;

--##########################################
--### VARIAVEIS
--##########################################
  PontoGPS geometry;
  Ponto geometry;
  PontoOSM geometry;
  PontoGPS2 geometry;
  Ponto2 geometry;
  PontoOSM2 geometry;
  PontoGPS3 geometry;
  Ponto3 geometry;
  PontoOSM3 geometry;
  mipontotransvref2 geometry;  
  --Area planet_osm_polygon;
  Dummy float;
  LineID float;
  LineID2 float;
  LineID3 float;
  lineIDTrans1 bigint;
  LineIDTrans2 bigint;  
  StreetPart planet_osm_line;
  StreetParts planet_osm_line[];
  StreetWays geometry[];
  StreetPart2 planet_osm_line;
  StreetParts2 planet_osm_line[];
  StreetWays2 geometry[];
  StreetPart3 planet_osm_line;
  StreetParts3 planet_osm_line[];
  StreetWays3 geometry[];
  nameviarecorrida varchar;
  nada float;
  nada1 float;
  norte integer;
  norte1 integer;
  norteReferencia integer;  
  Transversal2Direction varchar;
  Ret Varchar;
  Msg Varchar;
  PAux1 geometry;
  PAux2 geometry;
  nombre varchar;
  res varchar;
  nc varchar;
  nametrans1 varchar;
  nametrans2 varchar;
  i integer;
  mipontoTransvRef geometry;  
  otroang double precision;
  ajap varchar;
  ppp varchar;
  respuesta1 record;
  sPrefijo varchar;
  orientereferencia integer;
  aux varchar;
  ajaz varchar;
  iCantidad integer;
  iIdPunto integer;
begin
  if (not recalculo) then 
    select direccion,st_distance(
                  st_transform(punto,4326),
                  ST_SetSRID(ST_Point( lon,lat),4326)
                 ) as distance into ret,nada from vs_localizacao
    where 
      st_distance(
                  st_transform(punto,4326),
                  ST_SetSRID(ST_Point( lon,lat),4326)
                 )<0.00019
                 order by distance asc
                 limit 1;
  
    if ret is not null
      then return ret;
    end if;
  end if;  
    
  --end if;

    sPrefijo:=' entre ';
    norteReferencia:=-1;

    --Converte a latitude e a longitude em objetos geometricos
    PontoGPS := ST_SetSRID(ST_Point(lon,lat),4326);
    msg := 'PontoGPS -> '||'ST_GeomFromText('''||ST_AsText(PontoGPS)||''',4326)';
    raise notice '%',msg;

    --Busca a linha mais proxima do ponto,
    select line.name, ST_Distance( ST_Transform(line.way,4326), PontoGPS) as Distance, line.osm_id into ajaz,Dummy, LineID
    from planet_osm_line as line
    where 1 = 1
      and ST_Distance( ST_Transform(line.way,4326), PontoGPS )<0.000150
      and Line.name is not null			  
      and line.highway in ('primary','primary_link', 'secondary', 'secondary_link', 'tertiary','tertiary_link', 'residential','unclassified')
      and Line.route is null
    order by Distance asc
    limit 1;

   if LineId is null then
     Ponto := ST_ClosestPoint(PontoGPS,PontoGPS);   
     delete from vs_localizacao where punto=ponto;
     select vs_nuevaDireccion(lat, lon,direccionCorregida) into ajaz;   
     return 'No está en una vía';
   end if;  

    --Carrega os dados da rua na variavel
    select * into StreetPart
		from planet_osm_line
		where osm_id = LineId;
    
 
  --Calculo o Ponto da linha principal mais proximo do PontoGPS e usa este como o ponto daqui para frente
  Ponto := ST_ClosestPoint(ST_Transform(StreetPart.way,4326),PontoGPS);
  msg := 'Ponto -> '||'ST_GeomFromText('''||ST_AsText(Ponto)||''',4326)';
  raise notice '%',msg;
  --return 'antes pontoosm';
  PontoOSM := ST_Transform(Ponto,900913);
  msg := 'PontoOSM -> '||'ST_GeomFromText('''||ST_AsText(PontoOSM)||''',900913)';
  raise notice '%',msg;	

  --Acrescenta ao array com as partes da rua
  StreetParts := array[StreetPart];
  StreetWays  := array[StreetPart.way];
  msg := 'Street [Main]:'||StreetPart.osm_id||'-'||StreetPart.name||'-> '|| 'ST_GeomFromText('''||ST_AsText(StreetPart.way)||''',900913)';
  raise notice '%',msg;

  --Monta uma lista com outras linhas que são referentes à mesma rua
  for Part in curStreetParts(StreetParts[1].osm_id, StreetParts[1].name) loop
    --Acrescenta ao array com as partes da rua
    StreetPart := Part;
    StreetParts := StreetParts|| StreetPart;
    StreetWays  := StreetWays || StreetPart.way;
    msg := 'Street [Part]:'||StreetPart.osm_id||'-'||StreetPart.name||'-> '|| 'ST_GeomFromText('''||ST_AsText(StreetPart.way)||''',900913)';
    raise notice '%',msg;
  end loop;
  nameviarecorrida:= StreetParts[1].name;
  if (StreetParts[1].junction='roundabout') then
    sprefijo:=' con ';
  end if;	
  select pontoNorteref, st_primeraTransversal,pnortereferencia,porientereferencia,osmidprimeratransversal into mipontotransvref,nametrans1, nortereferencia, orientereferencia,lineidtrans1  
    from vs_obtenerTransversal(ponto,pontoosm, StreetParts[1], StreetWays);  
 if not position('(esquina)' in nametrans1)>0 then
   select st_segundaTransversal,osmidsegundatransversal into nametrans2,lineidtrans2 
     from vs_obtenerSegundaTransversal
                                    (ponto,pontoosm,StreetParts[1],StreetWays,  
                                    StreetPart, mipontotransvref,nortereferencia,orientereferencia);   
 else 
   nametrans2='NO APLICA';                                
 end if;          

  --Si no obtiene aún la segunda transversal
  if nametrans2 is null   then

    LineId2:=public.vs_proximaviacontigua(Ponto, PontoOSM, mipontoTransvRef, StreetParts[1].osm_id, nortereferencia);
    

    --Busca la via recorrida más próxima la punto
    select st_transform(
                        st_closestpoint(
                                        line.way,
                                        ST_CENTROID(line.way)
                                        ),
                         4326
                        ) into pontoGPS2
    from planet_osm_line as line
    where osm_id=lineid2;

    msg := 'PontoGPS2 -> '||'ST_GeomFromText('''||ST_AsText(PontoGPS2)||''',4326)';
    raise notice '%',msg;

    --Carrega os dados da rua na variavel
    select * into StreetPart2
		from planet_osm_line
		where osm_id = LineId2;

    --Calculo o Ponto da linha principal mais proximo do PontoGPS e usa este como o ponto daqui para frente
    Ponto2 := ST_ClosestPoint(ST_Transform(StreetPart2.way,4326),PontoGPS2);	
    msg := 'Ponto -> '||'ST_GeomFromText('''||ST_AsText(Ponto)||''',4326)';
    raise notice '%',msg;

    PontoOSM2 := ST_Transform(Ponto2,900913);
    msg := 'PontoOSM -> '||'ST_GeomFromText('''||ST_AsText(PontoOSM)||''',900913)';
    raise notice '%',msg;	

    --Acrescenta ao array com as partes da rua
    StreetParts2 := array[StreetPart2];
    StreetWays2  := array[StreetPart2.way];	
    msg := 'Street [Main]:'||StreetPart.osm_id||'-'||StreetPart.name||'-> '|| 'ST_GeomFromText('''||ST_AsText(StreetPart.way)||''',900913)';
    raise notice '%',msg;
		

    --Monta uma lista com outras linhas que são referentes à mesma rua
    for Part in curStreetParts(StreetParts2[1].osm_id, StreetParts2[1].name) loop
		--Acrescenta ao array com as partes da rua
			StreetPart2 := Part;
			StreetParts2 := StreetParts2|| StreetPart2;
			StreetWays2  := StreetWays2 || StreetPart2.way;
			msg := 'Street2 [Part]:'||StreetPart2.osm_id||'-'||StreetPart2.name||'-> '|| 'ST_GeomFromText('''||ST_AsText(StreetPart2.way)||''',900913)';
			raise notice '%',msg;
			--ajay:=ajay||StreetPart.osm_id||'-'||StreetPart.name;
    end loop;

    --##########################################
    --### BUSCA TRANSVERSAIS SEGUNDA otra vez
    --##########################################
        select st_segundaTransversal,osmidsegundatransversal into nametrans2,lineidtrans2 
          from vs_obtenerSegundaTransversal
                                    (ponto2,pontoosm2,StreetParts2[1],StreetWays2,  
                                    StreetPart2, mipontotransvref,nortereferencia,orientereferencia);   

  end if;

  if nametrans2 is null   then
    LineId3:=public.vs_proximaviacontigua(Ponto2, PontoOSM2, mipontoTransvRef, StreetParts2[1].osm_id, nortereferencia);

    --Busca la via recorrida más próxima la punto
    select st_transform(
                        st_closestpoint(
                                        line.way,
                                        ST_CENTROID(line.way)
                                        ),
                         4326
                        ) into pontoGPS3
    from planet_osm_line as line
    where osm_id=lineid3;

    msg := 'PontoGPS3 -> '||'ST_GeomFromText('''||ST_AsText(PontoGPS3)||''',4326)';
    raise notice '%',msg;

    --Carrega os dados da rua na variavel
    select * into StreetPart3
		from planet_osm_line
		where osm_id = LineId3;

    --Calculo o Ponto da linha principal mais proximo do PontoGPS e usa este como o ponto daqui para frente
    Ponto3 := ST_ClosestPoint(ST_Transform(StreetPart3.way,4326),PontoGPS3);	
    msg := 'Ponto3 -> '||'ST_GeomFromText('''||ST_AsText(Ponto3)||''',4326)';
    raise notice '%',msg;

    PontoOSM3 := ST_Transform(Ponto3,900913);
    msg := 'PontoOSM3 -> '||'ST_GeomFromText('''||ST_AsText(PontoOSM3)||''',900913)';
    raise notice '%',msg;	

    --Acrescenta ao array com as partes da rua
    StreetParts3 := array[StreetPart3];
    StreetWays3  := array[StreetPart3.way];	
    msg := 'Street [Main]:'||StreetPart3.osm_id||'-'||StreetPart3.name||'-> '|| 'ST_GeomFromText('''||ST_AsText(StreetPart3.way)||''',900913)';
    raise notice '%',msg;
		

    --Monta uma lista com outras linhas que são referentes à mesma rua
    for Part in curStreetParts(StreetParts3[1].osm_id, StreetParts3[1].name) loop
		--Acrescenta ao array com as partes da rua
			StreetPart3 := Part;
			StreetParts3 := StreetParts3|| StreetPart3;
			StreetWays3  := StreetWays3 || StreetPart3.way;
			msg := 'Street3 [Part]:'||StreetPart3.osm_id||'-'||StreetPart3.name||'-> '|| 'ST_GeomFromText('''||ST_AsText(StreetPart3.way)||''',900913)';
			raise notice '%',msg;
			--ajay:=ajay||StreetPart.osm_id||'-'||StreetPart.name;
    end loop;

    --##########################################
    --### BUSCA TRANSVERSAIS SEGUNDA otra vez
    --##########################################
        select st_segundaTransversal into nametrans2 
          from vs_obtenerSegundaTransversal
                                    (ponto3,pontoosm3,StreetParts3[1],StreetWays3,  
                                    StreetPart3, mipontotransvref,nortereferencia,orientereferencia);   

  end if;

	--##########################################
	--### RETORNO DA FUNCAO
	--##########################################       
	Ret := '';

	--Caso tenha selecionado uma rua
	if array_ndims(StreetParts) > 0 then
		Ret := nameviarecorrida;
	end if;

        sPrefijo:=' entre ';

        if (StreetParts[1].junction='roundabout') then
	  --nameviarecorrida:='Glorieta';
	  sprefijo:='';
	  nametrans1:=null;
	  nametrans2:=null;
	end if;	

        if position('(esquina)' in nametrans1)>0 then
          nametrans2:=null;
        end if;

        --Caso tenha selecionado a 1a transversal
        if  (nametrans2 is null) or nametrans2='' then
          sPrefijo:=' con ';
        end if;  
	
        --Ordena ascendentemente las vias
        if not ((nametrans2 is null) or nametrans2='') and nametrans2<nametrans1 then
          aux:=nametrans1;
          nametrans1:=nametrans2;
          nametrans2:=aux;
        end if;

        if not (nametrans2 is null) and nametrans1=nametrans2 then
          nametrans2:=nametrans2 || ' opuesta';
        end if;

        if not (nametrans1 is null) then
	  Ret := Ret || sPrefijo||nametrans1;
	end if;

        if nametrans2='NO APLICA' then
          nametrans2=null;
        end if;
	if not (nametrans2 is null) then
	  Ret := Ret || ' y '||nametrans2 ; 
	end if;
				
	    ret:=direccionCorregida;
        if not (ret is null or ret='') then
          select count(*) into iCantidad FROM vs_localizacao where punto=ponto;
          if iCantidad>0 then
            update vs_localizacao set direccion=ret, lineidtransversal1=lineidtrans1,lineidtransversal2=lineidtrans2 where punto=ponto;
          else
            insert into vs_localizacao(punto,direccion,lineid,direccion2,idpunto,lineidtransversal1,lineidtransversal2) values(ponto,ret,lineid,null,nextval('genidpunto'),lineidtrans1,lineidtrans2);
          end if;
          
        end if;
        --ret:=StreetParts[1].osm_id;
        return ret;
end;

$BODY$;

ALTER FUNCTION public.vs_reversegeocodereemplazo(double precision, double precision, boolean, character, character)
    OWNER TO postgres;
