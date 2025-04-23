# Run like:
#   ./build.sh <db.sqlite3> <members.tsv> <clusters.tsv>
# Where:
#   members.tsv  = rep_id, mem_id, flag, tax_id
#   members.tsv  = rep_id, mem_id, flag, tax_id, biome_id
#   clusters.tsv = acc, isOnlyESM, nMem, nAllMem, repPlddt, avgPlddt, avgAllPlddt, repLen, avgLen, avgAllLen, LCAtaxID, nBiome, LCBID


sqlite3 $1 << EOF

DROP TABLE IF EXISTS member;

CREATE TABLE member (
	accession TEXT PRIMARY KEY,
	rep_accession TEXT,
	tax_id TEXT,
	biome_id TEXT,
	flag INTEGER
);



PRAGMA journal_mode=OFF;
PRAGMA synchronous=OFF;
PRAGMA locking_mode=EXCLUSIVE;
PRAGMA temp_store=file;
PRAGMA cache_size=4000000000;
PRAGMA max_page_limit=13107200;

-- Import data into temp tables
.mode tabs

CREATE TABLE tmpMember (
	rep_id TEXT,
	mem_id TEXT,
	tax_id TEXT,
	biome_id TEXT,
	flag INTEGER
);

.import "${2}" tmpMember

-- Process names
UPDATE tmpMember
SET rep_id = REPLACE(rep_id, 'AF-', ''),
    mem_id = REPLACE(mem_id, 'AF-', '');
UPDATE tmpMember
SET rep_id = REPLACE(rep_id, '-F1-model_v4', ''),
    mem_id = REPLACE(mem_id, '-F1-model_v4', '');

-- Insert members & index on accession
INSERT INTO member (accession, rep_accession, flag, tax_id, biome_id)
SELECT mem_id, rep_id, flag, tax_id, biome_id
FROM tmpMember;

-- Index on member accessions
CREATE INDEX member_acc_idx
ON member(accession);

-- Index on member representative accessions
CREATE INDEX member_rep_idx
ON member(rep_accession);


-- Cleanup
DROP TABLE IF EXISTS tmpMember;
DROP TABLE IF EXISTS tmpCluster;
EOF

