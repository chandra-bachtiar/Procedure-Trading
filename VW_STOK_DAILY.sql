CREATE PROCEDURE VW_STOK_DAILY(
  TGL DATE,
  GUDANG VARCHAR(20),
  PARAM SMALLINT,
  GRUP VARCHAR(20))
RETURNS(
  NAMA_BARANG VARCHAR(200),
  KODE_BARANG VARCHAR(20),
  VSTOK DECIMAL(18, 2),
  VSTOK_AWAL DECIMAL(18, 2),
  KET_STOK_AWAL VARCHAR(100),
  VSTOK_JUAL DECIMAL(18, 2),
  KET_STOK_JUAL VARCHAR(100),
  VSTOK_RETUR_JUAL DECIMAL(18, 2),
  KET_STOK_RETUR_JUAL VARCHAR(100),
  VSTOK_BELI DECIMAL(18, 2),
  KET_STOK_BELI VARCHAR(100),
  VSTOK_RETUR_BELI DECIMAL(18, 2),
  KET_STOK_RETUR_BELI VARCHAR(100),
  VSTOK_MASUK DECIMAL(18, 2),
  KET_STOK_MASUK VARCHAR(100),
  VSTOK_KELUAR DECIMAL(18, 2),
  KET_STOK_KELUAR VARCHAR(100),
  VSTOK_AKHIR DECIMAL(18, 2),
  KET_STOK_AKHIR VARCHAR(100),
  TOTAL_ASET DECIMAL(18, 2))
