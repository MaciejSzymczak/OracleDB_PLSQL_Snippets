--Levenshtein Distance (1965)
select UTL_MATCH.EDIT_DISTANCE('Maciej','Maciej') from dual -- 0-identical >0-differences
select UTL_MATCH.EDIT_DISTANCE_SIMILARITY('Maciej','Macije')  from dual -- 100-identical <100-differences
 
--Jaro-Winkler (Modern)
select UTL_MATCH.JARO_WINKLER('Maciej','Macije') from dual  -- 1-indentical <1-differences
select UTL_MATCH.JARO_WINKLER_SIMILARITY('Maciej','Macije') from dual  -- 100-indentical <100-differences
