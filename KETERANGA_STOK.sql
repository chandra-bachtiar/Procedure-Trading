CREATE PROCEDURE KETERANGA_STOK(
  KODE_BARANG VARCHAR(20),
  STOK DECIMAL(18, 2))
RETURNS(
  KETERANGAN VARCHAR(100))
AS
DECLARE VARIABLE KODE_SATUAN VARCHAR(5);
DECLARE VARIABLE KONVERSI INTEGER;
DECLARE VARIABLE HASIL INTEGER;
DECLARE VARIABLE KOMA VARCHAR(2);
BEGIN
  if (coalesce(stok,0) < 0) then
     keterangan = 'MINUS - ';
  else
     keterangan = '';
  STOK = ABS(STOK);
  
  for
     select kode_satuan, coalesce(konversi,1)
     from mst_barang_jual
     where kode_barang = :kode_barang
     and coalesce(not_visible,0) = 0
     order by konversi desc
     into :kode_satuan, :konversi
  do
     begin
         konversi = coalesce(konversi,1);
         if (konversi =0) then konversi =1;
         hasil = 0;
         if (stok >= konversi) then
           begin
            hasil = div(stok, konversi);
            stok = stok - ( hasil * konversi);
            IF(COALESCE(STOK,0) > 0) THEN KOMA = ', '; ELSE KOMA = '';
            keterangan = keterangan || cast(hasil as varchar(10)) || ' ' || kode_satuan || KOMA;
           end
     end
  SUSPEND;
END;
