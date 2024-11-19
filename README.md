# stata_ssc_list
get all Stata commands contributed at SSC.

## Output using Stata

- [连享会](https://www.lianxh.cn/search.html?s=连享会), 2024, [Stata外部命令：SSC所有外部命令清单-按时间排序](https://www.lianxh.cn/details/1297.html), 连享会 No.1297.
- [连享会](https://www.lianxh.cn/search.html?s=连享会), 2024, [Stata外部命令：SSC所有外部命令清单-按类别排序](https://www.lianxh.cn/details/141.html), 连享会 No.141.
- Stata codes
  - [stata_ssc_list.do](https://github.com/arlionn/stata_ssc_list/blob/main/stata_ssc_list.do)
  - Usage: download, and do it (**Ctrl+D**). 

## Output using R
- 连享会, 2024, [Stata外部命令：SSC所有外部命令清单-按首字母分类](https://www.lianxh.cn/details/1501.html), 连享会 No.1501.
- R codes
  - [stata_ssc_list_R_codes.r](https://github.com/arlionn/stata_ssc_list/blob/main/stata_ssc_list_R_codes.r)

<br>
<br>

# SSC External Commands Archive for Stata

This repository provides a comprehensive set of scripts and methods for building a catalog of Stata external commands available on SSC and GitHub. It supports downloading, organizing, and exporting these commands into Markdown files for easier browsing and reference. Below is an overview of the functionality and key features of the project.

---

## Features

- **Automated Download and Processing**:
  - Fetch command lists from SSC (sorted alphabetically or by category).
  - Retrieve help files and associated metadata (e.g., release dates).

- **Markdown Export**:
  - Generate user-friendly Markdown files for external command documentation.
  - Export sorted lists:
    - **Alphabetically (A–Z)**
    - **Chronologically (by release date)**

- **Regular Expressions**:
  - Includes tools for extracting and formatting metadata using regular expressions.
  - Enables batch processing of SSC `.hlp` and `.sthlp` files.

- **Customization**:
  - Easily update paths and configurations via global variables.
  - Organize outputs into structured folders for commands, help files, and Markdown documentation.

---

## File Structure

```
/
├── data_cmd/         # Stores command name index files
├── data_hlp/         # Stores help files metadata
├── md/               # Output folder for Markdown files
├── SSC_list_final.dta # Final processed dataset
└── ssc_commands.do   # Main Stata script
```

---

## Usage

### 1. Prerequisites
- Ensure Stata is installed on your system.
- Create the required directory structure:
  - `data_cmd/`
  - `data_hlp/`
  - `md/`

### 2. Run the Script
Set the global paths in the script:

```stata
global path "D:\stata\personal\lianxh_SSC"
```

Then execute the `ssc_commands.do` script in Stata:

```stata
do ssc_commands.do
```

This script will:
1. Download command names and help files.
2. Process and organize the data.
3. Export Markdown files for documentation.

### 3. Output Markdown Files
- **Alphabetically Sorted List**:
  - Stored as `md/SSC所有外部命令清单a_z_<date>.md`.
- **Date Sorted List**:
  - Stored as `md/SSC所有外部命令清单_date_<date>.md`.

---

## Sample Output

### Alphabetical List Example
```markdown
## SSC - Stata 外部命令列表
> [命令清单-按时间排序](https://www.lianxh.cn/details/1297.html) &ensp; 2023/11/20 &emsp; | &emsp; [连享会](https://www.lianxh.cn) &ensp; [知乎](https://www.zhihu.com/people/arlionn/)

### A
- [aaniv](http://fmwww.bc.edu/repec/bocode/a/aaniv.hlp) Module to compute unbiased IV regression
- [abbrev](http://fmwww.bc.edu/repec/bocode/a/abbrev.hlp) Abbreviation utilities
```

### Date-Sorted List Example
```markdown
## SSC - Stata 外部命令列表 - 按时间排序
> [命令清单-按字母排序](https://www.lianxh.cn/details/141.html) &ensp; 2023/11/20 &emsp; | &emsp; [连享会](https://www.lianxh.cn) &ensp; [知乎](https://www.zhihu.com/people/arlionn/)

### 2023
- [xttools](http://fmwww.bc.edu/repec/bocode/x/xttools.hlp) Extended tools for panel data analysis `2023-11-18`
- [mycmd](http://fmwww.bc.edu/repec/bocode/m/mycmd.hlp) Custom command module `2023-10-25`
```

---

## References

- [连享会外部命令清单 (按时间排序)](https://www.lianxh.cn/details/1297.html)
- [连享会外部命令清单 (按类别排序)](https://www.lianxh.cn/details/141.html)
- [GitHub Repository for `githubtools`](https://github.com/haghish/githubtools)
- [GitHub Repository for `ssczip`](https://github.com/haghish/ssczip)

---

## Future Work

- Automate the SSC hot updates for recent releases.
- Expand compatibility with other repositories or user-specific custom commands.

For any issues or contributions, feel free to open a pull request or contact the repository maintainer.
