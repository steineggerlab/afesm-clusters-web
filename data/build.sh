# Run like:
#   ./build.sh <db.sqlite3> <members.tsv> <clusters.tsv>
# Where:
#   members.tsv  = rep_id, mem_id, flag, tax_id
#   clusters.tsv = acc, is_dark, n_mem, rep_len, avg_len, rep_plddt, avg_plddt, lca_tax_id
#   clusters.tsv = acc, isOnlyESM, nMem, nAllMem, repPlddt, avgPlddt, avgAllPlddt, repLen, avgLen, avgAllLen, LCAtaxID, nBiome, LCBID


sqlite3 $1 << EOF
DROP TABLE IF EXISTS member;
DROP TABLE IF EXISTS cluster;
CREATE TABLE cluster (
	rep_accession TEXT PRIMARY KEY,
	is_only_esm BOOLEAN,
	n_mem INTEGER,
	n_all_mem INTEGER,
	rep_plddt REAL,
	avg_plddt REAL,
	avg_all_plddt REAL,
	rep_len INTEGER,
	avg_len REAL,
	avg_all_len REAL,
	lca_tax_id INTEGER,
	n_biome INTEGER,
	lcb_id INTEGER
);

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

CREATE TABLE tmpCluster (
	rep_id TEXT,
	is_only_esm BOOLEAN,
	n_mem INTEGER,
	n_all_mem INTEGER,
	rep_plddt REAL,
	avg_plddt REAL,
	avg_all_plddt REAL,
	rep_len INTEGER,
	avg_len REAL,
	avg_all_len REAL,
	lca_tax_id INTEGER,
	n_biome INTEGER,
	lcb_id INTEGER
);

CREATE TABLE tmpMember (
	rep_id TEXT,
	mem_id TEXT,
	flag INTEGER,
	tax_id TEXT,
	biome_id TEXT
);

.import "${2}" tmpMember
.import "${3}" tmpCluster

-- Process names
UPDATE tmpMember
SET rep_id = REPLACE(rep_id, 'AF-', ''),
    mem_id = REPLACE(mem_id, 'AF-', '');
UPDATE tmpMember
SET rep_id = REPLACE(rep_id, '-F1-model_v4', ''),
    mem_id = REPLACE(mem_id, '-F1-model_v4', '');
UPDATE tmpCluster
SET rep_id = REPLACE(rep_id, 'AF-', '');
UPDATE tmpCluster
SET rep_id = REPLACE(rep_id, '-F1-model_v4', '');


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

-- Insert clusters
INSERT INTO cluster (rep_accession, is_only_esm, n_mem, n_all_mem, rep_plddt, avg_plddt, avg_all_plddt, rep_len, avg_len, avg_all_len, lca_tax_id, n_biome, lcb_id)
SELECT rep_id, is_only_esm, n_mem, n_all_mem, rep_plddt, avg_plddt, avg_all_plddt, rep_len, avg_len, avg_all_len, lca_tax_id, n_biome, lcb_id
FROM tmpCluster;

-- Index on cluster representative accessions
CREATE INDEX cluster_rep_idx
ON cluster(rep_accession);

-- Index on cluster lca tax id
CREATE INDEX cluster_lca_tax_id_idx
ON cluster(lca_tax_id);

-- Cleanup
DROP TABLE IF EXISTS tmpMember;
DROP TABLE IF EXISTS tmpCluster;
EOF

