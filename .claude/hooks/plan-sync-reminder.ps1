# 기획 산출물 변경 시 "산출물 동기화 & 변경 전파" 체크리스트를 Claude에 리마인드하는 PostToolUse 훅.
# 조건에 맞을 때만 additionalContext 를 출력하고, 그 외에는 조용히 통과(exit 0). 차단은 하지 않는다.
# 주의: 매칭 로직은 ASCII(0X_ 폴더 패턴)만 사용 — 한글 폴더명 인코딩에 의존하지 않음.
$ErrorActionPreference = 'SilentlyContinue'

$raw = [Console]::In.ReadToEnd()
if (-not $raw) { exit 0 }

try { $j = $raw | ConvertFrom-Json } catch { exit 0 }

$tool = $j.tool_name
if ($tool -ne 'Write' -and $tool -ne 'Edit') { exit 0 }

$fp = $j.tool_input.file_path
if (-not $fp) { exit 0 }

$p = $fp -replace '\\', '/'

# projects/<프로젝트>/0X_<단계폴더>/... .md|.html  (0X_ = 01~04 단계 폴더; 한글 포함 무관)
$inStep = $p -match '/projects/[^/]+/0[1-4]_[^/]+/.+\.(md|html)$'
if (-not $inStep) { exit 0 }

$msg = '기획 산출물이 변경되었습니다. CLAUDE.md의 [산출물 동기화 & 변경 전파] 프로토콜을 확인하세요: ' +
       '(1) .md<->.html 쌍이 모두 동기화됐는지, ' +
       '(2) 의존성 매트릭스에 따라 PRD/기획화면/화면흐름/결정로그 중 영향받는 문서를 함께 갱신했는지, ' +
       '(3) 각 문서의 [변경 이력] 표에 행을 추가하고 의사결정이면 결정로그.md에 D-### 항목을 추가했는지, ' +
       '(4) 사용자에게 영향 범위를 통지했는지. 누락이 있으면 지금 보완하세요.'

$out = [PSCustomObject]@{
  hookSpecificOutput = [PSCustomObject]@{
    hookEventName     = 'PostToolUse'
    additionalContext = $msg
  }
}

$out | ConvertTo-Json -Compress -Depth 5
exit 0
