-- FUNCTION: public.vs_obtenerviarecorrida(geometry)

-- DROP FUNCTION public.vs_obtenerviarecorrida(geometry);

CREATE OR REPLACE FUNCTION public.vs_obtenerviarecorrida(
	ppontogps geometry,
	OUT pponto geometry,
	OUT ppontoosm geometry,
	OUT pstreetpart planet_osm_line,
	OUT pstreetways geometry[],
	OUT viarecorrida planet_osm_line)
    RETURNS record
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 0
AS $BODY$

 

DECLARE
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
	  and Line.highway in ('primary', 'primary_link','secondary', 'secondary_link', 'tertiary','tertiary_link', 'residential','service','unclassiffied')
	  and Line.route is null;

  pStreetpart planet_osm_line;
  pStreetParts planet_osm_line[];
  viaRecorrida planet_osm_line;
  lineid bigint;
  Dummy float;
  msg varchar;
BEGIN

	--Busca a linha mais proxima do ponto,
        select ST_Distance( ST_Transform(line.way,4326), pPontoGPS) as Distance, line.osm_id into Dummy, LineID
        from planet_osm_line as line
	where 1 = 1
	  and Line.name is not null			  
	  and line.highway is not null
	  and Line.route is null
	order by Distance asc
	limit 1;

        --Carrega os dados da rua na variavel
	select * into pStreetPart
	  from planet_osm_line
	  where osm_id = LineId;

	--Calculo o Ponto da linha principal mais proximo do PontoGPS e usa este como o ponto daqui para frente
	pPonto := ST_ClosestPoint(ST_Transform(pStreetPart.way,4326),pPontoGPS);
	msg := 'Ponto -> '||'ST_GeomFromText('''||ST_AsText(pPonto)||''',4326)';
	raise notice '%',msg;

	pPontoOSM := ST_Transform(pPonto,900913);
	msg := 'PontoOSM -> '||'ST_GeomFromText('''||ST_AsText(pPontoOSM)||''',900913)';
	raise notice '%',msg;	

	--Acrescenta ao array com as partes da rua
	pStreetParts := array[pStreetPart];
	pStreetWays  := array[pStreetPart.way];
        msg := 'Street [Main]:'||pStreetPart.osm_id||'-'||pStreetPart.name||'-> '|| 'ST_GeomFromText('''||ST_AsText(pStreetPart.way)||''',900913)';
		raise notice '%',msg;
		
        viaRecorrida:=StreetParts[1];
	--Monta uma lista com outras linhas que são referentes à mesma rua
	for Part in curStreetParts(viaRecorrida.osm_id, viaRecorrida.name) loop
	  --Acrescenta ao array com as partes da rua
	  pStreetPart := Part;
	  pStreetParts := pStreetParts|| pStreetPart;
	  pStreetWays  := pStreetWays || pStreetPart.way;
	  msg := 'Street [Part]:'||pStreetPart.osm_id||'-'||pStreetPart.name||'-> '|| 'ST_GeomFromText('''||ST_AsText(pStreetPart.way)||''',900913)';
	  raise notice '%',msg;
	  --ajay:=ajay||StreetPart.osm_id||'-'||StreetPart.name;
	end loop;
END;

$BODY$;

ALTER FUNCTION public.vs_obtenerviarecorrida(geometry)
    OWNER TO postgres;
