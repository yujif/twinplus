#! /usr/bin/ruby
# coding: utf-8

require_relative 'functions.rb'

DATABASE_FILENAME = CONFIG["database"]["filename"]
BASE_YEAR = CONFIG["database"]["base_year"]
COLUMN_NAMES = CONFIG["database"]["column_names"]
TABLE_NAME = CONFIG["database"]["table_name"]

#科目区分定義
SECTION_MAST = CONFIG["sections"]["mast"]
SECTION_BASE = CONFIG["sections"]["base"]

require_relative './model/user.rb'
require_relative './model/sections.rb'

class View
  attr_accessor :all_earned_credits, :all_registed_credits, :all_earned_tt_credits, :all_registed_tt_credits, :all_others_credits, :all_require_credits, :all_require_tt_credits

  def initialize(sections)
    @sections = sections
    @all_earned_credits = 0.0
    @all_earned_tt_credits = 0.0
    @all_registed_credits = 0.0
    @all_registed_tt_credits = 0.0
    @all_others_credits = 0.0
    @all_require_credits = 0.0
    @all_require_tt_credits = 0.0

    @sections.each do |key, sbj|
        @all_others_credits += sbj.sum_others_credits
      if sbj.name != "教職"
        @all_earned_credits += sbj.sum_earned_credits
        @all_registed_credits += sbj.sum_registed_credits
        @all_require_credits += sbj.require_credits
      else
        @all_earned_tt_credits += sbj.sum_earned_credits
        @all_registed_tt_credits += sbj.sum_registed_credits
        @all_require_tt_credits += sbj.require_credits
      end
    end

  end

 def render path
    content = File.read(File.expand_path(path))
    t = ERB.new(content)
    t.result(binding)
  end

  extend ERB::DefMethod
  def_erb_method('to_html', 'views/result.erb')

end

begin

  cgi = CGI.new
  sections = Hash.new()  #科目区分群
  user = User.new(cgi.params['file'][0])  #csvからユーザーの履修科目を読込

  #定義から科目区分を作成
  SECTION_MAST.each do |key_array, name, require_credits|
    eval("sections['#{key_array}']=  Sections.new(#{key_array},'#{name}','#{require_credits}',true) ")
  end
  SECTION_BASE.each do |key_array, name, require_credits|
   eval("sections['#{key_array}']=  Sections.new(#{key_array},'#{name}','#{require_credits}',false) ")
  end

  #ユーザーの履修科目を科目区分に振り分け
  user.subjects.each do |row|
    sections.each do |key, sbj|
       sbj.assign_subjects(row,user) if key #nilでないもののみ
    end
  end

  #未履修科目を取得
  sections.each do |key, sbj|
   sbj.fetch_others(user)
  end

#振り分けられなかったものから自由単位枠を作成
sections["free"] = Sections.new(nil,"自由","9",false)
user.subjects_free = user.subjects - user.subjects_assigned
user.subjects_free.each do |row|
  sections["free"].classfiy_subjects(row)
end

# 出力
print cgi.header("charset"=>"UTF-8")
print View.new(sections).to_html

rescue => e
  # エラー処理
  exception_handling(e, cgi)
#  db.close
end
