module config_lifecycle.types;

/// Lifecycle status for a catalogued (or unknown) config key.
enum KeyStatus {
    active,
    deprecated_, /// JSON/wire value: "deprecated" (`deprecated` is a D keyword)
    expired,
    unknown,
}

string toString(KeyStatus s) pure @safe {
    final switch (s) {
    case KeyStatus.active:
        return "active";
    case KeyStatus.deprecated_:
        return "deprecated";
    case KeyStatus.expired:
        return "expired";
    case KeyStatus.unknown:
        return "unknown";
    }
}

KeyStatus parseKeyStatus(string s) pure @safe {
    switch (s) {
    case "active":
        return KeyStatus.active;
    case "deprecated":
        return KeyStatus.deprecated_;
    case "expired":
        return KeyStatus.expired;
    case "unknown":
        return KeyStatus.unknown;
    default:
        throw new Exception("unknown KeyStatus: " ~ s);
    }
}

/// One row in a key index / catalog.
struct KeyRecord {
    string name;
    KeyStatus status = KeyStatus.active;
    string since; /// tool version when this status became true
    string expiredAfter; /// last version that honored the key (expired)
    string successor; /// replacement key or "none"
    string rationale; /// URL or doc id
    string message; /// optional custom alert text
    string[] aliases;
}

/// A key found in a config source before classification.
struct FoundKey {
    string name;
    string value;
    string sourcePath;
    size_t lineNumber; /// 1-based; 0 if unknown
}

/// Classified finding ready for structured or human output.
struct Finding {
    FoundKey found;
    KeyStatus status;
    KeyRecord record; /// populated when status != unknown
    bool hasRecord;
}
