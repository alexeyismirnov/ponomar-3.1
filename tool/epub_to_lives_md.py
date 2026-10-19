#!/usr/bin/env python3
"""One-shot: convert assets/epubs/*.epub → assets/lives/*.md and update augustin_ru.sqlite."""

from __future__ import annotations

import html
import os
import re
import sqlite3
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
EPUB_DIR = ROOT / "assets" / "epubs"
OUT_DIR = ROOT / "assets" / "lives"
SQLITE = ROOT / "assets" / "books" / "augustin_ru.sqlite"


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
        # Prefer the GoogleDoc body doc over nav
        body = next((c for c in candidates if ".docx" in c or "main" in c.lower()), candidates[0])
        return zf.read(body).decode("utf-8", errors="replace")


def strip_tags(fragment: str) -> str:
    fragment = re.sub(r"<br\s*/?>", "\n", fragment, flags=re.I)
    fragment = re.sub(r"<[^>]+>", "", fragment)
    return html.unescape(fragment).strip()


def xhtml_to_markdown(xhtml: str) -> str:
    # Drop head / style
    body_match = re.search(r"<body[^>]*>(.*)</body>", xhtml, flags=re.I | re.S)
    body = body_match.group(1) if body_match else xhtml

    paragraphs: list[str] = []
    for m in re.finditer(r"<p[^>]*>(.*?)</p>", body, flags=re.I | re.S):
        text = strip_tags(m.group(1))
        # Collapse internal whitespace but keep intentional newlines from <br>
        text = re.sub(r"[ \t]+", " ", text)
        text = re.sub(r"\n{3,}", "\n\n", text).strip()
        if text:
            paragraphs.append(text)

    if not paragraphs:
        # Fallback: whole-body text
        text = strip_tags(body)
        text = re.sub(r"\n{3,}", "\n\n", text).strip()
        return text + "\n"

    # First paragraph is typically the title (often was bold in the source)
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
        # Preserve odd filenames (trailing spaces etc.) via stem from Path
        md_name = f"{basename}.md"
        xhtml = extract_xhtml(epub)
        md = xhtml_to_markdown(xhtml)
        (OUT_DIR / md_name).write_text(md, encoding="utf-8")
        converted.append(md_name)
        print(f"  {epub.name} → {md_name} ({len(md)} chars)")
    return converted


def update_sqlite() -> int:
    conn = sqlite3.connect(SQLITE)
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
    print(f"Converting EPUBs in {EPUB_DIR} …")
    files = convert_all()
    print(f"Wrote {len(files)} markdown files to {OUT_DIR}")
    n = update_sqlite()
    print(f"Updated {n} rows in {SQLITE.name}")


if __name__ == "__main__":
    main()
