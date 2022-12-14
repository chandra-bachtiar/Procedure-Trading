CREATE PROCEDURE HIS_PEMBAYARAN_PIUTANG_V1(
  DARI_TGL DATE,
  SAMPAI_TGL DATE)
RETURNS(
  TANGGAL DATE,
  KODE_CUSTOMER VARCHAR(11),
  CUSTOMER VARCHAR(100),
  UNTUK_FAKTUR VARCHAR(20),
  KODE_SALES VARCHAR(10),
  SALES VARCHAR(100),
  JENIS_TRANSAKSI VARCHAR(20),
  DARI_FAKTUR VARCHAR(11),
  JUMLAH_PEMBAYARAN DECIMAL(18, 2),
  SALDO_AWAL DECIMAL(18, 2),
  SALDO_AKHIR DECIMAL(18, 2),
  NO_PIUTANG BIGINT,
  USER_INPUT VARCHAR(20))
AS
BEGIN
    FOR
       SELECT
       A.TANGGAL, A.KODE_CUSTOMER, B.NAMA_CUSTOMER, A.KODE_SALES, C.NAMA_SALES,
       A.JENIS_TRANSAKSI, A.UNTUKFAKTUR, A.DARI_KEMBALIAN_FAKTUR, ABS(A.JUMLAH),
       A.USER_INPUT,A.SALDO_AWAL,A.SALDO_AKHIR,A.NO_PIUTANG
       FROM DT_PIUTANG_CUSTOMER A
       INNER JOIN MST_CUSTOMER B ON B.KODE_CUSTOMER = A.KODE_CUSTOMER
       LEFT JOIN MST_SALES C ON C.KODE_SALES = A.KODE_SALES
       WHERE
       COALESCE(A.BATAL,0)=0
       AND (A.TANGGAL BETWEEN :DARI_TGL AND :SAMPAI_TGL)
       AND COALESCE(JUMLAH,0) < 0 -- MINUS TANDA UNTUK PEMBAYARAN PIUTANG
       INTO
       :TANGGAL, :KODE_CUSTOMER, :CUSTOMER, :KODE_SALES, :SALES,
       :JENIS_TRANSAKSI, :UNTUK_FAKTUR, :DARI_FAKTUR, :JUMLAH_PEMBAYARAN,
       :USER_INPUT,:SALDO_AWAL,:SALDO_AKHIR,:NO_PIUTANG
    DO
      BEGIN      
         if ( coalesce(kode_sales,'') = '') then 
           begin
              select 
              b.kode_sales, b.nama_sales
              from mt_penjualan a
              inner join mst_sales b on b.kode_sales = a.kode_sales
              where no_faktur = :untuk_faktur
              into :kode_sales, :sales;
           end
         SUSPEND;
      END

END;
