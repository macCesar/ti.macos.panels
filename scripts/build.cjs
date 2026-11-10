const path = require('node:path')
const fs = require('node:fs')
const { spawnSync } = require('node:child_process')

const sdk = process.argv[2] || '13.2.0.GA'
const config = JSON.stringify({ paths: { hooks: [path.join(__dirname, 'hooks')] } })
const result = spawnSync('ti', [
  'build', '-p', 'ios', '--build-only', '--sdk', sdk,
  '--config', config, '--no-progress-bars'
], { cwd: path.join(__dirname, '..', 'ios'), stdio: 'inherit' })
if (result.error) console.error(result.error.message)
if (result.status !== 0) process.exit(result.status ?? 1)

const manifest = fs.readFileSync(path.join(__dirname, '..', 'ios', 'manifest'), 'utf8')
const version = manifest.match(/^version:\s*(\S+)/m)[1]
const zipPath = path.join(__dirname, '..', 'ios', 'dist', `ti.macos.panels-iphone-${version}.zip`)
const cleanup = spawnSync('/usr/bin/zip', ['-qd', zipPath, '*/.DS_Store', '__MACOSX/*'], { stdio: 'inherit' })
// zip returns 12 when the package has no matching metadata entries.
process.exit([0, 12].includes(cleanup.status) ? 0 : (cleanup.status ?? 1))
