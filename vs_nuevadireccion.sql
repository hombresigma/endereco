-- FUNCTION: public.vs_nuevadireccion(double precision, double precision, character)

-- DROP FUNCTION public.vs_nuevadireccion(double precision, double precision, character);

CREATE OR REPLACE FUNCTION public.vs_nuevadireccion(
	lat double precision,
	lon double precision,
	direccion character)
    RETURNS character
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 0
AS $BODY$

declare

--##########################################
--### VARIAVEIS
--##########################################
  PontoGPS geometry;
  Ponto geometry;
  Msg Varchar;

begin
    --Converte a latitude e a longitude em objetos geometricos
    PontoGPS := ST_SetSRID(ST_Point(lon,lat),4326);
    msg := 'PontoGPS -> '||'ST_GeomFromText('''||ST_AsText(PontoGPS)||''',4326)';
    raise notice '%',msg;

    
 
  --Calculo o Ponto da linha principal mais proximo do PontoGPS e usa este como o ponto daqui para frente
  Ponto := ST_ClosestPoint(PontoGPS,PontoGPS);
  msg := 'Ponto -> '||'ST_GeomFromText('''||ST_AsText(Ponto)||''',4326)';
  raise notice '%',msg;
				

 insert into vs_localizacao(punto,direccion,lineid,direccion2,idpunto,lineidtransversal1,lineidtransversal2) values(ponto,direccion,0,null,nextval('genidpunto'),0,0);

  return direccion;
end;

$BODY$;

ALTER FUNCTION public.vs_nuevadireccion(double precision, double precision, character)
    OWNER TO postgres;
