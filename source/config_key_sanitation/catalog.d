module config_key_sanitation.catalog;

import std.algorithm : canFind;
import std.exception : enforce;
import std.json;
import config_key_sanitation.types;

/// In-memory key catalog loaded from a JSON index.
struct Catalog {
    string tool;
    int catalogVersion = 1;
    KeyRecord[] keys;

    private KeyRecord[string] byName;

    /// Load a Config Key Sanitation JSON catalog.
    static Catalog loadJson(string jsonText) {
        auto root = parseJSON(jsonText);
        Catalog c;
        if ("tool" in root)
            c.tool = root["tool"].str;
        if ("catalogVersion" in root)
            c.catalogVersion = cast(int) root["catalogVersion"].integer;
        enforce("keys" in root && root["keys"].type == JSONType.array, "catalog requires keys[]");
        foreach (ref node; root["keys"].array) {
            KeyRecord rec;
            rec.name = node["name"].str;
            rec.status = parseKeyStatus(node["status"].str);
            if ("since" in node)
                rec.since = node["since"].str;
            if ("expiredAfter" in node)
                rec.expiredAfter = node["expiredAfter"].str;
            if ("successor" in node)
                rec.successor = node["successor"].str;
            if ("rationale" in node)
                rec.rationale = node["rationale"].str;
            if ("message" in node)
                rec.message = node["message"].str;
            if ("aliases" in node) {
                foreach (a; node["aliases"].array)
                    rec.aliases ~= a.str;
            }
            c.keys ~= rec;
        }
        c.rebuildIndex();
        return c;
    }

    void rebuildIndex() {
        byName = null;
        foreach (ref rec; keys) {
            byName[rec.name] = rec;
            foreach (a; rec.aliases)
                byName[a] = rec;
        }
    }

    /// Look up by canonical name or alias.
    bool tryGet(string name, out KeyRecord rec) {
        if (auto p = name in byName) {
            rec = *p;
            return true;
        }
        return false;
    }

    /// Classify found keys. Unknown names become status unknown.
    Finding[] classify(FoundKey[] found) {
        Finding[] outFindings;
        foreach (fk; found) {
            Finding f;
            f.found = fk;
            KeyRecord rec;
            if (tryGet(fk.name, rec)) {
                f.status = rec.status;
                f.record = rec;
                f.hasRecord = true;
            } else {
                f.status = KeyStatus.unknown;
            }
            outFindings ~= f;
        }
        return outFindings;
    }

    /// True when the catalog still contains at least one expired row (protocol sanity).
    bool retainsExpiredEntries() const {
        return keys.canFind!(k => k.status == KeyStatus.expired);
    }
}
