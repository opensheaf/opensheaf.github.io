// Per-version statuses of every line, from the Explorer's own code (Archive.line).
// usage: node statuses_explorer.mjs EXPLORER_DIR ARCHIVE_URL OUT_JSON
import { writeFile } from 'node:fs/promises';
import { pathToFileURL } from 'node:url';
const [dir, url, out] = process.argv.slice(2);
const { Http } = await import(pathToFileURL(`${dir}/app/http.js`));
const { Archive } = await import(pathToFileURL(`${dir}/app/archive.js`));
const a = await Archive.open(new Http(), url);
const res = {};
for (const o of a.objects()) {
  if (o.kind === 'owner') continue;
  const line = await a.line(o.id);
  res[o.id] = line.statuses.map(String);
}
const sorted = Object.fromEntries(Object.keys(res).sort().map((k) => [k, res[k]]));
await writeFile(out, JSON.stringify(sorted, null, 1));
