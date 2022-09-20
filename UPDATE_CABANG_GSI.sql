--ALTER TABLE GSI_CUSTOMER_FITUR ADD CABANG_VPS INTEGER;
CREATE PROCEDURE UPDATE_CABANG_GSI
RETURNS(
  CABANGNYA SMALLINT)
AS
DECLARE VARIABLE NO_FITUR INTEGER;
DECLARE VARIABLE CABANG INTEGER;
BEGIN
   FOR
     SELECT NO_FITUR FROM GSI_CUSTOMER_FITUR
     WHERE COALESCE(VPS,0) = 1
     AND COALESCE(TRIAL,0) = 0
     INTO :NO_FITUR
   DO
   BEGIN
     SELECT FIRST 1 NOMINAL/100000 FROM GSI_PEMBAYARAN_FITUR
     WHERE EXTRACT(MONTH FROM TANGGAL) = 8
     AND EXTRACT(YEAR FROM TANGGAL) = 2022
     AND NO_FITUR = :NO_FITUR
     INTO :CABANG;
     
     
     UPDATE GSI_CUSTOMER_FITUR
     SET CABANG_VPS = :CABANG
     WHERE NO_FITUR = :NO_FITUR;
   END
END;
