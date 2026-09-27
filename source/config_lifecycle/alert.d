module config_lifecycle.alert;

import std.format : format;
import config_lifecycle.types;

/// Whether this finding must produce a user-visible alert under the protocol.
bool needsAlert(const Finding f) pure @safe {
    return f.status == KeyStatus.deprecated_
        || f.status == KeyStatus.expired
        || f.status == KeyStatus.unknown;
}

/// Human-readable alert line (stderr-friendly).
string alertLine(const Finding f) pure @safe {
    auto key = f.found.name;
    auto where = f.found.sourcePath.length
        ? format("%s:%s", f.found.sourcePath, f.found.lineNumber)
        : format("line %s", f.found.lineNumber ? f.found.lineNumber : 0);

    if (f.hasRecord && f.record.message.length)
        return format("config-lifecycle: %s: %s (%s)", where, f.record.message, key);

    final switch (f.status) {
    case KeyStatus.active:
        return format("config-lifecycle: %s: active key %s", where, key);
    case KeyStatus.deprecated_:
        auto succ = f.record.successor.length ? f.record.successor : "(see docs)";
        auto since = f.record.since.length ? f.record.since : "unknown version";
        return format(
            "config-lifecycle: %s: deprecated key %s (since %s); use %s instead",
            where, key, since, succ);
    case KeyStatus.expired:
        auto after = f.record.expiredAfter.length ? f.record.expiredAfter : "a prior version";
        auto succ2 = f.record.successor.length ? f.record.successor : "remove this key";
        return format(
            "config-lifecycle: %s: expired key %s (expired after %s); value ignored; %s",
            where, key, after, succ2);
    case KeyStatus.unknown:
        return format(
            "config-lifecycle: %s: unknown key %s — not in catalog (typo, foreign tool, or missing index entry)",
            where, key);
    }
}
