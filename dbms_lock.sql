		v_lock_status	NUMBER;
		v_lock_handle 	VARCHAR2(50); -- uchwyt zasobu
		v_lock_name		VARCHAR2(50); -- nazwa uchwytu

		-- lockowanie procesu celem uniemozliwienia wykonania zlecenia w tym samym czasie przez te sam osoby w jednym ORG-u
		FUNCTION LOCK_ON (p_name VARCHAR2) RETURN NUMBER IS
			v_status 		INTEGER;
		BEGIN
			DBMS_LOCK.ALLOCATE_UNIQUE ( lockname      => p_name	, lockhandle   => v_lock_handle  );
			
		  IF v_lock_handle IS NULL THEN -- pobranie uchwytu nie powiod³o siê
				 p_err_text := p_err_text||' Nie uda³o sie przydzieliæ uchwytu !';
				 RETURN -1;
		  ELSE
			    v_status := DBMS_LOCK.REQUEST
			                ( lockhandle        => v_lock_handle --                  IN VARCHAR2,
			                , lockmode          => dbms_lock.x_mode   -- 6:exclusive_mode IN INTEGER DEFAULT x_mode,
			                , timeout           => 0                  --                  IN INTEGER DEFAULT maxwait,
			                , release_on_commit => FALSE              --                  IN BOOLEAN DEFAULT FALSE
			                );
			    IF v_status = 0 THEN  -- 0-SUCCESS
			      RETURN 0;
			    ELSIF v_status = 4 THEN  -- 4-OWN LOCK - nie powinno siê zdarzyæ
					p_err_text := p_err_text||' Uchwyt zosta³ ju¿ zablokowany (powiadom administratora systemu)';
					RETURN -1;
			    ELSE                     -- 1-TIMEOUT; 2-DEADLOCK; 5-BAD LOCK HANDLE;  or bad param
			      p_err_text := p_err_text||' Generowanie numeru jest aktualnie przetwarzane. Spróbuj zapisaæ za chwile !';
					RETURN -1;
			    END IF;
		  END IF;
		EXCEPTION
			WHEN OTHERS THEN
				v_sqlcode := SQLCODE;
				v_sqlerrm := SQLERRM;
				p_err_text := p_err_text||' Wyst¹pi³ blad w funkcji LOCK_ON'
								||' - '||v_sqlcode||'-'||v_sqlerrm;
				RETURN -1;
		END;
		
		-- funkcja zwalniajaca danego locka
		FUNCTION LOCK_OFF RETURN NUMBER IS
			v_status 		INTEGER;
		BEGIN
		  IF v_lock_handle IS NULL THEN
				null;
		  ELSE
				v_status := DBMS_LOCK.RELEASE( lockhandle => v_lock_handle );
		  END IF;
		  RETURN 0;
		EXCEPTION
			WHEN OTHERS THEN
				v_sqlcode := SQLCODE;
				v_sqlerrm := SQLERRM;
				p_err_text := p_err_text||' Wyst¹pi³ blad w funkcji LOCK_OFF'
								||' - '||v_sqlcode||'-'||v_sqlerrm;
				RETURN -1;
		END;
