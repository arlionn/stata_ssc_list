
// SSC所有外部命令清单-按时间排序. https://www.lianxh.cn/details/1297.html
// SSC所有外部命令清单-按类别排序. https://www.lianxh.cn/details/141.html


*-SSC 外部命令清单

*-2023/11/20 9:34 更新
*-2022/4/20 9:52 更新
/*

提供了 ssc + github 外部命令的下载方式
https://github.com/haghish/githubtools  

https://github.com/haghish/githubtools/blob/master/Archive.do 

提供了直接下载的命令和方法

PACKAGE LIST
============
This file includes a series of code for building an archive of all existing 
Stata packages and repositories on GitHub and SSC. Executing this file may 
take many hours. 


https://github.com/haghish/ssczip
package and download Stata packages from SSC as a zip file

2020/5/26 9:59
net from "http://www.stata.com/users/"  其他用户的命令
*/

/*
- 正则表达式语法： 
  - 正则表达式30分钟入门教程
    https://deerchao.cn/tutorials/regex/regex.htm
  - Stata: 正则表达式和文本分析
    https://www.lianxh.cn/news/2f765cfd4bffe.html
  - 在 Visual Studio (vsCode) 中使用正则表达式
    https://www.lianxh.cn/news/39021047ce624.html

- 正则表达式测试：
  - 将 copy 下来的 cmd.txt 文档另存一份为 cmd.html 
    (只需修改后缀即可，单击文件名，按 F2，修改后缀即可)
  - 用 vscode 打开 cmd.html 文档，按 Ctrl+H，在搜索框中测试正则表达式即可
    多数情况下，vscode 的正则表达式规则都适用于 Stata 
	
- 另一个帮助文件连接：
  https://gitee.com/arlionn/stata-users-cmd/blob/master/README.md	
  
  参考 http://www.haghish.com/statistics/stata-blog/stata-programming/download/mgen.html
  的思路，可以把 SSC 上的 hlp 文件下载下来，转换为 html 或 md 文件，然后提供浏览功能
  写个循环应该就搞定了 
  
  参考程序：-ssc.ado- 》-sub.ssccopy-, -sub.sscinstall-
	
*/
	
global path "D:\stata\personal\lianxh_SSC"   // 酌情修改此路径

cd "$path"

cap mkdir data_cmd
cap mkdir data_hlp
cap mkdir md

global cmd  "$path/data_cmd"  // 存储命令名称文件的文件夹
global hlp  "$path/data_hlp"  // 存储帮助文件的文件夹
global md   "$path/md"        // 输出的 Markdown 文档

cd $cmd

*=================================
*
*- Part A: 下载命令名称 Index 文件
*
*=================================
*  `2021/9/5 15:46`
*  `2023/11/18 8:40`

cd $cmd

*-每次更新命令清单时，才需要执行这一段 
*
global list "a b c d e f g h i j k l m n o p q r s t u  v w x y z"
*global list "      x y z" //经常 timeout，所以要分几次进行
foreach v in $list{
  copy "http://fmwww.bc.edu/repec/bocode/`v'/stata.toc" "`v'_cmd.txt", replace
  infix strL v 1-1000 using "`v'_cmd.txt", clear
  save `v'_cmd.dta, replace
}
*

*-合并数据
use "$cmd/a_cmd.dta", clear 
global list "b c d e f g h i j k l m n o p q r s t u  v w x y z"
foreach v in $list{
  append using "`v'_cmd.dta"
}
format v %-100s
save "$cmd/_cmd_temp.dta", replace //临时保存


*-转换为 Markdown 文本

use "$cmd/_cmd_temp.dta", clear

/*
p aaniv module to compute unbiased IV regression
   to (去掉 「p 」)
aaniv module to compute unbiased IV regression
----- --------
As    Bs 
*/
gen v2 = ustrregexrf(v, "^p\s", "")

