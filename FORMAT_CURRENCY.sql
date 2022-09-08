CREATE PROCEDURE FORMAT_CURRENCY(
  NILAI DECIMAL(18, 2))
RETURNS(
  OUTPUT VARCHAR(20))
AS
DECLARE VARIABLE NILAI_STRING VARCHAR(20);
DECLARE VARIABLE PANJANG INTEGER;
DECLARE VARIABLE KE INTEGER;
DECLARE VARIABLE TEMP VARCHAR(20);
DECLARE VARIABLE KARAKTER_ANGKA VARCHAR(1);
DECLARE VARIABLE PANJANG_MUNDUR INTEGER;
BEGIN
  NILAI_STRING = TRIM(CAST(ROUND(NILAI) AS VARCHAR(20)));
  PANJANG = STRLEN(NILAI_STRING);
  PANJANG_MUNDUR = PANJANG;
  OUTPUT = '';
  KE = 0;
  WHILE(PANJANG_MUNDUR > 0) DO
  BEGIN
  KE = KE + 1;
  IF(MOD(KE,3) = 0) THEN
    BEGIN
      IF(PANJANG_MUNDUR <> 1) THEN
      BEGIN
        OUTPUT = ',' || SUBSTRING(NILAI_STRING FROM PANJANG_MUNDUR FOR 1) || OUTPUT;
        PANJANG_MUNDUR = PANJANG_MUNDUR - 1;
      END
      ELSE
      BEGIN
        OUTPUT =  SUBSTRING(NILAI_STRING FROM PANJANG_MUNDUR FOR 1) || OUTPUT;
        PANJANG_MUNDUR = PANJANG_MUNDUR - 1; 
      END
       
    END
  ELSE
    BEGIN
       OUTPUT =  SUBSTRING(NILAI_STRING FROM PANJANG_MUNDUR FOR 1) || OUTPUT;
       PANJANG_MUNDUR = PANJANG_MUNDUR - 1; 
    END
  END
  SUSPEND;
END;