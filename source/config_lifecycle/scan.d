module config_lifecycle.scan;

import std.algorithm : startsWith;
import std.array : split;
import std.string : indexOf, strip, stripLeft;
import config_lifecycle.types;

/**
 * Parse npmrc / ini-like key=value lines.
 * Skips blank lines, `#` / `;` comments, and `//registry...:_authToken=` style
 * credential lines (keys containing `:_` after a host segment are still returned
 * but callers should avoid logging values).
 */
FoundKey[] parseKeyValueFile(string content, string sourcePath = "") {
    FoundKey[] keys;
    size_t lineNo = 0;
    foreach (line; content.split('\n')) {
        lineNo++;
        auto raw = line.strip();
        if (raw.length == 0)
            continue;
        if (raw.startsWith("#") || raw.startsWith(";"))
            continue;
        // registry auth lines: //host/:_authToken=...
        if (raw.startsWith("//") && raw.canFind(":_"))
            continue;
        auto eq = raw.indexOf('=');
        if (eq < 0)
            continue;
        auto name = raw[0 .. eq].strip();
        auto value = raw[eq + 1 .. $].strip();
        if (name.length == 0)
            continue;
        keys ~= FoundKey(name, value, sourcePath, lineNo);
    }
    return keys;
}

private bool canFind(string s, string sub) pure @safe {
    return s.indexOf(sub) >= 0;
}