local regex `"^[\w\-]+"'  // 行首第一个单词，特殊情形：scheme-burd 
gen v3a = ustrregexs(0) if ustrregexm(v2, `"`regex'"') // As
gen v3b = ustrregexrf(v2,`"^\w+"',`""')                // Bs

gen v4 = "- `" + v3a + "` " + v3b // - `aainv`  module to xxx


keep v3* v4
rename v3a cmd           // 命令名称    
rename v3b cmd_describe  // 命令描述
rename v4  cmd_md

save "$cmd/_cmd_Markdown.dta", replace


/*
use "$cmd\_cmd_Markdown.dta", clear 
gen Cat = substr(cmd,1,1)
tab Cat
cls
tab cmd, sort
duplicates report cmd
*/



*===================================
*
*-Part B: 添加帮助文件链接+发布日期
*
*===================================

cd "$hlp"

**
global list "a b c d e f g h i j k l m n o p q r s t u  v w x y z"
cd "$hlp"
foreach v in $list{
  copy "http://fmwww.bc.edu/repec/bocode/`v'/" "`v'_hlp.txt", replace
  infix strL v 1-1000 using "`v'_hlp.txt", clear
  save `v'_hlp.dta, replace 
}


*-合并数据
use "$hlp/a_hlp.dta", clear 
global list "a b c d e f g h i j k l m n o p q r s t u  v w x y z"
gettoken a list : list
foreach v in $list{
  append using "$hlp/`v'_hlp.dta"
}
format v %-100s
save "$hlp/_hlp_text.dta", replace  //临时保存



*-----------------
*-抽取帮助文件名称
*-----------------

cd "$hlp"
use "$hlp\_hlp_text.dta", clear 
keep if strmatch(v,"*.hlp*")|strmatch(v,"*.sthlp*")  // 只保留帮助文件对应的行

*-帮助文件名称
*  (?<=hlp">)(.*)(?=</a>)
local regex = `"(?<=hlp">)(.*)(?=</a>)"'
gen cmd_hlp = ustrregexs(0) if ustrregexm(v, `"`regex'"')
  
*-命令名称
local regex = `"(^.*)\."'
gen cmd = ustrregexs(1) if ustrregexm(cmd_hlp, `"`regex'"') 

*-发布日期
*local regex = `"\d\d-\w{3}-\d{4}"'  // old format
local regex = `"\d{4}-\d{2}-\d{2}"' 
gen cmd_date= ustrregexs(0) if ustrregexm(v, `"`regex'"')

*-删除重复值
duplicates drop cmd_hlp cmd_date, force

cap drop dup
bysort cmd: egen dup=count(cmd)
gen date = date(cmd_date,"YMD")

bysort cmd: egen maxdate = max(date)
format date maxdate %td
keep if date==maxdate    //只保留最新版本

bysort cmd: egen dup2=count(cmd)
drop if strpos(cmd_hlp,".hlp")!=0 & dup2>1 //删除 .hlp 版本，保留 .sthlp 版本

*-保留最终变量
sort cmd
keep cmd cmd_hlp cmd_date date

save "$hlp\_hlp_Markdown.dta", replace  //帮助文件链接对应的 Markdown 文档


*-------------------
*-与命令描述文档合并 + 按 A-Z 排序
*-------------------

use "$hlp\_hlp_Markdown.dta", clear 
merge 1:1 cmd using "$cmd\_cmd_Markdown.dta"
tab _merge
drop if _merge==1  // 子程序等

*-增加分类标题 a, b, c, d 
  gen Cat = substr(cmd,1,1)
  keep if ustrregexm(Cat,"[a-z]")
  
  local URL "http://fmwww.bc.edu/repec/bocode/"
  gen url_hlp = "`URL'" + Cat + "/" + cmd_hlp

*-Markdown 格式的链接
  gen cmd_hlp_link = "- [" + cmd + "]" + "(" + url_hlp + ")"

*-完整命令条目：cmd + cmd_describe
  gen     cmd_full = cmd_hlp_link + " " + cmd_describe if _merge!=2
  replace cmd_full = "- `symbol' `" + cmd + "`	" + cmd_describe if _merge==2 // - `aainv`  module to xxxcmd_hlp_link 
  

*-二级标题 A - Z 
  egen tag = tag(Cat)
  expand 2 if tag==1, gen(tag_expand)  
  replace cmd = Cat if tag_expand==1 // 26 个首字母，否则 cmd 不能作为唯一标示
  gsort cmd -tag -tag_exp
  
  local URL "http://fmwww.bc.edu/repec/bocode/"
  *replace cmd_full = "### [**" + upper(Cat) + "**]" + "(" + "`URL'" + Cat + ")" if tag_expand==1   // 分类标题
  replace cmd_full = "### " + upper(Cat) if tag_expand==1   // 分类标题 
  
*-一级标题    SSC - Stata 外部命令列表 
  gen id123 = _n 
  global N = _N
  set obs `=_N+2'  //增加一行观察值，以便写大标题
  replace id123 = $N - _n in -2/-1
  replace cmd_full = "## SSC - Stata 外部命令列表" if id123==-2
  replace cmd_full = `"> [命令清单-按时间排序](https://www.lianxh.cn/details/1297.html)  &ensp;  `c(current_date)'  &emsp; | &emsp; [连享会](https://www.lianxh.cn) &ensp; [知乎](https://www.zhihu.com/people/arlionn/)"' if id123==-1
   
  sort id123 // 把一级标题排到前两行
  
*-变量标签  
  label var cmd          "命令名称"
  label var cmd_date     "命令发布日期"
  label var id123        "按首字母排序标示"
  label var cmd_hlp_link "命令帮助文件链接"
  keep cmd cmd_date date Cat cmd_hlp_link cmd_full id123 
  
  save "$path\SSC_list_final.dta", replace

*-输出 Markdown ：按首字母排序
  use "$path\SSC_list_final.dta", clear
  sort cmd 
  format cmd_full %-100s
  br 

  *-输出为 Markdown 文档
  local fn1 = subinstr("`c(current_date)'"," ","",3)
  format cmd_full %-100s
  local fn_cat `"$md/SSC所有外部命令清单a_z_`fn1'.md"'
  export delimited cmd_full using "`fn_cat'", ///
         novar nolabel delimiter(tab) replace


*-------------------
*-与命令描述文档合并 + 按 【日期】 排序
*-------------------		 

/*
use "$hlp\_hlp_Markdown.dta", clear 
merge 1:1 cmd using "$cmd\_cmd_Markdown.dta"
tab _merge
drop if _merge==1  // 子程序等		 

*-定义年度变量
  gen year = year(date)
*/
		 
*-输出 Markdown ：按日期排序
  use "$path\SSC_list_final.dta", clear
  drop if strpos(cmd_full, "#")!=0
  replace cmd_full = cmd_full + " " + "`" + cmd_date + "`"
  gsort -date cmd

*-二级标题 Year 排序
  gen year = year(date)
  tostring year, gen(yearStr) 
  *clonevar Cat = year
  gsort -date Cat
  egen tag = tag(year)
  expand 2 if tag==1, gen(tag_expand)  
  replace cmd = yearStr if tag_expand==1 // 年份
  gsort -date -tag -tag_exp
  
//replace cmd_full = "### **" + yearStr + "**"  if tag_expand==1   // 分类标题
  replace cmd_full = "### " + yearStr  if tag_expand==1   // 分类标题 
  
*-一级标题    SSC - Stata 外部命令列表 
  cap drop id123
  gen id123 = _n 
  global N = _N
  set obs `=_N+2'  //增加一行观察值，以便写大标题
  replace id123 = $N - _n in -2/-1
  replace cmd_full = "## SSC - Stata 外部命令列表 - 按时间排序" if id123==-2
  replace cmd_full = `"> [命令清单-按字母排序](https://www.lianxh.cn/details/141.html)  &ensp;  `c(current_date)'  &emsp; | &emsp; [连享会](https://www.lianxh.cn) &ensp; [知乎](https://www.zhihu.com/people/arlionn/)"' if id123==-1
   
  
   
  sort id123 // 把一级标题排到前两行
  
  *-输出为 Markdown 文档
  local fn1 = subinstr("`c(current_date)'"," ","",3)
  local fn_date `"$md/SSC所有外部命令清单_date_`fn1'.md"'
  export delimited cmd_full using "`fn_date'", ///
         novar nolabel delimiter(tab) replace

* 屏幕显示           
  noi dis " "
  noi dis _dup(58) "-" _n ///
  		_col(3)  `"{stata `" view  "`fn_cat'" "': View_Cat}"' ///
        _col(17) `"{stata `" winexec cmd /c start "" "`fn_cat'" "' : Open}"' ///
  		_col(30) `"{stata `" view  "`fn_date'" "': View_Cat}"' ///
        _col(50) `"{stata `" winexec cmd /c start "" "`fn_date'" "' : Open}"' 
  noi dis _dup(58) "-"

*-做两个版本，一个是按 A-Z 排序的，一个是按 Date 排序的

*-SSC hot 不用单独写了，直接从这里截取最近一个月的即可，每个月发布一次。

*-在 知乎 和 CSDN 设置连接，指向 lianxh.cn 页面，同时在码云放置 Stata dofile


