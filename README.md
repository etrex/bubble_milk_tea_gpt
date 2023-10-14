# README

此專案用來展示 GPT 作為飲料店店員 LINE Bot 的能力。

此專案使用 [kamigo](https://github.com/etrex/kamigo) 作為 LINE Bot 的框架，並且使用 OpenAI 的 ChatGPT API 作為核心的對話引擎。

自己實作了一個 Agent 類別，用來處理對話的邏輯，並且可以從環境變數中決定使用 GPT-3.5 或 GPT-4 作為對話引擎。

這是一個 Rails 專案，可以直接部署到 Heroku，需要設定的環境變數如下：

```
LINE_LOGIN_CHANNEL_ID=...
LINE_LOGIN_CHANNEL_SECRET=...

LINE_CHANNEL_SECRET=...
LINE_CHANNEL_TOKEN=...

LIFF_FULL=https://liff.line.me/...
LIFF_TALL=https://liff.line.me/...
LIFF_COMPACT=https://liff.line.me/...

# OPEN AI
OPENAI_API_KEY=
ENABLE_GPT=true
USE_GPT_4=false
```

## 部署到 Heroku

除了設定環境變數之外，還需要修改 config/application.rb 的 `config.hosts`，加入你的 Heroku domain

## 核心主程式

- app/processes/line_bot_process.rb
- app/services/agent.rb