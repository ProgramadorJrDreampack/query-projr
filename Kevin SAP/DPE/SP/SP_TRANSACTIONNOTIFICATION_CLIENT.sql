IF :object_type = '2' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN

    SELECT "E_Mail", "Phone1" INTO v_email, v_phone
    FROM "SBO_FIGURETTI_PROD"."OCRD" WHERE "CardCode" = :list_of_cols_val_tab_del;

    SELECT "CardType" INTO v_cardtype
    FROM "SBO_FIGURETTI_PROD"."OCRD" WHERE "CardCode" = :list_of_cols_val_tab_del;

    IF v_cardtype = 'S' THEN
        IF v_email IS NULL OR v_email = '' THEN
            error = 1;
            error_message = N'DPE: El correo electrónico es obligatorio para proveedores.';
            return;
        END IF;
        IF v_phone IS NULL OR v_phone = '' THEN
            error = 2;
            error_message = N'DPE: El teléfono es obligatorio para proveedores.';
            return;
        END IF;

        -- Validar dirección "Pagar a" desde CRD1 (Street + Country)
        SELECT COUNT(*) INTO v_addr_count
        FROM "SBO_FIGURETTI_PROD"."CRD1"
        WHERE "CardCode" = :list_of_cols_val_tab_del
          AND "AdresType" = 'B'              -- B = Bill To (Pagar a)
          AND IFNULL("Street", '') <> ''
          AND IFNULL("Country", '') <> '';

        IF v_addr_count = 0 THEN
            error = 3;
            error_message = N'DPE: La dirección Pagar a (calle y país) es obligatoria para proveedores.';
            return;
        END IF;
    END IF;
END IF;