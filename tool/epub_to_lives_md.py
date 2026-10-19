#!/usr/bin/env python3
"""One-shot: convert assets/epubs/*.epub → assets/lives/*.md and update augustin_*.sqlite.

Usage:
  python3 tool/epub_to_lives_md.py [augustin_en.sqlite|augustin_ru.sqlite]
Default sqlite: augustin_en.sqlite when present, else augustin_ru.sqlite.
"""

from __future__ import annotations

import html
import re
import sqlite3
import sys
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
EPUB_DIR = ROOT / "assets" / "epubs"
OUT_DIR = ROOT / "assets" / "lives"
BOOKS_DIR = ROOT / "assets" / "books"


def default_sqlite() -> Path:
    en = BOOKS_DIR / "augustin_en.sqlite"
    ru = BOOKS_DIR / "augustin_ru.sqlite"
    if en.exists():
        return en
    if ru.exists():
        return ru
    raise SystemExit(f"No augustin_*.sqlite under {BOOKS_DIR}")


def extract_xhtml(epub_path: Path) -> str:
    with zipfile.ZipFile(epub_path) as zf:
        candidates = [
            n
            for n in zf.namelist()
            if n.lower().endswith((".xhtml", ".html", ".htm"))
            and "nav" not in n.lower()
            and not n.lower().endswith("nav.xhtml")
        ]
        if not candidates:
            raise RuntimeError(f"No content xhtml in {epub_path.name}")
        body = next((c for c in candidates if ".docx" in c or "main" in c.lower()), candidates[0])
        return zf.read(body).decode("utf-8", errors="replace")


def strip_tags(fragment: str) -> str:
    fragment = re.sub(r"<br\s*/?>", "\n", fragment, flags=re.I)
    fragment = re.sub(r"<[^>]+>", "", fragment)
    return html.unescape(fragment).strip()


def xhtml_to_markdown(xhtml: str) -> str:
    body_match = re.search(r"<body[^>]*>(.*)</body>", xhtml, flags=re.I | re.S)
    body = body_match.group(1) if body_match else xhtml

    paragraphs: list[str] = []
    for m in re.finditer(r"<p[^>]*>(.*?)</p>", body, flags=re.I | re.S):
        text = strip_tags(m.group(1))
        text = re.sub(r"[ \t]+", " ", text)
        text = re.sub(r"\n{3,}", "\n\n", text).strip()
        if text:
            paragraphs.append(text)

    if not paragraphs:
        text = strip_tags(body)
        text = re.sub(r"\n{3,}", "\n\n", text).strip()
        return text + "\n"

    title, *rest = paragraphs
    lines = [f"# {title}", ""]
    for p in rest:
        lines.append(p)
        lines.append("")
    return "\n".join(lines).rstrip() + "\n"


def convert_all() -> list[str]:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    converted: list[str] = []
    for epub in sorted(EPUB_DIR.glob("*.epub")):
        basename = epub.stem
        md_name = f"{basename}.md"
        xhtml = extract_xhtml(epub)
        md = xhtml_to_markdown(xhtml)
        (OUT_DIR / md_name).write_text(md, encoding="utf-8")
        converted.append(md_name)
        print(f"  {epub.name} → {md_name} ({len(md)} chars)")
    return converted


def update_sqlite(sqlite_path: Path) -> int:
    conn = sqlite3.connect(sqlite_path)
    cur = conn.cursor()
    rows = cur.execute("SELECT rowid, text FROM content").fetchall()
    updated = 0
    for rowid, text in rows:
        if text and ".epub" in text:
            new_text = text.replace(".epub", ".md")
            if new_text != text:
                cur.execute("UPDATE content SET text=? WHERE rowid=?", (new_text, rowid))
                updated += 1
    conn.commit()
    conn.close()
    return updated


def main() -> None:
    if not EPUB_DIR.is_dir():
        raise SystemExit(f"Missing {EPUB_DIR}")

    if len(sys.argv) > 1:
        name = sys.argv[1]
        sqlite_path = Path(name) if Path(name).is_absolute() else BOOKS_DIR / name
    else:
        sqlite_path = default_sqlite()

    if not sqlite_path.exists():
        raise SystemExit(f"Missing {sqlite_path}")

    print(f"Converting EPUBs in {EPUB_DIR} …")
    files = convert_all()
    print(f"Wrote {len(files)} markdown files to {OUT_DIR}")
    n = update_sqlite(sqlite_path)
    print(f"Updated {n} rows in {sqlite_path.name}")


if __name__ == "__main__":
    main()
