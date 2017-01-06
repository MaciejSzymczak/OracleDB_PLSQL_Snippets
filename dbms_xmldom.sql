easy example
-----------------------
declare
--  x_buff    CLOB;
--  G_XML            Xmldom.DOMDocument;
--  kcp_elmt  Xmldom.DOMElement;
--  kcp_node  Xmldom.DOMNode;
    G_XML         Xmldom.DOMDocument;
    kcp_node      Xmldom.DOMNode;        -- <KCP>
    kcp_elmt      Xmldom.DOMElement;  
    G_KCP_NODE                VARCHAR2(20)       := 'KCP';    
    x_buff CLOB := ' ';
begin
   /* if Xmldom.isnull(G_XML) then
        G_XML := Xmldom.newDOMDocument;
        kcp_node := Xmldom.makeNode(G_XML);
        kcp_elmt := Xmldom.createElement(G_XML, G_KCP_NODE);
        kcp_node := Xmldom.appendChild(kcp_node, Xmldom.makeNode(kcp_elmt));
    end if;
    Xmldom.writeToClob(G_XML,x_buff);
    insert into xxeraseme (cclob, name) values (x_buff, xxeraseme_s.nextval);
    Xmldom.freeDocument(G_XML);  */
  --      
  G_XML    := Xmldom.newDOMDocument;
  kcp_node := Xmldom.makeNode(G_XML);
  kcp_elmt := Xmldom.createElement (G_XML, 'TEST');  
  kcp_node := Xmldom.appendChild(kcp_node, Xmldom.makeNode(kcp_elmt));
--  G_XML    := Xmldom.makeDocument (kcp_node);
  Xmldom.writeToClob(G_XML,x_buff);
  --CREATE TABLE XXERASEME ( CCLOB  CLOB, NAME   VARCHAR2(10 BYTE) )
  insert into xxeraseme (cclob, name) values (x_buff, xxeraseme_s.nextval);
  Xmldom.freeDocument(G_XML);
end;


advanced example
-------------------------

CREATE OR REPLACE PACKAGE "XX_N_KCP_PKG" AS

    ---------------------------------------------------------------------------
	-- G³ówny pakiet obs³uguj¹cy generowanie raportu Karty Czasu Pracy       --
    -- Pracownika. Zlecenie jest bardzo skomplikoane i opis znajduje sie w   --
    -- PZUZ_MD050_NG08_v1B.doc. Zlecenie generuje plik XML uzywajac xmldom . --
    -- Potem te dane sa przetwarzaNE PRZEZ xmlp i generowany jest raport     --
 	--		   			  					  				 				 --
	-- Autor : Micha³ Kalisz												 --
	-- Data  : 13/03/2007													 --
	---------------------------------------------------------------------------
	G_LOG 	  		 	   NUMBER 	   	   := 1;
	G_OUTPUT  		 	   NUMBER		   := 2;
	G_DEBUG				   VARCHAR2(1)	   := 'Y';

	-- tagi XML
	G_KCP_NODE 			   VARCHAR2(20)	   := 'KCP';
	G_PARAMS	   		   VARCHAR2(20)	   := 'PARAM_LIST';
	G_EMP_LIST 		   	   VARCHAR2(20)	   := 'EMP_LIST';
	G_EMP	   		   	   VARCHAR2(20)	   := 'EMP';
	G_ASS_LIST 		   	   VARCHAR2(20)	   := 'ASS_LIST';
	G_ASS	   		   	   VARCHAR2(20)	   := 'ASS';
	G_MC_LIST  		   	   VARCHAR2(20)	   := 'MC_LIST';
	G_MC  		   	   	   VARCHAR2(20)	   := 'MC';
	G_DAY_LIST 		   	   VARCHAR2(20)	   := 'DAY_LIST';
	G_DAY  		   	   	   VARCHAR2(20)	   := 'DAY';

	-- tagi parametry
	G_DATE_FROM		   	   VARCHAR2(20)	   := 'OKRES_OD';
	G_DATE_TO		   	   VARCHAR2(20)	   := 'OKRES_DO';
	G_HIER_NAME		   	   VARCHAR2(20)	   := 'HIERARCHIA';
	G_ORG_NAME		   	   VARCHAR2(20)	   := 'JEDNOSTKA';
	G_PER_NAME		   	   VARCHAR2(20)	   := 'OSOBA';
	G_ASS_NUM		   	   VARCHAR2(20)	   := 'PRZYDZIAL';
	G_MODE		   	   	   VARCHAR2(20)	   := 'TRYB';

	-- tagi osoba
	G_PER_LAST_NAME		   VARCHAR2(20)	   := 'NAZWISKO';
	G_PER_FIRST_NAME	   VARCHAR2(20)	   := 'IMIE';
	G_PER_MID_NAME		   VARCHAR2(20)	   := 'D_IMIE';
	G_PER_LEVEL			   VARCHAR2(20)	   := 'LEVEL';
	G_SUM_PER_NCP		   VARCHAR2(20)	   := 'SUM_PER_NCP';
	G_SUM_PER_FCP		   VARCHAR2(20)	   := 'SUM_PER_FCP';
	G_SUM_PER_GN		   VARCHAR2(20)	   := 'SUM_PER_GN';
	G_SUM_PER_GD		   VARCHAR2(20)	   := 'SUM_PER_GD';
	G_SUM_PER_NC		   VARCHAR2(20)	   := 'SUM_PER_NC';
	G_SUM_PER_D_NCP		   VARCHAR2(20)	   := 'SUM_PER_D_NCP';
	G_SUM_PER_D_FCP		   VARCHAR2(20)	   := 'SUM_PER_D_FCP';
	G_SUM_PER_D_GN		   VARCHAR2(20)	   := 'SUM_PER_D_GN';
	G_SUM_PER_D_GD		   VARCHAR2(20)	   := 'SUM_PER_D_GD';
	G_SUM_PER_D_NC		   VARCHAR2(20)	   := 'SUM_PER_D_NC';
	G_SUM_PER_ABS_G		   VARCHAR2(20)	   := 'SUM_PER_ABS_G_';
	G_SUM_PER_ABS_D		   VARCHAR2(20)	   := 'SUM_PER_ABS_D_';

	-- tagi przydzial
	G_ASS_NUMBER		   VARCHAR2(20)	   := 'PRZYDZIAL_NUM';
	G_ASS_ORG		   	   VARCHAR2(20)	   := 'JEDNOSTKA_ORG';
	G_SUM_ASS_NCP		   VARCHAR2(20)	   := 'SUM_ASS_NCP';
	G_SUM_ASS_FCP		   VARCHAR2(20)	   := 'SUM_ASS_FCP';
	G_SUM_ASS_GN		   VARCHAR2(20)	   := 'SUM_ASS_GN';
	G_SUM_ASS_GD		   VARCHAR2(20)	   := 'SUM_ASS_GD';
	G_SUM_ASS_NC		   VARCHAR2(20)	   := 'SUM_ASS_NC';
	G_SUM_ASS_D_NCP		   VARCHAR2(20)	   := 'SUM_ASS_D_NCP';
	G_SUM_ASS_D_FCP		   VARCHAR2(20)	   := 'SUM_ASS_D_FCP';
	G_SUM_ASS_D_GN		   VARCHAR2(20)	   := 'SUM_ASS_D_GN';
	G_SUM_ASS_D_GD		   VARCHAR2(20)	   := 'SUM_ASS_D_GD';
	G_SUM_ASS_D_NC		   VARCHAR2(20)	   := 'SUM_ASS_D_NC';
	G_SUM_ASS_ABS_G		   VARCHAR2(20)	   := 'SUM_ASS_ABS_G_';
	G_SUM_ASS_ABS_D		   VARCHAR2(20)	   := 'SUM_ASS_ABS_D_';

	-- tagi miesiac
	G_MC_NR		   		   VARCHAR2(20)	   := 'MC_NR';
	G_MC_ROMAN	   		   VARCHAR2(20)	   := 'MC_ROMAN';
	G_MC_NAME	   		   VARCHAR2(20)	   := 'MC_NAME';
	G_YEAR_NR		   	   VARCHAR2(20)	   := 'YEAR';
	G_SUM_MC_NCP		   VARCHAR2(20)	   := 'SUM_MC_NCP';
	G_SUM_MC_FCP		   VARCHAR2(20)	   := 'SUM_MC_FCP';
	G_SUM_MC_GN		   	   VARCHAR2(20)	   := 'SUM_MC_GN';
	G_SUM_MC_GD		   	   VARCHAR2(20)	   := 'SUM_MC_GD';
	G_SUM_MC_NC		   	   VARCHAR2(20)	   := 'SUM_MC_NC';
	G_SUM_MC_D_NCP		   VARCHAR2(20)	   := 'SUM_MC_D_NCP';
	G_SUM_MC_D_FCP		   VARCHAR2(20)	   := 'SUM_MC_D_FCP';
	G_SUM_MC_D_GN		   VARCHAR2(20)	   := 'SUM_MC_D_GN';
	G_SUM_MC_D_GD		   VARCHAR2(20)	   := 'SUM_MC_D_GD';
	G_SUM_MC_D_NC		   VARCHAR2(20)	   := 'SUM_MC_D_NC';
	G_SUM_MC_ABS_G		   VARCHAR2(20)	   := 'SUM_MC_ABS_G_';
	G_SUM_MC_ABS_D		   VARCHAR2(20)	   := 'SUM_MC_ABS_D_';

	-- tagi dzien
	G_DAY_NR		   	   VARCHAR2(20)	   := 'DAY_NR';
	G_DAY_HOLY		   	   VARCHAR2(20)	   := 'DAY_HOLY';
	G_DAY_TYPE		   	   VARCHAR2(20)	   := 'DAY_TYPE';
	G_ABS_TYPE		   	   VARCHAR2(20)	   := 'ABS_TYPE';
	G_ABS_DISP_TYPE		   VARCHAR2(20)	   := 'ABS_DISP_TYPE';
	G_DAY_NCP		   	   VARCHAR2(20)	   := 'G_NCP'; 	  -- nominalny czas pracy
	G_DAY_FCP		   	   VARCHAR2(20)	   := 'G_FCP';	  -- faktyczny czas pracy
	G_DAY_GN		   	   VARCHAR2(20)	   := 'G_GN';	  -- Godziny nadliczbowe
	G_DAY_GD		   	   VARCHAR2(20)	   := 'G_GD';	  -- Godziny dyzuru
	G_DAY_NC		   	   VARCHAR2(20)	   := 'G_NC';	  -- Pora nocna
	-- tagi dla absencji sa ztablicowane i indeks jest wtedy nazwa znacznikiem XML

	-- liczniki
	g_err_cnt  			   NUMBER := 0;	   -- liczba bledow krytycznych
	g_ass_cnt 			   NUMBER := 0;	   -- liczba przydzialow
	g_mc_cnt 			   NUMBER := 0;	   -- liczba miesiecy

    TYPE R_ERROR IS RECORD
    (
        person_id		  NUMBER,
		assignment_id	  NUMBER,
		errbuf			  VARCHAR2(2000)
    );

  	TYPE T_ERRORS IS TABLE OF R_ERROR INDEX BY BINARY_INTEGER;
	G_ERRORS	  T_ERRORS;

	G_XML		  Xmldom.DOMDocument;

	-- nieobecnosci
	TYPE T_ABS IS TABLE OF NUMBER INDEX BY VARCHAR2(4);

	TYPE R_DAY IS RECORD
	(
	 	HOLY 	  VARCHAR2(1),	  -- Y/M
	 	DAY_TYPE  VARCHAR2(1),	  -- S/W/R
	 	ABS_TYPE  VARCHAR2(3),	  -- typ absencji jesli jest
	 	ABS_DISP  VARCHAR2(3),	  -- typ absencji - wyswietlany
	 	G_NCP 	  NUMBER,  	  -- godziny - nominalny czas pracy
		G_FCP     NUMBER,	  -- godziny - faktyczny czas pracy
		G_NADLICZ NUMBER,	  -- godziny - nadliczbowe
		G_DYZUR	  NUMBER,	  -- godziny - dyzur
		G_NOC	  NUMBER,	  -- godziny - noc
	 	D_NCP 	  NUMBER,  	  -- dni - nominalny czas pracy
		D_FCP     NUMBER,	  -- dni - faktyczny czas pracy
		D_NADLICZ NUMBER,	  -- dni - nadliczbowe
		D_DYZUR	  NUMBER,	  -- dni - dyzur
		D_NOC	  NUMBER,	  -- dni - noc
		G_ABS	  T_ABS,	  -- godziny nieobecnosci
		D_ABS	  T_ABS	  	  -- dni nieobecnosci
	);

	-- sumy dla poszczegolnych miesiecy
	TYPE R_SUMS IS RECORD
	(
	 	G_NCP 	  NUMBER,  	  -- godziny - nominalny czas pracy
		G_FCP     NUMBER,	  -- godziny - faktyczny czas pracy
		G_NADLICZ NUMBER,	  -- godziny nadliczbowe
		G_DYZUR	  NUMBER,	  -- godziny dyzur
		G_NOC	  NUMBER,	  -- godziny noc
	 	D_NCP 	  NUMBER,  	  -- dni - nominalny czas pracy
		D_FCP     NUMBER,	  -- dni - faktyczny czas pracy
		D_NADLICZ NUMBER,	  -- dni nadliczbowe
		D_DYZUR	  NUMBER,	  -- dni dyzur
		D_NOC	  NUMBER,	  -- dni noc
		G_ABS	  T_ABS,	  -- godziny nieobecnosci
		D_ABS	  T_ABS	  	  -- dni nieobecnosci
	);

	TYPE R_PERSON_DETAILS IS RECORD
	(
	 	LEVEL	  VARCHAR2(3)	   -- poziom zbierania danych dla osoby - PER/ASS
	);

	TYPE TABLE_D IS TABLE OF R_DAY INDEX BY BINARY_INTEGER;		-- 'DD'
	TYPE TABLE_M IS TABLE OF TABLE_D INDEX BY BINARY_INTEGER;	-- 'MMYYYY'
	TYPE TABLE_A IS TABLE OF TABLE_M INDEX BY BINARY_INTEGER; 	-- ASS_ID
	TYPE T_KCP IS TABLE OF TABLE_A INDEX BY BINARY_INTEGER; 	-- PER_ID

	-- sumy dla miesiaca
	TYPE SUMS_MC_M IS TABLE OF R_SUMS INDEX BY BINARY_INTEGER;		-- 'MMYYYY'
	TYPE SUMS_MC_A IS TABLE OF SUMS_MC_M INDEX BY BINARY_INTEGER; 	-- ASS_ID
	TYPE T_SUMS_MC IS TABLE OF SUMS_MC_A INDEX BY BINARY_INTEGER; 	-- PER_ID

	-- sumy dla przydzialu
	TYPE SUMS_ASS_A IS TABLE OF R_SUMS INDEX BY BINARY_INTEGER; 	-- ASS_ID
	TYPE T_SUMS_ASS IS TABLE OF SUMS_ASS_A INDEX BY BINARY_INTEGER; -- PER_ID

	-- sumy dla osoób
	TYPE T_SUMS_PER IS TABLE OF R_SUMS INDEX BY BINARY_INTEGER; 	-- PER_ID

	-- sumy dla osoób
	TYPE T_PERSON IS TABLE OF R_PERSON_DETAILS INDEX BY BINARY_INTEGER; 	-- PER_ID

	G_KCP	   	  T_KCP; 	 	-- szczegoly KCP
	G_PERSON	  T_PERSON;		-- szczegoly osoby
	G_SUMS_MC	  T_SUMS_MC; 	-- sumy MC
	G_SUMS_ASS	  T_SUMS_ASS; 	-- sumy ASS
	G_SUMS_PER	  T_SUMS_PER; 	-- sumy PER

	----------------------------------------------------------------------------
	-- Procedura g³owna zlecenia - raportu Karta Czasu Pracy                  --
	----------------------------------------------------------------------------
	PROCEDURE GenerateXML( p_errbuf  OUT NOCOPY VARCHAR2,
        	 			   p_retcode OUT NOCOPY VARCHAR2,
						   p_date_from 	 	    VARCHAR2,
						   p_date_to 	 		VARCHAR2,
						   p_effective_date		VARCHAR2,
						   p_hier_id            NUMBER,
						   p_hier_ver_id        NUMBER,
						   p_org_id             NUMBER,
						   p_person_id          NUMBER,
                           p_ass_id             NUMBER,
                           p_mode               VARCHAR2,
						   p_year_mode			VARCHAR2 DEFAULT 'N');

