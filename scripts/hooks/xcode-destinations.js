// Explicit destinations avoid Xcode 27 choosing an incompatible placeholder.
exports.cliVersion = '>=3.2'
exports.init = function (logger, config, cli) {
  cli.on('build.module.ios.xcodebuild', {
    pre(data, finished) {
      const args = data.args[1]
      const destinations = {
        iphoneos: 'generic/platform=iOS',
        iphonesimulator: 'generic/platform=iOS Simulator',
        macosx: 'generic/platform=macOS,variant=Mac Catalyst'
      }
      const sdkIndex = args.indexOf('-sdk')
      const destination = sdkIndex >= 0 && destinations[args[sdkIndex + 1]]
      if (destination && !args.some(arg => arg === '-destination' || arg.startsWith('-destination='))) {
        args.push('-destination', destination)
      }
      // Keep the header/framework SDK consistent with the CLI --sdk selection.
      args.push(`TITANIUM_SDK_VERSION=${cli.argv.sdk}`)
      finished()
    }
  })
}
