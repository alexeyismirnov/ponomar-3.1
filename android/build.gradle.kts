allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://jitpack.io") }
    }

    // JitPack can no longer build NanoHttpd commit fd80618e93d (pulled in by
    // vocsy_epub_viewer → folioreader → r2-streamer-kotlin). Use Maven Central.
    configurations.configureEach {
        resolutionStrategy.dependencySubstitution {
            substitute(module("com.github.NanoHttpd.nanohttpd:nanohttpd"))
                .using(module("org.nanohttpd:nanohttpd:2.3.1"))
                .because("JitPack NanoHttpd build is broken; use Maven Central")
            substitute(module("com.github.NanoHttpd.nanohttpd:nanohttpd-nanolets"))
                .using(module("org.nanohttpd:nanohttpd-nanolets:2.3.1"))
                .because("JitPack NanoHttpd build is broken; use Maven Central")
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
