// Codex-style status line for Claude Code. Reads session JSON from stdin.
let raw = '';
process.stdin.on('data', (c) => (raw += c));
process.stdin.on('end', () => {
  let d = {};
  try { d = JSON.parse(raw); } catch {}

  const c = (code, s) => `\x1b[${code}m${s}\x1b[0m`;
  const yellow = (s) => c('38;5;222', s);
  const pink = (s) => c('38;5;211', s);
  const dim = (s) => c('2', s);
  const sep = dim(' · ');

  const pct = (n) => (typeof n === 'number' ? Math.round(n) : null);
  const fmt = (n) =>
    n >= 1e6 ? (n / 1e6).toFixed(1) + 'M' : n >= 1e3 ? (n / 1e3).toFixed(1) + 'k' : String(n || 0);

  const model = d.model?.display_name || d.model?.id || 'claude';
  const effort = d.effort?.level ? ` ${d.effort.level}` : '';

  const dir = d.workspace?.current_dir || d.cwd || '';
  const home = (process.env.USERPROFILE || process.env.HOME || '').replace(/\\/g, '/');
  let shown = dir.replace(/\\/g, '/');
  if (home && shown.toLowerCase() === home.toLowerCase()) shown = '~';
  else if (home && shown.toLowerCase().startsWith(home.toLowerCase() + '/')) shown = '~' + shown.slice(home.length);

  const parts = [yellow(model + effort), yellow(shown)];

  const used = pct(d.context_window?.used_percentage) ?? 0;
  const left = pct(d.context_window?.remaining_percentage) ?? 100 - used;
  parts.push(yellow(`Context ${left}% left`), yellow(`Context ${used}% used`));

  const h5 = pct(d.rate_limits?.five_hour?.used_percentage);
  const w7 = pct(d.rate_limits?.seven_day?.used_percentage);
  if (h5 !== null) parts.push(pink(`5h ${100 - h5}% left`));
  if (w7 !== null) parts.push(pink(`weekly ${100 - w7}% left`));

  parts.push(yellow(`${fmt(d.context_window?.total_input_tokens)} in`));
  parts.push(yellow(`${fmt(d.context_window?.total_output_tokens)} out`));

  process.stdout.write(parts.join(sep));
});
