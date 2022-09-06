CREATE TRIGGER CIPTO_ONGKIR FOR MT_PENJUALAN
ACTIVE BEFORE 
  INSERT
POSITION 0
AS
DECLARE VARIABLE NONROKOK DECIMAL(18, 2);
DECLARE VARIABLE TOTAL_ONGKIR SMALLINT;
BEGIN
  IF(NEW.KODE_SALES = '015' OR NEW.KODE_SALES = '016') THEN
  BEGIN
     IF(NEW.TOTAL_BERSIH > 9999999) THEN
     BEGIN
       NEW.ONGKOS_KIRIM = 5000;
       NEW.TOTAL_BERSIH = NEW.TOTAL_BERSIH + NEW.ONGKOS_KIRIM;
       new.piutang = new.piutang + new.ongkos_kirim;
     END
     ELSE
     BEGIN
       NEW.ONGKOS_KIRIM = 3000;
       NEW.TOTAL_BERSIH = NEW.TOTAL_BERSIH + NEW.ONGKOS_KIRIM;
       new.piutang = new.piutang + new.ongkos_kirim;
     END
  END
  
   IF(NEW.KODE_SALES = '012' OR NEW.KODE_SALES = '013' OR NEW.KODE_SALES = '014') THEN
  BEGIN
    -- CARI TOTAL NON ROKOK
    select
    sum(coalesce(b.subtotal,0)) jumlah_rokok                                                                                                                                                                           
    from mt_penjualan a
    inner join dt_penjualan b on b.no_faktur = a.no_faktur
    inner join mst_barang_jual c on c.kode_jual = b.kode_barang and
                               c.kode_satuan = b.kode_satuan
    inner join mst_barang d on d.kode_barang = c.kode_barang
    inner join mst_customer e on e.kode_customer = a.kode_customer
    inner join mst_sales f on f.kode_sales = a.kode_sales
    left join mst_barang_hadiah g on g.kode_barang = d.kode_barang    
    left join mst_kota h on h.kota = e.kota
    left join mst_regional i on i.kode_regional  = h.kode_regional
    left join mst_groupbarang j on j.kode_groupbarang = d.kode_groupbarang                                                                                                                                                                               
    where
    a.no_faktur = new.no_faktur
    and j.group_barang = 'ROKOK'
    into :nonrokok;
    
    NONROKOK = COALESCE(NEW.TOTAL_BERSIH,0) - COALESCE(NONROKOK,0);
    --CARI TOTAL FAKTUR YG TIDAK MEMILIKI ONGKIR MULAI DARI SEPTEMBER 2022
    
    IF(COALESCE(NONROKOK,0) < 9999999) THEN
     BEGIN
       NEW.ONGKOS_KIRIM = 5000;
       NEW.TOTAL_BERSIH = NEW.TOTAL_BERSIH + NEW.ONGKOS_KIRIM;
       new.piutang = new.piutang + new.ongkos_kirim;
     END
     ELSE IF(COALESCE(NONROKOK,0) > 9999999) THEN
     BEGIN
       NEW.ONGKOS_KIRIM = 7500;
       NEW.TOTAL_BERSIH = NEW.TOTAL_BERSIH + NEW.ONGKOS_KIRIM;
       new.piutang = new.piutang + new.ongkos_kirim;
     END
  END
END;
