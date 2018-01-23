-- FUNCTION: public.vs_cargadirecciones(double precision, double precision)

-- DROP FUNCTION public.vs_cargadirecciones(double precision, double precision);

CREATE OR REPLACE FUNCTION public.vs_cargadirecciones(
	lat double precision,
	lon double precision)
    RETURNS character varying
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 0
AS $BODY$

declare


--##########################################
--### CURSORES
--##########################################
--Partes que compoe a rua principal
  curStreetParts cursor  for
	select line.*
	from planet_osm_line line
	where
	  Line.highway in ('primary', 'secondary', 'secondary_link','tertiary', 'residential','unclassiffied')
	  and Line.route is null;

  StreetPart planet_osm_line;

begin

--Monta uma lista com outras linhas que são referentes à mesma rua
  for Part in curStreetParts loop
		--Acrescenta ao array com as partes da rua
		StreetPart := Part;

  end loop;


        return Ret;
end;

$BODY$;

ALTER FUNCTION public.vs_cargadirecciones(double precision, double precision)
    OWNER TO postgres;
