#! /usr/bin/ruby
# coding: utf-8

class User
  attr_accessor :subjects, :subjects_id, :subjects_assigned, :subjects_free

  def initialize(csv_data)

    @subjects = []
    @subjects_id = []
    @subjects_assigned = []  #科目区分定義で振り分けできた科目
    @subjects_free = []          #科目区分定義で振り分けできなかった科目 = 自由単位

    #csvからユーザーの履修科目を読込
    input_csv = csv_data.read.gsub("\n","").force_encoding('UTF-8').gsub(/(“|”)/, 34.chr)

    #TWINSのCSVは、一行目がCRLF、二行目以降CRのみ なのでCRに統一
    table = CSV.parse(input_csv)
    if table[0] != ["\u79D1\u76EE\u533A\u5206", "\u5E74\u5EA6", "\u5B66\u671F", "\u79D1\u76EE\u756A\u53F7", "\u79D1\u76EE\u540D ", "\u4E3B\u62C5\u5F53\u6559\u54E1", "\u6210\u7E3E", "\u5358\u4F4D"]
      raise "Error CSV"
    end

    table.each do |section, year, term, id, title, teacher, grade, credit|
      if id != "" && id != "\u79D1\u76EE\u756A\u53F7"
        #空行かヘッダー行は無視（もっといいやり方ありそう）
        @subjects << [id,year,grade, title, credit] #encode(UTF-8)
      end
    end

    #idだけの配列を用意
    @subjects.each do |row|
      @subjects_id << row[0]
    end

  end
end