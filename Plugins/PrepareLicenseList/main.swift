import Foundation
import PackagePlugin

@main
struct PrepareLicenseList: BuildToolPlugin {
    struct SourcePackagesNotFoundError: Error & CustomStringConvertible {
        let description: String = "SourcePackages not found"
    }

    struct DerivedDataNotFoundError: Error & CustomStringConvertible {
        let description: String = "DerivedData not found"
    }

    func sourcePackages(_ pluginWorkDirectory: Path) throws -> Path {

        guard pluginWorkDirectory.string.contains("DerivedData") else {
            throw DerivedDataNotFoundError()
        }

        var path = pluginWorkDirectory
        while path.lastComponent != "Build", path.lastComponent != "SourcePackages" {
            path = path.removingLastComponent()
        }

        return path.removingLastComponent().appending("SourcePackages")
    }

    func makeBuildCommand(executablePath: Path, sourcePackagesPath: Path, outputPath: Path) -> Command {
        return .buildCommand(
            displayName: "Prepare LicenseList",
            executable: executablePath,
            arguments: [
                outputPath.string,
                sourcePackagesPath.string
            ],
            outputFiles: [
                outputPath.appending(["LicenseList.swift"])
            ]
        )
    }

    // This command works with the plugin specified in `Package.swift`.
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        return [
            makeBuildCommand(
                executablePath: try context.tool(named: "spp").path,
                sourcePackagesPath: try sourcePackages(context.pluginWorkDirectory),
                outputPath: context.pluginWorkDirectory
            )
        ]
    }
}
