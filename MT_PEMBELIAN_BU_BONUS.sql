ALTER TRIGGER MT_PEMBELIAN_BU
ACTIVE BEFORE 
  UPDATE
POSITION 0
AS
DECLARE VARIABLE GUDANG VARCHAR(20);
DECLARE VARIABLE KODE_BARANG VARCHAR(20);
DECLARE VARIABLE QTY DECIMAL(18, 4);
DECLARE VARIABLE KODE_SATUAN VARCHAR(10);
DECLARE VARIABLE KONVERSI DECIMAL(18, 4);
DECLARE VARIABLE KODE_JUAL VARCHAR(20);
DECLARE VARIABLE BATCH VARCHAR(20);
DECLARE VARIABLE TGL_EXP DATE;
DECLARE VARIABLE SERIAL VARCHAR(50);
DECLARE VARIABLE TMP BIGINT;
DECLARE VARIABLE QTY_BONUS DECIMAL(18, 2);
BEGIN
  -- jika kol batal ada perubahan dan perubahan itu adala batal maka
  if (
      (old.BATAL <> new.BATAL) and
      (new.batal = 1)
     )
  then
     begin
          -- looping item penjualan
          for
            select kode_barang, qty, kode_satuan, konversi, gudang,
            BATCH, TGL_EXP, SERIAL, QTY_BONUS
            from dt_pembelian
            where
            no_faktur = old.NO_FAKTUR
            into :kode_jual, :qty, :kode_satuan, :konversi, :gudang,
            :BATCH, :TGL_EXP, :SERIAL, :QTY_BONUS
          do
            begin
              SELECT KODE_BARANG FROM MST_BARANG_jual
              WHERE KODE_JUAL = :kode_jual AND KODE_SATUAN = :KODE_SATUAN
              INTO :KODE_BARANG;

              -- insert ke kartu stock
              EXECUTE PROCEDURE TOOLS_INSERTKARTUSTOCK
              (current_date,:GUDANG,:KODE_BARANG,0-(:QTY*:konversi),'BATAL PEMBELIAN',old.NO_FAKTUR,
              'BATAL PEMBELIAN',NEW.USER_EDIT,NEW.WAKTU_EDIT,0- :qty, :KODE_SATUAN, :BATCH, :TGL_EXP, :SERIAL)
              RETURNING_VALUES :TMP;
              
              --CEK JIKA ADA BONUS PEMBELIAN
              IF(COALESCE(QTY_BONUS,0) > 0)THEN
              BEGIN
              		EXECUTE PROCEDURE TOOLS_INSERTKARTUSTOCK
                    (current_date,:GUDANG,:KODE_BARANG,0-(:QTY_BONUS*:konversi),'BATAL PEMBELIAN',old.NO_FAKTUR,
                    'BATAL BONUS PEMBELIAN',NEW.USER_EDIT,NEW.WAKTU_EDIT,0- :qty_bonus, :KODE_SATUAN, :BATCH, :TGL_EXP, :SERIAL)
                    RETURNING_VALUES :TMP;
              END
              
              -- BATAL JUGA DI MASTER BARANG DET
              UPDATE MST_BARANG_DET SET BATAL = 1
              WHERE FAKTUR_PEMBELIAN = NEW.NO_FAKTUR;
              
            end
     end
END;
