# path
# path <- "D:/Rlian/Porj/ssc_list_stata"
getwd()

# 加载必要的包
library(rvest)
library(dplyr)
library(stringr)

# 基础 URL
base_url <- "https://econpapers.repec.org/software/bocbocode/"

# 获取总页数
get_total_pages <- function(url) {
  webpage <- read_html(url)
  pages <- webpage %>%
    html_nodes("div.issuelinks2 a") %>% 
    html_text(trim = TRUE)
  max(as.numeric(pages[!is.na(as.numeric(pages))]))
}

# 获取页面的内容
get_page_content <- function(page_url) {
  webpage <- read_html(page_url)
  
  titles <- webpage %>%
    html_nodes("dl dt a") %>%
    html_text(trim = TRUE) %>%
    tolower()  # 转为小写
  
  links <- webpage %>%
    html_nodes("dl dt a") %>%
    html_attr("href") %>%
    paste0(base_url, .)
  
  authors <- webpage %>%
    html_nodes("dl dd") %>%
    html_text(trim = TRUE) %>%
    str_replace_all(" and ", ", ") %>%  # 替换 "and" 为 ","
    str_replace_all("([a-zA-Z ]+)", "`\\1`")  # 给每个名字加反引号
  
  # 分解 titles 为 cmdName 和 description
  cmdName <- str_extract(titles, "^[^:]+")  # 提取 ":" 前的部分
  description <- str_trim(str_replace(titles, "^[^:]+:\\s*", ""))  # 提取 ":" 后的部分
  
  # 数据对齐：确保长度一致
  max_len <- max(length(cmdName), length(links), length(authors), length(description))
  cmdName <- c(cmdName, rep(NA, max_len - length(cmdName)))
  description <- c(description, rep(NA, max_len - length(description)))
  links <- c(links, rep(NA, max_len - length(links)))
  authors <- c(authors, rep(NA, max_len - length(authors)))
  
  data.frame(
    cmdName = cmdName,
    Description = description,
    Link = links,
    Authors = authors,
    stringsAsFactors = FALSE
  )
}

# 爬取所有页面内容
scrape_all_pages <- function(base_url, total_pages) {
  all_data <- list()
  
  for (i in 1:total_pages) {
    page_url <- ifelse(i == 1, 
                       paste0(base_url, "default.htm"), 
                       paste0(base_url, "default", i - 1, ".htm"))
    message("Scraping page: ", i)
    page_data <- get_page_content(page_url)
    all_data[[i]] <- page_data
  }
  
  do.call(rbind, all_data)
}

# 主流程
url <- paste0(base_url, "default.htm")
total_pages <- get_total_pages(url)
data <- scrape_all_pages(base_url, total_pages)

# 按字母分类
data$Letter <- toupper(substr(data$cmdName, 1, 1))  # 使用 cmdName 的首字母

# 保存 CSV 文件
csv_file_name <- paste0("ssc_list_", Sys.Date(), ".csv")
write.csv(data, csv_file_name, row.names = FALSE, fileEncoding = "UTF-8")

# 创建 Markdown 文本
generate_markdown <- function(data, file_name) {
  grouped_data <- data %>%
    arrange(Letter, cmdName) %>%
    group_by(Letter) %>%
    summarise(Content = paste0(
      "- [", cmdName, "](", Link, "): ", Description, ", ", Authors, collapse = "\n"
    ))
  
  header <- paste0(
    "# SSC 外部命令清单\n\n",
    "> 连享会: [lianxh.cn](https://www.lianxh.cn)    \n",
    "> Update: `", Sys.Date(), "`    \n",
    "> # of packages: ", nrow(data), "     \n",
    "> [github - R codes](https://github.com/arlionn/stata_ssc_list)&emsp; | &emsp; [ChatGPT](https://chatgpt.com/share/673c4d6d-49b0-8005-9ca0-753b67f88437)\n\n",
    "**相关推文：** \n",
    "- 连享会, 2023, [Stata外部命令：SSC所有外部命令清单-按时间排序](https://www.lianxh.cn/details/1297.html), 连享会 No.1297.\n",
    "- 连享会, 2022, [Stata外部命令：SSC所有外部命令清单-按类别排序](https://www.lianxh.cn/details/141.html), 连享会 No.141.\n\n",
    "**安装方法：** \n",
    "```stata\n",
    "ssc install pkgName, replace\n",
    "ssc install winsor2, replace  // Example\n",
    "```\n\n",
    "&emsp; \n\n"
  )
  
  body <- grouped_data %>%
    mutate(Content = paste0("## ", Letter, "\n", Content, "\n\n&emsp; \n\n")) %>%
    pull(Content) %>%
    paste(collapse = "")
  
  markdown_text <- paste0(header, body)
  
  writeLines(markdown_text, file_name)
}

# 保存 Markdown 文件
md_file_name <- paste0("ssc_list_", Sys.Date(), ".md")
generate_markdown(data, md_file_name)

message("Markdown 文件已生成: ", md_file_name)
message("CSV 文件已生成: ", csv_file_name)
