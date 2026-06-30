const express = require('express');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = process.env.PORT || 3000;
const ROOT = path.join(__dirname, '..');

// 뷰어 UI (public/) 를 최우선으로 서빙
app.use(express.static(path.join(__dirname, 'public')));

// 프로젝트 루트 전체를 정적 서빙 (iframe 내 HTML + 디자인시스템 CSS/JS 포함)
app.use(express.static(ROOT));

// API: 프로젝트별 02_기획화면 HTML 목록 반환
app.get('/api/screens', (req, res) => {
  const projectsDir = path.join(ROOT, 'projects');

  try {
    const projects = fs.readdirSync(projectsDir, { withFileTypes: true })
      .filter(d => d.isDirectory())
      .map(d => {
        const screenDir = path.join(projectsDir, d.name, '02_기획화면');
        let screens = [];

        if (fs.existsSync(screenDir)) {
          screens = fs.readdirSync(screenDir)
            .filter(f => f.endsWith('.html'))
            .sort()
            .map(f => {
              const base = f.replace('.html', '');
              const match = base.match(/^(SCR-[^_]+)_(.+)$/);
              return {
                filename: f,
                id: match ? match[1] : '—',
                name: match ? match[2] : base,
                path: `/projects/${d.name}/02_기획화면/${f}`
              };
            });
        }

        return { project: d.name, screens };
      })
      .filter(p => p.screens.length > 0);

    res.json(projects);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// SPA 딥링크 폴백 — /프로젝트/화면명 경로를 index.html 로 돌려줌
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.listen(PORT, () => {
  console.log('\n  ┌─────────────────────────────────────┐');
  console.log(`  │  🚀 기획화면 뷰어 실행 중              │`);
  console.log(`  │  → http://localhost:${PORT}             │`);
  console.log('  └─────────────────────────────────────┘\n');
});
