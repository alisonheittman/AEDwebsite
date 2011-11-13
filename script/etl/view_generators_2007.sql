create or replace view aed2007.actual_diff_continent as
select
  a."CONTINENT",
  a."DEFINITE"-o."DEFINITE" actual_dif_def,
  a."PROBABLE"-o."PROBABLE" actual_dif_prob,
  a."POSSIBLE"-o."POSSIBLE" actual_dif_poss,
  a."SPECUL"-o."SPECUL" actual_dif_spec
from aed2007."Continent" a
join (select 'Africa'::text "CONTINENT",aed2002."Continent".* from aed2002."Continent") o on
  a."CONTINENT" = o."CONTINENT"
;


-- Regional Change interpreters

create or replace view aed2007.actual_diff_region as
select
  a."REGION",
  a."DEFINITE"-o."DEFINITE" actual_dif_def,
  a."PROBABLE"-o."PROBABLE" actual_dif_prob,
  a."POSSIBLE"-o."POSSIBLE" actual_dif_poss,
  a."SPECUL"-o."SPECUL" actual_dif_spec
from aed2007."Regions" a
join aed2002."Regions" o on
  a."REGION" = o."REGION"
;

create or replace view aed2007.factor_region as
select
  i."REGION",
  actual_dif_def / CASE WHEN sum("DIFDEF")=0 THEN 1 ELSE sum("DIFDEF") END def_factor,
  actual_dif_prob / CASE WHEN sum("DIFPROB")=0 THEN 1 ELSE sum("DIFPROB") END prob_factor,
  actual_dif_poss / CASE WHEN sum("DIFPOSS")=0 THEN 1 ELSE sum("DIFPOSS") END poss_factor,
  actual_dif_spec / CASE WHEN sum("DIFSPEC")=0 THEN 1 ELSE sum("DIFSPEC") END spec_factor
from aed2007."ChangesInterpreter" i
join aed2007.actual_diff_region a on
  i."REGION"=a."REGION"
group by i."REGION",
  actual_dif_def,
  actual_dif_prob,
  actual_dif_poss,
  actual_dif_spec;

create or replace view aed2007.fractional_causes_of_change_by_region as
select
   aed2007."ChangesInterpreter"."REGION",
  "CauseofChange",
  def_factor * sum("DIFDEF") as definite,
  prob_factor * sum("DIFPROB") as probable,
  poss_factor * sum("DIFPOSS") as possible,
  spec_factor * sum("DIFSPEC") as specul
from aed2007."ChangesInterpreter"
join aed2007.factor_region on
  aed2007."ChangesInterpreter"."REGION" = aed2007.factor_region."REGION"
group by aed2007."ChangesInterpreter"."REGION", "CauseofChange", def_factor, prob_factor, poss_factor, spec_factor
order by aed2007."ChangesInterpreter"."REGION", "CauseofChange";

create or replace view aed2007.causes_of_change_by_region as
select
  "REGION",
  "CauseofChange",
  round(definite) definite,
  round(probable) probable,
  round(possible) possible,
  round(specul) specul
from aed2007.fractional_causes_of_change_by_region;

create or replace view aed2007.causes_of_change_sums_by_region as
select
  "REGION",
  round(sum(definite)) definite,
  round(sum(probable)) probable,
  round(sum(possible)) possible,
  round(sum(specul)) specul
from
  aed2007.fractional_causes_of_change_by_region
group by "REGION";


-- Country change interpeters

create or replace view aed2007.actual_diff_country as
select
  a."CCODE",
  a."DEFINITE"-o."DEFINITE" actual_dif_def,
  a."PROBABLE"-o."PROBABLE" actual_dif_prob,
  a."POSSIBLE"-o."POSSIBLE" actual_dif_poss,
  a."SPECUL"-o."SPECUL" actual_dif_spec
from aed2007."Country" a
join aed2002."Country" o on
  a."CCODE" = o."CCODE"
;

create or replace view aed2007.factor_country as
select
  a."CCODE" ccode,
  actual_dif_def / CASE WHEN sum(sumofdefinite)=0 THEN 1 ELSE sum(sumofdefinite) END def_factor,
  actual_dif_prob / CASE WHEN sum(sumofprobable)=0 THEN 1 ELSE sum(sumofprobable) END prob_factor,
  actual_dif_poss / CASE WHEN sum(sumofpossible)=0 THEN 1 ELSE sum(sumofpossible) END poss_factor,
  actual_dif_spec / CASE WHEN sum(sumofspecul)=0 THEN 1 ELSE sum(sumofspecul) END spec_factor
