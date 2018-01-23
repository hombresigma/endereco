-- FUNCTION: public.vs_cargadirecciones()

-- DROP FUNCTION public.vs_cargadirecciones();

CREATE OR REPLACE FUNCTION public.vs_cargadirecciones(
	)
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
  cursorposml cursor  for
	select line.*
	from planet_osm_line line
	where
	--'primary','primary_link','unclassified','secondary','secondary_link', 'tertiary','tertiary_link',
	  Line.highway in ( 'residential')
	  and Line.route is null
	 --  AND   100000*sT_DISTANCE(ST_TRANSFORM(line.WAY,4326),

                               --              ST_SetSRID(ST_Point(-75.597178, 6.254667),4326))
	                         --               <=1000
                                    
	                   and name is not null
	  ;

  poml planet_osm_line;
  punto point;
  puntogps point;
  ponto3 record;
  puntos geometry[];
  ii integer;
  jj integer;
  st varchar;
  id integer;
  xx geometry;
  x double precision;
  y double precision;
  msg varchar;
  texto varchar;
  a boolean;
begin
   a :=false;
  --ontogps:=ST_SetSRID(ST_MakePoint(-75.597221, 6.253409),4326);
  ii:=0;
  jj:=0;
       	msg := jj;
	raise notice '%',msg;
  for linea in cursorposml loop
    --Acrescenta ao array com as partes da rua
    ii:=ii+1;
    jj:=0;
    for xx in SELECT (dp).geom As wktnode
      FROM (SELECT 2 As edge_id
	, ST_DumpPoints(
	                linea.way
	                ) AS dp
       ) As foo 
    loop
      jj:=jj+1;
      x:=st_x(st_transform(xx,4326));
      y:=st_y(st_transform(xx,4326));
      
      texto:=vs_reversegeocode(y,x,false,null);
        
      --savepoint misavepoint;
      raise notice '%',texto;
      if texto is null or texto='' 
        then 
          continue;
      end if;
      raise notice '%',texto;
      raise notice 'iteracion ii  >>>>>>>>>>>>>>>>>> %',ii;
      raise notice 'iteracion jj  >>>>>>>>>>>>>>>>>> %',jj;	
    end loop;  
  end loop;
  return x||' - '||y||' '||ii||' '||jj;        
end;

$BODY$;

ALTER FUNCTION public.vs_cargadirecciones()
    OWNER TO postgres;
