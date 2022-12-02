# GitHub Actions 入门教程

[P3TERX](https://p3terx.com/author/1/) • 2019-11-11 • [7 评论](javascript:void(0);) • 22475 阅读

## 前言

Github Ac­tions 是 GitHub 推出的持续集成 (Con­tin­u­ous in­te­gra­tion，简称 CI) 服务，它提供了配置非常不错的虚拟服务器环境，基于它可以进行构建、测试、打包、部署项目。简单来讲就是将软件开发中的一些流程交给云服务器自动化处理，比方说开发者把代码 push 到 GitHub 后它会自动测试、编译、发布。有了持续集成服务开发者就可以专心于写代码，其它乱七八糟的事情就不用管了，这样可以大大提高开发效率。本篇文章将介绍 GitHub Ac­tions 的基本使用方法。

## 申请 Actions 使用权

GitHub Ac­tions 目前（2019 年 11 月 11 日）还处在 `Beta` 阶段，需要[申请](https://p3terx.com/go/aHR0cHM6Ly9naXRodWIuY29tL2ZlYXR1cmVzL2FjdGlvbnMvc2lnbnVw)才能使用，申请后在仓库主页就可以看到 `Actions` 按钮了。



[![img](https://imgcdn.p3terx.com/post/20191111201337.png#vwid=1052&vhei=619)](https://imgcdn.p3terx.com/post/20191111201337.png#vwid=1052&vhei=619)



## 基础概念

- **workflow** （工作流程）：持续集成一次运行的过程。
- **job** （任务）：一个 workflow 由一个或多个 job 构成，含义是一次持续集成的运行，可以完成多个任务。
- **step**（步骤）：每个 job 由多个 step 构成，一步步完成。
- **action** （动作）：每个 step 可以依次执行一个或多个命令（action）。

## 虚拟环境

GitHub Ac­tions 为每个任务 (job) 都提供了一个虚拟机来执行，每台虚拟机都有相同的硬件资源：

- 2-core CPU
- 7 GB RAM 内存
- 14 GB SSD 硬盘空间

> 实测硬盘总容量为90G左右，可用空间为30G左右，评测详见：《[GitHub Actions 虚拟服务器环境简单评测](https://p3terx.com/archives/github-actions-virtual-environment-simple-evaluation.html)》

使用限制：

- 每个仓库只能同时支持20个 workflow 并行。
- 每小时可以调用1000次 GitHub API 。
- 每个 job 最多可以执行6个小时。
- 免费版的用户最大支持20个 job 并发执行，macOS 最大只支持5个。
- 私有仓库每月累计使用时间为2000分钟，超过后$ 0.008/分钟，公共仓库则无限制。

操作系统方面可选择 Win­dows server、Linux、ma­cOS，并预装了大量[软件包和工具](https://p3terx.com/go/aHR0cHM6Ly9oZWxwLmdpdGh1Yi5jb20vY24vYWN0aW9ucy9hdXRvbWF0aW5nLXlvdXItd29ya2Zsb3ctd2l0aC1naXRodWItYWN0aW9ucy9zb2Z0d2FyZS1pbnN0YWxsZWQtb24tZ2l0aHViLWhvc3RlZC1ydW5uZXJz)。

> **TIPS：** 虽然名称叫持续集成，但当所有任务终止和完成时，虚拟环境内的数据会随之清空，并不会持续。即每个新任务都是一个全新的虚拟环境。

## workflow 文件

GitHub Ac­tions 的配置文件叫做 work­flow 文件（官方中文翻译为 “工作流程文件”），存放在代码仓库的`.github/workflows` 目录中。work­flow 文件采用 YAML 格式，文件名可以任意取，但是后缀名统一为`.yml`，比如 `p3terx.yml`。一个库可以有多个 work­flow 文件，GitHub 只要发现`.github/workflows` 目录里面有`.yml` 文件，就会按照文件中所指定的触发条件在符合条件时自动运行该文件中的工作流程。在 Ac­tions 页面可以看到很多种语言的 work­flow 文件的模版，可以用于简单的构建与测试。



[![img](https://imgcdn.p3terx.com/post/20191112182333.png#vwid=1333&vhei=897)](https://imgcdn.p3terx.com/post/20191112182333.png#vwid=1333&vhei=897)



下面是一个简单的 work­flow 文件示例：

```yaml
name: Hello World
on: push
jobs:
  my_first_job:
    name: My first job
    runs-on: ubuntu-latest
    steps:
    - name: checkout
      uses: actions/checkout@master
    - name: Run a single-line script
      run: echo "Hello World!"
  my_second_job:
    name: My second job
    runs-on: macos-latest
    steps:
    - name: Run a multi-line script
      env:
        MY_VAR: Hello World!
        MY_NAME: P3TERX
      run: |
        echo $MY_VAR
        echo My name is $MY_NAME
```

示例文件运行截图：



[![img](https://imgcdn.p3terx.com/post/20191112200912.png#vwid=813&vhei=508)](https://imgcdn.p3terx.com/post/20191112200912.png#vwid=813&vhei=508)



## workflow 语法

> **TIPS：** 参照上面的示例阅读。

### name

`name` 字段是 work­flow 的名称。若忽略此字段，则默认会设置为 work­flow 文件名。

### on

`on` 字段指定 work­flow 的触发条件，通常是某些事件，比如示例中的触发事件是 `push`，即在代码 `push` 到仓库后被触发。`on` 字段也可以是事件的数组，多种事件触发，比如在 `push` 或 `pull_request` 时触发：

```yaml
on: [push, pull_request]
```

完整的事件列表，请查看[官方文档](https://p3terx.com/go/aHR0cHM6Ly9oZWxwLmdpdGh1Yi5jb20vY24vYWN0aW9ucy9hdXRvbWF0aW5nLXlvdXItd29ya2Zsb3ctd2l0aC1naXRodWItYWN0aW9ucy93b3JrZmxvdy1zeW50YXgtZm9yLWdpdGh1Yi1hY3Rpb25z)。下面是一些比较常见的事件：

<details open="" style="box-sizing: border-box; display: block; color: rgba(0, 0, 0, 0.86); font-family: &quot;Open Sans&quot;, &quot;PingFang SC&quot;, &quot;Hiragino Sans GB&quot;, &quot;Microsoft Yahei&quot;, &quot;WenQuanYi Micro Hei&quot;, &quot;Segoe UI Emoji&quot;, &quot;Segoe UI Symbol&quot;, Helvetica, Arial, -apple-system, system-ui, sans-serif; font-size: 18px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial;"><p style="box-sizing: border-box; margin: 0.92em 0px;">push 指定分支触发</p><pre class=" language-yaml line-numbers" style="box-sizing: border-box; font-family: Menlo, Monaco, Consolas, &quot;Courier New&quot;, monospace; font-size: 0.96em; position: relative; width: 820px; overflow: hidden; line-height: 1.5; border: 1px solid rgba(0, 0, 0, 0.05); border-radius: 5px; background: rgb(241, 243, 243); text-align: left; white-space: pre; word-spacing: normal; word-break: normal; overflow-wrap: normal; tab-size: 4; hyphens: none; counter-reset: linenumber 0;"><code class=" language-yaml" style="box-sizing: border-box; font-family: Menlo, Monaco, Consolas, &quot;Courier New&quot;, monospace; font-size: 1em; background: 0px 0px !important; padding: 10px 10px 10px calc(3em + 10px); border-radius: 3px; text-align: left; white-space: inherit; word-spacing: normal; word-break: normal; overflow-wrap: normal; tab-size: 4; hyphens: none; display: block; overflow: auto;"><span class="token key atrule" style="box-sizing: border-box; color: rgb(0, 119, 170);">on</span><span class="token punctuation" style="box-sizing: border-box; color: rgb(153, 153, 153);">:</span>
  <span class="token key atrule" style="box-sizing: border-box; color: rgb(0, 119, 170);">push</span><span class="token punctuation" style="box-sizing: border-box; color: rgb(153, 153, 153);">:</span>
    <span class="token key atrule" style="box-sizing: border-box; color: rgb(0, 119, 170);">branches</span><span class="token punctuation" style="box-sizing: border-box; color: rgb(153, 153, 153);">:</span>
      <span class="token punctuation" style="box-sizing: border-box; color: rgb(153, 153, 153);">-</span> master</code><span aria-hidden="true" class="line-numbers-rows" style="box-sizing: border-box; position: absolute; pointer-events: none; top: 10px; font-size: 17.28px; left: 0px; width: 3em; letter-spacing: -1px; border-right: 1px solid rgba(153, 153, 153, 0.2); user-select: none; background: rgb(241, 243, 243);"><span style="box-sizing: border-box; pointer-events: none; display: block; counter-increment: linenumber 1;"></span><span style="box-sizing: border-box; pointer-events: none; display: block; counter-increment: linenumber 1;"></span><span style="box-sizing: border-box; pointer-events: none; display: block; counter-increment: linenumber 1;"></span><span style="box-sizing: border-box; pointer-events: none; display: block; counter-increment: linenumber 1;"></span></span></pre><p style="box-sizing: border-box; margin: 0.92em 0px;">push tag 时触发</p><pre class=" language-yaml line-numbers" style="box-sizing: border-box; font-family: Menlo, Monaco, Consolas, &quot;Courier New&quot;, monospace; font-size: 0.96em; position: relative; width: 820px; overflow: hidden; line-height: 1.5; border: 1px solid rgba(0, 0, 0, 0.05); border-radius: 5px; background: rgb(241, 243, 243); text-align: left; white-space: pre; word-spacing: normal; word-break: normal; overflow-wrap: normal; tab-size: 4; hyphens: none; counter-reset: linenumber 0;"><code class=" language-yaml" style="box-sizing: border-box; font-family: Menlo, Monaco, Consolas, &quot;Courier New&quot;, monospace; font-size: 1em; background: 0px 0px !important; padding: 10px 10px 10px calc(3em + 10px); border-radius: 3px; text-align: left; white-space: inherit; word-spacing: normal; word-break: normal; overflow-wrap: normal; tab-size: 4; hyphens: none; display: block; overflow: auto;"><span class="token key atrule" style="box-sizing: border-box; color: rgb(0, 119, 170);">on</span><span class="token punctuation" style="box-sizing: border-box; color: rgb(153, 153, 153);">:</span>
  <span class="token key atrule" style="box-sizing: border-box; color: rgb(0, 119, 170);">push</span><span class="token punctuation" style="box-sizing: border-box; color: rgb(153, 153, 153);">:</span>
    <span class="token key atrule" style="box-sizing: border-box; color: rgb(0, 119, 170);">tags</span><span class="token punctuation" style="box-sizing: border-box; color: rgb(153, 153, 153);">:</span>
    <span class="token punctuation" style="box-sizing: border-box; color: rgb(153, 153, 153);">-</span> <span class="token string" style="box-sizing: border-box; color: rgb(102, 153, 0);">'v*'</span></code><span aria-hidden="true" class="line-numbers-rows" style="box-sizing: border-box; position: absolute; pointer-events: none; top: 10px; font-size: 17.28px; left: 0px; width: 3em; letter-spacing: -1px; border-right: 1px solid rgba(153, 153, 153, 0.2); user-select: none; background: rgb(241, 243, 243);"><span style="box-sizing: border-box; pointer-events: none; display: block; counter-increment: linenumber 1;"></span><span style="box-sizing: border-box; pointer-events: none; display: block; counter-increment: linenumber 1;"></span><span style="box-sizing: border-box; pointer-events: none; display: block; counter-increment: linenumber 1;"></span><span style="box-sizing: border-box; pointer-events: none; display: block; counter-increment: linenumber 1;"></span></span></pre><p style="box-sizing: border-box; margin: 0.92em 0px;">定时触发</p><pre class=" language-yaml line-numbers" style="box-sizing: border-box; font-family: Menlo, Monaco, Consolas, &quot;Courier New&quot;, monospace; font-size: 0.96em; position: relative; width: 820px; overflow: hidden; line-height: 1.5; border: 1px solid rgba(0, 0, 0, 0.05); border-radius: 5px; background: rgb(241, 243, 243); text-align: left; white-space: pre; word-spacing: normal; word-break: normal; overflow-wrap: normal; tab-size: 4; hyphens: none; counter-reset: linenumber 0;"><code class=" language-yaml" style="box-sizing: border-box; font-family: Menlo, Monaco, Consolas, &quot;Courier New&quot;, monospace; font-size: 1em; background: 0px 0px !important; padding: 10px 10px 10px calc(3em + 10px); border-radius: 3px; text-align: left; white-space: inherit; word-spacing: normal; word-break: normal; overflow-wrap: normal; tab-size: 4; hyphens: none; display: block; overflow: auto;"><span class="token key atrule" style="box-sizing: border-box; color: rgb(0, 119, 170);">schedule</span><span class="token punctuation" style="box-sizing: border-box; color: rgb(153, 153, 153);">:</span>
  <span class="token punctuation" style="box-sizing: border-box; color: rgb(153, 153, 153);">-</span> <span class="token key atrule" style="box-sizing: border-box; color: rgb(0, 119, 170);">cron</span><span class="token punctuation" style="box-sizing: border-box; color: rgb(153, 153, 153);">:</span> 0 */6 * * *</code><span aria-hidden="true" class="line-numbers-rows" style="box-sizing: border-box; position: absolute; pointer-events: none; top: 10px; font-size: 17.28px; left: 0px; width: 3em; letter-spacing: -1px; border-right: 1px solid rgba(153, 153, 153, 0.2); user-select: none; background: rgb(241, 243, 243);"><span style="box-sizing: border-box; pointer-events: none; display: block; counter-increment: linenumber 1;"></span><span style="box-sizing: border-box; pointer-events: none; display: block; counter-increment: linenumber 1;"></span></span></pre><p style="box-sizing: border-box; margin: 0.92em 0px;">发布 re­lease 触发</p><pre class=" language-yaml line-numbers" style="box-sizing: border-box; font-family: Menlo, Monaco, Consolas, &quot;Courier New&quot;, monospace; font-size: 0.96em; position: relative; width: 820px; overflow: hidden; line-height: 1.5; border: 1px solid rgba(0, 0, 0, 0.05); border-radius: 5px; background: rgb(241, 243, 243); text-align: left; white-space: pre; word-spacing: normal; word-break: normal; overflow-wrap: normal; tab-size: 4; hyphens: none; counter-reset: linenumber 0;"><code class=" language-yaml" style="box-sizing: border-box; font-family: Menlo, Monaco, Consolas, &quot;Courier New&quot;, monospace; font-size: 1em; background: 0px 0px !important; padding: 10px 10px 10px calc(3em + 10px); border-radius: 3px; text-align: left; white-space: inherit; word-spacing: normal; word-break: normal; overflow-wrap: normal; tab-size: 4; hyphens: none; display: block; overflow: auto;"><span class="token key atrule" style="box-sizing: border-box; color: rgb(0, 119, 170);">on</span><span class="token punctuation" style="box-sizing: border-box; color: rgb(153, 153, 153);">:</span>
  <span class="token key atrule" style="box-sizing: border-box; color: rgb(0, 119, 170);">release</span><span class="token punctuation" style="box-sizing: border-box; color: rgb(153, 153, 153);">:</span>
    <span class="token key atrule" style="box-sizing: border-box; color: rgb(0, 119, 170);">types</span><span class="token punctuation" style="box-sizing: border-box; color: rgb(153, 153, 153);">:</span> <span class="token punctuation" style="box-sizing: border-box; color: rgb(153, 153, 153);">[</span>published<span class="token punctuation" style="box-sizing: border-box; color: rgb(153, 153, 153);">]</span></code><span aria-hidden="true" class="line-numbers-rows" style="box-sizing: border-box; position: absolute; pointer-events: none; top: 10px; font-size: 17.28px; left: 0px; width: 3em; letter-spacing: -1px; border-right: 1px solid rgba(153, 153, 153, 0.2); user-select: none; background: rgb(241, 243, 243);"><span style="box-sizing: border-box; pointer-events: none; display: block; counter-increment: linenumber 1;"></span><span style="box-sizing: border-box; pointer-events: none; display: block; counter-increment: linenumber 1;"></span><span style="box-sizing: border-box; pointer-events: none; display: block; counter-increment: linenumber 1;"></span></span></pre><p style="box-sizing: border-box; margin: 0.92em 0px;">仓库被 star 时触发</p><pre class=" language-yaml line-numbers" style="box-sizing: border-box; font-family: Menlo, Monaco, Consolas, &quot;Courier New&quot;, monospace; font-size: 0.96em; position: relative; width: 820px; overflow: hidden; line-height: 1.5; border: 1px solid rgba(0, 0, 0, 0.05); border-radius: 5px; background: rgb(241, 243, 243); text-align: left; white-space: pre; word-spacing: normal; word-break: normal; overflow-wrap: normal; tab-size: 4; hyphens: none; counter-reset: linenumber 0;"><code class=" language-yaml" style="box-sizing: border-box; font-family: Menlo, Monaco, Consolas, &quot;Courier New&quot;, monospace; font-size: 1em; background: 0px 0px !important; padding: 10px 10px 10px calc(3em + 10px); border-radius: 3px; text-align: left; white-space: inherit; word-spacing: normal; word-break: normal; overflow-wrap: normal; tab-size: 4; hyphens: none; display: block; overflow: auto;"><span class="token key atrule" style="box-sizing: border-box; color: rgb(0, 119, 170);">on</span><span class="token punctuation" style="box-sizing: border-box; color: rgb(153, 153, 153);">:</span>
  <span class="token key atrule" style="box-sizing: border-box; color: rgb(0, 119, 170);">watch</span><span class="token punctuation" style="box-sizing: border-box; color: rgb(153, 153, 153);">:</span>
    <span class="token key atrule" style="box-sizing: border-box; color: rgb(0, 119, 170);">types</span><span class="token punctuation" style="box-sizing: border-box; color: rgb(153, 153, 153);">:</span> <span class="token punctuation" style="box-sizing: border-box; color: rgb(153, 153, 153);">[</span>started<span class="token punctuation" style="box-sizing: border-box; color: rgb(153, 153, 153);">]</span></code><span aria-hidden="true" class="line-numbers-rows" style="box-sizing: border-box; position: absolute; pointer-events: none; top: 10px; font-size: 17.28px; left: 0px; width: 3em; letter-spacing: -1px; border-right: 1px solid rgba(153, 153, 153, 0.2); user-select: none; background: rgb(241, 243, 243);"><span style="box-sizing: border-box; pointer-events: none; display: block; counter-increment: linenumber 1;"></span><span style="box-sizing: border-box; pointer-events: none; display: block; counter-increment: linenumber 1;"></span><span style="box-sizing: border-box; pointer-events: none; display: block; counter-increment: linenumber 1;"></span></span></pre><p style="box-sizing: border-box; margin: 0.92em 0px;"></p></details>



### jobs

`jobs` 表示要执行的一项或多项任务。每一项任务必须关联一个 ID (`job_id`)，比如示例中的 `my_first_job` 和 `my_second_job`。`job_id` 里面的 `name` 字段是任务的名称。`job_id` 不能有空格，只能使用数字、英文字母和 `-` 或`_`符号，而 `name` 可以随意，若忽略 `name` 字段，则默认会设置为 `job_id`。

当有多个任务时，可以指定任务的依赖关系，即运行顺序，否则是同时运行。

```yaml
jobs:
  job1:
  job2:
    needs: job1
  job3:
    needs: [job1, job2]
```

上面代码中，`job1` 必须先于 `job2` 完成，而 `job3` 等待 `job1` 和 `job2` 的完成才能运行。因此，这个 work­flow 的运行顺序依次为：`job1`、`job2`、`job3`。

### runs-on

`runs-on` 字段指定任务运行所需要的虚拟服务器环境，是必填字段，目前可用的虚拟机如下：

> **TIPS：** 每个任务的虚拟环境都是独立的。

| 虚拟环境               | YAML workflow 标签                |
| :--------------------- | :-------------------------------- |
| Windows Server 2019    | `windows-latest`                  |
| Ubuntu 18.04           | `ubuntu-latest` or `ubuntu-18.04` |
| Ubuntu 16.04           | `ubuntu-16.04`                    |
| macOS X Catalina 10.15 | `macos-latest`                    |

### steps

`steps` 字段指定每个任务的运行步骤，可以包含一个或多个步骤。步骤开头使用 `-` 符号。每个步骤可以指定以下字段:

- `name`：步骤名称。
- `uses`：该步骤引用的`action`或 Docker 镜像。
- `run`：该步骤运行的 bash 命令。
- `env`：该步骤所需的环境变量。

其中 `uses` 和 `run` 是必填字段，每个步骤只能有其一。同样名称也是可以忽略的。

## action

`action` 是 GitHub Ac­tions 中的重要组成部分，这点从名称中就可以看出，`actions` 是 `action` 的复数形式。它是已经编写好的步骤脚本，存放在 GitHub 仓库中。

对于初学者来说可以直接引用其它开发者已经写好的 `action`，可以在[官方 action 仓库](https://p3terx.com/go/aHR0cHM6Ly9naXRodWIuY29tL2FjdGlvbnM)或者 [GitHub Marketplace](https://p3terx.com/go/aHR0cHM6Ly9naXRodWIuY29tL21hcmtldHBsYWNlP3R5cGU9YWN0aW9ucw) 去获取。此外 [Awesome Actions](https://p3terx.com/go/aHR0cHM6Ly9naXRodWIuY29tL3NkcmFzL2F3ZXNvbWUtYWN0aW9ucw) 这个项目收集了很多非常不错的 `action`。

既然 `action` 是代码仓库，当然就有版本的概念。引用某个具体版本的 `action`：

```yaml
steps:
  - uses: actions/setup-node@74bc508 # 指定一个 commit
  - uses: actions/setup-node@v1.2    # 指定一个 tag
  - uses: actions/setup-node@master  # 指定一个分支
```

一般来说 `action` 的开发者会说明建议使用的版本。

