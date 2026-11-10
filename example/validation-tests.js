// Run inside a Mac Catalyst Titanium app with ti.macos.panels installed.
// Invalid arguments must never present a panel or deliver a second callback.
exports.run = function (panels, done) {
  const failures = []
  const calls = []
  let assertions = 0
  function check(condition, message) {
    assertions++
    if (!condition) failures.push(message)
  }
  for (const method of ['pickFolder', 'pickFile', 'pickFiles', 'openDocument', 'openDocuments', 'saveFile']) {
    for (const [options, code] of [
      ['invalid-options', 'ERR_INVALID_OPTIONS'],
      [{ directoryURL: '/__ti_macos_panels_missing_directory__' }, 'ERR_INVALID_START_DIRECTORY']
    ]) {
      const result = panels[method](options)
      check(result && result.success === false && result.code === code, `${method} sync ${code}`)
      let count = 0
      const returned = panels[method](options, event => {
        count++
        check(event.success === false && event.code === code && event.cancelled === false,
          `${method} callback ${code}`)
      })
      check(returned == null, `${method} callback return ${code}`)
      calls.push(() => check(count === 1, `${method} exactly one callback ${code}: ${count}`))
    }
  }
  setTimeout(() => {
    calls.forEach(checkCount => checkCount())
    done({ assertions, failures, success: failures.length === 0 })
  }, 1000)
}
