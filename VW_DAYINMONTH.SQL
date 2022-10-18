create procedure VW_DAYINMONTH (TAHUN int, BULAN int)
returns (TANGGAL date) as
begin
  TANGGAL = cast(TAHUN || '-' || BULAN || '-01' as date);
  while (extract(month from TANGGAL) = BULAN) do
  begin
    suspend;
    TANGGAL = TANGGAL + 1;
  end
end
