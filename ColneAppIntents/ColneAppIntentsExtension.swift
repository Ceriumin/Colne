import AppIntents

@main
struct ColneAppIntentsExtension: AppIntentsExtension {
    init() {
        AppDependencyManager.shared.add(dependency: Repository.shared)
    }
}
