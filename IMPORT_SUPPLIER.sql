CREATE PROCEDURE IMPORT_SUPPLIER
RETURNS(
  KODE_SUPPLIER VARCHAR(20),
  TOP INTEGER,
  NAMA VARCHAR(200),
  ALAMAT VARCHAR(200),
  TELP VARCHAR(20))
AS
DECLARE VARIABLE NEW_VAR SMALLINT;
BEGIN
  FOR
    SELECT
    A.KODE_SUPPLIER,A.TOP,A.NAMA,A.ALAMAT,A.TELP
    FROM TMP_SUPPLIER A
    LEFT JOIN MST_SUPPLIER B ON B.KODE_SUPP = A.KODE_SUPPLIER
    WHERE COALESCE(B.KODE_SUPP,'') = ''
    INTO :KODE_SUPPLIER,:TOP,:NAMA,:ALAMAT,:TELP
  DO
    BEGIN
          INSERT INTO MST_SUPPLIER(KODE_SUPP,NAMA_SUPP,ALAMAT,TELP,TOP)
          VALUES(:KODE_SUPPLIER,:NAMA,:ALAMAT,:TELP,:TOP);
    END
END;