module demo;

import std.file : exists, readText;
import std.path : buildPath;
import std.stdio;
import config_lifecycle;

void main(string[] args) {
    string catalogPath = "fixtures/example-catalog.json";
    string configPath = args.length > 1 ? args[1] : "fixtures/sample.npmrc";

    if (!exists(catalogPath)) {
        // When run via `dub run`, cwd is the package root; allow stringImport fallback path.
        catalogPath = buildPath("fixtures", "example-catalog.json");
    }

    auto catalog = Catalog.loadJson(readText(catalogPath));
    auto found = parseKeyValueFile(readText(configPath), configPath);
    auto findings = catalog.classify(found);

    size_t alerts;
    foreach (f; findings) {
        if (f.needsAlert) {
            stderr.writeln(f.alertLine);
            alerts++;
        } else {
            stdout.writefln("ok: %s (%s)", f.found.name, f.status.toString);
        }
    }
    stdout.writefln("scanned %s keys; %s alert(s)", findings.length, alerts);
}
