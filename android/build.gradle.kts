allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Only relocate the build directory of in-tree projects. Included/external
// projects (Flutter plugins resolved from the pub cache) must keep their build
// directory inside their own project root, otherwise AGP 9 fails with
// "this and base files have different roots" when creating per-variant tasks.
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val inTree =
        project.projectDir.canonicalFile.path
            .startsWith(rootProject.projectDir.canonicalFile.path)
    if (inTree) {
        val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
        project.layout.buildDirectory.value(newSubprojectBuildDir)
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    val configureAndroid: Project.() -> Unit = {
        plugins.withId("com.android.library") {
            extensions.configure<com.android.build.api.dsl.LibraryExtension> {
                compileSdk = 36
            }
        }
        plugins.withId("com.android.application") {
            extensions.configure<com.android.build.api.dsl.ApplicationExtension> {
                compileSdk = 36
            }
        }
    }
    if (state.executed) {
        configureAndroid()
    } else {
        afterEvaluate { configureAndroid() }
    }
}


tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
