const assert = require('node:assert/strict')
const test = require('node:test')
const hook = require('../scripts/hooks/xcode-destinations.js')

function apply(args) {
  let pre
  let completed = false
  hook.init(null, null, {
    argv: { sdk: '13.2.0.GA' },
    on(name, handlers) {
      assert.equal(name, 'build.module.ios.xcodebuild')
      pre = handlers.pre
    }
  })
  pre({ args: ['xcodebuild', args] }, () => { completed = true })
  assert.equal(completed, true)
  assert.ok(args.includes('TITANIUM_SDK_VERSION=13.2.0.GA'))
  return args
}

for (const [sdk, destination] of Object.entries({
  iphoneos: 'generic/platform=iOS',
  iphonesimulator: 'generic/platform=iOS Simulator',
  macosx: 'generic/platform=macOS,variant=Mac Catalyst'
})) {
  test(`selects ${sdk} destination`, () => {
    const args = apply(['archive', '-sdk', sdk])
    assert.equal(args[args.indexOf('-destination') + 1], destination)
  })
}
test('preserves an explicit destination', () => {
  const args = apply(['archive', '-sdk', 'macosx', '-destination', 'id=existing'])
  assert.equal(args.filter(arg => arg === '-destination').length, 1)
  assert.ok(args.includes('id=existing'))
})
