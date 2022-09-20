CREATE GENERATOR GSI_NO_PEMBAYARAN_GEN;
CREATE TRIGGER BI_GSI_NO_PEMBAYARAN FOR GSI_PEMBAYARAN_FITUR
ACTIVE BEFORE 
  INSERT
POSITION 0
AS
BEGIN
  IF (NEW.NO_PEMBAYARAN IS NULL) THEN
      NEW.NO_PEMBAYARAN = GEN_ID(GSI_NO_PEMBAYARAN_GEN, 1);
END;
SET GENERATOR GSI_NO_PEMBAYARAN_GEN TO 141;