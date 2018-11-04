require 'csv'
bom = "\uFEFF"
CSV.generate(bom) do |csv|
  header = [
    "ASIN",
    "新品過去1ヶ月",
    "新品過去2ヶ月",
    "新品過去3ヶ月",
    "新品3ヶ月平均",
    "中古過去1ヶ月",
    "中古過去2ヶ月",
    "中古過去3ヶ月",
    "中古3ヶ月平均",
    "チェック1",
    "カート価格",
    "カート入金",
    "中古最安値",
    "中古入金",
    "チェック2",
    "商品名",
    "型番",
    "商品画像",
    "チェック3",
    "新品入札価格",
    "中古入札価格",
    "新品交渉価格",
    "中古交渉価格"
  ]

  csv << header
  logger.debug(@data)
  @data.each do |row|
    csv << row
  end

end
