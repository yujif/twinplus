#! /usr/bin/ruby
# coding: utf-8

class Sections
  attr_accessor :name, :earned_credits, :registed_credits, :others_credits, :require_credits, :is_fetch_all, :all, :earned, :failed, :registed, :others

  def initialize(keywords, name, require_credits, is_fetch_all)
    @name = name
    @earned_credits = 0.0
    @registed_credits = 0.0
    @others_credits = 0.0
    @require_credits = require_credits.to_f
    @is_fetch_all = is_fetch_all
    @keywords = keywords
    @all = []; fetch_all_kdb() if is_fetch_all  # [id]
      #全候補を取得すると膨大になるもの (ex. 自由）は is_fetch_all を false に
    @earned = []   # [id, year, grade]
    @failed = []     # [id, year, grade]
    @registed = [] # [id, year, grade]
    @others = []    # [id]

  end


  def fetch_subject_info(id,year)
    year = BASE_YEAR if year == "" #値が空ならBASE_YEARに
    db = SQLite3::Database.new(DATABASE_FILENAME.gsub("YEAR",year))
    db.busy_timeout(100000)
    db.results_as_hash = true
    sql = "select * from #{TABLE_NAME} where #{COLUMN_NAMES[0]} like ? "
    sql_rows = []
    db.execute(sql, id) do |sql_row|
       sql_rows << sql_row
    end
    db.close

    return sql_rows
  end

  def sum_earned_credits
    @earned.each do |row|
      info = fetch_subject_info(row[0],row[1]) #id, year
      @earned_credits += info[0]["unit"].to_f # unit -> credit
    end

    return @earned_credits
  end

  def sum_registed_credits
    @registed.each do |row|
      info = fetch_subject_info(row[0],row[1]) #id, year
      @registed_credits += info[0]["unit"].to_f # unit -> credit
    end

    return @registed_credits
  end

  def sum_others_credits
    #仮
    @others.each do |row|
      info = fetch_subject_info(row, BASE_YEAR) #id, year
      @others_credits += info[0]["unit"].to_f # unit -> credit
    end

    return @others_credits
  end

  def fetch_all_kdb     #kdbから該当科目を検索
    @keywords.each do |key|
      sql_rows = fetch_subject_info(key+"%", BASE_YEAR) #本年度kdb
      sql_rows.each do |row|
        @all << row[1]
      end
    end
  end

  def fetch_others(user) #未履修科目を抽出
    #登録済みを除く
    @others = @all - user.subjects_id
  end

  def classfiy_subjects(row)
        if row[2] != "" # row[2] = 評価
            if row[2] != "D" && row[2] != "F" #修得済み
              @earned << row
            else
              @failed << row
            end
      else #未修得 かつ 登録済み
            @registed << row
      end
  end

  def assign_subjects(row, user)    #与えられらた科目（row）を履修状況ごとに分類
    @keywords.each do |key|
      regexp = Regexp.new("^" + key)
      if regexp =~ row[0] #row[0] = 科目番号
        classfiy_subjects(row)
        user.subjects_assigned << row
      end
    end
 end

end