AS
DECLARE VARIABLE VHARGA_BELI DECIMAL(18, 2);
DECLARE VARIABLE TMP_QUERY VARCHAR(1000);
BEGIN
  /*
  KETERANGAN PARAM
  1 == SEMUA BARANG
  2 == BARANG BERGERAK
  3 == PERGROUP BARANG
  */
  if(coalesce(PARAM,0) = 0) then suspend;
  if(coalesce(GUDANG,'') = '') THEN SUSPEND;
  
  -- QUERY
  TMP_QUERY = '';
  IF(COALESCE(PARAM,0) = 1) THEN
  BEGIN
  TMP_QUERY = ' SELECT
                A.KODE_BARANG,A.NAMA_BARANG
                FROM MST_BARANG A';
  END
  
  IF(COALESCE(PARAM,0) = 2) THEN
  BEGIN
  TMP_QUERY = ' SELECT DISTINCT
                A.KODE_BARANG,B.NAMA_BARANG
                FROM DT_KARTUSTOCK A
                INNER JOIN MST_BARANG B ON B.KODE_BARANG = A.KODE_BARANG
                WHERE A.TANGGAL = '''|| TGL ||''' AND A.KODE_GUDANG = ''' || :GUDANG || '''';
  END
  
  IF(COALESCE(PARAM,0) = 3) THEN
  BEGIN
  TMP_QUERY = ' SELECT
                A.KODE_BARANG,A.NAMA_BARANG
                FROM MST_BARANG A
                WHERE A.KODE_GROUPBARANG = ''' || GRUP || '''';
  END
  
  FOR
    -- AMBIL SEMUA BARANG
    EXECUTE STATEMENT 
    TMP_QUERY
    INTO :KODE_BARANG,:NAMA_BARANG
  DO
    BEGIN
      -- RESET VARIABLE
      VSTOK_AWAL = 0; VSTOK_JUAL = 0; VSTOK_RETUR_JUAL = 0;VSTOK_RETUR_BELI = 0; VSTOK_BELI = 0;
      VSTOK_MASUK = 0; VSTOK_KELUAR = 0; VSTOK_AKHIR = 0;
      -- CARI SALDO AWAL TANGGAL TERPILIH
      select first 1 saldo_akhir
      from vw_kartustock_kemarin(:GUDANG, :kode_barang, :TGL - 1,:TGL - 1)
      order by nomer_urut desc
      INTO :VSTOK_AWAL;
      
        
      -- CARI STOK YANG TERJUAL
      SELECT
      SUM(B.QTY * B.KONVERSI)
      FROM MT_PENJUALAN A
      INNER JOIN DT_PENJUALAN B ON B.NO_FAKTUR = A.NO_FAKTUR
      INNER JOIN MST_BARANG_JUAL C ON C.KODE_JUAL = B.KODE_BARANG AND C.KODE_SATUAN = B.KODE_SATUAN
      WHERE COALESCE(A.BATAL,0) = 0 AND A.TANGGAL = :TGL
      AND C.KODE_BARANG = :KODE_BARANG AND B.GUDANG = :GUDANG
      INTO :VSTOK_JUAL;
        
      -- CARI STOK YANG DI RETUR
      SELECT
      SUM(B.QTY * B.KONVERSI)
      FROM MT_RETUR_PENJUALAN A
      INNER JOIN DT_RETUR_PENJUALAN B ON B.NO_RETUR = A.NO_RETUR
      INNER JOIN MST_BARANG_JUAL C ON C.KODE_JUAL = B.KODE_BARANG AND C.KODE_SATUAN = B.KODE_SATUAN
      WHERE COALESCE(A.BATAL,0) = 0 AND A.TANGGAL = :TGL
      AND C.KODE_BARANG = :KODE_BARANG AND B.GUDANG = :GUDANG
      INTO :VSTOK_RETUR_JUAL;
      
      --
      SELECT
      SUM(B.QTY * B.KONVERSI)
      FROM MT_RETUR_PEMBELIAN A
      INNER JOIN DT_RETUR_PEMBELIAN B ON B.NO_RETUR = A.NO_RETUR
      INNER JOIN MST_BARANG_JUAL C ON C.KODE_JUAL = B.KODE_BARANG AND C.KODE_SATUAN = B.KODE_SATUAN
      WHERE COALESCE(A.BATAL,0) = 0 AND A.TANGGAL = :TGL
      AND C.KODE_BARANG = :KODE_BARANG AND B.GUDANG = :GUDANG
      INTO :VSTOK_RETUR_BELI;
        
      -- CARI STOK PEMBELIAN
      SELECT
      SUM(B.QTY * B.KONVERSI)
      FROM MT_PEMBELIAN A
      INNER JOIN DT_PEMBELIAN B ON B.NO_FAKTUR = A.NO_FAKTUR
      INNER JOIN MST_BARANG_JUAL C ON C.KODE_JUAL = B.KODE_BARANG AND C.KODE_SATUAN = B.KODE_SATUAN
      WHERE COALESCE(A.BATAL,0) = 0 AND A.TANGGAL = :TGL
      AND C.KODE_BARANG = :KODE_BARANG AND B.GUDANG = :GUDANG
      INTO :VSTOK_BELI;
        
      -- CARI MUTASI KELUAR
      SELECT
      SUM(B.QTY * B.KONVERSI)
      FROM MT_BARANG_KELUAR A
      INNER JOIN DT_BARANG_KELUAR B ON B.NO_FAKTUR = A.NO_FAKTUR
      INNER JOIN MST_BARANG_JUAL C ON C.KODE_JUAL = B.KODE_BARANG AND C.KODE_SATUAN = B.KODE_SATUAN
      WHERE COALESCE(A.BATAL,0) = 0 AND A.TANGGAL = :TGL
      AND C.KODE_BARANG = :KODE_BARANG AND B.GUDANG = :GUDANG
      INTO :VSTOK_KELUAR;
        
      -- CARI MUTASI MASUK
      SELECT
      SUM(B.QTY * B.KONVERSI)
      FROM MT_BARANG_KELUAR A
      INNER JOIN DT_BARANG_KELUAR B ON B.NO_FAKTUR = A.NO_FAKTUR
      INNER JOIN MST_BARANG_JUAL C ON C.KODE_JUAL = B.KODE_BARANG AND C.KODE_SATUAN = B.KODE_SATUAN
      WHERE COALESCE(A.BATAL,0) = 0 AND A.TANGGAL = :TGL
      AND C.KODE_BARANG = :KODE_BARANG AND A.KODE_GUDANG_TUJUAN = :GUDANG
      INTO :VSTOK_MASUK;
        
      -- CARI STOK AKHIR
      select first 1 saldo_akhir
      from vw_kartustock_kemarin(:GUDANG, :kode_barang, :TGL,:TGL)
      order by nomer_urut desc
      INTO :VSTOK_AKHIR;
        
      -- cari harga beli
      SELECT FIRST 1 COALESCE(HARGA_POKOK,0) FROM MST_BARANG_JUAL
      WHERE KODE_BARANG = :KODE_BARANG AND COALESCE(KONVERSI,1) = 1
      INTO :VHARGA_BELI;
        
      TOTAL_ASET = COALESCE(VSTOK_AKHIR,0) * COALESCE(VHARGA_BELI,0);
        
      --DAPATKAN KETERANGAN STOK
      SELECT KETERANGAN FROM KETERANGA_STOK(:KODE_BARANG,COALESCE(:VSTOK_AWAL,0)) INTO :KET_STOK_AWAL;
      SELECT KETERANGAN FROM KETERANGA_STOK(:KODE_BARANG,COALESCE(:VSTOK_JUAL,0)) INTO :KET_STOK_JUAL;
      SELECT KETERANGAN FROM KETERANGA_STOK(:KODE_BARANG,COALESCE(:VSTOK_RETUR_JUAL,0)) INTO :KET_STOK_RETUR_JUAL;
      SELECT KETERANGAN FROM KETERANGA_STOK(:KODE_BARANG,COALESCE(:VSTOK_RETUR_BELI,0)) INTO :KET_STOK_RETUR_BELI;
      SELECT KETERANGAN FROM KETERANGA_STOK(:KODE_BARANG,COALESCE(:VSTOK_BELI,0)) INTO :KET_STOK_BELI;
      SELECT KETERANGAN FROM KETERANGA_STOK(:KODE_BARANG,COALESCE(:VSTOK_MASUK,0)) INTO :KET_STOK_MASUK;
      SELECT KETERANGAN FROM KETERANGA_STOK(:KODE_BARANG,COALESCE(:VSTOK_KELUAR,0)) INTO :KET_STOK_KELUAR;
      SELECT KETERANGAN FROM KETERANGA_STOK(:KODE_BARANG,COALESCE(:VSTOK_AKHIR,0)) INTO :KET_STOK_AKHIR;
    SUSPEND;
    END
END;
