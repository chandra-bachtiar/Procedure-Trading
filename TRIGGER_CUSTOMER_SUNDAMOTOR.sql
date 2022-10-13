ALTER TRIGGER MST_CUSTOMER_BI
ACTIVE BEFORE 
  INSERT OR 
  UPDATE
POSITION 0
AS
DECLARE VARIABLE PENANDA_ACTION VARCHAR(100);
BEGIN
  IF (COALESCE(NEW.KODE_CUSTOMER,'')='') THEN
    BEGIN                   
        IF ( COALESCE(NEW.PASIEN,0)=1) THEN
           BEGIN 
                IF (INSERTING) THEN
                   BEGIN
                     IF (COALESCE(NEW.NAMA_CUSTOMER,'')='') THEN
                         EXCEPTION EXP_ERROR 'NAMA CUSTOMER TIDAK BOLEH KOSONG !!!';
                     SELECT KODE FROM SP_CARINOMOR_URUTAN
                     ('MST_CUSTOMER','KODE_CUSTOMER',SUBSTRING(NEW.NAMA_CUSTOMER FROM 1 FOR 1)) INTO NEW.KODE_CUSTOMER;
                   END
                ELSE
                  BEGIN
                     IF (COALESCE(NEW.NAMA_CUSTOMER,'')='') THEN
                         EXCEPTION EXP_ERROR 'NAMA CUSTOMER TIDAK BOLEH KOSONG !!!';

                     IF (COALESCE(OLD.NAMA_CUSTOMER,'') <> COALESCE(NEW.NAMA_CUSTOMER,'') AND
                        COALESCE(NEW.NAMA_CUSTOMER,'') <> '') THEN
                        BEGIN
                          SELECT KODE FROM SP_CARINOMOR_URUTAN
                          ('MST_CUSTOMER','KODE_CUSTOMER',SUBSTRING(NEW.NAMA_CUSTOMER FROM 1 FOR 1)) INTO NEW.KODE_CUSTOMER;
                        END
                  END   
           END 
        ELSE
           BEGIN
           select penanda_action from mst_config 
           into :penanda_action;
           if(coalesce(PENANDA_ACTION,'') = 'SUNDA MOTOR') then
               begin
                 EXECUTE PROCEDURE SUNDA_MOTOR_KODE_CUSTOMER RETURNING_VALUES NEW.KODE_CUSTOMER;
               end
           else
               begin
                  NEW.KODE_CUSTOMER = NEW.NOURUT;
               end
           END
           
    END
END;
