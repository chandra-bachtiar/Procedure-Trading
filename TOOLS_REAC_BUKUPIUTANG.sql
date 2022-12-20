CREATE PROCEDURE TOOLS_REAC_BUKUPIUTANG(
  KODE_CUSTOMER VARCHAR(11))
AS
DECLARE VARIABLE AWAL DECIMAL(18, 2);
DECLARE VARIABLE JUMLAH DECIMAL(18, 2);
DECLARE VARIABLE AKHIR DECIMAL(18, 2);
DECLARE VARIABLE KE INTEGER;
DECLARE VARIABLE NO_PIUTANG BIGINT;
DECLARE VARIABLE VSALDO DECIMAL(18, 2);
BEGIN
   KE = 0;
   VSALDO = 0;
   FOR
      SELECT
      A.NO_PIUTANG, A.SALDO_AWAL, A.JUMLAH, A.SALDO_AKHIR
      FROM DT_PIUTANG_CUSTOMER A
      WHERE
      A.KODE_CUSTOMER = :KODE_CUSTOMER AND
      COALESCE(A.BATAL,0)=0  
      and coalesce(disabled,0)=0
      ORDER BY A.NO_PIUTANG
      INTO
      :NO_PIUTANG, :AWAL, :JUMLAH, :AKHIR
   DO
     BEGIN
        KE = KE + 1;
        IF (KE = 1) THEN
          BEGIN
             UPDATE DT_PIUTANG_CUSTOMER SET SALDO_AWAL = 0,
             SALDO_AKHIR = :JUMLAH WHERE NO_PIUTANG = :NO_PIUTANG;
             VSALDO = JUMLAH;
          END
        ELSE
          BEGIN
              UPDATE DT_PIUTANG_CUSTOMER SET SALDO_AWAL = :VSALDO,
              SALDO_AKHIR = :VSALDO + :JUMLAH  WHERE NO_PIUTANG = :NO_PIUTANG;
              VSALDO = VSALDO + JUMLAH;
          END
     END
END;