from aed2007.changesgrp i
join aed2007.actual_diff_country a on
  i."CCODE"=a."CCODE"
group by a."CCODE",
  actual_dif_def,
  actual_dif_prob,
  actual_dif_poss,
  actual_dif_spec;

create or replace view aed2007.fractional_causes_of_change_by_country as
select
  g."CCODE" ccode,
  "CauseofChange",
  def_factor * sum(sumofdefinite) as definite,
  prob_factor * sum(sumofprobable) as probable,
  poss_factor * sum(sumofpossible) as possible,
  spec_factor * sum(sumofspecul) as specul
from aed2007.changesgrp g
join aed2007.factor_country f on
  g."CCODE"=f.ccode
join aed2007."CausesOfChange" on
  "ReasonForChange"="ChangeCODE"
group by g."CCODE", "CauseofChange", def_factor, prob_factor, poss_factor, spec_factor
order by "CCODE", "CauseofChange";

create or replace view aed2007.causes_of_change_by_country as
select
  ccode,
  "CauseofChange",
  round(definite) definite,
  round(probable) probable,
  round(possible) possible,
  round(specul) specul
from aed2007.fractional_causes_of_change_by_country;

create or replace view aed2007.causes_of_change_sums_by_country as
select
  ccode,
  round(sum(definite)) definite,
  round(sum(probable)) probable,
  round(sum(possible)) possible,
  round(sum(specul)) specul
from
  aed2007.fractional_causes_of_change_by_country
group by ccode;


-- Summary totals

create or replace view aed2007.summary_totals_by_continent as
select
  'Africa'::text "CONTINENT",
  "CATEGORY",
  "SURVEYTYPE",
  ROUND("DEFINITE") "DEFINITE",
  ROUND("PROBABLE") "PROBABLE",
  ROUND("POSSIBLE") "POSSIBLE",
  ROUND("SPECUL") "SPECUL"
from aed2007."Contingrp"
order by "CATEGORY";

create or replace view aed2007.summary_sums_by_continent as
select
  "CONTINENT",
  "DEFINITE",
  "PROBABLE",
  "POSSIBLE",
  "SPECUL"
from aed2007."Continent";

create or replace view aed2007.summary_totals_by_region as
select
  "REGION",
  "CATEGORY",
  "SURVEYTYPE",
  ROUND("DEFINITE") "DEFINITE",
  ROUND("PROBABLE") "PROBABLE",
  ROUND("POSSIBLE") "POSSIBLE",
  ROUND("SPECUL") "SPECUL"
from aed2007."Regiongrp"
order by "CATEGORY";

create or replace view aed2007.summary_sums_by_region as
select
  "REGION",
  "DEFINITE",
  "PROBABLE",
  "POSSIBLE",
  "SPECUL"
from aed2007."Regions";

create or replace view aed2007.summary_totals_by_country as
select
  "CCODE" ccode,
  "CATEGORY",
  "SURVEYTYPE",
  "DEFINITE",
  "PROBABLE",
  "POSSIBLE",
  "SPECUL"
from aed2007."Countrygrp"
order by "CATEGORY";

create or replace view aed2007.summary_sums_by_country as
select
  "CCODE" ccode,
  "DEFINITE",
  "PROBABLE",
  "POSSIBLE",
  "SPECUL"
from aed2007."Country";


-- Area of range

create or replace view aed2007.area_of_range_covered_by_country as
select
  t1.ccode,
  t1.surveytype,
  t1.known,
  t2.possible,
  t3.total
from

(select aed2007."Country"."CCODE" ccode,
CASE WHEN "SURVEYTYPE" is null THEN 'Unassessed Range' ELSE "SURVEYTYPE" END
as surveytype, ROUND(SUM("SurvRang"."Shape_Area")) as known from aed2007."SurvRang" join aed2007."Country" on "CNTRYNAME_1"=aed2007."Country"."CNTRYNAME" and "Range"=1 and "RangeQuality"='Known' group by aed2007."Country"."CCODE","SURVEYTYPE" order by aed2007."Country"."CCODE","SURVEYTYPE") t1

