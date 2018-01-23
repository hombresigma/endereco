-- FUNCTION: public.vs_angletoway(geometry, geometry, geometry[])

-- DROP FUNCTION public.vs_angletoway(geometry, geometry, geometry[]);

CREATE OR REPLACE FUNCTION public.vs_angletoway(
	point geometry,
	line geometry,
	way geometry[])
    RETURNS double precision
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 0
AS $BODY$

declare
  Street geometry;
  AngleOffset float;
  Angle float;
  Intersection geometry;
  StreetCenter geometry;
  LineCenter geometry;
begin

	raise debug '################ INICIO vs_AngleToWay';

	raise debug 'Line=%',ST_AsText(Line);

	--Verifica se a linha é uma rotatoria, se for o angulo é 90o
	if ST_StartPoint(Line) = ST_EndPoint(Line) then
		raise debug 'Rotatoria!!! Angulo será 90';
		return 90;
	end if;

	--Percorre todas as ruas do caminho
	foreach Street in array Way loop

		--caso a linha cruze com a rua
		--if vs_TouchWay(line,Array[Street]) then		

			raise debug 'Street=%',ST_AsText(Street);

			--Pega o ponto de interseção e os centros da linhas e converte para o padrao correto
			--Intersection := ST_Intersection(Street,Line);
			Intersection := ST_ClosestPoint(Street,Line);
			Intersection := ST_Transform(Intersection,4326);
			raise debug 'Intersection=%',ST_AsText(Intersection);
			StreetCenter := ST_Centroid(Street);
			StreetCenter := ST_Transform(StreetCenter,4326);
			raise debug 'StreetCenter=%',ST_AsText(StreetCenter);
			LineCenter   := ST_Centroid(Line);
			LineCenter   := ST_Transform(LineCenter,4326);
			raise debug 'LineCenter=%',ST_AsText(LineCenter);
			

			--Calcula o angulo entre o centro da rua e o ponto de interseção dela com a linha
			--esta será o angulo da rua, e sera utilizado com offset para calibrar a angulacao
			AngleOffset := degrees(ST_Azimuth(StreetCenter,Intersection));
			raise debug 'AngleOffsetCenter=%',AngleOffset;
			AngleOffset := degrees(ST_Azimuth(Point,Intersection));
			raise debug 'AngleOffsetPoint=%',AngleOffset;

			--Calcula o angulo entre as ruas
			--Angle := degrees(ST_Azimuth(StreetCenter,LineCenter));
			Angle := degrees(ST_Azimuth(LineCenter,Intersection));
			raise debug 'Angle=%',Angle;
			Angle := Angle - AngleOffset;
		  	Angle := Angle + 360;
		 	Angle := cast(trunc(Angle) as Integer) % 360;
		        raise debug 'Angle final=%',Angle;
			
			raise debug '################ FIM - com retorno vs_AngleToWay';
			return Angle;

			
		--end if;

	end loop;

	raise notice '################ FIM - SEM RETORNO vs_AngleToWay';
	return 0;
 end;

$BODY$;

ALTER FUNCTION public.vs_angletoway(geometry, geometry, geometry[])
    OWNER TO postgres;
