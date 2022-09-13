CREATE PROCEDURE VW_DAFTAR_JUAL_CUSTOMER_DET(
  KODE_GUDANG VARCHAR(20),
  CARI VARCHAR(100),
  TGL DATE)
RETURNS(
  NO_ORDER VARCHAR(11),
  KODE_CUSTOMER VARCHAR(20),
  NAMA_CUSTOMER VARCHAR(100),
  TOP_CUSTOMER INTEGER,
  TANGGAL DATE,
  NO_FAKTUR VARCHAR(11),
  JUMLAH DECIMAL(18, 2),
  ALAMAT_KIRIM VARCHAR(200),
  ATAS_NAMA VARCHAR(100),
  KODE_SALES VARCHAR(20),
  NAMA_SALES VARCHAR(100),
  KODE_SUPP VARCHAR(11),
  NAMA_SUPP VARCHAR(100),
  HP VARCHAR(50),
  PARENT_KODE_BARANG VARCHAR(20),
  KODE_BARANG VARCHAR(20),
  NAMA_BARANG VARCHAR(100),
  KODE_SATUAN VARCHAR(5),
  QTY DECIMAL(18, 2))
AS
BEGIN
   FOR   
      select          
      a.no_order,
      a.tanggal,
      b.kode_customer,
      b.nama_customer,
      b.top top_customer,
      a.no_faktur,
      a.total_bersih jumlah,
      a.alamat_kirim,
      a.atas_nama,
      c.kode_sales,
      c.nama_sales,
      b.TELP,        
      g.kode_barang parent_kode_barang,
      e.kode_barang, 
      g.nama_barang,
      e.kode_satuan,
      e.qty
      from mt_PENJUALAN a                     
      inner join dt_PENJUALAN e on e.NO_FAKTUR = a.NO_FAKTUR
      inner join mst_barang_jual f on f.kode_jual = e.KODE_BARANG
                                    and f.KODE_SATUAN = e.KODE_SATUAN
      inner join mst_barang g on g.kode_barang = f.kode_barang
      left join mst_customer b on b.kode_customer = a.kode_customer
      left join mst_sales c on c.kode_sales = a.kode_sales
      where
      (
        upper(coalesce(b.nama_customer,'')) like upper(:cari)  or
        upper(a.no_faktur) like upper(:cari) or
        upper(g.nama_barang) like upper(:cari) 
      )
      and a.tanggal = :tgl
      and coalesce(a.batal,0)=0
      and a.kode_gudang = :kode_gudang
      order by a.tanggal desc, b.nama_customer asc , a.no_order desc
     INTO 
      :no_order,     
      :tanggal,
      :KODE_CUSTOMER ,
      :NAMA_CUSTOMER ,
      :top_customer ,
      :no_faktur ,
      :jumlah ,
      :alamat_kirim ,
      :atas_nama ,
      :kode_sales,
      :nama_sales,
      :hp,         
      :parent_kode_barang,
      :kode_barang,
      :nama_barang,
      :kode_satuan,
      :qty
   DO
     BEGIN
       suspend;
     END
END;