END Xx_N_Kcp_Pkg;
/




CREATE OR REPLACE PACKAGE BODY "XX_N_KCP_PKG" AS

    ---------------------------------------------------------------------------
	-- G³ówny pakiet obs³uguj¹cy generowanie raportu Karty Czasu Pracy       --
    -- Pracownika. Zlecenie jest bardzo skomplikoane i opis znajduje sie w   --
    -- PZUZ_MD050_NG08_v1B.doc. Zlecenie generuje plik XML uzywajac xmldom . --
    -- Potem te dane sa przetwarzaNE PRZEZ xmlp i generowany jest raport     --
 	--		   			  					  				 				 --
	-- Autor : Micha³ Kalisz												 --
	-- Data  : 13/03/2007													 --
	---------------------------------------------------------------------------

	--------------------------------------------------------------------------------------------------
	-- Funkcja w zaleznosci czy jest uruchomiona spod Concurrent Managera, czy z
	-- TOAD'a zapisuje dane do dbms_output lub na LOG/OUTPUT zlecenia
	--
	-- Autor : Micha³ Kalisz
	-- Data : 24/05/2005
	--------------------------------------------------------------------------------------------------
    PROCEDURE Put_Output(p_Type   VARCHAR2
                        ,p_Text	  CLOB
						,p_Debug  VARCHAR2 DEFAULT NULL)
	IS
	  	x_idx NUMBER := 0;
    BEGIN
		IF p_Debug IS NULL OR (p_Debug = 'Y' AND g_DEBUG = 'Y') THEN
	        IF Fnd_Global.conc_request_id = -1 THEN
			   	LOOP
		   	    	DBMS_OUTPUT.PUT_LINE(SUBSTR(p_Text,x_idx * 255 + 1, 255));
					x_idx := x_idx + 1;
					EXIT WHEN (NVL(LENGTH(p_Text),0) <= x_idx * 255);
				END LOOP;
			ELSE
				IF p_Type = g_LOG THEN Fnd_File.put_line(Fnd_File.LOG, p_Text);
				ELSIF p_Type = g_OUTPUT THEN
			   		LOOP
		   	    	    Fnd_File.put(Fnd_File.OUTPUT,SUBSTR(p_Text,x_idx * 8096 + 1, 8096));
						x_idx := x_idx + 1;
						EXIT WHEN (NVL(LENGTH(p_Text),0) <= x_idx * 8096);
					END LOOP;
				ELSE DBMS_OUTPUT.PUT_LINE(p_Text);
				END IF;
			END IF;
		END IF;
    END Put_Output;

	----------------------------------------------------------------------------
	-- Procedura sprawdzajaca czy dana osoba przydzial ma byc brana do KCP	  --
	-- oraz ewentualnie na jakim poziomie ma byc generowana dla tej osoby KCP --
	-- Moga byc dwa poziomy PER-osoby , ASS- przydzia³u, jesli funkcja zwraca --
	-- NULL to znaczy ze osoba nie bedzie brana do KCP	 	   		   		  --
	----------------------------------------------------------------------------
	FUNCTION CheckLevel(p_date_from DATE,
			  			p_date_to	DATE,
						p_person_id NUMBER,
						p_ass_id	NUMBER) RETURN VARCHAR2
	IS
	    CURSOR c_ass(cp_person_id NUMBER, cp_ass_id NUMBER, cp_date_from DATE, cp_date_to DATE) IS
			SELECT UNIQUE paaf.assignment_id ass_id
  			  FROM per_all_people_f papf,
  	   		  	   per_all_assignments_f paaf
 			 WHERE paaf.person_id = papf.person_id
   			   AND papf.person_id = cp_person_id
   			   AND paaf.assignment_id = NVL(cp_ass_id,paaf.assignment_id)
   			   AND paaf.assignment_status_type_id = 1
  			   AND NOT ((paaf.effective_end_date < cp_date_from) OR (paaf.effective_start_date > cp_date_to))
			   AND cp_date_to BETWEEN papf.EFFECTIVE_START_DATE AND papf.effective_end_date;

	    CURSOR c_cal(cp_ass_id NUMBER, cp_date_from DATE, cp_date_to DATE) IS
			SELECT xnacv.calendar_id cal_id
			  FROM xx_n_ass_cal_v xnacv
			 WHERE xnacv.assignment_id = cp_ass_id
  			   AND NOT ((xnacv.effective_end_date < cp_date_from) OR (xnacv.effective_start_date > cp_date_to));

		x_cnt      	NUMBER :=0;
		x_level    	VARCHAR2(3);
		x_cal_level	VARCHAR2(3);
		x_cal_name	VARCHAR2(240);

		x_per_cal_id NUMBER;
	BEGIN
		x_per_cal_id := Xx_N_Utils_Pkg.GetCalendar(p_person_id, NULL, p_date_to, x_cal_name, x_cal_level);

		FOR v_ass IN c_ass(p_person_id, p_ass_id,p_date_from, p_date_to) LOOP
			FOR v_cal IN c_cal(v_ass.ass_id, p_date_from, p_date_to) LOOP
				IF x_per_cal_id <> v_cal.cal_id THEN
				    RETURN 'ASG';
				END IF;
			END LOOP;
			x_cnt := x_cnt + 1;
		END LOOP;

		IF x_cnt > 0 THEN
		    RETURN 'PER';
		ELSE
		    RETURN NULL;
		END IF;
	END;


	----------------------------------------------------------------------------
	-- Funkcja sprawdza czy w danym miesiacu przydzial byl aktywny choc przez --
	-- jeden dzien i ma jakis kalendarz		 		   	   		   			  --
	----------------------------------------------------------------------------
	FUNCTION AssActive4Month(p_person_id NUMBER,
			 				 p_ass_id	 NUMBER,
			 				 p_month	 DATE) RETURN BOOLEAN
	IS
	    x_level	VARCHAR2(3);
	BEGIN
		x_level := CheckLevel(TRUNC(p_month,'MM'),LAST_DAY(p_month),p_person_id,p_ass_id);

		IF x_level IS NULL THEN
		    RETURN FALSE;
		ELSE
			RETURN TRUE;
		END IF;
	END;


	----------------------------------------------------------------------------
	-- Funkcja zwraca przydzial osoby na ktorym bedziemy zapisaywac dane do   --
	-- KCP. W przypdaku gdy pozim jest rowny PER to znajdujemy juz zalozony   --
	-- w strukturze G_KCP lub jesli nie jest zalozony zwracamy z parametru    --
	-- funkcji przydzial. Dal poziomu ASS zwracamy z parametru funkcji zawsze --
	----------------------------------------------------------------------------
	FUNCTION GetPersonAss(p_level 		VARCHAR2,
			 			  p_person_id	NUMBER,
						  p_ass_id		NUMBER) RETURN NUMBER
	IS
	  	x_ass_id	NUMBER;
	BEGIN
		IF p_level = 'ASG' THEN
		    x_ass_id := p_ass_id;
		ELSIF p_level = 'PER' THEN
			BEGIN
				x_ass_id := G_KCP(p_person_id).FIRST;
			EXCEPTION
				WHEN OTHERS THEN
					x_ass_Id := NULL;
			END;

			IF x_ass_id IS NULL THEN
				x_ass_id := p_ass_id;
			END IF;
		END IF;

		RETURN x_ass_id;
	END;


	----------------------------------------------------------------------------
	-- Procedura przygotowuje sekcje parametrow w pliku XML					  --
	----------------------------------------------------------------------------
	PROCEDURE StartXMLGen(p_date_from DATE,
			  			  p_date_to   DATE,
						  p_hier_name VARCHAR2,
						  p_org_name  VARCHAR2,
						  p_per_name  VARCHAR2,
						  p_ass_num   VARCHAR2,
						  p_mode	  VARCHAR2)
    IS
		main_node 	Xmldom.DOMNode;

		kcp_node  	Xmldom.DOMNode;		-- <KCP>
		kcp_elmt 	Xmldom.DOMElement;

		params_node Xmldom.DOMNode;	  	-- <PARAMS>
		params_elmt Xmldom.DOMElement;

  		param_node 	Xmldom.DOMNode;	  	-- <PARAM>
		param_elmt 	Xmldom.DOMElement;
  		param_text 	Xmldom.DOMText;

		per_node 	Xmldom.DOMNode;	  	-- <EMP_LIST>
		per_elmt 	Xmldom.DOMElement;
	BEGIN
		-- jesli nie ma jeszcze w pamieci dokumentu XML trzeba go zalozyc
		IF Xmldom.isnull(G_XML) THEN
		   	G_XML := Xmldom.newDOMDocument;
		   	kcp_node := Xmldom.makeNode(G_XML);
		   	kcp_elmt := Xmldom.createElement(G_XML, G_KCP_NODE);
		   	kcp_node := Xmldom.appendChild(kcp_node, Xmldom.makeNode(kcp_elmt));

    	   	params_elmt := Xmldom.createElement(G_XML, G_PARAMS);
    	   	params_node := Xmldom.appendChild(kcp_node, Xmldom.makeNode(params_elmt));

		   	-- p_date_from
		   	param_elmt := Xmldom.createElement(G_XML, G_DATE_FROM);
    	   	param_node := Xmldom.appendChild(params_node, Xmldom.makeNode(param_elmt));
		   	IF p_date_from IS NOT NULL THEN
			   	param_text := Xmldom.createTextNode(G_XML, TO_CHAR(p_date_from,'DD-MM-YYYY'));
    	   		param_node := Xmldom.appendChild(param_node, Xmldom.makeNode(param_text));
			END IF;

		   	-- p_date_to
		   	param_elmt := Xmldom.createElement(G_XML, G_DATE_TO);
    	   	param_node := Xmldom.appendChild(params_node, Xmldom.makeNode(param_elmt));
		   	IF p_date_to IS NOT NULL THEN
    	   	    param_text := Xmldom.createTextNode(G_XML, TO_CHAR(p_date_to,'DD-MM-YYYY'));
    	   		param_node := Xmldom.appendChild(param_node, Xmldom.makeNode(param_text));
			END IF;

		   	-- p_hier_name
		   	param_elmt := Xmldom.createElement(G_XML, G_HIER_NAME);
    	   	param_node := Xmldom.appendChild(params_node, Xmldom.makeNode(param_elmt));
		   	IF p_hier_name IS NOT NULL THEN
    	   	    param_text := Xmldom.createTextNode(G_XML, p_hier_name);
    	   	   	param_node := Xmldom.appendChild(param_node, Xmldom.makeNode(param_text));
		    END IF;

		   	-- p_org_name
		   	param_elmt := Xmldom.createElement(G_XML, G_ORG_NAME);
    	   	param_node := Xmldom.appendChild(params_node, Xmldom.makeNode(param_elmt));
		   	IF p_org_name IS NOT NULL THEN
    	   	   	param_text := Xmldom.createTextNode(G_XML, p_org_name);
    	   	   	param_node := Xmldom.appendChild(param_node, Xmldom.makeNode(param_text));
		   	END IF;

		   	-- p_per_name
		   	param_elmt := Xmldom.createElement(G_XML, G_PER_NAME);
    	   	param_node := Xmldom.appendChild(params_node, Xmldom.makeNode(param_elmt));
		   	IF p_per_name IS NOT NULL THEN
    	   	    param_text := Xmldom.createTextNode(G_XML, p_per_name);
    	   	   	param_node := Xmldom.appendChild(param_node, Xmldom.makeNode(param_text));
		   	END IF;

		   	-- p_ass_num
		   	param_elmt := Xmldom.createElement(G_XML, G_ASS_NUM);
    	   	param_node := Xmldom.appendChild(params_node, Xmldom.makeNode(param_elmt));
		    IF p_ass_num IS NOT NULL THEN
    	   	    param_text := Xmldom.createTextNode(G_XML, p_ass_num);
    	   		param_node := Xmldom.appendChild(param_node, Xmldom.makeNode(param_text));
			END IF;

		   	-- p_mode
		   	param_elmt := Xmldom.createElement(G_XML, G_MODE);
    	   	param_node := Xmldom.appendChild(params_node, Xmldom.makeNode(param_elmt));
		    IF p_mode IS NOT NULL THEN
    	   	    param_text := Xmldom.createTextNode(G_XML, p_mode);
    	   		param_node := Xmldom.appendChild(param_node, Xmldom.makeNode(param_text));
			END IF;
		END IF;

        per_elmt := Xmldom.createElement(G_XML, G_EMP_LIST);
		per_node := Xmldom.appendChild(kcp_node, Xmldom.makeNode(per_elmt));

	END;

	----------------------------------------------------------------------------
	-- Procedura zapisuje plik XML na output i zakancza jego przetwarzanie	  --
	----------------------------------------------------------------------------
	PROCEDURE FinishXMLGen
	IS
		x_buff CLOB := ' ';
	BEGIN
		Xmldom.writeToClob(G_XML,x_buff);
		Put_OutPut(G_OUTPUT,'<?xml version="1.0" encoding="windows-1250"?>');
		Put_Output(G_OUTPUT,x_buff);
		Xmldom.freeDocument(G_XML);
	END;

	----------------------------------------------------------------------------
	-- Funkcja tworzy nowa galaz dla osoby <PER>						      --
	----------------------------------------------------------------------------
	FUNCTION CreatePerNode(p_emp_node	Xmldom.DOMNode,
			  			   p_person_id  NUMBER,
			  			   p_date		DATE,
						   p_sum_per	R_SUMS) RETURN Xmldom.DOMNode
	IS
		x_details   Xx_N_Class_Pkg.T_DETAILS;

		per_node 	Xmldom.DOMNode;	  	-- <PER>
		per_elmt 	Xmldom.DOMElement;

		ass_node 	Xmldom.DOMNode;	  	-- <ASS_LIST>
		ass_elmt 	Xmldom.DOMElement;

		item_node 	Xmldom.DOMNode;	  	-- szczegly roznych znacznikow
		item_elmt 	Xmldom.DOMElement;
  		item_text 	Xmldom.DOMText;

		x_abs		VARCHAR2(40);
	BEGIN
		Xx_N_Class_Pkg.GetPersonDetails(p_person_id, p_date, x_details);

  	   	per_elmt := Xmldom.createElement(G_XML, G_EMP);
  	   	per_node := Xmldom.appendChild(p_emp_node, Xmldom.makeNode(per_elmt));

		-- last_name
  	    item_elmt := Xmldom.createElement(G_XML, G_PER_LAST_NAME);
 		item_node := Xmldom.appendChild(per_node, Xmldom.makeNode(item_elmt));
		IF x_details('PER_LAST_NAME') IS NOT NULL THEN
   	        item_text := Xmldom.createTextNode(G_XML, x_details('PER_LAST_NAME'));
   	   		item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
		END IF;

		-- first_name
  	    item_elmt := Xmldom.createElement(G_XML, G_PER_FIRST_NAME);
 		item_node := Xmldom.appendChild(per_node, Xmldom.makeNode(item_elmt));
		IF x_details('PER_FIRST_NAME') IS NOT NULL THEN
   	        item_text := Xmldom.createTextNode(G_XML, x_details('PER_FIRST_NAME'));
   	   		item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
		END IF;

		-- middle_name
  	    item_elmt := Xmldom.createElement(G_XML, G_PER_MID_NAME);
 		item_node := Xmldom.appendChild(per_node, Xmldom.makeNode(item_elmt));
		IF x_details('PER_MIDDLE_NAMES') IS NOT NULL THEN
   	        item_text := Xmldom.createTextNode(G_XML, x_details('PER_MIDDLE_NAMES'));
   	   		item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
		END IF;

		-- poziom PER/ASS
  	    item_elmt := Xmldom.createElement(G_XML, G_PER_LEVEL);
 		item_node := Xmldom.appendChild(per_node, Xmldom.makeNode(item_elmt));
		IF G_PERSON(p_person_id).LEVEL IS NOT NULL THEN
   	        item_text := Xmldom.createTextNode(G_XML, G_PERSON(p_person_id).LEVEL);
   	   		item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
		END IF;

		-- SUMA - nominalny czas pracy
 		IF p_sum_per.G_NCP IS NOT NULL THEN
   	        item_elmt := Xmldom.createElement(G_XML, G_SUM_PER_NCP);
  			item_node := Xmldom.appendChild(per_node, Xmldom.makeNode(item_elmt));
	   	    item_text := Xmldom.createTextNode(G_XML, Xx_N_Utils_Pkg.GetDispHours(p_sum_per.G_NCP));
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 		END IF;

 		IF p_sum_per.D_NCP IS NOT NULL THEN
   	        item_elmt := Xmldom.createElement(G_XML, G_SUM_PER_D_NCP);
  			item_node := Xmldom.appendChild(per_node, Xmldom.makeNode(item_elmt));
	   	    item_text := Xmldom.createTextNode(G_XML, p_sum_per.D_NCP);
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 		END IF;

		-- SUMA - faktyczny czas pracy
 		IF p_sum_per.G_FCP IS NOT NULL THEN
   	        item_elmt := Xmldom.createElement(G_XML, G_SUM_PER_FCP);
  			item_node := Xmldom.appendChild(per_node, Xmldom.makeNode(item_elmt));
	   	    item_text := Xmldom.createTextNode(G_XML, Xx_N_Utils_Pkg.GetDispHours(p_sum_per.G_FCP));
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 		END IF;

 		IF p_sum_per.D_FCP IS NOT NULL THEN
   	        item_elmt := Xmldom.createElement(G_XML, G_SUM_PER_D_FCP);
  			item_node := Xmldom.appendChild(per_node, Xmldom.makeNode(item_elmt));
	   	    item_text := Xmldom.createTextNode(G_XML, p_sum_per.D_FCP);
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 		END IF;

 		IF NOT NVL(p_sum_per.G_NADLICZ,0) = 0 THEN
   	        item_elmt := Xmldom.createElement(G_XML, G_SUM_PER_GN);
  			item_node := Xmldom.appendChild(per_node, Xmldom.makeNode(item_elmt));
	   	    item_text := Xmldom.createTextNode(G_XML, Xx_N_Utils_Pkg.GetDispHours(p_sum_per.G_NADLICZ));
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 		END IF;

 		IF p_sum_per.D_NADLICZ IS NOT NULL THEN
   	        item_elmt := Xmldom.createElement(G_XML, G_SUM_PER_D_GN);
  			item_node := Xmldom.appendChild(per_node, Xmldom.makeNode(item_elmt));
	   	    item_text := Xmldom.createTextNode(G_XML, p_sum_per.D_NADLICZ);
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 		END IF;

		IF NOT NVL(p_sum_per.G_DYZUR,0) = 0 THEN
   	        item_elmt := Xmldom.createElement(G_XML, G_SUM_PER_GD);
  			item_node := Xmldom.appendChild(per_node, Xmldom.makeNode(item_elmt));
	   	    item_text := Xmldom.createTextNode(G_XML, Xx_N_Utils_Pkg.GetDispHours(p_sum_per.G_DYZUR));
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 		END IF;

   		IF p_sum_per.D_DYZUR IS NOT NULL THEN
   	        item_elmt := Xmldom.createElement(G_XML, G_SUM_PER_D_GD);
  			item_node := Xmldom.appendChild(per_node, Xmldom.makeNode(item_elmt));
	   	    item_text := Xmldom.createTextNode(G_XML, p_sum_per.D_DYZUR);
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 		END IF;

		IF NOT NVL(p_sum_per.G_NOC,0) = 0 THEN
   	        item_elmt := Xmldom.createElement(G_XML, G_SUM_PER_NC);
  			item_node := Xmldom.appendChild(per_node, Xmldom.makeNode(item_elmt));
	   	    item_text := Xmldom.createTextNode(G_XML, Xx_N_Utils_Pkg.GetDispHours(p_sum_per.G_NOC));
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 		END IF;

    	IF p_sum_per.D_NOC IS NOT NULL THEN
   	        item_elmt := Xmldom.createElement(G_XML, G_SUM_PER_D_NC);
  			item_node := Xmldom.appendChild(per_node, Xmldom.makeNode(item_elmt));
	   	    item_text := Xmldom.createTextNode(G_XML, p_sum_per.D_NOC);
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 		END IF;

		-- SUMA - absencje
		x_abs := p_sum_per.G_ABS.FIRST;
		WHILE x_abs IS NOT NULL LOOP
			-- SUMA - godziny absencji
   	    	item_elmt := Xmldom.createElement(G_XML, G_SUM_PER_ABS_G || x_abs);
  			item_node := Xmldom.appendChild(per_node, Xmldom.makeNode(item_elmt));
 			IF NOT NVL(p_sum_per.G_ABS(x_abs),0) = 0 THEN
	   	        item_text := Xmldom.createTextNode(G_XML, Xx_N_Utils_Pkg.GetDispHours(p_sum_per.G_ABS(x_abs)));
	   	   		item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 			END IF;

			-- SUMA - dni absencji
   	    	item_elmt := Xmldom.createElement(G_XML, G_SUM_PER_ABS_D || x_abs);
  			item_node := Xmldom.appendChild(per_node, Xmldom.makeNode(item_elmt));
 			IF NOT NVL(p_sum_per.G_ABS(x_abs),0) = 0 THEN						  	  -- jesli tylko jest jakas godzina absencji wyswietl liczbe dni
	   	        item_text := Xmldom.createTextNode(G_XML, p_sum_per.D_ABS(x_abs));
	   	   		item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 			END IF;

			x_abs := p_sum_per.G_ABS.NEXT(x_abs);
		END LOOP;

        ass_elmt := Xmldom.createElement(G_XML, G_ASS_LIST);
		ass_node := Xmldom.appendChild(per_node, Xmldom.makeNode(ass_elmt));

		RETURN ass_node;
	END;


	----------------------------------------------------------------------------
	-- Funkcja tworzy nowa galaz dla przydzialu <ASS>					      --
	----------------------------------------------------------------------------
	FUNCTION CreateAssNode(p_per_node	Xmldom.DOMNode,
			  			   p_ass_id 	NUMBER,
			  			   p_date		DATE,
						   p_sum_ass	R_SUMS) RETURN Xmldom.DOMNode
	IS
		x_details   Xx_N_Class_Pkg.T_DETAILS;

		ass_node 	Xmldom.DOMNode;	  	-- <ASS>
		ass_elmt 	Xmldom.DOMElement;

		mc_node 	Xmldom.DOMNode;	  	-- <MC_LIST>
		mc_elmt 	Xmldom.DOMElement;

		item_node 	Xmldom.DOMNode;	  	-- szczegly roznych znacznikow
		item_elmt 	Xmldom.DOMElement;
  		item_text 	Xmldom.DOMText;

		x_abs		VARCHAR2(40);
	BEGIN
   	    ass_elmt := Xmldom.createElement(G_XML, G_ASS);
   		ass_node := Xmldom.appendChild(p_per_node, Xmldom.makeNode(ass_elmt));

		Xx_N_Class_Pkg.GetAssDetails(p_ass_id, p_date, x_details);

		-- ass_number
   	    item_elmt := Xmldom.createElement(G_XML, G_ASS_NUMBER);
  		item_node := Xmldom.appendChild(ass_node, Xmldom.makeNode(item_elmt));
 		IF x_details('ASS_NUMBER') IS NOT NULL THEN
	   	    item_text := Xmldom.createTextNode(G_XML, x_details('ASS_NUMBER'));
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 		END IF;

		-- org_name
        item_elmt := Xmldom.createElement(G_XML, G_ASS_ORG);
		item_node := Xmldom.appendChild(ass_node, Xmldom.makeNode(item_elmt));
 		IF x_details('ORG_NAME') IS NOT NULL THEN
	   	    item_text := Xmldom.createTextNode(G_XML, x_details('ORG_NAME'));
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 		END IF;

		-- SUMA - nominalny czas pracy
 		IF p_sum_ass.G_NCP IS NOT NULL THEN
   	        item_elmt := Xmldom.createElement(G_XML, G_SUM_ASS_NCP);
  			item_node := Xmldom.appendChild(ass_node, Xmldom.makeNode(item_elmt));
	   	    item_text := Xmldom.createTextNode(G_XML, Xx_N_Utils_Pkg.GetDispHours(p_sum_ass.G_NCP));
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 		END IF;

 		IF p_sum_ass.D_NCP IS NOT NULL THEN
   	        item_elmt := Xmldom.createElement(G_XML, G_SUM_ASS_D_NCP);
  			item_node := Xmldom.appendChild(ass_node, Xmldom.makeNode(item_elmt));
	   	    item_text := Xmldom.createTextNode(G_XML, p_sum_ass.D_NCP);
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 		END IF;

		-- SUMA - faktyczny czas pracy
 		IF p_sum_ass.G_FCP IS NOT NULL THEN
   	        item_elmt := Xmldom.createElement(G_XML, G_SUM_ASS_FCP);
  			item_node := Xmldom.appendChild(ass_node, Xmldom.makeNode(item_elmt));
	   	    item_text := Xmldom.createTextNode(G_XML, Xx_N_Utils_Pkg.GetDispHours(p_sum_ass.G_FCP));
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 		END IF;

 		IF p_sum_ass.D_FCP IS NOT NULL THEN
   	        item_elmt := Xmldom.createElement(G_XML, G_SUM_ASS_D_FCP);
  			item_node := Xmldom.appendChild(ass_node, Xmldom.makeNode(item_elmt));
	   	    item_text := Xmldom.createTextNode(G_XML, p_sum_ass.D_FCP);
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 		END IF;

		-- SUMA - godziny nadliczbowe
 		IF NOT NVL(p_sum_ass.G_NADLICZ,0) = 0 THEN
   	        item_elmt := Xmldom.createElement(G_XML, G_SUM_ASS_GN);
  			item_node := Xmldom.appendChild(ass_node, Xmldom.makeNode(item_elmt));
	   	    item_text := Xmldom.createTextNode(G_XML, Xx_N_Utils_Pkg.GetDispHours(p_sum_ass.G_NADLICZ));
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 		END IF;

 		IF p_sum_ass.D_NADLICZ IS NOT NULL THEN
   	        item_elmt := Xmldom.createElement(G_XML, G_SUM_ASS_D_GN);
  			item_node := Xmldom.appendChild(ass_node, Xmldom.makeNode(item_elmt));
	   	    item_text := Xmldom.createTextNode(G_XML, p_sum_ass.D_NADLICZ);
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 		END IF;

		-- SUMA - godziny dyzuru
		IF NOT NVL(p_sum_ass.G_DYZUR,0) = 0 THEN
		    item_elmt := Xmldom.createElement(G_XML, G_SUM_ASS_GD);
  			item_node := Xmldom.appendChild(ass_node, Xmldom.makeNode(item_elmt));
	   	    item_text := Xmldom.createTextNode(G_XML, Xx_N_Utils_Pkg.GetDispHours(p_sum_ass.G_DYZUR));
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 		END IF;

 		IF p_sum_ass.D_DYZUR IS NOT NULL THEN
		    item_elmt := Xmldom.createElement(G_XML, G_SUM_ASS_D_GD);
  			item_node := Xmldom.appendChild(ass_node, Xmldom.makeNode(item_elmt));
	   	    item_text := Xmldom.createTextNode(G_XML, p_sum_ass.D_DYZUR);
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 		END IF;

		-- SUMA - godziny nocne
 		IF NOT NVL(p_sum_ass.G_NOC,0) = 0 THEN
   	        item_elmt := Xmldom.createElement(G_XML, G_SUM_ASS_NC);
  			item_node := Xmldom.appendChild(ass_node, Xmldom.makeNode(item_elmt));
	   	    item_text := Xmldom.createTextNode(G_XML, Xx_N_Utils_Pkg.GetDispHours(p_sum_ass.G_NOC));
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 		END IF;

 		IF p_sum_ass.D_NOC IS NOT NULL THEN
   	        item_elmt := Xmldom.createElement(G_XML, G_SUM_ASS_D_NC);
  			item_node := Xmldom.appendChild(ass_node, Xmldom.makeNode(item_elmt));
	   	    item_text := Xmldom.createTextNode(G_XML, p_sum_ass.D_NOC);
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 		END IF;

		-- SUMA - absencje
		x_abs :=  p_sum_ass.G_ABS.FIRST;
		WHILE x_abs IS NOT NULL LOOP
			-- SUMA - godziny absencji
   	    	item_elmt := Xmldom.createElement(G_XML, G_SUM_ASS_ABS_G || x_abs);
  			item_node := Xmldom.appendChild(ass_node, Xmldom.makeNode(item_elmt));
 			IF NOT NVL(p_sum_ass.G_ABS(x_abs),0) = 0 THEN
	   	        item_text := Xmldom.createTextNode(G_XML, Xx_N_Utils_Pkg.GetDispHours(p_sum_ass.G_ABS(x_abs)));
	   	   		item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 			END IF;

			-- SUMA - dni absencji
   	    	item_elmt := Xmldom.createElement(G_XML, G_SUM_ASS_ABS_D|| x_abs);
  			item_node := Xmldom.appendChild(ass_node, Xmldom.makeNode(item_elmt));
 			IF NOT NVL(p_sum_ass.G_ABS(x_abs),0) = 0 THEN
	   	        item_text := Xmldom.createTextNode(G_XML, p_sum_ass.D_ABS(x_abs));
	   	   		item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 			END IF;

			x_abs := p_sum_ass.G_ABS.NEXT(x_abs);
		END LOOP;

        mc_elmt := Xmldom.createElement(G_XML, G_MC_LIST);
		mc_node := Xmldom.appendChild(ass_node, Xmldom.makeNode(mc_elmt));

		RETURN mc_node;
	END;

	----------------------------------------------------------------------------
	-- Funkcja tworzy nowa galaz dla miesiecy <MC>					      	  --
	----------------------------------------------------------------------------
	FUNCTION CreateMcNode(p_ass_node	Xmldom.DOMNode,
			  			  p_mc_idx 		NUMBER,
						  p_sum_mc		R_SUMS) RETURN Xmldom.DOMNode
	IS
		mc_node 	Xmldom.DOMNode;	  	-- <MC>
		mc_elmt 	Xmldom.DOMElement;

		day_node 	Xmldom.DOMNode;	  	-- <DAY_LIST>
		day_elmt 	Xmldom.DOMElement;

		item_node 	Xmldom.DOMNode;	  	-- szczegly roznych znacznikow
		item_elmt 	Xmldom.DOMElement;
  		item_text 	Xmldom.DOMText;

		x_abs		VARCHAR2(40);
	BEGIN
   	    mc_elmt := Xmldom.createElement(G_XML, G_MC);
   		mc_node := Xmldom.appendChild(p_ass_node, Xmldom.makeNode(mc_elmt));

		-- month_number
   	    item_elmt := Xmldom.createElement(G_XML, G_MC_NR);
  		item_node := Xmldom.appendChild(mc_node, Xmldom.makeNode(item_elmt));
 		IF p_mc_idx IS NOT NULL THEN
	   	    item_text := Xmldom.createTextNode(G_XML, SUBSTR(TO_CHAR(p_mc_idx),5,2));
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 		END IF;

		-- month_roman
   	    item_elmt := Xmldom.createElement(G_XML, G_MC_ROMAN);
  		item_node := Xmldom.appendChild(mc_node, Xmldom.makeNode(item_elmt));
 		IF p_mc_idx IS NOT NULL THEN
	   	    item_text := Xmldom.createTextNode(G_XML, TRIM(TO_CHAR(TO_DATE(p_mc_idx,'YYYYMM'),'RM')));
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 		END IF;

		-- month_name
   	    item_elmt := Xmldom.createElement(G_XML, G_MC_NAME);
  		item_node := Xmldom.appendChild(mc_node, Xmldom.makeNode(item_elmt));
 		IF p_mc_idx IS NOT NULL THEN
	   	    item_text := Xmldom.createTextNode(G_XML, TRIM(TO_CHAR(TO_DATE(p_mc_idx,'YYYYMM'),'MONTH')));
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 		END IF;

		-- year_number
   	    item_elmt := Xmldom.createElement(G_XML, G_YEAR_NR);
  		item_node := Xmldom.appendChild(mc_node, Xmldom.makeNode(item_elmt));
 		IF p_mc_idx IS NOT NULL THEN
	   	    item_text := Xmldom.createTextNode(G_XML,  SUBSTR(TO_CHAR(p_mc_idx),1,4));
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 		END IF;

		-- SUMA - nominalny czas pracy
 		IF p_sum_mc.G_NCP IS NOT NULL THEN
   	        item_elmt := Xmldom.createElement(G_XML, G_SUM_MC_NCP);
  		    item_node := Xmldom.appendChild(mc_node, Xmldom.makeNode(item_elmt));
	   	    item_text := Xmldom.createTextNode(G_XML, Xx_N_Utils_Pkg.GetDispHours(p_sum_mc.G_NCP));
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
		END IF;

		IF p_sum_mc.D_NCP IS NOT NULL THEN
   	    	item_elmt := Xmldom.createElement(G_XML, G_SUM_MC_D_NCP);
  			item_node := Xmldom.appendChild(mc_node, Xmldom.makeNode(item_elmt));
	   	    item_text := Xmldom.createTextNode(G_XML, p_sum_mc.D_NCP);
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 		END IF;

		-- SUMA - faktyczny czas pracy
		IF p_sum_mc.G_FCP IS NOT NULL THEN
   	        item_elmt := Xmldom.createElement(G_XML, G_SUM_MC_FCP);
  			item_node := Xmldom.appendChild(mc_node, Xmldom.makeNode(item_elmt));
	   	    item_text := Xmldom.createTextNode(G_XML, Xx_N_Utils_Pkg.GetDispHours(p_sum_mc.G_FCP));
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
		END IF;

 		IF p_sum_mc.D_FCP IS NOT NULL THEN
   	    	item_elmt := Xmldom.createElement(G_XML, G_SUM_MC_D_FCP);
  			item_node := Xmldom.appendChild(mc_node, Xmldom.makeNode(item_elmt));
	   	    item_text := Xmldom.createTextNode(G_XML, p_sum_mc.D_FCP);
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 		END IF;

		-- SUMA - godziny nadliczbowe
 		IF NOT NVL(p_sum_mc.G_NADLICZ, 0) = 0 THEN
   	        item_elmt := Xmldom.createElement(G_XML, G_SUM_MC_GN);
  			item_node := Xmldom.appendChild(mc_node, Xmldom.makeNode(item_elmt));
	   	    item_text := Xmldom.createTextNode(G_XML, Xx_N_Utils_Pkg.GetDispHours(p_sum_mc.G_NADLICZ));
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
		END IF;

 		IF p_sum_mc.D_NADLICZ IS NOT NULL THEN
   	    	item_elmt := Xmldom.createElement(G_XML, G_SUM_MC_D_GN);
  			item_node := Xmldom.appendChild(mc_node, Xmldom.makeNode(item_elmt));
	   	    item_text := Xmldom.createTextNode(G_XML, p_sum_mc.D_NADLICZ);
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 		END IF;

		-- SUMA - godziny dyzuru
 		IF NOT NVL(p_sum_mc.G_DYZUR, 0) = 0 THEN
   	        item_elmt := Xmldom.createElement(G_XML, G_SUM_MC_GD);
  			item_node := Xmldom.appendChild(mc_node, Xmldom.makeNode(item_elmt));
	   	    item_text := Xmldom.createTextNode(G_XML, Xx_N_Utils_Pkg.GetDispHours(p_sum_mc.G_DYZUR));
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
		END IF;

 		IF p_sum_mc.D_DYZUR IS NOT NULL THEN
   	    	item_elmt := Xmldom.createElement(G_XML, G_SUM_MC_D_GD);
  			item_node := Xmldom.appendChild(mc_node, Xmldom.makeNode(item_elmt));
	   	    item_text := Xmldom.createTextNode(G_XML, p_sum_mc.D_DYZUR);
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 		END IF;

		-- SUMA - godziny nocne
 		IF NOT NVL(p_sum_mc.G_NOC,0) = 0 THEN
   	        item_elmt := Xmldom.createElement(G_XML, G_SUM_MC_NC);
  		    item_node := Xmldom.appendChild(mc_node, Xmldom.makeNode(item_elmt));
	   	    item_text := Xmldom.createTextNode(G_XML, Xx_N_Utils_Pkg.GetDispHours(p_sum_mc.G_NOC));
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
		END IF;

 		IF p_sum_mc.D_NOC IS NOT NULL THEN
   	    	item_elmt := Xmldom.createElement(G_XML, G_SUM_MC_D_NC);
  			item_node := Xmldom.appendChild(mc_node, Xmldom.makeNode(item_elmt));
	   	    item_text := Xmldom.createTextNode(G_XML, p_sum_mc.D_NOC);
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 		END IF;

		-- SUMA - absencje
		x_abs :=  p_sum_mc.G_ABS.FIRST;
		WHILE x_abs IS NOT NULL LOOP
			-- SUMA - godziny absencji
   	    	item_elmt := Xmldom.createElement(G_XML, G_SUM_MC_ABS_G || x_abs);
  			item_node := Xmldom.appendChild(mc_node, Xmldom.makeNode(item_elmt));
 			IF NOT NVL(p_sum_mc.G_ABS(x_abs),0) = 0 THEN
	   	        item_text := Xmldom.createTextNode(G_XML, Xx_N_Utils_Pkg.GetDispHours(p_sum_mc.G_ABS(x_abs)));
	   	   		item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 			END IF;

			-- SUMA - dni absencji
   	    	item_elmt := Xmldom.createElement(G_XML, G_SUM_MC_ABS_D || x_abs);
  			item_node := Xmldom.appendChild(mc_node, Xmldom.makeNode(item_elmt));
 			IF NOT NVL(p_sum_mc.G_ABS(x_abs),0) = 0 THEN
	   	        item_text := Xmldom.createTextNode(G_XML, p_sum_mc.D_ABS(x_abs));
	   	   		item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 			END IF;

			x_abs := p_sum_mc.G_ABS.NEXT(x_abs);
		END LOOP;

        day_elmt := Xmldom.createElement(G_XML, G_DAY_LIST);
		day_node := Xmldom.appendChild(mc_node, Xmldom.makeNode(day_elmt));

		RETURN day_node;
	END;

	----------------------------------------------------------------------------
	-- Funkcja tworzy nowa galaz dla dni <DAY>						      	  --
	----------------------------------------------------------------------------
	FUNCTION CreateDayNode(p_mc_node	Xmldom.DOMNode,
			 			   p_day_idx	NUMBER,
			  			   p_day		R_DAY) RETURN Xmldom.DOMNode
	IS
		day_node 	Xmldom.DOMNode;	  	-- <DAY>
		day_elmt 	Xmldom.DOMElement;

		item_node 	Xmldom.DOMNode;	  	-- szczegly roznych znacznikow
		item_elmt 	Xmldom.DOMElement;
  		item_text 	Xmldom.DOMText;

		x_abs 		VARCHAR2(40);
	BEGIN
   	    day_elmt := Xmldom.createElement(G_XML, G_DAY);
		Xmldom.setAttribute(day_elmt, 'width', 1); 	   -- szerokosc kolumny dzien dla karty rocznej

   		day_node := Xmldom.appendChild(p_mc_node, Xmldom.makeNode(day_elmt));

		-- day_number
 		IF p_day_idx IS NOT NULL THEN
   	        item_elmt := Xmldom.createElement(G_XML, G_DAY_NR);
  			item_node := Xmldom.appendChild(day_node, Xmldom.makeNode(item_elmt));
	   	    item_text := Xmldom.createTextNode(G_XML, p_day_idx);
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 		END IF;

		-- holy
 		IF p_day.HOLY IS NOT NULL THEN
   	        item_elmt := Xmldom.createElement(G_XML, G_DAY_HOLY);
  			item_node := Xmldom.appendChild(day_node, Xmldom.makeNode(item_elmt));
	   	    item_text := Xmldom.createTextNode(G_XML, p_day.HOLY);
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 		END IF;

		-- day type
 		IF p_day.DAY_TYPE IS NOT NULL THEN
   	        item_elmt := Xmldom.createElement(G_XML, G_DAY_TYPE);
  			item_node := Xmldom.appendChild(day_node, Xmldom.makeNode(item_elmt));
	   	    item_text := Xmldom.createTextNode(G_XML, p_day.DAY_TYPE);
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 		END IF;

		-- abs type
 		IF p_day.ABS_TYPE IS NOT NULL THEN
   	        item_elmt := Xmldom.createElement(G_XML, G_ABS_TYPE);
  			item_node := Xmldom.appendChild(day_node, Xmldom.makeNode(item_elmt));
	   	    item_text := Xmldom.createTextNode(G_XML, p_day.ABS_TYPE);
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 		END IF;

		-- abs disp
 		IF p_day.ABS_DISP IS NOT NULL THEN
   	        item_elmt := Xmldom.createElement(G_XML, G_ABS_DISP_TYPE);
  			item_node := Xmldom.appendChild(day_node, Xmldom.makeNode(item_elmt));
	   	    item_text := Xmldom.createTextNode(G_XML, p_day.ABS_DISP);
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 		END IF;

		-- nominalny czas pracy
 		IF p_day.G_NCP IS NOT NULL THEN
   	        item_elmt := Xmldom.createElement(G_XML, G_DAY_NCP);
  			item_node := Xmldom.appendChild(day_node, Xmldom.makeNode(item_elmt));
	   	    item_text := Xmldom.createTextNode(G_XML, Xx_N_Utils_Pkg.GetDispHours(p_day.G_NCP));
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 		END IF;

		-- faktyczny czas pracy
 		IF p_day.G_FCP IS NOT NULL THEN
 		  	item_elmt := Xmldom.createElement(G_XML, G_DAY_FCP);
  			item_node := Xmldom.appendChild(day_node, Xmldom.makeNode(item_elmt));
	   	    item_text := Xmldom.createTextNode(G_XML, Xx_N_Utils_Pkg.GetDispHours(p_day.G_FCP));
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 		END IF;

		-- godziny nadliczbowe
 		IF p_day.G_NADLICZ IS NOT NULL THEN
   	        item_elmt := Xmldom.createElement(G_XML, G_DAY_GN);
  			item_node := Xmldom.appendChild(day_node, Xmldom.makeNode(item_elmt));
	   	    item_text := Xmldom.createTextNode(G_XML, Xx_N_Utils_Pkg.GetDispHours(p_day.G_NADLICZ));
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 		END IF;

		-- godziny dyzuru
 		IF p_day.G_DYZUR IS NOT NULL THEN
   	       	item_elmt := Xmldom.createElement(G_XML, G_DAY_GD);
  			item_node := Xmldom.appendChild(day_node, Xmldom.makeNode(item_elmt));
	   	    item_text := Xmldom.createTextNode(G_XML, Xx_N_Utils_Pkg.GetDispHours(p_day.G_DYZUR));
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 		END IF;

		-- godziny nocne
 		IF p_day.G_NOC IS NOT NULL THEN
   	        item_elmt := Xmldom.createElement(G_XML, G_DAY_NC);
  			item_node := Xmldom.appendChild(day_node, Xmldom.makeNode(item_elmt));
	   	    item_text := Xmldom.createTextNode(G_XML, Xx_N_Utils_Pkg.GetDispHours(p_day.G_NOC));
	   	   	item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 		END IF;

		-- absencje
		x_abs :=  p_day.G_ABS.FIRST;
		WHILE x_abs IS NOT NULL LOOP
			-- godziny absencji
   	    	item_elmt := Xmldom.createElement(G_XML, 'G_' || x_abs);
  			item_node := Xmldom.appendChild(day_node, Xmldom.makeNode(item_elmt));
 			IF NOT NVL(p_day.G_ABS(x_abs),0) = 0 THEN
	   	        item_text := Xmldom.createTextNode(G_XML, Xx_N_Utils_Pkg.GetDispHours(p_day.G_ABS(x_abs)));
	   	   		item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 			END IF;

			-- dni absencji
   	    	item_elmt := Xmldom.createElement(G_XML, 'D_' || x_abs);
  			item_node := Xmldom.appendChild(day_node, Xmldom.makeNode(item_elmt));
 			IF NOT NVL(p_day.G_ABS(x_abs),0) = 0 THEN
	   	        item_text := Xmldom.createTextNode(G_XML, p_day.D_ABS(x_abs));
	   	   		item_node := Xmldom.appendChild(item_node, Xmldom.makeNode(item_text));
 			END IF;

			x_abs := p_day.G_ABS.NEXT(x_abs);
		END LOOP;

		RETURN NULL;
	END;


	----------------------------------------------------------------------------
	-- Procedura zapisuje przetworzone informacje do XML-a				      --
	----------------------------------------------------------------------------
	PROCEDURE CreateAllNodes(p_date DATE,
			  				 p_mode VARCHAR2)									-- N - szczegoly, Y - tylko sumy
	IS
	  	emp_list 	Xmldom.DOMNodeList;
		emp_node	Xmldom.DOMNode;	   -- <EMP_LIST>

		per_node	Xmldom.DOMNode;	   -- <ASS_LIST>
		ass_node	Xmldom.DOMNode;	   -- <MC_LIST>
		mc_node		Xmldom.DOMNode;	   -- <DAY_LIST>
		day_node	Xmldom.DOMNode;	   -- NULL

		x_per_id	NUMBER;
		x_ass_id	NUMBER;
		x_mc_idx	NUMBER;
		x_day_idx	NUMBER;
	BEGIN
		emp_list := Xmldom.getElementsByTagName(G_XML,G_EMP_LIST);
		emp_node := Xmldom.item(emp_list, 0);

		-- osoby
		x_per_id := G_KCP.FIRST;
		WHILE x_per_id IS NOT NULL LOOP
			per_node := CreatePerNode(emp_node,
						  			  x_per_id,
						  			  p_date,
									  G_SUMS_PER(x_per_id));

			-- przydzialy
			x_ass_id := G_KCP(x_per_id).FIRST;
			WHILE x_ass_id IS NOT NULL LOOP
				ass_node := CreateAssNode(per_node,
						  			  	  x_ass_id,
						  			  	  p_date,
										  G_SUMS_ASS(x_per_id)(x_ass_id));

				-- miesiace
				x_mc_idx := G_KCP(x_per_id)(x_ass_id).FIRST;
				WHILE x_mc_idx IS NOT NULL LOOP
					mc_node := CreateMcNode(ass_node,
						  			  		x_mc_idx,
											G_SUMS_MC(x_per_id)(x_ass_id)(x_mc_idx));

					-- dni
					IF p_mode = 'N' THEN
					    x_day_idx := G_KCP(x_per_id)(x_ass_id)(x_mc_idx).FIRST;
						WHILE x_day_idx IS NOT NULL LOOP
							day_node := CreateDayNode(mc_node,
								 				  	  x_day_idx,
						  			  			  	  G_KCP(x_per_id)(x_ass_id)(x_mc_idx)(x_day_idx));

							x_day_idx := G_KCP(x_per_id)(x_ass_id)(x_mc_idx).NEXT(x_day_idx);
						END LOOP;
					END IF;

					x_mc_idx := G_KCP(x_per_id)(x_ass_id).NEXT(x_mc_idx);
				END LOOP;

				x_ass_id := G_KCP(x_per_id).NEXT(x_ass_id);
			END LOOP;

			x_per_id := G_KCP.NEXT(x_per_id);
		END LOOP;
	END;

	----------------------------------------------------------------------------
	-- Procedura wyliczajaca godziny do KCP dla danego przydzialu w dniu 	  --
	-- Tylko w trybie NEW zapamietujemy dane		   			  			  --
	----------------------------------------------------------------------------
	PROCEDURE CalculateDayHours(p_person_id 	NUMBER,
			  				 	p_dest_ass_id	NUMBER,
								p_src_ass_id	NUMBER,
								p_month_idx		NUMBER,
								p_day_idx		NUMBER,
							 	p_day		 	DATE,
								p_level			VARCHAR2,	-- PER/ASS
								p_mode			VARCHAR2) 	-- NEW/SUM
	IS
	    x_cal_id 	NUMBER;
		x_cal_name	VARCHAR2(240);
		x_cal_level VARCHAR2(3);
		x_dim		NUMBER;

		x_licz		NUMBER;
		x_mian		NUMBER;
		x_day_type	VARCHAR2(1);

		PROCEDURE CalcDayH
		IS
		BEGIN
		    IF p_level = 'PER' THEN
			    -- jesli zbieramy czas pracy na poziomie osoby to sprawdzamy
				-- z wymiarem etatu
			    x_dim := Hr_Pl_Pto.hr_pl_pto_wymiar_etatu(p_src_ass_id,
											 			  p_day,
											 			  x_licz,
											 			  x_mian,
											 			  p_level);
			ELSE
				-- jesli kalendarzjest na przydziale to nie uwzgledniamy wymiaru etatu
				x_dim := 1;	  -- jesli kalendarz jest na przydziale
			END IF;

		    x_cal_id := Xx_N_Utils_Pkg.GetCalendar(p_person_id, p_src_ass_id, p_day, x_cal_name, x_cal_level);

		    G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(p_day_idx).HOLY := 'N';
		    G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(p_day_idx).DAY_TYPE := 'A';

			IF x_cal_id IS NOT NULL THEN
		        G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(p_day_idx).HOLY := Xx_N_Utils_Pkg.IsHoly(x_cal_id, p_day);
		    	G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(p_day_idx).DAY_TYPE := Xx_N_Utils_Pkg.GetDayType(x_cal_id, p_day);
		    	G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(p_day_idx).G_NCP := Xx_N_Utils_Pkg.GetCalHours4Day(x_cal_id, p_day) * x_dim;
				G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(p_day_idx).G_FCP := G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(p_day_idx).G_NCP;
				G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(p_day_idx).D_NCP := 1;
				G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(p_day_idx).D_FCP := 1;

				IF G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(p_day_idx).G_NCP=0 THEN
			       G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(p_day_idx).G_NCP := NULL;
			       G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(p_day_idx).D_NCP := NULL;
				END IF;
				IF G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(p_day_idx).G_FCP=0 THEN
			       G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(p_day_idx).G_FCP := NULL;
			       G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(p_day_idx).D_FCP := NULL;
				END IF;
			ELSE
				-- nie ma kalendarza na dany dzien
		    	G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(p_day_idx).HOLY := 'N';
		    	G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(p_day_idx).DAY_TYPE := 'N';
			END IF;
		END;

	BEGIN
		IF p_mode = 'NEW' THEN
		    CalcDayH;
		ELSIF p_mode = 'SUM' THEN
			-- tryb SUM - tylko jesli nie zostaly jeszcze zainicjowane dni dla innego przydzialu pracownika
			BEGIN
				x_day_type := G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(p_day_idx).DAY_TYPE;
			EXCEPTION
				WHEN OTHERS THEN
					-- jesli nie byl dzien wypelniony to trzeba wypelnic
					CalcDayH;
			END;
		ELSE
			-- inne nie sa obslugiwane
			NULL;
		END IF;
	END;

	----------------------------------------------------------------------------
	-- Procedura wyliczajaca godziny z rejstracji nadgodzin i dyzurów do KCP  --
	-- dla danego przydzialu w miesiacu 		  			  		  	 	  --
	----------------------------------------------------------------------------
	PROCEDURE CalculateMonthNHours(p_person_id	 NUMBER,
			  					   p_src_ass_id	 NUMBER,
								   p_dest_ass_id NUMBER,
								   p_month_idx	 NUMBER,
							 	   p_month		 DATE,
								   p_mode		 VARCHAR2)		-- NEW/SUM
	IS
	    x_cal_id 	NUMBER;
		x_cal_name	VARCHAR2(240);
		x_cal_level VARCHAR2(3);

		CURSOR c_month(cp_ass_id NUMBER, cp_month DATE) IS
			 SELECT TO_NUMBER(TO_CHAR(xawh.DAY,'DD')) DAY,
			 		DECODE(xawh.hour_type,'GD','GD','GN','GN','NG') kcp_type,
					SUM(xawh.hours) hours_sum
			   FROM xxkip_ass_working_hours xawh
			  WHERE xawh.assignment_id = cp_ass_id
			    AND xawh.hour_type NOT IN ('ON')   							 -- oprócz typu odbiór nadgodzin
			    AND xawh.DAY BETWEEN TRUNC(cp_month,'MM') AND LAST_DAY(cp_month)
			  GROUP BY xawh.DAY, DECODE(xawh.hour_type,'GD','GD','GN','GN','NG');
	BEGIN
		-- zarowno dla trybu NEW i SUM obsluga jest identyczna

		FOR v_month IN c_month(p_src_ass_id, p_month) LOOP
			BEGIN
				IF v_month.kcp_type = 'NG' THEN
			        G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(v_month.DAY).G_NADLICZ := NVL(G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(v_month.DAY).G_NADLICZ,0) + v_month.hours_sum;
				ELSIF v_month.kcp_type = 'GD' THEN
			    	G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(v_month.DAY).G_DYZUR := NVL(G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(v_month.DAY).G_DYZUR,0) + v_month.hours_sum;
				ELSIF v_month.kcp_type = 'GN' THEN
			    	G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(v_month.DAY).G_NOC := NVL(G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(v_month.DAY).G_NOC,0) + v_month.hours_sum;
				END IF;

				-- faktyczny czas pracy
				G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(v_month.DAY).G_FCP := NVL(G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(v_month.DAY).G_FCP,0) + v_month.hours_sum;

			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					IF v_month.kcp_type = 'NG' THEN
			            G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(v_month.DAY).G_NADLICZ := v_month.hours_sum;
					ELSIF v_month.kcp_type = 'GD' THEN
			    		G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(v_month.DAY).G_DYZUR := v_month.hours_sum;
					ELSIF v_month.kcp_type = 'GN' THEN
			    		G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(v_month.DAY).G_NOC := v_month.hours_sum;
					END IF;

					IF G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(v_month.DAY).G_FCP IS NULL THEN
					    G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(v_month.DAY).G_FCP := v_month.hours_sum;
					END IF;
			END;
		END LOOP;
	END;


	----------------------------------------------------------------------------
	-- Procedura wyliczajaca godziny absencji do KCP dla danego przydzialu w  --
	-- miesiacu 		  			  		  	 	  	 				   	  --
	----------------------------------------------------------------------------
	PROCEDURE CalculateMonthAbsHours(p_person_id	NUMBER,
			  						 p_src_ass_id	NUMBER,
			  					  	 p_dest_ass_id 	NUMBER,
								  	 p_month_idx	NUMBER,
							 	  	 p_month		DATE,
									 p_level		VARCHAR2,	-- PER/ASS
									 p_mode			VARCHAR2) 	-- NEW/SUM
	IS
	    x_cal_id 	NUMBER;
		x_cal_name	VARCHAR2(240);
		x_cal_level VARCHAR2(3);

		x_abs_hours NUMBER;		-- godziny absencji - calej
		x_hours 	NUMBER;		-- godziny absencji - jeden dzien
		x_date		DATE;

		CURSOR c_abs(cp_person_id NUMBER, cp_month DATE) IS
            SELECT TO_NUMBER(TO_CHAR(GREATEST(date_start, TRUNC(cp_month,'MM')),'DD')) day_start,
            	   TO_NUMBER(TO_CHAR(LEAST(date_end, LAST_DAY(cp_month)),'DD')) day_to,
            	   paa.absence_hours,
            	   paa.absence_days,
				   paa.time_start,
				   paa.time_end,
            	   xnkamv.kcp_abs_type,
            	   xnkamv.kcp_disp_code,
				   absence_attendance_id abs_id
              FROM per_absence_attendances paa,
              	   xx_n_kcp_abs_map_v xnkamv
             WHERE paa.person_id = cp_person_id
               AND xnkamv.abs_type_id = paa.absence_attendance_type_id
               AND NVL(xnkamv.abs_reason_id, NVL(paa.abs_attendance_reason_id,-1)) = NVL(paa.abs_attendance_reason_id,-1)
               AND cp_month BETWEEN TRUNC(date_start,'MM') AND LAST_DAY( date_end)
               AND cp_month BETWEEN xnkamv.date_from AND xnkamv.date_to;

		-- korekty absencji
		CURSOR c_corr(cp_abs_id NUMBER, cp_month DATE) IS
			SELECT TO_NUMBER(TO_CHAR(GREATEST(date_start, TRUNC(cp_month,'MM')),'DD')) day_start,
            	   TO_NUMBER(TO_CHAR(LEAST(date_end, LAST_DAY(cp_month)),'DD')) day_to
			  FROM per_absence_attendances
			 WHERE attribute3 = cp_abs_id;

	BEGIN
		-- obsluga tylko trybu NEW, tryb SUM nie jest obslugiowany gdyz nieobecnosci sa na poziomie osoby
		IF p_mode = 'NEW' THEN
		    FOR v_abs IN c_abs(p_person_id, p_month) LOOP
				IF v_abs.absence_days IS NOT NULL THEN
			        -- absencje w dniach
			    	FOR x_day_idx IN v_abs.day_start .. v_abs.day_to LOOP
						x_date := TO_DATE(TO_CHAR(p_month,'YYYY-MM') || '-' || x_day_idx,'YYYY-MM-DD');

						-- jesli dzien jest roboczy to absencja jest widoczna w wykazie
						IF G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(x_day_idx).DAY_TYPE = 'R' THEN
						    G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(x_day_idx).G_ABS(v_abs.kcp_abs_type) := G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(x_day_idx).G_NCP;
							G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(x_day_idx).D_ABS(v_abs.kcp_abs_type) := 1;
							G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(x_day_idx).ABS_TYPE := v_abs.kcp_abs_type;
							G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(x_day_idx).ABS_DISP := v_abs.kcp_disp_code;
							G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(x_day_idx).G_FCP := 0;
							G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(x_day_idx).D_FCP := 0;
						END IF;
					END LOOP;
				ELSIF v_abs.absence_hours IS NOT NULL THEN
					-- absencje w godzinach
					x_abs_hours := v_abs.absence_hours;
			    	FOR x_day_idx IN v_abs.day_start .. v_abs.day_to LOOP
						x_date := TO_DATE(TO_CHAR(p_month,'YYYY-MM') || '-' || x_day_idx,'YYYY-MM-DD');

		    			x_cal_id := Xx_N_Utils_Pkg.GetCalendar(p_person_id, p_src_ass_id, x_date, x_cal_name, x_cal_level);
						x_hours := Xx_N_Utils_Pkg.CalcPeriodHours(x_cal_id,
								   						   		  x_date,
								   						   		  v_abs.time_start,
														   		  v_abs.time_end);

						-- jesli dzien jest roboczy to absencja jest widoczna w wykazie
						IF G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(x_day_idx).DAY_TYPE = 'R' THEN
						    G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(x_day_idx).G_ABS(v_abs.kcp_abs_type) := x_hours;
							G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(x_day_idx).ABS_TYPE := v_abs.kcp_abs_type;
							G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(x_day_idx).ABS_DISP := v_abs.kcp_disp_code;
							G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(x_day_idx).G_FCP := GREATEST(0, G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(x_day_idx).G_FCP - x_hours);
							IF x_hours = G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(x_day_idx).G_NCP THEN
						        G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(x_day_idx).D_ABS(v_abs.kcp_abs_type) := 1;
							    G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(x_day_idx).D_FCP := 0;
							ELSE
						    	G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(x_day_idx).D_ABS(v_abs.kcp_abs_type) := 0;
								G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(x_day_idx).D_FCP := 1;
							END IF;
						END IF;
					END LOOP;

				END IF;

				-- korekty
	    		FOR v_corr IN c_corr(v_abs.abs_id, p_month) LOOP
		    		FOR x_day IN v_corr.day_start .. v_corr.day_to LOOP
						G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(x_day).G_FCP := G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(x_day).G_NCP;
						G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(x_day).D_FCP := G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(x_day).D_NCP;
						G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(x_day).ABS_TYPE := NULL;
						G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(x_day).ABS_DISP := NULL;
						G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(x_day).G_ABS(v_abs.kcp_abs_type) := NULL;
						G_KCP(p_person_id)(p_dest_ass_id)(p_month_idx)(x_day).D_ABS(v_abs.kcp_abs_type) := NULL;
					END LOOP;
				END LOOP;
			END LOOP;
		END IF;
	END;

	----------------------------------------------------------------------------
	-- Procedura sumuje dni dla miesiaca									  --
	----------------------------------------------------------------------------
	PROCEDURE SumDay4Mc(p_per_id 	 NUMBER,
			  		    p_ass_id	 NUMBER,
					    p_mc_idx 	 NUMBER,
					    p_day_idx	 NUMBER)
	IS
	    x_abs		VARCHAR2(40);
	BEGIN
		-- sumowanie dla miesiecy
		BEGIN
		    G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).G_NCP := NVL(G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).G_NCP,0) + NVL(G_KCP(p_per_id)(p_ass_id)(p_mc_idx)(p_day_idx).G_NCP,0);
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
		    	G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).G_NCP := G_KCP(p_per_id)(p_ass_id)(p_mc_idx)(p_day_idx).G_NCP;
		END;

		-- sumowanie pozostalych
		G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).G_FCP := NVL(G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).G_FCP,0) + NVL(G_KCP(p_per_id)(p_ass_id)(p_mc_idx)(p_day_idx).G_FCP,0);
		G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).G_NADLICZ := NVL(G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).G_NADLICZ,0) + NVL(G_KCP(p_per_id)(p_ass_id)(p_mc_idx)(p_day_idx).G_NADLICZ,0);
		G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).G_DYZUR := NVL(G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).G_DYZUR,0) + NVL(G_KCP(p_per_id)(p_ass_id)(p_mc_idx)(p_day_idx).G_DYZUR,0);
		G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).G_NOC := NVL(G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).G_NOC,0) + NVL(G_KCP(p_per_id)(p_ass_id)(p_mc_idx)(p_day_idx).G_NOC,0);

		G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).D_NCP := NVL(G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).D_NCP,0) + NVL(G_KCP(p_per_id)(p_ass_id)(p_mc_idx)(p_day_idx).D_NCP,0);
		G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).D_FCP := NVL(G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).D_FCP,0) + NVL(G_KCP(p_per_id)(p_ass_id)(p_mc_idx)(p_day_idx).D_FCP,0);
		G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).D_NADLICZ := NVL(G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).D_NADLICZ,0) + NVL(G_KCP(p_per_id)(p_ass_id)(p_mc_idx)(p_day_idx).D_NADLICZ,0);
		G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).D_DYZUR := NVL(G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).D_DYZUR,0) + NVL(G_KCP(p_per_id)(p_ass_id)(p_mc_idx)(p_day_idx).D_DYZUR,0);
		G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).D_NOC := NVL(G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).D_NOC,0) + NVL(G_KCP(p_per_id)(p_ass_id)(p_mc_idx)(p_day_idx).D_NOC,0);

		-- sumowanie absencji
		x_abs :=  G_KCP(p_per_id)(p_ass_id)(p_mc_idx)(p_day_idx).G_ABS.FIRST;
		WHILE x_abs IS NOT NULL LOOP
			-- godziny absencji
			BEGIN
				G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).G_ABS(x_abs) := NVL(G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).G_ABS(x_abs),0) + NVL(G_KCP(p_per_id)(p_ass_id)(p_mc_idx)(p_day_idx).G_ABS(x_abs),0);
				G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).D_ABS(x_abs) := NVL(G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).D_ABS(x_abs),0) + NVL(G_KCP(p_per_id)(p_ass_id)(p_mc_idx)(p_day_idx).D_ABS(x_abs),0);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).G_ABS(x_abs) := NVL(G_KCP(p_per_id)(p_ass_id)(p_mc_idx)(p_day_idx).G_ABS(x_abs),0);
					G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).D_ABS(x_abs) := NVL(G_KCP(p_per_id)(p_ass_id)(p_mc_idx)(p_day_idx).D_ABS(x_abs),0);
			END;

			x_abs := G_KCP(p_per_id)(p_ass_id)(p_mc_idx)(p_day_idx).G_ABS.NEXT(x_abs);
		END LOOP;
	END;


	----------------------------------------------------------------------------
	-- Procedura sumuje miesiace dla przydzialu								  --
	----------------------------------------------------------------------------
	PROCEDURE SumMc4Ass(p_per_id 	 NUMBER,
			  		    p_ass_id	 NUMBER,
					    p_mc_idx 	 NUMBER)
	IS
	    x_abs		VARCHAR2(40);
	BEGIN
		-- sumowanie dla przydzialu
		BEGIN
		    G_SUMS_ASS(p_per_id)(p_ass_id).G_NCP := NVL(G_SUMS_ASS(p_per_id)(p_ass_id).G_NCP,0) + NVL(G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).G_NCP,0);
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
		    	G_SUMS_ASS(p_per_id)(p_ass_id).G_NCP := G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).G_NCP;
		END;

		-- sumowanie pozostalych
		G_SUMS_ASS(p_per_id)(p_ass_id).G_FCP := NVL(G_SUMS_ASS(p_per_id)(p_ass_id).G_FCP,0) + NVL(G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).G_FCP,0);
		G_SUMS_ASS(p_per_id)(p_ass_id).G_NADLICZ := NVL(G_SUMS_ASS(p_per_id)(p_ass_id).G_NADLICZ,0) + NVL(G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).G_NADLICZ,0);
		G_SUMS_ASS(p_per_id)(p_ass_id).G_DYZUR := NVL(G_SUMS_ASS(p_per_id)(p_ass_id).G_DYZUR,0) + NVL(G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).G_DYZUR,0);
		G_SUMS_ASS(p_per_id)(p_ass_id).G_NOC := NVL(G_SUMS_ASS(p_per_id)(p_ass_id).G_NOC,0) + NVL(G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).G_NOC,0);

		G_SUMS_ASS(p_per_id)(p_ass_id).D_NCP := NVL(G_SUMS_ASS(p_per_id)(p_ass_id).D_NCP,0) + NVL(G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).D_NCP,0);
		G_SUMS_ASS(p_per_id)(p_ass_id).D_FCP := NVL(G_SUMS_ASS(p_per_id)(p_ass_id).D_FCP,0) + NVL(G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).D_FCP,0);
		G_SUMS_ASS(p_per_id)(p_ass_id).D_NADLICZ := NVL(G_SUMS_ASS(p_per_id)(p_ass_id).D_NADLICZ,0) + NVL(G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).D_NADLICZ,0);
		G_SUMS_ASS(p_per_id)(p_ass_id).D_DYZUR := NVL(G_SUMS_ASS(p_per_id)(p_ass_id).D_DYZUR,0) + NVL(G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).D_DYZUR,0);
		G_SUMS_ASS(p_per_id)(p_ass_id).D_NOC := NVL(G_SUMS_ASS(p_per_id)(p_ass_id).D_NOC,0) + NVL(G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).D_NOC,0);

		-- sumowanie absencji
		x_abs :=  G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).G_ABS.FIRST;
		WHILE x_abs IS NOT NULL LOOP
			-- godziny absencji
			BEGIN
				G_SUMS_ASS(p_per_id)(p_ass_id).G_ABS(x_abs) := NVL(G_SUMS_ASS(p_per_id)(p_ass_id).G_ABS(x_abs),0) + NVL(G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).G_ABS(x_abs),0);
				G_SUMS_ASS(p_per_id)(p_ass_id).D_ABS(x_abs) := NVL(G_SUMS_ASS(p_per_id)(p_ass_id).D_ABS(x_abs),0) + NVL(G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).D_ABS(x_abs),0);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					G_SUMS_ASS(p_per_id)(p_ass_id).G_ABS(x_abs) := NVL(G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).G_ABS(x_abs),0);
					G_SUMS_ASS(p_per_id)(p_ass_id).D_ABS(x_abs) := NVL(G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).D_ABS(x_abs),0);
			END;

			x_abs := G_SUMS_MC(p_per_id)(p_ass_id)(p_mc_idx).G_ABS.NEXT(x_abs);
		END LOOP;
	END;


	----------------------------------------------------------------------------
	-- Procedura sumuje przydzialy dla osoby								  --
	----------------------------------------------------------------------------
	PROCEDURE SumAss4Per(p_per_id 	 NUMBER,
			  		     p_ass_id	 NUMBER)
	IS
	    x_abs		VARCHAR2(40);
	BEGIN
		-- sumowanie dla przydzialu
		BEGIN
		    G_SUMS_PER(p_per_id).G_NCP := NVL(G_SUMS_PER(p_per_id).G_NCP,0) + NVL(G_SUMS_ASS(p_per_id)(p_ass_id).G_NCP,0);
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
		    	G_SUMS_PER(p_per_id).G_NCP := G_SUMS_ASS(p_per_id)(p_ass_id).G_NCP;
		END;

		-- sumowanie pozostalych
		G_SUMS_PER(p_per_id).G_FCP := NVL(G_SUMS_PER(p_per_id).G_FCP,0) + NVL(G_SUMS_ASS(p_per_id)(p_ass_id).G_FCP,0);
		G_SUMS_PER(p_per_id).G_NADLICZ := NVL(G_SUMS_PER(p_per_id).G_NADLICZ,0) + NVL(G_SUMS_ASS(p_per_id)(p_ass_id).G_NADLICZ,0);
		G_SUMS_PER(p_per_id).G_DYZUR := NVL(G_SUMS_PER(p_per_id).G_DYZUR,0) + NVL(G_SUMS_ASS(p_per_id)(p_ass_id).G_DYZUR,0);
		G_SUMS_PER(p_per_id).G_NOC := NVL(G_SUMS_PER(p_per_id).G_NOC,0) + NVL(G_SUMS_ASS(p_per_id)(p_ass_id).G_NOC,0);

		G_SUMS_PER(p_per_id).D_NCP := NVL(G_SUMS_PER(p_per_id).D_NCP,0) + NVL(G_SUMS_ASS(p_per_id)(p_ass_id).D_NCP,0);
		G_SUMS_PER(p_per_id).D_FCP := NVL(G_SUMS_PER(p_per_id).D_FCP,0) + NVL(G_SUMS_ASS(p_per_id)(p_ass_id).D_FCP,0);
		G_SUMS_PER(p_per_id).D_NADLICZ := NVL(G_SUMS_PER(p_per_id).D_NADLICZ,0) + NVL(G_SUMS_ASS(p_per_id)(p_ass_id).D_NADLICZ,0);
		G_SUMS_PER(p_per_id).D_DYZUR := NVL(G_SUMS_PER(p_per_id).D_DYZUR,0) + NVL(G_SUMS_ASS(p_per_id)(p_ass_id).D_DYZUR,0);
		G_SUMS_PER(p_per_id).D_NOC := NVL(G_SUMS_PER(p_per_id).D_NOC,0) + NVL(G_SUMS_ASS(p_per_id)(p_ass_id).D_NOC,0);

		-- sumowanie absencji
		x_abs :=  G_SUMS_ASS(p_per_id)(p_ass_id).G_ABS.FIRST;
		WHILE x_abs IS NOT NULL LOOP
			-- godziny absencji
			BEGIN
				G_SUMS_PER(p_per_id).G_ABS(x_abs) := NVL(G_SUMS_PER(p_per_id).G_ABS(x_abs),0) + NVL(G_SUMS_ASS(p_per_id)(p_ass_id).G_ABS(x_abs),0);
				G_SUMS_PER(p_per_id).D_ABS(x_abs) := NVL(G_SUMS_PER(p_per_id).D_ABS(x_abs),0) + NVL(G_SUMS_ASS(p_per_id)(p_ass_id).D_ABS(x_abs),0);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					G_SUMS_PER(p_per_id).G_ABS(x_abs) := NVL(G_SUMS_ASS(p_per_id)(p_ass_id).G_ABS(x_abs),0);
					G_SUMS_PER(p_per_id).D_ABS(x_abs) := NVL(G_SUMS_ASS(p_per_id)(p_ass_id).D_ABS(x_abs),0);
			END;

			x_abs := G_SUMS_ASS(p_per_id)(p_ass_id).G_ABS.NEXT(x_abs);
		END LOOP;
	END;

	----------------------------------------------------------------------------
	-- Procedura wyliczajaca sumy dla poszczegolnych miesiecy				  --
	----------------------------------------------------------------------------
	PROCEDURE CalculateSumsMc
	IS
		x_per_id	NUMBER;
		x_ass_id	NUMBER;
		x_mc_idx	NUMBER;
		x_day_idx	NUMBER;

		x_abs		VARCHAR2(40);
	BEGIN
		-- osoby
		x_per_id := G_KCP.FIRST;
		WHILE x_per_id IS NOT NULL LOOP

			-- przydzialy
			x_ass_id := G_KCP(x_per_id).FIRST;
			WHILE x_ass_id IS NOT NULL LOOP

				-- miesiace
				x_mc_idx := G_KCP(x_per_id)(x_ass_id).FIRST;
				WHILE x_mc_idx IS NOT NULL LOOP

					-- dni
					x_day_idx := G_KCP(x_per_id)(x_ass_id)(x_mc_idx).FIRST;
					WHILE x_day_idx IS NOT NULL LOOP
						SumDay4Mc(x_per_id,
							      x_ass_id,
							      x_mc_idx,
							      x_day_idx);

						x_day_idx := G_KCP(x_per_id)(x_ass_id)(x_mc_idx).NEXT(x_day_idx);
					END LOOP;

					SumMc4Ass(x_per_id,
							  x_ass_id,
							  x_mc_idx);

					x_mc_idx := G_KCP(x_per_id)(x_ass_id).NEXT(x_mc_idx);
				END LOOP;

				SumAss4Per(x_per_id,
						   x_ass_id);

				x_ass_id := G_KCP(x_per_id).NEXT(x_ass_id);
			END LOOP;

			x_per_id := G_KCP.NEXT(x_per_id);
		END LOOP;

	END;

	----------------------------------------------------------------------------
	-- Procedura przetwarzajaca przydzia³y osob	i generujaca XML-a		      --
	----------------------------------------------------------------------------
	PROCEDURE ProcessAss(p_person_id 	NUMBER,
					   	 p_src_ass_id	NUMBER,
						 p_dest_ass_id	NUMBER,
						 p_level	 	VARCHAR2,			-- PER/ASS
						 p_new_per	 	BOOLEAN,
						 p_date_from 	DATE,
						 p_date_to	 	DATE,
						 p_year_mode	VARCHAR2)
	IS
		x_mc		DATE;
		x_day		DATE;
		x_idx_mc	NUMBER;
		x_idx_day	NUMBER;
		x_idx		NUMBER;
		x_mode		VARCHAR2(3); 	 -- NEW nowe, SUM - dosumowanie

	BEGIN
	    IF p_level = 'ASG' THEN
			x_mode := 'NEW';   		 -- nowe dane
		ELSIF p_level = 'PER' THEN
		    IF p_new_per THEN
			    x_mode := 'NEW';  	 -- nowe dane
			ELSE
				x_mode := 'SUM';	 -- suma
			END IF;
		END IF;

		-- petla miesiecy
		x_mc := TRUNC(p_date_from,'MM');
		WHILE x_mc <= p_date_to LOOP
			x_idx_mc := TO_NUMBER(TO_CHAR(x_mc,'YYYY') || LPAD(TO_CHAR(x_mc,'MM'),2,'0'));

			-- jesli przydzial istnieje w systemie i jest jakis kalendarz zdefiniowany to przetwarzamy
			IF AssActive4Month(p_person_id, p_src_ass_id, x_mc) THEN
				Put_Output(G_LOG,' - przetwarzam miesiac : ' || TO_CHAR(x_mc,'MM-YYYY'));

			    -- petla dni
				x_day := x_mc;
				WHILE x_day <= LAST_DAY(x_mc) LOOP
			   		x_idx_day := TO_NUMBER(TO_CHAR(x_day,'DD'));

			   		-- znalezienie danych z kalendarza

			   		CalculateDayHours(p_person_id,
			   					 	  p_dest_ass_id,
									  p_src_ass_id,
								      x_idx_mc,
								 	  x_idx_day,
								 	  x_day,
								 	  p_level,
								 	  x_mode);

			   	   x_day := x_day + 1;
			   END LOOP;

			   -- jesli tryb pracy KCP - roczna - to uzupelniamy do 31 dni (dni nie istniejace maja DAY_TYPE = 'X')
			   IF p_year_mode = 'Y' THEN
			   	   FOR x_idx IN x_idx_day+1 .. 31 LOOP
				   	   G_KCP(p_person_id)(p_dest_ass_id)(x_idx_mc)(x_idx).DAY_TYPE := 'X';
				   END LOOP;
			   END IF;

			   -- zebranie godzin absencji dotyczacych danego miesiaca
			   CalculateMonthAbsHours(p_person_id, p_src_ass_id, p_dest_ass_id, x_idx_mc, x_mc, p_level, x_mode);

			   -- zebranie godzin dotyczacych danego miesiaca z rejestracji nadgodzin i dyzurow
			   CalculateMonthNHours(p_person_id, p_src_ass_id, p_dest_ass_id, x_idx_mc, x_mc, x_mode);
			END IF;

			x_mc := ADD_MONTHS(x_mc,1);
			g_mc_cnt := g_mc_cnt + 1;
		END LOOP;
	END;

	----------------------------------------------------------------------------
	-- Procedura g³owna zlecenia - raportu Karta Czasu Pracy                  --
	----------------------------------------------------------------------------
	PROCEDURE GenerateXML( p_errbuf  OUT NOCOPY VARCHAR2,
        	 			   p_retcode OUT NOCOPY VARCHAR2,
						   p_date_from 	 	    VARCHAR2,
						   p_date_to 	 		VARCHAR2,
						   p_effective_date		VARCHAR2,
						   p_hier_id            NUMBER,
						   p_hier_ver_id        NUMBER,
						   p_org_id             NUMBER,
						   p_person_id          NUMBER,
                           p_ass_id             NUMBER,
                           p_mode               VARCHAR2,
						   p_year_mode			VARCHAR2 DEFAULT 'N')
	IS
	    x_date_from DATE;
		x_date_to	DATE;

		CURSOR c_ass(cp_person_id NUMBER, cp_ass_id NUMBER, cp_hier_ver_id NUMBER, cp_org_id NUMBER, cp_effective_date DATE) IS
   		  	SELECT /*+ RULE */
				   papf.person_id 	    	person_id,
				   paaf.assignment_id		ass_id,
				   papf.full_name			per_name,
				   paaf.assignment_number   ass_number
       		  FROM per_people_f       	 	papf,
			  	   per_all_assignments_f 	paaf,
   			 	   (SELECT hou.organization_id, hou.NAME
                   	  FROM hr_organization_units hou
                  	 WHERE hou.organization_id = NVL(cp_org_id,hou.organization_id)
                 	 UNION ALL
                 	SELECT hou.organization_id, hou.NAME
                   	  FROM (SELECT organization_id_child,
                                   org_structure_version_id
                              FROM per_org_structure_elements pose
                             WHERE pose.org_structure_version_id = cp_hier_ver_id
                        CONNECT BY PRIOR pose.organization_id_child = pose.organization_id_parent
                               AND PRIOR pose.org_structure_version_id = pose.org_structure_version_id
                        START WITH pose.organization_id_parent = cp_org_id
                               AND pose.org_structure_version_id = cp_hier_ver_id
       				 	   ) tree,
                           hr_organization_units hou,
                           per_org_structure_versions posv
                  	 WHERE tree.organization_id_child = hou.organization_id
                       AND posv.org_structure_version_id = tree.org_structure_version_id
                       AND cp_effective_date BETWEEN hou.date_from AND NVL (hou.date_to, Hr_General.end_of_time)) hou
      		 WHERE paaf.person_id = papf.person_id
			   AND cp_org_id IS NOT NULL
			   AND hou.organization_id = paaf.organization_id
        	   AND cp_effective_date BETWEEN papf.effective_start_date AND papf.effective_end_date
        	   AND cp_effective_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date
			 UNION ALL
			SELECT papf.person_id 	    	person_id,
				   paaf.assignment_id		ass_id,
				   papf.full_name			per_name,
				   paaf.assignment_number   ass_number
       		  FROM per_people_f       	 papf,
			  	   per_all_assignments_f paaf
			 WHERE papf.person_id = paaf.person_id
			   AND cp_ass_id IS NOT NULL
			   AND paaf.assignment_id = cp_ass_id
        	   AND cp_effective_date BETWEEN papf.effective_start_date AND papf.effective_end_date
        	   AND cp_effective_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date
			 UNION ALL
			SELECT papf.person_id 	    	person_id,
				   paaf.assignment_id		ass_id,
				   papf.full_name			per_name,
				   paaf.assignment_number   ass_number
       		  FROM per_people_f       	 	papf,
			  	   per_all_assignments_f 	paaf
			 WHERE papf.person_id = paaf.person_id
			   AND cp_person_id IS NOT NULL
			   AND papf.person_id = cp_person_id
        	   AND cp_effective_date BETWEEN papf.effective_start_date AND papf.effective_end_date
        	   AND cp_effective_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date
     		 ORDER BY per_name, ass_number;

		x_ass_id      NUMBER;
		x_org_id 	  NUMBER;
		x_hier_ver_id NUMBER;
		x_person_id	  NUMBER;
		x_str		  VARCHAR2(2000);
		x_idx		  NUMBER :=0;

		x_old_person_id NUMBER;
		x_hier_name		VARCHAR2(240);
		x_org_name		VARCHAR2(240);
		x_per_name		VARCHAR2(240);
		x_ass_num		VARCHAR2(240);
		x_level			VARCHAR2(3);  	   -- poziom przetwarzania osoby PER/ASS
		x_new_per		BOOLEAN;

		x_start_date	DATE;
	BEGIN
		x_start_date := SYSDATE;

		Put_Output(G_LOG,'Pocz¹tek zlecenia PZU - Karta pracy');
		Put_Output(G_LOG,LPAD('-',80,'-'));
		Put_Output(G_LOG,' ');
		Put_Output(g_LOG,'Godzina : ' || TO_CHAR(x_start_date, 'HH24:MI:SS'));

	  	G_ERRORS.DELETE;

	  	g_err_cnt := 0;
		g_ass_cnt := 0;
		g_mc_cnt := 0;

		x_date_from := TRUNC(TO_DATE(p_date_from,'DD-MM-YYYY'),'MM');
		x_date_to := LAST_DAY(TO_DATE(p_date_to,'DD-MM-YYYY'));

		IF MONTHS_BETWEEN(x_date_to, x_date_to) >= 12 THEN
		    RAISE_APPLICATION_ERROR(-20009,'Karte czasu pracy mo¿na zrobiæ tylko za 12 miesiêcy');
		END IF;

		IF p_year_mode = 'Y' AND TO_CHAR(x_date_from, 'YYYY') <> TO_CHAR(x_date_to, 'YYYY') THEN
		    RAISE_APPLICATION_ERROR(-20009,'Roczn¹ karte czasu pracy mo¿na zrobiæ tylko za jeden rok');
		END IF;

		IF x_date_from > x_date_to THEN
		    RAISE_APPLICATION_ERROR(-20009,'Data od póŸniejsza od daty do. Proszê poprawiæ parametry zlecenia');
		END IF;

		IF p_org_id IS NULL AND p_person_id IS NULL AND p_ass_id IS NULL THEN
		    RAISE_APPLICATION_ERROR(-20009,'Jeden z parametrów Przydzia³/Osoba/Jednostka organizacyjna musi byæ podany');
		END IF;

		x_hier_name := Xx_N_Class_Pkg.GetOrgHierName(p_hier_id);
		x_org_name := Hr_General.decode_organization(p_org_id);

		BEGIN
			x_per_name := Xx_N_Class_Pkg.GetPersonName(p_person_id,NULL,x_date_to);
			x_ass_num := Xx_N_Class_Pkg.GetAssNumber(p_ass_id,x_date_to);
		EXCEPTION
			WHEN OTHERS THEN
			    RAISE_APPLICATION_ERROR(-20009,'Osoba/przydzia³ nie istnieje na datê do : ' || TO_CHAR(x_date_to));
		END;

		Put_Output(G_LOG,'Parametry');
		Put_Output(G_LOG,LPAD('-',40,'-'));
		Put_Output(G_LOG,'Data pocz¹tku               : ' || TO_CHAR(x_date_from,'DD-MM-YYYY'));
		Put_Output(G_LOG,'Data koñca                  : ' || TO_CHAR(x_date_to,'DD-MM-YYYY'));
		Put_Output(G_LOG,'Hierarchia organizacyjna    : ' || x_hier_name);
		Put_Output(G_LOG,'Wersja hierarchii           : ' || Xx_N_Class_Pkg.GetOrgHierVer(p_hier_ver_id));
		put_output(G_LOG,'Jednostka organizacyjna     : ' || x_org_name);
		Put_Output(G_LOG,'Osoba                       : ' || x_per_name);
		IF x_ass_num IS NOT NULL THEN
		    Put_Output(G_LOG,'Przydzia³                   : ' || x_ass_num || ' - ' || x_per_name);
		ELSE
		    Put_Output(G_LOG,'Przydzia³                   : ');
		END IF;
		Put_Output(G_LOG,'Czy tylko podsumowanie      : ' || p_mode);
		Put_Output(G_LOG,' ');

	    Put_Output(G_LOG,'Karta czasu pracy zostanie przygotowana dla :');
		IF p_ass_id IS NOT NULL THEN
	        Put_Output(G_LOG,' - przydzia³u : ' || x_ass_num);
			x_ass_id := p_ass_id;
		ELSIF p_person_id IS NOT NULL THEN
	        Put_Output(G_LOG,' - osoby : ' || x_per_name);
			x_person_id := p_person_id;
		ELSIF p_org_id IS NOT NULL THEN
	        Put_Output(G_LOG,' - osób z jednostki organizacyjnej wraz z podleg³ymi ' || x_org_name);
		    x_org_id := p_org_id;
		    x_hier_ver_id := p_hier_ver_id;
		ELSE
			RAISE_APPLICATION_ERROR(-20009,'Nie mo¿na przetworzyæ zlecenia bez podania parametró');
		END IF;

		Put_Output(G_LOG,' ');
		Put_Output(G_LOG,'Pocz¹tek przetwarzania');
		Put_Output(G_LOG,LPAD('-',40,'-'));
		Put_Output(G_LOG,' ');

		-- przetworzenie wszystkich przydzia³ów
		FOR v_ass IN c_ass(x_person_id,
				  	 	   x_ass_id,
						   x_hier_ver_id,
						   x_org_id,
						   x_date_to) LOOP

			-- jesli zaczynamy przetwarzac nowa osobe sprawdzamy czy ma aktywne przydzialy w okresie.
			IF NVL(x_old_person_id,0) <> v_ass.person_id THEN
			    Put_Output(G_LOG,'Przetwarzam osobe : ' || v_ass.per_name);

				x_level := CheckLevel(x_date_from, x_date_to, v_ass.person_id, p_ass_id);  -- p_ass_id jest przekazywany tylko i wylacznie gdy zlecenie robimy na konkrrtny przydzial

				G_PERSON(v_ass.person_id).LEVEL := x_level;

				IF x_level IS NOT NULL THEN
				    Put_Output(G_LOG,' - poziom przetwarzania KCP : ' || x_level);
				ELSE
					Put_Output(G_LOG,' - osoba nie ma aktywnego przydzia³u w podanym okresie. Pomijam ja w dalszym przetwarzaniu.');
				END IF;
				x_new_per := TRUE;
			ELSE
				x_new_per := FALSE;
			END IF;

			-- jesli na osobe to trzeba zadbac by zliczal wszystkie dane tylko na jednym przydziale
			x_ass_id := GetPersonAss(x_level, p_person_id,v_ass.ass_id);

			IF x_level IS NOT NULL THEN
			    Put_Output(G_LOG,' - przetwarzam przydzia³ : ' || v_ass.ass_number);

			    ProcessAss(v_ass.person_id,
						   v_ass.ass_id,   -- src ass_id
					   	   x_ass_id,	   -- dest ass_id
					   	   x_level,
						   x_new_per,
					   	   x_date_from,
					   	   x_date_to,
						   p_year_mode);
			END IF;

			g_ass_cnt := g_ass_cnt + 1;
			x_old_person_id := v_ass.person_id;
		END LOOP;

		-- kalkulacja sum miesiêcznych
		CalculateSumsMc();

		-- wytworzenie XML-a
		StartXMLGen(x_date_from,
					x_date_to,
					x_hier_name,
					x_org_name,
					x_per_name,
					x_ass_num,
					p_mode);

		CreateAllNodes(x_date_to, p_mode);
		FinishXMLGen();

		Put_Output(G_LOG,' ');
		IF g_err_cnt <> 0 THEN
		    Put_Output(G_LOG,'Bledy napotkane');
			Put_Output(G_LOG,LPAD('-',40,'-'));

	  	  	FOR x_idx IN G_ERRORS.FIRST .. G_ERRORS.LAST LOOP
				x_str := ' * ';
				x_str := x_str || RPAD(Xx_N_Class_Pkg.GetPersonName(NULL,G_ERRORS(x_idx).assignment_id,x_date_to),50);
				x_str := x_str || RPAD(Xx_N_Class_Pkg.GetAssNumber(G_ERRORS(x_idx).assignment_id,x_date_to),12);
				x_str := x_str || G_ERRORS(x_idx).errbuf;
				Put_Output(G_LOG,x_str);
			END LOOP;
		END IF;

		Put_Output(G_LOG,'');
		Put_Output(G_LOG,'Podsumowanie');
		Put_Output(G_LOG,LPAD('-',40,'-'));
		Put_Output(G_LOG,'Liczba b³êdów                     : ' || g_err_cnt);
		Put_Output(G_LOG,'Liczba przydzia³ów analizowanych  : ' || g_ass_cnt);
		Put_Output(G_LOG,'Liczba przetworzonych miesiêcy    : ' || g_mc_cnt);

		Put_Output(g_LOG,'Godzina            : ' || TO_CHAR(SYSDATE, 'HH24:MI:SS'));
		Put_Output(g_LOG,'Czas przetwarzania : ' || MOD(ROUND((SYSDATE-x_start_date)*24,0),24) || ':'
						   					  	 || MOD(ROUND((SYSDATE-x_start_date)*24*60,0),60) || ':'
						   					  	 || MOD(ROUND((SYSDATE-x_start_date)*24*3600,0),3600));
		-- dzieleenie przez zero jest tak obsluzone
		BEGIN
			Put_Output(g_LOG,'Miesiacy KCP/s      : ' || TO_CHAR(ROUND(g_mc_cnt/ROUND((SYSDATE-x_start_date)*24*3600,0),3),'FM990D00') || ' rec/s');
		EXCEPTION
			WHEN OTHERS THEN NULL;
		END;

		Put_Output(G_LOG,' ');
		Put_Output(G_LOG,'Koniec zlecenia');
		Put_Output(G_LOG,LPAD('-',80,'-'));

		IF g_err_cnt = 0 THEN
		    p_retcode := '0';
		ELSE
			p_retcode := '2';
		END IF;

	EXCEPTION
		WHEN OTHERS THEN
			p_retcode := '2';
			p_errbuf := 'B£¥D : ' || SQLCODE || ' : ' || SQLERRM;
			Put_Output(G_LOG, p_errbuf);
	END;

END Xx_N_Kcp_Pkg;
/