left join

(select aed2007."Country"."CCODE" ccode,
CASE WHEN "SURVEYTYPE" is null THEN 'Unassessed Range' ELSE "SURVEYTYPE" END
as surveytype, ROUND(SUM("SurvRang"."Shape_Area")) as possible from aed2007."SurvRang" join aed2007."Country" on "CNTRYNAME_1"=aed2007."Country"."CNTRYNAME" and "Range"=1 and "RangeQuality"='Possible' group by aed2007."Country"."CCODE","SURVEYTYPE" order by aed2007."Country"."CCODE","SURVEYTYPE") t2

on t1.surveytype = t2.surveytype and t1.ccode = t2.ccode

left join

(select aed2007."Country"."CCODE" ccode,
CASE WHEN "SURVEYTYPE" is null THEN 'Unassessed Range' ELSE "SURVEYTYPE" END
as surveytype, ROUND(SUM("SurvRang"."Shape_Area")) as total from aed2007."SurvRang" join aed2007."Country" on "CNTRYNAME_1"=aed2007."Country"."CNTRYNAME" and "Range"=1 group by aed2007."Country"."CCODE","SURVEYTYPE" order by aed2007."Country"."CCODE","SURVEYTYPE") t3

on t1.surveytype = t3.surveytype and t1.ccode = t3.ccode;

create or replace view aed2007.area_of_range_covered_sum_by_country as
select ccode, sum(known) known, sum(possible) possible, sum(total) total from aed2007.area_of_range_covered_by_country group by ccode order by ccode;

create or replace view aed2007.area_of_range_covered_by_region as
select c."REGION", v.surveytype, sum(v.known) known, sum(v.possible) possible, sum(v.total) total from aed2007."Country" c join aed2007.area_of_range_covered_by_country v on c."CCODE"=v.ccode group by c."REGION", v.surveytype order by c."REGION", v.surveytype;

create or replace view aed2007.area_of_range_covered_sum_by_region as
select "REGION", sum(known) known, sum(possible) possible, sum(total) total from aed2007.area_of_range_covered_by_region group by "REGION" order by "REGION";

create or replace view aed2007.area_of_range_covered_by_continent as
select 'Africa'::text "CONTINENT", v.surveytype, sum(v.known) known, sum(v.possible) possible, sum(v.total) total from aed2007.area_of_range_covered_by_country v group by v.surveytype order by v.surveytype;

create or replace view aed2007.area_of_range_covered_sum_by_continent as
select "CONTINENT", sum(known) known, sum(possible) possible, sum(total) total from aed2007.area_of_range_covered_by_continent group by "CONTINENT" order by "CONTINENT";


-- Elephant Estimates by Country

create or replace view aed2007.elephant_estimates_by_country as
select distinct
  "INPCODE",
  "CCODE" ccode,
  "OBJECTID",
  "ReasonForChange",
  CASE WHEN "DESIGNATE" IS NULL THEN
    "SURVEYZONE"
  ELSE
    "SURVEYZONE" || ' ' || "DESIGNATE"
  END as survey_zone,
  "METHOD" || "QUALITY" method_and_quality,
  "CATEGORY",
  "CYEAR",
  "ESTIMATE",
  CASE WHEN "METHOD"='IG' THEN
    to_char("UPRANGE",'9999999') || '*'
  ELSE
    to_char(ROUND("CL95"),'9999999')
  END "CL95",
  "REFERENCE",
  "PFS",
  ROUND("AREA_SQKM") "AREA_SQKM",
  "LON" numeric_lon,
  "LAT" numeric_lat,
  CASE WHEN "LON"<0 THEN
    to_char(abs("LON"),'999D9')||'W'
  WHEN "LON"=0 THEN
    '0.0'
  ELSE
    to_char(abs("LON"),'999D9')||'E'
  END "LON",
  CASE WHEN "LAT"<0 THEN
    to_char(abs("LAT"),'990D9')||'S'
  WHEN "LAT"=0 THEN
    '0.0'
  ELSE
    to_char(abs("LAT"),'990D9')||'N'
  END "LAT"
from aed2007."Surveydata"
left join aed2007."ChangesTracker" on
  "OBJECTID"="CurrentOID"
order by "CCODE", survey_zone;