allprojects {
    repositories {
        // Prefer our rebuilt NanoHttpd (org.nanohttpd.* packages) over Maven Central
        // org.nanohttpd:2.3.1 which ships the older fi.iki.elonen.* package names.
        maven { url = uri("${rootDir}/nanohttpd-repo") }
        google()
        mavenCentral()
        maven { url = uri("https://jitpack.io") }
    }

    // JitPack can no longer build NanoHttpd commit fd80618e93d (pulled in by
    // vocsy_epub_viewer → folioreader → r2-streamer-kotlin). Maven Central
    // 2.3.1 uses fi.iki.elonen packages, but r2-streamer expects org.nanohttpd
    // (RouterNanoHTTPD). Use a local rebuild with the correct package names.
    configurations.configureEach {
        resolutionStrategy.dependencySubstitution {
            substitute(module("com.github.NanoHttpd.nanohttpd:nanohttpd"))
                .using(module("org.nanohttpd:nanohttpd:2.3.2-ponomar"))
                .because("r2-streamer needs org.nanohttpd packages; Maven Central 2.3.1 is fi.iki.elonen")
            substitute(module("com.github.NanoHttpd.nanohttpd:nanohttpd-nanolets"))
                .using(module("org.nanohttpd:nanohttpd-nanolets:2.3.2-ponomar"))
                .because("r2-streamer needs org.nanohttpd.router; Maven Central 2.3.1 is fi.iki.elonen")
            substitute(module("org.nanohttpd:nanohttpd"))
                .using(module("org.nanohttpd:nanohttpd:2.3.2-ponomar"))
                .because("Force rebuilt NanoHttpd with org.nanohttpd packages")
            substitute(module("org.nanohttpd:nanohttpd-nanolets"))
                .using(module("org.nanohttpd:nanohttpd-nanolets:2.3.2-ponomar"))
                .because("Force rebuilt nanolets with org.nanohttpd.router")
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
